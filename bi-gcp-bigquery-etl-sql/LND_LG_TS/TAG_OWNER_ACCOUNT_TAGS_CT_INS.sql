CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Tags_Ct_Ins (
    acct_tag_seq INT64 NOT NULL,
    acct_id NUMERIC(29) NOT NULL,
    agency_id STRING NOT NULL,
    tag_id STRING NOT NULL,
    acct_tag_status STRING NOT NULL,
    lic_plate STRING,
    lic_state STRING,
    lic_plate_tag STRING NOT NULL,
    vehicle_descr STRING,
    vehicle_make STRING,
    vehicle_model STRING,
    vehicle_year STRING,
    vehicle_color STRING,
    vehicle_class_code STRING NOT NULL,
    assigned_date DATETIME,
    expir_date DATETIME,
    tag_read_ct INT64,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME,
    modified_by STRING,
    vpn_id INT64,
    unit_id STRING,
    temp_plate_flag STRING,
    plate_expir_date DATETIME,
    dup_lp_date_send DATETIME,
    insert_datetime DATETIME NOT NULL
);