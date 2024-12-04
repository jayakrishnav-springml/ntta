CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Invoice_Batches (
    vbb_batch_id NUMERIC(29) NOT NULL,
    date_produced DATETIME NOT NULL,
    vb_invoice_count INT64 NOT NULL,
    date_printed DATETIME,
    date_mailed DATETIME,
    date_created DATETIME,
    date_modified DATETIME,
    modified_by STRING,
    created_by STRING,
    due_date DATETIME,
    vb_inv_batch_type_code STRING NOT NULL,
    vb_ln_count INT64,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
)
cluster by vbb_batch_id
;