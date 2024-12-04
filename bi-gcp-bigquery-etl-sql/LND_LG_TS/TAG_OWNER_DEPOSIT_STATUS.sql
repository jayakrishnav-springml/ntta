CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Deposit_Status (
    deposit_status STRING NOT NULL,
    deposit_status_descr STRING NOT NULL,
    is_active STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);