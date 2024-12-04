CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vb_Viol_Invoices_Ct_Del (
    vbi_vbi_invoice_id NUMERIC(29) NOT NULL,
    inv_viol_invoice_id NUMERIC(29) NOT NULL,
    date_created DATETIME,
    date_modified DATETIME,
    modified_by STRING,
    created_by STRING,
    insert_datetime DATETIME NOT NULL
);