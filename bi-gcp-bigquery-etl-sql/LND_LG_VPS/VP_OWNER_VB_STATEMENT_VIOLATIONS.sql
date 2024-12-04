CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Statement_Violations (
    vbsv_statement_id NUMERIC(29),
    vbi_invoice_id NUMERIC(29),
    viol_invoice_id NUMERIC(29),
    violation_id NUMERIC(29),
    viol_date DATETIME,
    lane_name STRING,
    lane_description STRING,
    vbsv_sv_amount_due NUMERIC(31, 2),
    vbsv_sv_amount_paid NUMERIC(31, 2),
    vbsv_violation_status STRING,
    vbsv_ntta_ind STRING,
    vbsv_discount_code STRING,
    vbsv_txn_fee NUMERIC(31, 2),
    ocr_nbr_confid NUMERIC(31, 2),
    post_date DATETIME,
    paid_indicator STRING,
    last_update_type STRING,
    last_update_date DATETIME
)
cluster by vbsv_statement_id,violation_id,viol_invoice_id,vbi_invoice_id
;