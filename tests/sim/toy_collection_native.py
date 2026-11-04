from support import Disk,session,ROOT
import json
lua,source,_,to_lua=session(Disk(),execute=False)
lua.globals().CAPTURED_CARDS=to_lua(json.loads((ROOT/'tests/fixtures/native_toy_cards.json').read_text()))
lua.execute(r"""
local mt=getmetatable(Instance.new('Frame'))local oldIndex=mt.__index
GUI_FULL_SCANS=0 PREVIEW_CLONES=0
mt.__index=function(o,k)
 if k=='GetDescendants'then return function(self)
  if self==TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')then GUI_FULL_SCANS=GUI_FULL_SCANS+1 end
  return oldIndex(o,k)(self)
 end end
 if k=='Clone'then return function(self)
  PREVIEW_CLONES=PREVIEW_CLONES+1
  local copy=Instance.new(self._class)
  for key,value in pairs(self._props)do if key~='Parent'and key~='CurrentCamera'then copy[key]=value end end
  for _,child in ipairs(self:GetChildren())do local cloned=child:Clone()cloned.Parent=copy end
  return copy
 end end
 return oldIndex(o,k)
end
local pg=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')
local function node(class,name,parent)local o=Instance.new(class)o.Name=name o.Parent=parent return o end
SCREEN=node('ScreenGui','MenuGui',pg)
local menu=node('Frame','Menu',SCREEN)local tabs=node('Frame','TabContents',menu)
local tab=node('Frame','Toys',tabs)LIST=node('ScrollingFrame','Contents',tab)
GRID=node('UIGridLayout','UIGridLayout',LIST)GRID.SortOrder=Enum.SortOrder.LayoutOrder
CARDS={}
for _,entry in ipairs(CAPTURED_CARDS)do
 local b=node('Frame',entry.name,LIST)b.Visible=true b.LayoutOrder=entry.order
 b.Size=UDim2.fromOffset(100,100)
 local click=node('TextButton','ViewItemButton',b)
 local vp=node('ViewportFrame','ViewportFrame',click)vp.CurrentCamera=node('Camera','Camera',vp)
 node('Model',entry.name,vp)
 local star=node('ImageLabel','Favorite',b)star.Visible=false star.Image='rbxassetid://10045503805'
 star.Size=UDim2.fromScale(.711,.711)star.AnchorPoint=Vector2.new(1,1)star.Position=UDim2.fromScale(1,1)star.ZIndex=10
 CARDS[entry.name]=b
end
for _,name in ipairs({'ToyShop','Shop','ToyDestroy'})do
 local t=node('Frame',name,tabs)local f=node('Frame','Contents',t)node('UIGridLayout','Grid',f)
 for _,key in ipairs({'BombMissile','PalletLightBrown'})do local b=node('TextButton',key,f)b.LayoutOrder=777 end
end
""")
lua.execute(source)
lua.execute(r"""
TEST_OPTIONS.toyCollectionEnabled:SetValue(true)
TEST_SERVICES.RunService.Heartbeat:Fire(.21)
assert(CARDS.BombMissile.LayoutOrder==-9986,'actual owned path not recognized')
assert(CARDS.BombDarkMatter.LayoutOrder==-9987,'native dark crystal alias missing')
assert(CARDS.TetracubeL.LayoutOrder==-9985)
assert(CARDS.PalletLightBrown.LayoutOrder==-9977)
assert(TEST_OPTIONS.toyCollectionToy==nil and TEST_OPTIONS.toyCollectionSlot==nil and TEST_OPTIONS.toyCollectionOrder==nil)
local marked=0 for _,card in pairs(CARDS)do if card:FindFirstChild('PV_CollectionStar')then marked=marked+1 end end
assert(marked==27,'collection must mark exactly27 toys')
CARDS.PalletLightBrown.LayoutOrder=999999
assert(CARDS.PalletLightBrown.LayoutOrder==-9977,'native favorite write was not repaired synchronously')
local star=CARDS.PalletLightBrown:FindFirstChild('PV_CollectionStar')
assert(star and math.abs(star.Size.X.Scale-.711*.65)<.00001)
for _,tab in ipairs(SCREEN:FindFirstChild('Menu'):FindFirstChild('TabContents'):GetChildren())do if tab.Name~='Toys'then
 for _,b in ipairs(tab:FindFirstChild('Contents'):GetChildren())do if b:IsA('GuiObject')then assert(b.LayoutOrder==777)end end
end end
local scans=GUI_FULL_SCANS
for i=1,100 do
 CARDS.PalletLightBrown.LayoutOrder=900000+i
 CARDS.PalletLightBrown.Visible=false CARDS.PalletLightBrown.Visible=true
 TEST_SERVICES.RunService.Heartbeat:Fire(.11)
 assert(CARDS.PalletLightBrown.LayoutOrder==-9977)
end
assert(GUI_FULL_SCANS==scans,'native reopening causes wholeGUI scans')
TEST_OPTIONS.toyCollectionEnabled:SetValue(false)
for _,entry in ipairs(CAPTURED_CARDS)do assert(CARDS[entry.name].LayoutOrder==(entry.name=='PalletLightBrown'and 900100 or entry.order))end
TEST_ACTIONS['Unload script']()
""")
print('PASS captured native MenuGui/Toys hierarchy and195 real IDs; aliases, pallet23, exact favorite geometry; shop/destroy untouched; restore')
# The shipped client exposes no collection editing controls/actions.
assert 'MountEditor' not in (ROOT/'lib/ToyCollection.lua').read_text(encoding='utf-8')
assert 'toyCollectionSlot' not in (ROOT/'PrimeVisuals.lua').read_text(encoding='utf-8')
print('PASS fixed27-toy set only: no editor, assignment action or obsolete persisted editor controls')
