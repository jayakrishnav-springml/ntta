CREATE TABLE [dbo].[Dim_Host_Service_Metric]
(
	[Host_Service_Metric_ID] bigint NULL,
	[Nagios_Object_ID] int NOT NULL,
	[Object_Type] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Host_Facility] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Host_Plaza] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Host_Type] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Host] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Service] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Plaza_Latitude] decimal(23,12) NULL,
	[Plaza_Longitude] decimal(23,12) NULL,
	[Is_Active] int NULL,
	[Metric_Name] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Suffix] smallint NULL,
	[Metric_Target_Type] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Target] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([Host_Service_Metric_ID] ASC), DISTRIBUTION = REPLICATE)
