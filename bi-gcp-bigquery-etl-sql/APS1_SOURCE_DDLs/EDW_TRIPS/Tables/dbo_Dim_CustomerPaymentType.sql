CREATE TABLE [dbo].[Dim_CustomerPaymentType]
(
	[CustomerPaymentTypeID] smallint NOT NULL,
	[CustomerPaymentType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EDW_Update_Date] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([CustomerPaymentTypeID] ASC), DISTRIBUTION = REPLICATE)
