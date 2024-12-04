CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Account_Comments (
    comment_id INT64 NOT NULL,
    acct_comment STRING NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME,
    modified_by STRING,
    acct_id NUMERIC(29) NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);