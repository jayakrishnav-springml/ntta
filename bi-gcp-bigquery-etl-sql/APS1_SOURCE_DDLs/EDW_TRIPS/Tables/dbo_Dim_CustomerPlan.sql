CREATE TABLE [dbo].[Dim_CustomerPlan]
(
	[CustomerPlanID] smallint NOT NULL,
	[CustomerPlanDesc] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([CustomerPlanID] ASC), DISTRIBUTION = REPLICATE)
