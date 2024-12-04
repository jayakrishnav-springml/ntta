CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Acct_Bal_History (
    acct_id NUMERIC(29) NOT NULL,
    acct_bal_seq NUMERIC(29) NOT NULL,
    old_bal_amt NUMERIC(31, 2),
    new_bal_amt NUMERIC(31, 2),
    old_dep_amt NUMERIC(31, 2),
    new_dep_amt NUMERIC(31, 2),
    bal_modified_date DATETIME NOT NULL,
    bal_modified_by STRING NOT NULL,
    acct_status_code STRING NOT NULL,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
);