CREATE FUNCTION [dbo].[UF_FIND_ELAPSED_TIME] (@start_dt [DATETIME],@end_dt [DATETIME]) RETURNS VARCHAR(50)
AS
BEGIN
	
	DECLARE @elapsed_time           VARCHAR(50),
	        @diff_ms                INT,
	        @diff_sec               INT,
	        @diff_min               INT,
	        @diff_hr                INT
	
	SET		@diff_sec   = DATEDIFF(SECOND, @start_dt,@end_dt)
	SET		@diff_min   = DATEDIFF(MINUTE, @start_dt, @end_dt)
	SET		@diff_hr    = DATEDIFF(HOUR, @start_dt, @end_dt)
    
    IF @diff_sec = 0 
        SET @diff_ms    = datediff(ms, @start_dt, @end_dt) 
	
    IF @start_dt <= @end_dt
		SET @elapsed_time = 		
			CASE
				WHEN @diff_sec = 0 
				THEN CONVERT(VARCHAR(8),@diff_ms) + ' msec'
				WHEN @diff_sec < 60 
				THEN CONVERT(VARCHAR(2),@diff_sec) + ' sec'
				WHEN @diff_min < 60
				THEN RTRIM(CONVERT(VARCHAR(5),(@diff_sec / 60))) + ' min ' +
						   CASE WHEN (@diff_sec % 60) > 0 THEN convert(varchar(2),(@diff_sec % 60)) + ' sec' ELSE '' END
				WHEN @diff_hr > 0
				THEN CASE   WHEN @diff_min - @diff_hr * 60 >= 0
				            THEN RTRIM(CONVERT(varchar(5), @diff_hr) + ' hr ' +
						         CASE WHEN (@diff_min - @diff_hr * 60) > 0 THEN CONVERT(VARCHAR(2),(@diff_min - @diff_hr * 60)) + ' min' ELSE '' END )
						    ELSE  -- negative minutes!
			                     RTRIM(CONVERT(VARCHAR(5), (@diff_hr-1)) + ' hr ' +
						         CONVERT(VARCHAR(2),(@diff_min - (@diff_hr-1) * 60))) + ' min' 
				    END

			END
	ELSE 
		SET @elapsed_time = '?'

	-- Return the result of the function
	RETURN @elapsed_time

END
