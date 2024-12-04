CREATE TABLE [Stage].[Transactions]
(
	[TransactionID] bigint NOT NULL,
	[AgencyCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ServerID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PlazaID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LaneID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TranID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LanePosition] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IssuingAuthority] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Timestamp] bigint NULL,
	[UtcTimeStamp] datetime2(3) NULL,
	[LocalTimeStamp] datetime2(3) NULL,
	[TransactionDate] date NOT NULL,
	[TransactionTime] int NOT NULL,
	[TransponderID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransponderClass] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClass] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Vehiclelength] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ViolationCode] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TollClass] int NULL,
	[TollDue] int NULL,
	[TollPaid] int NULL,
	[ImageOfRecordID] bigint NOT NULL,
	[PrimaryPlateImageID] bigint NULL,
	[PrimaryPlateReadConfidence] int NULL,
	[OCRPlateRegistration] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RegistrationReadConfidence] int NULL,
	[OCRPlateJurisdiction] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[JurisdictionReadConfidence] int NULL,
	[SignatureHandle] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SignatureConfidence] int NULL,
	[CombinedPlateResultStatus] smallint NULL,
	[CombinedStateResultStatus] smallint NULL,
	[StartDate] datetime2(0) NOT NULL,
	[EndDate] datetime2(0) NULL,
	[StageTypeID] int NULL,
	[StageID] int NULL,
	[StatusID] int NULL,
	[StatusDescription] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatusDate] datetime2(0) NULL,
	[VehicleID] bigint NULL,
	[GroupID] int NULL,
	[RepresentativeSigImageID] bigint NOT NULL,
	[SignatureMatchID] bigint NOT NULL,
	[SignatureConflictID1] bigint NOT NULL,
	[SignatureConflictID2] bigint NOT NULL,
	[Daynighttwilight] smallint NULL,
	[Node] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Nodeinst] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RoadwayID] int NOT NULL,
	[AgencyTimestamp] bigint NOT NULL,
	[ReceivedDate] datetime2(0) NOT NULL,
	[AuditFileID] int NULL,
	[MisreadDisposition] int NULL,
	[Disposition] int NULL,
	[ReasonCode] int NULL,
	[LastReviewer] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateTypePrefix] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateTypeSuffix] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateRegistration] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateJurisdiction] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ISFSerialNumber] int NULL,
	[RevenueAxles] int NULL,
	[IndicatedVehicleClass] int NULL,
	[IndicatedAxles] int NULL,
	[ActualAxles] int NULL,
	[VehicleSpeed] int NULL,
	[TagStatus] smallint NULL,
	[FacilityCode] varchar(45) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SubscriberID] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] nvarchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(0) NULL,
	[UpdatedUser] nvarchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TransactionID] ASC), DISTRIBUTION = HASH([TransactionID]))
