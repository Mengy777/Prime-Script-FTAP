from support import ROOT,BASE
from pathlib import Path

def setup(mode='ok',target='Obsidian'):
 ns={'REPO':ROOT}
 exec(BASE.replace("assert(info.Title=='Prime Visuals')","assert(info.Title=='Prime Vortex')"),ns)
 lua=ns['lua']
 lua.globals().MODE=mode;lua.globals().TARGET=target
 lua.execute(r'''
TEST_STARTUP_MESSAGES={}
TEST_SERVICES.StarterGui={SetCore=function(_,_,info)table.insert(TEST_STARTUP_MESSAGES,info)end}
TEST_ENV={Library={Name='Visuals sentinel'}} getgenv=function()return TEST_ENV end
local new=Instance.new
Instance.new=function(class)
 local object=new(class)
 if class=='TextButton' then object.MouseButton1Click=object:GetPropertyChangedSignal('testClick') end
 return object
end
local oldFactory=TEST_NEW_LIBRARY
TEST_NEW_LIBRARY=function(privateGet)
 local lib=oldFactory();privateGet().Library=lib
 local oldUnload=lib.Unload
 function lib:Unload() oldUnload(self);privateGet().Library=nil end
 return lib
end
TEST_CALLS=0
game.HttpGet=function(_,url)
 if url:find('/lib/'..TARGET..'.lua',1,true) then
  TEST_CALLS=TEST_CALLS+1
  if MODE=='offline' or (MODE=='transient' and TEST_CALLS<3) then error('injected offline') end
  if MODE=='html' and TEST_CALLS==1 then return '<html>temporary error</html>' end
  if MODE=='runtime' then return [[
    local _,track=...
    TEST_PARTIAL={ScreenGui=Instance.new('ScreenGui'),Signals={},ShowCursorBinding='VortexPartial'}
    TEST_PARTIAL.ScreenGui.Parent=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')
    TEST_PARTIAL.Signals[1]=TEST_SERVICES.RunService.RenderStepped:Connect(function()end)
    track(TEST_PARTIAL)
    TEST_SERVICES.UserInputService.MouseIconEnabled=false
    error('injected Vortex library failure')
  ]] end
 end
 if url:find('AnimatedEmblem.lua',1,true) then return TEST_EMBLEM_SOURCE end
 return 'return TEST_NEW_LIBRARY(getgenv)'
end
''')
 return lua,(ROOT/'PrimeVortex.lua').read_text(encoding='utf-8-sig')

for mode,count in [('transient',3),('html',2)]:
 lua,source=setup(mode)
 result=lua.execute(source);lua.globals().RESULT=result
 lua.execute(f"assert(RESULT.Library.Toggled and TEST_CALLS=={count} and #TEST_STARTUP_MESSAGES==0); assert(TEST_ENV.Library.Name=='Visuals sentinel'); RESULT:Unload()")
print('PASS Vortex HTTP/compile retry keeps Visuals global library isolated')

for mode,count in [('offline',3),('runtime',1)]:
 lua,source=setup(mode)
 result=lua.execute(source)
 assert isinstance(result,tuple) and result[0] is None
 lua.execute(f"assert(TEST_CALLS=={count} and #TEST_STARTUP_MESSAGES==1 and TEST_ENV.PrimeVortexUI==nil and TEST_ENV.Library.Name=='Visuals sentinel'); assert(TEST_SERVICES.UserInputService.MouseIconEnabled)")
 if mode=='runtime':lua.execute("assert(TEST_PARTIAL.ScreenGui.Parent==nil and not TEST_PARTIAL.Signals[1].active)")
print('PASS mandatory Vortex failure clears partial GUI/signals/input and leaves Visuals intact')

lua,source=setup('offline','AnimatedEmblem')
result=lua.execute(source);lua.globals().RESULT=result
lua.execute("assert(RESULT.Library.Toggled and RESULT.Artwork.Unavailable and #TEST_STARTUP_MESSAGES==0 and TEST_CALLS==3); RESULT:Unload(); assert(TEST_ENV.PrimeVortexUI==nil)")
print('PASS Vortex optional artwork failure still opens and closes the main window')

lua,source=setup()
lua.execute(r'''
local old=TEST_NEW_LIBRARY
TEST_NEW_LIBRARY=function(...)
 local lib=old(...);local create=lib.CreateWindow
 function lib:CreateWindow(info)create(self,info);error('injected Vortex window failure')end
 return lib
end
''')
result=lua.execute(source)
assert isinstance(result,tuple) and result[0] is None
lua.execute("assert(TEST_LIBRARY.Unloaded and TEST_ENV.PrimeVortexUI==nil and TEST_ENV.Library.Name=='Visuals sentinel' and #TEST_STARTUP_MESSAGES==1)")
print('PASS Vortex failed window constructor cleans controller and library')

lua,source=setup()
lua.execute(r"""
local previous=game.HttpGet
game.HttpGet=function(self,url)
 if url:find('AnimatedEmblem.lua',1,true) then TEST_ENV.PrimeVortexUI:Unload();return TEST_EMBLEM_SOURCE end
 return previous(self,url)
end
""")
result=lua.execute(source)
assert isinstance(result,tuple) and result[0] is None
lua.execute("assert(TEST_ENV.PrimeVortexUI==nil and #TEST_STARTUP_MESSAGES==0 and TEST_ENV.Library.Name=='Visuals sentinel')")
print('PASS deliberate Vortex cancellation during download stays clean and does not emit a fatal-startup notification')
