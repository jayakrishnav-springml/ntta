CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Shifts (
    shift_id INT64 NOT NULL,
    ap_user_id INT64 NOT NULL,
    shift_start DATETIME NOT NULL,
    shift_end DATETIME,
    cash_opn_bal NUMERIC(33, 4),
    cash_cls_bal NUMERIC(33, 4),
    cash_adj_amt NUMERIC(33, 4),
    chk_cls_bal NUMERIC(33, 4),
    cc_cls_bal NUMERIC(33, 4),
    phone_calls INT64,
    walk_in_customers INT64,
    toll_tag_updates INT64,
    adj_rsn STRING,
    deposit_status STRING NOT NULL,
    bank_deposit_id INT64,
    shift_status STRING NOT NULL,
    chk_mo_adj_amt NUMERIC(33, 4),
    cc_adj_amt NUMERIC(33, 4),
    vpc_loc_id INT64 NOT NULL,
    pos_id INT64 NOT NULL,
    deposit_date DATETIME,
    created_by STRING,
    attribute_1 STRING,
    date_created DATETIME NOT NULL,
    modified_by STRING,
    date_modified DATETIME,
    deposit_business_date DATETIME,
    last_update_type STRING NOT NULL,
    last_update_date DATETIME NOT NULL
)
cluster by shift_id
;