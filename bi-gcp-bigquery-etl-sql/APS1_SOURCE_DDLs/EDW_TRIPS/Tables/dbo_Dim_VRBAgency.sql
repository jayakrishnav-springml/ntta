CREATE TABLE [dbo].[Dim_VRBAgency]
(
	[VRBAgencyID] int NOT NULL,
	[VRBAgencyCode] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VRBAgencyDescription] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ActiveFlag] int NULL,
	[CreatedDate] datetime2(7) NULL,
	[LND_UpdateDate] datetime2(7) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([VRBAgencyID] ASC), DISTRIBUTION = REPLICATE)
