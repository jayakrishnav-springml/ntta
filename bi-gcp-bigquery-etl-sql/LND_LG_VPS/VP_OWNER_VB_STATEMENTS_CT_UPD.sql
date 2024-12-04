CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Statements_Ct_Upd (
    vbs_statement_id NUMERIC(29) NOT NULL,
    vba_account_id NUMERIC(29),
    vbsb_batch_id NUMERIC(29),
    vbs_statement_date DATETIME,
    vbs_generation_date DATETIME,
    vbs_payment_due_date DATETIME,
    vbs_amount_due NUMERIC(31, 2),
    vbs_previous_balance NUMERIC(31, 2),
    vbs_unpaid_balance NUMERIC(31, 2),
    vbs_payments_total NUMERIC(31, 2),
    vbs_tolls_total NUMERIC(31, 2),
    vbs_inv_admin_fee_total NUMERIC(31, 2),
    vbs_inv_admin_fee2_total NUMERIC(31, 2),
    vbs_adjustments_total NUMERIC(31, 2),
    vbs_first_name STRING,
    vbs_last_name STRING,
    vbs_license_plate STRING,
    vbs_lic_plate_state STRING,
    vbs_vehicle_make STRING,
    vbs_vehicle_model STRING,
    vbs_vehicle_year STRING,
    vbs_addr_viol_id NUMERIC(29),
    vbs_addr_seq_id INT64,
    vbs_billing_period_start DATETIME,
    vbs_billing_period_end DATETIME,
    vbs_statement_status STRING,
    vbs_toll_tag_savings NUMERIC(31, 2),
    vbs_image_name STRING,
    vbs_image_path STRING,
    vbs_statement_notes STRING,
    date_created DATETIME,
    created_by STRING,
    date_modified DATETIME,
    modified_by STRING,
    vbs_first_name_2 STRING,
    vbs_last_name_2 STRING,
    vbs_unique_id NUMERIC(29),
    insert_datetime DATETIME NOT NULL
);