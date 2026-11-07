"""Prepara dados/JavaScript para LibreSprite; não escreve pixels nem altera a room."""
from pathlib import Path
import json
import re
import os

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / "tools/arte/.work/mapa"


def load(path):
    return json.loads(re.sub(r",\s*([}\]])", r"\1", path.read_text(encoding="utf-8-sig")))


def main():
    room_name=os.environ.get("CB_ROOM","rm_level1")
    room = load(ROOT / f"rooms/{room_name}/{room_name}.yy")
    solids, instances, lights = [], [], []
    for layer in room["layers"]:
        for item in layer.get("instances", []):
            name = item["objectId"]["name"]
            obj = load(ROOT / item["objectId"]["path"])
            sprite = obj.get("spriteId")
            source, origin = None, [0, 0]
            if sprite:
                data = load(ROOT / sprite["path"])
                source = f"sprites/{data['name']}/{data['frames'][0]['name']}.png"
                origin = [data["sequence"]["xorigin"], data["sequence"]["yorigin"]]
            if name in ("obj_ground", "obj_wall"):
                solids.append({"name": item["name"], "object": name,
                               "x": round(item["x"]), "y": round(item["y"]),
                               "w": round(item["scaleX"] * 64),
                               "h": round(item["scaleY"] * 64)})
            elif name == "obj_light":
                lights.append([round(item["x"]), round(item["y"])])
            elif name in ("obj_player", "obj_spike", "obj_candle", "obj_coffin"):
                instances.append({"object": name, "source": source,
                                  "x": item["x"], "y": item["y"],
                                  "sx": item["scaleX"], "sy": item["scaleY"],
                                  "origin": origin, "depth": layer["depth"]})
    job = {"width": room["roomSettings"]["Width"],
           "height": room["roomSettings"]["Height"], "solids": solids,
           "lights": lights, "instances": instances}
    if (job["width"], job["height"]) != (1920, 540):
        raise ValueError("O gerador espera a geometria da fase 1920x540.")
    WORK.mkdir(parents=True, exist_ok=True)
    (ROOT / "assets/environment").mkdir(parents=True, exist_ok=True)
    (WORK / "job.json").write_text(json.dumps(job, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    script = (ROOT / "tools/arte/gerar_mapa.js").read_text(encoding="utf-8")
    (WORK / "gerar.js").write_text("var cryptMapJob = " + json.dumps(job) + ";\n" + script, encoding="utf-8")
    print(f"Dados do mapa: {len(solids)} colisores, {len(lights)} fontes de luz; geometria original preservada.")


if __name__ == "__main__":
    main()
