CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Aux_File_Config_Detail (
    aux_file_config_header_id NUMERIC(29) NOT NULL,
    aux_file_config_detail_id NUMERIC(29) NOT NULL,
    record_sequence INT64 NOT NULL,
    record_type STRING NOT NULL,
    field_sequence INT64 NOT NULL,
    field_type STRING NOT NULL,
    field_min_length INT64 NOT NULL,
    field_max_length INT64 NOT NULL,
    table_name STRING NOT NULL,
    column_name STRING NOT NULL,
    column_text STRING NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME NOT NULL,
    modified_by STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);