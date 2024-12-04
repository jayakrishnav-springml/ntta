CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Inv_Status (
    status STRING NOT NULL,
    description STRING,
    is_active STRING,
    is_closed STRING NOT NULL,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
)
;