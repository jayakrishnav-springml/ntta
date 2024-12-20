CREATE TABLE [Stage].[VRBAgencyLookup]
(
	[VRBAgencyLookupID] smallint NOT NULL,
	[VRBAgencyCode] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VRBAgencyDesc] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VRBAgencyLookupID] ASC), DISTRIBUTION = HASH([VRBAgencyLookupID]))
