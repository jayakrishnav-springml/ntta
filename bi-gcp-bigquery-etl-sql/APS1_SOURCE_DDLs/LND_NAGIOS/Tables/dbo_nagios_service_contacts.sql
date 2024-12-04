CREATE TABLE [dbo].[nagios_service_contacts]
(
	[service_contact_id] int NULL,
	[instance_id] smallint NULL,
	[service_id] int NULL,
	[contact_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([service_contact_id]))
