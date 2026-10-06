"""Export a self-contained application reset/install without AI prediction features."""
import csv
import hashlib
import json
import re
from pathlib import Path
from build_database import inserts

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'database'
REMOVED=('AIModels','AIModelConfig','RiskPredictions','SupportClassAISuggestions')
def without_ai(content):
    for table in REMOVED:
        content=re.sub(r'CREATE TABLE "'+table+r'" \([\s\S]*?\n\);','',content)
        content=re.sub(r'^CREATE INDEX [^\n]+ ON "'+table+r'"[^\n]*\n','',content,flags=re.M)
        content=re.sub(r'^(?:ALTER TABLE|REVOKE ALL ON TABLE) "'+table+r'"[^\n]*\n','',content,flags=re.M)
        content=content.replace("'"+table+"',",'').replace(",'"+table+"'",'')
    for column in ('PredictionID','SuggestionID'):
        content=re.sub(r'^    "'+column+r'" INT,\n','',content,flags=re.M)
    for fk in ('FK_PathwayRecommendations_Prediction','FK_SupportClasses_Suggestion'):
        content=re.sub(r'    CONSTRAINT "'+fk+r'"\n[^\n]+,\n','',content)
    content=re.sub(r"^\('(?:AI_RISK_VIEW|AI_CONFIG)'[^\n]*\n",'',content,flags=re.M)
    content=re.sub(r"^\s*'AI_RISK_VIEW',?\n",'\n',content,flags=re.M)
    content=re.sub(r',\s*\)', '\n    )',content)
    content=re.sub(r'/\*\s*RiskLevel length changed[\s\S]*?\*/','',content)
    content=content.replace('AI RISK PREDICTION & PATHWAY ADVISING','ACADEMIC PATHWAY ADVISING (STAFF-MANAGED)')
    assert not any(x in content for x in REMOVED+('"PredictionID"','"SuggestionID"',"'AI_RISK_VIEW'","'AI_CONFIG'"))
    return content
students=list(csv.DictReader((ROOT/'student/student.csv').open(encoding='utf-8-sig',newline='')))
assert len(students)==3000
assert sum(bool(s['selected_combo_id']) for s in students)==586
assert all(s['email'].startswith('ojt.synthetic.') for s in students)
header='''/*
 OJT-RPA — FULL DATABASE WITHOUT AI PREDICTION — PostgreSQL / Supabase
 Exported: 2026-10-06 (Asia/Saigon)

 WARNING: RESETS ALL KNOWN OJT-RPA APPLICATION TABLES AND THEIR DATA.
 Use on a new database OR when intentionally replacing the old application dataset.
 One transaction: reset + recreate + synthetic seed. A failure rolls back the reset.
 Does not drop public schema, unrelated tables, auth, storage or extensions.
 No CASCADE: external dependencies stop the reset rather than being silently removed.
 Backend authentication via Users/PasswordHash; RLS denies direct client access.

 Includes OJT, staff-managed pathway advising, support, evaluation and notification tables;
 No model/configuration, prediction or AI class-suggestion features.
 AI specialization and AI-related academic courses remain part of the IT catalog.
 IT -> SE/IA/AI/IS -> 40 curricula; 1924 curriculum rows;
 279 curriculum-combo links; 1029 combo subject rows;
 enterprise positions, recruitment posts and applications;
 3000 synthetic students and 586 curriculum-valid specialization selections.

 Synthetic student accounts are INACTIVE. Password hash comes from an unknown
 random secret generated at installation, NOT a published demo password.
 Reset passwords and activate only through the backend before testing login.
 Student accounts share that disposable initialization hash; no plaintext secret is stored.
 StudentCode preserves CSV student_id; internal StudentID remains an identity.
 Academic snapshots record imported credits as of export date; GPA/failed count unknown.

 No fabricated enterprise posts, grades, AI model metrics, or trained model artifacts.
 Program-slot mappings and unconfirmed academic rules remain unconfigured.
 Existing application records will be replaced with the supplied synthetic dataset.
*/
BEGIN;
'''
parts=[]
source_text='\n'.join((OUT/f).read_text(encoding='utf-8') for f in ['00_base_for_empty_database.sql','01_upgrade_it.sql'])
owned=sorted(set(re.findall(r'CREATE TABLE (?:IF NOT EXISTS )?"([^"]+)"',source_text)))
# Drop related tables together, without CASCADE. Include legacy unquoted/lowercase names.
reset='-- Remove only explicitly known application relations; preserve unrelated objects.\n'
reset+='DROP TABLE IF EXISTS '+',\n '.join('public."'+t+'"' for t in owned+sorted(set(t.lower() for t in owned)))+';\n'
for fn in ('CheckProgramSlot','CheckCoordinationContext','TouchUpdatedAt','ClassifyStudentCombo','ReclassifyComboSelections'):
    reset+='DROP FUNCTION IF EXISTS public."'+fn+'"();\n'
parts.append(reset)
for filename in ['00_base_for_empty_database.sql','01_upgrade_it.sql','02_catalog_data.sql','04_student_specialization_combo.sql']:
    content=(OUT/filename).read_text(encoding='utf-8')
    if filename in ('00_base_for_empty_database.sql','01_upgrade_it.sql'):
        content=without_ai(content)
    parts.append('-- SECTION: '+filename+'\n'+re.sub(r'^(?:BEGIN|COMMIT);\s*$','',content,flags=re.M))
seed='''
-- SECTION: synthetic users, student profiles and imported academic snapshot
SET LOCAL search_path=public;
CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;
-- Respect the existing extension schema in projects that already installed pgcrypto.
CREATE TEMP TABLE initial_password(hash text NOT NULL) ON COMMIT DROP;
DO $init$
DECLARE extension_schema text;
BEGIN
 SELECT n.nspname INTO STRICT extension_schema FROM pg_extension e
 JOIN pg_namespace n ON n.oid=e.extnamespace WHERE e.extname='pgcrypto';
 EXECUTE format('INSERT INTO initial_password SELECT %I.crypt(gen_random_uuid()::text,%I.gen_salt(''bf'',10))',
   extension_schema,extension_schema);
END $init$;
ALTER TABLE "Students" ADD COLUMN "CohortCode" varchar(20);
COMMENT ON COLUMN "Students"."CohortCode" IS 'Source cohort, e.g. K19; do not infer enrollment calendar year from this label.';
CREATE TEMP TABLE st_full_students(code text PRIMARY KEY,name text,email text,cohort text,program text,
 semester int,credits int) ON COMMIT DROP;
'''
seed+=inserts('st_full_students',[(s['student_id'],s['full_name'],s['email'],s['cohort'],s['curriculum_code'],s['current_semester'],s['accumulated_credits']) for s in students])
seed+='''
INSERT INTO "Users" ("Username","PasswordHash","Email","FullName","RoleID","Status")
SELECT x.code,pw.hash,x.email,x.name,r."RoleID",'INACTIVE'
FROM st_full_students x CROSS JOIN initial_password pw CROSS JOIN "Roles" r WHERE r."RoleCode"='STUDENT';
INSERT INTO "Students" ("UserID","StudentCode","ProgramID","CurrentSemester","CohortCode","Status")
SELECT u."UserID",x.code,p."ProgramID",x.semester,x.cohort,'ACTIVE'
FROM st_full_students x JOIN "Users" u ON u."Username"=x.code
JOIN "TrainingPrograms" p ON p."ProgramCode"=x.program;
INSERT INTO "StudentAcademicSnapshot" ("StudentID","SnapshotDate","AccumulatedCredits","RemainingCredits","CurrentSemester")
SELECT s."StudentID",DATE '2026-10-06',x.credits,p."TotalCredits"-x.credits,x.semester
FROM st_full_students x JOIN "Students" s ON s."StudentCode"=x.code JOIN "TrainingPrograms" p ON p."ProgramID"=s."ProgramID";
DO $$ BEGIN
 IF (SELECT count(*) FROM "Students")<>3000 OR (SELECT count(*) FROM "StudentAcademicSnapshot")<>3000 THEN
  RAISE EXCEPTION 'Student import incomplete';
 END IF;
END $$;
'''
parts.append(seed)
parts.append(re.sub(r'^(?:BEGIN|COMMIT);\s*$','',(OUT/'05_import_student_combos.sql').read_text(encoding='utf-8'),flags=re.M))
parts.append('''
-- Final installation checks within the same transaction.
DO $$ BEGIN
 IF (SELECT count(*) FROM "TrainingPrograms" WHERE "CatalogManaged")<>40
 OR (SELECT count(*) FROM "ProgramCourses")<>1924
 OR (SELECT count(*) FROM "ProgramCombos")<>279
 OR (SELECT count(*) FROM "ComboCourses")<>1029
 OR (SELECT count(*) FROM "StudentComboSelections" WHERE "SelectionPurpose"='SPECIALIZATION')<>586 THEN
  RAISE EXCEPTION 'Final catalog/selection counts do not match source';
 END IF;
END $$;
COMMIT;

-- Compact result summary; all detailed review queries remain in 03/06 files.
SELECT 'Students' AS "Dataset",count(*) AS "Rows" FROM "Students"
UNION ALL SELECT 'Curricula',count(*) FROM "TrainingPrograms"
UNION ALL SELECT 'Curriculum courses',count(*) FROM "ProgramCourses"
UNION ALL SELECT 'Curriculum combos',count(*) FROM "ProgramCombos"
UNION ALL SELECT 'Combo courses',count(*) FROM "ComboCourses"
UNION ALL SELECT 'Student combo selections',count(*) FROM "StudentComboSelections";
''')
dest=OUT/'OJT_RPA_FULL_SUPABASE.sql'
dest.write_text(header+'\n\n'.join(parts),encoding='utf-8')
print(json.dumps({'file':str(dest),'bytes':dest.stat().st_size,'sha256':hashlib.sha256(dest.read_bytes()).hexdigest()}))
