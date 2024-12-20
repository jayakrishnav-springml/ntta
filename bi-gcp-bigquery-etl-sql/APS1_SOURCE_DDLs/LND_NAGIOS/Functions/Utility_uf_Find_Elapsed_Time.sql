CREATE FUNCTION [Utility].[uf_Find_Elapsed_Time] (@start_dt [DATETIME2](3),@end_dt [DATETIME2](3)) RETURNS VARCHAR(50)
AS
BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @start_dt DATETIME2(3) = CONVERT(DATETIME2(3),'2021-03-23 09:29:26.441',121),@end_dt DATETIME2(3) = CONVERT(DATETIME2(3),'2021-03-23 10:29:14.358',121) --SYSDATETIME()
	/*====================================== TESTING =======================================================================*/

	DECLARE @elapsed_time           VARCHAR(50) = '',
	        @diff_ms                INT = 0,
	        @diff_sec               INT,
	        @diff_min               INT,
	        @diff_hr                INT,
	        @diff_days              INT,
	        @diff_ms_all            BIGINT
	
    IF @start_dt IS NOT NULL AND @end_dt IS NOT NULL
	BEGIN
		IF @start_dt > @end_dt
		BEGIN
			SET @elapsed_time = '-'
			DECLARE @start_dt_old DATETIME2(3) = @start_dt
			SET @start_dt = @end_dt
			SET @end_dt = @start_dt_old
		END

		SET	@diff_days = ROUND(DATEDIFF(HOUR, @start_dt,@end_dt) / 24, 0, 1)
		SET @start_dt = DATEADD(DAY,@diff_days,@start_dt)
		--SET	@diff_hr  = ROUND(DATEDIFF(MINUTE, @start_dt, @end_dt) / 60, 0, 1)  -- Found out this may return full hour if it's only several seconds less - not useful!
		SET	@diff_hr  = ROUND(DATEDIFF(SECOND, @start_dt, @end_dt) / 3600, 0, 1)
		SET @start_dt = DATEADD(HOUR,@diff_hr,@start_dt)
		SET @diff_ms_all  = DATEDIFF(millisecond, @start_dt, @end_dt)

		SET	@diff_min =	ROUND(@diff_ms_all / 60000, 0, 1)

		IF @diff_days = 0 
		BEGIN
			SET	@diff_sec = ROUND((@diff_ms_all - @diff_min * 60000) / 1000, 0, 1)

			IF @diff_hr = 0 
			BEGIN
				SET @start_dt = DATEADD(millisecond, @diff_ms_all,@start_dt)
				SET @diff_ms  = @diff_ms_all - @diff_min * 60000 - @diff_sec * 1000
			END
		END

		SET @elapsed_time = @elapsed_time +
			ISNULL(CAST(NULLIF(@diff_days,0) AS VARCHAR(10)) + ' days ','') +
			ISNULL(CAST(NULLIF(@diff_hr,0) AS VARCHAR(3)) + ' hr ','') +
			ISNULL(CAST(NULLIF(@diff_min,0) AS VARCHAR(3)) + ' min ','') +
			ISNULL(CAST(NULLIF(@diff_sec,0) AS VARCHAR(3)) + ' sec ','') +
			ISNULL(CAST(NULLIF(@diff_ms,0) AS VARCHAR(4)) + ' msec ','') -- Get more scale than needed to catch the negative number if it appears
	END
	ELSE
		SET @elapsed_time = '0 min 0 sec' --'? /calculation error/' -- it can be if there is null in input parameters

	-- Return the result of the function
	RETURN @elapsed_time

	/*====================================== TESTING =======================================================================*/
	--PRINT @elapsed_time
	/*====================================== TESTING =======================================================================*/

END
