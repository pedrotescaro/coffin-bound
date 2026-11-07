"""LibreSprite escreve pixels; Pillow somente lê e audita RGBA visível."""
from pathlib import Path
import json,os,subprocess,argparse,re
from PIL import Image, ImageSequence
ROOT=Path(__file__).resolve().parents[2]
PALETTE_PATH=ROOT/'art/palette/gb_green.gpl'
COLORS=[tuple(map(int,line.split()[:3])) for line in PALETTE_PATH.read_text(encoding='utf-8').splitlines() if line.strip() and line.split()[0].isdigit()]
assert len(COLORS)==4 and {(15,56,15),(48,98,48),(139,172,15),(155,188,15)}.issubset(COLORS)

def nearest(rgb):
    return min(COLORS,key=lambda c:sum((a-b)**2 for a,b in zip(rgb,c)))
def files():
    import subprocess
    names=subprocess.check_output(['git','ls-files','--cached','--others','--exclude-standard','-z'],cwd=ROOT).decode().split('\0')
    for name in sorted(set(names)):
        path=ROOT/name
        if path.is_file() and path.suffix.lower() in ('.png','.gif'):yield path
def audit():
    bad=[];total=0;count=0;frames=0
    for p in files():
        count+=1
        n=0
        with Image.open(p) as im:
            for frame in ImageSequence.Iterator(im):
                frames+=1
                for amount,(r,g,b,a) in frame.convert('RGBA').getcolors(frame.width*frame.height):
                    if a and ((r,g,b) not in COLORS or a!=255):
                        n+=amount
                        rgba=frame.convert('RGBA')
                        for y in range(frame.height):
                            for x in range(frame.width):
                                if rgba.getpixel((x,y))==(r,g,b,a):print(p.relative_to(ROOT),im.tell(),x,y,(r,g,b,a))
                        print(p.relative_to(ROOT), 'frame',im.tell(),'RGBA',(r,g,b,a),'pixels',amount)
        total+=n
        if n:bad.append({'file':p.relative_to(ROOT).as_posix(),'pixels':n})
    shaders=[]
    for name in ('shd_gameboy','__shd_scribble'):
        path=ROOT/f'shaders/{name}/{name}.fsh'
        values=[tuple(map(int,v)) for v in re.findall(r'vec3\((\d+)\.,(\d+)\.,(\d+)\.\)/255\.',path.read_text(encoding='utf-8'))]
        shaders.append({'shader':name,'matches_palette':values==COLORS})
    report={'files_checked':count,'visible_pixels_outside_palette_or_partial_alpha':total,'violations':bad,'animation_frames_checked':frames,'palette':['#%02X%02X%02X'%c for c in COLORS],'shaders':shaders}
    out=ROOT/'docs/palette-audit.json';out.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report,indent=2));return bool(bad) or not all(s['matches_palette'] for s in shaders)
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
                        r,g,b=values[k:k+3];pal.append(nearest((r,g,b)))
                    dest=work/f'{i}.gpl';dest.write_text('GIMP Palette\nName: GB\n#\n'+''.join(f'{r} {g} {b}\n' for r,g,b in pal));job['palette']=dest.as_posix()
            jobs.append(job)
        # Fontes editáveis também recebem a paleta atual.
        for p in (ROOT/'assets').rglob('*.aseprite'):jobs.append({'source':p.as_posix(),'output':p.as_posix()})
        script=work/'run.js';script.write_text('var gbJobs='+json.dumps(jobs)+';var gbPalette='+json.dumps(COLORS)+';\n'+(ROOT/'tools/arte/gameboy.js').read_text(),encoding='utf-8')
        env=dict(os.environ);env['APPDATA']=str(ROOT/'tools/arte/.work/config')
        r=subprocess.run([args.libresprite,'--batch','--script',str(script)],cwd=ROOT,env=env,capture_output=True,text=True)
        if r.returncode or 'Error:' in r.stdout+r.stderr:raise RuntimeError((r.stdout+r.stderr)[-3000:])
    raise SystemExit(audit())
if __name__=='__main__':main()
