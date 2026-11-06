// Paleta autoral Coffin Gothic 24. Executado dentro do LibreSprite.
var gothicPalette = [
 [11,13,23],[28,25,45],[48,38,63],[75,54,87],
 [109,77,104],[152,115,138],[192,162,173],[229,210,208],
 [29,51,52],[49,83,78],[80,115,93],[127,166,106],
 [182,204,139],[233,237,197],[52,63,86],[82,103,129],
 [127,155,176],[182,203,210],[84,35,52],[136,63,76],
 [191,89,99],[227,141,130],[180,136,91],[241,201,128]
];
var col = app.pixelColor;
var cache = {};
function nearest(c) {
 var r=col.rgbaR(c),g=col.rgbaG(c),b=col.rgbaB(c),a=col.rgbaA(c);
 if (!a) return col.rgba(0,0,0,0);
 var k=r+','+g+','+b;
 var found=cache[k];
 if (found === undefined) {
  var best=Infinity; found=0;
  for(var p=0;p<gothicPalette.length;p++) {
   var q=gothicPalette[p]; var dr=r-q[0],dg=g-q[1],db=b-q[2];
   var dist=dr*dr*2+dg*dg*3+db*db;
   if(dist<best) { best=dist;found=p; }
  }
  cache[k]=found;
 }
 var out=gothicPalette[found];return col.rgba(out[0],out[1],out[2],a);
}
// Recebe um job por PNG. app.open().sprite funciona no batch do LibreSprite 1.1.
function processGothic(job) {
 var doc=app.open(job.source); var spr=doc ? doc.sprite : app.activeSprite;
 if(!spr) throw new Error('Falha abrindo '+job.source);
 if(job.palette) {
  // PNGs indexados de referência preservam índices/alpha; troca-se só a paleta.
  spr.loadPalette(job.palette);
  spr.saveAs(job.output,true);
  doc.close();
  return;
 }
 for(var l=0;l<spr.layerCount;l++) {
  var layer=spr.layer(l);
  for(var f=0;f<layer.celCount;f++) {
   var cel=layer.cel(f); if(!cel)continue; var img=cel.image;
   var ow=img.width,oh=img.height,src=[];
   for(var y=0;y<oh;y++)for(var x=0;x<ow;x++)src.push(img.getPixel(x,y));
   var nw=job.width || ow,nh=job.height || oh;
   for(var y=0;y<oh;y++) for(var x=0;x<ow;x++) {
    var sx=x-(job.shift || 0),sy=y-(job.shift || 0),c=col.rgba(0,0,0,0);
    if(job.width) {sx=Math.floor(x*ow/nw);sy=Math.floor(y*oh/nh);}
    if(x<nw && y<nh && sx>=0 && sx<ow && sy>=0 && sy<oh)c=src[sy*ow+sx];
    img.putPixel(x,y,nearest(c));
   }
  }
 }
 // Somente vela: canvas reduzido após resampling nearest explícito dos pixels.
 if(job.width) {spr.width=job.width;spr.height=job.height;}
 spr.saveAs(job.output,true);
 doc.close();
 }
