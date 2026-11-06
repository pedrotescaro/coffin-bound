// Executa os kernels matemáticos GML em um sandbox JS com colisores retangulares.
// Não simula o runner, máscaras precisas, animação, eventos nem compila GML.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const read = name => fs.readFileSync(path.join(root, 'scripts', name, `${name}.gml`), 'utf8');
const enumBody = read('scr_enums').match(/enum PlayerState\s*\{([\s\S]*?)\}/)[1];
const labels = enumBody.replace(/\/\/[^\n]*/g, '').split(',').map(s => s.trim()).filter(Boolean);
const PlayerState = Object.fromEntries(labels.map((name, i) => [name, i]));
function sandbox() {
  const s = { PlayerState, Math, sign: Math.sign, floor: Math.floor, abs: Math.abs,
    max: Math.max, min: Math.min, clamp: (v, lo, hi) => Math.min(hi, Math.max(lo, v)),
    state: PlayerState.NORMAL, x: 40, y: 40, hsp: 0, vsp: 0,
    move_remainder_x: 0, move_remainder_y: 0, room_width: 480,
    obj_wall: 1, obj_ground: 2, walls: [], on_ground: false, on_wall: 0,
    visual_was_on_ground: false, visual_landed: false, can_dash: true,
    bat_landing_grace_timer: 0, damage_timer: 0,
    player_return_to_human() { s.state = PlayerState.TRANSFORM_TO_HUMAN; },
    player_update_contacts() { s.on_ground = s.place_meeting(s.x, s.y + 1); },
    player_sync_human_state() {},
    place_meeting(x, y) { return s.walls.some(r => x + 3 >= r.x && x <= r.x + r.w - 1
      && y + 7 >= r.y && y <= r.y + r.h - 1); }
  };
  Object.defineProperties(s, {
    bbox_left: { get: () => s.x }, bbox_right: { get: () => s.x + 3 },
    bbox_top: { get: () => s.y }
  });
  vm.createContext(s);
  const source = read('player_collision').replace(/repeat \(abs\((_move_[xy])\)\)/g,
    (_, axis) => `for (var __i_${axis} = 0; __i_${axis} < abs(${axis}); __i_${axis}++)`);
  vm.runInContext(source, s);
  return s;
}
let checks = 0;
function check(name, fn) { fn(); checks++; console.log(`OK ${name}`); }
check('não atravessa parede de um pixel com deslocamento de 20px', () => {
  const s = sandbox(); s.walls = [{ x: 50, y: 0, w: 1, h: 200 }]; s.hsp = 20;
  s.player_resolve_collision(); assert.equal(s.x, 46); assert.equal(s.hsp, 0);
});
check('não atravessa chão de um pixel em queda rápida', () => {
  const s = sandbox(); s.walls = [{ x: 0, y: 60, w: 200, h: 1 }]; s.vsp = 30;
  s.player_resolve_collision(); assert.equal(s.y, 52); assert.equal(s.vsp, 0);
});
check('resíduos preservam movimento lento nos dois sentidos', () => {
  for (const direction of [-1, 1]) {
    const s = sandbox(); s.x = 100; s.hsp = direction * 0.25;
    for (let i = 0; i < 40; i++) s.player_resolve_collision();
    assert.equal(s.x, 100 + direction * 10);
  }
});
check('gravidade fracionária acumula até deslocar um pixel', () => {
  const s = sandbox(); s.vsp = 0.3;
  for (let i = 0; i < 4; i++) s.player_resolve_collision();
  assert.equal(s.y, 41); assert.ok(Math.abs(s.move_remainder_y - 0.2) < 1e-9);
});
check('dash interrompido pela parede cancela deslocamento vertical restante', () => {
  const s = sandbox(); s.walls = [{ x: 50, y: 0, w: 1, h: 200 }];
  s.state = PlayerState.DASH; s.hsp = 20; s.vsp = 10;
  s.player_resolve_collision(); assert.equal(s.x, 46); assert.equal(s.y, 40);
  assert.equal(s.state, PlayerState.FALL);
});
check('vitória e morte não movem o personagem', () => {
  for (const state of [PlayerState.WIN, PlayerState.DEATH]) {
    const s = sandbox(); s.state = state; s.hsp = 10; s.vsp = 10;
    s.player_resolve_collision(); assert.equal(s.x, 40); assert.equal(s.y, 40);
  }
});
function movement() {
  const s = sandbox();
  Object.assign(s, {
    move_input: 0, walk_spd: 3, accel_ground: 0.5, accel_air: 0.3,
    friction_ground: 0.5, friction_air: 0.1, grv: 0.3, max_vsp: 10,
    jump_spd: -6, wall_jump_timer: 0, wall_stick_timer: 0, wall_stick_max: 15,
    wall_jump_hsp: 5, wall_jump_vsp: -6, wall_slide_spd: 2,
    buffer_counter: 0, buffer_frames: 6, coyote_counter: 0, coyote_frames: 10,
    input_jump_press: false, input_jump_held: true, input_dash: false,
    input_move_x: 1, input_move_y: 0, image_xscale: 1,
    spr_vampire_idle: 10, dash_spd: 3.5, dash_duration: 9, bat_energy: 100, bat_energy_max: 100,
    bat_recharge_rate: 0.33, respawn_invulnerability: 0,
    player_visual_start_jump() {}, player_visual_start_dash() {},
    point_direction: (x, y, xx, yy) => Math.atan2(y - yy, xx - x) * 180 / Math.PI,
    lengthdir_x: (l, d) => l * Math.cos(d * Math.PI / 180),
    lengthdir_y: (l, d) => -l * Math.sin(d * Math.PI / 180)
  });
  for (const name of ['player_states', 'player_transitions', 'player_resources']) {
    vm.runInContext(read(name).replace(/\bmod\b/g, '%'), s);
  }
  return s;
}
check('coyote permite saltar após sair da borda', () => {
  const s = movement(); s.coyote_counter = 3; s.input_jump_press = true;
  s.player_update_resources(); s.player_state_normal();
  assert.equal(s.vsp, -6); assert.equal(s.coyote_counter, 0);
});
check('buffer é consumido ao aterrissar', () => {
  const s = movement(); s.buffer_counter = 3; s.on_ground = true;
  s.player_update_resources(); s.player_state_normal();
  assert.equal(s.vsp, -6); assert.equal(s.buffer_counter, 0);
});
check('soltar pulo reduz altura e dash mantém prioridade sobre parede', () => {
  const s = movement(); s.vsp = -5; s.input_jump_held = false;
  s.player_state_normal(); assert.equal(s.vsp, -2.4);
  s.on_wall = 1; s.move_input = 1; s.vsp = 0; s.input_dash = true;
  s.player_state_normal(); assert.equal(s.state, PlayerState.DASH);
});
check('perder parede impede wall jump sem contato', () => {
  const s = movement(); s.state = PlayerState.WALL_SLIDE; s.buffer_counter = 3;
  s.player_state_wall_slide(); assert.ok(s.vsp >= 0); assert.equal(s.image_xscale, 1);
});
console.log(`${checks} verificações matemáticas aprovadas; teste no GameMaker continua necessário.`);
