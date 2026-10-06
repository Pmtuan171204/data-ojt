import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const code='BIT_IA_K18D-19A';
const combos=[['curriculum_code','combo_id','combo_name','selection_group','note'],
[code,'584','PHE_COM1: Vovinam BIT_IA_K16B(FNO)','',''],
[code,'585','PHE_COM2: Chess_Cờ vua BIT_IA_K16B(FNO)','',''],
[code,'586','IA_COM1: Topic on Application Security_Chủ đề An toàn ứng dụng BIT_IA_K16B(FNO)','',''],
[code,'587','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống BIT_IA_K16B(FNO)','','']];
const subjects=[
['584','2335','VOV114','Vovinam 1','0',''],
['584','2336','VOV124','Vovinam 2','1',''],
['584','2337','VOV134','Vovinam 3','2',''],
['585','2338','COV111','Cờ Vua 1','0',''],
['585','2339','COV121','Cờ Vua 2','1',''],
['585','2340','COV131','Cờ Vua 3','2',''],
['586','2341','DBS401','Database Security_An ninh cơ sở dữ liệu','8',''],
['586','2342','FRS401c','Network Forensics_Điều tra mạng','7',''],
['586','2343','IAR401c','Incident Response_Đối phó sự cố','8',''],
['586','2344','IAW301','Web security_An ninh Web','7',''],
['586','6630','NWC303','Network Connectivity_Kết nối mạng','8','or SPM401, if the student passed the subject NWC204'],
['587','2346','CES202','System Support and Trouble Shooting_Hỗ trợ hệ thống và khắc phục sự cố','7',''],
['587','2347','FRS401c','Network Forensics_Điều tra mạng','7',''],
['587','2348','IAR401c','Incident Response_Đối phó sự cố','8',''],
['587','2349','DMS401','Applied Data Mining for Information Assurance_Ứng dụng khai phá dữ liệu trong an toàn thông tin','8',''],
['587','2350','SPM401','Security Project Management_Quản trị dự án an toàn thông tin','8','']];
const courses=[['curriculum_code','combo_id','combo_subject_id','course_code','course_name','semester','credits','prerequisite','note'],...subjects.map(([id,rid,c,n,s,note])=>[code,id,rid,c,n,s,'','',note])];
assert.equal(new Set(subjects.map(r=>r[0]+':'+r[1])).size,16);
for(const id of ['584','585'])assert.deepEqual(subjects.filter(r=>r[0]===id).map(r=>r[4]),['0','1','2']);
for(const id of ['586','587'])assert.equal(subjects.filter(r=>r[0]===id).length,5);
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const wb=Workbook.create();const sh=wb.worksheets.add('data');
 sh.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 let path=new URL(`../combo/${code}/${file}`,import.meta.url);const q=v=>'"'+String(v).replaceAll('"','""')+'"';
 const csv='\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n';
 let existing='';try{existing=await fs.readFile(path,'utf8');}catch(e){if(e.code!=='ENOENT')throw e;}
 if(existing!==csv)try{await fs.writeFile(path,csv,'utf8');}catch(e){
  if(e.code!=='EBUSY')throw e;
  path=new URL(`../combo/${code}/${file.replace('.csv','_updated.csv')}`,import.meta.url);
  await fs.writeFile(path,csv,'utf8');console.log(`Locked original; saved ${path.pathname}`);
 }
 const check=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'check'});
 assert.deepEqual(check.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??''))),data);
 console.log(`${file}: ${data.length-1} rows verified`);
}
