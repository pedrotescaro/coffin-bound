"""Deriva peças sombreadas da arte existente com LibreSprite, sem reamostrar."""
import copy
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
from interface_referencias import ROOT, read, write

work = ROOT/'tools/arte/.work/fundo'
work.mkdir(parents=True, exist_ok=True)
out = ROOT/'assets/pecas/fundo'
out.mkdir(exist_ok=True)
names = ['pilar_1', 'pilar_2', 'pilar_3', 'pilar_4', 'pilar_raizes',
         'janela_1', 'janela_2', 'janela_3', 'hera_media', 'hera_curta',
         'estandarte_1', 'estandarte_2', 'estandarte_3', 'estandarte_4', 'estandarte_5',
         'arco_pedra', 'arco_teia', 'teia', 'teia_pendente', 'gargula_1', 'gargula_2',
         'lapide_1', 'lapide_2', 'lapide_3', 'urna_1', 'urna_2', 'urna_3', 'grade_partida']
kit = read(ROOT/'assets/pecas/catalogo.json')
sources = []
for name in names:
    for frame in range(kit[name]['frames']):
        sources.append(dict(name=name, frame=frame))
script = work/'render.js'
script.write_text('var sources='+json.dumps(sources)+';\n'+r'''
var pc=app.pixelColor, dark=pc.rgba(15,56,15,255), middle=pc.rgba(48,98,48,255);
for(var n=0;n<sources.length;n++){
 var m=sources[n],d=app.open('assets/pecas/'+m.name+'_'+m.frame+'.png');
 var s=d.sprite,im=s.layer(0).cel(0).image;
 for(var y=0;y<im.height;y++)for(var x=0;x<im.width;x++){
  var c=im.getPixel(x,y);if(!pc.rgbaA(c))continue;
  im.putPixel(x,y,pc.rgbaR(c)===15?dark:middle);
 }
 s.loadPalette('art/palette/gb_green.gpl');
 s.saveAs('assets/pecas/fundo/'+m.name+'_'+m.frame+'.png',true);d.close();
}
// Tijolos sutis cobrem toda a camada distante, sem uma imagem de cenário pronta.
var d=app.open('assets/pecas/pedra_01_0.png'),s=d.sprite,im=s.layer(0).cel(0).image;
im.clear(dark);
for(var y=0;y<32;y++)for(var x=0;x<32;x++)
 if((y%16===15&&x%8<3)||(x%32===(y>=16?15:31)&&y%16>11))im.putPixel(x,y,middle);
s.saveAs('assets/pecas/fundo/parede_0.png',true);d.close();
''', encoding='utf8')
result = subprocess.run([sys.argv[1], '--batch', '--script', str(script)], cwd=ROOT,
                        env=dict(os.environ, APPDATA=str(work)), capture_output=True)
if result.returncode or b'Error:' in result.stdout+result.stderr:
    raise RuntimeError(result.stdout+result.stderr)
project = read(ROOT/'Coffin Bound final.yyp')
for name in names+['parede']:
    sprite = 'spr_bg_'+name
    template = 'spr_mod_'+name if name!='parede' else 'spr_mod_pedra_01'
    data = read(ROOT/f'sprites/{template}/{template}.yy')
    data['name'] = data['%Name'] = sprite
    data['sequence']['name'] = data['sequence']['%Name'] = sprite
    folder = ROOT/'sprites'/sprite
    folder.mkdir(exist_ok=True)
    for frame, metadata in enumerate(data['frames']):
        fid = metadata['name']
        shutil.copyfile(out/f'{name}_{frame}.png', folder/(fid+'.png'))
        for layer in data['layers']:
            target = folder/'layers'/fid
            target.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(out/f'{name}_{frame}.png', target/(layer['name']+'.png'))
    for key in data['sequence']['tracks'][0]['keyframes']['Keyframes']:
        key['Channels']['0']['Id']['path'] = f'sprites/{sprite}/{sprite}.yy'
    write(folder/(sprite+'.yy'), data)
    if not any(r['id']['name']==sprite for r in project['resources']):
        project['resources'].append({'id':{'name':sprite,'path':f'sprites/{sprite}/{sprite}.yy'}})
write(ROOT/'Coffin Bound final.yyp', project)
