CREATE TABLE [Stage].[ReasonCodes]
(
	[ReasonCodeID] int NOT NULL,
	[ReasonCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReasonCodeDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ShortCutKey] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParentID] int NOT NULL,
	[TPMappingReasonCodeID] int NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(0) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ReasonCodeID] ASC), DISTRIBUTION = HASH([ReasonCodeID]))
