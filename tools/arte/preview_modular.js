var ad=app.open('assets/pecas/atlas.png'),atlas=ad.sprite.layer(0).cel(0).image,pc=app.pixelColor;
for(var n=0;n<rooms.length;n++){
 var room=rooms[n],doc=app.open('assets/environment/crypt_map.png'),s=doc.sprite,im=s.layer(0).cel(0).image;im.clear(pc.rgba(15,56,15,255));
 function blit(u,v,w,h,x,y,flip){for(var j=0;j<h;j++)for(var i=0;i<w;i++){if(x+i<0||x+i>=1920||y+j<0||y+j>=540)continue;var c=atlas.getPixel(u+(flip?w-1-i:i),v+j);if(pc.rgbaA(c))im.putPixel(x+i,y+j,c);}}
 for(var l=0;l<4;l++){
  for(var k=0;k<4080;k++){var index=room.grids[l][k];if(index<0)continue;var id=index&65535;blit(id%64*16,Math.floor(id/64)*16,16,16,k%120*16,Math.floor(k/120)*16,index!==id);}
  for(var a=0;a<room.anim.length;a++){var item=room.anim[a];if((item[3]==='Nave_Animada'?1:2)!==l)continue;var m=kit[item[0]];blit(m.x,m.y,m.w,m.h,item[1],item[2],false);}
 }
 s.saveAs('assets/pecas/cena_'+['entrada','nave','final'][n]+'.png',true);doc.close();
}
