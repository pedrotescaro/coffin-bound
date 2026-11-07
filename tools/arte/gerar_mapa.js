// SPDX-License-Identifier: GPL-3.0-only
// Arte estática da fase: pixels escritos exclusivamente pelo LibreSprite.
// A room é lida, nunca modificada. Objetos de gameplay aparecem somente nas prévias.
var job=cryptMapJob,W=1920,H=540,pc=app.pixelColor;
var P=[[11,13,23],[28,25,45],[48,38,63],[75,54,87],[109,77,104],[152,115,138],[192,162,173],[229,210,208],[29,51,52],[49,83,78],[80,115,93],[127,166,106],[182,204,139],[233,237,197],[52,63,86],[82,103,129],[127,155,176],[182,203,210],[84,35,52],[136,63,76],[191,89,99],[227,141,130],[180,136,91],[241,201,128]],C=[];
for(var i=0;i<P.length;i++)C.push(pc.rgba(P[i][0],P[i][1],P[i][2],255));
var doc=app.open('tools/arte/.work/mapa/canvas.png'),spr=doc.sprite,img=spr.layer(0).cel(0).image;
img.clear(C[0]);spr.width=W;spr.height=H;
var tileDoc=app.open('assets/environment/crypt_tiles.png'),tiles=tileDoc.sprite.layer(0).cel(0).image;
var decorDoc=app.open('assets/environment/crypt_decor.png'),decor=decorDoc.sprite.layer(0).cel(0).image;
function pixel(x,y,c){x=Math.round(x);y=Math.round(y);if(x>=0&&x<W&&y>=0&&y<H)img.putPixel(x,y,c);}
function rect(x1,y1,x2,y2,c){for(var y=Math.max(0,y1);y<=Math.min(H-1,y2);y++)for(var x=Math.max(0,x1);x<=Math.min(W-1,x2);x++)pixel(x,y,c);}
function line(x1,y1,x2,y2,c){var dx=Math.abs(x2-x1),sx=x1<x2?1:-1,dy=-Math.abs(y2-y1),sy=y1<y2?1:-1,e=dx+dy;for(;;){pixel(x1,y1,c);if(x1===x2&&y1===y2)break;var e2=e*2;if(e2>=dy){e+=dy;x1+=sx;}if(e2<=dx){e+=dx;y1+=sy;}}}
function poly(points,c){var lo=H,hi=0;for(var n=0;n<points.length;n++){lo=Math.min(lo,points[n][1]);hi=Math.max(hi,points[n][1]);}for(var y=Math.max(0,lo);y<=Math.min(H-1,hi);y++)for(var x=Math.max(0,Math.floor(points[0][0]-400));x<Math.min(W,Math.ceil(points[0][0]+800));x++){var inside=false;for(var a=0,b=points.length-1;a<points.length;b=a++){var u=points[a],v=points[b];if((u[1]>y+.5)!==(v[1]>y+.5)&&x+.5<(v[0]-u[0])*(y+.5-u[1])/(v[1]-u[1])+u[0])inside=!inside;}if(inside)pixel(x,y,c);}}
function blit(source,sx,sy,sw,sh,dx,dy,clip){for(var y=0;y<sh;y++)for(var x=0;x<sw;x++){var xx=dx+x,yy=dy+y;if(xx<0||yy<0||xx>=W||yy>=H)continue;if(clip&&!mask[yy*W+xx])continue;var c=source.getPixel(sx+x,sy+y);if(pc.rgbaA(c))pixel(xx,yy,c);}}
function tile(index,x,y,clip){blit(tiles,(index%8)*16,Math.floor(index/8)*16,16,16,x,y,clip);}
function module(index,x,y){blit(decor,(index%4)*64,Math.floor(index/4)*96,64,96,x,y,false);}
function arch(cx,y,width,height){var bottom=y+height,half=width/2;poly([[cx-half,bottom],[cx-half,y+Math.floor(height*.34)],[cx-half+14,y+Math.floor(height*.19)],[cx-24,y+12],[cx,y],[cx+24,y+12],[cx+half-14,y+Math.floor(height*.19)],[cx+half,y+Math.floor(height*.34)],[cx+half,bottom]],C[2]);poly([[cx-half+8,bottom],[cx-half+8,y+Math.floor(height*.35)],[cx-half+22,y+Math.floor(height*.21)],[cx-20,y+23],[cx,y+12],[cx+20,y+23],[cx+half-22,y+Math.floor(height*.21)],[cx+half-8,y+Math.floor(height*.35)],[cx+half-8,bottom]],C[0]);}

// Alvenaria distante com contraste baixo e grandes vãos, sem ruído aleatório por pixel.
for(var y=0;y<H;y+=16)for(var x=0;x<W;x+=16)tile(48+((Math.floor(x/16)+Math.floor(y/16)*3)%16),x,y,false);
var bays=[[156,12,252,490],[474,18,252,510],[792,8,252,530],[1110,40,252,500],[1428,84,252,470],[1746,112,252,430]];
for(var b=0;b<bays.length;b++){var q=bays[b];arch(q[0],q[1],q[2],q[3]);var lx=q[0]-q[2]/2-14,rx=q[0]+q[2]/2+5;rect(lx,0,lx+8,H-1,C[1]);rect(rx,0,rx+8,H-1,C[1]);line(lx+9,10,lx+9,H-1,C[2]);line(rx-1,10,rx-1,H-1,C[2]);}
rect(0,12,W-1,15,C[2]);rect(0,18,W-1,21,C[1]);line(0,26,W-1,26,C[2]);

// Apoios escuros começam abaixo das plataformas: são fundo, não novas superfícies.
for(var r=0;r<job.solids.length;r++){var s=job.solids[r];if(s.object!=='obj_ground'||s.y<48||s.y>=497||s.h>160||s.w<64)continue;var cx=Math.floor(s.x+s.w/2),base=s.y+s.h;rect(cx-8,base,cx+7,H-1,C[1]);line(cx-9,base,cx-9,H-1,C[2]);line(cx+8,base,cx+8,H-1,C[2]);poly([[cx-22,base],[cx+22,base],[cx+8,base+24],[cx-8,base+24]],C[2]);line(cx-4,base+24,cx-4,H-1,C[2]);line(cx+3,base+24,cx+3,H-1,C[2]);for(var band=base+48;band<H;band+=48){rect(cx-9,band,cx+8,band+1,C[2]);line(cx-7,band+2,cx+6,band+2,C[1]);}}

// Arte arquitetônica ligada às cinco fontes de luz reais; demais decorações não emitem luz.
for(var l=0;l<job.lights.length;l++){var p=job.lights[l];module(0,p[0]-32,p[1]-48);module(1,p[0]-32,p[1]-48);}
module(4,148,112);module(4,558,36);module(4,1016,48);module(4,1444,176);
module(5,72,128);module(7,362,128);module(6,16,0);module(6,1090,110);module(6,1410,390);
module(0,752,48);module(7,758,48);module(0,1258,160);module(7,1258,160);module(0,1533,272);module(7,1533,272);
// Mausoléu final, situado atrás do caixão real (não incorporado ao PNG do cenário).
module(2,1760,336);module(0,1818,336);module(3,1818,336);module(2,1872,336);
module(5,1452,401);module(7,1696,401);

// União exata dos colisores: todas as faces recebem material, inclusive o piso inferior oculto.
var mask=[];for(var n=0;n<W*H;n++)mask.push(false);
for(var r=0;r<job.solids.length;r++){var s=job.solids[r];for(var y=Math.max(0,s.y);y<Math.min(H,s.y+s.h);y++)for(var x=Math.max(0,s.x);x<Math.min(W,s.x+s.w);x++)mask[y*W+x]=true;}
for(var y=0;y<H;y+=16)for(var x=0;x<W;x+=16){var h=(Math.floor(x/16)*7+Math.floor(y/16)*11)%23;var index=h===3?13:(h===8?7:(h%3===0?6:5));for(var yy=0;yy<16&&y+yy<H;yy++)for(var xx=0;xx<16&&x+xx<W;xx++)if(mask[(y+yy)*W+x+xx])pixel(x+xx,y+yy,C[14]);tile(index,x,y,true);}
// Grandes massas usam silhares48x24 e sombra progressiva, sem alta frequência no piso.
for(var b=0;b<job.solids.length;b++){var bulk=job.solids[b];if(bulk.h<96||bulk.w<32)continue;for(var y=Math.max(0,bulk.y+32);y<Math.min(H,bulk.y+bulk.h);y++)for(var x=Math.max(0,bulk.x);x<Math.min(W,bulk.x+bulk.w);x++){if(!mask[y*W+x])continue;var depth=y-bulk.y,row=Math.floor(y/24),offset=(row%2)*24,col=Math.floor((x+offset)/48),xx=(x+offset)%48,yy=y%24;var face=depth>112?1:(depth>48?2:14),mortar=depth>112?0:1,light=depth>112?2:(depth>48?14:15),shade=depth>112?0:1;var c=face;if(yy===23||xx===47)c=mortar;else if(yy===0)c=light;else if(xx===0)c=shade;else if((col*3+row)%11===2&&((xx===19&&yy>=7&&yy<=13)||(xx===20&&yy>=12&&yy<=15)))c=shade;pixel(x,y,C[c]);}}
// Cumes legíveis alinhados a cada borda física, com recorte para formas não múltiplas de16.
for(var y=0;y<H;y++){var x=0;while(x<W){if(mask[y*W+x]&&(y===0||!mask[(y-1)*W+x])){var start=x;while(x<W&&mask[y*W+x]&&(y===0||!mask[(y-1)*W+x]))x++;var end=x;for(var tx=start;tx<end;tx+=16){var index=tx===start?1:((tx+16>=end)?4:(((tx-start)/16)%2?2:3));for(var yy=0;yy<16&&y+yy<H;yy++)for(var xx=0;xx<16&&tx+xx<end;xx++){if(!mask[(y+yy)*W+tx+xx])continue;var c=tiles.getPixel((index%8)*16+xx,Math.floor(index/8)*16+yy);if(pc.rgbaA(c))pixel(tx+xx,y+yy,c);}}}else x++;}}
for(var y=0;y<H;y++)for(var x=0;x<W;x++)if(mask[y*W+x]){if(x===0||!mask[y*W+x-1])pixel(x,y,C[15]);if(x===W-1||!mask[y*W+x+1])pixel(x,y,C[1]);if(y===H-1||!mask[(y+1)*W+x])pixel(x,y,C[0]);}

spr.loadPalette('assets/palette/coffin-gothic-24.gpl');spr.saveAs('assets/environment/crypt_map.aseprite',true);spr.saveAs('assets/environment/crypt_map.png',true);
// Prévias de composição incluem instâncias existentes; o mapa usado no jogo NÃO as incorpora.
var sourceDocs=[];job.instances.sort(function(a,b){return b.depth-a.depth;});
for(var k=0;k<job.instances.length;k++){var o=job.instances[k];if(!o.source)continue;var sd=app.open(o.source);sourceDocs.push(sd);var si=sd.sprite.layer(0).cel(0).image;var sw=Math.round(si.width*Math.abs(o.sx)),sh=Math.round(si.height*Math.abs(o.sy));for(var y=0;y<sh;y++)for(var x=0;x<sw;x++){var sx=Math.floor(x/Math.abs(o.sx)),sy=Math.floor(y/Math.abs(o.sy));if(o.sx<0)sx=si.width-1-sx;if(o.sy<0)sy=si.height-1-sy;var c=si.getPixel(sx,sy);if(pc.rgbaA(c))pixel(Math.round(o.x-o.origin[0]*o.sx)+x,Math.round(o.y-o.origin[1]*o.sy)+y,c);}}
spr.saveAs('assets/environment/crypt_map_overview.png',true);
var snapshots=[['crypt_map_entrance.png',0,64],['crypt_map_nave.png',672,16],['crypt_map_crypt.png',1440,270]];
for(var k=0;k<snapshots.length;k++){var shot=snapshots[k],pixels=[];for(var y=0;y<270;y++)for(var x=0;x<480;x++)pixels.push(img.getPixel(shot[1]+x,shot[2]+y));var pd=app.open('tools/arte/.work/mapa/canvas.png'),ps=pd.sprite,pi=ps.layer(0).cel(0).image;pi.clear(C[0]);ps.width=480;ps.height=270;for(var y=0;y<270;y++)for(var x=0;x<480;x++)pi.putPixel(x,y,pixels[y*480+x]);ps.loadPalette('assets/palette/coffin-gothic-24.gpl');ps.saveAs('assets/environment/'+shot[0],true);pd.close();}
for(var k=0;k<sourceDocs.length;k++)sourceDocs[k].close();tileDoc.close();decorDoc.close();doc.close();console.log('Mapa catedral 1920x540 exportado; geometria original preservada, prévias estáticas separadas.');
