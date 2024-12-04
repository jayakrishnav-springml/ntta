CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Invoice_Viol_Jn (
    jn_operation STRING,
    jn_oracle_user STRING,
    jn_datetime DATETIME,
    jn_notes STRING,
    jn_appln STRING,
    vbi_invoice_id NUMERIC(29),
    violation_id FLOAT64,
    toll_due NUMERIC(31, 2),
    viol_status STRING,
    image_selectable STRING,
    created_by STRING,
    date_created DATETIME,
    modified_by STRING,
    date_modified DATETIME,
    det_link_id NUMERIC(29),
    last_update_type STRING,
    last_update_date DATETIME
);