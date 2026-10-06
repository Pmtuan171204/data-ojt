import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
async function read(rel){
 const wb=await Workbook.fromCSV((await fs.readFile(new URL(rel,import.meta.url),'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return wb.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const code='BIT_IS_K20D',ids=['26','334','2636','2637','2641','2634','2635'];
const sourceCombos=await read('../combo/BIT_IS_K18D_19A/combos.csv');
const sourceCourses=await read('../combo/BIT_IS_K18D_19A/combo_courses.csv');
const combos=[['curriculum_code','combo_id','combo_name','selection_group','note'],...ids.map(id=>{
 const row=sourceCombos.slice(1).find(r=>r[1]===id);assert(row);
 return [code,id,row[2],row[3]||'',id==='2637'?'Sinh viên chọn combo SAP phải làm đồ án tốt nghiệp SAP490':(row[4]||'')];
})];
const courses=[sourceCourses[0],...ids.flatMap(id=>{
 const rows=sourceCourses.slice(1).filter(r=>r[1]===id);
 assert.equal(rows.length,['26','334'].includes(id)?3:4);
 return rows.map(r=>[code,...r.slice(1)]);
})];
assert.equal(courses.length-1,26);
assert.equal(new Set(courses.slice(1).map(r=>r[1]+':'+r[2])).size,26);
assert.deepEqual(new Set(courses.slice(1).map(r=>r[1])),new Set(ids));
assert(courses.some(r=>r[1]==='2636'&&r[3]==='FIN202'));
assert(courses.some(r=>r[1]==='2635'&&r[3]==='BDI301c'));
assert(!courses.some(r=>['2734','2754'].includes(r[1])));
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const wb=Workbook.create();const s=wb.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 const rel=`../combo/${code}/${file}`,q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(new URL(rel,import.meta.url),'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(rel),data);console.log(`${file}: ${data.length-1} rows verified`);
}
