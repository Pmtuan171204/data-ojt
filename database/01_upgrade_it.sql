-- OJT-RPA: additive migration from the supplied quoted PascalCase schema.
-- Run once, as database owner, BEFORE 02_catalog_data.sql. No DROP/RESET.
BEGIN;
SET LOCAL search_path = public;
CREATE TABLE IF NOT EXISTS "SchemaMigrations" (
  "Version" text PRIMARY KEY, "AppliedAt" timestamptz NOT NULL DEFAULT now()
);
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM "SchemaMigrations" WHERE "Version"='20261006_it_combos_recruitment') THEN
    RAISE EXCEPTION 'Migration already applied. Run catalog seed or verification instead.';
  END IF;
END $$;

CREATE TABLE "AcademicMajors" (
  "MajorID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "MajorCode" varchar(20) NOT NULL UNIQUE, "MajorName" text NOT NULL
);
CREATE TABLE "Specializations" (
  "SpecializationID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "MajorID" int NOT NULL REFERENCES "AcademicMajors"("MajorID"),
  "SpecializationCode" varchar(20) NOT NULL UNIQUE,
  "SpecializationName" text NOT NULL
);
INSERT INTO "AcademicMajors" ("MajorCode","MajorName") VALUES ('IT','Công nghệ thông tin');
INSERT INTO "Specializations" ("MajorID","SpecializationCode","SpecializationName")
SELECT "MajorID", v.code, v.name FROM "AcademicMajors"
CROSS JOIN (VALUES ('SE','Kỹ thuật phần mềm'),('IA','An toàn thông tin'),
 ('AI','Trí tuệ nhân tạo'),('IS','Hệ thống thông tin')) v(code,name) WHERE "MajorCode"='IT';

ALTER TABLE "TrainingPrograms"
  ALTER COLUMN "ProgramCode" TYPE varchar(100),
  ALTER COLUMN "ProgramName" TYPE text,
  ADD COLUMN "SpecializationID" int REFERENCES "Specializations"("SpecializationID"),
  ADD COLUMN "CatalogManaged" boolean NOT NULL DEFAULT false;
-- Do not guess the exact cohort of legacy students, or turn DS into AI.
UPDATE "TrainingPrograms" p SET "SpecializationID"=s."SpecializationID"
FROM "Specializations" s WHERE p."Specialty"=s."SpecializationCode";
COMMENT ON COLUMN "TrainingPrograms"."ProgramCode" IS 'Exact curriculum_code, including hyphens, underscores and cohort suffixes.';
COMMENT ON COLUMN "TrainingPrograms"."Specialty" IS 'Legacy compatibility field. Use SpecializationID for normalized joins.';
ALTER TABLE "Courses" ALTER COLUMN "CourseName" TYPE text;
COMMENT ON COLUMN "Courses"."Credits" IS 'Legacy/default only. Use ProgramCourses.Credits or verified slot credits for a student curriculum.';
COMMENT ON COLUMN "Courses"."IsOJTPrerequisite" IS 'Legacy global flag. New eligibility rules must be scoped to a program/condition.';
COMMENT ON TABLE "CoursePrerequisites" IS 'Legacy global AND edges. New cohort-specific rules belong to ProgramPrerequisiteGroups.';

ALTER TABLE "ProgramCourses"
  ADD COLUMN "CourseName" text,
  ADD COLUMN "Credits" numeric(6,2) CHECK ("Credits">=0),
  ADD COLUMN "PrerequisiteText" text,
  ADD COLUMN "EntryKind" varchar(20) NOT NULL DEFAULT 'COURSE'
    CHECK ("EntryKind" IN ('COURSE','COMBO_SLOT','ELECTIVE_SLOT')),
  ADD CONSTRAINT "UQ_ProgramCourses_ProgramRow" UNIQUE ("ProgramID","ProgramCourseID");
UPDATE "ProgramCourses" pc SET "CourseName"=c."CourseName", "Credits"=c."Credits"
FROM "Courses" c WHERE c."CourseID"=pc."CourseID";
ALTER TABLE "ProgramCourses" ALTER COLUMN "CourseName" SET NOT NULL;
ALTER TABLE "ProgramCourses" ALTER COLUMN "IsRequired" DROP DEFAULT;
COMMENT ON COLUMN "ProgramCourses"."IsRequired" IS 'NULL = source does not specify. A slot is not an additional real subject.';
COMMENT ON COLUMN "ProgramCourses"."PrerequisiteText" IS 'Verbatim source; blank, None, OR expressions and narrative rules are distinct. Not auto-executed.';

-- All groups required (AND); inside each group pass at least MinimumPassed members.
-- Only populate after academic staff translate and verify the source text.
CREATE TABLE "ProgramPrerequisiteGroups" (
  "GroupID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "ProgramID" int NOT NULL, "ProgramCourseID" int NOT NULL,
  "GroupCode" text NOT NULL, "MinimumPassed" int NOT NULL CHECK ("MinimumPassed">0),
  UNIQUE ("ProgramCourseID","GroupCode"), UNIQUE ("ProgramID","GroupID"),
  FOREIGN KEY ("ProgramID","ProgramCourseID") REFERENCES "ProgramCourses"("ProgramID","ProgramCourseID")
);
CREATE TABLE "ProgramPrerequisiteMembers" (
  "ProgramID" int NOT NULL, "GroupID" int NOT NULL,
  "CourseID" int NOT NULL REFERENCES "Courses"("CourseID"),
  PRIMARY KEY ("GroupID","CourseID"),
  FOREIGN KEY ("ProgramID","GroupID") REFERENCES "ProgramPrerequisiteGroups"("ProgramID","GroupID")
);
CREATE TABLE "EligibilityRequiredCourses" (
  "ConditionID" int NOT NULL REFERENCES "OJTEligibilityConditions"("ConditionID"),
  "CourseID" int NOT NULL REFERENCES "Courses"("CourseID"),
  "MinimumScore" numeric(4,2) CHECK ("MinimumScore" BETWEEN 0 AND 10),
  PRIMARY KEY ("ConditionID","CourseID")
);

-- Combo identity and membership are scoped to a curriculum. Source ID is NOT a global PK.
CREATE TABLE "ProgramCombos" (
  "ProgramComboID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "ProgramID" int NOT NULL REFERENCES "TrainingPrograms"("ProgramID"),
  "SourceComboID" int NOT NULL, "ComboCode" text NOT NULL, "ComboName" text NOT NULL,
  "SelectionGroup" text, "Note" text,
  UNIQUE ("ProgramID","SourceComboID"), UNIQUE ("ProgramID","ProgramComboID")
);
CREATE TABLE "ComboCourses" (
  "ComboCourseID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "ProgramComboID" int NOT NULL REFERENCES "ProgramCombos"("ProgramComboID"),
  "SourceComboSubjectID" int NOT NULL,
  "CourseID" int NOT NULL REFERENCES "Courses"("CourseID"),
  "CourseName" text NOT NULL, "Semester" int CHECK ("Semester">=0),
  "Credits" numeric(6,2) CHECK ("Credits">=0), "PrerequisiteText" text, "Note" text,
  UNIQUE ("ProgramComboID","SourceComboSubjectID"),
  UNIQUE ("ProgramComboID","ComboCourseID")
);
-- Optional explicit groups, e.g. JFE301 is required; choose ONE of JIS401/JIT401.
-- Empty groups mean UNREVIEWED, not that every listed subject is required.
CREATE TABLE "ComboCourseChoiceGroups" (
  "ChoiceGroupID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "ProgramComboID" int NOT NULL REFERENCES "ProgramCombos"("ProgramComboID"),
  "GroupCode" text NOT NULL, "MinCourses" int NOT NULL CHECK ("MinCourses">=0),
  "MaxCourses" int NOT NULL, CHECK ("MaxCourses">="MinCourses"),
  UNIQUE ("ProgramComboID","GroupCode"), UNIQUE ("ProgramComboID","ChoiceGroupID")
);
CREATE TABLE "ComboCourseChoiceMembers" (
  "ProgramComboID" int NOT NULL, "ChoiceGroupID" int NOT NULL, "ComboCourseID" int NOT NULL,
  PRIMARY KEY ("ChoiceGroupID","ComboCourseID"),
  UNIQUE ("ProgramComboID","ComboCourseID"),
  FOREIGN KEY ("ProgramComboID","ChoiceGroupID") REFERENCES "ComboCourseChoiceGroups"("ProgramComboID","ChoiceGroupID"),
  FOREIGN KEY ("ProgramComboID","ComboCourseID") REFERENCES "ComboCourses"("ProgramComboID","ComboCourseID")
);
-- Staff-confirmed mapping from a placeholder slot to allowed actual combo subjects.
-- No automatic mapping by semester: a semester may contain multiple slots/subjects.
CREATE TABLE "ProgramSlotOptions" (
  "ProgramID" int NOT NULL, "ProgramCourseID" int NOT NULL,
  "ProgramComboID" int NOT NULL, "ComboCourseID" int NOT NULL,
  PRIMARY KEY ("ProgramCourseID","ComboCourseID"),
  FOREIGN KEY ("ProgramID","ProgramCourseID") REFERENCES "ProgramCourses"("ProgramID","ProgramCourseID"),
  FOREIGN KEY ("ProgramID","ProgramComboID") REFERENCES "ProgramCombos"("ProgramID","ProgramComboID"),
  FOREIGN KEY ("ProgramComboID","ComboCourseID") REFERENCES "ComboCourses"("ProgramComboID","ComboCourseID")
);
CREATE FUNCTION "CheckProgramSlot"() RETURNS trigger LANGUAGE plpgsql SET search_path=public AS $$
BEGIN
 IF NOT EXISTS (SELECT 1 FROM "ProgramCourses" WHERE "ProgramCourseID"=NEW."ProgramCourseID"
   AND "EntryKind" IN ('COMBO_SLOT','ELECTIVE_SLOT')) THEN
   RAISE EXCEPTION 'ProgramSlotOptions requires a placeholder slot';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER "TR_ProgramSlotOptions" BEFORE INSERT OR UPDATE ON "ProgramSlotOptions"
 FOR EACH ROW EXECUTE FUNCTION "CheckProgramSlot"();

ALTER TABLE "Students" ADD CONSTRAINT "UQ_Students_Program" UNIQUE ("StudentID","ProgramID");
CREATE TABLE "StudentComboSelections" (
  "SelectionID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "StudentID" int NOT NULL, "ProgramID" int NOT NULL, "ProgramComboID" int NOT NULL,
  "SelectedAt" timestamptz NOT NULL DEFAULT now(),
  UNIQUE ("StudentID","ProgramComboID"), UNIQUE ("SelectionID","ProgramComboID"),
  FOREIGN KEY ("StudentID","ProgramID") REFERENCES "Students"("StudentID","ProgramID"),
  FOREIGN KEY ("ProgramID","ProgramComboID") REFERENCES "ProgramCombos"("ProgramID","ProgramComboID")
);
CREATE TABLE "StudentComboCourseSelections" (
  "SelectionID" int NOT NULL, "ProgramComboID" int NOT NULL, "ComboCourseID" int NOT NULL,
  PRIMARY KEY ("SelectionID","ComboCourseID"),
  FOREIGN KEY ("SelectionID","ProgramComboID") REFERENCES "StudentComboSelections"("SelectionID","ProgramComboID"),
  FOREIGN KEY ("ProgramComboID","ComboCourseID") REFERENCES "ComboCourses"("ProgramComboID","ComboCourseID")
);
COMMENT ON TABLE "StudentComboCourseSelections" IS 'Draft choices. Validate min/max groups and slot mapping before approving a study plan; rows alone do not imply eligibility.';

-- Preserve InternshipPositions as enterprise openings for a specific OJT semester.
CREATE TABLE "JobRoles" (
  "JobRoleID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "RoleCode" varchar(60) NOT NULL UNIQUE, "RoleName" text NOT NULL, "Description" text
);
ALTER TABLE "InternshipPositions"
  ADD COLUMN "JobRoleID" int REFERENCES "JobRoles"("JobRoleID"),
  ADD COLUMN "Location" text,
  ADD COLUMN "WorkMode" varchar(20) CHECK ("WorkMode" IN ('ONSITE','REMOTE','HYBRID')),
  ADD CONSTRAINT "UQ_Position_EnterpriseSemester" UNIQUE ("PositionID","EnterpriseID","OJTSemesterID"),
  ADD CONSTRAINT "UQ_Position_Semester" UNIQUE ("PositionID","OJTSemesterID"),
  ADD CONSTRAINT "UQ_Position_Enterprise" UNIQUE ("PositionID","EnterpriseID");
COMMENT ON COLUMN "InternshipPositions"."RemainingSlots" IS 'Legacy mutable counter. Reserve slots in a backend transaction with a position row lock; do not decrement from client requests without locking.';
CREATE TABLE "RecruitmentPosts" (
  "PostID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" int NOT NULL REFERENCES "Enterprises"("EnterpriseID"),
  "OJTSemesterID" int NOT NULL REFERENCES "OJTSemesters"("OJTSemesterID"),
  "Title" text NOT NULL, "Content" text NOT NULL, "Benefits" text, "ApplicationInstructions" text,
  "Status" varchar(20) NOT NULL DEFAULT 'DRAFT'
    CHECK ("Status" IN ('DRAFT','PENDING_REVIEW','PUBLISHED','CLOSED','ARCHIVED')),
  "PublishedAt" timestamptz, "DeadlineAt" timestamptz,
  "CreatedBy" int NOT NULL REFERENCES "Users"("UserID"),
  "ReviewedBy" int REFERENCES "Users"("UserID"), "ReviewedAt" timestamptz,
  "CreatedAt" timestamptz NOT NULL DEFAULT now(), "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  CHECK ("Status" <> 'PUBLISHED' OR "PublishedAt" IS NOT NULL),
  CHECK ("DeadlineAt" IS NULL OR "PublishedAt" IS NULL OR "DeadlineAt">="PublishedAt"),
  UNIQUE ("PostID","EnterpriseID","OJTSemesterID")
);
CREATE TABLE "RecruitmentPostPositions" (
  "PostID" int NOT NULL, "PositionID" int NOT NULL,
  "EnterpriseID" int NOT NULL, "OJTSemesterID" int NOT NULL,
  PRIMARY KEY ("PostID","PositionID"), UNIQUE ("PostID","PositionID","OJTSemesterID"),
  FOREIGN KEY ("PostID","EnterpriseID","OJTSemesterID") REFERENCES "RecruitmentPosts"("PostID","EnterpriseID","OJTSemesterID"),
  FOREIGN KEY ("PositionID","EnterpriseID","OJTSemesterID") REFERENCES "InternshipPositions"("PositionID","EnterpriseID","OJTSemesterID")
);
CREATE TABLE "PositionSpecializations" (
  "PositionID" int NOT NULL REFERENCES "InternshipPositions"("PositionID"),
  "SpecializationID" int NOT NULL REFERENCES "Specializations"("SpecializationID"),
  PRIMARY KEY ("PositionID","SpecializationID")
);
ALTER TABLE "OJTRegistrations"
  ADD CONSTRAINT "UQ_Registration_Semester" UNIQUE ("RegistrationID","OJTSemesterID"),
  ADD CONSTRAINT "FK_Registration_PositionSemester" FOREIGN KEY ("PreferredPositionID","OJTSemesterID")
    REFERENCES "InternshipPositions"("PositionID","OJTSemesterID");
CREATE TABLE "JobApplications" (
  "ApplicationID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "RegistrationID" int NOT NULL, "OJTSemesterID" int NOT NULL,
  "PostID" int NOT NULL, "PositionID" int NOT NULL,
  "ResumeObjectPath" text, "CoverLetter" text,
  "Status" varchar(20) NOT NULL DEFAULT 'SUBMITTED'
    CHECK ("Status" IN ('SUBMITTED','REVIEWING','INTERVIEW','OFFERED','ACCEPTED','REJECTED','WITHDRAWN')),
  "AppliedAt" timestamptz NOT NULL DEFAULT now(), "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
  "ReviewedBy" int REFERENCES "Users"("UserID"), "ReviewNote" text,
  UNIQUE ("RegistrationID","PostID","PositionID"),
  UNIQUE ("ApplicationID","RegistrationID","PositionID"),
  FOREIGN KEY ("RegistrationID","OJTSemesterID") REFERENCES "OJTRegistrations"("RegistrationID","OJTSemesterID"),
  FOREIGN KEY ("PostID","PositionID","OJTSemesterID") REFERENCES "RecruitmentPostPositions"("PostID","PositionID","OJTSemesterID")
);
COMMENT ON COLUMN "JobApplications"."ResumeObjectPath" IS 'Private Supabase Storage object path; backend issues short-lived signed URLs, not permanent public CV links.';
ALTER TABLE "StudentEnterpriseCoordination"
  ADD COLUMN "ApplicationID" int,
  ADD COLUMN "OJTSemesterID" int,
  ADD CONSTRAINT "FK_Coordination_ApplicationContext" FOREIGN KEY ("ApplicationID","RegistrationID","PositionID")
    REFERENCES "JobApplications"("ApplicationID","RegistrationID","PositionID"),
  ADD CONSTRAINT "FK_Coordination_PositionEnterprise" FOREIGN KEY ("PositionID","EnterpriseID")
    REFERENCES "InternshipPositions"("PositionID","EnterpriseID");
UPDATE "StudentEnterpriseCoordination" c SET "OJTSemesterID"=r."OJTSemesterID"
FROM "OJTRegistrations" r WHERE r."RegistrationID"=c."RegistrationID";
ALTER TABLE "StudentEnterpriseCoordination"
  ALTER COLUMN "OJTSemesterID" SET NOT NULL,
  ADD CONSTRAINT "FK_Coordination_RegistrationSemester" FOREIGN KEY ("RegistrationID","OJTSemesterID")
    REFERENCES "OJTRegistrations"("RegistrationID","OJTSemesterID"),
  ADD CONSTRAINT "FK_Coordination_PositionContext" FOREIGN KEY ("PositionID","EnterpriseID","OJTSemesterID")
    REFERENCES "InternshipPositions"("PositionID","EnterpriseID","OJTSemesterID");
-- Existing registration/coordinator flow remains usable when ApplicationID is NULL.
CREATE FUNCTION "CheckCoordinationContext"() RETURNS trigger LANGUAGE plpgsql SET search_path=public AS $$
BEGIN
 IF NEW."OJTSemesterID" IS NULL THEN
   SELECT "OJTSemesterID" INTO NEW."OJTSemesterID" FROM "OJTRegistrations"
     WHERE "RegistrationID"=NEW."RegistrationID";
 END IF;
 IF NOT EXISTS (SELECT 1 FROM "OJTRegistrations" r JOIN "InternshipPositions" p
   ON p."OJTSemesterID"=r."OJTSemesterID"
   WHERE r."RegistrationID"=NEW."RegistrationID" AND p."PositionID"=NEW."PositionID"
   AND p."EnterpriseID"=NEW."EnterpriseID") THEN
   RAISE EXCEPTION 'Coordination position must belong to registration semester and enterprise';
 END IF;
 IF NEW."ApplicationID" IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "JobApplications" a
   WHERE a."ApplicationID"=NEW."ApplicationID" AND a."RegistrationID"=NEW."RegistrationID"
     AND a."PositionID"=NEW."PositionID") THEN
   RAISE EXCEPTION 'Application and coordination context differ';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER "TR_CoordinationContext" BEFORE INSERT OR UPDATE ON "StudentEnterpriseCoordination"
 FOR EACH ROW EXECUTE FUNCTION "CheckCoordinationContext"();
CREATE FUNCTION "TouchUpdatedAt"() RETURNS trigger LANGUAGE plpgsql SET search_path=public AS $$
BEGIN NEW."UpdatedAt"=now(); RETURN NEW; END $$;
CREATE TRIGGER "TR_RecruitmentPosts_Updated" BEFORE UPDATE ON "RecruitmentPosts"
 FOR EACH ROW EXECUTE FUNCTION "TouchUpdatedAt"();
CREATE TRIGGER "TR_JobApplications_Updated" BEFORE UPDATE ON "JobApplications"
 FOR EACH ROW EXECUTE FUNCTION "TouchUpdatedAt"();

CREATE INDEX "IX_Specializations_Major" ON "Specializations"("MajorID");
CREATE INDEX "IX_Programs_Specialization" ON "TrainingPrograms"("SpecializationID");
CREATE INDEX "IX_ComboCourses_Course" ON "ComboCourses"("CourseID");
CREATE INDEX "IX_StudentCombo_Program" ON "StudentComboSelections"("ProgramID","ProgramComboID");
CREATE INDEX "IX_Post_EnterpriseStatus" ON "RecruitmentPosts"("EnterpriseID","Status");
CREATE INDEX "IX_Post_SemesterStatus" ON "RecruitmentPosts"("OJTSemesterID","Status","DeadlineAt");
CREATE INDEX "IX_PostPositions_Position" ON "RecruitmentPostPositions"("PositionID");
CREATE INDEX "IX_Applications_PositionStatus" ON "JobApplications"("PositionID","Status");
CREATE INDEX "IX_Applications_Post" ON "JobApplications"("PostID");
CREATE INDEX "IX_Positions_JobRole" ON "InternshipPositions"("JobRoleID");

INSERT INTO "Permissions" ("PermissionCode","PermissionName","Description") VALUES
 ('CURRICULUM_MANAGE','Manage IT curricula','Manage curriculum, combo and verified selection rules'),
 ('RECRUITMENT_MANAGE','Manage recruitment posts','Create and maintain enterprise-owned job posts'),
 ('RECRUITMENT_REVIEW','Review recruitment posts','Approve publication of recruitment posts'),
 ('JOB_APPLY','Apply for internship positions','Submit and withdraw own applications')
ON CONFLICT ("PermissionCode") DO NOTHING;
INSERT INTO "RolePermissions" ("RoleID","PermissionID")
SELECT r."RoleID",p."PermissionID" FROM "Roles" r CROSS JOIN "Permissions" p
WHERE (r."RoleCode"='ADMIN' AND p."PermissionCode" IN ('CURRICULUM_MANAGE','RECRUITMENT_MANAGE','RECRUITMENT_REVIEW','JOB_APPLY'))
 OR (r."RoleCode"='ACADEMIC' AND p."PermissionCode"='CURRICULUM_MANAGE')
 OR (r."RoleCode"='OJT_COORD' AND p."PermissionCode" IN ('RECRUITMENT_MANAGE','RECRUITMENT_REVIEW'))
 OR (r."RoleCode"='ENTERPRISE' AND p."PermissionCode"='RECRUITMENT_MANAGE')
 OR (r."RoleCode"='STUDENT' AND p."PermissionCode"='JOB_APPLY')
ON CONFLICT ("RoleID","PermissionID") DO NOTHING;

INSERT INTO "SchemaMigrations" ("Version") VALUES ('20261006_it_combos_recruitment');
-- Security block is generated below by build_database.py for precisely this application's tables.
-- BEGIN GENERATED SECURITY
-- Backend-only Data API. SQL editor owner/service_role bypass RLS.
ALTER TABLE "AIModelConfig" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "AIModelConfig" FROM PUBLIC;
ALTER TABLE "AIModels" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "AIModels" FROM PUBLIC;
ALTER TABLE "AcademicMajors" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "AcademicMajors" FROM PUBLIC;
ALTER TABLE "AcademicYears" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "AcademicYears" FROM PUBLIC;
ALTER TABLE "AuditLogs" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "AuditLogs" FROM PUBLIC;
ALTER TABLE "ComboCourseChoiceGroups" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "ComboCourseChoiceGroups" FROM PUBLIC;
ALTER TABLE "ComboCourseChoiceMembers" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "ComboCourseChoiceMembers" FROM PUBLIC;
ALTER TABLE "ComboCourses" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "ComboCourses" FROM PUBLIC;
ALTER TABLE "CoursePrerequisites" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "CoursePrerequisites" FROM PUBLIC;
ALTER TABLE "Courses" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Courses" FROM PUBLIC;
ALTER TABLE "EligibilityRequiredCourses" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "EligibilityRequiredCourses" FROM PUBLIC;
ALTER TABLE "EnterpriseUsers" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "EnterpriseUsers" FROM PUBLIC;
ALTER TABLE "Enterprises" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Enterprises" FROM PUBLIC;
ALTER TABLE "IncidentReports" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "IncidentReports" FROM PUBLIC;
ALTER TABLE "InternshipAssignments" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "InternshipAssignments" FROM PUBLIC;
ALTER TABLE "InternshipEvaluations" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "InternshipEvaluations" FROM PUBLIC;
ALTER TABLE "InternshipPositions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "InternshipPositions" FROM PUBLIC;
ALTER TABLE "InternshipTasks" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "InternshipTasks" FROM PUBLIC;
ALTER TABLE "JobApplications" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "JobApplications" FROM PUBLIC;
ALTER TABLE "JobRoles" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "JobRoles" FROM PUBLIC;
ALTER TABLE "NotificationTemplates" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "NotificationTemplates" FROM PUBLIC;
ALTER TABLE "Notifications" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Notifications" FROM PUBLIC;
ALTER TABLE "OJTEligibilityConditions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "OJTEligibilityConditions" FROM PUBLIC;
ALTER TABLE "OJTRegistrations" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "OJTRegistrations" FROM PUBLIC;
ALTER TABLE "OJTSemesters" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "OJTSemesters" FROM PUBLIC;
ALTER TABLE "PathwayRecommendations" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "PathwayRecommendations" FROM PUBLIC;
ALTER TABLE "Permissions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Permissions" FROM PUBLIC;
ALTER TABLE "PositionSpecializations" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "PositionSpecializations" FROM PUBLIC;
ALTER TABLE "ProgramCombos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "ProgramCombos" FROM PUBLIC;
ALTER TABLE "ProgramCourses" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "ProgramCourses" FROM PUBLIC;
ALTER TABLE "ProgramPrerequisiteGroups" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "ProgramPrerequisiteGroups" FROM PUBLIC;
ALTER TABLE "ProgramPrerequisiteMembers" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "ProgramPrerequisiteMembers" FROM PUBLIC;
ALTER TABLE "ProgramSlotOptions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "ProgramSlotOptions" FROM PUBLIC;
ALTER TABLE "RecruitmentPostPositions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "RecruitmentPostPositions" FROM PUBLIC;
ALTER TABLE "RecruitmentPosts" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "RecruitmentPosts" FROM PUBLIC;
ALTER TABLE "RiskPredictions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "RiskPredictions" FROM PUBLIC;
ALTER TABLE "RolePermissions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "RolePermissions" FROM PUBLIC;
ALTER TABLE "Roles" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Roles" FROM PUBLIC;
ALTER TABLE "SchemaMigrations" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "SchemaMigrations" FROM PUBLIC;
ALTER TABLE "Specializations" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Specializations" FROM PUBLIC;
ALTER TABLE "StudentAcademicSnapshot" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "StudentAcademicSnapshot" FROM PUBLIC;
ALTER TABLE "StudentComboCourseSelections" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "StudentComboCourseSelections" FROM PUBLIC;
ALTER TABLE "StudentComboSelections" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "StudentComboSelections" FROM PUBLIC;
ALTER TABLE "StudentCourseResults" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "StudentCourseResults" FROM PUBLIC;
ALTER TABLE "StudentEnterpriseCoordination" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "StudentEnterpriseCoordination" FROM PUBLIC;
ALTER TABLE "StudentOJTEligibility" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "StudentOJTEligibility" FROM PUBLIC;
ALTER TABLE "Students" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Students" FROM PUBLIC;
ALTER TABLE "SupportClassAISuggestions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "SupportClassAISuggestions" FROM PUBLIC;
ALTER TABLE "SupportClassRegistrations" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "SupportClassRegistrations" FROM PUBLIC;
ALTER TABLE "SupportClasses" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "SupportClasses" FROM PUBLIC;
ALTER TABLE "SupportRequests" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "SupportRequests" FROM PUBLIC;
ALTER TABLE "TaskProgressUpdates" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "TaskProgressUpdates" FROM PUBLIC;
ALTER TABLE "TrainingPrograms" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "TrainingPrograms" FROM PUBLIC;
ALTER TABLE "Users" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Users" FROM PUBLIC;
DO $security$
DECLARE item record; seq record; role_name text;
BEGIN
  FOR item IN SELECT c.oid,c.relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='public' AND c.relname = ANY (ARRAY['AIModelConfig','AIModels','AcademicMajors','AcademicYears','AuditLogs','ComboCourseChoiceGroups','ComboCourseChoiceMembers','ComboCourses','CoursePrerequisites','Courses','EligibilityRequiredCourses','EnterpriseUsers','Enterprises','IncidentReports','InternshipAssignments','InternshipEvaluations','InternshipPositions','InternshipTasks','JobApplications','JobRoles','NotificationTemplates','Notifications','OJTEligibilityConditions','OJTRegistrations','OJTSemesters','PathwayRecommendations','Permissions','PositionSpecializations','ProgramCombos','ProgramCourses','ProgramPrerequisiteGroups','ProgramPrerequisiteMembers','ProgramSlotOptions','RecruitmentPostPositions','RecruitmentPosts','RiskPredictions','RolePermissions','Roles','SchemaMigrations','Specializations','StudentAcademicSnapshot','StudentComboCourseSelections','StudentComboSelections','StudentCourseResults','StudentEnterpriseCoordination','StudentOJTEligibility','Students','SupportClassAISuggestions','SupportClassRegistrations','SupportClasses','SupportRequests','TaskProgressUpdates','TrainingPrograms','Users']) LOOP
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
-- END GENERATED SECURITY
COMMIT;
