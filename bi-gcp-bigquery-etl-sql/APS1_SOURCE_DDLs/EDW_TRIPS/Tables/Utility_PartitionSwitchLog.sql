CREATE TABLE [Utility].[PartitionSwitchLog]
(
	[SwitchLogID] int NOT NULL,
	[SeqID] smallint NOT NULL,
	[TableName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PartitionNum] int NOT NULL,
	[NumberValueFrom] bigint NULL,
	[NumberValueTo] bigint NULL,
	[DateValueFrom] date NULL,
	[DateValueTo] date NULL,
	[NewRowCount] bigint NULL,
	[TableRowCount] bigint NULL,
	[ActionType] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LogDate] datetime2(3) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([SwitchLogID]))
