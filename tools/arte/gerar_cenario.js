// SPDX-License-Identifier: GPL-3.0-only
// Arte original de cripta: todos os pixels são desenhados dentro do LibreSprite.
var palette = [[15, 56, 15], [15, 56, 15], [48, 98, 48], [48, 98, 48], [139, 172, 15], [139, 172, 15], [155, 188, 15], [155, 188, 15], [48, 98, 48], [48, 98, 48], [139, 172, 15], [139, 172, 15], [155, 188, 15], [155, 188, 15], [48, 98, 48], [139, 172, 15], [139, 172, 15], [155, 188, 15], [48, 98, 48], [48, 98, 48], [139, 172, 15], [139, 172, 15], [139, 172, 15], [155, 188, 15]];
var colors=[],pc=app.pixelColor;
for(var i=0;i<palette.length;i++)colors.push(pc.rgba(palette[i][0],palette[i][1],palette[i][2],255));
var doc,sprite,img,W,H,ox=0,oy=0,cw=0,ch=0;
function canvas(w,h){
 doc=app.open('sprites/s_background/f03ddb17-a0c4-4c9d-a5d9-477a8f246711.png');
 if(!doc || !doc.sprite)throw new Error('Canvas RGBA indisponivel');
 sprite=doc.sprite;img=sprite.layer(0).cel(0).image;img.clear(pc.rgba(0,0,0,0));
 sprite.width=w;sprite.height=h;W=w;H=h;ox=0;oy=0;cw=w;ch=h;
}
function cell(x,y,w,h){ox=x;oy=y;cw=w;ch=h;}
function clearCell(){for(var y=0;y<ch;y++)for(var x=0;x<cw;x++)img.putPixel(ox+x,oy+y,pc.rgba(0,0,0,0));}
function dot(x,y,c){x=Math.round(x);y=Math.round(y);if(x>=0&&y>=0&&x<cw&&y<ch)img.putPixel(ox+x,oy+y,colors[c]);}
function box(x0,y0,x1,y1,c){for(var y=y0;y<=y1;y++)for(var x=x0;x<=x1;x++)dot(x,y,c);}
function line(x0,y0,x1,y1,c){
 var dx=Math.abs(x1-x0),sx=x0<x1?1:-1,dy=-Math.abs(y1-y0),sy=y0<y1?1:-1,e=dx+dy;
 for(;;){dot(x0,y0,c);if(x0===x1&&y0===y1)break;var e2=e*2;if(e2>=dy){e+=dy;x0+=sx;}if(e2<=dx){e+=dx;y0+=sy;}}
}
function poly(p,c){
 var ymin=ch,ymax=0;
 for(var j=0;j<p.length;j++){ymin=Math.min(ymin,p[j][1]);ymax=Math.max(ymax,p[j][1]);}
 for(var y=ymin;y<=ymax;y++)for(var x=0;x<cw;x++){
  var inside=false;
  for(var a=0,b=p.length-1;a<p.length;b=a++){
   var v=p[a],u=p[b];
   if((v[1]>y+.5)!==(u[1]>y+.5)&&x+.5<(u[0]-v[0])*(y+.5-v[1])/(u[1]-v[1])+v[0])inside=!inside;
  }
  if(inside)dot(x,y,c);
 }
}
function ellipse(cx,cy,rx,ry,c){for(var y=cy-ry;y<=cy+ry;y++)for(var x=cx-rx;x<=cx+rx;x++)if((x-cx)*(x-cx)/(rx*rx)+(y-cy)*(y-cy)/(ry*ry)<=1)dot(x,y,c);}
function save(name){sprite.loadPalette('art/palette/gameboy-green.gpl');sprite.saveAs('assets/environment/'+name+'.aseprite',true);sprite.saveAs('assets/environment/'+name+'.png',true);doc.close();}

// Tijolos esculpidos em clusters: bordas gastas e juntas alternadas, sem ruído.
function brick(v,dark){
 var base=dark?1:14,face=dark?2:15,light=dark?3:16,joint=dark?0:1;
 box(0,0,15,15,base);
 for(var row=0;row<3;row++){
  var y=row*6,shift=((row+v)%2)*7;
  for(var k=-1;k<3;k++){
   var x=k*14+shift;
   box(x+1,y+1,x+12,y+4,face);line(x+2,y,x+10,y,base);
   line(x,y,x,y+4,joint);line(x+1,y+5,x+13,y+5,joint);
   line(x+3,y+1,x+7,y+1,light);
   if((row+k+v)%3===0){line(x+10,y+2,x+11,y+3,base);dot(x+10,y+4,joint);}
  }
 }
 if(!dark){box(2+(v%3)*3,8,4+(v%3)*3,9,14);line(10,13,13,13,14);}
}
function top(v,left,right){
 brick(v,false);box(0,0,15,4,14);box(0,0,15,1,16);
 line(0,0,15,0,17);line(0,4,15,4,1);line(0,3,15,3,15);
 if(v%2===0){line(3,0,5,0,15);dot(8,1,17);box(11,1,12,2,15);}
 else {line(8,0,10,0,15);box(2,1,3,2,17);dot(13,1,15);}
 if(left){box(0,0,1,15,1);line(2,1,2,15,15);line(2,0,15,0,17);dot(1,1,16);}
 if(right){box(14,0,15,15,1);line(13,1,13,15,14);line(0,0,13,0,17);dot(14,1,16);}
}
function moss(x,y){
 box(x,y,x+5,y+1,8);box(x+1,y-1,x+3,y,9);box(x+2,y-2,x+3,y-1,10);
 dot(x+1,y-2,11);line(x+5,y,x+6,y+3,9);dot(x+6,y+4,10);dot(x+3,y,11);
}
function tile(n){cell((n%8)*16,Math.floor(n/8)*16,16,16);}
canvas(128,128);
for(var n=1;n<64;n++){tile(n);brick(n,n>=24);}
tile(1);top(0,true,false);tile(2);top(0,false,false);tile(3);top(1,false,false);tile(4);top(1,false,true);
tile(5);brick(0,false);tile(6);brick(1,false);
tile(7);brick(2,false);moss(4,5);moss(11,13);
tile(8);brick(0,false);box(0,0,1,15,1);line(2,0,2,15,16);line(3,0,3,15,15);
tile(9);brick(1,false);box(14,0,15,15,1);line(13,0,13,15,14);
tile(10);brick(0,false);box(0,14,15,15,1);line(2,0,2,12,16);line(2,13,15,13,14);
tile(11);brick(1,false);box(0,14,15,15,1);line(0,13,15,13,14);
tile(12);brick(0,false);box(0,14,15,15,1);box(14,0,15,15,1);line(0,13,13,13,14);
tile(13);brick(2,false);line(7,0,7,4,1);line(7,4,4,7,1);line(4,7,6,10,1);line(6,10,6,15,1);line(8,1,8,4,14);dot(5,7,16);
for(var n=14;n<=16;n++){
 tile(n);
 box(0,0,15,15,0);box(0,0,15,6,14);line(0,0,15,0,17);line(0,1,15,1,16);line(0,4,15,4,15);line(0,7,15,7,1);
 if(n===14){box(0,0,1,15,0);line(2,1,2,5,16);poly([[3,6],[15,6],[12,10],[6,10]],2);}
 else if(n===16){box(14,0,15,15,0);poly([[0,6],[13,6],[10,10],[3,10]],2);}
 else {poly([[0,6],[15,6],[12,10],[2,10]],2);line(3,8,11,8,3);}
}
tile(17);box(0,0,15,15,0);box(0,1,15,4,16);line(0,0,15,0,17);box(2,5,13,8,14);box(4,9,11,15,15);line(4,9,4,15,16);line(11,9,11,15,14);
tile(18);box(0,0,15,15,0);box(4,0,11,15,15);line(4,0,4,15,16);line(6,0,6,15,14);line(10,0,10,15,14);line(11,0,11,15,1);line(8,2,8,12,16);
tile(19);box(0,0,15,15,0);box(4,0,11,7,15);line(4,0,4,7,16);box(2,8,13,11,14);box(0,12,15,15,15);line(0,12,15,12,16);line(0,15,15,15,1);
tile(20);clearCell();moss(1,3);moss(8,8);moss(4,13);
tile(21);brick(0,false);poly([[8,2],[12,6],[8,12],[4,6]],1);line(8,3,11,6,22);line(11,6,8,11,22);line(8,11,5,6,14);dot(8,6,23);
tile(22);brick(1,false);box(2,2,13,13,1);for(var x=4;x<=12;x+=3){line(x,3,x,12,14);line(x,3,x,4,16);}line(2,13,13,13,0);
tile(23);brick(2,true);line(1,1,14,1,3);line(1,1,1,14,3);line(1,14,14,14,0);line(14,1,14,14,0);
tile(24);brick(0,true);tile(25);brick(1,true);tile(26);brick(2,true);
tile(27);brick(2,false);poly([[10,0],[15,0],[15,6],[13,4],[12,5],[10,3]],1);line(8,1,9,3,16);line(9,3,12,5,14);
tile(28);brick(0,true);moss(3,5);moss(9,12);
tile(29);clearCell();line(4,0,7,5,8);line(7,5,5,12,9);line(5,12,7,15,8);line(7,6,11,4,9);box(10,3,12,4,10);dot(11,2,11);line(5,11,2,9,9);dot(1,8,10);
tile(30);clearCell();for(var y=0;y<16;y+=6){box(7,y,9,y+4,14);box(8,y+1,8,y+3,0);dot(7,y,16);line(8,y+4,8,y+6,3);}
tile(31);brick(1,false);box(4,4,11,11,1);poly([[8,3],[12,8],[8,12],[3,8]],14);line(7,5,9,5,16);dot(6,6,17);dot(9,9,3);
// Demais células oferecem variações discretas de corpo/ruína para montagem futura.
for(var n=32;n<64;n++){
 tile(n);brick(n%3,n>=48);
 if(n%4===0){line(8,0,8,3,0);line(8,3,5,6,0);dot(5,7,0);}
 if(n%5===0)moss(3,5);
 if(n%7===0){box(2,11,4,12,n>=48?2:14);line(11,2,13,2,n>=48?3:16);}
}
save('crypt_tiles');

// Arquitetura de fundo: valores contidos deixam as bordas jogáveis mais claras.
canvas(256,192);
function module(n){cell((n%4)*64,Math.floor(n/4)*96,64,96);}
function lancet(x0,y0,x1,y1,fill,edge){
 var cx=Math.floor((x0+x1)/2),spring=y0+Math.floor((x1-x0)*.48);
 poly([[x0,y1],[x0,spring],[x0+4,spring-8],[cx,y0],[x1-4,spring-8],[x1,spring],[x1,y1]],fill);
 line(x0,y1,x0,spring,edge);line(x0,spring,x0+4,spring-8,edge);line(x0+4,spring-8,cx,y0,edge);
 line(cx,y0,x1-4,spring-8,edge);line(x1-4,spring-8,x1,spring,edge);line(x1,spring,x1,y1,edge);
}
function masonryColumn(x,y,w,h){
 box(x,y,x+w-1,y+h-1,1);box(x+2,y,x+w-3,y+h-1,2);line(x+2,y,x+2,y+h-1,3);
 for(var sy=y+7;sy<y+h-2;sy+=11){line(x+1,sy,x+w-2,sy,0);line(x+3,sy+1,x+w-4,sy+1,3);}
}
function archFrame(){
 lancet(5,4,58,94,1,0);lancet(8,7,55,94,2,14);lancet(13,14,50,94,0,3);
 masonryColumn(5,39,9,52);masonryColumn(50,39,9,52);
 box(2,90,17,94,1);line(3,90,16,90,14);box(47,90,61,94,1);line(48,90,60,90,14);
 line(12,32,31,13,3);line(31,13,50,32,3);
 poly([[27,7],[31,3],[36,8],[34,14],[29,14]],3);line(30,6,32,5,14);
 line(16,22,20,25,0);line(22,15,25,18,0);line(39,16,43,19,0);line(46,25,50,23,0);
}
module(0);archFrame();
// Recorte interno preto pontuado por degraus de pedra no fundo do arco.
box(17,88,46,92,1);line(17,88,46,88,2);line(21,84,43,84,1);line(25,80,40,80,1);
module(1);archFrame();
lancet(16,18,47,87,18,0);
poly([[20,38],[31,23],[31,55],[20,65]],19);poly([[34,22],[43,37],[43,60],[34,52]],19);
poly([[21,69],[30,58],[31,83],[20,83]],19);poly([[35,57],[44,67],[44,83],[35,83]],19);
poly([[25,44],[31,35],[37,44],[31,56]],20);poly([[27,44],[31,39],[33,44],[31,50]],21);
line(31,22,31,84,22);line(34,24,34,84,3);line(19,64,44,64,22);line(20,66,44,66,0);
line(18,43,31,58,3);line(31,58,46,43,3);line(19,79,31,66,3);line(31,66,44,79,3);
line(20,37,31,22,22);line(33,22,44,37,22);line(16,87,47,87,14);line(20,84,43,84,3);
dot(27,42,23);dot(32,50,23);dot(40,73,20);dot(24,76,20);
module(2);
box(15,9,49,14,0);box(17,10,47,13,3);line(18,10,46,10,14);
poly([[17,14],[47,14],[43,23],[21,23]],2);line(20,15,44,15,14);box(21,22,43,28,1);
box(23,27,41,84,1);box(25,27,38,84,2);line(25,28,25,82,3);line(29,30,29,81,14);line(31,31,31,81,1);line(36,30,36,81,3);
for(var y=36;y<80;y+=16){line(24,y,40,y,0);line(26,y+1,38,y+1,3);}
poly([[23,83],[41,83],[44,88],[20,88]],2);box(16,88,48,94,1);line(18,88,46,88,14);line(16,94,48,94,0);
poly([[29,17],[32,15],[35,18],[32,22]],22);dot(31,17,23);
line(37,63,35,68,0);line(35,68,37,72,0);
module(3);archFrame();
for(var x=19;x<=45;x+=6){
 var top=36-Math.floor((1-Math.abs(x-32)/16)*12);
 line(x,top,x,90,14);line(x+1,top+2,x+1,90,1);
 poly([[x,top-5],[x-2,top],[x+2,top]],3);dot(x,top-3,15);
}
box(16,53,48,55,2);line(16,53,48,53,14);box(16,78,48,80,2);line(16,78,48,78,14);
box(30,53,35,61,0);box(31,54,34,60,22);box(32,56,33,58,1);dot(31,54,23);
module(4);
box(5,8,58,11,0);line(6,8,57,8,14);line(8,9,55,9,3);ellipse(6,9,3,3,2);ellipse(57,9,3,3,2);dot(5,8,15);dot(56,8,15);
poly([[15,13],[49,13],[49,68],[45,78],[39,75],[33,86],[27,77],[20,80],[15,69]],0);
poly([[17,14],[47,14],[47,67],[43,74],[38,72],[33,81],[28,73],[21,76],[17,67]],18);
poly([[19,15],[25,15],[25,68],[22,73],[19,66]],19);poly([[38,15],[44,15],[44,66],[40,72],[38,69]],19);
line(18,15,46,15,22);line(18,17,18,64,22);line(46,17,46,64,22);line(27,17,27,67,0);line(36,18,36,69,0);
// Emblema de morcego em metal antigo; símbolo gráfico, sem função de jogo.
poly([[31,34],[19,29],[22,39],[27,39],[31,45],[35,40],[41,40],[45,29],[34,34]],22);
poly([[30,35],[24,33],[27,37],[30,37],[32,41],[34,37],[37,37],[40,33],[34,35]],18);
box(31,32,33,40,22);dot(31,31,23);dot(33,31,23);dot(32,35,23);
line(20,60,23,61,19);line(39,62,43,60,19);dot(22,67,20);line(28,72,30,75,19);
module(5);
// Agrupamento assimétrico de lápides esculpidas e vegetação baixa.
poly([[3,93],[3,66],[6,59],[13,57],[20,62],[22,93]],0);
poly([[5,92],[5,66],[8,61],[13,59],[18,63],[20,92]],2);line(7,65,8,63,14);line(6,67,6,89,3);
line(10,68,16,68,0);line(11,71,17,71,0);line(9,80,17,80,1);
poly([[21,94],[21,49],[25,43],[33,41],[41,45],[45,52],[45,94]],0);
poly([[23,92],[23,50],[27,45],[33,43],[39,47],[42,53],[42,92]],14);
poly([[26,90],[26,52],[29,48],[33,46],[37,49],[39,54],[39,90]],2);
line(33,50,33,65,1);line(29,55,37,55,1);line(28,73,37,73,1);line(29,76,37,76,1);line(28,80,35,80,1);dot(25,51,15);
poly([[44,94],[44,70],[48,63],[54,62],[59,67],[61,94]],0);
poly([[46,92],[46,71],[49,66],[54,64],[57,68],[59,92]],3);line(48,70,48,89,14);line(50,73,56,73,1);line(51,77,56,77,1);
line(35,46,34,50,1);line(34,50,36,54,1);line(36,54,34,58,1);
for(var x=0;x<64;x+=10){line(x,95,x+3,88,8);line(x+3,88,x+6,92,9);dot(x+2,89,10);}
module(6);
// Vinhas de teto: raízes grossas recortadas e folhas agrupadas nos nós.
line(4,0,9,14,2);line(5,0,10,14,3);line(9,14,6,29,2);line(6,29,13,42,2);line(13,42,11,60,2);line(11,60,18,73,2);line(18,73,17,92,1);
line(9,14,19,20,8);line(19,20,24,34,9);line(24,34,29,39,8);line(6,29,0,36,8);line(13,42,24,46,8);line(24,46,31,60,8);
line(58,0,53,14,2);line(53,14,56,28,3);line(56,28,49,43,2);line(49,43,51,59,2);line(51,59,44,72,2);line(44,72,46,91,1);
line(53,14,44,20,8);line(44,20,40,32,9);line(49,43,38,48,8);line(38,48,34,62,8);
for(var n=0;n<10;n++){
 var x=n%2===0?10+(n*7)%19:42+(n*5)%15,y=11+n*7;
 poly([[x,y],[x+4,y-2],[x+3,y+2],[x+1,y+3]],9);line(x+1,y,x+3,y-1,10);dot(x+2,y-1,11);
}
line(14,1,19,5,8);line(19,5,24,4,8);line(44,1,39,6,8);dot(24,3,10);dot(40,4,10);
module(7);
// Urna funerária com aros e grupo de cristais frios de contraste contido.
ellipse(20,88,15,4,0);box(10,86,30,91,2);line(11,87,29,87,14);
poly([[10,57],[31,57],[33,65],[30,79],[26,87],[15,87],[10,77],[8,65]],0);
poly([[12,59],[29,59],[30,65],[27,78],[24,84],[16,84],[12,75],[10,66]],14);
poly([[14,61],[20,61],[18,79],[16,82],[13,74]],15);poly([[23,61],[28,61],[28,69],[24,81],[22,82]],2);
box(10,54,31,58,2);line(11,54,30,54,15);box(13,51,28,53,1);ellipse(21,50,9,3,3);line(15,49,25,49,14);
line(10,62,5,59,2);line(5,59,3,65,2);line(3,65,9,73,2);line(31,62,36,59,2);line(36,59,38,65,2);line(38,65,31,73,2);
poly([[18,66],[21,63],[24,67],[21,73]],22);poly([[19,67],[21,65],[22,68],[21,71]],18);dot(20,66,23);
poly([[38,94],[37,78],[42,68],[48,78],[46,94]],1);poly([[39,92],[39,79],[42,72],[43,81],[42,92]],15);poly([[43,81],[46,79],[45,92],[42,92]],14);line(42,73,42,83,16);
poly([[47,94],[46,68],[52,54],[59,67],[56,94]],0);poly([[49,91],[48,69],[52,59],[53,72],[52,91]],15);poly([[53,72],[57,69],[55,91],[52,91]],14);line(52,60,52,74,16);dot(51,64,17);
poly([[54,95],[56,83],[61,77],[63,88],[61,95]],1);poly([[56,93],[58,84],[61,81],[60,89],[59,93]],15);line(58,85,60,82,16);
line(36,95,63,95,1);box(39,93,42,95,2);box(50,93,55,95,2);
save('crypt_decor');
console.log('Cenario original exportado no LibreSprite: crypt_tiles128x128 e crypt_decor256x192.');
