CREATE VIEW [dbo].[vw_ViolatorStatus_TermLetterFlag] AS SELECT  INDICATOR_ID AS TermLetterFlag, INDICATOR as TermLetter
FROM dbo.DIM_INDICATOR;
