CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Lanes (
    vbl_id NUMERIC(29) NOT NULL,
    lane_id NUMERIC(29) NOT NULL,
    vbl_start DATETIME NOT NULL,
    vbl_end DATETIME,
    date_created DATETIME,
    date_modified DATETIME,
    modified_by STRING,
    created_by STRING,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
)
cluster by vbl_id
;