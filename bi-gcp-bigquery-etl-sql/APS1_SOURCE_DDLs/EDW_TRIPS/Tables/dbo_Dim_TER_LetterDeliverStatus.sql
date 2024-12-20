CREATE TABLE [dbo].[Dim_TER_LetterDeliverStatus]
(
	[LetterDeliverStatusID] int NOT NULL,
	[LetterDeliverStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LetterDeliverStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[L1_LookupTypeCodeID] int NOT NULL,
	[L1_LookupTypeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[L1_LookupTypeCodeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([LetterDeliverStatusID] ASC), DISTRIBUTION = REPLICATE)
