varying vec2 v_vTexcoord;varying vec4 v_vColour;vec3 gb(vec3 c){
    vec3 q=vec3(6.,26.,11.)/255.;
    vec3 d=c-q;float best=dot(d,d);float n;vec3 p;
    p=vec3(10.,40.,14.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(15.,56.,15.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(29.,70.,27.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(40.,86.,37.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(48.,98.,48.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(60.,109.,46.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(75.,122.,50.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(92.,135.,53.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(111.,150.,56.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(127.,164.,58.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(139.,172.,15.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(149.,184.,64.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(155.,188.,15.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(173.,203.,98.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    p=vec3(197.,219.,135.)/255.;d=c-p;n=dot(d,d);if(n<best){q=p;best=n;}
    return q;
}void main(){vec4 c=v_vColour*texture2D(gm_BaseTexture,v_vTexcoord);gl_FragColor=vec4(gb(c.rgb),step(.5,c.a));}