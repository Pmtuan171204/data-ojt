import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const code='BIT_SE_K20B',ids=['26','334','340','402','1469','2566','2497','2605','2640','2628','2675','2686'];
async function read(path){
 const w=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return w.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const file of ['combos.csv','combo_courses.csv']){
 const source=await read(new URL(`../combo/BIT_SE_K19B/${file}`,import.meta.url));
 assert.deepEqual(new Set(source.slice(1).filter(r=>ids.includes(r[1])).map(r=>r[1])),new Set(ids));
 assert.ok(source.slice(1).every(r=>r[0]==='BIT_SE_K19B'));
 const data=[source[0],...source.slice(1).filter(r=>ids.includes(r[1])).map(r=>[code,...r.slice(1)])];
 assert.equal(data.length-1,file==='combos.csv'?12:44);
 if(file==='combo_courses.csv'){
  assert.equal(new Set(data.slice(1).map(r=>r[1]+':'+r[2])).size,44);
  const semesters={'26':['0','1','2'],'334':['0','1','2'],'340':['5','7','8'],'402':['7','8','8'],'1469':['5','7','8','8','8'],'2566':['5','8','7','7'],'2497':['8','5','7','7'],'2605':['7','7','8','5'],'2640':['5','7','8'],'2628':['5','7','7','8'],'2675':['5','7','7','8'],'2686':['5','7','7','8']};
  for(const [id,expected] of Object.entries(semesters))assert.deepEqual(data.slice(1).filter(r=>r[1]===id).map(r=>r[5]),expected);
 }
 const w=Workbook.create(),s=w.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;w.recalculate();
 const path=new URL(`../combo/${code}/${file}`,import.meta.url),q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(path),data);console.log(`${file}: ${data.length-1} rows verified`);
}

