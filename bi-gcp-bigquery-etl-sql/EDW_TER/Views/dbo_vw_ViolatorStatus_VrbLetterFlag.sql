CREATE VIEW [dbo].[vw_ViolatorStatus_VrbLetterFlag] AS SELECT	INDICATOR_ID AS VrbLetterFlag
,	INDICATOR as VrbLetter
FROM	dbo.DIM_INDICATOR;
