// Executa a matemática e o End Step GML. O runner e a inspeção visual são separados.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const read = p => fs.readFileSync(path.join(root, p), 'utf8');
const kernel = read('scripts/cb_camera/cb_camera.gml');
const step = read('objects/obj_camera/Step_2.gml');
function camera() {
  const p = {bbox_left:230,bbox_right:246,bbox_top:130,bbox_bottom:154,
    hsp:0,vsp:0,on_ground:true,sprite_index:1};
  const offsets = {}, pos = {};
  const s = { global:{is_paused:false}, delta_time:1e6/60, cam:1, view_w:480,view_h:270,
    follow_x:0,follow_y:0,look_ahead_x:0,shake_timer:0,shake_amount:0,
    room_width:1920,room_height:540,obj_player:p,
    exp:Math.exp,round:Math.round,max:Math.max,min:Math.min,array_length:a=>a.length,
    clamp:(v,a,b)=>Math.max(a,Math.min(b,v)),lerp:(a,b,t)=>a+(b-a)*t,
    variable_global_exists:()=>true,instance_exists:()=>true,instance_find:()=>p,
    sprite_get_width:()=>24,sprite_get_height:()=>32,
    layer_get_id:n=>n,layer_x:(n,x)=>(offsets[n]??={}).x=x,
    layer_y:(n,y)=>(offsets[n]??={}).y=y,
    camera_set_view_pos:(_,x,y)=>Object.assign(pos,{x,y}),irandom_range:()=>0};
  vm.createContext(s);vm.runInContext(kernel,s);
  const run = dt => { s.delta_time=dt*1e6;vm.runInContext(step,s); };
  const move = (x,y) => Object.assign(p,{bbox_left:x-8,bbox_right:x+8,bbox_top:y-12,bbox_bottom:y+12});
  return {s,p,pos,offsets,run,move};
}
let count=0;
function check(name,fn){fn();count++;console.log('OK '+name);}
check('personagem parado e salto curto não movem o enquadramento',()=>{
  const c=camera();for(let i=0;i<120;i++){c.move(238,142-Math.sin(i/120*Math.PI)*42);c.run(1/60);}
  assert.equal(c.pos.x,0);assert.equal(c.pos.y,0);
});
check('resposta temporal equivalente em 30, 60 e 144 FPS',()=>{
  const values=[];
  for(const fps of [30,60,144]){const c=camera();c.p.hsp=3;
    for(let i=1;i<=fps*4;i++){c.move(238+i/fps*180,142);c.run(1/fps);}values.push(c.s.follow_x);}
  assert.ok(Math.max(...values)-Math.min(...values)<5,values);
});
check('antecipação troca de direção e retorna suavemente',()=>{
  const c=camera();c.move(900,250);c.s.follow_x=660;c.s.follow_y=110;c.p.hsp=3;
  for(let i=0;i<90;i++)c.run(1/60);assert.ok(c.s.look_ahead_x>55);
  c.p.hsp=-3;c.run(1/60);assert.ok(c.s.look_ahead_x>0);
  for(let i=0;i<90;i++)c.run(1/60);assert.ok(c.s.look_ahead_x< -55);
  c.p.hsp=0;for(let i=0;i<120;i++)c.run(1/60);assert.ok(Math.abs(c.s.look_ahead_x)<.01);
});
check('queda prolongada abre espaço abaixo do personagem',()=>{
  const c=camera();c.p.on_ground=false;c.p.vsp=9;
  for(let i=0;i<60;i++){c.move(238,142+i*3);c.run(1/60);}
  assert.ok(c.s.follow_y>140);assert.ok(319-c.pos.y<180);
});
check('limites da room e margem segura em deslocamentos rápidos',()=>{
  const c=camera();for(const x of [30,500,1100,1880])for(const y of [40,150,360,500]){
    c.move(x,y);c.run(1/60);assert.ok(c.pos.x>=0&&c.pos.x<=1440);
    assert.ok(c.pos.y>=0&&c.pos.y<=270);
    assert.ok(x-c.pos.x>=16&&x-c.pos.x<=464);assert.ok(y-c.pos.y>=16&&y-c.pos.y<=254);
  }
});
check('transformações parallax reversíveis e coordenadas inteiras',()=>{
  const c=camera();
  for(const [x,y] of [[1440,270],[720,130],[0,0],[720,130]]){
    c.s.cb_camera_parallax(x,y);
    for(const [name,rate] of [['Fundo_Distante',.1],['Pedra_Distante',.25],['Nave_Media',.5],['Ornamentos_Proximos',.75]]){
      assert.equal(c.offsets[name].x,Math.round(x*(1-rate)));assert.equal(c.offsets[name].y,Math.round(y*(1-rate)));
    }
    assert.deepEqual(c.offsets.Nave_Animada,c.offsets.Nave_Media);
    assert.equal(c.offsets.Piso_Modular,undefined);assert.equal(c.offsets.Reliquias,undefined);
  }
});
check('letterbox cabe na janela e preserva 16:9 com escala inteira quando possível',()=>{
  for(const [w,h] of [[320,180],[480,270],[800,600],[960,540],[1366,768],[1920,1080],[2560,1440]]){
    const s={global:{},max:Math.max,min:Math.min,floor:Math.floor,window_get_width:()=>w,window_get_height:()=>h};
    vm.createContext(s);vm.runInContext(read('scripts/cb_render/cb_render.gml'),s);s.cb_render_layout();
    const g=s.global;assert.ok(g.cb_render_x>=0&&g.cb_render_y>=0);
    assert.ok(g.cb_render_x+480*g.cb_render_scale<=w&&g.cb_render_y+270*g.cb_render_scale<=h);
    if(w>=480&&h>=270)assert.ok(Number.isInteger(g.cb_render_scale));
  }
});
check('configurar a GUI não deixa shader ativo para os próximos desenhos',()=>{
  const s={global:{},max:Math.max,min:Math.min,floor:Math.floor,
    window_get_width:()=>960,window_get_height:()=>540,
    display_set_gui_maximise:()=>{},shader_set:()=>{throw Error('Shader vazou da configuração da GUI');}};
  vm.createContext(s);vm.runInContext(read('scripts/cb_render/cb_render.gml'),s);s.cb_gui_apply();
});
console.log(`${count} verificações de câmera e renderização passaram.`);
