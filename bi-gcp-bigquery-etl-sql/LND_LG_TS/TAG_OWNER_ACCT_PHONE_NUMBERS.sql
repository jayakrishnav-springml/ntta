CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Acct_Phone_Numbers (
    acct_id NUMERIC(29) NOT NULL,
    home_pho_nbr STRING,
    work_pho_nbr STRING,
    new_home_pho_nbr STRING,
    new_work_pho_nbr STRING,
    last_update_date DATETIME,
    last_update_type STRING
);