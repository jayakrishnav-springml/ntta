CREATE PROC [dbo].[Fact_VehicleBan_Full_Load] AS

/*
###################################################################################################################
Proc  Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_VehicleBan table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0043993	    Gouthami	2023-11-02	New!
										1. This load is created to find the out Bans that happened for an HV.
										2. There are only two applied dates for BAN on '2019-01-01' and '2022-03-08'.
										   This how the data TRIPS data is. Need to pull data from RITE for these
										   dates.
CHG0044321	   Gouthami		2024-01-08	1. Pulled RITE data and merged it into final fact table.
										2. As TRIPS did not migrate correct dates for BANS, pulled those dates from 
											RITE system.

===================================================================================================================
Example:
----------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_VehicleBan_Full_Load

EXEC Utility.FromLog 'dbo.Fact_VehicleBan', 1
SELECT TOP 100 'dbo.Fact_VehicleBan' Table_Name, * FROM dbo.Fact_VehicleBan ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_VehicleBan_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL
		
		--=============================================================================================================
		-- Load dbo.Fact_VehicleBan
		--=============================================================================================================
		IF OBJECT_ID('dbo.Fact_VehicleBan_NEW') IS NOT NULL DROP TABLE dbo.Fact_VehicleBan_NEW
		CREATE TABLE dbo.Fact_VehicleBan_NEW WITH (CLUSTERED INDEX (HVID), DISTRIBUTION = REPLICATE) AS

		SELECT  VB.VehicleBanID
		       ,ISNULL(VB.HVID,-1) HVID
			   ,ISNULL(HV.CustomerID,-1) CustomerID
			   ,ISNULL(HV.VehicleID,-1) VehicleID
		       ,ISNULL(VB.VBLookupID,-1) VehicleBanStatusID
			   ,ISNULL(VB.RemovalLookupID,-1) VehicleBanRemovalStatusID		
			   ,VB.IsActive ActiveFlag
			   ,CASE		------ If BAN createddate is prior to 2021, then pull requested date from Ref table (RITE data)
					WHEN CAST(FT.CreatedDate AS DATE)<'2021-01-01' THEN CAST(LEFT(CONVERT(VARCHAR,Ref.DayID2,112),8) AS INT) 
				ELSE CAST(LEFT(CONVERT(VARCHAR,FT.CreatedDate,112),8) AS INT) 
				END AS VBRequestedDayID
			   ,CASE		------ If BAN createddate is prior to 2021, then pull applied date from Ref table (RITE data)
					WHEN CAST(FT.CreatedDate AS DATE)<'2021-01-01' THEN CAST(LEFT(CONVERT(VARCHAR,Ref.DayID2,112),8) AS INT) 
				ELSE CAST(LEFT(CONVERT(VARCHAR,FT.CreatedDate,112),8) AS INT) 
				END AS  VBAppliedDayID
		       ,CASE 
					WHEN VB.VBLookupID=28 THEN VB.ActionDate 
				ELSE NULL 
				END AS RemovedDate
				------ If the letter dates are not migrated to TRIPS, then pull the mailed date from Ref table (RITE data)
			   ,COALESCE(CAST(HV.EarliestVehicleBanLetterMailedDate AS DATE),CAST( CAST( Ref.DayID1 AS char(8)) AS DATE)) EarliestVehicleBanLetterMailedDate
			   ,CAST(HV.EarliestVehicleBanLetterDeliveredDate AS DATE) EarliestVehicleBanLetterDeliveredDate
			   ,CAST(HV.LatestVehicleBanLetterMailedDate AS DATE) LatestVehicleBanLetterMailedDate
			   ,CAST(HV.LatestVehicleBanLetterDeliveredDate AS DATE) LatestVehicleBanLetterDeliveredDate

		       ,ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate-- SELECT *  
		FROM LND_TBOS.TER.VehicleBan VB
		JOIN EDW_TRIPS.dbo.Dim_HabitualViolator HV ON HV.HVID = VB.HVID
		LEFT JOIN LND_TBOS.TER.VehicleBanRequest VBR ON VBR.VehicleBanID = VB.VehicleBanID
		LEFT JOIN LND_TBOS.TollPlus.TpFileTracker FT ON FT.FileID=VBR.FileID	
		LEFT JOIN ref.Ban Ref ON Ref.ViolatorID = HV.CustomerID	AND Ref.HvFlag=1

	
		OPTION (LABEL='dbo.Fact_VehicleBan_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Fact_VehicleBan_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Fact_VehicleBan_01 ON dbo.Fact_VehicleBan_NEW (VehicleBanID);
		CREATE STATISTICS STATS_dbo_Fact_VehicleBan_02 ON dbo.Fact_VehicleBan_NEW (HVID);
		CREATE STATISTICS STATS_dbo_Fact_VehicleBan_03 ON dbo.Fact_VehicleBan_NEW (VehicleBanStatusID);
		CREATE STATISTICS STATS_dbo_Fact_VehicleBan_04 ON dbo.Fact_VehicleBan_NEW (CustomerID);
		CREATE STATISTICS STATS_dbo_Fact_VehicleBan_05 ON dbo.Fact_VehicleBan_NEW (VBRequestedDayID);
		CREATE STATISTICS STATS_dbo_Fact_VehicleBan_06 ON dbo.Fact_VehicleBan_NEW (VBAppliedDayID);
		CREATE STATISTICS STATS_dbo_Fact_VehicleBan_07 ON dbo.Fact_VehicleBan_NEW (VehicleID);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_VehicleBan_NEW', 'dbo.Fact_VehicleBan'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_VehicleBan' TableName, * FROM dbo.Fact_VehicleBan ORDER BY 2 DESC
	
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
EXEC dbo.Fact_VehicleBan_Load

EXEC Utility.FromLog 'dbo.Fact_VehicleBan', 1
SELECT TOP 100 'dbo.Fact_VehicleBan' Table_Name, * FROM dbo.Fact_VehicleBan ORDER BY 2


select * FROM dbo.Fact_VehicleBan ORDER BY 2
select count(*) FROM dbo.Fact_VehicleBan --110984 
select * FROM edw_trips.dbo.Fact_VehicleBan  where customerid = 806539432
select * FROM edw_trips_dev.dbo.Fact_VehicleBan  where customerid = 806539432


---------------------------------------------------OLD CODE--------------------------------------------------------
	SELECT VB.VehicleBanID
						   ,ISNULL(VB.HVID,-1) HVID 
						   ,ISNULL(HV.CustomerID,-1) CustomerID
						   ,ISNULL(HV.VehicleID,-1) VehicleID
						   ,ISNULL(VBLookupID,-1) VehicleBanStatusID 
						   ,ISNULL(RemovalLookupID,-1) VBRemovalReasonID
						   ,VB.IsActive VBActiveFlag
						   ,CAST(LEFT(CONVERT(VARCHAR,FT.CreatedDate,112),8) AS INT) VBRequestedDayID
						   ,CAST(LEFT(CONVERT(VARCHAR,FT.CreatedDate,112),8) AS INT)  VBAppliedDayID
						   ,CAST(LEFT(CONVERT(VARCHAR,CASE WHEN VB.VBLookupID=28 THEN VB.ActionDate ELSE NULL END,112),8) AS INT) AS VBRemovedDayID
						   ,VB.CreatedDate
						   ,ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate 
						   --SELECT  *
					FROM LND_TBOS.TER.VehicleBan VB
					JOIN dbo.Dim_HabitualViolator HV ON HV.HVID = VB.HVID
					LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS ON VB.VBLookupID=HVS.HVStatusLookupID
					LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS1 ON VB.RemovalLookupID=HVS1.HVStatusLookupID
					LEFT JOIN LND_TBOS.TER.VehicleBanRequest VBR ON VB.VehicleBanID=vbr.VehicleBanID
					LEFT JOIN LND_TBOS.TollPlus.TpFileTracker FT ON FT.FileID=VBR.FileID	
			

*/


