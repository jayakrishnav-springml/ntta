CREATE PROC [dbo].[Dim_Host_Service_Load] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_Host_Service. This is the central dimension in Nagios data model for Host devices and Services.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039845	Shankar		2021-03-26	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Host_Service_Load 
SELECT * FROM dbo.Dim_Host_Service ORDER BY 2,1
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
###################################################################################################################
*/
BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_Host_Service_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 1 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_Host_Service
		--=============================================================================================================

		--:: Get #Dim_Host_Stage data 
		IF OBJECT_ID('tempdb..#Dim_Host_Stage') IS NOT NULL DROP TABLE #Dim_Host_Stage
		CREATE TABLE #Dim_Host_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (Host_Object_ID)) AS
		WITH Dim_Host_CTE AS
		(
			SELECT	ho.object_id Host_Object_ID,
					ho.name1 Host,
					CASE	WHEN ho.name1 LIKE '%UPS%'				THEN 'UPS'
							WHEN ho.name1 LIKE 'CCTV%'	OR ho.name1 LIKE 'NATE%' THEN 'CCTV'
							WHEN ho.name1 LIKE '%PDU%'				THEN 'PDU'
							WHEN ho.name1 LIKE '%AVI%'				THEN 'AVI'
							WHEN ho.name1 LIKE '%GTWY%'				THEN 'GateWay'
							WHEN ho.name1 LIKE '%IOC'				THEN 'IOC'
							WHEN hg.alias LIKE '%tolling_cameras%'	THEN 'Tolling Camera'
							WHEN hg.alias LIKE 'VES-%'	THEN 'VES Controller'
							WHEN hg.alias LIKE 'LC-%'	THEN 'Lane Controller'
							WHEN hg.alias LIKE 'cctv%'				THEN 'CCTV'
							--WHEN ho.name1 LIKE '%HVAC%'				THEN 'HVAC' -- not required, per Raymond on 10/15/2021
							--WHEN ho.name1 LIKE '%WVTRNX%'			THEN 'Wavetronix' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE 'Data Loggers%'		THEN 'Data Logger' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE 'data_logger_cameras%' THEN 'DLOG Camera' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE 'SPEED%'				THEN 'SpeedMap LC' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE '%SERVERS%'			THEN 'Server' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE '%gate%' AND hg.alias NOT LIKE '%CCTV%' THEN 'Gate' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE '%fireeye%'			THEN 'Fire Eye' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE '%lonestar%'			THEN 'Lonestar' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE 'infrastructure collectors'	THEN 'Infrastructure Collectors' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE '%testlane%'			THEN 'Unknown' -- not required, per Raymond on 10/15/2021 (used to be under Lane Controller)
							--ELSE hg.alias -- not required, per Raymond on 10/19. maps to all other host groups
					END Host_Type,
					CASE WHEN ho.name1 LIKE '%SRT%' OR ho.name1 LIKE 'CCTV ITS S%' OR ho.name1 LIKE 'CCTV S%' OR ho.name1 LIKE 'ITS S%' THEN 'SRT'
						 WHEN ho.name1 LIKE '%360%' OR ho.name1 LIKE 'CCTV ITS T%' OR ho.name1 LIKE 'CCTV T%' THEN '360'
						 WHEN ho.name1 LIKE '%PGBT%' OR ho.name1 LIKE '%PGBW%' OR ho.name1 LIKE 'CCTV%ITS P%' OR ho.name1 LIKE 'CCTV P%' THEN 'PGBT'
						 WHEN ho.name1 LIKE '%AATT%' THEN 'AATT'
						 WHEN ho.name1 LIKE '%PMC%' OR ho.name1 LIKE '%FOC%' OR ho.name1 LIKE 'CCTV GE%' OR ho.name1 LIKE 'GE %' THEN 'Facilities'
						 WHEN ho.name1 LIKE '%CTP%' OR ho.name1 LIKE 'CCTV C%' THEN 'CTP'
						 WHEN ho.name1 LIKE '%DNT%' OR ho.name1 LIKE 'CCTV D%' OR ho.name1 LIKE 'CCTV%ITS D%'  THEN 'DNT'
						 WHEN ho.name1 LIKE '%LLTB%' THEN 'LLTB'
						 WHEN ho.name1 LIKE '%MCLB%' THEN 'MCLB'
						 ELSE 'Unknown'  
					END Host_Facility, 
					REVERSE(SUBSTRING(REVERSE(CASE WHEN CHARINDEX('-', ho.name1, CHARINDEX('-', ho.name1)) > 1 AND ho.name1 NOT LIKE '%speed%' THEN SUBSTRING(ho.name1, 1, CHARINDEX('-', ho.name1, CHARINDEX('-', ho.name1)+1)) END),2,50)) Host_Plaza,
					P.PlazaLatitude Plaza_Latitude,
					P.PlazaLongitude Plaza_Longitude,
					ho.is_active Is_Active,
					COALESCE(h.LND_UpdateDate, ho.LND_UpdateDate) LND_UpdateDate
			FROM	LND_NAGIOS.dbo.nagios_objects ho 
			LEFT JOIN LND_NAGIOS.dbo.nagios_hosts h 
				 ON ho.object_id = h.host_object_id 
			LEFT JOIN LND_NAGIOS.dbo.nagios_hostgroup_members hgm 
				 ON h.host_object_id = hgm.host_object_id  
			LEFT JOIN LND_NAGIOS.dbo.nagios_hostgroups hg 
				 ON hgm.hostgroup_id = hg.hostgroup_id
			LEFT JOIN EDW_TRIPS.dbo.Dim_Plaza P 
				 ON P.FacilityCode = CASE WHEN CHARINDEX('-', ho.name1) > 1 THEN SUBSTRING(ho.name1, 1, ISNULL(NULLIF(CHARINDEX('-', ho.name1)-1,-1),0)) END 
					AND P.PlazaCode = CASE WHEN CHARINDEX('-', ho.name1, CHARINDEX('-', ho.name1)) > 1 THEN SUBSTRING(SUBSTRING(ho.name1, CHARINDEX('-', ho.name1)+1,50),1,  ISNULL(NULLIF(CHARINDEX('-', SUBSTRING(ho.name1, CHARINDEX('-', ho.name1)+1,50))-1,-1),0)) END 
			WHERE	ho.objecttype_id = 1
					--AND (hg.alias <> 'collectors' OR hg.alias IS NULL)
					--AND ho.name1 NOT LIKE 'test%'

		)
		SELECT	Host_Object_ID, Host, ISNULL(NULLIF(Host_Type,''),'Unknown') Host_Type, Host_Facility, ISNULL(NULLIF(Host_Plaza,''),'Unknown') Host_Plaza, Plaza_Latitude, Plaza_Longitude, Is_Active, LND_UpdateDate
		FROM	(
					SELECT	Host_Object_ID, Host, Host_Type, Host_Facility, Host_Plaza, Plaza_Latitude, Plaza_Longitude, Is_Active, LND_UpdateDate, ROW_NUMBER() OVER (PARTITION BY Host_Object_ID ORDER BY Host_Type DESC) RN
					FROM	Dim_Host_CTE
				) h
		WHERE	RN = 1
		AND Host_Type IS NOT NULL		 

		--:: Get #Dim_Service_Stage data 
		IF OBJECT_ID('tempdb..#Dim_Host_Service_Stage') IS NOT NULL DROP TABLE #Dim_Host_Service_Stage
		CREATE TABLE #Dim_Host_Service_Stage WITH (LOCATION = USER_DB, DISTRIBUTION = REPLICATE) AS
		SELECT	h.Host_Object_ID AS Nagios_Object_ID, 'Host' AS Object_Type, h.Host_Facility, h.Host_Type, h.Host, NULL Service, h.Host_Plaza, h.Plaza_Latitude, h.Plaza_Longitude, h.Is_Active, h.LND_UpdateDate 
		FROM	#Dim_Host_Stage h
		UNION ALL
		SELECT	s.Service_Object_ID AS Nagios_Object_ID, 'Service'AS Object_Type, h.Host_Facility, h.Host_Type, h.Host, so.name2 Service, h.Host_Plaza, h.Plaza_Latitude, h.Plaza_Longitude, so.Is_Active, s.LND_UpdateDate 
		FROM	#Dim_Host_Stage h
		JOIN	LND_NAGIOS.dbo.nagios_services s  
				ON s.host_object_id = h.host_object_id 
		JOIN	LND_NAGIOS.dbo.nagios_objects so
				ON s.service_object_id = so.object_id

		IF @Trace_Flag = 1 SELECT '#Dim_Host_Service_Stage' DataTable, * FROM dbo.#Dim_Host_Service_Stage ORDER BY 2,1

		IF OBJECT_ID('dbo.Dim_Host_Service_NEW') IS NOT NULL DROP TABLE dbo.Dim_Host_Service_NEW
		CREATE TABLE dbo.Dim_Host_Service_NEW WITH (CLUSTERED INDEX (Nagios_Object_ID), DISTRIBUTION = REPLICATE) AS
		--:: New/existing rows
		SELECT	Nagios_Object_ID, Object_Type, Host_Facility, Host_Type, Host, Service, Host_Plaza, Plaza_Latitude, Plaza_Longitude, Is_Active, CONVERT(BIT,0) AS Is_Deleted, LND_UpdateDate, GETDATE() EDW_UpdateDate 
		FROM	#Dim_Host_Service_Stage hss
		UNION ALL
		--:: Keep deleted rows as there may be events
		SELECT	Nagios_Object_ID, Object_Type, Host_Facility, Host_Type, Host, Service, Host_Plaza, Plaza_Latitude, Plaza_Longitude, 0 Is_Active, CONVERT(BIT,1) AS Is_Deleted, LND_UpdateDate, GETDATE() EDW_UpdateDate 
		FROM	dbo.Dim_Host_Service hs 
		WHERE	NOT EXISTS (SELECT 1 FROM #Dim_Host_Service_Stage hss WHERE hs.Nagios_Object_ID = hss.Nagios_Object_ID) 
		OPTION (LABEL = 'Load dbo.Dim_Host_Service_NEW')

		SET  @Log_Message = 'Loaded dbo.Dim_Host_Service_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_Dim_Host_Service_001 ON dbo.Dim_Host_Service_NEW (Object_Type)
		CREATE STATISTICS STATS_Dim_Host_Service_002 ON dbo.Dim_Host_Service_NEW (Host_Facility)
		CREATE STATISTICS STATS_Dim_Host_Service_003 ON dbo.Dim_Host_Service_NEW (Host_Type)
		CREATE STATISTICS STATS_Dim_Host_Service_004 ON dbo.Dim_Host_Service_NEW (Host)
		CREATE STATISTICS STATS_Dim_Host_Service_005 ON dbo.Dim_Host_Service_NEW (Service)
		CREATE STATISTICS STATS_Dim_Host_Service_006 ON dbo.Dim_Host_Service_NEW (Host_Plaza)
		CREATE STATISTICS STATS_Dim_Host_Service_007 ON dbo.Dim_Host_Service_NEW (Plaza_Latitude)
		CREATE STATISTICS STATS_Dim_Host_Service_008 ON dbo.Dim_Host_Service_NEW (Plaza_Longitude)
		CREATE STATISTICS STATS_Dim_Host_Service_009 ON dbo.Dim_Host_Service_NEW (Is_Active)
		CREATE STATISTICS STATS_Dim_Host_Service_010 ON dbo.Dim_Host_Service_NEW (Is_Deleted)

		SET  @Log_Message = 'Created STATISTICS on dbo.Dim_Host_Service_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_Host_Service_NEW', 'dbo.Dim_Host_Service'
	
		SET  @Log_Message = 'Completed dbo.Dim_Host_Service load' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

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
EXEC dbo.Dim_Host_Service_Load

EXEC Utility.FromLog 'dbo.Dim_Host_Service', 1
SELECT * FROM dbo.Dim_Host_Service ORDER BY Host, Object_Type

--:: Testing
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Active = 0
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Active = 1 AND Object_Type = 'Host'
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Active = 1 AND Object_Type = 'Service'
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Active = 0 AND Object_Type = 'Host'
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Active = 0 AND Object_Type = 'Service'
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Deleted = 1
SELECT * FROM dbo.Fact_Host_Service_Event F JOIN dbo.Dim_Host_Service D ON D.Nagios_Object_ID = F.Nagios_Object_ID WHERE D.Is_Active = 0

*/


