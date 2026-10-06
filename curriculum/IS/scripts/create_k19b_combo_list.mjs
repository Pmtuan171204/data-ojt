import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
// IDs and names confirmed in the user's K19B screenshot; reuse matching names only.
const src=await Workbook.fromCSV((await fs.readFile(new URL('../combo/BIT_IS_K18D_19A/combos.csv',import.meta.url),'utf8')).replace(/^\ufeff/,''),{sheetName:'source'});
const source=src.worksheets.getItemAt(0).getUsedRange().values;
const ids=['26','334','2636','2641','2634','2635'];
const data=[['curriculum_code','combo_id','combo_name','selection_group','note'],...ids.map(id=>{
 const row=source.slice(1).find(r=>String(r[1])===id);assert(row);
 return ['BIT_IS_K19B',id,row[2],'',''];
})];
const wb=Workbook.create();const s=wb.worksheets.add('combos');s.getRange('A1:E7').values=data;wb.recalculate();
const path=new URL('../combo/BIT_IS_K19B/combos.csv',import.meta.url);
const q=v=>'"'+String(v).replaceAll('"','""')+'"';
await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
const check=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'check'});
assert.deepEqual(check.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??''))),data);
console.log('Verified 6 K19B combos; no course details copied from another curriculum.');
