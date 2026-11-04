from support import Disk,session,ROOT
import json
lua,source,_,to_lua=session(Disk(),execute=False)
lua.globals().CAPTURED_CARDS=to_lua(json.loads((ROOT/'tests/fixtures/native_toy_cards.json').read_text()))
lua.execute(r"""
local mt=getmetatable(Instance.new('Frame'))local oldIndex=mt.__index
mt.__index=function(o,k)
 if k=='Clone'then return function(self)
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
assert(CARDS.BombMissile.LayoutOrder==-9999,'actual owned path not recognized')
assert(CARDS.BombDarkMatter.LayoutOrder==-9998,'native dark crystal alias missing')
assert(CARDS.TetracubeL.LayoutOrder==-9996)
assert(CARDS.PalletLightBrown.LayoutOrder==-9974)
assert(#TEST_OPTIONS.toyCollectionToy.Values>=195)
local star=CARDS.PalletLightBrown:FindFirstChild('PV_CollectionStar')
assert(star and star.Size==CARDS.PalletLightBrown:FindFirstChild('Favorite').Size)
for _,tab in ipairs(SCREEN:FindFirstChild('Menu'):FindFirstChild('TabContents'):GetChildren())do if tab.Name~='Toys'then
 for _,b in ipairs(tab:FindFirstChild('Contents'):GetChildren())do if b:IsA('GuiObject')then assert(b.LayoutOrder==777)end end
end end
TEST_OPTIONS.toyCollectionEnabled:SetValue(false)
for _,entry in ipairs(CAPTURED_CARDS)do assert(CARDS[entry.name].LayoutOrder==entry.order)end
TEST_ACTIONS['Unload script']()
""")
print('PASS captured native MenuGui/Toys hierarchy and195 real IDs; aliases, pallet26, exact favorite geometry; shop/destroy untouched; restore')
# Exercise real editor construction/click callbacks (not just SetValue controls).
factory=lua.execute((ROOT/'lib/ToyCollection.lua').read_text(encoding='utf-8'))
lua.globals().TOY_FACTORY=factory
lua.execute(r"""
local pg=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')
local parent=Instance.new('Frame')parent.Parent=pg parent.ZIndex=4
local panel={Container=parent}
function panel:AddLabel()
 local root=Instance.new('TextLabel')root.Parent=self.Container root.ZIndex=4
 local layout=Instance.new('UIListLayout')layout.Parent=root
 self.Root=root return {Holder=root}
end
function panel:Resize()end
local patches={}
local function patch(_,o,k,v)patches[o]=patches[o]or{}if not patches[o][k]then patches[o][k]={original=o[k]}end o[k]=v end
local manager=TOY_FACTORY({PlayerGui=pg,Run=TEST_SERVICES.RunService,Patches=patches,Patch=patch,Unpatch=function()end})
manager:SetEnabled(true)
local data=manager:DefaultOrder()local assigned=0
manager:MountEditor(panel,{Russian=function()return false end,Select=function(i)assert(i==26)end,Assign=function(slot,toy)
 assigned=slot data=manager:Assign(data,slot,toy)manager:SetOrder(data)
end})
local root=panel.Root
assert(not root:FindFirstChildWhichIsA('UIListLayout'),'label layout overrides editor positions')
local slots=root:GetChildren()[2]
local target
for _,o in ipairs(root:GetDescendants())do if o.Name=='Slot26' then target=o end end
assert(target and target.ZIndex==4)
target.MouseButton1Click:Fire()
local choice
for _,o in ipairs(root:GetDescendants())do if o.Name=='bombdarkmatter'or o.Name=='blackcrystal'then choice=o end end
if not choice then for _,o in ipairs(root:GetDescendants())do if o:IsA('TextButton')and o.Name~='Previous'and o.Name~='Next'and not o.Name:find('Slot')then choice=o break end end end
assert(choice,'catalogue page is empty')choice.MouseButton1Click:Fire()
assert(assigned==26,'slot click then toy click did not assign immediately')
local search=root:FindFirstChild('Search')search.Text='PalletLightBrown'
local found=false for _,o in ipairs(root:GetDescendants())do if o.Name=='palletlightbrown'then found=true end end assert(found,'search cannot find real toy')
manager:Destroy()parent:Destroy()
""")
print('PASS actual28-slot editor creation, inherited overlay ZIndex, layout isolation, slot26 selection, immediate catalogue assignment and search')

