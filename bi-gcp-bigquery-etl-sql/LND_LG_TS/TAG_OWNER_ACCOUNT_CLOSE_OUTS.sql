CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Close_Outs (
    acct_id NUMERIC(29) NOT NULL,
    close_out_type STRING NOT NULL,
    close_out_status STRING NOT NULL,
    close_out_date DATETIME,
    close_out_eligibility_date DATETIME,
    original_deposit NUMERIC(31, 2) NOT NULL,
    end_deposit NUMERIC(31, 2) NOT NULL,
    original_balance NUMERIC(31, 2) NOT NULL,
    end_balance NUMERIC(31, 2) NOT NULL,
    deposit_escheatment NUMERIC(31, 2) NOT NULL,
    balance_escheatment NUMERIC(31, 2) NOT NULL,
    last_activity_date DATETIME NOT NULL,
    retail_trans_id NUMERIC(29),
    last_update_date DATETIME,
    last_update_type STRING
);