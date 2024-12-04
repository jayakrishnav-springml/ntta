CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Device_Types (
    device_type STRING NOT NULL,
    description STRING NOT NULL,
    is_active STRING NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME,
    modified_by STRING,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
);