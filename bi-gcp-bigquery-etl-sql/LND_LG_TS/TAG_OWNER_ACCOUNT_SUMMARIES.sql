CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Summaries (
    acct_status_code STRING NOT NULL,
    as_date DATETIME NOT NULL,
    as_total INT64 NOT NULL,
    as_total_balance NUMERIC(31, 2),
    as_total_deposit NUMERIC(31, 2),
    acct_type_code STRING NOT NULL,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
);