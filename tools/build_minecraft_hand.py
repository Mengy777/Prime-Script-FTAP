"""Extract classic Steve arm UV faces losslessly; nearest-neighbor only, no generated artwork."""
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
FACES={"Front":(44,20,4,12),"Back":(52,20,4,12),"Right":(40,20,4,12),"Left":(48,20,4,12),"Top":(44,16,4,4),"Bottom":(48,16,4,4)}
source=Image.open(ROOT/"assets/minecraft/steve.png").convert("RGBA")
for name,(x,y,w,h) in FACES.items():
    face=source.crop((x,y,x+w,y+h))
    # Minecraft model Y increases downward, Roblox local Y increases upward.
    if name not in ("Top","Bottom"):face=face.transpose(Image.Transpose.ROTATE_180)
    target=face.resize((w*64,h*64),Image.Resampling.NEAREST)
    assert target.resize((w,h),Image.Resampling.NEAREST).tobytes()==face.tobytes()
    target.save(ROOT/("assets/minecraft/arm_"+name.lower()+".png"),optimize=True)
    print(name,target.size)
