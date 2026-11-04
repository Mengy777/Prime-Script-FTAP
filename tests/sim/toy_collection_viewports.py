from support import Disk,session
import json
D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(r'''
local playerGui=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')
local screen=Instance.new('ScreenGui')screen.Name='NativeMenu'screen.Parent=playerGui
local heading=Instance.new('TextLabel')heading.Text='Your Toys'heading.Parent=screen
LIST=Instance.new('ScrollingFrame')LIST.Name='Content'LIST.Parent=screen
CARDS={}POSITIONS={}
local names={'PalletLightBrown','FoodCakePink','FoodDonut','BombMissile','CrystalBlack','CreatureBlobman','TetracubeL','Cube','InstrumentBrassTrumpet','InstrumentWoodwindOcarina'}
for i=1,24 do names[#names+1]='OtherToy'..i end
for i,name in ipairs(names)do
 local card=Instance.new('ImageButton')card.Name='Button'..i card.LayoutOrder=0 card.Size=UDim2.fromOffset(80,80)
 card.Position=UDim2.fromOffset((i-1)%9*90,math.floor((i-1)/9)*90)card.AbsolutePosition=Vector2.new((i-1)%9*90,math.floor((i-1)/9)*90)card.Parent=LIST
 local vp=Instance.new('ViewportFrame')vp.Name='Preview'vp.Size=UDim2.fromScale(1,1)vp.Parent=card
 local model=Instance.new('Model')model.Name=name model.Parent=vp
 local star=Instance.new('ImageLabel')star.Name='FavoriteStar'star.Image='rbxassetid://123'star.Position=UDim2.new(1,-4,1,-3)star.Size=UDim2.fromOffset(20,20)star.AnchorPoint=Vector2.new(1,1)star.ZIndex=2 star.Parent=card
 CARDS[name]=card POSITIONS[i]=card.Position
end
''')
lua.execute(source)
lua.execute(r'''
TEST_OPTIONS.toyCollectionEnabled:SetValue(true)
for i=1,3 do TEST_SERVICES.RunService.Heartbeat:Fire(.21)end
assert(CARDS.BombMissile.Position==POSITIONS[14],'viewport-only rocket not sorted')
assert(CARDS.PalletLightBrown.Position==POSITIONS[23],'manual-position pallet not23')
local card=CARDS.PalletLightBrown local star=card:FindFirstChild('PV_CollectionStar')
assert(star and star.Position==card:FindFirstChild('FavoriteStar').Position and star.Size.X.Offset==card:FindFirstChild('FavoriteStar').Size.X.Offset*.65,'custom star misplaced')
assert(star:FindFirstChild('Fill').ImageColor3.R==0 and star:FindFirstChild('Fill').ImageColor3.G==0,'star not black')
local before=star:FindFirstChild('Outline').ImageColor3.R
TEST_CLOCK=TEST_CLOCK+1 TEST_SERVICES.RunService.Heartbeat:Fire(.11)
assert(star:FindFirstChild('Outline').ImageColor3.R~=before,'star outline not animated')
local option=TEST_OPTIONS.toyCollectionToy
assert(option.Type=='Dropdown' and option.Info.Searchable,'toy picker still requires typing')
assert(#option.Values>=34,'native toy catalogue not populated')
-- Legacy hidden dropdown no longer creates duplicate previews.
option:SetValue('tetracubl')TEST_OPTIONS.toyCollectionSlot:SetValue(2)
TEST_ACTIONS['Assign toy to position']()
TEST_SERVICES.RunService.Heartbeat:Fire(.21)
assert(CARDS.TetracubeL.Position==POSITIONS[2],'click selection did not assign toy')
TEST_OPTIONS.toyCollectionEnabled:SetValue(false)
assert(CARDS.PalletLightBrown.Position==POSITIONS[1] and not CARDS.PalletLightBrown:FindFirstChild('PV_CollectionStar'),'native position/marker not restored')
TEST_ACTIONS['Unload script']()
''')
print('PASS viewport-only/manual-position native catalogue, clickable searchable picker/preview factories, pallet23, exact native-star bounds, black fill/animated outline, assignment and restore')

report=json.loads(D.files['PrimeVisuals/ToyMenu-Diagnostics.json'])
assert report['roots']>=1 and any(n['class']=='ViewportFrame'for n in report['nodes'])
print('PASS integrated automatic local menu diagnostics; no separate script needed')
