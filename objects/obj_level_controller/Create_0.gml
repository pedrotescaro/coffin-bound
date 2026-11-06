/// @description Monta a expansao usando os tilesets reais do projeto.
// A sala original ocupa x=0..479. A continuacao recombina os tilemaps
// existentes sem regravar os dados comprimidos da room.

depth = 150;
display_set_gui_size(480, 270);

COLOR_LEVEL_DARKEST = make_color_rgb(15, 56, 15);
COLOR_LEVEL_DARK    = make_color_rgb(48, 98, 48);
COLOR_LEVEL_LIGHT   = make_color_rgb(139, 172, 15);
COLOR_LEVEL_BRIGHT  = make_color_rgb(155, 188, 15);

respawn_x = 56;
respawn_y = 205;
checkpoint = 0;
respawn_cooldown = 0;

global.dialogue_active = false;
dialogue_intro_timer = 24;
dialogue_seen = [false, false, false, false];

// Scribble usa a mesma fonte escolhida pelo menu, incluindo o fallback seguro.
scribble_initialize();
var _project_font = font_get_name(fnt_monogram);
dialogue_font = scribble_font_exists(_project_font) ? _project_font : "scribble_fallback_font";
dialogue_typist = scribble_typist();
dialogue_serial = 0;
dialogue_body = scribble("", "level_dialogue_empty")
    .starting_format(dialogue_font, c_white)
    .align(fa_left, fa_top)
    .wrap(350);
dialogue_name = scribble("", "level_dialogue_name_empty")
    .starting_format(dialogue_font, COLOR_LEVEL_BRIGHT)
    .align(fa_left, fa_top);
dialogue_continue = scribble(">", "level_dialogue_continue")
    .starting_format(dialogue_font, COLOR_LEVEL_BRIGHT)
    .align(fa_left, fa_top);

start_dialogue = function(_speaker, _text) {
    dialogue_serial++;
    dialogue_name = scribble(_speaker, "level_dialogue_name_" + string(dialogue_serial))
        .starting_format(dialogue_font, COLOR_LEVEL_BRIGHT)
        .align(fa_left, fa_top);
    dialogue_body = scribble(_text, "level_dialogue_body_" + string(dialogue_serial))
        .starting_format(dialogue_font, c_white)
        .align(fa_left, fa_top)
        .wrap(350);
    dialogue_typist.reset().in(0.65, 2);
    global.dialogue_active = true;
};

respawn_player = function() {
    if (!instance_exists(obj_player)) return;
    with (obj_player) {
        x = other.respawn_x;
        y = other.respawn_y;
        hsp = 0;
        vsp = 0;
        state = PlayerState.NORMAL;
        can_dash = true;
        bat_energy = bat_energy_max;
        hp = max_hp;
        display_hp = max_hp;
        hp_damage_trail = max_hp;
        sprite_index = spr_vampire_idle;
        image_speed = 1;
        flash_hit = 10;
    }
    respawn_cooldown = 24;
};
