CREATE TABLE [dbo].[nagios_serviceescalation_contacts]
(
	[serviceescalation_contact_id] int NULL,
	[instance_id] smallint NULL,
	[serviceescalation_id] int NULL,
	[contact_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([serviceescalation_contact_id]))
