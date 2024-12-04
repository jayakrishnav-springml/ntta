CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Close_Out_Statuses (
    close_out_status STRING NOT NULL,
    close_out_status_descr STRING NOT NULL,
    close_out_status_long_descr STRING NOT NULL,
    close_out_status_order INT64 NOT NULL,
    default_value_flag STRING NOT NULL,
    last_update_date DATETIME,
    last_update_type STRING
);