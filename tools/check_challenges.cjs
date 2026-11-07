// Executa o teste de cruzamento one-way real; não simula física/eventos GameMaker.
const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict'),path=require('node:path');
const s={x:0,y:0,bbox_left:10,bbox_right:23,bbox_bottom:39,
 obj_challenges:{platforms:[{x:0,y:40,w:64,active:true}]},
 instance_exists:()=>true,array_length:a=>a.length};
vm.createContext(s);vm.runInContext(fs.readFileSync(path.join(__dirname,'../scripts/cb_challenges/cb_challenges.gml'),'utf8'),s);
assert.equal(s.cb_oneway_at(0,1),true,'queda cruza topo');
assert.equal(s.cb_oneway_at(0,-1),false,'subida atravessa');
assert.equal(s.cb_oneway_at(80,1),false,'fora da largura não apoia');
s.obj_challenges.platforms[0].active=false;
assert.equal(s.cb_oneway_at(0,1),false,'plataforma caída não apoia');
assert.ok(8<=16 && 18>16,'corredor 16px comporta máscara8 do morcego, não humano18');
console.log('5 verificações de apoio/corredor aprovadas; percurso e timing pendentes no runner.');
