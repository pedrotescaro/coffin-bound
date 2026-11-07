"""Orquestra LibreSprite e sincroniza exports; não escreve pixels com Python."""
from pathlib import Path
import argparse, copy, json, os, re, shutil, subprocess, uuid
from interface_referencias import read, write

ROOT = Path(__file__).resolve().parents[2]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--libresprite', required=True)
    args = parser.parse_args()
    work = ROOT/'tools/arte/.work/challenges'
    work.mkdir(parents=True, exist_ok=True)
    (ROOT/'assets/challenges').mkdir(exist_ok=True)
    levels = []
    for level in range(1,4):
        room = read(ROOT/f'rooms/rm_level{level}/rm_level{level}.yy')
        solids, spikes = [], []
        for layer in room['layers']:
            for inst in layer.get('instances', []):
                if inst['objectId']['name'] in ('obj_ground','obj_wall'):
                    solids.append(dict(x=round(inst['x']), y=round(inst['y']),
                        w=round(inst['scaleX']*64), h=round(inst['scaleY']*64)))
                elif inst['objectId']['name']=='obj_spike':
                    spikes.append(dict(x=round(inst['x']),y=round(inst['y']),w=round(inst['scaleX']*16)))
        levels.append(dict(solids=solids,spikes=spikes))
    script = work/'run.js'
    glyphs = read(ROOT/'fonts/fnt_monogram/fnt_monogram.yy')['glyphs']
    script.write_text('var challengeArtJob='+json.dumps(dict(levels=levels,glyphs=glyphs))+';\n'+
        (ROOT/'tools/arte/polir_desafios.js').read_text(encoding='utf-8'), encoding='utf-8')
    env = dict(os.environ, APPDATA=str(ROOT/'tools/arte/.work/config'))
    result = subprocess.run([args.libresprite, '--batch', '--script', str(script)],
        cwd=ROOT, env=env, capture_output=True, text=True)
    (work/'libresprite.log').write_text(result.stdout+result.stderr, encoding='utf-8')
    if result.returncode or re.search(r'Error:|terminate called', result.stdout+result.stderr):
        raise RuntimeError(result.stdout+result.stderr)
    project_path = ROOT/'Coffin Bound final.yyp'
    project = read(project_path)
    for name, source in [('spr_challenge_atlas','assets/challenges/challenge_atlas.png'),
                         ('spr_spike','assets/challenges/spike.png')]+[
                         (f'spr_level_green_{n}',f'assets/environment/level{n}.png') for n in range(1,4)]:
        folder = ROOT/'sprites'/name
        folder.mkdir(exist_ok=True)
        path = folder/(name+'.yy')
        if path.exists():
            data = read(path)
        else:
            data = copy.deepcopy(read(ROOT/'sprites/spr_dialogue_frame/spr_dialogue_frame.yy'))
            data['%Name'] = data['name'] = name
            data['width'], data['height'] = 256, 160
            data['bbox_right'], data['bbox_bottom'] = 255, 159
            data['sequence']['%Name'] = data['sequence']['name'] = name
            frame = str(uuid.uuid5(uuid.NAMESPACE_URL,name+'/frame'))
            layer = str(uuid.uuid5(uuid.NAMESPACE_URL,name+'/layer'))
            data['frames'][0]['%Name'] = data['frames'][0]['name'] = frame
            data['layers'][0]['%Name'] = data['layers'][0]['name'] = layer
            key = data['sequence']['tracks'][0]['keyframes']['Keyframes'][0]
            key['id'] = str(uuid.uuid5(uuid.NAMESPACE_URL,name+'/key'))
            key['Channels']['0']['Id'] = dict(name=frame,path=f'sprites/{name}/{name}.yy')
            write(path,data)
        frame, layer = data['frames'][0]['name'], data['layers'][0]['name']
        layer_dir = folder/'layers'/frame
        layer_dir.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(ROOT/source,folder/(frame+'.png'))
        shutil.copyfile(ROOT/source,layer_dir/(layer+'.png'))
        if not any(r['id']['name']==name for r in project['resources']):
            project['resources'].append(dict(id=dict(name=name,path=f'sprites/{name}/{name}.yy')))
    # Preserva a formatação compacta da IDE e acrescenta somente o novo recurso.
    text = project_path.read_text(encoding='utf-8')
    if '"spr_challenge_atlas"' not in text:
        pos = text.index('[',text.index('"resources"'))+1
        text = text[:pos]+'\n    '+json.dumps(dict(id=dict(name='spr_challenge_atlas',
            path='sprites/spr_challenge_atlas/spr_challenge_atlas.yy')))+','+text[pos:]
        project_path.write_text(text,encoding='utf-8',newline='\n')
    print('LibreSprite: atlas 256x160, espinho 16x16 e revestimento das três rooms sincronizados.')

if __name__ == '__main__':
    main()
