CREATE VIEW [dbo].[vw_ViolatorStatus_BanLetterFlag] AS SELECT  INDICATOR_ID AS BanLetterFlag, INDICATOR as BanLetter
FROM dbo.DIM_INDICATOR;
