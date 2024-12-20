CREATE TABLE [MIR].[MST_DispositionCodes]
(
	[Disposition_CodeID_PK] int NOT NULL,
	[DispositionCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Description] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(0) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([Disposition_CodeID_PK] ASC), DISTRIBUTION = HASH([Disposition_CodeID_PK]))
