CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Aux_Account_Master (
    aux_account_master_id NUMERIC(29) NOT NULL,
    acct_id NUMERIC(29) NOT NULL,
    aux_agency_id NUMERIC(29) NOT NULL,
    aux_master_account_ind STRING NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME NOT NULL,
    modified_by STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);