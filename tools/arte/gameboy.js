// Pixels escritos exclusivamente pelo LibreSprite batch.
var gb=gbPalette,pc=app.pixelColor;
function gbColor(c){
 var alpha=pc.rgbaA(c)<128?0:255;if(!alpha)return pc.rgba(gb[0][0],gb[0][1],gb[0][2],0);
 var r=pc.rgbaR(c),g=pc.rgbaG(c),b=pc.rgbaB(c),best=0,distance=1e20;
 for(var i=0;i<gb.length;i++){
  var v=gb[i],dr=r-v[0],dg=g-v[1],db=b-v[2],d=dr*dr+dg*dg+db*db;
  if(d<distance){best=i;distance=d;}
 }
 var v=gb[best];return pc.rgba(v[0],v[1],v[2],alpha);
}
for(var j=0;j<gbJobs.length;j++){
 var d=app.open(gbJobs[j].source),s=d.sprite;
 if(gbJobs[j].palette){s.loadPalette(gbJobs[j].palette);}else{
 for(var k=0;k<s.layerCount;k++){var layer=s.layer(k);for(var f=0;f<layer.celCount;f++){var im=layer.cel(f).image;for(var y=0;y<im.height;y++)for(var x=0;x<im.width;x++)im.putPixel(x,y,gbColor(im.getPixel(x,y)));}}}
 s.saveAs(gbJobs[j].output,true);d.close();
}
