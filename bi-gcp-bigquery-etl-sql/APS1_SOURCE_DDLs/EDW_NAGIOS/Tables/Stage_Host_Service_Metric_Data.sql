CREATE TABLE [Stage].[Host_Service_Metric_Data]
(
	[Host_Service_Event_ID] bigint NOT NULL,
	[Event_Date] datetime NOT NULL,
	[Nagios_Object_ID] int NOT NULL,
	[Host_Type] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Host] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Service] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Host_Service_State] tinyint NOT NULL,
	[Event_Info] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_String] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Index] int NOT NULL,
	[Metric_Suffix] smallint NULL,
	[Metric_Name] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Value] decimal(19,8) NULL,
	[Metric_Unit] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Warning_Value] decimal(19,8) NULL,
	[Critical_Value] decimal(19,8) NULL,
	[Min_Value] decimal(19,8) NULL,
	[Max_Value] decimal(19,8) NULL,
	[Metric_State] int NOT NULL,
	[Percent_Warning] decimal(19,2) NULL,
	[Percent_Critical] decimal(19,2) NULL,
	[Percent_Max] decimal(19,2) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(HEAP, DISTRIBUTION = HASH([Host_Service_Event_ID]))
