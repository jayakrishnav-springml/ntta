CREATE TABLE [Stage].[DMVExceptionDetails]
(
	[ExceptionDetailsID] int NOT NULL,
	[ExceptionQueueID] int NOT NULL,
	[CustomerID] bigint NULL,
	[DataMartID] bigint NULL,
	[TpTripID] bigint NULL,
	[LinkSourceName] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VIN] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DocumentNumber] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RegistrationState] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RegistrationCountry] varchar(3) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleMake] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleModel] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleYear] int NULL,
	[VehicleColor] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClassName] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClassCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleStartEffeictiveDate] datetime2(3) NULL,
	[VehicleEndEffeictiveDate] datetime2(3) NULL,
	[OwnerFirstName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerLastName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerMiddleName] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerAddress1] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerAddress2] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerCity] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerCountry] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerZip1] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerZip2] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RenewalFirstName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RenewalLastName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RenewalMiddleName] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RenewalAddress1] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RenewalAddress2] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RenewalCity] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RenewalState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RenewalCountry] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RenewalZip1] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RenewalZip2] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsValid] bit NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ExceptionDetailsID] ASC), DISTRIBUTION = HASH([ExceptionDetailsID]))
