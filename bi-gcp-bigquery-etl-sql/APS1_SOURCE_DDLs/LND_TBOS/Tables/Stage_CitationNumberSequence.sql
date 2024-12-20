CREATE TABLE [Stage].[CitationNumberSequence]
(
	[SequenceID] int NOT NULL,
	[FailureCitationID] bigint NULL,
	[Sequence] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsConsumed] bit NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([SequenceID] ASC), DISTRIBUTION = HASH([SequenceID]))
