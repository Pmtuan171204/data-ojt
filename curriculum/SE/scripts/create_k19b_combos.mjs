import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const code='BIT_SE_K19B',ids=['26','334','340','402','1469','2566','2497','2605','2640','2638','2628','2675','2686'];
async function read(path){
 const w=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return w.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const base=new URL('../combo/BIT_SE_K18D_19A/',import.meta.url);
const oldCombos=await read(new URL('combos.csv',base)),oldCourses=await read(new URL('combo_courses.csv',base));
const combos=[oldCombos[0],...ids.map(id=>{
 if(id==='2675')return [code,id,'SE_COM14: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng_K19B','',''];
 const row=oldCombos.slice(1).find(r=>r[1]===id);assert.ok(row);return [code,...row.slice(1)];
})];
const courses=[oldCourses[0],...oldCourses.slice(1).filter(r=>ids.includes(r[1])).sort((a,b)=>ids.indexOf(a[1])-ids.indexOf(b[1])).map(r=>[code,...r.slice(1)])];
for(const row of courses.slice(1))assert.ok(oldCourses.some(r=>JSON.stringify(r.slice(1))===JSON.stringify(row.slice(1))));
const added=[
 ['7175','PDS301m','Python for Applied Data Science_Lập trình Python cho khoa học dữ liệu ứng dụng','5'],
 ['7176','DHV301','Data Handling and Visualization_Xử lý và Trực quan hóa Dữ liệu','7'],
 ['7177','MDS301','Machine Learning in Data Science_Học máy trong khoa học dữ liệu','7'],
 ['7178','BDT301','Big Data Technologies & Tools_Công cụ và kỹ thuật trên dữ liệu lớn.','8']
].map(r=>[code,'2675',...r,'','','']);
courses.push(...added);
const header=courses.shift();courses.sort((a,b)=>ids.indexOf(a[1])-ids.indexOf(b[1]));courses.unshift(header);
assert.equal(combos.length,14);assert.equal(courses.length,49);
assert.deepEqual(new Set(courses.slice(1).map(r=>r[1])),new Set(ids));
assert.equal(new Set(courses.slice(1).map(r=>r[1]+':'+r[2])).size,48);
assert.deepEqual(added.map(r=>r[5]),['5','7','7','8']);
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const w=Workbook.create(),s=w.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;w.recalculate();
 const path=new URL(`../combo/${code}/${file}`,import.meta.url),q=v=>'"'+String(v).replaceAll('"','""')+'"';
 const existing=await read(path);
 for(const row of existing.slice(1))assert.ok(data.some(r=>JSON.stringify(r)===JSON.stringify(row)),'Existing row changed');
 await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(path),data);console.log(`${file}: ${data.length-1} rows verified`);
}
