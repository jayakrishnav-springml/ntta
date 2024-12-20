CREATE TABLE [Stage].[VRBRequestDMV]
(
	[VRBRequestDMVID] bigint NOT NULL,
	[VRBID] bigint NOT NULL,
	[FileID] bigint NULL,
	[County] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VIN] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DocumentNumber] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VRBRequestDMVID] ASC), DISTRIBUTION = HASH([VRBRequestDMVID]))
