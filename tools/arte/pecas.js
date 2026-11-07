// Exportação de módulos em pixels inteiros. As peças usam origem superior esquerda.
var pc=app.pixelColor,C=[[15,56,15],[48,98,48],[139,172,15],[155,188,15]].map(function(v){return pc.rgba(v[0],v[1],v[2],255)}),clear=pc.rgba(15,56,15,0);
var srcDoc=app.open('assets/tileset/cathedral_16.png'),src=srcDoc.sprite.layer(0).cel(0).image;
var large=app.open('tools/arte/.work/pecas/canvas.png'),sheet=large.sprite,atlas=sheet.layer(0).cel(0).image;atlas.clear(clear);sheet.width=1024;sheet.height=1024;
for(var y=0;y<16;y++)for(var x=16;x<256;x++)atlas.putPixel(x,y,src.getPixel(x,y));
for(var i=0;i<pieces.length;i++){
 var m=pieces[i],n=m.name,w=m.w,h=m.h;
 for(var f=0;f<m.frames;f++){
  var d=app.open('assets/tileset/cathedral_16.png'),s=d.sprite,im=s.layer(0).cel(0).image;im.clear(clear);s.width=w;s.height=h;
  for(var y=0;y<h;y++)for(var x=0;x<w;x++){
   var off=m.frames===4?Math.round(Math.sin(f*Math.PI/2+y/16)*2*y/h):0;
   var xx=x-off;if(xx<0||xx>=w)continue;
   var c=src.getPixel(m.sx+Math.floor(xx*m.sw/w),m.sy+Math.floor(y*m.sh/h));
   var opaque=pc.rgbaA(c)>0;
   if(n.indexOf('pilar')===0&&opaque){if(x>w*.64&&c!==C[0])c=C[1];if((y<12||y>h-12)&&y%4===1)c=C[2];if(n==='pilar_2'&&x===10+Math.floor(y/8)%4)c=C[0];if(n==='pilar_partido'&&y<8+(x%9))c=clear;}
   if((n.indexOf('hera')===0||n==='trepadeiras'||n==='raiz_longa')&&y%18<3&&Math.abs(x-w*.5-4*Math.sin(y/8))<3)c=C[2];
   if(n.indexOf('plataforma_musgo')===0&&y>8&&y<24&&x%47>42)c=clear;
   if(n==='pedra_14'&&x<6&&y<8)c=clear;
   if(n==='pedra_15'&&x<8&&y>22)c=C[0];
   if(n.indexOf('arco')===0&&opaque){if((x+y*2)%29===0)c=C[0];if(n==='arco_pedra'&&x>48&&x<66&&y<33)c=clear;}
   if(n.indexOf('janela')===0&&opaque&&x>w*.18&&x<w*.77&&y>h*.25&&y<h*.86){if(c===C[2])c=C[3];if(x%20===0||((x+y)%41===0&&y<70))c=C[1];if(n==='janela_2'&&Math.abs(x-45)<(y%28)/3)c=clear;if(n==='janela_3'&&Math.abs(x-36-8*Math.sin(y/10))<2)c=C[1];}
   if(n.indexOf('grade_')===0&&opaque){if(n==='grade_partida'&&x>68&&x<104&&y<55-(x%9))c=clear;if(n==='grade_ferrugem'&&(x+y)%2===0&&y%22<9)c=C[1];}
   if(n.indexOf('estandarte')===0&&opaque){var v=Number(n.slice(-1));if(y>22&&y<38&&Math.abs(x-16)+Math.abs(y-30)===v+3)c=C[3];if(v===4&&y>h-14+Math.abs(x-13)%7)c=clear;if(v===5&&y>28)c=clear;}
   if(n.indexOf('urna')===0||n.indexOf('lapide')===0){if(opaque&&x>w*.68)c=C[1];if(opaque&&y>h*.35&&y<h*.57&&x===Math.floor(w*.44+y/6)%w)c=C[0];if(!opaque&&y>h-5&&x>w*.28&&x<w*.9)c=C[0];}
   if(n.indexOf('gargula')===0&&opaque&&x>w*.65&&c===C[2])c=C[1];
   if(n==='gargula_2'&&f===1&&y===29&&(x===28||x===35))c=C[3];
   if(n.indexOf('teia')===0){var X=n==='teia'?x:x-w/2-(f&&y>12?2:0),Y=n==='teia_pendente'?y-24:y-h/2;var r=Math.sqrt(X*X+Y*Y),a=Math.atan2(Y,X);if(n!=='teia')c=(r<22&&r>1&&(Math.abs(Math.sin(a*5))*r<2||Math.abs((r+2*Math.cos(a*5))%6)<1))?C[2]:clear;if(n==='teia_pendente'&&x===24&&y<24)c=C[1];if(f===1&&y>12&&n==='teia')c=xx>0?src.getPixel(m.sx+xx-1,m.sy+y):clear;}
   if(n.indexOf('porta_')===0&&x>10&&x<w-11&&y>16+Math.abs(x-w/2)*.35){c=n==='porta_aberta'?clear:n==='porta_luz'?C[x%16===1?3:2]:C[x%9===0||y%28===0?0:1];}
   if(n.indexOf('auto_')===0){var mask=Number(n.slice(5));c=C[(y%8===7||(x+(y>=8?8:0))%16===15)?1:2];if(!(mask&1)&&y<2)c=C[3];if(!(mask&2)&&x>13)c=C[0];if(!(mask&4)&&y>13)c=C[0];if(!(mask&8)&&x<2)c=C[1];}
   if(n.indexOf('fundo_')===0&&opaque)c=c===C[0]?C[0]:C[1];
   if(n==='passarela_fina'&&y>7)c=clear;
   im.putPixel(x,y,c);
  }
  if(f===0)for(var y=0;y<h;y++)for(var x=0;x<w;x++)atlas.putPixel(m.x+x,m.y+y,im.getPixel(x,y));
  s.loadPalette('art/palette/gb_green.gpl');s.saveAs('assets/pecas/'+n+'_'+f+'.png',true);d.close();
 }
}
sheet.loadPalette('art/palette/gb_green.gpl');sheet.saveAs('assets/pecas/atlas.png',true);sheet.saveAs('assets/pecas/atlas.aseprite',true);
