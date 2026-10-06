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
 await db.exec(sql);
 const count=async table=>(await db.query(`SELECT count(*)::int AS n FROM "${table}"`)).rows[0].n;
 const expected={Users:3000,Students:3000,StudentAcademicSnapshot:3000,TrainingPrograms:40,ProgramCourses:1924,ProgramCombos:279,ComboCourses:1029,StudentComboSelections:586};
 for(const [table,n] of Object.entries(expected))assert.equal(await count(table),n,table);
 assert.equal((await db.query(`SELECT count(*)::int AS n FROM "Users" WHERE "Status"='INACTIVE' AND "PasswordHash" ~ '^[$]2[aby][$]10[$]' AND length("PasswordHash")=60`)).rows[0].n,3000);
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
 assert.equal(await count('Students'),3000);
 const result={file:'OJT_RPA_FULL_SUPABASE.sql',sha256:crypto.createHash('sha256').update(sql).digest('hex'),
  engine:'PGlite 0.5.8 with pgcrypto (local PostgreSQL WASM)',status:'PASS',counts:expected,
  checks:['rebuild with existing Roles and AI tables','all AI feature tables/columns/permissions removed','AI specialization retained',
   'all source counts','valid bcrypt hashes; inactive synthetic accounts','semester/choice coverage','unknown grades stay null',
   'RLS and anonymous access denied','unrelated public table and auth data preserved','repeat reset succeeds','failed reset rolls back and restores data']};
 await fs.writeFile(new URL('full_export_test_results.json',import.meta.url),JSON.stringify(result,null,2));
 console.log(JSON.stringify(result,null,2));
}catch(e){console.error(e.message,e.code,e.detail);process.exitCode=1;}finally{await db.close();}
