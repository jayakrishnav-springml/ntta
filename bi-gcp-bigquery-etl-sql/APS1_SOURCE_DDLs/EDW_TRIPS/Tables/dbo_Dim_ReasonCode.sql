CREATE TABLE [dbo].[Dim_ReasonCode]
(
	[ReasonCodeID] bigint NULL,
	[ReasonCode] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([ReasonCodeID] ASC), DISTRIBUTION = REPLICATE)
