CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Balances (
    acct_id NUMERIC(29),
    balance_amt NUMERIC(31, 2),
    balance_date DATETIME,
    last_update_type STRING,
    last_update_date DATETIME
);