import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
async function read(rel){
 const wb=await Workbook.fromCSV((await fs.readFile(new URL(rel,import.meta.url),'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return wb.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const ids=new Set(['26','334','2637','2641','2634','2734','2754']);
for(const file of ['combos.csv','combo_courses.csv']){
 const source=await read(`../combo/BIT_IS_K20B/${file}`);
 assert.deepEqual(new Set(source.slice(1).map(r=>r[1])),ids);
 const data=[source[0],...source.slice(1).map(r=>['BIT_IS_K20C',...r.slice(1)])];
 assert.equal(data.length-1,file==='combos.csv'?7:26);
 if(file==='combos.csv')assert(data.find(r=>r[1]==='2637')[4].includes('SAP490'));
 else assert.equal(new Set(data.slice(1).map(r=>r[1]+':'+r[2])).size,26);
 const wb=Workbook.create();const s=wb.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 const rel=`../combo/BIT_IS_K20C/${file}`,q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(new URL(rel,import.meta.url),'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(rel),data);console.log(`${file}: ${data.length-1} rows verified`);
}
