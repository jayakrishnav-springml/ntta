CREATE TABLE [Stage].[CaseLinks]
(
	[CaseLinkID] bigint NOT NULL,
	[CaseID] bigint NOT NULL,
	[LinkID] bigint NOT NULL,
	[LinkSource] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CaseStatus] int NULL,
	[Remarks] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LinkStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ImageReviewStatus] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CaseLinkID] ASC), DISTRIBUTION = HASH([CaseLinkID]))
