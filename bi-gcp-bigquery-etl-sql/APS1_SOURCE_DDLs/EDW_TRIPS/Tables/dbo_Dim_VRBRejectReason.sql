CREATE TABLE [dbo].[Dim_VRBRejectReason]
(
	[VRBRejectReasonID] int NOT NULL,
	[VRBRejectReasonCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VRBRejectReasonDescription] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ActiveFlag] int NOT NULL,
	[CreatedDate] datetime2(7) NULL,
	[LND_UpdateDate] datetime2(7) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([VRBRejectReasonID] ASC), DISTRIBUTION = REPLICATE)
