CREATE TABLE [Stage].[EligibleForCitations]
(
	[EligibleCitationID] bigint NOT NULL,
	[AccountNumber] bigint NOT NULL,
	[Name] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleMake] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleModel] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleYear] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[NoOfEligibleNotices] int NULL,
	[TotalOutstandingTolls] int NULL,
	[FirstEligibleTxnDate] datetime2(3) NULL,
	[LastEligibleTxnDate] datetime2(3) NULL,
	[CoOwnerExists] bit NULL,
	[Suffix] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PrvRefreshOptOutDate] datetime2(3) NULL,
	[OptOutDate] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([EligibleCitationID] ASC), DISTRIBUTION = HASH([EligibleCitationID]))
