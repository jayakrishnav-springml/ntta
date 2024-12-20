CREATE TABLE [dbo].[Fact_Host_Service_Event_NEW]
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
WITH(CLUSTERED INDEX ([Host_Service_Event_ID] ASC), DISTRIBUTION = HASH([Host_Service_Event_ID]))
