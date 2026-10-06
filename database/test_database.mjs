// Local PostgreSQL WASM integration tests; never connects to Supabase.
import { PGlite } from './.test-tools/pglite/package/dist/index.js';
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
const read = f => fs.readFile(new URL(f,import.meta.url),'utf8');
const db = new PGlite();
const passed=[];
const q=async s=>(await db.query(s)).rows;
const value=async s=>Object.values((await q(s))[0])[0];
async function fails(label,sql,code){
 try { await db.exec(sql); } catch(e) {if(code)assert.equal(e.code,code,`${label}: ${e.message}`);passed.push(label);return;}
 throw Error(`Expected rejection: ${label}`);
}
try {
 await db.exec('CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role BYPASSRLS;');
 await db.exec(await read('00_base_for_empty_database.sql'));
 // Representative existing data, to verify additive migration and preservation.
 await db.exec(`INSERT INTO "TrainingPrograms" ("ProgramCode","ProgramName","Specialty","TotalCredits") VALUES ('DS','Legacy DS','DS',130);
 INSERT INTO "Users" ("Username","PasswordHash","Email","FullName","RoleID")
 SELECT 'test-user','not-a-real-login-hash','test@example.invalid','Test user',"RoleID" FROM "Roles" WHERE "RoleCode"='STUDENT';
 INSERT INTO "Students" ("UserID","StudentCode","ProgramID") SELECT 1,'LEGACY',"ProgramID" FROM "TrainingPrograms" WHERE "ProgramCode"='DS';
 INSERT INTO "Courses" ("CourseCode","CourseName","Credits") VALUES ('LEGACY101','Legacy course',3);
 INSERT INTO "ProgramCourses" ("ProgramID","CourseID","RecommendedSemester","IsRequired") VALUES (1,1,1,true);
 INSERT INTO "StudentCourseResults" ("StudentID","CourseID","SemesterTaken","Score") VALUES (1,1,1,8.5);`);
 await db.exec(await read('01_upgrade_it.sql'));
 await db.exec(await read('02_catalog_data.sql'));
 passed.push('base + migration + catalog execute');
 const expected=JSON.parse(await read('source_manifest.json')).counts;
 assert.equal(await value('SELECT count(*)::int FROM "TrainingPrograms" WHERE "CatalogManaged"'),expected.programs);
 assert.equal(await value('SELECT count(*)::int FROM "ProgramCourses"'),expected.program_courses+1);
 assert.equal(await value('SELECT count(*)::int FROM "ProgramCombos"'),expected.program_combos);
 assert.equal(await value('SELECT count(*)::int FROM "ComboCourses"'),expected.combo_courses);
 assert.equal(await value('SELECT count(*)::int FROM "Courses"'),expected.distinct_course_codes+1);
 passed.push('catalog counts match all CSVs');
 assert.equal(await value(`SELECT "ProgramCode" FROM "Students" s JOIN "TrainingPrograms" p ON p."ProgramID"=s."ProgramID" WHERE s."StudentCode"='LEGACY'`),'DS');
 assert.equal(await value(`SELECT "SpecializationID" FROM "TrainingPrograms" WHERE "ProgramCode"='DS'`),null);
 passed.push('legacy student and unmapped DS preserved');
 assert.equal(Number(await value('SELECT "Score" FROM "StudentCourseResults" WHERE "StudentID"=1')),8.5);
 assert.equal(Number(await value('SELECT "Credits" FROM "ProgramCourses" WHERE "ProgramCourseID"=1')),3);
 passed.push('legacy course, program credit and student result preserved');
 await db.exec(await read('02_catalog_data.sql'));
 assert.equal(await value('SELECT count(*)::int FROM "ProgramCourses"'),expected.program_courses+1);
 assert.equal(await value('SELECT count(*)::int FROM "ComboCourses"'),expected.combo_courses);
 passed.push('catalog seed can be rerun without duplication');
 await db.exec(await read('03_verify.sql'));
 assert.equal((await q(`SELECT p."ProgramCode" FROM "TrainingPrograms" p JOIN "ProgramCourses" pc USING ("ProgramID")
   WHERE p."CatalogManaged" GROUP BY p."ProgramID" HAVING sum(pc."Credits") IS DISTINCT FROM p."TotalCredits"`)).length,0);
 passed.push('verification queries execute; credit totals match all 40 curricula');
 assert.equal(await value('SELECT count(*)::int FROM "ComboCourses" WHERE "Credits" IS NOT NULL'),0);
 assert.ok(await value('SELECT count(*)::int FROM "ProgramCourses" WHERE "RecommendedSemester"=0')>0);
 assert.ok(await value('SELECT count(*)::int FROM "ProgramCourses" WHERE "EntryKind"=\'COMBO_SLOT\'')>0);
 passed.push('unknown combo credits, semester zero and placeholders preserved');
 const newCodes=(await q(`SELECT c."CourseCode" FROM "ComboCourses" cc JOIN "Courses" c USING ("CourseID")
 JOIN "ProgramCombos" b USING ("ProgramComboID") JOIN "TrainingPrograms" p USING ("ProgramID")
 WHERE p."ProgramCode"='BIT_SE-2026_K21D_K22A' AND b."SourceComboID"<>340 ORDER BY cc."SourceComboSubjectID"`)).map(r=>r.CourseCode);
 assert.deepEqual(newCodes,['AQA301','SQA301','TAI301','QCT301','ALF301','LLA301','EIA301','EAS301','BPE301','SLM301','SDS301','EDO301','EFD301','EMD301','BSS301','DDP301']);
 passed.push('all 16 SE-2026 codes retained exactly');
 assert.equal(await value(`SELECT count(*)::int FROM "ComboCourseChoiceGroups" g JOIN "ProgramCombos" b USING ("ProgramComboID")
 JOIN "TrainingPrograms" p USING ("ProgramID") WHERE p."ProgramCode"='BIT_SE_K19B' AND g."GroupCode"='JIS_OR_JIT' AND g."MinCourses"=1 AND g."MaxCourses"=1`),1);
 passed.push('Japanese choose-one rule stored');
 const p1=await value(`SELECT "ProgramID" FROM "TrainingPrograms" WHERE "ProgramCode"='BIT_SE_K19B'`);
 const p2=await value(`SELECT "ProgramID" FROM "TrainingPrograms" WHERE "ProgramCode"='BIT_SE_K19C'`);
 const combo=await value(`SELECT "ProgramComboID" FROM "ProgramCombos" WHERE "ProgramID"=${p1} LIMIT 1`);
 await db.exec(`UPDATE "Students" SET "ProgramID"=${p1} WHERE "StudentID"=1;`);
 await fails('student cannot select another curriculum combo',`INSERT INTO "StudentComboSelections" ("StudentID","ProgramID","ProgramComboID") VALUES (1,${p2},${combo})`,'23503');
 await db.exec(`INSERT INTO "StudentComboSelections" ("StudentID","ProgramID","ProgramComboID") VALUES (1,${p1},${combo});`);
 const selection=await value('SELECT "SelectionID" FROM "StudentComboSelections" LIMIT 1');
 const other=await value(`SELECT "ComboCourseID" FROM "ComboCourses" WHERE "ProgramComboID"<>${combo} LIMIT 1`);
 await fails('course cannot come from another combo',`INSERT INTO "StudentComboCourseSelections" VALUES (${selection},${combo},${other})`,'23503');
 const member=await value(`SELECT "ComboCourseID" FROM "ComboCourses" WHERE "ProgramComboID"=${combo} LIMIT 1`);
 const real=await value(`SELECT "ProgramCourseID" FROM "ProgramCourses" WHERE "ProgramID"=${p1} AND "EntryKind"='COURSE' LIMIT 1`);
 await fails('actual course cannot be used as placeholder',`INSERT INTO "ProgramSlotOptions" VALUES (${p1},${real},${combo},${member})`,'P0001');
 await db.exec(`INSERT INTO "AcademicYears" ("YearCode") VALUES ('TEST');
 INSERT INTO "OJTSemesters" ("AcademicYearID","SemesterCode","Name") VALUES (1,'T1','Test 1'),(1,'T2','Test 2');
 INSERT INTO "Enterprises" ("EnterpriseCode","Name") VALUES ('T1','Test enterprise 1'),('T2','Test enterprise 2');
 INSERT INTO "InternshipPositions" ("EnterpriseID","OJTSemesterID","Title") VALUES (1,1,'Position 1'),(2,1,'Position 2'),(1,2,'Position 3');
 INSERT INTO "RecruitmentPosts" ("EnterpriseID","OJTSemesterID","Title","Content","CreatedBy") VALUES (1,1,'Post','Details',1);
 INSERT INTO "RecruitmentPostPositions" VALUES (1,1,1,1);
 INSERT INTO "OJTRegistrations" ("StudentID","OJTSemesterID") VALUES (1,1),(1,2);`);
 await fails('post cannot link another enterprise position','INSERT INTO "RecruitmentPostPositions" VALUES (1,2,1,1)','23503');
 await fails('post cannot link another semester position','INSERT INTO "RecruitmentPostPositions" VALUES (1,3,1,1)','23503');
 await fails('application cannot use a different OJT semester','INSERT INTO "JobApplications" ("RegistrationID","OJTSemesterID","PostID","PositionID") VALUES (2,1,1,1)','23503');
 await db.exec('INSERT INTO "JobApplications" ("RegistrationID","OJTSemesterID","PostID","PositionID") VALUES (1,1,1,1)');
 await fails('duplicate application rejected','INSERT INTO "JobApplications" ("RegistrationID","OJTSemesterID","PostID","PositionID") VALUES (1,1,1,1)','23505');
 await fails('coordination cannot use other semester',`INSERT INTO "StudentEnterpriseCoordination" ("RegistrationID","EnterpriseID","PositionID","CoordinatedBy") VALUES (1,1,3,1)`,'P0001');
 await db.exec(`INSERT INTO "StudentEnterpriseCoordination" ("RegistrationID","EnterpriseID","PositionID","CoordinatedBy") VALUES (1,1,1,1)`);
 passed.push('valid recruitment application and legacy coordination flow');
 assert.equal(await value(`SELECT count(*)::int FROM pg_tables WHERE schemaname='public' AND NOT rowsecurity`),0);
 await db.exec('SET ROLE anon');
 await fails('anon cannot read Users','SELECT * FROM "Users"','42501');
 await db.exec('RESET ROLE; SET ROLE authenticated');
 await fails('authenticated cannot read private applications','SELECT * FROM "JobApplications"','42501');
 await db.exec('RESET ROLE; SET ROLE service_role');
 assert.ok(await value('SELECT count(*)::int FROM "TrainingPrograms"')>0);
 await db.exec('RESET ROLE');
 passed.push('all tables RLS enabled; backend service_role can query');
 await fails('migration detects a second run',await read('01_upgrade_it.sql'),'P0001');
 await db.exec('ROLLBACK');
 await db.exec(await read('04_student_specialization_combo.sql'));
 assert.equal(await value(`SELECT "SelectionPurpose" FROM "StudentComboSelections" WHERE "SelectionID"=${selection}`),'PHYSICAL_EDUCATION');
 passed.push('existing physical selection classified independently');
 await db.close();
 const fresh=new PGlite();
 await fresh.exec(await read('install_new_database.sql'));
 assert.equal((await fresh.query('SELECT count(*)::int AS n FROM "TrainingPrograms"')).rows[0].n,40);
 const freshFails=async(label,sql,code)=>{
  try{await fresh.exec(sql);}catch(e){assert.equal(e.code,code,`${label}: ${e.message}`);await fresh.exec('ROLLBACK');passed.push(label);return;}
  throw Error(`Expected rejection: ${label}`);
 };
 await freshFails('student import rejects missing profiles',await read('05_import_student_combos.sql'),'P0001');
 // Test-only provisioning, never part of deliverable SQL: invalid hashes disable logins.
 const source=await fs.readFile(new URL('../student/student.csv',import.meta.url),'utf8');
 const matrix=source.replace(/^\ufeff/,'').trimEnd().split(/\r?\n/).map(line=>Array.from(line.matchAll(/"((?:[^"]|"")*)"(?:,|$)/g),m=>m[1].replaceAll('""','"')));
 assert.equal(matrix[0].at(-1),'selected_combo_id');
 const inputs=matrix.slice(1).map(r=>({code:r[0],email:r[2],name:r[1],program:r[6],semester:Number(r[7]),combo:r[9]?Number(r[9]):null}));
 await fresh.query(`CREATE TEMP TABLE test_profiles AS SELECT * FROM jsonb_to_recordset($1::jsonb)
 AS x(code text,email text,name text,program text,semester int,combo int)`,[JSON.stringify(inputs)]);
 await fresh.exec(`INSERT INTO "Users" ("Username","PasswordHash","Email","FullName","RoleID")
 SELECT x.code,'TEST_ONLY_INVALID_HASH',x.email,x.name,r."RoleID" FROM test_profiles x CROSS JOIN "Roles" r WHERE r."RoleCode"='STUDENT';
 INSERT INTO "Students" ("StudentCode","UserID","ProgramID","CurrentSemester")
 SELECT x.code,u."UserID",p."ProgramID",x.semester FROM test_profiles x JOIN "Users" u ON u."Username"=x.code
 JOIN "TrainingPrograms" p ON p."ProgramCode"=x.program;`);
 const seed=await read('05_import_student_combos.sql');
 await fresh.exec(seed);await fresh.exec(seed);
 assert.equal((await fresh.query('SELECT count(*)::int AS n FROM "StudentComboSelections"')).rows[0].n,586);
 assert.equal((await fresh.query(`SELECT count(*)::int AS n FROM "StudentComboSelections" WHERE "SelectionSource"='SYNTHETIC' AND "SelectedAt" IS NULL AND "SelectionPurpose"='SPECIALIZATION'`)).rows[0].n,586);
 assert.equal((await fresh.query(`SELECT count(*)::int AS n FROM test_profiles x JOIN "Students" s ON s."StudentCode"=x.code
 JOIN "StudentComboSelections" sc ON sc."StudentID"=s."StudentID" JOIN "ProgramCombos" b ON b."ProgramComboID"=sc."ProgramComboID"
 WHERE b."SourceComboID"=x.combo AND s."ProgramID"=b."ProgramID"`)).rows[0].n,586);
 passed.push('all 586 synthetic choices match CSV; null dates; reimport does not duplicate');
 await freshFails('a second specialization combo is rejected',`INSERT INTO "StudentComboSelections" ("StudentID","ProgramID","ProgramComboID")
 SELECT sc."StudentID",sc."ProgramID",b."ProgramComboID" FROM "StudentComboSelections" sc JOIN "ProgramCombos" b ON b."ProgramID"=sc."ProgramID"
 WHERE b."ComboCode" !~ '^PHE_COM' AND b."ProgramComboID"<>sc."ProgramComboID" LIMIT 1`,'23505');
 await fresh.exec(`INSERT INTO "StudentComboSelections" ("StudentID","ProgramID","ProgramComboID")
 SELECT sc."StudentID",sc."ProgramID",b."ProgramComboID" FROM "StudentComboSelections" sc JOIN "ProgramCombos" b ON b."ProgramID"=sc."ProgramID"
 WHERE b."ComboCode" ~ '^PHE_COM' LIMIT 1`);
 passed.push('physical combo can coexist with specialization combo');
 await fresh.exec(`UPDATE "Students" SET "CurrentSemester"=3 WHERE "StudentCode"='SE190000'`);
 await freshFails('student import rejects semester mismatch',seed,'P0001');
 await fresh.exec(`UPDATE "Students" SET "CurrentSemester"=5 WHERE "StudentCode"='SE190000'`);
 await fresh.exec(await read('06_verify_student_combos.sql'));
 passed.push('student combo reporting queries execute');
 await fresh.close();
 passed.push('single-file fresh installation executes atomically');
 await fs.writeFile(new URL('test_results.json',import.meta.url),JSON.stringify({engine:'PGlite 0.5.8 (PostgreSQL WASM)',passed},null,2));
 console.log(JSON.stringify({passed:passed.length,checks:passed},null,2));
} catch(e) {console.error(e.message,e.code,e.detail);process.exitCode=1; await db.close().catch(()=>{});}
