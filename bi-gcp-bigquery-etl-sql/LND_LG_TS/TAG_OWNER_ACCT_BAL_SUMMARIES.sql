CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Acct_Bal_Summaries (
    bal_date DATETIME NOT NULL,
    total_balance NUMERIC(31, 2) NOT NULL,
    total_deposit NUMERIC(31, 2) NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME NOT NULL,
    modified_by STRING NOT NULL,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
);