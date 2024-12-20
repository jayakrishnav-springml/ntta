CREATE TABLE [dbo].[Fact_Host_Service_Event_Metric_Summary_OLD]
(
	[Event_Metric_Summary_ID] int NOT NULL,
	[Event_Day_ID] int NOT NULL,
	[Host_Service_Metric_ID] int NOT NULL,
	[Metric_State_ID] smallint NOT NULL,
	[Metric_Unit] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Total_Metric_Value] decimal(19,8) NULL,
	[Metric_Value_Count] int NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([Event_Metric_Summary_ID] ASC), DISTRIBUTION = HASH([Event_Metric_Summary_ID]))
