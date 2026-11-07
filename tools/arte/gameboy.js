// Pixels escritos exclusivamente pelo LibreSprite batch.
var gb=[[15,56,15],[48,98,48],[139,172,15],[155,188,15]],pc=app.pixelColor;
function gbColor(c){var a=pc.rgbaA(c);for(var z=0;z<4;z++){var v=gb[z];if(pc.rgbaR(c)==v[0]&&pc.rgbaG(c)==v[1]&&pc.rgbaB(c)==v[2])return pc.rgba(v[0],v[1],v[2],a<128?0:255);}if(a<128)return pc.rgba(15,56,15,0);var l=(pc.rgbaR(c)*.2126+pc.rgbaG(c)*.7152+pc.rgbaB(c)*.0722)/255;var q=gb[l<.13?0:l<.32?1:l<.65?2:3];return pc.rgba(q[0],q[1],q[2],255);}
for(var j=0;j<gbJobs.length;j++){
 var d=app.open(gbJobs[j].source),s=d.sprite;
 if(gbJobs[j].palette){s.loadPalette(gbJobs[j].palette);}else{
 for(var k=0;k<s.layerCount;k++){var layer=s.layer(k);for(var f=0;f<layer.celCount;f++){var im=layer.cel(f).image;for(var y=0;y<im.height;y++)for(var x=0;x<im.width;x++)im.putPixel(x,y,gbColor(im.getPixel(x,y)));}}}
 s.saveAs(gbJobs[j].output,true);d.close();
}
