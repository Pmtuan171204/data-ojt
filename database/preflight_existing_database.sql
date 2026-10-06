-- Run on the OLD supplied schema before 01_upgrade_it.sql.
-- Read-only. These queries should return ZERO rows; resolve issues before migration.
SET search_path=public;

SELECT r."RegistrationID",r."OJTSemesterID",r."PreferredPositionID",p."OJTSemesterID" AS "PositionSemester"
FROM "OJTRegistrations" r JOIN "InternshipPositions" p ON p."PositionID"=r."PreferredPositionID"
WHERE r."OJTSemesterID"<>p."OJTSemesterID";

SELECT c."CoordinationID",c."EnterpriseID",p."EnterpriseID" AS "PositionEnterprise",
 r."OJTSemesterID" AS "RegistrationSemester",p."OJTSemesterID" AS "PositionSemester"
FROM "StudentEnterpriseCoordination" c JOIN "OJTRegistrations" r USING ("RegistrationID")
JOIN "InternshipPositions" p USING ("PositionID")
WHERE c."EnterpriseID"<>p."EnterpriseID" OR r."OJTSemesterID"<>p."OJTSemesterID";

SELECT "CourseID","CourseCode","Credits" FROM "Courses" WHERE "Credits"<0;

-- Informational: exact mapping is still required after upgrade for these legacy programs.
SELECT p."ProgramID",p."ProgramCode",p."Specialty",count(s."StudentID") AS "Students"
FROM "TrainingPrograms" p LEFT JOIN "Students" s USING ("ProgramID") GROUP BY p."ProgramID" ORDER BY p."ProgramCode";
