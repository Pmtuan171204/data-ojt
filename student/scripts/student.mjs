import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import { Workbook } from '@oai/artifact-tool';
const root = new URL('../../',import.meta.url);
const studentPath = new URL('student/student.csv',root);
async function readCsv(path) {
 const wb=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return wb.worksheets.getItemAt(0).getUsedRange().values;
}
async function writeCsv(path, data) {
 const wb=Workbook.create(); const sheet=wb.worksheets.add('data');
 sheet.getRangeByIndexes(0,0,data.length,data[0].length).values=data; wb.recalculate();
 const output=sheet.getRangeByIndexes(0,0,data.length,data[0].length).values;
 const quote=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(path,'\ufeff'+output.map(r=>r.map(quote).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await readCsv(path),data.map(r=>r.map(String)));
}
const specs={SE:'Kỹ thuật phần mềm',IS:'Hệ thống thông tin',IA:'An toàn thông tin',AI:'Trí tuệ nhân tạo'};
const curricula=[]; let curriculumHeader;
for(const code of Object.keys(specs)) {
 const table=await readCsv(new URL(`curriculum/${code}/curricula_${code.toLowerCase()}.csv`,root));
 curriculumHeader ??= table[0]; assert.deepEqual(table[0],curriculumHeader);
 curricula.push(...table.slice(1));
}
const byCode=new Map(curricula.map(r=>[r[0],r]));
assert.equal(byCode.size,40); assert.equal(curricula.length,40);
// Parse actual source codes, including SE-2026 and both underscore/hyphen separators.
function intakes(code) {
 const suffix=code.slice(code.indexOf('_K')+1).replace(/_FNO$/,'');
 return [...suffix.matchAll(/K?(\d{2})([ABCD])/g)].map(m=>`K${m[1]}${m[2]}`);
}
const input=await readCsv(studentPath); const headers=input[0];
assert.deepEqual(headers,['student_id','full_name','email','cohort','major','specialization','curriculum_code','current_semester','accumulated_credits']);
assert([2000,3000].includes(input.length-1));
const rows=input.slice(1).map(r=>[...r]);
const oldIdentity=new Map(rows.map(r=>[r[0],[r[1],r[3],r[5]]]));
const family=['Nguyễn','Trần','Lê','Phạm','Hoàng','Huỳnh','Vũ','Võ','Đặng','Bùi','Đỗ','Hồ','Ngô','Dương','Lý'];
const given=['Minh Anh','Quang Huy','Ngọc Linh','Gia Bảo','Thanh Hà','Đức Anh','Thu Trang','Hoàng Nam','Khánh Vy','Tuấn Kiệt','Bảo Ngọc','Minh Khang','Phương Thảo','Hải Đăng','Ngọc Hân','Trung Hiếu','Anh Thư','Quốc Bảo','Thùy Dung','Nhật Minh'];
let seed=20261005;
function rng(){seed=(Math.imul(seed,1664525)+1013904223)>>>0; return seed/4294967296;}
function shuffle(a){for(let i=a.length-1;i>0;i--){const j=Math.floor(rng()*(i+1));[a[i],a[j]]=[a[j],a[i]];}return a;}
for(const cohort of ['K19','K20','K21']) {
 const existing=rows.filter(r=>r[3]===cohort);
 let next=Math.max(...existing.map(r=>Number(r[0].slice(4))))+1;
 const missing=[];
 for(const spec of Object.values(specs)) {
  const count=existing.filter(r=>r[5]===spec).length;
  assert(count<=250); missing.push(...Array(250-count).fill(spec));
 }
 for(const spec of shuffle(missing)) {
  const id=`SE${cohort.slice(1)}${String(next++).padStart(4,'0')}`;
  const name=family[Math.floor(rng()*family.length)]+' '+given[Math.floor(rng()*given.length)];
  rows.push([id,name,`ojt.synthetic.${id.toLowerCase()}@example.com`,cohort,'Công nghệ thông tin',spec,'',0,0]);
 }
}
const semesters={K19:{A:5,B:5,C:4,D:4},K20:{A:4,B:3,C:3,D:2},K21:{A:2,B:2,C:1,D:1}};
seed=20261005;
const distribution=[];
for(const cohort of ['K19','K20','K21']) for(const [specCode,spec] of Object.entries(specs)) {
 const group=shuffle(rows.filter(r=>r[3]===cohort && r[5]===spec).sort((a,b)=>a[0].localeCompare(b[0])));
 assert.equal(group.length,250);
 const choices={};
 for(const c of curricula.filter(r=>r[2]===spec)) for(const intake of intakes(c[0]).filter(i=>i.startsWith(cohort))) {
  const letter=intake.at(-1); (choices[letter]??=[]).push(c[0]);
 }
 const letters=Object.keys(choices).sort(); assert(letters.length);
 if(cohort==='K21'&&specCode==='IS') assert.deepEqual(letters,['A']);
 if(cohort==='K19'&&['IA','AI'].includes(specCode)) assert(!letters.includes('C'));
 const seen={};
 group.forEach((row,i)=>{
  const letter=letters[i%letters.length]; const n=seen[letter]||0; seen[letter]=n+1;
  const code=choices[letter][n%choices[letter].length]; const semester=semesters[cohort][letter];
  const draw=rng(); const missing=semester===1?0:draw<0.6?0:draw<0.85?1:draw<0.95?2:3;
  row[2]=`ojt.synthetic.${row[0].toLowerCase()}@example.com`;
  row[4]='Công nghệ thông tin'; row[6]=code; row[7]=semester; row[8]=(semester-1)*15-missing*3;
  assert(intakes(code).includes(cohort+letter)); assert.equal(byCode.get(code)[2],row[5]);
  assert(row[8]>=0&&row[8]%3===0&&row[8]<=(semester-1)*15);
  assert(row[8]<=Number(byCode.get(code)[3]));
 });
 assert(Math.max(...Object.values(seen))-Math.min(...Object.values(seen))<=1);
 distribution.push({cohort,specialization:spec,total:group.length,intakes:seen});
}
rows.sort((a,b)=>a[0].localeCompare(b[0]));
assert.equal(rows.length,3000); assert.equal(new Set(rows.map(r=>r[0])).size,3000);
assert.equal(new Set(rows.map(r=>r[2])).size,3000);
for(const row of rows) {
 assert(/^SE\d{6}$/.test(row[0])); assert.equal(row[0].slice(2,4),row[3].slice(1));
 if(oldIdentity.has(row[0])) assert.deepEqual([row[1],row[3],row[5]],oldIdentity.get(row[0]));
}
for(const cohort of ['K19','K20','K21']) {
 const group=rows.filter(r=>r[3]===cohort); assert.equal(group.length,1000);
 group.forEach((r,i)=>assert.equal(r[0],`SE${cohort.slice(1)}${String(i).padStart(4,'0')}`));
}
assert.equal(new Set(rows.map(r=>r[6])).size,40);
// Preserve the input once before replacing it. A later run does not overwrite this snapshot.
await fs.mkdir(new URL('backups/student/',root),{recursive:true});
try{await fs.copyFile(studentPath,new URL('backups/student/student_before_curriculum_sync.csv',root),fs.constants.COPYFILE_EXCL);}catch(e){if(e.code!=='EEXIST')throw e;}
await writeCsv(new URL('curriculum/curricula_all.csv',root),[curriculumHeader,...curricula]);
await writeCsv(studentPath,[headers,...rows]);
await fs.mkdir(new URL('reports/student/',root),{recursive:true});
await fs.writeFile(new URL('reports/student/distribution_summary.json',root),JSON.stringify({students:rows.length,curricula:curricula.length,distribution},null,2),'utf8');
console.log(JSON.stringify({students:rows.length,curricula:curricula.length,existingIdentitiesPreserved:oldIdentity.size,distribution},null,2));
