/// @description Arte modular; poses discretas acompanham o tick congelado pela pausa.
draw_set_alpha(1);
for (var _i=0; _i<array_length(platforms); _i++) {
    var _p=platforms[_i];
    if (_p.y>room_height+32) continue;
    var _base=(_p.kind=="moving") ? 3 : ((_p.kind=="falling") ? 6 : 0);
    if (_p.timer>0 && ((_p.timer div 4) mod 2)==0) _base=9;
    for (var _j=0; _j<_p.w; _j+=16) {
        var _cap=(_j==0) ? 0 : ((_j+16>=_p.w) ? 2 : 1);
        cb_challenge_tile(_base+_cap,_p.x+_j,_p.y,min(16,_p.w-_j),16);
    }
    // Farelos visuais determinísticos: não criam instâncias nem mudam colisões.
    if (_p.timer>0) {
        draw_set_color(make_color_rgb(139,172,15));
        for (var _j=0; _j<3; _j++) {
            var _cx=round(_p.x+10+_j*17), _cy=round(_p.y+14+(tick+_j*5) mod 9);
            draw_rectangle(_cx,_cy,_cx+1,_cy+1,false);
        }
    }
}
for (var _i=0; _i<array_length(hazards); _i++) {
    var _h=hazards[_i], _t=tick+_h.phase;
    var _frame=(_t div 7) mod 4;
    if (_h.kind=="pendulum") {
        var _length=point_distance(_h.bx,_h.by,_h.x,_h.y);
        for (var _link=0; _link<_length; _link+=6) {
            var _amount=_link/max(1,_length);
            var _lx=round(lerp(_h.bx,_h.x,_amount)), _ly=round(lerp(_h.by,_h.y,_amount));
            draw_set_color(make_color_rgb(15,56,15));
            draw_rectangle(_lx-1,_ly,_lx+2,_ly+4,false);
            draw_set_color(make_color_rgb(139,172,15));
            draw_line(_lx,_ly,_lx,_ly+2);
            draw_set_color(make_color_rgb(48,98,48));
            draw_line(_lx+1,_ly+2,_lx+1,_ly+3);
        }
        draw_set_color(make_color_rgb(139,172,15));
        draw_rectangle(_h.bx-3,_h.by-3,_h.bx+3,_h.by+3,false);
        draw_set_color(make_color_rgb(15,56,15));
        draw_rectangle(_h.bx-1,_h.by-1,_h.bx+1,_h.by+1,false);
    }
    var _index=20+_frame;
    var _flip=false;
    switch (_h.kind) {
        case "bat": _index=12+_frame; break;
        case "skeleton":
            _index=16+_frame;
            _flip=cos(_t*.03)<0;
            break;
        case "pendulum": _index=24+_frame; break;
        case "blade":
            var _phase=_t mod 150;
            _index=(_phase>=50) ? 28+_frame : 32;
            if (_phase>=25 && ((_phase div 4) mod 2)==0) _index=33;
            break;
    }
    cb_challenge_tile(_index,_h.x-16,_h.y-16,32,32,_flip);
}
draw_set_alpha(1);
draw_set_color(make_color_rgb(155,188,15));
