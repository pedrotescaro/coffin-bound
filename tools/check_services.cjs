// Regressões dos serviços/menus executando o source real GML em sandbox JavaScript.
// NÃO compila GML, não simula o runner, arquivos INI reais, o pacote Input,
// callbacks/eventos, áudio, navegador, máscaras, surfaces nem aparência.
// Os mocks registram chamadas e mantêm estado mínimo. Funções com `with`
// (câmera/partículas) não são exercitadas por este harness.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const read = name => fs.readFileSync(path.join(root, 'scripts', name, `${name}.gml`), 'utf8');
const plain = value => JSON.parse(JSON.stringify(value));
const DEFAULT_KEYS = [65, 68, 87, 83, 32, 67, 70];
const SETTINGS = 'coffin_bound_settings.ini';
const SAVE = 'coffin_bound_save.ini';
const names = ['PLAYER_LEFT', 'PLAYER_RIGHT', 'PLAYER_UP', 'PLAYER_DOWN', 'PLAYER_JUMP', 'PLAYER_DASH', 'PLAYER_BAT', 'MENU_ACCEPT', 'MENU_BACK', 'UP', 'DOWN', 'LEFT', 'RIGHT'];
function sandbox(files = {}, browser = false) {
  const state = {
    files: plain(files), open: null, iniEvents: [], writes: [], bindings: [],
    fullscreen: false, fullscreenCalls: [], requestedGroups: [], loadedGroups: new Set(),
    playing: new Set(), played: [], nextHandle: 100, masterGain: null, groupGains: [],
    room: null, key: 0, pressed: false, exited: false, layer: 1, visible: false
  };
  const s = {
    global: {}, Math, floor: Math.floor, round: Math.round, max: Math.max, min: Math.min,
    sign: Math.sign, clamp: (v, lo, hi) => Math.min(hi, Math.max(lo, v)),
    lerp: (a, b, t) => a + (b - a) * t, dsin: () => 0,
    array_length: a => a.length, variable_clone: plain,
    variable_global_exists: name => Object.hasOwn(s.global, name),
    ord: value => value.charCodeAt(0), chr: String.fromCharCode, string: String,
    vk_space: 32, vk_shift: 16, vk_left: 37, vk_up: 38, vk_right: 39, vk_down: 40,
    browser_not_a_browser: -1, os_browser: browser ? 3 : -1,
    rm_menu: 1000, rm_level1: 1001, audiogroup_music: 1, audiogroup_sfx: 2,
    snd_cb_music: 11, snd_cb_ui: 12,
    INPUT_VERB: Object.fromEntries(names.map((name, i) => [name, i])),
    MenuPage: { MAIN: 0, OPTIONS: 1, CONTROLS: 2, CREDITS: 3 },
    current_time: 100, keyboard_lastkey: 0,
    keyboard_check_pressed: key => state.pressed && key === state.key,
    make_color_rgb: (r, g, b) => r + 256 * g + 65536 * b,
    InputBindingSet: (...args) => state.bindings.push(args),
    ini_open(name) {
      assert.equal(state.open, null, 'INI anterior deve ser fechado antes de abrir outro');
      state.open = name; state.files[name] ??= {}; state.iniEvents.push(['open', name]);
    },
    ini_read_real(section, key, fallback) {
      assert.notEqual(state.open, null, 'leitura exige INI aberto');
      return state.files[state.open][section]?.[key] ?? fallback;
    },
    ini_write_real(section, key, value) {
      assert.notEqual(state.open, null, 'escrita exige INI aberto');
      const file = state.files[state.open]; file[section] ??= {}; file[section][key] = value;
      state.writes.push([state.open, section, key, value]);
    },
    ini_close() {
      assert.notEqual(state.open, null, 'fechamento exige INI aberto');
      state.iniEvents.push(['close', state.open]); state.open = null;
    },
    file_exists: name => Object.hasOwn(state.files, name),
    window_set_fullscreen(value) { state.fullscreen = Boolean(value); state.fullscreenCalls.push(Boolean(value)); },
    window_get_fullscreen: () => state.fullscreen,
    audio_group_load: group => state.requestedGroups.push(group),
    audio_group_is_loaded: group => state.loadedGroups.has(group),
    audio_master_gain: gain => { state.masterGain = gain; },
    audio_group_set_gain: (group, gain, duration) => state.groupGains.push([group, gain, duration]),
    audio_is_playing: handle => state.playing.has(handle),
    audio_play_sound(sound, priority, loop) {
      const handle = state.nextHandle++; state.playing.add(handle);
      state.played.push({ sound, priority, loop, handle }); return handle;
    },
    room_goto: room => { state.room = room; },
    layer_get_id: () => state.layer,
    layer_exists: id => id >= 0,
    layer_set_visible: (id, visible) => { state.visible = visible; },
    game_end: () => { state.exited = true; }
  };
  vm.createContext(s);
  vm.runInContext(read('cb_services'), s, { filename: 'cb_services.gml' });
  return { s, state };
}
function menus(s) {
  for (const name of ['menu_data', 'menu_actions', 'menu_navigation']) {
    vm.runInContext(read(name), s, { filename: `${name}.gml` });
  }
  s.menu_data_initialize();
}
let checks = 0;
function check(name, fn) { fn(); checks++; console.log(`OK ${name}`); }
check('boot define padrões, bindings primários/setas e é idempotente', () => {
  const { s, state } = sandbox(); s.cb_boot();
  assert.deepEqual(plain(s.global.cb.keys), DEFAULT_KEYS);
  assert.equal(s.global.cb.master, 0.8); assert.equal(s.global.cb.music, 0.45);
  assert.equal(s.global.cb.sfx, 0.7); assert.equal(s.global.cb.has_save, false);
  assert.deepEqual(plain(s.global.cb_levels), [s.rm_level1]);
  assert.equal(state.bindings.length, 14);
  assert.deepEqual(state.bindings.filter(b => b[3] === 0).map(b => b[2]), DEFAULT_KEYS);
  assert.deepEqual(state.bindings.filter(b => b[3] === 1).map(b => b[2]), [37, 39, 38, 40, undefined, undefined, undefined]);
  assert.deepEqual(state.requestedGroups, [s.audiogroup_music, s.audiogroup_sfx]);
  assert.equal(state.open, null); const events = state.iniEvents.length;
  s.cb_boot(); assert.equal(state.iniEvents.length, events); assert.equal(state.bindings.length, 14);
});
check('preferências limitam volumes e restauram teclas duplicadas/reservadas', () => {
  for (const controls of [{ 0: 68 }, { 0: 71 }, { 0: 13 }]) {
    const { s, state } = sandbox({ [SETTINGS]: { audio: { master: 5, music: -3, sfx: 0.35 }, controls } });
    s.cb_boot(); assert.equal(s.global.cb.master, 1); assert.equal(s.global.cb.music, 0);
    assert.equal(s.global.cb.sfx, 0.35); assert.deepEqual(plain(s.global.cb.keys), DEFAULT_KEYS);
    assert.equal(state.open, null);
  }
});
check('save inválido por versão ou fase é ignorado', () => {
  for (const progress of [{ version: 2, level: 0, checkpoint: 2 }, { version: 1, level: 9 }, { version: 1, level: -1 }]) {
    const { s, state } = sandbox({ [SAVE]: { progress } }); s.cb_boot();
    assert.equal(s.global.cb.has_save, false); assert.equal(s.global.cb.checkpoint, 0); assert.equal(state.open, null);
  }
});
check('save válido limita checkpoint e mortes; lê conclusão', () => {
  for (const [checkpoint, expected] of [[9.8, 3], [-5, 0], [2.9, 2]]) {
    const { s, state } = sandbox({ [SAVE]: { progress: { version: 1, level: 0, checkpoint, deaths: -3, completed: 1 } } });
    s.cb_boot(); assert.equal(s.global.cb.has_save, true); assert.equal(s.global.cb.checkpoint, expected);
    assert.equal(s.global.cb.deaths, 0); assert.equal(s.global.cb.completed, true); assert.equal(state.open, null);
  }
});
check('novo jogo reinicia progresso preservando opções; continuar preserva checkpoint', () => {
  const { s, state } = sandbox({ [SETTINGS]: { audio: { master: 0.25 } }, [SAVE]: { progress: { version: 1, level: 0, checkpoint: 3, deaths: 10, completed: 1 } } });
  s.cb_boot(); const options = [s.global.cb.master, s.global.cb.music, s.global.cb.sfx, s.global.cb.fullscreen, s.global.cb.filter, plain(s.global.cb.keys)];
  s.cb_start_game(false); assert.equal(s.global.cb.checkpoint, 3); assert.equal(state.room, s.rm_level1);
  s.global.is_paused = true; s.global.dialogue_active = true; s.cb_start_game(true);
  assert.equal(s.global.cb.checkpoint, 0); assert.equal(s.global.cb.deaths, 0); assert.equal(s.global.cb.completed, false);
  assert.equal(s.global.is_paused, false); assert.equal(s.global.dialogue_active, false);
  assert.deepEqual([s.global.cb.master, s.global.cb.music, s.global.cb.sfx, s.global.cb.fullscreen, s.global.cb.filter, plain(s.global.cb.keys)], options);
  assert.equal(state.files[SAVE].progress.version, 1); assert.equal(state.files[SAVE].progress.checkpoint, 0); assert.equal(state.open, null);
});
check('conclusão final salva e solicita créditos; catálogo avança fase intermediária', () => {
  const { s, state } = sandbox(); s.cb_boot(); s.cb_complete_level();
  assert.equal(s.global.cb.completed, true); assert.equal(s.global.cb_open_credits, true);
  assert.equal(state.room, s.rm_menu); assert.equal(state.files[SAVE].progress.completed, true); assert.equal(state.open, null);
  const next = sandbox(); next.s.cb_boot(); next.s.global.cb_levels.push(1002); next.s.global.cb.checkpoint = 3;
  next.s.cb_complete_level(); assert.equal(next.s.global.cb.level, 1); assert.equal(next.s.global.cb.checkpoint, 0);
  assert.equal(next.state.room, 1002); assert.equal(next.s.global.cb_open_credits, false);
});
check('música espera grupo, mantém uma voz e recupera handle encerrado', () => {
  const { s, state } = sandbox(); s.cb_boot(); s.cb_audio_update();
  assert.equal(state.played.length, 0); assert.equal(s.global.cb.music_handle, -1);
  state.loadedGroups.add(s.audiogroup_music); s.cb_audio_update(); const first = s.global.cb.music_handle;
  s.cb_audio_update(); assert.equal(state.played.length, 1); assert.equal(s.global.cb.music_handle, first);
  assert.equal(state.played[0].loop, true); state.playing.delete(first); s.cb_audio_update();
  assert.equal(state.played.length, 2); assert.notEqual(s.global.cb.music_handle, first);
});
check('efeitos esperam grupo e ganhos respeitam preferências', () => {
  const { s, state } = sandbox(); s.cb_boot(); s.cb_play_sfx(s.snd_cb_ui); assert.equal(state.played.length, 0);
  state.loadedGroups.add(s.audiogroup_sfx); s.cb_play_sfx(s.snd_cb_ui); assert.equal(state.played.length, 1);
  assert.equal(state.played[0].loop, false); s.global.cb.master = 0.2; s.global.cb.music = 0.3; s.global.cb.sfx = 0.4; s.cb_apply_audio();
  assert.equal(state.masterGain, 0.2); assert.deepEqual(state.groupGains.slice(-2), [[1, 0.3, 0], [2, 0.4, 0]]);
});
check('fullscreen nativo alterna e salva; navegador não chama API de janela', () => {
  const desktop = sandbox(); desktop.s.cb_boot(); desktop.s.cb_toggle_fullscreen();
  assert.deepEqual(desktop.state.fullscreenCalls, [false, true]); assert.equal(desktop.s.global.cb.fullscreen, true);
  assert.equal(desktop.state.files[SETTINGS].display.fullscreen, true); assert.equal(desktop.state.open, null);
  const browser = sandbox({}, true); browser.state.fullscreen = true; browser.s.cb_boot(); browser.s.cb_toggle_fullscreen();
  assert.deepEqual(browser.state.fullscreenCalls, []); assert.equal(browser.s.global.cb.fullscreen, true); assert.equal(browser.state.open, null);
});
check('salvar opções fecha INI, mantém progresso separado e persiste sete teclas', () => {
  const { s, state } = sandbox({ [SAVE]: { progress: { version: 1, level: 0, checkpoint: 2, deaths: 4 } } }); s.cb_boot();
  const progress = plain(state.files[SAVE]); s.global.cb.filter = true; s.global.cb.keys[4] = 66; s.cb_save_settings();
  assert.equal(state.files[SETTINGS].display.filter, true); assert.equal(state.files[SETTINGS].controls['4'], 66);
  assert.equal(Object.keys(state.files[SETTINGS].controls).length, 7); assert.deepEqual(state.files[SAVE], progress); assert.equal(state.open, null);
  assert.deepEqual(state.iniEvents.slice(-2), [['open', SETTINGS], ['close', SETTINGS]]);
});
check('menu oferece continuar apenas com save e despacha novo/continuar corretamente', () => {
  const { s, state } = sandbox(); s.cb_boot(); menus(s); assert.equal(s.menu.length, 4);
  s.selected = 0; s.menu_actions_main(); assert.equal(state.room, s.rm_level1); assert.equal(s.global.cb.has_save, true);
  s.menu_main_refresh(); assert.equal(s.menu.length, 5); s.global.cb.checkpoint = 2;
  s.selected = 0; s.menu_actions_main(); assert.equal(s.global.cb.checkpoint, 2);
  s.selected = 1; s.menu_actions_main(); assert.equal(s.global.cb.checkpoint, 0);
});
check('opções limitam volume, retornam de créditos e orientam fullscreen HTML5', () => {
  const { s, state } = sandbox(); s.cb_boot(); menus(s); s.current_page = s.MenuPage.OPTIONS;
  s.selected = 0; s.menu_input_accept = false; s.menu_input_horizontal = -1; s.global.cb.master = 0; s.menu_actions_options(); assert.equal(s.global.cb.master, 0);
  s.menu_input_horizontal = 1; s.global.cb.master = 1; s.menu_actions_options(); assert.equal(s.global.cb.master, 1); assert.equal(state.open, null);
  s.current_page = s.MenuPage.CREDITS; s.menu_input_back = true; s.menu_actions_update(); assert.equal(s.current_page, s.MenuPage.MAIN); assert.equal(s.selected, 2);
  const browser = sandbox({}, true); browser.s.cb_boot(); menus(browser.s); browser.s.selected = 3;
  browser.s.menu_input_accept = true; browser.s.menu_input_horizontal = 0; browser.s.menu_actions_options();
  assert.match(browser.s.menu_notice, /itch.io/); assert.deepEqual(browser.state.fullscreenCalls, []);
});
check('remap rejeita conflito, aceita tecla nova, cancela por voltar e por timeout', () => {
  const { s, state } = sandbox(); s.cb_boot(); menus(s); s.rebind_index = 4; s.rebind_deadline = 1000;
  s.menu_input_back = false; s.keyboard_lastkey = state.key = 68; state.pressed = true; s.menu_rebind_update();
  assert.equal(s.rebind_index, 4); assert.equal(s.global.cb.keys[4], 32);
  s.keyboard_lastkey = state.key = 66; s.menu_rebind_update(); assert.equal(s.rebind_index, -1); assert.equal(s.global.cb.keys[4], 66);
  assert.equal(state.files[SETTINGS].controls['4'], 66); assert.equal(state.open, null);
  s.rebind_index = 1; s.menu_input_back = true; s.menu_rebind_update(); assert.equal(s.rebind_index, -1);
  s.rebind_index = 1; s.menu_input_back = false; s.rebind_deadline = 1; s.menu_rebind_update(); assert.equal(s.rebind_index, -1);
});
console.log(`${checks} regressões de serviços/menus aprovadas; compilação e teste no GameMaker continuam necessários.`);
