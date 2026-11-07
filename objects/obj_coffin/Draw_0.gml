var _distance = distance_to_object(obj_player);
var _door = spr_mod_porta_fechada;
if (_distance < 88) _door = spr_mod_porta_aberta;
if (sprite_index == spr_coffin_open || _distance < 32) _door = spr_mod_porta_luz;
draw_sprite(_door,0,round(x)-40,bbox_bottom-95);
draw_self();
