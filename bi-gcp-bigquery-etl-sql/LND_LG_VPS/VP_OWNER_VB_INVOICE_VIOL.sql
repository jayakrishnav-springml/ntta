CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Invoice_Viol (
    vbi_invoice_id NUMERIC(29) NOT NULL,
    violation_id NUMERIC(29) NOT NULL,
    toll_due NUMERIC(33, 4) NOT NULL,
    date_created DATETIME,
    date_modified DATETIME,
    modified_by STRING,
    created_by STRING,
    image_selectable STRING,
    viol_status STRING,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
)
cluster by violation_id,vbi_invoice_id
;