CREATE TABLE [dbo].[nagios_host_contacts]
(
	[host_contact_id] int NULL,
	[instance_id] smallint NULL,
	[host_id] int NULL,
	[contact_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([host_contact_id]))
