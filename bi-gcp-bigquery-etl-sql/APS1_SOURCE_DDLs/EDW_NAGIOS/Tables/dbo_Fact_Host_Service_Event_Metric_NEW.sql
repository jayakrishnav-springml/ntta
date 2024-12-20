CREATE TABLE [dbo].[Fact_Host_Service_Event_Metric_NEW]
(
	[Host_Service_Event_ID] bigint NOT NULL,
	[Host_Service_Metric_ID] int NOT NULL,
	[Event_Day_ID] int NOT NULL,
	[Event_Time_ID] int NOT NULL,
	[Metric_State_ID] smallint NOT NULL,
	[Event_Date] datetime NOT NULL,
	[Metric_Index] smallint NOT NULL,
	[Metric_Value] decimal(19,8) NULL,
	[Metric_Unit] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Warning_Value] decimal(19,8) NULL,
	[Critical_Value] decimal(19,8) NULL,
	[Min_Value] decimal(19,8) NULL,
	[Max_Value] decimal(19,8) NULL,
	[Percent_Warning] decimal(19,2) NULL,
	[Percent_Critical] decimal(19,2) NULL,
	[Percent_Max] decimal(19,2) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([Host_Service_Event_ID] DESC), DISTRIBUTION = HASH([Host_Service_Event_ID]))
