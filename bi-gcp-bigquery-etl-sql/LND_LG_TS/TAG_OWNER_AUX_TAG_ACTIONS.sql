CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Aux_Tag_Actions (
    aux_tag_action_code STRING NOT NULL,
    aux_tag_action_code_short_desc STRING NOT NULL,
    aux_tag_action_code_desc STRING NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME NOT NULL,
    modified_by STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);