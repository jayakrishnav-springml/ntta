CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Transaction_Types (
    transaction_type STRING NOT NULL,
    transaction_type_descr STRING NOT NULL,
    transaction_type_comment STRING,
    rule_count NUMERIC(29) NOT NULL,
    is_active STRING NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    modified_by STRING,
    date_modified DATETIME,
    transaction_type_descr2 STRING,
    last_update_date DATETIME,
    last_update_type STRING
)
;