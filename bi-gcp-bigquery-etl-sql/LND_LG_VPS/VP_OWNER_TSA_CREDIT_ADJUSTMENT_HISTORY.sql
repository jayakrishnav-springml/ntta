CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Tsa_Credit_Adjustment_History (
    create_adj_history_id NUMERIC(29) NOT NULL,
    credit_adj_type STRING NOT NULL,
    credit_adj_date DATETIME NOT NULL,
    excused_reason STRING NOT NULL,
    adjusted_toll_amount NUMERIC(31, 2) NOT NULL,
    comments STRING,
    violation_id BIGNUMERIC(48, 10) NOT NULL,
    transaction_file_detail_id NUMERIC(29) NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME NOT NULL,
    modified_by STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
)
cluster by create_adj_history_id
;