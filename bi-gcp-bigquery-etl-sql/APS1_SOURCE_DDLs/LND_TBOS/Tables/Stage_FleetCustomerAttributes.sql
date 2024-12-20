CREATE TABLE [Stage].[FleetCustomerAttributes]
(
	[FleetAttrID] int NOT NULL,
	[CustomerID] bigint NULL,
	[Abbreviation] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VCFOptionsID] int NULL,
	[FleetTypeID] int NULL,
	[VCFGenerationTime] time(7) NULL,
	[VCFGenerationFrequency] int NULL,
	[VCFGenerationDay] tinyint NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([FleetAttrID] DESC), DISTRIBUTION = HASH([FleetAttrID]))
