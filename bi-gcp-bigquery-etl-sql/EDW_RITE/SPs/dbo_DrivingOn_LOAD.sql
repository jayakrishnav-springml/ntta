CREATE PROC [DBO].[DrivingOn_LOAD] @StartDate [DATETIME],@EndDate [DATETIME] AS 
	--DECLARE @StartDate [DATETIME] = '6/1/2018'
	--DECLARE @EndDate [DATETIME] = '9/30/2018'
	SET @EndDate = (SELECT DATEADD(SECOND, 86399, @EndDate)) --Set the End time to midnight

	--STEP#1: Load data using the filters to a table:
	IF OBJECT_ID('DrivingOn') IS NOT NULL--DROP TABLE #DrivingOn
		DROP TABLE dbo.DrivingOn

	CREATE TABLE dbo.DrivingOn WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([FACILITY_ABBREV])) AS
	SELECT --TOP(100) 
		   [TOLL_TRANSACTIONS].[ACCT_ID] [ACCT_ID], ZIP_CODE,
		   CASE 
			 WHEN ( [FACILITY_ABBREV] = 'AATT' OR [FACILITY_ABBREV] = 'DNT' OR 
					[FACILITY_ABBREV] = 'LLTB' OR [FACILITY_ABBREV] = 'MCLB' OR 
					[FACILITY_ABBREV] = 'PGBT' OR [FACILITY_ABBREV] = 'SRT')
					THEN 'System' 
			 WHEN ( [FACILITY_ABBREV] = 'PGBW' OR [FACILITY_ABBREV] = 'CTP')
					THEN 'SPS' 
			 WHEN ( [SUB_AGENCY_ABBREV] = 'TSA' OR [SUB_AGENCY_ABBREV] = '(NULL)' ) THEN [FACILITY_ABBREV] 
			 ELSE REPLACE([SUB_AGENCY_ABBREV], 'NTTA ', '') 
		   END  AS [FACILITY_ABBREV], COUNT_BIG(1) TXN_CNT--SELECT COUNT_BIG(1)
	FROM   EDW_RITE.[DBO].[FACT_TOLL_TRANSACTIONS] TOLL_TRANSACTIONS 
		   JOIN EDW_RITE.[DBO].[DIM_LANE]  ON [TOLL_TRANSACTIONS].[LANE_ID] = [DIM_LANE].[LANE_ID] 
		   JOIN EDW_RITE.[DBO].[ACCOUNTS]  ON [TOLL_TRANSACTIONS].[ACCT_ID] = [ACCOUNTS].[ACCT_ID] 
		   JOIN LND_LG_TS.[TAG_OWNER].[ACCOUNT_TYPES] ON [ACCOUNTS].[ACCT_TYPE_CODE] = [ACCOUNT_TYPES].[ACCT_TYPE_CODE] 
				AND POSTED_DATE BETWEEN @StartDate AND @EndDate --'1/1/2016' AND '12/31/2016 23:59:59' 
				AND CREDITED_FLAG = 'N' 
				AND ISNULL(TRANS_TYPE_ID, 99) != 102 --EXCLUDE PARKING TXNS 
				AND [DIM_LANE].[AGENCY_ID] = 2 
				AND REVENUE_FLAG = 'Y' 
				--AND [TOLL_TRANSACTIONS].ACCT_ID IN(2499486, 1842571)--4200629
	GROUP  BY [TOLL_TRANSACTIONS].[ACCT_ID], ZIP_CODE,
			  CASE 
			 WHEN ( [FACILITY_ABBREV] = 'AATT' OR [FACILITY_ABBREV] = 'DNT' OR 
					[FACILITY_ABBREV] = 'LLTB' OR [FACILITY_ABBREV] = 'MCLB' OR 
					[FACILITY_ABBREV] = 'PGBT' OR [FACILITY_ABBREV] = 'SRT')
					THEN 'System' 
			 WHEN ( [FACILITY_ABBREV] = 'PGBW' OR [FACILITY_ABBREV] = 'CTP')
					THEN 'SPS' 
				WHEN ( [SUB_AGENCY_ABBREV] = 'TSA' OR [SUB_AGENCY_ABBREV] = '(NULL)' ) THEN [FACILITY_ABBREV] 
				ELSE REPLACE([SUB_AGENCY_ABBREV], 'NTTA ', '') 
			  END
	OPTION (LABEL = 'Step#1 of 4: DrivingOn LOAD');
	--SELECT * FROM dbo.DrivingOn
	--No Data
	IF NOT EXISTS (SELECT TOP(1) [FACILITY_ABBREV] FROM dbo.DrivingOn)
		INSERT INTO dbo.DrivingOn VALUES(0, 'No Data for this selection criteria.' ) --PRINT '0 Records';

	--STEP#2: Identify all the FACILITY_ABBREV from above table:
	IF OBJECT_ID('FACILITY_ABBREV') IS NOT NULL--DROP TABLE #FACILITY_ABBREV
		DROP TABLE dbo.FACILITY_ABBREV

	CREATE TABLE dbo.FACILITY_ABBREV WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION =  HASH([FACILITY_ABBREV])) AS
	SELECT ROW_NUMBER() OVER(ORDER BY FACILITY_ABBREV ASC) ID, FACILITY_ABBREV FROM (SELECT DISTINCT FACILITY_ABBREV FROM dbo.DrivingOn) A 	OPTION (LABEL = 'Step#2 of 4: DrivingOn LOAD');
	--SELECT * FROM dbo.FACILITY_ABBREV

	--STEP#3: To make it flexible, we need to build dynamic SQL which picks all the FACILITY_ABBREV dynamically from a table:
	DECLARE @cols AS NVARCHAR(4000) = '',
			@IsNullcols AS NVARCHAR(4000) = '',
			@query  AS NVARCHAR(4000),
			@count  AS NVARCHAR(4000) = 1;

	DECLARE @norows int = (SELECT COUNT(1) FROM FACILITY_ABBREV);

	WHILE @count <= @norows
	BEGIN
			IF @cols = ''
			BEGIN
				SET @cols = (SELECT QUOTENAME(FACILITY_ABBREV) FROM FACILITY_ABBREV WHERE ID = @count);
				SET @IsNullcols = (SELECT 'ISNULL('+ QUOTENAME(FACILITY_ABBREV) + '+'','','''')' FROM FACILITY_ABBREV WHERE ID = @count);
			END
			ELSE
			BEGIN
				SET @cols += (SELECT ',' + QUOTENAME(FACILITY_ABBREV) FROM FACILITY_ABBREV WHERE ID = @count);
				SET @IsNullcols += (SELECT '+ISNULL('+QUOTENAME(FACILITY_ABBREV)+'+'','','''')' FROM FACILITY_ABBREV WHERE ID = @count);
			END
			SET @count = @count +1;
	END
	--PRINT @cols
	SET @IsNullcols = (SELECT 'SUBSTRING(' + @IsNullcols + ', 0, DATALENGTH(' + @IsNullcols + '))' )
	--PRINT @IsNullcols

	--STEP#4: Generate the dynamic SQL:
	SET @query = (SELECT 'SELECT Facility, ZIP_CODE, ACCT_ID, COUNT(Facility) [Count], SUM(TXN_CNT) TXN_CNT 
							FROM (SELECT ZIP_CODE, ACCT_ID,' + @IsNullcols +' AS Facility, TXN_CNT 
									FROM
										(SELECT     
											[ACCT_ID], ZIP_CODE,
											[FACILITY_ABBREV], TXN_CNT
										FROM dbo.DrivingOn)X
										PIVOT 
										(MAX(FACILITY_ABBREV)
											for [FACILITY_ABBREV] in (' + @cols + ')
										) P) Q GROUP BY ACCT_ID, ZIP_CODE, Facility ORDER BY 1 OPTION (LABEL = ''Step#3 of 4: DrivingOn LOAD'')' )
	PRINT @query
	--STEP#5: Generate the dynamic SQL:
	EXEC SP_EXECUTESQL @query

	IF OBJECT_ID('DrivingOn') IS NOT NULL--DROP TABLE #DrivingOn
		DROP TABLE dbo.DrivingOn
	IF OBJECT_ID('FACILITY_ABBREV') IS NOT NULL--DROP TABLE #FACILITY_ABBREV
		DROP TABLE dbo.FACILITY_ABBREV
	--EXEC [DBO].[DrivingOn_LOAD] '5/1/2018', '5/1/2018'

	--SELECT * FROM DrivingOn OPTION (LABEL = 'Step#4 of 4: DrivingOn LOAD')

