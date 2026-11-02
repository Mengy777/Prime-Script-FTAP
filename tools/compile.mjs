import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL}from 'node:url';
const {LuauState}=await import(pathToFileURL(process.argv[2]).href);
const root=path.resolve(import.meta.dirname,'..');const state=await LuauState.createAsync();
try{
 const files=['PrimeVisuals.lua','PrimeVortex.lua',...fs.readdirSync(path.join(root,'lib')).filter(x=>x.endsWith('.lua')).map(x=>'lib/'+x)];
 for(const file of files){state.loadstring(fs.readFileSync(path.join(root,file),'utf8'),file,true);console.log('PASS compile '+file);}
}finally{state.destroy();}
