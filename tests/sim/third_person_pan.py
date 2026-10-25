from support import Disk,session
lua,source,_,_=session(Disk(),execute=False)
lua.execute(r"""
local scripts=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerScripts')
local module=scripts:FindFirstChild('PlayerModule')
local camera=Instance.new('ModuleScript')camera.Name='CameraModule'camera.Parent=module
local input=Instance.new('ModuleScript')input.Name='CameraInput'input.Parent=camera
PAN=false
function require(obj)assert(obj==input)return {getTogglePan=function()return PAN end,setTogglePan=function(v)PAN=v end}end
TEST_SERVICES.UserInputService.MouseDeltaSensitivity=.63
ORIGINAL_MOUSE=TEST_SERVICES.UserInputService.MouseBehavior
""")
lua.execute(source)
lua.execute(r"""
TEST_OPTIONS.camThird:SetValue(true)
local run=TEST_SERVICES.RunService
local ui=TEST_SERVICES.UserInputService
assert(run._render.PrimeVisualsThirdPan)
TEST_LIBRARY.Toggled=false
for i=1,100 do run._render.PrimeVisualsThirdPan() assert(PAN)end
TEST_LIBRARY.Toggled=true run._render.PrimeVisualsThirdPan()assert(not PAN and ui.MouseBehavior==ORIGINAL_MOUSE)
TEST_LIBRARY.Toggled=false run._render.PrimeVisualsThirdPan()assert(PAN)
TEST_OPTIONS.camThird:SetValue(false)assert(not PAN and ui.MouseBehavior==ORIGINAL_MOUSE)
assert(not run._render.PrimeVisualsThirdPan and ui.MouseDeltaSensitivity==.63)
TEST_OPTIONS.camThird:SetValue(true)run._render.PrimeVisualsThirdPan()assert(PAN)
TEST_ACTIONS['Unload script']()assert(not PAN and not run._render.PrimeVisualsThirdPan)
assert(ui.MouseDeltaSensitivity==.63)
""")
print('PASS native toggle pan, menu pause, reenable, disable/unload restore, unchanged sensitivity')
