-- Read-only verification after 07_external_matching.sql or the latest full install.
SELECT "Version","AppliedAt" FROM public."SchemaMigrations"
WHERE "Version"='20261006_external_matching';

WITH expected(name) AS (VALUES
 ('OJTEnterpriseImportBatches'),('OJTEnterpriseImportRows'),('MatchingSkills'),
 ('StudentCareerProfiles'),('StudentMatchingSkills'),('StudentCareerInterests'),
 ('OJTMatchingProfiles'),('MatchingProfileMajors'),('MatchingProfileSpecializations'),
 ('MatchingProfileJobRoles'),('MatchingProfileSkills'),('MatchingProfileCourses'),
 ('EmbeddingConfigurations'),('MatchingEmbeddings'),('MatchingRuns'),
 ('MatchingCandidates'),('MatchingAPICalls'),('MatchingRecommendations'),('MatchingRecommendationFeedback'))
SELECT e.name AS "Table",c.oid IS NOT NULL AS "Exists",c.relrowsecurity AS "RLSEnabled"
FROM expected e LEFT JOIN pg_class c ON c.oid=to_regclass(format('public.%I',e.name))
ORDER BY e.name;

SELECT 'Profiles' AS "Dataset",count(*) AS "Rows" FROM public."OJTMatchingProfiles"
UNION ALL SELECT 'Embeddings',count(*) FROM public."MatchingEmbeddings"
UNION ALL SELECT 'Runs',count(*) FROM public."MatchingRuns"
UNION ALL SELECT 'Recommendations',count(*) FROM public."MatchingRecommendations";
-- Zero counts are expected before importing profiles and implementing backend matching.
