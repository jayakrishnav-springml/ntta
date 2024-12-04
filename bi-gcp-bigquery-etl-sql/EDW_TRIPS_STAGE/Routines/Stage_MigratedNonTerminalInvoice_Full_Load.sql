CREATE OR REPLACE PROCEDURE EDW_TRIPS_STAGE.MigratedNonTerminalInvoice_Full_Load()
BEGIN
    /*
    ###################################################################################################################
    Proc Description: 
    -------------------------------------------------------------------------------------------------------------------
    Load dbo.Fact_NonTerminal_MigratedInvoices table. 
    ===================================================================================================================
    Change Log:
    -------------------------------------------------------------------------------------------------------------------
    CHG0042443	Gouthami		2023-02-09	New!
                        1) This procedure is used to create data for all migrated Non terminal 
                          invoices. Non terminal Invoices are identified using Ref.RiteMigratedInvoice
                          table and invoice status as 'OPEN'.
                        2) Once the invoices are identified, rest of the columns are created using 
                          landing trips table.
                        3) FirstNotice, SecondNotice, ThirdNotice, LegalAction, Citation Dates are 
                          pulled from Ref and landing tables. This is because if the invoice is 
                          migrated at second notice EDW_TRIPS_STAGE, then trips tables doesn't have the dates 
                          prior to that EDW_TRIPS_STAGE. In order to bring the prior stages dates, RITE DB is 
                          used.
    ===================================================================================================================

    -------------------------------------------------------------------------------------------------------------------
    EXEC [EDW_TRIPS_STAGE].[MigratedNonTerminalInvoice_Full_Load]
    EXEC Utility.FromLog 'EDW_TRIPS_STAGE.MigratedNonTerminalInvoice', 1
    SELECT TOP 100 'EDW_TRIPS_STAGE.MigratedNonTerminalInvoice' Table_Name, * FROM EDW_TRIPS_STAGE.MigratedNonTerminalInvoice ORDER BY 2
    ###################################################################################################################
    */
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS_STAGE.MigratedNonTerminalInvoice_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;  -- Testing
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
      --=============================================================================================================
      -- Load EDW_TRIPS_STAGE.MigratedInvoice -- list of invoices that needs to be executed in each run
      --=============================================================================================================

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.MigratedInvoice
        AS
          SELECT
              a.*
            FROM
              (
                SELECT
                    row_number() OVER (PARTITION BY ihc.invoicenumber ORDER BY ihc.invoiceid DESC) AS rn_max,
                    ihc.invoicenumber,
                    ihc.invoiceid,
                    ihc.customerid,
                    ihc.agestageid,
                    ihc.collectionstatus,
                    ihc.vehicleid,
                    ihc.invoicedate,
                    ihc.duedate,
                    ihc.adjustedamount,
                    ihc.invoicestatus,
                    ihc.lnd_updatetype,
                    ri.agestageid AS agestageid_ri,
                    ri.zipcashdate AS zipcashdate_ri,
                    ri.firstnoticedate AS firstnoticedate_ri,
                    ri.secondnoticedate AS secondnoticedate_ri,
                    ri.thirdnoticedate AS thirdnoticedate_ri,  -- Casting Timestamp to Datetime while preserving timezone
                    ri.citationdate AS citationdate_ri,
                    ri.legalactionpendingdate AS legalactionpendingdate_ri,  -- Casting Timestamp to Datetime while preserving timezone
                    ri.duedate AS duedate_ri,
                    ri.currmbsgenerateddate AS currmbsgenerateddate_ri,
                    CASE
                      WHEN ri.firstpaymentdate < ri.zipcashdate THEN ri.firstpaymentdate
                      ELSE NULL
                    END AS firstpaymentdatepriortozc_ri,
                    CASE
                      WHEN ri.lastpaymentdate < ri.zipcashdate THEN ri.lastpaymentdate
                      ELSE NULL
                    END AS lastpaymentdatepriortozc_ri,
                    CASE
                      WHEN ri.firstpaymentdate < ri.zipcashdate THEN ri.firstpaymentdate
                      ELSE NULL
                    END AS firstpaymentdateafterzc_ri,
                    CASE
                      WHEN ri.lastpaymentdate < ri.zipcashdate THEN ri.lastpaymentdate
                      ELSE NULL
                    END AS lastpaymentdateafterzc_ri

                  FROM LND_TBOS.TollPlus_Invoice_Header AS ihc
                    INNER JOIN EDW_TRIPS_SUPPORT.RiteMigratedInvoice AS ri 
                      ON ri.invoicenumber  = SAFE_CAST(ihc.invoicenumber AS INT64)
                      AND ri.edw_invoicestatusid = 4370
                  WHERE ihc.lnd_updatetype <> 'D'
                   AND ihc.createduser <> 'DCBInvoiceGeneration'
                   AND ri.invoicenumber IS NOT NULL
              ) AS a
            WHERE a.rn_max = 1
      ;

      --Log
      SET log_message = 'Loaded EDW_TRIPS_STAGE.MigratedInvoice';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');

      
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.MigratedInvoice' AS tablename,
            MigratedInvoice.*
          FROM
            EDW_TRIPS_STAGE.MigratedInvoice
        ORDER BY 2 DESC
        LIMIT 100
        ;
      END IF;

      --=============================================================================================================
      -- Load EDW_TRIPS_STAGE.MigratedDimissedVToll  -- to bring dismissed Vtolls
      --=============================================================================================================

      CREATE TEMPORARY TABLE _SESSION.cte_vtolls 
        AS
          (
            SELECT DISTINCT
                a.invoicenumber AS invoicenumber,
                count(DISTINCT a.tptripid) AS vtolltxncnt,
                COALESCE(sum(CASE
                  WHEN a.tripstatusid IN(
                    171, 118
                  ) THEN 1
                  ELSE 0
                END), 0) AS unassignedvtolledtxncnt,
                sum(CASE
                  WHEN a.paymentstatusid = 456 THEN 1
                  ELSE 0
                END) AS vtollpaidtxncnt,
                min(a.posteddate) AS firstpaymentdate,
                max(a.posteddate) AS lastpaymentdate,
                sum(a.tolls) AS tolls,
                sum(a.pbmtollamount) AS pbmtollamount,
                sum(a.avitollamount) AS avitollamount,
                sum(a.pbmtollamount - a.avitollamount) AS premiumamount,
                sum(a.paidamount_vt) AS paidamount_vt,
                sum(a.tollsadjusted) AS tollsadjusted,
                sum(a.outstandingamount) AS outstandingamount
              FROM
                (
                  SELECT
                      h.invoicenumber,
                      tc.tptripid,
                      vt.tripstatusid,
                      tc.paymentstatusid,
                      max(tc.posteddate) AS posteddate,  --Ex:1199596135
                      CASE
                        WHEN tc.paymentstatusid = 3852
                         AND vt.tripstatusid <> 154
                         AND tc.tripstatusid <> 155 THEN 0
                        ELSE vt.pbmtollamount
                      END AS pbmtollamount, -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
                      CASE
                        WHEN tc.paymentstatusid = 3852
                         AND vt.tripstatusid <> 154
                         AND tc.tripstatusid <> 155 THEN 0
                        ELSE vt.avitollamount
                      END AS avitollamount, -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
                      CASE
                        WHEN tc.paymentstatusid = 3852
                         AND vt.tripstatusid <> 154
                         AND tc.tripstatusid <> 155 THEN 0
                        ELSE vt.tollamount
                      END AS tolls, -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
                      CASE
                        WHEN count(vt.tptripid) > 1 THEN div(sum(CASE
                          WHEN tc.paymentstatusid = 456
                           AND tc.tripstatusid = 5 THEN tc.tollamount
                          WHEN tc.paymentstatusid = 456 THEN tc.tollamount
                          WHEN tc.paymentstatusid = 457 THEN CAST(tc.tollamount - tc.outstandingamount as INT64)
                          ELSE 0
                        END), count(vt.tptripid))
                        ELSE sum(CASE
                          WHEN tc.paymentstatusid = 456
                           AND tc.tripstatusid = 5 THEN tc.tollamount
                          WHEN tc.paymentstatusid = 456 THEN tc.tollamount
                          WHEN tc.paymentstatusid = 457 THEN CAST(tc.tollamount - tc.outstandingamount as INT64)
                          ELSE 0
                        END)
                      END AS paidamount_vt,
                      tc.outstandingamount,
                      sum(CASE
                        WHEN tc.paymentstatusid = 3852
                         AND tc.tripstatusid = 135
                         AND vt.paymentstatusid = 456
                         AND vt.tripstatusid = 2 THEN 0 -- these are the txns that got posted in VT table and paid in vtrt 
                        WHEN tc.paymentstatusid = 458
                         AND tc.outstandingamount <> tc.tollamount
                         AND tc.outstandingamount = tc.pbmtollamount
                         AND tc.outstandingamount = tc.avitollamount THEN (tc.tollamount - tc.outstandingamount) -- Ex:1236741507
                        WHEN tc.paymentstatusid = 3852
                         AND tc.tripstatusid = 135
                         AND vt.paymentstatusid = 3852 THEN 0 --ex:1225983731
                        WHEN tc.paymentstatusid = 3852
                         AND tc.tripstatusid = 154 THEN 0 --Ex:1222959778
                        WHEN tc.paymentstatusid = 3852 THEN l.amount
                        WHEN tc.tollamount <> l.amount THEN l.amount - tc.tollamount
                        WHEN tc.tollamount = tc.pbmtollamount
                         AND tc.outstandingamount = tc.avitollamount
                         AND tc.paymentstatusid = 458 THEN (tc.tollamount - tc.outstandingamount) --Ex:1234342591
                        WHEN tc.tollamount = tc.pbmtollamount THEN 0
                        WHEN tc.tollamount = 0
                         AND vt.tollamount = tc.pbmtollamount THEN tc.pbmtollamount
                        WHEN tc.tollamount = l.amount
                         AND tc.tollamount <> tc.pbmtollamount
                         AND tc.tollamount <> tc.avitollamount THEN 0
                        WHEN tc.tollamount = 0
                         AND tc.paymentstatusid = 456 THEN 0
                        ELSE (tc.pbmtollamount - tc.avitollamount)
                      END) AS tollsadjusted
                      --SELECT *
                    FROM LND_TBOS.TollPlus_Invoice_Header AS h
                      INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS l 
                        ON l.invoiceid = h.invoiceid
                      INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt 
                        ON abs(l.linkid) = abs(vt.citationid)
                       AND l.linksourcename = 'TOLLPLUS.TP_ViolatedTrips'
                       AND (vt.paymentstatusid <> 456
                       AND vt.tripstatusid <> 2)  -- This is to avoid those Txns that are vtolled first and then moved back to Violated trips table
                       AND vt.tripstatusid NOT IN(
                        171, 118, 170
                      ) -- EX: 1233445625,1234165987,1230780604. This condition is for the Txns that are unassignd from an invoice and assigned to a different one and then gor VTOLLED.In this case, the citationID is going to change but TPTRIPID remains same. While joining this VT table to CT,we are goint to get all the txns assigned to the TPTRIPID(Assigned and Vtolled). 
                      INNER JOIN LND_TBOS.TollPlus_TP_Trips AS tt 
                        ON tt.tptripid = vt.tptripid
                        AND tt.tripwith IN('C') -- Ex:1201323030 Invoice can be vtolled and then go back to violations. In order to avoid those txns, using tripwith='C'
                      INNER JOIN EDW_TRIPS_STAGE.MigratedInvoice AS rite 
                        ON rite.invoicenumber = h.invoicenumber
                      INNER JOIN LND_TBOS.TollPlus_TP_CustomerTrips AS tc 
                        ON tc.tptripid = vt.tptripid
                        AND tc.paymentstatusid = 456      --Paid
                        AND tc.tripstatusid <> 5          --Adjusted
                        AND tc.transactionpostingtype NOT IN('Prepaid AVI', 'NTTA Fleet')
                        AND tc.outstandingamount = 0
                      --WHERE H.InvoiceNumber IN (1187146926,1041625728)--(PartialVtoll)--1187146926-- FullyVtoll
                      --WHERE Rite.InvoiceNumber=747518360
                      GROUP BY h.invoicenumber,
                          tc.tptripid,
                          vt.tripstatusid,
                          tc.paymentstatusid,
                          vt.tollamount,
                          tc.outstandingamount,
                          vt.tptripid,
                          vt.tripstatusid,
                          vt.paymentstatusid,
                          vt.outstandingamount,
                          vt.pbmtollamount,
                          vt.avitollamount,
                          tc.tripstatusid
                      ) AS a
              GROUP BY a.invoicenumber
          );
          
      CREATE TEMPORARY TABLE _SESSION.cte 
        AS 
          (
            SELECT
                h.invoicenumber,
                sum(CASE
                  WHEN custtxncategory IN('TOLL') THEN 1
                  ELSE 0
                END) AS totaltxncnt,
                sum(CASE
                  WHEN l.sourceviolationstatus = 'L'
                   AND (vt.paymentstatusid = 456
                   OR vt.paymentstatusid IS NULL) THEN 1
                  ELSE 0
                END) AS unassignedtxncnt, -- Out of 4, 1 txn got unassigned from an invoice and rest are vtolled then the Invoice status should be Vtoll.Ex:1120029424	
                sum(CASE
                  WHEN l.sourceviolationstatus = 'L'
                   AND vt.paymentstatusid IS NULL THEN l.amount
                  ELSE 0
                END) AS excusedtollsadjusted --1030630051
                --select *
              FROM LND_TBOS.TollPlus_Invoice_Header AS h
                INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS l 
                  ON l.invoiceid = h.invoiceid
                LEFT OUTER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt 
                  ON abs(l.linkid) = vt.citationid
                  AND l.linksourcename = 'TOLLPLUS.TP_ViolatedTrips'
                INNER JOIN EDW_TRIPS_STAGE.MigratedInvoice AS rite 
                  ON rite.invoicenumber = h.invoicenumber
                  --WHERE H.InvoiceNumber IN (1187146926,1041625728)
                --WHERE H.InvoiceNumber=1120029424 -- 1 Unassigned and 3 vtoll
              GROUP BY h.invoicenumber
          );


          CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.MigratedDimissedVToll
          AS
            SELECT
                cte_vtolls.invoicenumber,
                cte.totaltxncnt AS totaltxncnt,
                cte_vtolls.vtolltxncnt,
                cte.unassignedtxncnt,
                cte_vtolls.unassignedvtolledtxncnt,
                cte_vtolls.vtollpaidtxncnt,
                CASE
                  WHEN cte_vtolls.paidamount_vt = 0 THEN CAST('1900-01-01' as DATETIME)
                  ELSE cte_vtolls.firstpaymentdate
                END AS firstpaymentdate,
                CASE
                  WHEN cte_vtolls.paidamount_vt = 0 THEN CAST('1900-01-01' as DATETIME)
                  ELSE cte_vtolls.lastpaymentdate
                END AS lastpaymentdate,
                cte_vtolls.pbmtollamount,
                cte_vtolls.avitollamount,
                cte_vtolls.premiumamount,
                cte_vtolls.tolls,
                cte_vtolls.paidamount_vt,
                cte.excusedtollsadjusted + cte_vtolls.tollsadjusted AS tollsadjusted,
                0 AS tollsadjustedaftervtoll,
                0 AS adjustedamount_excused,
                0 AS classadj,
                cte_vtolls.outstandingamount,
                0 AS paidtnxs,
                CASE
                  WHEN cte_vtolls.vtolltxncnt = cte.totaltxncnt THEN 1
                  ELSE 0
                END AS vtollflag,
                CASE
                  cte.totaltxncnt
                  WHEN cte_vtolls.vtolltxncnt THEN '1 - Vtoll Invoice'
                  WHEN cte_vtolls.vtolltxncnt + cte.unassignedtxncnt THEN '1 - Vtoll Invoice'
                  ELSE '0 - PartialVtoll Invoice'
                END AS vtollflagdescription,
                COALESCE(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_update_date
              FROM
                cte_vtolls
                LEFT OUTER JOIN cte 
                  ON cte.invoicenumber = cte_vtolls.invoicenumber
      ;


      -- Log 
      SET log_message = 'Loaded EDW_TRIPS_STAGE.MigratedDimissedVToll';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');


      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.MigratedDimissedVToll' AS tablename,
            MigratedDimissedVToll.*
          FROM
            EDW_TRIPS_STAGE.MigratedDimissedVToll
        ORDER BY 2 DESC
        LIMIT 100
        ;
      END IF;

      --=============================================================================================================
        -- Load EDW_TRIPS_STAGE.MigratedUnassignedInvoice  -- to bring dismissed Unassigned Invoices
      --=============================================================================================================

      CREATE TEMPORARY TABLE _SESSION.cte_unassigned
      AS 
        (
            SELECT
                ih.invoicenumber AS invoicenumber_unass,
                count(DISTINCT vt.citationid) AS unassignedtxncnt,
                sum(vt.tollamount) AS tolls
              FROM
                (
                  SELECT
                      TollPlus_TP_ViolatedTrips.tptripid
                    FROM
                      LND_TBOS.TollPlus_TP_ViolatedTrips
                    GROUP BY tptripid
                    HAVING count(1) > 1
                ) AS a
                INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt 
                  ON vt.tptripid = a.tptripid
                INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS ili 
                  ON abs(vt.citationid) = abs(ili.linkid)
                  AND ili.linksourcename = 'TOLLPLUS.TP_ViolatedTrips'
                INNER JOIN LND_TBOS.TollPlus_Invoice_Header AS ih 
                  ON ili.invoiceid = ih.invoiceid
                INNER JOIN EDW_TRIPS_STAGE.MigratedInvoice AS rite 
                  ON rite.invoicenumber = ih.invoicenumber
              WHERE tripstatusid IN(171, 115)
                AND ih.invoicenumber NOT IN
                (
                  SELECT
                      MigratedDimissedVToll.invoicenumber
                    FROM
                      EDW_TRIPS_STAGE.MigratedDimissedVToll
              )
              GROUP BY ih.invoicenumber
          );
          
      CREATE TEMPORARY TABLE _SESSION.cte_all 
      AS 
        (
            SELECT
                h.invoicenumber,
                count(DISTINCT vt.citationid) AS totaltxncnt
              FROM
                LND_TBOS.TollPlus_Invoice_Header AS h
                INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS l 
                  ON l.invoiceid = h.invoiceid
                INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt 
                  ON abs(vt.citationid) = abs(l.linkid)
                 AND l.linksourcename = 'TOLLPLUS.TP_ViolatedTrips'
              GROUP BY h.invoicenumber
          );

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.MigratedUnassignedInvoice 
        AS
          SELECT
              cte_unassigned.invoicenumber_unass,
              cte_unassigned.unassignedtxncnt,
              cte_all.invoicenumber,
              cte_all.totaltxncnt,
              cte_unassigned.tolls,
              1 AS unassignedflag
            FROM
              cte_unassigned
              INNER JOIN cte_all 
                ON cte_all.invoicenumber = cte_unassigned.invoicenumber_unass
            WHERE cte_all.totaltxncnt = cte_unassigned.unassignedtxncnt
      ;

      -- Log 
      SET log_message = 'Loaded EDW_TRIPS_STAGE.MigratedUnassignedInvoice';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');

      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.MigratedUnassignedInvoice' AS tablename,
            MigratedUnassignedInvoice.*
          FROM
            EDW_TRIPS_STAGE.MigratedUnassignedInvoice
        ORDER BY 2 DESC
        LIMIT 100
        ;
      END IF;

      --=============================================================================================================
        -- Load EDW_TRIPS_STAGE.CAMigratedNonTerminalInvoice  -- To bring Collection agency information for all invoices
      --=============================================================================================================

      CREATE TEMPORARY TABLE _SESSION.cte_inv 
        AS 
          (
            SELECT
                vco.invoicenumber,
                mbs.mbsid,
                mbh.ispresentmbs,
                ftp.fileid,
                ftp.destination,
                count(DISTINCT ftp.filegenerateddate) AS numberoftimessent,
                max(ftp.filegenerateddate) AS latestfilegendate
              FROM
                LND_TBOS.TER_ViolatorCollectionsOutbound AS vco
                INNER JOIN LND_TBOS.TollPlus_TpFileTracker AS ftp ON vco.fileid = ftp.fileid
                INNER JOIN EDW_TRIPS_STAGE.MigratedInvoice AS minv ON minv.invoicenumber = vco.invoicenumber
                INNER JOIN LND_TBOS.TollPlus_MbsInvoices AS mbs ON mbs.invoicenumber = vco.invoicenumber
                INNER JOIN LND_TBOS.TollPlus_Mbsheader AS mbh ON mbh.mbsid = mbs.mbsid
              WHERE ftp.destination IN('CMI', 'CPA', 'LES', 'SWC')
              GROUP BY  vco.invoicenumber, 
                        mbs.mbsid, 
                        mbh.ispresentmbs, 
                        ftp.fileid, 
                        ftp.destination
          ); 
          
      CREATE TEMPORARY TABLE _SESSION.cte_ca 
        AS 
          (
            SELECT
                cte_inv.invoicenumber,
                CASE
                  WHEN cte_inv.destination = 'CMI' THEN max(cte_inv.fileid)
                END AS cmifileid,
                CASE
                  WHEN cte_inv.destination = 'CPA' THEN max(cte_inv.fileid)
                END AS cpafileid,
                CASE
                  WHEN cte_inv.destination = 'LES' THEN max(cte_inv.fileid)
                END AS lesfileid,
                CASE
                  WHEN cte_inv.destination = 'SWC' THEN max(cte_inv.fileid)
                END AS swcfileid,
                CASE
                  WHEN cte_inv.destination = 'CMI' THEN max(cte_inv.latestfilegendate)
                END AS cmilatestfilegendate,
                CASE
                  WHEN cte_inv.destination = 'CPA' THEN max(cte_inv.latestfilegendate)
                END AS cpalatestfilegendate,
                CASE
                  WHEN cte_inv.destination = 'LES' THEN max(cte_inv.latestfilegendate)
                END AS leslatestfilegendate,
                CASE
                  WHEN cte_inv.destination = 'SWC' THEN max(cte_inv.latestfilegendate)
                END AS swclatestfilegendate,
                CASE
                  WHEN cte_inv.destination = 'CMI' THEN max(cte_inv.numberoftimessent)
                END AS cminumberoftimessent,
                CASE
                  WHEN cte_inv.destination = 'CPA' THEN max(cte_inv.numberoftimessent)
                END AS cpanumberoftimessent,
                CASE
                  WHEN cte_inv.destination = 'LES' THEN max(cte_inv.numberoftimessent)
                END AS lesnumberoftimessent,
                CASE
                  WHEN cte_inv.destination = 'SWC' THEN max(cte_inv.numberoftimessent)
                END AS swcnumberoftimessent
              FROM
                cte_inv
              GROUP BY invoicenumber, cte_inv.destination
          );

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CAMigratedNonTerminalInvoice
        AS
          SELECT
              a.invoicenumber,
              COALESCE(a.cpalatestfilegendate, a.leslatestfilegendate) AS primarycollectionagencydate,
              COALESCE(a.swclatestfilegendate, a.cmilatestfilegendate) AS secondarycollectionagencydate,
              COALESCE(a.cpanumberoftimessent, a.lesnumberoftimessent, 0) AS nooftimessenttoprimary,
              COALESCE(a.swcnumberoftimessent, a.cminumberoftimessent, 0) AS nooftimessenttosecondary,
              CASE
                WHEN a.cpafileid IS NOT NULL THEN 'Credit Protected Assoc. (CPA)'
                WHEN a.lesfileid IS NOT NULL THEN 'Duncan Solutions (LES/PAM)'
                ELSE NULL
              END AS primarycollectionagency,
              CASE
                WHEN a.swcfileid IS NOT NULL THEN 'Southwest Credit Systems (SWC)'
                WHEN a.cmifileid IS NOT NULL THEN 'Credit Management Group (CMI)'
                ELSE NULL
              END AS secondarycollectionagency
            FROM
              (
                SELECT
                    cte_ca.invoicenumber,
                    max(cte_ca.cmifileid) AS cmifileid,
                    max(cte_ca.cpafileid) AS cpafileid,
                    max(cte_ca.lesfileid) AS lesfileid,
                    max(cte_ca.swcfileid) AS swcfileid,
                    max(cte_ca.cmilatestfilegendate) AS cmilatestfilegendate,
                    max(cte_ca.cpalatestfilegendate) AS cpalatestfilegendate,
                    max(cte_ca.leslatestfilegendate) AS leslatestfilegendate,
                    max(cte_ca.swclatestfilegendate) AS swclatestfilegendate,
                    max(cte_ca.cminumberoftimessent) AS cminumberoftimessent,
                    max(cte_ca.cpanumberoftimessent) AS cpanumberoftimessent,
                    max(cte_ca.lesnumberoftimessent) AS lesnumberoftimessent,
                    max(cte_ca.swcnumberoftimessent) AS swcnumberoftimessent
                  FROM
                    cte_ca
                  GROUP BY invoicenumber
              ) AS a
      ;--JOIN dbo.Dim_CollectionStatus

      -- Log 
      SET log_message = 'Loaded EDW_TRIPS_STAGE.CAMigratedNonTerminalInvoice';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');

      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.CAMigratedNonTerminalInvoice' AS tablename,
            CAMigratedNonTerminalInvoice.*
          FROM
            EDW_TRIPS_STAGE.CAMigratedNonTerminalInvoice
        ORDER BY 2 DESC
        LIMIT 100
        ;
      END IF;

      --=============================================================================================================
      -- Load EDW_TRIPS_STAGE.MigratedNonTerminalInvoice
      --=============================================================================================================

      CREATE TEMPORARY TABLE _SESSION.cte_first_inv
      AS 
        (
            SELECT
                a.*
              FROM
                (
                  SELECT
                      row_number() OVER (PARTITION BY ihf.invoicenumber ORDER BY ihf.invoiceid) AS rn_min,
                      ihf.invoicenumber,
                      ihf.invoiceid,
                      ihf.sourcename,
                      ihf.lnd_updatetype
                    FROM
                      LND_TBOS.TollPlus_Invoice_Header AS ihf
                      INNER JOIN EDW_TRIPS_STAGE.MigratedInvoice AS ri ON ri.invoicenumber = ihf.invoicenumber
                    WHERE ihf.lnd_updatetype <> 'D'
                     AND ihf.createduser <> 'DCBInvoiceGeneration'
                     --AND IHF.InvoiceNumber = 1188125295
                ) AS a
              WHERE a.rn_min = 1
          ); 
          
      CREATE TEMPORARY TABLE _SESSION.cte_inv_date
      AS 
        (
            SELECT
                a.invoicenumber,
                max(a.mbsid) AS mbsid,
                max(a.zipcashdate) AS zipcashdate,
                max(a.firstnoticedate) AS firstnoticedate,
                max(a.secondnoticedate) AS secondnoticedate,
                max(a.thirdnoticedate) AS thirdnoticedate,
                max(a.legalactionpendingdate) AS legalactionpendingdate,
                max(a.citationdate) AS citationdate,
                max(a.duedate) AS duedate,
                max(a.mbsgenerateddate) AS mbsgenerateddate,
                a.deleteflag AS deleteflag
              FROM
                (
                  SELECT
                      ihd.invoicenumber,
                      max(mbsh.mbsid) AS mbsid,
                      max(CASE
                        WHEN ihd.agestageid = 1 THEN CAST(  ihd.invoicedate as DATE)
                        ELSE CAST('1900-01-01' AS DATE)
                      END) AS zipcashdate,
                      COALESCE(CAST(  ri.firstnoticedate_ri as DATE), CAST(max(CASE
                        WHEN ihd.agestageid = 2 THEN CAST(  ihd.invoicedate as DATE) 
                        ELSE CAST('1900-01-01' AS DATE)
                      END) as DATE)) AS firstnoticedate,
                      COALESCE(CAST(  ri.secondnoticedate_ri as DATE), CAST(max(CASE
                        WHEN ihd.agestageid = 3 THEN CAST(  ihd.invoicedate as DATE) 
                        ELSE CAST('1900-01-01' AS DATE)
                      END) as DATE)) AS secondnoticedate,
                      COALESCE(CAST(  ri.thirdnoticedate_ri as DATE), CAST(min(CASE
                        WHEN ihd.agestageid = 4 THEN CAST(  ihd.invoicedate as DATE) 
                        ELSE CAST('1900-01-01' AS DATE)
                      END) as DATE)) AS thirdnoticedate,
                      COALESCE(CAST(  ri.legalactionpendingdate_ri as DATE), CAST(max(CASE
                        WHEN ihd.agestageid = 5 THEN CAST(  ihd.invoicedate as DATE) 
                        ELSE CAST('1900-01-01' AS DATE)
                      END) as DATE)) AS legalactionpendingdate,
                      COALESCE(CAST(  ri.citationdate_ri as DATE), CAST(CASE
                        WHEN ihd.agestageid = 6 THEN min(CAST(  ihd.invoicedate as DATE)) 
                        ELSE CAST('1900-01-01' AS DATE)
                      END as DATE)) AS citationdate,
                      max(CAST(  ihd.duedate as DATE)) AS duedate,
                      max(CAST(  mbsh.mbsgenerateddate as DATE)) AS mbsgenerateddate,
                      CASE
                        WHEN ihd.lnd_updatetype = 'D'
                         OR mbsi.lnd_updatetype = 'D'
                         OR mbsh.lnd_updatetype = 'D' THEN 1
                        ELSE 0
                      END AS deleteflag
                      --SELECT * 
                    FROM LND_TBOS.TollPlus_Invoice_Header AS ihd
                      INNER JOIN EDW_TRIPS_STAGE.MigratedInvoice AS ri 
                        ON ri.invoicenumber = ihd.invoicenumber
                      LEFT OUTER JOIN LND_TBOS.TollPlus_MbsInvoices AS mbsi 
                        ON mbsi.invoicenumber = ihd.invoicenumber
                        AND mbsi.lnd_updatetype <> 'D'
                      LEFT OUTER JOIN LND_TBOS.TollPlus_Mbsheader AS mbsh 
                        ON mbsh.mbsid = mbsi.mbsid
                        AND mbsh.lnd_updatetype <> 'D'
                    WHERE ihd.lnd_updatetype <> 'D'
                      AND ihd.createduser <> 'DCBInvoiceGeneration'
                    --AND IHD.InvoiceNumber=1188125295
                    GROUP BY  ihd.invoicenumber,
                              deleteflag, 
                              ihd.agestageid, 
                              ri.firstnoticedate_ri, 
                              ri.secondnoticedate_ri, 
                              ri.thirdnoticedate_ri, 
                              ri.legalactionpendingdate_ri, 
                              ri.citationdate_ri, 
                              ri.duedate_ri
                ) AS a
              GROUP BY  invoicenumber, 
                        a.deleteflag
          ); 
      CREATE TEMPORARY TABLE _SESSION.mi 
      AS 
        (
            SELECT
                CAST(  cte_curr_inv.invoicenumber as INT64) AS invoicenumber,
                cte_first_inv.invoiceid AS firstinvoiceid,
                cte_curr_inv.invoiceid AS currentinvoiceid,
                cte_curr_inv.customerid,
                CASE
                  WHEN cte_first_inv.sourcename IS NOT NULL THEN 1
                  ELSE 0
                END AS migratedflag,
                cte_curr_inv.agestageid AS agestageid,
                COALESCE(cte_curr_inv.collectionstatus, -1) AS collectionstatusid,
                COALESCE(cte_inv_date.mbsid, -1) AS currmbsid,
                cte_curr_inv.vehicleid,
                dis.invoicestatusid,
                pp.paymentplanid,
                COALESCE(cte_curr_inv.zipcashdate_ri, max(CASE
                  WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                END)) AS zipcashdate,
                cte_inv_date.firstnoticedate,
                cte_inv_date.secondnoticedate,
                cte_inv_date.thirdnoticedate,
                cte_inv_date.legalactionpendingdate,
                cte_inv_date.citationdate,
                cte_inv_date.duedate,
                COALESCE(cte_inv_date.mbsgenerateddate, DATE '1900-01-01') AS currmbsgenerateddate,
                --COALESCE(CTE_CURR_INV.FirstpaymentDate_RI,PMT.FirstPaymentDate) FirstPaymentDate,
			          --COALESCE(CTE_CURR_INV.LastPaymentDate_RI,PMT.LastPaymentDate) LastPaymentDate,
                COALESCE(cte_curr_inv.firstpaymentdatepriortozc_ri, pmt.firstpaymentdatepriortozc) AS firstpaymentdatepriortozc,
                COALESCE(cte_curr_inv.lastpaymentdatepriortozc_ri, pmt.lastpaymentdatepriortozc) AS lastpaymentdatepriortozc,
                COALESCE(cte_curr_inv.firstpaymentdateafterzc_ri, pmt.firstpaymentdateafterzc) AS firstpaymentdateafterzc,
                COALESCE(cte_curr_inv.lastpaymentdateafterzc_ri, pmt.lastpaymentdateafterzc) AS lastpaymentdateafterzc,
                
                
                fp.firstfeepaymentdate,
                fp.lastfeepaymentdate,
                ca.primarycollectionagencydate,
                ca.secondarycollectionagencydate,

                ---------------------------------------TxnCounts
                count(DISTINCT tpv.tptripid) AS txncnt,
                sum(CASE
                  WHEN tpv.tripstatusid = 170 THEN 1
                  ELSE 0
                END) AS excusedtxncnt,
                sum(CASE
                  WHEN tpv.tripstatusid IN(
                    171, 115
                  ) THEN 1
                  ELSE 0
                END) AS unassignedtxncnt,
                sum(CASE
                  WHEN vtp.vtollflag = 1
                   AND vtp.paymentstatusid IN(
                    456, 457, 458
                  ) THEN 1
                  ELSE 0
                END) AS vtolltxncnt,
                sum(CASE
                  WHEN tpv.paymentstatusid = 456
                   OR vtp.paymentstatusid = 456 THEN 1
                  ELSE 0
                END) AS paidtxncnt,
                sum(CASE
                  WHEN CAST(  vtp.firstpaiddate as DATE) < COALESCE(cte_curr_inv.zipcashdate_ri, CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                  END)
                   AND vtp.firstpaiddate IS NOT NULL
                   AND (vtp.vtollflag = 1
                   OR tpv.paymentstatusid = 456
                   OR tpv.paymentstatusid = 456
                   OR tpv.paymentstatusid = 457) THEN 1
                  WHEN CAST(  vtp.excuseddate as DATE) < CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                    ELSE DATE '1900-01-01'
                  END
                   AND vtp.excuseddate IS NOT NULL
                   AND tpv.tripstatusid = 170 THEN 1
                  ELSE 0
                END) AS txncntpriortozc,
                sum(CASE
                  WHEN CAST(  vtp.firstpaiddate as DATE) < COALESCE(cte_curr_inv.zipcashdate_ri, CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                  END)
                   AND vtp.firstpaiddate IS NOT NULL
                   AND vtp.vtollflag = 1 THEN 1
                  ELSE 0
                END) AS vtolltxncntpriortozc,
                sum(CASE
                  WHEN CAST(  vtp.firstpaiddate as DATE) < CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                    ELSE DATE '1900-01-01'
                  END
                   AND vtp.firstpaiddate IS NOT NULL
                   AND (tpv.paymentstatusid = 456
                   OR tpv.tripstatusid = 153
                   AND vtp.paymentstatusid = 456) THEN 1
                  WHEN CAST(  vtp.firstpaiddate as DATE) < CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                    ELSE DATE '1900-01-01'
                  END
                   AND tpv.tripstatusid = 170
                   AND vtp.actualpaidamount > 0 THEN 1
                  ELSE 0
                END) AS paidtxncntpriortozc,
                sum(CASE
                  WHEN CAST(  vtp.excuseddate as DATE) < CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                    ELSE DATE '1900-01-01'
                  END
                   AND vtp.excuseddate IS NOT NULL
                   AND tpv.tripstatusid = 170 THEN 1
                  ELSE 0
                END) AS excusedtxncntpriortozc,



                ca.nooftimessenttoprimary,
                ca.nooftimessenttosecondary,
                ----------------------------------------
                pmt.paymentchannel,
                pmt.pos,
                ca.primarycollectionagency,
                ca.secondarycollectionagency,

                ---------------------------------------- Amounts
                CAST(sum(CASE
                  WHEN custtxncategory IN(
                    'TOLL', 'FEE'
                  ) THEN il.amount
                  ELSE 0
                END) as NUMERIC) AS invoiceamount,
                CAST(sum(CASE
                  WHEN il.linksourcename = 'TOLLPLUS.TP_ViolatedTrips' THEN il.amount
                  ELSE 0
                END) as NUMERIC) AS tolls,
                CAST(COALESCE(f.fnfees, 0) as NUMERIC) AS fnfees,
                CAST(COALESCE(f.snfees, 0) as NUMERIC) AS snfees,
                CAST(CASE
                  WHEN COALESCE(cte_curr_inv.zipcashdate_ri, max(CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                  END)) >= DATE '2019-01-01' THEN pmt.tollspaid
                  ELSE COALESCE(tp.tollspaid, 0)
                END as NUMERIC) AS tollspaid, /* case statemnet logic is for migrated invoices payments which are actually showed as Adjustements in VTRT table. Pulling the actual payments from InvoicePayment table.EX:1151571794,792767240 */
                CAST(COALESCE(fp.fnfeespaid, 0) as NUMERIC) AS fnfeespaid,
                CAST(COALESCE(fp.snfeespaid, 0) as NUMERIC) AS snfeespaid,
                CAST(CASE
                  WHEN COALESCE(cte_curr_inv.zipcashdate_ri, max(CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                  END)) >= DATE '2019-01-01' THEN pmt.tollsadjusted
                  ELSE COALESCE(ta.tollsadjusted, 0)
                END as NUMERIC) AS tollsadjusted,  /* case statemnet logic is for migrated invoices payments which are actually showed as Adjustements in VTRT table. Pulling the actual payments from InvoicePayment table.EX:1151571794,792767240 */
			        --CAST(ISNULL(TA.TollsAdjusted,0) AS DECIMAL(19,2))   AS  TollsAdjusted,
                CAST(COALESCE(fa.fnfeesadjusted, 0) as NUMERIC) AS fnfeesadjusted,
                CAST(COALESCE(fa.snfeesadjusted, 0) as NUMERIC) AS snfeesadjusted,
                sum(CASE
                  WHEN tpv.tripstatusid = 170
                   AND tpv.paymentstatusid = 3852 THEN tpv.tollamount
                  ELSE 0
                END) AS excusedamount,
                sum(CASE
                  WHEN vtp.vtollflag = 1 THEN vtp.actualpaidamount
                  ELSE 0
                END) AS vtollamount,
                sum(CASE
                  WHEN CAST(  vtp.firstpaiddate as DATE) < CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                    ELSE DATE '1900-01-01'
                  END
                   AND vtp.firstpaiddate IS NOT NULL
                   AND (tpv.paymentstatusid = 456
                   OR tpv.tripstatusid = 153
                   OR tpv.paymentstatusid = 456) THEN vtp.tollamount
                  WHEN CAST(  vtp.excuseddate as DATE) < CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                    ELSE DATE '1900-01-01'
                  END
                   AND vtp.excuseddate IS NOT NULL
                   AND tpv.tripstatusid = 170 THEN vtp.tollamount
                  ELSE 0
                END) AS tollspriortozc,
                sum(CASE
                  WHEN CAST(  vtp.firstpaiddate as DATE) < CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                    ELSE DATE '1900-01-01'
                  END
                   AND vtp.vtollflag = 1 THEN COALESCE(vtp.actualpaidamount, vtp.tollamount)
                  ELSE 0
                END) AS vtollamountpriortozc,
                sum(CASE
                  WHEN CAST(  vtp.excuseddate as DATE) < CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                    ELSE DATE '1900-01-01'
                  END
                   AND vtp.excuseddate IS NOT NULL
                   AND tpv.tripstatusid = 170
                   AND tpv.paymentstatusid = 3852 THEN vtp.tollamount
                  ELSE 0
                END) AS excusedamountpriortozc,
                sum(CASE
                  WHEN CAST(  vtp.firstpaiddate as DATE) < CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                    ELSE DATE '1900-01-01'
                  END
                   AND vtp.firstpaiddate IS NOT NULL
                   AND (tpv.paymentstatusid = 456
                   OR tpv.tripstatusid = 153
                   AND tpv.paymentstatusid = 3852) THEN vtp.adjustedamount
                  WHEN CAST(  vtp.excuseddate as DATE) < CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                    ELSE DATE '1900-01-01'
                  END
                   AND vtp.excuseddate IS NOT NULL
                   AND tpv.tripstatusid = 170 THEN vtp.tollamount
                  ELSE 0
                END) AS tollsadjustedpriortozc,
                sum(CASE
                  WHEN CAST(  vtp.firstpaiddate as DATE) < COALESCE(cte_curr_inv.zipcashdate_ri, CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                  END)
                   AND (tpv.paymentstatusid = 456
                   OR tpv.tripstatusid = 153
                   AND vtp.paymentstatusid = 456) THEN vtp.actualpaidamount
                  WHEN CAST(  vtp.firstpaiddate as DATE) < COALESCE(cte_curr_inv.zipcashdate_ri, CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(  il.createddate as DATE)
                  END)
                   AND tpv.tripstatusid = 170
                   AND vtp.actualpaidamount > 0 THEN vtp.actualpaidamount
                  ELSE 0
                END) AS tollspaidpriortozc,
                COALESCE(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_update_date
              --SELECT *
              FROM
                EDW_TRIPS_STAGE.MigratedInvoice AS cte_curr_inv
                INNER JOIN cte_first_inv 
                  ON cte_curr_inv.invoicenumber = cte_first_inv.invoicenumber
                INNER JOIN cte_inv_date 
                  ON cte_curr_inv.invoicenumber = cte_inv_date.invoicenumber
                INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS il 
                  ON il.referenceinvoiceid = cte_curr_inv.invoicenumber
                  AND il.lnd_updatetype <> 'D'
                LEFT OUTER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS tpv 
                  ON abs(tpv.citationid) = abs(il.linkid)
                  AND linksourcename = 'TOLLPLUS.TP_ViolatedTrips'
                  AND tpv.lnd_updatetype <> 'D'
                  AND citationstage <> 'INVOICE'
                LEFT OUTER JOIN EDW_TRIPS.Dim_InvoiceStatus AS dis 
                  ON cte_curr_inv.invoicestatus = dis.invoicestatuscode
                LEFT OUTER JOIN EDW_TRIPS.Dim_InvoiceStage AS i 
                  ON cte_curr_inv.agestageid = i.invoicestageid
                LEFT OUTER JOIN (
                  SELECT
                      il_0.referenceinvoiceid AS invoicenumber, ---- To calculate Fees Due
                      COALESCE(sum(CASE
                        WHEN il_0.txntype = 'FSTNTVFEE' THEN ict.amount
                        ELSE 0
                      END), 0) AS fnfees,
                      COALESCE(sum(CASE
                        WHEN il_0.txntype = 'SECNTVFEE' THEN ict.amount
                        ELSE 0
                      END), 0) AS snfees
                    FROM
                      LND_TBOS.TollPlus_Invoice_LineItems AS il_0
                      INNER JOIN  LND_TBOS.TollPlus_Invoice_Charges_Tracker AS ict 
                        ON il_0.linkid = ict.invoicechargeid
                        AND ict.lnd_updatetype <> 'D'
                    WHERE il_0.linksourcename = 'TollPlus.Invoice_Charges_Tracker'
                     AND il_0.txntype IN(
                      'SECNTVFEE', 'FSTNTVFEE'
                    )
                     AND il_0.lnd_updatetype <> 'D'
                    GROUP BY il_0.referenceinvoiceid
                ) AS f 
                  ON cte_curr_inv.invoicenumber = f.invoicenumber

                LEFT OUTER JOIN (                                   ---------------------- TollsPaid
                  SELECT
                      il_0.referenceinvoiceid AS invoicenumber,
                      sum(CASE
                        WHEN il_0.sourceviolationstatus = 'L' THEN 0
                        ELSE COALESCE(vtrt.amountreceived * -1, 0)
                      END) AS tollspaid                                 -- select *
                    FROM
                      LND_TBOS.TollPlus_Invoice_LineItems AS il_0
                      INNER JOIN EDW_TRIPS_STAGE.MigratedInvoice AS ri ON ri.invoicenumber = il_0.referenceinvoiceid
                        AND il_0.linksourcename = 'TOLLPLUS.TP_ViolatedTrips'
                        AND il_0.linksourcename = 'TOLLPLUS.TP_ViolatedTrips'
                      INNER JOIN (
                        SELECT
                            vtrt_0.citationid,
                            vtrt_0.invoiceid,
                            sum(vtrt_0.amountreceived) AS amountreceived
                          FROM
                            LND_TBOS.Tollplus_TP_Violated_Trip_Receipts_Tracker AS vtrt_0
                          WHERE vtrt_0.linksourcename IN(
                            'FINANCE.PAYMENTTXNS'
                          )
                           AND vtrt_0.lnd_updatetype <> 'D'
                          GROUP BY citationid,
                                    vtrt_0.invoiceid
                      ) AS vtrt 
                        ON vtrt.citationid = abs(il_0.linkid)
                    --WHERE IL.ReferenceInvoiceID=1214359795
                    GROUP BY il_0.referenceinvoiceid
                ) AS tp ON tp.invoicenumber = cte_curr_inv.invoicenumber


                LEFT OUTER JOIN (                           ----------------------- FN & SN Fees Paid
                  SELECT
                      il_0.referenceinvoiceid,
                      min(irt.txndate) AS firstfeepaymentdate,
                      max(irt.txndate) AS lastfeepaymentdate,
                      COALESCE(sum(CASE
                        WHEN il_0.txntype = 'FSTNTVFEE' THEN irt.amountreceived * -1
                        ELSE 0
                      END), 0) AS fnfeespaid,
                      COALESCE(sum(CASE
                        WHEN il_0.txntype = 'SECNTVFEE' THEN irt.amountreceived * -1
                        ELSE 0
                      END), 0) AS snfeespaid
                    FROM
                      LND_TBOS.TollPlus_Invoice_LineItems AS il_0
                      INNER JOIN LND_TBOS.TollPlus_TP_Invoice_Receipts_Tracker AS irt 
                        ON il_0.linkid = irt.invoice_chargeid
                        AND irt.lnd_updatetype <> 'D'
                      INNER JOIN EDW_TRIPS_STAGE.MigratedInvoice AS ri 
                        ON ri.invoicenumber = il_0.referenceinvoiceid
                        AND irt.linksourcename = 'FINANCE.PAYMENTTXNS'
                    WHERE il_0.linksourcename = 'TOLLPLUS.Invoice_Charges_tracker'
                      AND il_0.lnd_updatetype <> 'D'
                      --AND IL.ReferenceInvoiceID=1236841109 (Invoice that has only Fee payments no toll payments	
									    --AND IL.ReferenceInvoiceID=1188125295
                    GROUP BY il_0.referenceinvoiceid
                ) AS fp ON fp.referenceinvoiceid = cte_curr_inv.invoicenumber

                LEFT OUTER JOIN (                                       ---------------------- TollsAdjusted
                  SELECT
                      il_0.referenceinvoiceid AS invoicenumber,
                      sum(CASE
                        WHEN vtrt.unassignedtxnflag = 1
                         AND il_0.sourceviolationstatus <> 'L' THEN 0
                        WHEN vtrt.unassignedtxnflag = 1
                         AND il_0.sourceviolationstatus = 'L'
                         AND vtrt.amountreceived * -1 = vtrt.citationcnt * il_0.amount THEN il_0.amount
                        WHEN vtrt.unassignedtxnflag = 1
                         AND il_0.sourceviolationstatus = 'L' THEN COALESCE(vtrt.amountreceived * -1, 0)
                        WHEN vtrt.unassignedtxnflag = 0
                         AND il_0.sourceviolationstatus = 'L' THEN 0
                        ELSE COALESCE(vtrt.amountreceived * -1, 0)
                      END) AS tollsadjusted -- select *
                    FROM
                      LND_TBOS.TollPlus_Invoice_LineItems AS il_0
                      INNER JOIN EDW_TRIPS_STAGE.MigratedInvoice AS ri 
                        ON ri.invoicenumber = il_0.referenceinvoiceid
                        AND il_0.linksourcename = 'TOLLPLUS.TP_ViolatedTrips'
                      INNER JOIN (
                        SELECT
                            abs(vtrt_0.citationid) AS citationid,
                            -- VTRT.InvoiceID InvoiceID,
                            count(abs(vtrt_0.citationid)) AS citationcnt,
                            CASE
                              WHEN vtrt_0.citationid < 0 THEN 1
                              ELSE 0
                            END AS unassignedtxnflag,
                            sum(COALESCE(vtrt_0.amountreceived, 0)) AS amountreceived -- select *
                          FROM
                            LND_TBOS.Tollplus_TP_Violated_Trip_Receipts_Tracker AS vtrt_0
                          WHERE vtrt_0.linksourcename IN(
                            'FINANCE.ADJUSTMENTS'
                          )
                           AND vtrt_0.lnd_updatetype <> 'D'
                          GROUP BY citationid, unassignedtxnflag
                          --VTRT.InvoiceID
                      ) AS vtrt 
                        ON vtrt.citationid = abs(il_0.linkid)
                    --WHERE IL.ReferenceInvoiceID=1188125295
                    GROUP BY il_0.referenceinvoiceid
                ) AS ta ON ta.invoicenumber = cte_curr_inv.invoicenumber

                LEFT OUTER JOIN (                     --- Bring the First and Second Notice Fee Adjustemnts to calculate the Invoice Status
                  SELECT
                      il_0.referenceinvoiceid,
                      COALESCE(sum(CASE
                        WHEN il_0.txntype = 'FSTNTVFEE' THEN amountreceived * -1
                        ELSE 0
                      END), 0) AS fnfeesadjusted,
                      COALESCE(sum(CASE
                        WHEN il_0.txntype = 'SECNTVFEE' THEN amountreceived * -1
                        ELSE 0
                      END), 0) AS snfeesadjusted
                    FROM
                      LND_TBOS.TollPlus_Invoice_LineItems AS il_0
                      INNER JOIN LND_TBOS.TollPlus_TP_Invoice_Receipts_Tracker AS irt 
                        ON il_0.linkid = irt.invoice_chargeid
                        AND irt.lnd_updatetype <> 'D'
                      INNER JOIN EDW_TRIPS_STAGE.MigratedInvoice AS ri 
                        ON ri.invoicenumber = il_0.referenceinvoiceid
                    WHERE irt.linksourcename = 'FINANCE.ADJUSTMENTS'
                     AND il_0.txntype IN(
                      'SECNTVFEE', 'FSTNTVFEE'
                    )
                     AND il_0.linksourcename = 'TOLLPLUS.invoice_Charges_tracker'
                     AND il_0.lnd_updatetype <> 'D'
                     --AND IL.ReferenceInvoiceID=1188125295
                    GROUP BY il_0.referenceinvoiceid
                ) AS fa ON fa.referenceinvoiceid = cte_curr_inv.invoicenumber


                LEFT OUTER JOIN (                 --------------- PaymentPlanID
                  SELECT DISTINCT
                      mbsi.invoicenumber,
                      pp_0.paymentplanid,
                      mbsi.mbsid
                    FROM
                      LND_TBOS.TollPlus_MbsInvoices AS mbsi
                      INNER JOIN LND_TBOS.TER_PaymentPlanViolator AS ppvt 
                        ON ppvt.mbsid = mbsi.mbsid
                      INNER JOIN EDW_TRIPS.Fact_PaymentPlan AS pp_0 
                        ON pp_0.mbsid = mbsi.mbsid
                        AND pp_0.paymentplanstatusid = 48
                ) AS pp ON pp.invoicenumber = cte_curr_inv.invoicenumber
                LEFT OUTER JOIN EDW_TRIPS_STAGE.InvoicePayment AS pmt ON CAST(pmt.invoicenumber AS STRING)  = cte_curr_inv.invoicenumber
                LEFT OUTER JOIN EDW_TRIPS_STAGE.CAMigratedNonTerminalInvoice AS ca ON ca.invoicenumber = cte_curr_inv.invoicenumber
                LEFT OUTER JOIN EDW_TRIPS_STAGE.violtrippayment AS vtp ON vtp.citationid = abs(tpv.citationid)
                --WHERE CAST(CTE_CURR_INV.InvoiceNumber AS BIGINT) = 1188125295
              
              GROUP BY invoicenumber, --CAST( cte_curr_inv.invoicenumber AS INT64)
                        migratedflag,
                        collectionstatusid,  -- coalesce(cte_curr_inv.collectionstatus, -1),
                        currmbsid,           -- coalesce(cte_inv_date.mbsid, -1)
                        cte_curr_inv.zipcashdate_ri,
                        cte_inv_date.firstnoticedate,
                        cte_inv_date.secondnoticedate,
                        cte_inv_date.thirdnoticedate,
                        cte_inv_date.legalactionpendingdate,
                        cte_inv_date.citationdate,
                        cte_inv_date.duedate,
                        currmbsgenerateddate, -- coalesce(cte_inv_date.mbsgenerateddate, CAST('1900-01-01' AS DATETIME))
                        firstpaymentdatepriortozc, --COALESCE(cte_curr_inv.firstpaymentdatepriortozc_ri, pmt.firstpaymentdatepriortozc), 
                        lastpaymentdatepriortozc, --COALESCE(cte_curr_inv.lastpaymentdatepriortozc_ri, pmt.lastpaymentdatepriortozc), 
                        firstpaymentdateafterzc, --COALESCE(cte_curr_inv.firstpaymentdateafterzc_ri, pmt.firstpaymentdateafterzc), 
                        lastpaymentdateafterzc, --COALESCE(cte_curr_inv.lastpaymentdateafterzc_ri, pmt.lastpaymentdateafterzc), 
                        fp.firstfeepaymentdate,
                        fp.lastfeepaymentdate, 
                        ca.primarycollectionagencydate,
                        ca.secondarycollectionagencydate,
                        ca.nooftimessenttoprimary,
                        ca.nooftimessenttosecondary,
                        pp.paymentplanid,
                        -------------------------------------------------
                        pmt.paymentchannel, 
                        pmt.pos,
                        ca.primarycollectionagency,
                        ca.secondarycollectionagency, 
                        /*fnfees,*/  COALESCE(f.fnfees, 0), 
                        /*snfees,*/COALESCE(f.snfees, 0), 
                        tp.tollspaid, --COALESCE(tp.tollspaid, 0), 
                        /*fnfeespaid,*/           COALESCE(fp.fnfeespaid, 0),
                        /*snfeespaid, */          coalesce(fp.snfeespaid, 0),
                        /*tollsadjusted,*/       coalesce(ta.tollsadjusted, 0),
                        /*fnfeesadjusted, */     coalesce(fa.fnfeesadjusted, 0),
                        /*snfeesadjusted,  */    coalesce(fa.snfeesadjusted, 0),
                        ta.tollsadjusted, 
                        pmt.tollsadjusted, 
                        pmt.tollspaid, 
                        cte_first_inv.invoiceid,
                        cte_curr_inv.invoiceid,
                        cte_curr_inv.customerid,
                        cte_curr_inv.agestageid,
                        cte_curr_inv.vehicleid,
                        dis.invoicestatusid
          );
          
      CREATE TEMPORARY TABLE _SESSION.cte_tolls AS (
            SELECT
                a.referenceinvoiceid,
                sum(a.invoiceamount) AS invoiceamount,
                sum(a.tolls) AS tolls,
                sum(a.pbmtollamount) AS pbmtollamount,
                sum(a.avitollamount) AS avitollamount,
                sum(a.pbmtollamount - a.avitollamount) AS premiumamount
              FROM
                (
                  SELECT
                      il.referenceinvoiceid,
                      CASE
                        WHEN vt.tptripid IS NULL THEN COALESCE(abs(il.linkid), 0)
                        ELSE vt.tptripid
                      END AS tptripid,
                      count(CASE
                        WHEN vt.tptripid IS NULL THEN COALESCE(abs(il.linkid), 0)
                        ELSE vt.tptripid
                      END) AS txncnt,
                      CASE
                        WHEN count(vt.tptripid) = 1 THEN sum(CASE
                          WHEN custtxncategory IN(
                            'TOLL', 'FEE'
                          ) THEN il.amount
                          ELSE 0
                        END)
                        WHEN COALESCE(count(DISTINCT vt.tptripid), 0) <> COALESCE(count(vt.tptripid), 0)
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            171, 170, 118, 115
                          ) THEN 1
                          ELSE 0
                        END) > 0 THEN sum(CASE
                          WHEN custtxncategory IN(
                            'TOLL', 'FEE'
                          ) THEN il.amount
                          ELSE 0
                        END)
                        WHEN COALESCE(count(DISTINCT vt.tptripid), 0) <> COALESCE(count(vt.tptripid), 0)
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            2, 153, 154
                          ) THEN 1
                          ELSE 0
                        END) > 1
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            171, 170, 118, 115
                          ) THEN 1
                          ELSE 0
                        END) = 0 THEN div(sum(CASE
                          WHEN custtxncategory IN(
                            'TOLL', 'FEE'
                          ) THEN il.amount
                          ELSE 0
                        END), count(vt.tptripid))
                        WHEN COALESCE(count(vt.tptripid), 0) = 0 THEN sum(CASE
                          WHEN custtxncategory IN(
                            'TOLL', 'FEE'
                          ) THEN il.amount
                          ELSE 0
                        END)
                        ELSE 0
                      END AS invoiceamount,
                      CASE
                        WHEN count(vt.tptripid) = 1 THEN sum(CASE
                          WHEN il.linksourcename = 'TOLLPLUS.TP_ViolatedTrips' THEN il.amount
                          ELSE 0
                        END)
                        WHEN count(COALESCE(vt.tptripid, 0)) = 0 THEN sum(CASE
                          WHEN il.linksourcename = 'TOLLPLUS.TP_ViolatedTrips' THEN il.amount
                          ELSE 0
                        END)
                        WHEN COALESCE(count(DISTINCT vt.tptripid), 0) <> COALESCE(count(vt.tptripid), 0)
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            171, 170, 118, 115
                          ) THEN 1
                          ELSE 0
                        END) > 0 THEN sum(CASE
                          WHEN il.linksourcename = 'TOLLPLUS.TP_ViolatedTrips' THEN il.amount
                          ELSE 0
                        END)
                        WHEN COALESCE(count(DISTINCT vt.tptripid), 0) <> COALESCE(count(vt.tptripid), 0)
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            2, 153, 154
                          ) THEN 1
                          ELSE 0
                        END) > 1
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            171, 170, 118, 115
                          ) THEN 1
                          ELSE 0
                        END) = 0 THEN div(sum(CASE
                          WHEN il.linksourcename = 'TOLLPLUS.TP_ViolatedTrips' THEN il.amount
                          ELSE 0
                        END), count(vt.tptripid))
                        WHEN COALESCE(count(vt.tptripid), 0) = 0 THEN sum(CASE
                          WHEN il.linksourcename = 'TOLLPLUS.TP_ViolatedTrips' THEN il.amount
                          ELSE 0
                        END)
                        ELSE 0
                      END AS tolls,
                      CASE
                        WHEN count(vt.tptripid) = 1 THEN sum(vt.pbmtollamount)
                        WHEN COALESCE(count(DISTINCT vt.tptripid), 0) <> COALESCE(count(vt.tptripid), 0)
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            171, 170, 118, 115
                          ) THEN 1
                          ELSE 0
                        END) > 0 THEN sum(vt.pbmtollamount)
                        WHEN COALESCE(count(DISTINCT vt.tptripid), 0) <> COALESCE(count(vt.tptripid), 0)
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            2, 153, 154
                          ) THEN 1
                          ELSE 0
                        END) > 1
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            171, 170, 118, 115
                          ) THEN 1
                          ELSE 0
                        END) = 0 THEN div(sum(vt.pbmtollamount), count(vt.tptripid))
                        ELSE 0
                      END AS pbmtollamount,
                      CASE
                        WHEN count(vt.tptripid) = 1 THEN sum(vt.avitollamount)
                        WHEN COALESCE(count(DISTINCT vt.tptripid), 0) <> COALESCE(count(vt.tptripid), 0)
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            171, 170, 118, 115
                          ) THEN 1
                          ELSE 0
                        END) > 0 THEN sum(vt.avitollamount)
                        WHEN COALESCE(count(DISTINCT vt.tptripid), 0) <> COALESCE(count(vt.tptripid), 0)
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            2, 153, 154
                          ) THEN 1
                          ELSE 0
                        END) > 1
                         AND sum(CASE
                          WHEN vt.tripstatusid IN(
                            171, 170, 118, 115
                          ) THEN 1
                          ELSE 0
                        END) = 0 THEN div(sum(vt.avitollamount), count(vt.tptripid))
                        ELSE 0
                      END AS avitollamount
                    FROM
                      EDW_TRIPS_STAGE.MigratedInvoice AS ri
                      INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS il 
                        ON ri.invoicenumber = il.referenceinvoiceid
                      LEFT OUTER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt 
                        ON abs(il.linkid) = vt.citationid
                        AND il.custtxncategory = 'TOLL'
                      --WHERE IL.ReferenceInvoiceID=1188125295
                    GROUP BY il.referenceinvoiceid, tptripid
                ) AS a
              GROUP BY a.referenceinvoiceid
          );

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.NonTerminalInvoice 
      AS
          SELECT
              mi.invoicenumber,
              mi.firstinvoiceid,
              mi.currentinvoiceid,
              mi.customerid,
              mi.migratedflag,
              CASE
                WHEN mi.txncntpriortozc > 0 THEN 1
                ELSE 0
              END AS txnpriortozcflag,
              mi.agestageid,
              mi.collectionstatusid,
              mi.currmbsid,
              mi.vehicleid,
              mi.invoicestatusid,
              mi.paymentplanid,
              mi.zipcashdate,
              mi.firstnoticedate,
              mi.secondnoticedate,
              mi.thirdnoticedate,
              mi.legalactionpendingdate,
              mi.citationdate,
              mi.duedate,
              mi.currmbsgenerateddate,
              --MI.FirstPaymentDate,
					    --MI.LastPaymentDate,
              mi.firstpaymentdatepriortozc,
              mi.lastpaymentdatepriortozc,
              mi.firstpaymentdateafterzc,
              mi.lastpaymentdateafterzc,
              mi.firstfeepaymentdate,
              mi.lastfeepaymentdate,
              mi.primarycollectionagencydate,
              mi.secondarycollectionagencydate,
              mi.txncnt,
              mi.excusedtxncnt,
              mi.unassignedtxncnt,
              mi.vtolltxncnt,
              mi.paidtxncnt,
              mi.txncntpriortozc,
              mi.vtolltxncntpriortozc,
              mi.excusedtxncntpriortozc,
              mi.paidtxncntpriortozc,
              mi.nooftimessenttoprimary,
              mi.nooftimessenttosecondary,
              mi.paymentchannel,
              mi.pos,
              mi.primarycollectionagency,
              mi.secondarycollectionagency,
              CAST(CASE
                WHEN vt.vtollflag = 1 THEN vt.tolls + mi.fnfees + mi.snfees 
                ELSE t.invoiceamount
              END as NUMERIC) AS invoiceamount,
              CAST(CASE
                WHEN vt.vtollflag = 1 THEN vt.pbmtollamount
                ELSE t.pbmtollamount
              END as NUMERIC) AS pbmtollamount,
              CAST(CASE
                WHEN vt.vtollflag = 1 THEN vt.avitollamount
                ELSE t.avitollamount
              END as NUMERIC) AS avitollamount,
              CAST(CASE
                WHEN vt.vtollflag = 1 THEN vt.premiumamount
                ELSE t.premiumamount
              END as NUMERIC) AS premiumamount,
              CAST(mi.excusedamount as NUMERIC) AS excusedamount,
              CAST(mi.vtollamount as NUMERIC) AS vtollamount,
              CAST(CASE
                WHEN vt.vtollflag = 1 THEN vt.tolls
                ELSE t.tolls
              END as NUMERIC) AS tolls,
              mi.fnfees AS fnfees,
              mi.snfees AS snfees,
              CASE
                WHEN vt.vtollflag = 1 THEN CAST(vt.paidamount_vt as BIGNUMERIC)
                ELSE COALESCE(mi.tollspaid, 0)
              END AS tollspaid,
              mi.fnfeespaid AS fnfeespaid,
              mi.snfeespaid AS snfeespaid,
              CASE
                WHEN mi.zipcashdate >= DATE '2019-01-01' THEN COALESCE(mi.tollsadjusted, 0)
                ELSE CASE
                  WHEN vt.vtollflag = 1 THEN vt.tollsadjusted
                  ELSE COALESCE(mi.tollsadjusted, 0)
                END
              END AS tollsadjusted,
              mi.fnfeesadjusted AS fnfeesadjusted,
              mi.snfeesadjusted AS snfeesadjusted,
              CAST(mi.excusedamountpriortozc as NUMERIC) AS excusedamountpriortozc,
              CAST(mi.vtollamountpriortozc as NUMERIC) AS vtollamountpriortozc,
              CAST(mi.tollspriortozc as NUMERIC) AS tollspriortozc,
              CAST(mi.tollsadjustedpriortozc as NUMERIC) AS tollsadjustedpriortozc,
              CAST(mi.tollspaidpriortozc as NUMERIC) AS tollspaidpriortozc,
              mi.edw_update_date
            FROM
              mi
              INNER JOIN cte_tolls AS t 
                ON SAFE_CAST(t.referenceinvoiceid AS INT64) = mi.invoicenumber
              LEFT OUTER JOIN EDW_TRIPS_STAGE.MigratedDimissedVToll AS vt 
                ON SAFE_CAST(vt.invoicenumber AS INT64) = mi.invoicenumber 
      ;


      SET log_message = 'Loaded EDW_TRIPS_STAGE.NonTerminalInvoice';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');
      

      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.NonTerminalInvoice' AS tablename,
            NonTerminalInvoice.*
          FROM
            EDW_TRIPS_STAGE.NonTerminalInvoice
        ORDER BY 2 DESC
        LIMIT 100
        ;
      END IF;

      --=============================================================================================================
      -- Load EDW_TRIPS_STAGE.MigratedNonTerminalInvoice
      --=============================================================================================================

      CREATE TEMPORARY TABLE _SESSION.cte_main AS (
            SELECT
                mi.invoicenumber,
                mi.firstinvoiceid,
                mi.currentinvoiceid,
                mi.customerid,
                mi.migratedflag,
                CASE
                  WHEN mi.vtolltxncnt - mi.vtolltxncntpriortozc = mi.txncnt - mi.txncntpriortozc THEN 1
                  ELSE COALESCE(vt.vtollflag, -1)
                END AS vtollflag,
                CASE
                  WHEN ui.invoicenumber IS NOT NULL THEN 1
                  ELSE -1
                END AS unassignedflag,
                mi.txnpriortozcflag,
                mi.agestageid,
                mi.collectionstatusid,
                mi.currmbsid,
                mi.vehicleid,
                mi.invoicestatusid,
                mi.paymentplanid,
                mi.zipcashdate,
                mi.firstnoticedate,
                mi.secondnoticedate,
                mi.thirdnoticedate,
                mi.legalactionpendingdate,
                mi.citationdate,
                mi.duedate,
                mi.currmbsgenerateddate,
                mi.firstpaymentdatepriortozc,
                mi.lastpaymentdatepriortozc,
                COALESCE(CAST(CASE
                  WHEN COALESCE(vt.vtollflag, -1) = 1
                   AND vt.firstpaymentdate > mi.zipcashdate THEN COALESCE(vt.firstpaymentdate, CAST('1900-01-01' as DATE)) 
                  WHEN COALESCE(vt.vtollflag, -1) = 1
                   AND vt.firstpaymentdate > mi.zipcashdate
                   AND vt.paidamount_vt = 0
                   AND vt.tolls = CASE
                    WHEN COALESCE(vt.vtollflag, -1) = 1 THEN vt.tollsadjusted + vt.tollsadjustedaftervtoll + vt.adjustedamount_excused + vt.classadj
                    ELSE mi.tollsadjusted
                  END THEN '1900-01-01'  -- This is because paid date is taken from customer trips posted date. eventhough there is no payment(tollspaid=0), there will be a posted date for that invoice
                END as DATE), CASE
                  WHEN COALESCE(vt.vtollflag, -1) = 0
                   AND vt.firstpaymentdate > mi.zipcashdate THEN COALESCE(CAST(COALESCE(vt.firstpaymentdate,'1900-01-01') as DATE), CAST(COALESCE(mi.firstpaymentdateafterzc, '1900-01-01') as DATE))
                  ELSE CAST(COALESCE(mi.firstpaymentdateafterzc, '1900-01-01') as DATE)
                END) AS firstpaymentdateafterzc,
                COALESCE(CAST(CASE
                  WHEN COALESCE(vt.vtollflag, -1) = 1
                   AND vt.firstpaymentdate > mi.zipcashdate THEN COALESCE(vt.lastpaymentdate, CAST('1900-01-01' as DATE))
                  WHEN COALESCE(vt.vtollflag, -1) = 1
                   AND vt.paidamount_vt = 0
                   AND vt.tolls = CASE
                    WHEN COALESCE(vt.vtollflag, -1) = 1 THEN vt.tollsadjusted + vt.tollsadjustedaftervtoll + vt.adjustedamount_excused + vt.classadj
                    ELSE mi.tollsadjusted
                  END THEN '1900-01-01'   -- This is because paid date is taken from customer trips posted date. eventhough there is no payment(tollspaid=0), there will be a posted date for that invoice
                END as DATE), CASE
                  WHEN COALESCE(vt.vtollflag, -1) = 0
                   AND vt.firstpaymentdate > mi.zipcashdate THEN COALESCE(CAST(COALESCE(vt.lastpaymentdate,'1900-01-01') as DATE), CAST(COALESCE(mi.lastpaymentdateafterzc, '1900-01-01') as DATE))
                  ELSE CAST(COALESCE(mi.lastpaymentdateafterzc, '1900-01-01') as DATE)
                END) AS lastpaymentdateafterzc,
                mi.firstfeepaymentdate,
                mi.lastfeepaymentdate,
                mi.primarycollectionagencydate,
                mi.secondarycollectionagencydate,
                -------------TxnCounts
                mi.txncntpriortozc,
                mi.vtolltxncntpriortozc,
                mi.paidtxncntpriortozc,
                mi.excusedtxncntpriortozc,
                mi.txncnt - mi.txncntpriortozc AS txncntafterzc,
                mi.vtolltxncnt - mi.vtolltxncntpriortozc AS vtolltxncntafterzc,
                mi.paidtxncnt - mi.paidtxncntpriortozc AS paidtxncntafterzc,
                mi.excusedtxncnt - mi.excusedtxncntpriortozc AS excusedtxncntafterzc,
                mi.txncnt,
                mi.excusedtxncnt,
                mi.unassignedtxncnt,
                vt.vtolltxncnt,
                mi.paidtxncnt,



                mi.nooftimessenttoprimary,
                mi.nooftimessenttosecondary,
                mi.paymentchannel,
                mi.pos,
                mi.primarycollectionagency,
                mi.secondarycollectionagency,


                mi.invoiceamount,
                mi.pbmtollamount,
                mi.avitollamount,
                mi.premiumamount,


                ------- EA
                mi.vtollamountpriortozc,
                --(VtollAmount - VtollAmountPriortoZC) VtollAmountAfterZC,
                mi.vtollamount,
                mi.excusedamountpriortozc,
                --(ExcusedAmount-ExcusedAmountPriortoZC) ExcusedAmountAfterZC,
                mi.excusedamount,
                mi.tollspriortozc,
                mi.tolls - mi.tollspriortozc AS tollsafterzc,
                mi.tolls,
                mi.fnfees,
                mi.snfees,
                mi.tolls + mi.fnfees + mi.snfees AS expectedamount,



                ------- AA
                mi.tollsadjustedpriortozc,
                --  (( CAST(CASE WHEN VT.VtollFlag=0 AND MI.TollsAdjusted=0 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+ISNULL (MI.TollsAdjusted,0) -- This is for the vtoll adjustments that is not coming from  VTRT.Tolladj table, so bringing it from Customer trips table for vtoll adj.Ex:1230002032
                --	WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 AND (VT.PaidAmount_VT) > ISNULL (MI.TollsAdjusted,0) THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+((VT.PaidAmount_VT)-ISNULL(MI.TollsAdjusted,0))+ISNULL(MI.ExcusedAmount,0) -- this condition is for credit adjustment and amount that is not coming from VTRT table ex:1234440179 
                --	WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 THEN ISNULL(MI.TollsAdjusted,0)-(VT.PaidAmount_VT)-- this is for adjustments that happened in VTRT table and vtoll adj (In order to avoid double adjustments from two tables. Ex:1225411445)
                --	ELSE ISNULL(MI.TollsAdjusted,0)
                --	END AS DECIMAL(19,2)))
                --- 
                --   TollsAdjustedPriortoZC) AS TollsAdjustedAfterZC,

                --       CAST(CASE WHEN VT.VtollFlag=0 AND MI.TollsAdjusted=0 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+ISNULL (MI.TollsAdjusted,0) -- This is for the vtoll adjustments that is not coming from  VTRT.Tolladj table, so bringing it from Customer trips table for vtoll adj.Ex:1230002032
                    --WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 AND (VT.PaidAmount_VT) > ISNULL (MI.TollsAdjusted,0) THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+((VT.PaidAmount_VT)-ISNULL(MI.TollsAdjusted,0))+ISNULL(MI.ExcusedAmount,0) -- this condition is for credit adjustment and amount that is not coming from VTRT table ex:1234440179 
                    --WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 THEN ISNULL(MI.TollsAdjusted,0)-(VT.PaidAmount_VT)-- this is for adjustments that happened in VTRT table and vtoll adj (In order to avoid double adjustments from two tables. Ex:1225411445)
                    --ELSE ISNULL(MI.TollsAdjusted,0)
                -- END AS DECIMAL(19,2)) AS TollsAdjusted,

                COALESCE(mi.tollsadjusted, 0) AS tollsadjusted,

                mi.fnfeesadjusted AS fnfeesadjusted,
                mi.snfeesadjusted AS snfeesadjusted,

                COALESCE(mi.tollsadjusted, 0) + mi.fnfeesadjusted + mi.snfeesadjusted AS adjustedamount,
                --------- AEA
                ---------- AET = ET-TA
                ---------- AETPriortoZC
                mi.tollspriortozc - mi.tollsadjustedpriortozc AS adjustedexpectedtollspriortozc,

                --  ---------- AETAfterZC
                --  ((CAST((MI.Tolls - 
                  --				 CASE WHEN VT.VtollFlag=0 AND MI.TollsAdjusted=0 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+ISNULL (MI.TollsAdjusted,0) -- This is for the vtoll adjustments that is not coming from  VTRT.Tolladj table, so bringing it from Customer trips table for vtoll adj.Ex:1230002032
                  --				 WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 AND (VT.PaidAmount_VT) > ISNULL (MI.TollsAdjusted,0) THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+((VT.PaidAmount_VT)-ISNULL(MI.TollsAdjusted,0))+ISNULL(MI.ExcusedAmount,0) -- this condition is for credit adjustment and amount that is not coming from VTRT table ex:1234440179 
                  --				 WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 THEN ISNULL(MI.TollsAdjusted,0)-(VT.PaidAmount_VT)-- this is for adjustments that happened in VTRT table and vtoll adj (In order to avoid double adjustments from two tables. Ex:1225411445)
                  --				 ELSE ISNULL(MI.TollsAdjusted,0) END ) AS DECIMAL(19,2)) )
                  -- - 
                  --  (MI.TollsPriortoZC - TollsAdjustedPriortoZC))
                  --AS AdjustedExpectedTollsAfterZC,
                mi.tolls - COALESCE(mi.tollsadjusted, 0) AS adjustedexpectedtolls,
                ---------- AEFn = EFn-FnA
                mi.fnfees - mi.fnfeesadjusted AS adjustedexpectedfnfees,
                ---------- AESn = ESn-SnA
                mi.snfees - mi.snfeesadjusted AS adjustedexpectedsnfees,

                ------- AEA = EA-AA
                mi.tolls - COALESCE(mi.tollsadjusted, 0) + (mi.fnfees - mi.fnfeesadjusted) + (mi.snfees - mi.snfeesadjusted) AS adjustedexpectedamount,



                ------- PA
                mi.tollspaidpriortozc,
                --  ((CAST(CASE    WHEN VtollFlag=1 THEN  VT.PaidAmount_VT
                  --		WHEN VtollFlag=0 THEN (VT.PaidAmount_VT)+ISNULL((MI.TollsPaid),0)
                  --					  ELSE ISNULL((MI.TollsPaid),0) 
                  --END AS DECIMAL(19,2)) )					-
                  -- MI.TollsPaidPriortoZC ) TollsPaidAfterZC,

              --        CAST(CASE    WHEN VtollFlag=1 THEN  VT.PaidAmount_VT
                  --			WHEN VtollFlag=0 THEN (VT.PaidAmount_VT)+ISNULL((MI.TollsPaid),0)
                  --	ELSE ISNULL((MI.TollsPaid),0) 
                  --	END AS DECIMAL(19,2))  
                  --AS TollsPaid,

                mi.tollspaid AS tollspaid,
                mi.fnfeespaid AS fnfeespaid,
                mi.snfeespaid AS snfeespaid,
                mi.tollspaid + mi.fnfeespaid + mi.snfeespaid AS paidamount,



                -------- OA
                CAST(CASE
                  WHEN mi.txnpriortozcflag = 1 THEN CAST(mi.tollspriortozc - mi.tollsadjustedpriortozc - mi.tollspriortozc as INT64)
                  ELSE 0
                END as NUMERIC) AS tolloutstandingamountpriortozc,
                      -------- TO = AEA-TP
                CASE
                  WHEN vt.vtollflag = 1 THEN vt.outstandingamount
                  ELSE (----- AET=ET-TA 
                      (mi.tolls - 
                            COALESCE(mi.tollsadjusted, 0) )
                            -  ------PA
                            mi.tollspaid
                      )
                END AS tolloutstandingamount,

                          ------ FnO = AEFn-FnP
                mi.fnfees - mi.fnfeesadjusted - mi.fnfeespaid AS fnfeesoutstandingamount,
                mi.snfees - mi.snfeesadjusted - mi.snfeespaid AS snfeesoutstandingamount,
                          ----- OA = AEA-OA
                CASE
                  WHEN vt.vtollflag = 1 THEN vt.outstandingamount
                  ELSE 
                    (----- AET=ET-TA
                    (mi.tolls - 
                        COALESCE(mi.tollsadjusted, 0) )
                      - ------PA
                      COALESCE(mi.tollspaid, 0)
                    )
                END + (mi.fnfees - mi.fnfeesadjusted - mi.fnfeespaid) + (mi.snfees - mi.snfeesadjusted - mi.snfeespaid) AS outstandingamount  -- select * 
              FROM
                EDW_TRIPS_STAGE.NonTerminalInvoice AS mi
                LEFT OUTER JOIN EDW_TRIPS_STAGE.MigratedDimissedVToll AS vt 
                  ON vt.invoicenumber = cast(mi.invoicenumber as string)
                LEFT OUTER JOIN EDW_TRIPS_STAGE.MigratedUnassignedInvoice AS ui 
                  ON ui.invoicenumber = cast(mi.invoicenumber as string)
                --WHERE MI.InvoiceNumber=1214359795
			          --WHERE MI.InvoiceNumber=1110124206
          );

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.MigratedNonTerminalInvoice
        AS
          SELECT
              cte_main.invoicenumber,
              cte_main.firstinvoiceid,
              cte_main.currentinvoiceid,
              cte_main.customerid,
              cte_main.migratedflag,
              cte_main.vtollflag,
              cte_main.unassignedflag,
              cte_main.txnpriortozcflag,
              cte_main.agestageid,
              cte_main.collectionstatusid,
              cte_main.currmbsid,
              cte_main.vehicleid,
              cte_main.invoicestatusid,
              CASE
                WHEN COALESCE(cte_main.vtollflag, -1) = 1 THEN 99999
                WHEN cte_main.unassignedflag = 1
                 AND (cte_main.fnfeesoutstandingamount = 0
                 AND cte_main.snfeesoutstandingamount = 0) THEN 99998
                WHEN COALESCE(cte_main.vtollflag, -1) IN(
                  0, -1
                )
                 AND cte_main.unassignedflag = -1
                 AND cte_main.expectedamount - cte_main.adjustedamount = cte_main.paidamount
                 AND cte_main.expectedamount - cte_main.adjustedamount > 0
                 AND cte_main.fnfeespaid + cte_main.fnfeesadjusted = cte_main.fnfees
                 AND cte_main.snfeespaid + cte_main.snfeesadjusted = cte_main.snfees THEN 516
                WHEN COALESCE(cte_main.vtollflag, -1) IN(
                  0, -1
                )
                 AND cte_main.unassignedflag = -1
                 AND cte_main.paidamount > 0
                 AND cte_main.expectedamount - cte_main.adjustedamount > cte_main.paidamount
                 OR cte_main.tollspaid > 0 THEN 515
                WHEN COALESCE(cte_main.vtollflag, -1) = -1
                 AND cte_main.unassignedflag = -1
                 AND (cte_main.paidamount = 0
                 OR cte_main.paidamount < 0)
                 AND cte_main.expectedamount - cte_main.adjustedamount > 0
                 AND cte_main.expectedamount > cte_main.adjustedamount THEN 4370
                WHEN COALESCE(cte_main.vtollflag, -1) = -1
                 AND cte_main.unassignedflag = -1
                 AND cte_main.paidamount = 0
                 AND cte_main.adjustedamount = cte_main.expectedamount THEN 4434
                ELSE -1
              END AS edw_invoicestatusid,
              CASE
                WHEN cte_main.txnpriortozcflag = 1
                 AND cte_main.unassignedflag = 1
                 AND (cte_main.fnfeesoutstandingamount = 0
                 AND cte_main.snfeesoutstandingamount = 0) THEN 99998
                WHEN cte_main.txnpriortozcflag = 1
                 AND cte_main.vtollflag = 1
                 AND cte_main.vtolltxncntpriortozc = cte_main.txncntpriortozc
                 AND cte_main.txncntafterzc = 0 THEN 4434
                WHEN cte_main.txnpriortozcflag = 1
                 AND cte_main.vtollflag = 1
                 AND cte_main.vtolltxncnt - cte_main.vtolltxncntpriortozc = cte_main.txncnt - cte_main.txncntpriortozc THEN 99999
                WHEN cte_main.txnpriortozcflag = 1
                 AND cte_main.tolls - cte_main.tollspriortozc = cte_main.tollspaid - cte_main.tollspaidpriortozc
                 AND cte_main.expectedamount - cte_main.tollspriortozc - (cte_main.adjustedamount - cte_main.tollsadjustedpriortozc) = cte_main.paidamount - cte_main.tollspaidpriortozc
                 AND cte_main.expectedamount - cte_main.tollspriortozc - (cte_main.adjustedamount - cte_main.tollsadjustedpriortozc) > 0
                 AND cte_main.vtolltxncntafterzc <> cte_main.txncntafterzc
                 AND cte_main.fnfeespaid + cte_main.fnfeesadjusted = cte_main.fnfees
                 AND cte_main.snfeespaid + cte_main.snfeesadjusted = cte_main.snfees THEN 516
                WHEN cte_main.txnpriortozcflag = 1
                 AND cte_main.paidamount - cte_main.tollspaidpriortozc > 0
                 AND cte_main.expectedamount - cte_main.tollspriortozc - (cte_main.adjustedamount - cte_main.tollsadjustedpriortozc) > cte_main.paidamount - cte_main.tollspaidpriortozc
                 AND cte_main.vtollflag <> 1 THEN 515
                WHEN cte_main.txnpriortozcflag = 1
                 AND (cte_main.paidamount - cte_main.tollspaidpriortozc = 0
                 OR cte_main.paidamount - cte_main.tollspaidpriortozc < 0)
                 AND cte_main.expectedamount - cte_main.tollspriortozc - (cte_main.adjustedamount - cte_main.tollsadjustedpriortozc) > 0
                 AND cte_main.expectedamount - cte_main.tollspriortozc > cte_main.adjustedamount - cte_main.tollsadjustedpriortozc THEN 4370
                WHEN cte_main.txnpriortozcflag = 1
                 AND cte_main.paidamount - cte_main.tollspaidpriortozc = 0
                 AND cte_main.adjustedamount - cte_main.tollsadjustedpriortozc = cte_main.expectedamount - cte_main.tollspriortozc THEN 4434
                ELSE -1
              END AS edw_invoicestatusidafterzc,
              cte_main.paymentplanid,
              cte_main.zipcashdate,
              cte_main.firstnoticedate,
              cte_main.secondnoticedate,
              cte_main.thirdnoticedate,
              cte_main.legalactionpendingdate,
              cte_main.citationdate,
              cte_main.duedate,
              cte_main.currmbsgenerateddate,
              cte_main.firstpaymentdatepriortozc,
              cte_main.lastpaymentdatepriortozc,
              cte_main.firstpaymentdateafterzc,
              cte_main.lastpaymentdateafterzc,
              cte_main.firstfeepaymentdate,
              cte_main.lastfeepaymentdate,
              cte_main.primarycollectionagencydate,
              cte_main.secondarycollectionagencydate,
              cte_main.txncntpriortozc,
              cte_main.vtolltxncntpriortozc,
              cte_main.paidtxncntpriortozc,
              cte_main.excusedtxncntpriortozc,
              cte_main.txncntafterzc,
              cte_main.vtolltxncntafterzc,
              cte_main.paidtxncntafterzc,
              cte_main.excusedtxncntafterzc,
              cte_main.txncnt,
              cte_main.excusedtxncnt,
              cte_main.unassignedtxncnt,
              cte_main.vtolltxncnt,
              cte_main.paidtxncnt,
              cte_main.nooftimessenttoprimary,
              cte_main.nooftimessenttosecondary,
              cte_main.paymentchannel,
              cte_main.pos,
              cte_main.primarycollectionagency,
              cte_main.secondarycollectionagency,
              cte_main.invoiceamount,
              cte_main.pbmtollamount,
              cte_main.avitollamount,
              cte_main.premiumamount,
              cte_main.vtollamountpriortozc,
              cte_main.vtollamount - cte_main.vtollamountpriortozc AS vtollamountafterzc,
              cte_main.vtollamount,
              cte_main.excusedamountpriortozc,
              cte_main.excusedamount - cte_main.excusedamountpriortozc AS excusedamountafterzc,
              cte_main.excusedamount,
              cte_main.tollspriortozc,
              cte_main.tolls - cte_main.tollspriortozc AS tollsafterzc,
              cte_main.tolls,
              cte_main.fnfees,
              cte_main.snfees,
              cte_main.expectedamount,
              cte_main.tollsadjustedpriortozc,
              cte_main.tollsadjusted - cte_main.tollsadjustedpriortozc AS tollsadjustedafterzc,
              cte_main.tollsadjusted,
              cte_main.fnfeesadjusted,
              cte_main.snfeesadjusted,
              cte_main.adjustedamount,
              cte_main.adjustedexpectedtollspriortozc,
              cte_main.adjustedexpectedtolls - cte_main.adjustedexpectedtollspriortozc AS adjustedexpectedtollsafterzc,
              cte_main.adjustedexpectedtolls,
              cte_main.adjustedexpectedfnfees,
              cte_main.adjustedexpectedsnfees,
              cte_main.adjustedexpectedamount,
              cte_main.tollspaidpriortozc,
              cte_main.tollspaid - cte_main.tollspaidpriortozc AS tollspaidafterzc,
              cte_main.tollspaid,
              cte_main.fnfeespaid,
              cte_main.snfeespaid,
              cte_main.paidamount,
              cte_main.tolloutstandingamountpriortozc,
              cte_main.tolloutstandingamount - cte_main.tolloutstandingamountpriortozc AS tolloutstandingamountafterzc,
              cte_main.tolloutstandingamount,
              cte_main.fnfeesoutstandingamount,
              cte_main.snfeesoutstandingamount,
              cte_main.outstandingamount,
              COALESCE(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_update_date
            FROM
              cte_main
      ;


      SET log_message = 'Loaded EDW_TRIPS_STAGE.MigratedNonTerminalInvoice';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      


      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);

      IF trace_flag = 1 THEN
        SELECT log_source ,log_start_date;  -- Replacement for FromLog
      END IF;

      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.MigratedNonTerminalInvoice' AS tablename,
            *
          FROM
            EDW_TRIPS_STAGE.MigratedNonTerminalInvoice
        ORDER BY 2 DESC
        LIMIT 1000
        ;
      END IF;

    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        SELECT log_source ,log_start_date;  -- Replacement for FromLog
        RAISE USING MESSAGE = error_message;
      END;
    END;

  /*
  --===============================================================================================================
  -- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
  --===============================================================================================================
  EXEC dbo.Fact_Invoice_Full_Load

  EXEC Utility.FromLog 'dbo.Fact_Invoice', 1
  SELECT TOP 100 'dbo.Fact_Invoice' Table_Name, * FROM dbo.Fact_Invoice ORDER BY 2

  --===============================================================================================================
  -- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
  --===============================================================================================================


  SELECT * FROM LND_TBOS.TollPlus.Invoice_Header WHERE invoicenumber=1204145788

  */

  END;