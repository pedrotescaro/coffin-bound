"""LibreSprite escreve o atlas; este script registra tileset/camadas no GameMaker."""
from pathlib import Path
import argparse,copy,json,os,re,shutil,subprocess,uuid
from interface_referencias import read,write

ROOT=Path(__file__).resolve().parents[2]
EMPTY=-2147483648

def compress(data):
    out=[];i=0
    while i<len(data):
        j=i+1
        while j<len(data) and data[j]==data[i]:j+=1
        if j-i>=3:out.extend((i-j,data[i]));i=j;continue
        start=i;i=j
        while i<len(data):
            j=i+1
            while j<len(data) and data[j]==data[i]:j+=1
            if j-i>=3:break
            i=j
        out.append(i-start);out.extend(data[start:i])
    return out

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--libresprite',required=True);args=parser.parse_args()
    out=ROOT/'assets/tileset';out.mkdir(exist_ok=True)
    work=ROOT/'tools/arte/.work/tileset';work.mkdir(parents=True,exist_ok=True)
    colors=[tuple(map(int,l.split()[:3])) for l in (ROOT/'art/palette/gameboy-green-16.gpl').read_text().splitlines() if l.strip() and l.split()[0].isdigit()]
    modules=[]
    def module(name,x,y,w,h,sx,sy,sw,sh,transparent=True):
        assert all(v%16==0 for v in (x,y,w,h))
        assert x+w<=1024 and y+h<=512
        modules.append(dict(name=name,x=x,y=y,w=w,h=h,sx=sx,sy=sy,sw=sw,sh=sh,transparent=transparent))
    samples=[(0,0),(34,0),(68,0),(102,0),(173,0),(207,0),(240,0),(274,0),
             (307,0),(343,34),(376,34),(410,34),(444,34),(478,34),(511,34),(376,68)]
    for i,(sx,sy) in enumerate(samples):module(f'pedra_{i+1:02}',i*32,16,32,32,sx,sy,34,33,False)
    module('cornija_longa',512,0,240,32,545,0,205,32)
    module('portal_superior',768,0,256,48,852,0,172,33)
    for i,(sx,sw) in enumerate([(0,34),(69,36),(105,36),(143,64)]):
        module(f'pilar_{i+1}',i*48,64,32 if i<3 else 64,160,sx,165,sw,164)
    module('arco_teia',224,64,160,160,207,165,141,161)
    module('arco_pedra',384,64,160,160,345,165,165,161)
    for i,(sx,sy,sw,sh) in enumerate([(6,344,98,144),(109,341,98,147),(213,341,96,148)]):
        module(f'janela_{i+1}',560+i*112,64,96,160,sx,sy,sw,sh)
    module('trepadeiras',896,64,64,192,515,132,96,194)
    module('pilar_raizes',976,64,32,192,306,326,41,239)
    module('grade',0,256,224,80,0,491,222,81)
    for i in range(5):module(f'estandarte_{i+1}',240+i*32,256,32,64,616+i*34,171,30,49)
    for i,(sx,sy,sw,sh) in enumerate([(650,292,34,51),(689,303,27,41),(752,299,33,49)]):
        module(f'lapide_{i+1}',416+i*48,256,32,64,sx,sy,sw,sh)
    for i in range(3):module(f'urna_{i+1}',560+i*48,256,32,48,753+i*35,232,30,43)
    module('gargula_1',704,256,64,80,849,280,67,78)
    module('gargula_2',784,256,64,80,950,282,73,78)
    module('teia',864,256,48,64,918,289,37,50)
    module('raiz_longa',928,288,64,192,548,132,67,195)
    module('portal',0,352,208,144,544,0,208,132)
    module('sombra_canto',224,352,64,64,750,67,69,68)
    module('sombra_interna',304,352,64,64,853,67,69,68)
    module('pedra_quebrada',384,352,128,64,341,99,137,66)
    for i,(sx,sw) in enumerate([(342,202),(545,202),(748,171)]):
        module(f'plataforma_musgo_{i+1}',224+i*192,432,192 if i<2 else 160,64,sx,354,sw,64)
    # Interseção de retângulos acusaria qualquer módulo empacotado sobre outro.
    for i,a in enumerate(modules):
        for b in modules[i+1:]:
            assert a['x']+a['w']<=b['x'] or b['x']+b['w']<=a['x'] or a['y']+a['h']<=b['y'] or b['y']+b['h']<=a['y'],(a['name'],b['name'])
    script=work/'run.js';script.write_text('var tileJob='+json.dumps(dict(palette=colors,modules=modules))+';\n'+(ROOT/'tools/arte/tileset_catedral.js').read_text(encoding='utf-8'),encoding='utf-8')
    result=subprocess.run([args.libresprite,'--batch','--script',str(script)],cwd=ROOT,env=dict(os.environ,APPDATA=str(ROOT/'tools/arte/.work/config')),capture_output=True,text=True)
    (work/'libresprite.log').write_text(result.stdout+result.stderr,encoding='utf-8')
    if result.returncode or re.search(r'Error:|terminate called',result.stdout+result.stderr):raise RuntimeError(result.stdout+result.stderr)
    write(out/'modules.json',dict(tile_size=16,columns=64,rows=32,empty_tile=0,technical_tiles=list(range(1,16)),modules=modules))
    name='spr_tileset_catedral';folder=ROOT/'sprites'/name;folder.mkdir(exist_ok=True);path=folder/(name+'.yy')
    if path.exists():data=read(path)
    else:
        data=copy.deepcopy(read(ROOT/'sprites/spr_challenge_atlas/spr_challenge_atlas.yy'))
        data['%Name']=data['name']=name;data['width']=1024;data['height']=512;data['bbox_right']=1023;data['bbox_bottom']=511
        data['parent']=dict(name='tiles',path='folders/Sprites/tiles.yy')
        data['sequence']['%Name']=data['sequence']['name']=name
        frame=str(uuid.uuid5(uuid.NAMESPACE_URL,name+'/frame'));layer=str(uuid.uuid5(uuid.NAMESPACE_URL,name+'/layer'))
        data['frames'][0]['%Name']=data['frames'][0]['name']=frame;data['layers'][0]['%Name']=data['layers'][0]['name']=layer
        key=data['sequence']['tracks'][0]['keyframes']['Keyframes'][0];key['id']=str(uuid.uuid5(uuid.NAMESPACE_URL,name+'/key'));key['Channels']['0']['Id']=dict(name=frame,path=f'sprites/{name}/{name}.yy')
        write(path,data)
    frame,layer=data['frames'][0]['name'],data['layers'][0]['name'];ld=folder/'layers'/frame;ld.mkdir(parents=True,exist_ok=True)
    for dest in (folder/(frame+'.png'),ld/(layer+'.png')):shutil.copyfile(out/'cathedral_16.png',dest)
    name='ts_catedral_16';folder=ROOT/'tilesets'/name;folder.mkdir(exist_ok=True)
    data=copy.deepcopy(read(ROOT/'tilesets/ts_grass/ts_grass.yy'));data['%Name']=data['name']=name
    data['spriteId']=dict(name='spr_tileset_catedral',path='sprites/spr_tileset_catedral/spr_tileset_catedral.yy');data['tile_count']=2048
    write(folder/(name+'.yy'),data)
    project_path=ROOT/'Coffin Bound final.yyp';project=read(project_path)
    missing=[]
    for name,kind in [('spr_tileset_catedral','sprites'),('ts_catedral_16','tilesets')]:
        if not any(r['id']['name']==name for r in project['resources']):missing.append(dict(id=dict(name=name,path=f'{kind}/{name}/{name}.yy')))
    if missing:
        text=project_path.read_text(encoding='utf-8');start=text.index('[',text.index('"resources"'));depth=1;end=start+1
        while depth:
            depth+=(text[end]=='[')-(text[end]==']');end+=1
        insert=text.rfind('\n',0,end-1)+1
        prefix=text[:insert]
        if not prefix.rstrip().endswith(','):prefix=prefix.rstrip()+',\n'
        project_path.write_text(prefix+''.join('    '+json.dumps(r)+',\n' for r in missing)+text[insert:],encoding='utf-8',newline='\n')
    reports=[];previews=[]
    for n in range(1,4):
        path=ROOT/f'rooms/rm_level{n}/rm_level{n}.yy';room=read(path);mask=bytearray(1920*544)
        for l in room['layers']:
            for inst in l.get('instances',[]):
                if inst['objectId']['name'] not in ('obj_ground','obj_wall'):continue
                x,y,w,h=round(inst['x']),round(inst['y']),round(inst['scaleX']*64),round(inst['scaleY']*64)
                for yy in range(max(0,y),min(544,y+h)):
                    for xx in range(max(0,x),min(1920,x+w)):mask[yy*1920+xx]=1
        values=[];partial=0
        for row in range(34):
            for col in range(120):
                x,y=col*16,row*16
                rows=[sum(mask[(y+dy)*1920+x:(y+dy)*1920+x+16]) for dy in range(16)]
                if not sum(rows):values.append(EMPTY);continue
                if rows==[0]*8+[16]*8:values.append(13);partial+=1;continue
                if rows==[16]*8+[0]*8:values.append(14);partial+=1;continue
                assert rows==[16]*16 or (row==33 and all(v==16 for v in rows[:12])),(n,x,y,rows)
                def inside(xx,yy):return 0<=xx<1920 and 0<=yy<544 and bool(mask[yy*1920+xx])
                top=not inside(x+8,y-1);bottom=not inside(x+8,y+16);left=not inside(x-1,y+8);right=not inside(x+16,y+8)
                if top:index=1 if left else 3 if right else 2
                elif bottom:index=7 if left else 9 if right else 8
                elif left:index=4
                elif right:index=6
                else:index=10 if (col+row*3)%13==0 else 11 if (col+row)%17==0 else 5
                values.append(index)
        layer=copy.deepcopy(next(l for l in room['layers'] if l['resourceType']=='GMRTileLayer'))
        layer['%Name']=layer['name']='Tiles_Catedral_Frente';layer['depth']=180;layer['visible']=True
        layer['gridX']=layer['gridY']=16;layer['effectEnabled']=False;layer['effectType']=None;layer['properties']=[]
        layer['tilesetId']=dict(name='ts_catedral_16',path='tilesets/ts_catedral_16/ts_catedral_16.yy')
        layer['tiles']=dict(SerialiseHeight=34,SerialiseWidth=120,TileCompressedData=compress(values))
        decor=copy.deepcopy(layer);decor['%Name']=decor['name']='Tiles_Catedral_Decor';decor['depth']=650
        decor['tiles']=dict(SerialiseHeight=34,SerialiseWidth=120,TileCompressedData=[-4080,EMPTY])
        room['layers']=[l for l in room['layers'] if l['name'] not in ('Tiles_Catedral_Frente','Tiles_Catedral_Decor')]+[layer,decor]
        room['layers'].sort(key=lambda l:l['depth']);write(path,room)
        reports.append(dict(room=n,painted_cells=sum(v!=EMPTY for v in values),half_tiles=partial))
        label=['entrance','nave','final'][n-1]
        background=work/(label+'.png')
        # Nomes sem número impedem importação automática como sequência de frames.
        shutil.copyfile(ROOT/f'assets/environment/level{n}.png',background)
        previews.append(dict(level=n,tiles=values,source=background.as_posix(),label=label))
    write(out/'integration.json',dict(rooms=reports))
    preview_script=work/'preview.js'
    preview_script.write_text('var previewTileJobs='+json.dumps(previews)+';\n'+(ROOT/'tools/arte/preview_tileset.js').read_text(encoding='utf-8'),encoding='utf-8')
    result=subprocess.run([args.libresprite,'--batch','--script',str(preview_script)],cwd=ROOT,env=dict(os.environ,APPDATA=str(ROOT/'tools/arte/.work/config')),capture_output=True,text=True)
    if result.returncode or re.search(r'Error:|terminate called',result.stdout+result.stderr):raise RuntimeError(result.stdout+result.stderr)
    print('LibreSprite: atlas modular 1024x512, 16px, tileset nativo e camadas das três rooms criados.')

if __name__=='__main__':main()
