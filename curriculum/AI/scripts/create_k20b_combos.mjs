import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const code='BIT_AI_K20B';
async function read(path){
 const w=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return w.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const base=new URL('../combo/BIT_AI_K18D-19A/',import.meta.url);
const oldCombos=await read(new URL('combos.csv',base)),oldCourses=await read(new URL('combo_courses.csv',base));
const reused=new Set(['1172','1173','1174','1176','2620']);
for(const data of [oldCombos,oldCourses]){
 assert.deepEqual(new Set(data.slice(1).map(r=>r[1])),reused);
 assert.ok(data.slice(1).every(r=>r[0]==='BIT_AI_K18D-19A'));
}
const combos=[oldCombos[0],...oldCombos.slice(1).map(r=>[code,...r.slice(1)]),
 [code,'2653','AI17_COM4: Topic on Generative AI_Chủ đề TTNT tạo sinh','',''],
 [code,'2654','AI17_COM5: Topic on Machine Learning Operations_Chủ đề Hoạt động học máy','','']];
const subjects=[
 ['2653','7073','GAI201m','Introduction to Generative AI_Nhập môn TTNT tạo sinh','5'],
 ['2653','7074','MGA301','Multimodal AI_TTNT đa phương thức','7'],
 ['2653','7075','AGA301c','Advanced Generative AI_TTNT tạo sinh nâng cao','5'],
 ['2653','7076','GAP301','GenAI Project_Dự án TTNT tạo sinh','8'],
 ['2654','7077','MOI201m','Introduction to MLOps_Nhập môn hoạt động học máy','5'],
 ['2654','7078','CMO301m','Cloud for MLOps_Cloud cho hoạt động học máy','7'],
 ['2654','7079','AIS301c','AI for Cybersecurity_TTNT cho an ninh mạng','5'],
 ['2654','7080','AMO301m','Advanced MLOps_Hoạt động học máy nâng cao','8']];
const courses=[oldCourses[0],...oldCourses.slice(1).map(r=>[code,...r.slice(1)]),...subjects.map(r=>[code,...r,'','',''])];
assert.equal(combos.length,8);assert.equal(courses.length,27);
assert.equal(new Set(courses.slice(1).map(r=>r[1]+':'+r[2])).size,26);
assert.equal(combos.find(r=>r[1]==='2620')[4],'Adjust the subject code in the combo (remove ending m)');
for(const r of combos.slice(1)){
 const expected=['1172','1173'].includes(r[1])?['0','1','2']:['2653','2654'].includes(r[1])?['5','7','5','8']:['5','5','7','8'];
 assert.deepEqual(courses.slice(1).filter(c=>c[1]===r[1]).map(c=>c[5]),expected);
}
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const w=Workbook.create(),s=w.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;w.recalculate();
 const path=new URL(`../combo/${code}/${file}`,import.meta.url),q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(path),data);console.log(`${file}: ${data.length-1} rows verified`);
}
