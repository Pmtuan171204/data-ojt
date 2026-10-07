import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {PGlite} from './.test-tools/pglite/package/dist/index.js';
const db=new PGlite();
const read=async name=>(await fs.readFile(new URL(name,import.meta.url),'utf8')).replace(/\r\n/g,'\n');
const migration=await read('07_external_matching.sql');
const body=migration.replace(/^(?:BEGIN|COMMIT);\s*$/gm,'');
const full=await read('OJT_RPA_FULL_SUPABASE.sql');
const checks=[];
const reject=async (sql,code)=>assert.rejects(db.exec(sql),e=>e.code===code);
try {
 await db.exec('CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role BYPASSRLS;');
 assert.ok(full.includes(body));
 await db.exec(full.replace(body,''));
 await db.exec(`INSERT INTO "Users" ("Username","PasswordHash","Email","FullName","RoleID")
 SELECT 'matching-test','not-a-real-login','fixture@example.invalid','Fixture',"RoleID" FROM "Roles" WHERE "RoleCode"='STUDENT';
 INSERT INTO "Students" ("UserID","StudentCode") SELECT "UserID",'TEST01' FROM "Users" WHERE "Username"='matching-test';`);
 await db.exec(migration);
 assert.equal((await db.query('SELECT count(*)::int n FROM "Students"')).rows[0].n,1);
 assert.equal((await db.query('SELECT count(*)::int n FROM "ProgramCourses"')).rows[0].n,1924);
 checks.push('additive migration preserves existing student and catalog');
 await reject(migration,'P0001'); await db.exec('ROLLBACK');
 checks.push('repeat migration fails clearly without partial changes');
 await db.exec(`INSERT INTO "AcademicYears" ("YearCode") VALUES ('TEST');
 INSERT INTO "OJTSemesters" ("AcademicYearID","SemesterCode","Name") VALUES (1,'TEST1','Test'),(1,'TEST2','Other semester');
 INSERT INTO "Enterprises" ("EnterpriseCode","Name") VALUES ('TEST','Test enterprise'),('OTHER','Other enterprise');
 INSERT INTO "InternshipPositions" ("EnterpriseID","OJTSemesterID","Title","Description","Capacity","RemainingSlots")
 VALUES (1,1,'Backend intern','Java and SQL',5,5);
 INSERT INTO "OJTMatchingProfiles" ("ProfileType","EnterpriseID","OJTSemesterID","PositionID") VALUES ('POSITION',1,1,1);
 INSERT INTO "OJTMatchingProfiles" ("ProfileType","EnterpriseID","OJTSemesterID","CompanyOJTDescription","CompanyCapacity","CompanyRemainingSlots")
 VALUES ('ENTERPRISE_OJT',2,1,'Software project support',10,10);
 INSERT INTO "EmbeddingConfigurations" ("Provider","ModelName","ModelVersion","Dimensions","PreprocessingVersion")
 VALUES ('test-provider','test-embedding','v1',3,'v1');`);
 await reject(`UPDATE "OJTMatchingProfiles" SET "EnterpriseID"=2,"OJTSemesterID"=2 WHERE "ProfileID"=1`,'23503');
 await reject(`INSERT INTO "OJTMatchingProfiles" ("ProfileType","EnterpriseID","OJTSemesterID") VALUES ('ENTERPRISE_OJT',1,1)`,'23514');
 checks.push('both profile branches supported; mismatched enterprise/semester and incomplete no-JD profile rejected');
 await reject(`INSERT INTO "MatchingEmbeddings" ("EmbeddingConfigID","Dimensions","StudentID","ContentHash","Embedding") VALUES (1,3,1,'bad',ARRAY[1.0,2.0])`,'23514');
 await reject(`INSERT INTO "MatchingEmbeddings" ("EmbeddingConfigID","Dimensions","StudentID","ContentHash","Embedding") VALUES (1,3,1,'bad',ARRAY[1.0,'NaN'::float8,2.0])`,'23514');
 await reject(`INSERT INTO "MatchingEmbeddings" ("EmbeddingConfigID","Dimensions","StudentID","ContentHash","Embedding") VALUES (1,3,1,'bad',ARRAY[0.0,0.0,0.0])`,'23514');
 const studentEmbedding=(await db.query(`INSERT INTO "MatchingEmbeddings" ("EmbeddingConfigID","Dimensions","StudentID","ContentHash","Embedding") VALUES (1,3,1,'student-hash',ARRAY[1.0,0.0,0.0]) RETURNING "EmbeddingID"`)).rows[0].EmbeddingID;
 const profileEmbedding=(await db.query(`INSERT INTO "MatchingEmbeddings" ("EmbeddingConfigID","Dimensions","ProfileID","ContentHash","Embedding") VALUES (1,3,1,'position-hash',ARRAY[1.0,0.0,0.0]) RETURNING "EmbeddingID"`)).rows[0].EmbeddingID;
 checks.push('embedding dimensions, non-finite values and zero norm validated');
 await db.exec(`INSERT INTO "MatchingRuns" ("IdempotencyKey","StudentID","OJTSemesterID","RequestedBy","FilterVersion","ScoringVersion","EmbeddingConfigID","StudentSnapshot","InputHash","ExpiresAt")
 VALUES ('run-1',1,1,1,'filter-v1','cosine-v1',1,'{}','input-hash',now()+interval '1 day');
 INSERT INTO "MatchingCandidates" ("RunID","ProfileID","OJTSemesterID","Eligibility","ProfileSnapshot") VALUES (1,1,1,'FAIL','{}');`);
 const recommendation=`INSERT INTO "MatchingRecommendations" ("RunID","ProfileID","StudentID","EmbeddingConfigID","ScoringSource","StudentEmbeddingID","ProfileEmbeddingID","CosineSimilarity","MatchScore","Rank","Explanation")
 VALUES (1,1,1,1,'CACHE',${studentEmbedding},${profileEmbedding},1,100,1,'Matching verified skills')`;
 await reject(recommendation,'23503');
 await db.exec(`UPDATE "MatchingCandidates" SET "Eligibility"='REVIEW_REQUIRED' WHERE "RunID"=1`);
 await reject(recommendation,'23503');
 await db.exec(`UPDATE "MatchingCandidates" SET "Eligibility"='PASS' WHERE "RunID"=1`);
 await reject(recommendation.replace(',1,100,1,',',1,101,1,'),'23514');
 await reject(recommendation.replace(`'CACHE',${studentEmbedding},${profileEmbedding}`,`'CACHE',${profileEmbedding},${studentEmbedding}`),'23503');
 await db.exec(recommendation);
 await reject(`UPDATE "MatchingCandidates" SET "Eligibility"='FAIL' WHERE "RunID"=1`,'23503');
 checks.push('FAIL/unknown eligibility cannot receive recommendations; score range and vector ownership enforced; cache path works');
 await reject(`UPDATE "MatchingRecommendations" SET "ScoringSource"='API',"CallID"=999`,'23503');
 const callID=(await db.query(`INSERT INTO "MatchingAPICalls" ("RunID","BatchNumber","AttemptNumber","Provider","ModelName","RequestHash") VALUES (1,1,1,'test','embedding','hash') RETURNING "CallID"`)).rows[0].CallID;
 await reject(`UPDATE "MatchingRecommendations" SET "ScoringSource"='API',"CallID"=${callID}`,'23503');
 await db.exec(`UPDATE "MatchingAPICalls" SET "Status"='SUCCEEDED',"FinishedAt"=now() WHERE "CallID"=${callID};
 UPDATE "MatchingRecommendations" SET "ScoringSource"='API',"CallID"=${callID};`);
 checks.push('API recommendations require successful call in same run');
 await db.exec('SET ROLE anon'); await reject('SELECT * FROM "MatchingEmbeddings"','42501'); await db.exec('RESET ROLE');
 await db.exec('SET ROLE authenticated'); await reject('SELECT * FROM "MatchingRecommendations"','42501'); await db.exec('RESET ROLE');
 checks.push('direct client access denied');
 const result={status:'PASS',engine:'PGlite local PostgreSQL',checks};
 await fs.writeFile(new URL('external_matching_test_results.json',import.meta.url),JSON.stringify(result,null,2));
 console.log(JSON.stringify(result,null,2));
} catch(e) {console.error(e.message,e.code,e.detail);process.exitCode=1;} finally {await db.close();}
