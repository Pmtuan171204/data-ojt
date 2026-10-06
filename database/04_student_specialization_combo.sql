-- Run once after 01_upgrade_it.sql. Keep selections normalized, not duplicated in Students.
BEGIN;
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
COMMIT;
