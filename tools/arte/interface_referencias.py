"""Orquestra LibreSprite; escreve apenas metadados e copia exports, nunca pixels."""
from pathlib import Path
import argparse, copy, json, os, re, shutil, subprocess, uuid

ROOT = Path(__file__).resolve().parents[2]

def read(path):
    return json.loads(re.sub(r',\s*([}\]])', r'\1', path.read_text(encoding='utf-8-sig')))

def write(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8', newline='\n')

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--libresprite', required=True)
    args = parser.parse_args()
    work = ROOT/'tools/arte/.work/interface'
    work.mkdir(parents=True, exist_ok=True)
    (ROOT/'assets/interface').mkdir(exist_ok=True)
    env = dict(os.environ, APPDATA=str(ROOT/'tools/arte/.work/config'))
    result = subprocess.run([args.libresprite, '--batch', '--script', str(ROOT/'tools/arte/interface_referencias.js')], cwd=ROOT, env=env, capture_output=True, text=True)
    (work/'libresprite.log').write_text(result.stdout+result.stderr, encoding='utf-8')
    if result.returncode or re.search(r'Error:|terminate called', result.stdout+result.stderr):
        raise RuntimeError(result.stdout+result.stderr)
    template = read(ROOT/'sprites/spr_portrait_vampire/spr_portrait_vampire.yy')
    project_path = ROOT/'Coffin Bound final.yyp'
    project = read(project_path)
    for name, source, width, height in [
        ('spr_portrait_vampire', 'assets/dialogue/vampire_portrait.png', 88, 96),
        ('spr_menu_forest', 'assets/interface/menu_forest.png', 480, 270),
        ('spr_dialogue_frame', 'assets/interface/dialogue_frame.png', 428, 126),
        ('spr_ui_border', 'assets/interface/screen_border.png', 480, 270),
        ('spr_title_coffin', 'assets/interface/title_coffin.png', 268, 28),
    ]:
        folder = ROOT/'sprites'/name
        metadata = folder/(name+'.yy')
        folder.mkdir(exist_ok=True)
        if metadata.exists():
            data = read(metadata)
        else:
            data = copy.deepcopy(template)
            data['%Name'] = data['name'] = name
            data['width'], data['height'] = width, height
            data['bbox_right'], data['bbox_bottom'] = width-1, height-1
            data['sequence']['%Name'] = data['sequence']['name'] = name
            frame = str(uuid.uuid5(uuid.NAMESPACE_URL, name+'/frame'))
            layer = str(uuid.uuid5(uuid.NAMESPACE_URL, name+'/layer'))
            data['frames'][0]['%Name'] = data['frames'][0]['name'] = frame
            data['layers'][0]['%Name'] = data['layers'][0]['name'] = layer
            data['layers'][0]['displayName'] = 'Arte'
            key = data['sequence']['tracks'][0]['keyframes']['Keyframes'][0]
            key['id'] = str(uuid.uuid5(uuid.NAMESPACE_URL, name+'/key'))
            key['Channels']['0']['Id'] = dict(name=frame, path=f'sprites/{name}/{name}.yy')
            write(metadata, data)
        frame, layer = data['frames'][0]['name'], data['layers'][0]['name']
        layer_dir = folder/'layers'/frame
        layer_dir.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT/source, folder/(frame+'.png'))
        shutil.copyfile(ROOT/source, layer_dir/(layer+'.png'))
        if not any(r['id']['name']==name for r in project['resources']):
            project['resources'].append(dict(id=dict(name=name, path=f'sprites/{name}/{name}.yy')))
    write(project_path, project)
    print('LibreSprite: floresta, retrato, molduras e título exportados; sprites sincronizados.')

if __name__ == '__main__':
    main()
