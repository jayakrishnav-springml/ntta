CREATE TABLE [dbo].[Fact_Host_Service_Event_Summary]
(
	[Event_Summary_ID] int NOT NULL,
	[Event_Day_ID] int NOT NULL,
	[Nagios_Object_ID] int NOT NULL,
	[Host_Service_State_ID] smallint NOT NULL,
	[Event_Count] bigint NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([Event_Summary_ID] ASC), DISTRIBUTION = HASH([Event_Summary_ID]))
