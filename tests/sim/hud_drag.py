from support import Disk,session
D=Disk();lua,_,_,_=session(D)
lua.execute(r'''
local input=TEST_SERVICES.UserInputService
local panel=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeStatus'):FindFirstChild('Watermark')
assert(panel:FindFirstChildOfClass('UICorner') and panel.Size.Y.Offset==30)
local press={UserInputType=Enum.UserInputType.MouseButton1,Position=Vector3.new(25,90,0)}
panel.InputBegan:Fire(press)
input.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseMovement,Position=Vector3.new(411,282,0)})
assert(panel.Position.X.Offset==400 and panel.Position.Y.Offset==270)
assert(TEST_OPTIONS.hudOffsetX.Value==14,'drag writes settings every movement')
input.InputEnded:Fire(press)
assert(TEST_OPTIONS.hudOffsetX.Value==400 and TEST_OPTIONS.hudOffsetY.Value==270,'final XY not committed together')
local open=TEST_LIBRARY.Toggled
panel.MouseButton1Click:Fire()assert(TEST_LIBRARY.Toggled==open,'drag clicked menu')
TEST_DRAIN()TEST_ACTIONS['Unload script']()
''')
lua,_,_,_=session(D)
lua.execute(r'''
local panel=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeStatus'):FindFirstChild('Watermark')
assert(panel.Position.X.Offset==400 and panel.Position.Y.Offset==270,'cold restore lost exact position')
TEST_SERVICES.RunService.RenderStepped:Fire(1.1)
assert(panel.Position.X.Offset==400 and panel.Position.Y.Offset==270,'FPS update moved panel')
TEST_ACTIONS['Unload script']()
''')
print('PASS rounded compact HUD drag, final-only XY commit, click suppression, exact cold restore and metric refresh')
