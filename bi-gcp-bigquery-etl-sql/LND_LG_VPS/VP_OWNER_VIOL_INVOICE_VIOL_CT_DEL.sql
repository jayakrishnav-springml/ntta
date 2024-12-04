CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Viol_Invoice_Viol_Ct_Del (
    violation_id NUMERIC(29) NOT NULL,
    viol_invoice_id NUMERIC(29) NOT NULL,
    fine_amount NUMERIC(33, 4) NOT NULL,
    toll_due_amount NUMERIC(33, 4) NOT NULL,
    viol_inv_status STRING NOT NULL,
    date_created DATETIME NOT NULL,
    created_by STRING NOT NULL,
    date_modified DATETIME,
    modified_by STRING,
    viol_status STRING NOT NULL,
    gl_status STRING NOT NULL,
    close_out_date DATETIME,
    insert_datetime DATETIME NOT NULL
);