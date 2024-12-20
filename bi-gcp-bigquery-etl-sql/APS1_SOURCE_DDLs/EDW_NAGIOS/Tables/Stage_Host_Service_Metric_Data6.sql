CREATE TABLE [Stage].[Host_Service_Metric_Data6]
(
	[Host_Service_Event_ID] bigint NOT NULL,
	[Host_Service_State] tinyint NOT NULL,
	[Host] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Service] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_String] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Index] int NOT NULL,
	[Metric_Suffix] smallint NULL,
	[Metric_Name] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Value] decimal(19,8) NULL,
	[Metric_Unit] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Warning_Value] decimal(19,8) NULL,
	[Critical_Value] decimal(19,8) NULL,
	[Min_Value] decimal(19,8) NULL,
	[Max_Value] decimal(19,8) NULL
)
WITH(HEAP, DISTRIBUTION = HASH([Host_Service_Event_ID]))
