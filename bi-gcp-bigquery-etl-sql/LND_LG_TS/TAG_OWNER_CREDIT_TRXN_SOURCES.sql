CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Credit_Trxn_Sources (
    credit_source STRING NOT NULL,
    credit_source_descr STRING NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME,
    modified_by STRING,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
);