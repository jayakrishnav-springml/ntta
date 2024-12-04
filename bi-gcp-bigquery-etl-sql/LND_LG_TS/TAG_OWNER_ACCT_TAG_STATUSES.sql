CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Acct_Tag_Statuses (
    acct_tag_status STRING NOT NULL,
    acct_tag_status_descr STRING,
    acct_tag_status_long_descr STRING,
    acct_tag_status_order INT64,
    default_value_flag STRING NOT NULL,
    active_flag STRING NOT NULL,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
);