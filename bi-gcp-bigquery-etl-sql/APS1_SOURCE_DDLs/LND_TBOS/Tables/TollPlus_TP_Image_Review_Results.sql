CREATE TABLE [TollPlus].[TP_Image_Review_Results]
(
	[ImageReviewResultID] bigint NOT NULL,
	[SourceTransactionID] bigint NULL,
	[IPSTransactionID] bigint NULL,
	[FacilityCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PlazaCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LaneCode] int NOT NULL,
	[Timestamp] datetime2(3) NOT NULL,
	[VesSerialNumber] bigint NOT NULL,
	[Disposition] int NOT NULL,
	[ReasonCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsManuallyReviewed] bit NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateRegistration] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateJurisdiction] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateJurisdictionCountry] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourceLanVilationID] bigint NULL,
	[SourceVilationID] bigint NULL,
	[ImageCodeOff] int NULL,
	[ImageReviewCount] int NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ImageReviewResultID] DESC), DISTRIBUTION = HASH([ImageReviewResultID]))
