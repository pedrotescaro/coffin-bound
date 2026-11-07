// Adaptação nearest do retrato da referência escolhida, escrita no LibreSprite.
var pc=app.pixelColor, palette=[[15,56,15],[48,98,48],[139,172,15],[155,188,15]];
function nearest(c) {
 var best=0,distance=1e20;
 for(var i=0;i<4;i++){
  var v=palette[i],r=pc.rgbaR(c)-v[0],g=pc.rgbaG(c)-v[1],b=pc.rgbaB(c)-v[2];
  var d=r*r+g*g+b*b;if(d<distance){best=i;distance=d;}
 }
 var v=palette[best];return pc.rgba(v[0],v[1],v[2],255);
}
var refDoc=app.open('art/reference/dialogue-design-reference.png'),ref=refDoc.sprite.layer(0).cel(0).image;
var doc=app.open('assets/dialogue/vampire_portrait.png'),spr=doc.sprite,img=spr.layer(0).cel(0).image;
for(var y=0;y<96;y++)for(var x=0;x<88;x++)
 img.putPixel(x,y,nearest(ref.getPixel(96+Math.floor((x+.5)*187/88),313+Math.floor((y+.5)*204/96))));
spr.loadPalette('art/palette/gameboy-green.gpl');
spr.saveAs('assets/dialogue/vampire_portrait.png',true);spr.saveAs('assets/dialogue/vampire_portrait.aseprite',true);
refDoc.close();doc.close();
