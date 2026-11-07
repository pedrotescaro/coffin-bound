// SPDX-License-Identifier: GPL-3.0-only
// Adaptação da referência fornecida por Pedro; rasterização no LibreSprite --batch.
var pc=app.pixelColor,P=cathedralJob.palette,C=[];
for(var i=0;i<P.length;i++)C.push(pc.rgba(P[i][0],P[i][1],P[i][2],255));
var refDoc=app.open('art/reference/cathedral-detailed-reference.png'),ref=refDoc.sprite.layer(0).cel(0).image;
var doc,spr,img,W=1920,H=540,mask,solidOnly=false,airOnly=false;
function nearest(c){var r=pc.rgbaR(c),g=pc.rgbaG(c),b=pc.rgbaB(c),best=0,dist=1e20;
 for(var i=0;i<P.length;i++){var dr=r-P[i][0],dg=g-P[i][1],db=b-P[i][2],d=dr*dr+dg*dg+db*db;if(d<dist){dist=d;best=i;}}return best;}
// Cache de indices da referência, sem cores intermediárias no resultado.
var source=[],light=[];for(var y=0;y<288;y++)for(var x=0;x<1024;x++){
 var c=ref.getPixel(x,y);source.push(nearest(c));light.push(pc.rgbaR(c)*.2126+pc.rgbaG(c)*.7152+pc.rgbaB(c)*.0722);
}
function sample(x,y){x=Math.max(0,Math.min(1023,Math.floor(x)));y=Math.max(0,Math.min(287,Math.floor(y)));return source[y*1024+x];}
function pixel(x,y,c){x=Math.round(x);y=Math.round(y);if(x<0||y<0||x>=W||y>=H)return;
 if(solidOnly&&!mask[y*W+x])return;if(airOnly&&mask[y*W+x])return;img.putPixel(x,y,C[c]);}
function rect(x,y,w,h,c){for(var yy=y;yy<y+h;yy++)for(var xx=x;xx<x+w;xx++)pixel(xx,yy,c);}
function line(x,y,u,v,c){x=Math.round(x);y=Math.round(y);u=Math.round(u);v=Math.round(v);var dx=Math.abs(u-x),sx=x<u?1:-1,dy=-Math.abs(v-y),sy=y<v?1:-1,e=dx+dy;
 while(true){pixel(x,y,c);if(x===u&&y===v)break;var ee=e*2;if(ee>=dy){e+=dy;x+=sx;}if(ee<=dx){e+=dx;y+=sy;}}}
// Faces da imagem que representam antigas plataformas: ficam em recesso no fundo.
var recesses=[[0,237,112,51],[20,102,58,27],[273,187,68,29],[339,171,66,31],
 [430,171,48,31],[478,0,67,288],[557,171,52,31],[633,167,71,36],[801,145,73,36],
 [938,168,86,43],[385,73,92,25]];
function recessed(x,y){for(var i=0;i<recesses.length;i++){var r=recesses[i];if(x>=r[0]-1&&x<r[0]+r[2]+1&&y>=r[1]-2&&y<r[1]+r[3]+3)return true;}return false;}
// Molduras, raízes e janelas preservam os volumes da referência, sem novas superfícies.
for(var level=1;level<=3;level++){
 var job=cathedralJob.levels[level-1];
 doc=app.open('assets/environment/crypt_map.png');spr=doc.sprite;img=spr.layer(0).cel(0).image;
 spr.width=W;spr.height=H;img.clear(C[0]);
 mask=[];for(var n=0;n<W*H;n++)mask[n]=false;
 for(var i=0;i<job.solids.length;i++){
  var q=job.solids[i];for(var y=Math.max(0,q.y);y<Math.min(H,q.y+q.h);y++)for(var x=Math.max(0,q.x);x<Math.min(W,q.x+q.w);x++)mask[y*W+x]=true;
 }
 // A arte base é ampliada em 2x nearest: cada pixel de referência vira um cluster 2x2.
 for(var y=0;y<H;y++)for(var x=0;x<W;x++){
  var u=Math.floor(x/2),v=Math.floor(y/2);
  // Substitui a parede central da imagem por um trecho de arco em recesso.
  // Só as paredes descritas na room recebem alvenaria de primeiro plano.
  var bgU=(u>=478&&u<545)?u-118:u,c=sample(bgU,v);
  if(recessed(bgU,v)&&c>3)c=Math.max(3,Math.round(c*.55));
  else if(v>=244&&c>3)c=Math.max(3,c-2);
  else c=Math.min(c,12);
  pixel(x,y,c);
 }
 // Sombra projetada sob as plataformas reais, recortada ao espaço livre.
 airOnly=true;
 for(var i=0;i<job.solids.length;i++){
  var q=job.solids[i];if(q.w<32||q.h>80)continue;
  for(var d=0;d<14;d++)for(var x=q.x+4+d;x<q.x+q.w+9;x++){
   var y=q.y+q.h+d;if(d<5)pixel(x,y,0);else if((x+y)%2===0)pixel(x,y,1);
  }
 }
 airOnly=false;
 // Material da pedra deriva da referência; todas as faces seguem a geometria atual.
 solidOnly=true;
 var depth=[];
 for(var y=0;y<H;y++)for(var x=0;x<W;x++){
  var at=y*W+x;if(!mask[at]){depth[at]=0;continue;}
  var d=(y>0&&mask[at-W])?depth[at-W]+1:0;depth[at]=d;
  var u=485+(Math.floor(x/2)%44),v=20+(Math.floor(y/2)%48),c=sample(u,v);
  if(c>2)c=Math.min(14,c+3);
  if(d===0)c=13;else if(d===1)c=11;else if(d===2)c=5;
  if(x===0||!mask[at-1])c=(d===0)?13:9;
  if(x===W-1||!mask[at+1])c=1;
  if(y===H-1||!mask[at+W])c=1;
  pixel(x,y,c);
 }
 // Cornijas, facetas laterais e ornamentos nos extremos de cada plataforma baixa.
 for(var i=0;i<job.solids.length;i++){
  var q=job.solids[i];
  // Faces laterais em sombra: volumes verticais continuam legíveis até o fim.
  if(q.h>80&&q.w>0){
   for(var y=Math.max(0,q.y+4);y<Math.min(H,q.y+q.h-1);y++)for(var x=Math.max(0,q.x);x<Math.min(W,q.x+q.w);x++){
    var shadow=(q.h>128)?x>q.x+q.w-18:y>q.y+48;
    if(shadow){var c=nearest(img.getPixel(x,y));pixel(x,y,Math.max(1,c-3));}
   }
  }
  if(q.w<32||q.h<16||q.h>80)continue;
  for(var y=3;y<q.h-1;y++){
   pixel(q.x+1,q.y+y,4);pixel(q.x+2,q.y+y,10);
   pixel(q.x+q.w-2,q.y+y,1);pixel(q.x+q.w-3,q.y+y,3);
  }
  line(q.x+2,q.y+4,q.x+q.w-3,q.y+4,12);line(q.x+2,q.y+5,q.x+q.w-3,q.y+5,4);
  line(q.x+2,q.y+q.h-5,q.x+q.w-3,q.y+q.h-5,3);
  line(q.x+2,q.y+q.h-4,q.x+q.w-3,q.y+q.h-4,7);
  for(var e=0;e<2;e++){
   var cx=e?q.x+q.w-9:q.x+8;
   rect(cx-3,q.y+6,7,12,1);line(cx-2,q.y+7,cx+2,q.y+7,10);
   line(cx-2,q.y+8,cx-2,q.y+14,12);line(cx+2,q.y+8,cx+2,q.y+14,4);
   pixel(cx,q.y+10,15);pixel(cx-1,q.y+11,9);pixel(cx+1,q.y+11,9);pixel(cx,q.y+12,8);
   line(cx-2,q.y+16,cx+2,q.y+16,4);
  }
 }
 solidOnly=false;
 // Capitais e suportes esculpidos extraídos da referência; sempre atrás do piso real.
 airOnly=true;
 for(var i=0;i<job.solids.length;i++){
  var q=job.solids[i];if(q.w<48||q.h<16||q.h>80||q.y<240||q.y>450)continue;
  var cx=Math.round(q.x+q.w/2),top=q.y+q.h;
  for(var y=0;y<Math.min(176,H-top);y++)for(var x=0;x<60;x++){
   var c=sample(285+Math.floor(x/2),202+Math.floor(y/2));
   if(c===0)continue;
   c=Math.min(c,10);
   // A lateral do suporte fica em sombra, abaixo do topo jogável claro.
   if(y>28&&c>4&&x>42)c-=2;
   pixel(cx-30+x,top+y,c);
  }
  // Musgo pendente em pequenos grupos, sem desenhar pontas no topo de apoio.
  for(var x=6;x<q.w-5;x+=11){
   var drop=3+((x+i*5)%7);line(q.x+x,top-1,q.x+x-1,top+drop,6);
   pixel(q.x+x,top,10);pixel(q.x+x-2,top+drop-2,8);
  }
 }
 airOnly=false;
 // Túneis de morcego ficam escuros e vazios, sem detalhes que escondam a abertura.
 for(var i=0;i<job.solids.length;i++)for(var j=0;j<job.solids.length;j++){
  var a=job.solids[i],b=job.solids[j],gap=b.y-a.y-a.h;
  var left=Math.max(a.x,b.x),right=Math.min(a.x+a.w,b.x+b.w);
  if(gap>0&&gap<=24&&right-left>=32){airOnly=true;rect(left,a.y+a.h,right-left,gap,0);airOnly=false;}
 }
 spr.loadPalette('art/palette/gameboy-green-16.gpl');
 spr.saveAs('assets/environment/level'+level+'.png',true);
 spr.saveAs('assets/cathedral/level'+level+'.aseprite',true);
 // Prévias sem personagem/armadilhas: são artes, não capturas de gameplay.
 var shots=[['entrance',0,240],['nave',480,128],['gate',800,160],['crypt',1440,256]];
 for(var s=0;s<shots.length;s++){
  var shot=shots[s],pixels=[];
  for(var y=0;y<270;y++)for(var x=0;x<480;x++)pixels.push(img.getPixel(shot[1]+x,shot[2]+y));
  var pd=app.open('assets/environment/crypt_map.png'),ps=pd.sprite,pi=ps.layer(0).cel(0).image;
  ps.width=480;ps.height=270;
  for(var y=0;y<270;y++)for(var x=0;x<480;x++)pi.putPixel(x,y,pixels[y*480+x]);
  ps.loadPalette('art/palette/gameboy-green-16.gpl');ps.saveAs('assets/cathedral/level'+level+'_'+shot[0]+'.png',true);pd.close();
 }
 doc.close();
}
refDoc.close();
