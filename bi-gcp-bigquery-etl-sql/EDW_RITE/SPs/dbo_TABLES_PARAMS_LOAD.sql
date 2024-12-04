CREATE PROC [DBO].[TABLES_PARAMS_LOAD] AS

/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.TABLES_PARAMS_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.TABLES_PARAMS_LOAD
GO

EXEC DBO.TABLES_PARAMS_LOAD
*/

IF OBJECT_ID('dbo.TABLES_PARAMS') IS NOT NULL DROP TABLE dbo.TABLES_PARAMS

CREATE TABLE dbo.TABLES_PARAMS WITH (CLUSTERED INDEX (TABLE_NAME), DISTRIBUTION = REPLICATE) AS
WITH CTE_TABLES AS
(
	SELECT t.name AS TABLE_NAME
	FROM SYS.tables T
	JOIN SYS.schemas S ON S.schema_id = T.schema_id AND S.name = 'DBO'
	WHERE T.Name NOT LIKE 'CTE_%' AND T.Name NOT LIKE '%_OLD%' AND T.Name NOT LIKE '%_STAGE%' AND T.Name NOT LIKE '%_NEW%' AND T.Name NOT LIKE '%_SWITCH%' AND T.Name NOT LIKE '%_TRUNCATE%' AND T.Name NOT LIKE '%_PART%' AND T.Name NOT LIKE '%TEMP%' AND T.Name NOT LIKE '%_PREV%' AND T.Name NOT LIKE '%_FINAL%' AND T.Name NOT LIKE '%TEST%'
)
, CTE_TABLE_FULL_LOAD AS
(
	SELECT T.TABLE_NAME, ISNULL(PR.NAME,'') AS FULL_LOAD
	FROM CTE_TABLES AS T
	LEFT JOIN SYS.PROCEDURES AS PR ON PR.name = (T.TABLE_NAME + '_LOAD') -- AND PR.name NOT LIKE '%_INCR%'
)
, CTE_TABLE_INCR_LOAD AS
(
	SELECT T.TABLE_NAME, ISNULL(PR.NAME,'') AS INCR_LOAD
	FROM CTE_TABLES AS T
	LEFT JOIN SYS.PROCEDURES AS PR ON PR.name = (T.TABLE_NAME + '_INCR_LOAD') OR PR.name = (T.TABLE_NAME + '_LOAD_INCR')
)
, CTE_TABLE_STAGE_LOAD AS
(
	SELECT T.TABLE_NAME, ISNULL(PR.NAME,'') AS STAGE_LOAD
	FROM CTE_TABLES AS T
	LEFT JOIN SYS.PROCEDURES AS PR ON PR.name = (T.TABLE_NAME + '_STAGE_LOAD')
)
SELECT 'EDW_RITE' AS DB, T.TABLE_NAME, FULL_LOAD, INCR_LOAD, STAGE_LOAD, 
	CAST(0 AS BIGINT) AS NOMBER_ROWS, 0 AS MINUTES_TO_LOAD, CAST(NULL AS INT) AS LOAD_LEVEL
FROM CTE_TABLES AS T
JOIN CTE_TABLE_FULL_LOAD F ON F.TABLE_NAME = T.TABLE_NAME
JOIN CTE_TABLE_INCR_LOAD I ON I.TABLE_NAME = T.TABLE_NAME
JOIN CTE_TABLE_STAGE_LOAD S ON S.TABLE_NAME = T.TABLE_NAME


UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_CA_INVOICE_LOAD'
WHERE TABLE_NAME = 'FACT_CA_INVOICES'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_VIOLATION_PAYMENTS_LOAD'
	,INCR_LOAD = 'FACT_VIOLATION_PAYMENTS_INCR_LOAD'
WHERE TABLE_NAME = 'FACT_VIOLATION_PAYMENTS_SUMMARY'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_VIOLATION_PAYMENTS_LOAD'
	,INCR_LOAD = 'FACT_VIOLATION_PAYMENTS_INCR_LOAD'
WHERE TABLE_NAME = 'FACT_INVOICE_PAYMENTS'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_TRIPS_DATA_LOAD'
	,INCR_LOAD = 'FACT_TRIPS_DATA_INCR_LOAD'
WHERE TABLE_NAME = 'FACT_TRIPS_DETAIL'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_TRIPS_DATA_LOAD'
	,INCR_LOAD = 'FACT_TRIPS_DATA_INCR_LOAD'
WHERE TABLE_NAME = 'FACT_TRIPS_SUMMARY'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_TRIP_ANALYSIS_LOAD'
	,INCR_LOAD = ''
WHERE TABLE_NAME = 'FACT_TRIP_HISTORY'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_BALANCE_HISTORY_TGS_LOAD_NEW'
	,INCR_LOAD = ''
WHERE TABLE_NAME = 'FACT_BALANCE_HISTORY_TGS'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'BALANCE_HISTORY_TGS_COMPARE_LOAD'
	,INCR_LOAD = ''
WHERE TABLE_NAME = 'FACT_BALANCE_HISTORY_TGS_COMPARE'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_INVOICE_DETAIL_LOAD'
	,INCR_LOAD = 'FACT_INVOICE_ANALYSIS_AMT_PAID_ADJ_UPDATE_NEW'
	,STAGE_LOAD = 'FACT_INVOICE_DETAIL_STAGE_LOAD'
WHERE TABLE_NAME = 'FACT_INVOICE_ANALYSIS_DETAIL'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_INVOICE_LOAD'
	,INCR_LOAD = 'FACT_INVOICE_STAGE_FINAL_LOAD'
	,STAGE_LOAD = 'FACT_INVOICE_STAGE_LOAD'
WHERE TABLE_NAME = 'FACT_INVOICE_ANALYSIS'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_MISCLASS_LOAD'
	,INCR_LOAD = ''
WHERE TABLE_NAME = 'FACT_MISCLASS_ICRS'


UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_UNIFIED_VIOLATION_SNAPSHOT_FINAL_LOAD'
	,INCR_LOAD = ''
	,STAGE_LOAD = 'FACT_UNIFIED_VIOLATION_SNAPSHOT_STAGE_LOAD'
WHERE TABLE_NAME = 'FACT_UNIFIED_VIOLATION_SNAPSHOT'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_UNIFIED_VIOLATION_SNAPSHOT_FINAL_LOAD'
	,INCR_LOAD = ''
	,STAGE_LOAD = 'FACT_UNIFIED_VIOLATION_SNAPSHOT_STAGE_LOAD'
WHERE TABLE_NAME = 'FACT_UNIFIED_VIOLATION_HISTORY'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_INVOICE_DETAIL_MISSING_VPS_HOST_TRANS_LOAD_NEW'
WHERE FULL_LOAD = 'FACT_INVOICE_DETAIL_MISSING_VPS_HOST_TRANS_LOAD'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_TART_FINAL_LOAD'
	,INCR_LOAD = ''
	,STAGE_LOAD = 'FACT_TART_STAGE_LOAD'
WHERE TABLE_NAME = 'FACT_TART_SNAPSHOT'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_TART_FINAL_LOAD'
	,INCR_LOAD = ''
	,STAGE_LOAD = 'FACT_TART_STAGE_LOAD'
WHERE TABLE_NAME = 'FACT_TART_HISTORY'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_TART_FINAL_LOAD'
	,INCR_LOAD = ''
	,STAGE_LOAD = 'FACT_TART_STAGE_LOAD'
WHERE TABLE_NAME = 'FACT_TART_HISTORY'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_LOAD'
	,INCR_LOAD = 'FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_DAILY_LOAD'
	,STAGE_LOAD = ''
WHERE TABLE_NAME = 'FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_LOAD'
	,INCR_LOAD = ''
	,STAGE_LOAD = ''
WHERE TABLE_NAME = 'FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_HIST'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_TART_SUMMARY_CATEGORY_LEVEL_LOAD'
	,INCR_LOAD = 'FACT_TART_SUMMARY_CATEGORY_LEVEL_DAILY_LOAD'
	,STAGE_LOAD = ''
WHERE TABLE_NAME = 'FACT_TART_SUMMARY_CATEGORY_LEVEL'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'FACT_TART_SUMMARY_CATEGORY_LEVEL_LOAD'
	,INCR_LOAD = ''
	,STAGE_LOAD = ''
WHERE TABLE_NAME = 'FACT_TART_SUMMARY_CATEGORY_LEVEL_HIST'

UPDATE dbo.TABLES_PARAMS
SET FULL_LOAD = 'TOTAL_NET_REV_TFC_EVTS_FIRST_LOAD'
	,INCR_LOAD = 'TOTAL_NET_REV_TFC_EVTS_LOAD'
	,STAGE_LOAD = ''
WHERE TABLE_NAME = 'TOTAL_NET_REV_TFC_EVTS'

UPDATE dbo.TABLES_PARAMS
SET INCR_LOAD = ''
WHERE TABLE_NAME = 'FACT_TER_INVOICE'


--GO

--USE EDW_TER
--GO

--IF OBJECT_ID('dbo.TABLES_PARAMS') IS NOT NULL DROP TABLE dbo.TABLES_PARAMS

--CREATE TABLE dbo.TABLES_PARAMS WITH (CLUSTERED INDEX (TABLE_NAME), DISTRIBUTION = REPLICATE) AS
--WITH CTE_TABLES AS
--(
--	SELECT t.name AS TABLE_NAME
--	FROM SYS.tables T
--	JOIN SYS.schemas S ON S.schema_id = T.schema_id AND S.name = 'DBO'
--	WHERE T.Name NOT LIKE 'CTE_%' AND T.Name NOT LIKE '%_OLD%' AND T.Name NOT LIKE '%_STAGE%' AND T.Name NOT LIKE '%_NEW%' AND T.Name NOT LIKE '%_SWITCH%' AND T.Name NOT LIKE '%_TRUNCATE%' AND T.Name NOT LIKE '%_PART%' AND T.Name NOT LIKE '%TEMP%' AND T.Name NOT LIKE '%_PREV%' AND T.Name NOT LIKE '%_FINAL%' AND T.Name NOT LIKE '%TEST%'
--)
--, CTE_TABLE_FULL_LOAD AS
--(
--	SELECT T.TABLE_NAME, ISNULL(PR.NAME,'') AS FULL_LOAD
--	FROM CTE_TABLES AS T
--	LEFT JOIN SYS.PROCEDURES AS PR ON PR.name = (T.TABLE_NAME + '_LOAD') -- AND PR.name NOT LIKE '%_INCR%'
--)
--, CTE_TABLE_INCR_LOAD AS
--(
--	SELECT T.TABLE_NAME, ISNULL(PR.NAME,'') AS INCR_LOAD
--	FROM CTE_TABLES AS T
--	LEFT JOIN SYS.PROCEDURES AS PR ON PR.name = (T.TABLE_NAME + '_INCR_LOAD') OR PR.name = (T.TABLE_NAME + '_LOAD_INCR')
--)
--, CTE_TABLE_STAGE_LOAD AS
--(
--	SELECT T.TABLE_NAME, ISNULL(PR.NAME,'') AS STAGE_LOAD
--	FROM CTE_TABLES AS T
--	LEFT JOIN SYS.PROCEDURES AS PR ON PR.name = (T.TABLE_NAME + '_STAGE_LOAD')
--)
--SELECT 'EDW_RITE' AS DB, T.TABLE_NAME, FULL_LOAD, INCR_LOAD, STAGE_LOAD, 
--	CAST(0 AS BIGINT) AS NOMBER_ROWS, 0 AS MINUTES_TO_LOAD, CAST(NULL AS INT) AS LOAD_LEVEL
--FROM CTE_TABLES AS T
--JOIN CTE_TABLE_FULL_LOAD F ON F.TABLE_NAME = T.TABLE_NAME
--JOIN CTE_TABLE_INCR_LOAD I ON I.TABLE_NAME = T.TABLE_NAME
--JOIN CTE_TABLE_STAGE_LOAD S ON S.TABLE_NAME = T.TABLE_NAME

--GO

--USE EDW_RITE
--GO

CREATE TABLE dbo.[TABLES_PARAMS_NEW_SET] WITH (CLUSTERED INDEX (DB, TABLE_NAME ), DISTRIBUTION = REPLICATE)
	AS 
	SELECT 
			 ISNULL(CAST('EDW_RITE' AS nvarchar(128)), '') AS DB
			, ISNULL(CAST(main_table.[TABLE_NAME] AS nvarchar(128)), '') AS [TABLE_NAME]
			, ISNULL(CAST(main_table.[FULL_LOAD] AS nvarchar(128)), '') AS [FULL_LOAD]
			, ISNULL(CAST(main_table.[INCR_LOAD] AS nvarchar(128)), '') AS [INCR_LOAD]
			, ISNULL(CAST(main_table.[STAGE_LOAD] AS nvarchar(128)), '') AS [STAGE_LOAD]
			, CAST(main_table.[NOMBER_ROWS] AS bigint) AS [NOMBER_ROWS]
			, ISNULL(CAST(main_table.[MINUTES_TO_LOAD] AS int), 0) AS [MINUTES_TO_LOAD]
			, CAST(main_table.[LOAD_LEVEL] AS int) AS [LOAD_LEVEL]
	FROM dbo.[TABLES_PARAMS] AS main_table
	UNION ALL
	SELECT 
			 ISNULL(CAST('EDW_TER' AS nvarchar(128)), '') AS DB
			, ISNULL(CAST(main_table.[TABLE_NAME] AS nvarchar(128)), '') AS [TABLE_NAME]
			, ISNULL(CAST(main_table.[FULL_LOAD] AS nvarchar(128)), '') AS [FULL_LOAD]
			, ISNULL(CAST(main_table.[INCR_LOAD] AS nvarchar(128)), '') AS [INCR_LOAD]
			, ISNULL(CAST(main_table.[STAGE_LOAD] AS nvarchar(128)), '') AS [STAGE_LOAD]
			, CAST(main_table.[NOMBER_ROWS] AS bigint) AS [NOMBER_ROWS]
			, ISNULL(CAST(main_table.[MINUTES_TO_LOAD] AS int), 0) AS [MINUTES_TO_LOAD]
			, CAST(main_table.[LOAD_LEVEL] AS int) AS [LOAD_LEVEL]
	FROM EDW_TER.dbo.[TABLES_PARAMS] AS main_table

    
	IF OBJECT_ID('dbo.[TABLES_PARAMS_OLD]') IS NOT NULL		DROP TABLE dbo.[TABLES_PARAMS_OLD];
	IF OBJECT_ID('dbo.[TABLES_PARAMS]') IS NOT NULL			RENAME OBJECT::dbo.[TABLES_PARAMS] TO [TABLES_PARAMS_OLD];
	IF OBJECT_ID('dbo.[TABLES_PARAMS_NEW_SET]') IS NOT NULL		RENAME OBJECT::dbo.[TABLES_PARAMS_NEW_SET] TO [TABLES_PARAMS];
	IF OBJECT_ID('dbo.[TABLES_PARAMS_OLD]') IS NOT NULL		DROP TABLE dbo.[TABLES_PARAMS_OLD];


/*
CREATE TABLE dbo.[PROCEDURES_WITH_DEFINITIONS_NEW_SET] WITH (CLUSTERED INDEX ( DB, [PROC_NAME] ), DISTRIBUTION = REPLICATE)
	AS 
	SELECT 
			CAST('EDW_RITE' AS varchar(128)) AS DB
			, CAST(main_table.[PROC_NAME] AS varchar(200)) AS [PROC_NAME]
			, CAST(main_table.[PROC_DEFINITION] AS varchar(MAX)) AS [PROC_DEFINITION]
			, CAST(main_table.[NO_COMMENTS_DEFINITION] AS varchar(MAX)) AS [NO_COMMENTS_DEFINITION]
	FROM dbo.[PROCEDURES_WITH_DEFINITIONS] AS main_table
	UNION ALL
	SELECT 
			CAST('EDW_TER' AS varchar(128)) AS DB
			, CAST(main_table.[PROC_NAME] AS varchar(200)) AS [PROC_NAME]
			, CAST(main_table.[PROC_DEFINITION] AS varchar(MAX)) AS [PROC_DEFINITION]
			, CAST(main_table.[NO_COMMENTS_DEFINITION] AS varchar(MAX)) AS [NO_COMMENTS_DEFINITION]
	FROM EDW_TER_DEV.dbo.[PROCEDURES_WITH_DEFINITIONS] AS main_table
	OPTION (LABEL = 'PROCEDURES_WITH_DEFINITIONS_NEW_SET LOAD');

 

	IF OBJECT_ID('dbo.[PROCEDURES_WITH_DEFINITIONS_OLD]') IS NOT NULL		DROP TABLE dbo.[PROCEDURES_WITH_DEFINITIONS_OLD];
	IF OBJECT_ID('dbo.[PROCEDURES_WITH_DEFINITIONS]') IS NOT NULL			RENAME OBJECT::dbo.[PROCEDURES_WITH_DEFINITIONS] TO [PROCEDURES_WITH_DEFINITIONS_OLD];
	IF OBJECT_ID('dbo.[PROCEDURES_WITH_DEFINITIONS_NEW_SET]') IS NOT NULL		RENAME OBJECT::dbo.[PROCEDURES_WITH_DEFINITIONS_NEW_SET] TO [PROCEDURES_WITH_DEFINITIONS];
	IF OBJECT_ID('dbo.[PROCEDURES_WITH_DEFINITIONS_OLD]') IS NOT NULL		DROP TABLE dbo.[PROCEDURES_WITH_DEFINITIONS_OLD];
*/

--SELECT * 
--FROM dbo.TABLES_PARAMS
--WHERE FULL_LOAD = ''

IF OBJECT_ID('dbo.TABLES_IN_USE') IS NOT NULL DROP TABLE dbo.TABLES_IN_USE

CREATE TABLE dbo.TABLES_IN_USE WITH (CLUSTERED INDEX (TABLE_NAME,USE_IN_PROC), DISTRIBUTION = REPLICATE) AS
WITH CTE_TABLES AS
(
	SELECT DB,TABLE_NAME, FULL_LOAD, INCR_LOAD, STAGE_LOAD 
	FROM dbo.TABLES_PARAMS
)
-- Look in the same database
SELECT T.DB, T.TABLE_NAME, P.DB AS USE_IN_DB, P.TABLE_NAME AS USE_IN_TABLE, P.PROC_NAME AS USE_IN_PROC
FROM CTE_TABLES AS T 
LEFT JOIN (
			SELECT DB,FULL_LOAD AS PROC_NAME, TABLE_NAME FROM CTE_TABLES 
			UNION ALL
			SELECT DB,INCR_LOAD AS PROC_NAME, TABLE_NAME FROM CTE_TABLES WHERE INCR_LOAD <> ''
			UNION ALL
			SELECT DB,STAGE_LOAD AS PROC_NAME, TABLE_NAME FROM CTE_TABLES WHERE STAGE_LOAD <> ''
			) P ON P.DB = T.DB AND (P.TABLE_NAME <> T.TABLE_NAME AND P.PROC_NAME <> T.FULL_LOAD AND P.PROC_NAME <> T.INCR_LOAD AND P.PROC_NAME <> T.STAGE_LOAD)
LEFT JOIN (
			SELECT DB, PROC_NAME, REPLACE(P.NO_COMMENTS_DEFINITION, DBS.ANOTHER_DB + '.dbo.', DBS.ANOTHER_DB + '..') AS NO_COMMENTS_DEFINITION
			FROM dbo.PROCEDURES_WITH_DEFINITIONS P
			LEFT JOIN (SELECT DB AS ANOTHER_DB 		FROM dbo.PROCEDURES_WITH_DEFINITIONS 		GROUP BY DB) AS DBS ON DBS.ANOTHER_DB <> P.DB
		) AS PR ON PR.PROC_NAME = P.PROC_NAME AND 
(PR.DB = T.DB AND (PR.NO_COMMENTS_DEFINITION LIKE ('%dbo.' + T.TABLE_NAME + ' %') OR PR.NO_COMMENTS_DEFINITION LIKE ('%dbo.' + T.TABLE_NAME + '	%') OR PR.NO_COMMENTS_DEFINITION LIKE ('%dbo.' + T.TABLE_NAME + CHAR(13) + '%') OR PR.NO_COMMENTS_DEFINITION LIKE ('%dbo.' + T.TABLE_NAME + ';%') OR PR.NO_COMMENTS_DEFINITION LIKE ('%dbo.' + T.TABLE_NAME + ')%') OR PR.NO_COMMENTS_DEFINITION LIKE ('%dbo.' + T.TABLE_NAME)))
WHERE PR.PROC_NAME IS NOT NULL

UNION ALL

-- Look in the other database
--WITH CTE_TABLES AS
--(
--	SELECT DB,TABLE_NAME, FULL_LOAD, INCR_LOAD, STAGE_LOAD 
--	FROM dbo.TABLES_PARAMS
--)
SELECT T.DB, T.TABLE_NAME, P.DB AS USE_IN_DB, P.TABLE_NAME AS USE_IN_TABLE, P.PROC_NAME AS USE_IN_PROC
FROM CTE_TABLES AS T
LEFT JOIN (
			SELECT DB,FULL_LOAD AS PROC_NAME, TABLE_NAME FROM CTE_TABLES 
			UNION ALL
			SELECT DB,INCR_LOAD AS PROC_NAME, TABLE_NAME FROM CTE_TABLES WHERE INCR_LOAD <> ''
			UNION ALL
			SELECT DB,STAGE_LOAD AS PROC_NAME, TABLE_NAME FROM CTE_TABLES WHERE STAGE_LOAD <> ''
			) P ON P.DB <> T.DB
LEFT JOIN dbo.PROCEDURES_WITH_DEFINITIONS AS PR ON PR.PROC_NAME = P.PROC_NAME AND 
(PR.DB <> T.DB AND (PR.NO_COMMENTS_DEFINITION LIKE ('%' + T.DB + '.dbo.' + T.TABLE_NAME + ' %') OR PR.NO_COMMENTS_DEFINITION LIKE ('%' + T.DB + '.dbo.' + T.TABLE_NAME + '	%') OR PR.NO_COMMENTS_DEFINITION LIKE ('%' + T.DB + '.dbo.' + T.TABLE_NAME + CHAR(13) + '%') OR PR.NO_COMMENTS_DEFINITION LIKE ('%' + T.DB + '.dbo.' + T.TABLE_NAME + ';%') OR PR.NO_COMMENTS_DEFINITION LIKE ('%' + T.DB + '.dbo.' + T.TABLE_NAME + ')%') OR PR.NO_COMMENTS_DEFINITION LIKE ('%' + T.DB + '.dbo.' + T.TABLE_NAME)))
WHERE PR.PROC_NAME IS NOT NULL

--DELETE FROM  dbo.TABLES_IN_USE
--WHERE USE_IN_PROC = 'FACT_TER_INVOICE_LOAD_INCR'

UPDATE dbo.TABLES_PARAMS
SET LOAD_LEVEL = NULL

DECLARE @LOAD_LEVEL INT = 0
DECLARE @STOP BIT = 0
DECLARE @ROW_COUNT BIGINT = 0

WHILE @STOP = 0
BEGIN

	IF OBJECT_ID('tempdb..#LoadLevel') IS NOT NULL DROP TABLE #LoadLevel

	SELECT 
		P.DB, P.TABLE_NAME
	INTO #LoadLevel
	FROM dbo.TABLES_PARAMS P
	WHERE NOT EXISTS (SELECT 1 FROM dbo.TABLES_IN_USE U JOIN dbo.TABLES_PARAMS T ON T.DB = U.DB AND T.TABLE_NAME = U.TABLE_NAME AND T.LOAD_LEVEL IS NULL WHERE U.USE_IN_DB = P.DB AND U.USE_IN_TABLE = P.TABLE_NAME) 
		AND P.LOAD_LEVEL IS NULL

	EXEC	dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT


	IF @ROW_COUNT > 0
	BEGIN
		PRINT @LOAD_LEVEL

		UPDATE dbo.TABLES_PARAMS
		SET LOAD_LEVEL = @LOAD_LEVEL
		FROM #LoadLevel P
		WHERE TABLES_PARAMS.DB = P.DB AND TABLES_PARAMS.TABLE_NAME = P.TABLE_NAME

		SET @LOAD_LEVEL += 1 
	END
	ELSE SET @STOP = 1

END


/*

SELECT 	*
FROM dbo.TABLES_PARAMS P
ORDER BY LOAD_LEVEL

SELECT 	*
FROM dbo.TABLES_PARAMS P
LEFT JOIN (
			SELECT U.TABLE_NAME AS USING_TABLE, U.DB AS USING_DB, U.USE_IN_DB, U.USE_IN_TABLE, U.USE_IN_PROC 
			FROM dbo.TABLES_IN_USE U 
			JOIN dbo.TABLES_PARAMS T ON T.DB = U.DB AND T.TABLE_NAME = U.TABLE_NAME AND T.LOAD_LEVEL IS NULL
			) U ON U.USE_IN_DB = P.DB AND U.USE_IN_TABLE = P.TABLE_NAME  
WHERE P.LOAD_LEVEL IS NULL
ORDER BY TABLE_NAME

SELECT * FROM dbo.TABLES_IN_USE U JOIN dbo.TABLES_PARAMS T ON T.TABLE_NAME = U.TABLE_NAME AND T.LOAD_LEVEL IS NULL --WHERE U.USE_IN_TABLE = P.TABLE_NAME

*/


/*

DECLARE @Your_TABLE NVARCHAR(128) = 'FACT_NET_REV_TFC_EVTS'

SELECT
	YOUR_TABLE, TABLE_YOU_TAKE_DATA_FROM, LOAD_LEVEL,FULL_LOAD,INCR_LOAD,STAGE_LOAD
FROM
(
SELECT
	U.USE_IN_TABLE AS YOUR_TABLE, U.TABLE_NAME AS TABLE_YOU_TAKE_DATA_FROM, P.LOAD_LEVEL,P.FULL_LOAD,P.INCR_LOAD,P.STAGE_LOAD
FROM [dbo].[TABLES_IN_USE] U
JOIN dbo.TABLES_PARAMS P ON P.TABLE_NAME = U.TABLE_NAME
LEFT JOIN [dbo].[TABLES_IN_USE] U1 ON U1.USE_IN_TABLE = P.TABLE_NAME
LEFT JOIN dbo.TABLES_PARAMS P1 ON P1.TABLE_NAME = U1.TABLE_NAME
WHERE U.USE_IN_TABLE = @Your_TABLE
UNION ALL
SELECT
	U.USE_IN_TABLE AS YOUR_TABLE, U1.TABLE_NAME AS TABLE_YOU_TAKE_DATA_FROM, P1.LOAD_LEVEL,P1.FULL_LOAD,P1.INCR_LOAD,P1.STAGE_LOAD
FROM [dbo].[TABLES_IN_USE] U
JOIN dbo.TABLES_PARAMS P ON P.TABLE_NAME = U.TABLE_NAME
JOIN [dbo].[TABLES_IN_USE] U1 ON U1.USE_IN_TABLE = P.TABLE_NAME
JOIN dbo.TABLES_PARAMS P1 ON P1.TABLE_NAME = U1.TABLE_NAME
WHERE U.USE_IN_TABLE = @Your_TABLE
UNION ALL
SELECT
	U.USE_IN_TABLE AS YOUR_TABLE, U2.TABLE_NAME AS TABLE_YOU_TAKE_DATA_FROM, P2.LOAD_LEVEL,P2.FULL_LOAD,P2.INCR_LOAD,P2.STAGE_LOAD
FROM [dbo].[TABLES_IN_USE] U
JOIN dbo.TABLES_PARAMS P ON P.TABLE_NAME = U.TABLE_NAME
JOIN [dbo].[TABLES_IN_USE] U1 ON U1.USE_IN_TABLE = P.TABLE_NAME
JOIN dbo.TABLES_PARAMS P1 ON P1.TABLE_NAME = U1.TABLE_NAME
JOIN [dbo].[TABLES_IN_USE] U2 ON U2.USE_IN_TABLE = P1.TABLE_NAME
JOIN dbo.TABLES_PARAMS P2 ON P2.TABLE_NAME = U2.TABLE_NAME
WHERE U.USE_IN_TABLE = @Your_TABLE
UNION ALL
SELECT
	U.USE_IN_TABLE AS YOUR_TABLE, U3.TABLE_NAME AS TABLE_YOU_TAKE_DATA_FROM, P3.LOAD_LEVEL,P3.FULL_LOAD,P3.INCR_LOAD,P3.STAGE_LOAD
FROM [dbo].[TABLES_IN_USE] U
JOIN dbo.TABLES_PARAMS P ON P.TABLE_NAME = U.TABLE_NAME
JOIN [dbo].[TABLES_IN_USE] U1 ON U1.USE_IN_TABLE = P.TABLE_NAME
JOIN dbo.TABLES_PARAMS P1 ON P1.TABLE_NAME = U1.TABLE_NAME
JOIN [dbo].[TABLES_IN_USE] U2 ON U2.USE_IN_TABLE = P1.TABLE_NAME
JOIN dbo.TABLES_PARAMS P2 ON P2.TABLE_NAME = U2.TABLE_NAME
JOIN [dbo].[TABLES_IN_USE] U3 ON U3.USE_IN_TABLE = P2.TABLE_NAME
JOIN dbo.TABLES_PARAMS P3 ON P3.TABLE_NAME = U3.TABLE_NAME
WHERE U.USE_IN_TABLE = @Your_TABLE
UNION ALL
SELECT
	U.USE_IN_TABLE AS YOUR_TABLE, U4.TABLE_NAME AS TABLE_YOU_TAKE_DATA_FROM, P4.LOAD_LEVEL,P4.FULL_LOAD,P4.INCR_LOAD,P4.STAGE_LOAD
FROM [dbo].[TABLES_IN_USE] U
JOIN dbo.TABLES_PARAMS P ON P.TABLE_NAME = U.TABLE_NAME
JOIN [dbo].[TABLES_IN_USE] U1 ON U1.USE_IN_TABLE = P.TABLE_NAME
JOIN dbo.TABLES_PARAMS P1 ON P1.TABLE_NAME = U1.TABLE_NAME
JOIN [dbo].[TABLES_IN_USE] U2 ON U2.USE_IN_TABLE = P1.TABLE_NAME
JOIN dbo.TABLES_PARAMS P2 ON P2.TABLE_NAME = U2.TABLE_NAME
JOIN [dbo].[TABLES_IN_USE] U3 ON U3.USE_IN_TABLE = P2.TABLE_NAME
JOIN dbo.TABLES_PARAMS P3 ON P3.TABLE_NAME = U3.TABLE_NAME
JOIN [dbo].[TABLES_IN_USE] U4 ON U4.USE_IN_TABLE = P3.TABLE_NAME
JOIN dbo.TABLES_PARAMS P4 ON P4.TABLE_NAME = U4.TABLE_NAME
WHERE U.USE_IN_TABLE = @Your_TABLE

-- Could be more - 11 levels we have now
) A
--GROUP BY U.TABLE_NAME, U.USE_IN_TABLE, P.LOAD_LEVEL,P.FULL_LOAD,P.INCR_LOAD,P.STAGE_LOAD
GROUP BY YOUR_TABLE, TABLE_YOU_TAKE_DATA_FROM, LOAD_LEVEL,FULL_LOAD,INCR_LOAD,STAGE_LOAD
ORDER BY LOAD_LEVEL ASC

--Find tables that use your table for load:

SELECT
	U.TABLE_NAME AS YOUR_TABLE, U.USE_IN_TABLE AS TABLE_THAT_USE_YOUR_TABLE, P.LOAD_LEVEL,P.FULL_LOAD,P.INCR_LOAD,P.STAGE_LOAD
FROM [dbo].[TABLES_IN_USE] U
JOIN dbo.TABLES_PARAMS P ON P.TABLE_NAME = U.USE_IN_TABLE
WHERE U.TABLE_NAME = @Your_TABLE
GROUP BY U.TABLE_NAME, U.USE_IN_TABLE, P.LOAD_LEVEL,P.FULL_LOAD,P.INCR_LOAD,P.STAGE_LOAD
ORDER BY P.LOAD_LEVEL ASC

*/


