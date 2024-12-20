CREATE TABLE [TER].[ViolatorCollectionsOutboundStatus]
(
	[VioCollOutboundStatusUpdateID] bigint NOT NULL,
	[FileID] bigint NULL,
	[SusRelFileID] bigint NULL,
	[ViolatorID] bigint NULL,
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Status] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Reason] varchar(300) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VioCollOutboundStatusUpdateID] ASC), DISTRIBUTION = HASH([VioCollOutboundStatusUpdateID]))
