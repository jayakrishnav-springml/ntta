CREATE PROC [DBO].[AVI_TRANSACTIONS_LOAD_NEW] AS 
BEGIN

	--STEP #1: SET PARAMETER DATE
	DECLARE @UPDATE_DATE datetime 
	
	IF OBJECT_ID('dbo.AVI_TRANSACTIONS') IS NULL 
	BEGIN
	SET @UPDATE_DATE ='1900-01-01' 
	END

	ELSE
	BEGIN
	SET @UPDATE_DATE =(SELECT MAX(LAST_UPDATE_DATE) LAST_UPDATE_DATE FROM dbo.AVI_TRANSACTIONS)
	END
	--PRINT @UPDATE_DATE

	IF OBJECT_ID('dbo.AVI_TRANSACTIONS_NEW') > 0  DROP TABLE dbo.AVI_TRANSACTIONS_NEW


	--STEP #2: Create the NEW table with DISTRIBUTION = HASH([TRANSACTION_ID]--Stage Table
	CREATE TABLE dbo.[AVI_TRANSACTIONS_NEW] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TRANSACTION_ID]))
	AS 
	SELECT *
     FROM LND_LG_HOST.TXNOWNER.AVI_TRANSACTIONS
	 WHERE LND_LG_HOST.TXNOWNER.AVI_TRANSACTIONS.LAST_UPDATE_DATE > @UPDATE_DATE 

	CREATE STATISTICS STATS_AVI_TRANSACTIONS_NEW_001 ON AVI_TRANSACTIONS_NEW ([TRANSACTION_ID])

	   --select * from dbo.AVI_TRANSACTIONS_NEW


	--STEP #2a: INSERT MISSING ONES
	--create table structure
	IF OBJECT_ID('dbo.AVI_TRANSACTIONS') IS NULL
	BEGIN		
		CREATE TABLE dbo.[AVI_TRANSACTIONS] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TRANSACTION_ID]))
		AS 
		SELECT *
		FROM dbo.AVI_TRANSACTIONS_NEW where 1=2
		CREATE STATISTICS STATS_AVI_TRANSACTIONS_001 ON AVI_TRANSACTIONS ([TRANSACTION_ID])
	END

	--insert values
    INSERT INTO dbo.[AVI_TRANSACTIONS]

	SELECT 
	A.[TRANSACTION_ID], 
	A.[TRANSACTION_DATE], 
	A.[AGENCY_CODE], 
	A.[TAG_ID], 
	A.[PLAZA_ID], 
	A.[FACILITY_ID], 
	A.[LANE_ID], 
	A.[DISPOSITION], 
	A.[REASON_CODE], 
	A.[EARNED_CLASS], 
	A.[EARNED_REVENUE], 
	A.[POSTED_CLASS], 
	A.[POSTED_REVENUE], 
	A.[POSTED_DATE_TIME], 
	A.[SOURCE_CODE], 
	A.[TXID_ID], 
	A.[CREATION_DATE], 
	A.[ACCT_ID], 
	A.[TRANSACTION_FILE_DETAIL_ID], 
	A.[LAST_UPDATE_TYPE], 
	A.[LAST_UPDATE_DATE]

    FROM  dbo.AVI_TRANSACTIONS_NEW A
    LEFT JOIN  dbo.[AVI_TRANSACTIONS] B ON A.TRANSACTION_ID = B.TRANSACTION_ID
    WHERE B.TRANSACTION_ID IS NULL;

	--STEP #2b: UPDATE THE CHANGED ONES
	UPDATE dbo.[AVI_TRANSACTIONS] 
	SET
       
	dbo.[AVI_TRANSACTIONS].[TRANSACTION_DATE] 			   = B.[TRANSACTION_DATE],			
	dbo.[AVI_TRANSACTIONS].[AGENCY_CODE] 				   = B.[AGENCY_CODE], 				
	dbo.[AVI_TRANSACTIONS].[TAG_ID] 					   = B.[TAG_ID], 					
	dbo.[AVI_TRANSACTIONS].[PLAZA_ID] 					   = B.[PLAZA_ID], 					
	dbo.[AVI_TRANSACTIONS].[FACILITY_ID] 				   = B.[FACILITY_ID], 				
	dbo.[AVI_TRANSACTIONS].[LANE_ID] 					   = B.[LANE_ID], 					
	dbo.[AVI_TRANSACTIONS].[DISPOSITION] 				   = B.[DISPOSITION], 				
	dbo.[AVI_TRANSACTIONS].[REASON_CODE] 				   = B.[REASON_CODE], 				
	dbo.[AVI_TRANSACTIONS].[EARNED_CLASS] 				   = B.[EARNED_CLASS], 				
	dbo.[AVI_TRANSACTIONS].[EARNED_REVENUE] 			   = B.[EARNED_REVENUE], 			
	dbo.[AVI_TRANSACTIONS].[POSTED_CLASS] 				   = B.[POSTED_CLASS], 				
	dbo.[AVI_TRANSACTIONS].[POSTED_REVENUE] 			   = B.[POSTED_REVENUE], 			
	dbo.[AVI_TRANSACTIONS].[POSTED_DATE_TIME] 			   = B.[POSTED_DATE_TIME], 			
	dbo.[AVI_TRANSACTIONS].[SOURCE_CODE] 				   = B.[SOURCE_CODE], 				
	dbo.[AVI_TRANSACTIONS].[TXID_ID] 					   = B.[TXID_ID], 					
	dbo.[AVI_TRANSACTIONS].[CREATION_DATE] 				   = B.[CREATION_DATE], 				
	dbo.[AVI_TRANSACTIONS].[ACCT_ID] 					   = B.[ACCT_ID], 					
	dbo.[AVI_TRANSACTIONS].[TRANSACTION_FILE_DETAIL_ID]    = B.[TRANSACTION_FILE_DETAIL_ID], 
	dbo.[AVI_TRANSACTIONS].[LAST_UPDATE_TYPE] 			   = B.[LAST_UPDATE_TYPE], 			
	dbo.[AVI_TRANSACTIONS].[LAST_UPDATE_DATE]			   = B.[LAST_UPDATE_DATE]			
    
	FROM dbo.AVI_TRANSACTIONS_NEW B
	WHERE dbo.[AVI_TRANSACTIONS].TRANSACTION_ID=B.TRANSACTION_ID
	AND B.LAST_UPDATE_DATE>@UPDATE_DATE
	AND 
	checksum
	( 
	dbo.[AVI_TRANSACTIONS].[TRANSACTION_DATE], 			
	dbo.[AVI_TRANSACTIONS].[AGENCY_CODE], 				
	dbo.[AVI_TRANSACTIONS].[TAG_ID], 					
	dbo.[AVI_TRANSACTIONS].[PLAZA_ID], 					
	dbo.[AVI_TRANSACTIONS].[FACILITY_ID],				
	dbo.[AVI_TRANSACTIONS].[LANE_ID], 					
	dbo.[AVI_TRANSACTIONS].[DISPOSITION], 				
	dbo.[AVI_TRANSACTIONS].[REASON_CODE], 				
	dbo.[AVI_TRANSACTIONS].[EARNED_CLASS], 				
	dbo.[AVI_TRANSACTIONS].[EARNED_REVENUE], 			
	dbo.[AVI_TRANSACTIONS].[POSTED_CLASS], 				
	dbo.[AVI_TRANSACTIONS].[POSTED_REVENUE], 			
	dbo.[AVI_TRANSACTIONS].[POSTED_DATE_TIME], 			
	dbo.[AVI_TRANSACTIONS].[SOURCE_CODE], 				
	dbo.[AVI_TRANSACTIONS].[TXID_ID], 					
	dbo.[AVI_TRANSACTIONS].[CREATION_DATE], 				
	dbo.[AVI_TRANSACTIONS].[ACCT_ID], 					
	dbo.[AVI_TRANSACTIONS].[TRANSACTION_FILE_DETAIL_ID], 
	dbo.[AVI_TRANSACTIONS].[LAST_UPDATE_TYPE], 			
	dbo.[AVI_TRANSACTIONS].[LAST_UPDATE_DATE]			
	)
	<>
	checksum
	(
	B.[TRANSACTION_DATE], 			
	B.[AGENCY_CODE], 				
	B.[TAG_ID], 					
	B.[PLAZA_ID], 					
	B.[FACILITY_ID], 				
	B.[LANE_ID], 					
	B.[DISPOSITION], 				
	B.[REASON_CODE], 				
	B.[EARNED_CLASS], 				
	B.[EARNED_REVENUE], 			
	B.[POSTED_CLASS], 				
	B.[POSTED_REVENUE], 			
	B.[POSTED_DATE_TIME], 			
	B.[SOURCE_CODE], 				
	B.[TXID_ID], 					
	B.[CREATION_DATE], 				
	B.[ACCT_ID], 					
	B.[TRANSACTION_FILE_DETAIL_ID], 
	B.[LAST_UPDATE_TYPE], 			
	B.[LAST_UPDATE_DATE]			
	)

--STEP #3: UPDATE STATISTICS
	UPDATE STATISTICS dbo.[AVI_TRANSACTIONS]
	IF OBJECT_ID('dbo.AVI_TRANSACTIONS_NEW')>0  DROP TABLE dbo.AVI_TRANSACTIONS_NEW

--STEP #4: Total Records
--SELECT COUNT_BIG(1) FROM LND_LG_HOST.TXNOWNER.AVI_TRANSACTIONS; 
END

