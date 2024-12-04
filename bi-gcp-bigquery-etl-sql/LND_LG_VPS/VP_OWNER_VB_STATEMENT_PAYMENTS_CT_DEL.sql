CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Statement_Payments_Ct_Del (
    vbsp_statement_id NUMERIC(29),
    vbsp_activity_id NUMERIC(29),
    vbi_invoice_id NUMERIC(29),
    viol_invoice_id NUMERIC(29),
    violation_id NUMERIC(29),
    payment_line_item_id NUMERIC(29),
    vbsp_activity_date DATETIME,
    vbsp_activity_type STRING,
    vbsp_activity_amount NUMERIC(31, 2),
    vbsp_activity_amount_paid NUMERIC(31, 2),
    vbsp_activity_line_amount NUMERIC(31, 2),
    vbsp_activity_split_amount NUMERIC(31, 2),
    insert_datetime DATETIME NOT NULL
);