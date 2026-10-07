import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {PGlite} from './.test-tools/pglite/package/dist/index.js';
import {pgcrypto} from './.test-tools/pglite/package/dist/contrib/pgcrypto.js';
const db=new PGlite({extensions:{pgcrypto}});
const sql=await fs.readFile(new URL('OJT_RPA_FULL_SUPABASE.sql',import.meta.url),'utf8');
try{
 await db.exec('CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role BYPASSRLS;');
 // Reproduce the user's existing Roles table and the old AI schema before rebuilding.
 await db.exec(await fs.readFile(new URL('00_base_for_empty_database.sql',import.meta.url),'utf8'));
 await db.exec(await fs.readFile(new URL('01_upgrade_it.sql',import.meta.url),'utf8'));
 await db.exec(`INSERT INTO "AIModels" ("ModelCode","ModelName") VALUES ('OLD_MODEL','Old model');
 CREATE TABLE "UnrelatedKeep" (id int); INSERT INTO "UnrelatedKeep" VALUES (42);
 CREATE SCHEMA auth; CREATE TABLE auth.keep (id int); INSERT INTO auth.keep VALUES (7);`);
 // Exact dependency shapes from the reported Supabase error (not guesses at full schemas).
 const legacyDependencies={
  OJTRuleSets:[['ApprovedBy','Users','UserID'],['OJTSemesterID','OJTSemesters','OJTSemesterID']],
  ComboRegistrationWindows:[['CreatedBy','Users','UserID']],
  StudentComboSelectionEvents:[['ActorUserID','Users','UserID'],['SelectionID','StudentComboSelections','SelectionID']],
  ImportBatches:[['ImportedBy','Users','UserID']],SystemSettings:[['UpdatedBy','Users','UserID']],
  OJTRegistrationPolicies:[['UpdatedBy','Users','UserID'],['OJTSemesterID','OJTSemesters','OJTSemesterID']],
  SupportRequestMessages:[['SenderUserID','Users','UserID'],['RequestID','SupportRequests','RequestID']],
  SupportRequestFiles:[['UploadedBy','Users','UserID'],['RequestID','SupportRequests','RequestID']],
  CurriculumRuleReviews:[['ReviewedBy','Users','UserID']],UserSessions:[['UserID','Users','UserID']],
  SupportClassSuggestionStudents:[['SuggestionID','SupportClassAISuggestions','SuggestionID'],['StudentID','Students','StudentID']],
  OJTHistoricalOutcomes:[['StudentID','Students','StudentID'],['OJTSemesterID','OJTSemesters','OJTSemesterID']],
  PathwayRecommendationItems:[['RecommendationID','PathwayRecommendations','RecommendationID'],['CourseID','Courses','CourseID']],
  CurriculumCourses:[['CourseCode','Courses','CourseCode']],CurriculumComboCourses:[['CourseCode','Courses','CourseCode']]
 };
 for(const [name,refs] of Object.entries(legacyDependencies)){
  await db.exec(`CREATE TABLE "${name}" (${refs.map(([col,target,key])=>`"${col}" ${col==='CourseCode'?'varchar(20)':'int'} REFERENCES "${target}"("${key}")`).join(',')})`);
 }
 await db.exec('CREATE VIEW "InternshipPositionAvailability" AS SELECT "PositionID" FROM "InternshipPositions"');
 await db.exec(`ALTER TABLE "ImportBatches" ADD COLUMN "ImportBatchID" int PRIMARY KEY;
 ALTER TABLE "CurriculumCourses" ADD COLUMN "CurriculumID" int;
 ALTER TABLE "CurriculumCourses" ADD UNIQUE ("CurriculumID","CourseCode");
 CREATE TABLE "ImportRows" ("ImportBatchID" int REFERENCES "ImportBatches"("ImportBatchID"));
 CREATE TABLE "Curricula" ("CurriculumID" int PRIMARY KEY,"LastImportBatchID" int REFERENCES "ImportBatches"("ImportBatchID"));
 CREATE TABLE "CurriculumPrerequisiteOptions" ("CurriculumID" int,"CourseCode" varchar(20),
 FOREIGN KEY ("CurriculumID","CourseCode") REFERENCES "CurriculumCourses"("CurriculumID","CourseCode"));
 CREATE TABLE "CurriculumCohorts" (id int PRIMARY KEY,"CurriculumID" int REFERENCES "Curricula"("CurriculumID"));
 CREATE TABLE "CurriculumCombos" (id int PRIMARY KEY,"CurriculumID" int REFERENCES "Curricula"("CurriculumID"));
 CREATE TABLE "LegacyDependencyProbe" (id int PRIMARY KEY REFERENCES "CurriculumCohorts"(id));
 CREATE TABLE "UnknownGrandchild" (id int REFERENCES "LegacyDependencyProbe"(id));
 CREATE VIEW "LegacyProbeView" AS SELECT id FROM "UnknownGrandchild";
 CREATE MATERIALIZED VIEW "LegacyProbeMaterialized" AS SELECT id FROM "LegacyProbeView";
 CREATE VIEW "LegacyOuterView" AS SELECT id FROM "LegacyProbeMaterialized";`);
 const diagnostic=await fs.readFile(new URL('check_reset_dependencies.sql',import.meta.url),'utf8');
 const blockers=(await db.query(diagnostic)).rows.map(r=>r.DependentObject);
 assert.ok(blockers.includes('public."LegacyDependencyProbe"'));
 assert.ok(blockers.includes('public."LegacyProbeView"'));
 // Cross-schema descendants must abort before destructive changes.
 await db.exec('CREATE TABLE auth.protected_reference (id int REFERENCES public."Users"("UserID"))');
 await assert.rejects(db.exec(sql),e=>e.code==='P0001' && e.message.includes('protected'));
 await db.exec('ROLLBACK');
 assert.equal((await db.query('SELECT count(*)::int n FROM "AIModels"')).rows[0].n,1);
 await db.exec('DROP TABLE auth.protected_reference');
 await db.exec(sql);
 for(const name of [...Object.keys(legacyDependencies),'ImportRows','Curricula','CurriculumPrerequisiteOptions','InternshipPositionAvailability',
 'CurriculumCohorts','CurriculumCombos','LegacyDependencyProbe','UnknownGrandchild','LegacyProbeView','LegacyProbeMaterialized','LegacyOuterView']){
  assert.equal((await db.query('SELECT to_regclass($1) AS t',[`public."${name}"`])).rows[0].t,null);
 }
 const count=async table=>(await db.query(`SELECT count(*)::int AS n FROM "${table}"`)).rows[0].n;
 const expected={Users:0,Students:0,StudentAcademicSnapshot:0,TrainingPrograms:40,ProgramCourses:1924,ProgramCombos:279,ComboCourses:1029,StudentComboSelections:0};
 for(const [table,n] of Object.entries(expected))assert.equal(await count(table),n,table);
 assert.equal((await db.query(`SELECT count(*)::int AS n FROM "Users" WHERE "Status"='INACTIVE' AND "PasswordHash" ~ '^[$]2[aby][$]10[$]' AND length("PasswordHash")=60`)).rows[0].n,0);
 assert.equal((await db.query(`SELECT count(*)::int AS n FROM "Students" s JOIN "StudentComboSelections" sc USING ("StudentID") WHERE s."CurrentSemester"<5`)).rows[0].n,0);
 assert.equal((await db.query(`SELECT count(*)::int AS n FROM "Students" s WHERE s."CurrentSemester">=5 AND NOT EXISTS (SELECT 1 FROM "StudentComboSelections" sc WHERE sc."StudentID"=s."StudentID" AND sc."SelectionPurpose"='SPECIALIZATION')`)).rows[0].n,0);
 assert.equal((await db.query(`SELECT count(*)::int AS n FROM "StudentAcademicSnapshot" WHERE "GPA" IS NOT NULL OR "FailedCoursesCount" IS NOT NULL OR "RemainingCredits"<0`)).rows[0].n,0);
 assert.equal((await db.query(`SELECT count(*)::int AS n FROM pg_tables WHERE schemaname='public' AND tablename<>'UnrelatedKeep' AND NOT rowsecurity`)).rows[0].n,0);
 for(const table of ['AIModels','AIModelConfig','RiskPredictions','SupportClassAISuggestions']){
  assert.equal((await db.query('SELECT to_regclass($1) AS t',[`public."${table}"`])).rows[0].t,null);
 }
 assert.equal((await db.query(`SELECT count(*)::int AS n FROM "Permissions" WHERE "PermissionCode" IN ('AI_RISK_VIEW','AI_CONFIG')`)).rows[0].n,0);
 assert.equal((await db.query(`SELECT count(*)::int AS n FROM information_schema.columns WHERE table_schema='public' AND column_name IN ('PredictionID','ModelID','SuggestionID')`)).rows[0].n,0);
 assert.equal((await db.query(`SELECT count(*)::int AS n FROM "Specializations" WHERE "SpecializationCode"='AI'`)).rows[0].n,1);
 assert.equal((await db.query('SELECT id FROM "UnrelatedKeep"')).rows[0].id,42);
 assert.equal((await db.query('SELECT id FROM auth.keep')).rows[0].id,7);
 await db.exec('SET ROLE anon');
 await assert.rejects(db.query('SELECT * FROM "Users"'),e=>e.code==='42501');
 await db.exec('RESET ROLE');
 await db.exec(sql);
 for(const [table,n] of Object.entries(expected))assert.equal(await count(table),n,`repeat reset: ${table}`);
 // Ensure a failure after the DROP statements restores the previous dataset.
 await assert.rejects(db.exec(sql.replace('CREATE TABLE "Roles" (','SELECT 1/0;\nCREATE TABLE "Roles" (')),e=>e.code==='22012');
 await db.exec('ROLLBACK');
 assert.equal(await count('Students'),0);
 const result={file:'OJT_RPA_FULL_SUPABASE.sql',sha256:crypto.createHash('sha256').update(sql).digest('hex'),
  engine:'PGlite 0.5.8 with pgcrypto (local PostgreSQL WASM)',status:'PASS',counts:expected,
  checks:['rebuild with existing Roles and AI tables','all reported and unknown indirect dependent tables removed','nested views and materialized views removed','cross-schema dependency aborts without deleting data','recursive diagnostic finds unknown table and downstream view','all AI feature tables/columns/permissions removed','AI specialization retained',
   'all source counts','no student accounts, profiles, snapshots or selections seeded','semester/choice coverage','unknown grades stay null',
   'RLS and anonymous access denied','unrelated public table and auth data preserved','repeat reset succeeds','failed reset rolls back and restores data']};
 await fs.writeFile(new URL('full_export_test_results.json',import.meta.url),JSON.stringify(result,null,2));
 console.log(JSON.stringify(result,null,2));
}catch(e){console.error(e.message,e.code,e.detail);process.exitCode=1;}finally{await db.close();}
