CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Balance_History (
    acct_id NUMERIC(29),
    status_date DATETIME,
    positive_balance STRING,
    last_update_type STRING,
    last_update_date DATETIME
);