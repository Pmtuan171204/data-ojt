import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {Workbook} from '@oai/artifact-tool';
const code='BIT_SE_K18D_19A';
async function read(path){
 const w=await Workbook.fromCSV((await fs.readFile(path,'utf8')).replace(/^\ufeff/,''),{sheetName:'data'});
 return w.worksheets.getItemAt(0).getUsedRange().values.map(r=>r.map(v=>String(v??'')));
}
const definitions=[
 ['26','PHE_COM1: Vovinam BIT_GD_K16D,K17A',''],
 ['334','PHE_COM2: Cờ vua BIT_SE_K15A',''],
 ['340','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A',''],
 ['402','SE_COM6: Topic on Information Technology - Korean Language_Chủ đề Công nghệ thông tin - tiếng Hàn BIT_SE_K15C',''],
 ['1469','SE_COM5.1.1:Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật CNTT: Lựa chọn JFE301 và 1 trong 2 học phần JIS401, JIT401 để triển khai ở kỳ 8) BIT_SE_K15C',''],
 ['2566','SE_COM7.1:Topic on AI_Chủ đề AI','Topic on AI_Chủ đề AI'],
 ['2553','SE_COM9: Topic on SAP_Chủ đề SAP','']];
const source=await read(new URL('../../IS/combo/BIT_IS_K18D_19A/combo_courses.csv',import.meta.url));
const sports=source.slice(1).filter(r=>['26','334'].includes(r[1])).sort((a,b)=>Number(a[2])-Number(b[2]));
assert.deepEqual(sports.map(r=>[r[1],r[2],r[3],r[5]]),[
 ['26','82','VOV114','0'],['26','83','VOV124','1'],['26','84','VOV134','2'],
 ['334','1398','COV111','0'],['334','1399','COV121','1'],['334','1400','COV131','2']]);
const subjects=[
 ['340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5'],
 ['340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7'],
 ['340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8'],
 ['402','4760','KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1','7'],
 ['402','4761','KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2','8'],
 ['402','4762','KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3','8'],
 ['1469','6206','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5'],
 ['1469','6207','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7'],
 ['1469','6208','JIS401','Tiếng Nhật CNTT trong ngành phần mềm','8'],
 ['1469','6209','JIT401','Information Technology Japanese_Tiếng Nhật công nghệ thông tin','8'],
 ['1469','6210','JFE301','Japanese IT Fundamentals_Kỹ năng CNTT cơ bản của Nhật Bản','8'],
 ['2566','6661','PRP201c','Python Programming_Lập trình Python','5'],
 ['2566','6662','DPL303m','Deep Learning_Học sâu','8'],
 ['2566','6668','AIL304m','Machine Learning_Học máy','7'],
 ['2566','6669','DBM301','Data mining_Khai phá dữ liệu','7'],
 ['2553','6598','SAP311','SAP General 1 - Tổng quan về SAP 1','7'],
 ['2553','6599','SAP321','SAP General 2 - Tổng quan về SAP 2','7'],
 ['2553','6613','ACC101','Principles of Accounting_Nguyên lý kế toán','5'],
 ['2553','6671','SAP341','SAP Application Development with ABAP_Phát triển ứng dụng SAP với ABAP','8']];
definitions.push(
 ['2497','SE_COM4.1: Topic on React/NodeJS_Chủ đề React/NodeJS',''],
 ['2605','SE_COM11: Topic on IC design_Chủ đề Thiết kế vi mạch',''],
 ['2640','SE_COM10.2: Topic on Intensive Java_Chủ đề Java chuyên sâu_K19A',''],
 ['2638','SE_COM13: Topic on DevSepOps for cloud_Chủ đề Tích hợp DevSepOps cho cloud',''],
 ['2628','SE_COM12: Topic on Game Development_Phát triển game',''],
 ['2686','SE_COM3.3: Topic on .NET Programming_Chủ đề lập trình .NET BIT_SE_From_K18C',''],
 ['2639','SE_COM14.0: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','']);
subjects.push(
 ['2497','6327','WDP301','Web Development Project_Dự án phát triển web','8'],
 ['2497','6706','FER202','Front-End web development with React_Phát triển web Front-End với React','5'],
 ['2497','6707','MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng','7'],
 ['2497','6823','SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB','7'],
 ['2605','6856','MIP201','Microcontroller Programming_Lập trình vi điều khiển','7'],
 ['2605','6857','DCD301','Digital Circuit Design_Thiết kế vi mạch số','7'],
 ['2605','6858','ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự','8'],
 ['2605','6901','ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử','5'],
 ['2640','7010','HSF302','Working with Spring Framework_Làm việc với Spring Framework','5'],
 ['2640','7011','SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot','7'],
 ['2640','7012','MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud','8'],
 ['2638','7002','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5'],
 ['2638','7003','PRC392m','Cloud Computing_Điện toán đám mây','7'],
 ['2638','7004','ASP301','Application Security_Bảo mật ứng dụng','7'],
 ['2638','7005','DSO391','DevSecOps for Cloud_Tích hợp DevSecOps cho Cloud','8'],
 ['2628','6955','FGU301','Fundamental Game Development_Phát triển game cơ bản','5'],
 ['2628','6956','AGU301','Advanced Game Development_Phát triển game nâng cao','7'],
 ['2628','6957','GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện','7'],
 ['2628','6958','GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao','8'],
 ['2686','7219','PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET','5'],
 ['2686','7220','PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET','7'],
 ['2686','7221','PRU213','Game Programming with C#_Lập trình Game với C#','7'],
 ['2686','7222','PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET','8'],
 ['2639','7167','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5'],
 ['2639','7168','BDI302c','Big Data_Dữ liệu lớn','7'],
 ['2639','7169','DBM302m','Data Mining_Khai phá dữ liệu','7'],
 ['2639','7170','DSP391m','Data Science - Capstone Project_Dự án KHDL','8']);
const combos=[['curriculum_code','combo_id','combo_name','selection_group','note'],...definitions.map(([id,name,note])=>[code,id,name,'',note])];
const courses=[source[0],...sports.map(r=>[code,...r.slice(1)]),...subjects.map(r=>[code,...r,'','',''])];
assert.equal(combos.length,15);
assert.equal(courses.length,53);assert.equal(new Set(courses.slice(1).map(r=>r[1]+':'+r[2])).size,52);
assert.deepEqual(new Set(courses.slice(1).map(r=>r[1])),new Set(definitions.map(r=>r[0])));
const semesters={'26':['0','1','2'],'334':['0','1','2'],'340':['5','7','8'],'402':['7','8','8'],'1469':['5','7','8','8','8'],'2566':['5','8','7','7'],'2553':['7','7','5','8']};
Object.assign(semesters,{'2497':['8','5','7','7'],'2605':['7','7','8','5'],'2640':['5','7','8'],'2638':['5','7','7','8'],'2628':['5','7','7','8'],'2686':['5','7','7','8'],'2639':['5','7','7','8']});
for(const [id,expected] of Object.entries(semesters))assert.deepEqual(courses.slice(1).filter(r=>r[1]===id).map(r=>r[5]),expected);
await fs.mkdir(new URL(`../combo/${code}/`,import.meta.url),{recursive:true});
for(const [file,data] of [['combos.csv',combos],['combo_courses.csv',courses]]){
 const w=Workbook.create(),s=w.worksheets.add('data');
 s.getRangeByIndexes(0,0,data.length,data[0].length).values=data;w.recalculate();
 const path=new URL(`../combo/${code}/${file}`,import.meta.url),q=v=>'"'+String(v).replaceAll('"','""')+'"';
 const old=await read(path);
 for(const row of old.slice(1))assert.ok(data.some(r=>JSON.stringify(r)===JSON.stringify(row)),'Existing row changed');
 await fs.writeFile(path,'\ufeff'+data.map(r=>r.map(q).join(',')).join('\r\n')+'\r\n','utf8');
 assert.deepEqual(await read(path),data);console.log(`${file}: ${data.length-1} rows verified`);
}
