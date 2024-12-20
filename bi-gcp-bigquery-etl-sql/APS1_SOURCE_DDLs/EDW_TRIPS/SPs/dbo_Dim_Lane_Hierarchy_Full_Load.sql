CREATE PROC [dbo].[Dim_Lane_Hierarchy_Full_Load] AS
/*
###################################################################################################################
Purpose: Load all Lane dimension hierarchy tables. 

~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ 
Good Template for: MATRYOSHKA RUSSIAN DOLLS ETL DESIGN PATTERN for loading related Dim tables in a natural hierarchy 
~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ 

Tables: !!! MATRYOSHKA RUSSIAN DOLLS ETL DESIGN PATTERN !!!
		- dbo.Dim_Agency	-> Agency level
		- dbo.Dim_Facility	-> Location level + dbo.Dim_Agency
		- dbo.Dim_Plaza		-> Plaza level + dbo.Dim_Facility
		- dbo.Dim_Lane		-> Lane level  + dbo.Dim_Plaza

-------------------------------------------------------------------------------------------------------------------
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838 		Gouthami		2020-01-04		New!
CHG0039000      Gouthami		2021-06-04		Added LaneCategoryID,LaneLatitude,LaneLongitude,LaneZipCode,LaneCountyName
												,PlazaLatitude, PlazaLongitude,PlazaZipCode  with new GIS data
CHG0040134		Gouthami		2021-12-15		Added Operations Agency for Bubble Report
CHG0041141		Shankar			2022-06-30		Added new columns for IPS. Modified OperationsAgency, SubAgency for NetRMA
-------------------------------------------------------------------------------------------------------------------
Run script:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Lane_Hierarchy_Full_Load

EXEC Utility.FromLog 'Dim_Lane', 1
SELECT 'dbo.Dim_Agency' TableName, * FROM dbo.Dim_Agency ORDER BY 2 DESC 
SELECT 'dbo.Dim_Facility' TableName, * FROM dbo.Dim_Facility ORDER BY 2 DESC
SELECT 'dbo.Dim_Plaza' TableName, * FROM dbo.Dim_Plaza ORDER BY 2 DESC
SELECT 'dbo.Dim_Lane' TableName, * FROM dbo.Dim_Lane ORDER BY 2 DESC
###################################################################################################################
*/
BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_Lane_Hierarchy_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load of Hierarchy dim tables', '-1', NULL, 'I'

		--=============================================================================================================
		-- Load dbo.Dim_Agency		->	Agency Level
		--=============================================================================================================

		IF OBJECT_ID('dbo.Dim_Agency_NEW') IS NOT NULL DROP TABLE dbo.Dim_Agency_NEW
		CREATE TABLE dbo.Dim_Agency_NEW WITH (CLUSTERED INDEX ( AgencyID ), DISTRIBUTION = REPLICATE)
			AS 
				SELECT 
					ISNULL(CAST(Agencies.AgencyID AS BIGINT), 0) AS AgencyID
					, ISNULL(CAST(AgencyType.LookupTypeCode AS VARCHAR(20)), '-1') AS AgencyType
					, CAST(Agencies.AgencyName AS VARCHAR(100)) AS AgencyName
					, ISNULL(CAST(Agencies.AgencyCode AS VARCHAR(10)), '') AS AgencyCode
					, CAST(Agencies.StartEffectiveDate AS DATETIME2(3)) AS AgencyStartDate
					, CAST(Agencies.EndEffectiveDate AS DATETIME2(3)) AS AgencyEndDate
					, CAST(Agencies.LND_UpdateDate AS DATETIME2(3)) AS LND_UpdatedDate
					, SYSDATETIME() AS EDW_UpdatedDate
				FROM LND_TBOS.TollPlus.Agencies AS Agencies
				LEFT JOIN LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy AS AgencyType ON Agencies.AgencyTypeID = AgencyType.LookupTypeCodeID
							AND AgencyType.Parent_LookupTypeCodeID=587  -- AgencyType
				OPTION (LABEL = 'dbo.Dim_Agency_NEW Load'); 

	
		-- Log 
		SET  @Log_Message = 'Loaded dbo.Dim_Agency with Agency level'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics and swap table
		CREATE STATISTICS STATS_Dim_Agency_001 ON dbo.Dim_Agency_NEW (AgencyID);
		EXEC Utility.TableSwap 'dbo.Dim_Agency_NEW', 'dbo.Dim_Agency'

		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Agency' TableName, * FROM dbo.Dim_Agency ORDER BY 2 DESC

		--=============================================================================================================
		-- Load dbo.Dim_Facility		->	 Location + Agency levels
		--=============================================================================================================

		IF OBJECT_ID('dbo.Dim_Facility_NEW') IS NOT NULL DROP TABLE dbo.Dim_Facility_NEW
		CREATE TABLE dbo.Dim_Facility_NEW WITH (CLUSTERED INDEX ( FacilityID ), DISTRIBUTION = REPLICATE)
			AS 
				SELECT 
					ISNULL(CAST(Location.LocationID AS int), 0) AS FacilityID
					, CAST(Location.LocationCode AS varchar(50)) AS FacilityCode
					, CAST(Location.LocationName AS varchar(50)) AS FacilityName
					, CAST(Location.TSAFacilityID AS int) AS TSAFacilityID
					, CAST(CASE WHEN Location.IsTSA = 1 THEN CAST(Location.TSAFacilityID AS VARCHAR(50)) ELSE Location.LocationCode END AS VARCHAR(50)) AS IPS_FacilityCode
					, CAST(Location.IsTSA AS BIT) AS TSAFlag
					, ISNULL(CAST(CASE
										WHEN Agency.AgencyCode <> 'NTTA' THEN 1
										WHEN Location.LocationID = 5 THEN 2
										WHEN Location.LocationID = 9 THEN 4		
										WHEN Location.LocationID = 10 THEN 8		
										WHEN Location.LocationID = 11 THEN 16	
										WHEN Location.LocationID = 210 THEN 32	
										WHEN Location.LocationID = 220 THEN 64	
										WHEN Location.LocationID = 230 THEN 128	
										WHEN Location.LocationID = 240 THEN 256	
										WHEN Location.LocationID = 250 THEN 512	
										WHEN Location.LocationID = 260 THEN 1024	
										WHEN Location.LocationID = 270 THEN 2048	
										WHEN Location.LocationID = 271 THEN 4096	
										WHEN Location.LocationID = 280 THEN 8192	
										WHEN Location.LocationID = 290 THEN 16384
										WHEN Location.LocationID = 281 THEN 32768
									END	AS bigint), 0) AS BitMaskID	
					----------------------------------Agency Level--------------------------------------------------------
					, CAST(CASE WHEN Location.IsTSA = 1 AND SA.SubAgencyAbbrev IS NOT NULL	THEN SA.SubAgencyAbbrev		-- TSA
								WHEN Location.IsTSA = 0 AND SA.SubAgencyAbbrev IS NOT NULL AND Agency.AgencyType = 'IOPAgency' THEN 'N/A' -- IOP
								WHEN Location.IsTSA = 0 AND SA.SubAgencyAbbrev <> 'TSA'		THEN SA.SubAgencyAbbrev		-- Other than TSA
							END AS VARCHAR(20)) AS SubAgencyAbbrev
					, CAST(CASE WHEN Location.IsTSA = 1 THEN SA.OperationsAgency 
								WHEN Location.IsTSA = 0 AND SA.OperationsAgency IS NOT NULL AND Agency.AgencyType = 'IOPAgency' THEN 'IOP - NTTA Home' 
								ELSE  SA.OperationsAgency 
							END AS VARCHAR(20)) AS OperationsAgency
					, Agency.AgencyID
					, Agency.AgencyType
					, Agency.AgencyName
					, Agency.AgencyCode
					, Agency.AgencyStartDate
					, Agency.AgencyEndDate
					, CAST(Location.LND_UpdateDate AS datetime2(3)) AS LND_UpdatedDate
					,SYSDATETIME() AS EDW_UpdatedDate
				FROM LND_TBOS.TollPlus.Locations AS Location
				LEFT JOIN Ref.Facility_Sub_Agency SA ON SA.FacilityAbbrev = Location.LocationCode 
				JOIN dbo.Dim_Agency AS Agency ON Location.AgencyID = Agency.AgencyID
				OPTION (LABEL = 'dbo.Dim_Facility_NEW Load');

		-- Log
		SET  @Log_Message = 'Loaded dbo.Dim_Facility_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics and swap table
		CREATE STATISTICS STATS_dbo_Dim_Facility_01 ON dbo.Dim_Facility_NEW (AgencyID);
		CREATE STATISTICS STATS_dbo_Dim_Facility_02 ON dbo.Dim_Facility_NEW (AgencyID, FacilityID); 
		CREATE STATISTICS STATS_dbo_Dim_Facility_03 ON dbo.Dim_Facility_NEW (IPS_FacilityCode); 
		CREATE STATISTICS STATS_dbo_Dim_Facility_04 ON dbo.Dim_Facility_NEW (TSAFlag); 

 		EXEC Utility.TableSwap 'dbo.Dim_Facility_NEW', 'dbo.Dim_Facility'

		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Facility' TableName, * FROM dbo.Dim_Facility ORDER BY 2 DESC
		/*
		--:: TxnCount by Facility

		DECLARE @SnapshotMonthID INT
		SELECT @SnapshotMonthID = MAX(SnapshotMonthID) FROM dbo.Fact_UnifiedTransaction_SummarySnapshot

		SELECT	ut.TripMonthID/100 TripYear, f.FacilityCode, f.OperationsAgency, COUNT(1) RC, SUM(ut.TxnCount) TxnCount 
		FROM	dbo.Fact_UnifiedTransaction_SummarySnapshot ut 
				JOIN dbo.Dim_Facility f ON f.FacilityID = ut.FacilityID 
				JOIN dbo.Dim_OperationsMapping OM ON OM.OperationsMappingID = ut.OperationsMappingID
		WHERE	ut.SnapshotMonthID = @SnapshotMonthID AND F.FacilityCode LIKE 'NE%49'
		GROUP BY ut.TripMonthID/100, f.FacilityCode, f.OperationsAgency  
		ORDER BY 3,2,1

		DECLARE @SnapshotMonthID INT
		SELECT @SnapshotMonthID = MAX(SnapshotMonthID) FROM dbo.Fact_UnifiedTransaction_SummarySnapshot

		SELECT	ut.TripMonthID, f.FacilityCode, f.OperationsAgency, COUNT(1) RC, SUM(ut.TxnCount) TxnCount 
		FROM	dbo.Fact_UnifiedTransaction_SummarySnapshot ut 
				JOIN dbo.Dim_Facility f ON f.FacilityID = ut.FacilityID 
				JOIN dbo.Dim_OperationsMapping OM ON OM.OperationsMappingID = ut.OperationsMappingID
		WHERE	ut.SnapshotMonthID = @SnapshotMonthID AND F.FacilityCode LIKE 'NE%49'
		GROUP BY ut.TripMonthID, f.FacilityCode, f.OperationsAgency  
		ORDER BY 3,2,1

		*/

		--=============================================================================================================
		-- Load dbo.Dim_Plaza		->	 Plaza + Facility + Agency levels
		--=============================================================================================================

		IF OBJECT_ID('dbo.Dim_Plaza_NEW') IS NOT NULL DROP TABLE dbo.Dim_Plaza_NEW
		CREATE TABLE dbo.Dim_Plaza_NEW WITH (CLUSTERED INDEX ( PlazaID ), DISTRIBUTION = REPLICATE)
			AS 
			SELECT 
				ISNULL(CAST(Plazas.PlazaID AS int), 0) AS PlazaID
				,CAST(Plazas.PlazaCode AS varchar(50)) AS PlazaCode
				,CAST(CASE WHEN Facility.TSAFlag = 1 THEN Plazas.ExitPlazaCode ELSE Plazas.PlazaCode END AS varchar(50)) AS IPS_PlazaCode
				,ISNULL(CAST(Plazas.PlazaName AS varchar(50)), '') AS PlazaName
				,P.PlazaLatitude AS PlazaLatitude 
				,P.PlazaLongitude AS PlazaLongitude
				,P.ZipCode AS ZipCode
				,P.COUNTY AS County
				---------------------------------Facility Level -----------------------------------------
				,Facility.FacilityID
				,Facility.FacilityCode
				,Facility.FacilityName
				,Facility.IPS_FacilityCode
				,Facility.TSAFlag
				,Facility.TSAFacilityID
				,Facility.BitMaskID
				,Facility.SubAgencyAbbrev
				,Facility.OperationsAgency
				,Facility.AgencyID
				,Facility.AgencyType
				,Facility.AgencyName
				,Facility.AgencyCode
				,Facility.AgencyStartDate
				,Facility.AgencyEndDate
				,CAST(Plazas.LND_UpdateDate AS datetime2(3)) AS LND_UpdatedDate
				,SYSDATETIME() AS EDW_UpdatedDate
			FROM LND_TBOS.TollPlus.Plazas AS Plazas
			JOIN dbo.Plaza_GIS_data AS P ON Plazas.PlazaID=P.PlazaID
			JOIN dbo.Dim_Facility AS Facility ON Plazas.LocationID = Facility.FacilityID
			OPTION (LABEL = 'dbo.Dim_Plaza_NEW Load');
		
		-- Log
		SET  @Log_Message = 'Loaded dbo.Dim_Plaza_NEW with Plaza level + dbo.Dim_Facility'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics and swap table
		CREATE STATISTICS STATS_dbo_Dim_Plaza_01 ON dbo.Dim_Plaza_NEW (PlazaID);
		CREATE STATISTICS STATS_dbo_Dim_Plaza_02 ON dbo.Dim_Plaza_NEW (FacilityID);
		CREATE STATISTICS STATS_dbo_Dim_Plaza_03 ON dbo.Dim_Plaza_NEW (IPS_PlazaCode);
		CREATE STATISTICS STATS_dbo_Dim_Plaza_04 ON dbo.Dim_Plaza_NEW (AgencyID);
		
		EXEC Utility.TableSwap 'dbo.Dim_Plaza_NEW', 'dbo.Dim_Plaza'

		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Plaza' TableName, * FROM dbo.Dim_Plaza ORDER BY 2 DESC

		--=============================================================================================================
		-- Load dbo.Dim_Lane		->	 Lane + Plaza + Facility + Agency levels
		--=============================================================================================================

		IF OBJECT_ID('dbo.Dim_Lane_NEW') IS NOT NULL DROP TABLE dbo.Dim_Lane_NEW
		CREATE TABLE dbo.Dim_Lane_NEW WITH (CLUSTERED INDEX ( LaneID ), DISTRIBUTION = REPLICATE)
			AS 
			SELECT 
				  ISNULL(CAST(Lanes.LaneID AS INT), 0) AS LaneID
				, ISNULL(CAST(Lanes.LaneCategoryID AS INT), 0) AS LaneCategoryID 
				, ISNULL(CAST(Lanes.LaneCode AS VARCHAR(50)), '') AS LaneCode
				, CASE WHEN Plaza.TSAFlag = 1 AND Lanes.ExitLaneCode IS NOT NULL THEN Lanes.ExitLaneCode WHEN CHARINDEX('-',REVERSE(Lanes.LaneCode)) > 0 THEN REPLACE(LTRIM(REPLACE(REVERSE(LEFT(REVERSE(Lanes.LaneCode),CHARINDEX('-',REVERSE(Lanes.LaneCode))-1)), '0', ' ')), ' ', '0') END AS LaneNumber
				, ISNULL(CAST(Lanes.LaneName AS VARCHAR(50)), '') AS LaneName
				, CAST(Lanes.Direction AS VARCHAR(50)) AS LaneDirection
				, L.Latitude AS LaneLatitude
				, L.Longitude AS LaneLongitude
				, L.ZipCode AS LaneZipCode
				, L.County	AS LaneCountyName
				, L.Mileage AS Mileage
				, ISNULL(CAST(Lanes.ExitLaneCode AS VARCHAR(3)), '') AS ExitLaneCode
				---------------------------------------------Plaza Level--------------------------
				, Plaza.PlazaID
				, Plaza.PlazaCode
				, Plaza.IPS_PlazaCode
				, Plaza.PlazaName
				, Plaza.PlazaLatitude AS PlazaLatitude
				, Plaza.plazaLongitude AS PlazaLongitude
				, Plaza.ZipCode AS PlazaZipCode
				, Plaza.COUNTY	AS PlazaCountyName
				, CAST(PlazaSortOrder AS INT) AS PlazaSortOrder
				, L.Active
				--------------------------------------------Facility Level-------------------------
				, Plaza.FacilityID
				, Plaza.FacilityCode
				, Plaza.FacilityName
				, Plaza.IPS_FacilityCode
				, Plaza.TSAFlag 
				, Plaza.TSAFacilityID
				, Plaza.BitMaskID
				, Plaza.SubAgencyAbbrev
				, Plaza.OperationsAgency
				---------------------------------------------Agency Level--------------------------	
				, Plaza.AgencyID
				, Plaza.AgencyType
				, Plaza.AgencyName
				, Plaza.AgencyCode
				, Plaza.AgencyStartDate
				, Plaza.AgencyEndDate
				, ISNULL(CAST(Lanes.UpdatedDate AS DATETIME2(3)), '1900-01-01') AS UpdatedDate
				, SYSDATETIME() AS EDW_UpdatedDate
			FROM LND_TBOS.TollPlus.Lanes AS Lanes			
			LEFT JOIN dbo.Dim_Plaza AS Plaza ON Lanes.PlazaID = Plaza.PlazaID
			JOIN dbo.Lane_GIS_Data L ON L.LANEID=Lanes.LaneID AND plaza.PlazaID = Lanes.PlazaID
			OPTION (LABEL = 'dbo.Dim_Lane_NEW Load');
		
		-- Log
		SET  @Log_Message = 'Loaded dbo.Dim_Lane with Lane level + dbo.Dim_Week + dbo.Dim_Plaza'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, '-1', -1, 'I'

		-- Create statistics and swap table
		CREATE STATISTICS STATS_Dim_Lane_01 ON dbo.Dim_Lane_NEW (LaneID);
		CREATE STATISTICS STATS_Dim_Lane_02 ON dbo.Dim_Lane_NEW (PlazaID);
		CREATE STATISTICS STATS_Dim_Lane_04 ON dbo.Dim_Lane_NEW (FacilityID);
		CREATE STATISTICS STATS_Dim_Lane_05 ON dbo.Dim_Lane_NEW (AgencyID);
		CREATE STATISTICS STATS_Dim_Lane_06 ON dbo.Dim_Lane_NEW (AgencyID, FacilityID, PlazaID, LaneID);
		CREATE STATISTICS STATS_Dim_Lane_07 ON dbo.Dim_Lane_NEW (LaneCode);
		CREATE STATISTICS STATS_Dim_Lane_08 ON dbo.Dim_Lane_NEW (LaneNumber);
		CREATE STATISTICS STATS_Dim_Lane_09 ON dbo.Dim_Lane_NEW (IPS_PlazaCode);
		CREATE STATISTICS STATS_Dim_Lane_10 ON dbo.Dim_Lane_NEW (IPS_FacilityCode);

		EXEC Utility.TableSwap 'dbo.Dim_Lane_NEW', 'dbo.Dim_Lane'

		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Dim_Lane' TableName, * FROM dbo.Dim_Lane ORDER BY 2 DESC
									 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load of Lane Hierarchy dim tables', '-1', NULL, 'I'
	
	END	TRY	

	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, '-1', NULL, 'E';
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error all the way to Data Manager
	
	END CATCH
END

/*

--:: Testing Zone

EXEC Dev.Dim_Lane_Hierarchy_Full_Load

SELECT * FROM Utility.ProcessLog 
WHERE LogDate > '2020-07-30' AND LogSource IN ('dbo.Dim_Lane','dbo.Dim_Plaza','dbo.Dim_Facility','dbo.Dim_Agency') 
ORDER BY LogDate DESC

--:: Quick check
SELECT * FROM EDW_RITE.dbo.Dim_Agency ORDER BY 1
SELECT * FROM EDW_TRIPS.dbo.Dim_Agency ORDER BY 1

--:: Quick check
SELECT * FROM EDW_RITE.dbo.Dim_Facility ORDER BY 1
SELECT * FROM EDW_TRIPS.dbo.Dim_Facility ORDER BY 1

--:: Quick check
SELECT * FROM EDW_RITE.dbo.Dim_Plaza-- ORDER BY 1
where plaza_Abbrev not in (
SELECT plazacode FROM EDW_TRIPS.dbo.Dim_Plaza ) ORDER BY 1

--:: Quick check
SELECT * FROM EDW_RITE.dbo.Dim_Lane --ORDER BY 1
where lane_Abbrev not in (
SELECT LaneCode FROM EDW_TRIPS.dbo.Dim_Lane_NEW where lanecode ='DFW-ENC-129') ORDER BY 1


*/


