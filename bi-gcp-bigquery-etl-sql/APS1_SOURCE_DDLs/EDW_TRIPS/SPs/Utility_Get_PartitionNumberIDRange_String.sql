CREATE PROC [Utility].[Get_PartitionNumberIDRange_String] @StartRange [BIGINT],@EndRange [BIGINT],@Step [BIGINT],@Partition_Ranges [VARCHAR](MAX) OUT AS
/*
USE EDW_TRIPS
GO
IF OBJECT_ID ('Utility.Get_PartitionNumberIDRange_String', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_PartitionNumberIDRange_String
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Partition_Ranges VARCHAR(MAX)
EXEC Utility.Get_PartitionNumberIDRange_String 0, 10000000000, 100000000, @Partition_Ranges OUTPUT 
EXEC Utility.LongPrint @Partition_Ranges
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning string of all Values for partitioned table, Partitioned by some numeric ID, separated by comma
Values comes from Utility.Number table
Every partition have 30 000 000 rows, creating 300 partitions (maybe it should be chosen by parameters, but now it's crud like valenok

@StartRange - First number (can be negative). By default = 0
@EndRange - The last number. By default = 18000000000
@Step - Step in range. By default = 10000000
@Partition_Ranges - Param to return string of values. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################

*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Partition_Ranges VARCHAR(MAX)
	/*====================================== TESTING =======================================================================*/

	IF @StartRange IS NULL SET @StartRange = 0
	IF @Step IS NULL SET @Step = 10000000  -- 10 Million
	IF @EndRange IS NULL SET @EndRange = 18000000000 -- 18 billion
	DECLARE @LastN INT = @EndRange / @Step

	IF OBJECT_ID('tempDB..#TEMP_Number') IS NOT NULL DROP Table #TEMP_Number;

	SELECT @StartRange + N * @Step AS BeginNumber, ROW_NUMBER() OVER (ORDER BY N) AS Partition_Num
	INTO #TEMP_Number -- SELECT *
	FROM Utility.Number
	WHERE N <= @LastN

	SET @Partition_Ranges = '' 
	DECLARE @TempVar VARCHAR(19)
	DECLARE @Num_Part INT = (SELECT MAX(Partition_Num) FROM #TEMP_Number)
	DECLARE @Cur_Part INT = 1
	DECLARE @Delimiter VARCHAR(3) = ''

	WHILE (@Cur_Part <= @Num_Part) BEGIN
		SELECT @TempVar = CAST(BeginNumber AS VARCHAR(19)) FROM #TEMP_Number WHERE Partition_Num = @Cur_Part
		SET @Partition_Ranges = @Partition_Ranges + @Delimiter + @TempVar
		SET	@Delimiter = ','
		SET @Cur_Part += 1
	END;

	/*====================================== TESTING =======================================================================*/
	--EXEC Utility.LongPrint @Partition_Ranges
	/*====================================== TESTING =======================================================================*/

END
