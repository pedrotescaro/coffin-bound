// LibreSprite --batch: referências fornecidas pelo autor, pixels sem interpolação.
var pc=app.pixelColor, colors=[[15,56,15],[48,98,48],[139,172,15],[155,188,15]];
var C=colors.map(function(c){return pc.rgba(c[0],c[1],c[2],255);});
var transparent=pc.rgba(15,56,15,0), doc, spr, img, W, H;
function nearest(c) {
 var best=0, distance=1e20;
 for(var i=0;i<4;i++) {
  var v=colors[i],r=pc.rgbaR(c)-v[0],g=pc.rgbaG(c)-v[1],b=pc.rgbaB(c)-v[2];
  var d=r*r+g*g+b*b;if(d<distance){distance=d;best=i;}
 }
 return C[best];
}
function canvas(w,h) {
 doc=app.open('assets/environment/crypt_map.png');spr=doc.sprite;
 img=spr.layer(0).cel(0).image;img.clear(transparent);spr.width=w;spr.height=h;W=w;H=h;
}
function px(x,y,c){if(x>=0&&y>=0&&x<W&&y<H)img.putPixel(x,y,c);}
function rect(x,y,w,h,c){for(var yy=y;yy<y+h;yy++)for(var xx=x;xx<x+w;xx++)px(xx,yy,c);}
function line(x,y,u,v,c){var dx=Math.abs(u-x),sx=x<u?1:-1,dy=-Math.abs(v-y),sy=y<v?1:-1,e=dx+dy;
 while(true){px(x,y,c);if(x===u&&y===v)break;var e2=2*e;if(e2>=dy){e+=dy;x+=sx;}if(e2<=dx){e+=dx;y+=sy;}}
}
function bevel(x,y,w,h,c){line(x+3,y,x+w-4,y,c);line(x+3,y,x,y+3,c);line(x,y+3,x,y+h-4,c);
 line(x,y+h-4,x+3,y+h-1,c);line(x+3,y+h-1,x+w-4,y+h-1,c);
 line(x+w-4,y+h-1,x+w-1,y+h-4,c);line(x+w-1,y+h-4,x+w-1,y+3,c);line(x+w-1,y+3,x+w-4,y,c);
}
function cross(x,y,c){rect(x-1,y-3,3,7,c);rect(x-3,y-1,7,3,c);}
function save(path){spr.loadPalette('art/palette/gameboy-green.gpl');spr.saveAs(path+'.png',true);spr.saveAs(path+'.aseprite',true);doc.close();}

// A floresta ocupa toda a GUI lógica; redução por amostragem nearest e paleta fixa.
var forestDoc=app.open('art/reference/menu-forest-reference.png'), forest=forestDoc.sprite.layer(0).cel(0).image;
canvas(480,270);
for(var y=0;y<270;y++)for(var x=0;x<480;x++)px(x,y,nearest(forest.getPixel(Math.floor((x+.5)*forest.width/480),Math.floor((y+.5)*forest.height/270))));
save('assets/interface/menu_forest');forestDoc.close();

// O retrato vem da segunda referência, sem incorporar texto ou moldura ao personagem.
var faceDoc=app.open('art/reference/dialogue-design-reference.png'),face=faceDoc.sprite.layer(0).cel(0).image;
canvas(88,96);
for(var y=0;y<96;y++)for(var x=0;x<88;x++)px(x,y,nearest(face.getPixel(96+Math.floor((x+.5)*187/88),313+Math.floor((y+.5)*204/96))));
save('assets/dialogue/vampire_portrait');faceDoc.close();

// Moldura sem texto: o conteúdo continua sendo composto pelo jogo.
canvas(428,126);rect(0,0,428,126,C[0]);
bevel(0,0,428,126,C[2]);bevel(2,2,424,122,C[1]);bevel(4,4,420,118,C[2]);
line(10,1,417,1,C[2]);line(10,124,417,124,C[2]);
cross(9,8,C[3]);cross(418,8,C[3]);cross(9,117,C[2]);cross(418,117,C[3]);
// Cantoneiras esculpidas e moldura larga do retrato.
rect(13,10,98,108,C[1]);bevel(12,9,100,110,C[2]);bevel(14,11,96,106,C[3]);bevel(16,13,92,102,C[2]);
for(var k=0;k<5;k++){
 rect(18+k*6,9,3,2,C[0]);rect(78+k*6,9,3,2,C[0]);
 rect(18+k*6,117,3,2,C[0]);rect(78+k*6,117,3,2,C[0]);
}
line(123,39,409,39,C[2]);line(123,40,409,40,C[1]);
// Florões nos cantos internos.
line(7,18,7,30,C[1]);line(7,30,10,30,C[1]);line(420,95,420,107,C[1]);line(417,95,420,95,C[1]);
save('assets/interface/dialogue_frame');

// Tijolos na borda, com centro transparente para preservar o cenário.
canvas(480,270);
for(var y=0;y<270;y+=8)for(var side=0;side<2;side++){
 var x=side?472:0;rect(x,y,8,7,C[0]);rect(x+1,y+1,6,5,C[1]);
 if((y/8)%3===0){rect(x+2,y+1,3,1,C[2]);px(x+1,y+5,C[0]);}
}
for(var x=8;x<472;x+=8){rect(x,0,7,7,C[0]);rect(x+1,0,5,6,C[1]);}
for(var y=262;y<270;y++)for(var x=8;x<472;x++)px(x,y,((x+y)%2)?C[1]:C[0]);
save('assets/interface/screen_border');

// Título desenhado em blocos inteiros, pixel a pixel (268x28).
var letters={
 C:['01111','10000','10000','10000','10000','10000','01111'],
 O:['01110','10001','10001','10001','10001','10001','01110'],
 F:['11111','10000','10000','11110','10000','10000','10000'],
 I:['111','010','010','010','010','010','111'],
 N:['10001','11001','11001','10101','10011','10011','10001'],
 B:['11110','10001','10001','11110','10001','10001','11110'],
 U:['10001','10001','10001','10001','10001','10001','01110'],
 D:['11110','10001','10001','10001','10001','10001','11110'],
 ' ':['000','000','000','000','000','000','000']
};
canvas(268,28);var word='COFFIN BOUND',cursor=0;
for(var i=0;i<word.length;i++){
 var glyph=letters[word.charAt(i)];
 for(var y=0;y<7;y++)for(var x=0;x<glyph[y].length;x++)if(glyph[y].charAt(x)==='1')rect(cursor+x*4,y*4,4,4,C[2]);
 cursor+=(glyph[0].length+1)*4;
}
save('assets/interface/title_coffin');
