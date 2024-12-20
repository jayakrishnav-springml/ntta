CREATE TABLE [EIP].[Image_Storage_Paths]
(
	[PathID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AgencyCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[StorageType] int NOT NULL,
	[ImageType] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PathName] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VirtualPath] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[SharedPath] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(0) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PathID] ASC, [AgencyCode] ASC, [StorageType] ASC), DISTRIBUTION = HASH([AgencyCode]))
