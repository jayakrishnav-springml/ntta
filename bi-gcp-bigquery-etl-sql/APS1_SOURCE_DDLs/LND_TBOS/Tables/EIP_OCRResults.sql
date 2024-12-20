CREATE TABLE [EIP].[OCRResults]
(
	[OCRResultID] bigint NOT NULL,
	[TransactionID] bigint NULL,
	[TxnImageID] bigint NULL,
	[OCRResultIndex] int NOT NULL,
	[PlateConfidence] int NOT NULL,
	[PlateRegistration] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RegistrationReadConfidence] int NULL,
	[PlateJurisdiction] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[JurisdictionReadConfidence] int NULL,
	[PlateCharHeight] int NULL,
	[PlateLoactionRight] int NULL,
	[PlateLoactionLeft] int NULL,
	[PlateLoactionTop] int NULL,
	[PlateLoactionBottom] int NULL,
	[PlateCharResults] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateVSRneeded] smallint NULL,
	[Disposition] int NULL,
	[ReasonCode] int NULL,
	[CreatedDate] datetime2(0) NULL,
	[CreatedUser] nvarchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(0) NULL,
	[UpdatedUser] nvarchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([OCRResultID] ASC), DISTRIBUTION = HASH([OCRResultID]))
