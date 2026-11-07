"""Converte só os arquivos publicados que precisam de correção; entrada isolada evita sequências automáticas."""
from gameboy import ROOT, COLORS, files
from PIL import Image
import subprocess, shutil, json, os, sys
work=ROOT/'tools/arte/.work/remap';work.mkdir(parents=True,exist_ok=True)
jobs=[];outputs=[]
for p in files():
    with Image.open(p) as im:
        if all(not a or (a==255 and (r,g,b) in COLORS) for _,(r,g,b,a) in im.convert('RGBA').getcolors(im.width*im.height)):continue
    directory=work/str(len(jobs));directory.mkdir(exist_ok=True)
    src=directory/'input.png';dest=directory/'output.png';shutil.copyfile(p,src)
    jobs.append(dict(source=src.as_posix(),output=dest.as_posix()));outputs.append((dest,p))
script=work/'remap.js';script.write_text('var gbJobs='+json.dumps(jobs)+';var gbPalette='+json.dumps(COLORS)+';\n'+(ROOT/'tools/arte/gameboy.js').read_text())
result=subprocess.run([sys.argv[1],'--batch','--script',str(script)],cwd=ROOT,env=dict(os.environ,APPDATA=str(work)),capture_output=True)
if result.returncode or b'Error:' in result.stdout+result.stderr:raise RuntimeError(result.stdout[-500:])
for dest,p in outputs:
    with Image.open(dest) as im:assert all(not a or (r,g,b) in COLORS for _,(r,g,b,a) in im.convert('RGBA').getcolors(im.width*im.height)),p
for dest,p in outputs:shutil.copyfile(dest,p)
