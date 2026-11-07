"""Audita frames, recortes do atlas e origens sem modificar pixels."""
import json
import re
from pathlib import Path
from PIL import Image, ImageChops

ROOT=Path(__file__).resolve().parents[1]
def read(p):
    return json.loads(re.sub(r',\s*([}\]])',r'\1',p.read_text(encoding='utf-8-sig')))
count=0
for path in (ROOT/'sprites').glob('*/*.yy'):
    sprite=read(path)
    for frame in sprite['frames']:
        image=Image.open(path.parent/(frame['name']+'.png'))
        assert image.size==(sprite['width'],sprite['height']),path
        count+=1
    for key in sprite['sequence']['tracks'][0]['keyframes']['Keyframes']:
        assert key['Channels']['0']['Id']['name'] in [f['name'] for f in sprite['frames']],path
kit=read(ROOT/'assets/pecas/catalogo.json')
atlas=Image.open(ROOT/'assets/pecas/atlas.png').convert('RGBA')
for name,m in kit.items():
    source=Image.open(ROOT/f'assets/pecas/{name}_0.png').convert('RGBA')
    crop=atlas.crop((m['x'],m['y'],m['x']+m['w'],m['y']+m['h']))
    difference=ImageChops.difference(crop,source)
    assert all(band.getbbox() is None for band in difference.split()),name
    assert m['x']+m['w']<=atlas.width and m['y']+m['h']<=atlas.height,name
challenge=Image.open(ROOT/'assets/challenges/challenge_atlas.png')
for index in range(34):
    x,y=index%8*32,index//8*32
    assert x+32<=challenge.width and y+32<=challenge.height,index
print(f'OK {count} frames com dimensões e índices válidos; {len(kit)} recortes modulares íntegros; 34 recortes de obstáculos dentro do atlas.')
