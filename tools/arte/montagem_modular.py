"""Monta arquitetura modular sem sobrepor recortes de peças grandes no mesmo tilemap."""
from interface_referencias import ROOT, read, write
from tileset_catedral import compress, EMPTY
import copy, json, os, subprocess, sys, uuid

kit = read(ROOT/'assets/pecas/catalogo.json')
plans = []
for level in range(1, 4):
    path = ROOT/f'rooms/rm_level{level}/rm_level{level}.yy'
    room = read(path)
    layers = room['layers']
    template = copy.deepcopy(next(l for l in layers if l['resourceType']=='GMRTileLayer'))
    background = copy.deepcopy(next(l for l in layers if l['resourceType']=='GMRBackgroundLayer'))
    for layer in layers:
        if layer['resourceType']=='GMRBackgroundLayer':
            layer.update(spriteId=None, colour=4279187471, stretch=False)
        if layer['resourceType']=='GMRTileLayer':
            layer['visible'] = False
    names = ['Pedra_Distante', 'Piso_Modular']
    grids = {name:[EMPTY]*4080 for name in names}
    graphics = []
    def graphic(piece, x, y, layer, shadow=True):
        graphics.append(dict(piece=piece, x=x, y=y, layer=layer, shadow=shadow))
    def stamp(name, col, row):
        m = kit[name]
        for yy in range(m['h']//16):
            for xx in range(m['w']//16):
                if 0<=row+yy<34 and 0<=col+xx<120:
                    index = (m['y']//16+yy)*64+m['x']//16+xx
                    grids['Pedra_Distante'][(row+yy)*120+col+xx] = index
    # Arcos inteiros, com espaço entre os módulos e alinhados ao mesmo nível.
    for k, col in enumerate(range(0, 120, 12)):
        stamp('fundo_arco_'+('teia' if (k+level)%3==0 else 'pedra'), col, 4)
    # Uma nave independente. Colunas e vitrais são sprites inteiros, nunca recortes sobrescritos.
    for k, x in enumerate(range(0, 1920, 224)):
        graphic('pilar_'+str(1+(k+level)%3), x, 240, 'Nave_Media')
        graphic('janela_'+str(1+(k+level)%3), x+64, 208, 'Nave_Media')
        if k%2==0:
            graphic('estandarte_'+str(1+(k+level)%5), x+176, 224, 'Nave_Animada')
        if k%3==1:
            graphic('hera_media', x, 256, 'Nave_Media')
        if k%2:
            graphic('teia', x+128, 144, 'Ornamentos_Proximos')
    instances = [i for layer in layers for i in layer.get('instances', [])]
    solids = [(int(i['x']), int(i['y']), round(64*i['scaleX']), round(64*i['scaleY']))
              for i in instances if i['objectId']['name'] in ('obj_ground','obj_wall')]
    # Peças apoiadas no chão ficam no mundo; o parallax nunca desloca sua base.
    for k, (x,y,w,h) in enumerate(solids):
        if y<240 or w<64 or h<16 or x<0 or x+w>1920 or y+h>548:
            continue
        piece = ('lapide_'+str(1+(k+level)%3)) if k%2 else ('urna_'+str(1+(k+level)%3))
        m = kit[piece]
        dx = x+w-m['w']-8
        # Deixa livre a área do spawn, da porta e dos espinhos.
        blocked = any(i['objectId']['name'] in ('obj_spike','obj_player','obj_coffin')
                      and abs(i['x']-dx)<64 and abs(i['y']-y)<80 for i in instances)
        if not blocked:
            graphic(piece, dx, y-m['h'], 'Reliquias')
        if h<=64 and y+h+48<540:
            graphic('hera_curta', x+min(16,w-32), y+h, 'Reliquias')
        if k%4==0 and y+h+64<540:
            graphic('teia_pendente', x+w-48, y+h, 'Reliquias_Animadas')
    mask = bytearray(1920*544)
    for x,y,w,h in solids:
        for yy in range(max(0,y), min(544,y+h)):
            lo,hi = max(0,x), min(1920,x+w)
            if hi>lo:
                mask[yy*1920+lo:yy*1920+hi] = bytes([1])*(hi-lo)
    def inside(x,y):
        return 0<=x<1920 and 0<=y<544 and mask[y*1920+x]
    for row in range(34):
        for col in range(120):
            x,y = col*16+8, row*16
            a,b = inside(x,y), inside(x,y+8)
            if not(a or b):
                continue
            if a!=b:
                index = 14 if a else 13
            else:
                bits = sum(1<<i for i,(dx,dy) in enumerate([(0,-1),(1,0),(0,1),(-1,0)])
                           if inside(x+dx*16,y+8+dy*16))
                m = kit['auto_'+str(bits)]
                index = m['y']//16*64+m['x']//16
            grids['Piso_Modular'][row*120+col] = index
    asset_depths = {'Nave_Media':550, 'Nave_Animada':545, 'Ornamentos_Proximos':450,
                    'Reliquias':350, 'Reliquias_Animadas':345}
    generated = names+list(asset_depths)+['Fundo_Distante']
    layers[:] = [l for l in layers if l['name'] not in generated]
    for name,depth in zip(names,[750,180]):
        layer = copy.deepcopy(template)
        layer.update(name=name, depth=depth, visible=True, gridX=16, gridY=16, x=0, y=0,
                     effectEnabled=False, effectType=None, properties=[],
                     tilesetId=dict(name='ts_modular',path='tilesets/ts_modular/ts_modular.yy'),
                     tiles=dict(SerialiseWidth=120,SerialiseHeight=34,TileDataFormat=1,
                                TileCompressedData=compress([0 if t==EMPTY else t for t in grids[name]])))
        layer['%Name'] = name
        layers.append(layer)
    for name,depth in asset_depths.items():
        layer = copy.deepcopy(template)
        for key in ('$GMRTileLayer','tiles','tilesetId','x','y'):
            layer.pop(key,None)
        layer.update(name=name, depth=depth, visible=True, effectEnabled=False,
                     effectType=None, properties=[], assets=[], resourceType='GMRAssetLayer')
        layer['$GMRAssetLayer']=''
        layer['%Name']=name
        for g in graphics:
            if g['layer']!=name:
                continue
            sprite = ('spr_bg_' if g['shadow'] else 'spr_mod_')+g['piece']
            graphic_name = 'graphic_'+uuid.uuid5(uuid.NAMESPACE_URL,
                f"coffin/{level}/{sprite}/{g['x']}/{g['y']}").hex[:12]
            layer['assets'].append(dict(sorted({'$GMRSpriteGraphic':'v1','%Name':graphic_name,
                'name':graphic_name,'resourceType':'GMRSpriteGraphic','resourceVersion':'2.0',
                'animationSpeed':1.0,'colour':4294967295,'frozen':False,'headPosition':0.0,
                'ignore':False,'inheritedItemId':None,'inheritItemSettings':False,'rotation':0,
                'scaleX':1,'scaleY':1,'spriteId':dict(name=sprite,path=f'sprites/{sprite}/{sprite}.yy'),
                'x':g['x'],'y':g['y']}.items())))
        layers.append(dict(sorted(layer.items())))
    background.update(name='Fundo_Distante', depth=790, visible=True, colour=4294967295,
                      spriteId=dict(name='spr_bg_parede',path='sprites/spr_bg_parede/spr_bg_parede.yy'),
                      htiled=True, vtiled=True, stretch=False, x=0, y=0, hspeed=0, vspeed=0)
    background['%Name']='Fundo_Distante'
    layers.append(background)
    layers.sort(key=lambda l:l['depth'])
    write(path,room)
    # A prévia lê o arquivo persistido, incluindo a ordem real das camadas.
    saved=read(path)
    scene=[]
    for layer in sorted(saved['layers'],key=lambda l:-l['depth']):
        if not layer['visible']:
            continue
        if layer['name']=='Fundo_Distante':
            scene.append(dict(kind='background',name=layer['name'],path='assets/pecas/fundo/parede_0.png'))
        elif layer['name'] in names:
            data=iter(layer['tiles']['TileCompressedData']);cells=[]
            for count in data:
                if count<0: cells.extend([next(data)]*(-count))
                else: cells.extend(next(data) for _ in range(count))
            assert cells==[0 if t==EMPTY else t for t in grids[layer['name']]]
            scene.append(dict(kind='tiles',name=layer['name'],cells=cells))
        elif layer['name'] in asset_depths:
            pieces=[]
            for a in layer['assets']:
                sprite=read(ROOT/a['spriteId']['path'])
                pieces.append(dict(x=a['x'],y=a['y'],path=f"sprites/{sprite['name']}/{sprite['frames'][0]['name']}.png"))
            scene.append(dict(kind='assets',name=layer['name'],pieces=pieces))
    pose=json.loads(subprocess.check_output(['node','--preserve-symlinks-main',str(ROOT/'tools/arte/pose_desafios.cjs'),str(level-1)],text=True))
    props=[]
    for i in instances:
        name=i['objectId']['name']
        if name not in ('obj_spike','obj_player','obj_coffin'):continue
        obj=read(ROOT/i['objectId']['path']);sprite=read(ROOT/obj['spriteId']['path'])
        props.append(dict(name=name,x=i['x'],y=i['y'],sx=i['scaleX'],sy=i['scaleY'],ox=sprite['sequence']['xorigin'],oy=sprite['sequence']['yorigin'],path='sprites/'+sprite['name']+'/'+sprite['frames'][0]['name']+'.png'))
    plans.append(dict(level=level,scene=scene,pose=pose,props=props))
work=ROOT/'tools/arte/.work/pecas'
work.mkdir(parents=True,exist_ok=True)
script=work/'preview.js'
script.write_text('var rooms='+json.dumps(plans)+';var kit='+json.dumps(kit)+';\n'+(ROOT/'tools/arte/preview_modular.js').read_text(),encoding='utf8')
res=subprocess.run([sys.argv[1],'--batch','--script',str(script)],cwd=ROOT,env=dict(os.environ,APPDATA=str(work)),capture_output=True)
if res.returncode or b'Error:' in res.stdout+res.stderr:raise RuntimeError(res.stdout[-1000:]+res.stderr[-1000:])
