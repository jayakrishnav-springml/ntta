CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Devices_Ct_Ins (
    acct_device_id NUMERIC(29),
    device_type STRING,
    acct_id NUMERIC(29),
    device_value STRING,
    precedence_level INT64,
    is_active STRING,
    date_created DATETIME,
    created_by STRING,
    date_modified DATETIME,
    modified_by STRING,
    insert_datetime DATETIME NOT NULL
);