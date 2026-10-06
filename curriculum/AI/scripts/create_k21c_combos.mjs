import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const code='BIT_AI_K21C',ids=new Set(['1172','1173','1174','1176','2620','2653','2654']);
async function read(path){
 const w=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return w.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const file of ['combos.csv','combo_courses.csv']){
 const source=await read(new URL(`../combo/BIT_AI_K20B/${file}`,import.meta.url));
 assert.deepEqual(new Set(source.slice(1).map(r=>r[1])),ids);
 assert.ok(source.slice(1).every(r=>r[0]==='BIT_AI_K20B'));
 const data=[source[0],...source.slice(1).map(r=>[code,...r.slice(1)])];
 assert.equal(data.length-1,file==='combos.csv'?7:26);
 if(file==='combo_courses.csv'){
  assert.equal(new Set(data.slice(1).map(r=>r[1]+':'+r[2])).size,26);
  for(const id of ids){
   const expected=['1172','1173'].includes(id)?['0','1','2']:['2653','2654'].includes(id)?['5','7','5','8']:['5','5','7','8'];
   assert.deepEqual(data.slice(1).filter(r=>r[1]===id).map(r=>r[5]),expected);
  }
 }else assert.equal(data.find(r=>r[1]==='2620')[4],'Adjust the subject code in the combo (remove ending m)');
 const w=Workbook.create(),s=w.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;w.recalculate();
 const path=new URL(`../combo/${code}/${file}`,import.meta.url),q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(path),data);console.log(`${file}: ${data.length-1} rows verified`);
}


