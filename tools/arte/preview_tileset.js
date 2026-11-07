// Composição estática das mesmas células gravadas nas rooms, feita no LibreSprite.
var pc=app.pixelColor,atlasDoc=app.open('assets/tileset/cathedral_16.png'),atlas=atlasDoc.sprite.layer(0).cel(0).image;
for(var n=0;n<previewTileJobs.length;n++){
 var job=previewTileJobs[n],doc=app.open(job.source),spr=doc.sprite,img=spr.layer(0).cel(0).image;
 for(var row=0;row<34;row++)for(var col=0;col<120;col++){
  var index=job.tiles[row*120+col];if(index<0)continue;
  for(var y=0;y<16&&row*16+y<540;y++)for(var x=0;x<16;x++){
   var c=atlas.getPixel((index%64)*16+x,Math.floor(index/64)*16+y);
   if(pc.rgbaA(c))img.putPixel(col*16+x,row*16+y,c);
  }
 }
 spr.loadPalette('art/palette/gameboy-green-16.gpl');
 spr.saveAs('assets/tileset/scene_'+job.label+'.png',true);doc.close();
}
atlasDoc.close();
