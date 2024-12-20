CREATE TABLE [dbo].[Fact_Host_Service_Event_Metric_OLD]
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
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([Host_Service_Event_ID]), 
	PARTITION ([Event_Day_ID] RANGE RIGHT FOR VALUES (20210301, 20210401, 20210501, 20210601, 20210701, 20210801, 20210901, 20211001, 20211101, 20211201, 20220101)))
