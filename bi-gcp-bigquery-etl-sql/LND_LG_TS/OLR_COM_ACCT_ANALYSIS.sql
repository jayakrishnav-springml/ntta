CREATE TABLE IF NOT EXISTS LND_LG_TS.Olr_Com_Acct_Analysis (
    acct_id BIGNUMERIC(48, 10) NOT NULL,
    date_created DATETIME,
    tollmate BIGNUMERIC(48, 10),
    tollperks BIGNUMERIC(48, 10),
    acct_status STRING,
    last_update_type STRING,
    last_update_date DATETIME
);