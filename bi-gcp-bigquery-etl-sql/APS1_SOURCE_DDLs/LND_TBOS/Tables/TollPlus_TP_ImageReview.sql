CREATE TABLE [TollPlus].[TP_ImageReview]
(
	[ImageReviewID] bigint NOT NULL,
	[EventID] bigint NOT NULL,
	[TransactionDateTime] datetime2(3) NOT NULL,
	[PlazaID] int NOT NULL,
	[LaneID] int NOT NULL,
	[VehicleState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClass] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagID] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FacilityCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatusID] int NOT NULL,
	[StatusDate] datetime2(3) NOT NULL,
	[ReasonCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReviewType] int NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ImageReviewID] DESC), DISTRIBUTION = HASH([ImageReviewID]))
