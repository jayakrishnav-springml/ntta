CREATE PROC [Utility].[TableLoadParameters_Insert] @DataBaseName [VARCHAR](30),@Table_Name [VARCHAR](130),@Row_Count [BIGINT] AS
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.TableLoadParameters_Insert', 'P') IS NOT NULL DROP PROCEDURE Utility.TableLoadParameters_Insert
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.TableLoadParameters_Insert 'TBOS','[TollPlus].[Agencies]', 76

SELECT * FROM Utility.TableLoadParameters order by TableName
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc inserting or updating a string for @Table_Name into table Utility.TableLoadParameters.


@DataBaseName - Name of the database. Needed for SSIS process. Can be 'TBOS', 'IPS', 'DMV'
@Table_Name - Table name (with Schema) we need to automatically add / update
@Row_Count - Row count to of the source table - needed to calculate LoadProcessID 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	12/31/2020	New!
###################################################################################################################

*/

BEGIN
	SET NOCOUNT ON

	DECLARE @Error VARCHAR(MAX) = ''

	IF @Table_Name IS NULL SET @Error = @Error + 'Table name cannot be NULL'

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
	END
	ELSE
	BEGIN
		DECLARE @Params VARCHAR(100) = 'Types,Alias,NoPrint'
		DECLARE @UseUpdatedDate BIT = 0, @TableID INT, @Full_Name varchar(130), @StageTableName varchar(130), @UseInsert BIT = 0, @UsePartition BIT = 0
		DECLARE @Schema VARCHAR(30), @Table VARCHAR(100), @StartDate DATETIME2(3) = SYSDATETIME()
		DECLARE @UID_Columns VARCHAR(400), @IndexString VARCHAR(400) = @Params, @ColumnsString VARCHAR(MAX) = @Params, @WhereString VARCHAR(400), @DistributionString VARCHAR(100) = @Params, @UpdatedDateColumn VARCHAR(100) = ''
		DECLARE @DeleteSQL VARCHAR(MAX) = '',@InsertSQL VARCHAR(MAX) = '', @SelectSQL VARCHAR(MAX) = @Params, @RenameSQL VARCHAR(MAX) = @Params, @StatsSQL VARCHAR(MAX) = @Params, @PartitionColumn VARCHAR(100) = '' 
		DECLARE @Active BIT = CASE WHEN @Row_Count = 0 THEN 0 ELSE 1 END
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)
		DECLARE @LoadProcessID INT = CASE WHEN @Row_Count = 0 THEN 0 WHEN @Row_Count < 1000000 THEN 1 WHEN @Row_Count < 10000000 THEN 2 WHEN @Row_Count < 100000000 THEN 3 ELSE 4 END

		SELECT      
			@Schema = s.name, @Table = t.name, @Full_Name = s.name + '.' + t.name, @TableID = ID.TableID,
			@StageTableName = 'Stage.' + CASE WHEN p.TableID IS NOT NULL THEN s.name + '_' ELSE '' END + t.name
		FROM (
				SELECT 
					SchemaName = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(LEFT(@Table_Name,@Dot - 1),'[',''),']','') END,
					TableName = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END,
					FullName = CASE WHEN @Dot = 0 THEN 'dbo.' ELSE '' END + REPLACE(REPLACE(@Table_Name,'[',''),']','')
			) c
		JOIN sys.Tables  t ON t.Name = c.TableName
		JOIN sys.schemas s ON t.schema_id = s.schema_id AND s.Name = c.SchemaName
		LEFT JOIN Utility.TableLoadParameters  p ON p.FullName <> c.FullName AND p.StageTableName = 'Stage.' + c.TableName
		LEFT JOIN Utility.TableLoadParameters  ID ON ID.FullName = c.FullName

		IF @TableID IS NULL
			SELECT @TableID = ISNULL(MAX(TableID),0) + 1, @UseInsert = 1 FROM Utility.TableLoadParameters

		EXEC Utility.Get_Index_String @Full_Name, @IndexString OUTPUT
		IF CHARINDEX('COLUMNSTORE',@IndexString) = 0
			SET @UID_Columns = REPLACE(REPLACE(REPLACE(SUBSTRING(@IndexString,CHARINDEX('(',@IndexString) + 1,100),')',''),' ASC',''),' DESC','')
		EXEC Utility.Get_Where_String @Full_Name, @UID_Columns, @WhereString OUTPUT 

		EXEC Utility.Get_Select_String @Full_Name, @ColumnsString OUTPUT 
		EXEC Utility.Get_PartitionColumn @Full_Name, @PartitionColumn OUTPUT 
		EXEC Utility.Get_Distribution_String @Full_Name, @DistributionString OUTPUT 
		EXEC Utility.Get_SelectFromTable_SQL @Full_Name, @SelectSQL OUTPUT
		EXEC Utility.Get_CreateStatistics_SQL @Full_Name, @StageTableName, @StatsSQL OUTPUT

		--DECLARE @HBUYBLKYASUKANAHUY VARCHAR(130) = @Full_Name
		--EXEC Utility.Get_TransferObject_SQL @StageTableName, @HBUYBLKYASUKANAHUY, @RenameSQL OUTPUT 
		EXEC Utility.Get_TransferObject_SQL @StageTableName, @Full_Name, @RenameSQL OUTPUT 
		--PRINT @RenameSQL

		IF LEN(@PartitionColumn) > 0
			SET @UsePartition = 1

		IF CHARINDEX('[UpdatedDate]',@ColumnsString) > 0
		BEGIN
			SET @UseUpdatedDate = 1
			SET @UpdatedDateColumn = '[UpdatedDate]'
		END
		ELSE IF CHARINDEX('[UpdatedTimestamp]',@ColumnsString) > 0
		BEGIN
			SET @UseUpdatedDate = 1
			SET @UpdatedDateColumn = '[UpdatedTimestamp]'
		END
		ELSE IF CHARINDEX('[MIRCompletedDate]',@ColumnsString) > 0
		BEGIN
			SET @UseUpdatedDate = 1
			SET @UpdatedDateColumn = 'ISNULL([MIRCompletedDate],[MIRReceivedDate])'
		END
		ELSE IF CHARINDEX('[EIPCompletedDate]',@ColumnsString) > 0
		BEGIN
			SET @UseUpdatedDate = 1
			SET @UpdatedDateColumn = 'ISNULL([EIPCompletedDate],[EIPReceivedDate])'
		END

		IF @UseUpdatedDate = 1
		BEGIN
			SET @DeleteSQL = CHAR(13) + 'DELETE FROM ' + @Full_Name + CHAR(13) + 'WHERE EXISTS (SELECT 1 FROM ' + @StageTableName + ' AS NSET WHERE ' + @WhereString + ')'
			SET @InsertSQL = CHAR(13) + 'INSERT INTO ' + @Full_Name + CHAR(13) + 'SELECT ' + REPLACE(@ColumnsString,'[' + @Table + '].','StageTable.')  + CHAR(13) + 'FROM ' + @StageTableName + ' AS StageTable WHERE 1 = 1'
		END

		DECLARE @UseMultiThreadFlag INT = CASE WHEN @LoadProcessID > 1 AND @UseUpdatedDate = 1 AND @UID_Columns != 'HEAP' THEN 1 ELSE 0 END
		-- We have to manually change it to '0' for tables, where first UID column is not a Number!!!

		IF @UseInsert = 1
		BEGIN
			INSERT INTO Utility.TableLoadParameters 
				(
					TableID 
					,LoadProcessID
					,DataBaseName 
					,SchemaName 
					,TableName
					,FullName
					,StageTableName 
					,UseUpdatedDate
					,UsePartition
					,UpdatedDateColumn
					,UID_Columns
					,DistributionString
					,IndexString
					,ColumnsString
					,WhereString
					,StatsSQL
					,SelectSQL
					,DeleteSQL
					,InsertSQL
					,RenameSQL
					,UpdateProc
					,RunAfterProc
					,RowCnt 
					,Active 
					,UseMultiThreadFlag
					,CreateFlag
					,CDCFlag
					,KeepHistoryFlag
					,NotInMasterPackageFlag
					,UpdateDate
			   )
			VALUES  
				(
					@TableID 
					,@LoadProcessID
					,@DataBaseName 
					,@Schema 
					,@Table
					,@Full_Name
					,@StageTableName
					,@UseUpdatedDate
					,@UsePartition
					,@UpdatedDateColumn
					,@UID_Columns
					,@DistributionString
					,@IndexString
					,@ColumnsString
					,@WhereString
					,@StatsSQL
					,@SelectSQL
					,@DeleteSQL
					,@InsertSQL
					,@RenameSQL
					,''
					,''
					,@Row_Count 
					,@Active
					,@UseMultiThreadFlag
					,1
					,0
					,0
					,0
					,@StartDate
			   )


		END
		ELSE
		BEGIN
			UPDATE Utility.TableLoadParameters 
				SET
					LoadProcessID			  = @LoadProcessID
					,DataBaseName 			  = @DataBaseName 
					,SchemaName 			  = @Schema 
					,TableName				  = @Table
					,FullName				  = @Full_Name
					,StageTableName 		  = @StageTableName
					,UseUpdatedDate			  = @UseUpdatedDate
					,UsePartition			  = @UsePartition
					,UpdatedDateColumn		  = @UpdatedDateColumn
					,UID_Columns			  = @UID_Columns
					,DistributionString		  = @DistributionString
					,IndexString			  = @IndexString
					,ColumnsString			  = @ColumnsString
					,WhereString			  = @WhereString
					,StatsSQL				  = @StatsSQL
					,SelectSQL				  = @SelectSQL
					,DeleteSQL				  = @DeleteSQL
					,InsertSQL				  = @InsertSQL
					,RenameSQL				  = @RenameSQL
					,Active 				  = @Active
					,RowCnt 				  = @Row_Count
					,CreateFlag				  = 1
					,UseMultiThreadFlag 	  = @UseMultiThreadFlag
					,NotInMasterPackageFlag	  = 0
					,UpdateDate				  = @StartDate
			WHERE TableID = @TableID
		END
	END

END

/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================

SELECT *
	FROM Utility.TableLoadParameters
--WHERE RowCnt = 0
--WHERE SchemaName = 'TOLLPLUS'
--WHERE TableName = 'NTTAHostBOSFileTracker'
--WHERE UseMultiThreadFlag = 0
--UseUpdatedDate = 0 AND
--LoadProcessID = 4 -- AND 
--RowCnt > 0
--WHERE CDCFlag = 1
--WHERE CreateFlag = 1 AND ACTIVE = 0
ORDER BY TableName



--truncate table Utility.TableLoadParameters

SELECT StageTableName, COUNT(1) AS CNT
FROM Utility.TableLoadParameters
GROUP BY StageTableName
HAVING COUNT(1) > 1

EXEC Utility.FromLog '', 1

UPDATE Utility.TableLoadParameters
SET CreateFlag = 0
WHERE Active = 0

UPDATE Utility.TableLoadParameters
SET CreateFlag = 1
WHERE FullName IN ('IOP.BOS_IOP_OutboundTransactions','TranProcessing.NTTAHostBOSFileTracker','CaseManager.PmCase','Finance.BusinessProcesses','Notifications.CustomerNotificationQueue','Ter.ViolatorCollectionsInbound')
WHERE Active = 1

UPDATE Utility.TableLoadParameters
--SET CreateFlag = CASE WHEN CreateFlag = 1 THEN 0 ELSE 1 END
SET CreateFlag = 1
WHERE FullName IN ('TollPlus.TP_Customer_Business','TollPlus.TP_Customer_Plans')


UPDATE Utility.TableLoadParameters
SET DataBaseName = 'IPS'
WHERE SchemaName IN ('EIP','MIR')


UPDATE Utility.TableLoadParameters
SET UseMultiThreadFlag = 0
, CreateFlag = 1
WHERE LoadProcessID = 1

UPDATE Utility.TableLoadParameters
SET LoadProcessID = 2
, CreateFlag = 1
, UseMultiThreadFlag = 1
, RowCnt = 169014393
,FullName = 'FInance.GL_Transactions'
,TableName = 'GL_Transactions'
WHERE FullName = 'FInance.Gl_Transactions'

UPDATE Utility.TableLoadParameters
SET LoadProcessID = 2
WHERE TableName = 'NTTAHostBOSFileTracker'


UPDATE Utility.TableLoadParameters
SET CDCFlag = 1, CreateFlag = 1
WHERE TableName IN ('TP_CUSTOMER_FLAGS')

	SELECT * 
	FROM Utility.ProcessLog
	WHERE 
		LogType  = 'E'
		AND LogDate >=  '20201015'
	ORDER BY LogDate DESC, LogSource

*/



