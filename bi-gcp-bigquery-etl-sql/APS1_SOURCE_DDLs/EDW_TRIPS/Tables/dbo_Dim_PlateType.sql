CREATE TABLE [dbo].[Dim_PlateType]
(
	[PlateTypeID] bigint NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(HEAP, DISTRIBUTION = REPLICATE)
