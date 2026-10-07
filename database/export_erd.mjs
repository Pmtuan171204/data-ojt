// Build ERD documentation from the installed final schema, including ALTER TABLE changes.
import fs from 'node:fs/promises';
import crypto from 'node:crypto';
import {PGlite} from './.test-tools/pglite/package/dist/index.js';
const db=new PGlite();
const root=new URL('./',import.meta.url);
const sql=await fs.readFile(new URL('OJT_RPA_FULL_SUPABASE.sql',root),'utf8');
const groups=[
 ['Tài khoản và phân quyền',{
 Roles:'Vai trò người dùng',Permissions:'Danh mục quyền',RolePermissions:'Liên kết vai trò và quyền',Users:'Tài khoản đăng nhập backend'}],
 ['Chương trình đào tạo và môn học',{
 AcademicYears:'Năm học',OJTSemesters:'Kỳ OJT',AcademicMajors:'Ngành đào tạo',Specializations:'Chuyên ngành thuộc ngành',TrainingPrograms:'Khung chương trình theo khóa',Courses:'Danh mục môn học',CoursePrerequisites:'Quan hệ môn tiên quyết chung',ProgramCourses:'Môn học thuộc khung chương trình',ProgramPrerequisiteGroups:'Nhóm điều kiện tiên quyết theo khung',ProgramPrerequisiteMembers:'Môn thành viên nhóm tiên quyết',OJTEligibilityConditions:'Điều kiện tham gia OJT',EligibilityRequiredCourses:'Các môn bắt buộc theo điều kiện OJT'}],
 ['Combo và lựa chọn của sinh viên',{
 ProgramCombos:'Combo thuộc từng khung chương trình',ComboCourses:'Môn học trong combo',ComboCourseChoiceGroups:'Nhóm môn cho phép lựa chọn trong combo',ComboCourseChoiceMembers:'Các môn thuộc nhóm lựa chọn',ProgramSlotOptions:'Ánh xạ lựa chọn vào ô môn của chương trình',StudentComboSelections:'Combo sinh viên đã chọn',StudentComboCourseSelections:'Các môn lựa chọn của sinh viên trong combo'}],
 ['Sinh viên, học tập và hỗ trợ',{
 Students:'Hồ sơ sinh viên',StudentCourseResults:'Kết quả môn học của sinh viên',StudentAcademicSnapshot:'Ảnh chụp trạng thái học tập tại thời điểm',StudentOJTEligibility:'Kết quả xét điều kiện OJT',PathwayRecommendations:'Tư vấn lộ trình do nhân sự quản lý',SupportClasses:'Lớp hỗ trợ',SupportClassRegistrations:'Sinh viên đăng ký lớp hỗ trợ',SupportRequests:'Yêu cầu hỗ trợ của người dùng'}],
 ['Doanh nghiệp và tuyển dụng',{
 Enterprises:'Doanh nghiệp',EnterpriseUsers:'Liên kết tài khoản với doanh nghiệp',JobRoles:'Danh mục nhóm nghề/vai trò công việc',InternshipPositions:'Vị trí tuyển OJT theo doanh nghiệp và kỳ',PositionSpecializations:'Chuyên ngành vị trí chấp nhận',RecruitmentPosts:'Bài tuyển dụng',RecruitmentPostPositions:'Liên kết bài tuyển dụng và vị trí',JobApplications:'Đơn ứng tuyển vào vị trí thuộc bài tuyển dụng'}],
 ['Đăng ký và theo dõi OJT',{
 OJTRegistrations:'Đăng ký OJT của sinh viên',StudentEnterpriseCoordination:'Điều phối sinh viên đến doanh nghiệp',InternshipAssignments:'Phân công thực tập',InternshipTasks:'Nhiệm vụ trong đợt thực tập',TaskProgressUpdates:'Cập nhật tiến độ nhiệm vụ',IncidentReports:'Báo cáo sự cố',InternshipEvaluations:'Đánh giá thực tập'}],
 ['Thông báo và quản trị',{
 NotificationTemplates:'Mẫu thông báo',Notifications:'Thông báo gửi người dùng',AuditLogs:'Nhật ký thao tác',SchemaMigrations:'Phiên bản migration đã áp dụng'}],
 ['Import và hồ sơ matching — migration 07',{
 OJTEnterpriseImportBatches:'Đợt import doanh nghiệp',OJTEnterpriseImportRows:'Dòng dữ liệu import và lỗi chuẩn hóa',MatchingSkills:'Danh mục kỹ năng chuẩn hóa',StudentCareerProfiles:'Hồ sơ nghề nghiệp bổ sung cho sinh viên',StudentMatchingSkills:'Kỹ năng của sinh viên',StudentCareerInterests:'Nhóm nghề sinh viên quan tâm',OJTMatchingProfiles:'Hồ sơ matching vị trí có JD hoặc doanh nghiệp không JD',MatchingProfileMajors:'Ngành được nhận của profile',MatchingProfileSpecializations:'Chuyên ngành được nhận của profile',MatchingProfileJobRoles:'Nhóm công việc của profile',MatchingProfileSkills:'Kỹ năng bắt buộc/mong muốn của profile',MatchingProfileCourses:'Yêu cầu môn học của profile'}],
 ['Cảnh báo tiến độ OJT — migration 09',{OJTAlertTargets:'Danh sách sinh viên cần theo dõi theo kỳ',OJTAlertRules:'Quy tắc cảnh báo có phiên bản',OJTAlertCheckRuns:'Lần chạy kiểm tra cảnh báo',OJTAlertEvaluations:'Kết quả đánh giá điều kiện theo đối tượng',OJTAlerts:'Cảnh báo đang mở hoặc đã đóng',OJTAlertEvents:'Lịch sử xử lý cảnh báo',OJTAlertDeliveries:'Hàng đợi và kết quả gửi thông báo'}],
 ['Embedding và kết quả đề xuất — migration 07',{
 EmbeddingConfigurations:'Cấu hình dịch vụ embedding ngoài',MatchingEmbeddings:'Vector và cache theo nội dung, chủ thể, cấu hình',MatchingRuns:'Lần chạy matching cho một sinh viên và kỳ OJT',MatchingCandidates:'Các profile được xét và kết quả lọc trong lần chạy',MatchingAPICalls:'Lịch sử các lần gọi Embedding API',MatchingRecommendations:'Kết quả phù hợp, điểm, thứ hạng và vector sử dụng',MatchingRecommendationFeedback:'Phản hồi hiện tại của sinh viên về đề xuất'}]
];
const q=s=>'"'+s.replaceAll('"','""')+'"';
const str=s=>"'"+s.replaceAll('\\','\\\\').replaceAll("'","\\'").replaceAll('\n','\\n')+"'";
try {
 await db.exec(sql);
 const tables=(await db.query(`SELECT c.relname AS name,c.oid,obj_description(c.oid) AS comment FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname`)).rows;
 const columns=(await db.query(`SELECT c.relname AS tbl,a.attname AS name,a.attnum,format_type(a.atttypid,a.atttypmod) AS type,a.attnotnull AS required,a.attidentity AS identity,a.attgenerated AS generated,pg_get_expr(d.adbin,d.adrelid) AS def,col_description(c.oid,a.attnum) AS comment FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace JOIN pg_attribute a ON a.attrelid=c.oid LEFT JOIN pg_attrdef d ON d.adrelid=c.oid AND d.adnum=a.attnum WHERE n.nspname='public' AND c.relkind='r' AND a.attnum>0 AND NOT a.attisdropped ORDER BY c.relname,a.attnum`)).rows;
 const constraints=(await db.query(`SELECT c.relname AS tbl,k.conname AS name,k.contype AS kind,k.conkey AS keys,k.confkey AS targetkeys,t.relname AS target,k.confdeltype AS del,k.confupdtype AS upd,pg_get_constraintdef(k.oid,true) AS definition FROM pg_constraint k JOIN pg_class c ON c.oid=k.conrelid JOIN pg_namespace n ON n.oid=c.relnamespace LEFT JOIN pg_class t ON t.oid=k.confrelid WHERE n.nspname='public' ORDER BY c.relname,k.conname`)).rows;
 const indexes=(await db.query(`SELECT c.relname AS tbl,i.relname AS name,x.indisunique AS unique,x.indisprimary AS primary,x.indkey::smallint[] AS keys,pg_get_expr(x.indpred,x.indrelid) AS predicate,pg_get_indexdef(x.indexrelid) AS definition FROM pg_index x JOIN pg_class c ON c.oid=x.indrelid JOIN pg_class i ON i.oid=x.indexrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' ORDER BY c.relname,i.relname`)).rows;
 const names=(tbl,keys)=>keys.map(k=>columns.find(c=>c.tbl===tbl&&c.attnum===k)?.name ?? '[expression]');
 const fks=constraints.filter(c=>c.kind==='f');
 const known=new Set(groups.flatMap(([,m])=>Object.keys(m)));
 if(tables.some(t=>!known.has(t.name))||known.size!==tables.length)throw Error('Update table descriptions: schema inventory changed');
 let text=`TÀI LIỆU BẢNG VÀ QUAN HỆ ĐỂ VẼ ERD — OJT-RPA\n=============================================\n\nNguồn: OJT_RPA_FULL_SUPABASE.sql hiện tại, đã thực thi trên PostgreSQL WASM\nrồi đọc catalog; bao gồm các thay đổi ALTER TABLE và migration 07/09.\nSHA-256 nguồn: ${crypto.createHash('sha256').update(sql).digest('hex')}\n\nTổng: ${tables.length} bảng, ${columns.length} cột, ${fks.length} ràng buộc khóa ngoại.\nĐây là schema của file SQL mới nhất, KHÔNG phải kiểm tra trực tiếp Supabase.\n19 bảng matching cần migration 07; 7 bảng cảnh báo cần migration 09, hoặc bản full mới.\nKhông có dữ liệu sinh viên mẫu trong bản full. Các bảng AI dự đoán cũ đã bỏ.\n\nCÁCH ĐỌC\n- PK: khóa chính; FK: khóa ngoại; UQ: khóa duy nhất; NULL: được để trống.\n- Bảng con chứa FK, bảng cha là bảng được REFERENCES.\n- FK ghép phải nối cả nhóm cột thành MỘT quan hệ, không tách từng cột.\n- Cha 1 -> con 0..N là quan hệ thường gặp; 0..1 khi FK phía con là duy nhất.\n- FK bắt buộc: mỗi dòng con có đúng 1 cha. FK nullable: con có thể không có cha.\n- Không suy ra FK chỉ vì tên cột kết thúc ID; chỉ các FK liệt kê là ràng buộc DB.\n- Unique index có WHERE chỉ áp dụng cho các dòng thỏa điều kiện, không phải UQ toàn bảng.\n- CHECK/trigger/quy tắc backend không thay thế bằng đường nối ERD.\n\nTệp OJT_RPA_ERD.dbml dùng để dựng sơ đồ bằng công cụ hỗ trợ DBML.\nDBML biểu diễn bảng/cột/PK/UQ toàn bảng/FK; default, CHECK và unique có điều kiện\nđược ghi chú. File SQL vẫn là nguồn chuẩn để tạo DB, không sinh ngược migration từ DBML.\n\nA. DANH SÁCH BẢNG THEO NHÓM\n`;
 for(const [g,map] of groups){text+=`\n${g}\n`;for(const [name,purpose] of Object.entries(map))text+=`  ${name}: ${purpose}.\n`;}
 text+='\nB. CHI TIẾT TỪNG BẢNG\n';
 let dbml='// Generated from the final PostgreSQL schema; use SQL for deployment.\n// Partial/expression indexes and CHECKs are notes, not executable DBML constraints.\n\n';
 for(const [g,map] of groups)for(const [name,purpose] of Object.entries(map)){
  const cols=columns.filter(c=>c.tbl===name),cons=constraints.filter(c=>c.tbl===name),idx=indexes.filter(i=>i.tbl===name);
  const pk=cons.find(c=>c.kind==='p');
  text+=`\n${name} — ${purpose}\n${'-'.repeat(65)}\n`;
  dbml+=`Table ${q(name)} {\n`;
  for(const col of cols){
   const tags=[];if(pk?.keys.includes(col.attnum))tags.push('PK');if(cons.some(c=>c.kind==='f'&&c.keys.includes(col.attnum)))tags.push('FK');
   text+=`  ${col.name} | ${col.type} | ${col.required?'NOT NULL':'NULL'}${tags.length?' | '+tags.join(', '):''}${col.identity?' | IDENTITY':''}${col.def?(col.generated?' | GENERATED STORED ':' | DEFAULT ')+col.def:''}\n`;
   const opts=[col.required?'not null':'null'];if(col.identity)opts.push('increment');
   const notes=[col.comment,col.def?(col.generated?'PostgreSQL generated stored expression: ':'PostgreSQL default: ')+col.def:null].filter(Boolean);if(notes.length)opts.push('note: '+str(notes.join(' / ')));
   dbml+=`  ${q(col.name)} ${q(col.type)} [${opts.join(', ')}]\n`;
  }
  text+='  Ràng buộc:\n';for(const c of cons)text+=`    ${c.name}: ${c.definition}\n`;
  const uniques=idx.filter(i=>i.unique&&!i.predicate&&!i.keys.includes(0));
  if(uniques.length){dbml+='  indexes {\n';for(const i of uniques)dbml+=`    (${names(name,i.keys).map(q).join(', ')}) [${i.primary?'pk':'unique'}, name: ${str(i.name)}]\n`;dbml+='  }\n';}
  const special=idx.filter(i=>i.predicate||i.keys.includes(0));
  const check=cons.filter(c=>c.kind==='c').map(c=>c.definition);
  dbml+='  Note: '+str([purpose,...check,...special.map(i=>i.definition)].join('\n'))+'\n}\n\n';
  if(special.length){text+='  Index có điều kiện/biểu thức:\n';for(const i of special)text+=`    ${i.definition}\n`;}
 }
 text+='\nC. DANH SÁCH QUAN HỆ KHÓA NGOẠI\n';
 const actions={a:'no action',r:'restrict',c:'cascade',n:'set null',d:'set default'};
 for(const [i,f] of fks.entries()){
  const unique=indexes.some(x=>x.tbl===f.tbl&&x.unique&&!x.predicate&&!x.keys.includes(0)&&x.keys.every(k=>f.keys.includes(k)));
  const nullable=f.keys.some(k=>!columns.find(c=>c.tbl===f.tbl&&c.attnum===k).required);
  text+=`${i+1}. ${f.tbl}(${names(f.tbl,f.keys).join(', ')}) -> ${f.target}(${names(f.target,f.targetkeys).join(', ')})\n`;
  text+=`   Cha -> con: 1 -> ${unique?'0..1':'0..N'}; con -> cha: ${nullable?'0..1 (FK có cột nullable)':'1 (bắt buộc)'}. DELETE ${actions[f.del].toUpperCase()}; UPDATE ${actions[f.upd].toUpperCase()}.\n`;
  dbml+=`Ref FK_${i+1}: ${q(f.tbl)}.(${names(f.tbl,f.keys).map(q).join(', ')}) > ${q(f.target)}.(${names(f.target,f.targetkeys).map(q).join(', ')}) [delete: ${actions[f.del]}, update: ${actions[f.upd]}]\n`;
 }
 text+='\nD. LƯU Ý KHI VẼ\n- Chia ERD thành các nhóm ở mục A; dùng Students, Users, TrainingPrograms,\n  Enterprises, OJTSemesters và OJTMatchingProfiles làm các điểm nối giữa sơ đồ.\n- Các bảng liên kết nhiều-nhiều vẫn phải vẽ thành thực thể có PK/FK; không bỏ\n  bảng trung gian có thuộc tính nghiệp vụ (điểm, kỳ, độ ưu tiên, trạng thái...).\n- StudentCareerProfiles dùng StudentID làm PK/FK: một sinh viên có 0 hoặc 1 hồ sơ.\n- MatchingRecommendationFeedback dùng RecommendationID làm PK/FK: tối đa một\n  phản hồi hiện tại cho mỗi đề xuất, không phải bảng lịch sử sự kiện.\n- OJTMatchingProfiles có hai loại: POSITION tham chiếu vị trí, ENTERPRISE_OJT\n  không tham chiếu vị trí. CHECK quyết định nhánh; PositionID nullable là có chủ ý.\n- MatchingEmbeddings thuộc đúng một StudentID hoặc ProfileID nhờ CHECK; không\n  vẽ hai FK này như hai chủ thể luôn bắt buộc đồng thời.\n- StudentID/EmbeddingConfigID lặp trong MatchingRecommendations phục vụ FK ghép\n  để bảo đảm đúng run và đúng vector; không xóa khỏi ERD vì thấy trùng thông tin.\n- Các quy tắc filter, consent, top-K, kiểm tra hết hạn và quyền sở hữu do backend\n  thực thi như mô tả trong EMBEDDING_MATCHING.txt; sơ đồ FK không thể hiện hết.\n';
 await fs.writeFile(new URL('ERD_DATABASE.txt',root),text);
 await fs.writeFile(new URL('OJT_RPA_ERD.dbml',root),dbml);
 console.log(JSON.stringify({tables:tables.length,columns:columns.length,foreignKeys:fks.length,files:['ERD_DATABASE.txt','OJT_RPA_ERD.dbml']}));
}finally{await db.close();}
