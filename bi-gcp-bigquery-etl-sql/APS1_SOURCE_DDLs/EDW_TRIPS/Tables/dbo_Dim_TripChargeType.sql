CREATE TABLE [dbo].[Dim_TripChargeType]
(
	[TripChargeTypeID] bigint NULL,
	[TripChargeType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(HEAP, DISTRIBUTION = REPLICATE)
