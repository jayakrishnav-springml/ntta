CREATE TABLE [dbo].[nagios_contact_addresses]
(
	[contact_address_id] int NULL,
	[instance_id] smallint NULL,
	[contact_id] int NULL,
	[address_number] smallint NULL,
	[address] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([contact_address_id]))
