-- Run after migration 04. Expected after importing this CSV: 586 selected, 2414 blank.
-- Choices remain in StudentComboSelections; this exposes one CSV-shaped column to the backend.
SELECT s."StudentCode",p."ProgramCode",s."CurrentSemester",b."SourceComboID" AS "selected_combo_id",
 b."ComboCode",b."ComboName",sc."SelectionSource",sc."SelectedAt",
 CASE WHEN sc."SelectionID" IS NOT NULL THEN 'SELECTED'
      WHEN s."CurrentSemester"<4 THEN 'NOT_YET_OPEN'
      WHEN s."CurrentSemester"=4 THEN 'PENDING_CONFIRMATION'
      WHEN s."CurrentSemester">=5 THEN 'MISSING_SELECTION'
      ELSE 'UNKNOWN' END AS "SelectionStatus"
FROM "Students" s LEFT JOIN "TrainingPrograms" p ON p."ProgramID"=s."ProgramID"
LEFT JOIN "StudentComboSelections" sc ON sc."StudentID"=s."StudentID" AND sc."ProgramID"=s."ProgramID"
 AND sc."SelectionPurpose"='SPECIALIZATION'
LEFT JOIN "ProgramCombos" b ON b."ProgramComboID"=sc."ProgramComboID"
ORDER BY s."StudentCode";

SELECT s."CurrentSemester",count(*) AS "Students",count(sc."SelectionID") AS "Selected",
 count(*)-count(sc."SelectionID") AS "NotConfirmed"
FROM "Students" s LEFT JOIN "StudentComboSelections" sc ON sc."StudentID"=s."StudentID"
 AND sc."ProgramID"=s."ProgramID" AND sc."SelectionPurpose"='SPECIALIZATION'
GROUP BY s."CurrentSemester" ORDER BY 1;
