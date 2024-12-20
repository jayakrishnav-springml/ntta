CREATE PROC [dbo].[Fact_TollTransaction_Adj_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_TollTransaction_Adj table. 
This Proc accommodate different adjustment dates for the same customer
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039407	Sagarika		2020-10-01	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_TollTransaction_Adj_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Fact_TollTransaction_Adj_Full_Load%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Fact_TollTransaction_Adj' Table_Name, * FROM  dbo.Fact_TollTransaction_Adj ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_TollTransaction_Adj_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Fact_TollTransaction_Adj
		--=============================================================================================================
		IF OBJECT_ID('dbo.Fact_TollTransaction_Adj_NEW','U') IS NOT NULL    DROP TABLE dbo.Fact_TollTransaction_Adj_NEW;
		CREATE TABLE  dbo.Fact_TollTransaction_Adj_NEW WITH (CLUSTERED INDEX(CustTripID), DISTRIBUTION = HASH(CustTripID))
		AS 
		SELECT  
				ISNULL(CAST(TP.CustTripID AS BIGINT), -1) AS CustTripID,
				ISNULL(CAST(ADJLI.AdjLineItemID AS BIGINT), -1) AS AdjLineItemID,
				ISNULL(CAST(ADJ.AdjustmentID AS BIGINT), -1) AS AdjustmentID,
				ISNULL(TP.TPTripID, -1) AS TPTripID,
				ISNULL(CAST(TP.CustomerID AS BIGINT), -1) AS CustomerID,
				ISNULL(CAST(TP.ExitLaneID AS INT), -1) AS LaneID,
				ISNULL(CAST(TI.TripIdentMethodID AS INT),-1) AS TripIdentMethodID,
				ISNULL(CAST(CONVERT(VARCHAR(8), TP.ExitTripDateTime, 112) AS INT), -1) AS TripDayID,
				ISNULL(CAST(CONVERT(VARCHAR(8), ADJ.ApprovedStatusDate, 112) AS INT), -1) AS AdjustedDayID,
				ISNULL(CAST(TP.ExitTripDateTime AS DATETIME2(3)), '1900-01-01') AS TripDate,
				ISNULL(CAST(TP.PostedDate AS DATETIME2(3)), '1900-01-01') AS PostedDate,
				ISNULL(CAST(ADJ.ApprovedStatusDate AS DATETIME2(3)), '1900-01-01') AS AdjustedDate,
				CAST(ADJ.DrCrFlag AS VARCHAR(2)) AS DrCrFlag,
				ISNULL(CAST(CASE WHEN TP.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT), 0) AS DeleteFlag,
				ISNULL(CAST(ADJ.AMOUNT * CASE WHEN ADJ.DrCrFlag = 'D' THEN -1 ELSE 1 END AS DECIMAL(9, 2)), 0) AS AdjustedTollAmount,
				ISNULL(CAST(TP.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate,
				ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate
		FROM LND_TBOS.TollPlus.TP_CustomerTrips TP
			INNER JOIN LND_TBOS.Finance.Adjustment_LineItems ADJLI
				ON TP.CustTripID = ADJLI.LinkID
					AND ADJLI.LinkSourceName = 'TOLLPLUS.TP_CUSTOMERTRIPS'
					AND ADJLI.LND_UpdateType <> 'D'
			INNER JOIN LND_TBOS.Finance.Adjustments ADJ
				ON ADJ.AdjustmentID = ADJLI.AdjustmentID
					AND ADJ.ApprovedStatusID = 466
					AND ADJ.LND_UpdateType <> 'D'
			LEFT JOIN dbo.Dim_TripIdentMethod TI 
				ON TI.TripIdentMethod = TP.TripIdentMethod
				

		SET  @Log_Message = 'Loaded dbo.Fact_TollTransaction_Adj_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Fact_TollTransaction_Adj_01 ON dbo.Fact_TollTransaction_Adj_NEW (CustomerID);
		CREATE STATISTICS STATS_dbo_Fact_TollTransaction_Adj_02 ON dbo.Fact_TollTransaction_Adj_NEW (LaneID);
		CREATE STATISTICS STATS_dbo_Fact_TollTransaction_Adj_03 ON dbo.Fact_TollTransaction_Adj_NEW (PostedDate);
		CREATE STATISTICS STATS_dbo_Fact_TollTransaction_Adj_04 ON dbo.Fact_TollTransaction_Adj_NEW (TPTripID);
		CREATE STATISTICS STATS_dbo_Fact_TollTransaction_Adj_05 ON dbo.Fact_TollTransaction_Adj_NEW (TripIdentMethodID);
		CREATE STATISTICS STATS_dbo_Fact_TollTransaction_Adj_06 ON dbo.Fact_TollTransaction_Adj_NEW (AdjustedDate);
		CREATE STATISTICS STATS_dbo_Fact_TollTransaction_Adj_07 ON dbo.Fact_TollTransaction_Adj_NEW (DrcrFlag);
		CREATE STATISTICS STATS_dbo_Fact_TollTransaction_Adj_08 ON dbo.Fact_TollTransaction_Adj_NEW (TripDayID);

		SET  @Log_Message = 'Created STATISTICS on dbo.Fact_TollTransaction_Adj_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_TollTransaction_Adj_NEW', 'dbo.Fact_TollTransaction_Adj'

		SET  @Log_Message = 'Completed dbo.Fact_TollTransaction_Adj table swap' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_TollTransaction_Adj' TableName, * FROM dbo.Fact_TollTransaction_Adj ORDER BY 2 DESC
	
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
EXEC dbo.Fact_TollTransaction_Adj_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Fact_TollTransaction_Adj_Full_Load%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Fact_TollTransaction_Adj' Table_Name, * FROM  dbo.Fact_TollTransaction_Adj ORDER BY 2

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/


