CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Types (
    acct_type_code STRING NOT NULL,
    acct_type_descr STRING NOT NULL,
    acct_type_long_descr STRING,
    acct_type_order INT64,
    default_value_flag STRING NOT NULL,
    revenue_flag STRING NOT NULL,
    active_flag STRING NOT NULL,
    is_interop_allowed STRING,
    is_personal STRING,
    toll_posting_order INT64,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
);