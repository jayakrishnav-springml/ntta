CREATE TABLE [dbo].[Dim_AccountCategory]
(
	[AccountCategoryID] smallint NOT NULL,
	[AccountCategoryDesc] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([AccountCategoryID] ASC), DISTRIBUTION = REPLICATE)
