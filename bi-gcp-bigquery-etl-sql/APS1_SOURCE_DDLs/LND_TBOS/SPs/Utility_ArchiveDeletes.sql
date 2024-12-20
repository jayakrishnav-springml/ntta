CREATE PROC [Utility].[ArchiveDeletes] @TableName [VARCHAR](250) AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Change the LND_UpdateType column value from “D” to “A” only for the rows that are in LND_TBOS_ARCH
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0041190	Sagarika,Shekhar	2022-05-23	New!
CHG0042607	Sagarika            2023-02-27  Passed parameter value for logging the Row Count after Updates
CHG0042646	Sagarika			2023-03-02	Reverted the logic for A to D
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.ArchiveDeletes 'TollPlus.TP_CUSTOMER_VEHICLES'
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'Archive %' ORDER BY 1 DESC 
###################################################################################################################
*/

BEGIN
	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'Archive '+ @TableName , @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
        EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Started Utility.ArchiveDeletes', 'I', NULL, NULL

		-- Declare @TableName [VARCHAR](250) = 'TollPlus.TP_CUSTOMER_VEHICLES' 
	
	    DECLARE @sql VARCHAR(MAX)
		DECLARE @ArchTableName VARCHAR(250), @Name VARCHAR(250) 
		DECLARE @IdentifyingColumns VARCHAR(250)
		DECLARE @WhereString VARCHAR(250)
		DECLARE @ArchiveFlag SMALLINT
        
		SELECT  @TableName = T.FullName
		      , @IdentifyingColumns = REPLACE(REPLACE(T.UID_Columns,'[',''),']','')
			  , @Name = T.TableName
			  , @WhereString = T.WhereString
			  , @ArchiveFlag = ArchiveFlag
		FROM Utility.TableLoadParameters T
		WHERE FullName = @TableName
		
		IF @ArchiveFlag = 1 -- Run the below update statement to change "A" records to "D" only if archiving is enabled
		BEGIN
			SET  @ArchTableName = 'Archive.'+@Name
			SET	 @WhereString = replace(replace(@WhereString, '[' + @Name +']', @ArchTableName), '[NSET]', @TableName)
			SET @sql = 'UPDATE ' + @TableName+'
						SET LND_UpdateType = ''D''
							  Where LND_UpdateType = ''A''
									AND not exists (select 1 from '+@ArchTableName+ ' where ' + @WhereString +')'
			IF @Trace_Flag = 0 PRINT @sql
			EXEC (@sql)

			-- Log 
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Updated rows back from A to D', 'I', NULL, -1

            SELECT TOP 1 @Row_Count = Row_Count FROM Utility.ProcessLog WHERE LogSource = @Log_Source ORDER BY LogDate DESC
			IF @Row_Count > 0
			BEGIN
				SET @sql = 'UPDATE STATISTICS ' + @TableName
				IF @Trace_Flag = 0 PRINT @sql
				EXEC (@sql)
			END
		END

        EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Finished Utility.ArchiveDeletes', 'I', NULL, NULL

	END	TRY
	
	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH

END

--/*
----===============================================================================================================
---- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
----===============================================================================================================
/*	
UPDATE lnd_tbos.[Tollplus].[TP_Customer_Vehicles] -- dsetination tollplus as
SET LND_UpdateType = 'D'
Where --VehicleID in  (select VehicleID from sandbox.[TollPlus].[TP_CUSTOMER_VEHICLES_ARCH])
LND_UpdateType = 'A'

SELECT *
from  lnd_tbos.[Tollplus].[TP_Customer_Vehicles] 
WHERE LND_UpdateType = 'A'

SELECT * FROM  LND_TBOS_dev.Utility.TableLoadParameters
WHERE TableName like '%TP_Customer_Vehicles%'

UPDATE LND_TBOS_dev.Utility.TableLoadParameters
SET TableName = 'TP_Customer_Vehicles'
, FullName = 'TollPlus.TP_Customer_Vehicles'
,StageTableName = 'TollPlus.TP_Customer_Vehicles'
Where TableID = 112

select top 10 * from TollPlus.TP_CUSTOMER_VEHICLES_ARCHive (source)
select VehicleID from TollPlus.TP_CUSTOMER_VEHICLES_ARCH( Tollplus destination)
select top 10 * from TollPlus.TP_CUSTOMER_VEHICLES
where  VehicleID = 52487800 ---(for deletes updating)

select * from Stage.TP_Customer_Vehicles
where LND_UpdateType = 'a' --- 29

select  * from TollPlus.TP_CUSTOMER_VEHICLES
where  LND_UpdateType = 'd'



select  * from TollPlus.TP_CUSTOMER_VEHICLES
where  vehicleid in (52487800
,52485846
,52489837
,52487844
)


select * from [TollPlus].[TP_CUSTOMER_VEHICLES_archive]
select * from archive.[TP_CUSTOMER_VEHICLES_archive]


UPDATE TollPlus.TP_Customer_Vehicles
		            SET LND_UpdateType = 'D'
		                  Where  exists  (select VehicleID from Archive.TP_Customer_Vehicles
				          Where TollPlus.TP_Customer_Vehicles.VehicleID  = Archive.TP_Customer_Vehicles.VehicleID 
		                 )
		            --  and LND_UpdateType = 'A'



					  select * from archive.[TP_CUSTOMER_VEHICLES]

					  select * from TollPlus.TP_Customer_Vehicles
					  where VehicleId in
					  (
'54727922',
'54727153',
'54730033',
'54728852',
'54727186',
'54727885',
'11690263') ---- delete

select * from TollPlus.TP_Customer_Vehicles
					  where VehicleId in
					  (
'54728287',
'45865719',
'54728869',
'54729428',
'54727160',
'12159105',
'54730010',
'54727211',
'11690262',
'54727991')
--*/



