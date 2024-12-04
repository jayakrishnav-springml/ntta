## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_REL_FinalStage_GROUP_TO_FinalStage.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Rel_Finalstage_Group_To_Finalstage
(
  finalstage STRING NOT NULL,
  finalstage_group STRING NOT NULL
)
;
