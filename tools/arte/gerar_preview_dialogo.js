// Prévia estática original da interface; executar pelo LibreSprite --batch.
// A imagem não representa uma captura do jogo em execução.
var job = dialoguePreviewJob;
var pc = app.pixelColor;
var C={ink:pc.rgba(15,56,15,255),shade:pc.rgba(48,98,48,255),edge:pc.rgba(139,172,15,255),light:pc.rgba(155,188,15,255)};
var doc = app.open(job.canvas);
var spr = doc.sprite;
var img = spr.layer(0).cel(0).image;
img.clear(pc.rgba(0,0,0,0));
spr.width = 480;
spr.height = 270;
function pixel(x,y,c) { if(x>=0&&y>=0&&x<480&&y<270) img.putPixel(x,y,c); }
function rect(x1,y1,x2,y2,c) {
 for(var y=y1;y<=y2;y++) for(var x=x1;x<=x2;x++) pixel(x,y,c);
}
function line(x1,y1,x2,y2,c) {
 var dx=Math.abs(x2-x1),sx=x1<x2?1:-1,dy=-Math.abs(y2-y1),sy=y1<y2?1:-1,err=dx+dy;
 while(true) {
  pixel(x1,y1,c); if(x1===x2&&y1===y2)break;
  var e2=2*err;
  if(e2>=dy) {err+=dy;x1+=sx;}
  if(e2<=dx) {err+=dx;y1+=sy;}
 }
}
function frame(x,y,w,h,cut,fill,edge) {
 var right=x+w-1,bottom=y+h-1;
 rect(x,y+cut,right,bottom-cut,fill);
 for(var r=0;r<cut;r++) {
  line(x+cut-r,y+r,right-cut+r,y+r,fill);
  line(x+cut-r,bottom-r,right-cut+r,bottom-r,fill);
 }
 line(x+cut,y,right-cut,y,edge);line(right-cut,y,right,y+cut,edge);
 line(right,y+cut,right,bottom-cut,edge);line(right,bottom-cut,right-cut,bottom,edge);
 line(right-cut,bottom,x+cut,bottom,edge);line(x+cut,bottom,x,bottom-cut,edge);
 line(x,bottom-cut,x,y+cut,edge);line(x,y+cut,x+cut,y,edge);
}
function jewel(x,y,r,c) {
 for(var row=-r;row<=r;row++) {var span=r-Math.abs(row);line(x-span,y+row,x+span,y+row,c);}
}
var atlasDoc=app.open(job.atlas);
var atlas=atlasDoc.sprite.layer(0).cel(0).image;
function text(s,x,y,c) {
 var cursor=x;
 for(var i=0;i<s.length;i++) {
  var glyph=job.glyphs[String(s.charCodeAt(i))];
  if(!glyph)continue;
  for(var gy=0;gy<glyph.h;gy++) for(var gx=0;gx<glyph.w;gx++) {
   var a=pc.rgbaA(atlas.getPixel(glyph.x+gx,glyph.y+gy));
   if(a)pixel(cursor+glyph.offset+gx,y+gy,pc.rgba(pc.rgbaR(c),pc.rgbaG(c),pc.rgbaB(c),a));
  }
  cursor+=glyph.shift;
 }
}
function blit(path,x,y) {
 var sourceDoc=app.open(path),source=sourceDoc.sprite.layer(0).cel(0).image;
 for(var yy=0;yy<source.height;yy++)for(var xx=0;xx<source.width;xx++){
  var c=source.getPixel(xx,yy);if(pc.rgbaA(c))pixel(x+xx,y+yy,c);
 }
 sourceDoc.close();
}
function rule(x,y,w) {
 var mid=x+Math.floor(w/2);line(x+8,y,mid-6,y,C.edge);line(mid+6,y,x+w-8,y,C.edge);
 jewel(mid,y,3,C.light);jewel(x+2,y,2,C.edge);jewel(x+w-2,y,2,C.edge);
}
rect(0,0,479,269,C.ink);
blit(job.border,0,0);blit(job.title,106,35);rule(100,68,280);
text('PRÉVIA DA INTERFACE',159,78,C.light);rule(120,104,240);
blit(job.frame,26,132);blit(job.portrait,44,147);
frame(146,144,98,25,2,C.shade,C.shade);line(148,169,243,169,C.edge);
text('VAMPIRO',151,145,C.light);
text('A noite engoliu a trilha.',148,173,C.light);
text('Meu caixao deve estar adiante.',148,193,C.light);
text('CONTINUAR',162,232,C.light);text('ENTER / A',358,232,C.light);
jewel(151,242,2,C.light);line(148,242,154,242,C.edge);jewel(443,242,2,C.light);
spr.saveAs(job.output,true);
// Prévia do menu com save: o quinto item também deve caber no painel.
rect(0,0,479,269,C.ink);blit(job.forest,0,0);blit(job.border,0,0);
frame(86,16,308,55,4,C.ink,C.shade);blit(job.title,106,27);rule(100,64,280);
frame(106,74,268,23,3,C.ink,C.shade);
text('ENCONTRE SEU LUGAR NA NOITE.',123,75,C.light);
frame(278,105,174,125,4,C.ink,C.edge);frame(280,107,170,121,3,C.ink,C.shade);
var items=['CONTINUAR','NOVO JOGO','OPCOES','CREDITOS','SAIR'];
for(var i=0;i<items.length;i++){
 var y=109+i*23;if(i===0)rect(299,y+2,441,y+22,C.shade);
 text(items[i],306,y,i===0?C.light:C.edge);
}
jewel(290,120,3,C.light);frame(26,239,428,24,3,C.ink,C.shade);
text('SETAS: NAVEGAR   ENTER: CONFIRMAR',42,240,C.light);
spr.saveAs(job.menuOutput,true);
atlasDoc.close();doc.close();
