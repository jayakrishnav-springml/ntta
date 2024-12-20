CREATE TABLE [dbo].[Dim_CustomerPaymentLevel]
(
	[CustomerPaymentLevelID] smallint NOT NULL,
	[CustomerPaymentLevel1] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CustomerPaymentLevel2] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CustomerPaymentLevel3] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CustomerPaymentLevel4] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SortSequenceNumber] smallint NOT NULL,
	[EDW_Update_Date] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([CustomerPaymentLevelID] ASC), DISTRIBUTION = REPLICATE)
