"""Confere o conteúdo dos tilemaps da IDE contra o chunk ROOM do pacote Windows VM."""
import argparse
import json
import re
import struct
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LAYERS = ('Pedra_Distante', 'Nave_Media', 'Reliquias', 'Piso_Modular')

def source_cells(layer):
    tiles = layer['tiles']
    assert tiles.get('TileDataFormat') == 1, layer['name']
    data = iter(tiles['TileCompressedData'])
    cells = []
    for run in data:
        if run < 0:
            cells.extend([next(data)] * -run)
        else:
            cells.extend(next(data) for _ in range(run))
    assert len(cells) == 4080 and any(cells), layer['name']
    return cells

def compiled_cells(data, offset):
    cells = []
    while len(cells) < 4080:
        run = data[offset]
        offset += 1
        if run & 128:
            cells.extend([struct.unpack_from('<I', data, offset)[0]] * ((run & 127) + 1))
            offset += 4
        else:
            assert run > 0
            cells.extend(struct.unpack_from(f'<{run}I', data, offset))
            offset += 4 * run
    return cells

def check(package):
    with zipfile.ZipFile(package) as archive:
        data = archive.read('data.win')
    cursor = 8
    chunks = {}
    while cursor < len(data):
        tag, size = struct.unpack_from('<4sI', data, cursor)
        chunks[tag] = (cursor+8, cursor+8+size)
        cursor += size+8
    start, end = chunks[b'ROOM']
    count = struct.unpack_from('<I', data, start)[0]
    offsets = list(struct.unpack_from(f'<{count}I', data, start+4)) + [end]
    results = {}
    for begin, limit in zip(offsets, offsets[1:]):
        ptr = struct.unpack_from('<I', data, begin)[0]
        room = data[ptr:data.index(0, ptr)].decode()
        if room not in ('rm_level1', 'rm_level2', 'rm_level3'):
            continue
        raw = (ROOT/f'rooms/{room}/{room}.yy').read_text(encoding='utf-8-sig')
        layers = json.loads(re.sub(r',\s*([}\]])', r'\1', raw))['layers']
        results[room] = {}
        for name in LAYERS:
            layer = next(item for item in layers if item['name'] == name)
            assert layer['visible'] and layer['tilesetId']['name'] == 'ts_modular'
            cells = source_cells(layer)
            pointer = data.index(name.encode()+b'\0', *chunks[b'STRG'])
            record = data.index(struct.pack('<I', pointer), begin, limit)
            assert struct.unpack_from('<II', data, record+52) == (120,34)
            assert compiled_cells(data, record+60) == cells, (room,name)
            results[room][name] = sum(bool(c) for c in cells)
    assert len(results) == 3
    return results

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('package')
    print(json.dumps(check(parser.parse_args().package),indent=2))
