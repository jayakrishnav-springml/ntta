CREATE TABLE [MIR].[TxnQueues]
(
	[QueueID] int NOT NULL,
	[QueueName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[QueueCode] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Queue Description] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[MaxTransToPull] int NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(0) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([QueueID] ASC), DISTRIBUTION = HASH([QueueID]))
