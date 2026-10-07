/*
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

SET LOCAL search_path=public,pg_catalog;
CREATE TEMP TABLE _ojt_reset_targets ON COMMIT DROP AS
WITH RECURSIVE roots AS (
 SELECT c.oid FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='public' AND c.relname IN ('AIModelConfig','AIModels','AcademicMajors','AcademicYears','AuditLogs','ComboCourseChoiceGroups','ComboCourseChoiceMembers','ComboCourses','ComboRegistrationWindows','CoursePrerequisites','Courses','Curricula','CurriculumComboCourses','CurriculumCourses','CurriculumPrerequisiteOptions','CurriculumRuleReviews','EligibilityRequiredCourses','EmbeddingConfigurations','EnterpriseUsers','Enterprises','ImportBatches','ImportRows','IncidentReports','InternshipAssignments','InternshipEvaluations','InternshipPositions','InternshipTasks','JobApplications','JobRoles','MatchingAPICalls','MatchingCandidates','MatchingEmbeddings','MatchingProfileCourses','MatchingProfileJobRoles','MatchingProfileMajors','MatchingProfileSkills','MatchingProfileSpecializations','MatchingRecommendationFeedback','MatchingRecommendations','MatchingRuns','MatchingSkills','NotificationTemplates','Notifications','OJTAlertCheckRuns','OJTAlertDeliveries','OJTAlertEvaluations','OJTAlertEvents','OJTAlertRules','OJTAlertTargets','OJTAlerts','OJTEligibilityConditions','OJTEnterpriseImportBatches','OJTEnterpriseImportRows','OJTHistoricalOutcomes','OJTMatchingProfiles','OJTRegistrationPolicies','OJTRegistrations','OJTRuleSets','OJTSemesters','PathwayRecommendationItems','PathwayRecommendations','Permissions','PositionSpecializations','ProgramCombos','ProgramCourses','ProgramPrerequisiteGroups','ProgramPrerequisiteMembers','ProgramSlotOptions','RecruitmentPostPositions','RecruitmentPosts','RiskPredictions','RolePermissions','Roles','SchemaMigrations','Specializations','StudentAcademicSnapshot','StudentCareerInterests','StudentCareerProfiles','StudentComboCourseSelections','StudentComboSelectionEvents','StudentComboSelections','StudentCourseResults','StudentEnterpriseCoordination','StudentMatchingSkills','StudentOJTEligibility','Students','SupportClassAISuggestions','SupportClassRegistrations','SupportClassSuggestionStudents','SupportClasses','SupportRequestFiles','SupportRequestMessages','SupportRequests','SystemSettings','TaskProgressUpdates','TrainingPrograms','UserSessions','Users','academicmajors','academicyears','aimodelconfig','aimodels','auditlogs','combocoursechoicegroups','combocoursechoicemembers','combocourses','comboregistrationwindows','courseprerequisites','courses','curricula','curriculumcombocourses','curriculumcourses','curriculumprerequisiteoptions','curriculumrulereviews','eligibilityrequiredcourses','embeddingconfigurations','enterprises','enterpriseusers','importbatches','importrows','incidentreports','internshipassignments','internshipevaluations','internshippositions','internshiptasks','jobapplications','jobroles','matchingapicalls','matchingcandidates','matchingembeddings','matchingprofilecourses','matchingprofilejobroles','matchingprofilemajors','matchingprofileskills','matchingprofilespecializations','matchingrecommendationfeedback','matchingrecommendations','matchingruns','matchingskills','notifications','notificationtemplates','ojtalertcheckruns','ojtalertdeliveries','ojtalertevaluations','ojtalertevents','ojtalertrules','ojtalerts','ojtalerttargets','ojteligibilityconditions','ojtenterpriseimportbatches','ojtenterpriseimportrows','ojthistoricaloutcomes','ojtmatchingprofiles','ojtregistrationpolicies','ojtregistrations','ojtrulesets','ojtsemesters','pathwayrecommendationitems','pathwayrecommendations','permissions','positionspecializations','programcombos','programcourses','programprerequisitegroups','programprerequisitemembers','programslotoptions','recruitmentpostpositions','recruitmentposts','riskpredictions','rolepermissions','roles','schemamigrations','specializations','studentacademicsnapshot','studentcareerinterests','studentcareerprofiles','studentcombocourseselections','studentcomboselectionevents','studentcomboselections','studentcourseresults','studententerprisecoordination','studentmatchingskills','studentojteligibility','students','supportclassaisuggestions','supportclasses','supportclassregistrations','supportclasssuggestionstudents','supportrequestfiles','supportrequestmessages','supportrequests','systemsettings','taskprogressupdates','trainingprograms','users','usersessions','InternshipPositionAvailability','internshippositionavailability')
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
DROP FUNCTION IF EXISTS public."CheckProgramSlot"();
DROP FUNCTION IF EXISTS public."CheckCoordinationContext"();
DROP FUNCTION IF EXISTS public."TouchUpdatedAt"();
DROP FUNCTION IF EXISTS public."ClassifyStudentCombo"();
DROP FUNCTION IF EXISTS public."ReclassifyComboSelections"();
DROP FUNCTION IF EXISTS public."CheckOJTAlertTaskContext"();


-- SECTION: 00_base_for_empty_database.sql
-- EMPTY DATABASE ONLY. Safe create: no reset, drops or demo users.
-- Backend hashes passwords; no pgcrypto dependency needed by this DDL.

SET LOCAL search_path=public;
CREATE TABLE "Roles" (
    "RoleID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "RoleCode" VARCHAR(30) NOT NULL UNIQUE,
    "RoleName" VARCHAR(100) NOT NULL
);

CREATE TABLE "Permissions" (
    "PermissionID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "PermissionCode" VARCHAR(50) NOT NULL UNIQUE,
    "PermissionName" VARCHAR(150) NOT NULL,
    "Description" VARCHAR(300)
);

CREATE TABLE "RolePermissions" (
    "RolePermissionID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "RoleID" INT NOT NULL,
    "PermissionID" INT NOT NULL,
    CONSTRAINT "UQ_RolePermissions" UNIQUE ("RoleID", "PermissionID"),
    CONSTRAINT "FK_RolePermissions_Role"
        FOREIGN KEY ("RoleID") REFERENCES "Roles"("RoleID") ON DELETE CASCADE,
    CONSTRAINT "FK_RolePermissions_Permission"
        FOREIGN KEY ("PermissionID") REFERENCES "Permissions"("PermissionID") ON DELETE CASCADE
);

CREATE TABLE "Users" (
    "UserID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "Username" VARCHAR(50) NOT NULL UNIQUE,
    "PasswordHash" VARCHAR(255) NOT NULL,
    "Email" VARCHAR(100) NOT NULL UNIQUE,
    "Phone" VARCHAR(20),
    "FullName" VARCHAR(150) NOT NULL,
    "RoleID" INT NOT NULL,
    "Status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    "CreatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "LastLoginAt" TIMESTAMP,
    CONSTRAINT "FK_Users_Role" FOREIGN KEY ("RoleID") REFERENCES "Roles"("RoleID")
);


/* ============================================================
   2. ACADEMIC MANAGEMENT
   ============================================================ */

CREATE TABLE "AcademicYears" (
    "AcademicYearID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "YearCode" VARCHAR(20) NOT NULL UNIQUE,
    "StartDate" DATE,
    "EndDate" DATE,
    "Status" VARCHAR(20)
);

CREATE TABLE "OJTSemesters" (
    "OJTSemesterID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "AcademicYearID" INT NOT NULL,
    "SemesterCode" VARCHAR(20) NOT NULL UNIQUE,
    "Name" VARCHAR(100) NOT NULL,
    "RegStartDate" DATE,
    "RegEndDate" DATE,
    "StartDate" DATE,
    "EndDate" DATE,
    "Status" VARCHAR(30),
    CONSTRAINT "FK_OJTSemesters_AcademicYear"
        FOREIGN KEY ("AcademicYearID") REFERENCES "AcademicYears"("AcademicYearID")
);

CREATE TABLE "TrainingPrograms" (
    "ProgramID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "ProgramCode" VARCHAR(20) NOT NULL UNIQUE,
    "ProgramName" VARCHAR(150) NOT NULL,
    "Specialty" VARCHAR(10),
    "TotalCredits" INT,
    "Version" VARCHAR(10),
    "EffectiveYear" INT
);

CREATE TABLE "Courses" (
    "CourseID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "CourseCode" VARCHAR(20) NOT NULL UNIQUE,
    "CourseName" VARCHAR(150) NOT NULL,
    "Credits" INT,
    "IsOJTPrerequisite" BOOLEAN DEFAULT FALSE
);

CREATE TABLE "CoursePrerequisites" (
    "CourseID" INT NOT NULL,
    "PrerequisiteCourseID" INT NOT NULL,
    CONSTRAINT "PK_CoursePrerequisites" PRIMARY KEY ("CourseID", "PrerequisiteCourseID"),
    CONSTRAINT "FK_CoursePrerequisites_Course"
        FOREIGN KEY ("CourseID") REFERENCES "Courses"("CourseID") ON DELETE CASCADE,
    CONSTRAINT "FK_CoursePrerequisites_Prerequisite"
        FOREIGN KEY ("PrerequisiteCourseID") REFERENCES "Courses"("CourseID"),
    CONSTRAINT "CHK_CoursePrerequisites_Self" CHECK ("CourseID" <> "PrerequisiteCourseID")
);

CREATE TABLE "ProgramCourses" (
    "ProgramCourseID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "ProgramID" INT NOT NULL,
    "CourseID" INT NOT NULL,
    "RecommendedSemester" INT,
    "IsRequired" BOOLEAN DEFAULT TRUE,
    CONSTRAINT "UQ_ProgramCourses" UNIQUE ("ProgramID", "CourseID"),
    CONSTRAINT "FK_ProgramCourses_Program"
        FOREIGN KEY ("ProgramID") REFERENCES "TrainingPrograms"("ProgramID") ON DELETE CASCADE,
    CONSTRAINT "FK_ProgramCourses_Course"
        FOREIGN KEY ("CourseID") REFERENCES "Courses"("CourseID") ON DELETE CASCADE
);

/*
   Specialty is intentionally NOT stored in Students.
   Student specialty is derived through:

   Students.ProgramID
        -> TrainingPrograms.ProgramID
        -> TrainingPrograms.Specialty
*/

CREATE TABLE "Students" (
    "StudentID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "UserID" INT NOT NULL UNIQUE,
    "StudentCode" VARCHAR(20) NOT NULL UNIQUE,
    "ProgramID" INT,
    "EnrollmentYear" INT,
    "CurrentSemester" INT,
    "ClassName" VARCHAR(20),
    "Status" VARCHAR(30),
    CONSTRAINT "FK_Students_User"
        FOREIGN KEY ("UserID") REFERENCES "Users"("UserID") ON DELETE CASCADE,
    CONSTRAINT "FK_Students_Program"
        FOREIGN KEY ("ProgramID") REFERENCES "TrainingPrograms"("ProgramID") ON DELETE SET NULL
);

CREATE TABLE "StudentCourseResults" (
    "ResultID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "StudentID" INT NOT NULL,
    "CourseID" INT NOT NULL,
    "SemesterTaken" INT,
    "AcademicYearID" INT,
    "Score" NUMERIC(4,2),
    "Grade" VARCHAR(2),
    "Status" VARCHAR(20),
    CONSTRAINT "UQ_StudentCourseResults" UNIQUE ("StudentID", "CourseID", "SemesterTaken"),
    CONSTRAINT "FK_StudentCourseResults_Student"
        FOREIGN KEY ("StudentID") REFERENCES "Students"("StudentID") ON DELETE CASCADE,
    CONSTRAINT "FK_StudentCourseResults_Course"
        FOREIGN KEY ("CourseID") REFERENCES "Courses"("CourseID"),
    CONSTRAINT "FK_StudentCourseResults_AcademicYear"
        FOREIGN KEY ("AcademicYearID") REFERENCES "AcademicYears"("AcademicYearID") ON DELETE SET NULL
);

CREATE TABLE "StudentAcademicSnapshot" (
    "SnapshotID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "StudentID" INT NOT NULL,
    "SnapshotDate" DATE NOT NULL,
    "GPA" NUMERIC(3,2),
    "AccumulatedCredits" INT,
    "RemainingCredits" INT,
    "FailedCoursesCount" INT,
    "CurrentSemester" INT,
    "TargetOJTSemesterID" INT,
    CONSTRAINT "FK_StudentAcademicSnapshot_Student"
        FOREIGN KEY ("StudentID") REFERENCES "Students"("StudentID") ON DELETE CASCADE,
    CONSTRAINT "FK_StudentAcademicSnapshot_Semester"
        FOREIGN KEY ("TargetOJTSemesterID") REFERENCES "OJTSemesters"("OJTSemesterID") ON DELETE SET NULL
);


/* ============================================================
   3. OJT ELIGIBILITY MANAGEMENT
   ============================================================ */

CREATE TABLE "OJTEligibilityConditions" (
    "ConditionID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "ProgramID" INT NOT NULL,
    "OJTSemesterID" INT,
    "MinGPA" NUMERIC(3,2),
    "MinCredits" INT,
    "RequiredCoursesNote" VARCHAR(500),
    "Description" VARCHAR(500),
    CONSTRAINT "FK_OJTEligibilityConditions_Program"
        FOREIGN KEY ("ProgramID") REFERENCES "TrainingPrograms"("ProgramID") ON DELETE CASCADE,
    CONSTRAINT "FK_OJTEligibilityConditions_Semester"
        FOREIGN KEY ("OJTSemesterID") REFERENCES "OJTSemesters"("OJTSemesterID") ON DELETE SET NULL
);

CREATE TABLE "StudentOJTEligibility" (
    "EligibilityID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "StudentID" INT NOT NULL,
    "OJTSemesterID" INT NOT NULL,
    "Status" VARCHAR(30) NOT NULL,
    "CheckedDate" TIMESTAMP,
    "CheckedBy" INT,
    "MissingCredits" INT,
    "MissingCoursesNote" VARCHAR(1000),
    CONSTRAINT "UQ_StudentOJTEligibility" UNIQUE ("StudentID", "OJTSemesterID"),
    CONSTRAINT "FK_StudentOJTEligibility_Student"
        FOREIGN KEY ("StudentID") REFERENCES "Students"("StudentID") ON DELETE CASCADE,
    CONSTRAINT "FK_StudentOJTEligibility_Semester"
        FOREIGN KEY ("OJTSemesterID") REFERENCES "OJTSemesters"("OJTSemesterID"),
    CONSTRAINT "FK_StudentOJTEligibility_CheckedBy"
        FOREIGN KEY ("CheckedBy") REFERENCES "Users"("UserID") ON DELETE NO ACTION
);


/* ============================================================
   4. ACADEMIC PATHWAY ADVISING (STAFF-MANAGED)
   ============================================================ */









CREATE TABLE "PathwayRecommendations" (
    "RecommendationID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "StudentID" INT NOT NULL,
    "OJTSemesterID" INT NOT NULL,
    "MissingCourses" VARCHAR(1000),
    "RecommendedPlan" TEXT,
    "GeneratedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "Status" VARCHAR(20),
    CONSTRAINT "FK_PathwayRecommendations_Student"
        FOREIGN KEY ("StudentID") REFERENCES "Students"("StudentID") ON DELETE CASCADE,
    CONSTRAINT "FK_PathwayRecommendations_Semester"
        FOREIGN KEY ("OJTSemesterID") REFERENCES "OJTSemesters"("OJTSemesterID")
);




/* ============================================================
   5. SUPPORT CLASS MANAGEMENT
   ============================================================ */

CREATE TABLE "SupportClasses" (
    "SupportClassID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "CourseID" INT NOT NULL,
    "OJTSemesterID" INT NOT NULL,
    "ClassName" VARCHAR(100),
    "StartDate" DATE,
    "EndDate" DATE,
    "Capacity" INT,
    "CreatedBy" INT,
    "Status" VARCHAR(20),
    CONSTRAINT "FK_SupportClasses_Course"
        FOREIGN KEY ("CourseID") REFERENCES "Courses"("CourseID"),
    CONSTRAINT "FK_SupportClasses_Semester"
        FOREIGN KEY ("OJTSemesterID") REFERENCES "OJTSemesters"("OJTSemesterID"),
    CONSTRAINT "FK_SupportClasses_CreatedBy"
        FOREIGN KEY ("CreatedBy") REFERENCES "Users"("UserID") ON DELETE SET NULL
);

CREATE TABLE "SupportClassRegistrations" (
    "RegistrationID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "SupportClassID" INT NOT NULL,
    "StudentID" INT NOT NULL,
    "RegisteredDate" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "Status" VARCHAR(20),
    CONSTRAINT "UQ_SupportClassStudent" UNIQUE ("SupportClassID", "StudentID"),
    CONSTRAINT "FK_SupportClassRegistrations_Class"
        FOREIGN KEY ("SupportClassID") REFERENCES "SupportClasses"("SupportClassID") ON DELETE CASCADE,
    CONSTRAINT "FK_SupportClassRegistrations_Student"
        FOREIGN KEY ("StudentID") REFERENCES "Students"("StudentID") ON DELETE CASCADE
);


/* ============================================================
   6. ENTERPRISE & OJT REGISTRATION
   ============================================================ */

CREATE TABLE "Enterprises" (
    "EnterpriseID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "EnterpriseCode" VARCHAR(20) NOT NULL UNIQUE,
    "Name" VARCHAR(200) NOT NULL,
    "Address" VARCHAR(300),
    "Industry" VARCHAR(100),
    "ContactPersonName" VARCHAR(100),
    "ContactPhone" VARCHAR(20),
    "ContactEmail" VARCHAR(100),
    "Status" VARCHAR(20),
    "CreatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "EnterpriseUsers" (
    "EnterpriseUserID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "UserID" INT NOT NULL UNIQUE,
    "EnterpriseID" INT NOT NULL,
    "PositionTitle" VARCHAR(100),
    CONSTRAINT "FK_EnterpriseUsers_User"
        FOREIGN KEY ("UserID") REFERENCES "Users"("UserID") ON DELETE CASCADE,
    CONSTRAINT "FK_EnterpriseUsers_Enterprise"
        FOREIGN KEY ("EnterpriseID") REFERENCES "Enterprises"("EnterpriseID") ON DELETE CASCADE
);

CREATE TABLE "InternshipPositions" (
    "PositionID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "EnterpriseID" INT NOT NULL,
    "OJTSemesterID" INT NOT NULL,
    "Title" VARCHAR(150) NOT NULL,
    "Description" TEXT,
    "Requirements" TEXT,
    "Capacity" INT,
    "RemainingSlots" INT,
    "Status" VARCHAR(20),
    CONSTRAINT "FK_InternshipPositions_Enterprise"
        FOREIGN KEY ("EnterpriseID") REFERENCES "Enterprises"("EnterpriseID") ON DELETE CASCADE,
    CONSTRAINT "FK_InternshipPositions_Semester"
        FOREIGN KEY ("OJTSemesterID") REFERENCES "OJTSemesters"("OJTSemesterID")
);

CREATE TABLE "OJTRegistrations" (
    "RegistrationID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "StudentID" INT NOT NULL,
    "OJTSemesterID" INT NOT NULL,
    "RegisteredAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "PreferredPositionID" INT,
    "Status" VARCHAR(30),
    CONSTRAINT "UQ_OJTRegistration" UNIQUE ("StudentID", "OJTSemesterID"),
    CONSTRAINT "FK_OJTRegistrations_Student"
        FOREIGN KEY ("StudentID") REFERENCES "Students"("StudentID") ON DELETE CASCADE,
    CONSTRAINT "FK_OJTRegistrations_Semester"
        FOREIGN KEY ("OJTSemesterID") REFERENCES "OJTSemesters"("OJTSemesterID"),
    CONSTRAINT "FK_OJTRegistrations_Position"
        FOREIGN KEY ("PreferredPositionID") REFERENCES "InternshipPositions"("PositionID") ON DELETE SET NULL
);

CREATE TABLE "StudentEnterpriseCoordination" (
    "CoordinationID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "RegistrationID" INT NOT NULL,
    "EnterpriseID" INT NOT NULL,
    "PositionID" INT NOT NULL,
    "CoordinatedBy" INT NOT NULL,
    "CoordinatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "Decision" VARCHAR(20),
    "DecisionAt" TIMESTAMP,
    "RejectReason" VARCHAR(300),
    "PreviousCoordinationID" INT,
    CONSTRAINT "FK_StudentEnterpriseCoordination_Registration"
        FOREIGN KEY ("RegistrationID") REFERENCES "OJTRegistrations"("RegistrationID") ON DELETE CASCADE,
    CONSTRAINT "FK_StudentEnterpriseCoordination_Enterprise"
        FOREIGN KEY ("EnterpriseID") REFERENCES "Enterprises"("EnterpriseID"),
    CONSTRAINT "FK_StudentEnterpriseCoordination_Position"
        FOREIGN KEY ("PositionID") REFERENCES "InternshipPositions"("PositionID"),
    CONSTRAINT "FK_StudentEnterpriseCoordination_User"
        FOREIGN KEY ("CoordinatedBy") REFERENCES "Users"("UserID"),
    CONSTRAINT "FK_StudentEnterpriseCoordination_Previous"
        FOREIGN KEY ("PreviousCoordinationID") REFERENCES "StudentEnterpriseCoordination"("CoordinationID") ON DELETE NO ACTION
);


/* ============================================================
   7. INTERNSHIP MANAGEMENT
   ============================================================ */

CREATE TABLE "InternshipAssignments" (
    "AssignmentID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "CoordinationID" INT NOT NULL UNIQUE,
    "StudentID" INT NOT NULL,
    "EnterpriseID" INT NOT NULL,
    "PositionID" INT NOT NULL,
    "EnterpriseSupervisorName" VARCHAR(100),
    "StartDate" DATE,
    "EndDate" DATE,
    "Status" VARCHAR(20),
    CONSTRAINT "FK_InternshipAssignments_Coordination"
        FOREIGN KEY ("CoordinationID") REFERENCES "StudentEnterpriseCoordination"("CoordinationID"),
    CONSTRAINT "FK_InternshipAssignments_Student"
        FOREIGN KEY ("StudentID") REFERENCES "Students"("StudentID"),
    CONSTRAINT "FK_InternshipAssignments_Enterprise"
        FOREIGN KEY ("EnterpriseID") REFERENCES "Enterprises"("EnterpriseID"),
    CONSTRAINT "FK_InternshipAssignments_Position"
        FOREIGN KEY ("PositionID") REFERENCES "InternshipPositions"("PositionID")
);

CREATE TABLE "InternshipTasks" (
    "TaskID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "AssignmentID" INT NOT NULL,
    "TaskName" VARCHAR(200) NOT NULL,
    "Description" TEXT,
    "AssignedDate" DATE,
    "DueDate" DATE,
    "Status" VARCHAR(20),
    CONSTRAINT "FK_InternshipTasks_Assignment"
        FOREIGN KEY ("AssignmentID") REFERENCES "InternshipAssignments"("AssignmentID") ON DELETE CASCADE
);

CREATE TABLE "TaskProgressUpdates" (
    "UpdateID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "TaskID" INT NOT NULL,
    "UpdatedByStudentID" INT NOT NULL,
    "UpdateDate" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "ProgressDescription" TEXT,
    "PercentComplete" INT,
    CONSTRAINT "FK_TaskProgressUpdates_Task"
        FOREIGN KEY ("TaskID") REFERENCES "InternshipTasks"("TaskID") ON DELETE CASCADE,
    CONSTRAINT "FK_TaskProgressUpdates_Student"
        FOREIGN KEY ("UpdatedByStudentID") REFERENCES "Students"("StudentID"),
    CONSTRAINT "CHK_TaskProgressUpdates_Percent"
        CHECK ("PercentComplete" IS NULL OR ("PercentComplete" >= 0 AND "PercentComplete" <= 100))
);

CREATE TABLE "IncidentReports" (
    "IncidentID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "AssignmentID" INT NOT NULL,
    "ReportedBy" INT NOT NULL,
    "ReportedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "Description" TEXT,
    "Severity" VARCHAR(10),
    "Status" VARCHAR(20),
    "ResolvedAt" TIMESTAMP,
    "ResolutionNote" VARCHAR(500),
    CONSTRAINT "FK_IncidentReports_Assignment"
        FOREIGN KEY ("AssignmentID") REFERENCES "InternshipAssignments"("AssignmentID") ON DELETE CASCADE,
    CONSTRAINT "FK_IncidentReports_Reporter"
        FOREIGN KEY ("ReportedBy") REFERENCES "Users"("UserID")
);

CREATE TABLE "InternshipEvaluations" (
    "EvaluationID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "AssignmentID" INT NOT NULL UNIQUE,
    "EvaluatedBy" INT NOT NULL,
    "EvaluatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "CompletionScore" NUMERIC(4,2),
    "AttitudeScore" NUMERIC(4,2),
    "SkillScore" NUMERIC(4,2),
    "OverallScore" NUMERIC(4,2),
    "Comments" TEXT,
    "Status" VARCHAR(20),
    CONSTRAINT "FK_InternshipEvaluations_Assignment"
        FOREIGN KEY ("AssignmentID") REFERENCES "InternshipAssignments"("AssignmentID") ON DELETE CASCADE,
    CONSTRAINT "FK_InternshipEvaluations_User"
        FOREIGN KEY ("EvaluatedBy") REFERENCES "Users"("UserID")
);


/* ============================================================
   8. NOTIFICATION & SUPPORT
   ============================================================ */

CREATE TABLE "NotificationTemplates" (
    "TemplateID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "TemplateCode" VARCHAR(30) NOT NULL UNIQUE,
    "Subject" VARCHAR(200),
    "BodyTemplate" TEXT,
    "Channel" VARCHAR(20)
);

CREATE TABLE "Notifications" (
    "NotificationID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "UserID" INT NOT NULL,
    "TemplateID" INT,
    "Title" VARCHAR(200),
    "Content" TEXT,
    "Channel" VARCHAR(20),
    "RelatedEntityType" VARCHAR(50),
    "RelatedEntityID" INT,
    "SentAt" TIMESTAMP,
    "IsRead" BOOLEAN DEFAULT FALSE,
    CONSTRAINT "FK_Notifications_User"
        FOREIGN KEY ("UserID") REFERENCES "Users"("UserID") ON DELETE CASCADE,
    CONSTRAINT "FK_Notifications_Template"
        FOREIGN KEY ("TemplateID") REFERENCES "NotificationTemplates"("TemplateID") ON DELETE SET NULL
);

CREATE TABLE "SupportRequests" (
    "RequestID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "StudentID" INT NOT NULL,
    "Subject" VARCHAR(200),
    "Content" TEXT,
    "SubmittedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "Status" VARCHAR(20),
    "HandledBy" INT,
    "Response" TEXT,
    "RespondedAt" TIMESTAMP,
    CONSTRAINT "FK_SupportRequests_Student"
        FOREIGN KEY ("StudentID") REFERENCES "Students"("StudentID") ON DELETE CASCADE,
    CONSTRAINT "FK_SupportRequests_Handler"
        FOREIGN KEY ("HandledBy") REFERENCES "Users"("UserID") ON DELETE NO ACTION
);


/* ============================================================
   9. SYSTEM & AUDIT
   ============================================================ */

CREATE TABLE "AuditLogs" (
    "LogID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "UserID" INT,
    "Action" VARCHAR(50),
    "EntityType" VARCHAR(50),
    "EntityID" INT,
    "ActionAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "Detail" TEXT,
    "IPAddress" VARCHAR(50),
    CONSTRAINT "FK_AuditLogs_User"
        FOREIGN KEY ("UserID") REFERENCES "Users"("UserID") ON DELETE SET NULL
);


/* ============================================================
   10. INDEXES
   ============================================================ */

CREATE INDEX "IX_Users_Role" ON "Users"("RoleID");
CREATE INDEX "IX_Students_Program" ON "Students"("ProgramID");
CREATE INDEX "IX_StudentCourseResults_Student" ON "StudentCourseResults"("StudentID");
CREATE INDEX "IX_StudentCourseResults_Course" ON "StudentCourseResults"("CourseID");
CREATE INDEX "IX_StudentAcademicSnapshot_StudentDate" ON "StudentAcademicSnapshot"("StudentID", "SnapshotDate");
CREATE INDEX "IX_StudentOJTEligibility_Student" ON "StudentOJTEligibility"("StudentID");
CREATE INDEX "IX_StudentOJTEligibility_Semester" ON "StudentOJTEligibility"("OJTSemesterID");
CREATE INDEX "IX_PathwayRecommendations_Student" ON "PathwayRecommendations"("StudentID");
CREATE INDEX "IX_SupportClasses_Semester" ON "SupportClasses"("OJTSemesterID");
CREATE INDEX "IX_InternshipPositions_Enterprise" ON "InternshipPositions"("EnterpriseID");
CREATE INDEX "IX_InternshipPositions_Semester" ON "InternshipPositions"("OJTSemesterID");
CREATE INDEX "IX_OJTRegistrations_Student" ON "OJTRegistrations"("StudentID");
CREATE INDEX "IX_OJTRegistrations_Semester" ON "OJTRegistrations"("OJTSemesterID");
CREATE INDEX "IX_StudentEnterpriseCoordination_Registration" ON "StudentEnterpriseCoordination"("RegistrationID");
CREATE INDEX "IX_StudentEnterpriseCoordination_Enterprise" ON "StudentEnterpriseCoordination"("EnterpriseID");
CREATE INDEX "IX_StudentEnterpriseCoordination_Position" ON "StudentEnterpriseCoordination"("PositionID");
CREATE INDEX "IX_InternshipAssignments_Student" ON "InternshipAssignments"("StudentID");
CREATE INDEX "IX_InternshipAssignments_Enterprise" ON "InternshipAssignments"("EnterpriseID");
CREATE INDEX "IX_InternshipTasks_Assignment" ON "InternshipTasks"("AssignmentID");
CREATE INDEX "IX_IncidentReports_Assignment" ON "IncidentReports"("AssignmentID");
CREATE INDEX "IX_Notifications_UserRead" ON "Notifications"("UserID", "IsRead");
CREATE INDEX "IX_SupportRequests_Student" ON "SupportRequests"("StudentID");
CREATE INDEX "IX_AuditLogs_User" ON "AuditLogs"("UserID");
CREATE INDEX "IX_AuditLogs_Entity" ON "AuditLogs"("EntityType", "EntityID");



INSERT INTO "Roles" ("RoleCode", "RoleName")
VALUES
    ('ADMIN', 'System Administrator'),
    ('ACADEMIC', 'Academic Staff'),
    ('OJT_COORD', 'OJT Coordinator'),
    ('STUDENT', 'Student'),
    ('ENTERPRISE', 'Enterprise Supervisor');

INSERT INTO "Permissions" ("PermissionCode", "PermissionName", "Description")
VALUES
('USER_VIEW', 'View users', 'View user accounts and user information'),
('USER_MANAGE', 'Manage users', 'Create, update and deactivate user accounts'),
('STUDENT_VIEW', 'View students', 'View student academic and OJT information'),
('STUDENT_MANAGE', 'Manage students', 'Manage student records'),
('OJT_ELIGIBILITY', 'Check OJT eligibility', 'Evaluate OJT eligibility conditions'),
('PATHWAY_MANAGE', 'Manage pathway recommendation', 'Create and manage study/OJT pathways'),
('SUPPORT_CLASS_MANAGE', 'Manage support classes', 'Create and manage support classes'),
('ENTERPRISE_MANAGE', 'Manage enterprises', 'Manage enterprise and internship positions'),
('OJT_REGISTRATION', 'Manage OJT registration', 'Register and process OJT applications'),
('INTERNSHIP_MANAGE', 'Manage internship', 'Manage assignments, tasks and evaluations'),
('NOTIFICATION_MANAGE', 'Manage notifications', 'Send and manage notifications'),
('SUPPORT_REQUEST', 'Handle support requests', 'Process student support requests'),
('AUDIT_VIEW', 'View audit logs', 'View system audit records');

INSERT INTO "RolePermissions" ("RoleID", "PermissionID")
SELECT r."RoleID", p."PermissionID"
FROM "Roles" r
CROSS JOIN "Permissions" p
WHERE r."RoleCode" = 'ADMIN';

INSERT INTO "RolePermissions" ("RoleID", "PermissionID")
SELECT r."RoleID", p."PermissionID"
FROM "Roles" r
JOIN "Permissions" p
    ON p."PermissionCode" IN (
        'STUDENT_VIEW',
        'STUDENT_MANAGE',
        'OJT_ELIGIBILITY',
        'PATHWAY_MANAGE',
        'SUPPORT_CLASS_MANAGE',
        'ENTERPRISE_MANAGE',
        'OJT_REGISTRATION',
        'INTERNSHIP_MANAGE',
        'NOTIFICATION_MANAGE',
        'SUPPORT_REQUEST'
    )
WHERE r."RoleCode" = 'ACADEMIC';

INSERT INTO "RolePermissions" ("RoleID", "PermissionID")
SELECT r."RoleID", p."PermissionID"
FROM "Roles" r
JOIN "Permissions" p
    ON p."PermissionCode" IN (
        'STUDENT_VIEW',
        'OJT_ELIGIBILITY',

        'PATHWAY_MANAGE',
        'SUPPORT_CLASS_MANAGE',
        'ENTERPRISE_MANAGE',
        'OJT_REGISTRATION',
        'INTERNSHIP_MANAGE',
        'NOTIFICATION_MANAGE',
        'SUPPORT_REQUEST'
    )
WHERE r."RoleCode" = 'OJT_COORD';

INSERT INTO "RolePermissions" ("RoleID", "PermissionID")
SELECT r."RoleID", p."PermissionID"
FROM "Roles" r
JOIN "Permissions" p
    ON p."PermissionCode" IN (
        'STUDENT_VIEW',
        'OJT_REGISTRATION',
        'SUPPORT_REQUEST'
    )
WHERE r."RoleCode" = 'STUDENT';

INSERT INTO "RolePermissions" ("RoleID", "PermissionID")
SELECT r."RoleID", p."PermissionID"
FROM "Roles" r
JOIN "Permissions" p
    ON p."PermissionCode" IN (
        'STUDENT_VIEW',
        'OJT_REGISTRATION',
        'INTERNSHIP_MANAGE',
        'SUPPORT_REQUEST'
    )
WHERE r."RoleCode" = 'ENTERPRISE';
-- BEGIN GENERATED SECURITY
-- Backend-only Data API. SQL editor owner/service_role bypass RLS.
ALTER TABLE "AcademicYears" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "AcademicYears" FROM PUBLIC;
ALTER TABLE "AuditLogs" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "AuditLogs" FROM PUBLIC;
ALTER TABLE "CoursePrerequisites" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "CoursePrerequisites" FROM PUBLIC;
ALTER TABLE "Courses" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Courses" FROM PUBLIC;
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
ALTER TABLE "ProgramCourses" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "ProgramCourses" FROM PUBLIC;
ALTER TABLE "RolePermissions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "RolePermissions" FROM PUBLIC;
ALTER TABLE "Roles" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Roles" FROM PUBLIC;
ALTER TABLE "StudentAcademicSnapshot" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "StudentAcademicSnapshot" FROM PUBLIC;
ALTER TABLE "StudentCourseResults" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "StudentCourseResults" FROM PUBLIC;
ALTER TABLE "StudentEnterpriseCoordination" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "StudentEnterpriseCoordination" FROM PUBLIC;
ALTER TABLE "StudentOJTEligibility" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "StudentOJTEligibility" FROM PUBLIC;
ALTER TABLE "Students" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "Students" FROM PUBLIC;
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
    WHERE n.nspname='public' AND c.relname = ANY (ARRAY['AcademicMajors','AcademicYears','AuditLogs','ComboCourseChoiceGroups','ComboCourseChoiceMembers','ComboCourses','CoursePrerequisites','Courses','EligibilityRequiredCourses','EnterpriseUsers','Enterprises','IncidentReports','InternshipAssignments','InternshipEvaluations','InternshipPositions','InternshipTasks','JobApplications','JobRoles','NotificationTemplates','Notifications','OJTEligibilityConditions','OJTRegistrations','OJTSemesters','PathwayRecommendations','Permissions','PositionSpecializations','ProgramCombos','ProgramCourses','ProgramPrerequisiteGroups','ProgramPrerequisiteMembers','ProgramSlotOptions','RecruitmentPostPositions','RecruitmentPosts','RolePermissions','Roles','SchemaMigrations','Specializations','StudentAcademicSnapshot','StudentComboCourseSelections','StudentComboSelections','StudentCourseResults','StudentEnterpriseCoordination','StudentOJTEligibility','Students','SupportClassRegistrations','SupportClasses','SupportRequests','TaskProgressUpdates','TrainingPrograms','Users']) LOOP
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
-- END GENERATED SECURITY


-- SECTION: 01_upgrade_it.sql
-- OJT-RPA: additive migration from the supplied quoted PascalCase schema.
-- Run once, as database owner, BEFORE 02_catalog_data.sql. No DROP/RESET.

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
    WHERE n.nspname='public' AND c.relname = ANY (ARRAY['AcademicMajors','AcademicYears','AuditLogs','ComboCourseChoiceGroups','ComboCourseChoiceMembers','ComboCourses','CoursePrerequisites','Courses','EligibilityRequiredCourses','EnterpriseUsers','Enterprises','IncidentReports','InternshipAssignments','InternshipEvaluations','InternshipPositions','InternshipTasks','JobApplications','JobRoles','NotificationTemplates','Notifications','OJTEligibilityConditions','OJTRegistrations','OJTSemesters','PathwayRecommendations','Permissions','PositionSpecializations','ProgramCombos','ProgramCourses','ProgramPrerequisiteGroups','ProgramPrerequisiteMembers','ProgramSlotOptions','RecruitmentPostPositions','RecruitmentPosts','RolePermissions','Roles','SchemaMigrations','Specializations','StudentAcademicSnapshot','StudentComboCourseSelections','StudentComboSelections','StudentCourseResults','StudentEnterpriseCoordination','StudentOJTEligibility','Students','SupportClassRegistrations','SupportClasses','SupportRequests','TaskProgressUpdates','TrainingPrograms','Users']) LOOP
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


-- SECTION: 02_catalog_data.sql
-- Generated from all four specializations. Run AFTER 01_upgrade_it.sql.
-- Transactional, repeatable UPSERT. No student assignments, inferred credits or demo records.
-- Source text and case-sensitive codes are retained. Existing unrelated records are not deleted.

SET LOCAL search_path=public;
SET LOCAL standard_conforming_strings=on;
CREATE TEMP TABLE st_programs(code text,name text,specialization text,credits int) ON COMMIT DROP;
CREATE TEMP TABLE st_courses(program text,code text,name text,semester int,credits numeric,prereq text,kind text) ON COMMIT DROP;
CREATE TEMP TABLE st_combos(program text,source_id int,code text,name text,selection_group text,note text) ON COMMIT DROP;
CREATE TEMP TABLE st_members(program text,combo int,subject int,code text,name text,semester int,credits numeric,prereq text,note text) ON COMMIT DROP;
CREATE TEMP TABLE st_catalog(code text,name text) ON COMMIT DROP;
INSERT INTO st_programs VALUES
('BIT_AI_K18D-19A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','145'),
('BIT_AI_K18D-19A_FNO','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','145'),
('BIT_AI_K19B_FNO','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','145'),
('BIT_AI_K19D-20A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','145'),
('BIT_AI_K20B','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','145'),
('BIT_AI_K20B_FNO','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','145'),
('BIT_AI_K20C','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','145'),
('BIT_AI_K20D-21A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','145'),
('BIT_AI_K21B','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','145'),
('BIT_AI_K21C','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','145'),
('BIT_AI_K21D-22A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Trí tuệ nhân tạo','AI','148'),
('BIT_IA_K18D-19A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','145'),
('BIT_IA_K18D-19A_FNO','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','145'),
('BIT_IA_K19B_FNO','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','145'),
('BIT_IA_K19D-20A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','145'),
('BIT_IA_K20B','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','111'),
('BIT_IA_K20B_FNO','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','108'),
('BIT_IA_K20C','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','111'),
('BIT_IA_K20D-21A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','111'),
('BIT_IA_K21B','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','111'),
('BIT_IA_K21C','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','111'),
('BIT_IA_K21D-22A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành An toàn thông tin','IA','114'),
('BIT_IS_K18D_19A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Hệ thống thông tin','IS','145'),
('BIT_IS_K19B','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Hệ thống thông tin','IS','145'),
('BIT_IS_K19C','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Hệ thống thông tin','IS','145'),
('BIT_IS_K19D_K20A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Hệ thống thông tin','IS','145'),
('BIT_IS_K20B','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Hệ thống thông tin','IS','145'),
('BIT_IS_K20C','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Hệ thống thông tin','IS','145'),
('BIT_IS_K20D','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Hệ thống thông tin','IS','145'),
('BIT_IS_K20D-21A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Hệ thống thông tin','IS','145'),
('BIT_SE_K18D_19A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Kỹ thuật phần mềm','SE','145'),
('BIT_SE_K19B','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Kỹ thuật phần mềm','SE','145'),
('BIT_SE_K19C','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Kỹ thuật phần mềm','SE','145'),
('BIT_SE_K19D_K20A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Kỹ thuật phần mềm','SE','145'),
('BIT_SE_K20B','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Kỹ thuật phần mềm','SE','145'),
('BIT_SE_K20C','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Kỹ thuật phần mềm','SE','145'),
('BIT_SE_K20D_K21A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Kỹ thuật phần mềm','SE','145'),
('BIT_SE_K21B','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Kỹ thuật phần mềm','SE','145'),
('BIT_SE_K21C','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Kỹ thuật phần mềm','SE','145'),
('BIT_SE-2026_K21D_K22A','Chương trình cử nhân ngành Công nghệ thông tin, chuyên ngành Kỹ thuật phần mềm','SE','148');
INSERT INTO st_courses VALUES
('BIT_AI_K18D-19A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K18D-19A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K18D-19A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K18D-19A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K18D-19A','CSI105','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K18D-19A','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K18D-19A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_AI_K18D-19A','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K18D-19A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K18D-19A','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_AI_K18D-19A','AIG202c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K18D-19A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_AI_K18D-19A','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K18D-19A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K18D-19A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K18D-19A','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_AI_K18D-19A','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K18D-19A','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K18D-19A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_AI_K18D-19A','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K18D-19A','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K18D-19A','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K18D-19A','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K18D-19A','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K18D-19A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_AI_K18D-19A','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_AI_K18D-19A','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K18D-19A','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K18D-19A','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K18D-19A','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K18D-19A','NLP301c','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','6','3','AIL30x and (PRP201c or PFP191)','COURSE'),
('BIT_AI_K18D-19A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K18D-19A','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K18D-19A','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K18D-19A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','7','3','','COURSE'),
('BIT_AI_K18D-19A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K18D-19A','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K18D-19A','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K18D-19A','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K18D-19A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K18D-19A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K18D-19A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K18D-19A','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K18D-19A','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K18D-19A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K18D-19A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K18D-19A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K18D-19A_FNO','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K18D-19A_FNO','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K18D-19A_FNO','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K18D-19A_FNO','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K18D-19A_FNO','CSI105','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K18D-19A_FNO','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K18D-19A_FNO','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_AI_K18D-19A_FNO','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K18D-19A_FNO','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K18D-19A_FNO','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_AI_K18D-19A_FNO','AIG201c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K18D-19A_FNO','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_AI_K18D-19A_FNO','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K18D-19A_FNO','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K18D-19A_FNO','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K18D-19A_FNO','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_AI_K18D-19A_FNO','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K18D-19A_FNO','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K18D-19A_FNO','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_AI_K18D-19A_FNO','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K18D-19A_FNO','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K18D-19A_FNO','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K18D-19A_FNO','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K18D-19A_FNO','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K18D-19A_FNO','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_AI_K18D-19A_FNO','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_AI_K18D-19A_FNO','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K18D-19A_FNO','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K18D-19A_FNO','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K18D-19A_FNO','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K18D-19A_FNO','NLP301c','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','6','3','AIL30x and (PRP201c or PFP191)','COURSE'),
('BIT_AI_K18D-19A_FNO','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K18D-19A_FNO','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K18D-19A_FNO','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K18D-19A_FNO','ENW492c','Academic Writing Skills_Kỹ năng viết học thuật','7','3','None','COURSE'),
('BIT_AI_K18D-19A_FNO','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K18D-19A_FNO','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K18D-19A_FNO','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K18D-19A_FNO','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K18D-19A_FNO','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K18D-19A_FNO','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K18D-19A_FNO','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K18D-19A_FNO','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K18D-19A_FNO','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K18D-19A_FNO','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K18D-19A_FNO','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K18D-19A_FNO','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K19B_FNO','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K19B_FNO','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K19B_FNO','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K19B_FNO','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K19B_FNO','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K19B_FNO','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K19B_FNO','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_AI_K19B_FNO','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K19B_FNO','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K19B_FNO','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_AI_K19B_FNO','AIG202c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K19B_FNO','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_AI_K19B_FNO','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K19B_FNO','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K19B_FNO','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K19B_FNO','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_AI_K19B_FNO','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K19B_FNO','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K19B_FNO','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_AI_K19B_FNO','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K19B_FNO','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K19B_FNO','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K19B_FNO','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K19B_FNO','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K19B_FNO','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_AI_K19B_FNO','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_AI_K19B_FNO','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K19B_FNO','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K19B_FNO','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K19B_FNO','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K19B_FNO','NLP301c','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','6','3','AIL30x and (PRP201c or PFP191)','COURSE'),
('BIT_AI_K19B_FNO','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K19B_FNO','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K19B_FNO','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K19B_FNO','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','7','3','','COURSE'),
('BIT_AI_K19B_FNO','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K19B_FNO','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K19B_FNO','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K19B_FNO','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K19B_FNO','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K19B_FNO','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K19B_FNO','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K19B_FNO','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K19B_FNO','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K19B_FNO','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K19B_FNO','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K19B_FNO','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K19D-20A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K19D-20A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K19D-20A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K19D-20A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K19D-20A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K19D-20A','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K19D-20A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_AI_K19D-20A','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K19D-20A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K19D-20A','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_AI_K19D-20A','AIG202c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K19D-20A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_AI_K19D-20A','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K19D-20A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K19D-20A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_AI_K19D-20A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K19D-20A','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K19D-20A','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K19D-20A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_AI_K19D-20A','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K19D-20A','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K19D-20A','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K19D-20A','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K19D-20A','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K19D-20A','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','4','3','None','COURSE'),
('BIT_AI_K19D-20A','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_AI_K19D-20A','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K19D-20A','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K19D-20A','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K19D-20A','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K19D-20A','NLP301c','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','6','3','AIL30x and (PRP201c or PFP191)','COURSE'),
('BIT_AI_K19D-20A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K19D-20A','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K19D-20A','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K19D-20A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','7','3','','COURSE'),
('BIT_AI_K19D-20A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K19D-20A','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K19D-20A','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K19D-20A','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K19D-20A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K19D-20A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K19D-20A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K19D-20A','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K19D-20A','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K19D-20A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K19D-20A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K19D-20A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20B','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K20B','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K20B','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K20B','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K20B','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K20B','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K20B','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_AI_K20B','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K20B','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K20B','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_AI_K20B','AIG202c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K20B','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_AI_K20B','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K20B','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K20B','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_AI_K20B','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K20B','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K20B','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K20B','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_AI_K20B','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K20B','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K20B','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K20B','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K20B','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K20B','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_AI_K20B','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_AI_K20B','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K20B','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K20B','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K20B','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K20B','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_AI_K20B','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K20B','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K20B','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K20B','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K20B','NLP301m','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','7','3','DPL302m','COURSE'),
('BIT_AI_K20B','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K20B','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K20B','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K20B','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K20B','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K20B','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K20B','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K20B','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K20B','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20B','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20B','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20B_FNO','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K20B_FNO','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K20B_FNO','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K20B_FNO','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K20B_FNO','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K20B_FNO','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K20B_FNO','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_AI_K20B_FNO','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K20B_FNO','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K20B_FNO','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_AI_K20B_FNO','AIG202c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K20B_FNO','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_AI_K20B_FNO','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K20B_FNO','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K20B_FNO','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE');
INSERT INTO st_courses VALUES
('BIT_AI_K20B_FNO','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K20B_FNO','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K20B_FNO','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K20B_FNO','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_AI_K20B_FNO','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K20B_FNO','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K20B_FNO','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K20B_FNO','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K20B_FNO','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K20B_FNO','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','4','3','None','COURSE'),
('BIT_AI_K20B_FNO','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_AI_K20B_FNO','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K20B_FNO','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K20B_FNO','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K20B_FNO','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K20B_FNO','NLP301c','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','6','3','AIL30x and (PRP201c or PFP191)','COURSE'),
('BIT_AI_K20B_FNO','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K20B_FNO','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K20B_FNO','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K20B_FNO','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','7','3','','COURSE'),
('BIT_AI_K20B_FNO','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K20B_FNO','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K20B_FNO','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K20B_FNO','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K20B_FNO','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K20B_FNO','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K20B_FNO','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K20B_FNO','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K20B_FNO','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K20B_FNO','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20B_FNO','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20B_FNO','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20C','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K20C','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K20C','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K20C','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K20C','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K20C','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K20C','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_AI_K20C','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K20C','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K20C','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_AI_K20C','AIG202c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K20C','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_AI_K20C','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K20C','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K20C','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_AI_K20C','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K20C','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K20C','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K20C','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_AI_K20C','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K20C','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K20C','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K20C','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K20C','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K20C','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_AI_K20C','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_AI_K20C','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K20C','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K20C','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K20C','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K20C','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_AI_K20C','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K20C','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K20C','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K20C','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K20C','NLP301m','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','7','3','DPL302m','COURSE'),
('BIT_AI_K20C','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K20C','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K20C','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K20C','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K20C','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K20C','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K20C','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K20C','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K20C','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20C','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20C','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20D-21A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K20D-21A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K20D-21A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K20D-21A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K20D-21A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K20D-21A','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K20D-21A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_AI_K20D-21A','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K20D-21A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K20D-21A','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_AI_K20D-21A','AIG202c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K20D-21A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_AI_K20D-21A','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K20D-21A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K20D-21A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_AI_K20D-21A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K20D-21A','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K20D-21A','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K20D-21A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_AI_K20D-21A','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K20D-21A','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K20D-21A','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K20D-21A','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K20D-21A','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K20D-21A','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_AI_K20D-21A','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_AI_K20D-21A','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K20D-21A','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K20D-21A','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K20D-21A','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K20D-21A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_AI_K20D-21A','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_AI_K20D-21A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K20D-21A','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K20D-21A','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K20D-21A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K20D-21A','NLP301m','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','7','3','DPL302m','COURSE'),
('BIT_AI_K20D-21A','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K20D-21A','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K20D-21A','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K20D-21A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K20D-21A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K20D-21A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K20D-21A','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K20D-21A','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K20D-21A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20D-21A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K20D-21A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K21B','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K21B','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K21B','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K21B','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K21B','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K21B','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K21B','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_AI_K21B','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K21B','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K21B','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_AI_K21B','AIG202c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K21B','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_AI_K21B','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K21B','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K21B','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_AI_K21B','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K21B','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K21B','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K21B','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_AI_K21B','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K21B','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K21B','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K21B','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K21B','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K21B','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_AI_K21B','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_AI_K21B','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K21B','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K21B','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K21B','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K21B','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_AI_K21B','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_AI_K21B','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K21B','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K21B','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K21B','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K21B','NLP301m','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','7','3','DPL302m','COURSE'),
('BIT_AI_K21B','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K21B','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K21B','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K21B','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K21B','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K21B','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K21B','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K21B','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K21B','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K21B','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K21B','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K21C','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K21C','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K21C','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K21C','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K21C','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K21C','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K21C','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_AI_K21C','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K21C','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K21C','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_AI_K21C','AIG202c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K21C','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_AI_K21C','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K21C','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K21C','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_AI_K21C','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K21C','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K21C','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K21C','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_AI_K21C','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K21C','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K21C','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K21C','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K21C','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K21C','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_AI_K21C','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_AI_K21C','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K21C','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K21C','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K21C','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K21C','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_AI_K21C','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_AI_K21C','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K21C','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K21C','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K21C','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K21C','NLP301m','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','7','3','DPL302m','COURSE'),
('BIT_AI_K21C','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K21C','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K21C','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K21C','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K21C','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K21C','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K21C','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K21C','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K21C','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K21C','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K21C','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K21D-22A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_AI_K21D-22A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_AI_K21D-22A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_AI_K21D-22A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_AI_K21D-22A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_AI_K21D-22A','MAC103','Calculus_Giải tích','1','3','','COURSE'),
('BIT_AI_K21D-22A','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_AI_K21D-22A','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_AI_K21D-22A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_AI_K21D-22A','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_AI_K21D-22A','AIG202c','Artificial Intelligence_Trí tuệ nhân tạo','2','3','','COURSE'),
('BIT_AI_K21D-22A','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','2','3','PFP191','COURSE'),
('BIT_AI_K21D-22A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','2','3','','COURSE'),
('BIT_AI_K21D-22A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_AI_K21D-22A','MAA102','Linear Algebra_Đại số tuyến tính','2','3','','COURSE'),
('BIT_AI_K21D-22A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_AI_K21D-22A','ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL','3','3','PFP191, DBI202','COURSE'),
('BIT_AI_K21D-22A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','3','3','','COURSE'),
('BIT_AI_K21D-22A','ITE303c','Ethics in IT_Đạo đức trong CNTT','3','3','','COURSE'),
('BIT_AI_K21D-22A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_AI_K21D-22A','MAI391','Mathematics for Machine Learning_Toán cho học máy','3','3','MAE101','COURSE'),
('BIT_AI_K21D-22A','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_AI_K21D-22A','AIL303m','Machine Learning_Học máy','4','3','MAS291, MAI391, PFP191','COURSE'),
('BIT_AI_K21D-22A','CPV301','Computer Vision_Thị giác máy tính','4','3','PFP191, CSD203','COURSE'),
('BIT_AI_K21D-22A','DAP391m','AI-DS Project_Dự án TTNT-KHDL','4','3','PFP191, ADY201m','COURSE'),
('BIT_AI_K21D-22A','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_AI_K21D-22A','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE');
INSERT INTO st_courses VALUES
('BIT_AI_K21D-22A','AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K21D-22A','AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','5','3','','COMBO_SLOT'),
('BIT_AI_K21D-22A','DPL302m','Deep Learning_Học sâu','5','6','AIL303m','COURSE'),
('BIT_AI_K21D-22A','DWP301c','Web Development with Python_Phát triển Web với Python','5','3','PFP191','COURSE'),
('BIT_AI_K21D-22A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_AI_K21D-22A','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_AI_K21D-22A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_AI_K21D-22A','AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_AI_K21D-22A','DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow','7','3','CPV301, DPL302m','COURSE'),
('BIT_AI_K21D-22A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_AI_K21D-22A','NLP301m','Natural Language Processing_Xử lý ngôn ngữ tự nhiên','7','3','DPL302m','COURSE'),
('BIT_AI_K21D-22A','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_AI_K21D-22A','AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_AI_K21D-22A','AID301c','AI in Production_Thiết kế sản phẩm TTNT','8','3','SWE201c, AIL303m','COURSE'),
('BIT_AI_K21D-22A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_AI_K21D-22A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_AI_K21D-22A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_AI_K21D-22A','REL301m','Reinforcement Learning_Học tăng cường','8','3','AIL303m, DPL302m','COURSE'),
('BIT_AI_K21D-22A','AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo','9','10','','ELECTIVE_SLOT'),
('BIT_AI_K21D-22A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K21D-22A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_AI_K21D-22A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K18D-19A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K18D-19A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K18D-19A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K18D-19A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K18D-19A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IA_K18D-19A','CSI104','Introduction to Computer_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K18D-19A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IA_K18D-19A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K18D-19A','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IA_K18D-19A','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IA_K18D-19A','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IA_K18D-19A','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K18D-19A','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K18D-19A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K18D-19A','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IA_K18D-19A','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_IA_K18D-19A','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IA_K18D-19A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K18D-19A','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K18D-19A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K18D-19A','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IA_K18D-19A','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_IA_K18D-19A','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K18D-19A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K18D-19A','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K18D-19A','OSP201','Open Source Platform and Network Administration_Hệ thống nguồn mở và quản trị mạng','4','3','','COURSE'),
('BIT_IA_K18D-19A','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','3','MAD101','COURSE'),
('BIT_IA_K18D-19A','FRS301','Digital Forensics_Điều tra số','5','3','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K18D-19A','IA_ELE3','IA Elective 3_IA Học phần lựa chọn 3','5','3','','ELECTIVE_SLOT'),
('BIT_IA_K18D-19A','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','3','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K18D-19A','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','3','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K18D-19A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IA_K18D-19A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K18D-19A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K18D-19A','HOD402','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','3','ITE303 or ITE302c','COURSE'),
('BIT_IA_K18D-19A','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K18D-19A','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K18D-19A','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','3','IAA202','COURSE'),
('BIT_IA_K18D-19A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K18D-19A','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K18D-19A','IA_COM*4_ELE','Học phần thứ 4 của Combo IA','8','3','','COMBO_SLOT'),
('BIT_IA_K18D-19A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K18D-19A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IA_K18D-19A','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IA_K18D-19A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K18D-19A','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K18D-19A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K18D-19A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K18D-19A_FNO','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K18D-19A_FNO','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K18D-19A_FNO','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K18D-19A_FNO','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K18D-19A_FNO','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IA_K18D-19A_FNO','CSI104','Introduction to Computer_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K18D-19A_FNO','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IA_K18D-19A_FNO','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K18D-19A_FNO','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IA_K18D-19A_FNO','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IA_K18D-19A_FNO','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IA_K18D-19A_FNO','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K18D-19A_FNO','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K18D-19A_FNO','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K18D-19A_FNO','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IA_K18D-19A_FNO','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_IA_K18D-19A_FNO','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IA_K18D-19A_FNO','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K18D-19A_FNO','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K18D-19A_FNO','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K18D-19A_FNO','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IA_K18D-19A_FNO','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_IA_K18D-19A_FNO','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K18D-19A_FNO','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K18D-19A_FNO','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K18D-19A_FNO','OSP201','Open Source Platform and Network Administration_Hệ thống nguồn mở và quản trị mạng','4','3','','COURSE'),
('BIT_IA_K18D-19A_FNO','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','3','MAD101','COURSE'),
('BIT_IA_K18D-19A_FNO','FRS301','Digital Forensics_Điều tra số','5','3','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K18D-19A_FNO','IA_ELE3','IA Elective 3_IA Học phần lựa chọn 3','5','3','','ELECTIVE_SLOT'),
('BIT_IA_K18D-19A_FNO','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','3','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K18D-19A_FNO','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','3','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K18D-19A_FNO','ENW492c','Academic Writing Skills_Kỹ năng viết học thuật','6','3','None','COURSE'),
('BIT_IA_K18D-19A_FNO','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K18D-19A_FNO','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K18D-19A_FNO','HOD401','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','3','ITE303 or ITE302c, OSP201','COURSE'),
('BIT_IA_K18D-19A_FNO','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K18D-19A_FNO','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K18D-19A_FNO','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','3','IAA202','COURSE'),
('BIT_IA_K18D-19A_FNO','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K18D-19A_FNO','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K18D-19A_FNO','IA_COM*4_ELE','Học phần thứ 4 của Combo IA','8','3','','COMBO_SLOT'),
('BIT_IA_K18D-19A_FNO','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K18D-19A_FNO','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IA_K18D-19A_FNO','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IA_K18D-19A_FNO','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K18D-19A_FNO','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K18D-19A_FNO','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K18D-19A_FNO','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K19B_FNO','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K19B_FNO','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K19B_FNO','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K19B_FNO','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K19B_FNO','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IA_K19B_FNO','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K19B_FNO','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IA_K19B_FNO','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K19B_FNO','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IA_K19B_FNO','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IA_K19B_FNO','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IA_K19B_FNO','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K19B_FNO','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K19B_FNO','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K19B_FNO','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IA_K19B_FNO','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_IA_K19B_FNO','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IA_K19B_FNO','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K19B_FNO','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K19B_FNO','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K19B_FNO','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IA_K19B_FNO','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_IA_K19B_FNO','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K19B_FNO','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K19B_FNO','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K19B_FNO','OSP201','Open Source Platform and Network Administration_Hệ thống nguồn mở và quản trị mạng','4','3','','COURSE'),
('BIT_IA_K19B_FNO','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','3','MAD101','COURSE'),
('BIT_IA_K19B_FNO','FRS301','Digital Forensics_Điều tra số','5','3','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K19B_FNO','IA_ELE3','IA Elective 3_IA Học phần lựa chọn 3','5','3','','ELECTIVE_SLOT'),
('BIT_IA_K19B_FNO','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','3','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K19B_FNO','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','3','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K19B_FNO','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IA_K19B_FNO','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K19B_FNO','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K19B_FNO','HOD401','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','3','ITE303 or ITE302c, OSP201','COURSE'),
('BIT_IA_K19B_FNO','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K19B_FNO','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K19B_FNO','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','3','IAA202','COURSE'),
('BIT_IA_K19B_FNO','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K19B_FNO','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K19B_FNO','IA_COM*4_ELE','Học phần thứ 4 của Combo IA','8','3','','COMBO_SLOT'),
('BIT_IA_K19B_FNO','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K19B_FNO','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IA_K19B_FNO','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IA_K19B_FNO','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K19B_FNO','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K19B_FNO','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K19B_FNO','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K19D-20A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K19D-20A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K19D-20A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K19D-20A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K19D-20A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IA_K19D-20A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K19D-20A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IA_K19D-20A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K19D-20A','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IA_K19D-20A','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IA_K19D-20A','IOT102','Internet of Things_Internet vạn vật','2','3','','COURSE'),
('BIT_IA_K19D-20A','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IA_K19D-20A','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K19D-20A','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K19D-20A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K19D-20A','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IA_K19D-20A','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IA_K19D-20A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K19D-20A','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K19D-20A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K19D-20A','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IA_K19D-20A','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K19D-20A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K19D-20A','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K19D-20A','OSP201','Open Source Platform and Network Administration_Hệ thống nguồn mở và quản trị mạng','4','3','','COURSE'),
('BIT_IA_K19D-20A','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','4','3','None','COURSE'),
('BIT_IA_K19D-20A','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','3','MAD101','COURSE'),
('BIT_IA_K19D-20A','FRS301','Digital Forensics_Điều tra số','5','3','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K19D-20A','IA_ELE3','IA Elective 3_IA Học phần lựa chọn 3','5','3','','ELECTIVE_SLOT'),
('BIT_IA_K19D-20A','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','3','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K19D-20A','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','3','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K19D-20A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IA_K19D-20A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K19D-20A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K19D-20A','HOD401','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','3','ITE303 or ITE302c, OSP201','COURSE'),
('BIT_IA_K19D-20A','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K19D-20A','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K19D-20A','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','3','IAA202','COURSE'),
('BIT_IA_K19D-20A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K19D-20A','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K19D-20A','IA_COM*4_ELE','Học phần thứ 4 của Combo IA','8','3','','COMBO_SLOT'),
('BIT_IA_K19D-20A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K19D-20A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IA_K19D-20A','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IA_K19D-20A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K19D-20A','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K19D-20A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K19D-20A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20B','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K20B','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K20B','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K20B','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K20B','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IA_K20B','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K20B','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IA_K20B','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_IA_K20B','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K20B','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IA_K20B','APO201c','Advanced Python with OOP_Lập trình hướng đối tượng với Python','2','3','PFP191','COURSE'),
('BIT_IA_K20B','IOT102','Internet of Things_Internet vạn vật','2','3','','COURSE'),
('BIT_IA_K20B','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IA_K20B','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K20B','OSG20x','Operating System_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K20B','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K20B','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','3','3','PFP191','COURSE'),
('BIT_IA_K20B','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K20B','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K20B','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K20B','NWC303','Network Connectivity_Kết nối mạng','3','0','NWC204','COURSE'),
('BIT_IA_K20B','AIC211','AI for Cybersecurity_Tri tuệ nhân tạo cho An ninh mạng','4','3','PFP191, MAE101','COURSE'),
('BIT_IA_K20B','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K20B','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K20B','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K20B','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_IA_K20B','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','0','MAD101','COURSE'),
('BIT_IA_K20B','FRS301','Digital Forensics_Điều tra số','5','0','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K20B','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','0','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K20B','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','0','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K20B','PWD301','Python Web Development_Phát triển Web với Python','5','3','APO201c','COURSE'),
('BIT_IA_K20B','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IA_K20B','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','0','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K20B','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K20B','HOD402','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','0','ITE303 or ITE302c','COURSE'),
('BIT_IA_K20B','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT');
INSERT INTO st_courses VALUES
('BIT_IA_K20B','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K20B','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','0','IAA202','COURSE'),
('BIT_IA_K20B','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K20B','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K20B','IA_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K20B','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K20B','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IA_K20B','PMG201c','Project Management','8','0','None','COURSE'),
('BIT_IA_K20B','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20B','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K20B','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20B','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20B_FNO','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K20B_FNO','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K20B_FNO','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K20B_FNO','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K20B_FNO','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IA_K20B_FNO','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K20B_FNO','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IA_K20B_FNO','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_IA_K20B_FNO','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K20B_FNO','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IA_K20B_FNO','APO201c','Advanced Python with OOP_Lập trình hướng đối tượng với Python','2','3','PFP191','COURSE'),
('BIT_IA_K20B_FNO','IOT102','Internet of Things_Internet vạn vật','2','3','','COURSE'),
('BIT_IA_K20B_FNO','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IA_K20B_FNO','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K20B_FNO','OSG20x','Operating System_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K20B_FNO','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K20B_FNO','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','3','3','PFP191','COURSE'),
('BIT_IA_K20B_FNO','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K20B_FNO','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K20B_FNO','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K20B_FNO','NWC303','Network Connectivity_Kết nối mạng','3','0','NWC204','COURSE'),
('BIT_IA_K20B_FNO','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K20B_FNO','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K20B_FNO','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K20B_FNO','OSP201','Open Source Platform and Network Administration_Hệ thống nguồn mở và quản trị mạng','4','0','','COURSE'),
('BIT_IA_K20B_FNO','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','4','3','None','COURSE'),
('BIT_IA_K20B_FNO','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','0','MAD101','COURSE'),
('BIT_IA_K20B_FNO','FRS301','Digital Forensics_Điều tra số','5','0','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K20B_FNO','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','0','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K20B_FNO','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','0','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K20B_FNO','PWD301','Python Web Development_Phát triển Web với Python','5','3','APO201c','COURSE'),
('BIT_IA_K20B_FNO','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IA_K20B_FNO','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','0','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K20B_FNO','PMG201c','Project Management','6','0','None','COURSE'),
('BIT_IA_K20B_FNO','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K20B_FNO','HOD402','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','0','ITE303 or ITE302c','COURSE'),
('BIT_IA_K20B_FNO','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K20B_FNO','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K20B_FNO','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','0','IAA202','COURSE'),
('BIT_IA_K20B_FNO','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K20B_FNO','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K20B_FNO','IA_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K20B_FNO','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K20B_FNO','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IA_K20B_FNO','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20B_FNO','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K20B_FNO','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20B_FNO','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20C','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K20C','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K20C','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K20C','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K20C','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IA_K20C','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K20C','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IA_K20C','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_IA_K20C','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K20C','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IA_K20C','APO201c','Advanced Python with OOP_Lập trình hướng đối tượng với Python','2','3','PFP191','COURSE'),
('BIT_IA_K20C','IOT102','Internet of Things_Internet vạn vật','2','3','','COURSE'),
('BIT_IA_K20C','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IA_K20C','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K20C','OSG20x','Operating System_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K20C','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K20C','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','3','3','PFP191','COURSE'),
('BIT_IA_K20C','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K20C','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K20C','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K20C','NWC303','Network Connectivity_Kết nối mạng','3','0','NWC204','COURSE'),
('BIT_IA_K20C','AIC211','AI for Cybersecurity_Tri tuệ nhân tạo cho An ninh mạng','4','3','PFP191, MAE101','COURSE'),
('BIT_IA_K20C','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K20C','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K20C','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K20C','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_IA_K20C','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','0','MAD101','COURSE'),
('BIT_IA_K20C','FRS301','Digital Forensics_Điều tra số','5','0','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K20C','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','0','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K20C','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','0','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K20C','PWD301','Python Web Development_Phát triển Web với Python','5','3','APO201c','COURSE'),
('BIT_IA_K20C','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IA_K20C','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','0','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K20C','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K20C','HOD402','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','0','ITE303 or ITE302c','COURSE'),
('BIT_IA_K20C','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K20C','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K20C','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','0','IAA202','COURSE'),
('BIT_IA_K20C','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K20C','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K20C','IA_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K20C','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K20C','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IA_K20C','PMG201c','Project Management','8','0','None','COURSE'),
('BIT_IA_K20C','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20C','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K20C','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20C','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20D-21A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K20D-21A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K20D-21A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K20D-21A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K20D-21A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IA_K20D-21A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K20D-21A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IA_K20D-21A','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_IA_K20D-21A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K20D-21A','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_IA_K20D-21A','APO201c','Advanced Python with OOP_Lập trình hướng đối tượng với Python','2','3','PFP191','COURSE'),
('BIT_IA_K20D-21A','IOT102','Internet of Things_Internet vạn vật','2','3','','COURSE'),
('BIT_IA_K20D-21A','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IA_K20D-21A','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K20D-21A','OSG203','Operating System_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K20D-21A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K20D-21A','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','3','3','PFP191','COURSE'),
('BIT_IA_K20D-21A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K20D-21A','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K20D-21A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K20D-21A','NWC303','Network Connectivity_Kết nối mạng','3','0','NWC204','COURSE'),
('BIT_IA_K20D-21A','AIC211','AI for Cybersecurity_Tri tuệ nhân tạo cho An ninh mạng','4','3','PFP191, MAE101','COURSE'),
('BIT_IA_K20D-21A','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K20D-21A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K20D-21A','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K20D-21A','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_IA_K20D-21A','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','0','MAD101','COURSE'),
('BIT_IA_K20D-21A','FRS301','Digital Forensics_Điều tra số','5','0','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K20D-21A','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','0','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K20D-21A','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','0','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K20D-21A','PWD301','Python Web Development_Phát triển Web với Python','5','3','APO201c','COURSE'),
('BIT_IA_K20D-21A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IA_K20D-21A','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_IA_K20D-21A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','0','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K20D-21A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K20D-21A','HOD402','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','0','ITE303 or ITE302c','COURSE'),
('BIT_IA_K20D-21A','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K20D-21A','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K20D-21A','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','0','IAA202','COURSE'),
('BIT_IA_K20D-21A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K20D-21A','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K20D-21A','IA_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K20D-21A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K20D-21A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IA_K20D-21A','PMG201c','Project Management','8','0','None','COURSE'),
('BIT_IA_K20D-21A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20D-21A','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K20D-21A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K20D-21A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K21B','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K21B','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K21B','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K21B','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K21B','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IA_K21B','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K21B','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IA_K21B','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_IA_K21B','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K21B','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_IA_K21B','APO201c','Advanced Python with OOP_Lập trình hướng đối tượng với Python','2','3','PFP191','COURSE'),
('BIT_IA_K21B','IOT102','Internet of Things_Internet vạn vật','2','3','','COURSE'),
('BIT_IA_K21B','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IA_K21B','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K21B','OSG203','Operating System_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K21B','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K21B','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','3','3','PFP191','COURSE'),
('BIT_IA_K21B','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K21B','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K21B','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K21B','NWC303','Network Connectivity_Kết nối mạng','3','0','NWC204','COURSE'),
('BIT_IA_K21B','AIC211','AI for Cybersecurity_Tri tuệ nhân tạo cho An ninh mạng','4','3','PFP191, MAE101','COURSE'),
('BIT_IA_K21B','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K21B','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K21B','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K21B','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_IA_K21B','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','0','MAD101','COURSE'),
('BIT_IA_K21B','FRS301','Digital Forensics_Điều tra số','5','0','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K21B','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','0','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K21B','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','0','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K21B','PWD301','Python Web Development_Phát triển Web với Python','5','3','APO201c','COURSE'),
('BIT_IA_K21B','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IA_K21B','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_IA_K21B','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','0','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K21B','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K21B','HOD402','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','0','ITE303 or ITE302c','COURSE'),
('BIT_IA_K21B','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K21B','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K21B','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','0','IAA202','COURSE'),
('BIT_IA_K21B','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K21B','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K21B','IA_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K21B','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K21B','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IA_K21B','PMG201c','Project Management','8','0','None','COURSE'),
('BIT_IA_K21B','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K21B','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K21B','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K21B','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K21C','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K21C','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K21C','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K21C','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K21C','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IA_K21C','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K21C','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IA_K21C','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_IA_K21C','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K21C','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_IA_K21C','APO201c','Advanced Python with OOP_Lập trình hướng đối tượng với Python','2','3','PFP191','COURSE'),
('BIT_IA_K21C','IOT102','Internet of Things_Internet vạn vật','2','3','','COURSE'),
('BIT_IA_K21C','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IA_K21C','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K21C','OSG203','Operating System_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K21C','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K21C','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','3','3','PFP191','COURSE'),
('BIT_IA_K21C','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K21C','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K21C','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K21C','NWC303','Network Connectivity_Kết nối mạng','3','0','NWC204','COURSE'),
('BIT_IA_K21C','AIC211','AI for Cybersecurity_Tri tuệ nhân tạo cho An ninh mạng','4','3','PFP191, MAE101','COURSE'),
('BIT_IA_K21C','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K21C','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K21C','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K21C','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_IA_K21C','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','0','MAD101','COURSE'),
('BIT_IA_K21C','FRS301','Digital Forensics_Điều tra số','5','0','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K21C','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','0','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K21C','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','0','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K21C','PWD301','Python Web Development_Phát triển Web với Python','5','3','APO201c','COURSE'),
('BIT_IA_K21C','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IA_K21C','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_IA_K21C','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','0','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K21C','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K21C','HOD402','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','0','ITE303 or ITE302c','COURSE'),
('BIT_IA_K21C','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K21C','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K21C','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','0','IAA202','COURSE'),
('BIT_IA_K21C','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K21C','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K21C','IA_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K21C','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K21C','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE');
INSERT INTO st_courses VALUES
('BIT_IA_K21C','PMG201c','Project Management','8','0','None','COURSE'),
('BIT_IA_K21C','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K21C','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K21C','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K21C','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K21D-22A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IA_K21D-22A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IA_K21D-22A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IA_K21D-22A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IA_K21D-22A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IA_K21D-22A','MAC103','Calculus_Giải tích','1','3','','COURSE'),
('BIT_IA_K21D-22A','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_IA_K21D-22A','PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python','1','3','','COURSE'),
('BIT_IA_K21D-22A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IA_K21D-22A','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_IA_K21D-22A','APO201c','Advanced Python with OOP_Lập trình hướng đối tượng với Python','2','3','PFP191','COURSE'),
('BIT_IA_K21D-22A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','2','3','','COURSE'),
('BIT_IA_K21D-22A','MAA102','Linear Algebra_Đại số tuyến tính','2','3','','COURSE'),
('BIT_IA_K21D-22A','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IA_K21D-22A','OSG203','Operating System_Hệ điều hành','2','3','','COURSE'),
('BIT_IA_K21D-22A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IA_K21D-22A','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','3','3','PFP191','COURSE'),
('BIT_IA_K21D-22A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IA_K21D-22A','IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2','3','3','','ELECTIVE_SLOT'),
('BIT_IA_K21D-22A','IOT102','Internet of Things_Internet vạn vật','3','3','','COURSE'),
('BIT_IA_K21D-22A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IA_K21D-22A','NWC303','Network Connectivity_Kết nối mạng','3','0','NWC204','COURSE'),
('BIT_IA_K21D-22A','AIC211','AI for Cybersecurity_Tri tuệ nhân tạo cho An ninh mạng','4','3','PFP191, MAE101','COURSE'),
('BIT_IA_K21D-22A','ITE302c','Ethics in IT_Đạo đức trong CNTT','4','3','None','COURSE'),
('BIT_IA_K21D-22A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IA_K21D-22A','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IA_K21D-22A','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_IA_K21D-22A','CRY303c','Applied Cryptography_Mật mã ứng dụng','5','0','MAD101','COURSE'),
('BIT_IA_K21D-22A','FRS301','Digital Forensics_Điều tra số','5','0','NWC202 or NWC203c or NWC204','COURSE'),
('BIT_IA_K21D-22A','IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin','5','0','IAO101 or IAO201c or IAO202','COURSE'),
('BIT_IA_K21D-22A','IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược','5','0','ITE303 or ITE302c, APO201c','COURSE'),
('BIT_IA_K21D-22A','PWD301','Python Web Development_Phát triển Web với Python','5','3','APO201c','COURSE'),
('BIT_IA_K21D-22A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IA_K21D-22A','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_IA_K21D-22A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','0','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IA_K21D-22A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IA_K21D-22A','HOD402','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ','7','0','ITE303 or ITE302c','COURSE'),
('BIT_IA_K21D-22A','IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K21D-22A','IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IA_K21D-22A','IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin','7','0','IAA202','COURSE'),
('BIT_IA_K21D-22A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IA_K21D-22A','IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K21D-22A','IA_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IA_K21D-22A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IA_K21D-22A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IA_K21D-22A','PMG201c','Project Management','8','0','None','COURSE'),
('BIT_IA_K21D-22A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K21D-22A','IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA','9','10','','ELECTIVE_SLOT'),
('BIT_IA_K21D-22A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IA_K21D-22A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K18D_19A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IS_K18D_19A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IS_K18D_19A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IS_K18D_19A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IS_K18D_19A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IS_K18D_19A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IS_K18D_19A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IS_K18D_19A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IS_K18D_19A','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IS_K18D_19A','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IS_K18D_19A','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IS_K18D_19A','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IS_K18D_19A','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IS_K18D_19A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IS_K18D_19A','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IS_K18D_19A','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_IS_K18D_19A','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IS_K18D_19A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IS_K18D_19A','ITA203c','Information System Overview/Nhập môn hệ thống thông tin','3','3','None','COURSE'),
('BIT_IS_K18D_19A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IS_K18D_19A','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IS_K18D_19A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IS_K18D_19A','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IS_K18D_19A','PRC392c','Cloud Computing_Điện toán đám mây','4','3','','COURSE'),
('BIT_IS_K18D_19A','PRJ302','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_IS_K18D_19A','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_IS_K18D_19A','IS_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_IS_K18D_19A','ISM302','Enterprise Resource Planning (ERP)_Lập kế hoạch nguồn lực doanh nghiệp','5','3','','COURSE'),
('BIT_IS_K18D_19A','ISP392','Information System Programming Project_Dự án lập trình HTTT','5','3','PRJ302, SWE201c, Pass LAB211','COURSE'),
('BIT_IS_K18D_19A','ITA301','Information System Design & Analysis_Phân tích thiết kế HTTT','5','3','ITA203c, DBI202','COURSE'),
('BIT_IS_K18D_19A','ITE302c','Ethics in IT_Đạo đức trong CNTT','5','3','None','COURSE'),
('BIT_IS_K18D_19A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IS_K18D_19A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IS_K18D_19A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IS_K18D_19A','IS_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K18D_19A','IS_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K18D_19A','ISC301','e-Commerce_Thương mại điện tử','7','3','','COURSE'),
('BIT_IS_K18D_19A','ITB302c','Business Intelligence (BI)_Kinh doanh thông minh','7','3','DBI202','COURSE'),
('BIT_IS_K18D_19A','DTA301','Data Analysis_Phân tích dữ liệu','8','3','PRO192, CSD201, DBI202, MAS291','COURSE'),
('BIT_IS_K18D_19A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IS_K18D_19A','IS_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IS_K18D_19A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IS_K18D_19A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IS_K18D_19A','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IS_K18D_19A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K18D_19A','IS_GRA_ELE','Graduation Elective - Information System_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Hệ thống thông tin','9','10','','ELECTIVE_SLOT'),
('BIT_IS_K18D_19A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K18D_19A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K19B','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IS_K19B','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IS_K19B','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IS_K19B','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IS_K19B','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IS_K19B','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IS_K19B','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IS_K19B','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IS_K19B','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IS_K19B','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IS_K19B','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IS_K19B','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IS_K19B','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IS_K19B','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IS_K19B','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IS_K19B','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_IS_K19B','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IS_K19B','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IS_K19B','ITA203c','Information System Overview/Nhập môn hệ thống thông tin','3','3','None','COURSE'),
('BIT_IS_K19B','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IS_K19B','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IS_K19B','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IS_K19B','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IS_K19B','PRC392c','Cloud Computing_Điện toán đám mây','4','3','','COURSE'),
('BIT_IS_K19B','PRJ302','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_IS_K19B','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_IS_K19B','IS_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_IS_K19B','ISM302','Enterprise Resource Planning (ERP)_Lập kế hoạch nguồn lực doanh nghiệp','5','3','','COURSE'),
('BIT_IS_K19B','ISP392','Information System Programming Project_Dự án lập trình HTTT','5','3','PRJ302, SWE201c, Pass LAB211','COURSE'),
('BIT_IS_K19B','ITA301','Information System Design & Analysis_Phân tích thiết kế HTTT','5','3','ITA203c, DBI202','COURSE'),
('BIT_IS_K19B','ITE302c','Ethics in IT_Đạo đức trong CNTT','5','3','None','COURSE'),
('BIT_IS_K19B','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IS_K19B','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IS_K19B','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IS_K19B','IS_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K19B','IS_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K19B','ISC301','e-Commerce_Thương mại điện tử','7','3','','COURSE'),
('BIT_IS_K19B','ITB302c','Business Intelligence (BI)_Kinh doanh thông minh','7','3','DBI202','COURSE'),
('BIT_IS_K19B','DTA301','Data Analysis_Phân tích dữ liệu','8','3','PRO192, CSD201, DBI202, MAS291','COURSE'),
('BIT_IS_K19B','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IS_K19B','IS_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IS_K19B','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IS_K19B','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IS_K19B','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IS_K19B','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K19B','IS_GRA_ELE','Graduation Elective - Information System_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Hệ thống thông tin','9','10','','ELECTIVE_SLOT'),
('BIT_IS_K19B','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K19B','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K19C','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IS_K19C','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IS_K19C','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IS_K19C','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IS_K19C','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IS_K19C','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IS_K19C','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IS_K19C','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IS_K19C','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IS_K19C','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IS_K19C','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IS_K19C','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IS_K19C','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IS_K19C','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IS_K19C','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IS_K19C','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_IS_K19C','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IS_K19C','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IS_K19C','ITA203c','Information System Overview/Nhập môn hệ thống thông tin','3','3','None','COURSE'),
('BIT_IS_K19C','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_IS_K19C','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IS_K19C','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_IS_K19C','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IS_K19C','PRC392c','Cloud Computing_Điện toán đám mây','4','3','','COURSE'),
('BIT_IS_K19C','PRJ302','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_IS_K19C','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_IS_K19C','IS_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_IS_K19C','ISM302','Enterprise Resource Planning (ERP)_Lập kế hoạch nguồn lực doanh nghiệp','5','3','','COURSE'),
('BIT_IS_K19C','ISP392','Information System Programming Project_Dự án lập trình HTTT','5','3','PRJ302, SWE201c, Pass LAB211','COURSE'),
('BIT_IS_K19C','ITA301','Information System Design & Analysis_Phân tích thiết kế HTTT','5','3','ITA203c, DBI202','COURSE'),
('BIT_IS_K19C','ITE302c','Ethics in IT_Đạo đức trong CNTT','5','3','None','COURSE'),
('BIT_IS_K19C','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IS_K19C','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IS_K19C','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IS_K19C','IS_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K19C','IS_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K19C','ISC301','e-Commerce_Thương mại điện tử','7','3','','COURSE'),
('BIT_IS_K19C','ITB302c','Business Intelligence (BI)_Kinh doanh thông minh','7','3','DBI202','COURSE'),
('BIT_IS_K19C','DTA301','Data Analysis_Phân tích dữ liệu','8','3','PRO192, CSD201, DBI202, MAS291','COURSE'),
('BIT_IS_K19C','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IS_K19C','IS_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IS_K19C','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IS_K19C','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IS_K19C','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IS_K19C','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K19C','IS_GRA_ELE','Graduation Elective - Information System_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Hệ thống thông tin','9','10','','ELECTIVE_SLOT'),
('BIT_IS_K19C','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K19C','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K19D_K20A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IS_K19D_K20A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IS_K19D_K20A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IS_K19D_K20A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IS_K19D_K20A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IS_K19D_K20A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IS_K19D_K20A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IS_K19D_K20A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IS_K19D_K20A','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IS_K19D_K20A','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IS_K19D_K20A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_IS_K19D_K20A','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IS_K19D_K20A','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IS_K19D_K20A','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IS_K19D_K20A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IS_K19D_K20A','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IS_K19D_K20A','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IS_K19D_K20A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IS_K19D_K20A','ITA203c','Information System Overview/Nhập môn hệ thống thông tin','3','3','None','COURSE'),
('BIT_IS_K19D_K20A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_IS_K19D_K20A','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IS_K19D_K20A','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IS_K19D_K20A','PRC392c','Cloud Computing_Điện toán đám mây','4','3','','COURSE'),
('BIT_IS_K19D_K20A','PRJ302','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_IS_K19D_K20A','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','4','3','None','COURSE'),
('BIT_IS_K19D_K20A','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_IS_K19D_K20A','IS_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_IS_K19D_K20A','ISM302','Enterprise Resource Planning (ERP)_Lập kế hoạch nguồn lực doanh nghiệp','5','3','','COURSE'),
('BIT_IS_K19D_K20A','ISP392','Information System Programming Project_Dự án lập trình HTTT','5','3','PRJ302, SWE201c, Pass LAB211','COURSE'),
('BIT_IS_K19D_K20A','ITA301','Information System Design & Analysis_Phân tích thiết kế HTTT','5','3','ITA203c, DBI202','COURSE'),
('BIT_IS_K19D_K20A','ITE302c','Ethics in IT_Đạo đức trong CNTT','5','3','None','COURSE'),
('BIT_IS_K19D_K20A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IS_K19D_K20A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IS_K19D_K20A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IS_K19D_K20A','IS_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K19D_K20A','IS_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K19D_K20A','ISC301','e-Commerce_Thương mại điện tử','7','3','','COURSE'),
('BIT_IS_K19D_K20A','ITB302c','Business Intelligence (BI)_Kinh doanh thông minh','7','3','DBI202','COURSE'),
('BIT_IS_K19D_K20A','DTA301','Data Analysis_Phân tích dữ liệu','8','3','PRO192, CSD201, DBI202, MAS291','COURSE'),
('BIT_IS_K19D_K20A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IS_K19D_K20A','IS_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IS_K19D_K20A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IS_K19D_K20A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IS_K19D_K20A','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IS_K19D_K20A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K19D_K20A','IS_GRA_ELE','Graduation Elective - Information System_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Hệ thống thông tin','9','10','','ELECTIVE_SLOT'),
('BIT_IS_K19D_K20A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K19D_K20A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20B','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IS_K20B','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IS_K20B','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT');
INSERT INTO st_courses VALUES
('BIT_IS_K20B','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IS_K20B','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IS_K20B','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IS_K20B','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IS_K20B','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IS_K20B','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IS_K20B','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IS_K20B','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_IS_K20B','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IS_K20B','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IS_K20B','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IS_K20B','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IS_K20B','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IS_K20B','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IS_K20B','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IS_K20B','ITA203c','Information System Overview/Nhập môn hệ thống thông tin','3','3','None','COURSE'),
('BIT_IS_K20B','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_IS_K20B','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IS_K20B','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IS_K20B','PRC392c','Cloud Computing_Điện toán đám mây','4','3','','COURSE'),
('BIT_IS_K20B','PRJ302','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_IS_K20B','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_IS_K20B','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_IS_K20B','IS_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_IS_K20B','ISM302','Enterprise Resource Planning (ERP)_Lập kế hoạch nguồn lực doanh nghiệp','5','3','','COURSE'),
('BIT_IS_K20B','ISP392','Information System Programming Project_Dự án lập trình HTTT','5','3','PRJ302, SWE201c, Pass LAB211','COURSE'),
('BIT_IS_K20B','ITA301','Information System Design & Analysis_Phân tích thiết kế HTTT','5','3','ITA203c, DBI202','COURSE'),
('BIT_IS_K20B','ITE302c','Ethics in IT_Đạo đức trong CNTT','5','3','None','COURSE'),
('BIT_IS_K20B','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IS_K20B','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IS_K20B','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IS_K20B','IS_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K20B','IS_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K20B','ISC301','e-Commerce_Thương mại điện tử','7','3','','COURSE'),
('BIT_IS_K20B','ITB302c','Business Intelligence (BI)_Kinh doanh thông minh','7','3','DBI202','COURSE'),
('BIT_IS_K20B','DTA301','Data Analysis_Phân tích dữ liệu','8','3','PRO192, CSD201, DBI202, MAS291','COURSE'),
('BIT_IS_K20B','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IS_K20B','IS_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IS_K20B','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IS_K20B','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IS_K20B','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IS_K20B','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20B','IS_GRA_ELE','Graduation Elective - Information System_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Hệ thống thông tin','9','10','','ELECTIVE_SLOT'),
('BIT_IS_K20B','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20B','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20C','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IS_K20C','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IS_K20C','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IS_K20C','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IS_K20C','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IS_K20C','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IS_K20C','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IS_K20C','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IS_K20C','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IS_K20C','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_IS_K20C','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_IS_K20C','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IS_K20C','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IS_K20C','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IS_K20C','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IS_K20C','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IS_K20C','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IS_K20C','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IS_K20C','ITA203c','Information System Overview/Nhập môn hệ thống thông tin','3','3','None','COURSE'),
('BIT_IS_K20C','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_IS_K20C','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IS_K20C','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IS_K20C','PRC392c','Cloud Computing_Điện toán đám mây','4','3','','COURSE'),
('BIT_IS_K20C','PRJ302','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_IS_K20C','SSG105','Kỹ năng giao tiếp và cộng tác','4','3','N/A','COURSE'),
('BIT_IS_K20C','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_IS_K20C','IS_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_IS_K20C','ISM302','Enterprise Resource Planning (ERP)_Lập kế hoạch nguồn lực doanh nghiệp','5','3','','COURSE'),
('BIT_IS_K20C','ISP392','Information System Programming Project_Dự án lập trình HTTT','5','3','PRJ302, SWE201c, Pass LAB211','COURSE'),
('BIT_IS_K20C','ITA301','Information System Design & Analysis_Phân tích thiết kế HTTT','5','3','ITA203c, DBI202','COURSE'),
('BIT_IS_K20C','ITE302c','Ethics in IT_Đạo đức trong CNTT','5','3','None','COURSE'),
('BIT_IS_K20C','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IS_K20C','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IS_K20C','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IS_K20C','IS_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K20C','IS_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K20C','ISC301','e-Commerce_Thương mại điện tử','7','3','','COURSE'),
('BIT_IS_K20C','ITB302c','Business Intelligence (BI)_Kinh doanh thông minh','7','3','DBI202','COURSE'),
('BIT_IS_K20C','DTA301','Data Analysis_Phân tích dữ liệu','8','3','PRO192, CSD201, DBI202, MAS291','COURSE'),
('BIT_IS_K20C','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IS_K20C','IS_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IS_K20C','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IS_K20C','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IS_K20C','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IS_K20C','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20C','IS_GRA_ELE','Graduation Elective - Information System_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Hệ thống thông tin','9','10','','ELECTIVE_SLOT'),
('BIT_IS_K20C','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20C','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20D','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IS_K20D','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IS_K20D','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IS_K20D','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IS_K20D','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IS_K20D','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IS_K20D','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IS_K20D','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IS_K20D','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IS_K20D','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_IS_K20D','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_IS_K20D','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IS_K20D','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IS_K20D','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IS_K20D','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IS_K20D','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IS_K20D','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IS_K20D','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IS_K20D','ITA203c','Information System Overview/Nhập môn hệ thống thông tin','3','3','None','COURSE'),
('BIT_IS_K20D','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_IS_K20D','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IS_K20D','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IS_K20D','PRC392c','Cloud Computing_Điện toán đám mây','4','3','','COURSE'),
('BIT_IS_K20D','PRJ302','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_IS_K20D','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','4','3','None','COURSE'),
('BIT_IS_K20D','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_IS_K20D','IS_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_IS_K20D','ISM302','Enterprise Resource Planning (ERP)_Lập kế hoạch nguồn lực doanh nghiệp','5','3','','COURSE'),
('BIT_IS_K20D','ISP392','Information System Programming Project_Dự án lập trình HTTT','5','3','PRJ302, SWE201c, Pass LAB211','COURSE'),
('BIT_IS_K20D','ITA301','Information System Design & Analysis_Phân tích thiết kế HTTT','5','3','ITA203c, DBI202','COURSE'),
('BIT_IS_K20D','ITE302c','Ethics in IT_Đạo đức trong CNTT','5','3','None','COURSE'),
('BIT_IS_K20D','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IS_K20D','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IS_K20D','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IS_K20D','IS_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K20D','IS_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K20D','ISC301','e-Commerce_Thương mại điện tử','7','3','','COURSE'),
('BIT_IS_K20D','ITB302c','Business Intelligence (BI)_Kinh doanh thông minh','7','3','DBI202','COURSE'),
('BIT_IS_K20D','DTA301','Data Analysis_Phân tích dữ liệu','8','3','PRO192, CSD201, DBI202, MAS291','COURSE'),
('BIT_IS_K20D','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IS_K20D','IS_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IS_K20D','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IS_K20D','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IS_K20D','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IS_K20D','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20D','IS_GRA_ELE','Graduation Elective - Information System_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Hệ thống thông tin','9','10','','ELECTIVE_SLOT'),
('BIT_IS_K20D','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20D','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20D-21A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_IS_K20D-21A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_IS_K20D-21A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_IS_K20D-21A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_IS_K20D-21A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_IS_K20D-21A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_IS_K20D-21A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_IS_K20D-21A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_IS_K20D-21A','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_IS_K20D-21A','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_IS_K20D-21A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','2','3','Không','COURSE'),
('BIT_IS_K20D-21A','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_IS_K20D-21A','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_IS_K20D-21A','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_IS_K20D-21A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_IS_K20D-21A','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_IS_K20D-21A','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_IS_K20D-21A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_IS_K20D-21A','ITA203c','Information System Overview/Nhập môn hệ thống thông tin','3','3','None','COURSE'),
('BIT_IS_K20D-21A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','3','3','JPD113','COURSE'),
('BIT_IS_K20D-21A','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_IS_K20D-21A','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_IS_K20D-21A','PRC392c','Cloud Computing_Điện toán đám mây','4','3','','COURSE'),
('BIT_IS_K20D-21A','PRJ302','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_IS_K20D-21A','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','4','3','None','COURSE'),
('BIT_IS_K20D-21A','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_IS_K20D-21A','IS_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_IS_K20D-21A','ISM302','Enterprise Resource Planning (ERP)_Lập kế hoạch nguồn lực doanh nghiệp','5','3','','COURSE'),
('BIT_IS_K20D-21A','ISP392','Information System Programming Project_Dự án lập trình HTTT','5','3','PRJ302, SWE201c, Pass LAB211','COURSE'),
('BIT_IS_K20D-21A','ITA301','Information System Design & Analysis_Phân tích thiết kế HTTT','5','3','ITA203c, DBI202','COURSE'),
('BIT_IS_K20D-21A','ITE302c','Ethics in IT_Đạo đức trong CNTT','5','3','None','COURSE'),
('BIT_IS_K20D-21A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_IS_K20D-21A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_IS_K20D-21A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_IS_K20D-21A','IS_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K20D-21A','IS_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_IS_K20D-21A','ISC301','e-Commerce_Thương mại điện tử','7','3','','COURSE'),
('BIT_IS_K20D-21A','ITB302c','Business Intelligence (BI)_Kinh doanh thông minh','7','3','DBI202','COURSE'),
('BIT_IS_K20D-21A','DTA301','Data Analysis_Phân tích dữ liệu','8','3','PRO192, CSD201, DBI202, MAS291','COURSE'),
('BIT_IS_K20D-21A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_IS_K20D-21A','IS_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_IS_K20D-21A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_IS_K20D-21A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_IS_K20D-21A','PMG201c','Project Management','8','3','None','COURSE'),
('BIT_IS_K20D-21A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20D-21A','IS_GRA_ELE','Graduation Elective - Information System_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Hệ thống thông tin','9','10','','ELECTIVE_SLOT'),
('BIT_IS_K20D-21A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_IS_K20D-21A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K18D_19A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_SE_K18D_19A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_SE_K18D_19A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_SE_K18D_19A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_SE_K18D_19A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_SE_K18D_19A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_SE_K18D_19A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_SE_K18D_19A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_SE_K18D_19A','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_SE_K18D_19A','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_SE_K18D_19A','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_SE_K18D_19A','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_SE_K18D_19A','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_SE_K18D_19A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_SE_K18D_19A','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_SE_K18D_19A','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_SE_K18D_19A','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_SE_K18D_19A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_SE_K18D_19A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_SE_K18D_19A','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_SE_K18D_19A','WED201c','Web Design_Thiết kế web','3','3','None','COURSE'),
('BIT_SE_K18D_19A','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_SE_K18D_19A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_SE_K18D_19A','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_SE_K18D_19A','PRJ301','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_SE_K18D_19A','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_SE_K18D_19A','SE_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_SE_K18D_19A','SWP391','Software development project_Dự án phát triển phần mềm','5','3','PRJ301, SWE201c or SWE202c, pass LAB211','COURSE'),
('BIT_SE_K18D_19A','SWR302','Software Requirement_Yêu cầu phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K18D_19A','SWT301','Software Testing_Kiểm thử phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K18D_19A','WDU203c','UI/UX Design_Thiết kế trải nghiệm người dùng','5','3','','COURSE'),
('BIT_SE_K18D_19A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_SE_K18D_19A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_SE_K18D_19A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_SE_K18D_19A','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_SE_K18D_19A','SE_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K18D_19A','SE_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K18D_19A','SWD392','Software Architecture and Design_Kiến trúc và thiết kế phần mềm','7','3','SWE201c or SWE202c, PRO192','COURSE'),
('BIT_SE_K18D_19A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_SE_K18D_19A','ITE302c','Ethics in IT_Đạo đức trong CNTT','8','3','None','COURSE'),
('BIT_SE_K18D_19A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_SE_K18D_19A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_SE_K18D_19A','PRM393','Mobile Programming_Lập trình di động','8','3','PRO192','COURSE'),
('BIT_SE_K18D_19A','SE_COM*4_ELE','Học phần 4 của combo SE','8','3','','COMBO_SLOT'),
('BIT_SE_K18D_19A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K18D_19A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K18D_19A','SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm','9','10','','ELECTIVE_SLOT'),
('BIT_SE_K18D_19A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K19B','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_SE_K19B','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_SE_K19B','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_SE_K19B','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_SE_K19B','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_SE_K19B','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_SE_K19B','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_SE_K19B','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_SE_K19B','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_SE_K19B','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_SE_K19B','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_SE_K19B','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_SE_K19B','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE');
INSERT INTO st_courses VALUES
('BIT_SE_K19B','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_SE_K19B','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_SE_K19B','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_SE_K19B','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_SE_K19B','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_SE_K19B','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_SE_K19B','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_SE_K19B','WED201c','Web Design_Thiết kế web','3','3','None','COURSE'),
('BIT_SE_K19B','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_SE_K19B','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_SE_K19B','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_SE_K19B','PRJ301','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_SE_K19B','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_SE_K19B','SE_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_SE_K19B','SWP391','Software development project_Dự án phát triển phần mềm','5','3','PRJ301, SWE201c or SWE202c, pass LAB211','COURSE'),
('BIT_SE_K19B','SWR302','Software Requirement_Yêu cầu phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K19B','SWT301','Software Testing_Kiểm thử phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K19B','WDU203c','UI/UX Design_Thiết kế trải nghiệm người dùng','5','3','','COURSE'),
('BIT_SE_K19B','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_SE_K19B','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_SE_K19B','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_SE_K19B','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_SE_K19B','SE_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K19B','SE_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K19B','SWD392','Software Architecture and Design_Kiến trúc và thiết kế phần mềm','7','3','SWE201c or SWE202c, PRO192','COURSE'),
('BIT_SE_K19B','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_SE_K19B','ITE302c','Ethics in IT_Đạo đức trong CNTT','8','3','None','COURSE'),
('BIT_SE_K19B','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_SE_K19B','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_SE_K19B','PRM393','Mobile Programming_Lập trình di động','8','3','PRO192','COURSE'),
('BIT_SE_K19B','SE_COM*4_ELE','Học phần 4 của combo SE','8','3','','COMBO_SLOT'),
('BIT_SE_K19B','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K19B','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K19B','SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm','9','10','','ELECTIVE_SLOT'),
('BIT_SE_K19B','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K19C','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_SE_K19C','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_SE_K19C','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_SE_K19C','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_SE_K19C','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_SE_K19C','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_SE_K19C','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_SE_K19C','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_SE_K19C','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_SE_K19C','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_SE_K19C','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_SE_K19C','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_SE_K19C','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_SE_K19C','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_SE_K19C','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_SE_K19C','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','2','3','None','COURSE'),
('BIT_SE_K19C','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_SE_K19C','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_SE_K19C','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_SE_K19C','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_SE_K19C','WED201c','Web Design_Thiết kế web','3','3','None','COURSE'),
('BIT_SE_K19C','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_SE_K19C','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_SE_K19C','MAS291','Statistics & Probability_Xác suất thống kê','4','3','MAE101 or MAC101','COURSE'),
('BIT_SE_K19C','PRJ301','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_SE_K19C','SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192 (not applied to the BIT_AI ; BIT_IC; BIT_AS; BIT_DX and BA programs)','COURSE'),
('BIT_SE_K19C','SE_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_SE_K19C','SWP391','Software development project_Dự án phát triển phần mềm','5','3','PRJ301, SWE201c or SWE202c, pass LAB211','COURSE'),
('BIT_SE_K19C','SWR302','Software Requirement_Yêu cầu phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K19C','SWT301','Software Testing_Kiểm thử phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K19C','WDU203c','UI/UX Design_Thiết kế trải nghiệm người dùng','5','3','','COURSE'),
('BIT_SE_K19C','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_SE_K19C','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_SE_K19C','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_SE_K19C','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_SE_K19C','SE_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K19C','SE_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K19C','SWD392','Software Architecture and Design_Kiến trúc và thiết kế phần mềm','7','3','SWE201c or SWE202c, PRO192','COURSE'),
('BIT_SE_K19C','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_SE_K19C','ITE302c','Ethics in IT_Đạo đức trong CNTT','8','3','None','COURSE'),
('BIT_SE_K19C','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_SE_K19C','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_SE_K19C','PRM393','Mobile Programming_Lập trình di động','8','3','PRO192','COURSE'),
('BIT_SE_K19C','SE_COM*4_ELE','Học phần 4 của combo SE','8','3','','COMBO_SLOT'),
('BIT_SE_K19C','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K19C','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K19C','SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm','9','10','','ELECTIVE_SLOT'),
('BIT_SE_K19C','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K19D_K20A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_SE_K19D_K20A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_SE_K19D_K20A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_SE_K19D_K20A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_SE_K19D_K20A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_SE_K19D_K20A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_SE_K19D_K20A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_SE_K19D_K20A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_SE_K19D_K20A','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_SE_K19D_K20A','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_SE_K19D_K20A','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_SE_K19D_K20A','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_SE_K19D_K20A','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_SE_K19D_K20A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_SE_K19D_K20A','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_SE_K19D_K20A','WED201c','Web Design_Thiết kế web','2','3','None','COURSE'),
('BIT_SE_K19D_K20A','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','3','3','PRO192','COURSE'),
('BIT_SE_K19D_K20A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_SE_K19D_K20A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_SE_K19D_K20A','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_SE_K19D_K20A','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_SE_K19D_K20A','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_SE_K19D_K20A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_SE_K19D_K20A','PRJ301','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_SE_K19D_K20A','SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác','4','3','None','COURSE'),
('BIT_SE_K19D_K20A','SWE202c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','4','3','PRO192','COURSE'),
('BIT_SE_K19D_K20A','SE_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_SE_K19D_K20A','SWP391','Software development project_Dự án phát triển phần mềm','5','3','PRJ301, SWE201c or SWE202c, pass LAB211','COURSE'),
('BIT_SE_K19D_K20A','SWR302','Software Requirement_Yêu cầu phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K19D_K20A','SWT301','Software Testing_Kiểm thử phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K19D_K20A','WDU203c','UI/UX Design_Thiết kế trải nghiệm người dùng','5','3','','COURSE'),
('BIT_SE_K19D_K20A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_SE_K19D_K20A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_SE_K19D_K20A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_SE_K19D_K20A','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_SE_K19D_K20A','SE_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K19D_K20A','SE_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K19D_K20A','SWD392','Software Architecture and Design_Kiến trúc và thiết kế phần mềm','7','3','SWE201c or SWE202c, PRO192','COURSE'),
('BIT_SE_K19D_K20A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_SE_K19D_K20A','ITE302c','Ethics in IT_Đạo đức trong CNTT','8','3','None','COURSE'),
('BIT_SE_K19D_K20A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_SE_K19D_K20A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_SE_K19D_K20A','PRM393','Mobile Programming_Lập trình di động','8','3','PRO192','COURSE'),
('BIT_SE_K19D_K20A','SE_COM*4_ELE','Học phần 4 của combo SE','8','3','','COMBO_SLOT'),
('BIT_SE_K19D_K20A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K19D_K20A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K19D_K20A','SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm','9','10','','ELECTIVE_SLOT'),
('BIT_SE_K19D_K20A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K20B','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_SE_K20B','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_SE_K20B','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_SE_K20B','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_SE_K20B','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_SE_K20B','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_SE_K20B','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_SE_K20B','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_SE_K20B','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_SE_K20B','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_SE_K20B','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_SE_K20B','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_SE_K20B','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_SE_K20B','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_SE_K20B','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_SE_K20B','WED201c','Web Design_Thiết kế web','2','3','None','COURSE'),
('BIT_SE_K20B','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_SE_K20B','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_SE_K20B','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_SE_K20B','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_SE_K20B','SWE202c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','3','3','PRO192','COURSE'),
('BIT_SE_K20B','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','4','3','PRO192','COURSE'),
('BIT_SE_K20B','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_SE_K20B','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_SE_K20B','PRJ301','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_SE_K20B','SWR302','Software Requirement_Yêu cầu phần mềm','4','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K20B','SE_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_SE_K20B','SSG105','Kỹ năng giao tiếp và cộng tác','5','3','N/A','COURSE'),
('BIT_SE_K20B','SWP391','Software development project_Dự án phát triển phần mềm','5','3','PRJ301, SWE201c or SWE202c, pass LAB211','COURSE'),
('BIT_SE_K20B','SWT301','Software Testing_Kiểm thử phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K20B','WDU203c','UI/UX Design_Thiết kế trải nghiệm người dùng','5','3','','COURSE'),
('BIT_SE_K20B','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_SE_K20B','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_SE_K20B','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_SE_K20B','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_SE_K20B','SE_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K20B','SE_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K20B','SWD392','Software Architecture and Design_Kiến trúc và thiết kế phần mềm','7','3','SWE201c or SWE202c, PRO192','COURSE'),
('BIT_SE_K20B','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_SE_K20B','ITE302c','Ethics in IT_Đạo đức trong CNTT','8','3','None','COURSE'),
('BIT_SE_K20B','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_SE_K20B','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_SE_K20B','PRM393','Mobile Programming_Lập trình di động','8','3','PRO192','COURSE'),
('BIT_SE_K20B','SE_COM*4_ELE','Học phần 4 của combo SE','8','3','','COMBO_SLOT'),
('BIT_SE_K20B','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K20B','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K20B','SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm','9','10','','ELECTIVE_SLOT'),
('BIT_SE_K20B','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K20C','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_SE_K20C','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_SE_K20C','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_SE_K20C','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_SE_K20C','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_SE_K20C','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_SE_K20C','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_SE_K20C','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_SE_K20C','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_SE_K20C','SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học','1','3','None','COURSE'),
('BIT_SE_K20C','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_SE_K20C','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_SE_K20C','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_SE_K20C','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_SE_K20C','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_SE_K20C','WED201c','Web Design_Thiết kế web','2','3','None','COURSE'),
('BIT_SE_K20C','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_SE_K20C','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_SE_K20C','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_SE_K20C','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_SE_K20C','SWE202c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','3','3','PRO192','COURSE'),
('BIT_SE_K20C','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','4','3','PRO192','COURSE'),
('BIT_SE_K20C','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_SE_K20C','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_SE_K20C','PRJ301','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_SE_K20C','SWR302','Software Requirement_Yêu cầu phần mềm','4','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K20C','SE_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_SE_K20C','SSG105','Kỹ năng giao tiếp và cộng tác','5','3','N/A','COURSE'),
('BIT_SE_K20C','SWP391','Software development project_Dự án phát triển phần mềm','5','3','PRJ301, SWE201c or SWE202c, pass LAB211','COURSE'),
('BIT_SE_K20C','SWT301','Software Testing_Kiểm thử phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K20C','WDU203c','UI/UX Design_Thiết kế trải nghiệm người dùng','5','3','','COURSE'),
('BIT_SE_K20C','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_SE_K20C','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_SE_K20C','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_SE_K20C','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_SE_K20C','SE_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K20C','SE_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K20C','SWD392','Software Architecture and Design_Kiến trúc và thiết kế phần mềm','7','3','SWE201c or SWE202c, PRO192','COURSE'),
('BIT_SE_K20C','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_SE_K20C','ITE302c','Ethics in IT_Đạo đức trong CNTT','8','3','None','COURSE'),
('BIT_SE_K20C','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_SE_K20C','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_SE_K20C','PRM393','Mobile Programming_Lập trình di động','8','3','PRO192','COURSE'),
('BIT_SE_K20C','SE_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_SE_K20C','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K20C','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K20C','SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm','9','10','','ELECTIVE_SLOT'),
('BIT_SE_K20C','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K20D_K21A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_SE_K20D_K21A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_SE_K20D_K21A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_SE_K20D_K21A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_SE_K20D_K21A','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_SE_K20D_K21A','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_SE_K20D_K21A','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_SE_K20D_K21A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_SE_K20D_K21A','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_SE_K20D_K21A','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_SE_K20D_K21A','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_SE_K20D_K21A','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_SE_K20D_K21A','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_SE_K20D_K21A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_SE_K20D_K21A','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_SE_K20D_K21A','WED201c','Web Design_Thiết kế web','2','3','None','COURSE'),
('BIT_SE_K20D_K21A','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_SE_K20D_K21A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_SE_K20D_K21A','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_SE_K20D_K21A','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_SE_K20D_K21A','SWE202c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','3','3','PRO192','COURSE'),
('BIT_SE_K20D_K21A','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','4','3','PRO192','COURSE'),
('BIT_SE_K20D_K21A','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE');
INSERT INTO st_courses VALUES
('BIT_SE_K20D_K21A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_SE_K20D_K21A','PRJ301','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_SE_K20D_K21A','SWR302','Software Requirement_Yêu cầu phần mềm','4','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K20D_K21A','SE_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_SE_K20D_K21A','SSG105','Kỹ năng giao tiếp và cộng tác','5','3','N/A','COURSE'),
('BIT_SE_K20D_K21A','SWP391','Software development project_Dự án phát triển phần mềm','5','3','PRJ301, SWE201c or SWE202c, pass LAB211','COURSE'),
('BIT_SE_K20D_K21A','SWT301','Software Testing_Kiểm thử phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K20D_K21A','WDU203c','UI/UX Design_Thiết kế trải nghiệm người dùng','5','3','','COURSE'),
('BIT_SE_K20D_K21A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_SE_K20D_K21A','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_SE_K20D_K21A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_SE_K20D_K21A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_SE_K20D_K21A','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_SE_K20D_K21A','SE_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K20D_K21A','SE_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K20D_K21A','SWD392','Software Architecture and Design_Kiến trúc và thiết kế phần mềm','7','3','SWE201c or SWE202c, PRO192','COURSE'),
('BIT_SE_K20D_K21A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_SE_K20D_K21A','ITE302c','Ethics in IT_Đạo đức trong CNTT','8','3','None','COURSE'),
('BIT_SE_K20D_K21A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_SE_K20D_K21A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_SE_K20D_K21A','PRM393','Mobile Programming_Lập trình di động','8','3','PRO192','COURSE'),
('BIT_SE_K20D_K21A','SE_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_SE_K20D_K21A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K20D_K21A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K20D_K21A','SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm','9','10','','ELECTIVE_SLOT'),
('BIT_SE_K20D_K21A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K21B','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_SE_K21B','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_SE_K21B','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_SE_K21B','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_SE_K21B','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_SE_K21B','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_SE_K21B','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_SE_K21B','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_SE_K21B','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_SE_K21B','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_SE_K21B','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_SE_K21B','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_SE_K21B','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_SE_K21B','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_SE_K21B','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_SE_K21B','WED201c','Web Design_Thiết kế web','2','3','None','COURSE'),
('BIT_SE_K21B','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_SE_K21B','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_SE_K21B','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_SE_K21B','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_SE_K21B','SWE202c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','3','3','PRO192','COURSE'),
('BIT_SE_K21B','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','4','3','PRO192','COURSE'),
('BIT_SE_K21B','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_SE_K21B','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_SE_K21B','PRJ301','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_SE_K21B','SWR302','Software Requirement_Yêu cầu phần mềm','4','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K21B','SE_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_SE_K21B','SSG105','Kỹ năng giao tiếp và cộng tác','5','3','N/A','COURSE'),
('BIT_SE_K21B','SWP391','Software development project_Dự án phát triển phần mềm','5','3','PRJ301, SWE201c or SWE202c, pass LAB211','COURSE'),
('BIT_SE_K21B','SWT301','Software Testing_Kiểm thử phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K21B','WDU203c','UI/UX Design_Thiết kế trải nghiệm người dùng','5','3','','COURSE'),
('BIT_SE_K21B','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_SE_K21B','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_SE_K21B','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_SE_K21B','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_SE_K21B','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_SE_K21B','SE_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K21B','SE_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K21B','SWD392','Software Architecture and Design_Kiến trúc và thiết kế phần mềm','7','3','SWE201c or SWE202c, PRO192','COURSE'),
('BIT_SE_K21B','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_SE_K21B','ITE302c','Ethics in IT_Đạo đức trong CNTT','8','3','None','COURSE'),
('BIT_SE_K21B','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_SE_K21B','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_SE_K21B','PRM393','Mobile Programming_Lập trình di động','8','3','PRO192','COURSE'),
('BIT_SE_K21B','SE_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_SE_K21B','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K21B','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K21B','SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm','9','10','','ELECTIVE_SLOT'),
('BIT_SE_K21B','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K21C','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_SE_K21C','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_SE_K21C','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_SE_K21C','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_SE_K21C','CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính','1','3','','COURSE'),
('BIT_SE_K21C','CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính','1','3','','COURSE'),
('BIT_SE_K21C','MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật','1','3','None','COURSE'),
('BIT_SE_K21C','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_SE_K21C','PRF192','Programming Fundamentals_Cơ sở lập trình','1','3','None','COURSE'),
('BIT_SE_K21C','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_SE_K21C','MAD101','Discrete mathematics_Toán rời rạc','2','3','None','COURSE'),
('BIT_SE_K21C','NWC204','Computer Networking_Mạng máy tính','2','3','','COURSE'),
('BIT_SE_K21C','OSG202','Operating Systems_Hệ điều hành','2','3','','COURSE'),
('BIT_SE_K21C','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_SE_K21C','PRO192','Object-Oriented Programming_Lập trình hướng đối tượng','2','3','Pass PRF192','COURSE'),
('BIT_SE_K21C','WED201c','Web Design_Thiết kế web','2','3','None','COURSE'),
('BIT_SE_K21C','DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu','3','3','','COURSE'),
('BIT_SE_K21C','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_SE_K21C','LAB211','OOP with Java Lab_Thực hành OOP với Java','3','3','PRO192','COURSE'),
('BIT_SE_K21C','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_SE_K21C','SWE202c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm','3','3','PRO192','COURSE'),
('BIT_SE_K21C','CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật','4','3','PRO192','COURSE'),
('BIT_SE_K21C','IOT102','Internet of Things_Internet vạn vật','4','3','','COURSE'),
('BIT_SE_K21C','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_SE_K21C','PRJ301','Java Web Application Development_Phát triển ứng dụng Java web','4','3','DBI202, PRO192','COURSE'),
('BIT_SE_K21C','SWR302','Software Requirement_Yêu cầu phần mềm','4','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K21C','SE_COM*1','Subject 1 of Combo*_Học phần 1 của combo*','5','3','','COMBO_SLOT'),
('BIT_SE_K21C','SSG105','Kỹ năng giao tiếp và cộng tác','5','3','N/A','COURSE'),
('BIT_SE_K21C','SWP391','Software development project_Dự án phát triển phần mềm','5','3','PRJ301, SWE201c or SWE202c, pass LAB211','COURSE'),
('BIT_SE_K21C','SWT301','Software Testing_Kiểm thử phần mềm','5','3','SWE102 or SWE201c or SWE202c','COURSE'),
('BIT_SE_K21C','WDU203c','UI/UX Design_Thiết kế trải nghiệm người dùng','5','3','','COURSE'),
('BIT_SE_K21C','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','6','3','','COURSE'),
('BIT_SE_K21C','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_SE_K21C','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_SE_K21C','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_SE_K21C','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_SE_K21C','SE_COM*2','Subject 2 of Combo*_Học phần 2 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K21C','SE_COM*3','Subject 3 of Combo*_Học phần 3 của combo*','7','3','','COMBO_SLOT'),
('BIT_SE_K21C','SWD392','Software Architecture and Design_Kiến trúc và thiết kế phần mềm','7','3','SWE201c or SWE202c, PRO192','COURSE'),
('BIT_SE_K21C','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_SE_K21C','ITE302c','Ethics in IT_Đạo đức trong CNTT','8','3','None','COURSE'),
('BIT_SE_K21C','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_SE_K21C','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_SE_K21C','PRM393','Mobile Programming_Lập trình di động','8','3','PRO192','COURSE'),
('BIT_SE_K21C','SE_COM*4','Subject 4 of Combo*_Học phần 4 của combo*','8','3','','COMBO_SLOT'),
('BIT_SE_K21C','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K21C','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_SE_K21C','SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm','9','10','','ELECTIVE_SLOT'),
('BIT_SE_K21C','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE'),
('BIT_SE-2026_K21D_K22A','OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung','0','0','None','COURSE'),
('BIT_SE-2026_K21D_K22A','PEN','Preparation English_Tiếng Anh chuẩn bị','0','0','','COURSE'),
('BIT_SE-2026_K21D_K22A','PHE_COM*1','Physical Education 1_Giáo dục thể chất 1','0','2','','COMBO_SLOT'),
('BIT_SE-2026_K21D_K22A','TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống','0','3','','ELECTIVE_SLOT'),
('BIT_SE-2026_K21D_K22A','MAC103','Calculus_Giải tích','1','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','MAD101','Discrete mathematics_Toán rời rạc','1','3','None','COURSE'),
('BIT_SE-2026_K21D_K22A','PHE_COM*2','Physical Education 2_Giáo dục thể chất 2','1','2','','COMBO_SLOT'),
('BIT_SE-2026_K21D_K22A','PPJ101','Programming Principles with Java_Nguyên lý lập trình với Java','1','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','SSA101','Kỹ năng học thuật','1','3','None','COURSE'),
('BIT_SE-2026_K21D_K22A','SWE204','Nhập môn kỹ thuật phần mềm_Introduction to Software Engineering','1','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật','2','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','MAA102','Linear Algebra_Đại số tuyến tính','2','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','PDD291','Lập trình Python cho hệ thống hướng dữ liệu_Python for Data-Driven Systems','2','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','PHE_COM*3','Physical Education 3_Giáo dục thể chất 3','2','2','','COMBO_SLOT'),
('BIT_SE-2026_K21D_K22A','POP201','Giải quyết vấn đề với Lập trình hướng đối tượng_Problem Solving with OOP','2','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','SIF201','System Infrastructure Fundamentals_Cơ sở Hạ tầng Hệ thống','2','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python','3','3','PFP191','COURSE'),
('BIT_SE-2026_K21D_K22A','DBI203','Các hệ cơ sở dữ liệu _Introduction to Databases','3','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1','3','3','Không','COURSE'),
('BIT_SE-2026_K21D_K22A','MAS291','Statistics & Probability_Xác suất thống kê','3','3','MAE101 or MAC101','COURSE'),
('BIT_SE-2026_K21D_K22A','UID201c','Thiết kế UI/UX và Nguyên lý Front-end_UI/UX Design & Front-end principles','3','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','AIL304m','Machine Learning_Học máy','4','3','MAS291, MAE101','COURSE'),
('BIT_SE-2026_K21D_K22A','JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2','4','3','JPD113','COURSE'),
('BIT_SE-2026_K21D_K22A','NLP201','Xử lý Ngôn ngữ Tự nhiên Cơ bản_ Fundamental NLP','4','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','PGI201c','Nhập môn Tính toán song song và Lập trình GPU_Introduction to Parallel Computing and GPU Programming','4','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','SAD301','Server-Side Application Development_Phát triển Hệ thống Web phía Máy chủ','4','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','SWR303','Yêu cầu phần mềm tăng cường bằng AI_AI-Augmented Software Requirement','4','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','ASP391','Dự án phát triển ứng dụng tích hợp AI_Application Development Project with AI Integration','5','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','LGA301c','Mô hình Ngôn ngữ Lớn (LLM) và AI Tạo sinh_LLM & Generative AI','5','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','SE-2026_COM*1','SE-2026_COM*1','5','3','','COMBO_SLOT'),
('BIT_SE-2026_K21D_K22A','SSG105','Kỹ năng giao tiếp và cộng tác','5','3','N/A','COURSE'),
('BIT_SE-2026_K21D_K22A','SWT302','Kiểm thử phần mềm tăng cường bằng AI_AI-augmented Software Testing','5','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','HMR101c','Human rights_Quyền con người','6','0','','COURSE'),
('BIT_SE-2026_K21D_K22A','OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế','6','10','Students attained 90% of the total credits prior to the OJT term (excluding Physical Education and OTP Programs) Students choosing JS combo (Japanese Bridge Engineer) have to pass JPD133','COURSE'),
('BIT_SE-2026_K21D_K22A','PRC392c','Cloud Computing_Điện toán đám mây','6','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1','7','3','None','COURSE'),
('BIT_SE-2026_K21D_K22A','PMG201c','Project Management','7','3','None','COURSE'),
('BIT_SE-2026_K21D_K22A','SE-2026_COM*2','SE-2026_COM*2','7','3','','COMBO_SLOT'),
('BIT_SE-2026_K21D_K22A','SE-2026_COM*3','SE-2026_COM*3','7','3','','COMBO_SLOT'),
('BIT_SE-2026_K21D_K22A','SWD393','Software Architecture and Design_Kiến trúc và thiết kế phần mềm','7','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','ASL391','Vòng đời phần mềm AI: MLOps, LLMOps và Kỹ thuật An toàn – Bảo mật_AI Software Lifecycle: MLOps, LLMOps, Safety & Secure Engineering','8','3','','COURSE'),
('BIT_SE-2026_K21D_K22A','EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2','8','3','EXE101','COURSE'),
('BIT_SE-2026_K21D_K22A','MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin','8','3','None','COURSE'),
('BIT_SE-2026_K21D_K22A','MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin','8','2','None','COURSE'),
('BIT_SE-2026_K21D_K22A','PRM393','Mobile Programming_Lập trình di động','8','3','PRO192','COURSE'),
('BIT_SE-2026_K21D_K22A','SE-2026_COM*4','SE-2026_COM*4','8','3','','COMBO_SLOT'),
('BIT_SE-2026_K21D_K22A','HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh','9','2','MLN111, MLN122','COURSE'),
('BIT_SE-2026_K21D_K22A','MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học','9','2','MLN111, MLN122','COURSE'),
('BIT_SE-2026_K21D_K22A','SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm','9','10','','ELECTIVE_SLOT'),
('BIT_SE-2026_K21D_K22A','VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam','9','2','MLN111, MLN122','COURSE');
INSERT INTO st_combos VALUES
('BIT_AI_K18D-19A','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K18D-19A','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K18D-19A','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K18D-19A','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K18D-19A','2620','AI17_COM2.1','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)'),
('BIT_AI_K18D-19A_FNO','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K18D-19A_FNO','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K18D-19A_FNO','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K18D-19A_FNO','1175','AI17_COM2','AI17_COM2: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K18D-19A_FNO','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K19B_FNO','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K19B_FNO','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K19B_FNO','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K19B_FNO','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K19B_FNO','2620','AI17_COM2.1','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)'),
('BIT_AI_K19D-20A','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K19D-20A','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K19D-20A','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K19D-20A','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K19D-20A','2620','AI17_COM2.1','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)'),
('BIT_AI_K20B','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20B','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20B','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20B','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20B','2620','AI17_COM2.1','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)'),
('BIT_AI_K20B','2653','AI17_COM4','AI17_COM4: Topic on Generative AI_Chủ đề TTNT tạo sinh','',''),
('BIT_AI_K20B','2654','AI17_COM5','AI17_COM5: Topic on Machine Learning Operations_Chủ đề Hoạt động học máy','',''),
('BIT_AI_K20B_FNO','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20B_FNO','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20B_FNO','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20B_FNO','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20B_FNO','2620','AI17_COM2.1','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)'),
('BIT_AI_K20C','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20C','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20C','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20C','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20C','2620','AI17_COM2.1','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)'),
('BIT_AI_K20C','2653','AI17_COM4','AI17_COM4: Topic on Generative AI_Chủ đề TTNT tạo sinh','',''),
('BIT_AI_K20C','2654','AI17_COM5','AI17_COM5: Topic on Machine Learning Operations_Chủ đề Hoạt động học máy','',''),
('BIT_AI_K20D-21A','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20D-21A','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20D-21A','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20D-21A','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K20D-21A','2620','AI17_COM2.1','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)'),
('BIT_AI_K20D-21A','2653','AI17_COM4','AI17_COM4: Topic on Generative AI_Chủ đề TTNT tạo sinh','',''),
('BIT_AI_K20D-21A','2654','AI17_COM5','AI17_COM5: Topic on Machine Learning Operations_Chủ đề Hoạt động học máy','',''),
('BIT_AI_K21B','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21B','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21B','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21B','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21B','2620','AI17_COM2.1','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)'),
('BIT_AI_K21B','2653','AI17_COM4','AI17_COM4: Topic on Generative AI_Chủ đề TTNT tạo sinh','',''),
('BIT_AI_K21B','2654','AI17_COM5','AI17_COM5: Topic on Machine Learning Operations_Chủ đề Hoạt động học máy','',''),
('BIT_AI_K21C','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21C','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21C','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21C','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21C','2620','AI17_COM2.1','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)'),
('BIT_AI_K21C','2653','AI17_COM4','AI17_COM4: Topic on Generative AI_Chủ đề TTNT tạo sinh','',''),
('BIT_AI_K21C','2654','AI17_COM5','AI17_COM5: Topic on Machine Learning Operations_Chủ đề Hoạt động học máy','',''),
('BIT_AI_K21D-22A','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21D-22A','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21D-22A','1174','AI17_COM1','AI17_COM1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu ứng dụng BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21D-22A','1176','AI17_COM3','AI17_COM3: Topic on AI application_Chủ đề Ứng dụng TTNT BIT_AI_K17C(FNO)','',''),
('BIT_AI_K21D-22A','2620','AI17_COM2.1','AI17_COM2.1: Topic on AI Applied research_Chủ đề Định hướng nghiên cứu ứng dụng TTNT','','Adjust the subject code in the combo (remove ending m)'),
('BIT_AI_K21D-22A','2654','AI17_COM5','AI17_COM5: Topic on Machine Learning Operations_Chủ đề Hoạt động học máy','',''),
('BIT_AI_K21D-22A','2653','AI17_COM4','AI17_COM4: Topic on Generative AI_Chủ đề TTNT tạo sinh','',''),
('BIT_IA_K18D-19A','584','PHE_COM1','PHE_COM1: Vovinam BIT_IA_K16B(FNO)','',''),
('BIT_IA_K18D-19A','585','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_IA_K16B(FNO)','',''),
('BIT_IA_K18D-19A','586','IA_COM1','IA_COM1: Topic on Application Security_Chủ đề An toàn ứng dụng BIT_IA_K16B(FNO)','',''),
('BIT_IA_K18D-19A','587','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống BIT_IA_K16B(FNO)','',''),
('BIT_IA_K18D-19A_FNO','584','PHE_COM1','PHE_COM1: Vovinam BIT_IA_K16B(FNO)','',''),
('BIT_IA_K18D-19A_FNO','585','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_IA_K16B(FNO)','',''),
('BIT_IA_K18D-19A_FNO','586','IA_COM1','IA_COM1: Topic on Application Security_Chủ đề An toàn ứng dụng BIT_IA_K16B(FNO)','',''),
('BIT_IA_K18D-19A_FNO','587','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống BIT_IA_K16B(FNO)','',''),
('BIT_IA_K19B_FNO','584','PHE_COM1','PHE_COM1: Vovinam BIT_IA_K16B(FNO)','',''),
('BIT_IA_K19B_FNO','585','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_IA_K16B(FNO)','',''),
('BIT_IA_K19B_FNO','586','IA_COM1','IA_COM1: Topic on Application Security_Chủ đề An toàn ứng dụng BIT_IA_K16B(FNO)','',''),
('BIT_IA_K19B_FNO','587','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống BIT_IA_K16B(FNO)','',''),
('BIT_IA_K19D-20A','584','PHE_COM1','PHE_COM1: Vovinam BIT_IA_K16B(FNO)','',''),
('BIT_IA_K19D-20A','585','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_IA_K16B(FNO)','',''),
('BIT_IA_K19D-20A','586','IA_COM1','IA_COM1: Topic on Application Security_Chủ đề An toàn ứng dụng BIT_IA_K16B(FNO)','',''),
('BIT_IA_K19D-20A','587','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống BIT_IA_K16B(FNO)','',''),
('BIT_IA_K20B','2650','IA_COM1','IA_COM1:Topic on Application Security_Chủ đề An toàn ứng dụng','',''),
('BIT_IA_K20B','2651','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống','',''),
('BIT_IA_K20B','2652','IA_COM3','IA_COM3: Topic on Apply AI for Cyber Security_Chủ đề Ứng dụng TTNT cho An toàn mạng','',''),
('BIT_IA_K20B','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_IA_K20B','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_IA_K20B_FNO','2650','IA_COM1','IA_COM1:Topic on Application Security_Chủ đề An toàn ứng dụng','',''),
('BIT_IA_K20B_FNO','2651','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống','',''),
('BIT_IA_K20B_FNO','2652','IA_COM3','IA_COM3: Topic on Apply AI for Cyber Security_Chủ đề Ứng dụng TTNT cho An toàn mạng','',''),
('BIT_IA_K20B_FNO','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_IA_K20B_FNO','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_IA_K20C','2650','IA_COM1','IA_COM1:Topic on Application Security_Chủ đề An toàn ứng dụng','',''),
('BIT_IA_K20C','2651','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống','',''),
('BIT_IA_K20C','2652','IA_COM3','IA_COM3: Topic on Apply AI for Cyber Security_Chủ đề Ứng dụng TTNT cho An toàn mạng','',''),
('BIT_IA_K20C','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_IA_K20C','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_IA_K20D-21A','2650','IA_COM1','IA_COM1:Topic on Application Security_Chủ đề An toàn ứng dụng','',''),
('BIT_IA_K20D-21A','2651','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống','',''),
('BIT_IA_K20D-21A','2652','IA_COM3','IA_COM3: Topic on Apply AI for Cyber Security_Chủ đề Ứng dụng TTNT cho An toàn mạng','',''),
('BIT_IA_K20D-21A','1172','PHE_COM1','PHE_COM1: Vovinam BIT_AI_K17C(FNO)','',''),
('BIT_IA_K20D-21A','1173','PHE_COM2','PHE_COM2: Chess_Cờ vua BIT_AI_K17C(FNO)','',''),
('BIT_IA_K21B','2650','IA_COM1','IA_COM1:Topic on Application Security_Chủ đề An toàn ứng dụng','',''),
('BIT_IA_K21B','2651','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống','',''),
('BIT_IA_K21B','2652','IA_COM3','IA_COM3: Topic on Apply AI for Cyber Security_Chủ đề Ứng dụng TTNT cho An toàn mạng','',''),
('BIT_IA_K21C','2650','IA_COM1','IA_COM1:Topic on Application Security_Chủ đề An toàn ứng dụng','',''),
('BIT_IA_K21C','2651','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống','',''),
('BIT_IA_K21C','2652','IA_COM3','IA_COM3: Topic on Apply AI for Cyber Security_Chủ đề Ứng dụng TTNT cho An toàn mạng','',''),
('BIT_IA_K21D-22A','2650','IA_COM1','IA_COM1:Topic on Application Security_Chủ đề An toàn ứng dụng','',''),
('BIT_IA_K21D-22A','2651','IA_COM2','IA_COM2: Topic on System Security_Chủ đề An toàn hệ thống','',''),
('BIT_IA_K21D-22A','2652','IA_COM3','IA_COM3: Topic on Apply AI for Cyber Security_Chủ đề Ứng dụng TTNT cho An toàn mạng','',''),
('BIT_IS_K18D_19A','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_IS_K18D_19A','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_IS_K18D_19A','2636','IS_COM1.1','IS_COM1.1: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19A','',''),
('BIT_IS_K18D_19A','2637','IS_COM2.1','IS_COM2.1: Topic on SAP_Chủ đề SAP_K19A','',''),
('BIT_IS_K18D_19A','2641','IS_COM3','IS_COM3: Topic on Topic on Software System Quality_Chủ đề Chất lượng hệ thống phần mềm','',''),
('BIT_IS_K18D_19A','2634','IS_COM4','IS_COM4: Topic on Cybersecurity for Information Systems_Chủ đề Bảo mật cho hệ thống thông tin','',''),
('BIT_IS_K18D_19A','2635','IS_COM5','IS_COM5: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','',''),
('BIT_IS_K19B','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_IS_K19B','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_IS_K19B','2636','IS_COM1.1','IS_COM1.1: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19A','',''),
('BIT_IS_K19B','2641','IS_COM3','IS_COM3: Topic on Topic on Software System Quality_Chủ đề Chất lượng hệ thống phần mềm','',''),
('BIT_IS_K19B','2634','IS_COM4','IS_COM4: Topic on Cybersecurity for Information Systems_Chủ đề Bảo mật cho hệ thống thông tin','',''),
('BIT_IS_K19B','2635','IS_COM5','IS_COM5: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','',''),
('BIT_IS_K19C','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_IS_K19C','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_IS_K19C','2636','IS_COM1.1','IS_COM1.1: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19A','',''),
('BIT_IS_K19C','2641','IS_COM3','IS_COM3: Topic on Topic on Software System Quality_Chủ đề Chất lượng hệ thống phần mềm','',''),
('BIT_IS_K19C','2634','IS_COM4','IS_COM4: Topic on Cybersecurity for Information Systems_Chủ đề Bảo mật cho hệ thống thông tin','',''),
('BIT_IS_K19C','2754','IS_COM5.1','IS_COM5.1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','',''),
('BIT_IS_K19D_K20A','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_IS_K19D_K20A','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_IS_K19D_K20A','2634','IS_COM4','IS_COM4: Topic on Cybersecurity for Information Systems_Chủ đề Bảo mật cho hệ thống thông tin','',''),
('BIT_IS_K19D_K20A','2641','IS_COM3','IS_COM3: Topic on Topic on Software System Quality_Chủ đề Chất lượng hệ thống phần mềm','',''),
('BIT_IS_K19D_K20A','2734','IS_COM1.2','IS_COM1.2: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19D','',''),
('BIT_IS_K19D_K20A','2754','IS_COM5.1','IS_COM5.1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','',''),
('BIT_IS_K20B','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_IS_K20B','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_IS_K20B','2637','IS_COM2.1','IS_COM2.1: Topic on SAP_Chủ đề SAP_K19A','','Sinh viên chọn combo SAP phải làm đồ án tốt nghiệp SAP490'),
('BIT_IS_K20B','2641','IS_COM3','IS_COM3: Topic on Topic on Software System Quality_Chủ đề Chất lượng hệ thống phần mềm','',''),
('BIT_IS_K20B','2634','IS_COM4','IS_COM4: Topic on Cybersecurity for Information Systems_Chủ đề Bảo mật cho hệ thống thông tin','',''),
('BIT_IS_K20B','2734','IS_COM1.2','IS_COM1.2: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19D','',''),
('BIT_IS_K20B','2754','IS_COM5.1','IS_COM5.1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','',''),
('BIT_IS_K20C','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_IS_K20C','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_IS_K20C','2637','IS_COM2.1','IS_COM2.1: Topic on SAP_Chủ đề SAP_K19A','','Sinh viên chọn combo SAP phải làm đồ án tốt nghiệp SAP490'),
('BIT_IS_K20C','2641','IS_COM3','IS_COM3: Topic on Topic on Software System Quality_Chủ đề Chất lượng hệ thống phần mềm','',''),
('BIT_IS_K20C','2634','IS_COM4','IS_COM4: Topic on Cybersecurity for Information Systems_Chủ đề Bảo mật cho hệ thống thông tin','',''),
('BIT_IS_K20C','2734','IS_COM1.2','IS_COM1.2: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19D','',''),
('BIT_IS_K20C','2754','IS_COM5.1','IS_COM5.1: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','',''),
('BIT_IS_K20D','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_IS_K20D','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_IS_K20D','2636','IS_COM1.1','IS_COM1.1: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19A','',''),
('BIT_IS_K20D','2637','IS_COM2.1','IS_COM2.1: Topic on SAP_Chủ đề SAP_K19A','','Sinh viên chọn combo SAP phải làm đồ án tốt nghiệp SAP490'),
('BIT_IS_K20D','2641','IS_COM3','IS_COM3: Topic on Topic on Software System Quality_Chủ đề Chất lượng hệ thống phần mềm','',''),
('BIT_IS_K20D','2634','IS_COM4','IS_COM4: Topic on Cybersecurity for Information Systems_Chủ đề Bảo mật cho hệ thống thông tin','',''),
('BIT_IS_K20D','2635','IS_COM5','IS_COM5: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','',''),
('BIT_IS_K20D-21A','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_IS_K20D-21A','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_IS_K20D-21A','2636','IS_COM1.1','IS_COM1.1: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19A','',''),
('BIT_IS_K20D-21A','2637','IS_COM2.1','IS_COM2.1: Topic on SAP_Chủ đề SAP_K19A','','Sinh viên chọn combo SAP phải làm đồ án tốt nghiệp SAP490'),
('BIT_IS_K20D-21A','2641','IS_COM3','IS_COM3: Topic on Topic on Software System Quality_Chủ đề Chất lượng hệ thống phần mềm','',''),
('BIT_IS_K20D-21A','2634','IS_COM4','IS_COM4: Topic on Cybersecurity for Information Systems_Chủ đề Bảo mật cho hệ thống thông tin','',''),
('BIT_IS_K20D-21A','2635','IS_COM5','IS_COM5: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','',''),
('BIT_SE_K18D_19A','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_SE_K18D_19A','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_SE_K18D_19A','340','SE_COM5.2','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A','',''),
('BIT_SE_K18D_19A','402','SE_COM6','SE_COM6: Topic on Information Technology - Korean Language_Chủ đề Công nghệ thông tin - tiếng Hàn BIT_SE_K15C','',''),
('BIT_SE_K18D_19A','1469','SE_COM5.1.1','SE_COM5.1.1:Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật CNTT: Lựa chọn JFE301 và 1 trong 2 học phần JIS401, JIT401 để triển khai ở kỳ 8) BIT_SE_K15C','',''),
('BIT_SE_K18D_19A','2566','SE_COM7.1','SE_COM7.1:Topic on AI_Chủ đề AI','','Topic on AI_Chủ đề AI'),
('BIT_SE_K18D_19A','2553','SE_COM9','SE_COM9: Topic on SAP_Chủ đề SAP','',''),
('BIT_SE_K18D_19A','2497','SE_COM4.1','SE_COM4.1: Topic on React/NodeJS_Chủ đề React/NodeJS','',''),
('BIT_SE_K18D_19A','2605','SE_COM11','SE_COM11: Topic on IC design_Chủ đề Thiết kế vi mạch','',''),
('BIT_SE_K18D_19A','2640','SE_COM10.2','SE_COM10.2: Topic on Intensive Java_Chủ đề Java chuyên sâu_K19A','',''),
('BIT_SE_K18D_19A','2638','SE_COM13','SE_COM13: Topic on DevSepOps for cloud_Chủ đề Tích hợp DevSepOps cho cloud','',''),
('BIT_SE_K18D_19A','2628','SE_COM12','SE_COM12: Topic on Game Development_Phát triển game','',''),
('BIT_SE_K18D_19A','2686','SE_COM3.3','SE_COM3.3: Topic on .NET Programming_Chủ đề lập trình .NET BIT_SE_From_K18C','',''),
('BIT_SE_K18D_19A','2639','SE_COM14.0','SE_COM14.0: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng','',''),
('BIT_SE_K19B','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_SE_K19B','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_SE_K19B','340','SE_COM5.2','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A','',''),
('BIT_SE_K19B','402','SE_COM6','SE_COM6: Topic on Information Technology - Korean Language_Chủ đề Công nghệ thông tin - tiếng Hàn BIT_SE_K15C','',''),
('BIT_SE_K19B','1469','SE_COM5.1.1','SE_COM5.1.1:Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật CNTT: Lựa chọn JFE301 và 1 trong 2 học phần JIS401, JIT401 để triển khai ở kỳ 8) BIT_SE_K15C','',''),
('BIT_SE_K19B','2566','SE_COM7.1','SE_COM7.1:Topic on AI_Chủ đề AI','','Topic on AI_Chủ đề AI'),
('BIT_SE_K19B','2497','SE_COM4.1','SE_COM4.1: Topic on React/NodeJS_Chủ đề React/NodeJS','',''),
('BIT_SE_K19B','2605','SE_COM11','SE_COM11: Topic on IC design_Chủ đề Thiết kế vi mạch','',''),
('BIT_SE_K19B','2640','SE_COM10.2','SE_COM10.2: Topic on Intensive Java_Chủ đề Java chuyên sâu_K19A','',''),
('BIT_SE_K19B','2638','SE_COM13','SE_COM13: Topic on DevSepOps for cloud_Chủ đề Tích hợp DevSepOps cho cloud','',''),
('BIT_SE_K19B','2628','SE_COM12','SE_COM12: Topic on Game Development_Phát triển game','',''),
('BIT_SE_K19B','2675','SE_COM14','SE_COM14: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng_K19B','',''),
('BIT_SE_K19B','2686','SE_COM3.3','SE_COM3.3: Topic on .NET Programming_Chủ đề lập trình .NET BIT_SE_From_K18C','',''),
('BIT_SE_K19C','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_SE_K19C','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_SE_K19C','340','SE_COM5.2','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A','',''),
('BIT_SE_K19C','402','SE_COM6','SE_COM6: Topic on Information Technology - Korean Language_Chủ đề Công nghệ thông tin - tiếng Hàn BIT_SE_K15C','',''),
('BIT_SE_K19C','1469','SE_COM5.1.1','SE_COM5.1.1:Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật CNTT: Lựa chọn JFE301 và 1 trong 2 học phần JIS401, JIT401 để triển khai ở kỳ 8) BIT_SE_K15C','',''),
('BIT_SE_K19C','2566','SE_COM7.1','SE_COM7.1:Topic on AI_Chủ đề AI','','Topic on AI_Chủ đề AI'),
('BIT_SE_K19C','2497','SE_COM4.1','SE_COM4.1: Topic on React/NodeJS_Chủ đề React/NodeJS','',''),
('BIT_SE_K19C','2605','SE_COM11','SE_COM11: Topic on IC design_Chủ đề Thiết kế vi mạch','',''),
('BIT_SE_K19C','2640','SE_COM10.2','SE_COM10.2: Topic on Intensive Java_Chủ đề Java chuyên sâu_K19A','',''),
('BIT_SE_K19C','2638','SE_COM13','SE_COM13: Topic on DevSepOps for cloud_Chủ đề Tích hợp DevSepOps cho cloud','',''),
('BIT_SE_K19C','2628','SE_COM12','SE_COM12: Topic on Game Development_Phát triển game','',''),
('BIT_SE_K19C','2675','SE_COM14','SE_COM14: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng_K19B','',''),
('BIT_SE_K19C','2686','SE_COM3.3','SE_COM3.3: Topic on .NET Programming_Chủ đề lập trình .NET BIT_SE_From_K18C','',''),
('BIT_SE_K19D_K20A','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_SE_K19D_K20A','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_SE_K19D_K20A','340','SE_COM5.2','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A','',''),
('BIT_SE_K19D_K20A','402','SE_COM6','SE_COM6: Topic on Information Technology - Korean Language_Chủ đề Công nghệ thông tin - tiếng Hàn BIT_SE_K15C','',''),
('BIT_SE_K19D_K20A','1469','SE_COM5.1.1','SE_COM5.1.1:Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật CNTT: Lựa chọn JFE301 và 1 trong 2 học phần JIS401, JIT401 để triển khai ở kỳ 8) BIT_SE_K15C','',''),
('BIT_SE_K19D_K20A','2566','SE_COM7.1','SE_COM7.1:Topic on AI_Chủ đề AI','','Topic on AI_Chủ đề AI'),
('BIT_SE_K19D_K20A','2497','SE_COM4.1','SE_COM4.1: Topic on React/NodeJS_Chủ đề React/NodeJS','',''),
('BIT_SE_K19D_K20A','2605','SE_COM11','SE_COM11: Topic on IC design_Chủ đề Thiết kế vi mạch','',''),
('BIT_SE_K19D_K20A','2640','SE_COM10.2','SE_COM10.2: Topic on Intensive Java_Chủ đề Java chuyên sâu_K19A','',''),
('BIT_SE_K19D_K20A','2638','SE_COM13','SE_COM13: Topic on DevSepOps for cloud_Chủ đề Tích hợp DevSepOps cho cloud','',''),
('BIT_SE_K19D_K20A','2628','SE_COM12','SE_COM12: Topic on Game Development_Phát triển game','',''),
('BIT_SE_K19D_K20A','2675','SE_COM14','SE_COM14: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng_K19B','',''),
('BIT_SE_K19D_K20A','2686','SE_COM3.3','SE_COM3.3: Topic on .NET Programming_Chủ đề lập trình .NET BIT_SE_From_K18C','',''),
('BIT_SE_K20B','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_SE_K20B','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_SE_K20B','340','SE_COM5.2','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A','',''),
('BIT_SE_K20B','402','SE_COM6','SE_COM6: Topic on Information Technology - Korean Language_Chủ đề Công nghệ thông tin - tiếng Hàn BIT_SE_K15C','',''),
('BIT_SE_K20B','1469','SE_COM5.1.1','SE_COM5.1.1:Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật CNTT: Lựa chọn JFE301 và 1 trong 2 học phần JIS401, JIT401 để triển khai ở kỳ 8) BIT_SE_K15C','',''),
('BIT_SE_K20B','2566','SE_COM7.1','SE_COM7.1:Topic on AI_Chủ đề AI','','Topic on AI_Chủ đề AI'),
('BIT_SE_K20B','2497','SE_COM4.1','SE_COM4.1: Topic on React/NodeJS_Chủ đề React/NodeJS','',''),
('BIT_SE_K20B','2605','SE_COM11','SE_COM11: Topic on IC design_Chủ đề Thiết kế vi mạch','',''),
('BIT_SE_K20B','2640','SE_COM10.2','SE_COM10.2: Topic on Intensive Java_Chủ đề Java chuyên sâu_K19A','',''),
('BIT_SE_K20B','2628','SE_COM12','SE_COM12: Topic on Game Development_Phát triển game','',''),
('BIT_SE_K20B','2675','SE_COM14','SE_COM14: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng_K19B','',''),
('BIT_SE_K20B','2686','SE_COM3.3','SE_COM3.3: Topic on .NET Programming_Chủ đề lập trình .NET BIT_SE_From_K18C','',''),
('BIT_SE_K20C','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_SE_K20C','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_SE_K20C','340','SE_COM5.2','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A','',''),
('BIT_SE_K20C','402','SE_COM6','SE_COM6: Topic on Information Technology - Korean Language_Chủ đề Công nghệ thông tin - tiếng Hàn BIT_SE_K15C','',''),
('BIT_SE_K20C','2566','SE_COM7.1','SE_COM7.1:Topic on AI_Chủ đề AI','','Topic on AI_Chủ đề AI'),
('BIT_SE_K20C','2497','SE_COM4.1','SE_COM4.1: Topic on React/NodeJS_Chủ đề React/NodeJS','',''),
('BIT_SE_K20C','2605','SE_COM11','SE_COM11: Topic on IC design_Chủ đề Thiết kế vi mạch','',''),
('BIT_SE_K20C','2640','SE_COM10.2','SE_COM10.2: Topic on Intensive Java_Chủ đề Java chuyên sâu_K19A','',''),
('BIT_SE_K20C','2628','SE_COM12','SE_COM12: Topic on Game Development_Phát triển game','',''),
('BIT_SE_K20C','2675','SE_COM14','SE_COM14: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng_K19B','',''),
('BIT_SE_K20C','2686','SE_COM3.3','SE_COM3.3: Topic on .NET Programming_Chủ đề lập trình .NET BIT_SE_From_K18C','',''),
('BIT_SE_K20D_K21A','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_SE_K20D_K21A','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_SE_K20D_K21A','340','SE_COM5.2','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A','',''),
('BIT_SE_K20D_K21A','402','SE_COM6','SE_COM6: Topic on Information Technology - Korean Language_Chủ đề Công nghệ thông tin - tiếng Hàn BIT_SE_K15C','',''),
('BIT_SE_K20D_K21A','2566','SE_COM7.1','SE_COM7.1:Topic on AI_Chủ đề AI','','Topic on AI_Chủ đề AI'),
('BIT_SE_K20D_K21A','2497','SE_COM4.1','SE_COM4.1: Topic on React/NodeJS_Chủ đề React/NodeJS','',''),
('BIT_SE_K20D_K21A','2605','SE_COM11','SE_COM11: Topic on IC design_Chủ đề Thiết kế vi mạch','',''),
('BIT_SE_K20D_K21A','2640','SE_COM10.2','SE_COM10.2: Topic on Intensive Java_Chủ đề Java chuyên sâu_K19A','',''),
('BIT_SE_K20D_K21A','2628','SE_COM12','SE_COM12: Topic on Game Development_Phát triển game','','');
INSERT INTO st_combos VALUES
('BIT_SE_K20D_K21A','2675','SE_COM14','SE_COM14: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng_K19B','',''),
('BIT_SE_K20D_K21A','2686','SE_COM3.3','SE_COM3.3: Topic on .NET Programming_Chủ đề lập trình .NET BIT_SE_From_K18C','',''),
('BIT_SE_K21B','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_SE_K21B','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_SE_K21B','340','SE_COM5.2','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A','',''),
('BIT_SE_K21B','402','SE_COM6','SE_COM6: Topic on Information Technology - Korean Language_Chủ đề Công nghệ thông tin - tiếng Hàn BIT_SE_K15C','',''),
('BIT_SE_K21B','2566','SE_COM7.1','SE_COM7.1:Topic on AI_Chủ đề AI','','Topic on AI_Chủ đề AI'),
('BIT_SE_K21B','2497','SE_COM4.1','SE_COM4.1: Topic on React/NodeJS_Chủ đề React/NodeJS','',''),
('BIT_SE_K21B','2605','SE_COM11','SE_COM11: Topic on IC design_Chủ đề Thiết kế vi mạch','',''),
('BIT_SE_K21B','2640','SE_COM10.2','SE_COM10.2: Topic on Intensive Java_Chủ đề Java chuyên sâu_K19A','',''),
('BIT_SE_K21B','2628','SE_COM12','SE_COM12: Topic on Game Development_Phát triển game','',''),
('BIT_SE_K21B','2675','SE_COM14','SE_COM14: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng_K19B','',''),
('BIT_SE_K21B','2686','SE_COM3.3','SE_COM3.3: Topic on .NET Programming_Chủ đề lập trình .NET BIT_SE_From_K18C','',''),
('BIT_SE_K21C','26','PHE_COM1','PHE_COM1: Vovinam BIT_GD_K16D,K17A','',''),
('BIT_SE_K21C','334','PHE_COM2','PHE_COM2: Cờ vua BIT_SE_K15A','',''),
('BIT_SE_K21C','340','SE_COM5.2','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A','',''),
('BIT_SE_K21C','402','SE_COM6','SE_COM6: Topic on Information Technology - Korean Language_Chủ đề Công nghệ thông tin - tiếng Hàn BIT_SE_K15C','',''),
('BIT_SE_K21C','2566','SE_COM7.1','SE_COM7.1:Topic on AI_Chủ đề AI','','Topic on AI_Chủ đề AI'),
('BIT_SE_K21C','2497','SE_COM4.1','SE_COM4.1: Topic on React/NodeJS_Chủ đề React/NodeJS','',''),
('BIT_SE_K21C','2605','SE_COM11','SE_COM11: Topic on IC design_Chủ đề Thiết kế vi mạch','',''),
('BIT_SE_K21C','2640','SE_COM10.2','SE_COM10.2: Topic on Intensive Java_Chủ đề Java chuyên sâu_K19A','',''),
('BIT_SE_K21C','2628','SE_COM12','SE_COM12: Topic on Game Development_Phát triển game','',''),
('BIT_SE_K21C','2675','SE_COM14','SE_COM14: Topic on Applied Data Science_Chủ đề Khoa học dữ liệu (KHDL) ứng dụng_K19B','',''),
('BIT_SE_K21C','2686','SE_COM3.3','SE_COM3.3: Topic on .NET Programming_Chủ đề lập trình .NET BIT_SE_From_K18C','',''),
('BIT_SE-2026_K21D_K22A','2746','SE-2026_COM1','SE-2026_COM1: Topic on AI-Augmented Quality Assurance_Chủ đề Đảm bảo chất lượng tăng cường bằng AI','',''),
('BIT_SE-2026_K21D_K22A','2747','SE-2026_COM2','SE-2026_COM2: Topic on AI Application Engineer_Chủ đề về Kỹ sư Ứng dụng AI','',''),
('BIT_SE-2026_K21D_K22A','2748','SE-2026_COM3','SE-2026_COM3: Topic on AI-Augmented Business Analyst_ Chủ đề về Chuyên viên phân tích nghiệp vụ tăng cường bằng AI','',''),
('BIT_SE-2026_K21D_K22A','2749','SE-2026_COM4','SE-2026_COM4: Topic on AI-Augmented Engineer (Fullstack Java)_Chủ đề Kỹ sư phát triển Fullstack Java tăng cường bằng AI','',''),
('BIT_SE-2026_K21D_K22A','340','SE_COM5.2','SE_COM5.2: Topic on Japanese Bridge Engineer_Chủ đề Kỹ sư cầu nối Nhật Bản (Định hướng Tiếng Nhật nâng cao cho kỹ sư CNTT) BIT_SE_K15A','','');
INSERT INTO st_members VALUES
('BIT_AI_K18D-19A','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K18D-19A','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K18D-19A','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K18D-19A','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K18D-19A','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K18D-19A','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K18D-19A','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K18D-19A','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K18D-19A','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K18D-19A','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K18D-19A','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K18D-19A','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K18D-19A','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K18D-19A','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K18D-19A','2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K18D-19A','2620','6920','TMG301','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K18D-19A','2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K18D-19A','2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1175','5034','SEG301m','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1175','5035','TMG301m','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1175','5036','SLP301m','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1175','5037','IMP302m','Image & Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K18D-19A_FNO','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K19B_FNO','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K19B_FNO','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K19B_FNO','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K19B_FNO','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K19B_FNO','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K19B_FNO','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K19B_FNO','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K19B_FNO','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K19B_FNO','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K19B_FNO','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K19B_FNO','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K19B_FNO','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K19B_FNO','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K19B_FNO','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K19B_FNO','2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K19B_FNO','2620','6920','TMG301','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K19B_FNO','2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K19B_FNO','2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K19D-20A','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K19D-20A','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K19D-20A','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K19D-20A','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K19D-20A','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K19D-20A','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K19D-20A','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K19D-20A','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K19D-20A','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K19D-20A','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K19D-20A','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K19D-20A','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K19D-20A','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K19D-20A','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K19D-20A','2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K19D-20A','2620','6920','TMG301','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K19D-20A','2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K19D-20A','2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K20B','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K20B','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K20B','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K20B','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K20B','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K20B','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K20B','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K20B','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K20B','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K20B','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K20B','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K20B','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K20B','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K20B','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K20B','2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K20B','2620','6920','TMG301','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K20B','2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K20B','2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K20B','2653','7073','GAI201m','Introduction to Generative AI_Nhập môn TTNT tạo sinh','5',NULL,'',''),
('BIT_AI_K20B','2653','7074','MGA301','Multimodal AI_TTNT đa phương thức','7',NULL,'',''),
('BIT_AI_K20B','2653','7075','AGA301c','Advanced Generative AI_TTNT tạo sinh nâng cao','5',NULL,'',''),
('BIT_AI_K20B','2653','7076','GAP301','GenAI Project_Dự án TTNT tạo sinh','8',NULL,'',''),
('BIT_AI_K20B','2654','7077','MOI201m','Introduction to MLOps_Nhập môn hoạt động học máy','5',NULL,'',''),
('BIT_AI_K20B','2654','7078','CMO301m','Cloud for MLOps_Cloud cho hoạt động học máy','7',NULL,'',''),
('BIT_AI_K20B','2654','7079','AIS301c','AI for Cybersecurity_TTNT cho an ninh mạng','5',NULL,'',''),
('BIT_AI_K20B','2654','7080','AMO301m','Advanced MLOps_Hoạt động học máy nâng cao','8',NULL,'',''),
('BIT_AI_K20B_FNO','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K20B_FNO','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K20B_FNO','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K20B_FNO','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K20B_FNO','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K20B_FNO','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K20B_FNO','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K20B_FNO','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K20B_FNO','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K20B_FNO','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K20B_FNO','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K20B_FNO','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K20B_FNO','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K20B_FNO','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K20B_FNO','2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K20B_FNO','2620','6920','TMG301','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K20B_FNO','2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K20B_FNO','2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K20C','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K20C','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K20C','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K20C','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K20C','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K20C','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K20C','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K20C','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K20C','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K20C','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K20C','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K20C','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K20C','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K20C','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K20C','2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K20C','2620','6920','TMG301','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K20C','2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K20C','2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K20C','2653','7073','GAI201m','Introduction to Generative AI_Nhập môn TTNT tạo sinh','5',NULL,'',''),
('BIT_AI_K20C','2653','7074','MGA301','Multimodal AI_TTNT đa phương thức','7',NULL,'',''),
('BIT_AI_K20C','2653','7075','AGA301c','Advanced Generative AI_TTNT tạo sinh nâng cao','5',NULL,'',''),
('BIT_AI_K20C','2653','7076','GAP301','GenAI Project_Dự án TTNT tạo sinh','8',NULL,'',''),
('BIT_AI_K20C','2654','7077','MOI201m','Introduction to MLOps_Nhập môn hoạt động học máy','5',NULL,'',''),
('BIT_AI_K20C','2654','7078','CMO301m','Cloud for MLOps_Cloud cho hoạt động học máy','7',NULL,'',''),
('BIT_AI_K20C','2654','7079','AIS301c','AI for Cybersecurity_TTNT cho an ninh mạng','5',NULL,'',''),
('BIT_AI_K20C','2654','7080','AMO301m','Advanced MLOps_Hoạt động học máy nâng cao','8',NULL,'',''),
('BIT_AI_K20D-21A','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K20D-21A','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K20D-21A','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K20D-21A','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K20D-21A','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K20D-21A','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K20D-21A','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K20D-21A','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K20D-21A','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K20D-21A','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K20D-21A','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K20D-21A','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K20D-21A','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K20D-21A','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K20D-21A','2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K20D-21A','2620','6920','TMG301','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K20D-21A','2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K20D-21A','2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K20D-21A','2653','7073','GAI201m','Introduction to Generative AI_Nhập môn TTNT tạo sinh','5',NULL,'',''),
('BIT_AI_K20D-21A','2653','7074','MGA301','Multimodal AI_TTNT đa phương thức','7',NULL,'',''),
('BIT_AI_K20D-21A','2653','7075','AGA301c','Advanced Generative AI_TTNT tạo sinh nâng cao','5',NULL,'',''),
('BIT_AI_K20D-21A','2653','7076','GAP301','GenAI Project_Dự án TTNT tạo sinh','8',NULL,'',''),
('BIT_AI_K20D-21A','2654','7077','MOI201m','Introduction to MLOps_Nhập môn hoạt động học máy','5',NULL,'',''),
('BIT_AI_K20D-21A','2654','7078','CMO301m','Cloud for MLOps_Cloud cho hoạt động học máy','7',NULL,'',''),
('BIT_AI_K20D-21A','2654','7079','AIS301c','AI for Cybersecurity_TTNT cho an ninh mạng','5',NULL,'',''),
('BIT_AI_K20D-21A','2654','7080','AMO301m','Advanced MLOps_Hoạt động học máy nâng cao','8',NULL,'',''),
('BIT_AI_K21B','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K21B','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K21B','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K21B','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K21B','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K21B','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K21B','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K21B','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K21B','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K21B','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K21B','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K21B','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K21B','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K21B','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K21B','2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K21B','2620','6920','TMG301','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K21B','2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K21B','2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K21B','2653','7073','GAI201m','Introduction to Generative AI_Nhập môn TTNT tạo sinh','5',NULL,'',''),
('BIT_AI_K21B','2653','7074','MGA301','Multimodal AI_TTNT đa phương thức','7',NULL,'',''),
('BIT_AI_K21B','2653','7075','AGA301c','Advanced Generative AI_TTNT tạo sinh nâng cao','5',NULL,'',''),
('BIT_AI_K21B','2653','7076','GAP301','GenAI Project_Dự án TTNT tạo sinh','8',NULL,'',''),
('BIT_AI_K21B','2654','7077','MOI201m','Introduction to MLOps_Nhập môn hoạt động học máy','5',NULL,'',''),
('BIT_AI_K21B','2654','7078','CMO301m','Cloud for MLOps_Cloud cho hoạt động học máy','7',NULL,'',''),
('BIT_AI_K21B','2654','7079','AIS301c','AI for Cybersecurity_TTNT cho an ninh mạng','5',NULL,'',''),
('BIT_AI_K21B','2654','7080','AMO301m','Advanced MLOps_Hoạt động học máy nâng cao','8',NULL,'',''),
('BIT_AI_K21C','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K21C','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K21C','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K21C','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K21C','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K21C','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K21C','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K21C','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K21C','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K21C','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K21C','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K21C','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K21C','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K21C','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K21C','2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K21C','2620','6920','TMG301','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K21C','2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K21C','2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K21C','2653','7073','GAI201m','Introduction to Generative AI_Nhập môn TTNT tạo sinh','5',NULL,'',''),
('BIT_AI_K21C','2653','7074','MGA301','Multimodal AI_TTNT đa phương thức','7',NULL,'',''),
('BIT_AI_K21C','2653','7075','AGA301c','Advanced Generative AI_TTNT tạo sinh nâng cao','5',NULL,'',''),
('BIT_AI_K21C','2653','7076','GAP301','GenAI Project_Dự án TTNT tạo sinh','8',NULL,'',''),
('BIT_AI_K21C','2654','7077','MOI201m','Introduction to MLOps_Nhập môn hoạt động học máy','5',NULL,'',''),
('BIT_AI_K21C','2654','7078','CMO301m','Cloud for MLOps_Cloud cho hoạt động học máy','7',NULL,'',''),
('BIT_AI_K21C','2654','7079','AIS301c','AI for Cybersecurity_TTNT cho an ninh mạng','5',NULL,'',''),
('BIT_AI_K21C','2654','7080','AMO301m','Advanced MLOps_Hoạt động học máy nâng cao','8',NULL,'',''),
('BIT_AI_K21D-22A','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_AI_K21D-22A','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_AI_K21D-22A','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_AI_K21D-22A','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_AI_K21D-22A','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_AI_K21D-22A','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_AI_K21D-22A','1174','5030','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_AI_K21D-22A','1174','5031','BDI302c','Big Data_Dữ liệu lớn','5',NULL,'',''),
('BIT_AI_K21D-22A','1174','5032','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_AI_K21D-22A','1174','5033','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_AI_K21D-22A','1176','5038','ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học','5',NULL,'',''),
('BIT_AI_K21D-22A','1176','5039','AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe','5',NULL,'',''),
('BIT_AI_K21D-22A','1176','5040','AIM301m','AI for Medicine_Ứng dụng TTNT cho y học','7',NULL,'',''),
('BIT_AI_K21D-22A','1176','5041','AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch','8',NULL,'',''),
('BIT_AI_K21D-22A','2620','6919','SEG301','Search Engines_Công cụ tìm kiếm','5',NULL,'',''),
('BIT_AI_K21D-22A','2620','6920','TMG301','Text Mining_Khai thác văn bản','5',NULL,'',''),
('BIT_AI_K21D-22A','2620','6921','SLP301','Speech Processing_Xử lý tiếng nói','7',NULL,'',''),
('BIT_AI_K21D-22A','2620','6922','IMP302','Image and Video processing_Xử lý hình ảnh và video','8',NULL,'',''),
('BIT_AI_K21D-22A','2654','7077','MOI201m','Introduction to MLOps_Nhập môn hoạt động học máy','5',NULL,'',''),
('BIT_AI_K21D-22A','2654','7078','CMO301m','Cloud for MLOps_Cloud cho hoạt động học máy','7',NULL,'',''),
('BIT_AI_K21D-22A','2654','7079','AIS301c','AI for Cybersecurity_TTNT cho an ninh mạng','5',NULL,'',''),
('BIT_AI_K21D-22A','2654','7080','AMO301m','Advanced MLOps_Hoạt động học máy nâng cao','8',NULL,'',''),
('BIT_AI_K21D-22A','2653','7073','GAI201m','Introduction to Generative AI_Nhập môn TTNT tạo sinh','5',NULL,'',''),
('BIT_AI_K21D-22A','2653','7074','MGA301','Multimodal AI_TTNT đa phương thức','7',NULL,'',''),
('BIT_AI_K21D-22A','2653','7075','AGA301c','Advanced Generative AI_TTNT tạo sinh nâng cao','5',NULL,'',''),
('BIT_AI_K21D-22A','2653','7076','GAP301','GenAI Project_Dự án TTNT tạo sinh','8',NULL,'',''),
('BIT_IA_K18D-19A','584','2335','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IA_K18D-19A','584','2336','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IA_K18D-19A','584','2337','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IA_K18D-19A','585','2338','COV111','Cờ Vua 1','0',NULL,'','');
INSERT INTO st_members VALUES
('BIT_IA_K18D-19A','585','2339','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IA_K18D-19A','585','2340','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IA_K18D-19A','586','2341','DBS401','Database Security_An ninh cơ sở dữ liệu','8',NULL,'',''),
('BIT_IA_K18D-19A','586','2342','FRS401c','Network Forensics_Điều tra mạng','7',NULL,'',''),
('BIT_IA_K18D-19A','586','2343','IAR401c','Incident Response_Đối phó sự cố','8',NULL,'',''),
('BIT_IA_K18D-19A','586','2344','IAW301','Web security_An ninh Web','7',NULL,'',''),
('BIT_IA_K18D-19A','586','6630','NWC303','Network Connectivity_Kết nối mạng','8',NULL,'','or SPM401, if the student passed the subject NWC204'),
('BIT_IA_K18D-19A','587','2346','CES202','System Support and Trouble Shooting_Hỗ trợ hệ thống và khắc phục sự cố','7',NULL,'',''),
('BIT_IA_K18D-19A','587','2347','FRS401c','Network Forensics_Điều tra mạng','7',NULL,'',''),
('BIT_IA_K18D-19A','587','2348','IAR401c','Incident Response_Đối phó sự cố','8',NULL,'',''),
('BIT_IA_K18D-19A','587','2349','DMS401','Applied Data Mining for Information Assurance_Ứng dụng khai phá dữ liệu trong an toàn thông tin','8',NULL,'',''),
('BIT_IA_K18D-19A','587','2350','SPM401','Security Project Management_Quản trị dự án an toàn thông tin','8',NULL,'',''),
('BIT_IA_K18D-19A_FNO','584','2335','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IA_K18D-19A_FNO','584','2336','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IA_K18D-19A_FNO','584','2337','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IA_K18D-19A_FNO','585','2338','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IA_K18D-19A_FNO','585','2339','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IA_K18D-19A_FNO','585','2340','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IA_K18D-19A_FNO','586','2341','DBS401','Database Security_An ninh cơ sở dữ liệu','8',NULL,'',''),
('BIT_IA_K18D-19A_FNO','586','2342','FRS401c','Network Forensics_Điều tra mạng','7',NULL,'',''),
('BIT_IA_K18D-19A_FNO','586','2343','IAR401c','Incident Response_Đối phó sự cố','8',NULL,'',''),
('BIT_IA_K18D-19A_FNO','586','2344','IAW301','Web security_An ninh Web','7',NULL,'',''),
('BIT_IA_K18D-19A_FNO','586','6630','NWC303','Network Connectivity_Kết nối mạng','8',NULL,'','or SPM401, if the student passed the subject NWC204'),
('BIT_IA_K18D-19A_FNO','587','2346','CES202','System Support and Trouble Shooting_Hỗ trợ hệ thống và khắc phục sự cố','7',NULL,'',''),
('BIT_IA_K18D-19A_FNO','587','2347','FRS401c','Network Forensics_Điều tra mạng','7',NULL,'',''),
('BIT_IA_K18D-19A_FNO','587','2348','IAR401c','Incident Response_Đối phó sự cố','8',NULL,'',''),
('BIT_IA_K18D-19A_FNO','587','2349','DMS401','Applied Data Mining for Information Assurance_Ứng dụng khai phá dữ liệu trong an toàn thông tin','8',NULL,'',''),
('BIT_IA_K18D-19A_FNO','587','2350','SPM401','Security Project Management_Quản trị dự án an toàn thông tin','8',NULL,'',''),
('BIT_IA_K19B_FNO','584','2335','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IA_K19B_FNO','584','2336','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IA_K19B_FNO','584','2337','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IA_K19B_FNO','585','2338','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IA_K19B_FNO','585','2339','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IA_K19B_FNO','585','2340','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IA_K19B_FNO','586','2341','DBS401','Database Security_An ninh cơ sở dữ liệu','8',NULL,'',''),
('BIT_IA_K19B_FNO','586','2342','FRS401c','Network Forensics_Điều tra mạng','7',NULL,'',''),
('BIT_IA_K19B_FNO','586','2343','IAR401c','Incident Response_Đối phó sự cố','8',NULL,'',''),
('BIT_IA_K19B_FNO','586','2344','IAW301','Web security_An ninh Web','7',NULL,'',''),
('BIT_IA_K19B_FNO','586','6630','NWC303','Network Connectivity_Kết nối mạng','8',NULL,'','or SPM401, if the student passed the subject NWC204'),
('BIT_IA_K19B_FNO','587','2346','CES202','System Support and Trouble Shooting_Hỗ trợ hệ thống và khắc phục sự cố','7',NULL,'',''),
('BIT_IA_K19B_FNO','587','2347','FRS401c','Network Forensics_Điều tra mạng','7',NULL,'',''),
('BIT_IA_K19B_FNO','587','2348','IAR401c','Incident Response_Đối phó sự cố','8',NULL,'',''),
('BIT_IA_K19B_FNO','587','2349','DMS401','Applied Data Mining for Information Assurance_Ứng dụng khai phá dữ liệu trong an toàn thông tin','8',NULL,'',''),
('BIT_IA_K19B_FNO','587','2350','SPM401','Security Project Management_Quản trị dự án an toàn thông tin','8',NULL,'',''),
('BIT_IA_K19D-20A','584','2335','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IA_K19D-20A','584','2336','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IA_K19D-20A','584','2337','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IA_K19D-20A','585','2338','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IA_K19D-20A','585','2339','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IA_K19D-20A','585','2340','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IA_K19D-20A','586','2341','DBS401','Database Security_An ninh cơ sở dữ liệu','8',NULL,'',''),
('BIT_IA_K19D-20A','586','2342','FRS401c','Network Forensics_Điều tra mạng','7',NULL,'',''),
('BIT_IA_K19D-20A','586','2343','IAR401c','Incident Response_Đối phó sự cố','8',NULL,'',''),
('BIT_IA_K19D-20A','586','2344','IAW301','Web security_An ninh Web','7',NULL,'',''),
('BIT_IA_K19D-20A','586','6630','NWC303','Network Connectivity_Kết nối mạng','8',NULL,'','or SPM401, if the student passed the subject NWC204'),
('BIT_IA_K19D-20A','587','2346','CES202','System Support and Trouble Shooting_Hỗ trợ hệ thống và khắc phục sự cố','7',NULL,'',''),
('BIT_IA_K19D-20A','587','2347','FRS401c','Network Forensics_Điều tra mạng','7',NULL,'',''),
('BIT_IA_K19D-20A','587','2348','IAR401c','Incident Response_Đối phó sự cố','8',NULL,'',''),
('BIT_IA_K19D-20A','587','2349','DMS401','Applied Data Mining for Information Assurance_Ứng dụng khai phá dữ liệu trong an toàn thông tin','8',NULL,'',''),
('BIT_IA_K19D-20A','587','2350','SPM401','Security Project Management_Quản trị dự án an toàn thông tin','8',NULL,'',''),
('BIT_IA_K20B','2650','7061','SDL201','Secure Software Development Lifecycle_Vòng đời Phát triển Phần mềm an toàn','7',NULL,'',''),
('BIT_IA_K20B','2650','7062','ASE201','Application Security Evaluation_Đánh giá bảo mật ứng dụng','7',NULL,'',''),
('BIT_IA_K20B','2650','7063','ADD301','Application Security Design and Development_Thiết kế và phát triển bảo mật ứng dụng','8',NULL,'',''),
('BIT_IA_K20B','2650','7064','DSO301','DevSecOps_Tích hợp DevSecOps','8',NULL,'',''),
('BIT_IA_K20B','2651','7065','NSA201','Enterprise Networking, Security, and Automation_Mạng Doanh nghiệp, An ninh và Tự động hóa','7',NULL,'',''),
('BIT_IA_K20B','2651','7066','NSR201','Network Security_An ninh mạng','7',NULL,'',''),
('BIT_IA_K20B','2651','7067','IIR301c','Network Incident Investigation and Response_Điều tra và Ứng phó sự cố An ninh Mạng','8',NULL,'',''),
('BIT_IA_K20B','2651','7068','COA301','Cybersecurity Operations and Analysis_Vận hành và Phân tích An ninh Mạng','8',NULL,'',''),
('BIT_IA_K20B','2652','7069','AML201','Introduction to Artificial Intelligence and Machine Learning_Nhập môn Trí tuệ Nhân tạo và Học máy','7',NULL,'',''),
('BIT_IA_K20B','2652','7070','CDA201','Foundations of Cybersecurity and Data Analyst_Nền tảng An ninh mạng và Phân tích Dữ liệu','7',NULL,'',''),
('BIT_IA_K20B','2652','7071','MLC301','Machine Learning Applications in Cyber Security','8',NULL,'',''),
('BIT_IA_K20B','2652','7072','AAC301','Advanced Topics in AI for Cyber Security_Nâng cao về TTNT trong An ninh mạng','8',NULL,'',''),
('BIT_IA_K20B','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IA_K20B','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IA_K20B','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IA_K20B','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IA_K20B','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IA_K20B','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IA_K20B_FNO','2650','7061','SDL201','Secure Software Development Lifecycle_Vòng đời Phát triển Phần mềm an toàn','7',NULL,'',''),
('BIT_IA_K20B_FNO','2650','7062','ASE201','Application Security Evaluation_Đánh giá bảo mật ứng dụng','7',NULL,'',''),
('BIT_IA_K20B_FNO','2650','7063','ADD301','Application Security Design and Development_Thiết kế và phát triển bảo mật ứng dụng','8',NULL,'',''),
('BIT_IA_K20B_FNO','2650','7064','DSO301','DevSecOps_Tích hợp DevSecOps','8',NULL,'',''),
('BIT_IA_K20B_FNO','2651','7065','NSA201','Enterprise Networking, Security, and Automation_Mạng Doanh nghiệp, An ninh và Tự động hóa','7',NULL,'',''),
('BIT_IA_K20B_FNO','2651','7066','NSR201','Network Security_An ninh mạng','7',NULL,'',''),
('BIT_IA_K20B_FNO','2651','7067','IIR301c','Network Incident Investigation and Response_Điều tra và Ứng phó sự cố An ninh Mạng','8',NULL,'',''),
('BIT_IA_K20B_FNO','2651','7068','COA301','Cybersecurity Operations and Analysis_Vận hành và Phân tích An ninh Mạng','8',NULL,'',''),
('BIT_IA_K20B_FNO','2652','7069','AML201','Introduction to Artificial Intelligence and Machine Learning_Nhập môn Trí tuệ Nhân tạo và Học máy','7',NULL,'',''),
('BIT_IA_K20B_FNO','2652','7070','CDA201','Foundations of Cybersecurity and Data Analyst_Nền tảng An ninh mạng và Phân tích Dữ liệu','7',NULL,'',''),
('BIT_IA_K20B_FNO','2652','7071','MLC301','Machine Learning Applications in Cyber Security','8',NULL,'',''),
('BIT_IA_K20B_FNO','2652','7072','AAC301','Advanced Topics in AI for Cyber Security_Nâng cao về TTNT trong An ninh mạng','8',NULL,'',''),
('BIT_IA_K20B_FNO','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IA_K20B_FNO','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IA_K20B_FNO','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IA_K20B_FNO','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IA_K20B_FNO','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IA_K20B_FNO','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IA_K20C','2650','7061','SDL201','Secure Software Development Lifecycle_Vòng đời Phát triển Phần mềm an toàn','7',NULL,'',''),
('BIT_IA_K20C','2650','7062','ASE201','Application Security Evaluation_Đánh giá bảo mật ứng dụng','7',NULL,'',''),
('BIT_IA_K20C','2650','7063','ADD301','Application Security Design and Development_Thiết kế và phát triển bảo mật ứng dụng','8',NULL,'',''),
('BIT_IA_K20C','2650','7064','DSO301','DevSecOps_Tích hợp DevSecOps','8',NULL,'',''),
('BIT_IA_K20C','2651','7065','NSA201','Enterprise Networking, Security, and Automation_Mạng Doanh nghiệp, An ninh và Tự động hóa','7',NULL,'',''),
('BIT_IA_K20C','2651','7066','NSR201','Network Security_An ninh mạng','7',NULL,'',''),
('BIT_IA_K20C','2651','7067','IIR301c','Network Incident Investigation and Response_Điều tra và Ứng phó sự cố An ninh Mạng','8',NULL,'',''),
('BIT_IA_K20C','2651','7068','COA301','Cybersecurity Operations and Analysis_Vận hành và Phân tích An ninh Mạng','8',NULL,'',''),
('BIT_IA_K20C','2652','7069','AML201','Introduction to Artificial Intelligence and Machine Learning_Nhập môn Trí tuệ Nhân tạo và Học máy','7',NULL,'',''),
('BIT_IA_K20C','2652','7070','CDA201','Foundations of Cybersecurity and Data Analyst_Nền tảng An ninh mạng và Phân tích Dữ liệu','7',NULL,'',''),
('BIT_IA_K20C','2652','7071','MLC301','Machine Learning Applications in Cyber Security','8',NULL,'',''),
('BIT_IA_K20C','2652','7072','AAC301','Advanced Topics in AI for Cyber Security_Nâng cao về TTNT trong An ninh mạng','8',NULL,'',''),
('BIT_IA_K20C','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IA_K20C','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IA_K20C','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IA_K20C','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IA_K20C','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IA_K20C','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IA_K20D-21A','2650','7061','SDL201','Secure Software Development Lifecycle_Vòng đời Phát triển Phần mềm an toàn','7',NULL,'',''),
('BIT_IA_K20D-21A','2650','7062','ASE201','Application Security Evaluation_Đánh giá bảo mật ứng dụng','7',NULL,'',''),
('BIT_IA_K20D-21A','2650','7063','ADD301','Application Security Design and Development_Thiết kế và phát triển bảo mật ứng dụng','8',NULL,'',''),
('BIT_IA_K20D-21A','2650','7064','DSO301','DevSecOps_Tích hợp DevSecOps','8',NULL,'',''),
('BIT_IA_K20D-21A','2651','7065','NSA201','Enterprise Networking, Security, and Automation_Mạng Doanh nghiệp, An ninh và Tự động hóa','7',NULL,'',''),
('BIT_IA_K20D-21A','2651','7066','NSR201','Network Security_An ninh mạng','7',NULL,'',''),
('BIT_IA_K20D-21A','2651','7067','IIR301c','Network Incident Investigation and Response_Điều tra và Ứng phó sự cố An ninh Mạng','8',NULL,'',''),
('BIT_IA_K20D-21A','2651','7068','COA301','Cybersecurity Operations and Analysis_Vận hành và Phân tích An ninh Mạng','8',NULL,'',''),
('BIT_IA_K20D-21A','2652','7069','AML201','Introduction to Artificial Intelligence and Machine Learning_Nhập môn Trí tuệ Nhân tạo và Học máy','7',NULL,'',''),
('BIT_IA_K20D-21A','2652','7070','CDA201','Foundations of Cybersecurity and Data Analyst_Nền tảng An ninh mạng và Phân tích Dữ liệu','7',NULL,'',''),
('BIT_IA_K20D-21A','2652','7071','MLC301','Machine Learning Applications in Cyber Security','8',NULL,'',''),
('BIT_IA_K20D-21A','2652','7072','AAC301','Advanced Topics in AI for Cyber Security_Nâng cao về TTNT trong An ninh mạng','8',NULL,'',''),
('BIT_IA_K20D-21A','1172','5024','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IA_K20D-21A','1172','5025','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IA_K20D-21A','1172','5026','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IA_K20D-21A','1173','5027','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IA_K20D-21A','1173','5028','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IA_K20D-21A','1173','5029','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IA_K21B','2650','7061','SDL201','Secure Software Development Lifecycle_Vòng đời Phát triển Phần mềm an toàn','7',NULL,'',''),
('BIT_IA_K21B','2650','7062','ASE201','Application Security Evaluation_Đánh giá bảo mật ứng dụng','7',NULL,'',''),
('BIT_IA_K21B','2650','7063','ADD301','Application Security Design and Development_Thiết kế và phát triển bảo mật ứng dụng','8',NULL,'',''),
('BIT_IA_K21B','2650','7064','DSO301','DevSecOps_Tích hợp DevSecOps','8',NULL,'',''),
('BIT_IA_K21B','2651','7065','NSA201','Enterprise Networking, Security, and Automation_Mạng Doanh nghiệp, An ninh và Tự động hóa','7',NULL,'',''),
('BIT_IA_K21B','2651','7066','NSR201','Network Security_An ninh mạng','7',NULL,'',''),
('BIT_IA_K21B','2651','7067','IIR301c','Network Incident Investigation and Response_Điều tra và Ứng phó sự cố An ninh Mạng','8',NULL,'',''),
('BIT_IA_K21B','2651','7068','COA301','Cybersecurity Operations and Analysis_Vận hành và Phân tích An ninh Mạng','8',NULL,'',''),
('BIT_IA_K21B','2652','7069','AML201','Introduction to Artificial Intelligence and Machine Learning_Nhập môn Trí tuệ Nhân tạo và Học máy','7',NULL,'',''),
('BIT_IA_K21B','2652','7070','CDA201','Foundations of Cybersecurity and Data Analyst_Nền tảng An ninh mạng và Phân tích Dữ liệu','7',NULL,'',''),
('BIT_IA_K21B','2652','7071','MLC301','Machine Learning Applications in Cyber Security','8',NULL,'',''),
('BIT_IA_K21B','2652','7072','AAC301','Advanced Topics in AI for Cyber Security_Nâng cao về TTNT trong An ninh mạng','8',NULL,'',''),
('BIT_IA_K21C','2650','7061','SDL201','Secure Software Development Lifecycle_Vòng đời Phát triển Phần mềm an toàn','7',NULL,'',''),
('BIT_IA_K21C','2650','7062','ASE201','Application Security Evaluation_Đánh giá bảo mật ứng dụng','7',NULL,'',''),
('BIT_IA_K21C','2650','7063','ADD301','Application Security Design and Development_Thiết kế và phát triển bảo mật ứng dụng','8',NULL,'',''),
('BIT_IA_K21C','2650','7064','DSO301','DevSecOps_Tích hợp DevSecOps','8',NULL,'',''),
('BIT_IA_K21C','2651','7065','NSA201','Enterprise Networking, Security, and Automation_Mạng Doanh nghiệp, An ninh và Tự động hóa','7',NULL,'',''),
('BIT_IA_K21C','2651','7066','NSR201','Network Security_An ninh mạng','7',NULL,'',''),
('BIT_IA_K21C','2651','7067','IIR301c','Network Incident Investigation and Response_Điều tra và Ứng phó sự cố An ninh Mạng','8',NULL,'',''),
('BIT_IA_K21C','2651','7068','COA301','Cybersecurity Operations and Analysis_Vận hành và Phân tích An ninh Mạng','8',NULL,'',''),
('BIT_IA_K21C','2652','7069','AML201','Introduction to Artificial Intelligence and Machine Learning_Nhập môn Trí tuệ Nhân tạo và Học máy','7',NULL,'',''),
('BIT_IA_K21C','2652','7070','CDA201','Foundations of Cybersecurity and Data Analyst_Nền tảng An ninh mạng và Phân tích Dữ liệu','7',NULL,'',''),
('BIT_IA_K21C','2652','7071','MLC301','Machine Learning Applications in Cyber Security','8',NULL,'',''),
('BIT_IA_K21C','2652','7072','AAC301','Advanced Topics in AI for Cyber Security_Nâng cao về TTNT trong An ninh mạng','8',NULL,'',''),
('BIT_IA_K21D-22A','2650','7061','SDL201','Secure Software Development Lifecycle_Vòng đời Phát triển Phần mềm an toàn','7',NULL,'',''),
('BIT_IA_K21D-22A','2650','7062','ASE201','Application Security Evaluation_Đánh giá bảo mật ứng dụng','7',NULL,'',''),
('BIT_IA_K21D-22A','2650','7063','ADD301','Application Security Design and Development_Thiết kế và phát triển bảo mật ứng dụng','8',NULL,'',''),
('BIT_IA_K21D-22A','2650','7064','DSO301','DevSecOps_Tích hợp DevSecOps','8',NULL,'',''),
('BIT_IA_K21D-22A','2651','7065','NSA201','Enterprise Networking, Security, and Automation_Mạng Doanh nghiệp, An ninh và Tự động hóa','7',NULL,'',''),
('BIT_IA_K21D-22A','2651','7066','NSR201','Network Security_An ninh mạng','7',NULL,'',''),
('BIT_IA_K21D-22A','2651','7067','IIR301c','Network Incident Investigation and Response_Điều tra và Ứng phó sự cố An ninh Mạng','8',NULL,'',''),
('BIT_IA_K21D-22A','2651','7068','COA301','Cybersecurity Operations and Analysis_Vận hành và Phân tích An ninh Mạng','8',NULL,'',''),
('BIT_IA_K21D-22A','2652','7069','AML201','Introduction to Artificial Intelligence and Machine Learning_Nhập môn Trí tuệ Nhân tạo và Học máy','7',NULL,'',''),
('BIT_IA_K21D-22A','2652','7070','CDA201','Foundations of Cybersecurity and Data Analyst_Nền tảng An ninh mạng và Phân tích Dữ liệu','7',NULL,'',''),
('BIT_IA_K21D-22A','2652','7071','MLC301','Machine Learning Applications in Cyber Security','8',NULL,'',''),
('BIT_IA_K21D-22A','2652','7072','AAC301','Advanced Topics in AI for Cyber Security_Nâng cao về TTNT trong An ninh mạng','8',NULL,'',''),
('BIT_IS_K18D_19A','2636','6994','FIN202','Principles of Corporate Finance_Tài chính doanh nghiệp','5',NULL,'',''),
('BIT_IS_K18D_19A','2636','6995','KMS301','Knowledge management system_Hệ thống quản trị tri thức','7',NULL,'',''),
('BIT_IS_K18D_19A','2636','6996','DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định','7',NULL,'',''),
('BIT_IS_K18D_19A','2636','6997','BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh','8',NULL,'',''),
('BIT_IS_K18D_19A','2637','6998','ACC101','Principles of Accounting_Nguyên lý kế toán','5',NULL,'',''),
('BIT_IS_K18D_19A','2637','6999','SAP311','SAP General 1 - Tổng quan về SAP 1','7',NULL,'',''),
('BIT_IS_K18D_19A','2637','7000','SAP321','SAP General 2 - Tổng quan về SAP 2','7',NULL,'',''),
('BIT_IS_K18D_19A','2637','7001','SAP341','SAP Application Development with ABAP_Phát triển ứng dụng SAP với ABAP','8',NULL,'',''),
('BIT_IS_K18D_19A','2641','7017','SWR302','Software Requirement_Yêu cầu phần mềm','5',NULL,'',''),
('BIT_IS_K18D_19A','2641','7018','MIS301','Management Information System_Hệ thống thông tin quản lý','7',NULL,'',''),
('BIT_IS_K18D_19A','2641','7019','SWT301','Software Testing_Kiểm thử phần mềm','7',NULL,'',''),
('BIT_IS_K18D_19A','2641','7020','AAT301','Agile and Automation Testing_Kiểm thử tự động và linh hoạt','8',NULL,'',''),
('BIT_IS_K18D_19A','2634','6986','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_IS_K18D_19A','2634','6987','AST301','Security Testing_Kiểm thử bảo mật','7',NULL,'',''),
('BIT_IS_K18D_19A','2634','6988','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_IS_K18D_19A','2634','6989','DSO392','DevSecOps for Information Systems_Tích hợp DevSecOps cho Hệ thống thông tin','8',NULL,'',''),
('BIT_IS_K18D_19A','2635','6990','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_IS_K18D_19A','2635','6992','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_IS_K18D_19A','2635','6993','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_IS_K18D_19A','2635','7504','BDI301c','Big Data_Dữ liệu lớn','7',NULL,'',''),
('BIT_IS_K18D_19A','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IS_K18D_19A','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IS_K18D_19A','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IS_K18D_19A','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IS_K18D_19A','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IS_K18D_19A','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IS_K19B','2636','6994','FIN202','Principles of Corporate Finance_Tài chính doanh nghiệp','5',NULL,'',''),
('BIT_IS_K19B','2636','6995','KMS301','Knowledge management system_Hệ thống quản trị tri thức','7',NULL,'',''),
('BIT_IS_K19B','2636','6996','DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định','7',NULL,'',''),
('BIT_IS_K19B','2636','6997','BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh','8',NULL,'',''),
('BIT_IS_K19B','2641','7017','SWR302','Software Requirement_Yêu cầu phần mềm','5',NULL,'',''),
('BIT_IS_K19B','2641','7018','MIS301','Management Information System_Hệ thống thông tin quản lý','7',NULL,'',''),
('BIT_IS_K19B','2641','7019','SWT301','Software Testing_Kiểm thử phần mềm','7',NULL,'',''),
('BIT_IS_K19B','2641','7020','AAT301','Agile and Automation Testing_Kiểm thử tự động và linh hoạt','8',NULL,'',''),
('BIT_IS_K19B','2634','6986','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_IS_K19B','2634','6987','AST301','Security Testing_Kiểm thử bảo mật','7',NULL,'',''),
('BIT_IS_K19B','2634','6988','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_IS_K19B','2634','6989','DSO392','DevSecOps for Information Systems_Tích hợp DevSecOps cho Hệ thống thông tin','8',NULL,'',''),
('BIT_IS_K19B','2635','6990','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_IS_K19B','2635','6992','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_IS_K19B','2635','6993','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_IS_K19B','2635','7504','BDI301c','Big Data_Dữ liệu lớn','7',NULL,'',''),
('BIT_IS_K19B','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IS_K19B','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IS_K19B','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IS_K19B','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IS_K19B','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IS_K19B','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IS_K19C','2636','6994','FIN202','Principles of Corporate Finance_Tài chính doanh nghiệp','5',NULL,'',''),
('BIT_IS_K19C','2636','6995','KMS301','Knowledge management system_Hệ thống quản trị tri thức','7',NULL,'',''),
('BIT_IS_K19C','2636','6996','DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định','7',NULL,'',''),
('BIT_IS_K19C','2636','6997','BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh','8',NULL,'',''),
('BIT_IS_K19C','2641','7017','SWR302','Software Requirement_Yêu cầu phần mềm','5',NULL,'',''),
('BIT_IS_K19C','2641','7018','MIS301','Management Information System_Hệ thống thông tin quản lý','7',NULL,'',''),
('BIT_IS_K19C','2641','7019','SWT301','Software Testing_Kiểm thử phần mềm','7',NULL,'',''),
('BIT_IS_K19C','2641','7020','AAT301','Agile and Automation Testing_Kiểm thử tự động và linh hoạt','8',NULL,'',''),
('BIT_IS_K19C','2634','6986','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_IS_K19C','2634','6987','AST301','Security Testing_Kiểm thử bảo mật','7',NULL,'',''),
('BIT_IS_K19C','2634','6988','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_IS_K19C','2634','6989','DSO392','DevSecOps for Information Systems_Tích hợp DevSecOps cho Hệ thống thông tin','8',NULL,'',''),
('BIT_IS_K19C','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IS_K19C','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IS_K19C','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IS_K19C','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IS_K19C','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IS_K19C','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IS_K19C','2754','7505','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_IS_K19C','2754','7506','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_IS_K19C','2754','7507','BDI302c','Big Data_Dữ liệu lớn','7',NULL,'',''),
('BIT_IS_K19C','2754','7508','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_IS_K19D_K20A','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IS_K19D_K20A','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IS_K19D_K20A','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IS_K19D_K20A','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IS_K19D_K20A','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IS_K19D_K20A','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IS_K19D_K20A','2634','6986','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_IS_K19D_K20A','2634','6987','AST301','Security Testing_Kiểm thử bảo mật','7',NULL,'',''),
('BIT_IS_K19D_K20A','2634','6988','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_IS_K19D_K20A','2634','6989','DSO392','DevSecOps for Information Systems_Tích hợp DevSecOps cho Hệ thống thông tin','8',NULL,'',''),
('BIT_IS_K19D_K20A','2641','7017','SWR302','Software Requirement_Yêu cầu phần mềm','5',NULL,'',''),
('BIT_IS_K19D_K20A','2641','7018','MIS301','Management Information System_Hệ thống thông tin quản lý','7',NULL,'','');
INSERT INTO st_members VALUES
('BIT_IS_K19D_K20A','2641','7019','SWT301','Software Testing_Kiểm thử phần mềm','7',NULL,'',''),
('BIT_IS_K19D_K20A','2641','7020','AAT301','Agile and Automation Testing_Kiểm thử tự động và linh hoạt','8',NULL,'',''),
('BIT_IS_K19D_K20A','2734','7421','IMO301c','IT Service Management and Operations_Quản lý và Vận hành Dịch vụ Công nghệ Thông tin','5',NULL,'',''),
('BIT_IS_K19D_K20A','2734','7422','KMS301','Knowledge management system_Hệ thống quản trị tri thức','7',NULL,'',''),
('BIT_IS_K19D_K20A','2734','7423','DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định','7',NULL,'',''),
('BIT_IS_K19D_K20A','2734','7424','BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh','8',NULL,'',''),
('BIT_IS_K19D_K20A','2754','7505','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_IS_K19D_K20A','2754','7506','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_IS_K19D_K20A','2754','7507','BDI302c','Big Data_Dữ liệu lớn','7',NULL,'',''),
('BIT_IS_K19D_K20A','2754','7508','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_IS_K20B','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IS_K20B','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IS_K20B','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IS_K20B','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IS_K20B','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IS_K20B','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IS_K20B','2637','6998','ACC101','Principles of Accounting_Nguyên lý kế toán','5',NULL,'',''),
('BIT_IS_K20B','2637','6999','SAP311','SAP General 1 - Tổng quan về SAP 1','7',NULL,'',''),
('BIT_IS_K20B','2637','7000','SAP321','SAP General 2 - Tổng quan về SAP 2','7',NULL,'',''),
('BIT_IS_K20B','2637','7001','SAP341','SAP Application Development with ABAP_Phát triển ứng dụng SAP với ABAP','8',NULL,'',''),
('BIT_IS_K20B','2641','7017','SWR302','Software Requirement_Yêu cầu phần mềm','5',NULL,'',''),
('BIT_IS_K20B','2641','7018','MIS301','Management Information System_Hệ thống thông tin quản lý','7',NULL,'',''),
('BIT_IS_K20B','2641','7019','SWT301','Software Testing_Kiểm thử phần mềm','7',NULL,'',''),
('BIT_IS_K20B','2641','7020','AAT301','Agile and Automation Testing_Kiểm thử tự động và linh hoạt','8',NULL,'',''),
('BIT_IS_K20B','2634','6986','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_IS_K20B','2634','6987','AST301','Security Testing_Kiểm thử bảo mật','7',NULL,'',''),
('BIT_IS_K20B','2634','6988','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_IS_K20B','2634','6989','DSO392','DevSecOps for Information Systems_Tích hợp DevSecOps cho Hệ thống thông tin','8',NULL,'',''),
('BIT_IS_K20B','2734','7421','IMO301c','IT Service Management and Operations_Quản lý và Vận hành Dịch vụ Công nghệ Thông tin','5',NULL,'',''),
('BIT_IS_K20B','2734','7422','KMS301','Knowledge management system_Hệ thống quản trị tri thức','7',NULL,'',''),
('BIT_IS_K20B','2734','7423','DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định','7',NULL,'',''),
('BIT_IS_K20B','2734','7424','BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh','8',NULL,'',''),
('BIT_IS_K20B','2754','7505','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_IS_K20B','2754','7506','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_IS_K20B','2754','7507','BDI302c','Big Data_Dữ liệu lớn','7',NULL,'',''),
('BIT_IS_K20B','2754','7508','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_IS_K20C','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IS_K20C','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IS_K20C','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IS_K20C','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IS_K20C','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IS_K20C','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IS_K20C','2637','6998','ACC101','Principles of Accounting_Nguyên lý kế toán','5',NULL,'',''),
('BIT_IS_K20C','2637','6999','SAP311','SAP General 1 - Tổng quan về SAP 1','7',NULL,'',''),
('BIT_IS_K20C','2637','7000','SAP321','SAP General 2 - Tổng quan về SAP 2','7',NULL,'',''),
('BIT_IS_K20C','2637','7001','SAP341','SAP Application Development with ABAP_Phát triển ứng dụng SAP với ABAP','8',NULL,'',''),
('BIT_IS_K20C','2641','7017','SWR302','Software Requirement_Yêu cầu phần mềm','5',NULL,'',''),
('BIT_IS_K20C','2641','7018','MIS301','Management Information System_Hệ thống thông tin quản lý','7',NULL,'',''),
('BIT_IS_K20C','2641','7019','SWT301','Software Testing_Kiểm thử phần mềm','7',NULL,'',''),
('BIT_IS_K20C','2641','7020','AAT301','Agile and Automation Testing_Kiểm thử tự động và linh hoạt','8',NULL,'',''),
('BIT_IS_K20C','2634','6986','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_IS_K20C','2634','6987','AST301','Security Testing_Kiểm thử bảo mật','7',NULL,'',''),
('BIT_IS_K20C','2634','6988','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_IS_K20C','2634','6989','DSO392','DevSecOps for Information Systems_Tích hợp DevSecOps cho Hệ thống thông tin','8',NULL,'',''),
('BIT_IS_K20C','2734','7421','IMO301c','IT Service Management and Operations_Quản lý và Vận hành Dịch vụ Công nghệ Thông tin','5',NULL,'',''),
('BIT_IS_K20C','2734','7422','KMS301','Knowledge management system_Hệ thống quản trị tri thức','7',NULL,'',''),
('BIT_IS_K20C','2734','7423','DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định','7',NULL,'',''),
('BIT_IS_K20C','2734','7424','BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh','8',NULL,'',''),
('BIT_IS_K20C','2754','7505','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_IS_K20C','2754','7506','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_IS_K20C','2754','7507','BDI302c','Big Data_Dữ liệu lớn','7',NULL,'',''),
('BIT_IS_K20C','2754','7508','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_IS_K20D','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IS_K20D','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IS_K20D','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IS_K20D','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IS_K20D','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IS_K20D','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IS_K20D','2636','6994','FIN202','Principles of Corporate Finance_Tài chính doanh nghiệp','5',NULL,'',''),
('BIT_IS_K20D','2636','6995','KMS301','Knowledge management system_Hệ thống quản trị tri thức','7',NULL,'',''),
('BIT_IS_K20D','2636','6996','DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định','7',NULL,'',''),
('BIT_IS_K20D','2636','6997','BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh','8',NULL,'',''),
('BIT_IS_K20D','2637','6998','ACC101','Principles of Accounting_Nguyên lý kế toán','5',NULL,'',''),
('BIT_IS_K20D','2637','6999','SAP311','SAP General 1 - Tổng quan về SAP 1','7',NULL,'',''),
('BIT_IS_K20D','2637','7000','SAP321','SAP General 2 - Tổng quan về SAP 2','7',NULL,'',''),
('BIT_IS_K20D','2637','7001','SAP341','SAP Application Development with ABAP_Phát triển ứng dụng SAP với ABAP','8',NULL,'',''),
('BIT_IS_K20D','2641','7017','SWR302','Software Requirement_Yêu cầu phần mềm','5',NULL,'',''),
('BIT_IS_K20D','2641','7018','MIS301','Management Information System_Hệ thống thông tin quản lý','7',NULL,'',''),
('BIT_IS_K20D','2641','7019','SWT301','Software Testing_Kiểm thử phần mềm','7',NULL,'',''),
('BIT_IS_K20D','2641','7020','AAT301','Agile and Automation Testing_Kiểm thử tự động và linh hoạt','8',NULL,'',''),
('BIT_IS_K20D','2634','6986','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_IS_K20D','2634','6987','AST301','Security Testing_Kiểm thử bảo mật','7',NULL,'',''),
('BIT_IS_K20D','2634','6988','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_IS_K20D','2634','6989','DSO392','DevSecOps for Information Systems_Tích hợp DevSecOps cho Hệ thống thông tin','8',NULL,'',''),
('BIT_IS_K20D','2635','6990','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_IS_K20D','2635','6992','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_IS_K20D','2635','6993','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_IS_K20D','2635','7504','BDI301c','Big Data_Dữ liệu lớn','7',NULL,'',''),
('BIT_IS_K20D-21A','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_IS_K20D-21A','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_IS_K20D-21A','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_IS_K20D-21A','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_IS_K20D-21A','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_IS_K20D-21A','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_IS_K20D-21A','2636','6994','FIN202','Principles of Corporate Finance_Tài chính doanh nghiệp','5',NULL,'',''),
('BIT_IS_K20D-21A','2636','6995','KMS301','Knowledge management system_Hệ thống quản trị tri thức','7',NULL,'',''),
('BIT_IS_K20D-21A','2636','6996','DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định','7',NULL,'',''),
('BIT_IS_K20D-21A','2636','6997','BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh','8',NULL,'',''),
('BIT_IS_K20D-21A','2637','6998','ACC101','Principles of Accounting_Nguyên lý kế toán','5',NULL,'',''),
('BIT_IS_K20D-21A','2637','6999','SAP311','SAP General 1 - Tổng quan về SAP 1','7',NULL,'',''),
('BIT_IS_K20D-21A','2637','7000','SAP321','SAP General 2 - Tổng quan về SAP 2','7',NULL,'',''),
('BIT_IS_K20D-21A','2637','7001','SAP341','SAP Application Development with ABAP_Phát triển ứng dụng SAP với ABAP','8',NULL,'',''),
('BIT_IS_K20D-21A','2641','7017','SWR302','Software Requirement_Yêu cầu phần mềm','5',NULL,'',''),
('BIT_IS_K20D-21A','2641','7018','MIS301','Management Information System_Hệ thống thông tin quản lý','7',NULL,'',''),
('BIT_IS_K20D-21A','2641','7019','SWT301','Software Testing_Kiểm thử phần mềm','7',NULL,'',''),
('BIT_IS_K20D-21A','2641','7020','AAT301','Agile and Automation Testing_Kiểm thử tự động và linh hoạt','8',NULL,'',''),
('BIT_IS_K20D-21A','2634','6986','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_IS_K20D-21A','2634','6987','AST301','Security Testing_Kiểm thử bảo mật','7',NULL,'',''),
('BIT_IS_K20D-21A','2634','6988','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_IS_K20D-21A','2634','6989','DSO392','DevSecOps for Information Systems_Tích hợp DevSecOps cho Hệ thống thông tin','8',NULL,'',''),
('BIT_IS_K20D-21A','2635','6990','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_IS_K20D-21A','2635','6992','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_IS_K20D-21A','2635','6993','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_IS_K20D-21A','2635','7504','BDI301c','Big Data_Dữ liệu lớn','7',NULL,'',''),
('BIT_SE_K18D_19A','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_SE_K18D_19A','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_SE_K18D_19A','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_SE_K18D_19A','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_SE_K18D_19A','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_SE_K18D_19A','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_SE_K18D_19A','340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K18D_19A','340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K18D_19A','340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8',NULL,'',''),
('BIT_SE_K18D_19A','402','4760','KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1','7',NULL,'',''),
('BIT_SE_K18D_19A','402','4761','KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2','8',NULL,'',''),
('BIT_SE_K18D_19A','402','4762','KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3','8',NULL,'',''),
('BIT_SE_K18D_19A','1469','6206','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K18D_19A','1469','6207','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K18D_19A','1469','6208','JIS401','Tiếng Nhật CNTT trong ngành phần mềm','8',NULL,'',''),
('BIT_SE_K18D_19A','1469','6209','JIT401','Information Technology Japanese_Tiếng Nhật công nghệ thông tin','8',NULL,'',''),
('BIT_SE_K18D_19A','1469','6210','JFE301','Japanese IT Fundamentals_Kỹ năng CNTT cơ bản của Nhật Bản','8',NULL,'',''),
('BIT_SE_K18D_19A','2566','6661','PRP201c','Python Programming_Lập trình Python','5',NULL,'',''),
('BIT_SE_K18D_19A','2566','6662','DPL303m','Deep Learning_Học sâu','8',NULL,'',''),
('BIT_SE_K18D_19A','2566','6668','AIL304m','Machine Learning_Học máy','7',NULL,'',''),
('BIT_SE_K18D_19A','2566','6669','DBM301','Data mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_SE_K18D_19A','2553','6598','SAP311','SAP General 1 - Tổng quan về SAP 1','7',NULL,'',''),
('BIT_SE_K18D_19A','2553','6599','SAP321','SAP General 2 - Tổng quan về SAP 2','7',NULL,'',''),
('BIT_SE_K18D_19A','2553','6613','ACC101','Principles of Accounting_Nguyên lý kế toán','5',NULL,'',''),
('BIT_SE_K18D_19A','2553','6671','SAP341','SAP Application Development with ABAP_Phát triển ứng dụng SAP với ABAP','8',NULL,'',''),
('BIT_SE_K18D_19A','2497','6327','WDP301','Web Development Project_Dự án phát triển web','8',NULL,'',''),
('BIT_SE_K18D_19A','2497','6706','FER202','Front-End web development with React_Phát triển web Front-End với React','5',NULL,'',''),
('BIT_SE_K18D_19A','2497','6707','MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng','7',NULL,'',''),
('BIT_SE_K18D_19A','2497','6823','SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB','7',NULL,'',''),
('BIT_SE_K18D_19A','2605','6856','MIP201','Microcontroller Programming_Lập trình vi điều khiển','7',NULL,'',''),
('BIT_SE_K18D_19A','2605','6857','DCD301','Digital Circuit Design_Thiết kế vi mạch số','7',NULL,'',''),
('BIT_SE_K18D_19A','2605','6858','ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự','8',NULL,'',''),
('BIT_SE_K18D_19A','2605','6901','ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử','5',NULL,'',''),
('BIT_SE_K18D_19A','2640','7010','HSF302','Working with Spring Framework_Làm việc với Spring Framework','5',NULL,'',''),
('BIT_SE_K18D_19A','2640','7011','SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot','7',NULL,'',''),
('BIT_SE_K18D_19A','2640','7012','MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud','8',NULL,'',''),
('BIT_SE_K18D_19A','2638','7002','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_SE_K18D_19A','2638','7003','PRC392m','Cloud Computing_Điện toán đám mây','7',NULL,'',''),
('BIT_SE_K18D_19A','2638','7004','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_SE_K18D_19A','2638','7005','DSO391','DevSecOps for Cloud_Tích hợp DevSecOps cho Cloud','8',NULL,'',''),
('BIT_SE_K18D_19A','2628','6955','FGU301','Fundamental Game Development_Phát triển game cơ bản','5',NULL,'',''),
('BIT_SE_K18D_19A','2628','6956','AGU301','Advanced Game Development_Phát triển game nâng cao','7',NULL,'',''),
('BIT_SE_K18D_19A','2628','6957','GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện','7',NULL,'',''),
('BIT_SE_K18D_19A','2628','6958','GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao','8',NULL,'',''),
('BIT_SE_K18D_19A','2686','7219','PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET','5',NULL,'',''),
('BIT_SE_K18D_19A','2686','7220','PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET','7',NULL,'',''),
('BIT_SE_K18D_19A','2686','7221','PRU213','Game Programming with C#_Lập trình Game với C#','7',NULL,'',''),
('BIT_SE_K18D_19A','2686','7222','PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET','8',NULL,'',''),
('BIT_SE_K18D_19A','2639','7167','DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R','5',NULL,'',''),
('BIT_SE_K18D_19A','2639','7168','BDI302c','Big Data_Dữ liệu lớn','7',NULL,'',''),
('BIT_SE_K18D_19A','2639','7169','DBM302m','Data Mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_SE_K18D_19A','2639','7170','DSP391m','Data Science - Capstone Project_Dự án KHDL','8',NULL,'',''),
('BIT_SE_K19B','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_SE_K19B','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_SE_K19B','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_SE_K19B','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_SE_K19B','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_SE_K19B','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_SE_K19B','340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K19B','340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K19B','340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8',NULL,'',''),
('BIT_SE_K19B','402','4760','KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1','7',NULL,'',''),
('BIT_SE_K19B','402','4761','KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2','8',NULL,'',''),
('BIT_SE_K19B','402','4762','KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3','8',NULL,'',''),
('BIT_SE_K19B','1469','6206','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K19B','1469','6207','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K19B','1469','6208','JIS401','Tiếng Nhật CNTT trong ngành phần mềm','8',NULL,'',''),
('BIT_SE_K19B','1469','6209','JIT401','Information Technology Japanese_Tiếng Nhật công nghệ thông tin','8',NULL,'',''),
('BIT_SE_K19B','1469','6210','JFE301','Japanese IT Fundamentals_Kỹ năng CNTT cơ bản của Nhật Bản','8',NULL,'',''),
('BIT_SE_K19B','2566','6661','PRP201c','Python Programming_Lập trình Python','5',NULL,'',''),
('BIT_SE_K19B','2566','6662','DPL303m','Deep Learning_Học sâu','8',NULL,'',''),
('BIT_SE_K19B','2566','6668','AIL304m','Machine Learning_Học máy','7',NULL,'',''),
('BIT_SE_K19B','2566','6669','DBM301','Data mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_SE_K19B','2497','6327','WDP301','Web Development Project_Dự án phát triển web','8',NULL,'',''),
('BIT_SE_K19B','2497','6706','FER202','Front-End web development with React_Phát triển web Front-End với React','5',NULL,'',''),
('BIT_SE_K19B','2497','6707','MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng','7',NULL,'',''),
('BIT_SE_K19B','2497','6823','SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB','7',NULL,'',''),
('BIT_SE_K19B','2605','6856','MIP201','Microcontroller Programming_Lập trình vi điều khiển','7',NULL,'',''),
('BIT_SE_K19B','2605','6857','DCD301','Digital Circuit Design_Thiết kế vi mạch số','7',NULL,'',''),
('BIT_SE_K19B','2605','6858','ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự','8',NULL,'',''),
('BIT_SE_K19B','2605','6901','ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử','5',NULL,'',''),
('BIT_SE_K19B','2640','7010','HSF302','Working with Spring Framework_Làm việc với Spring Framework','5',NULL,'',''),
('BIT_SE_K19B','2640','7011','SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot','7',NULL,'',''),
('BIT_SE_K19B','2640','7012','MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud','8',NULL,'',''),
('BIT_SE_K19B','2638','7002','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_SE_K19B','2638','7003','PRC392m','Cloud Computing_Điện toán đám mây','7',NULL,'',''),
('BIT_SE_K19B','2638','7004','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_SE_K19B','2638','7005','DSO391','DevSecOps for Cloud_Tích hợp DevSecOps cho Cloud','8',NULL,'',''),
('BIT_SE_K19B','2628','6955','FGU301','Fundamental Game Development_Phát triển game cơ bản','5',NULL,'',''),
('BIT_SE_K19B','2628','6956','AGU301','Advanced Game Development_Phát triển game nâng cao','7',NULL,'',''),
('BIT_SE_K19B','2628','6957','GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện','7',NULL,'',''),
('BIT_SE_K19B','2628','6958','GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao','8',NULL,'',''),
('BIT_SE_K19B','2675','7175','PDS301m','Python for Applied Data Science_Lập trình Python cho khoa học dữ liệu ứng dụng','5',NULL,'',''),
('BIT_SE_K19B','2675','7176','DHV301','Data Handling and Visualization_Xử lý và Trực quan hóa Dữ liệu','7',NULL,'',''),
('BIT_SE_K19B','2675','7177','MDS301','Machine Learning in Data Science_Học máy trong khoa học dữ liệu','7',NULL,'',''),
('BIT_SE_K19B','2675','7178','BDT301','Big Data Technologies & Tools_Công cụ và kỹ thuật trên dữ liệu lớn.','8',NULL,'',''),
('BIT_SE_K19B','2686','7219','PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET','5',NULL,'',''),
('BIT_SE_K19B','2686','7220','PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET','7',NULL,'',''),
('BIT_SE_K19B','2686','7221','PRU213','Game Programming with C#_Lập trình Game với C#','7',NULL,'',''),
('BIT_SE_K19B','2686','7222','PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET','8',NULL,'',''),
('BIT_SE_K19C','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_SE_K19C','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_SE_K19C','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_SE_K19C','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_SE_K19C','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_SE_K19C','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_SE_K19C','340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K19C','340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K19C','340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8',NULL,'',''),
('BIT_SE_K19C','402','4760','KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1','7',NULL,'',''),
('BIT_SE_K19C','402','4761','KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2','8',NULL,'',''),
('BIT_SE_K19C','402','4762','KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3','8',NULL,'',''),
('BIT_SE_K19C','1469','6206','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K19C','1469','6207','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K19C','1469','6208','JIS401','Tiếng Nhật CNTT trong ngành phần mềm','8',NULL,'',''),
('BIT_SE_K19C','1469','6209','JIT401','Information Technology Japanese_Tiếng Nhật công nghệ thông tin','8',NULL,'',''),
('BIT_SE_K19C','1469','6210','JFE301','Japanese IT Fundamentals_Kỹ năng CNTT cơ bản của Nhật Bản','8',NULL,'',''),
('BIT_SE_K19C','2566','6661','PRP201c','Python Programming_Lập trình Python','5',NULL,'',''),
('BIT_SE_K19C','2566','6662','DPL303m','Deep Learning_Học sâu','8',NULL,'',''),
('BIT_SE_K19C','2566','6668','AIL304m','Machine Learning_Học máy','7',NULL,'',''),
('BIT_SE_K19C','2566','6669','DBM301','Data mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_SE_K19C','2497','6327','WDP301','Web Development Project_Dự án phát triển web','8',NULL,'',''),
('BIT_SE_K19C','2497','6706','FER202','Front-End web development with React_Phát triển web Front-End với React','5',NULL,'',''),
('BIT_SE_K19C','2497','6707','MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng','7',NULL,'',''),
('BIT_SE_K19C','2497','6823','SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB','7',NULL,'',''),
('BIT_SE_K19C','2605','6856','MIP201','Microcontroller Programming_Lập trình vi điều khiển','7',NULL,'',''),
('BIT_SE_K19C','2605','6857','DCD301','Digital Circuit Design_Thiết kế vi mạch số','7',NULL,'',''),
('BIT_SE_K19C','2605','6858','ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự','8',NULL,'',''),
('BIT_SE_K19C','2605','6901','ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử','5',NULL,'',''),
('BIT_SE_K19C','2640','7010','HSF302','Working with Spring Framework_Làm việc với Spring Framework','5',NULL,'',''),
('BIT_SE_K19C','2640','7011','SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot','7',NULL,'',''),
('BIT_SE_K19C','2640','7012','MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud','8',NULL,'',''),
('BIT_SE_K19C','2638','7002','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_SE_K19C','2638','7003','PRC392m','Cloud Computing_Điện toán đám mây','7',NULL,'',''),
('BIT_SE_K19C','2638','7004','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_SE_K19C','2638','7005','DSO391','DevSecOps for Cloud_Tích hợp DevSecOps cho Cloud','8',NULL,'','');
INSERT INTO st_members VALUES
('BIT_SE_K19C','2628','6955','FGU301','Fundamental Game Development_Phát triển game cơ bản','5',NULL,'',''),
('BIT_SE_K19C','2628','6956','AGU301','Advanced Game Development_Phát triển game nâng cao','7',NULL,'',''),
('BIT_SE_K19C','2628','6957','GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện','7',NULL,'',''),
('BIT_SE_K19C','2628','6958','GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao','8',NULL,'',''),
('BIT_SE_K19C','2675','7175','PDS301m','Python for Applied Data Science_Lập trình Python cho khoa học dữ liệu ứng dụng','5',NULL,'',''),
('BIT_SE_K19C','2675','7176','DHV301','Data Handling and Visualization_Xử lý và Trực quan hóa Dữ liệu','7',NULL,'',''),
('BIT_SE_K19C','2675','7177','MDS301','Machine Learning in Data Science_Học máy trong khoa học dữ liệu','7',NULL,'',''),
('BIT_SE_K19C','2675','7178','BDT301','Big Data Technologies & Tools_Công cụ và kỹ thuật trên dữ liệu lớn.','8',NULL,'',''),
('BIT_SE_K19C','2686','7219','PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET','5',NULL,'',''),
('BIT_SE_K19C','2686','7220','PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET','7',NULL,'',''),
('BIT_SE_K19C','2686','7221','PRU213','Game Programming with C#_Lập trình Game với C#','7',NULL,'',''),
('BIT_SE_K19C','2686','7222','PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET','8',NULL,'',''),
('BIT_SE_K19D_K20A','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_SE_K19D_K20A','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_SE_K19D_K20A','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_SE_K19D_K20A','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_SE_K19D_K20A','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_SE_K19D_K20A','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_SE_K19D_K20A','340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K19D_K20A','340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K19D_K20A','340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8',NULL,'',''),
('BIT_SE_K19D_K20A','402','4760','KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1','7',NULL,'',''),
('BIT_SE_K19D_K20A','402','4761','KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2','8',NULL,'',''),
('BIT_SE_K19D_K20A','402','4762','KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3','8',NULL,'',''),
('BIT_SE_K19D_K20A','1469','6206','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K19D_K20A','1469','6207','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K19D_K20A','1469','6208','JIS401','Tiếng Nhật CNTT trong ngành phần mềm','8',NULL,'',''),
('BIT_SE_K19D_K20A','1469','6209','JIT401','Information Technology Japanese_Tiếng Nhật công nghệ thông tin','8',NULL,'',''),
('BIT_SE_K19D_K20A','1469','6210','JFE301','Japanese IT Fundamentals_Kỹ năng CNTT cơ bản của Nhật Bản','8',NULL,'',''),
('BIT_SE_K19D_K20A','2566','6661','PRP201c','Python Programming_Lập trình Python','5',NULL,'',''),
('BIT_SE_K19D_K20A','2566','6662','DPL303m','Deep Learning_Học sâu','8',NULL,'',''),
('BIT_SE_K19D_K20A','2566','6668','AIL304m','Machine Learning_Học máy','7',NULL,'',''),
('BIT_SE_K19D_K20A','2566','6669','DBM301','Data mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_SE_K19D_K20A','2497','6327','WDP301','Web Development Project_Dự án phát triển web','8',NULL,'',''),
('BIT_SE_K19D_K20A','2497','6706','FER202','Front-End web development with React_Phát triển web Front-End với React','5',NULL,'',''),
('BIT_SE_K19D_K20A','2497','6707','MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng','7',NULL,'',''),
('BIT_SE_K19D_K20A','2497','6823','SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB','7',NULL,'',''),
('BIT_SE_K19D_K20A','2605','6856','MIP201','Microcontroller Programming_Lập trình vi điều khiển','7',NULL,'',''),
('BIT_SE_K19D_K20A','2605','6857','DCD301','Digital Circuit Design_Thiết kế vi mạch số','7',NULL,'',''),
('BIT_SE_K19D_K20A','2605','6858','ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự','8',NULL,'',''),
('BIT_SE_K19D_K20A','2605','6901','ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử','5',NULL,'',''),
('BIT_SE_K19D_K20A','2640','7010','HSF302','Working with Spring Framework_Làm việc với Spring Framework','5',NULL,'',''),
('BIT_SE_K19D_K20A','2640','7011','SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot','7',NULL,'',''),
('BIT_SE_K19D_K20A','2640','7012','MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud','8',NULL,'',''),
('BIT_SE_K19D_K20A','2638','7002','IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin','5',NULL,'',''),
('BIT_SE_K19D_K20A','2638','7003','PRC392m','Cloud Computing_Điện toán đám mây','7',NULL,'',''),
('BIT_SE_K19D_K20A','2638','7004','ASP301','Application Security_Bảo mật ứng dụng','7',NULL,'',''),
('BIT_SE_K19D_K20A','2638','7005','DSO391','DevSecOps for Cloud_Tích hợp DevSecOps cho Cloud','8',NULL,'',''),
('BIT_SE_K19D_K20A','2628','6955','FGU301','Fundamental Game Development_Phát triển game cơ bản','5',NULL,'',''),
('BIT_SE_K19D_K20A','2628','6956','AGU301','Advanced Game Development_Phát triển game nâng cao','7',NULL,'',''),
('BIT_SE_K19D_K20A','2628','6957','GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện','7',NULL,'',''),
('BIT_SE_K19D_K20A','2628','6958','GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao','8',NULL,'',''),
('BIT_SE_K19D_K20A','2675','7175','PDS301m','Python for Applied Data Science_Lập trình Python cho khoa học dữ liệu ứng dụng','5',NULL,'',''),
('BIT_SE_K19D_K20A','2675','7176','DHV301','Data Handling and Visualization_Xử lý và Trực quan hóa Dữ liệu','7',NULL,'',''),
('BIT_SE_K19D_K20A','2675','7177','MDS301','Machine Learning in Data Science_Học máy trong khoa học dữ liệu','7',NULL,'',''),
('BIT_SE_K19D_K20A','2675','7178','BDT301','Big Data Technologies & Tools_Công cụ và kỹ thuật trên dữ liệu lớn.','8',NULL,'',''),
('BIT_SE_K19D_K20A','2686','7219','PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET','5',NULL,'',''),
('BIT_SE_K19D_K20A','2686','7220','PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET','7',NULL,'',''),
('BIT_SE_K19D_K20A','2686','7221','PRU213','Game Programming with C#_Lập trình Game với C#','7',NULL,'',''),
('BIT_SE_K19D_K20A','2686','7222','PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET','8',NULL,'',''),
('BIT_SE_K20B','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_SE_K20B','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_SE_K20B','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_SE_K20B','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_SE_K20B','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_SE_K20B','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_SE_K20B','340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K20B','340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K20B','340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8',NULL,'',''),
('BIT_SE_K20B','402','4760','KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1','7',NULL,'',''),
('BIT_SE_K20B','402','4761','KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2','8',NULL,'',''),
('BIT_SE_K20B','402','4762','KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3','8',NULL,'',''),
('BIT_SE_K20B','1469','6206','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K20B','1469','6207','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K20B','1469','6208','JIS401','Tiếng Nhật CNTT trong ngành phần mềm','8',NULL,'',''),
('BIT_SE_K20B','1469','6209','JIT401','Information Technology Japanese_Tiếng Nhật công nghệ thông tin','8',NULL,'',''),
('BIT_SE_K20B','1469','6210','JFE301','Japanese IT Fundamentals_Kỹ năng CNTT cơ bản của Nhật Bản','8',NULL,'',''),
('BIT_SE_K20B','2566','6661','PRP201c','Python Programming_Lập trình Python','5',NULL,'',''),
('BIT_SE_K20B','2566','6662','DPL303m','Deep Learning_Học sâu','8',NULL,'',''),
('BIT_SE_K20B','2566','6668','AIL304m','Machine Learning_Học máy','7',NULL,'',''),
('BIT_SE_K20B','2566','6669','DBM301','Data mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_SE_K20B','2497','6327','WDP301','Web Development Project_Dự án phát triển web','8',NULL,'',''),
('BIT_SE_K20B','2497','6706','FER202','Front-End web development with React_Phát triển web Front-End với React','5',NULL,'',''),
('BIT_SE_K20B','2497','6707','MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng','7',NULL,'',''),
('BIT_SE_K20B','2497','6823','SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB','7',NULL,'',''),
('BIT_SE_K20B','2605','6856','MIP201','Microcontroller Programming_Lập trình vi điều khiển','7',NULL,'',''),
('BIT_SE_K20B','2605','6857','DCD301','Digital Circuit Design_Thiết kế vi mạch số','7',NULL,'',''),
('BIT_SE_K20B','2605','6858','ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự','8',NULL,'',''),
('BIT_SE_K20B','2605','6901','ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử','5',NULL,'',''),
('BIT_SE_K20B','2640','7010','HSF302','Working with Spring Framework_Làm việc với Spring Framework','5',NULL,'',''),
('BIT_SE_K20B','2640','7011','SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot','7',NULL,'',''),
('BIT_SE_K20B','2640','7012','MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud','8',NULL,'',''),
('BIT_SE_K20B','2628','6955','FGU301','Fundamental Game Development_Phát triển game cơ bản','5',NULL,'',''),
('BIT_SE_K20B','2628','6956','AGU301','Advanced Game Development_Phát triển game nâng cao','7',NULL,'',''),
('BIT_SE_K20B','2628','6957','GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện','7',NULL,'',''),
('BIT_SE_K20B','2628','6958','GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao','8',NULL,'',''),
('BIT_SE_K20B','2675','7175','PDS301m','Python for Applied Data Science_Lập trình Python cho khoa học dữ liệu ứng dụng','5',NULL,'',''),
('BIT_SE_K20B','2675','7176','DHV301','Data Handling and Visualization_Xử lý và Trực quan hóa Dữ liệu','7',NULL,'',''),
('BIT_SE_K20B','2675','7177','MDS301','Machine Learning in Data Science_Học máy trong khoa học dữ liệu','7',NULL,'',''),
('BIT_SE_K20B','2675','7178','BDT301','Big Data Technologies & Tools_Công cụ và kỹ thuật trên dữ liệu lớn.','8',NULL,'',''),
('BIT_SE_K20B','2686','7219','PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET','5',NULL,'',''),
('BIT_SE_K20B','2686','7220','PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET','7',NULL,'',''),
('BIT_SE_K20B','2686','7221','PRU213','Game Programming with C#_Lập trình Game với C#','7',NULL,'',''),
('BIT_SE_K20B','2686','7222','PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET','8',NULL,'',''),
('BIT_SE_K20C','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_SE_K20C','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_SE_K20C','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_SE_K20C','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_SE_K20C','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_SE_K20C','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_SE_K20C','340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K20C','340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K20C','340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8',NULL,'',''),
('BIT_SE_K20C','402','4760','KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1','7',NULL,'',''),
('BIT_SE_K20C','402','4761','KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2','8',NULL,'',''),
('BIT_SE_K20C','402','4762','KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3','8',NULL,'',''),
('BIT_SE_K20C','2566','6661','PRP201c','Python Programming_Lập trình Python','5',NULL,'',''),
('BIT_SE_K20C','2566','6662','DPL303m','Deep Learning_Học sâu','8',NULL,'',''),
('BIT_SE_K20C','2566','6668','AIL304m','Machine Learning_Học máy','7',NULL,'',''),
('BIT_SE_K20C','2566','6669','DBM301','Data mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_SE_K20C','2497','6327','WDP301','Web Development Project_Dự án phát triển web','8',NULL,'',''),
('BIT_SE_K20C','2497','6706','FER202','Front-End web development with React_Phát triển web Front-End với React','5',NULL,'',''),
('BIT_SE_K20C','2497','6707','MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng','7',NULL,'',''),
('BIT_SE_K20C','2497','6823','SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB','7',NULL,'',''),
('BIT_SE_K20C','2605','6856','MIP201','Microcontroller Programming_Lập trình vi điều khiển','7',NULL,'',''),
('BIT_SE_K20C','2605','6857','DCD301','Digital Circuit Design_Thiết kế vi mạch số','7',NULL,'',''),
('BIT_SE_K20C','2605','6858','ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự','8',NULL,'',''),
('BIT_SE_K20C','2605','6901','ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử','5',NULL,'',''),
('BIT_SE_K20C','2640','7010','HSF302','Working with Spring Framework_Làm việc với Spring Framework','5',NULL,'',''),
('BIT_SE_K20C','2640','7011','SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot','7',NULL,'',''),
('BIT_SE_K20C','2640','7012','MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud','8',NULL,'',''),
('BIT_SE_K20C','2628','6955','FGU301','Fundamental Game Development_Phát triển game cơ bản','5',NULL,'',''),
('BIT_SE_K20C','2628','6956','AGU301','Advanced Game Development_Phát triển game nâng cao','7',NULL,'',''),
('BIT_SE_K20C','2628','6957','GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện','7',NULL,'',''),
('BIT_SE_K20C','2628','6958','GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao','8',NULL,'',''),
('BIT_SE_K20C','2675','7175','PDS301m','Python for Applied Data Science_Lập trình Python cho khoa học dữ liệu ứng dụng','5',NULL,'',''),
('BIT_SE_K20C','2675','7176','DHV301','Data Handling and Visualization_Xử lý và Trực quan hóa Dữ liệu','7',NULL,'',''),
('BIT_SE_K20C','2675','7177','MDS301','Machine Learning in Data Science_Học máy trong khoa học dữ liệu','7',NULL,'',''),
('BIT_SE_K20C','2675','7178','BDT301','Big Data Technologies & Tools_Công cụ và kỹ thuật trên dữ liệu lớn.','8',NULL,'',''),
('BIT_SE_K20C','2686','7219','PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET','5',NULL,'',''),
('BIT_SE_K20C','2686','7220','PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET','7',NULL,'',''),
('BIT_SE_K20C','2686','7221','PRU213','Game Programming with C#_Lập trình Game với C#','7',NULL,'',''),
('BIT_SE_K20C','2686','7222','PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET','8',NULL,'',''),
('BIT_SE_K20D_K21A','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_SE_K20D_K21A','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_SE_K20D_K21A','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_SE_K20D_K21A','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_SE_K20D_K21A','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_SE_K20D_K21A','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_SE_K20D_K21A','340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K20D_K21A','340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K20D_K21A','340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8',NULL,'',''),
('BIT_SE_K20D_K21A','402','4760','KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1','7',NULL,'',''),
('BIT_SE_K20D_K21A','402','4761','KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2','8',NULL,'',''),
('BIT_SE_K20D_K21A','402','4762','KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3','8',NULL,'',''),
('BIT_SE_K20D_K21A','2566','6661','PRP201c','Python Programming_Lập trình Python','5',NULL,'',''),
('BIT_SE_K20D_K21A','2566','6662','DPL303m','Deep Learning_Học sâu','8',NULL,'',''),
('BIT_SE_K20D_K21A','2566','6668','AIL304m','Machine Learning_Học máy','7',NULL,'',''),
('BIT_SE_K20D_K21A','2566','6669','DBM301','Data mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_SE_K20D_K21A','2497','6327','WDP301','Web Development Project_Dự án phát triển web','8',NULL,'',''),
('BIT_SE_K20D_K21A','2497','6706','FER202','Front-End web development with React_Phát triển web Front-End với React','5',NULL,'',''),
('BIT_SE_K20D_K21A','2497','6707','MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng','7',NULL,'',''),
('BIT_SE_K20D_K21A','2497','6823','SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB','7',NULL,'',''),
('BIT_SE_K20D_K21A','2605','6856','MIP201','Microcontroller Programming_Lập trình vi điều khiển','7',NULL,'',''),
('BIT_SE_K20D_K21A','2605','6857','DCD301','Digital Circuit Design_Thiết kế vi mạch số','7',NULL,'',''),
('BIT_SE_K20D_K21A','2605','6858','ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự','8',NULL,'',''),
('BIT_SE_K20D_K21A','2605','6901','ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử','5',NULL,'',''),
('BIT_SE_K20D_K21A','2640','7010','HSF302','Working with Spring Framework_Làm việc với Spring Framework','5',NULL,'',''),
('BIT_SE_K20D_K21A','2640','7011','SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot','7',NULL,'',''),
('BIT_SE_K20D_K21A','2640','7012','MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud','8',NULL,'',''),
('BIT_SE_K20D_K21A','2628','6955','FGU301','Fundamental Game Development_Phát triển game cơ bản','5',NULL,'',''),
('BIT_SE_K20D_K21A','2628','6956','AGU301','Advanced Game Development_Phát triển game nâng cao','7',NULL,'',''),
('BIT_SE_K20D_K21A','2628','6957','GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện','7',NULL,'',''),
('BIT_SE_K20D_K21A','2628','6958','GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao','8',NULL,'',''),
('BIT_SE_K20D_K21A','2675','7175','PDS301m','Python for Applied Data Science_Lập trình Python cho khoa học dữ liệu ứng dụng','5',NULL,'',''),
('BIT_SE_K20D_K21A','2675','7176','DHV301','Data Handling and Visualization_Xử lý và Trực quan hóa Dữ liệu','7',NULL,'',''),
('BIT_SE_K20D_K21A','2675','7177','MDS301','Machine Learning in Data Science_Học máy trong khoa học dữ liệu','7',NULL,'',''),
('BIT_SE_K20D_K21A','2675','7178','BDT301','Big Data Technologies & Tools_Công cụ và kỹ thuật trên dữ liệu lớn.','8',NULL,'',''),
('BIT_SE_K20D_K21A','2686','7219','PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET','5',NULL,'',''),
('BIT_SE_K20D_K21A','2686','7220','PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET','7',NULL,'',''),
('BIT_SE_K20D_K21A','2686','7221','PRU213','Game Programming with C#_Lập trình Game với C#','7',NULL,'',''),
('BIT_SE_K20D_K21A','2686','7222','PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET','8',NULL,'',''),
('BIT_SE_K21B','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_SE_K21B','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_SE_K21B','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_SE_K21B','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_SE_K21B','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_SE_K21B','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_SE_K21B','340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K21B','340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K21B','340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8',NULL,'',''),
('BIT_SE_K21B','402','4760','KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1','7',NULL,'',''),
('BIT_SE_K21B','402','4761','KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2','8',NULL,'',''),
('BIT_SE_K21B','402','4762','KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3','8',NULL,'',''),
('BIT_SE_K21B','2566','6661','PRP201c','Python Programming_Lập trình Python','5',NULL,'',''),
('BIT_SE_K21B','2566','6662','DPL303m','Deep Learning_Học sâu','8',NULL,'',''),
('BIT_SE_K21B','2566','6668','AIL304m','Machine Learning_Học máy','7',NULL,'',''),
('BIT_SE_K21B','2566','6669','DBM301','Data mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_SE_K21B','2497','6327','WDP301','Web Development Project_Dự án phát triển web','8',NULL,'',''),
('BIT_SE_K21B','2497','6706','FER202','Front-End web development with React_Phát triển web Front-End với React','5',NULL,'',''),
('BIT_SE_K21B','2497','6707','MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng','7',NULL,'',''),
('BIT_SE_K21B','2497','6823','SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB','7',NULL,'',''),
('BIT_SE_K21B','2605','6856','MIP201','Microcontroller Programming_Lập trình vi điều khiển','7',NULL,'',''),
('BIT_SE_K21B','2605','6857','DCD301','Digital Circuit Design_Thiết kế vi mạch số','7',NULL,'',''),
('BIT_SE_K21B','2605','6858','ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự','8',NULL,'',''),
('BIT_SE_K21B','2605','6901','ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử','5',NULL,'',''),
('BIT_SE_K21B','2640','7010','HSF302','Working with Spring Framework_Làm việc với Spring Framework','5',NULL,'',''),
('BIT_SE_K21B','2640','7011','SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot','7',NULL,'',''),
('BIT_SE_K21B','2640','7012','MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud','8',NULL,'',''),
('BIT_SE_K21B','2628','6955','FGU301','Fundamental Game Development_Phát triển game cơ bản','5',NULL,'',''),
('BIT_SE_K21B','2628','6956','AGU301','Advanced Game Development_Phát triển game nâng cao','7',NULL,'',''),
('BIT_SE_K21B','2628','6957','GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện','7',NULL,'',''),
('BIT_SE_K21B','2628','6958','GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao','8',NULL,'',''),
('BIT_SE_K21B','2675','7175','PDS301m','Python for Applied Data Science_Lập trình Python cho khoa học dữ liệu ứng dụng','5',NULL,'',''),
('BIT_SE_K21B','2675','7176','DHV301','Data Handling and Visualization_Xử lý và Trực quan hóa Dữ liệu','7',NULL,'',''),
('BIT_SE_K21B','2675','7177','MDS301','Machine Learning in Data Science_Học máy trong khoa học dữ liệu','7',NULL,'',''),
('BIT_SE_K21B','2675','7178','BDT301','Big Data Technologies & Tools_Công cụ và kỹ thuật trên dữ liệu lớn.','8',NULL,'',''),
('BIT_SE_K21B','2686','7219','PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET','5',NULL,'',''),
('BIT_SE_K21B','2686','7220','PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET','7',NULL,'',''),
('BIT_SE_K21B','2686','7221','PRU213','Game Programming with C#_Lập trình Game với C#','7',NULL,'',''),
('BIT_SE_K21B','2686','7222','PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET','8',NULL,'',''),
('BIT_SE_K21C','26','82','VOV114','Vovinam 1','0',NULL,'',''),
('BIT_SE_K21C','26','83','VOV124','Vovinam 2','1',NULL,'',''),
('BIT_SE_K21C','26','84','VOV134','Vovinam 3','2',NULL,'',''),
('BIT_SE_K21C','334','1398','COV111','Cờ Vua 1','0',NULL,'',''),
('BIT_SE_K21C','334','1399','COV121','Cờ Vua 2','1',NULL,'',''),
('BIT_SE_K21C','334','1400','COV131','Cờ Vua 3','2',NULL,'',''),
('BIT_SE_K21C','340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE_K21C','340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE_K21C','340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8',NULL,'',''),
('BIT_SE_K21C','402','4760','KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1','7',NULL,'',''),
('BIT_SE_K21C','402','4761','KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2','8',NULL,'',''),
('BIT_SE_K21C','402','4762','KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3','8',NULL,'',''),
('BIT_SE_K21C','2566','6661','PRP201c','Python Programming_Lập trình Python','5',NULL,'',''),
('BIT_SE_K21C','2566','6662','DPL303m','Deep Learning_Học sâu','8',NULL,'',''),
('BIT_SE_K21C','2566','6668','AIL304m','Machine Learning_Học máy','7',NULL,'',''),
('BIT_SE_K21C','2566','6669','DBM301','Data mining_Khai phá dữ liệu','7',NULL,'',''),
('BIT_SE_K21C','2497','6327','WDP301','Web Development Project_Dự án phát triển web','8',NULL,'',''),
('BIT_SE_K21C','2497','6706','FER202','Front-End web development with React_Phát triển web Front-End với React','5',NULL,'',''),
('BIT_SE_K21C','2497','6707','MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng','7',NULL,'',''),
('BIT_SE_K21C','2497','6823','SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB','7',NULL,'',''),
('BIT_SE_K21C','2605','6856','MIP201','Microcontroller Programming_Lập trình vi điều khiển','7',NULL,'',''),
('BIT_SE_K21C','2605','6857','DCD301','Digital Circuit Design_Thiết kế vi mạch số','7',NULL,'',''),
('BIT_SE_K21C','2605','6858','ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự','8',NULL,'',''),
('BIT_SE_K21C','2605','6901','ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử','5',NULL,'',''),
('BIT_SE_K21C','2640','7010','HSF302','Working with Spring Framework_Làm việc với Spring Framework','5',NULL,'',''),
('BIT_SE_K21C','2640','7011','SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot','7',NULL,'',''),
('BIT_SE_K21C','2640','7012','MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud','8',NULL,'',''),
('BIT_SE_K21C','2628','6955','FGU301','Fundamental Game Development_Phát triển game cơ bản','5',NULL,'',''),
('BIT_SE_K21C','2628','6956','AGU301','Advanced Game Development_Phát triển game nâng cao','7',NULL,'','');
INSERT INTO st_members VALUES
('BIT_SE_K21C','2628','6957','GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện','7',NULL,'',''),
('BIT_SE_K21C','2628','6958','GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao','8',NULL,'',''),
('BIT_SE_K21C','2675','7175','PDS301m','Python for Applied Data Science_Lập trình Python cho khoa học dữ liệu ứng dụng','5',NULL,'',''),
('BIT_SE_K21C','2675','7176','DHV301','Data Handling and Visualization_Xử lý và Trực quan hóa Dữ liệu','7',NULL,'',''),
('BIT_SE_K21C','2675','7177','MDS301','Machine Learning in Data Science_Học máy trong khoa học dữ liệu','7',NULL,'',''),
('BIT_SE_K21C','2675','7178','BDT301','Big Data Technologies & Tools_Công cụ và kỹ thuật trên dữ liệu lớn.','8',NULL,'',''),
('BIT_SE_K21C','2686','7219','PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET','5',NULL,'',''),
('BIT_SE_K21C','2686','7220','PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET','7',NULL,'',''),
('BIT_SE_K21C','2686','7221','PRU213','Game Programming with C#_Lập trình Game với C#','7',NULL,'',''),
('BIT_SE_K21C','2686','7222','PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET','8',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2746','7471','AQA301','Agile Software Quality Assurance_Đảm bảo chất lượng phần mềm theo Agile','5',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2746','7472','SQA301','AI-based System Quality Assurance_Đảm bảo chất lượng hệ thống dựa trên AI','7',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2746','7473','TAI301','Testing with Generative AI_Kiểm thử với AI tạo sinh','7',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2746','7474','QCT301','Quality Characteristics Testing_Kiểm thử các đặc tính chất lượng','8',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2747','7475','ALF301','AI, LLMs & GenAI Foundation_Cơ sở AI, LLM và AI tạo sinh','5',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2747','7476','LLA301','LLM Application Engineering_Kỹ thuật phát triển ứng dụng với LLM','7',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2747','7477','EIA301','Embeddings and Intelligent Applications_Nhúng dữ liệu và Ứng dụng Thông minh','7',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2747','7478','EAS301','Enterprise AI Systems_Hệ thống AI cho Doanh nghiệp','8',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2748','7479','BPE301','Business Analysis Planning & Elicitation with Generative AI_Lập kế hoạch và Thu thập Yêu cầu Kinh doanh với AI tạo sinh','5',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2748','7480','SLM301','AI-Augmented Software Requirements Life Cycle Management_Quản lý vòng đời yêu cầu phần mềm được tăng cường bằng AI','7',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2748','7481','SDS301','Strategy Analysis & Decision Support with AI_Phân tích chiến lược và Hỗ trợ quyết định với AI','7',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2748','7482','EDO301','Solution Evaluation, Delivery & Operations with AI_Đánh giá, Triển khai và Vận hành Giải pháp với AI','8',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2749','7483','EFD301','Enterprise Fullstack Application Development (with Java)_Phát triển ứng dụng Fullstack doanh nghiệp (với Java)','5',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2749','7484','EMD301','Enterprise Microservices Architecture & Development (with Java)_Kiến trúc và Phát triển Microservices doanh nghiệp (với Java)','7',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2749','7485','BSS301','AI-Augmented Backend Systems & Intelligent Services_Hệ thống Backend và Dịch vụ Thông minh được tăng cường bằng AI','7',NULL,'',''),
('BIT_SE-2026_K21D_K22A','2749','7486','DDP301','Software Delivery, DevOps & Platform Engineering_Triển khai Phần mềm, DevOps và Kỹ thuật Nền tảng','8',NULL,'',''),
('BIT_SE-2026_K21D_K22A','340','1426','JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2','5',NULL,'',''),
('BIT_SE-2026_K21D_K22A','340','1427','JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2','7',NULL,'',''),
('BIT_SE-2026_K21D_K22A','340','1428','JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1','8',NULL,'','');
INSERT INTO st_catalog VALUES
('OTP101','Orientation and General Training Program_Định hướng và Rèn luyện tập trung'),
('PEN','Preparation English_Tiếng Anh chuẩn bị'),
('PHE_COM*1','Physical Education 1_Giáo dục thể chất 1'),
('TMI_ELE','Traditional musical instrument_Nhạc cụ truyền thống'),
('CSI105','Introduction to Computer Science_Nhập môn khoa học máy tính'),
('MAD101','Discrete mathematics_Toán rời rạc'),
('MAE101','Mathematics for Engineering_Toán cho ngành kỹ thuật'),
('PFP191','Programming Fundamentals with Python_Cơ sở lập trình với Python'),
('PHE_COM*2','Physical Education 2_Giáo dục thể chất 2'),
('SSL101c','Academic Skills for University Success_Kỹ năng học tập đại học'),
('AIG202c','Artificial Intelligence_Trí tuệ nhân tạo'),
('CEA201','Computer Organization and Architecture_Tổ chức và Kiến trúc máy tính'),
('CSD203','Data Structures and Algorithm with Python_Cấu trúc dữ liệu và giải thuật với Python'),
('DBI202','Introduction to Databases_Các hệ cơ sở dữ liệu'),
('PHE_COM*3','Physical Education 3_Giáo dục thể chất 3'),
('SSG104','Communication and In-Group Working Skills_Kỹ năng giao tiếp và cộng tác'),
('ADY201m','AI, DS with Python & SQL_TTNT và KHDL với Python và SQL'),
('ITE303c','Ethics in IT_Đạo đức trong CNTT'),
('JPD113','Elementary Japanese 1- A1.1_Tiếng Nhật sơ cấp 1-A1.1'),
('MAI391','Mathematics for Machine Learning_Toán cho học máy'),
('MAS291','Statistics & Probability_Xác suất thống kê'),
('AIL303m','Machine Learning_Học máy'),
('CPV301','Computer Vision_Thị giác máy tính'),
('DAP391m','AI-DS Project_Dự án TTNT-KHDL'),
('JPD123','Elementary Japanese 1-A1.2_Tiếng Nhật sơ cấp 1-A1.2'),
('SWE201c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm'),
('AI17_COM*1','Subject 1 of Combo*_Học phần 1 của combo*'),
('AI17_COM*2','Subject 2 of Combo*_Học phần 2 của combo*'),
('DPL302m','Deep Learning_Học sâu'),
('DWP301c','Web Development with Python_Phát triển Web với Python'),
('NLP301c','Natural Language Processing_Xử lý ngôn ngữ tự nhiên'),
('OJT202','On-The-Job Training_Đào tạo trong môi trường thực tế'),
('AI17_COM*3','Subject 3 of Combo*_Học phần 3 của combo*'),
('DAT301m','AI Development with TensorFlow_Phát triển UDTTNT với TensorFlow'),
('ENW493c','Research Methods & Academic Writing Skills_Phương pháp nghiên cứu & Kỹ năng viết học thuật'),
('EXE101','Experiential Entrepreneurship 1_Trải nghiệm khởi nghiệp 1'),
('PMG201c','Project Management'),
('AI17_COM*4','Subject 4 of Combo*_Học phần 4 của combo*'),
('AID301c','AI in Production_Thiết kế sản phẩm TTNT'),
('EXE201','Experiential Entrepreneurship 2_Trải nghiệm khởi nghiệp 2'),
('MLN111','Philosophy of Marxism – Leninism_Triết học Mác - Lê-nin'),
('MLN122','Political economics of Marxism – Leninism_Kinh tế chính trị Mác - Lê-nin'),
('REL301m','Reinforcement Learning_Học tăng cường'),
('AI17_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Trí Tuệ Nhân Tạo'),
('HCM202','Ho Chi Minh Ideology_Tư tưởng Hồ Chí Minh'),
('MLN131','Scientific socialism_Chủ nghĩa xã hội khoa học'),
('VNR202','History of Communist Party of Vietnam_Lịch sử Đảng Cộng sản Việt Nam'),
('AIG201c','Artificial Intelligence_Trí tuệ nhân tạo'),
('ENW492c','Academic Writing Skills_Kỹ năng viết học thuật'),
('CSI106','Introduction to Computer Science_Nhập môn khoa học máy tính'),
('SSG105','Kỹ năng giao tiếp và cộng tác'),
('NLP301m','Natural Language Processing_Xử lý ngôn ngữ tự nhiên'),
('SSA101','Kỹ năng học thuật'),
('HMR101c','Human rights_Quyền con người'),
('MAC103','Calculus_Giải tích'),
('MAA102','Linear Algebra_Đại số tuyến tính'),
('CSI104','Introduction to Computer_Nhập môn khoa học máy tính'),
('PRF192','Programming Fundamentals_Cơ sở lập trình'),
('NWC204','Computer Networking_Mạng máy tính'),
('OSG202','Operating Systems_Hệ điều hành'),
('PRO192','Object-Oriented Programming_Lập trình hướng đối tượng'),
('CSD201','Data Structures and Algorithms_Cấu trúc dữ liệu và giải thuật'),
('IA_ELE2','IA Elective 2_IA Học phần lựa chọn 2'),
('LAB211','OOP with Java Lab_Thực hành OOP với Java'),
('IOT102','Internet of Things_Internet vạn vật'),
('ITE302c','Ethics in IT_Đạo đức trong CNTT'),
('OSP201','Open Source Platform and Network Administration_Hệ thống nguồn mở và quản trị mạng'),
('CRY303c','Applied Cryptography_Mật mã ứng dụng'),
('FRS301','Digital Forensics_Điều tra số'),
('IA_ELE3','IA Elective 3_IA Học phần lựa chọn 3'),
('IAA202','Risk Management in Information Systems_Quản trị rủi ro trong hệ thống thông tin'),
('IAM302','Malware Analysis and Reverse Engineering_Phân tích mã độc và kỹ thuật dịch ngược'),
('HOD402','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ'),
('IA_COM*1','Subject 1 of Combo*_Học phần 1 của combo*'),
('IA_COM*2','Subject 2 of Combo*_Học phần 2 của combo*'),
('IAP301','Policy Development in Information Assurance_Phát triển chính sách an toàn thông tin'),
('IA_COM*3','Subject 3 of Combo*_Học phần 3 của combo*'),
('IA_COM*4_ELE','Học phần thứ 4 của Combo IA'),
('IA_GRA_ELE','Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành An Toàn Thông Tin_Graduation Elective for IA'),
('HOD401','Ethical Hacking and Offensive Security_Thâm nhập thử và phòng thủ'),
('APO201c','Advanced Python with OOP_Lập trình hướng đối tượng với Python'),
('OSG20x','Operating System_Hệ điều hành'),
('NWC303','Network Connectivity_Kết nối mạng'),
('AIC211','AI for Cybersecurity_Tri tuệ nhân tạo cho An ninh mạng'),
('PWD301','Python Web Development_Phát triển Web với Python'),
('IA_COM*4','Subject 4 of Combo*_Học phần 4 của combo*'),
('OSG203','Operating System_Hệ điều hành'),
('ITA203c','Information System Overview/Nhập môn hệ thống thông tin'),
('PRC392c','Cloud Computing_Điện toán đám mây'),
('PRJ302','Java Web Application Development_Phát triển ứng dụng Java web'),
('IS_COM*1','Subject 1 of Combo*_Học phần 1 của combo*'),
('ISM302','Enterprise Resource Planning (ERP)_Lập kế hoạch nguồn lực doanh nghiệp'),
('ISP392','Information System Programming Project_Dự án lập trình HTTT'),
('ITA301','Information System Design & Analysis_Phân tích thiết kế HTTT'),
('IS_COM*2','Subject 2 of Combo*_Học phần 2 của combo*'),
('IS_COM*3','Subject 3 of Combo*_Học phần 3 của combo*'),
('ISC301','e-Commerce_Thương mại điện tử'),
('ITB302c','Business Intelligence (BI)_Kinh doanh thông minh'),
('DTA301','Data Analysis_Phân tích dữ liệu'),
('IS_COM*4','Subject 4 of Combo*_Học phần 4 của combo*'),
('IS_GRA_ELE','Graduation Elective - Information System_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Hệ thống thông tin'),
('WED201c','Web Design_Thiết kế web'),
('PRJ301','Java Web Application Development_Phát triển ứng dụng Java web'),
('SE_COM*1','Subject 1 of Combo*_Học phần 1 của combo*'),
('SWP391','Software development project_Dự án phát triển phần mềm'),
('SWR302','Software Requirement_Yêu cầu phần mềm'),
('SWT301','Software Testing_Kiểm thử phần mềm'),
('WDU203c','UI/UX Design_Thiết kế trải nghiệm người dùng'),
('SE_COM*2','Subject 2 of Combo*_Học phần 2 của combo*'),
('SE_COM*3','Subject 3 of Combo*_Học phần 3 của combo*'),
('SWD392','Software Architecture and Design_Kiến trúc và thiết kế phần mềm'),
('PRM393','Mobile Programming_Lập trình di động'),
('SE_COM*4_ELE','Học phần 4 của combo SE'),
('SE_GRA_ELE','Graduation Elective - Software Engineering_Học phần lựa chọn Đồ án tốt nghiệp chuyên ngành Kỹ thuật phần mềm'),
('SWE202c','Introduction to Software Engineering_Nhập môn kĩ thuật phần mềm'),
('SE_COM*4','Subject 4 of Combo*_Học phần 4 của combo*'),
('PPJ101','Programming Principles with Java_Nguyên lý lập trình với Java'),
('SWE204','Nhập môn kỹ thuật phần mềm_Introduction to Software Engineering'),
('PDD291','Lập trình Python cho hệ thống hướng dữ liệu_Python for Data-Driven Systems'),
('POP201','Giải quyết vấn đề với Lập trình hướng đối tượng_Problem Solving with OOP'),
('SIF201','System Infrastructure Fundamentals_Cơ sở Hạ tầng Hệ thống'),
('DBI203','Các hệ cơ sở dữ liệu _Introduction to Databases'),
('UID201c','Thiết kế UI/UX và Nguyên lý Front-end_UI/UX Design & Front-end principles'),
('AIL304m','Machine Learning_Học máy'),
('NLP201','Xử lý Ngôn ngữ Tự nhiên Cơ bản_ Fundamental NLP'),
('PGI201c','Nhập môn Tính toán song song và Lập trình GPU_Introduction to Parallel Computing and GPU Programming'),
('SAD301','Server-Side Application Development_Phát triển Hệ thống Web phía Máy chủ'),
('SWR303','Yêu cầu phần mềm tăng cường bằng AI_AI-Augmented Software Requirement'),
('ASP391','Dự án phát triển ứng dụng tích hợp AI_Application Development Project with AI Integration'),
('LGA301c','Mô hình Ngôn ngữ Lớn (LLM) và AI Tạo sinh_LLM & Generative AI'),
('SE-2026_COM*1','SE-2026_COM*1'),
('SWT302','Kiểm thử phần mềm tăng cường bằng AI_AI-augmented Software Testing'),
('SE-2026_COM*2','SE-2026_COM*2'),
('SE-2026_COM*3','SE-2026_COM*3'),
('SWD393','Software Architecture and Design_Kiến trúc và thiết kế phần mềm'),
('ASL391','Vòng đời phần mềm AI: MLOps, LLMOps và Kỹ thuật An toàn – Bảo mật_AI Software Lifecycle: MLOps, LLMOps, Safety & Secure Engineering'),
('SE-2026_COM*4','SE-2026_COM*4'),
('VOV114','Vovinam 1'),
('VOV124','Vovinam 2'),
('VOV134','Vovinam 3'),
('COV111','Cờ Vua 1'),
('COV121','Cờ Vua 2'),
('COV131','Cờ Vua 3'),
('DSR301m','Applied DS with R_Khoa học dữ liệu ứng dụng với R'),
('BDI302c','Big Data_Dữ liệu lớn'),
('DBM302m','Data Mining_Khai phá dữ liệu'),
('DSP391m','Data Science - Capstone Project_Dự án KHDL'),
('ASR301c','AI for Scientific Research_TTNT cho Nghiên cứu khoa học'),
('AIH301m','AI in Healthcare_Ứng dụng TTNT trong chăm sóc sức khỏe'),
('AIM301m','AI for Medicine_Ứng dụng TTNT cho y học'),
('AIE301m','AI for Trading_Ứng dụng TTNT cho giao dịch'),
('SEG301','Search Engines_Công cụ tìm kiếm'),
('TMG301','Text Mining_Khai thác văn bản'),
('SLP301','Speech Processing_Xử lý tiếng nói'),
('IMP302','Image and Video processing_Xử lý hình ảnh và video'),
('SEG301m','Search Engines_Công cụ tìm kiếm'),
('TMG301m','Text Mining_Khai thác văn bản'),
('SLP301m','Speech Processing_Xử lý tiếng nói'),
('IMP302m','Image & Video processing_Xử lý hình ảnh và video'),
('GAI201m','Introduction to Generative AI_Nhập môn TTNT tạo sinh'),
('MGA301','Multimodal AI_TTNT đa phương thức'),
('AGA301c','Advanced Generative AI_TTNT tạo sinh nâng cao'),
('GAP301','GenAI Project_Dự án TTNT tạo sinh'),
('MOI201m','Introduction to MLOps_Nhập môn hoạt động học máy'),
('CMO301m','Cloud for MLOps_Cloud cho hoạt động học máy'),
('AIS301c','AI for Cybersecurity_TTNT cho an ninh mạng'),
('AMO301m','Advanced MLOps_Hoạt động học máy nâng cao'),
('DBS401','Database Security_An ninh cơ sở dữ liệu'),
('FRS401c','Network Forensics_Điều tra mạng'),
('IAR401c','Incident Response_Đối phó sự cố'),
('IAW301','Web security_An ninh Web'),
('CES202','System Support and Trouble Shooting_Hỗ trợ hệ thống và khắc phục sự cố'),
('DMS401','Applied Data Mining for Information Assurance_Ứng dụng khai phá dữ liệu trong an toàn thông tin'),
('SPM401','Security Project Management_Quản trị dự án an toàn thông tin'),
('SDL201','Secure Software Development Lifecycle_Vòng đời Phát triển Phần mềm an toàn'),
('ASE201','Application Security Evaluation_Đánh giá bảo mật ứng dụng'),
('ADD301','Application Security Design and Development_Thiết kế và phát triển bảo mật ứng dụng'),
('DSO301','DevSecOps_Tích hợp DevSecOps'),
('NSA201','Enterprise Networking, Security, and Automation_Mạng Doanh nghiệp, An ninh và Tự động hóa'),
('NSR201','Network Security_An ninh mạng'),
('IIR301c','Network Incident Investigation and Response_Điều tra và Ứng phó sự cố An ninh Mạng'),
('COA301','Cybersecurity Operations and Analysis_Vận hành và Phân tích An ninh Mạng'),
('AML201','Introduction to Artificial Intelligence and Machine Learning_Nhập môn Trí tuệ Nhân tạo và Học máy'),
('CDA201','Foundations of Cybersecurity and Data Analyst_Nền tảng An ninh mạng và Phân tích Dữ liệu'),
('MLC301','Machine Learning Applications in Cyber Security'),
('AAC301','Advanced Topics in AI for Cyber Security_Nâng cao về TTNT trong An ninh mạng'),
('FIN202','Principles of Corporate Finance_Tài chính doanh nghiệp'),
('KMS301','Knowledge management system_Hệ thống quản trị tri thức'),
('DSS301','Decision Support Systems_Hệ thống hỗ trợ ra quyết định'),
('BPS301','Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh'),
('ACC101','Principles of Accounting_Nguyên lý kế toán'),
('SAP311','SAP General 1 - Tổng quan về SAP 1'),
('SAP321','SAP General 2 - Tổng quan về SAP 2'),
('SAP341','SAP Application Development with ABAP_Phát triển ứng dụng SAP với ABAP'),
('MIS301','Management Information System_Hệ thống thông tin quản lý'),
('AAT301','Agile and Automation Testing_Kiểm thử tự động và linh hoạt'),
('IAO201c','Introduction to Information Assurance_Nhập môn an toàn thông tin'),
('AST301','Security Testing_Kiểm thử bảo mật'),
('ASP301','Application Security_Bảo mật ứng dụng'),
('DSO392','DevSecOps for Information Systems_Tích hợp DevSecOps cho Hệ thống thông tin'),
('BDI301c','Big Data_Dữ liệu lớn'),
('IMO301c','IT Service Management and Operations_Quản lý và Vận hành Dịch vụ Công nghệ Thông tin'),
('JPD133','Elementary Japanese 1-A1/A2_Tiếng Nhật sơ cấp 1-A1/A2'),
('JPD316','Intermediate Japanese 1-B1/B2_ Tiếng Nhật trung cấp 1-B1/B2'),
('JPD326','Intermediate Japanese 2-B2.1_ Tiếng Nhật trung cấp 2-B2.1'),
('KOR311','Intermediate Korean Language 1_Hàn ngữ trung cấp 1'),
('KOR321','Intermediate Korean Language 2_Hàn ngữ trung cấp 2'),
('KOR411','Intermediate Korean Language 3_Hàn ngữ trung cấp 3'),
('JIS401','Tiếng Nhật CNTT trong ngành phần mềm'),
('JIT401','Information Technology Japanese_Tiếng Nhật công nghệ thông tin'),
('JFE301','Japanese IT Fundamentals_Kỹ năng CNTT cơ bản của Nhật Bản'),
('PRP201c','Python Programming_Lập trình Python'),
('DPL303m','Deep Learning_Học sâu'),
('DBM301','Data mining_Khai phá dữ liệu'),
('WDP301','Web Development Project_Dự án phát triển web'),
('FER202','Front-End web development with React_Phát triển web Front-End với React'),
('MMA301','Multiplatform Mobile App Development_Phát triển ứng dụng di động đa nền tảng'),
('SDN302','Server-Side development with NodeJS, Express, and MongoDB_Phát triển Server-Side với NodeJS, Express và MongoDB'),
('MIP201','Microcontroller Programming_Lập trình vi điều khiển'),
('DCD301','Digital Circuit Design_Thiết kế vi mạch số'),
('ACD301','Analog Circuit Design_Thiết kế vi mạch tương tự'),
('ECI101','Introduction to Electronic Components and Circuits_Nhập môn các linh kiện và mạch điện tử'),
('HSF302','Working with Spring Framework_Làm việc với Spring Framework'),
('SBA301','Integrate single page application with Spring Boot_Tích hợp ứng dụng trang đơn với Spring Boot'),
('MSS301','Microservices with Spring Cloud__Microservices với Spring Cloud'),
('PRC392m','Cloud Computing_Điện toán đám mây'),
('DSO391','DevSecOps for Cloud_Tích hợp DevSecOps cho Cloud'),
('FGU301','Fundamental Game Development_Phát triển game cơ bản'),
('AGU301','Advanced Game Development_Phát triển game nâng cao'),
('GDC301','Game Design Fundamentals - From Concept to Creation_Thiết kế game cơ bản - Từ ý tưởng đến thực hiện'),
('GNS301','Game Networking and Server Development_Mạng game và phát triển máy chủ game nâng cao'),
('PRN212','Basic Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng cơ bản với .NET'),
('PRN222','Advanced Cross-Platform Application Programming With .NET_Lập trình ứng dụng đa nền tảng nâng cao với .NET'),
('PRU213','Game Programming with C#_Lập trình Game với C#'),
('PRN232','Building Cross-Platform Back-End Application With .NET_Xây dựng ứng dụng back-end với .NET'),
('PDS301m','Python for Applied Data Science_Lập trình Python cho khoa học dữ liệu ứng dụng'),
('DHV301','Data Handling and Visualization_Xử lý và Trực quan hóa Dữ liệu'),
('MDS301','Machine Learning in Data Science_Học máy trong khoa học dữ liệu'),
('BDT301','Big Data Technologies & Tools_Công cụ và kỹ thuật trên dữ liệu lớn.'),
('AQA301','Agile Software Quality Assurance_Đảm bảo chất lượng phần mềm theo Agile'),
('SQA301','AI-based System Quality Assurance_Đảm bảo chất lượng hệ thống dựa trên AI'),
('TAI301','Testing with Generative AI_Kiểm thử với AI tạo sinh'),
('QCT301','Quality Characteristics Testing_Kiểm thử các đặc tính chất lượng'),
('ALF301','AI, LLMs & GenAI Foundation_Cơ sở AI, LLM và AI tạo sinh'),
('LLA301','LLM Application Engineering_Kỹ thuật phát triển ứng dụng với LLM'),
('EIA301','Embeddings and Intelligent Applications_Nhúng dữ liệu và Ứng dụng Thông minh'),
('EAS301','Enterprise AI Systems_Hệ thống AI cho Doanh nghiệp'),
('BPE301','Business Analysis Planning & Elicitation with Generative AI_Lập kế hoạch và Thu thập Yêu cầu Kinh doanh với AI tạo sinh'),
('SLM301','AI-Augmented Software Requirements Life Cycle Management_Quản lý vòng đời yêu cầu phần mềm được tăng cường bằng AI'),
('SDS301','Strategy Analysis & Decision Support with AI_Phân tích chiến lược và Hỗ trợ quyết định với AI');
INSERT INTO st_catalog VALUES
('EDO301','Solution Evaluation, Delivery & Operations with AI_Đánh giá, Triển khai và Vận hành Giải pháp với AI'),
('EFD301','Enterprise Fullstack Application Development (with Java)_Phát triển ứng dụng Fullstack doanh nghiệp (với Java)'),
('EMD301','Enterprise Microservices Architecture & Development (with Java)_Kiến trúc và Phát triển Microservices doanh nghiệp (với Java)'),
('BSS301','AI-Augmented Backend Systems & Intelligent Services_Hệ thống Backend và Dịch vụ Thông minh được tăng cường bằng AI'),
('DDP301','Software Delivery, DevOps & Platform Engineering_Triển khai Phần mềm, DevOps và Kỹ thuật Nền tảng');

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


-- SECTION: 04_student_specialization_combo.sql
-- Run once after 01_upgrade_it.sql. Keep selections normalized, not duplicated in Students.

SET LOCAL search_path=public;
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM "SchemaMigrations" WHERE "Version"='20261006_it_combos_recruitment') THEN
  RAISE EXCEPTION 'Run 01_upgrade_it.sql first';
 END IF;
 IF EXISTS (SELECT 1 FROM "SchemaMigrations" WHERE "Version"='20261006_student_specialization_combo') THEN
  RAISE EXCEPTION 'Student combo migration already applied';
 END IF;
END $$;
ALTER TABLE "StudentComboSelections"
 ADD COLUMN "SelectionPurpose" text NOT NULL DEFAULT 'OTHER'
   CHECK ("SelectionPurpose" IN ('SPECIALIZATION','PHYSICAL_EDUCATION','OTHER')),
 ADD COLUMN "SelectionSource" text NOT NULL DEFAULT 'USER'
   CHECK ("SelectionSource" IN ('USER','IMPORT','SYNTHETIC')),
 ALTER COLUMN "SelectedAt" DROP NOT NULL;
COMMENT ON COLUMN "StudentComboSelections"."SelectedAt" IS 'Actual choice timestamp if known. NULL for imported/synthetic choices without a source date.';
COMMENT ON COLUMN "StudentComboSelections"."SelectionPurpose" IS 'Derived from the referenced ComboCode by trigger. One specialization choice per student and curriculum.';
UPDATE "StudentComboSelections" sc SET "SelectionPurpose"=CASE
 WHEN b."ComboCode" ~ '^PHE_COM' THEN 'PHYSICAL_EDUCATION'
 WHEN b."ComboCode" ~ '^(AI17|IA|IS|SE(-2026)?)_COM' THEN 'SPECIALIZATION'
 ELSE 'OTHER' END
FROM "ProgramCombos" b WHERE b."ProgramComboID"=sc."ProgramComboID";
-- If legacy data contains two specialization choices, migration fails atomically for review.
CREATE UNIQUE INDEX "UQ_Student_SpecializationCombo" ON "StudentComboSelections"("StudentID","ProgramID")
 WHERE "SelectionPurpose"='SPECIALIZATION';
CREATE FUNCTION "ClassifyStudentCombo"() RETURNS trigger LANGUAGE plpgsql SET search_path=public AS $$
DECLARE combo_code text;
BEGIN
 SELECT "ComboCode" INTO STRICT combo_code FROM "ProgramCombos" WHERE "ProgramComboID"=NEW."ProgramComboID";
 NEW."SelectionPurpose"=CASE WHEN combo_code ~ '^PHE_COM' THEN 'PHYSICAL_EDUCATION'
   WHEN combo_code ~ '^(AI17|IA|IS|SE(-2026)?)_COM' THEN 'SPECIALIZATION' ELSE 'OTHER' END;
 RETURN NEW;
END $$;
CREATE TRIGGER "TR_StudentCombo_Purpose" BEFORE INSERT OR UPDATE ON "StudentComboSelections"
 FOR EACH ROW EXECUTE FUNCTION "ClassifyStudentCombo"();
-- Keep classification consistent when catalog metadata is edited.
CREATE FUNCTION "ReclassifyComboSelections"() RETURNS trigger LANGUAGE plpgsql SET search_path=public AS $$
BEGIN
 UPDATE "StudentComboSelections" SET "SelectionPurpose"="SelectionPurpose"
 WHERE "ProgramComboID"=NEW."ProgramComboID";
 RETURN NEW;
END $$;
CREATE TRIGGER "TR_ProgramCombos_Reclassify" AFTER UPDATE OF "ComboCode" ON "ProgramCombos"
 FOR EACH ROW WHEN (OLD."ComboCode" IS DISTINCT FROM NEW."ComboCode") EXECUTE FUNCTION "ReclassifyComboSelections"();
REVOKE ALL ON FUNCTION "ClassifyStudentCombo"(),"ReclassifyComboSelections"() FROM PUBLIC;
DO $$ DECLARE r text; BEGIN
 FOREACH r IN ARRAY ARRAY['anon','authenticated'] LOOP
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname=r) THEN
   EXECUTE format('REVOKE ALL ON FUNCTION public."ClassifyStudentCombo"(),public."ReclassifyComboSelections"() FROM %I',r);
  END IF;
 END LOOP;
END $$;
INSERT INTO "SchemaMigrations" ("Version") VALUES ('20261006_student_specialization_combo');


-- SECTION: 07_external_matching.sql
-- ADDITIVE migration for the existing full database. Run once; no reset or student seed.

SET LOCAL search_path=public;
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM "SchemaMigrations" WHERE "Version"='20261006_student_specialization_combo') THEN
  RAISE EXCEPTION 'Install the current full schema first';
 END IF;
 IF EXISTS (SELECT 1 FROM "SchemaMigrations" WHERE "Version"='20261006_external_matching') THEN
  RAISE EXCEPTION 'External matching migration already applied';
 END IF;
END $$;

CREATE TABLE "OJTEnterpriseImportBatches" (
 "BatchID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "IdempotencyKey" text NOT NULL UNIQUE,
 "SourceName" text NOT NULL, "SourceObjectPath" text,
 "ImportedBy" int NOT NULL REFERENCES "Users"("UserID"),
 "Status" text NOT NULL DEFAULT 'PENDING' CHECK ("Status" IN ('PENDING','PROCESSING','COMPLETED','PARTIAL','FAILED')),
 "CreatedAt" timestamptz NOT NULL DEFAULT now(), "CompletedAt" timestamptz
);
CREATE TABLE "OJTEnterpriseImportRows" (
 "ImportRowID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "BatchID" bigint NOT NULL REFERENCES "OJTEnterpriseImportBatches"("BatchID"),
 "RowNumber" int NOT NULL CHECK ("RowNumber">0),
 "SourceRecordKey" text, "RawData" jsonb NOT NULL CHECK (jsonb_typeof("RawData")='object'),
 "NormalizedData" jsonb CHECK (jsonb_typeof("NormalizedData")='object'),
 "Status" text NOT NULL DEFAULT 'PENDING' CHECK ("Status" IN ('PENDING','VALID','IMPORTED','REJECTED')),
 "ValidationErrors" jsonb NOT NULL DEFAULT '[]' CHECK (jsonb_typeof("ValidationErrors")='array'),
 "EnterpriseID" int REFERENCES "Enterprises"("EnterpriseID"),
 UNIQUE ("BatchID","RowNumber"),
 CHECK ("Status"<>'IMPORTED' OR "EnterpriseID" IS NOT NULL)
);
CREATE TABLE "MatchingSkills" (
 "SkillID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "SkillCode" text NOT NULL UNIQUE, "SkillName" text NOT NULL,
 "Aliases" text[] NOT NULL DEFAULT '{}'
);
CREATE TABLE "StudentCareerProfiles" (
 "StudentID" int PRIMARY KEY REFERENCES "Students"("StudentID"),
 "CareerSummary" text, "ResumeObjectPath" text,
 "Languages" jsonb NOT NULL DEFAULT '[]' CHECK (jsonb_typeof("Languages")='array'),
 "Preferences" jsonb NOT NULL DEFAULT '{}' CHECK (jsonb_typeof("Preferences")='object'),
 "ExternalMatchingAllowed" boolean NOT NULL DEFAULT false,
 "ConsentRecordedAt" timestamptz,
 "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
 CHECK (NOT "ExternalMatchingAllowed" OR "ConsentRecordedAt" IS NOT NULL)
);
CREATE TABLE "StudentMatchingSkills" (
 "StudentID" int NOT NULL REFERENCES "StudentCareerProfiles"("StudentID"),
 "SkillID" int NOT NULL REFERENCES "MatchingSkills"("SkillID"),
 "Level" smallint CHECK ("Level" BETWEEN 1 AND 5),
 "Evidence" text, "VerifiedBy" int REFERENCES "Users"("UserID"),
 PRIMARY KEY ("StudentID","SkillID")
);
CREATE TABLE "StudentCareerInterests" (
 "StudentID" int NOT NULL REFERENCES "StudentCareerProfiles"("StudentID"),
 "JobRoleID" int NOT NULL REFERENCES "JobRoles"("JobRoleID"),
 "Priority" smallint NOT NULL CHECK ("Priority">0),
 PRIMARY KEY ("StudentID","JobRoleID"), UNIQUE ("StudentID","Priority")
);

-- One matching target is either a real position OR a company intake without a JD.
-- Existing InternshipPositions remains authoritative for title/JD/requirements/capacity.
CREATE TABLE "OJTMatchingProfiles" (
 "ProfileID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "ProfileType" text NOT NULL CHECK ("ProfileType" IN ('POSITION','ENTERPRISE_OJT')),
 "EnterpriseID" int NOT NULL REFERENCES "Enterprises"("EnterpriseID"),
 "OJTSemesterID" int NOT NULL REFERENCES "OJTSemesters"("OJTSemesterID"),
 "PositionID" int UNIQUE,
 "ImportRowID" bigint REFERENCES "OJTEnterpriseImportRows"("ImportRowID"),
 "CompanyOJTDescription" text, "CompanyCapacity" int CHECK ("CompanyCapacity">=0),
 "CompanyRemainingSlots" int CHECK ("CompanyRemainingSlots">=0 AND "CompanyRemainingSlots"<="CompanyCapacity"),
 "CompanyLocation" text,
 "CompanyWorkMode" text CHECK ("CompanyWorkMode" IN ('ONSITE','REMOTE','HYBRID')),
 "MinGPA" numeric(4,2) CHECK ("MinGPA">=0 AND "MinGPA"<="GPAScale"),
 "GPAScale" numeric(4,2) CHECK ("GPAScale" IN (4,10)),
 "LanguageRequirements" jsonb NOT NULL DEFAULT '[]' CHECK (jsonb_typeof("LanguageRequirements")='array'),
 "OtherHardRequirements" jsonb NOT NULL DEFAULT '{}' CHECK (jsonb_typeof("OtherHardRequirements")='object'),
 "MajorPolicy" text NOT NULL DEFAULT 'REVIEW_REQUIRED' CHECK ("MajorPolicy" IN ('ANY','ALLOW_LIST','REVIEW_REQUIRED')),
 "DeadlineAt" timestamptz,
 "Status" text NOT NULL DEFAULT 'DRAFT' CHECK ("Status" IN ('DRAFT','PUBLISHED','CLOSED','ARCHIVED')),
 "ReviewedBy" int REFERENCES "Users"("UserID"), "ReviewedAt" timestamptz,
 "UpdatedAt" timestamptz NOT NULL DEFAULT now(),
 UNIQUE ("ProfileID","OJTSemesterID"),
 FOREIGN KEY ("PositionID","EnterpriseID","OJTSemesterID")
  REFERENCES "InternshipPositions"("PositionID","EnterpriseID","OJTSemesterID"),
 CHECK (("MinGPA" IS NULL)=("GPAScale" IS NULL)),
 CHECK (("ProfileType"='POSITION' AND "PositionID" IS NOT NULL
    AND "CompanyCapacity" IS NULL AND "CompanyRemainingSlots" IS NULL
    AND "CompanyOJTDescription" IS NULL AND "CompanyLocation" IS NULL AND "CompanyWorkMode" IS NULL)
  OR ("ProfileType"='ENTERPRISE_OJT' AND "PositionID" IS NULL
    AND length(btrim("CompanyOJTDescription"))>0 AND "CompanyOJTDescription" IS NOT NULL
    AND "CompanyCapacity" IS NOT NULL AND "CompanyRemainingSlots" IS NOT NULL)),
 CHECK ("Status"<>'PUBLISHED' OR ("ReviewedBy" IS NOT NULL AND "ReviewedAt" IS NOT NULL AND "MajorPolicy"<>'REVIEW_REQUIRED'))
);
CREATE UNIQUE INDEX "UQ_CompanyOJT_Semester" ON "OJTMatchingProfiles"("EnterpriseID","OJTSemesterID") WHERE "ProfileType"='ENTERPRISE_OJT';
CREATE INDEX "IX_MatchingProfile_SemesterStatus" ON "OJTMatchingProfiles"("OJTSemesterID","Status");
CREATE TABLE "MatchingProfileMajors" (
 "ProfileID" bigint NOT NULL REFERENCES "OJTMatchingProfiles"("ProfileID"),
 "MajorID" int NOT NULL REFERENCES "AcademicMajors"("MajorID"),
 PRIMARY KEY ("ProfileID","MajorID")
);
CREATE TABLE "MatchingProfileSpecializations" (
 "ProfileID" bigint NOT NULL REFERENCES "OJTMatchingProfiles"("ProfileID"),
 "SpecializationID" int NOT NULL REFERENCES "Specializations"("SpecializationID"),
 PRIMARY KEY ("ProfileID","SpecializationID")
);
CREATE TABLE "MatchingProfileJobRoles" (
 "ProfileID" bigint NOT NULL REFERENCES "OJTMatchingProfiles"("ProfileID"),
 "JobRoleID" int NOT NULL REFERENCES "JobRoles"("JobRoleID"),
 PRIMARY KEY ("ProfileID","JobRoleID")
);
CREATE TABLE "MatchingProfileSkills" (
 "ProfileID" bigint NOT NULL REFERENCES "OJTMatchingProfiles"("ProfileID"),
 "SkillID" int NOT NULL REFERENCES "MatchingSkills"("SkillID"),
 "IsRequired" boolean NOT NULL DEFAULT false,
 "MinLevel" smallint CHECK ("MinLevel" BETWEEN 1 AND 5),
 "Weight" numeric(5,2) NOT NULL DEFAULT 1 CHECK ("Weight">0),
 PRIMARY KEY ("ProfileID","SkillID")
);
CREATE TABLE "MatchingProfileCourses" (
 "ProfileID" bigint NOT NULL REFERENCES "OJTMatchingProfiles"("ProfileID"),
 "CourseID" int NOT NULL REFERENCES "Courses"("CourseID"),
 "IsRequired" boolean NOT NULL DEFAULT true,
 PRIMARY KEY ("ProfileID","CourseID")
);

-- Portable storage: backend computes cosine after filtering; no pgvector extension required.
CREATE TABLE "EmbeddingConfigurations" (
 "EmbeddingConfigID" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "Provider" text NOT NULL, "ModelName" text NOT NULL, "ModelVersion" text NOT NULL,
 "Dimensions" int NOT NULL CHECK ("Dimensions">0),
 "PreprocessingVersion" text NOT NULL,
 "IsActive" boolean NOT NULL DEFAULT true,
 UNIQUE ("Provider","ModelName","ModelVersion","Dimensions","PreprocessingVersion"),
 UNIQUE ("EmbeddingConfigID","Dimensions")
);
CREATE TABLE "MatchingEmbeddings" (
 "EmbeddingID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "EmbeddingConfigID" int NOT NULL, "Dimensions" int NOT NULL,
 "StudentID" int REFERENCES "Students"("StudentID"),
 "ProfileID" bigint REFERENCES "OJTMatchingProfiles"("ProfileID"),
 "ContentHash" text NOT NULL,
 "Embedding" double precision[] NOT NULL,
 "CreatedAt" timestamptz NOT NULL DEFAULT now(),
 UNIQUE ("EmbeddingID","StudentID","EmbeddingConfigID"),
 UNIQUE ("EmbeddingID","ProfileID","EmbeddingConfigID"),
 FOREIGN KEY ("EmbeddingConfigID","Dimensions") REFERENCES "EmbeddingConfigurations"("EmbeddingConfigID","Dimensions"),
 CHECK (("StudentID" IS NOT NULL)::int+("ProfileID" IS NOT NULL)::int=1),
 CHECK (cardinality("Embedding")="Dimensions" AND array_ndims("Embedding")=1 AND array_lower("Embedding",1)=1),
 CHECK ("Embedding"<>array_fill(0::double precision,ARRAY["Dimensions"])),
 CHECK (array_position("Embedding",NULL) IS NULL
  AND array_position("Embedding",'NaN'::double precision) IS NULL
  AND array_position("Embedding",'Infinity'::double precision) IS NULL
  AND array_position("Embedding",'-Infinity'::double precision) IS NULL)
);
CREATE UNIQUE INDEX "UQ_StudentEmbedding" ON "MatchingEmbeddings"("StudentID","EmbeddingConfigID","ContentHash") WHERE "StudentID" IS NOT NULL;
CREATE UNIQUE INDEX "UQ_ProfileEmbedding" ON "MatchingEmbeddings"("ProfileID","EmbeddingConfigID","ContentHash") WHERE "ProfileID" IS NOT NULL;
COMMENT ON TABLE "MatchingEmbeddings" IS 'Sensitive derived profile data. Cache only for matching; delete per retention policy. Backend rejects zero-norm vectors and never compares different configurations.';

CREATE TABLE "MatchingRuns" (
 "RunID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "IdempotencyKey" text NOT NULL UNIQUE,
 "StudentID" int NOT NULL REFERENCES "Students"("StudentID"),
 "OJTSemesterID" int NOT NULL REFERENCES "OJTSemesters"("OJTSemesterID"),
 "RequestedBy" int NOT NULL REFERENCES "Users"("UserID"),
 "TopK" smallint NOT NULL DEFAULT 10 CHECK ("TopK" BETWEEN 1 AND 100),
 "FilterVersion" text NOT NULL, "ScoringVersion" text NOT NULL,
 "EmbeddingConfigID" int NOT NULL REFERENCES "EmbeddingConfigurations"("EmbeddingConfigID"),
 "Status" text NOT NULL DEFAULT 'PENDING' CHECK ("Status" IN ('PENDING','FILTERING','SCORING','SUCCEEDED','FAILED','CANCELLED')),
 "StudentSnapshot" jsonb NOT NULL CHECK (jsonb_typeof("StudentSnapshot")='object'),
 "InputHash" text NOT NULL,
 "CreatedAt" timestamptz NOT NULL DEFAULT now(), "CompletedAt" timestamptz,
 "ExpiresAt" timestamptz NOT NULL, "ErrorCode" text,
 UNIQUE ("RunID","OJTSemesterID"),
 UNIQUE ("RunID","StudentID","EmbeddingConfigID"),
 CHECK ("ExpiresAt">"CreatedAt"),
 CHECK ("Status" NOT IN ('SUCCEEDED','FAILED','CANCELLED') OR "CompletedAt" IS NOT NULL)
);
CREATE INDEX "IX_MatchingRuns_Student" ON "MatchingRuns"("StudentID","OJTSemesterID","CreatedAt" DESC);
CREATE TABLE "MatchingCandidates" (
 "RunID" bigint NOT NULL, "ProfileID" bigint NOT NULL, "OJTSemesterID" int NOT NULL,
 "Eligibility" text NOT NULL CHECK ("Eligibility" IN ('PASS','FAIL','REVIEW_REQUIRED')),
 "FilterReasons" jsonb NOT NULL DEFAULT '[]' CHECK (jsonb_typeof("FilterReasons")='array'),
 "ProfileSnapshot" jsonb NOT NULL CHECK (jsonb_typeof("ProfileSnapshot")='object'),
 "CheckedAt" timestamptz NOT NULL DEFAULT now(),
 PRIMARY KEY ("RunID","ProfileID"), UNIQUE ("RunID","ProfileID","Eligibility"),
 FOREIGN KEY ("RunID","OJTSemesterID") REFERENCES "MatchingRuns"("RunID","OJTSemesterID"),
 FOREIGN KEY ("ProfileID","OJTSemesterID") REFERENCES "OJTMatchingProfiles"("ProfileID","OJTSemesterID")
);
CREATE TABLE "MatchingAPICalls" (
 "CallID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "RunID" bigint NOT NULL REFERENCES "MatchingRuns"("RunID"),
 "BatchNumber" int NOT NULL CHECK ("BatchNumber">0), "AttemptNumber" int NOT NULL CHECK ("AttemptNumber">0),
 "Provider" text NOT NULL, "ModelName" text NOT NULL,
 "ProviderRequestID" text, "RequestHash" text NOT NULL,
 "Status" text NOT NULL DEFAULT 'PENDING' CHECK ("Status" IN ('PENDING','SUCCEEDED','FAILED','TIMED_OUT')),
 "HTTPStatus" int CHECK ("HTTPStatus" BETWEEN 100 AND 599),
 "ErrorCode" text, "LatencyMs" int CHECK ("LatencyMs">=0),
 "InputTokens" int CHECK ("InputTokens">=0), "OutputTokens" int CHECK ("OutputTokens">=0),
 "StartedAt" timestamptz NOT NULL DEFAULT now(), "FinishedAt" timestamptz,
 UNIQUE ("RunID","BatchNumber","AttemptNumber"), UNIQUE ("CallID","RunID","Status"),
 CHECK ("Status"='PENDING' OR "FinishedAt" IS NOT NULL)
);
COMMENT ON TABLE "MatchingAPICalls" IS 'Backend call audit only. Never store API keys, Authorization headers, raw CVs or unredacted request/response bodies.';
CREATE TABLE "MatchingRecommendations" (
 "RecommendationID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "RunID" bigint NOT NULL, "ProfileID" bigint NOT NULL,
 "StudentID" int NOT NULL, "EmbeddingConfigID" int NOT NULL,
 "Eligibility" text NOT NULL DEFAULT 'PASS' CHECK ("Eligibility"='PASS'),
 "CallID" bigint, "CallStatus" text NOT NULL DEFAULT 'SUCCEEDED' CHECK ("CallStatus"='SUCCEEDED'),
 "ScoringSource" text NOT NULL CHECK ("ScoringSource" IN ('API','CACHE')),
 "StudentEmbeddingID" bigint NOT NULL,
 "ProfileEmbeddingID" bigint NOT NULL,
 "CosineSimilarity" double precision NOT NULL CHECK ("CosineSimilarity" BETWEEN -1 AND 1),
 "MatchScore" numeric(5,2) NOT NULL CHECK ("MatchScore" BETWEEN 0 AND 100),
 "Rank" int NOT NULL CHECK ("Rank">0),
 "Explanation" text NOT NULL,
 "MatchedSkills" jsonb NOT NULL DEFAULT '[]' CHECK (jsonb_typeof("MatchedSkills")='array'),
 "MissingSkills" jsonb NOT NULL DEFAULT '[]' CHECK (jsonb_typeof("MissingSkills")='array'),
 "ScoreBreakdown" jsonb NOT NULL DEFAULT '{}' CHECK (jsonb_typeof("ScoreBreakdown")='object'),
 UNIQUE ("RunID","ProfileID"), UNIQUE ("RunID","Rank"),
 CHECK (("ScoringSource"='API' AND "CallID" IS NOT NULL) OR ("ScoringSource"='CACHE' AND "CallID" IS NULL)),
 FOREIGN KEY ("RunID","StudentID","EmbeddingConfigID") REFERENCES "MatchingRuns"("RunID","StudentID","EmbeddingConfigID"),
 FOREIGN KEY ("StudentEmbeddingID","StudentID","EmbeddingConfigID") REFERENCES "MatchingEmbeddings"("EmbeddingID","StudentID","EmbeddingConfigID"),
 FOREIGN KEY ("ProfileEmbeddingID","ProfileID","EmbeddingConfigID") REFERENCES "MatchingEmbeddings"("EmbeddingID","ProfileID","EmbeddingConfigID"),
 FOREIGN KEY ("RunID","ProfileID","Eligibility") REFERENCES "MatchingCandidates"("RunID","ProfileID","Eligibility"),
 FOREIGN KEY ("CallID","RunID","CallStatus") REFERENCES "MatchingAPICalls"("CallID","RunID","Status")
);
COMMENT ON COLUMN "MatchingRecommendations"."MatchScore" IS 'Advisory fit score, not probability of hiring or OJT eligibility. Backend computes cosine and versioned scoring; ranks descending with ProfileID tie-break.';
CREATE TABLE "MatchingRecommendationFeedback" (
 "RecommendationID" bigint PRIMARY KEY REFERENCES "MatchingRecommendations"("RecommendationID"),
 "Action" text NOT NULL CHECK ("Action" IN ('SAVED','DISMISSED','INTERESTED')),
 "Note" text, "UpdatedAt" timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE "MatchingRecommendationFeedback" IS 'Backend checks the authenticated student owns the recommendation run. Does not create an application or reserve capacity.';

-- Backend-only access, consistent with Users/PasswordHash authentication.
DO $matching_security$
DECLARE item record; seq record; role_name text;
BEGIN
 FOR item IN SELECT c.oid,c.relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='public' AND c.relname=ANY(ARRAY[
 'OJTEnterpriseImportBatches','OJTEnterpriseImportRows','MatchingSkills','StudentCareerProfiles',
 'StudentMatchingSkills','StudentCareerInterests','OJTMatchingProfiles','MatchingProfileMajors',
 'MatchingProfileSpecializations','MatchingProfileJobRoles','MatchingProfileSkills','MatchingProfileCourses',
 'EmbeddingConfigurations','MatchingEmbeddings','MatchingRuns','MatchingCandidates','MatchingAPICalls','MatchingRecommendations','MatchingRecommendationFeedback']) LOOP
  EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',item.relname);
  EXECUTE format('REVOKE ALL ON TABLE public.%I FROM PUBLIC',item.relname);
  FOREACH role_name IN ARRAY ARRAY['anon','authenticated'] LOOP
   IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname=role_name) THEN
    EXECUTE format('REVOKE ALL ON TABLE public.%I FROM %I',item.relname,role_name);
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
END $matching_security$;
INSERT INTO "SchemaMigrations"("Version") VALUES ('20261006_external_matching');


-- SECTION: 09_ojt_deadline_alerts.sql
-- Additive OJT deadline alerts. No student seed, no AI prediction, no scheduled job.

SET LOCAL search_path=public;
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM "SchemaMigrations" WHERE "Version"='20261006_it_combos_recruitment') THEN
  RAISE EXCEPTION 'Install the IT/OJT schema first';
 END IF;
 IF EXISTS (SELECT 1 FROM "SchemaMigrations" WHERE "Version"='20261006_ojt_deadline_alerts') THEN
  RAISE EXCEPTION 'OJT deadline alert migration already applied';
 END IF;
END $$;

-- Explicit roster includes students who have NOT registered yet.
CREATE TABLE "OJTAlertTargets" (
 "TargetID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "StudentID" int NOT NULL REFERENCES "Students"("StudentID"),
 "OJTSemesterID" int NOT NULL REFERENCES "OJTSemesters"("OJTSemesterID"),
 "IsActive" boolean NOT NULL DEFAULT true,
 "Source" text NOT NULL CHECK ("Source" IN ('ACADEMIC_PLAN','IMPORT','STAFF')),
 "ConfirmedBy" int NOT NULL REFERENCES "Users"("UserID"),
 "ConfirmedAt" timestamptz NOT NULL DEFAULT now(),
 UNIQUE ("StudentID","OJTSemesterID")
);
CREATE TABLE "OJTAlertRules" (
 "RuleID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "RuleCode" text NOT NULL, "Version" int NOT NULL CHECK ("Version">0),
 "Name" text NOT NULL,
 "RuleType" text NOT NULL CHECK ("RuleType" IN ('ELIGIBILITY_NOT_MET','REGISTRATION_MISSING','PLACEMENT_MISSING','TASK_OVERDUE')),
 "Scope" text NOT NULL CHECK ("Scope" IN ('STUDENT','TASK')),
 "Anchor" text NOT NULL CHECK ("Anchor" IN ('REG_END','OJT_START','TASK_DUE')),
 "LeadDays" int NOT NULL DEFAULT 7 CHECK ("LeadDays">=0),
 "GraceDays" int NOT NULL DEFAULT 0 CHECK ("GraceDays">=0),
 "Severity" text NOT NULL DEFAULT 'WARNING' CHECK ("Severity" IN ('INFO','WARNING','CRITICAL')),
 "CooldownHours" int NOT NULL DEFAULT 24 CHECK ("CooldownHours">=1),
 "Parameters" jsonb NOT NULL DEFAULT '{}' CHECK (jsonb_typeof("Parameters")='object'),
 "IsEnabled" boolean NOT NULL DEFAULT false,
 "ApprovedBy" int REFERENCES "Users"("UserID"), "ApprovedAt" timestamptz,
 "CreatedAt" timestamptz NOT NULL DEFAULT now(),
 UNIQUE ("RuleCode","Version"), UNIQUE ("RuleID","Scope"),
 CHECK (NOT "IsEnabled" OR ("ApprovedBy" IS NOT NULL AND "ApprovedAt" IS NOT NULL)),
 CHECK (("RuleType"='TASK_OVERDUE' AND "Scope"='TASK' AND "Anchor"='TASK_DUE' AND "LeadDays"=0)
 OR ("RuleType"<>'TASK_OVERDUE' AND "Scope"='STUDENT' AND "Anchor" IN ('REG_END','OJT_START')))
);
CREATE UNIQUE INDEX "UQ_EnabledAlertRule" ON "OJTAlertRules"("RuleCode") WHERE "IsEnabled";
CREATE TABLE "OJTAlertCheckRuns" (
 "RunID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "IdempotencyKey" text NOT NULL UNIQUE,
 "OJTSemesterID" int NOT NULL REFERENCES "OJTSemesters"("OJTSemesterID"),
 "AsOf" timestamptz NOT NULL, "EngineVersion" text NOT NULL,
 "TriggeredBy" int REFERENCES "Users"("UserID"),
 "Status" text NOT NULL DEFAULT 'PENDING' CHECK ("Status" IN ('PENDING','RUNNING','SUCCEEDED','FAILED')),
 "StartedAt" timestamptz, "CompletedAt" timestamptz, "ErrorCode" text,
 UNIQUE ("RunID","OJTSemesterID"),
 CHECK ("Status" NOT IN ('SUCCEEDED','FAILED') OR "CompletedAt" IS NOT NULL)
);
ALTER TABLE "OJTAlertTargets" ADD UNIQUE ("TargetID","OJTSemesterID");
CREATE TABLE "OJTAlertEvaluations" (
 "EvaluationID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "RunID" bigint NOT NULL, "TargetID" bigint NOT NULL, "OJTSemesterID" int NOT NULL,
 "RuleID" bigint NOT NULL, "Scope" text NOT NULL,
 "TaskID" int REFERENCES "InternshipTasks"("TaskID"),
 "ScopeKey" text GENERATED ALWAYS AS (CASE WHEN "TaskID" IS NULL THEN 'STUDENT' ELSE 'TASK:' || "TaskID"::text END) STORED,
 "Outcome" text NOT NULL CHECK ("Outcome" IN ('TRIGGERED','CLEAR','UNKNOWN','NOT_APPLICABLE')),
 "ReasonCode" text NOT NULL,
 "Evidence" jsonb NOT NULL CHECK (jsonb_typeof("Evidence")='object'),
 "RuleSnapshot" jsonb NOT NULL CHECK (jsonb_typeof("RuleSnapshot")='object'),
 "EvaluatedAt" timestamptz NOT NULL DEFAULT now(),
 FOREIGN KEY ("RunID","OJTSemesterID") REFERENCES "OJTAlertCheckRuns"("RunID","OJTSemesterID"),
 FOREIGN KEY ("TargetID","OJTSemesterID") REFERENCES "OJTAlertTargets"("TargetID","OJTSemesterID"),
 FOREIGN KEY ("RuleID","Scope") REFERENCES "OJTAlertRules"("RuleID","Scope"),
 UNIQUE ("RunID","TargetID","RuleID","ScopeKey"),
 UNIQUE ("EvaluationID","TargetID","RuleID","ScopeKey","Outcome"),
 CHECK (("Scope"='STUDENT' AND "TaskID" IS NULL) OR ("Scope"='TASK' AND "TaskID" IS NOT NULL))
);
-- Prevent attaching another student's task or another semester's task to an evaluation.
CREATE FUNCTION "CheckOJTAlertTaskContext"() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW."TaskID" IS NOT NULL AND NOT EXISTS (
  SELECT 1 FROM public."InternshipTasks" t
  JOIN public."InternshipAssignments" a ON a."AssignmentID"=t."AssignmentID"
  JOIN public."InternshipPositions" p ON p."PositionID"=a."PositionID"
  JOIN public."OJTAlertTargets" x ON x."TargetID"=NEW."TargetID"
  WHERE t."TaskID"=NEW."TaskID" AND a."StudentID"=x."StudentID" AND p."OJTSemesterID"=NEW."OJTSemesterID"
 ) THEN RAISE EXCEPTION 'Task does not belong to alert student/semester'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER "TR_OJTAlertTaskContext" BEFORE INSERT OR UPDATE ON "OJTAlertEvaluations"
FOR EACH ROW EXECUTE FUNCTION "CheckOJTAlertTaskContext"();
CREATE TABLE "OJTAlerts" (
 "AlertID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "TargetID" bigint NOT NULL, "RuleID" bigint NOT NULL,
 "ScopeKey" text NOT NULL,
 "TriggerEvaluationID" bigint NOT NULL,
 "TriggerOutcome" text NOT NULL DEFAULT 'TRIGGERED' CHECK ("TriggerOutcome"='TRIGGERED'),
 "Severity" text NOT NULL CHECK ("Severity" IN ('INFO','WARNING','CRITICAL')),
 "Status" text NOT NULL DEFAULT 'OPEN' CHECK ("Status" IN ('OPEN','ACKNOWLEDGED','RESOLVED','DISMISSED')),
 "Title" text NOT NULL, "Message" text NOT NULL,
 "FirstDetectedAt" timestamptz NOT NULL DEFAULT now(), "LastDetectedAt" timestamptz NOT NULL DEFAULT now(),
 "ClosedAt" timestamptz, "ClosedBy" int REFERENCES "Users"("UserID"), "CloseReason" text,
 FOREIGN KEY ("TriggerEvaluationID","TargetID","RuleID","ScopeKey","TriggerOutcome")
 REFERENCES "OJTAlertEvaluations"("EvaluationID","TargetID","RuleID","ScopeKey","Outcome"),
 CHECK ("LastDetectedAt">="FirstDetectedAt"),
 CHECK (("Status" IN ('OPEN','ACKNOWLEDGED') AND "ClosedAt" IS NULL)
  OR ("Status" IN ('RESOLVED','DISMISSED') AND "ClosedAt" IS NOT NULL AND "CloseReason" IS NOT NULL))
);
CREATE UNIQUE INDEX "UQ_ActiveOJTAlert" ON "OJTAlerts"("TargetID","RuleID","ScopeKey") WHERE "Status" IN ('OPEN','ACKNOWLEDGED');
CREATE TABLE "OJTAlertEvents" (
 "EventID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "AlertID" bigint NOT NULL REFERENCES "OJTAlerts"("AlertID"),
 "EventType" text NOT NULL CHECK ("EventType" IN ('CREATED','RECONFIRMED','ACKNOWLEDGED','RESOLVED','DISMISSED','NOTIFICATION_QUEUED')),
 "ActorUserID" int REFERENCES "Users"("UserID"),
 "Note" text, "CreatedAt" timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE "Notifications" ADD CONSTRAINT "UQ_Notification_Recipient" UNIQUE ("NotificationID","UserID");
CREATE TABLE "OJTAlertDeliveries" (
 "DeliveryID" bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 "AlertID" bigint NOT NULL REFERENCES "OJTAlerts"("AlertID"),
 "RecipientUserID" int NOT NULL REFERENCES "Users"("UserID"),
 "Channel" text NOT NULL CHECK ("Channel" IN ('IN_APP','EMAIL')),
 "IdempotencyKey" text NOT NULL UNIQUE,
 "NotificationID" int UNIQUE,
 "Status" text NOT NULL DEFAULT 'PENDING' CHECK ("Status" IN ('PENDING','SENDING','SENT','FAILED','CANCELLED')),
 "AttemptCount" int NOT NULL DEFAULT 0 CHECK ("AttemptCount">=0),
 "NextAttemptAt" timestamptz NOT NULL DEFAULT now(), "LeaseUntil" timestamptz,
 "SentAt" timestamptz, "ProviderMessageID" text, "ErrorCode" text,
 "CreatedAt" timestamptz NOT NULL DEFAULT now(),
 FOREIGN KEY ("NotificationID","RecipientUserID") REFERENCES "Notifications"("NotificationID","UserID"),
 CHECK ("Status"<>'SENT' OR "SentAt" IS NOT NULL),
 CHECK ("Status"<>'SENDING' OR "LeaseUntil" IS NOT NULL)
);
CREATE INDEX "IX_AlertDelivery_Queue" ON "OJTAlertDeliveries"("Status","NextAttemptAt");
CREATE INDEX "IX_OJTAlerts_TargetStatus" ON "OJTAlerts"("TargetID","Status");
CREATE INDEX "IX_AlertEvaluation_Target" ON "OJTAlertEvaluations"("TargetID","EvaluatedAt" DESC);
COMMENT ON TABLE "OJTAlerts" IS 'Rule-based actionable warnings, not AI probabilities. Backend evaluates rules, maintains events and resolves alerts; SQL does not schedule jobs.';
COMMENT ON TABLE "OJTAlertRules" IS 'Versioned rules. Seed examples disabled until school confirms deadlines, thresholds and legacy status mappings. Published versions should be immutable.';
INSERT INTO "OJTAlertRules" ("RuleCode","Version","Name","RuleType","Scope","Anchor","LeadDays") VALUES
 ('OJT_ELIGIBILITY',1,'Chưa đủ điều kiện OJT','ELIGIBILITY_NOT_MET','STUDENT','REG_END',7),
 ('OJT_REGISTRATION',1,'Chưa đăng ký OJT hợp lệ','REGISTRATION_MISSING','STUDENT','REG_END',7),
 ('OJT_PLACEMENT',1,'Chưa có nơi thực tập','PLACEMENT_MISSING','STUDENT','OJT_START',7),
 ('OJT_TASK_OVERDUE',1,'Nhiệm vụ thực tập quá hạn','TASK_OVERDUE','TASK','TASK_DUE',0);

DO $alert_security$
DECLARE item record; seq record; role_name text;
BEGIN
 FOR item IN SELECT c.oid,c.relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='public' AND c.relname=ANY(ARRAY['OJTAlertTargets','OJTAlertRules','OJTAlertCheckRuns','OJTAlertEvaluations','OJTAlerts','OJTAlertEvents','OJTAlertDeliveries']) LOOP
  EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',item.relname);
  EXECUTE format('REVOKE ALL ON TABLE public.%I FROM PUBLIC',item.relname);
  FOREACH role_name IN ARRAY ARRAY['anon','authenticated'] LOOP
   IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname=role_name) THEN
    EXECUTE format('REVOKE ALL ON TABLE public.%I FROM %I',item.relname,role_name);
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
END $alert_security$;
REVOKE ALL ON FUNCTION "CheckOJTAlertTaskContext"() FROM PUBLIC;
INSERT INTO "SchemaMigrations"("Version") VALUES ('20261006_ojt_deadline_alerts');



-- Keep student schema available for later imports; no student data is seeded.
ALTER TABLE "Students" ADD COLUMN "CohortCode" varchar(20);
COMMENT ON COLUMN "Students"."CohortCode" IS 'Source cohort, e.g. K19; do not infer enrollment calendar year from this label.';



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
