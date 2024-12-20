CREATE TABLE [Stage].[Host_Service_Metric_Data5]
(
	[Host_Service_Event_ID] bigint NOT NULL,
	[Host_Service_State] tinyint NOT NULL,
	[Host] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Service] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Count] tinyint NULL,
	[Metric_String] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Index] int NOT NULL,
	[Metric_Name] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Value_String] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Value_Unit] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Value] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Unit] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Warning_Value] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Critical_Value] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Min_Value] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Max_Value] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(HEAP, DISTRIBUTION = HASH([Host_Service_Event_ID]))
