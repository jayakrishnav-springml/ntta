-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_GL_POSTING_TABLE_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Gl_Posting_Table_Truncate
(
  q_name STRING,
  msgid BYTES NOT NULL,
  corrid STRING,
  priority BIGNUMERIC(48, 10),
  state BIGNUMERIC(48, 10),
  delay DATETIME,
  expiration BIGNUMERIC(48, 10),
  time_manager_info DATETIME,
  local_order_no BIGNUMERIC(48, 10),
  chain_no BIGNUMERIC(48, 10),
  cscn BIGNUMERIC(48, 10),
  dscn BIGNUMERIC(48, 10),
  enq_time DATETIME,
  enq_uid BIGNUMERIC(48, 10),
  enq_tid STRING,
  deq_time DATETIME,
  deq_uid BIGNUMERIC(48, 10),
  deq_tid STRING,
  retry_count BIGNUMERIC(48, 10),
  exception_qschema STRING,
  exception_queue STRING,
  step_no BIGNUMERIC(48, 10),
  recipient_key BIGNUMERIC(48, 10),
  dequeue_msgid BYTES,
  sender_name STRING,
  sender_address STRING,
  sender_protocol BIGNUMERIC(48, 10),
  last_update_date DATETIME,
  last_update_type STRING
)
;
