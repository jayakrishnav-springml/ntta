CREATE TABLE [dbo].[nagios_contacts_hist]
(
	[contact_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[contact_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([contact_id]))
