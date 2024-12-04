CREATE PROC [DBO].[FACT_NET_REV_TFC_EVTS_SUMMARY_INCR_LOAD] AS --DROP PROC [DBO].[FACT_NET_REV_TFC_EVTS_SUMMARY_INCR_LOAD]
--#1	Andy Filipps	2018-09-07	CREATED

	--STEP #0: --DROP table IF EXISTS 
	IF OBJECT_ID('DBO.FACT_NET_REV_TFC_EVTS_SUMMARY_SWITCH')>0 	DROP TABLE DBO.FACT_NET_REV_TFC_EVTS_SUMMARY_SWITCH;


	DECLARE @TEST INT = NULL
	DECLARE @FROM_DAYID INT = ISNULL(@TEST,(SELECT CONVERT(VARCHAR(10),DATEADD(DAY,1,MAX(DATEADD(MONTH,-1,DATA_AS_OF_DATE))),112)
							   FROM dbo.PARTITION_AS_OF_DATE_CONTROL
							   WHERE current_ind = 1)) 
    DECLARE @FROM_DATE DATETIME2 = CAST(CAST(@FROM_DAYID AS VARCHAR) AS DATETIME2)

	DECLARE @SQL_DDL NVARCHAR(MAX) = '
	CREATE TABLE dbo.FACT_NET_REV_TFC_EVTS_SUMMARY_SWITCH 
	WITH (PARTITION   ([DAY_ID] RANGE RIGHT FOR VALUES ('+cast(@FROM_DAYID as NVARCHAR)+'))  
	     ,CLUSTERED COLUMNSTORE INDEX
		 ,DISTRIBUTION = HASH([DAY_ID])) AS  --ROUND_ROBIN 
	--EXPLAIN
	SELECT	--TOP(100) 
			 DAY_ID
			,LANE_ID
			,PMTY_ID
			,VCLY_ID
			,LOCAL_TIME
			,(DATEPART(HH,Local_Time) * 3600) + (DATEPART(mi,Local_Time) * 60) + DATEPART(SS,Local_Time) AS TIME_ID
			,COUNT(TART_ID) TXN_CNT
			,SUM(EAR_REV) EAR_REV
			,SUM(COALESCE(IOP_TXNS_POSTED_REVENUE, AVIT_POSTED_REVENUE, ACT_REV)) ACT_REV
			--SELECT TOP(100) *--SELECT COUNT_BIG(1)
	FROM	dbo.FACT_NET_REV_TFC_EVTS
	WHERE DATE_TIME  >= '+CHAR(39)+cast(@FROM_DATE as NVARCHAR)+CHAR(39)+'
	GROUP BY DAY_ID
			,LANE_ID
			,PMTY_ID
			,VCLY_ID
			,LOCAL_TIME'

	----STEP #3: Replace OLD table with NEW

	--DECLARE @sqlRangeSplit NVARCHAR(MAX) = (select 'ALTER TABLE FACT_NET_REV_TFC_EVTS_SUMMARY_SWITCH SPLIT RANGE ('+cast(@FROM_DAYID as NVARCHAR)+')');
	EXEC (@SQL_DDL)

	IF OBJECT_ID('DBO.FACT_NET_REV_TFC_EVTS_SUMMARY_TRUNCATE')>0 	DROP TABLE DBO.FACT_NET_REV_TFC_EVTS_SUMMARY_TRUNCATE;

	CREATE TABLE dbo.FACT_NET_REV_TFC_EVTS_SUMMARY_TRUNCATE
	WITH (
	     CLUSTERED COLUMNSTORE INDEX
		 ,DISTRIBUTION = HASH([DAY_ID])) AS  --ROUND_ROBIN 
	SELECT * FROM dbo.FACT_NET_REV_TFC_EVTS_SUMMARY_SWITCH
	WHERE 1 = 2

    ALTER TABLE dbo.FACT_NET_REV_TFC_EVTS_SUMMARY SWITCH PARTITION 2 TO dbo.FACT_NET_REV_TFC_EVTS_SUMMARY_TRUNCATE PARTITION 1;	
	--SWITCH IN Incremental Load of recent data to FACT table
	ALTER TABLE dbo.FACT_NET_REV_TFC_EVTS_SUMMARY_SWITCH SWITCH PARTITION 2 TO dbo.FACT_NET_REV_TFC_EVTS_SUMMARY PARTITION 2;

	IF OBJECT_ID('DBO.FACT_NET_REV_TFC_EVTS_SUMMARY_TRUNCATE')>0 	DROP TABLE DBO.FACT_NET_REV_TFC_EVTS_SUMMARY_TRUNCATE;
	
	UPDATE STATISTICS dbo.FACT_NET_REV_TFC_EVTS_SUMMARY;


