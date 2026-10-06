-- Read-only checks after installation or migration + catalog import.
SET search_path=public;

-- Expected catalog: AI 11, IA 11, IS 8, SE 10 = 40 programs.
SELECT s."SpecializationCode", count(*) AS "Curricula"
FROM "TrainingPrograms" p JOIN "Specializations" s USING ("SpecializationID")
WHERE p."CatalogManaged" GROUP BY s."SpecializationCode" ORDER BY 1;
SELECT 'ProgramCourses' AS "Table",count(*) AS "CatalogRows" FROM "ProgramCourses" pc
JOIN "TrainingPrograms" p USING ("ProgramID") WHERE p."CatalogManaged"
UNION ALL SELECT 'ProgramCombos',count(*) FROM "ProgramCombos" b
JOIN "TrainingPrograms" p USING ("ProgramID") WHERE p."CatalogManaged"
UNION ALL SELECT 'ComboCourses',count(*) FROM "ComboCourses" cc
JOIN "ProgramCombos" b USING ("ProgramComboID") JOIN "TrainingPrograms" p USING ("ProgramID") WHERE p."CatalogManaged";
-- Expected: 1924, 279, 1029 respectively.

-- Zero rows expected for imported curricula. Do NOT add combo credits to this sum.
SELECT p."ProgramCode",p."TotalCredits",sum(pc."Credits") AS "SourceCredits"
FROM "TrainingPrograms" p JOIN "ProgramCourses" pc USING ("ProgramID")
WHERE p."CatalogManaged" GROUP BY p."ProgramID"
HAVING sum(pc."Credits") IS DISTINCT FROM p."TotalCredits";

-- Legacy students need an explicit exact curriculum mapping; DS is not automatically AI.
SELECT st."StudentID",st."StudentCode",p."ProgramCode",p."Specialty"
FROM "Students" st LEFT JOIN "TrainingPrograms" p USING ("ProgramID")
WHERE p."ProgramID" IS NULL OR NOT p."CatalogManaged";

-- Source curriculum/name/prerequisite details (rather than legacy global defaults).
SELECT p."ProgramCode",c."CourseCode",pc."CourseName",pc."RecommendedSemester",pc."Credits",
 pc."EntryKind",pc."PrerequisiteText"
FROM "ProgramCourses" pc JOIN "TrainingPrograms" p USING ("ProgramID") JOIN "Courses" c USING ("CourseID")
WHERE p."ProgramCode"='BIT_SE-2026_K21D_K22A'
ORDER BY pc."RecommendedSemester",pc."ProgramCourseID";
SELECT p."ProgramCode",b."SourceComboID",b."ComboCode",c."CourseCode",cc."CourseName",cc."Semester",cc."Credits"
FROM "ProgramCombos" b JOIN "TrainingPrograms" p USING ("ProgramID")
JOIN "ComboCourses" cc USING ("ProgramComboID") JOIN "Courses" c USING ("CourseID")
WHERE p."ProgramCode"='BIT_SE-2026_K21D_K22A' ORDER BY b."SourceComboID",cc."SourceComboSubjectID";

-- Draft choices outside verified min/max. No rows does NOT prove an entire plan is valid:
-- also check unreviewed groups, placeholder mapping, and academic eligibility rules.
SELECT sc."SelectionID",g."GroupCode",g."MinCourses",g."MaxCourses",count(ch."ComboCourseID") AS "Chosen"
FROM "StudentComboSelections" sc JOIN "ComboCourseChoiceGroups" g USING ("ProgramComboID")
LEFT JOIN "ComboCourseChoiceMembers" m USING ("ProgramComboID","ChoiceGroupID")
LEFT JOIN "StudentComboCourseSelections" ch ON ch."SelectionID"=sc."SelectionID" AND ch."ComboCourseID"=m."ComboCourseID"
GROUP BY sc."SelectionID",g."ChoiceGroupID" HAVING count(ch."ComboCourseID") NOT BETWEEN g."MinCourses" AND g."MaxCourses";

-- Unreviewed placeholders: expected until academic staff supply exact slot mappings.
SELECT p."ProgramCode",c."CourseCode",pc."EntryKind"
FROM "ProgramCourses" pc JOIN "TrainingPrograms" p USING ("ProgramID") JOIN "Courses" c USING ("CourseID")
WHERE p."CatalogManaged" AND pc."EntryKind"<>'COURSE'
AND NOT EXISTS (SELECT 1 FROM "ProgramSlotOptions" o WHERE o."ProgramCourseID"=pc."ProgramCourseID");

-- Expected zero exposed application tables lacking RLS; unrelated tables may also be listed.
SELECT tablename FROM pg_tables WHERE schemaname='public' AND NOT rowsecurity;

-- Read model for published, non-expired posts; backend also verifies permissions/eligibility on apply.
SELECT p."PostID",p."Title",e."Name" AS "Enterprise",ip."PositionID",ip."Title" AS "Position",
 ip."Capacity",ip."WorkMode",ip."Location",p."DeadlineAt"
FROM "RecruitmentPosts" p JOIN "Enterprises" e USING ("EnterpriseID")
JOIN "RecruitmentPostPositions" link ON link."PostID"=p."PostID"
JOIN "InternshipPositions" ip ON ip."PositionID"=link."PositionID"
WHERE p."Status"='PUBLISHED' AND (p."DeadlineAt" IS NULL OR p."DeadlineAt">now());
