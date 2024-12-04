CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Aux_Plate_Master_Xref (
    aux_plate_master_xref_id NUMERIC(29) NOT NULL,
    aux_agency_id NUMERIC(29) NOT NULL,
    aux_external_reference_id STRING,
    lic_plate_nbr STRING NOT NULL,
    lic_plate_state STRING NOT NULL,
    acct_id NUMERIC(29) NOT NULL,
    acct_tag_seq INT64 NOT NULL,
    acct_tag_status STRING NOT NULL,
    acct_tag_status_date DATETIME NOT NULL,
    aux_file_stage_header_id NUMERIC(29) NOT NULL,
    aux_file_stage_detail_id NUMERIC(29) NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME NOT NULL,
    modified_by STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);