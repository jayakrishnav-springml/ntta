CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Source_Code_Toll (
    source_code STRING NOT NULL,
    source_descr STRING NOT NULL,
    created_by STRING NOT NULL,
    created_date DATETIME NOT NULL,
    modified_by STRING,
    modified_date DATETIME,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
)
;