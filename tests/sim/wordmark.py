from support import Disk,session
lua,_,_,_=session(Disk())
lua.execute(r'''
local screen=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeStatus')
local panel=screen:FindFirstChild('Watermark')local title,metrics
for _,child in ipairs(panel:GetChildren())do
 if child:IsA('TextLabel')then if child.RichText then title=child else metrics=child end end
end
assert(title and title.Font==Enum.Font.Arcade)
local _,count=title.Text:gsub('<font color=', '')assert(count==13,'wordmark letters not individually coloured')
assert(title:FindFirstChild('RainbowUnderline'):FindFirstChildOfClass('UIGradient'))
assert(panel:FindFirstChild('Omega').Size.X.Offset==26,'Omega not enlarged')
local text=title.Text
for i=1,5 do TEST_SERVICES.RunService.RenderStepped:Fire(1.1)end
assert(title.Text==text,'letter colours animated')
assert(metrics.Position.X.Offset==title.Position.X.Offset+title.Size.X.Offset+7,'FPS gap not compact')
assert(panel.Size.X.Offset==metrics.Position.X.Offset+metrics.Size.X.Offset+8,'panel contains trailing empty space')
TEST_ACTIONS['Unload script']()
''')
print('PASS shared pixel wordmark: thirteen fixed-colour letters, rainbow underline, enlarged Omega and tight measured FPS spacing')
