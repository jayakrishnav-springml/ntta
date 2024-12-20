CREATE TABLE [dbo].[Dim_AdjApprovalStatus]
(
	[AdjApprovalStatusID] int NOT NULL,
	[AdjApprovalStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AdjApprovalStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([AdjApprovalStatusID] ASC), DISTRIBUTION = REPLICATE)
