"""Build reviewable PostgreSQL scripts from the supplied DDL and immutable CSV inputs.
Usage: python database/build_database.py --legacy-script 'path/to/Pasted text.txt'
No database connections; never changes the source CSVs.
"""
import argparse
import csv
import hashlib
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'database'

def read_csv(path):
    with path.open(encoding='utf-8-sig', newline='') as f:
        return list(csv.DictReader(f))

def quote(value):
    return 'NULL' if value is None else "'" + str(value).replace("'", "''") + "'"

def number(value):
    if value == '':
        return None
    if not re.fullmatch(r'\d+(?:\.\d+)?', value):
        raise ValueError(f'Invalid nonnegative number: {value!r}')
    return value

def inserts(table, rows):
    return '\n'.join('INSERT INTO '+table+' VALUES\n'+',\n'.join(
        '('+','.join(quote(v) for v in row)+')' for row in rows[i:i+250])+';'
        for i in range(0, len(rows), 250))

def student_combo_import():
    path = ROOT/'student/student.csv'
    students = read_csv(path)
    if not students or 'selected_combo_id' not in students[0]:
        return
    rows = [(s['student_id'],s['curriculum_code'],number(s['current_semester']),
             number(s['selected_combo_id'])) for s in students]
    assert all((int(s['current_semester'])>=5)==bool(s['selected_combo_id']) for s in students)
    assert all(s['email'].startswith('ojt.synthetic.') for s in students)
    selected = sum(bool(s['selected_combo_id']) for s in students)
    sql = '''-- SYNTHETIC STUDENT COMBO CHOICES. Run after 04 migration and student/user provisioning.
-- This script never creates accounts, remaps curricula, or replaces existing choices.
-- CSV student_id maps to Students.StudentCode, NOT to the database identity StudentID.
-- Blank source choices are NULL and never delete an existing selection.
BEGIN;
SET LOCAL search_path=public;
CREATE TEMP TABLE st_student_choices(code text PRIMARY KEY,program text,semester int,combo int) ON COMMIT DROP;
'''+inserts('st_student_choices',rows)+'''
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM "SchemaMigrations" WHERE "Version"='20261006_student_specialization_combo') THEN
  RAISE EXCEPTION 'Run 04_student_specialization_combo.sql first';
 END IF;
 IF EXISTS (SELECT 1 FROM st_student_choices x LEFT JOIN "Students" s ON s."StudentCode"=x.code
   WHERE s."StudentID" IS NULL) THEN
  RAISE EXCEPTION 'Missing Students. Provision/import all CSV student profiles first; no choices imported.';
 END IF;
 IF EXISTS (SELECT 1 FROM st_student_choices x JOIN "Students" s ON s."StudentCode"=x.code
   LEFT JOIN "TrainingPrograms" p ON p."ProgramID"=s."ProgramID"
   WHERE p."ProgramCode" IS DISTINCT FROM x.program OR s."CurrentSemester" IS DISTINCT FROM x.semester) THEN
  RAISE EXCEPTION 'Student curriculum/semester differs from CSV. Review profile mapping first.';
 END IF;
 IF EXISTS (SELECT 1 FROM st_student_choices x JOIN "TrainingPrograms" p ON p."ProgramCode"=x.program
   LEFT JOIN "ProgramCombos" b ON b."ProgramID"=p."ProgramID" AND b."SourceComboID"=x.combo
   WHERE x.combo IS NOT NULL AND (b."ProgramComboID" IS NULL
     OR b."ComboCode" !~ '^(AI17|IA|IS|SE(-2026)?)_COM')) THEN
  RAISE EXCEPTION 'Choice is not a specialization combo of the exact curriculum';
 END IF;
 IF EXISTS (SELECT 1 FROM st_student_choices x JOIN "Students" s ON s."StudentCode"=x.code
   JOIN "StudentComboSelections" sc ON sc."StudentID"=s."StudentID" AND sc."ProgramID"=s."ProgramID"
   JOIN "ProgramCombos" b ON b."ProgramComboID"=sc."ProgramComboID"
   WHERE x.combo IS NOT NULL AND sc."SelectionPurpose"='SPECIALIZATION' AND b."SourceComboID"<>x.combo) THEN
  RAISE EXCEPTION 'Existing specialization choice conflicts with synthetic source; no changes applied';
 END IF;
END $$;
INSERT INTO "StudentComboSelections" ("StudentID","ProgramID","ProgramComboID","SelectedAt","SelectionSource")
SELECT s."StudentID",s."ProgramID",b."ProgramComboID",NULL,'SYNTHETIC'
FROM st_student_choices x JOIN "Students" s ON s."StudentCode"=x.code
JOIN "ProgramCombos" b ON b."ProgramID"=s."ProgramID" AND b."SourceComboID"=x.combo
WHERE x.combo IS NOT NULL
ON CONFLICT ("StudentID","ProgramComboID") DO NOTHING;
DO $$ BEGIN
 IF (SELECT count(*) FROM st_student_choices x JOIN "Students" s ON s."StudentCode"=x.code
     JOIN "ProgramCombos" b ON b."ProgramID"=s."ProgramID" AND b."SourceComboID"=x.combo
     JOIN "StudentComboSelections" sc ON sc."StudentID"=s."StudentID" AND sc."ProgramComboID"=b."ProgramComboID"
     WHERE x.combo IS NOT NULL AND sc."SelectionPurpose"='SPECIALIZATION') <> '''+str(selected)+''' THEN
  RAISE EXCEPTION 'Imported selection count does not match source';
 END IF;
END $$;
COMMIT;
'''
    (OUT/'05_import_student_combos.sql').write_text(sql,encoding='utf-8')
    (OUT/'student_combo_manifest.json').write_text(json.dumps({
        'source':'student/student.csv','sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
        'students':len(rows),'selected':selected,'blank':len(rows)-selected,'synthetic':True
    },indent=2),encoding='utf-8')

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--legacy-script', type=Path)
    args = parser.parse_args()
    if args.legacy_script:
        src = args.legacy_script.read_text(encoding='utf-8-sig')
        ddl = src[src.index('CREATE TABLE "Roles"'):src.index('   11. INITIAL ROLES')]
        # Last separator opens a comment immediately before section 11.
        ddl = ddl[:ddl.rfind('/*')]
        auth_seed = '\n\n'.join(re.findall(r'INSERT INTO "(?:Roles|Permissions|RolePermissions)"[\s\S]*?;', src))
        (OUT/'00_base_for_empty_database.sql').write_text(
            '-- EMPTY DATABASE ONLY. Safe create: no reset, drops or demo users.\n'
            '-- Backend hashes passwords; no pgcrypto dependency needed by this DDL.\n'
            'BEGIN;\nSET LOCAL search_path=public;\n'+ddl+'\n'+auth_seed+'\nCOMMIT;\n', encoding='utf-8')
    base = (OUT/'00_base_for_empty_database.sql').read_text(encoding='utf-8')
    migration = (OUT/'01_upgrade_it.sql').read_text(encoding='utf-8')
    tables = sorted(set(re.findall(r'CREATE TABLE (?:IF NOT EXISTS )?"([^"]+)"', base+migration)))
    security = '-- BEGIN GENERATED SECURITY\n'
    security += '-- Backend-only Data API. SQL editor owner/service_role bypass RLS.\n'
    for table in tables:
        security += f'ALTER TABLE "{table}" ENABLE ROW LEVEL SECURITY;\n'
        security += f'REVOKE ALL ON TABLE "{table}" FROM PUBLIC;\n'
    # Table grants also control SERIAL/IDENTITY sequence access; scope by dependency, not entire schema.
    security += '''DO $security$
DECLARE item record; seq record; role_name text;
BEGIN
  FOR item IN SELECT c.oid,c.relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='public' AND c.relname = ANY (ARRAY['''
    security += ','.join(quote(t) for t in tables)+''']) LOOP
    FOREACH role_name IN ARRAY ARRAY['anon','authenticated'] LOOP
      IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname=role_name) THEN
        EXECUTE format('REVOKE ALL ON TABLE public.%I FROM %I', item.relname, role_name);
      END IF;
    END LOOP;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname='service_role') THEN
      EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.%I TO service_role',item.relname);
    END IF;
    FOR seq IN SELECT s.relname FROM pg_class s JOIN pg_depend d ON d.objid=s.oid
      WHERE s.relkind='S' AND d.refobjid=item.oid AND d.deptype IN ('a','i') LOOP
      EXECUTE format('REVOKE ALL ON SEQUENCE public.%I FROM PUBLIC',seq.relname);
      FOREACH role_name IN ARRAY ARRAY['anon','authenticated'] LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname=role_name) THEN
          EXECUTE format('REVOKE ALL ON SEQUENCE public.%I FROM %I',seq.relname,role_name);
        END IF;
      END LOOP;
      IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname='service_role') THEN
        EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE public.%I TO service_role',seq.relname);
      END IF;
    END LOOP;
  END LOOP;
END $security$;
REVOKE ALL ON FUNCTION "CheckProgramSlot"(), "CheckCoordinationContext"(), "TouchUpdatedAt"() FROM PUBLIC;
-- END GENERATED SECURITY'''
    migration = re.sub(r'-- BEGIN GENERATED SECURITY[\s\S]*?-- END GENERATED SECURITY', '-- SECURITY_BLOCK', migration)
    migration = migration.replace('-- SECURITY_BLOCK', security)
    (OUT/'01_upgrade_it.sql').write_text(migration, encoding='utf-8')
    base = re.sub(r'-- BEGIN GENERATED SECURITY[\s\S]*?-- END GENERATED SECURITY\n?', '', base)
    base_tables = set(re.findall(r'CREATE TABLE "([^"]+)"', base))
    base_security = security
    for table in tables:
        if table not in base_tables:
            base_security = base_security.replace(f'ALTER TABLE "{table}" ENABLE ROW LEVEL SECURITY;\n','')
            base_security = base_security.replace(f'REVOKE ALL ON TABLE "{table}" FROM PUBLIC;\n','')
    base_security = re.sub(r'REVOKE ALL ON FUNCTION[^\n]*\n','',base_security)
    base = base.replace('COMMIT;',base_security+'\nCOMMIT;')
    (OUT/'00_base_for_empty_database.sql').write_text(base,encoding='utf-8')

    programs, courses, combos, members = [], [], [], []
    source_files = []
    for major in ('AI','IA','IS','SE'):
        path = ROOT/'curriculum'/major/f'curricula_{major.lower()}.csv'
        source_files.append(path)
        for row in read_csv(path):
            code = row['curriculum_code']
            programs.append((code,row['curriculum_name'],major,number(row['total_credits'])))
            cp = path.parent/'courses'/f'{code}.csv'
            bp = path.parent/'combo'/code/'combos.csv'
            mp = bp.with_name('combo_courses.csv')
            source_files.extend([cp,bp,mp])
            for r in read_csv(cp):
                assert r['curriculum_code']==code
                c = r['course_code']
                kind = 'COMBO_SLOT' if '_COM*' in c else 'ELECTIVE_SLOT' if '_ELE' in c else 'COURSE'
                courses.append((code,c,r['course_name'],number(r['semester']),number(r['credits']),r['prerequisite'],kind))
            for r in read_csv(bp):
                assert r['curriculum_code']==code
                combos.append((code,number(r['combo_id']),r['combo_name'].split(':',1)[0].strip(),
                               r['combo_name'],r.get('selection_group',''),r.get('note','')))
            for r in read_csv(mp):
                assert r['curriculum_code']==code
                members.append((code,number(r['combo_id']),number(r['combo_subject_id']),r['course_code'],
                                r['course_name'],number(r['semester']),number(r['credits']),r['prerequisite'],r.get('note','')))
    for rows, keys in [(programs,lambda r:r[0]),(courses,lambda r:r[:2]),
                       (combos,lambda r:r[:2]),(members,lambda r:r[:3])]:
        assert len(rows)==len(set(keys(r) for r in rows)), 'Duplicate source key'
    assert {r[:2] for r in combos} == {r[:2] for r in members}, 'Missing combo details'
    canonical = {}
    for r in courses: canonical.setdefault(r[1],r[2])
    for r in members: canonical.setdefault(r[3],r[4])
    source_counts = {'programs':len(programs),'program_courses':len(courses),'program_combos':len(combos),
                     'combo_courses':len(members),'distinct_course_codes':len(canonical)}
    sql = '''-- Generated from all four specializations. Run AFTER 01_upgrade_it.sql.
-- Transactional, repeatable UPSERT. No student assignments, inferred credits or demo records.
-- Source text and case-sensitive codes are retained. Existing unrelated records are not deleted.
BEGIN;
SET LOCAL search_path=public;
SET LOCAL standard_conforming_strings=on;
CREATE TEMP TABLE st_programs(code text,name text,specialization text,credits int) ON COMMIT DROP;
CREATE TEMP TABLE st_courses(program text,code text,name text,semester int,credits numeric,prereq text,kind text) ON COMMIT DROP;
CREATE TEMP TABLE st_combos(program text,source_id int,code text,name text,selection_group text,note text) ON COMMIT DROP;
CREATE TEMP TABLE st_members(program text,combo int,subject int,code text,name text,semester int,credits numeric,prereq text,note text) ON COMMIT DROP;
CREATE TEMP TABLE st_catalog(code text,name text) ON COMMIT DROP;
'''
    for table,rows in [('st_programs',programs),('st_courses',courses),('st_combos',combos),
                       ('st_members',members),('st_catalog',list(canonical.items()))]:
        sql += inserts(table,rows)+'\n'
    sql += '''
INSERT INTO "TrainingPrograms" ("ProgramCode","ProgramName","Specialty","TotalCredits","SpecializationID","CatalogManaged")
SELECT x.code,x.name,x.specialization,x.credits,s."SpecializationID",true
FROM st_programs x JOIN "Specializations" s ON s."SpecializationCode"=x.specialization
ON CONFLICT ("ProgramCode") DO UPDATE SET "ProgramName"=EXCLUDED."ProgramName",
 "Specialty"=EXCLUDED."Specialty","TotalCredits"=EXCLUDED."TotalCredits",
 "SpecializationID"=EXCLUDED."SpecializationID","CatalogManaged"=true;
INSERT INTO "Courses" ("CourseCode","CourseName","Credits") SELECT code,name,NULL FROM st_catalog
ON CONFLICT ("CourseCode") DO NOTHING;
INSERT INTO "ProgramCourses" ("ProgramID","CourseID","CourseName","RecommendedSemester","Credits","PrerequisiteText","EntryKind","IsRequired")
SELECT p."ProgramID",c."CourseID",x.name,x.semester,x.credits,x.prereq,x.kind,NULL
FROM st_courses x JOIN "TrainingPrograms" p ON p."ProgramCode"=x.program JOIN "Courses" c ON c."CourseCode"=x.code
ON CONFLICT ("ProgramID","CourseID") DO UPDATE SET "CourseName"=EXCLUDED."CourseName",
 "RecommendedSemester"=EXCLUDED."RecommendedSemester","Credits"=EXCLUDED."Credits",
 "PrerequisiteText"=EXCLUDED."PrerequisiteText","EntryKind"=EXCLUDED."EntryKind";
INSERT INTO "ProgramCombos" ("ProgramID","SourceComboID","ComboCode","ComboName","SelectionGroup","Note")
SELECT p."ProgramID",x.source_id,x.code,x.name,NULLIF(x.selection_group,''),x.note
FROM st_combos x JOIN "TrainingPrograms" p ON p."ProgramCode"=x.program
ON CONFLICT ("ProgramID","SourceComboID") DO UPDATE SET "ComboCode"=EXCLUDED."ComboCode",
 "ComboName"=EXCLUDED."ComboName","SelectionGroup"=EXCLUDED."SelectionGroup","Note"=EXCLUDED."Note";
INSERT INTO "ComboCourses" ("ProgramComboID","SourceComboSubjectID","CourseID","CourseName","Semester","Credits","PrerequisiteText","Note")
SELECT b."ProgramComboID",x.subject,c."CourseID",x.name,x.semester,x.credits,x.prereq,x.note
FROM st_members x JOIN "TrainingPrograms" p ON p."ProgramCode"=x.program
JOIN "ProgramCombos" b ON b."ProgramID"=p."ProgramID" AND b."SourceComboID"=x.combo
JOIN "Courses" c ON c."CourseCode"=x.code
ON CONFLICT ("ProgramComboID","SourceComboSubjectID") DO UPDATE SET "CourseID"=EXCLUDED."CourseID",
 "CourseName"=EXCLUDED."CourseName","Semester"=EXCLUDED."Semester","Credits"=EXCLUDED."Credits",
 "PrerequisiteText"=EXCLUDED."PrerequisiteText","Note"=EXCLUDED."Note";

-- Only the explicitly supplied Japanese selection rule is encoded here.
-- JPD133, JPD316 and JFE301 + exactly one of JIS401/JIT401.
INSERT INTO "ComboCourseChoiceGroups" ("ProgramComboID","GroupCode","MinCourses","MaxCourses")
SELECT b."ProgramComboID",v.code,v.n,v.n FROM "ProgramCombos" b
JOIN "TrainingPrograms" p ON p."ProgramID"=b."ProgramID"
CROSS JOIN (VALUES ('REQUIRED',3),('JIS_OR_JIT',1)) v(code,n)
WHERE b."SourceComboID"=1469 AND p."ProgramCode" IN (SELECT code FROM st_programs)
ON CONFLICT ("ProgramComboID","GroupCode") DO UPDATE SET "MinCourses"=EXCLUDED."MinCourses","MaxCourses"=EXCLUDED."MaxCourses";
INSERT INTO "ComboCourseChoiceMembers" ("ProgramComboID","ChoiceGroupID","ComboCourseID")
SELECT b."ProgramComboID",g."ChoiceGroupID",cc."ComboCourseID"
FROM "ProgramCombos" b JOIN "TrainingPrograms" p ON p."ProgramID"=b."ProgramID"
JOIN "ComboCourses" cc ON cc."ProgramComboID"=b."ProgramComboID"
JOIN "Courses" c ON c."CourseID"=cc."CourseID"
JOIN "ComboCourseChoiceGroups" g ON g."ProgramComboID"=b."ProgramComboID"
 AND g."GroupCode"=CASE WHEN c."CourseCode" IN ('JIS401','JIT401') THEN 'JIS_OR_JIT' ELSE 'REQUIRED' END
WHERE b."SourceComboID"=1469 AND p."ProgramCode" IN (SELECT code FROM st_programs)
 AND c."CourseCode" IN ('JPD133','JPD316','JFE301','JIS401','JIT401')
ON CONFLICT ("ChoiceGroupID","ComboCourseID") DO NOTHING;
COMMIT;
'''
    (OUT/'02_catalog_data.sql').write_text(sql,encoding='utf-8')
    # Convenience install is one transaction, with no destructive reset.
    combined = '-- NEW EMPTY DATABASE ONLY. Includes base + migration + all CSV catalog data.\nBEGIN;\n'
    selection_migration = OUT/'04_student_specialization_combo.sql'
    parts = [base,migration,sql]
    if selection_migration.exists():
        parts.append(selection_migration.read_text(encoding='utf-8'))
    for part in parts:
        combined += re.sub(r'^(?:BEGIN|COMMIT);\s*$', '', part, flags=re.M)+'\n'
    combined += 'COMMIT;\n'
    (OUT/'install_new_database.sql').write_text(combined,encoding='utf-8')
    manifest = {'counts':source_counts,'source_files':[{ 'path':p.relative_to(ROOT).as_posix(),
                  'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in source_files]}
    (OUT/'source_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
    student_combo_import()
    print(json.dumps(source_counts))

if __name__=='__main__': main()
