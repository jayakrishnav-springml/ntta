CREATE TABLE [TER].[VehicleBan]
(
	[VehicleBanID] bigint NOT NULL,
	[HVID] bigint NOT NULL,
	[IsActive] bit NOT NULL,
	[VBLookupID] int NULL,
	[ActionDate] datetime2(3) NULL,
	[SourcePKID] bigint NULL,
	[RemovalLookupID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VehicleBanID] ASC), DISTRIBUTION = HASH([VehicleBanID]))
