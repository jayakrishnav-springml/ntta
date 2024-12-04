CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Balance_History_Ct_Del (
    acct_id NUMERIC(29),
    status_date DATETIME,
    positive_balance STRING,
    insert_datetime DATETIME NOT NULL
);