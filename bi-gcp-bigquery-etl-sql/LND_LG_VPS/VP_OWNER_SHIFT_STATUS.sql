CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Shift_Status (
    shift_status STRING NOT NULL,
    shift_status_descr STRING NOT NULL,
    shift_status_order INT64,
    is_active STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);