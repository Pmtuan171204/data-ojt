import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const code='BIT_AI_K18D-19A';
async function read(path){
 const w=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return w.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const base=new URL('../../IA/combo/BIT_IA_K20B/',import.meta.url);
const oldCombos=await read(new URL('combos.csv',base));
const oldCourses=await read(new URL('combo_courses.csv',base));
const sports=r=>['1172','1173'].includes(r[1]);
const combos=[oldCombos[0],...oldCombos.slice(1).filter(sports).map(r=>[code,...r.slice(1)]),
 [code,'1174','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''],
 [code,'1176','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''],
 [code,'2620','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)']];
const subjects=[
 ['1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5'],
 ['1174','5031','BDI302c','Big Data_Dữ liệu lớn','5'],
 ['1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7'],
 ['1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8'],
 ['1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5'],
 ['1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5'],
 ['1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7'],
 ['1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8'],
 ['2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5'],
 ['2620','6920','TMG301','Text Mining_Khai thác văn bản','5'],
 ['2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7'],
 ['2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8']];
const courses=[oldCourses[0],...oldCourses.slice(1).filter(sports).map(r=>[code,...r.slice(1)]),...subjects.map(r=>[code,...r,'','',''])];
assert.equal(combos.length,6);assert.equal(courses.length,19);
assert.equal(new Set(courses.slice(1).map(r=>r[1]+':'+r[2])).size,18);
for(const r of combos.slice(1))assert.deepEqual(courses.slice(1).filter(c=>c[1]===r[1]).map(c=>c[5]),sports(r)?['0','1','2']:['5','5','7','8']);
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const w=Workbook.create(),s=w.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;w.recalculate();
 const path=new URL(`../combo/${code}/${file}`,import.meta.url),q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(path),data);console.log(`${file}: ${data.length-1} rows verified`);
}
