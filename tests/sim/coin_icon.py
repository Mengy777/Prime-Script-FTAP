from support import Disk,session
D=Disk();lua,source,_,_=session(D,execute=False)
SCENE=r"""
function COIN_SCENE()
 local pg=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')
 local function node(class,name,parent)local o=Instance.new(class)o.Name=name o.Parent=parent return o end
 local screen=node('ScreenGui','MenuGui',pg)
 local top=node('Frame','TopRight',screen)local frame=node('Frame','CoinsFrame',top)
 local button=node('TextButton','CoinsButton',frame)
 local display=node('Frame','CoinsDisplay',frame)
 local amount=node('TextLabel','Coins',display)amount.Text='2360'
 local icon=node('ImageLabel','CoinImage',display)icon.Image='rbxassetid://8659337867'icon.ImageTransparency=.15 icon.ZIndex=1 icon.Size=UDim2.fromOffset(80,80)
 local shop=node('Frame','Shop',screen)local price=node('ImageLabel','CoinImage',shop)price.ImageTransparency=.2
 return screen,display,icon,amount,price,button
end
SCREEN,DISPLAY,ICON,AMOUNT,PRICE,BUTTON=COIN_SCENE()
"""
lua.execute(SCENE);lua.execute(source)
lua.execute(r"""
assert(not TEST_OPTIONS.coinIconEnabled.Value and ICON.ImageTransparency==.15)
assert(not ICON:FindFirstChild('PV_CoinSymbol'))
TEST_OPTIONS.coinIconEnabled:SetValue(true)
local root=ICON:FindFirstChild('PV_CoinSymbol')assert(root and ICON.ImageTransparency==1)
assert(PRICE.ImageTransparency==.2 and AMOUNT.Text=='2360'and BUTTON.Parent)
assert(#root:GetChildren()>50,'sparkle fill and glow geometry missing')
local edge
for _,o in ipairs(root:GetChildren())do if o.BackgroundTransparency==.02 then edge=o break end end
assert(edge,'crisp rainbow contour missing')
TEST_SERVICES.RunService.Heartbeat:Fire(.04)local first=edge.BackgroundColor3
TEST_CLOCK=TEST_CLOCK+1 TEST_SERVICES.RunService.Heartbeat:Fire(.04)
assert(edge.BackgroundColor3.R~=first.R or edge.BackgroundColor3.G~=first.G,'hue does not animate')
AMOUNT.Text='2500'TEST_SERVICES.RunService.Heartbeat:Fire(.6)assert(AMOUNT.Text=='2500')
root:Destroy()TEST_SERVICES.RunService.Heartbeat:Fire(.6)
assert(ICON:FindFirstChild('PV_CoinSymbol'),'deleted overlay did not recover')
local old=ICON SCREEN:Destroy()
SCREEN,DISPLAY,ICON,AMOUNT,PRICE,BUTTON=COIN_SCENE()
TEST_SERVICES.RunService.Heartbeat:Fire(.6)
assert(ICON.ImageTransparency==1 and ICON:FindFirstChild('PV_CoinSymbol'))
TEST_OPTIONS.coinIconEnabled:SetValue(false)
assert(ICON.ImageTransparency==.15 and not ICON:FindFirstChild('PV_CoinSymbol'))
TEST_OPTIONS.coinIconEnabled:SetValue(true)TEST_DRAIN()
TEST_ACTIONS['Unload script']()
assert(ICON.ImageTransparency==.15 and not ICON:FindFirstChild('PV_CoinSymbol'))
""")
print('PASS default-off; exact native HUD-only icon; black concave sparkle and animated contour; balance/button/shop untouched; overlay/menu recovery; disable/unload restore')
lua,source,_,_=session(D,execute=False);lua.execute(SCENE);lua.execute(source)
lua.execute(r"""
TEST_SERVICES.RunService.Heartbeat:Fire(.6)
assert(TEST_OPTIONS.coinIconEnabled.Value and ICON.ImageTransparency==1)
TEST_OPTIONS.coinIconEnabled:SetValue(false)TEST_DRAIN()TEST_ACTIONS['Unload script']()
""")
print('PASS local autosave/cold restore of optional icon switch')
