CREATE TABLE [Stage].[VehicleRegBlocks]
(
	[VRBID] bigint NOT NULL,
	[HVID] bigint NULL,
	[IsActive] bit NOT NULL,
	[StatusLookupID] int NULL,
	[VRBAgencyLookupID] int NULL,
	[RequestedDate] datetime2(3) NULL,
	[PlacedDate] datetime2(3) NULL,
	[RejectionDate] datetime2(3) NULL,
	[VRBRejectLookupID] int NULL,
	[RemoveRequestedDate] datetime2(3) NULL,
	[RemoveRejectionDate] datetime2(3) NULL,
	[VRBremovalRejectionLookupID] int NULL,
	[RemovedDate] datetime2(3) NULL,
	[VRBRemovalLookupID] int NULL,
	[RetryCount] int NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VRBID] ASC), DISTRIBUTION = HASH([VRBID]))
