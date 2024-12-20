CREATE TABLE [Stage].[ETagPlates]
(
	[ETagPlateRecordID] int NOT NULL,
	[UniqueID] int NULL,
	[VIN] varchar(22) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LicensePlateNumber] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LicensePlateState] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ETagUsageReason] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ETagDescription] varchar(21) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TitleNo] varchar(17) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerName1] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerName2] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerAddress1] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerAddress2] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerCity] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerState] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerZip1] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerZip2] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleBodyStyle] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleMake] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleModel] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleYear] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleColor] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerShipStartDate] datetime2(3) NOT NULL,
	[OwnerShipEndDate] datetime2(3) NULL,
	[FileID] int NOT NULL,
	[Stage1RecordID] bigint NULL,
	[Stage2RecordID] bigint NULL,
	[NormalisedLicensePlateNumber] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[NormalisedPreviousPlateNo] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedTimestamp] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedTimestamp] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ETagPlateRecordID] DESC), DISTRIBUTION = HASH([ETagPlateRecordID]))
