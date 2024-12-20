CREATE TABLE [Ref].[Facility_Sub_Agency]
(
	[FacilityAbbrev] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SubAgencyAbbrev] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OperationsAgency] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastUpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastUpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([FacilityAbbrev] ASC), DISTRIBUTION = REPLICATE)
