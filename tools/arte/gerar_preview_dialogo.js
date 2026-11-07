// Prévia estática original da interface; executar pelo LibreSprite --batch.
// A imagem não representa uma captura do jogo em execução.
var job = dialoguePreviewJob;
var pc = app.pixelColor;
function rgb(r,g,b) { var l=(r*.2126+g*.7152+b*.0722)/255;var a=[[15,56,15],[48,98,48],[139,172,15],[155,188,15]][l<.13?0:l<.32?1:l<.65?2:3];return pc.rgba(a[0],a[1],a[2],255); }
var C = {
 ink:rgb(11,13,23),plate:rgb(28,25,45),shadow:rgb(48,38,63),
 line:rgb(75,54,87),edge:rgb(109,77,104),bone:rgb(233,237,197),
 muted:rgb(152,115,138),ruby:rgb(191,89,99),gold:rgb(180,136,91),
 glint:rgb(241,201,128)
};
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
rect(0,0,479,269,C.ink);
text('COFFIN BOUND',190,38,C.gold);
text('PREVIA DA INTERFACE',159,66,C.muted);
line(148,96,331,96,C.shadow);jewel(240,96,2,C.ruby);
frame(18,143,448,118,6,C.ink,C.ink);
frame(16,140,448,118,6,C.ink,C.edge);
frame(18,142,444,114,5,C.plate,C.shadow);
line(29,144,451,144,C.gold);line(29,253,451,253,C.gold);
jewel(24,148,2,C.ruby);jewel(455,148,2,C.ruby);jewel(24,249,2,C.ruby);jewel(455,249,2,C.ruby);
pixel(24,147,C.glint);pixel(455,147,C.glint);
frame(22,150,92,100,3,C.ink,C.gold);
line(30,242,30,173,C.shadow);line(30,173,68,155,C.shadow);line(68,155,105,173,C.shadow);line(105,173,105,242,C.shadow);
line(34,242,34,177,C.line);line(34,177,68,161,C.line);line(68,161,101,177,C.line);line(101,177,101,242,C.line);
var portraitDoc=app.open(job.portrait);
var portrait=portraitDoc.sprite.layer(0).cel(0).image;
for(var py=0;py<96;py++) for(var px=0;px<88;px++) {
 var c=portrait.getPixel(px,py);if(pc.rgbaA(c))pixel(24+px,152+py,c);
}
line(122,158,122,241,C.line);jewel(122,153,2,C.gold);jewel(122,246,2,C.gold);
frame(128,148,98,25,3,C.shadow,C.line);text('VAMPIRO',134,151,C.glint);
line(134,176,443,176,C.line);line(134,176,157,176,C.ruby);
text('A noite engoliu a trilha.',134,181,C.bone);
text('Meu caixao deve estar adiante.',134,201,C.bone);
line(134,230,443,230,C.line);
text('CONTINUAR',134,235,C.muted);text('ENTER / A',344,235,C.bone);jewel(441,244,2,C.glint);
spr.saveAs(job.output,true);
portraitDoc.close();atlasDoc.close();doc.close();
