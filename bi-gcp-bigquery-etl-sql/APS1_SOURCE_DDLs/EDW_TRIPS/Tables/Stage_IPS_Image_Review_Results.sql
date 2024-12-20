CREATE TABLE [Stage].[IPS_Image_Review_Results]
(
	[ImageReviewResultID] bigint NOT NULL,
	[IPSTransactionID] bigint NULL,
	[TPTripID] bigint NULL,
	[IsManuallyReviewed] bit NULL,
	[Timestamp] datetime2(3) NOT NULL,
	[IRR_LaneID] int NULL,
	[IRR_FacilityCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[IRR_PlazaCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[IRR_LaneCode] int NOT NULL,
	[VesSerialNumber] bigint NOT NULL,
	[PlateRegistration] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateJurisdiction] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReasonCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Disposition] int NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([TPTripID] ASC), DISTRIBUTION = HASH([TPTripID]))
