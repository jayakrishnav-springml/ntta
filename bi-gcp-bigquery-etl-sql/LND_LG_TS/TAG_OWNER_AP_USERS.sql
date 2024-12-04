CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Ap_Users (
    ap_user_id INT64 NOT NULL,
    display_name STRING NOT NULL,
    user_name STRING NOT NULL,
    employee_number NUMERIC(29),
    created_by STRING NOT NULL,
    date_created DATETIME NOT NULL,
    modified_by STRING,
    date_modified DATETIME,
    password STRING,
    email_address STRING,
    working_pos_id INT64,
    restricted STRING NOT NULL,
    status STRING NOT NULL,
    last_login_timestamp DATETIME,
    last_update_type STRING,
    last_update_date DATETIME
);