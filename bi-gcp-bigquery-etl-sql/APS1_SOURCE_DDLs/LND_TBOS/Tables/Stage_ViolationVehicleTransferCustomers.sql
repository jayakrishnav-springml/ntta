CREATE TABLE [Stage].[ViolationVehicleTransferCustomers]
(
	[VTNCustID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[VehicleNumber] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleState] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EffectiveDate] datetime2(3) NULL,
	[CustomerFullName] varchar(122) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DocNo] varchar(17) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[NonLiabilityReasonID] bigint NULL,
	[NormalizedVehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsValid] bit NULL,
	[Comments] varchar(2000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DocumentPath] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FilePathConfigID] int NULL,
	[Status] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RequestedDate] datetime2(3) NULL,
	[ProcessedDate] datetime2(3) NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VTNCustID] ASC), DISTRIBUTION = HASH([VTNCustID]))
