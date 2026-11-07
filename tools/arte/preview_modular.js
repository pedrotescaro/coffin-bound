var ad=app.open('assets/pecas/atlas.png'),atlas=ad.sprite.layer(0).cel(0).image,pc=app.pixelColor;
for(var n=0;n<rooms.length;n++){
 var room=rooms[n],doc=app.open('assets/environment/crypt_map.png'),s=doc.sprite,im=s.layer(0).cel(0).image;im.clear(pc.rgba(15,56,15,255));
 function blit(u,v,w,h,x,y,flip){for(var j=0;j<h;j++)for(var i=0;i<w;i++){if(x+i<0||x+i>=1920||y+j<0||y+j>=540)continue;var c=atlas.getPixel(u+(flip?w-1-i:i),v+j);if(pc.rgbaA(c))im.putPixel(x+i,y+j,c);}}
 for(var l=0;l<4;l++){
  for(var k=0;k<4080;k++){var index=room.grids[l][k];if(index<0)continue;var id=index&65535;blit(id%64*16,Math.floor(id/64)*16,16,16,k%120*16,Math.floor(k/120)*16,index!==id);}
  for(var a=0;a<room.anim.length;a++){var item=room.anim[a];if((item[3]==='Nave_Animada'?1:2)!==l)continue;var m=kit[item[0]];blit(m.x,m.y,m.w,m.h,item[1],item[2],false);}
 }
 var hazards=app.open('assets/challenges/challenge_atlas.png'),original=atlas;atlas=hazards.sprite.layer(0).cel(0).image;
 for(var j=0;j<room.pose.platforms.length;j++){var p=room.pose.platforms[j],base=p.kind==='moving'?3:p.kind==='falling'?6:0;for(var xx=0;xx<p.w;xx+=16){var id=base+(xx===0?0:(xx+16>=p.w?2:1));blit(id%8*32,Math.floor(id/8)*32,16,16,p.x+xx,p.y,false);}}
 for(var j=0;j<room.pose.hazards.length;j++){var h=room.pose.hazards[j],id={saw:20,pendulum:24,blade:28,bat:12,skeleton:16}[h.kind],hy=h.y;if(h.kind==='pendulum'){hy+=h.range;for(var y=h.y;y<hy;y++)im.putPixel(h.x,y,pc.rgba(48,98,48,255));}blit(id%8*32,Math.floor(id/8)*32,32,32,h.x-16,hy-16,false);}
 atlas=original;hazards.close();
 for(var j=0;j<room.props.length;j++){var o=room.props[j],pd=app.open(o.path),pi=pd.sprite.layer(0).cel(0).image;
 if(o.name==='obj_coffin'){var gate=kit.porta_fechada;blit(gate.x,gate.y,gate.w,gate.h,o.x-40,o.y-o.oy+pi.height-96,false);}
 for(var repeat=0;repeat<(o.name==='obj_spike'?o.sx:1);repeat++)for(var yy=0;yy<pi.height;yy++)for(var xx=0;xx<pi.width;xx++){var dx=o.x-o.ox+xx+repeat*16,dy=o.y+(o.sy<0?-yy-1:yy)-o.oy,c=pi.getPixel(xx,yy);if(dx>=0&&dx<1920&&dy>=0&&dy<540&&pc.rgbaA(c))im.putPixel(dx,dy,c);}
 pd.close();}
 s.saveAs('assets/pecas/cena_'+['entrada','nave','final'][n]+'.png',true);doc.close();
}
