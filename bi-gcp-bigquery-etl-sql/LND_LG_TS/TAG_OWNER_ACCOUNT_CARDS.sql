CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Cards (
    acct_card_seq INT64 NOT NULL,
    name_on_card STRING,
    card_expires DATETIME NOT NULL,
    address1 STRING NOT NULL,
    address2 STRING,
    city STRING NOT NULL,
    state STRING NOT NULL,
    zip_code STRING NOT NULL,
    plus4 STRING,
    date_applied DATETIME NOT NULL,
    date_withdrawn DATETIME,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME,
    modified_by STRING,
    acct_id NUMERIC(29) NOT NULL,
    card_status STRING NOT NULL,
    card_code STRING NOT NULL,
    payment_failed_flag STRING NOT NULL,
    payment_failed_date DATETIME,
    selected_for_update STRING,
    request_date DATETIME,
    request_file STRING,
    response_date DATETIME,
    response_code STRING,
    response_file STRING,
    last_update_type STRING,
    last_update_date DATETIME
);