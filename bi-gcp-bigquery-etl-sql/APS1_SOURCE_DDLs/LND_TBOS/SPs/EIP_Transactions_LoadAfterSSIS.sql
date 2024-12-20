CREATE PROC [EIP].[Transactions_LoadAfterSSIS] @Row_Count [BIGINT],@IsFullLoad [BIT] AS
/*

USE LND_TBOS 
GO
IF OBJECT_ID ('EIP.Transactions_LoadAfterSSIS', 'P') IS NOT NULL DROP PROCEDURE EIP.Transactions_LoadAfterSSIS  
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC EIP.Transactions_LoadAfterSSIS 2000, 0

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc used as a second step for EIP.Transactions SSIS load process and moving all loaded changes from Stage table.

@Row_Count  - Sent from Utility.LandingDataTransferAfterSSIS to use it the load
@IsFullLoad - Sent from Utility.LandingDataTransferAfterSSIS to use it the load
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy		01/10/2020	New!
CHG0041063 Shankar	06/15/2022	1. Now ETL process is able to properly convert Epoch timestamp format and 
								   YYYYMMDDHHMMSSmmm format values to Utc and Local Timestamp. NULLs in prod.
								2. Edge case bug fix when Timestamp is on the DST transition start/end dates in the year. 
								   Earlier it picked Timeone offset (-5 or -6 hours incorrectly)
###################################################################################################################
*/

BEGIN

	DECLARE @LogMessage VARCHAR(4000), @SourceName VARCHAR(100) = 'EIP.Transactions_LoadAfterSSIS', @RowCnt BIGINT, @Step VARCHAR(30), @Errors BIT
	DECLARE @SchemaName	VARCHAR(30), @TableName VARCHAR(100), @FullName VARCHAR(130), @StageTableName VARCHAR(130), @NewTableName VARCHAR(130), @UpdatedDateColumn VARCHAR(30)
	DECLARE @DistributionString	VARCHAR(100), @UID_Columns VARCHAR(800), @ColumnsString VARCHAR(8000), @WhereString VARCHAR(8000), @TableCount BIGINT = 0
	DECLARE @StatsSQL VARCHAR(8000), @IndexString VARCHAR(8000), @DeleteSQL VARCHAR(MAX), @InsertSQL VARCHAR(MAX), @RenameSQL VARCHAR(MAX)
	DECLARE @ColumnsStringWithLocalTime VARCHAR(MAX), @UseUpdatedDate	BIT = 1, @UsePartition BIT = 0, @SQL_NEW_SET VARCHAR(MAX), @StartDate DATETIME2(3) = SYSDATETIME()
	DECLARE @Nsql NVARCHAR(MAX), @ParmDefinition NVARCHAR(1000), @Query VARCHAR(MAX), @Trace_Flag BIT = 0 -- Testing

	EXEC Utility.ToLog @SourceName, @StartDate, 'Started', 'I',NULL,NULL

	;WITH CTE_TableLoadParameters AS
	(	
		SELECT 
			T.[SchemaName], T.TableName, T.FullName, T.StageTableName, T.UseUpdatedDate, T.UID_Columns, T.UsePartition, T.DistributionString,
			T.StatsSQL, T.DeleteSQL, T.InsertSQL, T.ColumnsString, T.WhereString, T.RenameSQL, T.RowCnt, T.IndexString, T.UpdatedDateColumn
		FROM Utility.[TableLoadParameters] T
		WHERE FullName  = 'EIP.Transactions'
	)
	SELECT TOP 1
		@SchemaName			 = [SchemaName]		
		,@TableName			 = TableName			
		,@FullName			 = FullName			
		,@RowCnt			 = RowCnt			
		,@StageTableName	 = StageTableName		
		,@NewTableName		 = FullName + '_NEW'
		,@UID_Columns		 = UID_Columns	
		,@UsePartition		 = UsePartition	
		,@ColumnsString		 = ColumnsString
		,@ColumnsStringWithLocalTime = REPLACE(ColumnsString, '[Transactions].[LocalTimeStamp]','DATEADD(HOUR, CASE WHEN [Transactions].UtcTimestamp BETWEEN tz.DST_Start_Date_UTC AND tz.DST_End_Date_UTC THEN -5 ELSE -6 END, [Transactions].UtcTimestamp) ')
		,@DistributionString = DistributionString	
		,@IndexString		 = IndexString	
		,@WhereString		 = WhereString		
		,@StatsSQL			 = StatsSQL			
		,@DeleteSQL			 = DeleteSQL			
		,@InsertSQL			 = InsertSQL			
		,@UseUpdatedDate	 = CASE WHEN @IsFullLoad = 1 THEN 0 ELSE UseUpdatedDate END	
		,@UpdatedDateColumn	 = UpdatedDateColumn	
	FROM CTE_TableLoadParameters

	SELECT @Errors = 0, @ParmDefinition = N'@TableCount BIGINT OUT', @Nsql = N'SELECT TOP 1	@TableCount = COUNT_BIG(1) FROM ' + @FullName + N' OPTION (LABEL = ''' + @FullName + N' count rows'');'
	IF @Trace_Flag = 1 PRINT @Nsql
	EXECUTE sp_executesql @Nsql, @ParmDefinition, @TableCount = @TableCount OUTPUT

	IF @TableCount = 0
		SET @UseUpdatedDate = 0

	IF @UseUpdatedDate = 1 -- This proc is never called for incremental load by UpdatedDate as this approach is not use. Attunity CDC SSIS is used for incremental load.
	BEGIN

		IF @Trace_Flag = 1 PRINT 'Using UpdatedDate for incremental load' 
		-- If it's more then 16 time less than full partition - better to do delete\insert instead of CREATE TABLE AS.
		DECLARE @USE_CREATE_AS BIT = CASE WHEN @Row_Count > @RowCnt / 16 THEN 1 ELSE 0 END

		IF @USE_CREATE_AS = 1
		BEGIN

			IF @Trace_Flag = 1 PRINT 'Using CREATE TABLE AS SELECT'
			SET @Step = 'Step 3 Failed: New Set load: '
			BEGIN TRY

				EXEC Utility.ToLog @SourceName, @StartDate, 'Step 3: New Set for incr load by UpdatedDate started!!?', 'I',NULL,NULL

				SET @SQL_NEW_SET = '
				IF OBJECT_ID(''' + @NewTableName + ''') IS NOT NULL DROP TABLE ' + @NewTableName + ';

				CREATE TABLE ' + @NewTableName + ' WITH (' + @IndexString + ', ' + @DistributionString + ') AS
				SELECT	' + @ColumnsString + '
				FROM [EIP].[Transactions] AS [Transactions] 
				WHERE NOT EXISTS (SELECT 1 FROM ' + @StageTableName + ' AS NSET WHERE ' + @WhereString + ')
				
				UNION ALL 
				
				' + REPLACE(@InsertSQL,'INSERT INTO EIP.Transactions','') + '
				OPTION (LABEL = ''' + @FullName + ' Incr Load: Get NEW SET table'');'

				IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL_NEW_SET
				SET @Query = @SQL_NEW_SET
				EXECUTE (@SQL_NEW_SET); 

				SET @Step = 'Step 3 Failed: SQL Create Stats: '
				SET @StatsSQL = REPLACE(REPLACE(REPLACE(@StatsSQL,'[',''),']',''),@StageTableName,@NewTableName)
				SET @Query = @StatsSQL
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @StatsSQL
				EXECUTE (@StatsSQL)

				SELECT @Step = 'Step 3 Failed: SQL Rename Table: ', @RenameSQL = 'NoPrint'
				EXEC Utility.Get_TransferObject_SQL @NewTableName, @FullName, @RenameSQL OUTPUT
				SET @Query = @RenameSQL
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @RenameSQL
				EXECUTE (@RenameSQL)

				SET  @LogMessage = 'Step 3: New Set load finished'
				EXEC Utility.ToLog @SourceName, @StartDate, @LogMessage, 'I', -1, NULL

			END	TRY	
			BEGIN CATCH
				SELECT @Errors = 1, @LogMessage = @Step + ERROR_MESSAGE()
				EXEC  Utility.ToLog @SourceName, @StartDate, @LogMessage, 'E',NULL,@Query
				IF @Trace_Flag = 1 PRINT @LogMessage;
				THROW;  -- Rethrow the error!
			END CATCH

		END -- IF @USE_CREATE_AS = 1
		ELSE -- IF @USE_CREATE_AS = 0
		BEGIN
			IF @Trace_Flag = 1 PRINT 'Using DELETE & INSERT'

			SET @Step = 'Step 3 Failed: SQL DELETE: '
			BEGIN TRY
				EXEC Utility.ToLog @SourceName, @StartDate, 'STEP 3: DELETE\INSERT load started', 'I', NULL, NULL
				SET @Query = @DeleteSQL
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @DeleteSQL
				EXECUTE (@DeleteSQL)

				SET @Step = 'Step 3 Failed: SQL INSERT: '
				SET @Query = @InsertSQL
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @InsertSQL
				EXECUTE (@InsertSQL)

				SET @Nsql = 'UPDATE STATISTICS ' + @FullName
				SET @Query = @Nsql
				EXECUTE (@Nsql) 

			END	TRY	
			BEGIN CATCH
				SELECT @Errors = 1, @LogMessage = @Step + ERROR_MESSAGE()
				EXEC  Utility.ToLog @SourceName, @StartDate, @LogMessage, 'E', NULL, @Query
				IF @Trace_Flag = 1 PRINT @LogMessage;
				THROW;  -- Rethrow the error!
			END CATCH

		END
	END
	ELSE -- No UPDATEDDATE column or Full Load - reload whole table then only rename it from stage to main table and back
	BEGIN

		-- It because Stage table may not have the same Index as main one - we can't just rename it. Also we are keeping stage table - dunno why.
		IF @Trace_Flag = 1 PRINT 'Using CREATE TABLE AS SELECT for Full Load'
		SET @Step = 'Step 3 Failed: New Set for full load: '
		BEGIN TRY

			EXEC Utility.ToLog @SourceName, @StartDate, 'Step 3: New Set for full load started', 'I', NULL, NULL

			IF OBJECT_ID('EIP.Transactions_NEW','U') IS NOT NULL			DROP TABLE EIP.Transactions_NEW;
			CREATE TABLE EIP.Transactions_NEW WITH (CLUSTERED INDEX ( TransactionID ASC ), DISTRIBUTION = HASH(TransactionID)) AS
			WITH CTE_Transactions_UTC AS 
			(
				SELECT CASE	WHEN LEN([Transactions].[Timestamp]) = 10 THEN DATEADD(SECOND, [Transactions].[Timestamp], '1970-01-01')
							WHEN LEN([Transactions].[Timestamp]) = 13 THEN DATEADD(MILLISECOND, [Transactions].[Timestamp] % 1000, DATEADD(SECOND, [Transactions].[Timestamp] / 1000, '1970-01-01'))
							WHEN LEN([Transactions].[Timestamp]) = 14 THEN CONVERT(DATETIME2(3),LEFT(CONVERT(VARCHAR,Timestamp),8) + ' ' + SUBSTRING(CONVERT(VARCHAR,Timestamp),9,2) + ':' + SUBSTRING(CONVERT(VARCHAR,Timestamp),11,2) + ':' + SUBSTRING(CONVERT(VARCHAR,Timestamp),13,2))
						END Timestamp_UTC, Transactions.* 
				FROM Stage.Transactions
			)
			SELECT
				  ISNULL(CAST(Transactions.TransactionID AS BIGINT), 0) AS TransactionID
				, ISNULL(CAST(AgencyCode AS VARCHAR(5)), '') AS AgencyCode
				, ISNULL(CAST(ServerID AS VARCHAR(20)), '') AS ServerID
				, ISNULL(CAST(PlazaID AS VARCHAR(20)), '') AS PlazaID
				, ISNULL(CAST(LaneID AS VARCHAR(20)), '') AS LaneID
				, ISNULL(CAST(TranID AS VARCHAR(20)), '') AS TranID
				, CAST(LanePosition AS VARCHAR(15)) AS LanePosition
				, CAST(IssuingAuthority AS VARCHAR(15)) AS IssuingAuthority
				, CAST(Timestamp AS BIGINT) AS Timestamp
				, CAST([Transactions].Timestamp_UTC AS DATETIME2(3)) AS UtcTimeStamp
				, CAST(DATEADD(HOUR, CASE WHEN [Transactions].Timestamp_UTC BETWEEN tz.DST_Start_Date_UTC AND tz.DST_End_Date_UTC THEN -5 ELSE -6 END, [Transactions].Timestamp_UTC) AS DATETIME2(3)) AS LocalTimeStamp
				, ISNULL(CAST(Transactions.TransactionDate AS DATE), '1900-01-01') AS TransactionDate
				, ISNULL(CAST(TransactionTime AS INT), 0) AS TransactionTime
				, CAST(TransponderID AS VARCHAR(20)) AS TransponderID
				, CAST(TransponderClass AS VARCHAR(5)) AS TransponderClass
				, CAST(VehicleClass AS VARCHAR(5)) AS VehicleClass
				, CAST(Vehiclelength AS VARCHAR(4)) AS Vehiclelength
				, CAST(ViolationCode AS VARCHAR(4)) AS ViolationCode
				, CAST(TollClass AS INT) AS TollClass
				, CAST(TollDue AS INT) AS TollDue
				, CAST(TollPaid AS INT) AS TollPaid
				, ISNULL(CAST(ImageOfRecordID AS BIGINT), 0) AS ImageOfRecordID
				, CAST(PrimaryPlateImageID AS BIGINT) AS PrimaryPlateImageID
				, CAST(PrimaryPlateReadConfidence AS INT) AS PrimaryPlateReadConfidence
				, CAST(OCRPlateRegistration AS VARCHAR(15)) AS OCRPlateRegistration
				, CAST(RegistrationReadConfidence AS INT) AS RegistrationReadConfidence
				, CAST(OCRPlateJurisdiction AS VARCHAR(8)) AS OCRPlateJurisdiction
				, CAST(JurisdictionReadConfidence AS INT) AS JurisdictionReadConfidence
				, CAST(SignatureHandle AS VARCHAR(15)) AS SignatureHandle
				, CAST(SignatureConfidence AS INT) AS SignatureConfidence
				, CAST(CombinedPlateResultStatus AS SMALLINT) AS CombinedPlateResultStatus
				, CAST(CombinedStateResultStatus AS SMALLINT) AS CombinedStateResultStatus
				, ISNULL(CAST(StartDate AS DATETIME2(0)), '1900-01-01') AS StartDate
				, CAST(EndDate AS DATETIME2(0)) AS EndDate
				, CAST(StageTypeID AS INT) AS StageTypeID
				, CAST(StageID AS INT) AS StageID
				, CAST(StatusID AS INT) AS StatusID
				, CAST(StatusDescription AS VARCHAR(256)) AS StatusDescription
				, CAST(StatusDate AS DATETIME2(0)) AS StatusDate
				, CAST(VehicleID AS BIGINT) AS VehicleID
				, CAST(GroupID AS INT) AS GroupID
				, ISNULL(CAST(RepresentativeSigImageID AS BIGINT), 0) AS RepresentativeSigImageID
				, ISNULL(CAST(SignatureMatchID AS BIGINT), 0) AS SignatureMatchID
				, ISNULL(CAST(SignatureConflictID1 AS BIGINT), 0) AS SignatureConflictID1
				, ISNULL(CAST(SignatureConflictID2 AS BIGINT), 0) AS SignatureConflictID2
				, CAST(Daynighttwilight AS SMALLINT) AS Daynighttwilight
				, ISNULL(CAST(Node AS VARCHAR(15)), '') AS Node
				, ISNULL(CAST(Nodeinst AS VARCHAR(15)), '') AS Nodeinst
				, ISNULL(CAST(RoadwayID AS INT), 0) AS RoadwayID
				, ISNULL(CAST(AgencyTimestamp AS BIGINT), 0) AS AgencyTimestamp
				, ISNULL(CAST(ReceivedDate AS DATETIME2(0)), '1900-01-01') AS ReceivedDate
				, CAST(AuditFileID AS INT) AS AuditFileID
				, CAST(MisreadDisposition AS INT) AS MisreadDisposition
				, CAST(Disposition AS INT) AS Disposition
				, CAST(ReasonCode AS INT) AS ReasonCode
				, CAST(LastReviewer AS VARCHAR(50)) AS LastReviewer
				, CAST(PlateTypePrefix AS VARCHAR(8)) AS PlateTypePrefix
				, CAST(PlateTypeSuffix AS VARCHAR(8)) AS PlateTypeSuffix
				, CAST(PlateRegistration AS VARCHAR(15)) AS PlateRegistration
				, CAST(PlateJurisdiction AS VARCHAR(8)) AS PlateJurisdiction
				, CAST(ISFSerialNumber AS INT) AS ISFSerialNumber
				, CAST(RevenueAxles AS INT) AS RevenueAxles
				, CAST(IndicatedVehicleClass AS INT) AS IndicatedVehicleClass
				, CAST(IndicatedAxles AS INT) AS IndicatedAxles
				, CAST(ActualAxles AS INT) AS ActualAxles
				, CAST(VehicleSpeed AS INT) AS VehicleSpeed
				, CAST(TagStatus AS SMALLINT) AS TagStatus
				, CAST(FacilityCode AS VARCHAR(45)) AS FacilityCode
				, CAST(PlateType AS VARCHAR(50)) AS PlateType
				, CAST(SubscriberID AS VARCHAR(10)) AS SubscriberID
				, ISNULL(CAST(CreatedDate AS DATETIME2(0)), '1900-01-01') AS CreatedDate
				, CAST(CreatedUser AS NVARCHAR(100)) AS CreatedUser
				, CAST(UpdatedDate AS DATETIME2(0)) AS UpdatedDate
				, CAST(UpdatedUser AS NVARCHAR(100)) AS UpdatedUser
				, CAST(LND_UpdateDate AS DATETIME2(3)) AS LND_UpdateDate
				, CAST(LND_UpdateType AS VARCHAR(1)) AS LND_UpdateType
			FROM	CTE_Transactions_UTC AS Transactions
			JOIN	Utility.Time_Zone_Offset tz
					ON YEAR([Transactions].TransactionDate) = tz.YYYY
			OPTION (LABEL = 'EIP.Transactions_NEW Load');

			SET @Step = 'Step 3 Failed: SQL Create Stats: '
			SET @StatsSQL = REPLACE(REPLACE(REPLACE(@StatsSQL,'[',''),']',''),@StageTableName,@NewTableName)
			SET @Query = @StatsSQL
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @StatsSQL
			EXECUTE (@StatsSQL)

			SELECT @Step = 'Step 3 Failed: SQL Rename Table: ', @RenameSQL = 'NoPrint'
			EXEC Utility.Get_TransferObject_SQL @NewTableName, @FullName, @RenameSQL OUTPUT
			SET @Query = @RenameSQL
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @RenameSQL
			EXECUTE (@RenameSQL)

			--TRUNCATE TABLE Stage.Transactions

			SET  @LogMessage = 'Step 3: New Set load finished'
			EXEC Utility.ToLog @SourceName, @StartDate, @LogMessage, 'I', -1, NULL

		END	TRY	
		BEGIN CATCH
			SELECT @Errors = 1, @LogMessage = @Step + ERROR_MESSAGE()
			EXEC  Utility.ToLog @SourceName, @StartDate, @LogMessage, 'E', NULL, @Query
			IF @Trace_Flag = 1 PRINT @LogMessage;
			THROW;  -- Rethrow the error!
		END CATCH

	END

	IF @Errors = 0
		EXEC Utility.ToLog @SourceName, @StartDate, 'Finished', 'I', NULL, NULL

END

/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================

UPDATE Utility.TableLoadParameters
SET UpdateProc = 'EXEC EIP.Transactions_LoadAfterSSIS @Row_Count, @IsFullLoad'
WHERE FullName  = 'EIP.Transactions'

SELECT *
	FROM Utility.TableLoadParameters
WHERE FullName  = 'EIP.Transactions'
ORDER BY TableName


*/
