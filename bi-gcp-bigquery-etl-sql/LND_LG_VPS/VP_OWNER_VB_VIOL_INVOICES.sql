CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Viol_Invoices (
    vbi_vbi_invoice_id NUMERIC(29) NOT NULL,
    inv_viol_invoice_id NUMERIC(29) NOT NULL,
    date_created DATETIME,
    date_modified DATETIME,
    modified_by STRING,
    created_by STRING,
    last_update_type STRING,
    last_update_date DATETIME
)
cluster by vbi_vbi_invoice_id,inv_viol_invoice_id
;