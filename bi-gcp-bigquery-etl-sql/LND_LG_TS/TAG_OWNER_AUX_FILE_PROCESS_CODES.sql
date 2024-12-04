CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Aux_File_Process_Codes (
    aux_file_process_code STRING NOT NULL,
    aux_file_process_short_desc STRING NOT NULL,
    aux_file_process_desc STRING NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME NOT NULL,
    modified_by STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);