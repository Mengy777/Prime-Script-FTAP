from support import Disk,session
import json
D=Disk();lua,_,_,_=session(D)
lua.execute("TEST_OPTIONS.objectBlobman:SetValue(false); TEST_OPTIONS.blobESP:SetValue(true); TEST_OPTIONS.objectESPEnabled:SetValue(false); TEST_DRAIN(); TEST_ACTIONS['Unload script']()")
lua,_,_,_=session(D)
lua.execute("assert(TEST_OPTIONS.blobESP.Value and not TEST_OPTIONS.objectBlobman.Value and not TEST_OPTIONS.objectESPEnabled.Value); TEST_ACTIONS['Unload script']()")
for path in list(D.files):
 if path.endswith(('autosave.json','autosave.backup.json')):
  doc=json.loads(D.files[path]); payload=doc['payload']
  for key in list(payload['values']):
   if key.startswith('object'):
    payload['values'].pop(key);payload.get('applied',{}).pop(key,None)
  payload['values']['blobESP']=True
  D.files[path]=json.dumps(doc)
lua,_,_,_=session(D)
lua.execute("assert(TEST_OPTIONS.objectESPEnabled.Value and TEST_OPTIONS.blobESP.Value and TEST_OPTIONS.objectBlobman.Value)")
print('PASS object master-off preserves subtype settings across restart; legacy item profiles infer umbrella enabled')
