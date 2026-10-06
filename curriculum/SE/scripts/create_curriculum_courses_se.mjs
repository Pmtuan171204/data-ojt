import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import { Workbook } from '@oai/artifact-tool';
const payload=JSON.parse(await fs.readFile(new URL('../../../intermediate/curriculum/SE/courses_extracted.json',import.meta.url),'utf8'));
await fs.mkdir(new URL('../courses/',import.meta.url),{recursive:true});
let exported=0;
for (const code of [...new Set(payload.rows.map(r=>r[0]))]) {
assert(/^[A-Za-z0-9_-]+$/.test(code));
const data=[payload.headers,...payload.rows.filter(r=>r[0]===code)];
const wb=Workbook.create();const sh=wb.worksheets.add('courses');
sh.getRangeByIndexes(0,0,data.length,6).values=data; wb.recalculate();
const values=sh.getRangeByIndexes(0,0,data.length,6).values;
const q=v=>'"'+String(v??'').replaceAll('"','""')+'"';
const path=new URL(`../courses/${code}.csv`,import.meta.url);
await fs.writeFile(path,'\ufeff'+values.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
const check=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'check'});
assert.deepEqual(check.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??''))),data.map(r=>r.map(String)));
exported+=data.length-1;
console.log(`${code}: ${data.length-1} rows`);
}
assert.equal(exported,payload.rows.length);
await fs.mkdir(new URL('../../../reports/curriculum/SE/',import.meta.url),{recursive:true});
await fs.writeFile(new URL('../../../reports/curriculum/SE/course_extraction_status.json',import.meta.url),JSON.stringify({sources:payload.sources,missing_curricula:payload.missing_curricula},null,2),'utf8');
console.log(`Verified ${payload.rows.length} rows from ${payload.sources.length} curriculum source(s).`);



