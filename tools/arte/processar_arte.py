"""Orquestra LibreSprite real; Pillow é usado apenas para leitura/validação.

python tools/arte/processar_arte.py --libresprite C:/caminho/libresprite.exe
Não escreve pixels com Pillow. Preserva IDs, PNGs extras, alpha e dimensões.
"""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools/arte"
WORK = TOOLS / ".work"
PALETTE = [
    (11,13,23),(28,25,45),(48,38,63),(75,54,87),
    (109,77,104),(152,115,138),(192,162,173),(229,210,208),
    (29,51,52),(49,83,78),(80,115,93),(127,166,106),
    (182,204,139),(233,237,197),(52,63,86),(82,103,129),
    (127,155,176),(182,203,210),(84,35,52),(136,63,76),
    (191,89,99),(227,141,130),(180,136,91),(241,201,128),
]


def load_yy(path):
    return json.loads(re.sub(r",\s*([}\]])", r"\1", path.read_text(encoding="utf-8-sig")))


def run_cli(exe, args, env):
    result = subprocess.run([str(exe), "--batch", *map(str,args)], cwd=ROOT,
                            env=env, capture_output=True, text=True, errors="replace")
    log = result.stdout + result.stderr
    with (WORK / "libresprite.log").open("a", encoding="utf-8") as stream:
        stream.write(log)
    # A versão instalada retorna zero mesmo quando um script lança exceção.
    if result.returncode or "Error:" in log or "terminate called" in log:
        raise RuntimeError(log[-6000:])


def pixels(path):
    with Image.open(path) as image:
        image = image.convert("RGBA")
        return image.size, list(image.get_flattened_data())


def verify_job(job):
    size, before = pixels(job["source"])
    actual_size, after = pixels(job["output"])
    target = (job.get("width",size[0]),job.get("height",size[1]))
    assert actual_size == target, (job["source"], actual_size, target)
    palette = set(PALETTE)
    assert all(p[:3] in palette for p in after if p[3]), job["source"]
    ow,oh=size
    for y in range(target[1]):
        for x in range(target[0]):
            if "width" in job:
                sx,sy=x*ow//target[0],y*oh//target[1]
            else:
                sx,sy=x-job.get("shift",0),y-job.get("shift",0)
            alpha=before[sy*ow+sx][3] if 0<=sx<ow and 0<=sy<oh else 0
            assert after[y*target[0]+x][3] == alpha, (job["source"],x,y,"alpha")
    if job.get("shift"):
        assert not any(before[y*ow+x][3] for y in range(oh) for x in range(ow)
                       if x+job["shift"]>=ow or y+job["shift"]>=oh), "Shift cortaria pixels!"


def verify_sheets(sprites):
    total=0
    for yy,data in sprites:
        data=load_yy(yy)
        info=json.loads((ROOT/"assets/spritesheets"/(data["name"]+".json")).read_text(encoding="utf-8-sig"))
        with Image.open(ROOT/"assets/spritesheets"/(data["name"]+".png")) as image:
            sheet=image.convert("RGBA")
        assert len(info["frames"])==len(data["frames"]), yy
        for entry,frame in zip(info["frames"],data["frames"]):
            rect=entry["frame"]
            source=yy.parent/(frame["name"]+".png")
            with Image.open(source) as image:original=image.convert("RGBA")
            assert original.size==(data["width"],data["height"]),source
            crop=sheet.crop((rect["x"],rect["y"],rect["x"]+rect["w"],rect["y"]+rect["h"]))
            assert original.tobytes()==crop.tobytes(),source
            for layer in (yy.parent/"layers"/frame["name"]).glob("*.png"):
                with Image.open(layer) as image:assert image.size==original.size,layer
            total+=1
    return total


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--libresprite",required=True,type=Path)
    parser.add_argument("--validate-only",action="store_true")
    args=parser.parse_args()
    exe=args.libresprite.resolve()
    if not exe.is_file(): raise FileNotFoundError(exe)
    WORK.mkdir(parents=True,exist_ok=True)
    env=dict(os.environ)
    env["APPDATA"]=str(WORK / "config")
    (WORK / "config/LibreSprite").mkdir(parents=True,exist_ok=True)
    sprites=[];jobs=[];metadata=[]
    for yy in sorted((ROOT/"sprites").glob("*/*.yy")):
        data=load_yy(yy)
        if data["name"].startswith("scribble_"): continue
        sprites.append((yy,data))
        shift=(data["name"] in ("spr_vampire_idle","spr_vampire_walk")
               and (data["sequence"]["xorigin"],data["sequence"]["yorigin"])==(16,25))
        resize=data["name"]=="spr_candle" and (data["width"],data["height"])==(26,29)
        if shift or resize:metadata.append((yy,data,shift,resize))
        for png in sorted(yy.parent.rglob("*.png")):
            target=WORK / "processed" / png.relative_to(ROOT)
            target.parent.mkdir(parents=True,exist_ok=True)
            job={"source":png.as_posix(),"output":target.as_posix()}
            with Image.open(png) as image:
                if image.mode == "P":
                    values=image.getpalette();mapped=[]
                    for i in range(0,len(values),3):
                        r,g,b=values[i:i+3]
                        mapped.append(min(PALETTE,key=lambda q:2*(r-q[0])**2+3*(g-q[1])**2+(b-q[2])**2))
                    pal=WORK/(png.stem+".gpl")
                    pal.write_text("GIMP Palette\nName: Coffin Gothic indexado\nColumns: 8\n#\n"+
                        "".join(f"{r} {g} {b}\tCor {i}\n" for i,(r,g,b) in enumerate(mapped)),encoding="utf-8")
                    job["palette"]=pal.as_posix()
            if shift:job["shift"]=1
            if resize:job.update(width=14,height=16)
            jobs.append(job)
    # Caches de tile mantidos, sem exclusão; a IDE pode regenerá-los dos sprites.
    for png in sorted((ROOT/"tilesets").glob("*/output_tileset.png")):
        target=WORK/"processed"/png.relative_to(ROOT)
        target.parent.mkdir(parents=True,exist_ok=True)
        jobs.append({"source":png.as_posix(),"output":target.as_posix()})
    if args.validate_only:
        for job in jobs:
            size,data=pixels(job["source"])
            assert all(p[:3] in set(PALETTE) for p in data if p[3]), job["source"]
        total=verify_sheets(sprites)
        print(f"OK: {len(jobs)} PNGs, paleta e dimensões válidas; {total} frames reconstruídos das sheets.")
        return
    script=WORK / "processar_lote.js"
    script.write_text((TOOLS/"paleta_gotica.js").read_text(encoding="utf-8-sig")+
                      "\nvar jobs="+json.dumps(jobs)+";\n"+
                      "for(var i=0;i<jobs.length;i++)processGothic(jobs[i]);\n",encoding="utf-8")
    run_cli(exe,["--script",script],env)
    for job in jobs: verify_job(job)
    # Somente após validar o lote inteiro, substitui os PNGs do projeto.
    for job in jobs:shutil.copy2(job["output"],job["source"])
    for yy,data,shift,resize in metadata:
        content=yy.read_text(encoding="utf-8-sig")
        changes={}
        if shift:
            changes.update(xorigin=17,yorigin=26)
            changes.update({k:data[k]+1 for k in ("bbox_left","bbox_top","bbox_right","bbox_bottom")})
        if resize:
            _,rgba=pixels(yy.parent/(data["frames"][0]["name"]+".png"))
            ink=[(i%14,i//14) for i,p in enumerate(rgba) if p[3]]
            changes.update(width=14,height=16,bbox_left=min(x for x,y in ink),
                           bbox_top=min(y for x,y in ink),bbox_right=max(x for x,y in ink),
                           bbox_bottom=max(y for x,y in ink))
        for key,value in changes.items():
            content=re.sub(r'("'+key+r'"\s*:\s*)[-\d.]+',lambda m:m[1]+str(value),content)
        yy.write_text(content,encoding="utf-8",newline="\n")
    palette_dir=ROOT/"assets/palette";palette_dir.mkdir(parents=True,exist_ok=True)
    (palette_dir/"coffin-gothic-24.gpl").write_text("GIMP Palette\nName: Coffin Gothic 24\nColumns: 8\n#\n"+
        "".join(f"{r:3} {g:3} {b:3}\tCor {i+1:02}\n" for i,(r,g,b) in enumerate(PALETTE)),encoding="utf-8")
    exports=ROOT/"assets/spritesheets";exports.mkdir(parents=True,exist_ok=True)
    manifest=[]
    for yy,_ in sprites:
        data=load_yy(yy);name=data["name"];frames=data["frames"]
        sheet=exports/(name+".png");info=exports/(name+".json")
        sources=[yy.parent/(f["name"]+".png") for f in frames]
        run_cli(exe,["--sheet-type","vertical","--border-padding","1",
                     "--shape-padding","1","--format","json-array",*sources,
                     "--sheet",sheet,"--data",info],env)
        exported=json.loads(info.read_text(encoding="utf-8-sig"))
        exported["meta"]["image"]=sheet.name
        fps=data["sequence"]["playbackSpeed"]
        for frame in exported["frames"]:frame["duration"]=round(1000/fps) if fps else 0
        exported["coffin_bound"]={"source_yy":yy.relative_to(ROOT).as_posix(),"fps":fps,
            "origin":[data["sequence"]["xorigin"],data["sequence"]["yorigin"]],
            "frame_order":[f["name"] for f in frames],"static":fps==0 or len(frames)==1,
            "note":"Duração exportada a partir do .yy; image_speed do jogo pode modular o timing."}
        info.write_text(json.dumps(exported,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
        manifest.append({"sprite":name,"frames":len(frames),"fps":fps,"canvas":[data["width"],data["height"]]})
    total=verify_sheets(sprites)
    report={"sprites":len(sprites),"pngs_processed":len(jobs),"active_frames_verified":total,"palette_size":len(PALETTE),
            "engine":"LibreSprite 1.1-dev --batch --script", "checks":["dimensions","palette","alpha","shift_without_clipping"],
            "excluded":["scribble_fallback_bulletpoint (branco técnico)","fonts/ (texturas de fonte)"],
            "sheets":manifest}
    (exports/"manifest.json").write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(f"OK: {len(jobs)} PNGs processados, {len(sprites)} spritesheets exportadas; alpha e geometria validados.")


if __name__=="__main__":main()
