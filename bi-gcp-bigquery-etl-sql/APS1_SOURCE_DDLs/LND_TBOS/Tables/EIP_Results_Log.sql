CREATE TABLE [EIP].[Results_Log]
(
	[TransactionID] bigint NOT NULL,
	[Node] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[GroupID] int NOT NULL,
	[GroupSize] int NOT NULL,
	[GroupStageID] int NOT NULL,
	[IsValidGroup] smallint NOT NULL,
	[TranID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AgencyCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RoadID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PlazaID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LaneID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VehicleClass] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TransactionDate] date NOT NULL,
	[TransactionTime] int NOT NULL,
	[ImageOfRecordID] bigint NULL,
	[Disposition] int NULL,
	[ReasonCode] int NULL,
	[TimeMIR] int NOT NULL,
	[PlateJurisdiction] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateRegistration] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateTypePrefix] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateTypeSuffix] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ALPRJurisdiction] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ALPRRegistration] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EIPReceivedDate] datetime2(0) NULL,
	[EIPCompletedDate] datetime2(0) NULL,
	[PlateSyntax] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatusID] int NULL,
	[SubReasonTime] int NOT NULL,
	[LastReviewer] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionTypeID] smallint NOT NULL,
	[TotalImgEnhTime] int NOT NULL,
	[ReviewCount] int NOT NULL,
	[CameraName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CameraID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsDayImage] smallint NULL,
	[ImageContrast] decimal(5,2) NULL,
	[ImageBrightness] decimal(5,2) NULL,
	[PlateReadConfidence] int NULL,
	[IsCommonSyntax] smallint NULL,
	[SignatureMatchStatus] smallint NULL,
	[CameraView] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsValidGroupAIP] smallint NULL,
	[RepresentativeTranID] bigint NULL,
	[PlateType] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TransactionID] ASC, [TransactionTypeID] ASC), DISTRIBUTION = HASH([TransactionID]))
