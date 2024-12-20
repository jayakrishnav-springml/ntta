CREATE PROC [dbo].[Fact_LanePerformanceDailySummary_Full_Load] AS

/*
IF OBJECT_ID ('dbo.Fact_LanePerformanceDailySummary_Full_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_LanePerformanceDailySummary_Full_Load
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_LanePerformanceDailySummary_Full_Load table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG00XXXXX	Shekhar/Sagarika		2021-12-09	Created
			Shekhar					2022-03-28  Added a where clause to avoid future trips as they are causing a sudden 
											    drop the graph shown on dashboard (As of today, there are some future
												dated trips (ExitTripDateTime) in the TP_Trips table. )
			Shekhar					2022-03-28	Added extra comments for clarity


Description
	Fact_LanePerformanceDailySummary table is used to build 2 Microstrategy dashboards
		1. Lane Performance dashboard
		2. Misclass dashboard (Misclass dashboard uses one more fact table in addition to this one - Fact_Misclass)

	In the future, this table can source data from EDW_Trips.dbo.Fact_UnifiedTransaction instead of 
	LND_TBOS.Tollplus.TP_Trips. Currently (as of 3/28/2022) Fact_UnifiedTranscation table does not
	contain Airport and IOP Inbound trips.

	Note: as of 3/28/2022, this procedure takes around 22 min to run in DEV.


===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_LanePerformanceDailySummary_Full_Load

EXEC Utility.FromLog 'dbo.Fact_LanePerformanceDailySummary_Full_Load', 1
SELECT TOP 100 'dbo.Fact_LanePerformanceDailySummary_Full_Load' Table_Name, * FROM dbo.Fact_LanePerformanceDailySummary_Full_Load ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_LanePerformanceDailySummary_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Fact_LanePerformanceDailySummary_Full_Load
		--=============================================================================================================
		IF OBJECT_ID('dbo.Fact_LanePerformanceDailySummary_NEW') IS NOT NULL DROP TABLE dbo.Fact_LanePerformanceDailySummary_NEW
		CREATE TABLE dbo.Fact_LanePerformanceDailySummary_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(DayID)) AS
		
		SELECT  ISNULL(CAST(CONVERT(VARCHAR(8), tt.ExitTripDateTime, 112) AS INT), -1) AS DayID,
		        tt.ExitLaneID AS LaneID, 
		        dtim.TripIdentMethodID,
		        ISNULL(drc.ReasonCodeID, -1) AS ReasonCodeID,
		        CASE WHEN tt.IsImageReviewed IS NULL THEN 0 ELSE tt.IsImageReviewed END AS ImageReviewedFlag,
		        COUNT(*) AS TxnCount
		FROM    lnd_tbos.Tollplus.TP_Trips tt 
		        JOIN  dbo.Dim_TripIdentMethod dtim
		               ON dtim.TripIdentMethod = tt.TripIdentMethod
		        LEFT JOIN  dbo.Dim_ReasonCode drc
		               ON drc.ReasonCode = tt.ReasonCode
		WHERE   tt.Lnd_UpdateType !='D'
		and		ExitTripDateTime <= getdate()  -- Eliminate future trips present in the TP_Trips table. This where clause is added by Shekhar on 3/28/2022
		                                       -- after Sreedevi pointed out a sudden drop on one of the dashboard graphs because of future trips.
											   -- We do not know why future dated trips are present in TP_Trips. It could be a data quality issue.
											   -- As of today the number of future trips is very small - around 50, but since the dashboard graph looks
											   -- ugly and raises a lot of questions, we are eliminating them.
		GROUP BY  ISNULL(CAST(CONVERT(VARCHAR(8), tt.ExitTripDateTime, 112) AS INT), -1),
		          tt.ExitLaneID, 
		          dtim.TripIdentMethodID, 
		          drc.ReasonCodeID,
		          tt.IsImageReviewed
		OPTION (LABEL='dbo.Fact_LanePerformanceDailySummary_NEW Load');
				
		-- Log
		SET  @Log_Message = 'Loaded dbo.Fact_LanePerformanceDailySummary_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_dbo_Fact_LanePerformanceDailySummary_01 ON dbo.Fact_LanePerformanceDailySummary_NEW (DayID);
		CREATE STATISTICS STATS_dbo_Fact_LanePerformanceDailySummary_02 ON dbo.Fact_LanePerformanceDailySummary_NEW (LaneID);
		CREATE STATISTICS STATS_dbo_Fact_LanePerformanceDailySummary_03 ON dbo.Fact_LanePerformanceDailySummary_NEW (TripIdentMethodID);
		CREATE STATISTICS STATS_dbo_Fact_LanePerformanceDailySummary_04 ON dbo.Fact_LanePerformanceDailySummary_NEW (ReasonCodeID);
		CREATE STATISTICS STATS_dbo_Fact_LanePerformanceDailySummary_05 ON dbo.Fact_LanePerformanceDailySummary_NEW (ImageReviewedFlag);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_LanePerformanceDailySummary_NEW', 'dbo.Fact_LanePerformanceDailySummary'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_LanePerformanceDailySummary' TableName, * FROM dbo.Fact_LanePerformanceDailySummary ORDER BY 2 DESC
	
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
EXEC dbo.Fact_LanePerformanceDailySummary


EXEC Utility.FromLog 'dbo.Fact_LanePerformanceDailySummary', 1
SELECT TOP 100 'dbo.Fact_LanePerformanceDailySummary' Table_Name, * FROM dbo.Fact_LanePerformanceDailySummary ORDER BY 2


-- Check if there are any future dated trips
SELECT TOP 100 'dbo.Fact_LanePerformanceDailySummary' Table_Name, * FROM dbo.Fact_LanePerformanceDailySummary 
where dayid > 20220328


select count_big(*) FROM lnd_tbos.tollplus.tp_trips where dayid is null ---- transactions reasoncode are rejected

SELECT CAST(exittripdatetime AS DATE) TripDate ,COUNT(tptripid)VideoTXNCnt		
FROM lnd_tbos.tollplus.tp_trips		
WHERE CAST(exittripdatetime AS DATE) BETWEEN '2021-05-01' AND '2021-05-31'		
AND TripIdentMethod='Videotoll'		
AND LND_UpdateType!='d'		
GROUP BY TripIdentMethod,CAST(exittripdatetime AS DATE)		
ORDER BY 1 		
		
SELECT DayID,SUM(TXnCount)VideoTXNCnt		
FROM dbo.Fact_LanePerformanceDailySummary		
WHERE dayid BETWEEN 20210501 AND 20210531		
AND TripIdentMethodID=2		
GROUP BY DayID 		
ORDER BY dayid 	



*/


