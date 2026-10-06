-- EMPTY DATABASE ONLY. Safe create: no reset, drops or demo users.
-- Backend hashes passwords; no pgcrypto dependency needed by this DDL.
BEGIN;
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
   4. AI RISK PREDICTION & PATHWAY ADVISING
   ============================================================ */

CREATE TABLE "AIModels" (
    "ModelID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "ModelCode" VARCHAR(30) NOT NULL UNIQUE,
    "ModelName" VARCHAR(100) NOT NULL,
    "ModelType" VARCHAR(30),
    "Algorithm" VARCHAR(50),
    "Version" VARCHAR(20),
    "TrainedDate" DATE,
    "IsActive" BOOLEAN DEFAULT FALSE,
    "MetricsJSON" JSONB,
    "ArtifactPath" VARCHAR(255)
);

CREATE TABLE "AIModelConfig" (
    "ConfigID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "ModelID" INT NOT NULL,
    "RiskThresholdMedium" NUMERIC(4,3),
    "RiskThresholdHigh" NUMERIC(4,3),
    "RiskThresholdCritical" NUMERIC(4,3),
    "UpdatedBy" INT,
    "UpdatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "FK_AIModelConfig_Model"
        FOREIGN KEY ("ModelID") REFERENCES "AIModels"("ModelID") ON DELETE CASCADE,
    CONSTRAINT "FK_AIModelConfig_UpdatedBy"
        FOREIGN KEY ("UpdatedBy") REFERENCES "Users"("UserID") ON DELETE SET NULL,
    CONSTRAINT "CHK_AIModelConfig_Threshold"
        CHECK (
            "RiskThresholdMedium" >= 0
            AND "RiskThresholdMedium" < "RiskThresholdHigh"
            AND "RiskThresholdHigh" < "RiskThresholdCritical"
            AND "RiskThresholdCritical" <= 1
        )
);

/*
   RiskLevel length changed from VARCHAR(10) to VARCHAR(20)
   to support CRITICAL safely.
*/

CREATE TABLE "RiskPredictions" (
    "PredictionID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "StudentID" INT NOT NULL,
    "OJTSemesterID" INT NOT NULL,
    "ModelID" INT NOT NULL,
    "SnapshotID" INT NOT NULL,
    "RiskProbability" NUMERIC(5,4),
    "RiskLevel" VARCHAR(20),
    "PredictedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "FeaturesJSON" JSONB,
    CONSTRAINT "FK_RiskPredictions_Student"
        FOREIGN KEY ("StudentID") REFERENCES "Students"("StudentID") ON DELETE CASCADE,
    CONSTRAINT "FK_RiskPredictions_OJTSemester"
        FOREIGN KEY ("OJTSemesterID") REFERENCES "OJTSemesters"("OJTSemesterID"),
    CONSTRAINT "FK_RiskPredictions_Model"
        FOREIGN KEY ("ModelID") REFERENCES "AIModels"("ModelID"),
    CONSTRAINT "FK_RiskPredictions_Snapshot"
        FOREIGN KEY ("SnapshotID") REFERENCES "StudentAcademicSnapshot"("SnapshotID"),
    CONSTRAINT "CHK_RiskPredictions_Probability"
        CHECK ("RiskProbability" IS NULL OR ("RiskProbability" >= 0 AND "RiskProbability" <= 1)),
    CONSTRAINT "CHK_RiskPredictions_Level"
        CHECK ("RiskLevel" IS NULL OR "RiskLevel" IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);

CREATE TABLE "PathwayRecommendations" (
    "RecommendationID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "StudentID" INT NOT NULL,
    "PredictionID" INT,
    "OJTSemesterID" INT NOT NULL,
    "MissingCourses" VARCHAR(1000),
    "RecommendedPlan" TEXT,
    "GeneratedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "Status" VARCHAR(20),
    CONSTRAINT "FK_PathwayRecommendations_Student"
        FOREIGN KEY ("StudentID") REFERENCES "Students"("StudentID") ON DELETE CASCADE,
    CONSTRAINT "FK_PathwayRecommendations_Prediction"
        FOREIGN KEY ("PredictionID") REFERENCES "RiskPredictions"("PredictionID") ON DELETE NO ACTION,
    CONSTRAINT "FK_PathwayRecommendations_Semester"
        FOREIGN KEY ("OJTSemesterID") REFERENCES "OJTSemesters"("OJTSemesterID")
);

CREATE TABLE "SupportClassAISuggestions" (
    "SuggestionID" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "CourseID" INT NOT NULL,
    "OJTSemesterID" INT NOT NULL,
    "SuggestedStudentCount" INT,
    "Reason" VARCHAR(500),
    "SuggestedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "Status" VARCHAR(20),
    CONSTRAINT "FK_SupportClassAISuggestions_Course"
        FOREIGN KEY ("CourseID") REFERENCES "Courses"("CourseID"),
    CONSTRAINT "FK_SupportClassAISuggestions_Semester"
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
    "SuggestionID" INT,
    "StartDate" DATE,
    "EndDate" DATE,
    "Capacity" INT,
    "CreatedBy" INT,
    "Status" VARCHAR(20),
    CONSTRAINT "FK_SupportClasses_Course"
        FOREIGN KEY ("CourseID") REFERENCES "Courses"("CourseID"),
    CONSTRAINT "FK_SupportClasses_Semester"
        FOREIGN KEY ("OJTSemesterID") REFERENCES "OJTSemesters"("OJTSemesterID"),
    CONSTRAINT "FK_SupportClasses_Suggestion"
        FOREIGN KEY ("SuggestionID") REFERENCES "SupportClassAISuggestions"("SuggestionID") ON DELETE SET NULL,
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
CREATE INDEX "IX_RiskPredictions_Student" ON "RiskPredictions"("StudentID");
CREATE INDEX "IX_RiskPredictions_Semester" ON "RiskPredictions"("OJTSemesterID");
CREATE INDEX "IX_RiskPredictions_Level" ON "RiskPredictions"("RiskLevel");
CREATE INDEX "IX_RiskPredictions_PredictedAt" ON "RiskPredictions"("PredictedAt");
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
('AI_RISK_VIEW', 'View AI risk prediction', 'View student risk predictions'),
('AI_CONFIG', 'Configure AI', 'Configure AI model thresholds'),
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
        'AI_RISK_VIEW',
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
        'SUPPORT_REQUEST',
        'AI_RISK_VIEW'
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
ALTER TABLE "AIModelConfig" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "AIModelConfig" FROM PUBLIC;
ALTER TABLE "AIModels" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "AIModels" FROM PUBLIC;
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
ALTER TABLE "RiskPredictions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "RiskPredictions" FROM PUBLIC;
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
-- END GENERATED SECURITY
COMMIT;
