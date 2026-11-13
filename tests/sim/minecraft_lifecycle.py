from support import Disk,session

for mode in ('disable','reenable','unload'):
 lua,_,_,_=session(Disk())
 lua.globals().LIFECYCLE_MODE=mode
 lua.execute(r"""
local player=TEST_SERVICES.Players.LocalPlayer
local gui=player:FindFirstChild('PlayerGui')
local original=game.HttpGet local fetches=0 local interrupted=false
local oldMode=player.CameraMode
local cached=true
TEST_OPTIONS.camThird:SetValue(true)
game.HttpGet=function(self,url)
 if url:find('/assets/minecraft/',1,true)then
  fetches=fetches+1
  if not interrupted then
   interrupted=true
   if LIFECYCLE_MODE=='unload'then TEST_ACTIONS['Unload script']()
   else
    TEST_OPTIONS.minecraftEnabled:SetValue(false)
    if LIFECYCLE_MODE=='reenable'then TEST_OPTIONS.minecraftEnabled:SetValue(true)end
   end
  end
 end
 return original(self,url)
end
TEST_OPTIONS.minecraftEnabled:SetValue(true)
TEST_DRAIN()
if LIFECYCLE_MODE=='reenable'then
 assert(TEST_OPTIONS.minecraftEnabled.Value)
 local count=0 for _,o in ipairs(gui:GetChildren())do if o.Name=='PrimeMinecraft'then count=count+1 end end
 assert(count==1,'rapid reenable built duplicate/stale HUD')
 TEST_OPTIONS.minecraftEnabled:SetValue(false)
else
 assert(not gui:FindFirstChild('PrimeMinecraft'),'cancelled asset load resurrected HUD')
 assert(fetches==1,'cancelled load continued downloading unused textures')
end
assert(not gui:FindFirstChild('PrimeMinecraft'))
assert(not TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftAttack)
if LIFECYCLE_MODE~='unload'then TEST_ACTIONS['Unload script']()end
""")
 print('PASS Minecraft asset-load interruption:',mode)
