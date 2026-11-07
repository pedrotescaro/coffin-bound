/// @description Repete dentes de 16px; a máscara escalada da instância é preservada.
if (image_angle!=0) { draw_self(); exit; }
var _width=round(16*abs(image_xscale));
var _dir=sign(image_xscale);
for (var _offset=0; _offset<_width; _offset+=16) {
    var _part=min(16,_width-_offset);
    draw_sprite_part_ext(spr_spike,0,0,0,_part,16,
        round(x)+_offset*_dir,round(y),_dir,image_yscale,c_white,image_alpha);
}
