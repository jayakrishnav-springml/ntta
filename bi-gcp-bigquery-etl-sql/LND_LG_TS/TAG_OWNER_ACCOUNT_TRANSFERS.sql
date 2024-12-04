CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Transfers (
    atf_id INT64 NOT NULL,
    trans_acct_id NUMERIC(29) NOT NULL,
    recv_acct_id NUMERIC(29),
    accts_merged STRING NOT NULL,
    balance_amt_transfered NUMERIC(31, 2) NOT NULL,
    trans_retail_trans_id INT64 NOT NULL,
    recv_retail_trans_id INT64,
    date_created DATETIME,
    created_by STRING,
    date_modified DATETIME,
    modified_by STRING,
    last_update_date DATETIME,
    last_update_type STRING
);