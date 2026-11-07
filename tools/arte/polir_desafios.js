// SPDX-License-Identifier: GPL-3.0-only
// Desenho e exportação de pixels exclusivamente no LibreSprite --batch.
var pc=app.pixelColor,P=[[15,56,15],[48,98,48],[139,172,15],[155,188,15]],C=[];
for(var i=0;i<4;i++)C.push(pc.rgba(P[i][0],P[i][1],P[i][2],255));
var doc,spr,img,W,H,ox=0,oy=0,cw=0,ch=0;
function canvas(w,h,source){doc=app.open(source||'assets/environment/crypt_map.png');spr=doc.sprite;img=spr.layer(0).cel(0).image;if(!source)img.clear(pc.rgba(15,56,15,0));spr.width=w;spr.height=h;W=w;H=h;cell(0,0,w,h);}
function cell(x,y,w,h){ox=x;oy=y;cw=w;ch=h;}
function px(x,y,c){x=Math.round(x);y=Math.round(y);if(x>=0&&y>=0&&x<cw&&y<ch&&ox+x>=0&&oy+y>=0&&ox+x<W&&oy+y<H)img.putPixel(ox+x,oy+y,C[c]);}
function rect(x,y,w,h,c){for(var yy=y;yy<y+h;yy++)for(var xx=x;xx<x+w;xx++)px(xx,yy,c);}
function line(x,y,u,v,c){x=Math.round(x);y=Math.round(y);u=Math.round(u);v=Math.round(v);var dx=Math.abs(u-x),sx=x<u?1:-1,dy=-Math.abs(v-y),sy=y<v?1:-1,e=dx+dy;
 while(true){px(x,y,c);if(x===u&&y===v)break;var ee=2*e;if(ee>=dy){e+=dy;x+=sx;}if(ee<=dx){e+=dx;y+=sy;}}
}
function poly(points,c){for(var y=0;y<ch;y++)for(var x=0;x<cw;x++){
 var inside=false;for(var a=0,b=points.length-1;a<points.length;b=a++){
  var u=points[a],v=points[b];if((u[1]>y+.5)!==(v[1]>y+.5)&&x+.5<(v[0]-u[0])*(y+.5-u[1])/(v[1]-u[1])+u[0])inside=!inside;
 }if(inside)px(x,y,c);
}}
function ellipse(x,y,rx,ry,c){for(var yy=-ry;yy<=ry;yy++)for(var xx=-rx;xx<=rx;xx++)if(xx*xx/(rx*rx)+yy*yy/(ry*ry)<=1)px(x+xx,y+yy,c);}
function save(name){spr.loadPalette('art/palette/gameboy-green.gpl');spr.saveAs('assets/challenges/'+name+'.png',true);spr.saveAs('assets/challenges/'+name+'.aseprite',true);doc.close();}
function slot(n){cell((n%8)*32,Math.floor(n/8)*32,32,32);}

// Três famílias de peças modulares: passarela, mecanismo móvel e pedra frágil.
function platform(kind,edge,cracked){
 rect(0,0,16,8,0);rect(0,0,16,1,3);rect(0,1,16,2,2);rect(1,3,14,3,1);
 line(0,6,15,6,0);line(1,5,14,5,2);
 if(kind===0){
  for(var x=2;x<16;x+=6){rect(x,3,3,1,2);px(x+1,4,0);}
  poly([[1,7],[7,7],[6,10],[4,12]],0);poly([[9,7],[15,7],[12,12],[10,10]],0);
  line(2,7,4,10,2);line(13,7,12,10,1);px(4,8,3);px(12,8,2);
 }else if(kind===1){
  rect(0,3,16,5,1);line(0,7,15,7,0);line(0,4,15,4,2);
  for(var x=3;x<16;x+=8){rect(x-1,4,3,3,0);px(x,4,3);px(x,6,2);}
  poly([[0,8],[16,8],[13,12],[3,12]],0);line(3,9,12,9,1);
  poly([[8,7],[11,10],[8,13],[5,10]],2);px(8,9,3);px(8,11,1);
 }else{
  rect(0,3,16,5,2);line(0,7,15,7,1);line(8,3,8,6,0);
  poly([[0,8],[16,8],[14,12],[11,11],[9,15],[6,12],[2,13]],0);
  poly([[1,8],[15,8],[13,11],[10,10],[9,13],[6,10],[3,11]],1);
  line(2,8,5,8,2);line(10,8,13,8,2);px(8,10,2);px(9,12,2);
  line(5,2,6,4,0);line(6,4,4,6,0);px(7,4,3);
  if(cracked){line(10,0,9,3,0);line(9,3,11,5,0);line(11,5,9,8,0);line(9,8,9,11,0);px(11,1,3);px(12,6,3);}
 }
 if(edge===0){line(0,1,0,7,0);line(1,2,1,5,3);px(2,6,2);}
 if(edge===2){line(15,1,15,7,0);line(14,2,14,5,1);px(13,6,2);}
}
canvas(256,160);
for(var k=0;k<3;k++)for(var e=0;e<3;e++){slot(k*3+e);platform(k,e,false);}
for(var e=0;e<3;e++){slot(9+e);platform(2,e,true);}

// Morcego hostil: membranas recortadas, dedos, orelhas e olhos claros.
for(var f=0;f<4;f++){
 slot(12+f);var wing=[5,10,19,11][f];
 for(var side=0;side<2;side++){
  var wingPoints=[[14,14],[8,wing+1],[2,wing-2],[3,wing+8],[6,wing+5],[8,wing+10],[11,wing+7],[14,20]];
  if(side)for(var j=0;j<wingPoints.length;j++)wingPoints[j][0]=31-wingPoints[j][0];
  poly(wingPoints,0);
  function xx(x){return side?31-x:x;}
  poly([[xx(13),15],[xx(4),wing+1],[xx(5),wing+6],[xx(7),wing+4],[xx(9),wing+8],[xx(12),18]],1);
  line(xx(13),14,xx(3),wing,2);line(xx(12),15,xx(5),wing+5,1);line(xx(12),16,xx(8),wing+8,1);
  line(xx(8),wing+2,xx(9),wing+5,2);px(xx(4),wing+1,3);
 }
 ellipse(16,17,5,7,0);ellipse(16,18,3,5,1);line(14,20,17,22,2);
 poly([[11,15],[11,7],[16,13],[20,7],[21,16]],0);line(12,10,13,13,2);line(19,10,18,13,2);
 rect(12,14,8,5,1);line(13,14,14,15,2);line(18,15,19,14,2);
 px(14,16,3);px(18,16,3);rect(15,18,3,1,0);px(15,19,3);px(17,19,3);
 line(14,23,13,25,2);line(18,23,19,25,2);
}

// Esqueleto patrulheiro: crânio, costelas, ombreiras e quatro poses de caminhada.
for(var f=0;f<4;f++){
 slot(16+f);var bob=(f===1||f===3)?1:0,walk=[-2,0,2,0][f];
 ellipse(16,8+bob,6,6,0);rect(12,5+bob,9,6,2);line(13,3+bob,18,3+bob,3);rect(12,5+bob,4,1,3);
 rect(11,7+bob,3,3,0);rect(17,7+bob,3,3,0);px(12,7+bob,1);px(18,7+bob,1);
 px(16,10+bob,0);rect(13,11+bob,6,3,3);px(14,12+bob,0);px(17,12+bob,0);
 line(16,14+bob,16,21,0);line(15,14+bob,15,20,2);
 rect(10,14+bob,13,2,0);line(11,14+bob,13,14+bob,2);line(19,14+bob,21,14+bob,2);
 for(var r=0;r<3;r++){line(12,16+r*2,19,16+r*2,0);line(12,15+r*2,19,15+r*2,2);px(13,15+r*2,3);}
 line(11,16,9-walk,20,0);line(10,16,8-walk,20,2);line(8-walk,20,10-walk,23,2);px(10-walk,23,3);
 line(22,16,23+walk,20,0);line(21,16,22+walk,20,2);line(22+walk,20,20+walk,23,2);
 rect(12,21,8,3,0);line(12,21,19,21,1);px(15,22,3);
 line(14,23,12+walk,27,0);line(13,23,11+walk,26,2);line(17,23,20-walk,27,0);line(17,23,19-walk,26,2);
 rect(9+walk,27,5,2,0);rect(9+walk,27,4,1,2);rect(18-walk,27,5,2,0);rect(19-walk,27,3,1,2);
}

// Serras em poses discretas: a imagem não sofre rotação fracionária no Draw.
function gear(frame,mace,blade){
 if(mace){
  // Machado duplo do pêndulo: silhueta distinta das rodas dentadas.
  rect(14,2,5,27,0);rect(15,3,2,24,1);line(15,4,15,24,2);
  for(var side=0;side<2;side++){
   function mx(x){return side?32-x:x;}
   poly([[mx(14),7],[mx(10),5],[mx(7),6],[mx(4),10],[mx(3),16],[mx(4),22],[mx(9),26],[mx(13),27],[mx(14),23],[mx(11),21],[mx(10),17],[mx(11),12],[mx(14),11]],0);
   poly([[mx(10),7],[mx(6),10],[mx(5),16],[mx(6),21],[mx(11),25],[mx(10),20],[mx(9),16],[mx(11),11]],2);
   line(mx(6),11,mx(5),16,3);line(mx(5),17,mx(6),21,3);line(mx(7),22,mx(10),24,1);
  }
  rect(13,13,7,5,0);rect(14,14,5,3,1);px(16,14,3);px(16,16,2);
  if(frame===1||frame===3)px(7,10,3);
  return;
 }
 if(blade){
  for(var i=0;i<4;i++){
   var a=frame*Math.PI/8+i*Math.PI/2;
   poly([[16+Math.cos(a-.5)*3,16+Math.sin(a-.5)*3],[16+Math.cos(a-.3)*14,16+Math.sin(a-.3)*14],
    [16+Math.cos(a+.05)*12,16+Math.sin(a+.05)*12],[16+Math.cos(a+.8)*6,16+Math.sin(a+.8)*6]],0);
   poly([[16+Math.cos(a-.35)*4,16+Math.sin(a-.35)*4],[16+Math.cos(a-.25)*12,16+Math.sin(a-.25)*12],
    [16+Math.cos(a+.05)*10,16+Math.sin(a+.05)*10],[16+Math.cos(a+.5)*6,16+Math.sin(a+.5)*6]],2);
   line(16+Math.cos(a-.25)*7,16+Math.sin(a-.25)*7,16+Math.cos(a-.25)*12,16+Math.sin(a-.25)*12,3);
  }
  ellipse(16,16,5,5,0);ellipse(16,16,3,3,1);px(15,15,3);px(17,17,2);return;
 }
 var angle=frame*Math.PI/8,count=blade?4:8;
 for(var i=0;i<count;i++){
  var a=angle+i*Math.PI*2/count,r=13;
  poly([[16+Math.cos(a-.35)*7,16+Math.sin(a-.35)*7],
   [16+Math.cos(a)*r,16+Math.sin(a)*r],
   [16+Math.cos(a+.26)*12,16+Math.sin(a+.26)*12],
   [16+Math.cos(a+.5)*7,16+Math.sin(a+.5)*7]],0);
  line(16+Math.cos(a)*10,16+Math.sin(a)*10,16+Math.cos(a)*12,16+Math.sin(a)*12,3);
  line(16+Math.cos(a+.15)*7,16+Math.sin(a+.15)*7,16+Math.cos(a+.15)*11,16+Math.sin(a+.15)*11,2);
 }
 ellipse(16,16,9,9,0);ellipse(16,16,8,8,mace?1:2);
 for(var y=10;y<23;y++)for(var x=10;x<23;x++)if((x-16)*(x-16)+(y-16)*(y-16)<49&&((x+y)%2===0)&&x+y>33)px(x,y,1);
 line(12,10,17,9,3);line(10,12,10,16,3);line(19,22,22,19,1);
 if(mace){line(13,10,13,21,2);line(19,10,19,21,0);line(14,10,14,20,3);}
 ellipse(16,16,4,4,0);ellipse(16,16,2,2,1);px(15,15,3);px(17,17,2);
 if(blade){line(16,10,16,12,3);line(16,20,16,22,3);}
}
for(var f=0;f<4;f++){slot(20+f);gear(f,false,false);slot(24+f);gear(f,true,false);slot(28+f);gear(f,false,true);}
for(var warn=0;warn<2;warn++){
 slot(32+warn);ellipse(16,16,10,10,0);ellipse(16,16,8,8,1);
 line(11,10,21,10,2);line(10,11,10,20,2);line(21,12,21,20,0);line(12,22,20,22,0);
 for(var i=0;i<4;i++){var x=11+i*3;line(x,12,x,20,0);px(x,12,2);}
 if(warn){poly([[16,11],[20,16],[16,21],[12,16]],2);px(16,14,3);line(16,15,16,17,0);px(16,19,0);}
}
save('challenge_atlas');

// Espinhos 16x16: pontas metálicas facetadas e base rebitada (mesmo bbox de antes).
canvas(16,16);cell(0,0,16,16);
rect(0,13,16,3,0);rect(0,13,16,1,2);line(0,15,15,15,1);
poly([[0,13],[8,2],[16,13]],0);
poly([[2,12],[8,5],[14,12]],2);poly([[8,5],[14,12],[8,12]],1);
line(8,4,1,12,3);line(8,6,8,12,2);
px(8,2,3);px(8,3,3);px(2,14,3);px(8,14,1);px(14,14,3);
save('spike');

// Revestimento das plataformas fixas, estritamente dentro da união dos colisores.
for(var level=1;level<=3;level++){
 var job=challengeArtJob.levels[level-1];canvas(1920,540,'assets/environment/level'+level+'.png');
 var mask=[],depth=[];for(var n=0;n<1920*540;n++){mask[n]=false;depth[n]=0;}
 for(var s=0;s<job.solids.length;s++){
  var q=job.solids[s];for(var y=Math.max(0,q.y);y<Math.min(H,q.y+q.h);y++)for(var x=Math.max(0,q.x);x<Math.min(W,q.x+q.w);x++)mask[y*W+x]=true;
 }
 for(var y=0;y<H;y++)for(var x=0;x<W;x++)if(mask[y*W+x]){
  var at=y*W+x,d=(y>0&&mask[at-W])?depth[at-W]+1:0;depth[at]=d;
  var row=Math.floor(y/10),bx=(x+(row%2)*12)%24,by=y%10;
  var dark=d>56,base=dark?1:2,highlight=dark?2:3,c=base;
  if(by===9||bx===23)c=0;
  else if(by===8||bx===22)c=1;
  else if(by===0&&bx>1&&bx<21)c=highlight;
  else if(bx===0)c=1;
  if((Math.floor((x+(row%2)*12)/24)+row*3)%7===2&&bx===9+Math.floor(by/3)&&by>2&&by<8)c=1;
  if(d===0)c=3;
  else if(d===1||d===2)c=2;
  else if(d===3)c=0;
  if(x===0||!mask[at-1])c=(d===0)?3:1;
  if(x===W-1||!mask[at+1])c=0;
  if(y===H-1||!mask[at+W])c=0;
  px(x,y,c);
 }
 // Cornijas e peças de canto esculpidas, sempre dentro do retângulo físico.
 for(var s=0;s<job.solids.length;s++){
  var q=job.solids[s];if(q.w<32||q.h<16||q.h>64)continue;
  cell(q.x,q.y,q.w,q.h);
  var bottom=q.h-5;
  rect(1,bottom,q.w-2,2,1);line(2,bottom,q.w-3,bottom,2);
  for(var edge=0;edge<2;edge++){
   var cx=edge?q.w-8:7;
   rect(cx-2,5,5,10,0);line(cx-2,5,cx+2,5,3);line(cx-2,6,cx-2,12,2);
   poly([[cx,7],[cx+2,10],[cx,13],[cx-2,10]],2);px(cx,9,3);
   line(cx-2,14,cx+2,14,1);
  }
  // Musgo em pequenas placas laterais, sem confundir-se com as pontas de metal.
  for(var m=18;m<q.w-12;m+=37){rect(m,6,4,2,1);px(m+1,8,1);px(m+2,6,2);}
  px(1,3,0);px(q.w-2,3,0);
 }
 cell(0,0,W,H);
 spr.loadPalette('art/palette/gameboy-green.gpl');spr.saveAs('assets/environment/level'+level+'.png',true);
 spr.saveAs('assets/challenges/level'+level+'_stone.aseprite',true);doc.close();
}
console.log('Arte de desafios exportada: plataformas modulares, inimigos animados, mecanismos e espinhos.');

// Prévias estáticas para revisão de arte, sem simular o runner.
var atlasDoc=app.open('assets/challenges/challenge_atlas.png'),atlas=atlasDoc.sprite.layer(0).cel(0).image;
var spikeDoc=app.open('assets/challenges/spike.png'),spike=spikeDoc.sprite.layer(0).cel(0).image;
var fontDoc=app.open('fonts/fnt_monogram/fnt_monogram.png'),font=fontDoc.sprite.layer(0).cel(0).image;
function blit(source,sx,sy,w,h,x,y,scale){
 for(var yy=0;yy<h;yy++)for(var xx=0;xx<w;xx++){
  var c=source.getPixel(sx+xx,sy+yy);if(!pc.rgbaA(c))continue;
  for(var zy=0;zy<scale;zy++)for(var zx=0;zx<scale;zx++){
   var dx=x+xx*scale+zx,dy=y+yy*scale+zy;if(dx>=0&&dy>=0&&dx<W&&dy<H)img.putPixel(dx,dy,c);
  }
 }
}
function tile(index,x,y,w,h,scale){blit(atlas,(index%8)*32,Math.floor(index/8)*32,w,h,x,y,scale||1);}
function text(word,x,y){for(var i=0;i<word.length;i++){
 var g=challengeArtJob.glyphs[String(word.charCodeAt(i))];if(!g)continue;
 for(var yy=0;yy<g.h;yy++)for(var xx=0;xx<g.w;xx++)if(pc.rgbaA(font.getPixel(g.x+xx,g.y+yy)))px(x+g.offset+xx,y+yy,3);
 x+=g.shift;
}}
canvas(480,270);rect(0,0,480,270,0);
text('PASSARELA',24,15);text('MOVEL',200,15);text('FRAGIL',360,15);
for(var k=0;k<3;k++)for(var i=0;i<6;i++)tile(k*3+(i===0?0:i===5?2:1),24+k*160+i*16,42,16,16,1);
line(16,74,463,74,1);
var names=['MORCEGO','ESQUELETO','SERRA','PENDULO','LAMINA'];
var types=[13,18,21,25,29];
for(var i=0;i<5;i++){tile(types[i],16+i*94,103,32,32,2);text(names[i],16+i*94,174);}
line(16,200,463,200,1);text('ESPINHOS',24,209);
for(var i=0;i<8;i++)blit(spike,0,0,16,16,24+i*32,236,2);
text('AVISO',354,209);tile(32,350,236,32,32,1);tile(33,408,236,32,32,1);
spr.saveAs('assets/challenges/preview_sheet.png',true);doc.close();

var bgDoc=app.open('assets/environment/level2.png'),bg=bgDoc.sprite.layer(0).cel(0).image;
canvas(480,270);blit(bg,1184,128,480,270,0,0,1);
for(var p=0;p<2;p++)for(var i=0;i<4;i++)tile(6+(i===0?0:i===3?2:1),(p?1424:1328)-1184+i*16,(p?288:320)-128,16,16,1);
tile(18,1248-1184-16,310-128-16,32,32,1);tile(13,1540-1184-16,252-128-16,32,32,1);tile(29,1460-1184-16,240-128-16,32,32,1);
var spikes=challengeArtJob.levels[1].spikes;
for(var i=0;i<spikes.length;i++)for(var x=0;x<spikes[i].w;x+=16)blit(spike,0,0,16,16,spikes[i].x-1184+x,spikes[i].y-128,1);
spr.saveAs('assets/challenges/preview_scene.png',true);doc.close();bgDoc.close();
fontDoc.close();spikeDoc.close();atlasDoc.close();
