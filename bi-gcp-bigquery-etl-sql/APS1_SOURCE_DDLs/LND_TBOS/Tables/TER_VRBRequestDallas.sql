CREATE TABLE [TER].[VRBRequestDallas]
(
	[VRBRequestDallasID] bigint NOT NULL,
	[VRBID] bigint NOT NULL,
	[CitationNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FirstName] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastName] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Address] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[City] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[State] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Zip] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FileID] bigint NULL,
	[OffenceDate] datetime2(3) NULL,
	[VehicleNumber] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VIN] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CaseBalance] decimal(19,2) NULL,
	[CaseFileDate] datetime2(3) NULL,
	[DallasScOffLaw] bit NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VRBRequestDallasID] ASC), DISTRIBUTION = HASH([VRBRequestDallasID]))
