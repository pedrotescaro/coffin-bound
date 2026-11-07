"""Monta as três rooms com tiles nativos e gera as prévias pelo LibreSprite."""
from interface_referencias import ROOT,read,write
from tileset_catedral import compress,EMPTY
from pathlib import Path
import copy,subprocess,os,json,sys,uuid
kit=read(ROOT/'assets/pecas/catalogo.json');plans=[]
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
  stamp(['pilar_1','pilar_2','pilar_3','pilar_raizes','pilar_partido'][(k+level)%5],c,r)
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
 sprite_layers=['Nave_Animada','Reliquias_Animadas']
 layers[:]=[l for l in layers if l['name'] not in names+sprite_layers]
 for name,depth in zip(names,[750,550,350,180]):
  l=copy.deepcopy(template);l.update(name=name,depth=depth,visible=True,gridX=16,gridY=16,effectEnabled=False,effectType=None,properties=[],tilesetId=dict(name='ts_modular',path='tilesets/ts_modular/ts_modular.yy'),tiles=dict(SerialiseWidth=120,SerialiseHeight=34,TileDataFormat=1,TileCompressedData=compress([0 if tile==EMPTY else tile for tile in grids[name]])));l['%Name']=name;layers.append(l)
 # Salva os sprites animados como elementos nativos para a IDE mostrá-los ao abrir.
 for layer_name,depth in zip(sprite_layers,[545,345]):
  asset_layer=copy.deepcopy(template)
  for key in ('$GMRTileLayer','tiles','tilesetId','x','y'):asset_layer.pop(key,None)
  asset_layer.update(name=layer_name,depth=depth,visible=True,effectEnabled=False,effectType=None,properties=[],assets=[],resourceType='GMRAssetLayer')
  asset_layer['$GMRAssetLayer']='';asset_layer['%Name']=layer_name
  for piece,x,y,target in anim:
   if target!=layer_name:continue
   graphic='graphic_'+uuid.uuid5(uuid.NAMESPACE_URL,f'coffin/{level}/{piece}/{x}/{y}').hex[:12]
   sprite='spr_mod_'+piece
   asset_layer['assets'].append({'$GMRSpriteGraphic':'v1','%Name':graphic,'name':graphic,'resourceType':'GMRSpriteGraphic','resourceVersion':'2.0','animationSpeed':1.0,'colour':4294967295,'frozen':False,'headPosition':0.0,'ignore':False,'inheritedItemId':None,'inheritItemSettings':False,'rotation':0,'scaleX':1,'scaleY':1,'spriteId':dict(name=sprite,path=f'sprites/{sprite}/{sprite}.yy'),'x':x,'y':y})
  asset_layer['assets']=[dict(sorted(a.items())) for a in asset_layer['assets']]
  layers.append(dict(sorted(asset_layer.items())))
 layers.sort(key=lambda l:l['depth']);write(path,room)
 saved=read(path)['layers'];disk_grids=[];disk_anim=[]
 for name in names:
  tiles=next(l for l in saved if l['name']==name)['tiles']
  assert tiles['TileDataFormat']==1
  data=iter(tiles['TileCompressedData']);cells=[]
  for count in data:
   if count<0:cells.extend([next(data)]*(-count))
   else:cells.extend(next(data) for _ in range(count))
  assert len(cells)==4080 and any(cells)
  assert cells==[0 if t==EMPTY else t for t in grids[name]]
  disk_grids.append([t if t else EMPTY for t in cells])
 for name in sprite_layers:
  for a in next(l for l in saved if l['name']==name)['assets']:
   disk_anim.append([a['spriteId']['name'].removeprefix('spr_mod_'),a['x'],a['y'],name])
 pose=json.loads(subprocess.check_output(['node','--preserve-symlinks-main',str(ROOT/'tools/arte/pose_desafios.cjs'),str(level-1)],text=True))
 props=[]
 for i in instances:
  name=i['objectId']['name']
  if name not in ('obj_spike','obj_player','obj_coffin'):continue
  obj=read(ROOT/i['objectId']['path']);sprite=read(ROOT/obj['spriteId']['path'])
  props.append(dict(name=name,x=i['x'],y=i['y'],sx=i['scaleX'],sy=i['scaleY'],ox=sprite['sequence']['xorigin'],oy=sprite['sequence']['yorigin'],path='sprites/'+sprite['name']+'/'+sprite['frames'][0]['name']+'.png'))
 plans.append(dict(level=level,grids=disk_grids,anim=disk_anim,pose=pose,props=props))
work=ROOT/'tools/arte/.work/pecas';script=work/'preview.js';script.write_text('var rooms='+json.dumps(plans)+';var kit='+json.dumps(kit)+';\n'+(ROOT/'tools/arte/preview_modular.js').read_text())
res=subprocess.run([sys.argv[1],'--batch','--script',str(script)],cwd=ROOT,env=dict(os.environ,APPDATA=str(work)),capture_output=True)
if res.returncode or b'Error:' in res.stdout+res.stderr:raise RuntimeError(res.stdout[-500:])
