CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Accounts (
    vba_account_id NUMERIC(29) NOT NULL,
    violator_id NUMERIC(29) NOT NULL,
    vba_date DATETIME NOT NULL,
    next_invoice_date DATETIME,
    status STRING NOT NULL,
    date_created DATETIME,
    date_modified DATETIME,
    modified_by STRING,
    created_by STRING,
    uninvoiced_count INT64,
    oldest_uninvoiced DATETIME,
    next_generation_date DATETIME,
    reprint_date DATETIME,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
)
cluster by violator_id
;