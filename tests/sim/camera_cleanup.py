from support import Disk,session
D=Disk();lua,source,_,_=session(D)
lua.execute('''
TEST_OPTIONS.cameraFOV:SetValue(90)
TEST_FIRST_CAMERA=TEST_SERVICES.Workspace.CurrentCamera
TEST_SECOND_CAMERA=Instance.new('Camera') TEST_SECOND_CAMERA.FieldOfView=82 TEST_SECOND_CAMERA.Parent=TEST_SERVICES.Workspace
TEST_SERVICES.Workspace.CurrentCamera=TEST_SECOND_CAMERA
assert(TEST_SECOND_CAMERA.FieldOfView==90)
TEST_OPTIONS.cameraFOV:SetValue(101)
TEST_ACTIONS['Unload script']()
assert(TEST_FIRST_CAMERA.FieldOfView==70.4 and TEST_SECOND_CAMERA.FieldOfView==82)
''')
# Rejected feature callback must roll back a restored toggle instead of leaving a fake enabled checkbox.
lua,source,_,_=session(D)
lua.execute("TEST_OPTIONS.bhSound:SetValue('https://example.invalid/test.mp3'); TEST_OPTIONS.bhSoundEnabled:SetValue(true); assert(not TEST_OPTIONS.bhSoundEnabled.Value)")
print('PASS FOV tracks original values for both old/replacement cameras; feature callback failure restores the toggle state')

# Reset sky/time must remain reset on a different server with different native time/FOV.
E=Disk();lu,source,_,_=session(E)
lu.execute("TEST_OPTIONS.skyAsset:SetValue('570559352'); TEST_ACTIONS.Load(); TEST_ACTIONS['Reset sky'](); TEST_OPTIONS.skyTime:SetValue(20); TEST_ACTIONS['Reset time and sun'](); TEST_DRAIN(); TEST_ACTIONS['Unload script']()")
lu,source,_,_=session(E,execute=False)
lu.execute("TEST_SERVICES.Lighting.ClockTime=14; TEST_SERVICES.Workspace.CurrentCamera.FieldOfView=80")
lu.execute(source)
lu.execute("assert(TEST_SERVICES.Lighting.ClockTime==14 and TEST_OPTIONS.skyTime.Value==14); assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==80 and TEST_OPTIONS.cameraFOV.Value==80); assert(not TEST_SERVICES.Lighting:FindFirstChild('PrimeVisualsSky'))")
print('PASS reset sky/time remain native defaults on another simulated server; untouched FOV/time sliders follow its real values')

import json
F=Disk();lu,source,_,_=session(F)
lu.execute('TEST_OPTIONS.cameraFOV:SetValue(92); TEST_DRAIN()')
invalid=json.loads(F.files['PrimeVisuals/Configs/1234/autosave.json'])
invalid['revision']+=100
invalid['payload']['values']['cameraFOV']=999
F.files['PrimeVisuals/Configs/1234/autosave.json']=json.dumps(invalid)
lu,source,_,_=session(F)
lu.execute('assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==92)')
print('PASS newest JSON with invalid setting ranges is rejected in favor of an older fully valid backup')
