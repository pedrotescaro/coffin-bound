// SPDX-License-Identifier: GPL-3.0-only
// Atlas modular alinhado em 16px, adaptado da referência no LibreSprite.
var pc=app.pixelColor,P=tileJob.palette,C=[];
for(var i=0;i<P.length;i++)C.push(pc.rgba(P[i][0],P[i][1],P[i][2],255));
var input=app.open('art/reference/cathedral-tileset-reference.png'),source=input.sprite.layer(0).cel(0).image;
var doc=app.open('assets/environment/crypt_map.png'),spr=doc.sprite,img=spr.layer(0).cel(0).image;
spr.width=1024;spr.height=512;img.clear(pc.rgba(6,26,11,0));
function nearest(c){var r=pc.rgbaR(c),g=pc.rgbaG(c),b=pc.rgbaB(c),best=0,dist=1e20;
 for(var i=0;i<P.length;i++){var v=P[i],dr=r-v[0],dg=g-v[1],db=b-v[2],d=dr*dr+dg*dg+db*db;if(d<dist){best=i;dist=d;}}return best;}
function px(x,y,c){if(x>=0&&y>=0&&x<1024&&y<512)img.putPixel(x,y,C[c]);}
function line(x,y,u,v,c){var dx=Math.abs(u-x),sx=x<u?1:-1,dy=-Math.abs(v-y),sy=y<v?1:-1,e=dx+dy;
 while(true){px(x,y,c);if(x===u&&y===v)break;var ee=2*e;if(ee>=dy){e+=dy;x+=sx;}if(ee<=dx){e+=dx;y+=sy;}}}
// Módulos separados: elimina o fundo verde uniforme e mantém clusters opacos.
for(var n=0;n<tileJob.modules.length;n++){
 var m=tileJob.modules[n];
 for(var y=0;y<m.h;y++)for(var x=0;x<m.w;x++){
  var c=nearest(source.getPixel(m.sx+Math.floor((x+.5)*m.sw/m.w),m.sy+Math.floor((y+.5)*m.sh/m.h)));
  if(m.transparent&&c<=2)continue;
  px(m.x+x,m.y+y,c);
 }
}
// Teia independente, com fios e anéis legíveis ao lado das gárgulas.
for(var y=256;y<320;y++)for(var x=864;x<912;x++)img.putPixel(x,y,pc.rgba(6,26,11,0));
var rays=[[44,0],[43,13],[35,30],[19,47],[0,52]];
for(var i=0;i<rays.length;i++)line(865,257,865+rays[i][0],257+rays[i][1],6);
for(var r=10;r<=42;r+=8)for(var i=0;i<rays.length-1;i++){
 var a=rays[i],b=rays[i+1];
 line(865+Math.round(a[0]*r/52),257+Math.round(a[1]*r/52),865+Math.round(b[0]*r/52),257+Math.round(b[1]*r/52),7);
 px(865+Math.round(a[0]*r/52),257+Math.round(a[1]*r/52),9);
}
// Primeira linha: peças técnicas para as superfícies reais das fases; tile0 vazio.
for(var index=1;index<=15;index++){
 var ox=index*16;
 for(var y=0;y<16;y++)for(var x=0;x<16;x++){
  if(index===13&&y<8)continue;if(index===14&&y>=8)continue;
  var wear=nearest(source.getPixel(175+(x+(index%3)*11)%61,69+y));
  var by=y%8,bx=(x+(y>=8?8:0))%16,c=9+(wear%3);
  if(by===0&&bx>1&&bx<14)c=12;
  else if(by===7)c=3;
  else if(by===6)c=6;
  if(bx===15)c=3;else if(bx===0)c=7;
  if(wear<3&&by>1&&by<5)c=7;
  var top=index<=3||index===13||index===14;
  var left=index===1||index===4||index===7,right=index===3||index===6||index===9;
  var bottom=index>=7&&index<=9;
  var first=index===13?8:0,last=index===14?7:15;
  if(top&&y===first)c=13;
  else if(top&&y===first+1)c=11;
  else if(top&&y===first+2)c=5;
  if(left&&x===0)c=4;else if(left&&x===1)c=10;
  if(right&&x===15)c=1;else if(right&&x===14)c=3;
  if(bottom&&y===15)c=1;
  if(index===10&&x===6+Math.floor(y/4))c=3;
  if(index===11&&y>7&&((x+2*y)%13)<3)c=6;
  if(index===12)c=Math.max(1,c-4);
  if(index===15&&y===0)c=13;
  px(ox+x,y,c);
 }
}
spr.loadPalette('art/palette/gameboy-green-16.gpl');
spr.saveAs('assets/tileset/cathedral_16.png',true);spr.saveAs('assets/tileset/cathedral_16.aseprite',true);
// Prévia de catálogo: mesmo atlas sobre fundo escuro, sem alterar o PNG transparente.
for(var y=0;y<512;y++)for(var x=0;x<1024;x++)if(pc.rgbaA(img.getPixel(x,y))===0)img.putPixel(x,y,C[0]);
spr.saveAs('assets/tileset/catalogue.png',true);doc.close();input.close();
