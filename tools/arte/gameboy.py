"""LibreSprite escreve pixels; Pillow somente lê e audita RGBA visível."""
from pathlib import Path
import json,os,subprocess,argparse
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
COLORS=[(15,56,15),(48,98,48),(139,172,15),(155,188,15)]
def files():
    for folder in ('sprites','fonts','tilesets','assets','prefabs'):
        yield from (ROOT/folder).rglob('*.png')
        yield from (ROOT/folder).rglob('*.gif')
def audit():
    bad=[];total=0;count=0
    for p in files():
        count+=1
        with Image.open(p) as im:
            pixels=list(im.convert('RGBA').get_flattened_data())
        n=sum(1 for r,g,b,a in pixels if a and ((r,g,b) not in COLORS or a!=255))
        total+=n
        if n:bad.append({'file':p.relative_to(ROOT).as_posix(),'pixels':n})
    report={'files_checked':count,'visible_pixels_outside_palette_or_partial_alpha':total,'violations':bad,'palette':['#0F380F','#306230','#8BAC0F','#9BBC0F']}
    out=ROOT/'docs/palette-audit.json';out.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report,indent=2));return bool(bad)
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--apply',action='store_true');ap.add_argument('--libresprite');args=ap.parse_args()
    if args.apply:
        work=ROOT/'tools/arte/.work/gb';work.mkdir(parents=True,exist_ok=True);jobs=[]
        for i,p in enumerate(files()):
            job={'source':p.as_posix(),'output':p.as_posix()}
            with Image.open(p) as im:
                if im.mode=='P':
                    values=im.getpalette();pal=[]
                    for k in range(0,len(values),3):
                        r,g,b=values[k:k+3];l=(r*.2126+g*.7152+b*.0722)/255;q=(r,g,b) if (r,g,b) in COLORS else COLORS[0 if l<.13 else 1 if l<.32 else 2 if l<.65 else 3];pal.append(q)
                    dest=work/f'{i}.gpl';dest.write_text('GIMP Palette\nName: GB\n#\n'+''.join(f'{r} {g} {b}\n' for r,g,b in pal));job['palette']=dest.as_posix()
            jobs.append(job)
        # Fontes editáveis também recebem a paleta atual.
        for p in (ROOT/'assets').rglob('*.aseprite'):jobs.append({'source':p.as_posix(),'output':p.as_posix()})
        script=work/'run.js';script.write_text('var gbJobs='+json.dumps(jobs)+';\n'+(ROOT/'tools/arte/gameboy.js').read_text(),encoding='utf-8')
        env=dict(os.environ);env['APPDATA']=str(ROOT/'tools/arte/.work/config')
        r=subprocess.run([args.libresprite,'--batch','--script',str(script)],cwd=ROOT,env=env,capture_output=True,text=True)
        if r.returncode or 'Error:' in r.stdout+r.stderr:raise RuntimeError((r.stdout+r.stderr)[-3000:])
    raise SystemExit(audit())
if __name__=='__main__':main()
