CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Aux_Agencies (
    aux_agency_id NUMERIC(29) NOT NULL,
    aux_agency_desc STRING NOT NULL,
    aux_agency_abbrev STRING NOT NULL,
    tag_start_param_name STRING NOT NULL,
    tag_end_param_name STRING NOT NULL,
    tags_per_acct_param_name STRING NOT NULL,
    inbound_plate_file_app STRING NOT NULL,
    outbound_excp_file_app STRING NOT NULL,
    outbound_trxn_file_app STRING NOT NULL,
    low_tag_threshold NUMERIC(29) NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME NOT NULL,
    modified_by STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);