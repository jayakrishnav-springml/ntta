CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Email_Addresses (
    address STRING NOT NULL,
    status STRING,
    status_date DATETIME,
    smtp_result STRING,
    sendmail_log STRING,
    status_count BIGNUMERIC(48, 10),
    last_success DATETIME,
    success_count BIGNUMERIC(48, 10),
    last_failure DATETIME,
    failure_count BIGNUMERIC(48, 10),
    valid STRING NOT NULL,
    date_created DATETIME,
    date_modified DATETIME,
    modified_by STRING,
    created_by STRING,
    last_update_date DATETIME,
    last_update_type STRING
);