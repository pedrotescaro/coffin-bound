// Usa as mesmas posições e condições de criação de cada room para a prévia estática.
const fs=require('node:fs'),vm=require('node:vm'),path=require('node:path');
const scene={global:{cb:{level:Number(process.argv[2])}},array_push:(list,item)=>list.push(item)};
vm.runInNewContext(fs.readFileSync(path.resolve(__dirname,'../../objects/obj_challenges/Create_0.gml'),'utf8'),scene);
console.log(JSON.stringify({platforms:scene.platforms,hazards:scene.hazards}));
