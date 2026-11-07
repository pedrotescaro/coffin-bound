/// @description Atualiza antes do movimento do jogador; pausa/diálogo congelam ciclos.
if (global.is_paused || global.dialogue_active || !instance_exists(obj_player)) exit;
var _player=instance_find(obj_player,0);
if (_player.state==PlayerState.DEATH || _player.state==PlayerState.WIN) exit;
tick++;
for(var _i=0;_i<array_length(platforms);_i++) {
    var _p=platforms[_i],_oldx=_p.x,_oldy=_p.y;
    var _riding=_p.active && _player.bbox_bottom>=_p.y-2 && _player.bbox_bottom<_p.y+1
        && _player.bbox_right>=_p.x && _player.bbox_left<_p.x+_p.w && _player.vsp>=0;
    if (_p.kind=="moving") _p.x=round(_p.bx+sin(tick*_p.speed)*_p.range);
    if (_p.kind=="falling") {
        if(_riding && _p.timer==0) _p.timer=30;
        if(_p.timer>0) {
            _p.timer--;
            if(_p.timer==0) {_p.active=false;_p.timer=-180;}
        } else if(_p.timer<0) {
            _p.timer++;
            if(_p.timer==0){_p.active=true;_p.y=_p.by;_p.fall=0;}
            else {_p.fall=min(8,_p.fall+.3);_p.y+=_p.fall;}
        }
    }
    if(_riding && _p.active) {
        var _mx=_p.x-_oldx;
        with(_player) {
            repeat(abs(_mx)) {
                if(place_meeting(x+sign(_mx),y,[obj_wall,obj_ground])) break;
                x+=sign(_mx);
            }
        }
    }
}
for(var _i=0;_i<array_length(hazards);_i++) {
    var _h=hazards[_i],_t=tick+_h.phase;
    if(_h.kind=="pendulum") {
        _h.x=round(_h.bx+sin(_t*.035)*_h.range);
        _h.y=round(_h.by+sqrt(max(0,_h.range*_h.range-sqr(_h.x-_h.bx))));
    } else {
        _h.x=round(_h.bx+sin(_t*.03)*_h.range);
        if(_h.kind=="bat") _h.y=round(_h.by+sin(_t*.07)*18);
    }
    var _active=_h.kind!="blade" || (_t mod 150)>=50;
    if(_active && collision_rectangle(_h.x-10,_h.y-10,_h.x+10,_h.y+10,obj_player,false,true)!=noone) {
        with(_player) {
            if(respawn_invulnerability<=0) {
                player_take_damage(35);
                respawn_invulnerability=45;
            }
        }
    }
}
