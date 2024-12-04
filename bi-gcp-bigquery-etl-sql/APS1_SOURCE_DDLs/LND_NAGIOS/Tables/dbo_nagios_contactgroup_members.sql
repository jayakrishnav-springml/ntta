CREATE TABLE [dbo].[nagios_contactgroup_members]
(
	[contactgroup_member_id] int NULL,
	[instance_id] smallint NULL,
	[contactgroup_id] int NULL,
	[contact_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([contactgroup_member_id]))
