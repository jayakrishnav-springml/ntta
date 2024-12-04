## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VIOL_REJECT_TYPE_REVIEW_STATUS_IMAGE_QUALITY_RPT_XREF.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Viol_Reject_Type_Review_Status_Image_Quality_Rpt_Xref
(
  viol_reject_type STRING NOT NULL,
  viol_reject_type_descr STRING NOT NULL,
  review_status STRING NOT NULL,
  rev_status_descr STRING NOT NULL,
  b_all_image_count INT64 NOT NULL,
  c_ocr_failed INT64 NOT NULL,
  d_rejected_manual_review INT64 NOT NULL,
  f_rejected_paper_plate INT64 NOT NULL,
  g_plate_obstruction INT64 NOT NULL,
  h_no_plate INT64 NOT NULL,
  i_not_reviewed INT64 NOT NULL,
  j_incomplete_image INT64 NOT NULL,
  k_black_image INT64 NOT NULL,
  l_no_roi INT64 NOT NULL,
  m_unclear_image INT64 NOT NULL,
  n_unknown_state INT64 NOT NULL,
  q_ocr_passed INT64 NOT NULL,
  s_reviewed_and_edited INT64 NOT NULL,
  t_reviewed_no_edit INT64 NOT NULL,
  y_first_responder INT64 NOT NULL,
  z_out_of_country INT64 NOT NULL,
  aa_government_plate INT64 NOT NULL,
  ab_class_mismatch INT64 NOT NULL,
  ac_not_reviewed INT64 NOT NULL
)
;
