CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Adjustment_Reasons (
    adj_rsn STRING NOT NULL,
    adj_rsn_desc STRING NOT NULL,
    adj_rsn_order INT64,
    is_active STRING NOT NULL,
    comments STRING,
    last_update_date DATETIME,
    last_update_type STRING
);