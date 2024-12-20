CREATE FUNCTION [dbo].[UF_FIND_ELAPSED_TIME] (@start_dt [DATETIME2](7),@end_dt [DATETIME2](7)) RETURNS VARCHAR(50)
AS
BEGIN

--DROP FUNCTION [dbo].[UF_FIND_ELAPSED_TIME] 
	
	--DECLARE @start_dt DATETIME2(7) = CONVERT(DATETIME2(7),'2019-05-06 23:34:45.4567887',121),@end_dt DATETIME2(7) = CONVERT(DATETIME2(7),'2019-05-06 23:34:45.4587999',121)
	--DECLARE @start_dt DATETIME2(7) = CONVERT(DATETIME2(7),'2019-05-06 23:34:45.4567887',121),@end_dt DATETIME2(7) = CONVERT(DATETIME2(7),'2019-05-06 23:44:41.67887',121)
	--DECLARE @start_dt DATETIME2(7) = CONVERT(DATETIME2(7),'2019-05-06 23:34:45.4567887',121),@end_dt DATETIME2(7) = CONVERT(DATETIME2(7),'2019-03-06 11:24:41.67887',121)
	--DECLARE @start_dt DATETIME2(7) = CONVERT(DATETIME2(7),'2020-04-29 08:04:45.4567887',121),@end_dt DATETIME2(7) = SYSDATETIME()
	--PRINT DATEDIFF(nanosecond, @start_dt, @end_dt)

	DECLARE @elapsed_time           VARCHAR(50) = '',
	        @diff_ns                INT = 0,
	        @diff_ms                INT = 0,
	        @diff_sec               INT,
	        @diff_min               INT,
	        @diff_hr                INT,
	        @diff_days              INT,
	        @diff_ms_all            BIGINT

    IF @start_dt > @end_dt
	BEGIN
		SET @elapsed_time = '-'
		DECLARE @start_dt_old DATETIME2(7) = @start_dt
		SET @start_dt = @end_dt
		SET @end_dt = @start_dt_old
	END

    IF @start_dt < @end_dt
	BEGIN

		SET	@diff_days = ROUND(DATEDIFF(HOUR, @start_dt,@end_dt) / 24, 0, 1)
		SET @start_dt = DATEADD(DAY,@diff_days,@start_dt)
		SET	@diff_hr  = ROUND(DATEDIFF(MINUTE, @start_dt, @end_dt) / 60, 0, 1)
		SET @start_dt = DATEADD(HOUR,@diff_hr,@start_dt)
		SET @diff_ms_all  = DATEDIFF(millisecond, @start_dt, @end_dt)

		--PRINT @diff_ms_all
		SET	@diff_min =	ROUND(@diff_ms_all / 60000, 0, 1)

		IF @diff_days = 0 
		BEGIN
			SET	@diff_sec = ROUND((@diff_ms_all - @diff_min * 60000) / 1000, 0, 1)

			IF @diff_hr = 0 
			BEGIN
				SET @start_dt = DATEADD(millisecond, @diff_ms_all,@start_dt)
				SET @diff_ms  = @diff_ms_all - @diff_min * 60000 - @diff_sec * 1000
				IF @diff_min = 0
				BEGIN
					SET @diff_ns = DATEDIFF(nanosecond, @start_dt, @end_dt)
					IF @diff_ns < 0
					BEGIN
						SET @diff_ms = @diff_ms - 1
						SET @diff_ns = 1000000 + @diff_ns
					END

				END
			END
		END

		--PRINT @diff_days
		--PRINT @diff_hr
		--PRINT @diff_min
		--PRINT @diff_sec
		--PRINT @diff_ms
		--PRINT @diff_ns

		SET @elapsed_time = @elapsed_time +
			ISNULL(CAST(NULLIF(@diff_days,0) AS VARCHAR(10)) + ' days ','') +
			ISNULL(CAST(NULLIF(@diff_hr,0) AS VARCHAR(2)) + ' hr ','') +
			ISNULL(CAST(NULLIF(@diff_min,0) AS VARCHAR(2)) + ' min ','') +
			ISNULL(CAST(NULLIF(@diff_sec,0) AS VARCHAR(2)) + ' sec ','') +
			ISNULL(CAST(NULLIF(@diff_ms,0) AS VARCHAR(3)) + ' msec ','') +
			ISNULL(CAST(NULLIF(@diff_ns,0) AS VARCHAR(6)) + ' nsec ','')
	END
	ELSE
	BEGIN
		SET @elapsed_time = '0 min 0 sec' --'? /calculation error/' -- it can be if there is null in input parameters
	END

	-- Return the result of the function
	--PRINT @elapsed_time

	RETURN @elapsed_time

END
