CREATE VIEW [dbo].[vw_FACT_VIOLATIONS_CATEGORY_LEVEL] AS SELECT * FROM FACT_VIOLATIONS_SUMMARY_CATEGORY_LEVEL WHERE LEVEL_0 IS NOT NULL;
