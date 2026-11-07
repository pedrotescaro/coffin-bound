/// @description Monta a expansao usando os tilesets reais do projeto.
// A sala original ocupa x=0..479. A continuacao recombina os tilemaps
// existentes sem regravar os dados comprimidos da room.

cb_boot();
var _room_level=(room==rm_level3)?2:((room==rm_level2)?1:0);
if(global.cb.level!=_room_level) { global.cb.level=_room_level;global.cb.checkpoint=0; }
depth = -100;
cb_gui_apply();

COLOR_LEVEL_DARKEST = make_color_rgb(15,56,15);
COLOR_LEVEL_DARK    = make_color_rgb(15,56,15);
COLOR_LEVEL_LIGHT   = make_color_rgb(139,172,15);
COLOR_LEVEL_BRIGHT  = make_color_rgb(155,188,15);

respawn_x = 56;
respawn_y = 205;
checkpoint = global.cb.checkpoint;
respawn_cooldown = 0;

global.dialogue_active = false;
dialogue_intro_timer = 24;
dialogue_seen = [checkpoint > 0, checkpoint > 0, checkpoint > 1, checkpoint > 2];

// Scribble usa a mesma fonte escolhida pelo menu, incluindo o fallback seguro.
scribble_initialize();
var _project_font = font_get_name(fnt_monogram);
dialogue_font = scribble_font_exists(_project_font) ? _project_font : "scribble_fallback_font";
dialogue_typist = scribble_typist();
dialogue_serial = 0;
dialogue_speaker = "";
dialogue_body = scribble("", "level_dialogue_empty")
    .starting_format(dialogue_font, make_color_rgb(155,188,15))
    .align(fa_left, fa_top)
    .line_height(20, 20)
    .line_spacing(20)
    .wrap(294);
dialogue_name = scribble("", "level_dialogue_name_empty")
    .starting_format(dialogue_font, COLOR_LEVEL_BRIGHT)
    .align(fa_left, fa_top);
dialogue_continue = scribble("ENTER / A", "level_dialogue_continue")
    .starting_format(dialogue_font, make_color_rgb(155,188,15))
    .align(fa_left, fa_top);

start_dialogue = function(_speaker, _text) {
    dialogue_serial++;
    dialogue_speaker = _speaker;
    dialogue_name = scribble(_speaker, "level_dialogue_name_" + string(dialogue_serial))
        .starting_format(dialogue_font, (_speaker == "VAMPIRO")
            ? make_color_rgb(155,188,15) : COLOR_LEVEL_BRIGHT)
        .align(fa_left, fa_top);
    dialogue_body = scribble(_text, "level_dialogue_body_" + string(dialogue_serial))
        .starting_format(dialogue_font, make_color_rgb(155,188,15))
        .align(fa_left, fa_top)
        .line_height(20, 20)
        .line_spacing(20)
        .wrap(294);
    dialogue_typist.reset().in(0.65, 2);
    global.dialogue_active = true;
};

respawn_player = function() {
    if (!instance_exists(obj_player)) return;
    with (obj_player) {
        player_reset(other.respawn_x, other.respawn_y);
    }
    respawn_cooldown = 24;
    death_handled = false;
    win_handled = false;
    global.dialogue_active = false;
    with (obj_coffin) sprite_index = spr_coffin;
    if(instance_exists(obj_challenges)) { with(obj_challenges) event_perform(ev_create,0); }
    if (instance_exists(obj_camera) && instance_exists(obj_player)) {
        with (obj_camera) {
            follow_x = clamp(obj_player.x - view_w / 2, 0, max(0, room_width - view_w));
            follow_y = clamp(obj_player.y - view_h / 2, 0, max(0, room_height - view_h));
            camera_set_view_pos(cam, round(follow_x), round(follow_y));
        }
    }
};

// Posições seguras do catálogo da fase, sem gravar coordenadas arbitrárias no save.
checkpoint_spawns = (global.cb.level==2) ? [[48,448],[672,320],[1216,336],[1536,272]] : ((global.cb.level==1) ? [[48,448],[672,320],[1216,320],[1536,272]] : [[48,448],[672,320],[1216,288],[1536,272]]);
checkpoint_timer = 0;
death_handled = false;
win_handled = false;
last_grounded = false;
last_bat = false;
fx_particles = [];
emit_burst = function(_px, _py, _count, _colour) {
    repeat (min(_count, max(0, 96 - array_length(fx_particles)))) {
        array_push(fx_particles, { px: _px, py: _py,
            vx: random_range(-1.6, 1.6), vy: random_range(-2, 0.2),
            life: irandom_range(12, 24), max_life: 24, colour: _colour });
    }
};
set_checkpoint = function(_index) {
    checkpoint = clamp(_index, 0, array_length(checkpoint_spawns) - 1);
    respawn_x = checkpoint_spawns[checkpoint][0];
    respawn_y = checkpoint_spawns[checkpoint][1];
    global.cb.checkpoint = checkpoint;
    cb_save_progress();
    checkpoint_timer = 90;
    cb_play_sfx(snd_cb_checkpoint);
    if (instance_exists(obj_player)) emit_burst(obj_player.x, obj_player.y, 12, COLOR_LEVEL_BRIGHT);
};
respawn_x = checkpoint_spawns[checkpoint][0];
respawn_y = checkpoint_spawns[checkpoint][1];
respawn_player();
