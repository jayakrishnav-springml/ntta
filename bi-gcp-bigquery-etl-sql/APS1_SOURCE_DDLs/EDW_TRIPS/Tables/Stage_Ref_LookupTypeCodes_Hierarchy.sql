CREATE TABLE [Stage].[Ref_LookupTypeCodes_Hierarchy]
(
	[LookupTypeCodeID] int NULL,
	[L1_LookupTypeCodeID] int NOT NULL,
	[L1_LookupTypeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[L1_LookupTypeCodeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[L2_LookupTypeCodeID] int NOT NULL,
	[L2_LookupTypeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[L2_LookupTypeCodeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[L3_LookupTypeCodeID] int NULL,
	[L3_LookupTypeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[L3_LookupTypeCodeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[L4_LookupTypeCodeID] int NULL,
	[L4_LookupTypeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[L4_LookupTypeCodeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([LookupTypeCodeID] ASC), DISTRIBUTION = REPLICATE)
