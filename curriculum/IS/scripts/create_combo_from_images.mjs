import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const names={
26:'PHE_COM1: Vovinam BIT_GD_K16D,K17A',
334:'PHE_COM2: Cờ vua BIT_SE_K15A',
2636:'IS_COM1.1: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19A',
2637:'IS_COM2.1: Topic on SAP_Chủ đề SAP_K19A',
2641:'IS_COM3: Topic on Topic on Software System Quality_Chủ đề Chất lượng hệ thống phần mềm',
2634:'IS_COM4: Topic on Cybersecurity for Information Systems_Chủ đề Bảo mật cho hệ thống thông tin',
2635:'IS_COM5: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng',
2734:'IS_COM1.2: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19D',
2754:'IS_COM5.1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng'};
async function save(code,file,data){
 const dir=new URL(`../combo/${code}/`,import.meta.url);await fs.mkdir(dir,{recursive:true});
 const path=new URL(file,dir);
 // These are screenshot seed files; do not overwrite subsequent HTML-derived data.
 try{await fs.access(path);throw new Error(`Output already exists: ${path.pathname}`);}catch(e){if(e.code!=='ENOENT')throw e;}
 const wb=Workbook.create();const s=wb.worksheets.add('data');s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 const q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 const check=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'check'});
 assert.deepEqual(check.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??''))),data.map(r=>r.map(String)));
 console.log(`${code}/${file}: ${data.length-1} rows verified`);
}
for(const [code,ids] of Object.entries({BIT_IS_K18D_19A:[26,334,2636,2637,2641,2634,2635],BIT_IS_K19D_K20A:[26,334,2634,2641,2734,2754]})){
 await save(code,'combos.csv',[['curriculum_code','combo_id','combo_name','selection_group'],...ids.map(id=>[code,String(id),names[id],''])]);
}
const code='BIT_IS_K19D_K20A';
await save(code,'combo_courses.csv',[
['curriculum_code','combo_id','combo_subject_id','course_code','course_name','semester','credits','prerequisite','note'],
[code,'2734','7421','IMO301c','IT Service Management and Operations_Quản lý và Vận hành Dịch vụ Công nghệ Thông tin',5,'','',''],
[code,'2734','7422','KMS301','Knowledge management system_Hệ thống quản trị tri thức',7,'','',''],
[code,'2734','7423','DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định',7,'','',''],
[code,'2734','7424','BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh',8,'','','']]);
