-- Additive OJT deadline alerts. No student seed, no AI prediction, no scheduled job.
BEGIN;
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
COMMIT;
