import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
async function read(rel){
 const wb=await Workbook.fromCSV((await fs.readFile(new URL(rel,import.meta.url),'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return wb.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const code='BIT_IA_K19D-20A', ids=new Set(['584','585','586','587']);
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const file of ['combos.csv','combo_courses.csv']){
 const source=await read(`../combo/BIT_IA_K18D-19A/${file}`);
 assert.deepEqual(new Set(source.slice(1).map(r=>r[1])),ids);
 const data=[source[0],...source.slice(1).map(r=>[code,...r.slice(1)])];
 assert.equal(data.length-1,file==='combos.csv'?4:16);
 if(file==='combo_courses.csv'){
  assert.equal(new Set(data.slice(1).map(r=>r[1]+':'+r[2])).size,16);
  for(const id of ids)assert.equal(data.slice(1).filter(r=>r[1]===id).length,['584','585'].includes(id)?3:5);
  assert.equal(data.find(r=>r[1]==='586'&&r[3]==='NWC303')[8],'or SPM401, if the student passed the subject NWC204');
 }
 const wb=Workbook.create();const s=wb.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 const rel=`../combo/${code}/${file}`,q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(new URL(rel,import.meta.url),'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(rel),data);console.log(`${file}: ${data.length-1} rows verified`);
}


