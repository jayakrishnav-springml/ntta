CREATE TABLE [dbo].[nagios_hostgroup_members_STAGE]
(
	[hostgroup_member_id] int NULL,
	[instance_id] smallint NULL,
	[hostgroup_id] int NULL,
	[host_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([hostgroup_member_id]))
