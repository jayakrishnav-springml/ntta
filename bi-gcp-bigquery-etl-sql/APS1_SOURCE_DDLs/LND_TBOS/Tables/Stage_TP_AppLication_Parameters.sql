CREATE TABLE [Stage].[TP_AppLication_Parameters]
(
	[ParameterID] int NOT NULL,
	[ParameterKey] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParameterName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParameterValue] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ParameterDesc] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[MeasurementDesc] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ConfigType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DepartmentType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DataType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MinLength] int NULL,
	[MaxLength] int NULL,
	[AllowedSplChars] bit NULL,
	[IsSpaceAllowed] bit NULL,
	[RegularExp] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StartEffectiveDate] datetime2(3) NOT NULL,
	[EndEffectiveDate] datetime2(3) NOT NULL,
	[IsEditable] bit NOT NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[IsActive] bit NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ParameterID] DESC), DISTRIBUTION = HASH([ParameterID]))
