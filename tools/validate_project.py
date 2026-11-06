#!/usr/bin/env python3
"""Read-only GameMaker asset and GML sanity checks; this is not a compiler.

Run from any directory: python /absolute/path/tools/validate_project.py
Only registered assets and their declared frames/events are required. Archives,
old exports and unregistered PNGs are never interpreted as current frames.
"""

from __future__ import annotations

import argparse
from collections import Counter
import json
from pathlib import Path
import struct
import sys
from typing import Any


EVENT_NAMES = {
    0: "Create", 1: "Destroy", 2: "Alarm", 3: "Step", 4: "Collision",
    5: "Keyboard", 6: "Mouse", 7: "Other", 8: "Draw", 9: "KeyPress",
    10: "KeyRelease", 11: "Trigger", 12: "CleanUp", 13: "Gesture",
    14: "PreCreate",
}
REFERENCE_ROOTS = {"sprites", "objects", "tilesets", "rooms", "scripts",
                   "shaders", "fonts", "sounds", "paths", "sequences",
                   "animcurves", "particles", "timelines"}


def strip_trailing_commas(source: str) -> str:
    """Remove only JSON commas outside quoted strings; preserve line numbers."""
    output = list(source)
    quoted = escaped = False
    for index, char in enumerate(source):
        if quoted:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
        elif char == '"':
            quoted = True
        elif char == ",":
            following = index + 1
            while following < len(source) and source[following].isspace():
                following += 1
            if following < len(source) and source[following] in "}]":
                output[index] = " "
    return "".join(output)


def walk(value: Any):
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from walk(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk(child)


def gml_balance(source: str) -> list[tuple[int, str]]:
    """Check delimiters, comments and string termination, without type analysis."""
    problems: list[tuple[int, str]] = []
    stack: list[tuple[str, int]] = []
    index, line, size = 0, 1, len(source)
    pairs = {"}": "{", ")": "(", "]": "["}
    while index < size:
        char = source[index]
        if char == "\n":
            line += 1
            index += 1
            continue
        if source.startswith("//", index):
            end = source.find("\n", index + 2)
            index = size if end < 0 else end
            continue
        if source.startswith("/*", index):
            start_line = line
            end = source.find("*/", index + 2)
            if end < 0:
                problems.append((start_line, "comentário de bloco sem fechamento"))
                break
            line += source[index:end + 2].count("\n")
            index = end + 2
            continue
        verbatim = char == "@" and index + 1 < size and source[index + 1] in "\"'"
        if char in "\"'" or verbatim:
            if verbatim:
                index += 1
                char = source[index]
            quote, start_line = char, line
            index += 1
            closed = False
            while index < size:
                char = source[index]
                if char == "\n":
                    line += 1
                if not verbatim and char == "\\":
                    if index + 1 < size and source[index + 1] == "\n":
                        line += 1
                    index += 2
                    continue
                if char == quote:
                    if verbatim and index + 1 < size and source[index + 1] == quote:
                        index += 2
                        continue
                    closed = True
                    index += 1
                    break
                index += 1
            if not closed:
                problems.append((start_line, "string sem fechamento"))
            continue
        if char in "{([":
            stack.append((char, line))
        elif char in "})]":
            if not stack or stack[-1][0] != pairs[char]:
                problems.append((line, f"delimitador inesperado: {char}"))
            else:
                stack.pop()
        index += 1
    problems.extend((row, f"delimitador sem fechamento: {char}") for char, row in stack)
    return problems


class Validator:
    def __init__(self, project: Path):
        self.project = project.resolve()
        self.root = self.project.parent
        self.errors: list[str] = []
        self.warnings: list[str] = []
        self.assets: dict[str, dict] = {}
        self.counts: Counter = Counter()
        self.checked_gml: set[Path] = set()

    def label(self, path: Path) -> str:
        try:
            return path.relative_to(self.root).as_posix()
        except ValueError:
            return str(path)

    def error(self, path: Path, message: str):
        self.errors.append(f"{self.label(path)}: {message}")

    def warning(self, path: Path, message: str):
        self.warnings.append(f"{self.label(path)}: {message}")

    def resolve(self, relative: str, owner: Path) -> Path | None:
        relative = relative.replace("\\", "/")
        path = (self.root / relative).resolve()
        if not path.is_relative_to(self.root):
            self.error(owner, f"referência fora do projeto: {relative}")
            return None
        return path

    def load(self, path: Path) -> dict | None:
        try:
            data = json.loads(strip_trailing_commas(path.read_text(encoding="utf-8-sig")))
            if not isinstance(data, dict):
                raise ValueError("raiz deve ser um objeto JSON")
            self.counts["metadata_files"] += 1
            return data
        except (OSError, ValueError) as error:
            self.error(path, f"metadados inválidos/inacessíveis: {error}")
            return None

    def check_gml(self, path: Path):
        if path in self.checked_gml:
            return
        self.checked_gml.add(path)
        if not path.is_file():
            self.error(path, "arquivo GML declarado ausente")
            return
        # Windows aceita nomes com caixa diferente; Linux/GitHub exigem igualdade.
        if path.name not in {entry.name for entry in path.parent.iterdir()}:
            self.error(path, "capitalização do arquivo GML difere do recurso declarado")
            return
        # Third-party libraries remain covered by asset/event checks. Their many
        # macro/preprocessor constructs are outside this lexical sanity check.
        if path.parent.name.startswith(("Input", "__Input", "scribble", "__scribble")):
            return
        if path.parent.name == "__InputUpdateController":
            return
        try:
            source = path.read_text(encoding="utf-8-sig")
        except (OSError, UnicodeError) as error:
            self.error(path, f"não foi possível ler GML: {error}")
            return
        self.counts["authored_gml_files"] += 1
        for line, message in gml_balance(source):
            self.error(path, f"linha {line}: {message}")

    def check_png(self, path: Path, expected: tuple[int, int]):
        try:
            with path.open("rb") as handle:
                header = handle.read(24)
            if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
                raise ValueError("assinatura PNG/IHDR inválida")
            actual = struct.unpack(">II", header[16:24])
            self.counts["declared_frame_pngs"] += 1
            if actual != expected:
                self.error(path, f"dimensão {actual}, esperada {expected}")
        except (OSError, ValueError) as error:
            self.error(path, f"PNG declarado ausente/inválido: {error}")

    def check_sprite(self, path: Path, asset: dict):
        expected = (asset.get("width"), asset.get("height"))
        if not all(isinstance(value, int) and value > 0 for value in expected):
            self.error(path, "largura/altura do sprite inválidas")
            return
        frames = [frame.get("name") for frame in asset.get("frames", [])]
        if len(set(frames)) != len(frames):
            self.error(path, "identificadores de frames duplicados")
        layer_names = [layer.get("name") for layer in walk(asset.get("layers", []))
                       if layer.get("resourceType") == "GMImageLayer"]
        for frame in frames:
            if not isinstance(frame, str):
                self.error(path, "frame sem nome")
                continue
            self.check_png(path.parent / f"{frame}.png", expected)
            for layer in layer_names:
                self.check_png(path.parent / "layers" / frame / f"{layer}.png", expected)
        sequence = asset.get("sequence", {})
        for channel in walk(sequence.get("tracks", [])):
            if channel.get("resourceType") == "SpriteFrameKeyframe":
                frame = channel.get("Id", {}).get("name")
                if frame not in frames:
                    self.error(path, f"animação referencia frame não declarado: {frame}")

    def check_object(self, path: Path, asset: dict):
        expected: set[str] = set()
        for event in asset.get("eventList", []):
            kind, number = event.get("eventType"), event.get("eventNum")
            prefix = EVENT_NAMES.get(kind)
            if prefix is None:
                self.warning(path, f"tipo de evento não reconhecido: {kind}")
                continue
            suffix = str(number)
            if kind == 4 and event.get("collisionObjectId"):
                suffix = event["collisionObjectId"].get("name", suffix)
            filename = f"{prefix}_{suffix}.gml"
            if filename in expected:
                self.error(path, f"evento duplicado: {filename}")
            expected.add(filename)
            self.check_gml(path.parent / filename)
        for file in path.parent.glob("*.gml"):
            if file.name not in expected:
                self.warning(file, "GML não listado nos eventos do objeto; a IDE não o executará")

    def check_room(self, path: Path, asset: dict):
        instances = [item for item in walk(asset.get("layers", []))
                     if item.get("resourceType") == "GMRInstance"]
        names = [item.get("name") for item in instances]
        if len(set(names)) != len(names):
            self.error(path, "nomes de instâncias duplicados")
        order = [item.get("name") for item in asset.get("instanceCreationOrder", [])]
        if len(set(order)) != len(order):
            self.error(path, "instâncias duplicadas na ordem de criação")
        for name in set(order) - set(names):
            self.error(path, f"ordem de criação referencia instância inexistente: {name}")
        if not asset.get("inheritCreationOrder"):
            for name in set(names) - set(order):
                self.error(path, f"instância ausente da ordem de criação: {name}")
        creation = asset.get("creationCodeFile")
        if creation:
            self.check_gml(path.parent / creation)
        for instance in instances:
            if instance.get("hasCreationCode"):
                self.check_gml(path.parent / f"InstanceCreationCode_{instance['name']}.gml")
        self.counts["room_instances"] += len(instances)

    def check_references(self, owner: Path, asset: dict):
        for item in walk(asset):
            relative = item.get("path")
            if not isinstance(relative, str):
                continue
            normalized = relative.replace("\\", "/")
            if normalized.split("/")[0] not in REFERENCE_ROOTS or not normalized.endswith(".yy"):
                continue
            target = self.resolve(relative, owner)
            if target is None:
                continue
            key = target.relative_to(self.root).as_posix()
            if key not in self.assets:
                self.error(owner, f"referência a recurso não registrado: {relative}")
            elif not target.is_file():
                self.error(owner, f"referência a arquivo ausente: {relative}")
            else:
                target_name = self.assets[key].get("name")
                ref_name = item.get("name")
                # Sprite frames and room instance creation order refer to a
                # subresource UUID/name in their owning .yy, not its asset name.
                internal = target == owner and (
                    self.assets[key].get("resourceType") == "GMSprite"
                    or str(ref_name).startswith("inst_")
                )
                if ref_name and ref_name != target_name and not internal:
                    self.error(owner, f"nome de referência {ref_name} difere de {target_name}: {relative}")

    def run(self):
        project = self.load(self.project)
        if project is None:
            return
        names: set[str] = set()
        declared_paths: set[str] = set()
        for entry in project.get("resources", []):
            identifier = entry.get("id", {})
            name, relative = identifier.get("name"), identifier.get("path")
            if not isinstance(name, str) or not isinstance(relative, str):
                self.error(self.project, "entrada de recurso sem nome/path")
                continue
            folded_name = name.casefold()
            if folded_name in names:
                self.error(self.project, f"nome de recurso duplicado: {name}")
            names.add(folded_name)
            normalized = relative.replace("\\", "/")
            if normalized.casefold() in declared_paths:
                self.error(self.project, f"path de recurso duplicado: {relative}")
            declared_paths.add(normalized.casefold())
            path = self.resolve(relative, self.project)
            if path is None:
                continue
            asset = self.load(path)
            if asset is None:
                continue
            if asset.get("name") != name:
                self.error(path, f"nome do asset difere do registro YYP: {name}")
            self.assets[path.relative_to(self.root).as_posix()] = asset
            self.counts[asset.get("resourceType", "unknown_assets")] += 1
        self.check_references(self.project, project)
        for relative, asset in self.assets.items():
            path = self.root / relative
            self.check_references(path, asset)
            kind = asset.get("resourceType")
            if kind == "GMSprite":
                self.check_sprite(path, asset)
            elif kind == "GMObject":
                self.check_object(path, asset)
            elif kind == "GMRoom":
                self.check_room(path, asset)
            elif kind == "GMScript":
                self.check_gml(path.with_suffix(".gml"))
            elif kind == "GMSound":
                if asset.get("$GMSound") == "v2":
                    for field in ("channelFormat", "compressionQuality", "exportDir"):
                        if field not in asset:
                            self.error(path, f"GMSound v2: campo obrigatório ausente: {field}")
                    for field in ("bitRate", "type"):
                        if field in asset:
                            self.error(path, f"GMSound v2: campo legado incompatível com runtime 2026: {field}")
                sound_file = asset.get("soundFile")
                if sound_file and not (path.parent / sound_file).is_file():
                    self.error(path, f"arquivo de áudio ausente: {sound_file}")
        for path in sorted((self.root / "options").glob("*/*.yy")):
            self.load(path)
        room_order = [entry.get("roomId", {}).get("name") for entry in project.get("RoomOrderNodes", [])]
        if not room_order:
            self.error(self.project, "ordem das rooms vazia")
        elif len(room_order) != len(set(room_order)):
            self.error(self.project, "rooms duplicadas na ordem de execução")
        for include in project.get("IncludedFiles", []):
            relative = str(Path(include.get("filePath", "")) / include.get("name", ""))
            target = self.resolve(relative, self.project)
            if target is not None and not target.is_file():
                self.error(self.project, f"Included File ausente: {relative}")
        for prefab in project.get("ForcedPrefabProjectReferences", []):
            name = prefab.get("name", "")
            relative = prefab.get("path", "")
            target = self.root / "prefabs" / name / relative
            if not target.is_file():
                self.warning(self.project, f"prefab ausente localmente, conferir resolução na IDE: {name}")
            else:
                self.load(target)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project", nargs="?", type=Path, help="caminho absoluto ou relativo do .yyp")
    parser.add_argument("--json", action="store_true", help="emitir resultado JSON")
    parser.add_argument("--strict-warnings", action="store_true", help="retornar 1 também para avisos")
    args = parser.parse_args()
    project = args.project
    if project is None:
        candidates = sorted(Path(__file__).resolve().parents[1].glob("*.yyp"))
        if len(candidates) != 1:
            parser.error("informe o .yyp: não foi encontrado um único projeto junto de tools/")
        project = candidates[0]
    validator = Validator(project)
    validator.run()
    result = {"project": str(validator.project), "counts": dict(validator.counts),
              "errors": validator.errors, "warnings": validator.warnings,
              "limitation": "Validação estática; não compila GML nem testa física, renderização, áudio ou exportação."}
    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(f"Projeto: {validator.project}")
        print("Verificados: " + ", ".join(f"{key}={value}" for key, value in sorted(validator.counts.items())))
        for message in validator.errors:
            print(f"ERRO: {message}")
        for message in validator.warnings:
            print(f"AVISO: {message}")
        print(f"Resultado: {len(validator.errors)} erro(s), {len(validator.warnings)} aviso(s).")
        print(result["limitation"])
    return int(bool(validator.errors or (args.strict_warnings and validator.warnings)))


if __name__ == "__main__":
    sys.exit(main())
