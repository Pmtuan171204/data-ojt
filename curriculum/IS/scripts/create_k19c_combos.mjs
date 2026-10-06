import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
async function read(rel){
 const wb=await Workbook.fromCSV((await fs.readFile(new URL(rel,import.meta.url),'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return wb.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const code='BIT_IS_K19C';
const ids=['26','334','2636','2641','2634'];
const sourceCombos=await read('../combo/BIT_IS_K19B/combos.csv');
const sourceCourses=await read('../combo/BIT_IS_K19B/combo_courses.csv');
const combos=[sourceCombos[0],...ids.map(id=>{
 const row=sourceCombos.slice(1).find(r=>r[1]===id);assert(row);
 return [code,...row.slice(1)];
}),[code,'2754','IS_COM5.1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','','']];
const courses=[sourceCourses[0],...sourceCourses.slice(1).filter(r=>ids.includes(r[1])).map(r=>[code,...r.slice(1)]),
 [code,'2754','7505','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5','','',''],
 [code,'2754','7506','DBM302m','Data Mining_Khai phá dữ liệu','7','','',''],
 [code,'2754','7507','BDI302c','Big Data_Dữ liệu lớn','7','','',''],
 [code,'2754','7508','DSP391m','Data Science - Capstone Project_Dự án KHDL','8','','','']];
assert.equal(combos.length-1,6);assert.equal(courses.length-1,22);
assert.equal(new Set(courses.slice(1).map(r=>r[1]+':'+r[2])).size,22);
assert.deepEqual(new Set(courses.slice(1).map(r=>r[1])),new Set(combos.slice(1).map(r=>r[1])));
assert(!courses.slice(1).some(r=>['2635','2637'].includes(r[1])||r[3]==='BDI301c'));
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const wb=Workbook.create();const s=wb.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 const rel=`../combo/${code}/${file}`;const q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(new URL(rel,import.meta.url),'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(rel),data);console.log(`${file}: ${data.length-1} rows verified`);
}
