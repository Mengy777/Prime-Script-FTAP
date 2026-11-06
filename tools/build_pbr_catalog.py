from pathlib import Path
import json
r=Path(__file__).resolve().parents[1]
manifest=json.loads((r/'tools/pbr-texture-manifest.json').read_text());themes=json.loads((r/'tools/pbr-themes.json').read_text());styles={}
for a in manifest['Assets']:styles[a['Name']]={'Library':a['Library'],'Source':a['Source'],'Maps':{p:{'File':m['File'],'Bytes':m['Bytes']}for p,m in a['Maps'].items()}}
def lu(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lu(x)for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(map(lu,v))+'}'
 return json.dumps(v)
s='-- Downloaded PBR sets: Poly Haven, ambientCG, TextureCan. See docs/Map-Textures.md.\nreturn {\n Styles={\n'+'\n'.join('  ['+json.dumps(k)+']='+lu(v)+','for k,v in sorted(styles.items()))+'\n },\n Themes={\n'+'\n'.join('  '+lu(t)+','for t in themes)+'\n },\n}\n'
legacyStyles=['Asphalt','Basalt','Brick','Carpet','CeramicTiles','Cobblestone','Concrete','CorrodedMetal','CrackedLava','DiamondPlate','Fabric','Glacier','Granite','Grass','Ground','Ice','LeafyGrass','Limestone','Marble','Metal','Mud','Pavement','Pebble','Plaster','Rock','Rubber','Salt','Sand','Sandstone','Slate','Snow','Wood','WoodPlanks','Dream checker','Arcade grid','Circuit traces','Hologram hex','Soft clouds','Rose pattern','Candy stripes','Pixel stars']
legacyThemes={'Dreamcore':'Dreamcore Atrium','Rainbow World':'Rainbow Atelier','Rose Quartz':'Rose Quartz Palace','Neon Tokyo':'Cyberpunk Station','Cyberpunk':'Cyberpunk Station','Vaporwave':'Rainbow Atelier','Cotton Clouds':'Alpine Expedition','Candyland':'Festive Workshop','Liminal Hotel':'Timber Lodge','Lunar Outpost':'Industrial Hangar','Frozen Palace':'Alpine Expedition','Volcanic Forge':'Volcanic Citadel','Emerald Ruins':'Emerald Temple','Atlantis':'Tropical Coast','Solar Desert':'Tropical Coast','Space Arcade':'Rainbow Atelier','Monochrome Lab':'Modern Art Gallery','Royal Amethyst':'Rose Quartz Palace','Enchanted Grove':'Forest Sanctuary','Retro Playground':'Blue Porcelain Garden'}
s=s[:-2]+' LegacyStyleAliases='+lu({k:'Original'for k in legacyStyles})+',\n LegacyThemeAliases='+lu(legacyThemes)+',\n}\n'
(r/'lib/MapTextureCatalog.lua').write_text(s,encoding='utf-8')
