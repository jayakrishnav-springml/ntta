CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Cc_Processor_Details (
    cc_proc_det_id INT64 NOT NULL,
    cc_proc_id INT64 NOT NULL,
    merchant_id STRING NOT NULL,
    card_code STRING NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME,
    modified_by STRING,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
)
cluster by cc_proc_det_id
;