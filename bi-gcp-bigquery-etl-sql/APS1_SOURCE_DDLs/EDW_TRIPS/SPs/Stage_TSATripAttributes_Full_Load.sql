CREATE PROC [Stage].[TSATripAttributes_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load Stage.TSATripAttributes table to optmize dbo.Fact_UnifiedTransaction load as part of Bubble ETL Process 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040744	Shankar		2022-03-22	New!
CHG0040994	Shankar		2022-05-26	Added Discount related TSA columns
CHG0041141	Shankar		2022-06-30	In case of multiple submissions of a Txn, take the first one for Expected Amount
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Stage.TSATripAttributes_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource = 'Stage.TSATripAttributes_Full_Load' ORDER BY 1 DESC
SELECT TOP 100 'Stage.TSATripAttributes' Table_Name, * FROM  Stage.TSATripAttributes ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'Stage.TSATripAttributes_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load Stage.TSATripAttributes
		--=============================================================================================================
		IF OBJECT_ID('Stage.TSATripAttributes_NEW','U') IS NOT NULL			DROP TABLE Stage.TSATripAttributes_NEW
		CREATE TABLE Stage.TSATripAttributes_NEW WITH (CLUSTERED INDEX (TpTripID ASC), DISTRIBUTION = HASH(TpTripID)) AS
		--EXPLAIN
		SELECT TPTripID, SourceTripID, TripDate, RecordType, VehicleSpeed, VehicleClassification
			 , TransactionType, TransponderTollAmount, VideoTollAmountWithVideoTollPremium, VideoTollAmountWithoutVideoTollPremium, TSA_ReceivedTollAmount
			 , TSA_Base, TSA_Premium, TransponderDiscountType, DiscountedTransponderTollAmount, VideoDiscountType, DiscountedVideoTollAmountWithoutVideoTollPremium, DiscountedVideoTollAmountWithVideoTollPremium
			 , LND_UpdateDate, EDW_UpdateDate
		FROM
		(
			SELECT TT.TPTripID
				, TT.SourceTripID
				, TT.ExitTripDateTime TripDate -- RT.Timestamp is TripDateUTC
				, TRaw.RecordType
				, TRaw.Speed VehicleSpeed
				, TRaw.VehicleClassification
				, TA.TransactionType
				, TA.TransponderTollAmount
				, TA.VideoTollAmountWithVideoTollPremium
				, TA.VideoTollAmountWithoutVideoTollPremium
				, CASE WHEN TA.TransactionType = 'T' THEN TA.TransponderTollAmount 
					   WHEN TA.TransactionType = 'V' THEN TA.VideoTollAmountWithVideoTollPremium
				  END TSA_ReceivedTollAmount
				, CASE WHEN TA.TransactionType = 'T' THEN TA.TransponderTollAmount 
					   WHEN TA.TransactionType = 'V' THEN TA.VideoTollAmountWithoutVideoTollPremium
				  END TSA_Base
				, CASE WHEN TA.TransactionType = 'T' THEN 0 
					   WHEN TA.TransactionType = 'V' THEN TA.VideoTollAmountWithVideoTollPremium - TA.TransponderTollAmount
				  END TSA_Premium
				, TA.TransponderDiscountType
				, TA.DiscountedTransponderTollAmount
				, TA.VideoDiscountType
				, TA.DiscountedVideoTollAmountWithoutVideoTollPremium
				, TA.DiscountedVideoTollAmountWithVideoTollPremium
				, ISNULL(TA.LND_UpdateDate, TRaw.LND_UpdateDate) LND_UpdateDate
				, CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
				, ROW_NUMBER() OVER (PARTITION BY TT.TpTripID ORDER BY TA.UpdatedDate ASC) RN
			FROM LND_TBOS.TOLLPLUS.TP_TRIPS TT 
			LEFT JOIN LND_TBOS.TSA.TSATripAttributes TA -- main table
					ON TA.TpTripID  = TT.TpTripID AND TA.LND_UpdateType <> 'D'
			LEFT JOIN LND_TBOS.TranProcessing.TSARawTransactions TRaw -- optional table
					ON TRaw.TxnID = TT.SourceTripID AND TRaw.LND_UpdateType <> 'D'
			WHERE	TT.Exit_TollTxnID >= 0
				AND TT.TpTripID > 0
				AND TT.SourceOfEntry = 3 -- TSA
				AND TT.ExitTripDateTime >= '2019-01-01' -- @FirstDateToLoad
				AND TT.ExitTripDateTime < SYSDATETIME()
				AND TT.LND_UpdateType <> 'D'

		) EA															
		WHERE RN = 1															
		OPTION (LABEL = 'Stage.TSATripAttributes_NEW Load')

		SET  @Log_Message = 'Loaded Stage.TSATripAttributes_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_Stage_TSATripAttributes_001 ON Stage.TSATripAttributes_NEW (TPTripID)
		CREATE STATISTICS STATS_Stage_TSATripAttributes_002 ON Stage.TSATripAttributes_NEW (SourceTripID)
		CREATE STATISTICS STATS_Stage_TSATripAttributes_003 ON Stage.TSATripAttributes_NEW (TripDate)
		
		-- Table swap!
		EXEC Utility.TableSwap 'Stage.TSATripAttributes_NEW', 'Stage.TSATripAttributes'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'Stage.TSATripAttributes' TableName, * FROM Stage.TSATripAttributes ORDER BY 2 DESC
	
	END	TRY
	
	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH

END

/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC Stage.TSATripAttributes_FullLoad
SELECT * FROM Utility.ProcessLog WHERE LogSource = 'Stage.TSATripAttributes_Full_Load' ORDER BY 1 DESC
SELECT TOP 100 'Stage.TSATripAttributes' Table_Name, * FROM Stage.TSATripAttributes WHERE TPTripID = 2017948180 ORDER BY 2

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

SELECT COUNT(*) FROM LND_TBOS.TSA.TSATripAttributes WHERE TransponderDiscountType IS NOT NULL
SELECT TOP 10 * FROM LND_TBOS.TSA.TSATripAttributes WHERE TransponderDiscountType IS NOT NULL AND TransactionDate > 20210106
SELECT TOP 10 * FROM LND_TBOS.TSA.TSATripAttributes WHERE VideoDiscountType IS NOT NULL AND TransactionDate > 20210106
SELECT YEAR(TransactionDate) TripYear, COUNT(1) RC FROM LND_TBOS.TSA.TSATripAttributes WHERE TransponderDiscountType IS NOT NULL GROUP BY YEAR(TransactionDate) ORDER BY 1
 
SELECT COUNT(*) FROM LND_TBOS.TSA.TSATripAttributes WHERE VideoDiscountType IS NOT NULL
SELECT TOP 10 * FROM LND_TBOS.TSA.TSATripAttributes WHERE VideoDiscountType IS NOT NULL AND TransactionDate > 20210106
SELECT TOP 10 * FROM LND_TBOS.TSA.TSATripAttributes WHERE VideoDiscountType IS NOT NULL AND TransactionDate > 20210106
SELECT YEAR(TransactionDate) TripYear, COUNT(1) RC FROM LND_TBOS.TSA.TSATripAttributes WHERE VideoDiscountType IS NOT NULL GROUP BY YEAR(TransactionDate) ORDER BY 1 -- only migrated data has this scenario.

*/

