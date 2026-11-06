#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2026 Pedro Tescaro
"""Generate Coffin Bound's original CC0 audio using Python's standard library.

No recordings, samples, soundfonts or external music are used. Run normally to
write WAVs and GMSound resources, or --check to compare existing outputs without
changing files. Listening and in-game mixing still require manual verification.
"""

from __future__ import annotations

import argparse
from array import array
import hashlib
import io
import json
import math
from pathlib import Path
import random
import sys
import wave


ROOT = Path(__file__).resolve().parents[1]
SAMPLE_RATE = 22050
BEAT_SAMPLES = 14700  # 90 BPM, exactly representable at 22050 Hz.
MUSIC_SAMPLES = BEAT_SAMPLES * 32
TAU = math.tau
SFX_NAMES = ("jump", "dash", "bat", "hurt", "death", "checkpoint", "win", "ui")
LABELS = {
    "jump": "Pulo: subida curta de tom",
    "dash": "Dash: sopro filtrado e ataque descendente",
    "bat": "Morcego: tremolo de asas e queda de tom",
    "hurt": "Dano: pulso grave com ruído suave",
    "death": "Morte: queda de tom com sino grave",
    "checkpoint": "Checkpoint: arpejo menor ascendente",
    "win": "Vitória: arpejo de ré menor em duas oitavas",
    "ui": "Interface: toque curto de sino",
    "music": "Cripta: oito compassos de harmonia menor, 90 BPM",
}


def midi(note: float) -> float:
    return 440.0 * 2.0 ** ((note - 69.0) / 12.0)


def envelope(position: float, duration: float, attack: float, release: float) -> float:
    if position <= 0.0 or position >= duration:
        return 0.0
    amount = min(1.0, position / attack, (duration - position) / release)
    return amount * amount * (3.0 - 2.0 * amount)


def add_note(target: list[float], start: float, duration: float, frequency: float,
             gain: float, *, attack: float = 0.008, release: float = 0.045,
             decay: float = 2.0, wrap: bool = False, bell: bool = False):
    start_sample = round(start * SAMPLE_RATE)
    count = round(duration * SAMPLE_RATE)
    # Restrict harmonics below Nyquist; the source is synthesized directly.
    harmonics = ((1.0, 1.0), (2.0, 0.16), (3.0, 0.05))
    if bell:
        harmonics = ((1.0, 1.0), (2.0, 0.24), (3.0, 0.11), (4.0, 0.03))
    harmonics = tuple((multiple, weight) for multiple, weight in harmonics
                      if multiple * frequency < SAMPLE_RATE * 0.45)
    for index in range(count):
        destination = start_sample + index
        if wrap:
            destination %= len(target)
        elif not 0 <= destination < len(target):
            continue
        time = index / SAMPLE_RATE
        shape = envelope(time, duration, attack, release) * math.exp(-decay * time)
        tone = sum(math.sin(TAU * frequency * multiple * time) * weight
                   for multiple, weight in harmonics)
        target[destination] += gain * shape * tone


def chirp(duration: float, start_frequency: float, end_frequency: float,
          *, noise: float = 0.0, flutter: float = 0.0, seed: int = 0) -> list[float]:
    count = round(duration * SAMPLE_RATE)
    samples = [0.0] * count
    rng = random.Random(seed)
    phase = filtered_noise = 0.0
    ratio = math.log(end_frequency / start_frequency)
    for index in range(count):
        time = index / SAMPLE_RATE
        progress = index / max(1, count - 1)
        frequency = start_frequency * math.exp(ratio * progress)
        phase += TAU * frequency / SAMPLE_RATE
        filtered_noise += 0.16 * (rng.uniform(-1.0, 1.0) - filtered_noise)
        wing = 1.0 if not flutter else 0.65 + 0.35 * math.cos(TAU * flutter * time)
        shape = envelope(time, duration, 0.007, min(0.09, duration * 0.4))
        shape *= math.exp(-1.4 * progress)
        tone = math.sin(phase) + 0.13 * math.sin(phase * 2.0)
        samples[index] = shape * wing * ((1.0 - noise) * tone + noise * filtered_noise)
    return samples


def make_sfx(name: str) -> list[float]:
    if name == "jump":
        return chirp(0.14, 180, 620, seed=11)
    if name == "dash":
        return chirp(0.18, 440, 100, noise=0.82, seed=23)
    if name == "bat":
        return chirp(0.26, 640, 190, noise=0.20, flutter=25.0, seed=37)
    if name == "hurt":
        return chirp(0.22, 150, 62, noise=0.38, flutter=34.0, seed=41)
    if name == "death":
        samples = chirp(0.70, 260, 42, noise=0.19, seed=59)
        add_note(samples, 0.01, 0.66, midi(38), 0.30, decay=3.0, bell=True)
        return samples
    if name == "ui":
        samples = [0.0] * round(0.09 * SAMPLE_RATE)
        add_note(samples, 0.0, 0.09, midi(81), 0.75, decay=11.0, bell=True)
        return samples
    if name == "checkpoint":
        samples = [0.0] * round(0.56 * SAMPLE_RATE)
        for index, note in enumerate((62, 65, 69)):
            add_note(samples, index * 0.085, 0.38, midi(note), 0.42,
                     release=0.08, decay=5.0, bell=True)
        return samples
    if name == "win":
        samples = [0.0] * round(1.30 * SAMPLE_RATE)
        for index, note in enumerate((50, 57, 62, 65, 69, 74)):
            add_note(samples, index * 0.12, 0.70, midi(note), 0.32,
                     release=0.16, decay=2.8, bell=True)
        return samples
    raise ValueError(f"Unknown SFX: {name}")


def make_music() -> list[float]:
    """Loop additions wrap around the boundary, avoiding a reset of envelopes."""
    samples = [0.0] * MUSIC_SAMPLES
    loop_seconds = MUSIC_SAMPLES / SAMPLE_RATE
    beat_seconds = BEAT_SAMPLES / SAMPLE_RATE
    # D minor, B-flat, G minor and A major: a restrained gothic cadence.
    chords = ((38, 50, 53, 57), (38, 50, 53, 57),
              (34, 46, 50, 53), (31, 43, 46, 50),
              (38, 50, 53, 57), (34, 46, 50, 53),
              (33, 45, 49, 52), (38, 50, 53, 57))
    for bar, chord in enumerate(chords):
        for voice, note in enumerate(chord):
            add_note(samples, bar * 4.0 * beat_seconds - 0.16,
                     4.0 * beat_seconds + 0.32, midi(note),
                     0.048 if voice == 0 else 0.026,
                     attack=0.32, release=0.40, decay=0.08, wrap=True)
    melody = (74, 77, 69, 65, 74, 70, 73, 74)
    for bar, note in enumerate(melody):
        add_note(samples, (bar * 4.0 + 0.5) * beat_seconds,
                 beat_seconds * 2.6, midi(note), 0.019,
                 attack=0.012, release=0.30, decay=2.0, bell=True, wrap=True)
    # Quantization to an integer number of periods makes the drone periodic.
    drone_frequency = round(midi(26) * loop_seconds) / loop_seconds
    for index in range(MUSIC_SAMPLES):
        time = index / SAMPLE_RATE
        breath = 0.8 + 0.2 * math.cos(TAU * index * 4.0 / MUSIC_SAMPLES)
        samples[index] += 0.025 * breath * math.sin(TAU * drone_frequency * time)
    return samples


def encode(samples: list[float], *, music: bool) -> tuple[bytes, dict]:
    peak = max(abs(sample) for sample in samples)
    if not peak or not math.isfinite(peak):
        raise ValueError("Invalid or silent synthesized audio")
    gain = (0.34 if music else 0.50) / peak
    values = array("h", (round(sample * gain * 32767.0) for sample in samples))
    clipped = sum(abs(value) >= 32767 for value in values)
    rms = math.sqrt(sum(value * value for value in values) / len(values)) / 32768.0
    stats = {
        "sample_rate": SAMPLE_RATE, "channels": 1, "sample_width_bytes": 2,
        "samples": len(values), "duration_seconds": round(len(values) / SAMPLE_RATE, 6),
        "peak": round(max(abs(value) for value in values) / 32768.0, 6),
        "rms": round(rms, 6), "clipped_samples": clipped,
        "first_sample": values[0], "last_sample": values[-1],
        "boundary_delta_pcm16": abs(values[0] - values[-1]),
    }
    if clipped:
        raise ValueError("Clipped synthesized audio")
    if music and stats["boundary_delta_pcm16"] > 160:
        raise ValueError("Loop boundary exceeds 160 PCM16 units")
    if not music and (values[0] or abs(values[-1]) > 1):
        # The tail has a full release; enforce exact digital silence at endpoints.
        values[0] = values[-1] = 0
        stats["first_sample"] = stats["last_sample"] = stats["boundary_delta_pcm16"] = 0
    if sys.byteorder != "little":
        values.byteswap()
    output = io.BytesIO()
    with wave.open(output, "wb") as writer:
        writer.setnchannels(1)
        writer.setsampwidth(2)
        writer.setframerate(SAMPLE_RATE)
        writer.writeframes(values.tobytes())
    return output.getvalue(), stats


def sound_metadata(name: str, stats: dict, *, music: bool) -> dict:
    group = "audiogroup_music" if music else "audiogroup_sfx"
    return {
        "$GMSound": "v2", "%Name": name,
        "audioGroupId": {"name": group, "path": f"audiogroups/{group}"},
        "bitDepth": 1, "bitRate": 128, "compression": 0, "conversionMode": 0,
        "duration": stats["duration_seconds"], "name": name,
        "parent": {"name": "Sounds", "path": "folders/Sounds.yy"},
        "preload": not music, "resourceType": "GMSound", "resourceVersion": "2.0",
        "sampleRate": SAMPLE_RATE, "soundFile": f"{name}.wav", "type": 0,
        "volume": 1.0,
    }


def json_bytes(data: dict) -> bytes:
    return (json.dumps(data, ensure_ascii=False, indent=2) + "\n").encode("utf-8")


def outputs() -> dict[Path, bytes]:
    result: dict[Path, bytes] = {}
    manifest = {
        "generator": "tools/generate_audio.py", "generator_license": "GPL-3.0-only",
        "author": "Pedro Tescaro", "audio_license": "CC0-1.0",
        "source": "Original deterministic synthesis; no recordings, samples or soundfonts.",
        "listening_test": "Pending manual listening and in-game mix validation.",
        "tracks": [],
    }
    for short_name in (*SFX_NAMES, "music"):
        name = f"snd_cb_{short_name}"
        music = short_name == "music"
        samples = make_music() if music else make_sfx(short_name)
        wav_bytes, stats = encode(samples, music=music)
        folder = Path("sounds") / name
        result[folder / f"{name}.wav"] = wav_bytes
        result[folder / f"{name}.yy"] = json_bytes(sound_metadata(name, stats, music=music))
        manifest["tracks"].append({
            "name": name, "description": LABELS[short_name], "license": "CC0-1.0",
            "audio_group": "audiogroup_music" if music else "audiogroup_sfx",
            "loop": music, "file": (folder / f"{name}.wav").as_posix(),
            "sha256": hashlib.sha256(wav_bytes).hexdigest(), **stats,
        })
    result[Path("assets/audio_manifest.json")] = json_bytes(manifest)
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="compare outputs without writing")
    args = parser.parse_args()
    generated = outputs()
    # Generate twice to catch accidental use of time, unseeded noise or state.
    if generated != outputs():
        raise RuntimeError("Audio generation is not deterministic")
    failures = []
    for relative, payload in generated.items():
        target = ROOT / relative
        if args.check:
            if not target.is_file() or target.read_bytes() != payload:
                failures.append(relative.as_posix())
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(payload)
    manifest = json.loads(generated[Path("assets/audio_manifest.json")])
    for track in manifest["tracks"]:
        print(f"{track['name']}: {track['duration_seconds']:.3f}s, "
              f"peak={track['peak']:.3f}, RMS={track['rms']:.3f}, "
              f"clipped={track['clipped_samples']}, edge={track['boundary_delta_pcm16']}")
    if failures:
        print("Mismatched/missing outputs: " + ", ".join(failures))
        return 1
    print("Deterministic outputs verified." if args.check else "Generated original audio and metadata.")
    print("No listening test performed; verify loop, balance and playback in GameMaker.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
