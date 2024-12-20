CREATE PROC [dbo].[Dim_Host_Service_Metric_Load] @IsFullLoad [BIT] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_Host_Service_Metric. This proc parses the metric data from Host_Event and Service_Event tables
for events after the last update date and does the the incremental load of Stage.Host_Service_Metric_Data which is
used in loading dbo.Dim_Host_Service_Metric, dbo.Fact_Host_Service_Event, dbo.Fact_Host_Service_Event_Metric tables

The following 3 procs go together in tight sequence, as if all in one proc:
1. dbo.Dim_Host_Service_Metric_Load
2. dbo.Fact_Host_Service_Event_Load
3. dbo.Fact_Host_Service_Event_Metric_Load
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039845	Shankar		2021-03-26	New!
CHG0039980  Shankar	    2021-11-15  Refresh dim table with updated Lane Camera Mapping data
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Host_Service_Metric_Load 0
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_Host_Service_Metric%' ORDER BY 1 DESC
SELECT * FROM dbo.Dim_Host_Service_Metric
SELECT * FROM Utility.LoadProcessControl

--:: Log
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_Host_Service_Metric%' ORDER BY 1 DESC
SELECT * FROM Utility.LoadProcessControl

--:: Input
SELECT TOP 1000 * FROM Stage.Host_Service_Event ORDER BY Host_Service_Event_ID DESC

--:: Parsed Output Metrics
SELECT TOP 1000 'Stage.Host_Service_Metric_Data1' TableName, * FROM Stage.Host_Service_Metric_Data1 ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data2' TableName, * FROM Stage.Host_Service_Metric_Data2	ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data3' TableName, * FROM Stage.Host_Service_Metric_Data3	ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data4' TableName, * FROM Stage.Host_Service_Metric_Data4	ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data5' TableName, * FROM Stage.Host_Service_Metric_Data5	ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data6' TableName, * FROM Stage.Host_Service_Metric_Data6	ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data ' TableName, * FROM Stage.Host_Service_Metric_Data 	WHERE Nagios_Object_ID = 143 ORDER BY Host_Service_Event_ID DESC

--:: Output
SELECT * FROM dbo.Dim_Host_Service_Metric ORDER BY LND_UpdateDate DESC

--:: Data volume statistics
SELECT MIN(status_update_time), MAX(status_update_time), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.nagios_hoststatus_HIST
SELECT MIN(status_update_time), MAX(status_update_time), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.nagios_servicestatus_HIST  
SELECT MIN(Event_Date), MAX(Event_Date), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.Host_Event  
SELECT MIN(Event_Date), MAX(Event_Date), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.Service_Event  
SELECT MIN(Event_Day_ID), MAX(Event_Day_ID), COUNT_big(1) RC FROM   dbo.Fact_Host_Service_Event  
SELECT MIN(Event_Day_ID), MAX(Event_Day_ID), COUNT_big(1) RC FROM   dbo.Fact_Host_Service_Event_Metric 

SELECT CONVERT(DATE,status_update_time), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.nagios_hoststatus_HIST GROUP BY CONVERT(DATE,status_update_time) ORDER BY 1 desc
SELECT CONVERT(DATE,status_update_time), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.nagios_servicestatus_HIST GROUP BY CONVERT(DATE,status_update_time)  ORDER BY 1 desc
SELECT CONVERT(DATE,Event_Date) Event_Date, COUNT_BIG(1) Host_Event FROM   LND_NAGIOS.dbo.Host_Event GROUP BY CONVERT(DATE,Event_Date) ORDER BY 1 DESC
SELECT CONVERT(DATE,Event_Date) Event_Date, COUNT_BIG(1) Service_Event FROM   LND_NAGIOS.dbo.Service_Event GROUP BY CONVERT(DATE,Event_Date) ORDER BY 1 DESC 
SELECT CONVERT(DATE,CONVERT(VARCHAR,Event_Day_ID)) Event_Date, COUNT_BIG(1) Fact_Host_Service_Event FROM   dbo.Fact_Host_Service_Event GROUP BY CONVERT(DATE,CONVERT(VARCHAR,Event_Day_ID)) ORDER BY 1 DESC
SELECT CONVERT(DATE,CONVERT(VARCHAR,Event_Day_ID)) Event_Date, COUNT_BIG(1) Fact_Host_Service_Event_Metric FROM   dbo.Fact_Host_Service_Event_Metric GROUP BY CONVERT(DATE,CONVERT(VARCHAR,Event_Day_ID)) ORDER BY 1 DESC
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		--:: Debug
		-- DECLARE @IsFullLoad BIT = 1

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_Host_Service_Metric_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME(), @no_data_to_process BIT = 0 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 1 -- Testing
		DECLARE @Last_Updated_Date DATETIME2(3), @SQL VARCHAR(MAX)

		--======================================================================
		-- Get Host/Service Status History data from landing
		--======================================================================
		IF @IsFullLoad = 0
		BEGIN 
			EXEC	Utility.Get_UpdatedDate 'Nagios Host_Service_Event Dim & Fact Tables', @Last_Updated_Date OUTPUT 
			SET		@Log_Message = 'Started incremental load from LND_UpdateDate since the last successful run: ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
		END 
		ELSE
        BEGIN
			SELECT	@Last_Updated_Date = ISNULL(DATEADD(SECOND,-1,MIN(LND_UpdateDate)),'1/1/2021') -- 1 sec less to include the first load batch
			FROM	(	SELECT MIN(LND_UpdateDate) LND_UpdateDate FROM LND_NAGIOS.dbo.Host_Event
						UNION  
						SELECT MIN(LND_UpdateDate) LND_UpdateDate FROM LND_NAGIOS.dbo.Service_Event
					) T
			SET		@Log_Message = 'Started full load from the 1st LND_UpdateDate in LND_NAGIOS.dbo.Host_Event and dbo.Service_Event: ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
		END
		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		SET @SQL = '
		IF OBJECT_ID(''Stage.Host_Service_Event'') IS NOT NULL DROP TABLE Stage.Host_Service_Event 
		CREATE TABLE Stage.Host_Service_Event
		WITH (CLUSTERED INDEX ( Host_Service_Event_ID ASC ), DISTRIBUTION = HASH(Nagios_Object_ID))
		AS 
		SELECT	SRC.Service_Event_ID AS Host_Service_Event_ID, SRC.Service_Object_ID AS Nagios_Object_ID, SRC.Event_Date, SRC.Service_State AS Host_Service_State, SRC.Host, SRC.Service, SRC.Event_Info, SRC.Perf_Data, SRC.Metric_String, SRC.Metric_Count, SRC.LND_UpdateDate
		FROM	LND_NAGIOS.dbo.Service_Event SRC
		JOIN	dbo.Dim_Host_Service HS
				ON SRC.Service_Object_ID = HS.Nagios_Object_ID
		WHERE	SRC.LND_UpdateDate > ''' + CONVERT(VARCHAR(25),@Last_Updated_Date,121) + '''
		UNION ALL
		SELECT	SRC.Host_Event_ID AS Host_Service_Event_ID, SRC.Host_Object_ID AS Nagios_Object_ID, SRC.Event_Date, SRC.Host_State AS Host_Service_State, SRC.Host, NULL Service, SRC.Event_Info, SRC.Perf_Data, SRC.Metric_String, SRC.Metric_Count, SRC.LND_UpdateDate 
		FROM	LND_NAGIOS.dbo.Host_Event SRC
		JOIN	dbo.Dim_Host_Service HS
				ON SRC.Host_Object_ID = HS.Nagios_Object_ID
		WHERE	SRC.LND_UpdateDate > ''' + CONVERT(VARCHAR(25),@Last_Updated_Date,121) + '''
		OPTION (LABEL = ''Load Stage.Host_Service_Event'');'
	
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
		EXEC (@SQL)
		SET  @Log_Message = 'Loaded Stage.Host_Service_Event table'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @SQL

		CREATE STATISTICS STATS_Host_Service_Event_001 ON Stage.Host_Service_Event (Nagios_Object_ID)
		CREATE STATISTICS STATS_Host_Service_Event_002 ON Stage.Host_Service_Event (Service)
		CREATE STATISTICS STATS_Host_Service_Event_003 ON Stage.Host_Service_Event (Metric_String)

		--======================================================================
		--:: Load Stage.Host_Service_Metric_Data from STAGE data
		--======================================================================
	
		DECLARE @Max_Metric_Count INT = ISNULL((SELECT MAX(Metric_Count) FROM Stage.Host_Service_Event),0)
		IF @Max_Metric_Count = 0 OR (SELECT COUNT_BIG(1) FROM Stage.Host_Service_Event) = 0
		BEGIN
			SELECT  @Log_Message = 'Finished load proc, nothing process!', @no_data_to_process = 1
			EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
			RAISERROR(@Log_Message,16,1)
		END

		SET @Max_Metric_Count = CASE WHEN @Max_Metric_Count > 20 THEN 20 ELSE @Max_Metric_Count END
		DECLARE @num INT = 1, @new_SQL VARCHAR(MAX), @EQ VARCHAR(MAX) = 'CHARINDEX(''='',Metric_String)'
		IF OBJECT_ID('Stage.Host_Service_Metric_Data1') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data1 
		IF OBJECT_ID('Stage.Host_Service_Metric_Data2') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data2 
		IF OBJECT_ID('Stage.Host_Service_Metric_Data3') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data3 
		IF OBJECT_ID('Stage.Host_Service_Metric_Data4') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data4 
		IF OBJECT_ID('Stage.Host_Service_Metric_Data5') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data5 
		IF OBJECT_ID('Stage.Host_Service_Metric_Data6') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data6 
		IF OBJECT_ID('Stage.Host_Service_Metric_Data')  IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data 
 
		--:: Load dbo.Host_Service_Metric_Data1 with "=" locations. One row per event.
		SET @SQL = '
		IF OBJECT_ID(''Stage.Host_Service_Metric_Data1'') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data1 
		CREATE TABLE Stage.Host_Service_Metric_Data1 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
		SELECT 
				 Host_Service_Event_ID
				,Host_Service_State
				,Host
				,Service
				,Metric_String
				,Metric_Count
				,CASE WHEN Metric_Count >= 1 THEN CHARINDEX(''='',Metric_String) END EQ_1' + CHAR(10)

		WHILE @num < @Max_Metric_Count
		BEGIN 
			SET @num = @num + 1
			SET @EQ = 'CHARINDEX(''='',Metric_String,' + @EQ+'+1)'
			SET @SQL = @SQL + '		,CASE WHEN Metric_Count >= ' + CONVERT(VARCHAR,@num) + ' THEN ' + @EQ + ' END EQ_' + CONVERT(VARCHAR,@num) + CHAR(10)
		END
		SET @SQL = @SQL + 'FROM	Stage.Host_Service_Event' + CHAR(10) + 'WHERE Metric_Count > 0'  + CHAR(10) + 'OPTION (LABEL = ''Load Stage.Host_Service_Metric_Data1'');'

	
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
		EXEC (@SQL)
		SET  @Log_Message = 'Loaded dbo.Host_Service_Metric_Data1 with "=" locations. One row per event.'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, -1

		--:: Load dbo.Host_Service_Metric_Data2 with each metric start locations. One row per event.
		SET @num = 1 --> Reset loop counter
		SET @SQL = '
		IF OBJECT_ID(''Stage.Host_Service_Metric_Data2'') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data2 
		CREATE TABLE Stage.Host_Service_Metric_Data2 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
		SELECT 	*
				,1 M_1' + CHAR(10)

		WHILE @num < @Max_Metric_Count
		BEGIN 
			SET @num = @num + 1
			SET @SQL = @SQL + '		,CASE WHEN Metric_Count >= ' + CONVERT(VARCHAR,@num) + ' AND CHARINDEX('';'',REVERSE(SUBSTRING(Metric_String,EQ_' + CONVERT(VARCHAR,@num-1) + ',EQ_' + CONVERT(VARCHAR,@num) +'-EQ_' +  CONVERT(VARCHAR,@num-1)+')))-1 > 0 THEN PATINDEX(''%''+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_' + CONVERT(VARCHAR,@num-1) + ',EQ_' + CONVERT(VARCHAR,@num) +'-EQ_' +  CONVERT(VARCHAR,@num-1)+')),CHARINDEX('';'',REVERSE(SUBSTRING(Metric_String,EQ_' + CONVERT(VARCHAR,@num-1) + ',EQ_' + CONVERT(VARCHAR,@num) +'-EQ_' +  CONVERT(VARCHAR,@num-1)+')))-1))+''%'',Metric_String) END M_' + CONVERT(VARCHAR,@num) + CHAR(10)
		END
		SET @SQL = @SQL + 'FROM	Stage.Host_Service_Metric_Data1' + CHAR(10) + 'OPTION (LABEL = ''Load Stage.Host_Service_Metric_Data2'');'
	
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
		EXEC (@SQL)
		SET  @Log_Message = 'Loaded dbo.Host_Service_Metric_Data2 with each metric start locations. One row per event.'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, -1

		--:: Expand! Load dbo.Host_Service_Metric_Data3 with precise Metric Name and Value String for each metric. One row per event,metric.
		SET @num = 0 --> Reset loop counter
		SET @SQL = '
		IF OBJECT_ID(''Stage.Host_Service_Metric_Data3'') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data3
		CREATE TABLE Stage.Host_Service_Metric_Data3 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS'

		WHILE @num < @Max_Metric_Count
		BEGIN 
			SET @num = @num + 1
			SET @new_SQL = '
			SELECT 
				Host_Service_Event_ID,
				Host,
				Service,
				Host_Service_State,
				Metric_String,
				Metric_Count,
				' + CAST(@num AS VARCHAR) + ' AS Metric_Index,
				CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_'+ CAST(@num AS VARCHAR) +',EQ_'+ CAST(@num AS VARCHAR) + '-M_' + CAST(@num AS VARCHAR) +')) AS Metric_Name,
				SUBSTRING(Metric_String,EQ_'+ CAST(@num AS VARCHAR) + '+1,' + CASE WHEN @num = @Max_Metric_Count THEN '50' ELSE 'ISNULL(M_'+ CAST(@num+1 AS VARCHAR) + '-EQ_'+ CAST(@num AS VARCHAR) + '-1,50)' END + ') AS Value_String
			FROM  Stage.Host_Service_Metric_Data2
			WHERE Metric_Count >= ' + CAST(@num AS VARCHAR)  

			SET @SQL = @SQL + CASE WHEN @num > 1 THEN '
			UNION ALL ' ELSE '' END + @new_SQL
		END

		SET @SQL = @SQL + CHAR(10) + 'OPTION (LABEL = ''Load Stage.Host_Service_Metric_Data3'');'
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
		EXEC (@SQL)
		SET  @Log_Message = 'Loaded Stage.Host_Service_Metric_Data3 with precise Metric Name and Value String for each metric. One row per event,metric.'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, -1

		--:: Parse Value_String delimiter positions
		IF OBJECT_ID('Stage.Host_Service_Metric_Data4') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data4 
		CREATE TABLE Stage.Host_Service_Metric_Data4 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
		SELECT 
			Host_Service_Event_ID,
			Host_Service_State,
			Host,
			Service,
			Metric_Count,
			Metric_String,
			Metric_Index,
			Metric_Name,
			Value_String,
			LEFT(Value_String,CHARINDEX(';', Value_String)-1) Value_Unit,
			NULLIF(CHARINDEX(';',Value_String),0) DELIM_1,
			NULLIF(CHARINDEX(';',Value_String,CHARINDEX(';',Value_String)+1),0) DELIM_2,
			NULLIF(CHARINDEX(';',Value_String,CHARINDEX(';',Value_String,CHARINDEX(';',Value_String)+1)+1),0) DELIM_3,
			NULLIF(CHARINDEX(';',Value_String,CHARINDEX(';',Value_String,CHARINDEX(';',Value_String,CHARINDEX(';',Value_String)+1)+1)+1),0) DELIM_4
		FROM Stage.Host_Service_Metric_Data3
		WHERE Metric_Name IS NOT NULL
		--ORDER BY Host_Service_Event_ID, Metric_Index
		OPTION (LABEL = 'Load Stage.Host_Service_Metric_Data4')

		EXEC (@SQL)
		SET  @Log_Message = 'Loaded Stage.Host_Service_Metric_Data4 table. Parse Value_String delimiter positions.'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Parse Value_String
		IF OBJECT_ID('Stage.Host_Service_Metric_Data5') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data5 
		CREATE TABLE Stage.Host_Service_Metric_Data5 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
		SELECT 
			Host_Service_Event_ID,
			Host_Service_State,
			Host,
			Service,
			Metric_Count,
			Metric_String,
			Metric_Index,
			Metric_Name,
			Value_String,
			Value_Unit,
			REPLACE(Value_Unit, ISNULL(SUBSTRING(Value_Unit,NULLIF(PATINDEX('%[^0-9.-]%', Value_Unit),0),5),''),'') Metric_Value,
			SUBSTRING(Value_Unit,NULLIF(PATINDEX('%[^0-9.-]%', Value_Unit),0),5) Metric_Unit,
 			CASE WHEN DELIM_2-DELIM_1-1 > 0  THEN REPLACE(REPLACE(SUBSTRING(Value_String,DELIM_1+1,DELIM_2-DELIM_1-1),ISNULL(SUBSTRING(Value_Unit,NULLIF(PATINDEX('%[^0-9.-]%', Value_Unit),0),5),''),''),'_','') END Warning_Value,
			CASE WHEN DELIM_3-DELIM_2-1 > 0  THEN REPLACE(REPLACE(SUBSTRING(Value_String,DELIM_2+1,DELIM_3-DELIM_2-1),ISNULL(SUBSTRING(Value_Unit,NULLIF(PATINDEX('%[^0-9.-]%', Value_Unit),0),5),''),''),'_','') END Critical_Value,
			CASE WHEN DELIM_4-DELIM_3-1 > 0  THEN REPLACE(REPLACE(SUBSTRING(Value_String,DELIM_3+1,DELIM_4-DELIM_3-1),ISNULL(SUBSTRING(Value_Unit,NULLIF(PATINDEX('%[^0-9.-]%', Value_Unit),0),5),''),''),'_','') END Min_Value,
			CASE WHEN DELIM_4+1 > 0			 THEN NULLIF(REPLACE(REPLACE(REPLACE(SUBSTRING(Value_String,DELIM_4+1,50),ISNULL(SUBSTRING(Value_Unit,NULLIF(PATINDEX('%[^0-9.-]%', Value_Unit),0),5),''),''),';',''),'_',''),'')END Max_Value
		FROM Stage.Host_Service_Metric_Data4
		WHERE REPLACE(Value_Unit, ISNULL(SUBSTRING(Value_Unit,NULLIF(PATINDEX('%[^0-9.-]%', Value_Unit),0),5),''),'') NOT LIKE '%=%'
		--ORDER BY Host_Service_Event_ID, Metric_Index
		OPTION (LABEL = 'Load Stage.Host_Service_Metric_Data5')

		EXEC (@SQL)
		SET  @Log_Message = 'Loaded Stage.Host_Service_Metric_Data5 table. Parse Value_String.'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		IF OBJECT_ID('Stage.Host_Service_Metric_Data6') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data6 
		CREATE TABLE Stage.Host_Service_Metric_Data6 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
			SELECT	
				Host_Service_Event_ID,
				Host_Service_State,
				Host,
				Service,
				Metric_String,
				Metric_Index,
				CAST(CASE WHEN (Metric_Name LIKE '%.[0-9]' OR Metric_Name LIKE '%0') AND Metric_Count = 1 THEN NULL 
								WHEN Metric_Name LIKE '%[0-9][0-9]' THEN RIGHT(Metric_Name,2)
								WHEN Metric_Name LIKE '%[0-9]' THEN RIGHT(Metric_Name,1)
					END AS SMALLINT) Metric_Suffix,
				Metric_Name,
				CASE
					WHEN ISNUMERIC(Metric_Value) = 0 THEN NULL  
					ELSE CAST(Metric_Value AS DECIMAL(19,8))
				END AS Metric_Value,
				Metric_Unit,
				CASE
					WHEN ISNUMERIC(Warning_Value) = 0 THEN  NULL 
					ELSE CAST(Warning_Value AS DECIMAL(19,8))
				END AS Warning_Value,
				CASE
					WHEN ISNUMERIC(Critical_Value) = 0 THEN  NULL 
					ELSE CAST(Critical_Value AS DECIMAL(19,8))
				END AS Critical_Value,
				CASE
					WHEN ISNUMERIC(Min_Value) = 0 THEN  NULL 
					ELSE CAST(Min_Value AS DECIMAL(19,8))
				END AS Min_Value,
				CASE
					WHEN ISNUMERIC(Max_Value) = 0 THEN  NULL 
					ELSE CAST(Max_Value AS DECIMAL(19,8))
				END AS Max_Value
			FROM Stage.Host_Service_Metric_Data5
		OPTION (LABEL = 'Load Stage.Host_Service_Metric_Data6')

		SET  @Log_Message = 'Loaded Stage.Host_Service_Metric_Data6 table with key, values'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		IF OBJECT_ID('Stage.Host_Service_Metric_Data') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data 
		CREATE TABLE Stage.Host_Service_Metric_Data WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
			SELECT
				MD.Host_Service_Event_ID,
				SS.Event_Date,
				SS.Nagios_Object_ID,
				HS.Host_Type,
				SS.Host,
				MD.Service,
				MD.Host_Service_State,
				SS.Event_Info,
				MD.Metric_String,
				Metric_Index,
				Metric_Suffix,
				Metric_Name,
				Metric_Value,
				Metric_Unit,
				Warning_Value,
				Critical_Value,
				Min_Value,
				Max_Value,
				CASE
					WHEN Metric_Suffix IS NULL AND Metric_Index = 1 THEN MD.Host_Service_State
					WHEN Max_Value IS NOT NULL AND Metric_Value >= Max_Value THEN 2 -- Critical
					WHEN Min_Value IS NOT NULL AND Metric_Value < Min_Value THEN 3 -- Unknown
					WHEN Critical_Value IS NOT NULL AND Metric_Value >= Critical_Value THEN 2 -- Critical
					WHEN Warning_Value IS NOT NULL AND Metric_Value >= Warning_Value THEN 1
					ELSE 0
				END AS Metric_State,
				CAST(CASE WHEN Warning_Value > 0 THEN Metric_Value * 100 / Warning_Value ELSE NULL END AS DECIMAL(19,2)) AS Percent_Warning,
				CAST(CASE WHEN Critical_Value > 0 THEN Metric_Value * 100 / Critical_Value ELSE NULL END AS DECIMAL(19,2)) AS Percent_Critical,
				CAST(CASE WHEN Max_Value > 0 THEN Metric_Value * 100 / Max_Value ELSE NULL END AS DECIMAL(19,2)) AS Percent_Max,
				SS.LND_UpdateDate,
				CONVERT(DATETIME2(3),GETDATE()) EDW_UpdateDate
			FROM	Stage.Host_Service_Metric_Data6 MD
			JOIN	Stage.Host_Service_Event SS	ON MD.Host_Service_Event_ID = SS.Host_Service_Event_ID
			LEFT JOIN dbo.Dim_Host_Service HS	ON SS.Nagios_Object_ID = hs.Nagios_Object_ID -- Optional. FYI field Host_Type
		OPTION (LABEL = 'Load Stage.Host_Service_Metric_Data')

		SET  @Log_Message = 'Loaded Stage.Host_Service_Metric_Data table with all metric details'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		CREATE STATISTICS STATS_dbo_Host_Service_Metric_Data_01 ON Stage.Host_Service_Metric_Data (Nagios_Object_ID)
		CREATE STATISTICS STATS_dbo_Host_Service_Metric_Data_02 ON Stage.Host_Service_Metric_Data (Metric_Name)
		CREATE STATISTICS STATS_dbo_Host_Service_Metric_Data_03 ON Stage.Host_Service_Metric_Data (Metric_Suffix)
		CREATE STATISTICS STATS_dbo_Host_Service_Metric_Data_04 ON Stage.Host_Service_Metric_Data (Host_Service_Event_ID)

		--======================================================================
		--:: Load dbo.Dim_Host_Service_Metric
		--======================================================================

		--:: Insert the unknown Camera mapping from the known mapping of one of the Controller Hosts pair ending in A/B or AA/BB. 
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

		SET  @Log_Message = 'Before dbo.Dim_Host_Service_Metric Load: Copied the missing Camera mapping for a Controller based on pair into Ref.Lane_Camera_Mapping' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		IF OBJECT_ID('Temp.Host_Service_Metric') IS NOT NULL DROP TABLE Temp.Host_Service_Metric
		CREATE TABLE Temp.Host_Service_Metric WITH (HEAP, DISTRIBUTION = HASH(Nagios_Object_ID)) AS
		SELECT	 HSM.Nagios_Object_ID
				, HSM.Service
				, HSM.Metric_Name 
				, HSM.Metric_Suffix 
				, CASE 
					WHEN HSM.Event_Info LIKE '%Ln %:%' AND HSM.Metric_Suffix IS NOT NULL THEN 'Lane ' + CONVERT(VARCHAR,HSM.Metric_Suffix) 
					WHEN HT.Camera IS NOT NULL OR HSM.Service IN ('OCR Failure Rate','Missed Image Pct') THEN ISNULL(HT.Camera,'Unknown')
					END Metric_Target
				, MAX(HSM.LND_UpdateDate) LND_UpdateDate
		FROM	Stage.Host_Service_Metric_Data HSM
		LEFT JOIN Ref.Lane_Camera_Mapping HT
				ON HSM.Host = HT.Controller 
				AND HSM.Metric_Suffix = HT.Metric_Suffix  
		GROUP BY 
				HSM.Nagios_Object_ID
				, HSM.Service
				, HSM.Metric_Name 
				, HSM.Metric_Suffix 
				, CASE 
					WHEN HSM.Event_Info LIKE '%Ln %:%' AND HSM.Metric_Suffix IS NOT NULL THEN 'Lane ' + CONVERT(VARCHAR,HSM.Metric_Suffix) 
					WHEN HT.Camera IS NOT NULL OR HSM.Service IN ('OCR Failure Rate','Missed Image Pct') THEN ISNULL(HT.Camera,'Unknown')
					END
		
		CREATE STATISTICS STATS_Temp_Host_Service_Metric_01 ON Temp.Host_Service_Metric (Nagios_Object_ID)
		CREATE STATISTICS STATS_Temp_Host_Service_Metric_02 ON Temp.Host_Service_Metric (Metric_Name)
		CREATE STATISTICS STATS_Temp_Host_Service_Metric_03 ON Temp.Host_Service_Metric (Metric_Suffix)

		DECLARE @Last_Host_Service_Metric_ID	INT
		SELECT @Last_Host_Service_Metric_ID = MAX(Host_Service_Metric_ID) FROM dbo.Dim_Host_Service_Metric

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
		UNION ALL
		--:: New rows
		SELECT	ISNULL(@Last_Host_Service_Metric_ID,0) + ROW_NUMBER() OVER (ORDER BY M.Nagios_Object_ID, SUBSTRING(M.Metric_Name, 1, 1 + LEN(M.Metric_Name) - PATINDEX('%[^0-9 ]%',REVERSE(M.Metric_Name))), M.Metric_Suffix) Host_Service_Metric_ID 
				, M.Nagios_Object_ID 
				, HS.Object_Type
				, HS.Host_Facility
				, HS.Host_Plaza
				, HS.Host_Type
				, HS.Host
				, HS.Service
				, HS.Plaza_Latitude
				, HS.Plaza_Longitude
				, HS.Is_Active
				, M.Metric_Name 
				, M.Metric_Suffix 				
				, CASE WHEN M.Metric_Target LIKE 'Lane%' THEN 'Lane' WHEN M.Metric_Target IS NOT NULL THEN 'Camera' END Metric_Target_Type 
				, M.Metric_Target 
				, M.LND_UpdateDate
				, CONVERT(DATETIME2(3),GETDATE()) EDW_UpdateDate
		FROM Temp.Host_Service_Metric M
		JOIN dbo.Dim_Host_Service HS	
				ON M.Nagios_Object_ID = HS.Nagios_Object_ID
		WHERE NOT EXISTS (SELECT 1 FROM dbo.Dim_Host_Service_Metric D WHERE D.Nagios_Object_ID = M.Nagios_Object_ID AND D.Metric_Name = M.Metric_Name)

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
		
		--:: Insert new Controller Hosts in Ref.Lane_Camera_Mapping table.
		INSERT Ref.Lane_Camera_Mapping (Controller ,Metric_Suffix,Camera,EDW_UpdateDate)
		SELECT	Controller, Metric_Suffix, Metric_Target, SYSDATETIME() AS EDW_UpdateDate
		FROM	(
					SELECT	DISTINCT Host AS Controller, Metric_Suffix, ISNULL(Metric_Target,'Unknown' ) Metric_Target
					FROM	dbo.Dim_Host_Service_Metric 
					WHERE	Service IN ('OCR Failure Rate','Missed Image Pct')  
				) cmn		
		WHERE	NOT EXISTS (SELECT 1 FROM Ref.Lane_Camera_Mapping cm WHERE cmn.Controller = cm.Controller AND cmn.Metric_Suffix = cm.Metric_Suffix)

		SET  @Log_Message = 'Inserted new Controller Hosts into Ref.Lane_Camera_Mapping table'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		SET  @Log_Message = 'Completed dbo.Dim_Host_Service_Metric load'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
		--:: Output
		IF @Trace_Flag = 1 
		BEGIN
			EXEC Utility.FromLog @Log_Source, @Log_Start_Date
			SELECT TOP 100 'Stage.Host_Service_Metric_Data1' TableName, * FROM Stage.Host_Service_Metric_Data1  ORDER BY Host_Service_Event_ID DESC
			SELECT TOP 100 'Stage.Host_Service_Metric_Data2' TableName, * FROM Stage.Host_Service_Metric_Data2	ORDER BY Host_Service_Event_ID DESC
			SELECT TOP 100 'Stage.Host_Service_Metric_Data3' TableName, * FROM Stage.Host_Service_Metric_Data3	ORDER BY Host_Service_Event_ID DESC
			SELECT TOP 100 'Stage.Host_Service_Metric_Data4' TableName, * FROM Stage.Host_Service_Metric_Data4	ORDER BY Host_Service_Event_ID DESC
			SELECT TOP 100 'Stage.Host_Service_Metric_Data5' TableName, * FROM Stage.Host_Service_Metric_Data5	ORDER BY Host_Service_Event_ID DESC
			SELECT TOP 100 'Stage.Host_Service_Metric_Data6' TableName, * FROM Stage.Host_Service_Metric_Data6	ORDER BY Host_Service_Event_ID DESC
			SELECT TOP 100 'Stage.Host_Service_Metric_Data ' TableName, * FROM Stage.Host_Service_Metric_Data 	ORDER BY Host_Service_Event_ID DESC
			SELECT * FROM dbo.Dim_Host_Service_Metric ORDER BY LND_UpdateDate DESC, Host, Service, Metric_Name
		END

	END	TRY

	BEGIN CATCH
		IF @no_data_to_process = 0
		BEGIN 
			DECLARE @Error_Message VARCHAR(MAX) = '*** Error in dbo.Dim_Host_Service_Metric_Load: ' + ERROR_MESSAGE();
			EXEC	Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
			THROW;  -- Rethrow the error!
		END  
	END CATCH

END



/*

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_Host_Service_Metric_Load 0
SELECT * FROM dbo.Dim_Host_Service_Metric ORDER BY Host_Type, Host, Service, Metric_Name, Metric_Suffix
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT * FROM Utility.LoadProcessControl

--:: Data profile by Event Date
SELECT 'dbo.Host_Event' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Host_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.Host_Event GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date desc
SELECT 'dbo.Service_Event' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Service_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.Service_Event GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date DESC
SELECT 'Stage.Host_Service_Event' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM Stage.Host_Service_Event GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date desc
											 
SELECT 'dbo.Fact_Host_Service_Event' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM dbo.Fact_Host_Service_Event GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date desc
SELECT 'dbo.Fact_Host_Service_Event_Metric' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM dbo.Fact_Host_Service_Event_Metric GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date desc
SELECT 'dbo.Fact_Host_Service_Event_Metric' TableName, COUNT_BIG(1) Row_Count, MIN(Event_Date) Event_DateFrom, MAX(Event_Date) Event_DateTo FROM dbo.Fact_Host_Service_Event_Metric   ORDER BY Event_Date desc

SELECT 'dbo.nagios_hoststatus_HIST' TableName, CONVERT(DATE, status_update_time) status_update_time, COUNT_BIG(1) Row_Count, COUNT(DISTINCT host_object_id) Dist_Count FROM LND_NAGIOS.dbo.nagios_hoststatus_HIST  GROUP BY CONVERT(DATE, status_update_time) ORDER BY status_update_time desc
SELECT 'dbo.nagios_servicestatus_HIST' TableName, CONVERT(DATE, status_update_time) status_update_time, COUNT_BIG(1) Row_Count, COUNT(DISTINCT service_object_id) Dist_Count FROM LND_NAGIOS.dbo.nagios_servicestatus_HIST GROUP BY CONVERT(DATE, status_update_time) ORDER BY status_update_time desc

SELECT 'dbo.nagios_hoststatus_STAGE' TableName, LND_UpdateDate , COUNT_BIG(1) Row_Count
FROM	LND_NAGIOS.dbo.nagios_hoststatus_STAGE hs  
JOIN	LND_NAGIOS.dbo.nagios_objects ho 
		ON hs.host_object_id = ho.object_id
WHERE	(hs.current_check_attempt = hs.max_check_attempts OR hs.current_state = 0)
GROUP BY LND_UpdateDate

--:: Data profile by LND_UpdateDate
SELECT 'dbo.Host_Event' TableName, LND_UpdateDate , COUNT_BIG(1) Row_Count, COUNT(DISTINCT Host_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.Host_Event GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate desc
SELECT 'dbo.Service_Event' TableName, LND_UpdateDate , COUNT_BIG(1) Row_Count, COUNT(DISTINCT Service_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.Service_Event GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate DESC
SELECT 'Stage.Host_Service_Event' TableName, LND_UpdateDate , COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM Stage.Host_Service_Event GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate DESC
SELECT 'dbo.Fact_Host_Service_Event' TableName, LND_UpdateDate, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM dbo.Fact_Host_Service_Event GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate desc
SELECT 'dbo.Fact_Host_Service_Event_Metric' TableName, LND_UpdateDate, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM dbo.Fact_Host_Service_Event_Metric GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate desc
SELECT * FROM Utility.LoadProcessControl

SELECT 'dbo.nagios_hoststatus_HIST' TableName, LND_UpdateDate, COUNT_BIG(1) Row_Count, COUNT(DISTINCT host_object_id) Dist_Count FROM LND_NAGIOS.dbo.nagios_hoststatus_HIST  GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate desc
SELECT 'dbo.nagios_servicestatus_HIST' TableName, LND_UpdateDate, COUNT_BIG(1) Row_Count, COUNT(DISTINCT service_object_id) Dist_Count FROM LND_NAGIOS.dbo.nagios_servicestatus_HIST GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate desc

--===============================================================================================================
-- Dynamic SQL outputs
--===============================================================================================================
IF OBJECT_ID('Stage.Host_Service_Metric_Data1') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data1 
CREATE TABLE Stage.Host_Service_Metric_Data1 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
SELECT 
		Host_Service_Event_ID
		,State
		,Host
		,Service
		,Metric_String
		,Metric_Count
		,CASE WHEN Metric_Count >= 1 THEN CHARINDEX('=',Metric_String) END EQ_1
		,CASE WHEN Metric_Count >= 2 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1) END EQ_2
		,CASE WHEN Metric_Count >= 3 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1) END EQ_3
		,CASE WHEN Metric_Count >= 4 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1) END EQ_4
		,CASE WHEN Metric_Count >= 5 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1) END EQ_5
		,CASE WHEN Metric_Count >= 6 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1) END EQ_6
		,CASE WHEN Metric_Count >= 7 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1) END EQ_7
		,CASE WHEN Metric_Count >= 8 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1) END EQ_8
		,CASE WHEN Metric_Count >= 9 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_9
		,CASE WHEN Metric_Count >= 10 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_10
		,CASE WHEN Metric_Count >= 11 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_11
		,CASE WHEN Metric_Count >= 12 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_12
		,CASE WHEN Metric_Count >= 13 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_13
		,CASE WHEN Metric_Count >= 14 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_14
		,CASE WHEN Metric_Count >= 15 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_15
		,CASE WHEN Metric_Count >= 16 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_16
		,CASE WHEN Metric_Count >= 17 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_17
FROM	Stage.Host_Service_Event

IF OBJECT_ID('Stage.Host_Service_Metric_Data2') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data2 
CREATE TABLE Stage.Host_Service_Metric_Data2 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
SELECT 	*
		,1 M_1
	,CASE WHEN Metric_Count >= 2 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_1,EQ_2-EQ_1)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_1,EQ_2-EQ_1)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_1,EQ_2-EQ_1)))-1))+'%',Metric_String) END M_2
	,CASE WHEN Metric_Count >= 3 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_2,EQ_3-EQ_2)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_2,EQ_3-EQ_2)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_2,EQ_3-EQ_2)))-1))+'%',Metric_String) END M_3
	,CASE WHEN Metric_Count >= 4 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_3,EQ_4-EQ_3)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_3,EQ_4-EQ_3)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_3,EQ_4-EQ_3)))-1))+'%',Metric_String) END M_4
	,CASE WHEN Metric_Count >= 5 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_4,EQ_5-EQ_4)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_4,EQ_5-EQ_4)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_4,EQ_5-EQ_4)))-1))+'%',Metric_String) END M_5
	,CASE WHEN Metric_Count >= 6 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_5,EQ_6-EQ_5)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_5,EQ_6-EQ_5)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_5,EQ_6-EQ_5)))-1))+'%',Metric_String) END M_6
	,CASE WHEN Metric_Count >= 7 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_6,EQ_7-EQ_6)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_6,EQ_7-EQ_6)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_6,EQ_7-EQ_6)))-1))+'%',Metric_String) END M_7
	,CASE WHEN Metric_Count >= 8 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_7,EQ_8-EQ_7)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_7,EQ_8-EQ_7)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_7,EQ_8-EQ_7)))-1))+'%',Metric_String) END M_8
	,CASE WHEN Metric_Count >= 9 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_8,EQ_9-EQ_8)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_8,EQ_9-EQ_8)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_8,EQ_9-EQ_8)))-1))+'%',Metric_String) END M_9
	,CASE WHEN Metric_Count >= 10 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_9,EQ_10-EQ_9)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_9,EQ_10-EQ_9)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_9,EQ_10-EQ_9)))-1))+'%',Metric_String) END M_10
	,CASE WHEN Metric_Count >= 11 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_10,EQ_11-EQ_10)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_10,EQ_11-EQ_10)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_10,EQ_11-EQ_10)))-1))+'%',Metric_String) END M_11
	,CASE WHEN Metric_Count >= 12 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_11,EQ_12-EQ_11)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_11,EQ_12-EQ_11)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_11,EQ_12-EQ_11)))-1))+'%',Metric_String) END M_12
	,CASE WHEN Metric_Count >= 13 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_12,EQ_13-EQ_12)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_12,EQ_13-EQ_12)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_12,EQ_13-EQ_12)))-1))+'%',Metric_String) END M_13
	,CASE WHEN Metric_Count >= 14 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_13,EQ_14-EQ_13)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_13,EQ_14-EQ_13)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_13,EQ_14-EQ_13)))-1))+'%',Metric_String) END M_14
	,CASE WHEN Metric_Count >= 15 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_14,EQ_15-EQ_14)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_14,EQ_15-EQ_14)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_14,EQ_15-EQ_14)))-1))+'%',Metric_String) END M_15
	,CASE WHEN Metric_Count >= 16 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_15,EQ_16-EQ_15)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_15,EQ_16-EQ_15)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_15,EQ_16-EQ_15)))-1))+'%',Metric_String) END M_16
	,CASE WHEN Metric_Count >= 17 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_16,EQ_17-EQ_16)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_16,EQ_17-EQ_16)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_16,EQ_17-EQ_16)))-1))+'%',Metric_String) END M_17
FROM	Stage.Host_Service_Metric_Data1


IF OBJECT_ID('Stage.Host_Service_Metric_Data3') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data3
CREATE TABLE Stage.Host_Service_Metric_Data3 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		1 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_1,EQ_1-M_1)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_1+1,ISNULL(M_2-EQ_1-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 1
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		2 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_2,EQ_2-M_2)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_2+1,ISNULL(M_3-EQ_2-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 2
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		3 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_3,EQ_3-M_3)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_3+1,ISNULL(M_4-EQ_3-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 3
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		4 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_4,EQ_4-M_4)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_4+1,ISNULL(M_5-EQ_4-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 4
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		5 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_5,EQ_5-M_5)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_5+1,ISNULL(M_6-EQ_5-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 5
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		6 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_6,EQ_6-M_6)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_6+1,ISNULL(M_7-EQ_6-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 6
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		7 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_7,EQ_7-M_7)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_7+1,ISNULL(M_8-EQ_7-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 7
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		8 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_8,EQ_8-M_8)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_8+1,ISNULL(M_9-EQ_8-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 8
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		9 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_9,EQ_9-M_9)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_9+1,ISNULL(M_10-EQ_9-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 9
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		10 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_10,EQ_10-M_10)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_10+1,ISNULL(M_11-EQ_10-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 10
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		11 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_11,EQ_11-M_11)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_11+1,ISNULL(M_12-EQ_11-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 11
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		12 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_12,EQ_12-M_12)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_12+1,ISNULL(M_13-EQ_12-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 12
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		13 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_13,EQ_13-M_13)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_13+1,ISNULL(M_14-EQ_13-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 13
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		14 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_14,EQ_14-M_14)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_14+1,ISNULL(M_15-EQ_14-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 14
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		15 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_15,EQ_15-M_15)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_15+1,ISNULL(M_16-EQ_15-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 15
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		16 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_16,EQ_16-M_16)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_16+1,ISNULL(M_17-EQ_16-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 16
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		17 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_17,EQ_17-M_17)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_17+1,50) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 17

--===============================================================================================================
-- Testing
--===============================================================================================================

SELECT TOP 1000 * FROM dbo.Dim_Host_Service WHERE Host = '360-WEBRD-1A' AND Service IN ('Missed Image Pct','OCR Failure Rate') 
SELECT TOP 1000 * FROM Stage.Host_Service_Metric_Data F WHERE Host = '360-WEBRD-1A' AND F.Nagios_Object_ID IN (72936, 72934)
SELECT TOP 1000 * FROM dbo.Dim_Host_Service_Metric ORDER BY Nagios_Object_ID, Host_Service_Metric_ID
SELECT TOP 1000 * FROM Stage.Host_Service_Metric_Data F WHERE metric_string LIKE '%iso.3.6.1.4.1.25597.11.1.1.4.0%'

--:: Distinct Services
SELECT DISTINCT Host_Type, Service FROM dbo.Dim_Host_Service WHERE Host_Type  = 'Lane Controller' AND Service IS NOT NULL ORDER BY   Service

SELECT TOP 1000 * FROM dbo.Dim_State 

SELECT * FROM Ref.Lane_Camera_Mapping

--:: Distinct Metric Names

SELECT	DISTINCT M.Metric_Name 
FROM	dbo.Dim_Host_Service_Metric M 
ORDER BY 1

SELECT	DISTINCT ISNULL(HS.Service,'Host') Host_Service,  M.Metric_Name 
FROM	dbo.Dim_Host_Service_Metric M 
JOIN	dbo.Dim_Host_Service HS 
		ON M.Nagios_Object_ID = HS.Nagios_Object_ID 
ORDER BY 1,2

SELECT	TOP 10000 HS.Nagios_Object_ID, HS.Host_type, HS.Host, HS.Service, M.* 
FROM	dbo.Dim_Host_Service_Metric M 
JOIN	dbo.Dim_Host_Service HS 
		ON M.Nagios_Object_ID = HS.Nagios_Object_ID 
WHERE	Host = 'SRT-NALDR-4A'  AND Service IN ('Missed Image Pct','OCR Failure Rate') 
ORDER BY M.Nagios_Object_ID, Metric_Suffix

SELECT	TOP 10000 HS.Nagios_Object_ID, HS.Host_type, HS.Host, HS.Service, M.* 
FROM	dbo.Dim_Host_Service_Metric M 
JOIN	dbo.Dim_Host_Service HS 
		ON M.Nagios_Object_ID = HS.Nagios_Object_ID 
WHERE	 Metric_Target_type = 'Camera'
		AND metric_target = 'CTP-MLG1-NR1'
ORDER BY M.Nagios_Object_ID, Metric_Suffix

SELECT	CONVERT(VARCHAR,status_update_time,112) StatusDayID, COUNT_BIG(1) RC
FROM	LND_NAGIOS.dbo.nagios_servicestatus_hist
GROUP BY CONVERT(VARCHAR,status_update_time,112)
ORDER BY 1

SELECT * FROM dbo.Dim_Host_Service_Metric WHERE Nagios_Object_ID = 13951

SELECT * FROM dbo.Host_Service_Metric_Data WHERE Host_Type IN ('Lane Controller','VES Controller','Tolling Camera') ORDER BY Host_Service_Event_ID, metric_index
SELECT * FROM dbo.Host_Service_Metric_Data WHERE Host_Type = 'UPS' ORDER BY Host_Service_Event_ID, metric_index

SELECT * FROM dbo.Host_Service_Metric_Data WHERE Service_State <> Metric_State AND Service_State = 1 ORDER BY Host_Service_Event_ID desc, metric_index
SELECT * FROM dbo.Host_Service_Metric_Data WHERE Host_Service_Event_ID  IN (190830165250073778) ORDER BY Host_Service_Event_ID, metric_index

SELECT COUNT_BIG(1) RC, COUNT(DISTINCT Host_Service_Event_ID) Event_Count FROM dbo.Host_Service_Metric_Data -- 72370706
SELECT COUNT_BIG(1) FROM service_state_STAGE

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



