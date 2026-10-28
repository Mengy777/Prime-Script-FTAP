from support import Disk,session,ROOT
import copy

def setup(disk=None):
 lua,source,_,_=session(disk or Disk(),execute=False)
 lua.execute(r'''
 TEST_STARTUP_MESSAGES={}
 TEST_SERVICES.StarterGui={SetCore=function(_,kind,info) assert(kind=='SendNotification'); table.insert(TEST_STARTUP_MESSAGES,info) end}
 TEST_MODULE_CALLS={}
 TEST_MODE='ok'
 function TEST_FAULT(file,mode)
  TEST_MODE=mode
  local previous=game.HttpGet
  game.HttpGet=function(self,url)
   if url:find('/lib/'..file..'.lua',1,true) then
    TEST_MODULE_CALLS[file]=(TEST_MODULE_CALLS[file] or 0)+1
    local n=TEST_MODULE_CALLS[file]
    if TEST_MODE=='offline' or (TEST_MODE=='transient' and n<3) then error('injected offline') end
    if TEST_MODE=='html' and n==1 then return '<html>temporary proxy response</html>' end
    if TEST_MODE=='badsyntax' then return '<html>invalid Lua</html>' end
    if TEST_MODE=='runtime' then return [[
      local _,track=...
      TEST_PARTIAL={ScreenGui=Instance.new('ScreenGui'),Signals={},ShowCursorBinding='PartialStartup'}
      TEST_PARTIAL.ScreenGui.Parent=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')
      TEST_PARTIAL.Signals[1]=TEST_SERVICES.RunService.RenderStepped:Connect(function()end)
      track(TEST_PARTIAL)
      TEST_SERVICES.UserInputService.MouseBehavior=Enum.MouseBehavior.Default
      TEST_SERVICES.UserInputService.MouseIconEnabled=false
      error('injected library runtime failure')
    ]] end
    if TEST_MODE=='artinit' then return [[return function(options)
      TEST_ART_CHILD=Instance.new('Frame') TEST_ART_CHILD.Parent=options.Parent
      TEST_ART_HEADER=Instance.new('Frame') TEST_ART_HEADER.Parent=options.Header
      options.Header.Image='broken://changed'
      error('injected artwork constructor failure')
    end]] end
   end
   return previous(self,url)
  end
 end
 function TEST_NO_LEAKS()
  assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==70.4)
  assert(TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter and TEST_SERVICES.UserInputService.MouseIconEnabled)
  local pg=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')
  for _,child in ipairs(pg:GetChildren()) do assert(child.Name~='PrimeVisuals' and child.ClassName~='ScreenGui','orphan GUI') end
  assert(not TEST_SERVICES.Workspace:FindFirstChild('PV_ESP'))
 end
 ''')
 return lua,source

for mode,expected in [('transient',3),('html',2)]:
 lu,s=setup();lu.execute(f"TEST_FAULT('Obsidian','{mode}')")
 lu.execute(s)
 lu.execute(f"assert(TEST_LIBRARY.Toggled and TEST_ACTIVE_TAB=='Home' and #TEST_STARTUP_MESSAGES==0); assert(TEST_MODULE_CALLS.Obsidian=={expected}); TEST_ACTIONS['Reset all settings'](); assert(TEST_MODULE_CALLS.Obsidian=={expected})")
print('PASS module HTTP/compile retry and successful-source cache reuse')

lu,s=setup();lu.execute("TEST_FAULT('Obsidian','offline')")
lu.execute(s)
lu.execute("assert(TEST_MODULE_CALLS.Obsidian==3 and #TEST_STARTUP_MESSAGES==1); TEST_NO_LEAKS()")
print('PASS mandatory HTTP failure: bounded retries, one native message, clean game and no GUI')

lu,s=setup();lu.execute("TEST_FAULT('Obsidian','runtime')")
lu.execute(s)
lu.execute("assert(TEST_MODULE_CALLS.Obsidian==1 and #TEST_STARTUP_MESSAGES==1); assert(TEST_PARTIAL.ScreenGui.Parent==nil and not TEST_PARTIAL.Signals[1].active); TEST_NO_LEAKS()")
lu.execute("TEST_MODE='ok'")
lu.execute(s)
lu.execute("assert(TEST_LIBRARY.Toggled and TEST_MODULE_CALLS.Obsidian==2)")
print('PASS partial library runtime failure: no unsafe re-execution, tracked GUI/signals/input restored, later startup succeeds')

D=Disk();lu,_,_,_=session(D);lu.execute("TEST_OPTIONS.cameraFOV:SetValue(97); TEST_DRAIN(); TEST_ACTIONS['Unload script']()")
before=copy.deepcopy(D.files)
lu,s=setup(D);lu.execute("TEST_FAULT('ConfigStore','offline')")
lu.execute(s)
lu.execute("assert(TEST_MODULE_CALLS.ConfigStore==3 and #TEST_STARTUP_MESSAGES==1 and TEST_LIBRARY.Unloaded); TEST_NO_LEAKS()")
assert D.files==before
print('PASS required config module failure cleans partially built effects and preserves stored profiles')

for mode in ('offline','badsyntax','artinit'):
 lu,s=setup()
 if mode=='artinit':
  lu.execute(r'''
  local old=TEST_NEW_LIBRARY
  TEST_NEW_LIBRARY=function(...)
   local lib=old(...);local create=lib.CreateWindow
   function lib:CreateWindow(info)
    local w=create(self,info);w.IconHolder.Image='native://diamond';TEST_NATIVE_WINDOW=w;return w
   end
   return lib
  end
  ''')
 lu.execute(f"TEST_FAULT('AnimatedEmblem','{mode}')")
 lu.execute(s)
 lu.execute("assert(TEST_LIBRARY.Toggled and #TEST_STARTUP_MESSAGES==0 and TEST_GROUPS['Prime Visuals'].BoxHolder.Visible==false); TEST_OPTIONS.cameraFOV:SetValue(94); assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==94)")
 if mode=='artinit': lu.execute("assert(TEST_MODULE_CALLS.AnimatedEmblem==1 and TEST_ART_CHILD.Parent==nil and TEST_ART_HEADER.Parent==nil and TEST_NATIVE_WINDOW.IconHolder.Image=='native://diamond')")
 else: lu.execute("assert(TEST_MODULE_CALLS.AnimatedEmblem==3)")
 if mode=='badsyntax':
  lu.execute("TEST_MODE='ok'; TEST_ACTIONS['Reset all settings'](); assert(TEST_MODULE_CALLS.AnimatedEmblem==4 and TEST_GROUPS['Prime Visuals'].BoxHolder.Visible~=false)")
print('PASS optional artwork HTTP/syntax/constructor failures keep menu functional and remove partial decorations')

lu,s=setup()
lu.execute(r'''
local old=TEST_NEW_LIBRARY
TEST_NEW_LIBRARY=function(...)
 local lib=old(...);local create=lib.CreateWindow
 function lib:CreateWindow(info)
  create(self,info)
  TEST_SERVICES.UserInputService.MouseBehavior=Enum.MouseBehavior.Default
  TEST_SERVICES.UserInputService.MouseIconEnabled=false
  error('injected CreateWindow failure')
 end
 return lib
end
''')
lu.execute(s)
lu.execute("assert(TEST_LIBRARY.Unloaded and #TEST_STARTUP_MESSAGES==1); TEST_NO_LEAKS()")
print('PASS CreateWindow failure is protected before the regular shutdown handler exists')

lu,s=setup();lu.execute(s)
lu.execute(r'''
local previous=game.HttpGet
game.HttpGet=function(self,url)
 if url:find('/lib/Mannequins.lua',1,true) then
  TEST_ACTIONS['Unload script']()
  return 'TEST_STALE_MODULE_EXECUTED=true; return function()end'
 end
 return previous(self,url)
end
TEST_OPTIONS.mannequinEnabled:SetValue(true)
assert(TEST_LIBRARY.Unloaded and not TEST_STALE_MODULE_EXECUTED and #TEST_STARTUP_MESSAGES==0)
''')
print('PASS late module response after unloading is cancelled before executing its code')

lu,s=setup()
lu.execute(r"""
TEST_FAULT('Obsidian','ok')
local previous=loadstring
local first=true
loadstring=function(...)
 if first then first=false error('injected compiler exception')end
 return previous(...)
end
""")
lu.execute(s)
lu.execute("assert(TEST_LIBRARY.Toggled and TEST_MODULE_CALLS.Obsidian==2 and #TEST_STARTUP_MESSAGES==0)")
print('PASS thrown compiler exception is retried without aborting startup')

lu,s=setup()
lu.execute(r"""
local previous=game.HttpGet
game.HttpGet=function(self,url)
 if url:find('Obsidian.lua',1,true) then return [[
  TEST_INVALID={ScreenGui=Instance.new('ScreenGui'),Signals=true}
  TEST_INVALID.ScreenGui.Parent=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')
  return TEST_INVALID
 ]] end
 return previous(self,url)
end
""")
lu.execute(s)
lu.execute("assert(TEST_INVALID.ScreenGui.Parent==nil and #TEST_STARTUP_MESSAGES==1); TEST_NO_LEAKS()")
print('PASS malformed library API and signal registry still cleanly report failure')

lu,s=setup();lu.execute("TEST_FAULT('LightingEditor','offline')")
lu.execute(s)
lu.execute("assert(TEST_MODULE_CALLS.LightingEditor==3 and #TEST_STARTUP_MESSAGES==1); TEST_NO_LEAKS()")
print('PASS advanced lighting module HTTP failure cleans partial startup without changing the game')
