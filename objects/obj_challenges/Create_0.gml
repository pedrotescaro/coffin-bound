/// @description Estado local por room; reinício recupera plataformas caídas.
depth=75;
tick=0;
var _level=global.cb.level;
platforms=[];
add_platform=function(_x,_y,_w,_kind,_range,_speed) {
    array_push(platforms,{x:_x,y:_y,w:_w,bx:_x,by:_y,kind:_kind,range:_range,
        speed:_speed,timer:0,active:true,fall:0});
};
add_platform(272,400,64,"oneway",0,0);
if (_level>=1) {
    add_platform(352,368,80,"moving",96,0.025);
    add_platform(1328,304,48,"falling",0,0);
    add_platform(1424,272,48,"falling",0,0);
}
if (_level==2) {
    add_platform(448,320,48,"falling",0,0);
    add_platform(1664,304,48,"moving",56,0.035);
}
hazards=[];
add_hazard=function(_x,_y,_kind,_range,_phase) {
    array_push(hazards,{x:_x,y:_y,bx:_x,by:_y,kind:_kind,range:_range,phase:_phase});
};
add_hazard(1096,320,"saw",32,0);
if (_level>=1) {
    add_hazard(760,180,"pendulum",88,0);
    add_hazard(1460,240,"blade",48,60);
    add_hazard(1540,252,"bat",64,0);
    add_hazard(1268,(_level==2)?326:310,"skeleton",24,0);
}
if (_level==2) {
    add_hazard(540,304,"saw",54,40);
    add_hazard(1776,264,"pendulum",64,90);
    add_hazard(1648,232,"bat",64,75);
}
