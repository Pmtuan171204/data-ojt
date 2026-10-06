import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const code='BIT_AI_K18D-19A_FNO',ids=['1172','1173','1174','1175','1176'];
async function read(path){
 const w=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return w.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const base=new URL('../combo/BIT_AI_K18D-19A/',import.meta.url);
const oldCombos=await read(new URL('combos.csv',base)),oldCourses=await read(new URL('combo_courses.csv',base));
const reused=new Set(['1172','1173','1174','1176']);
const comboRows=oldCombos.slice(1).filter(r=>reused.has(r[1])).map(r=>[code,...r.slice(1)]);
assert.equal(comboRows.length,4);
comboRows.push([code,'1175','AI17_COM2: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT BIT_AI_K17C(FNO)','','']);
comboRows.sort((a,b)=>ids.indexOf(a[1])-ids.indexOf(b[1]));
const newSubjects=[
 ['5034','SEG301m','Search Engines_Công cụ tìm kiếm','5'],
 ['5035','TMG301m','Text Mining_Khai thác văn bản','5'],
 ['5036','SLP301m','Speech Processing_Xử lý tiếng nói','7'],
 ['5037','IMP302m','Image & Video processing_Xử lý hình ảnh và video','8']];
const courseRows=oldCourses.slice(1).filter(r=>reused.has(r[1])).map(r=>[code,...r.slice(1)]);
courseRows.push(...newSubjects.map(r=>[code,'1175',...r,'','','']));
courseRows.sort((a,b)=>ids.indexOf(a[1])-ids.indexOf(b[1]));
assert.equal(courseRows.length,18);
assert.equal(new Set(courseRows.map(r=>r[1]+':'+r[2])).size,18);
for(const id of ids)assert.deepEqual(courseRows.filter(r=>r[1]===id).map(r=>r[5]),['1172','1173'].includes(id)?['0','1','2']:['5','5','7','8']);
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const [file,data] of [['combos.csv',[oldCombos[0],...comboRows]],['combo_courses.csv',[oldCourses[0],...courseRows]]]){
 const w=Workbook.create(),s=w.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;w.recalculate();
 const path=new URL(`../combo/${code}/${file}`,import.meta.url),q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(path),data);console.log(`${file}: ${data.length-1} rows verified`);
}
