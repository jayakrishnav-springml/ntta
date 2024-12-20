CREATE TABLE [Stage].[TP_Customer_Activities]
(
	[ActivityID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[ActivityDate] datetime2(3) NOT NULL,
	[ActivityType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ActivityText] varchar(2000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PerformedBy] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SubSystem] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ActivitySource] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LinkID] bigint NOT NULL,
	[LinkSourceName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NOT NULL,
	[UserLocation] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleState] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ICNID] bigint NULL,
	[OutboundCommunicationID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ActivityID] DESC), DISTRIBUTION = HASH([ActivityID]))
