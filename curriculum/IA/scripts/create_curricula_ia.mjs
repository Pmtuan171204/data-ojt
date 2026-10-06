import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import { Workbook } from '@oai/artifact-tool';
const curricula=[
 ['BIT_IA_K18D-19A',145],
 ['BIT_IA_K18D-19A_FNO',145],
 ['BIT_IA_K19B_FNO',145],
 ['BIT_IA_K19D-20A',145],
 ['BIT_IA_K20B',111],
 ['BIT_IA_K20B_FNO',108],
 ['BIT_IA_K20C',111],
 ['BIT_IA_K20D-21A',111],
 ['BIT_IA_K21B',111],
 ['BIT_IA_K21C',111],
 ['BIT_IA_K21D-22A',114],
];
const data=[['curriculum_code','curriculum_name','specialization','total_credits'],...curricula.map(([code,credits])=>[code,'Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','An toàn thông tin',credits])];
const wb=Workbook.create();
const sheet=wb.worksheets.add('curricula');
sheet.getRange('A1:D12').values=data;
wb.recalculate();
assert.equal(new Set(curricula.map(r=>r[0])).size,11);
assert.equal(curricula.filter(r=>r[0].endsWith('_FNO')).length,3);
assert.equal(curricula.reduce((s,r)=>s+r[1],0),1357);
const escape=v=>'"'+String(v).replaceAll('"','""')+'"';
const path='D:/data/curriculum/IA/curricula_ia.csv';
await fs.mkdir('D:/data/curriculum/IA',{recursive:true});
await fs.writeFile(path,'\ufeff'+sheet.getRange('A1:D12').values.map(r=>r.map(escape).join(',')).join('\r\n')+'\r\n','utf8');
const saved=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'check'});
assert.deepEqual(saved.worksheets.getItemAt(0).getUsedRange().values,data.map(r=>r.map(String)));
console.log('Verified 11 unique IA curricula, 4 columns, 3 FNO variants. Credits: 108, 111, 114, 145.');
