CREATE VIEW [dbo].[vw_ViolatorStatus_Ban2ndLetterFlag] AS SELECT	INDICATOR_ID AS Ban2ndLetterFlag
,	INDICATOR as Ban2ndLetter
FROM	dbo.DIM_INDICATOR;
