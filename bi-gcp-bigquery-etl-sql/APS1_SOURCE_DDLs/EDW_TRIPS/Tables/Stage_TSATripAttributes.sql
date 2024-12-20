CREATE TABLE [Stage].[TSATripAttributes]
(
	[TPTripID] bigint NOT NULL,
	[SourceTripID] bigint NULL,
	[TripDate] datetime2(3) NULL,
	[RecordType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleSpeed] int NULL,
	[VehicleClassification] varchar(3) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransponderTollAmount] decimal(19,2) NULL,
	[VideoTollAmountWithVideoTollPremium] decimal(19,2) NULL,
	[VideoTollAmountWithoutVideoTollPremium] decimal(19,2) NULL,
	[TSA_ReceivedTollAmount] decimal(19,2) NULL,
	[TSA_Base] decimal(19,2) NULL,
	[TSA_Premium] decimal(20,2) NULL,
	[TransponderDiscountType] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DiscountedTransponderTollAmount] decimal(19,2) NULL,
	[VideoDiscountType] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DiscountedVideoTollAmountWithoutVideoTollPremium] decimal(19,2) NULL,
	[DiscountedVideoTollAmountWithVideoTollPremium] decimal(19,2) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([TPTripID] ASC), DISTRIBUTION = HASH([TPTripID]))
