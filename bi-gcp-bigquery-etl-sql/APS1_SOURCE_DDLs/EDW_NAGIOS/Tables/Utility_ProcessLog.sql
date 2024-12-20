CREATE TABLE [Utility].[ProcessLog]
(
	[LogDate] datetime2(3) NOT NULL,
	[LogSource] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LogMessage] varchar(4000) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LogType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Row_Count] bigint NULL,
	[ProcTime] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[QueryTime] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ProcTimeInSec] decimal(19,3) NULL,
	[QueryTimeInSec] decimal(19,3) NULL,
	[ProcStartDate] datetime2(3) NULL,
	[QuerySubmitDate] datetime2(3) NULL,
	[QueryEndDate] datetime2(3) NULL,
	[SessionID] varchar(12) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[QueryID] varchar(12) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Query] varchar(max) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ResourceClass] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([LogDate] DESC, [LogSource] ASC), DISTRIBUTION = REPLICATE)
