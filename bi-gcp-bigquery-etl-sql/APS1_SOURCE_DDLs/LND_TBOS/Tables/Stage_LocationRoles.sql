CREATE TABLE [Stage].[LocationRoles]
(
	[LocationRoleID] bigint NOT NULL,
	[LocationID] bigint NOT NULL,
	[RoleID] smallint NOT NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[IsActive] bit NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([LocationRoleID] DESC), DISTRIBUTION = HASH([LocationRoleID]))
