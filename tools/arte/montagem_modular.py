"""Monta as três rooms com tiles nativos e gera as prévias pelo LibreSprite."""
from interface_referencias import ROOT,read,write
from tileset_catedral import compress,EMPTY
from pathlib import Path
import copy,subprocess,os,json,sys
kit=read(ROOT/'assets/pecas/catalogo.json');plans=[];flags=[]
for level in range(1,4):
 path=ROOT/f'rooms/rm_level{level}/rm_level{level}.yy';room=read(path);layers=room['layers']
 template=copy.deepcopy(next(l for l in layers if l['resourceType']=='GMRTileLayer'))
 for l in layers:
  if l['resourceType']=='GMRBackgroundLayer':l.update(spriteId=None,colour=4279187471,stretch=False)
  if l['resourceType']=='GMRTileLayer':l['visible']=False
 names=['Pedra_Distante','Nave_Media','Reliquias','Piso_Modular']
 grids={k:[EMPTY]*4080 for k in names};anim=[];paint=grids[names[0]]
 def stamp(name,c,r,flip=False):
  m=kit[name];w=m['w']//16;h=m['h']//16
  for yy in range(h):
   for xx in range(w):
    if 0<=r+yy<34 and 0<=c+xx<120:
     index=(m['y']//16+yy)*64+m['x']//16+(w-1-xx if flip else xx)
     paint[(r+yy)*120+c+xx]=index|(0x10000000 if flip else 0)
 for c in range(0,120,2):
  for r in range(0,34,2):
   if r<4+abs(c%16-8)//2 or c%16<4 or r>28+(c%5):stamp('fundo_pedra_'+['06','07','10'][(r+c+level)%3],c,r)
 for c in range(-2,120,14):stamp('fundo_arco_'+('teia' if (c+level)%3 else 'pedra'),c,3+(c+level)%4)
 paint=grids[names[1]]
 for k,c in enumerate(range(-3,120,15)):
  r=7+(k*3+level)%6
  stamp('pilar_'+str(1+(k+level)%4),c,r)
  for row in range(r+10,34,4):stamp('apoio',c+1,row)
  if k%3!=1:stamp('janela_'+str(1+(k+level)%3),c+5,r-2)
  else:anim.append(['estandarte_'+str(1+(k+level)%5),(c+6)*16,(r-1)*16,'Nave_Animada'])
  if k%2:stamp('hera_media',c,r+2)
 instances=[i for l in layers for i in l.get('instances',[])]
 solids=[(int(i['x']),int(i['y']),round(64*i['scaleX']),round(64*i['scaleY'])) for i in instances if i['objectId']['name'] in ('obj_ground','obj_wall')]
 paint=grids[names[2]]
 ground=[q for q in solids if q[1]>=240 and q[2]>=48 and q[3]>=16 and q[0]>=0 and q[1]+q[3]<=548]
 for k,(x,y,w,h) in enumerate(ground):
  col=x//16;row=y//16
  if k%3==0:stamp('lapide_'+str(k%3+1 if k==0 else (k+level)%3+1),col+1,row-4)
  elif k%3==1:stamp('urna_'+str(1+(level+k)%3),col,row-3)
  elif w>=96:stamp('grade_partida',col-4,row-5)
  stamp('apoio',col+w//32,row+h//16)
  if k%2:stamp('hera_curta',col,row+h//16)
  if k%4==1:anim.append(['teia_pendente',x+8,y+h,'Reliquias_Animadas'])
  if k%5==2:anim.append(['gargula_2',x+w-48,y-80,'Reliquias_Animadas'])
  if k%5==4:stamp('gargula_1',col,row-5)
 mask=bytearray(1920*544)
 for x,y,w,h in solids:
  for yy in range(max(0,y),min(544,y+h)):
   lo=max(0,x);hi=min(1920,x+w)
   if hi>lo:mask[yy*1920+lo:yy*1920+hi]=bytes([1])*(hi-lo)
 def inside(x,y):return 0<=x<1920 and 0<=y<544 and mask[y*1920+x]
 paint=grids[names[3]]
 for r in range(34):
  for c in range(120):
   x=c*16+8;y=r*16
   a=inside(x,y);b=inside(x,y+8)
   if not(a or b):continue
   if a!=b:idx=14 if a else 13
   else:
    bits=sum((1<<i) for i,(dx,dy) in enumerate([(0,-1),(1,0),(0,1),(-1,0)]) if inside(x+dx*16,y+8+dy*16))
    m=kit['auto_'+str(bits)];idx=m['y']//16*64+m['x']//16
   paint[r*120+c]=idx
 layers[:]=[l for l in layers if l['name'] not in names]
 for name,depth in zip(names,[750,550,350,180]):
  l=copy.deepcopy(template);l.update(name=name,depth=depth,visible=True,gridX=16,gridY=16,effectEnabled=False,effectType=None,properties=[],tilesetId=dict(name='ts_modular',path='tilesets/ts_modular/ts_modular.yy'),tiles=dict(SerialiseWidth=120,SerialiseHeight=34,TileCompressedData=compress(grids[name])));l['%Name']=name;layers.append(l)
 layers.sort(key=lambda l:l['depth']);write(path,room)
 flags.append('if (room == rm_level'+str(level)+') {\n'+'\n'.join(f'    layer_sprite_create("{layer}", {x}, {y}, spr_mod_{name});' for name,x,y,layer in anim)+'\n}')
 plans.append(dict(level=level,grids=list(grids.values()),anim=anim))
p=ROOT/'objects/obj_level_controller/Create_0.gml';s=p.read_text().split('// Decoração modular por room.')[0];p.write_text(s.rstrip()+'\n\n// Decoração modular por room.\nlayer_create(545,"Nave_Animada");\nlayer_create(345,"Reliquias_Animadas");\n'+'\n'.join(flags)+'\n')
work=ROOT/'tools/arte/.work/pecas';script=work/'preview.js';script.write_text('var rooms='+json.dumps(plans)+';var kit='+json.dumps(kit)+';\n'+(ROOT/'tools/arte/preview_modular.js').read_text())
res=subprocess.run([sys.argv[1],'--batch','--script',str(script)],cwd=ROOT,env=dict(os.environ,APPDATA=str(work)),capture_output=True)
if res.returncode or b'Error:' in res.stdout+res.stderr:raise RuntimeError(res.stdout[-500:])
