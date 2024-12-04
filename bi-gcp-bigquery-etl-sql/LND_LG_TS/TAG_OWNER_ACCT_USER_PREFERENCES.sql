CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Acct_User_Preferences (
    acct_user_pref_id NUMERIC(29) NOT NULL,
    user_pref_id NUMERIC(29) NOT NULL,
    acct_id NUMERIC(29) NOT NULL,
    up_value STRING NOT NULL,
    is_active STRING NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME,
    modified_by STRING,
    last_update_date DATETIME,
    last_update_type STRING
);