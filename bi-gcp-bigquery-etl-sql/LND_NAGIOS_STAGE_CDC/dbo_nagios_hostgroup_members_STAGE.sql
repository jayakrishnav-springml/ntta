-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_hostgroup_members_STAGE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS_STAGE_CDC.Nagios_HostGroup_Members
(
  hostgroup_member_id INT64,
  instance_id INT64,
  hostgroup_id INT64,
  host_object_id INT64,
  lnd_updatedate DATETIME NOT NULL
)
;

/*alter for CDC changes*/

ALTER TABLE LND_NAGIOS_STAGE_CDC.Nagios_HostGroup_Members ADD COLUMN IF NOT EXISTS lnd_updatetype STRING, ADD COLUMN IF NOT EXISTS src_changedate DATETIME;

