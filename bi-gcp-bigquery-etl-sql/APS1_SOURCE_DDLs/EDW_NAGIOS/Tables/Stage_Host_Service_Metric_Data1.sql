CREATE TABLE [Stage].[Host_Service_Metric_Data1]
(
	[Host_Service_Event_ID] bigint NOT NULL,
	[Host_Service_State] tinyint NOT NULL,
	[Host] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Service] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_String] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Count] tinyint NULL,
	[EQ_1] int NULL,
	[EQ_2] int NULL,
	[EQ_3] int NULL,
	[EQ_4] int NULL,
	[EQ_5] int NULL,
	[EQ_6] int NULL,
	[EQ_7] int NULL,
	[EQ_8] int NULL,
	[EQ_9] int NULL,
	[EQ_10] int NULL,
	[EQ_11] int NULL,
	[EQ_12] int NULL,
	[EQ_13] int NULL,
	[EQ_14] int NULL,
	[EQ_15] int NULL,
	[EQ_16] int NULL,
	[EQ_17] int NULL
)
WITH(HEAP, DISTRIBUTION = HASH([Host_Service_Event_ID]))
