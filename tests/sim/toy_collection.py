from support import Disk,session
D=Disk()
NATIVE=r'''
function NATIVE_MENU()
 local screen=Instance.new('ScreenGui')screen.Name='GameToyMenu'screen.Parent=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')
 local list=Instance.new('Frame')list.Name='YourToys'list.Parent=screen
 local grid=Instance.new('UIGridLayout')grid.SortOrder=Enum.SortOrder.Name grid.Parent=list
 local names={'PalletLightBrown','FoodCakePink','FoodDonut','BombMissile','CrystalBlack','CreatureBlobman','TetracubeL','Cube','InstrumentBrassTrumpet','InstrumentWoodwindOcarina'}
 for i=1,26 do names[#names+1]='ExtraToy'..i end
 local shop=Instance.new('Frame')shop.Name='ToyShop'shop.Parent=screen
 local shopGrid=Instance.new('UIGridLayout')shopGrid.SortOrder=Enum.SortOrder.Name shopGrid.Parent=shop
 for _,name in ipairs({'PalletLightBrown','FoodCakePink','BombMissile'})do local button=Instance.new('ImageButton')button.Name=name button.LayoutOrder=77 button.Parent=shop end
 local cards={}
 for i,name in ipairs(names)do
  local card=Instance.new('ImageButton')card.Name=name card.Visible=true card.LayoutOrder=100+i card.Parent=list
  local star=Instance.new('BoolValue')star.Name='Favorite'star.Value=false star.Parent=card
  cards[name]=card
 end
 return screen,list,grid,cards
end
SCREEN,LIST,GRID,CARDS=NATIVE_MENU()
'''
lua,source,_,_=session(D,execute=False)
lua.execute(NATIVE)
lua.execute(source)
lua.execute(r'''
assert(CARDS.PalletLightBrown.LayoutOrder==101,'default-off changed native menu')
TEST_OPTIONS.toyCollectionEnabled:SetValue(true)
for i=1,4 do TEST_SERVICES.RunService.Heartbeat:Fire(.21)end
assert(CARDS.BombMissile.LayoutOrder==-9999,'rocket not first '..tostring(CARDS.BombMissile.LayoutOrder))
assert(CARDS.CrystalBlack.LayoutOrder==-9998)
assert(CARDS.CreatureBlobman.LayoutOrder==-9997)
assert(CARDS.TetracubeL.LayoutOrder==-9996)
assert(CARDS.PalletLightBrown.LayoutOrder==-9974,'pallet not slot26')
assert(GRID.SortOrder==Enum.SortOrder.LayoutOrder)
for _,o in ipairs(SCREEN:FindFirstChild('ToyShop'):GetChildren())do if o:IsA('GuiObject')then assert(o.LayoutOrder==77,'shop card changed')end end
CARDS.PalletLightBrown.Visible=false TEST_SERVICES.RunService.Heartbeat:Fire(.21)
CARDS.PalletLightBrown.Visible=true TEST_SERVICES.RunService.Heartbeat:Fire(.21)
assert(CARDS.PalletLightBrown.LayoutOrder==-9974,'search hide/show lost pallet ordering')
assert(#LIST:GetChildren()==37,'native cards cloned/deleted')
assert(not CARDS.PalletLightBrown:FindFirstChild('Favorite').Value,'game favorites changed')
-- Native favorite order writes are re-enforced but retained for disabling.
CARDS.PalletLightBrown.LayoutOrder=9999
TEST_SERVICES.RunService.Heartbeat:Fire(.21)
assert(CARDS.PalletLightBrown.LayoutOrder==-9974)
TEST_OPTIONS.toyCollectionEnabled:SetValue(false)
assert(CARDS.PalletLightBrown.LayoutOrder==9999 and GRID.SortOrder==Enum.SortOrder.Name)
-- Rearrangement swaps an existing preferred item rather than duplicating it.
TEST_OPTIONS.toyCollectionEnabled:SetValue(true)
TEST_OPTIONS.toyCollectionSlot:SetValue(1)
TEST_OPTIONS.toyCollectionToy:SetValue('Donut')
TEST_ACTIONS['Assign toy to position']()
TEST_SERVICES.RunService.Heartbeat:Fire(.21)
assert(CARDS.FoodDonut.LayoutOrder==-9999 and CARDS.BombMissile.LayoutOrder==-9991)
assert(CARDS.PalletLightBrown.LayoutOrder==-9974)
-- Destroyed/recreated native game menu is rebound.
SCREEN:Destroy()
SCREEN,LIST,GRID,CARDS=NATIVE_MENU()
TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui').DescendantAdded:Fire(SCREEN)
TEST_SERVICES.RunService.Heartbeat:Fire(.21)
assert(CARDS.FoodDonut.LayoutOrder==-9999 and CARDS.PalletLightBrown.LayoutOrder==-9974)
TEST_DRAIN()
TEST_ACTIONS['Unload script']()
assert(CARDS.PalletLightBrown.LayoutOrder==101 and GRID.SortOrder==Enum.SortOrder.Name)
''')
print('PASS native toy sorting: rocket/black crystal/blob/Tetracub L priority, pallet26 with missing preferred toys, original instances/favorites, native rewrites, editing, menu recreation and unload')
lua,source,_,_=session(D,execute=False)
lua.execute(NATIVE)
lua.execute(source)
lua.execute(r'''
for i=1,4 do TEST_SERVICES.RunService.Heartbeat:Fire(.21)end
assert(TEST_OPTIONS.toyCollectionEnabled.Value)
assert(CARDS.FoodDonut.LayoutOrder==-9999 and CARDS.PalletLightBrown.LayoutOrder==-9974,'saved collection did not cold-restore')
TEST_ACTIONS['Unload script']()
''')
print('PASS autosave cold restore of collection enabled/order and pallet26')
