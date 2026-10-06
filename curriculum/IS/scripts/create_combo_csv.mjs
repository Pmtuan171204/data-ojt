import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const p=JSON.parse(await fs.readFile(new URL('../../../intermediate/curriculum/IS/combo_extracted.json',import.meta.url),'utf8'));
for(const [key,file] of [['combos','combos.csv'],['courses','combo_courses.csv']]){
 const data=p[key];const wb=Workbook.create();const s=wb.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 let path=new URL(`../combo/${p.code}/${file}`,import.meta.url);
 const q=v=>'"'+String(v).replaceAll('"','""')+'"';
 const csv='\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n';
 try{await fs.writeFile(path,csv,'utf8');}catch(e){
  if(!['EBUSY','EPERM'].includes(e.code))throw e;
  path=new URL(`../combo/${p.code}/${file.replace('.csv','_updated.csv')}`,import.meta.url);
  await fs.writeFile(path,csv,'utf8'); console.log(`Locked original; saved ${path.pathname}`);
 }
 const check=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'check'});
 assert.deepEqual(check.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??''))),data.map(r=>r.map(String)));
 console.log(`${file}: ${data.length-1} rows verified`);
}
await fs.writeFile(new URL('../../../reports/curriculum/IS/combo_K18D_19A.json',import.meta.url),JSON.stringify(p.sources,null,2),'utf8');
