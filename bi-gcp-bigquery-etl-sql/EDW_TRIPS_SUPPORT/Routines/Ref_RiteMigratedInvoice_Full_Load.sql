CREATE OR REPLACE PROCEDURE `EDW_TRIPS_SUPPORT.RiteMigratedInvoice_Full_Load`()
BEGIN
/*
########################################################################################################################
Proc Description: 
------------------------------------------------------------------------------------------------------------------------
========================================================================================================================
Change Log:
------------------------------------------------------------------------------------------------------------------------
CHG0042443	Gouthami		2023-02-09	New!
									  1) This Ref table is created using Fact_Invoice_Analysis table from RITE Database.
									  2) Migrated data for Item 90 is brought from RITE inorder to get the appropriate 
										 data for current Item 90 report. As TRIPS did not migrate the data properly for
										 all the invoices, this approach has been used.
									  3) Some of the case statements in this stored procedure is used from old Item 90
										 report.
									  4) First temp table #ViolNoVBI is created for the invoices which does not have 
										 VI Invoice ID prior to 2012 invoices.
																			 
========================================================================================================================
------------------------------------------------------------------------------------------------------------------------
EXEC [Ref].[RiteMigratedInvoice_Full_Load] 
########################################################################################################################
*/

    -- DROP TABLE IF EXISTS __cw_local_tmp_violnovbi;
    CREATE OR REPLACE TEMPORARY TABLE _SESSION.ViolNoVBI
      AS
        SELECT
            CASE
              WHEN invan.viol_invoice_id = -1 THEN invan.vbi_invoice_id
              ELSE invan.viol_invoice_id
            END AS invoicenumber,
            invan.vbi_invoice_id,
            invan.viol_invoice_id,
            CASE
              WHEN invsta.invoice_status_descr_sum_group = 'ReAsgn_UnAsgn' THEN 'DismissedUnassigned'
              WHEN invsta.invoice_status_descr_sum_group = 'Paid-VToll' THEN 'DismissedVtolled'
              WHEN invan.viol_inv_status IN(
                'L', 'V'
              )
               AND invsta.invoice_status_descr_sum_group IS NULL THEN 'DismissedUnassigned'
              WHEN invan.vbi_status IN(
                'L', 'V'
              )
               AND invsta.invoice_status_descr_sum_group IS NULL THEN 'DismissedUnassigned'
              ELSE invsta.invoice_status_descr_sum_group
            END AS invoicestatus,
            CASE
               invan.invoice_stage_id
              WHEN 1 THEN 1 -- ZipCash
              WHEN 2 THEN 2 -- First Notice
              WHEN 6 THEN 3 -- Second Notice
              WHEN 7 THEN 4 -- Third Notice
              WHEN 4 THEN 5 -- Legal Action Pending
              WHEN 3 THEN 6 -- Citation Issued
              ELSE -1
            END AS agestageid,
            CASE
              WHEN CASE
                WHEN invsta.invoice_status_descr_sum_group = 'ReAsgn_UnAsgn' THEN 'DismissedUnassigned'
                WHEN invsta.invoice_status_descr_sum_group = 'Paid-VToll' THEN 'DismissedVtolled'
                WHEN invan.viol_inv_status IN(
                  'L', 'V'
                )
                 AND invsta.invoice_status_descr_sum_group IS NULL THEN 'DismissedUnassigned'
                WHEN invan.vbi_status IN(
                  'L', 'V'
                )
                 AND invsta.invoice_status_descr_sum_group IS NULL THEN 'DismissedUnassigned'
                ELSE invsta.invoice_status_descr_sum_group
              END = 'DismissedUnassigned' THEN 0
              ELSE coalesce(amt_paid, 0)
            END AS paidamount,
            coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0) AS fnfees,
            coalesce(invan.vi_late_fees, 0) + coalesce(admin_fee2, 0) AS snfees,                           -- Need to check.
            coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0) + coalesce(invan.vi_late_fees, 0) + coalesce(admin_fee2, 0) AS feesdue,
            toll_due + zi_late_fees + admin_fee + vi_late_fees + admin_fee2 AS expectedamount,
            row_number() OVER (PARTITION BY invan.vbi_invoice_id ORDER BY invan.viol_invoice_id DESC) AS rn -- SELECT *
          FROM
            EDW_RITE.Fact_Invoice_Analysis AS invan
            INNER JOIN EDW_RITE.Dim_Invoice_Status AS invsta ON invan.vbi_status = invsta.vbi_status
             AND invan.viol_inv_status = invsta.viol_inv_status
             AND invan.zi_stage_id = invsta.zi_stage_id
          WHERE partition_date = '2021-01-01'
           AND viol_invoice_id <> -1
           AND vbi_invoice_id = -1
           AND converted_date <= '2012-01-01'
    ;
    
    -- DROP TABLE IF EXISTS __cw_local_tmp_viol;
    CREATE OR REPLACE TEMPORARY TABLE _SESSION.Viol
      AS
        SELECT
            a.*
          FROM
            (
              SELECT
                  CASE
                    WHEN invan.viol_invoice_id = -1 THEN invan.vbi_invoice_id
                    ELSE invan.viol_invoice_id
                  END AS invoicenumber,
                  invan.vbi_invoice_id,
                  invan.viol_invoice_id,
                  CASE
                    WHEN invsta.invoice_status_descr_sum_group = 'ReAsgn_UnAsgn' THEN 'DismissedUnassigned'
                    WHEN invsta.invoice_status_descr_sum_group = 'Paid-VToll' THEN 'DismissedVtolled'
                    WHEN invan.viol_inv_status IN(
                      'L', 'V'
                    )
                     AND invsta.invoice_status_descr_sum_group IS NULL THEN 'DismissedUnassigned'
                    WHEN invan.vbi_status IN(
                      'L', 'V'
                    )
                     AND invsta.invoice_status_descr_sum_group IS NULL THEN 'DismissedUnassigned'
                    ELSE invsta.invoice_status_descr_sum_group
                  END AS invoicestatus,
                  CASE
                     invan.invoice_stage_id
                    WHEN 1 THEN 1 -- ZipCash
                    WHEN 2 THEN 2 -- First Notice
                    WHEN 6 THEN 3 -- Second Notice
                    WHEN 7 THEN 4 -- Third Notice
                    WHEN 4 THEN 5 -- Legal Action Pending
                    WHEN 3 THEN 6 -- Citation Issued
                    ELSE -1
                  END AS agestageid,
                  CASE
                    WHEN CASE
                      WHEN invsta.invoice_status_descr_sum_group = 'ReAsgn_UnAsgn' THEN 'DismissedUnassigned'
                      WHEN invsta.invoice_status_descr_sum_group = 'Paid-VToll' THEN 'DismissedVtolled'
                      WHEN invan.viol_inv_status IN(
                        'L', 'V'
                      )
                       AND invsta.invoice_status_descr_sum_group IS NULL THEN 'DismissedUnassigned'
                      WHEN invan.vbi_status IN(
                        'L', 'V'
                      )
                       AND invsta.invoice_status_descr_sum_group IS NULL THEN 'DismissedUnassigned'
                      ELSE invsta.invoice_status_descr_sum_group
                    END = 'DismissedUnassigned' THEN 0
                    ELSE coalesce(amt_paid, 0)
                  END AS paidamount,
                  coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0) AS fnfees,
                  coalesce(invan.vi_late_fees, 0) + coalesce(admin_fee2, 0) AS snfees,                        -- Need to check.
                  coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0) + coalesce(invan.vi_late_fees, 0) + coalesce(admin_fee2, 0) AS feesdue,
                  toll_due + zi_late_fees + admin_fee + vi_late_fees + admin_fee2 AS expectedamount,
                  row_number() OVER (PARTITION BY invan.vbi_invoice_id ORDER BY invan.viol_invoice_id DESC) AS rn -- SELECT *
                FROM
                  EDW_RITE.Fact_Invoice_Analysis AS invan
                  INNER JOIN EDW_RITE.Dim_Invoice_Status AS invsta ON invan.vbi_status = invsta.vbi_status
                   AND invan.viol_inv_status = invsta.viol_inv_status
                   AND invan.zi_stage_id = invsta.zi_stage_id
                WHERE partition_date = '2021-01-01' -- Use the latest Item-90 shapshot. 2021-01-01 is the partition_date for the last RITE item-90
                 AND vbi_invoice_id <> -1
            ) AS a
          WHERE a.rn = 1
        UNION DISTINCT
        SELECT
            `#violnovbi`.*
          FROM
            _SESSION.ViolNoVBI AS `#violnovbi`
    ;
    
    -- DROP TABLE IF EXISTS __cw_local_tmp_dates;
    CREATE OR REPLACE TEMPORARY TABLE _SESSION.Dates
      AS
        SELECT
            cav.viol_invoice_id,
            max(ca.mail_date) AS mail_date,
            max(ca.court_date) AS court_date
          FROM
            LND_LG_VPS.Vp_Owner_Court_Act_Viol AS cav
            INNER JOIN LND_LG_VPS.Vp_Owner_Court_Actions AS ca ON ca.court_action_id = cav.court_action_id
          GROUP BY cav.viol_invoice_id
    ;
    

    -- DROP TABLE IF EXISTS __cw_local_tmp_thirdnoticedate;
    CREATE OR REPLACE TEMPORARY TABLE _SESSION.ThirdNoticeDate
      AS
        SELECT
            cai.viol_invoice_id,
            min(ca.file_gen_date) AS thirdnoticedate
          FROM
            LND_LG_VPS.Vp_Owner_Ca_Acct_Inv_Xref AS cai
            INNER JOIN LND_LG_VPS.Vp_Owner_Ca_Accts AS ca ON ca.ca_acct_id = cai.ca_acct_id
   --where    viol_invoice_id = 810368980
          GROUP BY cai.viol_invoice_id
    ;
    
    --DROP TABLE IF EXISTS __cw_local_tmp_legalactionpendingdate;
    CREATE OR REPLACE TEMPORARY TABLE _SESSION.LegalActionPendingDate
      AS
        SELECT
            viol_invoices.viol_invoice_id,
            viol_invoices.status_date,
            viol_invoices.viol_inv_status
          FROM
            EDW_RITE.Viol_Invoices
          WHERE viol_invoices.viol_inv_status = 'D'
    ;
    
    --DROP TABLE IF EXISTS ref.ritemigratedinvoice;
    CREATE OR REPLACE TABLE EDW_TRIPS_SUPPORT.RiteMigratedInvoice  --98687304
      AS
--declare @InvoiceNumber int = 747739677 --506591578
        WITH aaa AS (
          SELECT
              viol.invoicenumber,
              NULL AS firstinvoiceid,
              NULL AS currentinvoiceid,
              coalesce(invan.violator_id, -1) AS customerid,
              CASE
                WHEN viol.agestageid = 4
                 AND vi.viol_inv_status = 'D' THEN 5
                ELSE viol.agestageid
              END AS agestageid,
              NULL AS collectionstatusid,                                                        -- not availabnle in fact_analysis,
              NULL AS currmbsid,
              coalesce(ih.vehicleid, -1) AS vehicleid,
              viol8.lic_plate_nbr AS lic_plate_nbr,
              viol8.lic_plate_state AS lic_plate_state,
              1 AS migratedflag,
              viol.invoicestatus,
              invs.invoicestatusid AS edw_invoicestatusid,
              --- Dates
              invan.vb_inv_date AS zipcashdate,
              CASE
                WHEN invan.invoice_stage_id IN(
                  2, 6, 7, 4, 3
                ) THEN date_add(invan.vb_inv_date, interval 1 MONTH)
              END AS firstnoticedate,                                                             -- get from rite landing tables. cannot find out from fact_Unified_violation_invoice, RiteMigratedInvoice_analysis,
              CASE
                WHEN invan.invoice_stage_id IN(
                  6, 7, 4, 3
                ) THEN invan.vb_inv_date_modified
              END AS vb_inv_date_modified_secondnoticedate,
              CASE
                WHEN invan.invoice_stage_id IN(
                  6, 7, 4, 3
                ) THEN invan.converted_date
              END AS secondnoticedate,
              thirdnoticedate.thirdnoticedate AS thirdnoticedate,
              dates.mail_date AS citationdate,
              -- Dates.COURT_DATE LegalActionPendingDate,
              CASE
                WHEN viol.agestageid = 4
                 AND vi.viol_inv_status = 'D' THEN vi.status_date
                WHEN invan.invoice_stage_id IN(
                  4
                ) THEN date_add(thirdnoticedate.thirdnoticedate, interval 2 YEAR)   -- After discussion with Pat on 12/15/2022, decided to add 2 years from the time time
                                                                     -- invoice was sent to collections(i.e.ThirdNoticeDate)
              END AS legalactionpendingdate,
              CASE
                WHEN viol.viol_invoice_id = -1 THEN invan.vb_inv_due_date
                ELSE invan.viol_inv_due_date
              END AS duedate,                                                            -- use voil_invoice_due_date if the invoice is in the 2nnd stage
                                                                                             -- vb_inv_date CurrMBSgeneratedDate, -- This logic needs to be tested.  use vb_inv_date for ZC/FN invoice & converted_date for SN
              '1900-01-01' AS currmbsgenerateddate,
              CASE
                WHEN (invan.vbi_status = 'E'
                 OR invan.viol_inv_status = 'E')
                 AND invan.amt_paid = 0 THEN '1900-01-01'
                WHEN (invan.vbi_status = 'L'
                 OR invan.viol_inv_status = 'L')
                 AND invan.amt_paid = 0 THEN '1900-01-01'
                WHEN invan.viol_inv_status IN(
                  'TS', 'K', 'F'
                )
                 AND invan.viol_inv_date_excused > '1900-01-01'
                 AND invan.first_paid_date = '1900-01-01'
                 AND invan.viol_inv_date_modified > '1900-01-01' THEN invan.viol_inv_date_excused
                WHEN invan.viol_inv_status IN(
                  'TS', 'K', 'F'
                )
                 AND invan.viol_inv_date_excused = '1900-01-01'
                 AND invan.first_paid_date = '1900-01-01'
                 AND invan.viol_inv_date_modified > '1900-01-01' THEN invan.viol_inv_date_modified
                WHEN invan.vbi_status = 'TS' THEN invan.vb_inv_date_excused
                WHEN invan.viol_inv_status = 'TS' THEN invan.viol_inv_date_excused
                ELSE invan.first_paid_date
              END AS firstpaymentdate,
              CASE
                WHEN (invan.vbi_status = 'E'
                 OR invan.viol_inv_status = 'E')
                 AND invan.amt_paid = 0 THEN '1900-01-01'
                WHEN (invan.vbi_status = 'L'
                 OR invan.viol_inv_status = 'L')
                 AND invan.amt_paid = 0 THEN '1900-01-01'
                WHEN invan.viol_inv_status IN(
                  'TS', 'K', 'F'
                )
                 AND invan.viol_inv_date_excused > '1900-01-01'
                 AND invan.last_paid_date = '1900-01-01'
                 AND invan.viol_inv_date_modified > '1900-01-01' THEN invan.viol_inv_date_excused
                WHEN invan.viol_inv_status IN(
                  'TS', 'K', 'F'
                )
                 AND invan.viol_inv_date_excused = '1900-01-01'
                 AND invan.last_paid_date = '1900-01-01'
                 AND invan.viol_inv_date_modified > '1900-01-01' THEN invan.viol_inv_date_modified
                WHEN invan.vbi_status IN(
                  'TS', 'K', 'F'
                )
                 AND invan.vb_inv_date_excused > '1900-01-01'
                 AND invan.last_paid_date = '1900-01-01'
                 AND invan.vb_inv_date_modified > '1900-01-01' THEN invan.vb_inv_date_excused
                WHEN invan.vbi_status IN(
                  'TS', 'K', 'F'
                )
                 AND invan.vb_inv_date_excused = '1900-01-01'
                 AND invan.last_paid_date = '1900-01-01'
                 AND invan.vb_inv_date_modified > '1900-01-01' THEN invan.vb_inv_date_modified
                WHEN invan.vbi_status = 'TS' THEN invan.vb_inv_date_excused
                WHEN invan.viol_inv_status = 'TS' THEN invan.viol_inv_date_excused
                ELSE invan.last_paid_date
              END AS lastpaymentdate,
              
                                                                                             -- first_paid_date FirstPaidDate,
                                                                                             -- last_paid_date LastPaidDate,
                                                                                             ---- -- Get the status from Dim_invoice_status after joining with RiteMigratedInvoice_analysis. Use MSTR item-90 join 

              invoice_amt AS invoiceamount,                                                        -- 100% correct
              NULL AS pbmtollamount,                                                              -- ?
              NULL AS avitollamount,                                                               --?
              NULL AS premiumamount,                                                               --?
              viol_count AS txncnt,                                                                -- 100% correct
              toll_due AS tolls,                                                                   -- 100% correct
                                                                                             --zi_late_fees,
                                                                                             --vi_late_fees,
                                                                                             --admin_fee, -- Need to check.
                                                                                             --admin_fee2 , -- Need to check.
                                                                                             --vbi_status,

              
              viol.fnfees,
              viol.snfees,
              viol.feesdue AS feesdue,  -- Modified By Shekhar on 12/6 as this calculation is easier than the below
              viol.expectedamount, -- -- 100% correct add the above 3 columns
                                                                                              --999 TollsAdjusted, -- perform calclculations based on invoice_amt_disc
              CASE
                WHEN viol.expectedamount - viol.paidamount = 0 THEN 0   -- i.e. if AdjustedAmount - PaidAmount = 0
                ELSE CASE
                  WHEN coalesce(toll_due + zi_late_fees + admin_fee + vi_late_fees + admin_fee2, 0) - viol.paidamount - (coalesce(invan.vi_late_fees, 0) + coalesce(admin_fee2, 0) + coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0)) < 0 THEN 0
                  ELSE coalesce(toll_due + zi_late_fees + admin_fee + vi_late_fees + admin_fee2, 0) - viol.paidamount - (coalesce(invan.vi_late_fees, 0) + coalesce(admin_fee2, 0) + coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0))
                END
              END AS tollsadjusted,
              CASE
                WHEN viol.paidamount > viol.expectedamount THEN 0
                WHEN viol.expectedamount - viol.paidamount = 0 THEN 0
                WHEN viol.expectedamount - viol.paidamount < viol.snfees THEN 0
                WHEN viol.expectedamount - viol.paidamount >= viol.feesdue THEN viol.fnfees
                WHEN viol.expectedamount - viol.paidamount < viol.feesdue THEN CAST(viol.expectedamount - viol.paidamount - viol.snfees as DECIMAL)
                ELSE 99999
              END AS fnfeesadjusted,
              CASE
                WHEN viol.paidamount > viol.expectedamount THEN 0
                WHEN viol.expectedamount - viol.paidamount = 0 THEN 0
                WHEN viol.expectedamount - viol.paidamount >= viol.snfees THEN viol.snfees
                WHEN viol.expectedamount - viol.paidamount < viol.snfees THEN CAST(viol.expectedamount - viol.paidamount as DECIMAL)
                ELSE 99999
              END AS snfeesadjusted,
              CASE
                WHEN viol.paidamount > viol.expectedamount THEN 0
                ELSE viol.expectedamount - viol.paidamount
              END AS adjustedamount,  -- Changed By Shekhar on 12/6/2022
              CASE
                WHEN viol.paidamount = 0 THEN 0
                WHEN viol.paidamount >= coalesce(toll_due, 0) THEN coalesce(toll_due, 0)
                ELSE viol.paidamount
              END AS tollspaid,
              CASE
                WHEN viol.paidamount = 0 THEN 0
                WHEN viol.paidamount > coalesce(toll_due, 0)
                 AND viol.paidamount <= coalesce(toll_due, 0) + coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0) THEN viol.paidamount - coalesce(toll_due, 0)
                WHEN viol.paidamount >= coalesce(toll_due, 0) + coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0) THEN coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0)
                ELSE 0
              END AS fnfeespaid,                                                                   -- fact_UVI.Fees_Paid as , -- split calculation needed
              CASE
                WHEN viol.paidamount = 0 THEN 0
                WHEN viol.paidamount >= coalesce(toll_due, 0) + coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0)
                 AND viol.paidamount < coalesce(toll_due, 0) + coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0) + coalesce(invan.vi_late_fees, 0) + coalesce(admin_fee2, 0) THEN viol.paidamount - coalesce(toll_due, 0) - (coalesce(invan.vi_late_fees, 0) + coalesce(admin_fee, 0))
                WHEN viol.paidamount >= coalesce(toll_due, 0) + coalesce(invan.zi_late_fees, 0) + coalesce(admin_fee, 0) + coalesce(invan.vi_late_fees, 0) + coalesce(admin_fee2, 0) THEN coalesce(invan.vi_late_fees, 0) + coalesce(admin_fee2, 0)
                ELSE 0
              END AS snfeespaid,   -- Fixed By Shekhar on 12/6/2022
           -- fact_UVI.Fees_Paid as , -- split calculation needed
              viol.paidamount,                                                              -- Calculated by adding the above 3 columns.
              invan.last_ca_company_id AS lastcacompanyid
            FROM
              _SESSION.Viol AS viol
              INNER JOIN EDW_RITE.Fact_Invoice_Analysis AS invan ON viol.vbi_invoice_id = invan.vbi_invoice_id
               AND viol.viol_invoice_id = invan.viol_invoice_id
              INNER JOIN EDW_RITE.Dim_Invoice_Status AS invsta ON invan.vbi_status = invsta.vbi_status
               AND invan.viol_inv_status = invsta.viol_inv_status
               AND invan.zi_stage_id = invsta.zi_stage_id
              LEFT OUTER JOIN _SESSION.Dates AS dates ON dates.viol_invoice_id = viol.viol_invoice_id
              LEFT OUTER JOIN _SESSION.ThirdNoticeDate AS thirdnoticedate ON thirdnoticedate.viol_invoice_id = viol.viol_invoice_id
              INNER JOIN EDW_RITE.Dim_Violator_Asof AS viol8 ON invan.partition_date = viol8.partition_date
               AND invan.violator_id = viol8.violator_id
              INNER JOIN EDW_RITE.Ca_Companies AS viol10 ON invan.first_ca_company_id = viol10.ca_company_id
              INNER JOIN EDW_RITE.Ca_Companies AS viol11 ON invan.last_ca_company_id = viol11.ca_company_id
              INNER JOIN EDW_RITE.Ca_Inv_Status AS viol12 ON invan.ca_inv_status = viol12.ca_inv_status
              LEFT OUTER JOIN LND_TBOS.Tollplus_Invoice_Header AS ih ON CAST(viol.invoicenumber as STRING) = CAST(ih.invoicenumber as STRING)
               AND ih.invoicestatus <> 'Transferred'
              LEFT OUTER JOIN EDW_TRIPS.Dim_Invoicestatus AS invs ON invs.invoicestatusdesc = viol.invoicestatus
              LEFT OUTER JOIN _SESSION.LegalActionPendingDate AS vi ON viol.viol_invoice_id = vi.viol_invoice_id
            WHERE invan.partition_date = '2021-01-01'
        )
        SELECT
            aaa.invoicenumber,
            aaa.firstinvoiceid,
            aaa.currentinvoiceid,
            aaa.customerid,
            aaa.agestageid,
            aaa.collectionstatusid,
            aaa.currmbsid,
            aaa.vehicleid,
            aaa.lic_plate_nbr,
            aaa.lic_plate_state,
            aaa.migratedflag,
            aaa.invoicestatus,
            aaa.edw_invoicestatusid,
            aaa.zipcashdate,
            aaa.firstnoticedate,
            aaa.vb_inv_date_modified_secondnoticedate,
            aaa.secondnoticedate,
            aaa.thirdnoticedate,
            aaa.citationdate,
            aaa.legalactionpendingdate,
            aaa.duedate,
            aaa.currmbsgenerateddate,
            CASE
              WHEN aaa.firstpaymentdate = '1900-01-01' THEN NULL
              ELSE aaa.firstpaymentdate
            END AS firstpaymentdate,
            CASE
              WHEN aaa.lastpaymentdate = '1900-01-01' THEN NULL
              ELSE aaa.lastpaymentdate
            END AS lastpaymentdate,
            aaa.invoiceamount,
            aaa.pbmtollamount,
            aaa.avitollamount,
            aaa.premiumamount,
            aaa.txncnt,
            aaa.tolls,
            aaa.fnfees,
            aaa.snfees,
            aaa.feesdue,
            aaa.expectedamount,
            aaa.tollsadjusted,
            aaa.fnfeesadjusted,
            aaa.snfeesadjusted,
            aaa.adjustedamount,
            aaa.tollspaid,
            aaa.fnfeespaid,
            aaa.snfeespaid,
            aaa.paidamount,
            aaa.lastcacompanyid,
            aaa.tolls - aaa.tollsadjusted AS adjustedexpectedtolls,
            aaa.fnfees - aaa.fnfeesadjusted AS adjustedexpectedfnfees,
            aaa.snfees - aaa.snfeesadjusted AS adjustedexpectedsnfees,
            aaa.expectedamount - aaa.adjustedamount AS adjustedexpectedamount,
            aaa.tolls - aaa.tollsadjusted - aaa.tollspaid AS tolloutstandingamount,
            aaa.fnfees - aaa.fnfeesadjusted - aaa.fnfeespaid AS fnfeesoutstandingamount,
            aaa.snfees - aaa.snfeesadjusted - aaa.snfeespaid AS snfeesoutstandingamount,
            CASE
              WHEN aaa.paidamount > aaa.expectedamount THEN 0
              ELSE aaa.expectedamount - aaa.adjustedamount - aaa.paidamount
            END AS outstandingamount
          FROM
            aaa
    ;
  END;