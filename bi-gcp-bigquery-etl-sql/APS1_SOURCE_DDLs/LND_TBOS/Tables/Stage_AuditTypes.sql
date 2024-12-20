CREATE TABLE [Stage].[AuditTypes]
(
	[AuditID] bigint NOT NULL,
	[AuditType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AuditID] ASC), DISTRIBUTION = HASH([AuditID]))
