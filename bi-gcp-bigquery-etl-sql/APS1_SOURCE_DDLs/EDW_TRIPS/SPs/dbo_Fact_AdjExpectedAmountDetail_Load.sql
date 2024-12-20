CREATE PROC [dbo].[Fact_AdjExpectedAmountDetail_Load] @IsFullLoad [BIT] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_AdjExpectedAmountDetail and dbo.Fact_AdjExpectedAmount tables which are important for Board Reporting
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040744	Shankar		2022-03-21	New!
CHG0041141	Shankar		2022-06-30	Filter TPTripIDs selected to reduce incr run payload
CHG0042644	Shankar		2023-03-01	Incremental load cleanup of invalid data in existing table
===================================================================================================================
Example:   
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_AdjExpectedAmountDetail_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_AdjExpectedAmount%' ORDER BY 1 DESC
SELECT * FROM Utility.LoadProcessControl WHERE TableName LIKE 'Fact_AdjExpectedAmountDetail%' ORDER BY 1

SELECT TOP 100 'dbo.Fact_AdjExpectedAmountDetail' Table_Name, TA.AdjustmentType,* 
FROM dbo.Fact_AdjExpectedAmountDetail AEA 
LEFT JOIN LND_TBOS.Finance.TollAdjustments TA ON AEA.TollAdjustmentID = TA.TollAdjustmentID 
WHERE TPTripID = 1938177625 
ORDER BY TxnSeqDesc Desc

SELECT TOP 100 'dbo.Fact_AdjExpectedAmount' Table_Name, * FROM dbo.Fact_AdjExpectedAmount WHERE TPTripID = 1938177625

SELECT COUNT(1) RC FROM Stage.Bubble_TPTripID
###################################################################################################################
*/

BEGIN
	BEGIN TRY

		/*=========================================== TESTING ========================================================*/
		--DECLARE @IsFullLoad BIT = 0
		/*=========================================== TESTING ========================================================*/

		DECLARE @TableName VARCHAR(100) = 'dbo.Fact_AdjExpectedAmountDetail', @StageTableName VARCHAR(100) = 'dbo.Fact_AdjExpectedAmountDetail_NEW', @IdentifyingColumns VARCHAR(100) = '[TPTripID]'
		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_AdjExpectedAmountDetail_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
		DECLARE @sql VARCHAR(MAX), @CreateTableWith VARCHAR(MAX)
		DECLARE @Last_TP_Trips_Date DATETIME2(3) = '2019-01-01', @Last_TP_CustomerTrips_Date DATETIME2(3) = '2019-01-01', @Last_TP_ViolatedTrips_Date DATETIME2(3) = '2019-01-01', @Last_BOS_IOP_OutboundTransactions_Date DATETIME2(3) = '2019-01-01' 
		DECLARE @Next_TP_Trips_Date DATETIME2(3), @Next_TP_CustomerTrips_Date DATETIME2(3), @Next_TP_ViolatedTrips_Date DATETIME2(3), @Next_BOS_IOP_OutboundTransactions_Date DATETIME2(3)
		DECLARE @FirstDateToLoad VARCHAR(30) = '2019-01-01', @LastDateToLoad VARCHAR(30) = SYSDATETIME(), @NoDataFlag BIT = 0
		DECLARE @Partition_Ranges VARCHAR(MAX), @FirstPartitionID INT = 201901, @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(SYSDATETIME(),1)),112) AS INT)
	
		IF OBJECT_ID(@TableName) IS NULL
			SET @IsFullLoad = 1

		IF @IsFullLoad = 1
		BEGIN
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_PartitionDayIDRange_String from ' + CAST(@FirstPartitionID AS VARCHAR(10))+ ' till ' + CAST(@LastPartitionID AS VARCHAR(10))
			EXEC Utility.Get_PartitionDayIDRange_String @FirstPartitionID, @LastPartitionID, @Partition_Ranges OUTPUT
			SET @CreateTableWith = '(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
			--SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID), PARTITION (DayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
			SET @Log_Message = 'Started full load'
			IF @Trace_Flag = 1 PRINT @Log_Message
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
		END
		ELSE
		BEGIN
			SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID))'
		
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_UpdatedDate for ''Fact_AdjExpectedAmountDetail~TP_Trips'''
			EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_Trips', @Last_TP_Trips_Date OUTPUT 
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_UpdatedDate for ''Fact_AdjExpectedAmountDetail~TP_CustomerTrips'''
			EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_CustomerTrips', @Last_TP_CustomerTrips_Date OUTPUT 
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_UpdatedDate for ''Fact_AdjExpectedAmountDetail~TP_ViolatedTrips'''
			EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', @Last_TP_ViolatedTrips_Date OUTPUT 
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_UpdatedDate for ''Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions'''
			EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', @Last_BOS_IOP_OutboundTransactions_Date OUTPUT 
		
			SET @Log_Message = 'Started incremental load: TP_Trips from ' + ISNULL(CONVERT(VARCHAR(25),@Last_TP_Trips_Date,121),'???') + ', TP_CustomerTrips from ' +  ISNULL(CONVERT(VARCHAR(25),@Last_TP_CustomerTrips_Date,121),'???') + 
							   ', TP_ViolatedTrips from ' +  ISNULL(CONVERT(VARCHAR(25),@Last_TP_ViolatedTrips_Date,121),'???') + ', BOS_IOP_OutboundTransactions from ' +  ISNULL(CONVERT(VARCHAR(25),@Last_BOS_IOP_OutboundTransactions_Date,121),'???') 
			IF @Trace_Flag = 1 PRINT @Log_Message
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
	
			--:: Get the TPTripIDs for incremental load
			IF OBJECT_ID('Stage.Bubble_TPTripID') IS NOT NULL DROP TABLE Stage.Bubble_TPTripID;
			CREATE TABLE Stage.Bubble_TPTripID WITH (CLUSTERED INDEX (TPTripID), DISTRIBUTION = HASH(TPTripID)) AS 
			SELECT TPTripID FROM LND_TBOS.TollPlus.TP_Trips  WHERE LND_UpdateDate > @Last_TP_Trips_Date AND SourceOfEntry IN (1,3) AND ExitTripDateTime >= @FirstDateToLoad AND Exit_TollTxnID >= 0 AND LND_UpdateType <> 'D'				UNION 
			SELECT TPTripID FROM LND_TBOS.TollPlus.TP_CustomerTrips WHERE LND_UpdateDate > @Last_TP_CustomerTrips_Date AND SourceOfEntry IN (1,3) AND ExitTripDateTime >= @FirstDateToLoad AND LND_UpdateType <> 'D'	UNION
			SELECT TPTripID FROM LND_TBOS.TollPlus.TP_ViolatedTrips WHERE LND_UpdateDate > @Last_TP_ViolatedTrips_Date AND ExitTripDateTime >= @FirstDateToLoad AND LND_UpdateType <> 'D'							UNION
			SELECT TPTripID FROM LND_TBOS.IOP.BOS_IOP_OutboundTransactions WHERE LND_UpdateDate > @Last_BOS_IOP_OutboundTransactions_Date AND TransactionStatus = 'Posted' AND LND_UpdateType <> 'D'
			OPTION (LABEL = 'Stage.Bubble_TPTripID with TPTripIDs for incremental load')

			SET  @Log_Message = 'Loaded Stage.Bubble_TPTripID with TPTripIDs for incremental load' 
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
			
			CREATE STATISTICS Stats_Stage_Bubble_TPTripID_001 ON Stage.Bubble_TPTripID (TpTripID)

			IF (SELECT COUNT(1) FROM Stage.Bubble_TPTripID) = 0	
			BEGIN
				SELECT @NoDataFlag = 1
				EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed incremental load: No data to load!', 'I', -1, NULL
			END 
		END

		--=============================================================================================================
		-- Load dbo.Fact_AdjExpectedAmountDetail
		--============================================================================================================
		IF @IsFullLoad = 1 OR (@IsFullLoad = 0 AND @NoDataFlag = 0)
		BEGIN
			SET @sql = '
			IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL		DROP TABLE ' + @StageTableName + ';
			CREATE TABLE ' + @StageTableName + ' WITH ' + @CreateTableWith + ' AS
			WITH CTE_AdjExpectedAmt AS
			(
				--:: CustomerTrips
				SELECT	T.TpTripID,
						TC.CustTripID AS CustTripID,
						CAST(NULL AS BIGINT) AS CitationID,
						CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
						CAST(CASE WHEN T.TripWith = ''C'' AND T.LinkID = TC.CustTripID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
						CAST(''TP_Customer_Trip_Charges_Tracker'' AS VARCHAR(40)) AS SourceName,
						CT.TripChargeID AS SourceID,
						CAST(NULL AS INT) AS TollAdjustmentID,
						CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
						CT.Amount,
						CT.CreatedDate TxnDate,
						TC.LND_UpdateDate
				FROM	LND_TBOS.TollPlus.TP_Trips T
				JOIN	LND_TBOS.TollPlus.TP_CustomerTrips TC
						ON TC.TpTripID = T.TpTripID
				JOIN	LND_TBOS.TollPlus.TP_Customer_Trip_Charges_Tracker CT
						ON CT.CustTripID = TC.CustTripID
				WHERE 1 = 1
						AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
						AND T.Exit_TollTxnID >= 0
						AND T.ExitTripDateTime >= ''' + @FirstDateToLoad + '''
						AND T.ExitTripDateTime <  ''' + @LastDateToLoad  + '''	
						AND T.LND_UpdateType <> ''D''
						AND TC.LND_UpdateType <> ''D''

				UNION ALL

				--:: CustomerTrip Adjustments
				SELECT	T.TpTripID,
						TC.CustTripID,
						CAST(NULL AS BIGINT) AS CitationID,
						CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
						CAST(CASE WHEN T.TripWith = ''C'' AND T.LinkID = TC.CustTripID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
						CAST(''Adjustment_LineItems'' AS VARCHAR(40)) SourceName,
						ALI.AdjustmentID,
						A.TollAdjustmentID, -- Key to get Finance.TollAdjustments.AdjustmentType,
						A.AdjustmentReason,
						CASE WHEN A.DrcrFlag = ''C'' THEN ALI.Amount*-1 ELSE ALI.Amount END AdjustmentLineItemAmount,
						A.ApprovedStatusDate,
						TC.LND_UpdateDate
				FROM	LND_TBOS.TollPlus.TP_Trips T
				JOIN	LND_TBOS.TollPlus.TP_CustomerTrips TC
						ON TC.TpTripID = T.TpTripID
				JOIN	LND_TBOS.Finance.Adjustment_LineItems ALI
						ON TC.CustTripID = ALI.LinkID
						AND ALI.LinkSourceName = ''TollPlus.TP_CustomerTrips''
				JOIN	LND_TBOS.Finance.Adjustments A
						ON A.AdjustmentID = ALI.AdjustmentID
						AND A.ApprovedStatusID = 466 -- Approved
				WHERE 1 = 1 
						AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
						AND T.Exit_TollTxnID >= 0
						AND T.ExitTripDateTime >= ''' + @FirstDateToLoad + '''
						AND T.ExitTripDateTime <  ''' + @LastDateToLoad  + '''
						AND T.LND_UpdateType <> ''D''
						AND TC.LND_UpdateType <> ''D''
						AND ALI.LND_UpdateType <> ''D''
						AND A.LND_UpdateType <> ''D''

				UNION ALL

				--:: ViolatedTrips
				SELECT	T.TpTripID,
						CAST(NULL AS BIGINT) AS CustTripID,
						TV.CitationID,
						CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
						CAST(CASE WHEN T.TripWith = ''V'' AND T.LinkID = TV.CitationID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
						CAST(''TP_Violated_Trip_Charges_Tracker'' AS VARCHAR(40)) SourceName,
						VT.TripChargeID,
						CAST(NULL AS INT) AS TollAdjustmentID,
						CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
						VT.Amount ViolatedTripCharge,
						VT.CreatedDate,
						TV.LND_UpdateDate
				FROM	LND_TBOS.TollPlus.TP_Trips T
				JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips TV
						ON TV.TpTripID = T.TpTripID
				JOIN	LND_TBOS.TollPlus.TP_Violated_Trip_Charges_Tracker VT
						ON VT.CitationID = TV.CitationID
				WHERE 1 = 1
						AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
						AND T.Exit_TollTxnID >= 0
						AND T.ExitTripDateTime >= ''' + @FirstDateToLoad + '''
						AND T.ExitTripDateTime <  ''' + @LastDateToLoad  + '''	
						AND T.LND_UpdateType <> ''D''
						AND TV.LND_UpdateType <> ''D''

				UNION ALL
	
				--:: ViolatedTrip Adjustments
				SELECT	T.TpTripID,
						CAST(NULL AS BIGINT)  AS CustTripID, 
						TV.CitationID,
						CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
						CAST(CASE WHEN T.TripWith = ''V'' AND T.LinkID = TV.CitationID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
						CAST(''Adjustment_LineItems'' AS VARCHAR(40)) SourceName,
						A.AdjustmentID,
						A.TollAdjustmentID, -- Key to get Finance.TollAdjustments.AdjustmentType,
						A.AdjustmentReason,
						CASE WHEN A.DrcrFlag = ''C'' THEN ALI.Amount*-1 ELSE ALI.Amount END AdjustmentLineItemAmount,
						A.ApprovedStatusDate,
						TV.LND_UpdateDate
				FROM	LND_TBOS.TollPlus.TP_Trips T
				JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips TV
						ON TV.TpTripID = T.TpTripID
				JOIN	LND_TBOS.Finance.Adjustment_LineItems ALI
						ON TV.CitationID = ALI.LinkID
						AND ALI.LinkSourceName = ''TollPlus.TP_ViolatedTrips''
				JOIN	LND_TBOS.Finance.Adjustments A
						ON A.AdjustmentID = ALI.AdjustmentID
						AND A.ApprovedStatusID = 466 -- Approved. Add this check.
				WHERE 1 = 1
						AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
						AND T.Exit_TollTxnID >= 0
						AND T.ExitTripDateTime >= ''' + @FirstDateToLoad + '''
						AND T.ExitTripDateTime <  ''' + @LastDateToLoad  + '''
						AND T.LND_UpdateType <> ''D''
						AND TV.LND_UpdateType <> ''D''
						AND ALI.LND_UpdateType <> ''D''
						AND A.LND_UpdateType <> ''D''

				UNION ALL
	
				--:: IOP Outbound Trips without or rarely with Adjustments
				SELECT	T.TpTripID,
						CAST(NULL AS BIGINT) AS CustTripID,
						CAST(NULL AS BIGINT) AS CitationID,
						CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
						CAST(CASE WHEN T.TripWith = ''I'' THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
						CAST(CASE WHEN I.TollAmount IS NOT NULL /*Posted status in IOP table*/ THEN ''BOS_IOP_OutboundTransactions-Paid'' ELSE ''BOS_IOP_OutboundTransactions-NotPaid'' END AS VARCHAR(40)) AS SourceName,
						T.LinkID AS SourceID,
						CAST(NULL AS INT) AS TollAdjustmentID,
						CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
						ISNULL(I.TollAmount,T.TollAmount) TollAmount, --> AEA always has value.
						T.PostedDate,
						ISNULL(I.LND_UpdateDate,T.LND_UpdateDate) LND_UpdateDate
						
				FROM	LND_TBOS.TollPlus.TP_Trips T
				LEFT JOIN
						(
								SELECT	TpTripID, SUM(TollAmount) TollAmount, MAX(LND_UpdateDate) LND_UpdateDate
								FROM	LND_TBOS.IOP.BOS_IOP_OutboundTransactions
								WHERE	TransactionStatus = ''Posted'' 
									AND ExitTripDateTime >= ''' + @FirstDateToLoad + '''
									AND ExitTripDateTime <  ''' + @LastDateToLoad  + '''
										AND LND_UpdateType <> ''D''
								GROUP BY TpTripID 
						) I
						ON I.TpTripID = T.TpTripID

				WHERE 1 = 1
						AND T.TripStageID = 31 /*QUALIFY_FOR_IOP*/ 
						AND ISNULL(T.TripWith,''I'') = ''I''
						AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
						AND T.Exit_TollTxnID >= 0
						AND T.ExitTripDateTime >= ''' + @FirstDateToLoad + '''
						AND T.ExitTripDateTime <  ''' + @LastDateToLoad  + '''
						AND T.LND_UpdateType <> ''D''
			)
			SELECT	TpTripID
					, CustTripID
					, CitationID
					, CurrentTxnFlag
					, TripDayID
					, SourceID
					, SourceName
					, TollAdjustmentID -- Key to get Finance.TollAdjustments.AdjustmentType,
					, AdjustmentReason
					, ROW_NUMBER() OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) TxnSeqAsc
					, TxnDate
					, Amount
					, SUM(Amount) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningTotalAmount
					, SUM(CASE WHEN SourceName = ''Adjustment_LineItems'' THEN Amount ELSE 0 END) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningAllAdjAmount
					, SUM(CASE WHEN SourceName = ''Adjustment_LineItems'' AND CurrentTxnFlag = 1 THEN Amount ELSE 0 END) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningTripWithAdjAmount
					, ROW_NUMBER() OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag DESC, TxnDate DESC) TxnSeqDesc
					, LND_UpdateDate
					, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
			FROM	CTE_AdjExpectedAmt
			--ORDER BY TpTripID, TxnSeqAsc
	


			OPTION (LABEL = ''' + @StageTableName + ''');'

			IF @IsFullLoad = 0  -- filter for incremental load
			BEGIN
				SET @sql = REPLACE(@sql,'WHERE 1 = 1','WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID)') 
			END

			IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql

			EXEC (@sql)

			-- Log 
			SET  @Log_Message = 'Loaded ' + @StageTableName
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @sql
		END
        
		--====================================================================================
		-- Finish full load
		--====================================================================================
		IF @IsFullLoad = 1
		BEGIN

			SET @sql = '
			CREATE STATISTICS Stats_' + REPLACE(@TableName,'.','_') + '_001 ON ' + @StageTableName + '(TpTripID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_002 ON ' + @StageTableName + '(CustTripID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_003 ON ' + @StageTableName + '(CitationID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_004 ON ' + @StageTableName + '(CurrentTxnFlag)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_005 ON ' + @StageTableName + '(SourceName)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_006 ON ' + @StageTableName + '(SourceID)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_007 ON ' + @StageTableName + '(TxnSeqAsc)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_008 ON ' + @StageTableName + '(TxnSeqDesc)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_009 ON ' + @StageTableName + '(TpTripID,TxnSeqDesc)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_010 ON ' + @StageTableName + '(Amount)
			CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_501 ON ' + @StageTableName + '(LND_UpdateDate)
			'
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
			EXEC (@sql)
		
			SET @Log_Message = 'Created Statistics'
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

			-- Table swap!
			EXEC Utility.TableSwap @StageTableName, @TableName
			SET @Log_Message = 'Completed full load'
		END 

		--====================================================================================
		-- Incremental load cleanup of invalid data in existing in Fact_AdjExpectedAmountDetail
		--====================================================================================
		IF @IsFullLoad = 0 AND @NoDataFlag = 0
		BEGIN

			--Some TpTripIDs existing in Fact_AdjExpectedAmountDetail no longer qualify in full load run. Clean them up! Replicate full load output.
			IF OBJECT_ID('Temp.Fact_AdjExpectedAmountDetail_DEL','U') IS NOT NULL	DROP TABLE Temp.Fact_AdjExpectedAmountDetail_DEL;
			CREATE TABLE Temp.Fact_AdjExpectedAmountDetail_DEL WITH (CLUSTERED INDEX(TPTripID), DISTRIBUTION = HASH(TPTripID))
			AS 
			SELECT TpTripID FROM dbo.Fact_AdjExpectedAmountDetail -- Present in the table before the run
			INTERSECT
			SELECT TpTripID FROM Stage.Bubble_TPTripID  -- and also in the incremental load input
			EXCEPT
			SELECT TpTripID FROM dbo.Fact_AdjExpectedAmountDetail_NEW -- but not selected in the NEW output

			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Loaded TpTripIDs not qualified for dbo.Fact_AdjExpectedAmountDetail full load as of now into Temp.Fact_AdjExpectedAmountDetail_DEL', 'I', NULL, -1
			DELETE dbo.Fact_AdjExpectedAmountDetail WHERE TpTripID IN (SELECT TpTripID FROM Temp.Fact_AdjExpectedAmountDetail_DEL)
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Deleted TpTripID rows not qualified for full load from dbo.Fact_AdjExpectedAmountDetail using Temp.Fact_AdjExpectedAmountDetail_DEL', 'I', NULL, -1
		END

		--====================================================================================
		-- Call dbo.Fact_AdjExpectedAmount_Load
		--====================================================================================
		IF @IsFullLoad = 1 OR (@IsFullLoad = 0 AND @NoDataFlag = 0)
		BEGIN
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Calling: dbo.Fact_AdjExpectedAmount_Load', 'I', NULL, NULL
			IF @Trace_Flag = 1 PRINT 'Calling: dbo.Fact_AdjExpectedAmount_Load'
			EXEC dbo.Fact_AdjExpectedAmount_Load @IsFullLoad
		END
		--====================================================================================
		-- Finish incremental load
		--====================================================================================
		IF @IsFullLoad = 0 AND @NoDataFlag = 0
		BEGIN
			IF @Trace_Flag = 1 PRINT 'Calling: Utility.ManagePartitions_DateID'
			EXEC Utility.ManagePartitions_DateID @TableName, 'DayID:Month'

			IF @Trace_Flag = 1 PRINT 'Calling: Utility.PartitionSwitch_Range'
			EXEC Utility.PartitionSwitch_Range @StageTableName, @TableName, @IdentifyingColumns, Null

			SET @sql = 'UPDATE STATISTICS  ' + @TableName
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
			EXEC (@sql)
			SET @Log_Message = 'Updated Statistics'
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

			SET @Log_Message = 'Completed incremental load' 
		END

		--====================================================================================
		-- Set the load dates for next run for full or incremental load
		--====================================================================================
		IF @IsFullLoad = 1 OR (@IsFullLoad = 0 AND @NoDataFlag = 0)
		BEGIN
			--:: Set the load date for the next incremental run
			EXEC Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_Trips', 'LND_TBOS.TollPlus.TP_Trips', @Next_TP_Trips_Date OUTPUT
			EXEC Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_CustomerTrips', 'LND_TBOS.TollPlus.TP_CustomerTrips', @Next_TP_CustomerTrips_Date OUTPUT
			EXEC Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', 'LND_TBOS.TollPlus.TP_ViolatedTrips', @Next_TP_ViolatedTrips_Date OUTPUT
			EXEC Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', 'LND_TBOS.IOP.BOS_IOP_OutboundTransactions', @Next_BOS_IOP_OutboundTransactions_Date OUTPUT

			SET @Log_Message = @Log_Message + '. SET next run start dates: TP_Trips after ' + ISNULL(CONVERT(VARCHAR(25),@Next_TP_Trips_Date,121),'???') + ', TP_CustomerTrips after ' + ISNULL(CONVERT(VARCHAR(25),@Next_TP_CustomerTrips_Date,121),'???') + 
			', TP_ViolatedTrips after ' + ISNULL(CONVERT(VARCHAR(25),@Next_TP_ViolatedTrips_Date,121),'???') + ', BOS_IOP_OutboundTransactions after ' + ISNULL(CONVERT(VARCHAR(25),@Next_BOS_IOP_OutboundTransactions_Date,121),'???')
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
			IF @Trace_Flag = 1 PRINT @Log_Message
			IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Fact_AdjExpectedAmountDetail' TableName, * FROM dbo.Fact_AdjExpectedAmountDetail ORDER BY CONVERT(DATE,EDW_UpdateDate) DESC, TpTripID, TxnDate
		END 	
		
		IF @Trace_Flag = 1 EXEC Utility.FromLog @TableName, @Log_Start_Date

	END	TRY

	BEGIN CATCH
	
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH;

END



/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_AdjExpectedAmountDetail_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_AdjExpectedAmount%' ORDER BY 1 DESC  
SELECT TOP 100 'dbo.Fact_AdjExpectedAmountDetail' TableName, * FROM dbo.Fact_AdjExpectedAmountDetail WHERE TPTripID = 1937242377 ORDER BY 2, TxnSeqAsc
SELECT TOP 100 * FROM dbo.Fact_AdjExpectedAmountDetail_NEW 
 
SourceName                                                 RC
---------------------------------------- --------------------
TP_Customer_Trip_Charges_Tracker                   2308198869
TP_Violated_Trip_Charges_Tracker                    611543925
BOS_IOP_OutboundTransactions-Paid                   196969483
Adjustment_LineItems                                173986315
BOS_IOP_OutboundTransactions-NotPaid                  3512093


--:: Full
SELECT COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail  

SELECT LND_UpdateDate, COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail  
GROUP BY LND_UpdateDate
ORDER BY 1

SELECT SourceName, COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail  
GROUP BY SourceName
ORDER BY 1

--:: Incremental
SELECT COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail_NEW 

SELECT LND_UpdateDate, COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail_NEW 
GROUP BY LND_UpdateDate
ORDER BY 1

SELECT SourceName, COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail_NEW 
GROUP BY SourceName
ORDER BY 1

SELECT TOP 100 * FROM Stage.Bubble_TPTripID
SELECT COUNT(1) Incremental_Load_Trips_Count FROM Stage.Bubble_TPTripID

SELECT * FROM Utility.LoadProcessControl WHERE TableName LIKE 'Fact_AdjExpectedAmountDetail%' ORDER BY 1

--:: Testing

DECLARE @Last_TP_Trips_Date DATETIME2(3), @Last_TP_CustomerTrips_Date DATETIME2(3), @Last_TP_ViolatedTrips_Date DATETIME2(3), @Last_BOS_IOP_OutboundTransactions_Date DATETIME2(3)

EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_Trips', @Last_TP_Trips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_CustomerTrips', @Last_TP_CustomerTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', @Last_TP_ViolatedTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', @Last_BOS_IOP_OutboundTransactions_Date OUTPUT
SELECT 'Before Set_UpdatedDate' SRC, @Last_TP_Trips_Date [@Last_TP_Trips_Date], @Last_TP_CustomerTrips_Date [@Last_TP_CustomerTrips_Date], @Last_TP_ViolatedTrips_Date [@Last_TP_ViolatedTrips_Date], @Last_BOS_IOP_OutboundTransactions_Date [@Last_BOS_IOP_OutboundTransactions_Date], SYSDATETIME() [RunTime]

EXEC EDW_TRIPS_DEV.Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_Trips', NULL, '2022-06-06';
EXEC EDW_TRIPS_DEV.Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_CustomerTrips', NULL, '2022-06-06';
EXEC EDW_TRIPS_DEV.Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', NULL, '2022-06-06';
EXEC EDW_TRIPS_DEV.Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', NULL, '2022-06-06';

--DECLARE @Last_TP_Trips_Date DATETIME2(3), @Last_TP_CustomerTrips_Date DATETIME2(3), @Last_TP_ViolatedTrips_Date DATETIME2(3), @Last_BOS_IOP_OutboundTransactions_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_Trips', @Last_TP_Trips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_CustomerTrips', @Last_TP_CustomerTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', @Last_TP_ViolatedTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', @Last_BOS_IOP_OutboundTransactions_Date OUTPUT
SELECT 'After Set_UpdatedDate' SRC,  @Last_TP_Trips_Date [@Last_TP_Trips_Date], @Last_TP_CustomerTrips_Date [@Last_TP_CustomerTrips_Date], @Last_TP_ViolatedTrips_Date [@Last_TP_ViolatedTrips_Date], @Last_BOS_IOP_OutboundTransactions_Date [@Last_BOS_IOP_OutboundTransactions_Date],  SYSDATETIME() [RunTime]

EXEC dbo.Fact_AdjExpectedAmountDetail_Load 0

EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_Trips', @Last_TP_Trips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_CustomerTrips', @Last_TP_CustomerTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', @Last_TP_ViolatedTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', @Last_BOS_IOP_OutboundTransactions_Date OUTPUT
SELECT 'After run' SRC, @Last_TP_Trips_Date [@Last_TP_Trips_Date], @Last_TP_CustomerTrips_Date [@Last_TP_CustomerTrips_Date], @Last_TP_ViolatedTrips_Date [@Last_TP_ViolatedTrips_Date], @Last_BOS_IOP_OutboundTransactions_Date [@Last_BOS_IOP_OutboundTransactions_Date],  SYSDATETIME() [RunTime]

SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_AdjExpectedAmount%' AND LogDate > CONVERT(DATE,SYSDATETIME()) ORDER BY 1 DESC

--===============================================================================================================
-- Incremental load sliding window. Start date for next run.
--===============================================================================================================

SELECT LND_UpdateDate, COUNT(1) TP_Trips FROM LND_TBOS.TollPlus.TP_Trips WHERE LND_UpdateDate > '6/1/2022' GROUP BY LND_UpdateDate ORDER BY 1 DESC
SELECT LND_UpdateDate, COUNT(1) TP_CustomerTrips FROM LND_TBOS.TollPlus.TP_CustomerTrips WHERE LND_UpdateDate > '6/1/2022'  GROUP BY LND_UpdateDate ORDER BY 1 DESC
SELECT LND_UpdateDate, COUNT(1) [CustTrips Adjustment_LineItems] FROM LND_TBOS.Finance.Adjustment_LineItems WHERE LinkSourceName ='TollPlus.TP_CustomerTrips'AND LND_UpdateDate > '6/1/2022' GROUP BY LND_UpdateDate ORDER BY 1 DESC
SELECT LND_UpdateDate, COUNT(1) TP_ViolatedTrips FROM LND_TBOS.TollPlus.TP_ViolatedTrips WHERE LND_UpdateDate > '6/1/2022' GROUP BY LND_UpdateDate ORDER BY 1 DESC
SELECT LND_UpdateDate, COUNT(1) [ViolatedTrips Adjustment_LineItems] FROM LND_TBOS.Finance.Adjustment_LineItems WHERE LinkSourceName ='TollPlus.TP_ViolatedTrips' AND LND_UpdateDate > '6/1/2022' GROUP BY LND_UpdateDate ORDER BY 1 DESC
SELECT LND_UpdateDate, COUNT(1) BOS_IOP_OutboundTransactions FROM LND_TBOS.IOP.BOS_IOP_OutboundTransactions WHERE LND_UpdateDate > '6/1/2022' GROUP BY LND_UpdateDate ORDER BY 1 DESC

SELECT 'TP_Trips' SourceTableName, COUNT(1) Row_Count, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.TollPlus.TP_Trips  WHERE LND_UpdateDate > '6/1/2022' AND SourceOfEntry IN (1,3) AND LND_UpdateType <> 'D'			
UNION 
SELECT 'TP_CustomerTrips' SourceTableName, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.TollPlus.TP_CustomerTrips WHERE LND_UpdateDate >'6/1/2022' AND SourceOfEntry IN (1,3) AND LND_UpdateType <> 'D'	
UNION
SELECT 'TP_Customer_Trip_Charges_Tracker' SourceTableName, COUNT(1) Row_Count, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.TollPlus.TP_Customer_Trip_Charges_Tracker  WHERE LND_UpdateDate > '6/1/2022' AND LND_UpdateType <> 'D'			
UNION 
SELECT'TP_ViolatedTrips' SourceTableName, COUNT(1) Row_Count, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.TollPlus.TP_ViolatedTrips WHERE LND_UpdateDate >'6/1/2022' AND SourceOfEntry IN (1,3) AND LND_UpdateType <> 'D' 
UNION
SELECT'TP_Violated_Trip_Charges_Tracker' SourceTableName, COUNT(1) Row_Count, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.TollPlus.TP_Violated_Trip_Charges_Tracker WHERE LND_UpdateDate >'6/1/2022' AND LND_UpdateType <> 'D' 
UNION
SELECT'BOS_IOP_OutboundTransactions' SourceTableName, COUNT(1) Row_Count, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.IOP.BOS_IOP_OutboundTransactions WHERE LND_UpdateDate >'6/1/2022' AND LND_UpdateType <> 'D'

--===============================================================================================================
-- !!! Full Load Dynamic SQL!!! 
--===============================================================================================================
IF OBJECT_ID('dbo.Fact_AdjExpectedAmountDetail_NEW','U') IS NOT NULL		DROP TABLE dbo.Fact_AdjExpectedAmountDetail_NEW;
CREATE TABLE dbo.Fact_AdjExpectedAmountDetail_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (20190101,20190201,20190301,20190401,20190501,20190601,20190701,20190801,20190901,20191001,20191101,20191201,20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,20210101,20210201,20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201,20220101,20220201,20220301,20220401,20220501,20220601,20220701,20220801))) AS
WITH CTE_AdjExpectedAmt AS
(
	--:: CustomerTrips
	SELECT	T.TpTripID,
			TC.CustTripID AS CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'C' AND T.LinkID = TC.CustTripID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('TP_Customer_Trip_Charges_Tracker' AS VARCHAR(40)) AS SourceName,
			CT.TripChargeID AS SourceID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			CT.Amount,
			CT.CreatedDate TxnDate,
			TC.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_CustomerTrips TC
			ON TC.TpTripID = T.TpTripID
	JOIN	LND_TBOS.TollPlus.TP_Customer_Trip_Charges_Tracker CT
			ON CT.CustTripID = TC.CustTripID
	WHERE 1 = 1
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:33:39.5224488'	
			AND T.LND_UpdateType <> 'D'
			AND TC.LND_UpdateType <> 'D'

	UNION ALL

	--:: CustomerTrip Adjustments
	SELECT	T.TpTripID,
			TC.CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'C' AND T.LinkID = TC.CustTripID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('Adjustment_LineItems' AS VARCHAR(40)) SourceName,
			ALI.AdjustmentID,
			A.TollAdjustmentID, -- Key to get Finance.TollAdjustments.AdjustmentType,
			A.AdjustmentReason,
			CASE WHEN A.DrcrFlag = 'C' THEN ALI.Amount*-1 ELSE ALI.Amount END AdjustmentLineItemAmount,
			A.ApprovedStatusDate,
			TC.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_CustomerTrips TC
			ON TC.TpTripID = T.TpTripID
	JOIN	LND_TBOS.Finance.Adjustment_LineItems ALI
			ON TC.CustTripID = ALI.LinkID
			AND ALI.LinkSourceName = 'TollPlus.TP_CustomerTrips'
	JOIN	LND_TBOS.Finance.Adjustments A
			ON A.AdjustmentID = ALI.AdjustmentID
			AND A.ApprovedStatusID = 466 -- Approved
	WHERE 1 = 1 
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:33:39.5224488'
			AND T.LND_UpdateType <> 'D'
			AND TC.LND_UpdateType <> 'D'
			AND ALI.LND_UpdateType <> 'D'
			AND A.LND_UpdateType <> 'D'

	UNION ALL

	--:: ViolatedTrips
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT) AS CustTripID,
			TV.CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'V' AND T.LinkID = TV.CitationID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('TP_Violated_Trip_Charges_Tracker' AS VARCHAR(40)) SourceName,
			VT.TripChargeID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			VT.Amount ViolatedTripCharge,
			VT.CreatedDate,
			TV.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips TV
			ON TV.TpTripID = T.TpTripID
	JOIN	LND_TBOS.TollPlus.TP_Violated_Trip_Charges_Tracker VT
			ON VT.CitationID = TV.CitationID
	WHERE 1 = 1
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:33:39.5224488'	
			AND T.LND_UpdateType <> 'D'
			AND TV.LND_UpdateType <> 'D'

	UNION ALL
	
	--:: ViolatedTrip Adjustments
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT)  AS CustTripID, 
			TV.CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'V' AND T.LinkID = TV.CitationID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('Adjustment_LineItems' AS VARCHAR(40)) SourceName,
			A.AdjustmentID,
			A.TollAdjustmentID, -- Key to get Finance.TollAdjustments.AdjustmentType,
			A.AdjustmentReason,
			CASE WHEN A.DrcrFlag = 'C' THEN ALI.Amount*-1 ELSE ALI.Amount END AdjustmentLineItemAmount,
			A.ApprovedStatusDate,
			TV.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips TV
			ON TV.TpTripID = T.TpTripID
	JOIN	LND_TBOS.Finance.Adjustment_LineItems ALI
			ON TV.CitationID = ALI.LinkID
			AND ALI.LinkSourceName = 'TollPlus.TP_ViolatedTrips'
	JOIN	LND_TBOS.Finance.Adjustments A
			ON A.AdjustmentID = ALI.AdjustmentID
			AND A.ApprovedStatusID = 466 -- Approved. Add this check.
	WHERE 1 = 1
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:33:39.5224488'
			AND T.LND_UpdateType <> 'D'
			AND TV.LND_UpdateType <> 'D'
			AND ALI.LND_UpdateType <> 'D'
			AND A.LND_UpdateType <> 'D'

	UNION ALL
	
	--:: IOP Outbound Trips without or rarely with Adjustments
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT) AS CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'I' THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST(CASE WHEN I.TollAmount IS NOT NULL /*Posted status in IOP table*/ THEN 'BOS_IOP_OutboundTransactions-Paid' ELSE 'BOS_IOP_OutboundTransactions-NotPaid' END AS VARCHAR(40)) AS SourceName,
			T.LinkID AS SourceID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			ISNULL(I.TollAmount,T.TollAmount) TollAmount, --> AEA always has value.
			T.PostedDate,
			ISNULL(I.LND_UpdateDate,T.LND_UpdateDate) LND_UpdateDate
						
	FROM	LND_TBOS.TollPlus.TP_Trips T
	LEFT JOIN
			(
					SELECT	TpTripID, SUM(TollAmount) TollAmount, MAX(LND_UpdateDate) LND_UpdateDate
					FROM	LND_TBOS.IOP.BOS_IOP_OutboundTransactions
					WHERE	TransactionStatus = 'Posted' 
						AND ExitTripDateTime >= '2019-01-01'
						AND ExitTripDateTime <  '2022-06-05 19:33:39.5224488'
							AND LND_UpdateType <> 'D'
					GROUP BY TpTripID 
			) I
			ON I.TpTripID = T.TpTripID

	WHERE 1 = 1
			AND T.TripStageID = 31 /*QUALIFY_FOR_IOP*/ 
			AND ISNULL(T.TripWith,'I') = 'I'
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:33:39.5224488'
			AND T.LND_UpdateType <> 'D'
)
SELECT	TpTripID
		, CustTripID
		, CitationID
		, CurrentTxnFlag
		, TripDayID
		, SourceID
		, SourceName
		, TollAdjustmentID -- Key to get Finance.TollAdjustments.AdjustmentType,
		, AdjustmentReason
		, ROW_NUMBER() OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) TxnSeqAsc
		, TxnDate
		, Amount
		, SUM(Amount) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningTotalAmount

		, SUM(CASE WHEN SourceName = 'Adjustment_LineItems' THEN Amount ELSE 0 END) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningAllAdjAmount
		, SUM(CASE WHEN SourceName = 'Adjustment_LineItems' AND CurrentTxnFlag = 1 THEN Amount ELSE 0 END) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningTripWithAdjAmount
		, ROW_NUMBER() OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag DESC, TxnDate DESC) TxnSeqDesc
		, LND_UpdateDate
		, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
FROM	CTE_AdjExpectedAmt
--ORDER BY TpTripID, TxnSeqAsc
OPTION (LABEL = 'dbo.Fact_AdjExpectedAmountDetail_NEW');
    
CREATE STATISTICS Stats_dbo_Fact_AdjExpectedAmountDetail_001 ON dbo.Fact_AdjExpectedAmountDetail_NEW(TpTripID)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_002 ON dbo.Fact_AdjExpectedAmountDetail_NEW(CustTripID)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_003 ON dbo.Fact_AdjExpectedAmountDetail_NEW(CitationID)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_004 ON dbo.Fact_AdjExpectedAmountDetail_NEW(CurrentTxnFlag)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_005 ON dbo.Fact_AdjExpectedAmountDetail_NEW(SourceName)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_006 ON dbo.Fact_AdjExpectedAmountDetail_NEW(SourceID)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_007 ON dbo.Fact_AdjExpectedAmountDetail_NEW(TxnSeqAsc)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_008 ON dbo.Fact_AdjExpectedAmountDetail_NEW(TxnSeqDesc)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_009 ON dbo.Fact_AdjExpectedAmountDetail_NEW(TpTripID,TxnSeqDesc)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_010 ON dbo.Fact_AdjExpectedAmountDetail_NEW(Amount)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_501 ON dbo.Fact_AdjExpectedAmountDetail_NEW(LND_UpdateDate)
			
--===============================================================================================================
-- !!! Incremental Load Dynamic SQL!!! 
--===============================================================================================================
IF OBJECT_ID('dbo.Fact_AdjExpectedAmountDetail_NEW','U') IS NOT NULL		DROP TABLE dbo.Fact_AdjExpectedAmountDetail_NEW;
CREATE TABLE dbo.Fact_AdjExpectedAmountDetail_NEW WITH (CLUSTERED INDEX ([TPTripID]), DISTRIBUTION = HASH(TPTripID)) AS
WITH CTE_AdjExpectedAmt AS
(
	--:: CustomerTrips
	SELECT	T.TpTripID,
			TC.CustTripID AS CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'C' AND T.LinkID = TC.CustTripID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('TP_Customer_Trip_Charges_Tracker' AS VARCHAR(40)) AS SourceName,
			CT.TripChargeID AS SourceID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			CT.Amount,
			CT.CreatedDate TxnDate,
			TC.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_CustomerTrips TC
			ON TC.TpTripID = T.TpTripID
	JOIN	LND_TBOS.TollPlus.TP_Customer_Trip_Charges_Tracker CT
			ON CT.CustTripID = TC.CustTripID
	WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID)
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:27:04.9869916'	
			AND T.LND_UpdateType <> 'D'
			AND TC.LND_UpdateType <> 'D'

	UNION ALL

	--:: CustomerTrip Adjustments
	SELECT	T.TpTripID,
			TC.CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'C' AND T.LinkID = TC.CustTripID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('Adjustment_LineItems' AS VARCHAR(40)) SourceName,
			ALI.AdjustmentID,
			A.TollAdjustmentID, -- Key to get Finance.TollAdjustments.AdjustmentType,
			A.AdjustmentReason,
			CASE WHEN A.DrcrFlag = 'C' THEN ALI.Amount*-1 ELSE ALI.Amount END AdjustmentLineItemAmount,
			A.ApprovedStatusDate,
			TC.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_CustomerTrips TC
			ON TC.TpTripID = T.TpTripID
	JOIN	LND_TBOS.Finance.Adjustment_LineItems ALI
			ON TC.CustTripID = ALI.LinkID
			AND ALI.LinkSourceName = 'TollPlus.TP_CustomerTrips'
	JOIN	LND_TBOS.Finance.Adjustments A
			ON A.AdjustmentID = ALI.AdjustmentID
			AND A.ApprovedStatusID = 466 -- Approved
	WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID) 
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:27:04.9869916'
			AND T.LND_UpdateType <> 'D'
			AND TC.LND_UpdateType <> 'D'
			AND ALI.LND_UpdateType <> 'D'
			AND A.LND_UpdateType <> 'D'

	UNION ALL

	--:: ViolatedTrips
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT) AS CustTripID,
			TV.CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'V' AND T.LinkID = TV.CitationID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('TP_Violated_Trip_Charges_Tracker' AS VARCHAR(40)) SourceName,
			VT.TripChargeID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			VT.Amount ViolatedTripCharge,
			VT.CreatedDate,
			TV.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips TV
			ON TV.TpTripID = T.TpTripID
	JOIN	LND_TBOS.TollPlus.TP_Violated_Trip_Charges_Tracker VT
			ON VT.CitationID = TV.CitationID
	WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID)
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:27:04.9869916'	
			AND T.LND_UpdateType <> 'D'
			AND TV.LND_UpdateType <> 'D'

	UNION ALL
	
	--:: ViolatedTrip Adjustments
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT)  AS CustTripID, 
			TV.CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'V' AND T.LinkID = TV.CitationID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('Adjustment_LineItems' AS VARCHAR(40)) SourceName,
			A.AdjustmentID,
			A.TollAdjustmentID, -- Key to get Finance.TollAdjustments.AdjustmentType,
			A.AdjustmentReason,
			CASE WHEN A.DrcrFlag = 'C' THEN ALI.Amount*-1 ELSE ALI.Amount END AdjustmentLineItemAmount,
			A.ApprovedStatusDate,
			TV.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips TV
			ON TV.TpTripID = T.TpTripID
	JOIN	LND_TBOS.Finance.Adjustment_LineItems ALI
			ON TV.CitationID = ALI.LinkID
			AND ALI.LinkSourceName = 'TollPlus.TP_ViolatedTrips'
	JOIN	LND_TBOS.Finance.Adjustments A
			ON A.AdjustmentID = ALI.AdjustmentID
			AND A.ApprovedStatusID = 466 -- Approved. Add this check.
	WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID)
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:27:04.9869916'
			AND T.LND_UpdateType <> 'D'
			AND TV.LND_UpdateType <> 'D'
			AND ALI.LND_UpdateType <> 'D'
			AND A.LND_UpdateType <> 'D'

	UNION ALL
	
	--:: IOP Outbound Trips without or rarely with Adjustments
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT) AS CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'I' THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST(CASE WHEN I.TollAmount IS NOT NULL /*Posted status in IOP table*/ THEN 'BOS_IOP_OutboundTransactions-Paid' ELSE 'BOS_IOP_OutboundTransactions-NotPaid' END AS VARCHAR(40)) AS SourceName,
			T.LinkID AS SourceID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			ISNULL(I.TollAmount,T.TollAmount) TollAmount, --> AEA always has value.
			T.PostedDate,
			ISNULL(I.LND_UpdateDate,T.LND_UpdateDate) LND_UpdateDate
						
	FROM	LND_TBOS.TollPlus.TP_Trips T
	LEFT JOIN
			(
					SELECT	TpTripID, SUM(TollAmount) TollAmount, MAX(LND_UpdateDate) LND_UpdateDate
					FROM	LND_TBOS.IOP.BOS_IOP_OutboundTransactions
					WHERE	TransactionStatus = 'Posted' 
						AND ExitTripDateTime >= '2019-01-01'
						AND ExitTripDateTime <  '2022-06-05 19:27:04.9869916'
							AND LND_UpdateType <> 'D'
					GROUP BY TpTripID 
			) I
			ON I.TpTripID = T.TpTripID

	WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID)
			AND T.TripStageID = 31 /*QUALIFY_FOR_IOP*/ 
			AND ISNULL(T.TripWith,'I') = 'I'
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:27:04.9869916'
			AND T.LND_UpdateType <> 'D'
)
SELECT	TpTripID
		, CustTripID
		, CitationID
		, CurrentTxnFlag
		, TripDayID
		, SourceID
		, SourceName
		, TollAdjustmentID -- Key to get Finance.TollAdjustments.AdjustmentType,
		, AdjustmentReason
		, ROW_NUMBER() OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) TxnSeqAsc
		, TxnDate
		, Amount
		, SUM(Amount) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningTotalAmount

		, SUM(CASE WHEN SourceName = 'Adjustment_LineItems' THEN Amount ELSE 0 END) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningAllAdjAmount
		, SUM(CASE WHEN SourceName = 'Adjustment_LineItems' AND CurrentTxnFlag = 1 THEN Amount ELSE 0 END) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningTripWithAdjAmount
		, ROW_NUMBER() OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag DESC, TxnDate DESC) TxnSeqDesc
		, LND_UpdateDate
		, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
FROM	CTE_AdjExpectedAmt
--ORDER BY TpTripID, TxnSeqAsc

OPTION (LABEL = 'dbo.Fact_AdjExpectedAmountDetail_NEW');



*/	
