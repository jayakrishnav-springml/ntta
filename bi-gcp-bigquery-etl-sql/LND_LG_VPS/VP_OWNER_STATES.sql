CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_States (
    state_code STRING NOT NULL,
    state_name STRING,
    country_code STRING,
    last_update_date DATETIME,
    last_update_type STRING
);