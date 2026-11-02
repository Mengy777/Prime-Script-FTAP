from support import Disk,session
import json
D=Disk();lua,_,_,_=session(D)
lua.execute("assert(not TEST_OPTIONS.objectESPEnabled and not TEST_OPTIONS.blobESP and not TEST_OPTIONS.espServer and not TEST_OPTIONS.espSticky and not TEST_OPTIONS.espBlackholes); TEST_OPTIONS.cameraFOV:SetValue(91); TEST_DRAIN(); TEST_ACTIONS['Unload script']()")
for path in list(D.files):
 if path.endswith(('autosave.json','autosave.backup.json')):
  doc=json.loads(D.files[path]);doc['payload']['values'].update({'objectESPEnabled':True,'blobESP':True,'espServer':True,'espSticky':True,'espBlackholes':True})
  D.files[path]=json.dumps(doc)
lua,_,_,_=session(D)
lua.execute("assert(TEST_OPTIONS.cameraFOV.Value==91 and not TEST_OPTIONS.objectESPEnabled and not TEST_OPTIONS.espServer); for _,o in ipairs(TEST_LIBRARY.ScreenGui:GetDescendants())do assert(o.Name~='Section_Objects' and o.Name~='Section_Items')end; TEST_ACTIONS['Unload script']()")
print('PASS removed object/item tabs and controls absent; legacy object keys ignored while FOV preserved')
