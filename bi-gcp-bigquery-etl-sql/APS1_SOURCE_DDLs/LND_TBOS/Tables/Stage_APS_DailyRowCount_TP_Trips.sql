CREATE TABLE [Stage].[APS_DailyRowCount_TP_Trips]
(
	[DataBaseName] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TableName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] date NULL,
	[DRC_Row_Count] bigint NULL,
	[DUP_Row_Count] bigint NOT NULL,
	[Row_Count] bigint NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(HEAP, DISTRIBUTION = ROUND_ROBIN)
