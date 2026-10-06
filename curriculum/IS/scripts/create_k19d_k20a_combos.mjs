import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
async function read(rel){
 const wb=await Workbook.fromCSV((await fs.readFile(new URL(rel,import.meta.url),'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return wb.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const code='BIT_IS_K19D_K20A';
const ids=['26','334','2634','2641','2734','2754'];
const sourceCombos=await read('../combo/BIT_IS_K19C/combos.csv');
const sourceCourses=await read('../combo/BIT_IS_K19C/combo_courses.csv');
const combos=[sourceCombos[0],...ids.map(id=>{
 if(id==='2734')return [code,id,'IS_COM1.2: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19D','',''];
 const row=sourceCombos.slice(1).find(r=>r[1]===id);assert(row);return [code,...row.slice(1)];
})];
const fresh=[
 [code,'2734','7421','IMO301c','IT Service Management and Operations_Quản lý và Vận hành Dịch vụ Công nghệ Thông tin','5','','',''],
 [code,'2734','7422','KMS301','Knowledge management system_Hệ thống quản trị tri thức','7','','',''],
 [code,'2734','7423','DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định','7','','',''],
 [code,'2734','7424','BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh','8','','','']];
const courses=[sourceCourses[0],...ids.flatMap(id=>id==='2734'?fresh:sourceCourses.slice(1).filter(r=>r[1]===id).map(r=>[code,...r.slice(1)]))];
assert.equal(combos.length-1,6);assert.equal(courses.length-1,22);
assert.equal(new Set(courses.slice(1).map(r=>r[1]+':'+r[2])).size,22);
assert.deepEqual(new Set(courses.slice(1).map(r=>r[1])),new Set(ids));
assert(!courses.slice(1).some(r=>['2635','2636','2637'].includes(r[1])));
assert(courses.some(r=>r[1]==='2754'&&r[3]==='BDI302c'));
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const wb=Workbook.create();const s=wb.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 const rel=`../combo/${code}/${file}`;const q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(new URL(rel,import.meta.url),'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(rel),data);console.log(`${file}: ${data.length-1} rows verified`);
}
