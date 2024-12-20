CREATE TABLE [dbo].[Dim_TripPaymentStatus]
(
	[TripPaymentStatusID] int NOT NULL,
	[TripPaymentStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripPaymentStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([TripPaymentStatusID] ASC), DISTRIBUTION = REPLICATE)
