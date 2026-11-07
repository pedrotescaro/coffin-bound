varying vec2 v_vTexcoord;varying vec4 v_vColour;vec3 gb(vec3 c){
 vec3 q=vec3(15.,56.,15.)/255.;vec3 d=c-q;float best=dot(d,d);vec3 p;float n;
 p=vec3(48.,98.,48.)/255.;d=c-p;n=dot(d,d);if(n<best){best=n;q=p;}
 p=vec3(139.,172.,15.)/255.;d=c-p;n=dot(d,d);if(n<best){best=n;q=p;}
 p=vec3(155.,188.,15.)/255.;d=c-p;n=dot(d,d);if(n<best){best=n;q=p;}
return q;
}void main(){vec4 c=v_vColour*texture2D(gm_BaseTexture,v_vTexcoord);gl_FragColor=vec4(gb(c.rgb),step(.5,c.a));}