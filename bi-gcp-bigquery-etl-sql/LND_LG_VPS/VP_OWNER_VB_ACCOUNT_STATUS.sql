CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Account_Status (
    status STRING NOT NULL,
    description STRING NOT NULL,
    is_active STRING NOT NULL,
    is_closed STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);