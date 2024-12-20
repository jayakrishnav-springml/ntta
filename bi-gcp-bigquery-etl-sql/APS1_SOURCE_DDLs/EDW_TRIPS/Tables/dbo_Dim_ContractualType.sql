CREATE TABLE [dbo].[Dim_ContractualType]
(
	[ContractualTypeID] int NOT NULL,
	[ContractualTypeCode] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ContractualTypeDesc] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([ContractualTypeID] ASC), DISTRIBUTION = REPLICATE)
