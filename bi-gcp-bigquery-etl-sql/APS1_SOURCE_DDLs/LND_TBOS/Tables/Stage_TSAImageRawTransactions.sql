CREATE TABLE [Stage].[TSAImageRawTransactions]
(
	[ImgTxnID] bigint NOT NULL,
	[TxnID] bigint NULL,
	[SeparaTor] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ImageFileName] varchar(38) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ImageLocationType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ImageFacing] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LicensePlateState] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LicensePlateStateConfidenceLevel] bigint NULL,
	[LicensePlateCountry] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LicensePlateCountryConfidenceLevel] bigint NULL,
	[LicensePlateValue] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LicensePlateValueConfidenceLevel] bigint NULL,
	[LicensePlateType] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LicensePlateTypeConfidenceLevel] bigint NULL,
	[OCREngineType] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LicensePlateOverallConfidenceLevel] bigint NULL,
	[RegionOfInterestROICoordinateUpperLeftX] bigint NULL,
	[RegionOfInterestROICoordinateUpperLeftY] bigint NULL,
	[RegionOfInterestROICoordinateLowerRightX] bigint NULL,
	[RegionOfInterestROICoordinateLowerRightY] bigint NULL,
	[LicensePlateStatus] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsImageValid] bit NULL,
	[ReasonCode] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourcePKID] bigint NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ImgTxnID] ASC), DISTRIBUTION = HASH([ImgTxnID]))
