CREATE VIEW [dbo].[vw_ViolatorStatus_DeterminationLetterFlag] AS SELECT  INDICATOR_ID AS DeterminationLetterFlag, INDICATOR as DeterminationLetter
FROM dbo.DIM_INDICATOR;
