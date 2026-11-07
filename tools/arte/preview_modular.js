var ad=app.open('assets/pecas/atlas.png'),atlas=ad.sprite.layer(0).cel(0).image,pc=app.pixelColor;
for(var n=0;n<rooms.length;n++){
 var room=rooms[n];
 var poses=[{x:0,y:0,w:1920,h:540,suffix:''}];
 if(n===1)poses=poses.concat([{x:0,y:270,w:480,h:270,suffix:'_inicio'},{x:720,y:200,w:480,h:270,suffix:'_meio'},{x:1440,y:200,w:480,h:270,suffix:'_fim'}]);
 for(var vp=0;vp<poses.length;vp++){
 var pose=poses[vp],doc=app.open(pose.w===480?'assets/interface/menu_forest.png':'assets/environment/crypt_map.png'),s=doc.sprite,im=s.layer(0).cel(0).image;
 im.clear(pc.rgba(15,56,15,255));var offsetX=-pose.x,offsetY=-pose.y;
 function blit(u,v,w,h,x,y,flip){x+=offsetX;y+=offsetY;for(var j=0;j<h;j++)for(var i=0;i<w;i++){if(x+i<0||x+i>=pose.w||y+j<0||y+j>=pose.h)continue;var c=atlas.getPixel(u+(flip?w-1-i:i),v+j);if(pc.rgbaA(c))im.putPixel(x+i,y+j,c);}}
 var mainAtlas=atlas;
 for(var l=0;l<room.scene.length;l++){
  var layer=room.scene[l],rate={Fundo_Distante:.1,Pedra_Distante:.25,Nave_Media:.5,Nave_Animada:.5,Ornamentos_Proximos:.75}[layer.name];
  if(rate===undefined)rate=1;
  offsetX=-pose.x+Math.round(pose.x*(1-rate));offsetY=-pose.y+Math.round(pose.y*(1-rate));
  if(layer.kind==='background'){
   var pd=app.open(layer.path);atlas=pd.sprite.layer(0).cel(0).image;
   for(var y=-32;y<pose.h+32;y+=32)for(var x=-32;x<pose.w+32;x+=32){
    var ox=offsetX,oy=offsetY;offsetX=ox%32;offsetY=oy%32;blit(0,0,32,32,x,y,false);offsetX=ox;offsetY=oy;
   }
   pd.close();
  }else if(layer.kind==='tiles'){
   atlas=mainAtlas;
   for(var k=0;k<4080;k++){var id=layer.cells[k];if(!id)continue;blit(id%64*16,Math.floor(id/64)*16,16,16,k%120*16,Math.floor(k/120)*16,false);}
  }else{
   for(var a=0;a<layer.pieces.length;a++){var p=layer.pieces[a],pd=app.open(p.path);atlas=pd.sprite.layer(0).cel(0).image;blit(0,0,atlas.width,atlas.height,p.x,p.y,false);pd.close();}
  }
 }
 atlas=mainAtlas;offsetX=-pose.x;offsetY=-pose.y;
 var hazards=app.open('assets/challenges/challenge_atlas.png'),original=atlas;atlas=hazards.sprite.layer(0).cel(0).image;
 for(var j=0;j<room.pose.platforms.length;j++){var p=room.pose.platforms[j],base=p.kind==='moving'?3:p.kind==='falling'?6:0;for(var xx=0;xx<p.w;xx+=16){var id=base+(xx===0?0:(xx+16>=p.w?2:1));blit(id%8*32,Math.floor(id/8)*32,16,16,p.x+xx,p.y,false);}}
 for(var j=0;j<room.pose.hazards.length;j++){var h=room.pose.hazards[j],id={saw:20,pendulum:24,blade:28,bat:12,skeleton:16}[h.kind],hy=h.y;if(h.kind==='pendulum'){hy+=h.range;for(var y=h.y;y<hy;y++)((h.x+offsetX>=0&&h.x+offsetX<pose.w&&y+offsetY>=0&&y+offsetY<pose.h)?im.putPixel(h.x+offsetX,y+offsetY,pc.rgba(48,98,48,255)):null);}blit(id%8*32,Math.floor(id/8)*32,32,32,h.x-16,hy-16,false);}
 atlas=original;hazards.close();
 for(var j=0;j<room.props.length;j++){var o=room.props[j],pd=app.open(o.path),pi=pd.sprite.layer(0).cel(0).image;
 if(o.name==='obj_coffin'){var gate=kit.porta_fechada;blit(gate.x,gate.y,gate.w,gate.h,o.x-40,o.y-o.oy+pi.height-96,false);}
 for(var repeat=0;repeat<(o.name==='obj_spike'?o.sx:1);repeat++)for(var yy=0;yy<pi.height;yy++)for(var xx=0;xx<pi.width;xx++){var dx=o.x-o.ox+xx+repeat*16,dy=o.y+(o.sy<0?-yy-1:yy)-o.oy,c=pi.getPixel(xx,yy);if(dx+offsetX>=0&&dx+offsetX<pose.w&&dy+offsetY>=0&&dy+offsetY<pose.h&&pc.rgbaA(c))im.putPixel(dx+offsetX,dy+offsetY,c);}
 pd.close();}
 s.saveAs('assets/pecas/cena_'+['entrada','nave','final'][n]+pose.suffix+'.png',true);doc.close();
}
}
