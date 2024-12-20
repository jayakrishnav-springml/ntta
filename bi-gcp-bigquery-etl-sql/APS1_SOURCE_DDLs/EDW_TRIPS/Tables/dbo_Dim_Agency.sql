CREATE TABLE [dbo].[Dim_Agency]
(
	[AgencyID] bigint NOT NULL,
	[AgencyType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AgencyName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AgencyStartDate] datetime2(3) NULL,
	[AgencyEndDate] datetime2(3) NULL,
	[LND_UpdatedDate] datetime2(3) NULL,
	[EDW_UpdatedDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([AgencyID] ASC), DISTRIBUTION = REPLICATE)
