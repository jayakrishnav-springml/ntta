CREATE TABLE [dbo].[Dim_VBRemovalReason]
(
	[VBRemovalReasonID] int NOT NULL,
	[VBRemovalReasonCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VBRemovalReasonDescription] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParentStatusID] int NULL,
	[ActiveFlag] int NOT NULL,
	[DetailedDesc] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(7) NULL,
	[LND_UpdateDate] datetime2(7) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([VBRemovalReasonID] ASC), DISTRIBUTION = REPLICATE)
