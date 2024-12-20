CREATE PROC [dbo].[Plaza_Lane_GIS_Data_Full_Load] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Plaza_GIS_Data and dbo.Lane_GIS_Data tables. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Gouthami	2020-10-14	New!
CHG0039000	Gouthami	2021-06-04	Removed unnecessary joins from Lane_GIS_Data as there is PlazaID in GIS file
									and changed the default value of plaza lattitude and longitude to 0

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Plaza_Lane_GIS_Data_Full_Load

EXEC Utility.FromLog 'dbo.Plaza_Lane_GIS_Data_Full_Load', 1
SELECT TOP 100 'dbo.Lane_GIS_Data' Table_Name, * FROM dbo.Lane_GIS_Data ORDER BY 2
SELECT TOP 100 'dbo.Plaza_GIS_Data' Table_Name, * FROM dbo.Plaza_GIS_Data ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Plaza_Lane_GIS_Data_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Lane_GIS_Data
		--=============================================================================================================
		IF OBJECT_ID('dbo.Lane_GIS_Data_NEW') IS NOT NULL  DROP TABLE dbo.Lane_GIS_Data_NEW
		CREATE TABLE dbo.Lane_GIS_Data_NEW WITH (CLUSTERED INDEX(LaneID), DISTRIBUTION=REPLICATE) AS 
		SELECT DISTINCT
			   E.LaneID,
			   C.PlazaID,
			   E.LaneName,
			   E.Direction,
			   CAST(COALESCE(G.Latitude, GP1.YCoord,	LC.YCOORD,0) AS DECIMAL(23, 12)) AS Latitude,
			   CAST(COALESCE(G.Longitude,  GP1.XCoord, LC.XCOORD,0) AS DECIMAL(23, 12)) AS Longitude,
			   COALESCE(G.ZipCode, GP1.PostCode, 	0) AS ZipCode,
			   COALESCE( G.COUNTY, GP1.COUNTY, X.COUNTY,'') AS County,
			   ISNULL(M.MILEAGE, 0) AS Mileage,
			   CASE
				   WHEN G.[STATUS] = 'Closed' THEN
					   0
				   ELSE
					   1
			   END AS Active
			   ,L.PlazaSortOrder	   
		FROM LND_TBOS.TollPlus.AGENCIES A
			INNER JOIN LND_TBOS.TollPlus.Locations B
				ON A.AgencyID = B.AgencyID
			INNER JOIN LND_TBOS.TollPlus.Plazas C
				ON B.LocationID = C.LocationID
			INNER JOIN LND_TBOS.TollPlus.Lanes E 
				ON C.PlazaID = E.PlazaID
			LEFT JOIN Ref.Directions D
				ON E.Direction = D.DIREDESC
			LEFT JOIN Ref.Facility_Sub_Agency SA
				ON B.LocationCode = SA.FacilityAbbrev
			LEFT JOIN Ref.Lane_GIS_data G
				ON E.LaneID = G.LANEID
		LEFT JOIN
			(
				SELECT PlazaID,
					   RITENAME,
					   YCOORD,
					   XCOORD,
					   POSTCODE,
					   COUNTY,
					   ROW_NUMBER() OVER (PARTITION BY RITENAME ORDER BY [TYPE], [ROADWAYNAME]) RN
				FROM Ref.Plaza_GIS_Data
			) GP1
				ON C.PlazaID=GP1.PlazaID
				   AND GP1.RN = 1
				
			LEFT JOIN
			(
				SELECT CORRIDOR,
					   RITENAME,
					   YCOORD,
					   XCOORD,
					   ROW_NUMBER() OVER (PARTITION BY CORRIDOR, RITENAME ORDER BY [TYPE] DESC) AS RW
				FROM Ref.NTTA_Toll_Locations
			) LC
				ON C.PlazaCode LIKE (LC.RITENAME + '%')
				   AND LC.CORRIDOR = B.LocationCode
				   AND LC.RW = 1
			LEFT JOIN Ref.Plaza_County_XREF X
				ON X.PLAZAID = C.PlazaID
				   AND X.LANEDIRECTION = ISNULL(G.LaneDirection, D.DIREDESC)
			LEFT JOIN Ref.Plaza_Mileage M
				ON M.PLAZAID = C.PlazaID
				   AND M.LANEDIRECTION = ISNULL(G.LaneDirection, D.DIREDESC)
			LEFT JOIN Ref.DIM_LANE L ON L.LANEID = E.LaneID 
				   
				OPTION (LABEL = 'dbo.Lane_GIS_Data_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Lane_GIS_Data_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_YOUR_SCHEMA_Lane_GIS_Data_01 ON dbo.Lane_GIS_Data_NEW (LaneID);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Lane_GIS_Data_NEW', 'dbo.Lane_GIS_Data'

		--=============================================================================================================
		-- Load dbo.Plaza_GIS_Data
		--=============================================================================================================
		IF OBJECT_ID('dbo.Plaza_GIS_Data_NEW') IS NOT NULL  DROP TABLE dbo.Plaza_GIS_Data_NEW
		CREATE TABLE dbo.Plaza_GIS_Data_NEW WITH (CLUSTERED INDEX(PlazaID), DISTRIBUTION=REPLICATE) AS 
		SELECT DISTINCT
						E.PlazaID
			  			,ISNULL(G.Latitude, 0) AS PlazaLatitude
						,ISNULL(G.Longitude, 0) AS PlazaLongitude
						,ISNULL(G.ZipCode,0) AS ZipCode
						,ISNULL(G.County,'') AS COUNTY	    
		FROM LND_TBOS.TollPlus.AGENCIES A
					INNER JOIN LND_TBOS.TollPlus.Locations B
						ON A.AgencyID = B.AgencyID
					INNER JOIN LND_TBOS.TollPlus.Plazas  C
						ON B.LocationID = C.LocationID
					INNER JOIN LND_TBOS.TollPlus.Lanes E
						ON C.PlazaID = E.PlazaID
				  LEFT JOIN (
							SELECT
								PlazaID,Latitude,Longitude,ZipCode,County,
								ROW_NUMBER() OVER (PARTITION BY PlazaID ORDER BY  ACTIVE,DIRECTION,LANEID) AS RN
							FROM dbo.lane_GIS_Data --WHERE LANE_ID=31
							) AS G ON C.PlazaID = G.plazaID AND RN = 1
		OPTION (LABEL = 'dbo.Plaza_GIS_Data_NEW_SET Load');
		
		SET  @Log_Message = 'Loaded dbo.Plaza_GIS_Data_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_Plaza_GIS_Data_00 ON dbo.Plaza_GIS_Data_NEW (PlazaID);		
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Plaza_GIS_Data_NEW', 'dbo.Plaza_GIS_Data'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 
		BEGIN
		SELECT TOP 1000 'dbo.Lane_GIS_Data' TableName, * FROM dbo.Plaza_GIS_Data ORDER BY 2 DESC
		SELECT TOP 1000 'dbo.PLaza_GIS_Data' TableName, * FROM dbo.Plaza_GIS_Data ORDER BY 2 DESC
		END
	
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
EXEC dbo.Rite_Plaza_Lane_GIS_Data_Full_Load

EXEC Utility.FromLog 'dbo.Dim_InvoiceStage', 1
SELECT 'LND_TBOS.MIR.ReasonCodes' Table_name,* FROM LND_TBOS.MIR.ReasonCodes ORDER BY 2
SELECT TOP 100 'dbo.Dim_InvoiceStage' Table_Name, * FROM dbo.Dim_InvoiceStage ORDER BY 2

*/


