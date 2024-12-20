CREATE PROC [DBO].[VPS_TGS_XREF_INCR_LOAD] AS 
BEGIN
----#1	ANDY FILIPPS	2018-09-07	Changed
	/*  APPROACH WAS CHANGED WITH USING CTE INSTEAD OF TEMP TABLES*/

	--STEP #1: Delete all temp tables

	IF OBJECT_ID('tempdb..#SourceSet') IS NOT NULL DROP TABLE #SourceSet
	IF OBJECT_ID('tempdb..#TargetSet') IS NOT NULL DROP TABLE #TargetSet
	IF OBJECT_ID('tempdb..#DiffSet') IS NOT NULL DROP TABLE #DiffSet

	DECLARE @LenOfCheck TINYINT = 5
	DECLARE @CutOffID decimal(14, 0) = CAST(LEFT('10000000000000', 1 + @LenOfCheck) AS decimal(14, 0))


	--STEP #2: Compare 2 sets to find all missed sets (by 4 first digits of ID)
	CREATE TABLE #DiffSet WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(ID_PREFIX)) AS
	WITH SourceSet AS
	(SELECT    
		CASE WHEN TT.TTXN_ID < @CutOffID THEN '0' ELSE LEFT(CAST(TT.TTXN_ID AS VARCHAR), @LenOfCheck) END AS ID_PREFIX
		, CASE WHEN TT.TTXN_ID < @CutOffID THEN @LenOfCheck ELSE LEN(TT.TTXN_ID) END AS LEN_ID
		, MIN(TT.TTXN_ID) AS Min_ID
		, MAX(TT.TTXN_ID) AS Max_ID
		, COUNT(TT.TTXN_ID) AS Count_ID
	FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS AS TT
	WHERE TT.SOURCE_CODE IN ('M','O','V','W','X','Z')
		AND	TT.CREDITED_FLAG =  'N'
	GROUP BY 
		CASE WHEN TT.TTXN_ID < @CutOffID THEN '0' ELSE LEFT(CAST(TT.TTXN_ID AS VARCHAR), @LenOfCheck) END
		, CASE WHEN TT.TTXN_ID < @CutOffID THEN @LenOfCheck ELSE LEN(TT.TTXN_ID) END
	)
	,TargetSet AS
	(SELECT    
		CASE WHEN TT.TTXN_ID < @CutOffID THEN '0' ELSE LEFT(CAST(TT.TTXN_ID AS VARCHAR), @LenOfCheck) END AS ID_PREFIX
		, CASE WHEN TT.TTXN_ID < @CutOffID THEN @LenOfCheck ELSE LEN(TT.TTXN_ID) END AS LEN_ID
		, COUNT(TT.TTXN_ID) AS Count_ID
	FROM EDW_RITE.dbo.VPS_TGS_XREF AS TT
	GROUP BY 
		CASE WHEN TT.TTXN_ID < @CutOffID THEN '0' ELSE LEFT(CAST(TT.TTXN_ID AS VARCHAR), @LenOfCheck) END
		, CASE WHEN TT.TTXN_ID < @CutOffID THEN @LenOfCheck ELSE LEN(TT.TTXN_ID) END
	)
	SELECT  
		SS.ID_PREFIX
		, SS.Min_ID
		, SS.Max_ID
		, SS.LEN_ID
	FROM SourceSet AS SS
	LEFT JOIN TargetSet AS TS
		ON SS.ID_PREFIX = TS.ID_PREFIX
		AND SS.Count_ID = TS.Count_ID
		AND SS.LEN_ID = TS.LEN_ID
	WHERE TS.ID_PREFIX IS NULL

	-- we use these variables to determin the while loop
	DECLARE @Min_Len TINYINT
		, @Max_Len TINYINT
	
	SELECT @Min_Len = MIN(MS.LEN_ID)
			, @Max_Len = MAX(MS.LEN_ID)
	FROM #DiffSet AS MS

	-- We use these variables for condition that can use index on the table
	DECLARE @Min_ID AS decimal(14, 0)
		, @Max_ID AS decimal(14, 0)

	--STEP #3: Using While loop find all new rows to add and insert them into main table

	-- Need this WHILE to use filter TT.TTXN_ID >= @MinID AND TT.TTXN_ID <= @MaxID that help a lot with performance
	-- Now and in future it should be only the rows with Len_ID = 10 (or more) and loop will work only once
	-- But use filter like WHERE TT.TTXN_ID >= 1 000 000 000 (half of the table) - not a universal approach 
	WHILE @Min_Len <= @Max_Len
	BEGIN
		
		IF OBJECT_ID('tempdb..#VPS_TGS_XREF_NEW') IS NOT NULL  DROP TABLE #VPS_TGS_XREF_NEW;

		SELECT @Min_ID = Min(MS.Min_ID) 
			, @Max_ID = Max(MS.Max_ID) 
		FROM #DiffSet AS MS
		WHERE MS.LEN_ID = @Min_Len

		IF (@Min_ID IS NOT NULL) 
		BEGIN
			CREATE TABLE #VPS_TGS_XREF_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TRANSACTION_ID))
			AS --EXPLAIN
			WITH CTE_TOLL_TRANS AS
			(SELECT CAST(TT.SOURCE_TRXN_ID AS DECIMAL(14, 0))  AS TRANSACTION_ID
				, TT.TTXN_ID AS TTXN_ID
			FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS AS TT	
			WHERE TT.TTXN_ID BETWEEN @Min_ID AND @Max_ID
				AND TT.SOURCE_CODE IN ('M','O','V','W','X','Z')
				AND	TT.CREDITED_FLAG =  'N'
			)
			,CTE_VPS_TGS_XREF AS
			(SELECT    
				DW_VPS.TRANSACTION_ID
				, DW_VPS.TTXN_ID AS TTXN_ID
			FROM EDW_RITE.dbo.VPS_TGS_XREF AS DW_VPS
			WHERE DW_VPS.TTXN_ID BETWEEN @Min_ID AND @Max_ID
			)
			SELECT TT.TRANSACTION_ID
				, TT.TTXN_ID AS TTXN_ID
			FROM #DiffSet AS MS
			INNER JOIN CTE_TOLL_TRANS AS TT
				ON TT.TTXN_ID BETWEEN MS.Min_ID AND MS.Max_ID
			WHERE MS.LEN_ID = @Min_Len 
			EXCEPT 
			SELECT    
				DW_VPS.TRANSACTION_ID
				, DW_VPS.TTXN_ID AS TTXN_ID
			FROM #DiffSet AS MS
			INNER JOIN CTE_VPS_TGS_XREF AS DW_VPS
				ON DW_VPS.TTXN_ID BETWEEN MS.Min_ID AND MS.Max_ID
			WHERE MS.LEN_ID = @Min_Len 
			OPTION (LABEL = 'VPS_TGS_XREF LOAD');

			----INSERT New rows INTO VPS_TGS_XREF table
			INSERT INTO EDW_RITE.dbo.VPS_TGS_XREF
			SELECT 
				A.TRANSACTION_ID, 
				A.TTXN_ID
			FROM	#VPS_TGS_XREF_NEW A

			SET @Min_Len += 1 
		END
		ELSE
		BEGIN
			SET @Min_Len += 1
			--CONTINUE; -- Somehow this returns an error and I have to use ELSE instead
		END
	END


	--STEP #4: UPDATE STATISTICS
	UPDATE STATISTICS EDW_RITE.dbo.[VPS_TGS_XREF]


END


