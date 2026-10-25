from support import Disk,session
import json
class ReentrantDisk(Disk):
 def __init__(self): super().__init__();self.hook=None
 def write(self,path,text):
  if self.hook:
   hook,self.hook=self.hook,None
   hook()
  return super().write(path,text)
D=ReentrantDisk();lua,source,_,_=session(D)
D.hook=lambda:lua.execute('TEST_OPTIONS.cameraFOV:SetValue(99)')
lua.execute('TEST_OPTIONS.cameraFOV:SetValue(90); TEST_DRAIN(); TEST_DRAIN()')
assert json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])['payload']['values']['cameraFOV']==99
# Force unload from inside an unfinished file operation.
D.hook=lambda:lua.execute("TEST_OPTIONS.cameraFOV:SetValue(102); TEST_ACTIONS['Unload script']()")
lua.execute('TEST_OPTIONS.cameraFOV:SetValue(93); TEST_DRAIN()')
assert json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])['payload']['values']['cameraFOV']==102
lua.execute('assert(TEST_LIBRARY.Unloaded and TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==70.4)')
lua,source,_,_=session(D)
lua.execute('assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==102)')
print('PASS reentrant write: edits during write are not lost; unload during write queues its final snapshot and cold restart restores it')

E=Disk();lu,source,_,_=session(E)
E.fail=True
lu.execute('TEST_OPTIONS.cameraFOV:SetValue(109); TEST_DRAIN()')
E.fail=False
lu.execute('TEST_DRAIN()')
assert json.loads(E.files['PrimeVisuals/Configs/1234/autosave.json'])['payload']['values']['cameraFOV']==109
print('PASS temporary disk failure retries automatically after recovery without another settings edit')
