CREATE TABLE [Stage].[Plaza_Types]
(
	[PlazaTypeID] tinyint NOT NULL,
	[Description] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Note] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PlazaTypeID] ASC), DISTRIBUTION = HASH([PlazaTypeID]))
