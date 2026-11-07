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
