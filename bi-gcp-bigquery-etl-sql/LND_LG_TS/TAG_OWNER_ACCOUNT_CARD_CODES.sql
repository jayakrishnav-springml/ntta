CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Card_Codes (
    card_name STRING NOT NULL,
    card_code STRING NOT NULL,
    starts_with BIGNUMERIC(48, 10),
    card_code_status STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);