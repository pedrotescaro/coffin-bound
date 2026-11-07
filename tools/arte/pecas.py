from pathlib import Path
from interface_referencias import ROOT,read,write
import json,copy,shutil,subprocess,os,sys,uuid
exe=sys.argv[1];out=ROOT/'assets/pecas';out.mkdir(exist_ok=True);work=ROOT/'tools/arte/.work/pecas';work.mkdir(parents=True,exist_ok=True)
def batch(args):
 r=subprocess.run([exe,'--batch',*args],cwd=ROOT,capture_output=True,env=dict(os.environ,APPDATA=str(work)))
 if r.returncode or b'Error:' in r.stdout+r.stderr:raise RuntimeError((r.stdout+r.stderr)[-1000:])
items={m['name']:dict(name=m['name'],x=m['x'],y=m['y'],w=m['w'],h=m['h'],sx=m['x'],sy=m['y'],sw=m['w'],sh=m['h']) for m in read(ROOT/'assets/tileset/modules.json')['modules']}
x=0;y=512;rowh=0
def extra(name,base,w,h):
 global x,y,rowh
 if x+w>1024:x=0;y+=rowh;rowh=0
 m=dict(items[base],name=name,w=w,h=h,x=x,y=y);items[name]=m;x+=w;rowh=max(h,rowh)
for name,base,w,h in [('pilar_partido','pilar_1',32,80),('hera_curta','trepadeiras',32,48),('hera_media','trepadeiras',32,96),('grade_partida','grade',224,80),('grade_ferrugem','grade',224,80),('teia_central','teia',48,64),('teia_pendente','teia',48,64),('porta_aberta','portal',80,96),('porta_fechada','portal',80,96),('porta_luz','portal',80,96),('passarela_fina','plataforma_musgo_1',64,16),('apoio','pilar_1',16,64)]:extra(name,base,w,h)
for mask in range(16):extra('auto_'+str(mask),'pedra_05',16,16)
for name in ['arco_pedra','arco_teia','pedra_06','pedra_07','pedra_10']:extra('fundo_'+name,name,items[name]['w'],items[name]['h'])
for m in items.values():
 m['frames']=4 if m['name'].startswith('estandarte') else 2 if m['name'].startswith('teia') or m['name']=='gargula_2' else 1
assert max(m['y']+m['h'] for m in items.values())<=1024
batch(['assets/tileset/cathedral_16.png','--scale','2','--save-as',str(work/'canvas.png')])
script=work/'render.js';script.write_text('var pieces='+json.dumps(list(items.values()))+';\n'+(ROOT/'tools/arte/pecas.js').read_text(encoding='utf8'),encoding='utf8');batch(['--script',str(script)])
project=read(ROOT/'Coffin Bound final.yyp')
def register(name,kind):
 path=f'{kind}/{name}/{name}.yy'
 if not any(r['id']['name']==name for r in project['resources']):project['resources'].append(dict(id=dict(name=name,path=path)))
 return ROOT/path
def resource(name,w,h,frames):
 path=register(name,'sprites');path.parent.mkdir(exist_ok=True)
 d=read(ROOT/'sprites/spr_challenge_atlas/spr_challenge_atlas.yy');d.update(name=name,width=w,height=h,bbox_right=w-1,bbox_bottom=h-1);d['%Name']=name
 seq=d['sequence'];seq['%Name']=seq['name']=name;seq['length']=len(frames);seq['playbackSpeed']=5
 uid=lambda label:str(uuid.uuid5(uuid.NAMESPACE_URL,name+'/'+label))
 layer=uid('layer');d['layers'][0].update(name=layer);d['layers'][0]['%Name']=layer
 orig=d['frames'][0];keys=seq['tracks'][0]['keyframes'];key=keys['Keyframes'][0];keys['Keyframes']=[];d['frames']=[]
 for i,src in enumerate(frames):
  frame=uid(str(i));fr=dict(orig,name=frame);fr['%Name']=frame;d['frames'].append(fr);k=copy.deepcopy(key);k.update(id=uid('key'+str(i)),Key=i);k['Channels']['0']['Id']=dict(name=frame,path=path.relative_to(ROOT).as_posix());keys['Keyframes'].append(k)
  ld=path.parent/'layers'/frame;ld.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,path.parent/(frame+'.png'));shutil.copyfile(src,ld/(layer+'.png'))
 write(path,d)
for m in items.values():resource('spr_mod_'+m['name'],m['w'],m['h'],[out/(m['name']+'_'+str(i)+'.png') for i in range(m['frames'])])
resource('spr_mod_atlas',1024,1024,[out/'atlas.png'])
t=read(ROOT/'tilesets/ts_catedral_16/ts_catedral_16.yy');t['%Name']=t['name']='ts_modular';t['tile_count']=4096;t['spriteId']=dict(name='spr_mod_atlas',path='sprites/spr_mod_atlas/spr_mod_atlas.yy');p=register('ts_modular','tilesets');p.parent.mkdir(exist_ok=True);write(p,t);write(ROOT/'Coffin Bound final.yyp',project);write(out/'catalogo.json',items)
