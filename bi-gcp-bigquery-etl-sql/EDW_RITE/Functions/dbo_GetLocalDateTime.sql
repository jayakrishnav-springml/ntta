CREATE FUNCTION [dbo].[GetLocalDateTime] (@UtcDateTime [DATETIME]) RETURNS DATETIME
AS
BEGIN 
    --====================================================
    --Calculate the Offset Datetime
    --====================================================
	--DECLARE @UtcDateTime DATETIME = 'GETUTCDATE();
	DECLARE @Offset smallint = 360;			--US Central Time, 300 for US Eastern Time, 480 for US West Coast
    DECLARE @ApplyDaylightSavings bit = 1;	--1 for most US time zones except Arizona which doesn't observer daylight savings, 
											--0 for most time zones outside the US
    DECLARE @LocalDateTime DATETIME
    SET		@LocalDateTime = DATEADD(MINUTE, @Offset * -1, @UtcDateTime)
	--PRINT	@LocalDateTime; --PRINT @UtcDateTime;-- PRINT @ApplyDaylightSavings
    IF @ApplyDaylightSavings = 0 RETURN @UtcDateTime;

    --====================================================
    --Calculate the DST Offset for the UDT Datetime
    --====================================================
    DECLARE @Year as SMALLINT =  DATEPART(yyyy, @UtcDateTime)
    DECLARE @DSTStartDate AS DATETIME
    DECLARE @DSTEndDate AS DATETIME

    --Get First Possible DST StartDay
    IF (@Year > 2006) SET @DSTStartDate = CAST(@Year AS CHAR(4)) + '-03-08 02:00:00'
    ELSE              SET @DSTStartDate = CAST(@Year AS CHAR(4)) + '-04-01 02:00:00'
    --Get DST StartDate 
    WHILE (DATENAME(dw, @DSTStartDate) <> 'SUNDAY') SET @DSTStartDate = DATEADD(day, 1,@DSTStartDate)

    --Get First Possible DST EndDate
    IF (@Year > 2006) SET @DSTEndDate = CAST(@Year AS CHAR(4)) + '-11-01 02:00:00'
    ELSE              SET @DSTEndDate = CAST(@Year AS CHAR(4)) + '-10-25 02:00:00'

    --Get DST EndDate 
    WHILE (DATENAME(dw, @DSTEndDate) <> 'SUNDAY') SET @DSTEndDate = DATEADD(day,1,@DSTEndDate)

    --Finally add the DST Offset if needed 
	--PRINT	@DSTStartDate; PRINT @DSTEndDate;
    RETURN --		PRINT 
	CASE WHEN @LocalDateTime BETWEEN @DSTStartDate AND @DSTEndDate THEN 
        DATEADD(MINUTE, 60, @LocalDateTime) 
    ELSE 
        @LocalDateTime
    END

END
