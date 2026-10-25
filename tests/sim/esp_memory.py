from support import Disk,session
import json
D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(r'''
function TEST_NATIVE_MULTI()
 for _,option in pairs(TEST_OPTIONS) do
  if option.Info.Multi then
   local original=option.SetValue
   function option:SetValues(values) self.Info.Values=values self:SetValue(self.Value) end
   function option:SetValue(values)
    local allowed={} for _,name in ipairs(self.Info.Values) do allowed[name]=true end
    local filtered={} for name,on in pairs(values or {}) do if on and allowed[name] then filtered[name]=true end end
    original(self,filtered)
   end
  end
 end
end
''')
source=source.replace('-- PROFILE_BLOCK_START','TEST_NATIVE_MULTI()\n-- PROFILE_BLOCK_START',1)
lua.execute(source)
lua.execute(r'''
local player=TEST_SERVICES.Players.LocalPlayer
TEST_ENEMY=Instance.new('Player') TEST_ENEMY.Name='ReturningEnemy' TEST_ENEMY.DisplayName='Enemy' TEST_ENEMY.UserId=555
TEST_ROSTER={player,TEST_ENEMY}
TEST_SERVICES.Players.GetPlayers=function()return TEST_ROSTER end
TEST_SERVICES.Players.PlayerAdded:Fire(TEST_ENEMY)
TEST_OPTIONS.espAllPlayers:SetValue(false)
TEST_OPTIONS.espSelectedPlayers:SetValue({ReturningEnemy=true})
TEST_DRAIN()
TEST_ROSTER={player}
TEST_SERVICES.Players.PlayerRemoving:Fire(TEST_ENEMY)
TEST_DRAIN()
''')
record=json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])
assert record['payload']['values']['espSelectedPlayers']['names']==['ReturningEnemy']
lua.execute("TEST_ACTIONS['Unload script']()")
# Reload while the selected player is absent: native multi-dropdown has no selected row.
lua.execute(source)
lua.execute("assert(not TEST_OPTIONS.espSelectedPlayers.Value.ReturningEnemy)")
record=json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])
assert record['payload']['values']['espSelectedPlayers']['names']==['ReturningEnemy']
lua.execute(r'''
TEST_ROSTER={TEST_SERVICES.Players.LocalPlayer,TEST_ENEMY}
TEST_SERVICES.Players.PlayerAdded:Fire(TEST_ENEMY)
assert(TEST_OPTIONS.espSelectedPlayers.Value.ReturningEnemy==true)
TEST_OPTIONS.espSelectedPlayers:SetValue({}) TEST_DRAIN()
''')
record=json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])
assert record['payload']['values']['espSelectedPlayers']['names'] in ([],{})
print('PASS native-like dropdown prunes absent rows but saved ESP selection survives leave/reload, reselects returning player and respects explicit deselection')
