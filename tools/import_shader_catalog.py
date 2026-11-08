"""Extract reviewed configuration literals only. Never execute collection scripts."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def table_at(text, start):
    start = text.index('{', start)
    depth, quote, escaped = 0, None, False
    for end in range(start, len(text)):
        ch = text[end]
        if quote:
            if escaped: escaped = False
            elif ch == '\\': escaped = True
            elif ch == quote: quote = None
        elif ch in "\"'": quote = ch
        elif ch == '{': depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0:
                literal = '\n'.join(line.strip() for line in text[start:end+1].splitlines())
                # Literal tables may call only Color3 constructors, never loaders/functions.
                calls = re.findall(r'([\w.]+)\s*\(', literal)
                assert set(calls) <= {'Color3.fromRGB', 'Color3.new'}, calls
                assert not re.search(r'\b(function|require|loadstring|game)\b', literal)
                return literal
    raise ValueError('Unclosed configuration table')

def assignments(text, baseline=''):
    objects, light = [], {}
    aliases = {'Lighting': light}
    for line in (baseline+'\n'+text).splitlines():
        line = line.strip()
        m = re.match(r'local (\w+) = Instance.new\(["\']?(\w+)', line)
        if m:
            props = {}; aliases[m[1]] = props; objects.append((m[2], props)); continue
        m = re.match(r'Instance.new\("(\w+)", Lighting\)\.(\w+) = (.+)', line)
        if m:
            objects.append((m[1], {m[2]: m[3]})); continue
        m = re.match(r'(\w+)\.(\w+) = (.+)', line)
        if not m or m[1] not in aliases or m[2] in {'Name','Parent'}: continue
        value = m[3]
        if value.startswith('rbxassetid'): value = json.dumps('rbxassetid://'+re.sub(r'\D', '', value))
        if value == 'rbxassetskymoon.jpg': value = '"rbxasset://sky/moon.jpg"'
        if value == 'rbxassetskysun.jpg': value = '"rbxasset://sky/sun.jpg"'
        assert re.fullmatch(r'-?[\d.]+|true|false|Color3\.(?:new|fromRGB)\([\d., -]+\)|"[^"\n]+"', value), (line, value)
        aliases[m[1]][m[2]] = value
    def props(values): return '{'+','.join(k+'='+v for k,v in values.items())+'}'
    parts = ['Lighting='+props(light)]
    mapping = {'BloomEffect':'Bloom','BlurEffect':'Blur','ColorCorrectionEffect':'CC','SunRaysEffect':'SunRays','DepthOfFieldEffect':'DepthOfField','Atmosphere':'Atmosphere','Sky':'Sky'}
    for cls, values in objects: parts.append(mapping[cls]+'='+props(values))
    return '{'+','.join(parts)+'}'

def build(findings):
    groups = json.loads(findings.read_text(encoding='utf8'))['primary_groups']
    sources = [Path(g['file']).read_text(encoding='utf8') for g in groups]
    chunks = ['-- Source-reviewed configuration values. See docs/Shader-Catalog-Sources.json.', 'local catalog={}']
    chunks.append('''local classes={Bloom="BloomEffect",Blur="BlurEffect",CC="ColorCorrectionEffect",ColorCorrection="ColorCorrectionEffect",SunRays="SunRaysEffect",Atmosphere="Atmosphere",DepthOfField="DepthOfFieldEffect"}
local function add(source,name,raw,flat)
    local data={source=source,light=raw.Lighting or {},effects={},sky=raw.Sky,clouds=raw.Clouds}
    if flat then for k,value in pairs(raw) do if not classes[k] then data.light[k]=value end end end
    for _,key in ipairs({"Bloom","Blur","CC","ColorCorrection","SunRays","Atmosphere","DepthOfField"}) do
        local props=raw[key]
        if props then
            if props.Tint then props.TintColor=props.Tint props.Tint=nil end
            data.effects[#data.effects+1]={classes[key],props}
        end
    end
    catalog[source.." / "..name]=data
end''')
    mercury = '\n'.join(sources[0].splitlines()[4027:4337])
    for n in range(16,35):
        raw = table_at(mercury, mercury.index(f'local tbl{n} ='))
        chunks.append(f'do local item={raw} add("Mercury",item.name,item.data) end')
    raw = table_at(mercury, mercury.index('tbl15[17] ='))
    chunks.append(f'do local item={raw} add("Mercury",item.name,item.data) end')
    sav = '\n'.join(sources[1].splitlines()[32601:32881])
    chunks.append('add("SAVITAR","Scarlet Atmosphere",'+table_at(sav, sav.index('local tbl35 ='))+')')
    chunks.append('for name,raw in pairs('+table_at(sav, sav.index('local tbl36 ='))+') do add("SAVITAR",name,raw) end')
    # Sky settings are outside the preset tables, in the source builders.
    for builder, scarlet in [('_buildRedShaderInstances = function()', True), ('_buildGenericShaderInstances = function()', False)]:
        body=sources[1].split(builder,1)[1].split('local bloomEffect',1)[0]
        metadata=assignments(body)
        selector='name=="SAVITAR / Scarlet Atmosphere"' if scarlet else 'data.source=="SAVITAR" and name~="SAVITAR / Scarlet Atmosphere"'
        chunks.append('do local metadata='+metadata+' for name,data in pairs(catalog) do if '+selector+' then data.sky=metadata.Sky end end end')
    eris = sources[3]
    chunks.append('for name,raw in pairs('+table_at(eris, eris.index('local ShaderPresets ='))+') do add("Eris",name,raw,true) end')
    chunks.append('for _,data in pairs(catalog) do if data.source=="Eris" then data.light.GlobalShadows=false end end')
    fos = '\n'.join(sources[2].splitlines()[6548:6737])
    for name, body in re.findall(r'registerShader\(\w+,([^,]+), function\(self\)(.*?)(?=\n\s*registerShader|\Z)', fos, re.S):
        chunks.append('add("Fosfor",'+json.dumps(name.strip())+','+assignments(body)+')')
    # The saved Adaptive source calls an undefined accentLerp. Keep its numeric
    # settings and explicit accent blending, documented as a compatibility repair.
    chunks.append('''add("Fosfor","Adaptive Map",{Lighting={ClockTime=18,Brightness=2.5,FogStart=50,FogEnd=500},CC={Saturation=.15,Contrast=.05,Brightness=0}})
catalog["Fosfor / Adaptive Map"].adaptiveAccent=true''')
    st = '\n'.join(sources[4].splitlines()[27275:27400])
    baseline = st[:st.index('if A1724_1')]
    for name, body in re.findall(r'(?:if|elseif) A1724_1 == "([^"]+)" then(.*?)(?=\n\s*elseif|\Z)', st, re.S):
        chunks.append('add("Silent Target",'+json.dumps(name)+','+assignments(body,baseline)+')')
    chunks.append('return catalog\n')
    (ROOT/'lib/ShaderCatalog.lua').write_text('\n'.join(chunks), encoding='utf8')
    manifest = {'date':'2026-11-08','entries':42,'sources':[
        {'file':Path(g['file']).name,'sha256':hashlib.sha256(Path(g['file']).read_bytes()).hexdigest(),'lines':g['lines'],'presets':g['presets']} for g in groups],
        'additional_source_ranges':{'SAVITAR.txt':[33058,33120],'Eris.txt':[2588,2648]},
        'repairs':['Fosfor: restore missing asset URI quotes/punctuation without changing asset IDs.', 'Fosfor Adaptive: undefined accentLerp replaced with explicit base:Lerp(accent, factor); follows Prime UI accent.'],
        'limits':['Only configuration data copied; foreign loaders and destructive lifecycle code excluded.', 'Roblox property clamping and unavailable assets can affect rendering.', 'Unspecified properties inherit game state; identical output across different games is not guaranteed.']}
    (ROOT/'docs/Shader-Catalog-Sources.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf8')

if __name__ == '__main__':
    p=argparse.ArgumentParser();p.add_argument('findings',type=Path);build(p.parse_args().findings)
