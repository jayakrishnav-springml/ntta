CREATE OR REPLACE PROCEDURE EDW_TRIPS_Stage.InvoicePayment_Full_Load()
BEGIN
/*
###############################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------------------
Load [Stage].[InvoicePayment_Full_Load] table. 
===============================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------------------
CHG0042443	Gouthami		2023-02-09	New!
									   1) This Stored procedure is created using some part of bubble logic. In order to fix the 
										  credit adjustments issue i.e,Pure payments on transactions that are made through 
										  Adjustments.
									   2) Second stage is created to bring all the Transaction Payments and Adjustments to
										  Invoice level
																			 
================================================================================================================================
Example:
--------------------------------------------------------------------------------------------------------------------------------
EXEC EDW_TRIPS_Stage.InvoicePayment_Full_Load
EXEC Utility.FromLog 'EDW_TRIPS_Stage.InvoicePayment_Full_Load', 1
SELECT TOP 100 'EDW_TRIPS_Stage.InvoicePayment_Full_Load' Table_Name, * FROM EDW_TRIPS_Stage.violtrippayment ORDER BY 2
################################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS_STAGE.InvoicePayment_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL , NULL );

	--=============================================================================================================
		-- Load EDW_TRIPS_Stage.DismissedVtollTxn
	--=============================================================================================================
          CREATE TEMPORARY TABLE _SESSION.cte_vtolls AS (
            SELECT
                vt.referenceinvoiceid AS invoicenumber,
                tc.tptripid,
                vt.tptripid AS tptripid_vt,
                tc.custtripid,
                vt.citationid,
                vt.tripstatusid AS tripstatusid_vt,
                tc.tripstatusid AS tripstatusid_ct,
                CASE
                  WHEN tc.paymentstatusid = 456
                   AND vt.sourceviolationstatus = 'Z' THEN 3852
                  ELSE tc.paymentstatusid
                END AS paymentstatusid,
                tc.posteddate,
                CASE
                  WHEN count(vt.tptripid) > 1
                   AND sum(CASE
                    WHEN tc.tripstatusid = 2 THEN 1
                    ELSE 0
                  END) > 1 THEN CAST(div(vt.pbmtollamount, count(vt.tptripid)) as NUMERIC)
                  ELSE CASE
                    WHEN tc.paymentstatusid = 3852
                     AND vt.tripstatusid <> 154
                     AND tc.tripstatusid NOT IN(
                      155, 159, 135, 170
                    ) THEN 0
                    ELSE vt.pbmtollamount
                  END-- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
                END AS pbmtollamount,
                CASE
                  WHEN count(vt.tptripid) > 1
                   AND sum(CASE
                    WHEN tc.tripstatusid = 2 THEN 1
                    ELSE 0
                  END) > 1 THEN CAST(div(vt.avitollamount, count(vt.tptripid)) as NUMERIC)
                  ELSE CASE
                    WHEN tc.paymentstatusid = 3852
                     AND vt.tripstatusid <> 154
                     AND tc.tripstatusid NOT IN(
                      155, 159, 135, 170
                    ) THEN 0
                    ELSE vt.avitollamount
                  END -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
                END AS avitollamount,
                CASE
                  WHEN count(vt.tptripid) > 1
                   AND sum(CASE
                    WHEN tc.tripstatusid = 2 THEN 1
                    ELSE 0
                  END) > 1 THEN CAST(div(vt.tollamount, count(vt.tptripid)) as NUMERIC)   --Ex:1226708097 
                  ELSE CASE
                    WHEN tc.paymentstatusid = 3852
                     AND vt.tripstatusid <> 154
                     AND tc.tripstatusid NOT IN(
                      155, 159, 135, 170
                    ) THEN 0
                    ELSE vt.tollamount
                  END -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
                END AS tolls,
                CASE
                  WHEN count(vt.tptripid) > 1 THEN div(sum(CASE
                    WHEN tc.paymentstatusid = 456
                     AND tc.tripstatusid = 5 THEN tc.tollamount
                    WHEN tc.paymentstatusid = 456 THEN tc.tollamount
                    WHEN tc.paymentstatusid = 457 THEN tc.tollamount - tc.outstandingamount
                    ELSE 0
                  END), count(vt.tptripid))
                  ELSE sum(CASE
                    WHEN tc.paymentstatusid = 456
                     AND tc.tripstatusid = 5 THEN tc.tollamount
                    WHEN tc.paymentstatusid = 456
                     AND vt.sourceviolationstatus = 'Z' THEN 0
                    WHEN tc.paymentstatusid = 456 THEN tc.tollamount
                    WHEN tc.paymentstatusid = 457 THEN tc.tollamount - tc.outstandingamount
                    ELSE 0
                  END)
                END AS paidamount_vt,
                tc.outstandingamount,
                sum(CASE
                  WHEN tc.paymentstatusid = 456
                   AND vt.sourceviolationstatus = 'Z' THEN tc.tollamount
                  WHEN tc.paymentstatusid = 3852
                   AND tc.tripstatusid = 135
                   AND vt.paymentstatusid = 456
                   AND vt.tripstatusid = 2 THEN 0 -- these are the txns that got posted in VT table and paid in vtrt 
                  WHEN tc.paymentstatusid = 3852
                   AND tc.tripstatusid = 118/* 118 - Unmatched , 135 - CSR Adjusted*/ THEN 0 -- 1223509842
                  WHEN tc.paymentstatusid = 458
                   AND tc.outstandingamount <> tc.tollamount
                   AND tc.outstandingamount = tc.pbmtollamount
                   AND tc.outstandingamount = tc.avitollamount THEN tc.tollamount - tc.outstandingamount -- Ex:1236741507	
                  WHEN vt.tripstatusid = 154
                   AND tc.tripstatusid = 135
                   AND tt.paymentstatusid = 456 THEN vt.tollamount -- Trips that got vtolled and posted to different zipcash account
                  WHEN tc.paymentstatusid = 3852
                   AND tc.tripstatusid = 135
                   AND vt.paymentstatusid = 3852 THEN vt.tollamount --ex:1225983731
                  WHEN tc.paymentstatusid = 3852
                   AND tc.tripstatusid = 154 THEN 0 --Ex:1222959778
                  WHEN tc.paymentstatusid = 3852 THEN vt.amount
                  WHEN tc.tollamount <> vt.amount THEN vt.amount - tc.tollamount
                  WHEN tc.tollamount = tc.pbmtollamount
                   AND tc.outstandingamount = tc.avitollamount
                   AND tc.paymentstatusid = 458 THEN tc.tollamount - tc.outstandingamount --Ex:1234342591
                  WHEN tc.tollamount = tc.pbmtollamount THEN 0
                  WHEN tc.tollamount = 0
                   AND vt.tollamount = tc.pbmtollamount THEN tc.pbmtollamount
                  WHEN tc.tollamount = vt.amount
                   AND tc.tollamount <> tc.pbmtollamount
                   AND tc.tollamount <> tc.avitollamount THEN 0
                  WHEN tc.tollamount = 0
                   AND tc.paymentstatusid = 456 THEN 0
                  ELSE tc.pbmtollamount - tc.avitollamount
                END) AS tollsadjusted --
              FROM
                (
                  --SELECT * FROM
						      --(
                  SELECT
                      row_number() OVER (PARTITION BY vt_0.tptripid --,L.ReferenceInvoiceID
                          ORDER BY vt_0.citationid DESC, vt_0.exittripdatetime DESC) AS rn_vt,
                      vt_0.citationid,
                      vt_0.tptripid,
                      vt_0.violatorid,
                      vt_0.tollamount,
                      vt_0.outstandingamount,
                      vt_0.pbmtollamount,
                      vt_0.avitollamount,
                      vt_0.citationstage,
                      vt_0.tripstageid,
                      vt_0.tripstatusid,
                      vt_0.stagemodifieddate,
                      vt_0.entrytripdatetime,
                      vt_0.exittripdatetime,
                      vt_0.paymentstatusid,
                      vt_0.posteddate,
                      l.linkid,
                      l.amount,
                      l.linksourcename,
                      l.txndate,
                      l.referenceinvoiceid,
                      l.sourceviolationstatus --SELECT *
                    FROM
                      LND_TBOS.TollPlus_Invoice_Header AS h
                      INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS l ON l.invoiceid = h.invoiceid
                      INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt_0 ON l.linkid = vt_0.citationid
                       AND l.linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                       AND vt_0.tripstatusid NOT IN(
                        171, 170, 118
                      )
                      --WHERE VT.TpTripID=2170804023
										--AND (VT.PaymentStatusID<>456 AND  vt.TripStatusID<>2)  -- This is to avoid those Txns that are vtolled first and then moved back to Violated trips table
										--AND VT.TripStatusID NOT IN (171,118) -- EX: 1233445625,1234165987,1230780604. This condition is for the Txns that are unassignd from an invoice and assigned to a different one and then gor VTOLLED.In this case, the citationID is going to change but TPTRIPID remains same. While joining this VT table to CT,we are goint to get all the txns assigned to the TPTRIPID(Assigned and Vtolled). 
								--WHERE VT.TpTripID=5623227552
								--WHERE  VT.TpTripID=3888729265
							--WHERE VT.TpTripID=2592187014
							--WHERE VT.TpTripID=3888497531--3110762177
						 --) VT WHERE  RN_VT=1 --AND VT.ReferenceInvoiceID=1223304290
                ) AS vt
                INNER JOIN (
                  --SELECT * FROM 
						      --(
                  SELECT
                      tc_0.tptripid,
                      tc_0.custtripid,
                      tc_0.tripstatusid,
                      tc_0.paymentstatusid,
                      tc_0.posteddate,
                      tc_0.tollamount,
                      tc_0.pbmtollamount,
                      tc_0.avitollamount,
                      tc_0.outstandingamount,
                      row_number() OVER (PARTITION BY tc_0.tptripid ORDER BY tc_0.custtripid DESC, tc_0.posteddate DESC) AS rn
                    FROM
                      LND_TBOS.TollPlus_TP_CustomerTrips AS tc_0
                    WHERE tc_0.transactionpostingtype NOT IN(
                      'Prepaid AVI', 'NTTA Fleet'
                    )
                    -- AND TC.TpTripID=2170804023
                    --AND TC.TpTripID=3888729265
                    --AND  TC.TpTripID=2592187014
                    --AND TC.TpTripID=3888497531--3110762177
                  --) A WHERE RN=1
                ) AS tc ON tc.tptripid = vt.tptripid
                 AND tc.rn = vt.rn_vt
                INNER JOIN LND_TBOS.TollPlus_TP_Trips AS tt ON tt.tptripid = tc.tptripid
                 AND tt.tripwith IN('C')
                 --WHERE VT.TpTripID=3888729265
                --WHERE TC.TpTripID=3888497531--3110762177
                --WHERE VT.TpTripID=2592187014
                --where VT.TpTripID=3548802379
                  --WHERE H.InvoiceNumber=1230002032 --partial vtoll
                  --WHERE H.InvoiceNumber=1237067582 -- issue in stage table joining to customer trips as these trips have 135 and 2 statuses	
                  --H.InvoiceNumber= 1227517722  -- some of the Txns on these invoice are on the customer account first, and then moved to Violated trips and got invoiced as the auto payment was not done on the account
		            --WHERE H.InvoiceNumber IN (1030630051,1120029424)
              GROUP BY vt.referenceinvoiceid,tc.tptripid,vt.tripstatusid,tc.paymentstatusid,tc.posteddate,vt.tollamount,tc.outstandingamount,
					         vt.tptripid,tc.custtripid,vt.citationid,
					         vt.tripstatusid,
					         vt.paymentstatusid,
					         vt.posteddate,
					         vt.outstandingamount,tc.tripstatusid,vt.pbmtollamount,vt.avitollamount,vt.sourceviolationstatus
          --	) A
		      --GROUP BY A.InvoiceNumber
          
          );
          
          
          CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.DismissedVtollTxn CLUSTER BY tptripid AS
          SELECT
              cte_vtolls.invoicenumber,
              cte_vtolls.tptripid,
              cte_vtolls.citationid,
              cte_vtolls.tripstatusid_ct,
              cte_vtolls.paymentstatusid,
              -- cte.TotalTxnCnt TotalTxnCnt,
              CASE
                WHEN cte_vtolls.paidamount_vt = 0 THEN NULL
                ELSE cte_vtolls.posteddate
              END AS firstpaymentdate,
              CASE
                WHEN cte_vtolls.paidamount_vt = 0 THEN NULL
                ELSE cte_vtolls.posteddate
              END AS lastpaymentdate,
              cte_vtolls.tolls,
              cte_vtolls.pbmtollamount,
              cte_vtolls.avitollamount,
              cte_vtolls.pbmtollamount - cte_vtolls.avitollamount AS premiumamount,
              cte_vtolls.paidamount_vt,
              cte_vtolls.tollsadjusted AS tollsadjusted,
              --cte.ExcusedTollsAdjusted,
              cte_vtolls.outstandingamount,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              cte_vtolls
              --WHERE CTE_Vtolls.TpTripID=3888729265
		            --LEFT JOIN cte ON cte.InvoiceNumber = CTE_Vtolls.InvoiceNumber	
      ;
                            --Log
      SET log_message = 'Loaded EDW_TRIPS_Stage.DismissedVtollTxn';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');

      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_Stage.DismissedVtollTxn' AS tablename,
            dismissedvtolltxn.*
          FROM
            EDW_TRIPS_STAGE.DismissedVtollTxn
        ORDER BY 2 DESC
        LIMIT 100
        ;
      END IF;
	--=============================================================================================================
		-- Load EDW_TRIPS_STAGE.ViolatedTripPayment
	--=============================================================================================================
        CREATE TEMPORARY TABLE _SESSION.cte_vt_receipts_tracker AS (
            SELECT
                vt.tptripid,--TT.TripWith,
                vt.citationid,
                vt.tollamount,
                vt.outstandingamount,
                vt.tripstatusid,
                vt.paymentstatusid,
                rt.tripreceiptid,
                rt.linkid AS rt_linkid,
                rt.linksourcename AS rt_linksourcename,
                rt.txndate,
                rt.amountreceived AS txnamount
              FROM -- LND_TBOS.TollPlus.TP_Trips TT
                LND_TBOS.TollPlus_TP_ViolatedTrips AS vt
                --ON VT.TPTripID = TT.TPTripID AND VT.CitationID = TT.LinkID AND TT.TripWith = 'V' AND TT.LND_UpdateType <> 'D' AND VT.LND_UpdateType <> 'D'
                INNER JOIN LND_TBOS.TollPlus_TP_Violated_Trip_Receipts_Tracker AS rt ON vt.citationid = rt.citationid
                 AND rt.lnd_updatetype <> 'D'
              WHERE rt.linksourcename IN(
                'FINANCE.PAYMENTTXNS', 'FINANCE.ADJUSTMENTS'
              )
              --AND VT.TpTripID=3985864122
              --AND VT.TpTripID=3513822875
              --AND VT.TpTripID=3909830376
              --AND VT.TpTripID=4617548112
              --AND VT.TpTripID=2804016262
              --AND VT.TpTripID=3795348233
          ); 
		      --SELECT * FROM CTE_VT_Receipts_Tracker ORDER BY TPTripID, TxnDate

          CREATE TEMPORARY TABLE _SESSION.cte_ali AS (
            --:: Payment Txns
            SELECT
                rt.*,
                CAST(NULL as INT64) AS adjustmentid,
                CAST(NULL as INT64) AS ali_linkid,
                CAST(NULL as STRING) AS ali_linksourcename,
                1 AS ali_seq
              FROM
                cte_vt_receipts_tracker AS rt
              WHERE rt.rt_linksourcename = 'FINANCE.PAYMENTTXNS'
              --AND RT.TpTripID=3985864122

            UNION DISTINCT

            --:: Payment thru Adjustment and pure Adjustments
            SELECT
                rt.*,
                ali.adjustmentid,
                ali.linkid AS ali_linkid,
                ali.linksourcename AS ali_linksourcename,
                row_number() OVER (PARTITION BY rt.citationid, rt.tripreceiptid, ali.adjustmentid ORDER BY CASE
                  WHEN ali.linksourcename = 'TOLLPLUS.INVOICE_HEADER'
                   OR ali.linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                   AND ali.linkid = rt.citationid THEN 1
                  ELSE 2
                END) AS ali_seq
              FROM
                cte_vt_receipts_tracker AS rt
                INNER JOIN LND_TBOS.Finance_Adjustment_LineItems AS ali ON ali.adjustmentid = rt.rt_linkid
                 AND ali.linksourcename IN(
                  'TOLLPLUS.TP_VIOLATEDTRIPS', 'TOLLPLUS.INVOICE_HEADER', 'FINANCE.ADJUSTMENTS'
                )
                 AND rt.rt_linksourcename = 'FINANCE.ADJUSTMENTS'
                 AND ali.lnd_updatetype <> 'D'
                INNER JOIN LND_TBOS.Finance_Adjustments AS adj ON adj.adjustmentid = ali.adjustmentid
                 AND adj.approvedstatusid = 466
                 AND adj.lnd_updatetype <> 'D'
                 --WHERE RT.TpTripID=3985864122
                  --WHERE RT.TpTripID=3513822875
                    --WHERE RT.TpTripID=4617548112
                    --AND RT.TpTripID=2804016262
                    --WHERE RT.TpTripID=3795348233
          ); 
		      --SELECT * FROM CTE_ALI ORDER BY TPTripID, TxnDate, CTE_ALI.ALI_Seq
          CREATE TEMPORARY TABLE _SESSION.cte_viol_payments AS (
            SELECT
                a.tptripid,
                a.citationid,
                a.tollamount,
                a.outstandingamount,
                a.paymentstatusid,
                a.tripstatusid,
                a.txndate,
                a.txnamount,
                CASE
                  WHEN a.rt_linksourcename = 'FINANCE.PAYMENTTXNS'
                   OR NOT (a.ali_linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                   AND a.ali_linkid = a.citationid) THEN a.txnamount
                  ELSE 0
                END AS actualpaidamount,
                CASE
                  WHEN a.ali_linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                   AND a.ali_linkid = a.citationid THEN a.txnamount
                  ELSE 0
                END AS adjustedamount,
                CASE
                  WHEN a.rt_linksourcename = 'FINANCE.PAYMENTTXNS' THEN a.rt_linkid
                END AS paymentid,
                CASE
                  WHEN a.rt_linksourcename = 'FINANCE.ADJUSTMENTS' THEN a.rt_linkid
                END AS adjustmentid,
                a.rt_linksourcename,
                a.ali_linksourcename,
                a.ali_linkid,
                row_number() OVER (PARTITION BY a.citationid ORDER BY a.txndate) AS txnseq,
                a.ali_seq,
                sum(a.txnamount) OVER (PARTITION BY a.citationid ORDER BY a.txndate) AS runningtotalamount
              FROM
                cte_ali AS a
              WHERE a.ali_seq = 1
          );
		      --SELECT * FROM CTE_Viol_Payments ORDER BY TPTripID, TxnDate
          CREATE TEMPORARY TABLE _SESSION.cte_firstcreditadjtxndate AS (
            SELECT
                cte_viol_payments.tptripid,
                cte_viol_payments.citationid,
                max(cte_viol_payments.txndate) AS firstcreditadjtxndate
              FROM
                cte_viol_payments
              WHERE cte_viol_payments.adjustedamount < 0 -- Credit Adjustment
              GROUP BY TpTripID, CitationID
          );

          --SELECT * FROM CTE_FirstCreditAdjTxnDate -- 2021-09-14 13:40:59.197

          CREATE TEMPORARY TABLE _SESSION.cte_validlastzeroamounttxndate AS (
            SELECT
                p.tptripid,
                p.citationid,
                max(p.txndate) AS zeroamounttxndate
              FROM
                cte_viol_payments AS p
                INNER JOIN cte_firstcreditadjtxndate AS cad ON p.tptripid = cad.tptripid
              WHERE p.runningtotalamount = 0
               AND p.txndate < cad.firstcreditadjtxndate /* Example: 2864601976 with Payment Reversal (that is, $0 Running Total) before the first Credit Adjustment */
              GROUP BY P.TpTripID, P.CitationID
          );

          --SELECT * FROM CTE_ValidLastZeroAmountTxnDate -- 2021-09-14 13:34:21.907
          CREATE TEMPORARY TABLE _SESSION.cte_txnamounts AS
              SELECT
                a.tptripid,
                a.citationid,
                CASE
                  WHEN vtolltxn.citationid IS NOT NULL THEN 1
                  ELSE 0
                END AS vtollflag,
                CASE
                  WHEN a.paymentstatusid = 3852
                   AND a.tripstatusid IN(
                    153, 154
                  ) THEN coalesce(vtolltxn.tripstatusid_ct, a.tripstatusid)
                  ELSE a.tripstatusid
                END AS tripstatusid,
                a.totaltxnamount,
                a.tollamount,
                CASE
                  WHEN a.paymentstatusid = 3852
                   AND a.tripstatusid IN(
                    153, 154
                  ) THEN coalesce(vtolltxn.tollsadjusted, a.adjustedamount * -1)/*3795348233*/ 
                  ELSE a.adjustedamount * -1
                END AS adjustedamount,
                CASE
                  WHEN (a.paymentstatusid = 3852
                   OR a.paymentstatusid = 456)
                   AND a.tripstatusid IN(
                    153, 154
                  ) THEN CAST(vtolltxn.paidamount_vt as BIGNUMERIC)
                  WHEN a.paymentstatusid = 456 THEN a.actualpaidamount
                  ELSE a.actualpaidamount
                END AS actualpaidamount,
                CASE
                  WHEN (a.paymentstatusid = 3852
                   OR a.paymentstatusid = 456)
                   AND a.tripstatusid IN(
                    153, 154
                  ) THEN vtolltxn.outstandingamount
                  ELSE a.outstandingamount
                END AS outstandingamount,
                CASE
                  WHEN (a.paymentstatusid = 3852
                   OR a.paymentstatusid = 456)
                   AND a.tripstatusid IN(
                    153, 154
                  ) THEN coalesce(vtolltxn.paymentstatusid, a.paymentstatusid)
                  ELSE a.paymentstatusid
                END AS paymentstatusid,
                CASE
                  WHEN (a.paymentstatusid = 3852
                   OR a.paymentstatusid = 456)
                   AND a.tripstatusid IN(
                    153, 154
                  ) THEN vtolltxn.firstpaymentdate
                  WHEN a.tripstatusid NOT IN(
                    456, 457
                  )
                   AND a.actualpaidamount = 0 THEN NULL
                  WHEN a.tripstatusid = 170
                   AND a.actualpaidamount = 0 THEN NULL
                  ELSE a.firstpaiddate
                END AS firstpaiddate,
                CASE
                  WHEN (a.paymentstatusid = 3852
                   OR a.paymentstatusid = 456)
                   AND a.tripstatusid IN(
                    153, 154
                  ) THEN vtolltxn.lastpaymentdate
                  WHEN a.tripstatusid NOT IN(
                    456, 457
                  )
                   AND a.actualpaidamount = 0 THEN NULL
                  WHEN a.tripstatusid = 170
                   AND a.actualpaidamount = 0 THEN NULL
                  ELSE a.lastpaiddate
                END AS lastpaiddate,
                CASE
                  WHEN (a.paymentstatusid = 3852
                   OR a.paymentstatusid = 456)
                   AND a.tripstatusid = 170 THEN a.lastpaiddate
                  ELSE NULL
                END AS excuseddate,
                current_datetime() AS edw_updatedate
              --SELECT * 
              FROM
                (
                  SELECT
                      vp.tptripid,
                      vp.citationid,
                      vp.tripstatusid,
                      CAST(sum(vp.txnamount) as NUMERIC) AS totaltxnamount,
                      vp.tollamount,
                      CAST(sum(vp.adjustedamount) as NUMERIC) AS adjustedamount,
                      CAST(sum(vp.actualpaidamount) * -1 as NUMERIC) AS actualpaidamount,
                      vp.outstandingamount,
                      vp.paymentstatusid,
                      min(vp.txndate) AS firstpaiddate,
                      max(vp.txndate) AS lastpaiddate
                    FROM
                      cte_viol_payments AS vp
                    WHERE NOT EXISTS (
                      SELECT
                          1
                        FROM
                          cte_validlastzeroamounttxndate AS zd
                        WHERE zd.citationid = vp.citationid
                         AND vp.txndate <= zd.zeroamounttxndate
                    )
                    GROUP BY VP.TpTripID, VP.CitationID, VP.TollAmount, VP.OutstandingAmount, VP.PaymentStatusID ,VP.TripStatusID
                ) AS a
                LEFT OUTER JOIN EDW_TRIPS_STAGE.DismissedVtollTxn AS vtolltxn ON vtolltxn.tptripid = a.tptripid
                 AND vtolltxn.citationid = a.citationid;
                  --WHERE A.TpTripID=2168982908
                  --WHERE A.TpTripID=3795348233
                  --WHERE A.TpTripID=3513822875

          CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.ViolTripPayment AS
          SELECT
              cte_txnamounts.tptripid,
              cte_txnamounts.citationid,
              cte_txnamounts.vtollflag,
              cte_txnamounts.tripstatusid,
              cte_txnamounts.totaltxnamount,
              cte_txnamounts.tollamount,
              cte_txnamounts.adjustedamount,
              cte_txnamounts.actualpaidamount,
              cte_txnamounts.outstandingamount,
              CASE
                WHEN cte_txnamounts.actualpaidamount = cte_txnamounts.tollamount
                 AND cte_txnamounts.tripstatusid = 170 THEN 456
                ELSE cte_txnamounts.paymentstatusid
              END AS paymentstatusid,
              cte_txnamounts.firstpaiddate,
              cte_txnamounts.lastpaiddate,
              cte_txnamounts.excuseddate,
              cte_txnamounts.edw_updatedate
            FROM
              cte_txnamounts
            ;

      		-- Log 
      SET log_message = 'Loaded EDW_TRIPS_Stage.ViolTripPayment';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_Stage.ViolTripPayment' AS tablename,
            violtrippayment.*
          FROM
            EDW_TRIPS_STAGE.ViolTripPayment
        ORDER BY
          2 DESC
        LIMIT 100
        ;
      END IF;

      
      
		--------------------------------------------------------------------------------------------------------------------
		-- load EDW_TRIPS_STAGE.InvoicePayment_NEW - This is to sum up at Invoice level
		-------------------------------------------------------------------------------------------------------------------

    CREATE TEMPORARY TABLE _SESSION.cte_paymentchannel AS
    SELECT
              pivottable.invoicenumber,
             CONCAT('', SUBSTR(CAST(CONCAT(coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`1`), CAST('' as STRING)) ,coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`2`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`3`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`4`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`5`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`6`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`7`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`8`), CAST('' as STRING))) AS STRING), 4)) AS paymentchannel
            FROM
              (
                SELECT
                    a.*,
                    row_number() OVER (PARTITION BY a.invoicenumber ORDER BY a.channelname) AS channelnumber
                  FROM
                    (
                      SELECT DISTINCT
                          invoicenumber,
                          channelname
                        FROM
                          EDW_TRIPS.Fact_PaymentDetail AS pd
                          INNER JOIN EDW_TRIPS.Dim_Channel AS pc ON pd.channelid = pc.channelid
                          INNER JOIN EDW_TRIPS.Dim_POSLocation AS pos ON pos.posid = pd.posid
                          --WHERE PD.InvoiceNumber IN (1249075076,1198639441,1254902914,1239190976)
                        --WHERE PD.InvoiceNumber=1257480211
                        --WHERE PD.InvoiceNumber=1257517968
                        --WHERE InvoiceNumber IN (1193212468 ,850223486,1233700037)
                    ) AS a --ORDER BY A.InvoiceNumber
              ) AS sourcetable PIVOT(max(COLLATE(sourcetable.channelname,'')) FOR sourcetable.channelnumber IN (1 AS `1`, 2 AS `2`, 3 AS `3`, 4 AS `4`, 5 AS `5`, 6 AS `6`, 7 AS `7`, 8 AS `8`)) AS pivottable
        ;

      CREATE TEMPORARY TABLE _SESSION.cte_pos AS
      SELECT
                pivottable.invoicenumber,
               CONCAT('', SUBSTR(CAST(CONCAT(coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`1`), CAST('' as STRING)) ,coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`2`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`3`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`4`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`5`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`6`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`7`), CAST('' as STRING)) , coalesce(CONCAT(CAST(' - ' as STRING) , pivottable.`8`), CAST('' as STRING))) AS STRING), 4)) AS pos
              FROM
                (
                  SELECT
                      a.*,
                      row_number() OVER (PARTITION BY a.invoicenumber ORDER BY a.posname) AS posnumber
                    FROM
                      (
                        SELECT DISTINCT
                            invoicenumber,
                            pos.posname
                          FROM
                            EDW_TRIPS.Fact_PaymentDetail AS pd
                            INNER JOIN EDW_TRIPS.Dim_POSLocation AS pos ON pos.posid = pd.posid
                            --WHERE PD.InvoiceNumber IN (1249075076,1198639441,1254902914,1239190976)
                            --WHERE PD.InvoiceNumber=1257480211
                            --WHERE PD.InvoiceNumber=1257517968
                            --WHERE InvoiceNumber IN (1193212468 ,850223486,1233700037)
                      ) AS a--ORDER BY A.InvoiceNumber
                ) AS sourcetable PIVOT(max(COLLATE(sourcetable.posname,'')) FOR sourcetable.posnumber IN (1 AS `1`, 2 AS `2`, 3 AS `3`, 4 AS `4`, 5 AS `5`, 6 AS `6`, 7 AS `7`, 8 AS `8`, 9 AS `9`, 10 AS `10`, 11 AS `11`, 12 AS `12`)) AS pivottable
      ;

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.InvoicePayment
        AS
          SELECT
              CAST(a.referenceinvoiceid as INT64) AS invoicenumber,
              --CAST(SUM(A.InvoiceAmount) AS DECIMAL(19,2)) InvoiceAmount,
              max(a.excuseddate) AS excuseddate,
             min(a.firstpaymentdatepriortozc) AS firstpaymentdatepriortozc,
              CASE
                WHEN max(a.lastpaymentdatepriortozc) IS NULL
                 AND min(a.firstpaymentdatepriortozc) < min(a.firstpaymentdateafterzc) THEN min(a.firstpaymentdatepriortozc)
                ELSE max(a.lastpaymentdatepriortozc)
              END AS lastpaymentdatepriortozc,
              min(a.firstpaymentdateafterzc) AS firstpaymentdateafterzc,
              max(a.lastpaymentdateafterzc) AS lastpaymentdateafterzc,
              pc.paymentchannel,
              pos.pos as pos,
              CAST(sum(a.pbmtollamount) as NUMERIC) AS pbmtollamount,
              CAST(sum(a.avitollamount) as NUMERIC) AS avitollamount,
              CAST(sum(a.tolls) as NUMERIC) AS tolls,
              sum(a.tollspaid) AS tollspaid,
              sum(a.tollsadjusted) AS tollsadjusted,
              current_datetime() AS edw_updatedate
            FROM
              (
                SELECT
                    il.referenceinvoiceid,
                    vt.tptripid,
                    vt.citationid,
                    vt.tripstatusid,
                    vt.paymentstatusid,
                    exittripdatetime,
                    vt.stagemodifieddate,
								   --CASE WHEN IL.TxnType = 'VTOLL' THEN CAST(IL.CreatedDate AS DATE) ELSE NULL END AS ZipCashDate,
                    max(t.excuseddate) AS excuseddate,
                    min(CASE
                      WHEN t.actualpaidamount > 0
                       AND t.firstpaiddate < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                      END THEN CAST(t.firstpaiddate as DATE)
                      ELSE NULL
                    END) AS firstpaymentdatepriortozc,
                    max(CASE
                      WHEN t.actualpaidamount > 0
                       AND t.lastpaiddate < CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                      END THEN CAST(t.lastpaiddate as DATE)
                      ELSE NULL
                    END) AS lastpaymentdatepriortozc,
                    min(CASE
                      WHEN t.actualpaidamount > 0
                       AND t.firstpaiddate > CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                      END THEN CAST(t.firstpaiddate as DATE)
                      WHEN t.actualpaidamount > 0
                       AND t.lastpaiddate > CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                      END THEN CAST(t.lastpaiddate as DATE)
                      ELSE NULL
                    END) AS firstpaymentdateafterzc,
                    max(CASE
                      WHEN t.actualpaidamount > 0
                       AND t.lastpaiddate > CASE
                        WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                        ELSE DATE '1900-01-01'
                      END THEN CAST(t.lastpaiddate as DATE)
                      ELSE NULL
                    END) AS lastpaymentdateafterzc,
                    vt.tollamount,
                    avitollamount,
                    pbmtollamount,
								   --CASE WHEN  IL.CustTxnCategory IN ('TOLL','FEE' ) THEN IL.Amount ELSE  0 END  InvoiceAmount,
                    CASE
                      WHEN il.linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS' THEN il.amount
                      ELSE 0
                    END AS tolls,
                    coalesce(t.actualpaidamount, 0) AS tollspaid,
                    coalesce(t.adjustedamount, 0) AS tollsadjusted,
                    row_number() OVER (PARTITION BY vt.tptripid, il.referenceinvoiceid ORDER BY vt.citationid DESC, vt.exittripdatetime DESC) AS rn
                  FROM
                    LND_TBOS.TollPlus_Invoice_LineItems AS il
                    INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt ON abs(il.linkid) = vt.citationid
                     AND il.txntype = 'VTOLL'
                     AND citationstage <> 'INVOICE'
                    LEFT OUTER JOIN EDW_TRIPS_STAGE.ViolTripPayment AS t ON vt.citationid = t.citationid
                  --WHERE IL.ReferenceInvoiceID=1214361358
								--WHERE IL.ReferenceInvoiceID=1252802508
								--WHERE IL.ReferenceInvoiceID=1180582597
								--WHERE IL.ReferenceInvoiceID=1253211410
								--WHERE IL.ReferenceInvoiceID IN (1198639441,1249075076,1254902914,1239190976)
								--WHERE IL.ReferenceInvoiceID=1257517968--1257480211---1257517968
								--WHERE IL.ReferenceInvoiceID=1222085789
							--WHERE vt.TpTripID = 3432483382
							--WHERE vt.TpTripID IN (3968522557,3968531731,3969234413,3969252534)
							--WHERE IL.ReferenceInvoiceID IN (1237141486,1236141325,1237171775,1237206818,1237070055,1230776160,1227662935,1225424611,1232976582,1223907444,1227352365,1234364963)
							--WHERE IL.ReferenceInvoiceID IN (1240068046)
							--WHERE IL.ReferenceInvoiceID=1241247249
                  GROUP BY tolls, 
                    tollspaid, 
                    tollsadjusted, 
                    CASE
                    WHEN il.txntype = 'VTOLL' THEN CAST(il.createddate as DATE)
                    ELSE NULL
                    END, 
                    il.referenceinvoiceid,
                    vt.tptripid,
                    vt.citationid, 
                    vt.tripstatusid,
                    vt.paymentstatusid,
                    vt.exittripdatetime,
                    vt.stagemodifieddate,
                    vt.tollamount,
                    vt.avitollamount,
                    vt.pbmtollamount
              ) AS a
              LEFT OUTER JOIN cte_paymentchannel AS pc ON pc.invoicenumber = cast(a.referenceinvoiceid as int64)
              LEFT OUTER JOIN cte_pos AS pos ON pos.invoicenumber = cast(a.referenceinvoiceid as int64)
            WHERE a.rn = 1
            GROUP BY A.ReferenceInvoiceID,PaymentChannel,pos
      ;
      SET log_message = 'Loaded EDW_TRIPS_STAGE.InvoicePayment';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL );

      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL , NULL );
      -- Show results
      IF trace_flag = 1 THEN
        SELECT log_source,log_start_date;
      END IF;
      IF trace_flag = 1 THEN
        SELECT 
            'EDW_TRIPS_STAGE.InvoicePayment ' AS tablename,
            *
          FROM
           -- Printing data from "EDW_TRIPS_STAGE.NonMigratedInvoice" This Looks like a Development Error , Replaced this Table with "EDW_TRIPS_STAGE.InvoicePayment" 
            -- EDW_TRIPS_STAGE.NonMigratedInvoice 
            EDW_TRIPS_STAGE.InvoicePayment
        ORDER BY
          2 DESC LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL );
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;
    END;
  END;