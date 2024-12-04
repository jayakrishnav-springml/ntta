-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_MAIL_FILE_DETAILS_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Mail_File_Details_Ct_Upd
(
  mail_file_header_id BIGNUMERIC(38) NOT NULL,
  mail_file_detail_id BIGNUMERIC(38) NOT NULL,
  statement_id BIGNUMERIC(38),
  account_id BIGNUMERIC(38),
  org_next_generation_date DATETIME,
  pushed_next_generation_date DATETIME,
  processed_date DATETIME,
  status_code STRING NOT NULL,
  statement_type STRING,
  statement_date DATETIME,
  print_rej_date DATETIME,
  print_ind STRING,
  comments STRING,
  nxi STRING,
  ank STRING,
  reprint STRING,
  mail_date DATETIME,
  ms_unique_id BIGNUMERIC(38),
  line_comment STRING NOT NULL,
  date_created DATETIME NOT NULL,
  insert_datetime DATETIME NOT NULL
)
;
