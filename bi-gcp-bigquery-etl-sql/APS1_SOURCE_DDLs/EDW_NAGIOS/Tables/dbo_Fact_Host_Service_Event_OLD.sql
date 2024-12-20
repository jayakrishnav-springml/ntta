CREATE TABLE [dbo].[Fact_Host_Service_Event_OLD]
(
	[Host_Service_Event_ID] bigint NOT NULL,
	[Nagios_Object_ID] int NOT NULL,
	[Event_Date] datetime NOT NULL,
	[Event_Day_ID] int NOT NULL,
	[Event_Time_ID] int NOT NULL,
	[Host_Service_State_ID] smallint NOT NULL,
	[Metric_Count] tinyint NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([Host_Service_Event_ID]), 
	PARTITION ([Event_Day_ID] RANGE RIGHT FOR VALUES (20210301, 20210401, 20210501, 20210601, 20210701, 20210801, 20210901, 20211001, 20211101, 20211201, 20220101)))
