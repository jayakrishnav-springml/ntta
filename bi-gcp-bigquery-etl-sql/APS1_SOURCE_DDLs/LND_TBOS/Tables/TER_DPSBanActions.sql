CREATE TABLE [TER].[DPSBanActions]
(
	[DPSBanActionID] bigint NOT NULL,
	[DPSAction] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IssueDate] datetime2(3) NULL,
	[Location] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TrooperName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TrooperRadioNum] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AlprAction] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[NotifiedBy] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleBanID] bigint NULL,
	[MileMarker] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([DPSBanActionID] ASC), DISTRIBUTION = HASH([DPSBanActionID]))
