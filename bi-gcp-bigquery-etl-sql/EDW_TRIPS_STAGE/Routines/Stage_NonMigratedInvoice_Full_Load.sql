CREATE OR REPLACE PROCEDURE EDW_TRIPS_STAGE.NonMigratedInvoice_Full_Load()
BEGIN 
/*
#################################################################################################################################
Proc Description: 
---------------------------------------------------------------------------------------------------------------------------------
Exec  [Stage].[NonMigratedInvoice_Full_Load] 
=================================================================================================================================
Change Log:
---------------------------------------------------------------------------------------------------------------------------------
CHG0042443	Gouthami		2023-02-09	New!
									  1) This Stored procedure loads the data for all non migrated Invoices. (>=2021)
									  2) Payments and Adjustments for the Invoices are taken from bubble logic table 
										 Stage.InvoicePAyment
																			 
==================================================================================================================================

-------------------------------------------------------------------------------------------------------3---------------------------
EXEC Stage.NonMigratedInvoice_Full_Load
EXEC Utility.FromLog 'Stage.NonMigratedInvoice_Full_Load', 1
SELECT TOP 100 'Stage.NonMigratedInvoice_Full_Load' Table_Name, * FROM Stage.NonMigratedInvoice_Full_Load ORDER BY 2
##################################################################################################################################
*/


  DECLARE log_source STRING DEFAULT 'EDW_TRIPS_STAGE.NonMigratedInvoice_Full_Load'; 
  DECLARE log_start_date DATETIME; 
  DECLARE log_message STRING; 
  DECLARE trace_flag INT64 DEFAULT 0; --Testing
  BEGIN 
    DECLARE ROW_COUNT INT64;
    SET log_start_date = current_datetime('America/Chicago');
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
    
    --=============================================================================================================
    -- Load EDW_TRIPS_STAGE.NonMigInvoice -- list of invoices that needs to be executed in each run
    --=============================================================================================================

    CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.NonMigInvoice
    AS 
    SELECT a.* FROM
        (
            SELECT row_number() OVER (PARTITION BY ihc.invoicenumber ORDER BY invoiceid DESC) AS rn_max,
                        ihc.invoicenumber,
                        invoiceid,
                        ihc.customerid,
                        ihc.agestageid,
                        ihc.vehicleid,
                        collectionstatus,
                        ihc.invoicestatus,
                        ihc.invoicedate,
                        ihc.lnd_updatetype -- select count(distinct IHC.invoicenumber)
            FROM LND_TBOS.TollPlus_Invoice_Header AS ihc
            LEFT OUTER JOIN EDW_TRIPS_SUPPORT.RiteMigratedInvoice AS ri ON ri.invoicenumber  = CAST(ihc.invoicenumber AS INT64)
            WHERE lnd_updatetype <> 'D'
            AND ihc.createduser <> 'DCBInvoiceGeneration'
            AND ri.invoicenumber IS NULL 
        ) AS a
        WHERE a.rn_max = 1 ;


    --log
    SET log_message = 'Loaded EDW_TRIPS_STAGE.NonMigInvoice'; 
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');

    IF trace_flag = 1 THEN
        SELECT 'EDW_TRIPS_STAGE.NonMigInvoice' AS tablename,
            nonmiginvoice.*
        FROM EDW_TRIPS_STAGE.NonMigInvoice
        ORDER BY 2 DESC LIMIT 100;
    END IF;
    --=============================================================================================================
    -- Load EDW_TRIPS_STAGE.DismissedVToll  -- to bring dismissed Vtolls
	--=============================================================================================================
		

  
    CREATE TEMPORARY TABLE _SESSION.cte_vtolls 
    AS 
        (
            SELECT DISTINCT a.invoicenumber AS invoicenumber,
                            count(DISTINCT a.tptripid) AS vtolltxncnt,
                            count(a.custtripid) AS custtxncnt,
                            coalesce(sum(CASE
                                            WHEN a.tripstatusid_vt IN(171, 118) THEN 1
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
                    SELECT vt.referenceinvoiceid AS invoicenumber,
                        tc.tptripid,
                        vt.tptripid AS tptripid_vt,
                        tc.custtripid,
                        vt.tripstatusid AS tripstatusid_vt,
                        tc.tripstatusid AS tripstatusid_ct,
                        tc.paymentstatusid,
                        tc.posteddate,
                        CASE
                            WHEN count(vt.tptripid) > 1
                                    AND sum(CASE
                                                WHEN tc.tripstatusid = 2 THEN 1
                                                ELSE 0
                                            END) > 1 THEN CAST(div(vt.pbmtollamount, count(vt.tptripid)) AS NUMERIC) 
                            ELSE CASE
                                        WHEN tc.paymentstatusid = 3852
                                            AND vt.tripstatusid <> 154
                                            AND tc.tripstatusid NOT IN(155,
                                                                        159,
                                                                        135,
                                                                    170) THEN 0
                                        ELSE vt.pbmtollamount
                                    END  -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
                        END AS pbmtollamount,
                        CASE
                            WHEN count(vt.tptripid) > 1
                                    AND sum(CASE
                                                WHEN tc.tripstatusid = 2 THEN 1
                                                ELSE 0
                                            END) > 1 THEN CAST(div(vt.avitollamount, count(vt.tptripid)) AS NUMERIC) 
                            ELSE CASE
                                        WHEN tc.paymentstatusid = 3852
                                            AND vt.tripstatusid <> 154
                                            AND tc.tripstatusid NOT IN(155,
                                                                        159,
                                                                        135,
                                                                        170) THEN 0
                                        ELSE vt.avitollamount
                                    END -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
                        END AS avitollamount,
                        CASE
                            WHEN count(vt.tptripid) > 1
                                    AND sum(CASE
                                                WHEN tc.tripstatusid = 2 THEN 1
                                                ELSE 0
                                            END) > 1 THEN CAST(div(vt.tollamount, count(vt.tptripid)) AS NUMERIC)  --Ex:1226708097 
                            ELSE CASE
                                        WHEN tc.paymentstatusid = 3852
                                            AND vt.tripstatusid <> 154
                                            AND tc.tripstatusid NOT IN(155,
                                                                        159,
                                                                        135,
                                                                        170) THEN 0
                                        ELSE vt.tollamount
                                    END  -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
                        END AS tolls,
                        CASE
                            WHEN count(vt.tptripid) > 1 THEN div(sum(CASE
                                                                            WHEN tc.paymentstatusid = 456
                                                                                AND tc.tripstatusid = 5 THEN tc.tollamount
                                                                            WHEN tc.paymentstatusid = 456 THEN tc.tollamount
                                                                            WHEN tc.paymentstatusid = 457 THEN (tc.tollamount - tc.outstandingamount )
                                                                            ELSE 0
                                                                        END), count(vt.tptripid))
                            ELSE sum(CASE
                                            WHEN tc.paymentstatusid = 456
                                                AND tc.tripstatusid = 5 THEN tc.tollamount
                                            WHEN tc.paymentstatusid = 456 THEN tc.tollamount
                                            WHEN tc.paymentstatusid = 457 THEN (tc.tollamount - tc.outstandingamount )
                                            ELSE 0
                                        END)
                        END AS paidamount_vt,
                        tc.outstandingamount,
                        sum(CASE
                                WHEN tc.paymentstatusid = 3852
                                        AND tc.tripstatusid = 135
                                        AND vt.paymentstatusid = 456
                                        AND vt.tripstatusid = 2 THEN 0  -- these are the txns that got posted in VT table and paid in vtrt 
                                WHEN tc.paymentstatusid = 3852 -- 118 - Unmatched , 135 - CSR Adjusted
                                        AND tc.tripstatusid = 118 THEN 0    -- 1223509842
                                WHEN tc.paymentstatusid = 458
                                        AND tc.outstandingamount <> tc.tollamount
                                        AND tc.outstandingamount = tc.pbmtollamount
                                        AND tc.outstandingamount = tc.avitollamount THEN (tc.tollamount - tc.outstandingamount)
                                WHEN vt.tripstatusid = 154
                                        AND tc.tripstatusid = 135
                                        AND tt.paymentstatusid = 456 THEN vt.tollamount -- Trips that got vtolled and posted to different zipcash account
                                WHEN tc.paymentstatusid = 3852
                                        AND tc.tripstatusid = 135
                                        AND vt.paymentstatusid = 3852 THEN vt.tollamount--ex:1225983731
                                WHEN tc.paymentstatusid = 3852
                                        AND tc.tripstatusid = 154 THEN 0  --Ex:1222959778
                                WHEN tc.paymentstatusid = 3852 THEN vt.amount
                                WHEN tc.tollamount <> vt.amount THEN vt.amount - tc.tollamount
                                WHEN tc.tollamount = tc.pbmtollamount
                                        AND tc.outstandingamount = tc.avitollamount
                                        AND tc.paymentstatusid = 458 THEN (tc.tollamount - tc.outstandingamount)  --Ex:1234342591
                                WHEN tc.tollamount = tc.pbmtollamount THEN 0
                                WHEN tc.tollamount = 0
                                        AND vt.tollamount = tc.pbmtollamount THEN tc.pbmtollamount
                                WHEN tc.tollamount = vt.amount
                                        AND tc.tollamount <> tc.pbmtollamount
                                        AND tc.tollamount <> tc.avitollamount THEN 0
                                WHEN tc.tollamount = 0
                                    AND tc.paymentstatusid = 456 THEN 0
                                ELSE (tc.pbmtollamount - tc.avitollamount)
                            END) AS tollsadjusted
                    FROM(
                            SELECT vt_0.* 
                                FROM (
                                    SELECT row_number() OVER (PARTITION BY vt_1.tptripid,l.referenceinvoiceid
                                                    ORDER BY vt_1.citationid DESC, vt_1.exittripdatetime DESC) AS rn_vt,
                                            vt_1.citationid,
                                            vt_1.tptripid,
                                            vt_1.violatorid,
                                            vt_1.tollamount,
                                            vt_1.outstandingamount,
                                            vt_1.pbmtollamount,
                                            vt_1.avitollamount,
                                            vt_1.citationstage,
                                            vt_1.tripstageid,
                                            vt_1.tripstatusid,
                                            vt_1.stagemodifieddate,
                                            vt_1.entrytripdatetime,
                                            vt_1.exittripdatetime,
                                            vt_1.paymentstatusid,
                                            vt_1.posteddate,
                                            l.linkid,
                                            l.amount,
                                            l.linksourcename,
                                            l.txndate,
                                            l.referenceinvoiceid
                                    FROM LND_TBOS.TollPlus_Invoice_Header AS h
                                        INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS l 
                                            ON l.invoiceid = h.invoiceid
                                        INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt_1 
                                            ON l.linkid = vt_1.citationid
                                                AND l.linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                                                AND (vt_1.paymentstatusid <> 456 AND vt_1.tripstatusid <> 2 )  -- This is to avoid those Txns that are vtolled first and then moved back to Violated trips table
                                                AND vt_1.tripstatusid NOT IN (171,118,170)-- EX: 1233445625,1234165987,1230780604. This condition is for the Txns that are unassignd from an invoice and assigned to a different one and then gor VTOLLED.In this case, the citationID is going to change but TPTRIPID remains same. While joining this VT table to CT,we are goint to get all the txns assigned to the TPTRIPID(Assigned and Vtolled). 
                                ) AS vt_0  
                                WHERE vt_0.rn_vt = 1 --AND VT.ReferenceInvoiceID=1223304290
                        ) AS vt 
                        INNER JOIN
                        (
                            SELECT a_0.*
                            FROM(
                                    SELECT  tc_0.tptripid,
                                            tc_0.custtripid,
                                            tc_0.tripstatusid,
                                            tc_0.paymentstatusid,
                                            tc_0.posteddate,
                                            tc_0.tollamount,
                                            tc_0.pbmtollamount,
                                            tc_0.avitollamount,
                                            tc_0.outstandingamount,
                                            row_number() OVER (PARTITION BY tc_0.tptripid
                                                        ORDER BY tc_0.custtripid DESC, tc_0.posteddate DESC) AS rn
                                    FROM LND_TBOS.TollPlus_TP_CustomerTrips AS tc_0
                                    WHERE tc_0.transactionpostingtype NOT IN('Prepaid AVI','NTTA Fleet') 
                                ) AS a_0
                            WHERE a_0.rn = 1 
                        ) AS tc ON tc.tptripid = vt.tptripid
                        INNER JOIN LND_TBOS.TollPlus_TP_Trips AS tt 
                            ON tt.tptripid = tc.tptripid
                                AND tt.tripwith IN ('C')
                        INNER JOIN EDW_TRIPS_STAGE.NonMigInvoice AS inv 
                            ON inv.invoicenumber = vt.referenceinvoiceid
                        --WHERE VT.ReferenceInvoiceID IN (1220370385,1220379954,1235080293,1247105490,1233896153)
                        --WHERE H.InvoiceNumber=1230002032 --partial vtoll
                        --WHERE H.InvoiceNumber=1237067582 -- issue in stage table joining to customer trips as these trips have 135 and 2 statuses	
                        --H.InvoiceNumber= 1227517722  -- some of the Txns on these invoice are on the customer account first, and then moved to Violated trips and got invoiced as the auto payment was not done on the account
                        --WHERE H.InvoiceNumber IN (1030630051,1120029424)	
                        GROUP BY    vt.referenceinvoiceid,
                                    tc.tptripid,
                                    vt.tripstatusid,
                                    tc.paymentstatusid,
                                    tc.posteddate,
                                    vt.tollamount,
                                    tc.outstandingamount,
                                    vt.tptripid,
                                    tc.custtripid,
                                    vt.tripstatusid,
                                    vt.paymentstatusid,
                                    vt.posteddate,
                                    vt.outstandingamount,
                                    tc.tripstatusid,
                                    vt.pbmtollamount,
                                    vt.avitollamount
                ) AS a
            GROUP BY a.invoicenumber
        );


    CREATE TEMPORARY TABLE _SESSION.cte 
    AS
        (
            SELECT  h.invoicenumber,
                    count(DISTINCT vt.tptripid) AS totaltxncnt,
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
                        AND l.linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                INNER JOIN EDW_TRIPS_STAGE.NonMigInvoice AS inv 
                    ON inv.invoicenumber = h.invoicenumber
            --WHERE L.ReferenceInvoiceID IN (1220370385,1220379954,1235080293,1247105490,1233896153)
            --WHERE H.InvoiceNumber=1120029424 -- 1 Unassigned and 3 vtoll
            GROUP BY h.invoicenumber
        );

   
    CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.DismissedVToll 
    AS
        SELECT  cte_vtolls.invoicenumber,
                cte.totaltxncnt AS totaltxncnt,
                cte_vtolls.vtolltxncnt,
                cte.unassignedtxncnt,
                cte_vtolls.unassignedvtolledtxncnt,
                cte_vtolls.vtollpaidtxncnt,
                CASE
                    WHEN cte_vtolls.paidamount_vt = 0 THEN CAST('1900-01-01' AS  DATETIME)
                    ELSE cte_vtolls.firstpaymentdate
                END AS firstpaymentdate,
                CASE
                    WHEN cte_vtolls.paidamount_vt = 0 THEN CAST('1900-01-01' AS DATETIME)
                    ELSE cte_vtolls.lastpaymentdate
                END AS lastpaymentdate,
                cte_vtolls.tolls,
                cte_vtolls.pbmtollamount,
                cte_vtolls.avitollamount,
                cte_vtolls.premiumamount,
                cte_vtolls.paidamount_vt,
                (cte.excusedtollsadjusted + cte_vtolls.tollsadjusted) AS tollsadjusted,
                0 AS tollsadjustedaftervtoll,
                0 AS adjustedamount_excused,
                0 AS classadj,
                cte_vtolls.outstandingamount,
                0 AS paidtnxs,
                CASE
                    WHEN cte_vtolls.vtolltxncnt = cte.totaltxncnt THEN 1
                    ELSE 0
                END AS vtollflag,
                CASE cte.totaltxncnt
                    WHEN cte_vtolls.vtolltxncnt THEN '1 - Vtoll Invoice'
                    WHEN cte_vtolls.vtolltxncnt + cte.unassignedtxncnt THEN '1 - Vtoll Invoice'
                    ELSE '0 - PartialVtoll Invoice'
                END AS vtollflagdescription,
                current_datetime()  AS edw_update_date
        FROM cte_vtolls
            LEFT OUTER JOIN cte 
                ON cte.invoicenumber = cte_vtolls.invoicenumber ;

    -- Log 
    SET log_message = 'Loaded EDW_TRIPS_STAGE.DismissedVToll';

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');

    IF trace_flag = 1 THEN
        SELECT 'EDW_TRIPS_STAGE.DismissedVToll' AS tablename,
            dismissedvtoll.*
        FROM EDW_TRIPS_STAGE.DismissedVToll
        ORDER BY 2 DESC LIMIT 100;

    END IF;

    --=============================================================================================================
    -- Load EDW_TRIPS_STAGE.UnassignedInvoice  -- to bring dismissed Unassigned Invoices
    --=============================================================================================================


    CREATE TEMPORARY TABLE _SESSION.cte_unassigned 
    AS
        (
            SELECT  ih.invoicenumber AS invoicenumber_unass,
                    count(DISTINCT vt.citationid) AS citationid_unassgned,
                    count(DISTINCT a.tptripid) AS unassignedtxncnt,
                    sum(vt.tollamount) AS tolls
            FROM
            (
                SELECT  vt_0.tptripid,
                        row_number() OVER (PARTITION BY vt_0.tptripid ORDER BY vt_0.citationid) AS rn
                FROM LND_TBOS.TollPlus_TP_ViolatedTrips AS vt_0
            ) AS a
            INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt 
                ON vt.tptripid = a.tptripid
            INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS ili 
                ON vt.citationid = ili.linkid
                    AND ili.linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
            INNER JOIN LND_TBOS.TollPlus_Invoice_Header AS ih 
                ON ili.invoiceid = ih.invoiceid
            INNER JOIN EDW_TRIPS_STAGE.NonMigInvoice AS inv 
                ON inv.invoicenumber = ih.invoicenumber
            WHERE a.rn = 2
                AND tripstatusid IN(171,115,118)
                AND ih.invoicenumber NOT IN
                (
                    SELECT dismissedvtoll.invoicenumber
                    FROM EDW_TRIPS_STAGE.DismissedVToll
                )
                --AND ili.ReferenceInvoiceID=1230780604
            GROUP BY ih.invoicenumber
        );


    CREATE TEMPORARY TABLE _SESSION.cte_all 
    AS
        (
            SELECT h.invoicenumber,
                count(DISTINCT vt.citationid) AS citationid_all
            FROM LND_TBOS.TollPlus_Invoice_Header AS h
                INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS l 
                    ON l.invoiceid = h.invoiceid
                INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt 
                    ON vt.citationid = l.linkid
                        AND l.linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                INNER JOIN EDW_TRIPS_STAGE.NonMigInvoice AS inv 
                    ON inv.invoicenumber = h.invoicenumber
            -- WHERE H.InvoiceNumber=1230780604
            GROUP BY h.invoicenumber
        );


    CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.UnassignedInvoice 
    AS
        SELECT  cte_unassigned.invoicenumber_unass,
                cte_unassigned.citationid_unassgned,
                cte_unassigned.unassignedtxncnt,
                cte_all.invoicenumber,
                cte_all.citationid_all,
                cte_unassigned.tolls,
                1 AS unassignedflag
        FROM cte_unassigned
        INNER JOIN cte_all 
            ON cte_all.invoicenumber = cte_unassigned.invoicenumber_unass
        WHERE cte_all.citationid_all = cte_unassigned.citationid_unassgned ;


    --log
    SET log_message = 'Loaded EDW_TRIPS_STAGE.UnassignedInvoice';

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');
    IF trace_flag = 1 THEN
        SELECT 'EDW_TRIPS_STAGE.UnassignedInvoice' AS tablename,
            unassignedinvoice.*
        FROM EDW_TRIPS_STAGE.UnassignedInvoice
        ORDER BY 2 DESC LIMIT 100;

    END IF;

    --=============================================================================================================
    -- Load Stage.CANonMigratedInvoice  -- To bring Collection agency information for all invoices
    --=============================================================================================================

       CREATE TEMPORARY TABLE _SESSION.cte_inv AS (
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
                INNER JOIN EDW_TRIPS_STAGE.NonMigInvoice AS nminv ON nminv.invoicenumber = vco.invoicenumber
                INNER JOIN LND_TBOS.TollPlus_MbsInvoices AS mbs ON mbs.invoicenumber = vco.invoicenumber
                INNER JOIN LND_TBOS.TollPlus_Mbsheader AS mbh ON mbh.mbsid = mbs.mbsid
              WHERE ftp.destination IN('CMI', 'CPA', 'LES', 'SWC')
              --AND VCO.InvoiceNumber=1246000499
              GROUP BY  vco.invoicenumber,
                        mbs.mbsid,
                        mbh.ispresentmbs,
                        ftp.fileid,
                        ftp.destination
          ) ;
          CREATE TEMPORARY TABLE _SESSION.cte_ca AS (
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
              GROUP BY cte_inv.invoicenumber, cte_inv.destination
          );

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CANonMigratedInvoice
        AS
          SELECT
              a.invoicenumber,
              coalesce(a.cpalatestfilegendate, a.leslatestfilegendate) AS primarycollectionagencydate,
              coalesce(a.swclatestfilegendate, a.cmilatestfilegendate) AS secondarycollectionagencydate,
              coalesce(a.cpanumberoftimessent, a.lesnumberoftimessent, 0) AS nooftimessenttoprimary,
              coalesce(a.swcnumberoftimessent, a.cminumberoftimessent, 0) AS nooftimessenttosecondary,
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
                  GROUP BY cte_ca.invoicenumber
              ) AS a
              --JOIN dbo.Dim_CollectionStatus
      ;
      		
		  -- Log 
      SET log_message = 'Loaded Stage.CANonMigratedInvoice';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');
      
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.CANonMigratedInvoice' AS tablename,
            canonmigratedinvoice.*
          FROM
            EDW_TRIPS_STAGE.CANonMigratedInvoice
        ORDER BY
          2 DESC LIMIT 100
        ;
      END IF;
    

    --=============================================================================================================
    -- Load EDW_TRIPS_STAGE.Invoice  -- to bring dismissed Unassigned Invoices
    --=============================================================================================================
		

    CREATE TEMPORARY TABLE _SESSION.cte_curr_inv 
    AS
        (
            SELECT  row_number() OVER (PARTITION BY ihc.invoicenumber ORDER BY ihc.invoiceid DESC) AS rn_max,
                    ihc.invoicenumber,
                    ihc.invoiceid,
                    ihc.customerid,
                    ihc.agestageid,
                    ihc.collectionstatus,
                    ihc.vehicleid,
                    ihc.adjustedamount,
                    ihc.invoicestatus,
                    ihc.lnd_updatetype
            FROM LND_TBOS.TollPlus_Invoice_Header AS ihc
                INNER JOIN EDW_TRIPS_STAGE.NonMigInvoice AS inv 
                    ON inv.invoicenumber = ihc.invoicenumber
            WHERE ihc.lnd_updatetype <> 'D'
                AND ihc.createduser <> 'DCBInvoiceGeneration' 
                --AND IHC.InvoiceNumber=1246000499 
        );


    CREATE TEMPORARY TABLE _SESSION.cte_first_inv 
    AS
        (
            SELECT  row_number() OVER (PARTITION BY ihf.invoicenumber ORDER BY ihf.invoiceid) AS rn_min,
                    ihf.invoicenumber,
                    ihf.invoiceid,
                    ihf.sourcename,
                    ihf.lnd_updatetype
            FROM LND_TBOS.TollPlus_Invoice_Header AS ihf
                INNER JOIN EDW_TRIPS_STAGE.NonMigInvoice AS inv 
                    ON inv.invoicenumber = ihf.invoicenumber
            WHERE ihf.lnd_updatetype <> 'D'
                AND ihf.createduser <> 'DCBInvoiceGeneration' 
                --AND IHF.InvoiceNumber=1246000499 
        );

  
    CREATE TEMPORARY TABLE _SESSION.cte_inv_date 
    AS
        (
            SELECT  a.invoicenumber,
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
                    SELECT  ihd.invoicenumber,
                            max(mbsh.mbsid) AS mbsid,
                            max(CASE
                                    WHEN ihd.agestageid = 1 THEN CAST(ihd.invoicedate as DATE)
                                    ELSE '1900-01-01'
                                END) AS zipcashdate,
                            max(CASE
                                    WHEN ihd.agestageid = 2 THEN CAST( ihd.invoicedate AS DATE) 
                                    ELSE CAST('1900-01-01' AS DATE)
                                END) AS firstnoticedate,
                            max(CASE
                                    WHEN ihd.agestageid = 3 THEN CAST( ihd.invoicedate AS DATE)
                                    ELSE CAST('1900-01-01' AS DATE)
                                END) AS secondnoticedate,
                            min(CASE
                                    WHEN ihd.agestageid = 4 THEN CAST( ihd.invoicedate AS DATE)
                                    ELSE CAST('1900-01-01' AS DATE)
                                END) AS thirdnoticedate,
                            max(CASE
                                    WHEN ihd.agestageid = 5 THEN CAST( ihd.invoicedate AS DATE) 
                                    ELSE CAST('1900-01-01' AS DATE)
                                END) AS legalactionpendingdate,
                            CASE
                                WHEN ihd.agestageid = 6 THEN min(CAST( ihd.invoicedate AS DATE))
                                ELSE CAST('1900-01-01' AS DATE)
                            END AS citationdate,
                            max(CAST( ihd.duedate AS DATE)) AS duedate,
                            max(CAST( mbsh.mbsgenerateddate AS DATE)) AS mbsgenerateddate,
                            CASE
                                WHEN ihd.lnd_updatetype = 'D'
                                    OR mbsi.lnd_updatetype = 'D'
                                    OR mbsh.lnd_updatetype = 'D' THEN 1
                                ELSE 0
                            END AS deleteflag
                    --SELECT * 
                    FROM LND_TBOS.TollPlus_Invoice_Header AS ihd
                        INNER JOIN EDW_TRIPS_STAGE.NonMigInvoice AS inv
                            ON inv.invoicenumber = ihd.invoicenumber
                        LEFT OUTER JOIN LND_TBOS.TollPlus_MbsInvoices AS mbsi 
                            ON mbsi.invoicenumber = ihd.invoicenumber
                                AND mbsi.lnd_updatetype <> 'D'
                        LEFT OUTER JOIN LND_TBOS.TollPlus_Mbsheader AS mbsh 
                            ON mbsh.mbsid = mbsi.mbsid
                                AND mbsh.lnd_updatetype <> 'D'
                    WHERE ihd.lnd_updatetype <> 'D'
                        AND ihd.createduser <> 'DCBInvoiceGeneration'
                        --AND IHD.InvoiceNumber=1246000499 
                    GROUP BY    ihd.invoicenumber,
                                CASE
                                    WHEN ihd.lnd_updatetype = 'D'
                                        OR mbsi.lnd_updatetype = 'D'
                                        OR mbsh.lnd_updatetype = 'D' THEN 1
                                    ELSE 0
                                END,
                                ihd.agestageid
                ) AS a
            GROUP BY    invoicenumber,
                        a.deleteflag
        );

    CREATE TEMPORARY TABLE _SESSION.mi 
    AS
        (
            SELECT  CAST( cte_curr_inv.invoicenumber AS INT64) AS invoicenumber,
                    cte_first_inv.invoiceid AS firstinvoiceid,
                    cte_curr_inv.invoiceid AS currentinvoiceid,
                    cte_curr_inv.customerid,
                    CASE
                        WHEN cte_first_inv.sourcename IS NOT NULL THEN 1
                        ELSE 0
                    END AS migratedflag,
                    cte_curr_inv.agestageid AS agestageid,
                    coalesce(cte_curr_inv.collectionstatus, -1) AS collectionstatusid,
                    coalesce(cte_inv_date.mbsid, -1) AS currmbsid,
                    cte_curr_inv.vehicleid,
                    dis.invoicestatusid,
                    pp.paymentplanid,

                    ------------------------------------ Dates
                    max(CASE
                            WHEN il.txntype = 'VTOLL' THEN CAST( il.createddate AS DATE)
                            ELSE DATE '1900-01-01'
                        END) AS zipcashdate,
                    cte_inv_date.firstnoticedate,
                    cte_inv_date.secondnoticedate,
                    cte_inv_date.thirdnoticedate,
                    cte_inv_date.legalactionpendingdate,
                    cte_inv_date.citationdate,
                    cte_inv_date.duedate,
                    coalesce(cte_inv_date.mbsgenerateddate, DATE '1900-01-01') AS currmbsgenerateddate,
                    invp.firstpaymentdatepriortozc,
                    CASE
                        WHEN invp.excuseddate IS NOT NULL
                            AND CAST(invp.excuseddate as DATE) = invp.lastpaymentdatepriortozc THEN invp.firstpaymentdatepriortozc
                        ELSE invp.lastpaymentdatepriortozc
                    END AS lastpaymentdatepriortozc,
                    invp.firstpaymentdateafterzc,
                    invp.lastpaymentdateafterzc,
                    fp.firstfeepaymentdate,
                    fp.lastfeepaymentdate,
                    ca.primarycollectionagencydate,
                    ca.secondarycollectionagencydate,
                    ---TxnCounts
                    count(DISTINCT tpv.tptripid) AS txncnt,
                    sum(CASE
                            WHEN tpv.tripstatusid = 170 THEN 1
                        ELSE 0
                     END) AS excusedtxncnt,
                    sum(CASE
                            WHEN tpv.tripstatusid IN(
                                171, 115, 118
                            ) THEN 1
                        ELSE 0
                    END) AS unassignedtxncnt,
                    sum(CASE
                    WHEN tpv.paymentstatusid = 456
                    OR vtp.paymentstatusid = 456 THEN 1
                    ELSE 0
                    END) AS paidtxncnt,
                    sum(CASE
                            WHEN vtp.vtollflag = 1
                                AND vtp.paymentstatusid IN(
                                    456, 457, 458
                                ) THEN 1
                        ELSE 0
                    END) AS vtolltxncnt,
                    sum(CASE
                            WHEN CAST(vtp.firstpaiddate as DATE) < CASE
                                WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                            ELSE DATE '1900-01-01'
                    END
                            AND vtp.firstpaiddate IS NOT NULL
                            AND (vtp.vtollflag = 1
                                OR vtp.paymentstatusid = 456
                                OR vtp.paymentstatusid = 457) THEN 1
                        WHEN CAST(vtp.excuseddate as DATE) < CASE
                                WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                            END
                        AND vtp.excuseddate IS NOT NULL
                        AND tpv.tripstatusid = 170 THEN 1
                    ELSE 0
                    END) AS txncntpriortozc,
                    sum(CASE
                    WHEN CAST(vtp.firstpaiddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND vtollflag = 1
                    AND tpv.tripstatusid IN(
                        153, 154
                    ) THEN 1
                    ELSE 0
                    END) AS vtolltxncntpriortozc,
                    sum(CASE
                    WHEN CAST(vtp.firstpaiddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND vtp.firstpaiddate IS NOT NULL
                    AND (tpv.paymentstatusid = 456
                    OR tpv.tripstatusid IN(
                        153, 154
                    )
                    AND vtp.paymentstatusid = 456) THEN 1
                    WHEN CAST(vtp.firstpaiddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND tpv.tripstatusid = 170
                    AND vtp.actualpaidamount = tpv.tollamount THEN 1
                    ELSE 0
                    END) AS paidtxncntpriortozc,
                    sum(CASE
                    WHEN CAST(vtp.excuseddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND vtp.excuseddate IS NOT NULL
                    AND tpv.tripstatusid = 170 THEN 1
                    ELSE 0
                    END) AS excusedtxncntpriortozc,
                    ca.nooftimessenttoprimary,
                    ca.nooftimessenttosecondary,
                    ----------------------------------------
                    invp.paymentchannel,
                    invp.pos,
                    ca.primarycollectionagency,
                    ca.secondarycollectionagency,

                    ------------------------------------------ Amounts
                    CAST(coalesce(invp.tolls, 0) + coalesce(f.fnfees, 0) + coalesce(f.snfees, 0) AS NUMERIC) AS invoiceamount,
                    CAST(coalesce(invp.pbmtollamount, 0) AS NUMERIC) AS pbmtollamount,
                    CAST(coalesce(invp.avitollamount, 0) AS NUMERIC) AS avitollamount,
                    CAST(coalesce(invp.pbmtollamount, 0) - coalesce(invp.avitollamount, 0) AS NUMERIC) AS premiumamount,
                    CAST(coalesce(invp.tolls, 0) AS NUMERIC) AS tolls,
                    CAST(coalesce(f.fnfees, 0) AS NUMERIC) AS fnfees,
                    CAST(coalesce(f.snfees, 0) AS NUMERIC) AS snfees,
                    CAST(coalesce(invp.tollspaid, 0) AS NUMERIC) AS tollspaid,
                    CAST(coalesce(fp.fnfeespaid, 0) AS NUMERIC) AS fnfeespaid,
                    CAST(coalesce(fp.snfeespaid, 0) AS NUMERIC) AS snfeespaid,
                    CAST(coalesce(invp.tollsadjusted, 0) AS NUMERIC) AS tollsadjusted,
                    CAST(coalesce(fa.fnfeesadjusted, 0) AS NUMERIC) AS fnfeesadjusted,
                    CAST(coalesce(fa.snfeesadjusted, 0) AS NUMERIC) AS snfeesadjusted,
                    sum(CASE
                    WHEN tpv.tripstatusid = 170
                    AND vtp.paymentstatusid = 3852 THEN tpv.tollamount - vtp.actualpaidamount
                    ELSE 0
                    END) AS excusedamount,
                    sum(CASE
                    WHEN vtp.vtollflag = 1
                    AND vtp.actualpaidamount > 0 THEN vtp.actualpaidamount
                    ELSE 0
                    END) AS vtollamount,
                    sum(CASE
                    WHEN CAST( vtp.firstpaiddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST( il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND vtp.firstpaiddate IS NOT NULL
                    AND (tpv.paymentstatusid = 456
                    OR tpv.tripstatusid = 153
                    OR tpv.paymentstatusid = 457) THEN vtp.tollamount
                    WHEN CAST( vtp.excuseddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST( il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND vtp.excuseddate IS NOT NULL
                    AND tpv.tripstatusid = 170 THEN vtp.tollamount
                    ELSE 0
                    END) AS tollspriortozc,
                    sum(CASE
                    WHEN CAST(vtp.firstpaiddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND vtp.vtollflag = 1 THEN coalesce(vtp.actualpaidamount, vtp.tollamount)
                    ELSE 0
                    END) AS vtollamountpriortozc,
                    sum(CASE
                    WHEN CAST(vtp.excuseddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND vtp.excuseddate IS NOT NULL
                    AND tpv.tripstatusid = 170
                    AND vtp.paymentstatusid = 3852 THEN vtp.tollamount - vtp.actualpaidamount
                    ELSE 0
                    END) AS excusedamountpriortozc,
                    sum(CASE
                    WHEN CAST(vtp.firstpaiddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND vtp.firstpaiddate IS NOT NULL
                    AND (tpv.paymentstatusid = 456
                    OR tpv.tripstatusid = 153
                    AND tpv.paymentstatusid = 3852) THEN vtp.adjustedamount
                    WHEN CAST(vtp.excuseddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND vtp.excuseddate IS NOT NULL
                    AND tpv.tripstatusid = 170 THEN vtp.adjustedamount
                    ELSE 0
                    END) AS tollsadjustedpriortozc,
                    sum(CASE
                    WHEN CAST(vtp.firstpaiddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND (tpv.tripstatusid = 153
                    OR tpv.paymentstatusid = 456
                    OR tpv.paymentstatusid = 457) THEN vtp.actualpaidamount
                    WHEN CAST(vtp.firstpaiddate as DATE) < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                    END
                    AND tpv.tripstatusid = 170
                    AND vtp.actualpaidamount > 0 THEN vtp.actualpaidamount
                    ELSE 0
                    END) AS tollspaidpriortozc,
                    CASE
                        WHEN sum(CASE
                                    WHEN tpv.paymentstatusid = 458 THEN 1
                                    ELSE 0
                                END) = count(tpv.citationid) THEN 'Open'
                        WHEN sum(CASE
                                    WHEN il.linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                                            AND tpv.paymentstatusid = 458 THEN il.amount
                                    ELSE 0
                                END) = 0
                            AND count(tpv.citationid) = 0 THEN 'Closed'
                        WHEN sum(CASE
                                    WHEN tpv.paymentstatusid = 456 THEN 1
                                    ELSE 0
                                END) > 0
                            AND sum(CASE
                                        WHEN tpv.paymentstatusid = 456 THEN 1
                                        ELSE 0
                                    END) < count(tpv.citationid) THEN 'PartialPaid'
                        WHEN sum(CASE
                                    WHEN tpv.paymentstatusid = 456 THEN 1
                                    ELSE 0
                                END) = 0
                            AND sum(CASE
                                        WHEN tpv.paymentstatusid = 458 THEN 1
                                        ELSE 0
                                    END) <> count(tpv.citationid)
                            AND sum(CASE
                                        WHEN tpv.paymentstatusid = 458 THEN 1
                                        ELSE 0
                                    END) <> 0
                            AND count(tpv.citationid) <> 0 THEN 'PartialPaid'
                        WHEN sum(CASE
                                    WHEN tpv.paymentstatusid = 456 THEN 1
                                    ELSE 0
                                END) = count(tpv.citationid) THEN 'Paid'
                        WHEN cte_curr_inv.invoicestatus = 'Closed' THEN 'Closed'
                        ELSE cte_curr_inv.invoicestatus
                    END AS invoicestatus,
                    coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_update_date
            --SELECT *

            FROM cte_curr_inv
                INNER JOIN cte_first_inv 
                    ON  cte_curr_inv.invoicenumber= cte_first_inv.invoicenumber
                        AND cte_curr_inv.rn_max = 1
                        AND cte_first_inv.rn_min = 1
                INNER JOIN cte_inv_date 
                    ON cte_curr_inv.invoicenumber = cte_inv_date.invoicenumber
                INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS il 
                    ON il.referenceinvoiceid = cte_curr_inv.invoicenumber 
                        AND il.lnd_updatetype <> 'D'
                LEFT OUTER JOIN EDW_TRIPS_STAGE.InvoicePayment AS invp 
                    ON cte_curr_inv.invoicenumber = CAST(invp.invoicenumber AS STRING)
                LEFT OUTER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS tpv 
                    ON tpv.citationid = il.linkid
                        AND linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                        AND tpv.lnd_updatetype <> 'D'
                LEFT OUTER JOIN EDW_TRIPS.Dim_InvoiceStatus AS dis 
                    ON cte_curr_inv.invoicestatus = dis.invoicestatuscode
                LEFT OUTER JOIN EDW_TRIPS.Dim_InvoiceStage AS i 
                    ON cte_curr_inv.agestageid = i.invoicestageid
                LEFT OUTER JOIN
                    (
                        SELECT  il_0.referenceinvoiceid AS invoicenumber, -- To calculate Fees Due
                                coalesce(sum(CASE
                                                WHEN il_0.txntype = 'FSTNTVFEE' THEN ict.amount
                                                ELSE 0
                                            END), 0) AS fnfees,
                                coalesce(sum(CASE
                                                WHEN il_0.txntype = 'SECNTVFEE' THEN ict.amount
                                                ELSE 0
                                            END), 0) AS snfees
                        FROM LND_TBOS.TollPlus_Invoice_LineItems AS il_0
                        INNER JOIN LND_TBOS.TollPlus_Invoice_Charges_Tracker AS ict 
                            ON il_0.linkid = ict.invoicechargeid
                                AND ict.lnd_updatetype <> 'D'
                        WHERE il_0.linksourcename = 'TollPlus.Invoice_Charges_Tracker'
                            AND il_0.txntype IN('SECNTVFEE','FSTNTVFEE')
                            AND il_0.lnd_updatetype <> 'D'
                        GROUP BY il_0.referenceinvoiceid
                    ) AS f 
                        ON cte_curr_inv.invoicenumber = f.invoicenumber
                LEFT OUTER JOIN
                    (
                        SELECT  il_0.referenceinvoiceid, ----  FN & SN Fees Paid
                                min(irt.txndate) AS firstfeepaymentdate,
                                max(irt.txndate) AS lastfeepaymentdate,
                                coalesce(sum(CASE
                                                WHEN il_0.txntype = 'FSTNTVFEE' THEN irt.amountreceived * -1
                                                ELSE 0
                                            END), 0) AS fnfeespaid,
                                coalesce(sum(CASE
                                                WHEN il_0.txntype = 'SECNTVFEE' THEN irt.amountreceived * -1
                                                ELSE 0
                                            END), 0) AS snfeespaid
                        FROM LND_TBOS.TollPlus_Invoice_LineItems AS il_0
                            INNER JOIN LND_TBOS.TollPlus_TP_Invoice_Receipts_Tracker AS irt 
                                ON il_0.linkid = irt.invoice_chargeid
                                    AND irt.lnd_updatetype <> 'D'
                            INNER JOIN EDW_TRIPS_STAGE.NonMigInvoice AS ri 
                                ON ri.invoicenumber = il_0.referenceinvoiceid
                                    AND irt.linksourcename = 'FINANCE.PAYMENTTXNS'
                        WHERE il_0.linksourcename = 'TOLLPLUS.Invoice_Charges_tracker'
                            AND il_0.lnd_updatetype <> 'D'
                            --AND IL.ReferenceInvoiceID=1236841109 (Invoice that has only Fee payments no toll payments	)	
                            --AND ReferenceInvoiceID=3795348233 
							--AND ReferenceInvoiceID=1246000499 					  
                        GROUP BY il_0.referenceinvoiceid
                    ) AS fp 
                        ON fp.referenceinvoiceid = cte_curr_inv.invoicenumber
                LEFT OUTER JOIN -- Bring the First and Second Notice Fee Adjustemnts to calculate the Invoice Status
                    (
                        SELECT  il_0.referenceinvoiceid,
                                coalesce(sum(CASE
                                                WHEN il_0.txntype = 'FSTNTVFEE' THEN amountreceived * -1
                                                ELSE 0
                                            END), 0) AS fnfeesadjusted,
                                coalesce(sum(CASE
                                                WHEN il_0.txntype = 'SECNTVFEE' THEN amountreceived * -1
                                                ELSE 0
                                            END), 0) AS snfeesadjusted
                        FROM LND_TBOS.TollPlus_Invoice_LineItems AS il_0
                            INNER JOIN LND_TBOS.TollPlus_TP_Invoice_Receipts_Tracker AS irt 
                                ON il_0.linkid = irt.invoice_chargeid
                                    AND irt.lnd_updatetype <> 'D'
                            INNER JOIN EDW_TRIPS_STAGE.NonMigInvoice AS ri 
                                ON ri.invoicenumber = il_0.referenceinvoiceid
                        WHERE irt.linksourcename = 'FINANCE.ADJUSTMENTS'
                            AND il_0.txntype IN('SECNTVFEE','FSTNTVFEE')
                            AND il_0.linksourcename = 'TOLLPLUS.invoice_Charges_tracker'
                            AND il_0.lnd_updatetype <> 'D'
                            --AND ReferenceInvoiceID=1246000499
							--AND ReferenceInvoiceID=1250379580 
                        GROUP BY il_0.referenceinvoiceid
                    ) AS fa 
                        ON fa.referenceinvoiceid = cte_curr_inv.invoicenumber
                LEFT OUTER JOIN (              --------------- PaymentPlanID
                  SELECT DISTINCT
                      mbsi.invoicenumber,
                      pp_0.paymentplanid,
                      mbsi.mbsid
                    FROM
                      LND_TBOS.TollPlus_MbsInvoices AS mbsi
                      INNER JOIN LND_TBOS.TER_PaymentPlanViolator AS ppvt ON ppvt.mbsid = mbsi.mbsid
                      INNER JOIN EDW_TRIPS.Fact_PaymentPlan AS pp_0 ON pp_0.mbsid = mbsi.mbsid
                       AND pp_0.paymentplanstatusid = 48    -- 'Settlement Agreement Active'
                      --WHERE MBSI.InvoiceNumber=1244641158
                ) AS pp ON pp.invoicenumber = cte_curr_inv.invoicenumber
                LEFT OUTER JOIN EDW_TRIPS_STAGE.CANonMigratedInvoice AS ca ON ca.invoicenumber = cte_curr_inv.invoicenumber
                LEFT OUTER JOIN EDW_TRIPS_STAGE.ViolTripPayment AS vtp ON vtp.citationid = tpv.citationid
                 AND tpv.tptripid = vtp.tptripid
                --WHERE CTE_CURR_INV.InvoiceNumber=3795348233
			    --WHERE IL.ReferenceInvoiceID=1246000499
            ---WHERE CAST(CTE_CURR_INV.InvoiceNumber AS BIGINT) = @invoicenumber
            GROUP BY    invoicenumber,
                        migratedflag,
                        collectionstatusid,
                        currmbsid,
                        currmbsgenerateddate,
                        cte_first_inv.invoiceid,
                        cte_curr_inv.invoiceid,
                        cte_curr_inv.customerid,
                        cte_curr_inv.agestageid,
                        cte_curr_inv.vehicleid,
                        PP.PaymentPlanID,
                        cte_inv_date.firstnoticedate,
                        cte_inv_date.secondnoticedate,
                        cte_inv_date.thirdnoticedate,
                        cte_inv_date.legalactionpendingdate,
                        cte_inv_date.citationdate,
                        cte_inv_date.duedate,
                        fp.firstfeepaymentdate,
                        fp.lastfeepaymentdate,
                        CA.PrimaryCollectionAgencyDate,
                        CA.SecondaryCollectionAgencyDate,
                        CA.NoOfTimesSentToPrimary,
                        CA.NoOfTimesSentToSecondary,

                        ----------------------------------------
                        Invp.Paymentchannel,
                        Invp.POS,
                        CA.PrimaryCollectionAgency,
                        CA.SecondaryCollectionAgency,
                        dis.invoicestatusid,
                        cte_first_inv.lnd_updatetype,
                        cte_curr_inv.lnd_updatetype,
                        invoiceamount,
                        pbmtollamount,
                        avitollamount, --coalesce(invp.avitollamount, 0),
                        premiumamount,
                        tolls,--coalesce(invp.tolls, 0),
                        fnfees,--coalesce(f.fnfees, 0),
                        snfees,-- coalesce(f.snfees, 0),
                        tollspaid,-- coalesce(invp.tollspaid, 0)
                        fnfeespaid,-- coalesce(fp.fnfeespaid, 0),
                        snfeespaid,-- coalesce(fp.snfeespaid, 0),
                        snfeesadjusted,-- coalesce(fa.snfeesadjusted, 0),
                        fnfeesadjusted,-- coalesce(fa.fnfeesadjusted, 0),
                        cte_curr_inv.invoicestatus,
                        tollsadjusted,-- coalesce(invp.tollsadjusted, 0),
                        InvP.FirstPaymentDatePriortoZC,
                        InvP.LastPaymentDatePriortoZC,
                        InvP.FirstPaymentDateAfterZC,
                        InvP.LastPaymentDateAfterZC,
                        Invp.excuseddate
        );
      
    CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.Invoice 
    AS
        SELECT mi.invoicenumber,
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
            mi.paidtxncntpriortozc,
            mi.excusedtxncntpriortozc,
            
			-- MI.PaidTxnCntPriortoZC,
            mi.nooftimessenttoprimary,
            mi.nooftimessenttosecondary,
            mi.paymentchannel,
            mi.pos,
            mi.primarycollectionagency,
            mi.secondarycollectionagency,
            mi.invoicestatus,
            --MI.InvoiceAmount InvoiceAmount_Old,
            CASE
                WHEN vt.vtollflag = 1 THEN vt.tolls + mi.fnfees + mi.snfees
                ELSE mi.invoiceamount
            END AS invoiceamount,
            CASE
                WHEN vt.vtollflag = 1 THEN CAST(vt.pbmtollamount AS BIGNUMERIC)
                ELSE mi.pbmtollamount
            END AS pbmtollamount,
            CASE
                WHEN vt.vtollflag = 1 THEN CAST(vt.avitollamount AS BIGNUMERIC)
                ELSE mi.avitollamount
            END AS avitollamount,
            CASE
                WHEN vt.vtollflag = 1 THEN CAST(vt.premiumamount AS BIGNUMERIC)
                ELSE mi.premiumamount
            END AS premiumamount,
            mi.excusedamount,
            mi.vtollamount,
            --MI.Tolls Tolls_Old,
            CASE
                WHEN vt.vtollflag = 1 THEN CAST(vt.tolls AS BIGNUMERIC)
                ELSE mi.tolls
            END AS tolls,
            mi.fnfees AS fnfees,
            mi.snfees AS snfees,
            -- CASE vt.vtollflag
            --     WHEN 1 THEN CAST(vt.paidamount_vt AS BIGNUMERIC)
            --     WHEN 0 THEN mi.tollspaid + vt.paidamount_vt
            --     ELSE coalesce(mi.tollspaid, CAST(0 AS NUMERIC))
            -- END AS tollspaid,
            coalesce(mi.tollspaid, 0) AS tollspaid,
            mi.fnfeespaid AS fnfeespaid,
            mi.snfeespaid AS snfeespaid,
            -- CASE vt.vtollflag
            --     WHEN 1 THEN vt.tollsadjusted
            --     WHEN 0 THEN mi.tollsadjusted - vt.tolls + (vt.tollsadjusted + vt.tollsadjustedaftervtoll + vt.adjustedamount_excused + vt.classadj)
            --     ELSE coalesce(mi.tollsadjusted, CAST(0 AS NUMERIC))
            -- END AS tollsadjusted,
            coalesce(mi.tollsadjusted, 0) AS tollsadjusted,
            mi.fnfeesadjusted AS fnfeesadjusted,
            mi.snfeesadjusted AS snfeesadjusted,
            CAST(mi.tollspriortozc as NUMERIC) AS tollspriortozc,
            CAST(mi.vtollamountpriortozc as NUMERIC) AS vtollamountpriortozc,
            CAST(mi.excusedamountpriortozc as NUMERIC) AS excusedamountpriortozc,
            CAST(mi.tollsadjustedpriortozc as NUMERIC) AS tollsadjustedpriortozc,
            --CAST(VtollsAdjusteddPriortoZC AS DECIMAL(19,2)) AS VtollsAdjusteddPriortoZC,
            CAST(mi.tollspaidpriortozc as NUMERIC) AS tollspaidpriortozc,
            --CAST(VtollsPaidPriortoZC AS DECIMAL(19,2)) AS VtollsPaidPriortoZC,
            mi.edw_update_date
        FROM mi
            LEFT OUTER JOIN EDW_TRIPS_STAGE.DismissedVToll AS vt 
                ON vt.invoicenumber = CAST( mi.invoicenumber AS STRING) ;


    SET log_message = 'Loaded EDW_TRIPS_STAGE.Invoice';

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);


    --=============================================================================================================
    -- Load EDW_TRIPS_STAGE.NonMigratedInvoice
    --=============================================================================================================


    CREATE TEMPORARY TABLE _SESSION.cte_main AS (
                    SELECT
                        mi.invoicenumber,
                        mi.firstinvoiceid,
                        mi.currentinvoiceid,
                        mi.customerid,
                        mi.migratedflag,
                        CASE
                          WHEN (mi.vtolltxncnt - mi.vtolltxncntpriortozc) = (mi.txncnt - mi.txncntpriortozc) THEN 1
                          ELSE coalesce(vt.vtollflag, -1)
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
                        pp.paymentplanid,
                        mi.invoicestatusid,
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
                        coalesce(CAST(CASE
                            WHEN coalesce(vt.vtollflag, -1) = 1
                            AND vt.firstpaymentdate > mi.zipcashdate THEN CAST(coalesce(vt.firstpaymentdate,'1900-01-01') as DATE)
                            WHEN coalesce(vt.vtollflag, -1) = 1
                            AND vt.firstpaymentdate > mi.zipcashdate
                            AND vt.paidamount_vt = 0
                            AND vt.tolls = CASE
                                WHEN coalesce(vt.vtollflag, -1) = 1 THEN vt.tollsadjusted + vt.tollsadjustedaftervtoll + vt.adjustedamount_excused + vt.classadj
                                ELSE mi.tollsadjusted
                            END THEN '1900-01-01'   -- This is because paid date is taken from customer trips posted date. eventhough there is no payment(tollspaid=0), there will be a posted date for that invoice
                            END as DATE), CASE
                            WHEN coalesce(vt.vtollflag, -1) = 0
                            AND vt.firstpaymentdate > mi.zipcashdate THEN CASE
                                WHEN CAST(coalesce(mi.firstpaymentdateafterzc, '1900-01-01') as DATE) < CAST(coalesce(vt.firstpaymentdate, '1900-01-01') AS DATE)
                                AND CAST(coalesce(mi.firstpaymentdateafterzc, '1900-01-01') as DATE) <> DATE '1900-01-01' THEN CAST(coalesce(mi.firstpaymentdateafterzc, '1900-01-01') as DATE)
                                WHEN CAST(coalesce(mi.firstpaymentdateafterzc, '1900-01-01') as DATE) > CAST(coalesce(vt.firstpaymentdate,'1900-01-01') as DATE)
                                AND CAST(coalesce(vt.firstpaymentdate,'1900-01-01') as DATE) = DATE '1900-01-01' THEN CAST(coalesce(mi.firstpaymentdateafterzc, '1900-01-01') as DATE)
                                ELSE CAST(coalesce(vt.firstpaymentdate,'1900-01-01') as DATE)
                            END
                            WHEN ui.unassignedflag = 1 THEN NULL
                            ELSE CAST( mi.firstpaymentdateafterzc as DATE)
                            END) AS firstpaymentdateafterzc,
                        coalesce(CAST(CASE
                            WHEN coalesce(vt.vtollflag, -1) = 1
                                AND vt.firstpaymentdate > mi.zipcashdate THEN CAST(coalesce(vt.lastpaymentdate, '1900-01-01') as DATE)
                            WHEN coalesce(vt.vtollflag, -1) = 1
                                AND vt.firstpaymentdate > mi.zipcashdate
                                AND vt.paidamount_vt = 0
                                AND vt.tolls = CASE
                                    WHEN coalesce(vt.vtollflag, -1) = 1 THEN vt.tollsadjusted + vt.tollsadjustedaftervtoll + vt.adjustedamount_excused + vt.classadj
                                    ELSE mi.tollsadjusted
                                END THEN '1900-01-01'    -- This is because paid date is taken from customer trips posted date. eventhough there is no payment(tollspaid=0), there will be a posted date for that invoice
                            END as DATE), CASE
                                WHEN coalesce(vt.vtollflag, -1) = 0
                                    AND vt.firstpaymentdate > mi.zipcashdate THEN CASE
                                        WHEN CAST(coalesce(mi.lastpaymentdateafterzc, '1900-01-01') as DATE) > CAST(coalesce(vt.lastpaymentdate,'1900-01-01') as DATE) THEN CAST(coalesce(mi.lastpaymentdateafterzc, '1900-01-01') as DATE)
                                        ELSE CAST(coalesce(vt.lastpaymentdate,'1900-01-01') as DATE)
                            END
                            WHEN ui.unassignedflag = 1 THEN NULL
                            ELSE CAST(mi.lastpaymentdateafterzc as DATE)
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
                        (mi.txncnt - mi.txncntpriortozc) AS txncntafterzc,
                        (mi.vtolltxncnt - mi.vtolltxncntpriortozc) AS vtolltxncntafterzc,
                        (mi.paidtxncnt - mi.paidtxncntpriortozc) AS paidtxncntafterzc,
                        (mi.excusedtxncnt - mi.excusedtxncntpriortozc) AS excusedtxncntafterzc,
                        mi.txncnt,
                        mi.excusedtxncnt,
                        ui.unassignedtxncnt,
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
                        -- EA - Expected Amount
                        mi.vtollamountpriortozc,
                         --(VtollAmount - VtollAmountPriortoZC) VtollAmountAfterZC,
                        mi.vtollamount,
                        mi.excusedamountpriortozc,
                        --(ExcusedAmount-ExcusedAmountPriortoZC) ExcusedAmountAfterZC,
                        mi.excusedamount,
                        mi.tollspriortozc AS tollspriortozc,
                        --(MI.Tolls - MI.TollsPriortoZC) TollsAfterZC,
                        mi.tolls,
                        mi.fnfees,
                        mi.snfees,
                        mi.tolls + mi.fnfees + mi.snfees AS expectedamount,
                        --- AA - AdjustedAmount
                        mi.tollsadjustedpriortozc,
                        --(MI.TollsAdjusted - TollsAdjustedPriortoZC) TollsAdjustedAfterZC,
                        mi.tollsadjusted,
                        mi.fnfeesadjusted,
                        mi.snfeesadjusted,
                        mi.tollsadjusted + mi.fnfeesadjusted + mi.snfeesadjusted AS adjustedamount,
                        --VtollsAdjusteddPriortoZC,
		
                        --------- AEA - AdjustedExpectedAmount

                        ---------- AET = ET-TA
                        ---------- AETPriortoZC
                        mi.tollspriortozc - mi.tollsadjustedpriortozc AS adjustedexpectedtollspriortozc,
                        -----------AETAfterZC
				        --((MI.Tolls - MI.TollsPriortoZC) - (MI.TollsAdjusted - TollsAdjustedPriortoZC)) AS AdjustedExpectedTollsAfterZC,

                        mi.tolls - mi.tollsadjusted AS adjustedexpectedtolls,
                        -- AEFn = EFn-FnA
                        mi.fnfees - mi.fnfeesadjusted AS adjustedexpectedfnfees,
                        --- AESn = ESn-AA
                        mi.snfees - mi.snfeesadjusted AS adjustedexpectedsnfees,
                        --- AEA = EA-AA
                        (mi.tolls - mi.tollsadjusted) + (mi.fnfees - mi.fnfeesadjusted) + (mi.snfees - mi.snfeesadjusted) AS adjustedexpectedamount,
                        --- PA - PaidAmount
                        mi.tollspaidpriortozc,
                        --(MI.TollsPaid - MI.TollsPaidPriortoZC) TollsPaidAfterZC,
                        mi.tollspaid,
                        --MI.VtollsPaidPriortoZC,
                        mi.fnfeespaid,
                        mi.snfeespaid,
                        mi.tollspaid + mi.fnfeespaid + mi.snfeespaid AS paidamount,
                        ------------- OA  - OutstandingAmount
                        CASE
                          WHEN mi.txnpriortozcflag = 1 THEN mi.tollspriortozc - mi.tollsadjustedpriortozc - mi.tollspaidpriortozc
                            ELSE 0
                          END AS tolloutstandingamountpriortozc,

                        --(
						--(CASE 
						--	 WHEN VTollFlag=1 THEN VT.outstandingamount
						--	 ELSE 
						--	 ( ----- AET=ET-TA
						--	(MI.Tolls -  MI.TollsAdjusted)
						--	 - ------PA
						--	 (MI.TollsPaid)
						--	  )
						-- END)
						-- -
						-- (CASE 
						--	  WHEN VTollFlag=1 AND MI.FirstPaymentDatePriortoZC=Vt.FirstPaymentDate THEN VT.outstandingamount
						--	 ELSE 
						--	 ( ----- AET=ET-TA
						--	(MI.TollsPriortoZC -  MI.TollsAdjustedPriortoZC)
						--	 - ------PA
						--	 (MI.TollsPaidPriortoZC)
						--	  )
						--  END)
						--) AS TollOutStandingAmountAfterZC,

                        ------------- TO = AEA-TP
                        CASE
                            WHEN vt.vtollflag = 1 THEN ((vt.tolls - vt.tollsadjusted) - vt.paidamount_vt)
                            ELSE 
                            (  ------ AET=ET-TA)
                                (mi.tolls - mi.tollsadjusted) 
                                - ------PA
                                (mi.tollspaid)
                            )
                        END AS tolloutstandingamount,
                        -- FnO = AEFn-FnP
                        mi.fnfees - mi.fnfeesadjusted - mi.fnfeespaid AS fnfeesoutstandingamount,
                        mi.snfees - mi.snfeesadjusted - mi.snfeespaid AS snfeesoutstandingamount,
                        --- OA = AEA-OA
                        CASE
                            WHEN vt.vtollflag = 1 THEN CAST(vt.outstandingamount AS BIGNUMERIC)
                            ELSE 
                                (   ----- AET=ET-TA
                                    (mi.tolls - mi.tollsadjusted)
                                     - -------PA
                                    (mi.tollspaid)
                                )
                        END 
                        + 
                        (mi.fnfees - mi.fnfeesadjusted - mi.fnfeespaid) 
                        + 
                        (mi.snfees - mi.snfeesadjusted - mi.snfeespaid) 
                        AS outstandingamount,
                        mi.invoicestatus
                        -- select * 
                FROM EDW_TRIPS_STAGE.Invoice AS mi
                LEFT OUTER JOIN EDW_TRIPS_STAGE.DismissedVToll AS vt ON vt.invoicenumber =CAST( mi.invoicenumber AS STRING)
                LEFT OUTER JOIN EDW_TRIPS_STAGE.UnassignedInvoice AS ui ON ui.invoicenumber = CAST( mi.invoicenumber AS STRING)
                LEFT OUTER JOIN (           --------------- PaymentPlanID
                  SELECT DISTINCT
                      mbsi.invoicenumber,
                      pp_0.paymentplanid,
                      mbsi.mbsid
                    FROM
                      LND_TBOS.TollPlus_MbsInvoices AS mbsi
                      INNER JOIN LND_TBOS.TER_PaymentPlanViolator AS ppvt ON ppvt.mbsid = mbsi.mbsid
                      INNER JOIN EDW_TRIPS.Fact_PaymentPlan AS pp_0 ON pp_0.mbsid = mbsi.mbsid
                       AND pp_0.paymentplanstatusid = 48    -- 'Settlement Agreement Active'
                    --WHERE MBSI.InvoiceNumber=1244558720
                ) AS pp ON pp.invoicenumber = CAST(mi.invoicenumber AS STRING)
                --WHERE MI.InvoiceNumber=1244558720

                --WHERE MI.InvoiceNumber IN (1258352773,1229872519,1221142112,1244605918,1258371917)
                --WHERE MI.InvoiceNumber=1246702088 -- come back and check 04/14
          );
        CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.NonMigratedInvoice AS
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
              cte_main.paymentplanid,
              cte_main.invoicestatusid,
              CASE
                WHEN coalesce(cte_main.vtollflag, -1) = 1 THEN 99999
                WHEN cte_main.unassignedflag = 1
                 AND (cte_main.fnfeesoutstandingamount = 0
                 AND cte_main.snfeesoutstandingamount = 0) THEN 99998
                WHEN coalesce(cte_main.vtollflag, -1) IN(
                  0, -1
                )
                 AND cte_main.unassignedflag = -1
                 AND (cte_main.expectedamount - cte_main.adjustedamount )= cte_main.paidamount
                 AND cte_main.expectedamount - cte_main.adjustedamount > 0
                 AND (cte_main.fnfeespaid + cte_main.fnfeesadjusted) = cte_main.fnfees
                 AND (cte_main.snfeespaid + cte_main.snfeesadjusted) = cte_main.snfees THEN 516
                WHEN coalesce(cte_main.vtollflag, -1) IN(
                  0, -1
                )
                 AND cte_main.unassignedflag = -1
                 AND cte_main.paidamount > 0
                 AND (cte_main.expectedamount - cte_main.adjustedamount) > cte_main.paidamount
                 OR cte_main.tollspaid > 0 THEN 515
                WHEN coalesce(cte_main.vtollflag, -1) = -1
                 AND cte_main.unassignedflag = -1
                 AND (cte_main.paidamount = 0
                 OR cte_main.paidamount < 0)
                 AND (cte_main.expectedamount - cte_main.adjustedamount) > 0
                 AND (cte_main.expectedamount > cte_main.adjustedamount) THEN 4370
                WHEN coalesce(cte_main.vtollflag, -1) = -1
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
                 AND cte_main.txncntafterzc = 0 THEN 4434       -- This status is for those invoices which are completely Vtolled prior to ZC
                WHEN cte_main.txnpriortozcflag = 1
                 AND cte_main.vtollflag = 1
                 AND (cte_main.vtolltxncnt - cte_main.vtolltxncntpriortozc) = (cte_main.txncnt - cte_main.txncntpriortozc) THEN 99999
                WHEN cte_main.txnpriortozcflag = 1
                 AND (cte_main.tolls - cte_main.tollspriortozc) = (cte_main.tollspaid - cte_main.tollspaidpriortozc)    -- Tolls=Tollspaid
                 AND ((cte_main.expectedamount - cte_main.tollspriortozc) - (cte_main.adjustedamount - cte_main.tollsadjustedpriortozc)) = (cte_main.paidamount - cte_main.tollspaidpriortozc)  --AEA=PA
                 AND ((cte_main.expectedamount - cte_main.tollspriortozc) - (cte_main.adjustedamount - cte_main.tollsadjustedpriortozc)) > 0    -- AEA>0
                 AND cte_main.vtolltxncntafterzc <> cte_main.txncntafterzc  -- VtollTxnCnt<>TxncntAfterZC
                 AND (cte_main.fnfeespaid + cte_main.fnfeesadjusted) = cte_main.fnfees
                 AND (cte_main.snfeespaid + cte_main.snfeesadjusted) = cte_main.snfees
                 AND ((cte_main.tolls - cte_main.tollspriortozc) - (cte_main.tollspaid - cte_main.tollspaidpriortozc)) = 0
                 AND cte_main.fnfeesoutstandingamount = 0
                 AND cte_main.snfeesoutstandingamount = 0 THEN 516
                WHEN cte_main.txnpriortozcflag = 1
                 AND (cte_main.paidamount - cte_main.tollspaidpriortozc) > 0  -- PA>0
                 AND ((cte_main.expectedamount - cte_main.tollspriortozc) - (cte_main.adjustedamount - cte_main.tollsadjustedpriortozc)) > (cte_main.paidamount - cte_main.tollspaidpriortozc)
                 AND cte_main.vtollflag <> 1 THEN 515
                WHEN cte_main.txnpriortozcflag = 1
                 AND ((cte_main.paidamount - cte_main.tollspaidpriortozc) = 0
                 OR (cte_main.paidamount - cte_main.tollspaidpriortozc) < 0) -- PA=0 or PA<0
                 AND ((cte_main.expectedamount - cte_main.tollspriortozc) - (cte_main.adjustedamount - cte_main.tollsadjustedpriortozc)) > 0
                 AND ((cte_main.expectedamount - cte_main.tollspriortozc) > (cte_main.adjustedamount - cte_main.tollsadjustedpriortozc)) THEN 4370
                WHEN cte_main.txnpriortozcflag = 1
                 AND (cte_main.paidamount - cte_main.tollspaidpriortozc) = 0
                 AND (cte_main.adjustedamount - cte_main.tollsadjustedpriortozc) = (cte_main.expectedamount - cte_main.tollspriortozc) THEN 4434
                ELSE -1
              END AS edw_invoicestatusidafterzc,
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

              --- Amounts
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
              (((cte_main.tolls - cte_main.tollspriortozc) - (cte_main.tollsadjusted - cte_main.tollsadjustedpriortozc)) - (cte_main.tollspaid - cte_main.tollspaidpriortozc)) AS tolloutstandingamountafterzc,
              cte_main.tolloutstandingamount,
              cte_main.fnfeesoutstandingamount,
              cte_main.snfeesoutstandingamount,
              cte_main.outstandingamount,
              --CTE_Main.InvoiceStatus ,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_update_date
            FROM
              cte_main
      ;


   
    SET log_message = 'Loaded EDW_TRIPS_STAGE.NonMigratedInvoice';

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
 
    IF trace_flag = 1 THEN 
        SELECT log_source,log_start_date;
    END IF;

    IF trace_flag = 1 THEN
        SELECT 'EDW_TRIPS_STAGE.NonMigratedInvoice ' AS tablename,
            nonmigratedinvoice.*
        FROM EDW_TRIPS_STAGE.NonMigratedInvoice
        ORDER BY 2 DESC LIMIT 1000 ;

    END IF;

    EXCEPTION WHEN ERROR THEN
        BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        SELECT log_source,log_start_date;
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
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


SELECT * FROM LND_TBOS.tollplus.invoice_header WHERE invoicenumber=1204145788

Multiple TpTripID's posted to VT table -- Ex:1230780604
SELECT * FROM LND_TBOS.TollPlus.TP_ViolatedTrips WHERE CitationID IN (
SELECT linkID FROM LND_TBOS.TollPlus.Invoice_LineItems WHERE ReferenceInvoiceID=1226708097 AND CustTxnCategory='Toll') order by tptripID

Invoices Paid using Overpayment

SELECT * FROM  LND_TBOS.TollPlus.TP_Violated_Trip_Receipts_Tracker WHERE CitationID IN 
(SELECT linkid FROM LND_TBOS.TollPlus.Invoice_LineItems WHERE ReferenceInvoiceID=1237618377 --908343647-- AND CustTxnCategory='TOLL')

Overpayments in receipts tracker table

SELECT * FROM  LND_TBOS.TollPlus.TP_Violated_Trip_Receipts_Tracker VTRT
join LND_TBOS.TollPlus.TP_ViolatedTrips VT on VT.CitationID=VTRT.CitationID
WHERE VTRT.CitationID IN 
(SELECT * FROM LND_TBOS.TollPlus.Invoice_LineItems WHERE ReferenceInvoiceID=1228683740 --908343647-- AND CustTxnCategory='TOLL')
and VTRT.citationID=2083171984
order by VTRT.citationID

select * from edw_TRIPS_OLD.dbo.fact_invoice where invoicenumber=1228683740
*/


END;