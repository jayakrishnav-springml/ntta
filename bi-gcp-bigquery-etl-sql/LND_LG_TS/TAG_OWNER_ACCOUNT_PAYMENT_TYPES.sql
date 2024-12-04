CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Payment_Types (
    pmt_type_code STRING NOT NULL,
    pmt_type_descr STRING NOT NULL,
    pmt_type_order INT64,
    default_value_flag STRING NOT NULL,
    active_flag STRING NOT NULL,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
);