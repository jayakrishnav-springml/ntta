CREATE TABLE [dbo].[nagios_hostescalation_contacts]
(
	[hostescalation_contact_id] int NULL,
	[instance_id] smallint NULL,
	[hostescalation_id] int NULL,
	[contact_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([hostescalation_contact_id]))
