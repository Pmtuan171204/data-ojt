import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
async function read(rel){
 const wb=await Workbook.fromCSV((await fs.readFile(new URL(rel,import.meta.url),'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return wb.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const code='BIT_IA_K21C', ids=new Set(['2650','2651','2652']);
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const file of ['combos.csv','combo_courses.csv']){
 const source=await read(`../combo/BIT_IA_K20B/${file}`);
 const selected=source.slice(1).filter(r=>ids.has(r[1]));
 assert.deepEqual(new Set(selected.map(r=>r[1])),ids);
 assert.ok(selected.every(r=>r[0]==='BIT_IA_K20B'));
 const data=[source[0],...selected.map(r=>[code,...r.slice(1)])];
 assert.equal(data.length-1,file==='combos.csv'?3:12);
 if(file==='combo_courses.csv'){
  assert.equal(new Set(data.slice(1).map(r=>r[1]+':'+r[2])).size,12);
  for(const id of ids)assert.deepEqual(data.slice(1).filter(r=>r[1]===id).map(r=>r[5]),['7','7','8','8']);
 }
 const wb=Workbook.create();const s=wb.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 const rel=`../combo/${code}/${file}`,q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(new URL(rel,import.meta.url),'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(rel),data);console.log(`${file}: ${data.length-1} rows verified`);
}

