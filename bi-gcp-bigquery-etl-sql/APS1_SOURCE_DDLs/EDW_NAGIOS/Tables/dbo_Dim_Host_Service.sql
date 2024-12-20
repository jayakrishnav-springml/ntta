CREATE TABLE [dbo].[Dim_Host_Service]
(
	[Nagios_Object_ID] int NULL,
	[Object_Type] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Host_Facility] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Host_Type] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Host] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Service] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Host_Plaza] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Plaza_Latitude] decimal(23,12) NULL,
	[Plaza_Longitude] decimal(23,12) NULL,
	[Is_Active] int NOT NULL,
	[Is_Deleted] bit NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime NOT NULL
)
WITH(CLUSTERED INDEX ([Nagios_Object_ID] ASC), DISTRIBUTION = REPLICATE)
