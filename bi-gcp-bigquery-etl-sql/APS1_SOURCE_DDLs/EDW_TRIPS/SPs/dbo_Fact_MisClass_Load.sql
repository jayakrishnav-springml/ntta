CREATE PROC [dbo].[Fact_MisClass_Load] @IsFullLoad [BIT] AS
/*
IF OBJECT_ID ('dbo.Fact_MisClass_Load_New', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_MisClass_Load_New
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_MisClass_Load_New table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040590	Shekhar, Gouthami		2022-01-06	Created
CHG0040590	Shekhar					2022-03-01  The below Comments added for better explanation of the logic
CHG0044538  Gouthami				2024-02-07  1. Added vehicleclass <> 'null filter as Viaplus team updated vehicle 
												class value with 'null' for	131 trips which are in 2021. As this column 
												is INT, joining to dim_vehiclass is failing with conversion error.
												2. In order to avoid failure in our process , filtered out these trips.
												3. Reported this data issue to Anusha to raise this to Viaplus team.

Q: What is a misclass?
A: Equipment at the lane identifies the Axle count of the vehicle that passes through. If the lane equipment 
   incorrectly identifies the axle of a vehicle, we call that transaction as a misclass.

Q: How to identify a misclass?
A: There is no perfect way to identify a transaction as a misclass transaction. Our logic identifies a transaction 
   as a misclass with a fair amount of accuracy. It is as follows.
   Step 1:  Are there any other transactions during the same  day ? If yes, we identify them.
   Step 2:  What is the most frequent Axle Count for those transactions? We assume that this is the accurate Axle Count.
   Step 3:  If the current transaction's Axle count does not match the most frequent Axle Count for that day, we flag
            the current transaction as a misclass transaction.

   The above logic will not flag a transaction as a misclass "accurately" if:
	1. there is only one transaction in a day
	2. There are multiple "most frequent" Axle counts for a day.  Example: There are 10 txns in a day. 5 have an
	   axle count of 3 and the remaining 5 have an axle of count of 4. In this case we take the lowest(i.e. 3)
	   as the most frequent axle count. 


	Note: The above logic was tested by Cory & Raymond (ITS) by actually viewing the videos of vehicles. 
	      It was found to be satisfactorily accurate.

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_MisClass_Load 0

EXEC Utility.FromLog 'dbo.Fact_MisClass_Load_New', 1
SELECT TOP 100 'dbo.Fact_MisClass_Load_New' Table_Name, * FROM dbo.Fact_MisClass_Load_New ORDER BY 2

###################################################################################################################
*/
BEGIN
BEGIN TRY
/*====================================== TESTING =======================================================================*/
	--DECLARE @IsFullLoad BIT = 0
	/*====================================== TESTING =======================================================================*/

	DECLARE @TableName VARCHAR(100) = 'dbo.Fact_MisClass', @StageTableName VARCHAR(100) = 'dbo.Fact_MisClass_NEW', @IdentifyingColumns VARCHAR(100) = '[TPTripID]'
	DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_MisClass_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME()
	DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @Last_Updated_Date DATETIME2(3), @sql VARCHAR(MAX), @CreateTableWith VARCHAR(MAX)
	DECLARE @StartDate DATE = CONVERT(DATE,DATEADD(yy,DATEDIFF(yy,0,GETDATE())-1,0))
	DECLARE @Partition_Ranges VARCHAR(MAX), @FirstPartitionID INT = 202001, @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(SYSDATETIME(),1)),112) AS INT)

		IF OBJECT_ID(@TableName) IS NULL
					SET @IsFullLoad = 1

	IF @IsFullLoad = 1
	BEGIN
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_PartitionDayIDRange_String from ' + CAST(@FirstPartitionID AS VARCHAR(10))+ ' till ' + CAST(@LastPartitionID AS VARCHAR(10))
		EXEC Utility.Get_PartitionDayIDRange_String @FirstPartitionID, @LastPartitionID, @Partition_Ranges OUTPUT
		-- Will use if go to columnstore - not delete this comment!!!!! --  SET @CreateTableWith = '(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
		SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID), PARTITION (DayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
		SET @Log_Message = 'Started Full load'
	END
	ELSE
	BEGIN
		SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID))'
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_UpdatedDate for ' + @TableName
		EXEC Utility.Get_UpdatedDate @TableName, @Last_Updated_Date OUTPUT 
		SET @Log_Message = 'Started Incremental load from: ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
	END

	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	--=============================================================================================================
	-- Load dbo.Fact_MisClass
	--============================================================================================================

	SET @sql = '
	IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL    DROP TABLE ' + @StageTableName + ' ;
	CREATE TABLE ' + @StageTableName + ' WITH ' + @CreateTableWith + ' AS 
	WITH VC AS
		(
		SELECT  (tt.VehicleNumber+tt.VehicleState) VehicleNumber,   
				CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112)) AS DayID,
				dvc.Axles,
				COUNT(1)        AS Frequency,
				MAX(COUNT(1))   OVER (PARTITION BY VehicleNumber,  CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112)) ) AS MaxFrequency
		FROM LND_TBOS.TollPlus.TP_Trips tt 
				JOIN EDW_TRIPS.dbo.Dim_VehicleClass dvc
				   ON tt.VehicleClass = dvc.VehicleClassID
				   AND tt.VehicleClass<>''null''
		WHERE cast(ExitTripDateTime as Date) >=''' + CAST(@StartDate AS VARCHAR(10)) + '''
		GROUP  BY tt.VehicleNumber,tt.VehicleState, dvc.Axles,  CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112))
		)
		, vc1 AS
		(
		SELECT  VehicleNumber , 
				DayID,
				MIN(Axles) AS MostFrequentAxles 
		FROM    VC
		WHERE    Frequency = MaxFrequency
		GROUP   BY VehicleNumber, DayID
		)
		SELECT  tt.TpTripID, 
				tt.TripWith, 
				tt.ExitTripDateTime, 
				CONVERT(INT,CONVERT(VARCHAR(8), tt.ExitTripDateTime,112)) AS DayID,
				dtim.TripIdentMethodID, 
				tt.ExitLaneID AS LaneID, 
				ISNULL(tt.VehicleID,-1) VehicleID,
				(tt.VehicleNumber+tt.VehicleState) LicensePlateNumber,
				dvc.Axles AS ReportedVehicleClassID,
				vc1.MostFrequentAxles MostFrequentVehicleClassID,
				tt.ReceivedTollAmount AS TollsDue,
				tt.LND_UpdateDate,
				ISNULL(CAST(SYSDATETIME() AS DATETIME2(7)), ''1900-01-01'') AS EDW_UpdateDate
		FROM    LND_TBOS.TollPlus.TP_Trips tt 
				JOIN EDW_TRIPS.dbo.Dim_VehicleClass dvc
					ON tt.VehicleClass = dvc.VehicleClassID
					AND tt.VehicleClass<>''null''
				JOIN   EDW_TRIPS.dbo.Dim_TripIdentMethod dtim
					ON tt.TripIdentMethod = dtim.TripIdentMethod
				JOIN    EDW_TRIPS.dbo.Dim_Lane dl
					ON dl.LaneID = tt.ExitLaneID
				JOIN    vc1 
					ON vc1.VehicleNumber = (tt.VehicleNumber+tt.VehicleState)
					AND vc1.DayID = CONVERT(INT,CONVERT(VARCHAR(8), tt.ExitTripDateTime,112)) 
				WHERE cast(ExitTripDateTime as Date) >=''' + CAST(@StartDate AS VARCHAR(10)) + '''
					AND   (tt.VehicleNumber is not null and tt.vehicleNumber != '''') 					
					AND    vc1.MostFrequentAxles != dvc.Axles
					OPTION (LABEL = ''' + @StageTableName + ''');'	

	IF @IsFullLoad != 1
	BEGIN
		SET @sql = REPLACE(@sql,'WITH VC AS','WITH ChangedTPTripIDs_CTE AS
		(	SELECT TP.TPTripID
			FROM LND_TBOS.TollPlus.TP_Trips TP
			WHERE TP.LND_UpdateDate > ''' + CONVERT(VARCHAR(25),@Last_Updated_Date,121) + ''' AND TP.VehicleClass<>''null''
		)
		,VC AS')

		SET @sql = REPLACE(@sql,'cast(ExitTripDateTime as Date) >=''' + CAST(@StartDate AS VARCHAR(10)) + '''','EXISTS (SELECT 1 FROM ChangedTPTripIDs_CTE AS CTE WHERE TT.TPTripID = CTE.TPTripID)')
 
	END

	IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
	EXEC (@sql)

	-- Log 
	SET  @Log_Message = 'Loaded ' + @StageTableName
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @sql
                                
	-- Create statistics and swap table
	IF @IsFullLoad = 1
	BEGIN

		SET @sql = '
		CREATE STATISTICS Stats_' + REPLACE(@TableName,'.','_') + '_001 ON ' + @StageTableName + '(DayID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_002 ON ' + @StageTableName + '(LaneID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_003 ON ' + @StageTableName + '(TripIdentMethodID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_004 ON ' + @StageTableName + '(VehicleID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_005 ON ' + @StageTableName + '(ReportedVehicleClassID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_006 ON ' + @StageTableName + '(MostFrequentVehicleClassID)
		'

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
		--EXEC (@sql)

		-- Table swap!
		EXEC Utility.TableSwap @StageTableName, @TableName

		SET @Log_Message = 'Completed full load'
	END
	ELSE
	BEGIN
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.ManagePartitions_DateID'
		EXEC Utility.ManagePartitions_DateID @TableName, 'DayID:Month'

		IF @Trace_Flag = 1 PRINT 'Calling: Utility.PartitionSwitch_Range'
		EXEC Utility.PartitionSwitch_Range @StageTableName, @TableName, @IdentifyingColumns, Null

		SET @sql = 'UPDATE STATISTICS  ' + @TableName
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
		EXEC (@sql)

		SET @Log_Message = 'Completed Incremental load from ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
	END
	
	SET @Last_Updated_Date = NULL
	EXEC Utility.Set_UpdatedDate @TableName, @TableName, @Last_Updated_Date OUTPUT -- So we going to manually set Updated date to be sure it didn't cach any error before that
	SET @Log_Message = @Log_Message + '. Set Last Update date as ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)

	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

END	TRY
	
BEGIN CATCH
	
	DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
	EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
	EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
	THROW;  -- Rethrow the error!
	
END CATCH;

END

/*
----========Print of the query=======------

IF OBJECT_ID('dbo.Fact_MisClass_NEW','U') IS NOT NULL    DROP TABLE dbo.Fact_MisClass_NEW ;
	CREATE TABLE dbo.Fact_MisClass_NEW WITH (CLUSTERED INDEX ([TPTripID]), DISTRIBUTION = HASH(TPTripID), PARTITION (DayID RANGE RIGHT FOR VALUES (20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,20210101,20210201,20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201,20220101,20220201,20220301,20220401,20220501))) AS 
	WITH VC AS
		(
		SELECT  (tt.VehicleNumber+tt.VehicleState) VehicleNumber,   
				CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112)) AS DayID,
				dvc.Axles,
				COUNT(1)        AS Frequency,
				MAX(COUNT(1))   OVER (PARTITION BY VehicleNumber,  CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112)) ) AS MaxFrequency
		FROM LND_TBOS.TollPlus.TP_Trips tt 
				JOIN EDW_TRIPS.dbo.Dim_VehicleClass dvc
				   ON tt.VehicleClass = dvc.VehicleClassID
		WHERE cast(ExitTripDateTime as Date) >='2021-01-01'
		GROUP  BY tt.VehicleNumber,tt.VehicleState, dvc.Axles,  CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112))
		)
		, vc1 AS
		(
		SELECT  VehicleNumber , 
				DayID,
				MIN(Axles) AS MostFrequentAxles 
		FROM    VC
		WHERE    Frequency = MaxFrequency
		GROUP   BY VehicleNumber, DayID
		)
		SELECT  tt.TpTripID, 
				tt.TripWith, 
				tt.ExitTripDateTime, 
				CONVERT(INT,CONVERT(VARCHAR(8), tt.ExitTripDateTime,112)) AS DayID,
				dtim.TripIdentMethodID, 
				tt.ExitLaneID AS LaneID, 
				ISNULL(tt.VehicleID,-1) VehicleID,
				(tt.VehicleNumber+tt.VehicleState) LicensePlateNumber,
				dvc.Axles AS ReportedVehicleClassID,
				vc1.MostFrequentAxles MostFrequentVehicleClassID,
				tt.ReceivedTollAmount AS TollsDue,
				tt.LND_UpdateDate,
				ISNULL(CAST(SYSDATETIME() AS DATETIME2(7)), '1900-01-01') AS EDW_UpdateDate
		FROM    LND_TBOS.TollPlus.TP_Trips tt 
				JOIN EDW_TRIPS.dbo.Dim_VehicleClass dvc
					ON tt.VehicleClass = dvc.VehicleClassID
				JOIN   EDW_TRIPS.dbo.Dim_TripIdentMethod dtim
					ON tt.TripIdentMethod = dtim.TripIdentMethod
				JOIN    EDW_TRIPS.dbo.Dim_Lane dl
					ON dl.LaneID = tt.ExitLaneID
				JOIN    vc1 
					ON vc1.VehicleNumber = (tt.VehicleNumber+tt.VehicleState)
					AND vc1.DayID = CONVERT(INT,CONVERT(VARCHAR(8), tt.ExitTripDateTime,112)) 
				WHERE cast(ExitTripDateTime as Date) >='2021-01-01'
					AND   (tt.VehicleNumber is not null and tt.vehicleNumber != '') 					
					AND    vc1.MostFrequentAxles != dvc.Axles
					OPTION (LABEL = 'dbo.Fact_MisClass_NEW');

    (1 row(s) affected)
    

		CREATE STATISTICS Stats_dbo_Fact_MisClass_001 ON dbo.Fact_MisClass_NEW(DayID)
		CREATE STATISTICS STATS_dbo_Fact_MisClass_002 ON dbo.Fact_MisClass_NEW(LaneID)
		CREATE STATISTICS STATS_dbo_Fact_MisClass_003 ON dbo.Fact_MisClass_NEW(TripIdentMethodID)
		CREATE STATISTICS STATS_dbo_Fact_MisClass_004 ON dbo.Fact_MisClass_NEW(VehicleID)
		CREATE STATISTICS STATS_dbo_Fact_MisClass_005 ON dbo.Fact_MisClass_NEW(ReportedVehicleClassID)
		CREATE STATISTICS STATS_dbo_Fact_MisClass_006 ON dbo.Fact_MisClass_NEW(MostFrequentVehicleClassID)
		*/
/* -------Incremental query print
IF OBJECT_ID('dbo.Fact_MisClass_NEW','U') IS NOT NULL    DROP TABLE dbo.Fact_MisClass_NEW ;
	CREATE TABLE dbo.Fact_MisClass_NEW WITH (CLUSTERED INDEX ([TPTripID]), DISTRIBUTION = HASH(TPTripID)) AS 
	WITH ChangedTPTripIDs_CTE AS
		(	SELECT TP.TPTripID
			FROM LND_TBOS.TollPlus.TP_Trips TP
			WHERE TP.LND_UpdateDate > '1990-01-01 00:00:00.000'
		)
		,VC AS
		(
		SELECT  (tt.VehicleNumber+tt.VehicleState) VehicleNumber,   
				CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112)) AS DayID,
				dvc.Axles,
				COUNT(1)        AS Frequency,
				MAX(COUNT(1))   OVER (PARTITION BY VehicleNumber,  CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112)) ) AS MaxFrequency
		FROM LND_TBOS.TollPlus.TP_Trips tt 
				JOIN EDW_TRIPS.dbo.Dim_VehicleClass dvc
				   ON tt.VehicleClass = dvc.VehicleClassID
		WHERE EXISTS (SELECT 1 FROM ChangedTPTripIDs_CTE AS CTE WHERE TT.TPTripID = CTE.TPTripID)
		GROUP  BY tt.VehicleNumber,tt.VehicleState, dvc.Axles,  CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112))
		)
		, vc1 AS
		(
		SELECT  VehicleNumber , 
				DayID,
				MIN(Axles) AS MostFrequentAxles 
		FROM    VC
		WHERE    Frequency = MaxFrequency
		GROUP   BY VehicleNumber, DayID
		)
		SELECT  tt.TpTripID, 
				tt.TripWith, 
				tt.ExitTripDateTime, 
				CONVERT(INT,CONVERT(VARCHAR(8), tt.ExitTripDateTime,112)) AS DayID,
				dtim.TripIdentMethodID, 
				tt.ExitLaneID AS LaneID, 
				ISNULL(tt.VehicleID,-1) VehicleID,
				(tt.VehicleNumber+tt.VehicleState) LicensePlateNumber,
				dvc.Axles AS ReportedVehicleClassID,
				vc1.MostFrequentAxles MostFrequentVehicleClassID,
				tt.ReceivedTollAmount AS TollsDue,
				tt.LND_UpdateDate,
				ISNULL(CAST(SYSDATETIME() AS DATETIME2(7)), '1900-01-01') AS EDW_UpdateDate
		FROM    LND_TBOS.TollPlus.TP_Trips tt 
				JOIN EDW_TRIPS.dbo.Dim_VehicleClass dvc
					ON tt.VehicleClass = dvc.VehicleClassID
				JOIN   EDW_TRIPS.dbo.Dim_TripIdentMethod dtim
					ON tt.TripIdentMethod = dtim.TripIdentMethod
				JOIN    EDW_TRIPS.dbo.Dim_Lane dl
					ON dl.LaneID = tt.ExitLaneID
				JOIN    vc1 
					ON vc1.VehicleNumber = (tt.VehicleNumber+tt.VehicleState)
					AND vc1.DayID = CONVERT(INT,CONVERT(VARCHAR(8), tt.ExitTripDateTime,112)) 
				WHERE EXISTS (SELECT 1 FROM ChangedTPTripIDs_CTE AS CTE WHERE TT.TPTripID = CTE.TPTripID)
					AND   (tt.VehicleNumber is not null and tt.vehicleNumber != '') 					
					AND    vc1.MostFrequentAxles != dvc.Axles
					OPTION (LABEL = 'dbo.Fact_MisClass_NEW');


*/
