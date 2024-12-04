CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Auth_Retailers (
    art_id INT64 NOT NULL,
    art_name STRING NOT NULL,
    art_type STRING,
    address1 STRING,
    address2 STRING,
    city STRING,
    state STRING NOT NULL,
    zip_code STRING,
    plus4 STRING,
    phone_nbr STRING,
    fax_nbr STRING,
    art_manager STRING,
    is_active STRING NOT NULL,
    agcy_id NUMERIC(29) NOT NULL,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
);