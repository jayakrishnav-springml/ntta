CREATE PROC [dbo].[Lane_Camera_Mapping_Load_After_XL_Import] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Run after importing Lane_Camera_Mapping XL data into Ref.Lane_Camera_Mapping.
1. Auto fill Camera for a Lane Controller Host if mapping is found for the redundant Host.
•	VES Controller ends with AA or it’s redundant Host ends with BB with only one of them being active at a given time; 
•	Lane Controller ends with A  or it’s redundant Host ends with B with only one of them being active at a given time. 
•	The Camera mapping is identical for both main host and redundant host for the same metric suffix.
2. Update dbo.Dim_Host_Service_Metric to reflect the latest data. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039845	Shankar		2021-10-21	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Lane_Camera_Mapping_Load_After_XL_Import
SELECT 'Bkup.Lane_Camera_Mapping' TableName, * FROM Bkup.Lane_Camera_Mapping ORDER BY 2,3
SELECT 'Ref.Lane_Camera_Mapping' TableName, * FROM Ref.Lane_Camera_Mapping ORDER BY 2,3
SELECT 'dbo.Dim_Host_Service_Metric' TableName, * FROM dbo.Dim_Host_Service_Metric ORDER BY LND_UpdateDate DESC, Host, Service, Metric_Name
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Lane_Camera_Mapping_Load_After_XL_Import%' ORDER BY 1 DESC
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		--:: Debug
		-- DECLARE @IsFullLoad BIT = 1

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Lane_Camera_Mapping_Load_After_XL_Import', @Log_Start_Date DATETIME2 (3) = SYSDATETIME()
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 1 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started dbo.Lane_Camera_Mapping_Load_After_XL_Import', 'I', NULL, NULL

		--======================================================================
		-- Insert the missing Camera mapping for a Controller pairs
		--======================================================================
		INSERT Ref.Lane_Camera_Mapping (Controller ,Metric_Suffix,Camera,EDW_UpdateDate)
		SELECT CASE WHEN N.Controller  LIKE '%A' THEN REVERSE(SUBSTRING(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller ))),50)) + REPLACE(REVERSE(LEFT(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller )))-1)),'A','B')
					WHEN N.Controller  LIKE '%B' THEN REVERSE(SUBSTRING(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller ))),50)) + REPLACE(REVERSE(LEFT(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller )))-1)),'B','A')
				END Controller ,
				Metric_Suffix,
				Camera,
				EDW_UpdateDate
		FROM Ref.Lane_Camera_Mapping N
		WHERE	NOT EXISTS (
				SELECT 1 
				FROM	Ref.Lane_Camera_Mapping S 
				WHERE	S.Controller  = CASE WHEN N.Controller  LIKE '%A' THEN REVERSE(SUBSTRING(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller ))),50)) + REPLACE(REVERSE(LEFT(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller )))-1)),'A','B')
											 WHEN N.Controller  LIKE '%B' THEN REVERSE(SUBSTRING(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller ))),50)) + REPLACE(REVERSE(LEFT(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller )))-1)),'B','A')
											END  
						AND S.Metric_Suffix = N.Metric_Suffix)
				AND CASE WHEN N.Controller  LIKE '%A' THEN REVERSE(SUBSTRING(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller ))),50)) + REPLACE(REVERSE(LEFT(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller )))-1)),'A','B')
						 WHEN N.Controller  LIKE '%B' THEN REVERSE(SUBSTRING(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller ))),50)) + REPLACE(REVERSE(LEFT(REVERSE(N.Controller ),CHARINDEX('-',(REVERSE(N.Controller )))-1)),'B','A')
					END IN (SELECT Host From dbo.Dim_Host_Service WHERE Object_Type = 'Host')

		SET  @Log_Message = 'Inserted the missing Camera mapping for a Controller pair into Ref.Lane_Camera_Mapping' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--======================================================================
		-- Reload dbo.Dim_Host_Service_Metric
		--======================================================================
		IF OBJECT_ID('dbo.Dim_Host_Service_Metric_NEW') IS NOT NULL DROP TABLE dbo.Dim_Host_Service_Metric_NEW
		CREATE TABLE dbo.Dim_Host_Service_Metric_NEW WITH (CLUSTERED INDEX (Host_Service_Metric_ID), DISTRIBUTION = REPLICATE) AS
		-- Existing rows with the latest data coming from dbo.Dim_Host_Service, Ref.Lane_Camera_Mapping tables
		SELECT	D.Host_Service_Metric_ID
				, D.Nagios_Object_ID
				, COALESCE(HS.Object_Type, D.Object_Type)			Object_Type
				, COALESCE(HS.Host_Facility, D.Host_Facility)		Host_Facility
				, COALESCE(HS.Host_Plaza, D.Host_Plaza)				Host_Plaza
				, COALESCE(HS.Host_Type, D.Host_Type)				Host_Type
				, COALESCE(HS.Host, D.Host)							Host
				, COALESCE(HS.Service, D.Service)					Service
				, COALESCE(HS.Plaza_Latitude, D.Plaza_Latitude)		Plaza_Latitude
				, COALESCE(HS.Plaza_Longitude, D.Plaza_Longitude)	Plaza_Longitude
				, COALESCE(HS.Is_Active, D.Is_Active)				Is_Active
				, D.Metric_Name 
				, D.Metric_Suffix
				, CASE WHEN D.Metric_Target_Type = 'Lane' THEN D.Metric_Target_Type WHEN HT.Camera IS NOT NULL THEN 'Camera' END Metric_Target_Type
				, CASE WHEN D.Metric_Target_Type = 'Lane' THEN D.Metric_Target WHEN HT.Camera IS NOT NULL THEN HT.Camera END Metric_Target
				, D.LND_UpdateDate
				, CONVERT(DATETIME2(3),GETDATE()) EDW_UpdateDate
		FROM	dbo.Dim_Host_Service_Metric D 
		LEFT JOIN dbo.Dim_Host_Service HS	
				ON D.Nagios_Object_ID = HS.Nagios_Object_ID
		LEFT JOIN Ref.Lane_Camera_Mapping HT
				ON HS.Host = HT.Controller 
				AND D.Metric_Suffix = HT.Metric_Suffix

		OPTION (LABEL = 'Load dbo.Dim_Host_Service_Metric_NEW')

		SET  @Log_Message = 'Loaded dbo.Dim_Host_Service_Metric_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_001 ON dbo.Dim_Host_Service_Metric_NEW (Nagios_Object_ID);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_002 ON dbo.Dim_Host_Service_Metric_NEW (Object_Type);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_003 ON dbo.Dim_Host_Service_Metric_NEW (Host_Facility);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_004 ON dbo.Dim_Host_Service_Metric_NEW (Host_Type);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_005 ON dbo.Dim_Host_Service_Metric_NEW (Host);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_006 ON dbo.Dim_Host_Service_Metric_NEW (Service);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_007 ON dbo.Dim_Host_Service_Metric_NEW (Host_Plaza);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_008 ON dbo.Dim_Host_Service_Metric_NEW (Plaza_Latitude);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_009 ON dbo.Dim_Host_Service_Metric_NEW (Plaza_Longitude);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_010 ON dbo.Dim_Host_Service_Metric_NEW (Metric_Name);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_011 ON dbo.Dim_Host_Service_Metric_NEW (Metric_Suffix);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_012 ON dbo.Dim_Host_Service_Metric_NEW (Metric_Target_Type);
		CREATE STATISTICS STATS_Dim_Host_Service_Metric_013 ON dbo.Dim_Host_Service_Metric_NEW (Metric_Target);

		SET  @Log_Message = 'Created STATISTICS on dbo.Dim_Host_Service_Metric_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_Host_Service_Metric_NEW', 'dbo.Dim_Host_Service_Metric'

		SET  @Log_Message = 'Completed dbo.Dim_Host_Service_Metric reload'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
		
		SET  @Log_Message = 'Completed dbo.Lane_Camera_Mapping_Load_After_XL_Import'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		--:: Output
		IF @Trace_Flag = 1 
		BEGIN
			SELECT 'Bkup.Lane_Camera_Mapping' TableName, * FROM Bkup.Lane_Camera_Mapping ORDER BY 2,3
			SELECT 'Ref.Lane_Camera_Mapping' TableName, * FROM Ref.Lane_Camera_Mapping ORDER BY 2,3
			SELECT 'dbo.Dim_Host_Service_Metric' TableName, * FROM dbo.Dim_Host_Service_Metric ORDER BY LND_UpdateDate DESC, Host, Service, Metric_Name
			EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		END

	END	TRY

	BEGIN CATCH
			DECLARE @Error_Message VARCHAR(MAX) = '*** Error in dbo.Lane_Camera_Mapping_Load_After_XL_Import: ' + ERROR_MESSAGE();
			EXEC	Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
			THROW;  -- Rethrow the error!
	END CATCH

END



/*

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================

EXEC dbo.Lane_Camera_Mapping_Load_After_XL_Import
SELECT 'Bkup.Lane_Camera_Mapping' TableName, * FROM Bkup.Lane_Camera_Mapping ORDER BY 2,3
SELECT 'Ref.Lane_Camera_Mapping' TableName, * FROM Ref.Lane_Camera_Mapping ORDER BY 2,3
SELECT 'dbo.Dim_Host_Service_Metric' TableName, * FROM dbo.Dim_Host_Service_Metric ORDER BY LND_UpdateDate DESC, Host, Service, Metric_Name
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Lane_Camera_Mapping_Load_After_XL_Import%' ORDER BY 1 DESC

--:: Lane_Camera_Mapping data analysis									
SELECT DISTINCT Service FROM dbo.Dim_Host_Service_Metric m  WHERE m.Metric_Target IS NOT NULL AND m.Metric_Target_Type = 'Camera' 									
SELECT DISTINCT Host FROM dbo.Dim_Host_Service_Metric m WHERE service IN ('OCR Failure Rate','Missed Image Pct') AND m.Metric_Target IS NULL  ORDER BY  Host 									
SELECT DISTINCT Host, m.Metric_Suffix, Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE service IN ('OCR Failure Rate','Missed Image Pct') ORDER BY Host, m.Metric_Suffix									
SELECT DISTINCT Host_Plaza, Host, M.Object_Type, m.Metric_Target_Type, m.Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE m.Metric_Target IS NULL AND service IN ('OCR Failure Rate','Missed Image Pct') ORDER BY Host_Plaza, Host, M.Object_Type -- !!missing mapping rows!!									
SELECT DISTINCT Host_Plaza, Host, M.Object_Type, m.Metric_Target_Type, m.Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE m.Metric_Target IS NOT NULL AND service IN ('OCR Failure Rate','Missed Image Pct') ORDER BY Host_Plaza, Host, M.Object_Type  								
SELECT DISTINCT Host_Plaza, Host, M.Object_Type, Service, m.Metric_Target_Type, m.Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE m.Metric_Target IS NOT NULL AND m.Metric_Target_Type = 'Camera' ORDER BY Host_Plaza, Host, M.Object_Type, Service  									

--:: Before vs After
SELECT DISTINCT Host, m.Metric_Suffix, CASE WHEN Host = '360-MLG14-1BB' THEN NULL ELSE Metric_Target END Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE service IN ('OCR Failure Rate','Missed Image Pct') AND Host IN ( '360-MLG14-1AA','360-MLG14-1BB') ORDER BY Host, m.Metric_Suffix									
SELECT DISTINCT Host, m.Metric_Suffix, Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE service IN ('OCR Failure Rate','Missed Image Pct') AND Host IN ( '360-MLG14-1AA','360-MLG14-1BB') ORDER BY Host, m.Metric_Suffix									

--> Ref.Lane_Camera_Mapping XL File query <--
SELECT DISTINCT Host, Metric_Suffix, Metric_Target FROM dbo.Dim_Host_Service_Metric WHERE Service IN ('OCR Failure Rate','Missed Image Pct') ORDER BY 1, 2 

*/



