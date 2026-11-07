/// @description Silhuetas de armadilha e aviso antes de ativar; somente quatro verdes.
draw_set_alpha(1);
for(var _i=0;_i<array_length(platforms);_i++) {
    var _p=platforms[_i];if(_p.y>room_height+32)continue;
    draw_set_color(make_color_rgb(15,56,15));
    draw_rectangle(_p.x,_p.y,_p.x+_p.w-1,_p.y+7,false);
    draw_set_color(make_color_rgb(139,172,15));
    draw_rectangle(_p.x,_p.y,_p.x+_p.w-1,_p.y+2,false);
    draw_set_color(make_color_rgb(48,98,48));
    for(var _j=8;_j<_p.w;_j+=16)draw_line(_p.x+_j,_p.y+3,_p.x+_j+3,_p.y+6);
    if(_p.timer>0){draw_set_color(make_color_rgb(155,188,15));draw_text(_p.x,_p.y+8,"!");}
}
for(var _i=0;_i<array_length(hazards);_i++) {
    var _h=hazards[_i];
    var _active=_h.kind!="blade" || ((tick+_h.phase) mod 150)>=50;
    draw_set_color(make_color_rgb(48,98,48));
    if(_h.kind=="pendulum")draw_line(_h.bx,_h.by,_h.x,_h.y);
    if(_h.kind=="bat") {
        draw_sprite_ext(spr_bat,0,_h.x,_h.y+12,1,1,0,c_white,1);
    }else if(_h.kind=="skeleton") {
        draw_set_color(make_color_rgb(155,188,15));
        draw_rectangle(_h.x-4,_h.y-10,_h.x+4,_h.y-3,false);
        draw_line(_h.x,_h.y-2,_h.x,_h.y+6);
        draw_line(_h.x-6,_h.y,_h.x+6,_h.y);
        draw_line(_h.x,_h.y+6,_h.x-4,_h.y+11);
        draw_line(_h.x,_h.y+6,_h.x+4,_h.y+11);
        draw_set_color(make_color_rgb(15,56,15));draw_point(_h.x-2,_h.y-7);draw_point(_h.x+2,_h.y-7);
    }else{
        draw_set_color(_active?make_color_rgb(155,188,15):make_color_rgb(48,98,48));
        draw_circle(_h.x,_h.y,9,false);
        for(var _j=0;_j<8;_j++){
            var _a=tick*3+_j*45;
            draw_triangle(_h.x+lengthdir_x(7,_a-16),_h.y+lengthdir_y(7,_a-16),
                _h.x+lengthdir_x(13,_a),_h.y+lengthdir_y(13,_a),
                _h.x+lengthdir_x(7,_a+16),_h.y+lengthdir_y(7,_a+16),false);
        }
        draw_set_color(make_color_rgb(15,56,15));draw_circle(_h.x,_h.y,3,false);
    }
}
draw_set_color(make_color_rgb(155,188,15));
