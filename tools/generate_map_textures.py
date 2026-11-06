from pathlib import Path
from PIL import Image, ImageDraw
import math,random,json
out=Path('assets/map-textures');n=512
for name in ['checker','grid','circuit','hex','clouds','rose','candy','stars']:
 im=Image.new('RGB',(n,n),(210,210,210));d=ImageDraw.Draw(im)
 if name=='checker':
  for y in range(0,n,64):
   for x in range(0,n,64):d.rectangle((x,y,x+63,y+63),fill=(245,)*3 if (x+y)//64%2==0 else(160,)*3)
 elif name=='grid':
  im.paste((80,)*3,(0,0,n,n));d=ImageDraw.Draw(im)
  for i in range(0,n,64):d.line((i,0,i,n),fill=(220,)*3,width=2);d.line((0,i,n,i),fill=(220,)*3,width=2)
  for x in range(32,n,64):
   for y in range(32,n,64):d.line((x-3,y,x+3,y),fill=(130,)*3);d.line((x,y-3,x,y+3),fill=(130,)*3)
 elif name=='circuit':
  im.paste((72,)*3,(0,0,n,n));d=ImageDraw.Draw(im)
  for x in range(0,n,64):
   for y in range(0,n,64):
    d.line([(x,y+16),(x+20,y+16),(x+32,y+28),(x+32,y+64)],fill=(235,)*3,width=3)
    d.line([(x+64,y+48),(x+52,y+48),(x+44,y+40),(x+44,y)],fill=(180,)*3,width=2)
    d.ellipse((x+12,y+12,x+20,y+20),outline=(245,)*3,width=2)
 elif name=='hex':
  im.paste((100,)*3,(0,0,n,n));d=ImageDraw.Draw(im)
  for y in range(-64,n+64,64):
   for x in range(-64,n+64,64):
    ox=x+(32 if (y//64)%2 else 0);points=[(ox+32*math.cos(a*math.pi/3),y+32*math.sin(a*math.pi/3))for a in range(6)]
    d.polygon(points,outline=(225,)*3,width=2)
 elif name=='clouds':
  pix=im.load()
  for y in range(n):
   for x in range(n):
    u=x/n*math.tau;v=y/n*math.tau;z=math.sin(u+math.sin(v))+math.cos(v*2+math.sin(u*2))*.5+math.sin(u*4-v*3)*.22
    value=int(206+z*22);pix[x,y]=(value,)*3
 elif name=='rose':
  for y in range(-64,n+64,64):
   for x in range(-64,n+64,64):
    ox=x+(32 if (y//64)%2 else 0)
    for a in range(8):
     cx=ox+13*math.cos(a*math.pi/4);cy=y+13*math.sin(a*math.pi/4);d.ellipse((cx-7,cy-7,cx+7,cy+7),fill=(240,)*3)
    d.ellipse((ox-5,y-5,ox+5,y+5),fill=(150,)*3)
 elif name=='candy':
  pix=im.load()
  for y in range(n):
   for x in range(n):pix[x,y]=((245,)*3 if (x+y)%64<32 else(175,)*3)
 elif name=='stars':
  im.paste((80,)*3,(0,0,n,n));d=ImageDraw.Draw(im);rng=random.Random(777)
  for _ in range(100):
   x,y=rng.randrange(n),rng.randrange(n);d.rectangle((x,y,x+1,y+1),fill=(190,)*3)
  for y in range(32,n,64):
   for x in range(32,n,64):d.line((x-5,y,x+5,y),fill=(250,)*3,width=2);d.line((x,y-5,x,y+5),fill=(250,)*3,width=2)
 im.save(out/(name+'.png'),optimize=True)
print({p.name:p.stat().st_size for p in out.glob('*.png')})
