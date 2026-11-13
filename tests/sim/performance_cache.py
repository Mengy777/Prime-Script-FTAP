from support import Disk, session

lua, source, _, _ = session(Disk(), execute=False)
# Expose existing lexical caches only in the test build; no runtime diagnostic API.
source = source.replace('local startup={Alive=true}', 'local startup={Alive=true}; TEST_STARTUP_STATE=startup', 1)
lua.execute(source + '\nTEST_SOURCE_CACHE=sourceCache; TEST_FACTORY_CACHE=factoryCache')
lua.execute(r"""
local count=0
for name,factory in pairs(TEST_FACTORY_CACHE)do
 assert(type(factory)=='function')
 assert(TEST_SOURCE_CACHE[name]==nil,'compiled factory still pins source: '..name)
 local item=TEST_STARTUP_STATE.Downloads[name]
 if item then assert(item.Source==nil,'prefetch still pins source: '..name)end
 count=count+1
end
assert(count>=20,'test did not exercise production module set')
assert(type(TEST_SOURCE_CACHE.Library)=='string','restartable table module lost source')
TEST_ACTIONS['Reset all settings']()
assert(TEST_LIBRARY.Toggled,'factory cache failed after restart')
TEST_ACTIONS['Unload script']()
""")
print('PASS compiled factories release source/prefetch buffers and retain restart support')
