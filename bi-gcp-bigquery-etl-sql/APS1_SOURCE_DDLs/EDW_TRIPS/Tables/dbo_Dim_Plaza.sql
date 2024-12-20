CREATE TABLE [dbo].[Dim_Plaza]
(
	[PlazaID] int NOT NULL,
	[PlazaCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IPS_PlazaCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlazaName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PlazaLatitude] decimal(23,12) NOT NULL,
	[PlazaLongitude] decimal(23,12) NOT NULL,
	[ZipCode] int NOT NULL,
	[County] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[FacilityID] int NOT NULL,
	[FacilityCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FacilityName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IPS_FacilityCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TSAFlag] bit NULL,
	[TSAFacilityID] int NULL,
	[BitMaskID] bigint NOT NULL,
	[SubAgencyAbbrev] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OperationsAgency] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyID] bigint NOT NULL,
	[AgencyType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AgencyName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AgencyStartDate] datetime2(3) NULL,
	[AgencyEndDate] datetime2(3) NULL,
	[LND_UpdatedDate] datetime2(3) NULL,
	[EDW_UpdatedDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([PlazaID] ASC), DISTRIBUTION = REPLICATE)
