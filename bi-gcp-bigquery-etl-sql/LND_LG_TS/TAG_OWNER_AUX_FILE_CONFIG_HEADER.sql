CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Aux_File_Config_Header (
    aux_agency_id NUMERIC(29) NOT NULL,
    aux_file_config_header_id NUMERIC(29) NOT NULL,
    file_type STRING NOT NULL,
    delimiter STRING,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME NOT NULL,
    modified_by STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);