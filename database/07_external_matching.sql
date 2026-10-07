-- ADDITIVE migration for the existing full database. Run once; no reset or student seed.
BEGIN;
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
COMMIT;
