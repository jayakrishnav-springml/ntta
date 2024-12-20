CREATE TABLE [Ref].[Plaza_County_XREF]
(
	[PlazaID] bigint NOT NULL,
	[PlazaAbbrev] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LaneDirection] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FacilityID] decimal(14,0) NOT NULL,
	[FacilityAbbrev] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[SubAgencyAbbrev] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AgencyAbbrev] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[County] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
)
WITH(CLUSTERED INDEX ([PlazaID] ASC), DISTRIBUTION = REPLICATE)
