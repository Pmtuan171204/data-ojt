"""Export a self-contained application reset/install without AI prediction features."""
import hashlib
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'database'
REMOVED=('AIModels','AIModelConfig','RiskPredictions','SupportClassAISuggestions')
# Additional legacy application objects reported by the user's Supabase dependency error.
# Their definitions were not supplied; reset removes them, it does not invent replacements.
LEGACY_EXTRA_TABLES=(
 'OJTRuleSets','ComboRegistrationWindows','StudentComboSelectionEvents','ImportBatches',
 'SystemSettings','OJTRegistrationPolicies','SupportRequestMessages','SupportRequestFiles',
 'CurriculumRuleReviews','UserSessions','SupportClassSuggestionStudents','OJTHistoricalOutcomes',
 'PathwayRecommendationItems','CurriculumCourses','CurriculumComboCourses',
 'ImportRows','Curricula','CurriculumPrerequisiteOptions'
)
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
header='''/*
 OJT-RPA — FULL DATABASE WITH EXTERNAL EMBEDDING MATCHING — PostgreSQL / Supabase
 Exported: 2026-10-06 (Asia/Saigon)

 WARNING: RESETS OJT-RPA TABLES AND ALL THEIR PUBLIC FK/VIEW DEPENDENTS AND DATA.
 RESET STRATEGY: RECURSIVE_DEPENDENCIES_V1
 Use on a new database OR when intentionally replacing the old application dataset.
 One transaction: reset + recreate + academic catalog. A failure rolls back the reset.
 Does not drop public schema, unrelated tables, auth, storage or extensions.
 No CASCADE: dependencies outside public or extension-owned objects stop the reset.
 Finds indirect FK, view and partition dependencies, including unknown legacy names.
 Legacy dependent objects are removed with the application. Their old extra features are not
 recreated: only the application schema defined below is installed.
 Backend authentication via Users/PasswordHash; RLS denies direct client access.

 Includes OJT, staff-managed pathway advising, support, evaluation and notification tables;
 No legacy trained-model management, risk prediction or AI class-suggestion features.
 External embedding matching has separate configuration, vector cache and recommendation tables.
 Rule-based OJT deadline alerts included; four example rules start disabled.
 No external API calls are performed by this SQL script; backend integration is required.
 AI specialization and AI-related academic courses remain part of the IT catalog.
 IT -> SE/IA/AI/IS -> 40 curricula; 1924 curriculum rows;
 279 curriculum-combo links; 1029 combo subject rows;
 enterprise positions, recruitment posts and applications;
 No student accounts, profiles, academic snapshots or combo selections are inserted.

 No fabricated enterprise posts, grades, AI model metrics, or trained model artifacts.
 Program-slot mappings and unconfirmed academic rules remain unconfigured.
 Existing application records are deleted; only catalog and configuration seeds are loaded.
*/
BEGIN;
'''
parts=[]
source_text='\n'.join((OUT/f).read_text(encoding='utf-8') for f in ['00_base_for_empty_database.sql','01_upgrade_it.sql','07_external_matching.sql','09_ojt_deadline_alerts.sql'])
owned=sorted(set(re.findall(r'CREATE TABLE (?:IF NOT EXISTS )?"([^"]+)"',source_text)) | set(LEGACY_EXTRA_TABLES))
planned=owned+sorted(set(t.lower() for t in owned))+['InternshipPositionAvailability','internshippositionavailability']
diagnostic='''-- READ ONLY: list unplanned FK/view dependencies, including indirect chains.
-- Optional preview: public dependencies below are included automatically by the full reset.
WITH RECURSIVE planned AS (
 SELECT c.oid FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='public' AND c.relname IN ('''+','.join("'"+t+"'" for t in planned)+''')
), edges AS (
 SELECT con.confrelid AS parent,con.conrelid AS child,'FOREIGN KEY'::text AS kind
 FROM pg_constraint con WHERE con.contype='f'
 UNION
 SELECT d.refobjid,r.ev_class,'VIEW'::text FROM pg_depend d
 JOIN pg_rewrite r ON r.oid=d.objid
 JOIN pg_class v ON v.oid=r.ev_class AND v.relkind IN ('v','m')
 WHERE d.classid='pg_rewrite'::regclass AND d.refclassid='pg_class'::regclass
 AND d.refobjid<>r.ev_class
), reachable(oid) AS (
 SELECT oid FROM planned
 UNION
 SELECT e.child FROM edges e JOIN reachable r ON e.parent=r.oid
)
SELECT DISTINCT format('%I.%I',cn.nspname,c.relname) AS "DependentObject",
 format('%I.%I',pn.nspname,p.relname) AS "DependsOn",e.kind AS "DependencyType"
FROM edges e JOIN reachable r ON r.oid=e.parent
JOIN pg_class c ON c.oid=e.child JOIN pg_namespace cn ON cn.oid=c.relnamespace
JOIN pg_class p ON p.oid=e.parent JOIN pg_namespace pn ON pn.oid=p.relnamespace
WHERE e.child NOT IN (SELECT oid FROM planned)
ORDER BY 1,2,3;
'''
(OUT/'check_reset_dependencies.sql').write_text(diagnostic,encoding='utf-8')
# Resolve the entire dependency graph before deleting anything. UNION handles FK cycles.
reset='''
SET LOCAL search_path=public,pg_catalog;
CREATE TEMP TABLE _ojt_reset_targets ON COMMIT DROP AS
WITH RECURSIVE roots AS (
 SELECT c.oid FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='public' AND c.relname IN ('''+','.join("'"+t+"'" for t in planned)+''')
), edges AS (
 SELECT confrelid AS parent,conrelid AS child FROM pg_constraint WHERE contype='f'
 UNION
 SELECT d.refobjid,r.ev_class FROM pg_depend d JOIN pg_rewrite r ON r.oid=d.objid
 JOIN pg_class v ON v.oid=r.ev_class AND v.relkind IN ('v','m')
 WHERE d.classid='pg_rewrite'::regclass AND d.refclassid='pg_class'::regclass
 AND d.refobjid<>r.ev_class
 UNION
 SELECT inhparent,inhrelid FROM pg_inherits
), reachable(oid) AS (
 SELECT oid FROM roots UNION SELECT e.child FROM edges e JOIN reachable r ON e.parent=r.oid
)
SELECT c.oid,n.nspname,c.relname,c.relkind FROM reachable r
JOIN pg_class c ON c.oid=r.oid JOIN pg_namespace n ON n.oid=c.relnamespace;
DO $reset$
DECLARE obj record; names text;
BEGIN
 SELECT string_agg(format('%I.%I',t.nspname,t.relname),', ') INTO names
 FROM pg_temp._ojt_reset_targets t
 WHERE t.nspname<>'public' OR t.relkind NOT IN ('r','p','v','m')
 OR EXISTS (SELECT 1 FROM pg_depend d WHERE d.classid='pg_class'::regclass
   AND d.objid=t.oid AND d.deptype='e');
 IF names IS NOT NULL THEN
  RAISE EXCEPTION 'Reset stopped: protected or unsupported dependent objects: %',names;
 END IF;
 -- Remove outermost views first, including materialized views and nested view chains.
 LOOP
  SELECT t.* INTO obj FROM pg_temp._ojt_reset_targets t
  WHERE t.relkind IN ('v','m') AND NOT EXISTS (
   SELECT 1 FROM pg_depend d JOIN pg_rewrite rw ON rw.oid=d.objid
   JOIN pg_temp._ojt_reset_targets child ON child.oid=rw.ev_class
   WHERE d.classid='pg_rewrite'::regclass AND d.refclassid='pg_class'::regclass
   AND d.refobjid=t.oid AND rw.ev_class<>t.oid
  ) ORDER BY t.oid LIMIT 1;
  EXIT WHEN NOT FOUND;
  EXECUTE format('DROP %s %I.%I',CASE WHEN obj.relkind='m' THEN 'MATERIALIZED VIEW' ELSE 'VIEW' END,
   obj.nspname,obj.relname);
  DELETE FROM pg_temp._ojt_reset_targets WHERE oid=obj.oid;
 END LOOP;
 IF EXISTS (SELECT 1 FROM pg_temp._ojt_reset_targets WHERE relkind IN ('v','m')) THEN
  RAISE EXCEPTION 'Reset stopped: unresolved view dependency cycle';
 END IF;
 -- One statement removes every table in the closure, including mutually referencing tables.
 SELECT string_agg(format('%I.%I',nspname,relname),', ' ORDER BY oid) INTO names
 FROM pg_temp._ojt_reset_targets;
 IF names IS NOT NULL THEN EXECUTE 'DROP TABLE ' || names; END IF;
END $reset$;
'''
for fn in ('CheckProgramSlot','CheckCoordinationContext','TouchUpdatedAt','ClassifyStudentCombo','ReclassifyComboSelections','CheckOJTAlertTaskContext'):
    reset+='DROP FUNCTION IF EXISTS public."'+fn+'"();\n'
parts.append(reset)
for filename in ['00_base_for_empty_database.sql','01_upgrade_it.sql','02_catalog_data.sql','04_student_specialization_combo.sql','07_external_matching.sql','09_ojt_deadline_alerts.sql']:
    content=(OUT/filename).read_text(encoding='utf-8')
    if filename in ('00_base_for_empty_database.sql','01_upgrade_it.sql'):
        content=without_ai(content)
    parts.append('-- SECTION: '+filename+'\n'+re.sub(r'^(?:BEGIN|COMMIT);\s*$','',content,flags=re.M))
parts.append("""
-- Keep student schema available for later imports; no student data is seeded.
ALTER TABLE "Students" ADD COLUMN "CohortCode" varchar(20);
COMMENT ON COLUMN "Students"."CohortCode" IS 'Source cohort, e.g. K19; do not infer enrollment calendar year from this label.';
""")
parts.append('''
-- Final installation checks within the same transaction.
DO $$ BEGIN
 IF (SELECT count(*) FROM "TrainingPrograms" WHERE "CatalogManaged")<>40
 OR (SELECT count(*) FROM "ProgramCourses")<>1924
 OR (SELECT count(*) FROM "ProgramCombos")<>279
 OR (SELECT count(*) FROM "ComboCourses")<>1029 THEN
  RAISE EXCEPTION 'Final catalog counts do not match source';
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
