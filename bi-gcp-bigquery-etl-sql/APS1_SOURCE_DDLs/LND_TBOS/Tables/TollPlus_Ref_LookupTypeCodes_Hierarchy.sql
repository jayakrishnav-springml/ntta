CREATE TABLE [TollPlus].[Ref_LookupTypeCodes_Hierarchy]
(
	[LookupTypeCodeID] int NOT NULL,
	[LookupTypeCode] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LookupTypeCodeDesc] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Parent_LookupTypeCodeID] int NULL,
	[Is_Available_ForUse] bit NULL,
	[Remarks] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([LookupTypeCodeID] DESC), DISTRIBUTION = HASH([LookupTypeCodeID]))
