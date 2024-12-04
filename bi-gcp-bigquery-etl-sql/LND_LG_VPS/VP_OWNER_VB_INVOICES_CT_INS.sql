CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Invoices_Ct_Ins (
    vbi_invoice_id NUMERIC(29) NOT NULL,
    vbi_account_id NUMERIC(29) NOT NULL,
    vbi_status STRING NOT NULL,
    vbb_batch_id NUMERIC(29) NOT NULL,
    violator_id NUMERIC(29) NOT NULL,
    violator_addr_seq INT64 NOT NULL,
    invoice_date DATETIME NOT NULL,
    invoice_amount NUMERIC(33, 4) NOT NULL,
    toll_amount NUMERIC(33, 4) NOT NULL,
    late_fee_amount NUMERIC(33, 4) NOT NULL,
    mail_fee_amount NUMERIC(33, 4) NOT NULL,
    past_due_amount NUMERIC(33, 4) NOT NULL,
    invoice_amt_disc NUMERIC(33, 4),
    invoice_amt_paid NUMERIC(33, 4),
    due_date DATETIME NOT NULL,
    inv_closed_date DATETIME,
    mail_return_date DATETIME,
    excused_by STRING,
    date_excused DATETIME,
    excused_reason STRING,
    remailed STRING,
    late_fee_generating_invoice NUMERIC(29),
    date_created DATETIME,
    date_modified DATETIME,
    modified_by STRING,
    created_by STRING,
    past_due_late_fee_amount NUMERIC(33, 4) NOT NULL,
    past_due_mail_fee_amount NUMERIC(33, 4) NOT NULL,
    waived_late_fee_by STRING,
    waived_late_fee_date DATETIME,
    vbb_ln_batch_id NUMERIC(29),
    invoice_location STRING,
    late_notice_location STRING,
    orig_due_date DATETIME,
    conversion_date DATETIME,
    source_code STRING,
    insert_datetime DATETIME NOT NULL
);