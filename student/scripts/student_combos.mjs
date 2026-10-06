import fs from 'node:fs/promises';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const root=new URL('../../',import.meta.url), path=new URL('student/student.csv',root);
const originalColumns=['student_id','full_name','email','cohort','major','specialization','curriculum_code','current_semester','accumulated_credits'];
const hash=s=>crypto.createHash('sha256').update(s).digest('hex');
async function read(p){const w=await Workbook.fromCSV((await fs.readFile(p,'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});return w.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));}
async function preview(data,name){
 const w=Workbook.create(),s=w.worksheets.add('student');
 s.getRangeByIndexes(0,0,7,data[0].length).values=data.slice(0,7);
 s.getUsedRange().format.autofitColumns();w.recalculate();
 const blob=await w.render({sheetName:'student',autoCrop:'all',scale:1,format:'png'});
 await fs.mkdir(new URL('reports/student/',root),{recursive:true});
 await fs.writeFile(new URL(`reports/student/${name}.png`,root),new Uint8Array(await blob.arrayBuffer()));
}
const old=await read(path);
assert.deepEqual(old[0].slice(0,9),originalColumns);
assert(old[0].length===9||(old[0].length===10&&old[0][9]==='selected_combo_id'));
if(process.argv.includes('--preview-before')){await preview(old,'before_combo');process.exit(0);}
assert.equal(old.length,3001);
const curricula=new Map();
for(const major of ['AI','IA','IS','SE']){
 for(const c of (await read(new URL(`curriculum/${major}/curricula_${major.toLowerCase()}.csv`,root))).slice(1)){
  const combos=(await read(new URL(`curriculum/${major}/combo/${c[0]}/combos.csv`,root))).slice(1).filter(r=>!r[2].startsWith('PHE_COM'));
  assert(combos.length>0);assert(combos.every(r=>r[0]===c[0]&&/^(AI17|IA|IS|SE(?:-2026)?)_COM/.test(r[2])));
  curricula.set(c[0],{specialization:c[2],combos:combos.sort((a,b)=>Number(a[1])-Number(b[1]))});
 }
}
const rows=old.slice(1).map(r=>[...r.slice(0,9),r[9]??'']),groups=new Map();
assert.equal(new Set(rows.map(r=>r[0])).size,3000);
for(const r of rows){
 assert(r[2].startsWith('ojt.synthetic.'),'Only the synthetic dataset may be allocated automatically');
 const c=curricula.get(r[6]);assert(c,`Unknown curriculum ${r[6]}`);assert.equal(r[5],c.specialization);
 assert(/^\d+$/.test(r[7]));
 if(Number(r[7])<5){assert.equal(r[9],'',`Early existing selection needs manual review: ${r[0]}`);continue;}
 if(r[9])assert(c.combos.some(b=>b[1]===r[9]),`Invalid existing choice ${r[0]}`);
 const g=groups.get(r[6])??[];g.push(r);groups.set(r[6],g);
}
for(const [code,students] of groups){
 const opts=curricula.get(code).combos;
 const counts=new Map(opts.map(b=>[b[1],students.filter(s=>s[9]===b[1]).length]));
 for(const r of students.filter(s=>!s[9]).sort((a,b)=>hash(a[0]+'|'+code).localeCompare(hash(b[0]+'|'+code)))){
  const choice=[...opts].sort((a,b)=>counts.get(a[1])-counts.get(b[1])||Number(a[1])-Number(b[1]))[0];
  r[9]=choice[1];counts.set(r[9],counts.get(r[9])+1);
 }
}
const data=[originalColumns.concat('selected_combo_id'),...rows];
assert.deepEqual(rows.map(r=>r.slice(0,9)),old.slice(1).map(r=>r.slice(0,9)));
rows.forEach(r=>assert.equal(r[9]!=='',Number(r[7])>=5));
const w=Workbook.create(),s=w.worksheets.add('student');
s.getRangeByIndexes(0,0,data.length,10).values=data.map((r,i)=>i?r.map((v,j)=>[7,8].includes(j)?Number(v):v):r);
w.recalculate();
const out=s.getRangeByIndexes(0,0,data.length,10).values.map(r=>r.map(v=>String(v??'')));
assert.deepEqual(out,data);
const csv='\ufeff'+out.map(r=>r.map(v=>'"'+v.replaceAll('"','""')+'"').join(',')).join('\r\n')+'\r\n';
await fs.writeFile(path,csv,'utf8');assert.deepEqual(await read(path),data);
await preview(data,'after_combo');
const result={students:rows.length,selected:rows.filter(r=>r[9]).length,blank:rows.filter(r=>!r[9]).length,
 source:'SYNTHETIC: balanced assignment within exact curriculum, not actual student choices',
 rule:'Semester >=5: one specialization combo. Semester <5: blank (not confirmed). PHE_COM excluded.',
 originalColumnsPreserved:true,originalColumnsSha256:hash(JSON.stringify(rows.map(r=>r.slice(0,9)))),csvSha256:hash(csv),
 bySemester:Object.fromEntries([...new Set(rows.map(r=>r[7]))].sort().map(k=>[k,{students:rows.filter(r=>r[7]===k).length,selected:rows.filter(r=>r[7]===k&&r[9]).length}])),
 distribution:[...groups].flatMap(([code,ss])=>curricula.get(code).combos.map(c=>({curriculum_code:code,combo_id:c[1],combo_name:c[2],students:ss.filter(r=>r[9]===c[1]).length})))};
await fs.writeFile(new URL('reports/student/combo_assignment_summary.json',root),JSON.stringify(result,null,2));
console.log(JSON.stringify({students:result.students,selected:result.selected,blank:result.blank,bySemester:result.bySemester,originalColumnsPreserved:true},null,2));
