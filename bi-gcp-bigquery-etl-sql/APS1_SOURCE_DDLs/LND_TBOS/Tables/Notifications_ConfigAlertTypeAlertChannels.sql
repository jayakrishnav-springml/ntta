CREATE TABLE [Notifications].[ConfigAlertTypeAlertChannels]
(
	[ConfigAlertTypeAlertChannelID] bigint NOT NULL,
	[AlertTypeID] int NULL,
	[AlertChannelID] int NULL,
	[TemplateID] int NULL,
	[TemplateQuery] varchar(2000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Sender] int NULL,
	[IsActive] bit NOT NULL,
	[ChargeToCustomer] decimal(9,2) NULL,
	[Remarks] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OrderNo] int NULL,
	[SourceTable] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TextMessage] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ConfigAlertTypeAlertChannelID] ASC), DISTRIBUTION = HASH([ConfigAlertTypeAlertChannelID]))
