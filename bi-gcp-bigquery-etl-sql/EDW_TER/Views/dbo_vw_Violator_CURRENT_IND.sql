CREATE VIEW [dbo].[vw_Violator_CURRENT_IND] AS SELECT 
		 INDICATOR_ID AS CURRENT_IND
		,INDICATOR AS CurrentViolatorCase
	FROM dbo.DIM_INDICATOR;
