CREATE TABLE IF NOT EXISTS LND_LG_TS.Fpl_Owner_Plaza_Groups (
    agcy_agcy_id NUMERIC(29) NOT NULL,
    plgp_id INT64 NOT NULL,
    plgp_desc STRING,
    lc_plaza_nbr INT64,
    descr STRING,
    location_code STRING,
    user_code STRING,
    has_lanes STRING NOT NULL,
    has_deposits STRING NOT NULL,
    abbrev STRING,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
)
cluster by plgp_id
;