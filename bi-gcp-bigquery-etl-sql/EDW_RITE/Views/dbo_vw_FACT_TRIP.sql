CREATE VIEW [dbo].[vw_FACT_TRIP] AS SELECT --TOP 100 
		LIC_PLATE_NBR ACCT_LIC_PLATE, LIC_PLATE_STATE TAG_STATE,DAY_ID,TRIP_AMT,PLAZA_1,DIR_1,TXN_1,PLAZA_2,DIR_2,TXN_2,PLAZA_3,DIR_3,TXN_3,PLAZA_4,DIR_4,TXN_4,PLAZA_5,DIR_5,TXN_5,PLAZA_6,DIR_6,TXN_6,PLAZA_7,DIR_7,TXN_7,PLAZA_8,DIR_8,TXN_8,PLAZA_9,DIR_9,TXN_9,PLAZA_10,DIR_10,TXN_10,
		COALESCE([PLAZA_10],[PLAZA_9],[PLAZA_8],[PLAZA_7],[PLAZA_6],[PLAZA_5],[PLAZA_4],[PLAZA_3],[PLAZA_2],[PLAZA_1]) END_PLAZA, 'Video' AS TXN_TYPE
FROM dbo.FACT_TRIP_ICRS
UNION ALL
SELECT --TOP 10 
       CAST(ACCT_ID AS VARCHAR),TAG_ID,DAY_ID,TRIP_AMT,PLAZA_1,DIR_1,TXN_1,PLAZA_2,DIR_2,TXN_2,PLAZA_3,DIR_3,TXN_3,PLAZA_4,DIR_4,TXN_4,PLAZA_5,DIR_5,TXN_5,PLAZA_6,DIR_6,TXN_6,PLAZA_7,DIR_7,TXN_7,PLAZA_8,DIR_8,TXN_8,PLAZA_9,DIR_9,TXN_9,PLAZA_10,DIR_10,TXN_10,
	   COALESCE([PLAZA_10],[PLAZA_9],[PLAZA_8],[PLAZA_7],[PLAZA_6],[PLAZA_5],[PLAZA_4],[PLAZA_3],[PLAZA_2],[PLAZA_1]) END_PLAZA, 'Tag' AS TXN_TYPE
FROM dbo.FACT_TRIP;
