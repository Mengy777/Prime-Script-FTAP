"""Code-native overlay masks aligned to gaming-mouse.png; does not modify body artwork."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
ROOT=Path(__file__).resolve().parents[1]
W,H=941,1672
polygons={
"left":[(126,203),(422,29),(429,39),(428,177),(412,213),(405,258),(405,432),(423,477),(459,490),(459,759),(285,736),(205,715),(164,685),(144,632),(128,498)],
"right":[(519,30),(805,203),(815,258),(808,489),(794,630),(766,685),(718,716),(634,741),(480,760),(480,492),(514,475),(529,435),(527,258),(511,210),(508,69)],
}
for name in ("left","right","middle","wheel-up","wheel-down"):
    alpha=Image.new("L",(W,H));draw=ImageDraw.Draw(alpha)
    if name in polygons:draw.polygon(polygons[name],fill=255)
    else:
        box={"middle":(438,210,501,468),"wheel-up":(438,210,501,336),"wheel-down":(438,342,501,468)}[name]
        draw.rounded_rectangle(box,radius=13,fill=255)
    image=Image.new("RGBA",(W,H),(255,255,255,0));image.putalpha(alpha.filter(ImageFilter.GaussianBlur(2)))
    image.save(ROOT/("assets/input-overlay/"+name+".png"),optimize=True)
