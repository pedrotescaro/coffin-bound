/// @description End Step acompanha a posição final, depois da física e dos checkpoints.
if (variable_global_exists("is_paused") && global.is_paused) exit;
var _dt = clamp(delta_time * 0.000001, 0, 0.05);
var _shake_x = 0, _shake_y = 0;
if (shake_timer > 0) {
    shake_timer = max(0, shake_timer - _dt * 60);
    _shake_x = irandom_range(-shake_amount, shake_amount);
    _shake_y = irandom_range(-shake_amount, shake_amount);
} else shake_amount = 0;

if (instance_exists(obj_player)) {
    var _p = instance_find(obj_player, 0);
    var _focus_x = (_p.bbox_left + _p.bbox_right) * 0.5;
    var _focus_y = (_p.bbox_top + _p.bbox_bottom) * 0.5;
    var _look = clamp(_p.hsp / 3, -1, 1) * 56;
    look_ahead_x = lerp(look_ahead_x, _look, cb_camera_blend(5, _dt));
    var _fall_look = _p.on_ground ? 0 : clamp((_p.vsp - 3) * 5, 0, 40);
    var _target_x = cb_camera_deadzone(follow_x, _focus_x + look_ahead_x,
        view_w * 0.5 - 24, view_w * 0.5 + 24);
    var _target_y = cb_camera_deadzone(follow_y, _focus_y + _fall_look,
        view_h * 0.34, view_h * 0.66);
    follow_x = lerp(follow_x, _target_x, cb_camera_blend(9, _dt));
    follow_y = lerp(follow_y, _target_y, cb_camera_blend(6, _dt));
    // Limite de segurança inclui o sprite completo, mesmo durante um dash.
    var _sw = sprite_get_width(_p.sprite_index), _sh = sprite_get_height(_p.sprite_index);
    follow_x = clamp(follow_x, _focus_x - view_w + _sw + 16, _focus_x - _sw - 16);
    follow_y = clamp(follow_y, _focus_y - view_h + _sh + 16, _focus_y - _sh - 16);
    follow_x = clamp(follow_x, 0, max(0, room_width - view_w));
    follow_y = clamp(follow_y, 0, max(0, room_height - view_h));
}
var _draw_x = clamp(round(follow_x) + _shake_x, 0, max(0, room_width - view_w));
var _draw_y = clamp(round(follow_y) + _shake_y, 0, max(0, room_height - view_h));
camera_set_view_pos(cam, _draw_x, _draw_y);
cb_camera_parallax(_draw_x, _draw_y);
