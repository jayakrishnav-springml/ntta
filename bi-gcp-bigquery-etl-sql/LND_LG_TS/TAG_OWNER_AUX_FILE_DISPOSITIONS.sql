CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Aux_File_Dispositions (
    aux_file_disposition_code STRING NOT NULL,
    aux_file_disp_code_short_desc STRING NOT NULL,
    aux_file_disp_code_desc STRING NOT NULL,
    disposition_order INT64 NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME NOT NULL,
    modified_by STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);