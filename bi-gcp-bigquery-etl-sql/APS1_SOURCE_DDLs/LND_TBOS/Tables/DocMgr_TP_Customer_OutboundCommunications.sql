CREATE TABLE [DocMgr].[TP_Customer_OutboundCommunications]
(
	[OutboundCommunicationID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[DocumentType] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CommunicationDate] datetime2(3) NULL,
	[GeneratedDate] datetime2(3) NULL,
	[Description] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DocumentPath] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InitiatedBy] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[QueueID] bigint NULL,
	[IsDelivered] bit NULL,
	[PaymentID] bigint NULL,
	[DeliveryDate] datetime2(3) NULL,
	[ReadDate] datetime2(3) NULL,
	[GeneratedBy] int NULL,
	[FilePathConfigurationID] smallint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([OutboundCommunicationID] DESC), DISTRIBUTION = HASH([OutboundCommunicationID]))
