import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
async function read(rel){
 const wb=await Workbook.fromCSV((await fs.readFile(new URL(rel,import.meta.url),'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return wb.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const combos=await read('../combo/BIT_IS_K19B/combos.csv');
const source=await read('../combo/BIT_IS_K18D_19A/combo_courses.csv');
const ids=new Set(combos.slice(1).map(r=>r[1]));
assert.equal(ids.size,6);
const rows=source.slice(1).filter(r=>ids.has(r[1])).map(r=>['BIT_IS_K19B',...r.slice(1)]);
assert.equal(rows.length,22);
assert.deepEqual(new Set(rows.map(r=>r[1])),ids);
assert.equal(new Set(rows.map(r=>`${r[1]}:${r[2]}`)).size,rows.length);
assert(!rows.some(r=>r[1]==='2637'));
const data=[source[0],...rows];
const wb=Workbook.create();const s=wb.worksheets.add('courses');
s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;wb.recalculate();
const quote=v=>'"'+String(v).replaceAll('"','""')+'"';
const rel='../combo/BIT_IS_K19B/combo_courses.csv';
await fs.writeFile(new URL(rel,import.meta.url),'\ufeff'+data.map(r=>r.map(quote).join(',')).join('\r\n')+'\r\n','utf8');
assert.deepEqual(await read(rel),data);
console.log(JSON.stringify({curriculum:'BIT_IS_K19B',rows:rows.length,counts:Object.fromEntries([...ids].map(id=>[id,rows.filter(r=>r[1]===id).length]))}));
