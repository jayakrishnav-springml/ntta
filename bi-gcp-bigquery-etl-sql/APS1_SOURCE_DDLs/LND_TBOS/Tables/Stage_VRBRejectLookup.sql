CREATE TABLE [Stage].[VRBRejectLookup]
(
	[VRBRejectLookupID] int NOT NULL,
	[VRBRejectCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VRBRejectDesc] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NOT NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VRBRejectLookupID] ASC), DISTRIBUTION = HASH([VRBRejectLookupID]))
