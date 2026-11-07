/// @description Plataformas sem colisão lateral; só apoiam ao cruzar o topo em queda.
function cb_oneway_at(_x, _y) {
    if (!instance_exists(obj_challenges)) return false;
    var _dx = _x - x, _dy = _y - y;
    var _platforms = obj_challenges.platforms;
    for (var _i=0; _i<array_length(_platforms); _i++) {
        var _p=_platforms[_i];
        if (!_p.active) continue;
        if (bbox_right+_dx>=_p.x && bbox_left+_dx<_p.x+_p.w
            && bbox_bottom<_p.y && bbox_bottom+_dy>=_p.y) return true;
    }
    return false;
}

/// @description Recorta peças do atlas sem esticar os pixels ou interpolar poses.
function cb_challenge_tile(_index, _x, _y, _width=32, _height=32, _flip=false) {
    draw_sprite_part_ext(spr_challenge_atlas, 0,
        (_index % 8)*32, floor(_index / 8)*32, _width, _height,
        round(_x)+(_flip ? _width : 0), round(_y), _flip ? -1 : 1, 1, c_white, 1);
}
