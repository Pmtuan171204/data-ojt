import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const code='BIT_IA_K20B';
const definitions=[
['2650','IA_COM1:Topic on Application Security_Chủ đề An toàn ứng dụng'],
['2651','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống'],
['2652','IA_COM3: Topic on Apply AI for Cyber Security_Chủ đề Ứng dụng TTNT cho An toàn mạng'],
['1172','PHE_COM1: Vovinam BIT_AI_K17C(FNO)'],
['1173','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)']];
const subjects=[
['2650','7061','SDL201','Secure Software Development Lifecycle_Vòng đời Phát triển Phần mềm an toàn','7'],
['2650','7062','ASE201','Application Security Evaluation_Đánh giá bảo mật ứng dụng','7'],
['2650','7063','ADD301','Application Security Design and Development_Thiết kế và phát triển bảo mật ứng dụng','8'],
['2650','7064','DSO301','DevSecOps_Tích hợp DevSecOps','8'],
['2651','7065','NSA201','Enterprise Networking, Security, and Automation_Mạng Doanh nghiệp, An ninh và Tự động hóa','7'],
['2651','7066','NSR201','Network Security_An ninh mạng','7'],
['2651','7067','IIR301c','Network Incident Investigation and Response_Điều tra và Ứng phó sự cố An ninh Mạng','8'],
['2651','7068','COA301','Cybersecurity Operations and Analysis_Vận hành và Phân tích An ninh Mạng','8'],
['2652','7069','AML201','Introduction to Artificial Intelligence and Machine Learning_Nhập môn Trí tuệ Nhân tạo và Học máy','7'],
['2652','7070','CDA201','Foundations of Cybersecurity and Data Analyst_Nền tảng An ninh mạng và Phân tích Dữ liệu','7'],
['2652','7071','MLC301','Machine Learning Applications in Cyber Security','8'],
['2652','7072','AAC301','Advanced Topics in AI for Cyber Security_Nâng cao về TTNT trong An ninh mạng','8'],
['1172','5024','VOV114','Vovinam 1','0'],
['1172','5025','VOV124','Vovinam 2','1'],
['1172','5026','VOV134','Vovinam 3','2'],
['1173','5027','COV111','Cờ Vua 1','0'],
['1173','5028','COV121','Cờ Vua 2','1'],
['1173','5029','COV131','Cờ Vua 3','2']];
const combos=[['curriculum_code','combo_id','combo_name','selection_group','note'],...definitions.map(([id,name])=>[code,id,name,'',''])];
const courses=[['curriculum_code','combo_id','combo_subject_id','course_code','course_name','semester','credits','prerequisite','note'],...subjects.map(r=>[code,...r,'','',''])];
assert.equal(new Set(subjects.map(r=>r[0]+':'+r[1])).size,18);
assert.deepEqual(new Set(subjects.map(r=>r[0])),new Set(definitions.map(r=>r[0])));
for(const [id] of definitions){
 const semesters=subjects.filter(r=>r[0]===id).map(r=>r[4]);
 assert.deepEqual(semesters,['1172','1173'].includes(id)?['0','1','2']:['7','7','8','8']);
}
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const wb=Workbook.create();const s=wb.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 const path=new URL(`../combo/${code}/${file}`,import.meta.url),q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 const check=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'check'});
 assert.deepEqual(check.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??''))),data);
 console.log(`${file}: ${data.length-1} rows verified`);
}
