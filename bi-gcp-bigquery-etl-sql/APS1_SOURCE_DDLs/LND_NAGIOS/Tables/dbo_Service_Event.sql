CREATE TABLE [dbo].[Service_Event]
(
	[Service_Event_ID] bigint NOT NULL,
	[Service_Object_ID] int NOT NULL,
	[Event_Date] datetime NOT NULL,
	[Service_State] tinyint NOT NULL,
	[Host] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Service] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Event_Info] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Perf_Data] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_String] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Count] tinyint NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([Service_Event_ID] DESC), DISTRIBUTION = HASH([Service_Object_ID]), 
	PARTITION ([Event_Date] RANGE RIGHT FOR VALUES ('20210501 00:00:00', '20210601 00:00:00', '20210701 00:00:00', '20210801 00:00:00', '20210901 00:00:00', '20211001 00:00:00', '20211101 00:00:00', '20211201 00:00:00', '20220101 00:00:00', '20220201 00:00:00', '20220301 00:00:00', '20220401 00:00:00', '20220501 00:00:00', '20220601 00:00:00', '20220701 00:00:00', '20220801 00:00:00', '20220901 00:00:00', '20221001 00:00:00', '20221101 00:00:00', '20221201 00:00:00')))
