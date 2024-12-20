CREATE PROC [DBO].[GET_PARTITION_RANGE_DATE_STRING] @TABLE_NAME [VARCHAR](150),@PART_RANGES [VARCHAR](MAX) OUT AS 
BEGIN
-- DROP PROC [DBO].[GET_PARTITION_RANGE_DATE_STRING]

	IF (@TABLE_NAME IS NULL) SET @TABLE_NAME = 'DIM_VIOLATOR_ASOF'
	--STEP #1: 	-- Calculate ranges from PARTITION_DAY_ID_CONTROL for whole table
	SET @PART_RANGES = '' 
	DECLARE @TempVar VARCHAR(12)
	DECLARE @NUM_PART INT = (SELECT MAX(PARTITION_NUM) FROM dbo.PARTITION_DAY_ID_CONTROL WHERE TABLE_NAME = @TABLE_NAME)
	DECLARE @Cur_Part INT = 2
	-- First not in the loop without any comma
	SELECT @PART_RANGES = CHAR(39) + CONVERT(VARCHAR(19), StartDate, 112) + CHAR(39) FROM dbo.PARTITION_DAY_ID_CONTROL WHERE TABLE_NAME = @TABLE_NAME AND PARTITION_NUM = @Cur_Part


	WHILE (@Cur_Part < @NUM_PART) BEGIN
		SET @Cur_Part += 1
		SELECT @TempVar = CHAR(39) + CONVERT(VARCHAR(19), PD.StartDate, 112) + CHAR(39) FROM dbo.PARTITION_DAY_ID_CONTROL AS PD WHERE TABLE_NAME = @TABLE_NAME AND PD.PARTITION_NUM = @Cur_Part
		SET @PART_RANGES = @PART_RANGES + ',' + @TempVar
	END;

END
