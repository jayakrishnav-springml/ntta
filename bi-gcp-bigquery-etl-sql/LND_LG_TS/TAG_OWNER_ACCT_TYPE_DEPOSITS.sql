CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Acct_Type_Deposits (
    deposit_id INT64 NOT NULL,
    deposit_amt NUMERIC(31, 2) NOT NULL,
    lp_deposit_amt NUMERIC(31, 2),
    tags_per_deposit INT64 NOT NULL,
    max_deposit_amt NUMERIC(31, 2),
    low_balance NUMERIC(31, 2),
    tags_per_low_balance INT64,
    tag_charge NUMERIC(31, 2),
    tags_per_charge INT64,
    effective_date DATETIME NOT NULL,
    expiration_date DATETIME NOT NULL,
    active_flag STRING NOT NULL,
    acct_type_code STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);