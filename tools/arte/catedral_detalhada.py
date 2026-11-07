"""Adapta a referência no LibreSprite; Python não escreve pixels."""
from pathlib import Path
import argparse, json, os, re, shutil, subprocess
from interface_referencias import read

ROOT=Path(__file__).resolve().parents[2]

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--libresprite',required=True)
    args=parser.parse_args()
    work=ROOT/'tools/arte/.work/cathedral'
    work.mkdir(parents=True,exist_ok=True)
    (ROOT/'assets/cathedral').mkdir(exist_ok=True)
    levels=[]
    for n in range(1,4):
        room=read(ROOT/f'rooms/rm_level{n}/rm_level{n}.yy')
        solids=[];instances=[]
        for layer in room['layers']:
            for inst in layer.get('instances',[]):
                name=inst['objectId']['name']
                if name in ('obj_ground','obj_wall'):
                    solids.append(dict(x=round(inst['x']),y=round(inst['y']),
                        w=round(inst['scaleX']*64),h=round(inst['scaleY']*64)))
                elif name in ('obj_player','obj_spike','obj_candle','obj_coffin'):
                    obj=read(ROOT/inst['objectId']['path'])
                    sprite=read(ROOT/obj['spriteId']['path'])
                    instances.append(dict(name=name,x=inst['x'],y=inst['y'],sx=inst['scaleX'],sy=inst['scaleY'],
                        source=f"sprites/{sprite['name']}/{sprite['frames'][0]['name']}.png",
                        ox=sprite['sequence']['xorigin'],oy=sprite['sequence']['yorigin']))
        levels.append(dict(solids=solids,instances=instances))
    colors=[tuple(map(int,line.split()[:3])) for line in (ROOT/'art/palette/gameboy-green-16.gpl').read_text(encoding='utf-8').splitlines() if line.strip() and line.split()[0].isdigit()]
    script=work/'run.js'
    script.write_text('var cathedralJob='+json.dumps(dict(levels=levels,palette=colors))+';\n'+
        (ROOT/'tools/arte/catedral_detalhada.js').read_text(encoding='utf-8'),encoding='utf-8')
    result=subprocess.run([args.libresprite,'--batch','--script',str(script)],cwd=ROOT,
        env=dict(os.environ,APPDATA=str(ROOT/'tools/arte/.work/config')),capture_output=True,text=True)
    (work/'libresprite.log').write_text(result.stdout+result.stderr,encoding='utf-8')
    if result.returncode or re.search(r'Error:|terminate called',result.stdout+result.stderr):
        raise RuntimeError(result.stdout+result.stderr)
    for n in range(1,4):
        folder=ROOT/f'sprites/spr_level_green_{n}'
        data=read(folder/f'spr_level_green_{n}.yy')
        frame,layer=data['frames'][0]['name'],data['layers'][0]['name']
        for dest in (folder/(frame+'.png'),folder/'layers'/frame/(layer+'.png')):
            shutil.copyfile(ROOT/f'assets/environment/level{n}.png',dest)
    print('LibreSprite: três cenários 1920x540, fontes editáveis e prévias exportados; IDs preservados.')

if __name__=='__main__':main()
