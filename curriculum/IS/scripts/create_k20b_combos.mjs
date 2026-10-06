import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
async function read(rel){
 const wb=await Workbook.fromCSV((await fs.readFile(new URL(rel,import.meta.url),'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return wb.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const code='BIT_IS_K20B',ids=['26','334','2637','2641','2634','2734','2754'];
const sources={};
for(const c of ['BIT_IS_K18D_19A','BIT_IS_K19D_K20A']) sources[c]={combos:await read(`../combo/${c}/combos.csv`),courses:await read(`../combo/${c}/combo_courses.csv`)};
const combos=[['curriculum_code','combo_id','combo_name','selection_group','note']];
const courses=[sources.BIT_IS_K18D_19A.courses[0]];
for(const id of ids){
 const src=sources[id==='2637'?'BIT_IS_K18D_19A':'BIT_IS_K19D_K20A'];
 const row=src.combos.slice(1).find(r=>r[1]===id);assert(row);
 const note=id==='2637'?'Sinh viên chọn combo SAP phải làm đồ án tốt nghiệp SAP490':(row[4]||'');
 combos.push([code,id,row[2],row[3]||'',note]);
 const matches=src.courses.slice(1).filter(r=>r[1]===id);
 assert.equal(matches.length,['26','334'].includes(id)?3:4);
 courses.push(...matches.map(r=>[code,...r.slice(1)]));
}
assert.equal(courses.length-1,26);
assert.equal(new Set(courses.slice(1).map(r=>r[1]+':'+r[2])).size,26);
assert.deepEqual(courses.slice(1).filter(r=>r[1]==='2637').map(r=>[r[2],r[3],r[5]]),[['6998','ACC101','5'],['6999','SAP311','7'],['7000','SAP321','7'],['7001','SAP341','8']]);
assert.deepEqual(new Set(courses.slice(1).map(r=>r[1])),new Set(ids));
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const wb=Workbook.create();const s=wb.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
 const rel=`../combo/${code}/${file}`,q=v=>'"'+String(v).replaceAll('"','""')+'"';
 await fs.writeFile(new URL(rel,import.meta.url),'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(rel),data);console.log(`${file}: ${data.length-1} rows verified`);
}
