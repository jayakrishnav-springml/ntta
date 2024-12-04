CREATE PROC [DBO].[LP_INSTATE_SKIPTRACE_HISTORY_LOAD] AS

DECLARE @GENERATION_MONTH INT, @CURRENT_MONTH INT = (YEAR(GETDATE()) * 100 + MONTH(GETDATE()))
SELECT @GENERATION_MONTH = MAX(GEN_MONTH) FROM DBO.LP_INSTATE_SKIPTRACE_HISTORY

--Step #1:  Is it First run or not
IF (@GENERATION_MONTH IS NULL OR @GENERATION_MONTH < @CURRENT_MONTH) 
BEGIN
	--Step #1-A :  Get current month data and store in Stage Table
		
	IF OBJECT_ID('dbo.LP_INSTATE_SKIPTRACE_HISTORY_STAGE') IS NOT NULL DROP TABLE dbo.LP_INSTATE_SKIPTRACE_HISTORY_STAGE
	CREATE TABLE dbo.LP_INSTATE_SKIPTRACE_HISTORY_STAGE WITH (HEAP, DISTRIBUTION = REPLICATE) AS  
	SELECT
		TOP 40000
		ROW_NUMBER() OVER(ORDER BY SUM(TOLL_DUE)DESC, A11.LIC_PLATE_NBR) AS LP_SEQ_NO,
		LIC_PLATE_NBR AS LIC_PLATE,
		LIC_PLATE_STATE AS LIC_PLATE_STATE,
		MIN(CAST(VIOL_DATE as date)) MIN_TXN_DATE,
		Sum(A11.TOLL_DUE) TOLL_DUE,
		GETDATE() GEN_DATE
	FROM
		DBO.FACT_VIOLATIONS_DETAIL A11
	WHERE
		A11.VIOL_STATUS IN
		(
			'ZH',
			'WJ',
			'A'
		)
		AND DMV_STS IN
		(
			'LP-NDMV'
		)
		AND A11.VIOL_DATE BETWEEN DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) - 12, 0) AND GETDATE()
		AND A11.LIC_PLATE_STATE IN
		(
			'TX'
		)
		AND A11.LIC_PLATE_NBR NOT IN
		(
			SELECT
				LIC_PLATE
			FROM
				DBO.LP_INSTATE_SKIPTRACE_HISTORY WHERE LP_FLAG = 1
		)
		AND A11.VIOLATOR_ID = - 1
	GROUP BY
		LIC_PLATE_NBR,
		LIC_PLATE_STATE
	HAVING
	( Sum(A11.TOLL_DUE) >= 2.5
		OR Count(VIOLATION_ID) >= 3.0 )
	
	SELECT 	@CURRENT_MONTH GEN_MONTH
			,LP_SEQ_NO
			,LIC_PLATE
			,LIC_PLATE_STATE
			,CONCAT(LIC_PLATE_STATE,'-',LIC_PLATE) ST_LP
			,MIN_TXN_DATE
			,TOLL_DUE
	FROM	DBO.LP_INSTATE_SKIPTRACE_HISTORY_STAGE 
	ORDER BY LP_SEQ_NO

	--Step #1-B :  Insert to history table from Stage Table for current month

	INSERT DBO.LP_INSTATE_SKIPTRACE_HISTORY (GEN_MONTH, LP_SEQ_NO, LIC_PLATE, LIC_PLATE_STATE, MIN_TXN_DATE, LP_FLAG, TOLL_DUE, GEN_DATE)
	SELECT 
		@CURRENT_MONTH AS GEN_MONTH,
		LP_SEQ_NO,
		LIC_PLATE,
		LIC_PLATE_STATE,
		MIN_TXN_DATE ,
		1 AS LP_FLAG,
		TOLL_DUE, 
		GEN_DATE
	FROM DBO.LP_INSTATE_SKIPTRACE_HISTORY_STAGE

	DROP TABLE DBO.LP_INSTATE_SKIPTRACE_HISTORY_STAGE;	
  
END 

ELSE

--Step #2A :  If data is already present get it from history table

	SELECT 	GEN_MONTH
			,LP_SEQ_NO
			,LIC_PLATE
			,LIC_PLATE_STATE
			,CONCAT(LIC_PLATE_STATE,'-',LIC_PLATE) ST_LP
			,MIN_TXN_DATE
			,TOLL_DUE
	FROM  DBO.LP_INSTATE_SKIPTRACE_HISTORY   
	WHERE GEN_MONTH = @CURRENT_MONTH
	ORDER BY LP_SEQ_NO

