CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Statuses (
    acct_status_code STRING NOT NULL,
    acct_status_descr STRING NOT NULL,
    acct_status_long_descr STRING,
    acct_status_order INT64,
    default_value_flag STRING NOT NULL,
    active_flag STRING NOT NULL,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
);