#!/usr/bin/env python3
"""Validate the real Windows distribution ZIP without extracting or executing it.

Checks GameMaker payload headers, complete companion files, CRCs, Windows path
collisions and accidental caches/credentials. This is not gameplay, signing,
antivirus or licence-provenance approval.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import stat
import sys
import zipfile


REQUIRED_COMPANIONS = {
    "audiogroup_music.dat", "options.ini", "gamecontrollerdb.txt",
    "GPL-3.0.txt", "input_license.txt", "scribble_license.txt",
    "third_party_notices.txt",
}
FORBIDDEN_COMPONENTS = {".git", ".build", ".work", "__pycache__", "node_modules"}
FORBIDDEN_FILES = {
    "id_rsa", "id_ed25519", "credentials", "credentials.json", "hosts.yml",
    "licence.plt", "local_settings.json", "coffin_bound_save.ini",
    "coffin_bound_settings.ini", "igor.output.manifest",
}
SECRET_PATTERNS = (
    re.compile(rb"gh[pousr]_[A-Za-z0-9]{30,}"),
    re.compile(rb"github_pat_[A-Za-z0-9_]{40,}"),
    re.compile(rb"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
    re.compile(rb"AKIA[A-Z0-9]{16}"),
)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate(archive: Path, max_size_mb: int) -> dict:
    errors: list[str] = []
    entries: list[dict] = []
    paths: dict[str, zipfile.ZipInfo] = {}
    prefixes: dict[str, bytes] = {}
    casefolded: set[str] = set()
    package_root = None

    with zipfile.ZipFile(archive) as package:
        infos = package.infolist()
        if not infos:
            errors.append("ZIP vazio")
        total = sum(info.file_size for info in infos)
        if total > max_size_mb * 1024 * 1024:
            raise ValueError(f"ZIP excede o limite de {max_size_mb} MiB descompactados")
        for info in infos:
            name = info.filename.replace("\\", "/")
            path = PurePosixPath(name)
            components = name.split("/")
            if path.is_absolute() or ":" in name or ".." in components or "\x00" in name:
                errors.append(f"caminho inseguro: {info.filename}")
                continue
            normalized = path.as_posix().rstrip("/")
            folded = normalized.casefold()
            if folded in casefolded:
                errors.append(f"entrada duplicada ou colisão de caixa no Windows: {name}")
                continue
            casefolded.add(folded)
            if stat.S_ISLNK(info.external_attr >> 16):
                errors.append(f"link simbólico não permitido: {name}")
                continue
            if info.flag_bits & 1:
                errors.append(f"entrada criptografada: {name}")
                continue
            lowered_parts = {part.casefold() for part in path.parts}
            leaf = path.name.casefold()
            if (lowered_parts & FORBIDDEN_COMPONENTS or leaf in FORBIDDEN_FILES
                    or leaf == ".env" or leaf.startswith(".env.")
                    or leaf.endswith((".pyc", ".log", ".yydebug"))):
                errors.append(f"cache, configuração privada ou credencial não deve ser distribuída: {name}")
            if info.is_dir():
                continue
            digest = hashlib.sha256()
            prefix = b""
            # Small text files are scanned without exposing matched secrets.
            text_payload = bytearray() if info.file_size <= 2 * 1024 * 1024 else None
            with package.open(info) as handle:
                for chunk in iter(lambda: handle.read(65536), b""):
                    if not prefix:
                        prefix = chunk[:16]
                    digest.update(chunk)
                    if text_payload is not None:
                        text_payload.extend(chunk)
            if text_payload is not None and b"\x00" not in text_payload[:4096]:
                if any(pattern.search(text_payload) for pattern in SECRET_PATTERNS):
                    errors.append(f"padrão de segredo encontrado em: {name}")
            paths[normalized] = info
            prefixes[normalized] = prefix
            entries.append({"path": normalized, "size": info.file_size,
                            "crc32": f"{info.CRC:08x}", "sha256": digest.hexdigest()})

        executables = [name for name in paths if PurePosixPath(name).name == "CoffinBound.exe"]
        if len(executables) != 1:
            errors.append("esperado exatamente um CoffinBound.exe no pacote")
        else:
            executable = executables[0]
            base = PurePosixPath(executable).parent
            package_root = base.as_posix()
            if not prefixes[executable].startswith(b"MZ"):
                errors.append("CoffinBound.exe não tem cabeçalho PE/MZ")
            files_in_root = {PurePosixPath(name).name: name for name in paths
                             if PurePosixPath(name).parent == base}
            for companion in sorted(REQUIRED_COMPANIONS):
                if companion not in files_in_root:
                    errors.append(f"arquivo obrigatório ausente ao lado do executável: {companion}")
                elif paths[files_in_root[companion]].file_size == 0:
                    errors.append(f"arquivo obrigatório vazio: {companion}")
            data_files = [name for name in files_in_root.values()
                          if PurePosixPath(name).suffix.casefold() == ".win"]
            if len(data_files) != 1:
                errors.append("esperado exatamente um arquivo .win de dados ao lado do executável")
            elif not prefixes[data_files[0]].startswith(b"FORM"):
                errors.append("arquivo .win não tem cabeçalho FORM do GameMaker")
            audio = files_in_root.get("audiogroup_music.dat")
            if audio and not prefixes[audio].startswith(b"FORM"):
                errors.append("audiogroup_music.dat não tem cabeçalho FORM do GameMaker")
            for companion, marker in (
                ("GPL-3.0.txt", b"GNU GENERAL PUBLIC LICENSE"),
                ("third_party_notices.txt", b"Apache License"),
            ):
                name = files_in_root.get(companion)
                if name and marker not in package.read(name):
                    errors.append(f"aviso obrigatório parece incompleto: {companion}")

    return {
        "archive": archive.name, "sha256": sha256_file(archive),
        "archive_size": archive.stat().st_size,
        "uncompressed_size": sum(entry["size"] for entry in entries),
        "checked_at_utc": datetime.now(timezone.utc).isoformat(),
        "package_root": package_root, "files": entries, "errors": errors,
        "passed": not errors,
        "limits": "Inspeção de arquivos e CRC; não executa o jogo nem valida gameplay, assinatura ou procedência das artes.",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    parser.add_argument("--output-manifest", type=Path)
    parser.add_argument("--max-size-mb", type=int, default=1024)
    args = parser.parse_args()
    if args.max_size_mb < 1:
        parser.error("--max-size-mb deve ser positivo")
    try:
        if args.output_manifest and args.output_manifest.resolve() == args.archive.resolve():
            parser.error("o manifesto não pode sobrescrever o arquivo ZIP")
        result = validate(args.archive, args.max_size_mb)
    except (OSError, ValueError, RuntimeError, zipfile.BadZipFile) as error:
        print(f"ERRO: não foi possível validar o pacote: {error}")
        return 1
    if args.output_manifest:
        args.output_manifest.parent.mkdir(parents=True, exist_ok=True)
        args.output_manifest.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                                        encoding="utf-8")
    for error in result["errors"]:
        print(f"ERRO: {error}")
    print(f"Pacote: {result['archive']} | arquivos: {len(result['files'])} | "
          f"SHA-256: {result['sha256']}")
    print("APROVADO: integridade e arquivos obrigatórios." if result["passed"]
          else "REPROVADO: corrigir os erros acima.")
    print(result["limits"])
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
