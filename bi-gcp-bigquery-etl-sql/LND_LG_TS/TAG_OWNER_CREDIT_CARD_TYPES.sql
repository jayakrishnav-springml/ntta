CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Credit_Card_Types (
    card_code STRING NOT NULL,
    card_name STRING,
    card_nbr_length INT64 NOT NULL,
    card_nbr_prefix STRING,
    card_type_order INT64,
    default_value_flag STRING NOT NULL,
    old_pmt_code STRING,
    active_flag STRING NOT NULL,
    validation_regex STRING,
    invalid_message STRING,
    last_update_type STRING,
    last_update_date DATETIME
);