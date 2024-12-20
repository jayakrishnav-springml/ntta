CREATE TABLE [Court].[AdminHearing]
(
	[AdminHearingID] bigint NOT NULL,
	[HVID] bigint NOT NULL,
	[VioAffidavitID] bigint NULL,
	[JudgeID] int NULL,
	[CauseNo] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[HVStatusLookupID] int NOT NULL,
	[HearingDate] datetime2(3) NULL,
	[CountyID] int NULL,
	[RequestedDate] datetime2(3) NOT NULL,
	[HearingReason] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Comments] varchar(2000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AdminHearingID] ASC), DISTRIBUTION = HASH([AdminHearingID]))
