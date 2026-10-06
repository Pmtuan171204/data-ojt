import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const code='BIT_SE-2026_K21D_K22A';
async function read(path){
 const w=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return w.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const base=new URL('../combo/BIT_SE_K19B/',import.meta.url);
const oldCombos=await read(new URL('combos.csv',base)),oldCourses=await read(new URL('combo_courses.csv',base));
const japanese=oldCourses.slice(1).filter(r=>r[1]==='340');
assert.deepEqual(japanese.map(r=>[r[2],r[3],r[5]]),[['1426','JPD133','5'],['1427','JPD316','7'],['1428','JPD326','8']]);
const definitions=[
 ['2746','SE-2026_COM1: Topic on AI-Augmented Quality Assurance_Chủ đề Đảm bảo chất lượng tăng cường bằng AI'],
 ['2747','SE-2026_COM2: Topic on AI Application Engineer_Chủ đề về Kỹ sư Ứng dụng AI'],
 ['2748','SE-2026_COM3: Topic on AI-Augmented Business Analyst_ Chủ đề về Chuyên viên phân tích nghiệp vụ tăng cường bằng AI'],
 ['2749','SE-2026_COM4: Topic on AI-Augmented Engineer (Fullstack Java)_Chủ đề Kỹ sư phát triển Fullstack Java tăng cường bằng AI']];
const subjects=[
 ['2746','7471','AQA301','Agile Software Quality Assurance_Đảm bảo chất lượng phần mềm theo Agile','5'],
 ['2746','7472','SQA301','AI-based System Quality Assurance_Đảm bảo chất lượng hệ thống dựa trên AI','7'],
 ['2746','7473','TAI301','Testing with Generative AI_Kiểm thử với AI tạo sinh','7'],
 ['2746','7474','QCT301','Quality Characteristics Testing_Kiểm thử các đặc tính chất lượng','8'],
 ['2747','7475','ALF301','AI, LLMs & GenAI Foundation_Cơ sở AI, LLM và AI tạo sinh','5'],
 ['2747','7476','LLA301','LLM Application Engineering_Kỹ thuật phát triển ứng dụng với LLM','7'],
 ['2747','7477','EIA301','Embeddings and Intelligent Applications_Nhúng dữ liệu và Ứng dụng Thông minh','7'],
 ['2747','7478','EAS301','Enterprise AI Systems_Hệ thống AI cho Doanh nghiệp','8'],
 ['2748','7479','BPE301','Business Analysis Planning & Elicitation with Generative AI_Lập kế hoạch và Thu thập Yêu cầu Kinh doanh với AI tạo sinh','5'],
 ['2748','7480','SLM301','AI-Augmented Software Requirements Life Cycle Management_Quản lý vòng đời yêu cầu phần mềm được tăng cường bằng AI','7'],
 ['2748','7481','SDS301','Strategy Analysis & Decision Support with AI_Phân tích chiến lược và Hỗ trợ quyết định với AI','7'],
 ['2748','7482','EDO301','Solution Evaluation, Delivery & Operations with AI_Đánh giá, Triển khai và Vận hành Giải pháp với AI','8'],
 ['2749','7483','EFD301','Enterprise Fullstack Application Development (with Java)_Phát triển ứng dụng Fullstack doanh nghiệp (với Java)','5'],
 ['2749','7484','EMD301','Enterprise Microservices Architecture & Development (with Java)_Kiến trúc và Phát triển Microservices doanh nghiệp (với Java)','7'],
 ['2749','7485','BSS301','AI-Augmented Backend Systems & Intelligent Services_Hệ thống Backend và Dịch vụ Thông minh được tăng cường bằng AI','7'],
 ['2749','7486','DDP301','Software Delivery, DevOps & Platform Engineering_Triển khai Phần mềm, DevOps và Kỹ thuật Nền tảng','8']];
const jpCombo=oldCombos.slice(1).find(r=>r[1]==='340');assert.ok(jpCombo);
const combos=[oldCombos[0],...definitions.map(([id,name])=>[code,id,name,'','']),[code,...jpCombo.slice(1)]];
const courses=[oldCourses[0],...subjects.map(r=>[code,...r,'','','']),...japanese.map(r=>[code,...r.slice(1)])];
assert.equal(combos.length,6);assert.equal(courses.length,20);
assert.equal(new Set(courses.slice(1).map(r=>r[1]+':'+r[2])).size,19);
assert.deepEqual(subjects.map(r=>r[1]),Array.from({length:16},(_,i)=>String(7471+i)));
for(const [id] of definitions)assert.deepEqual(subjects.filter(r=>r[0]===id).map(r=>r[4]),['5','7','7','8']);
assert.deepEqual(subjects.map(r=>r[2]),['AQA301','SQA301','TAI301','QCT301','ALF301','LLA301','EIA301','EAS301','BPE301','SLM301','SDS301','EDO301','EFD301','EMD301','BSS301','DDP301']);
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const w=Workbook.create(),s=w.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;w.recalculate();
 const path=new URL(`../combo/${code}/${file}`,import.meta.url),q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(path),data);console.log(`${file}: ${data.length-1} rows verified`);
}
