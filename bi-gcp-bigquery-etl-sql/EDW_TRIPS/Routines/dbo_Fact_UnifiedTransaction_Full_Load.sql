CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_UnifiedTransaction_Full_Load`()
BEGIN

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_UnifiedTransaction. This table provides unified 360 degrees view of a transaction. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040134	Shankar 		2021-12-10	New!

CHG0040343	Shankar			2022-01-31	1. Get OOSPlateFlag for all transaction types, not just video.
										2. Add the First Payment Date and Last Payment Date columns. 
										3. Get Paid Amount for prepaid trips from TP_CustomerTrips along with Adj.

CHG0040744 Shankar			2022-03-21  1. Expected Amount. Changes for TSA Txns.
										2. Adjusted Expected Amount. Taking all adjustments to TollAmount into consideration.
										3. Calc Adjusted Amount. AEA - EA.
										4. Paid Amount for Violated Trips. Taking Payment adjustments into account.
										5. Trip Payment Status. Earlier only TripWith = 'V' got Payment Status or else 
										   it is "Unknown". Now Payment Status is available for all Txns. 
										6. Bad Address Flag. Earlier Bad Address flag is ignored for prepaid trips. 
										   Now Bad address flag is available for prepaid trips in delinquent status.
										7. Flags default values. Default value NULL or 0 is replaced with -1 (unknown) 
										   and data type is smallint instead of bit. 
										8. IOP Duplicate Flag. Removed this column from all places. IOP Duplicate Flag = 1 rows
										   are no longer loaded into Bubble fact table/snapshot table.									

CHG0040994 Shankar			2022-05-19  1. Violation paid using Overpayment Adj of paid unmatched transaction

CHG0041141 Shankar, Bhanu	2022-06-30  1. ExpectedAmount logic changes for $0 cases
										2. Rpt_PaidvsAEA and other new columns

CHG0041377 Shankar			2022-08-23	Improve JOIN to find OperationsMappingID when BadAddressFlag = -1 on CustTrips. No data issue.

CHG0041406 Shekhar			2022-08-23  Added the following two columns 
										1. VTollFlag - A flag to identify if a transaction is VTolled or not
										2. ClassAdjustmentFlag - A flag to identify if a transaction has any class adjustment

CHG0042058 Shankar			2022-11-30  If RecordType is not found in Ref.TartTPTrip (TTT) lookup, use RT22 as default value. 
										Default value for TSA Txns is 'V'.

CHG0042058 Shankar			2024-01-09  1. IOP Txns with Invalid PaymentStatusID = 0 in TP_Trips caused duplicate rows 
										   in Bubble stage, dim and fact tables. Treat 0 as NULL.
										2. Add CustTagID in dbo.Fact_UnifiedTransaction table for Fact_TollTransaction_MonthlySummary

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_UnifiedTransaction_Full_Load
SELECT * FROM Utility.ProcessLog Where LogSource LIKE 'dbo.Fact_UnifiedTransaction%' ORDER BY 1 DESC
SELECT TOP 1000 'Stage.UnifiedTransaction' TableName, * FROM Stage.UnifiedTransaction ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction' TableName, * FROM dbo.Fact_UnifiedTransaction ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_Summary' TableName, * FROM dbo.Fact_UnifiedTransaction_Summary ORDER BY 2 DESC,3,4
SELECT TOP 1000 'Fact_UnifiedTransaction_SummarySnapshot' TableName, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot
ORDER BY SnapshotMonthID DESC, TripMonthID DESC, OperationsMappingID, FacilityID
###################################################################################################################
*/

    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_UnifiedTransaction_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE lv_mintxncntunregcustinv INT64;
    DECLARE lv_minamtunregcustinv NUMERIC(33, 4);
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0; -- Testing
    BEGIN
      DECLARE load_cutoff_date DATE DEFAULT '2019-01-01';
		--=============================================================================================================
		-- Load Stage.Uninvoiced_Citation_Summary_BR with Business Rule Matching Flag for unpaid Citations
		--=============================================================================================================
      DECLARE max_id INT64;
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
      SET lv_mintxncntunregcustinv =  (
        SELECT
          CAST(TollPlus_Tp_Application_Parameters.parametervalue AS INT64) 
        FROM
          LND_TBOS.TollPlus_Tp_Application_Parameters
        WHERE TollPlus_Tp_Application_Parameters.parameterkey = 'MinTxnCntUnRegCustInv'
      );
      SET lv_minamtunregcustinv = ( 
        SELECT
          CAST(TollPlus_Tp_Application_Parameters.parametervalue AS NUMERIC) 
        FROM
          LND_TBOS.TollPlus_Tp_Application_Parameters
        WHERE TollPlus_Tp_Application_Parameters.parameterkey = 'MinAmtUnRegCustInv'
      );
      CREATE TEMPORARY TABLE uninvoiced_citation_cte AS (
        SELECT
            vt.violatorid AS customerid,
            vt.tptripid,
            vt.citationid,
            st.tripstatuscode,
            vt.posteddate,
            vt.tollamount
          FROM
            LND_TBOS.TollPlus_TP_ViolatedTrips AS vt
            INNER JOIN LND_TBOS.TollPlus_TripStatuses AS st ON st.tripstatusid = vt.tripstatusid
          WHERE vt.citationstage = 'INVOICE'
            AND vt.outstandingamount > 0
            --AND VT.ViolatorID IN (810858671)
      );
      --SELECT * FROM Uninvoiced_Citation_CTE
      CREATE TEMPORARY TABLE mintxncnt_minamt_cte AS (
        SELECT
            uc.customerid,
            count(1) AS txncount,
            sum(uc.tollamount) AS tollamount
          FROM
            uninvoiced_citation_cte AS uc
            INNER JOIN EDW_TRIPS.Dim_Customer AS c ON c.customerid = uc.customerid
              AND c.paymentplanestablishedflag = 0
              AND c.badaddressflag = 0
          WHERE uc.tripstatuscode NOT IN(
            'UNMATCHED', 'DISPUTE_ADJUSTED', 'HOLD'
          )
          --AND UC.CustomerID IN (810858671)
          GROUP BY uc.customerid
          --HAVING  COUNT(1) >= 3 OR SUM(TollAmount) >= 2.5
          HAVING count(1) >= lv_mintxncntunregcustinv
            OR sum(uc.tollamount) >= lv_minamtunregcustinv
      );
    --SELECT * FROM MinTxnCnt_MinAmt_CTE


      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.Uninvoiced_Citation_Summary_BR
      CLUSTER by citationid
        AS
          SELECT
              uc.customerid,
              uc.tptripid,
              uc.citationid,
              uc.tripstatuscode,
              uc.posteddate,
              uc.tollamount,
              CASE
                WHEN br.customerid IS NOT NULL THEN 1
                ELSE -1
              END AS businessrulematchedflag
            FROM
              uninvoiced_citation_cte AS uc
              LEFT OUTER JOIN mintxncnt_minamt_cte AS br ON uc.customerid = br.customerid
               AND uc.tripstatuscode NOT IN(
                'UNMATCHED', 'DISPUTE_ADJUSTED', 'HOLD'
              )
      ;
      SET log_message = concat('Loaded EDW_TRIPS_STAGE.Uninvoiced_Citation_Summary_BR. Min Txn Count: ', coalesce(substr(CAST(lv_mintxncntunregcustinv as STRING), 1, 30), r'?'), ', Min Amount: $', coalesce(substr(CAST(lv_minamtunregcustinv as STRING), 1, 30), r'?'));
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
		--=============================================================================================================
		-- Load Stage.IPS_Image_Review_Results	02:46	(751481706 row(s) affected)
		--=============================================================================================================
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.IPS_Image_Review_Results
      CLUSTER by tptripid
        AS
          SELECT
              t.imagereviewresultid,
              t.ipstransactionid,
              t.tptripid,
              t.ismanuallyreviewed,
              t.timestamp,
              t.irr_laneid,
              t.irr_facilitycode,
              t.irr_plazacode,
              t.irr_lanecode,
              t.vesserialnumber,
              t.plateregistration,
              t.platejurisdiction,
              t.reasoncode,
              t.disposition,
              t.createduser,
              t.createddate,
              t.updateduser,
              t.updateddate,
              current_datetime() AS edw_updatedate
            FROM
              (
                SELECT
                    imagereviewresultid,
                    ipstransactionid,
                    sourcetransactionid AS tptripid,
                    ismanuallyreviewed,
                    timestamp,
                    l.laneid AS irr_laneid,
                    irr.facilitycode AS irr_facilitycode,
                    irr.plazacode AS irr_plazacode,
                    irr.lanecode AS irr_lanecode,
                    vesserialnumber,
                    plateregistration,
                    platejurisdiction,
                    reasoncode,
                    disposition,
                    irr.createduser,
                    irr.createddate,
                    irr.updateduser,
                    irr.updateddate,
                    row_number() OVER (PARTITION BY sourcetransactionid ORDER BY imagereviewresultid DESC) AS rn
                  FROM
                    LND_TBOS.TollPlus_TP_Image_Review_Results AS irr
                    LEFT OUTER JOIN EDW_TRIPS.Dim_Lane AS l ON l.ips_facilitycode = irr.facilitycode
                     AND l.ips_plazacode = irr.plazacode
                     AND l.lanenumber = CAST( irr.lanecode as STRING)
                  WHERE timestamp >= DATETIME('2021-01-01')
                   AND irr.lnd_updatetype <> 'D'
              ) AS t
            WHERE t.rn = 1
      ;
      SET log_message = 'Loaded EDW_TRIPS_STAGE.IPS_Image_Review_Results';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
		--=============================================================================================================
		-- Load Stage.ViolatedTripPayment
		--=============================================================================================================
          CREATE TEMPORARY TABLE cte_vt_receipts_tracker AS (
            SELECT
                tt.tptripid,
                tt.tripwith,
                tt.exittripdatetime AS tripdate,
                tt.sourceofentry,
                vt.citationid,
                vt.tollamount,
                vt.outstandingamount,
                vt.paymentstatusid,
                tt.isnonrevenue AS nonrevenueflag,
                vt.iswriteoff AS writeoffflag,
                vt.writeoffdate,
                vt.writeoffamount,
                rt.tripreceiptid,
                rt.linkid AS rt_linkid,
                rt.linksourcename AS rt_linksourcename,
                rt.txndate,
                rt.amountreceived AS txnamount
              FROM
                LND_TBOS.TollPlus_TP_Trips AS tt
                INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt ON vt.tptripid = tt.tptripid
                 AND vt.citationid = tt.linkid
                 AND tt.tripwith = 'V'
                 AND tt.lnd_updatetype <> 'D'
                 AND vt.lnd_updatetype <> 'D'
                INNER JOIN LND_TBOS.TollPlus_TP_Violated_Trip_Receipts_Tracker AS rt ON vt.citationid = rt.citationid
                 AND rt.lnd_updatetype <> 'D'
              WHERE rt.linksourcename IN(
                'FINANCE.PAYMENTTXNS', 'FINANCE.ADJUSTMENTS'
              )
               AND tt.sourceofentry IN(
                1, 3
              ) -- TSA & NTTA 
               AND tt.exit_tolltxnid >= 0
               AND tt.exittripdatetime >= '2019-01-01' -- @Load_Cutoff_Date
               AND tt.exittripdatetime < current_datetime()
               --AND (TT.TpTripID IN (2394521987,2864601976,2874007937,3018338513,3035826778,3107276708, 1937242377,2123262841,2171601474,2171750141,2554758633, 1919833818) OR TT.ExitTripDateTime >= '2021-03-22' AND TT.ExitTripDateTime < '2021-03-23')
               --AND VT.TpTripID IN ( 3528694386,3530036803,3533177703,3533218053,3533936506,3533947751,3534230983,3538888035) -- multiple adj lines for 1 adj id which is present multiple times in receipts tracker	
               --AND VT.TpTripID IN (2394521987,2864601976,2874007937,3018338513,3035826778,3107276708) -- credit adj examples -- 34 sec v1 vs 34 sec v2 vs 21 sec v3
               --AND VT.TpTripID IN (1937242377,2123262841,2171601474,2171750141,2554758633) -- debit adj or reversal examples -- 29 sec v1 vs 31 sec v2 vs 15 sec v3  
               --AND VT.TpTripID IN ( 2530609156, 2783824527,2567894441,2546175530,3220034386,2778945056,2771048636,2906264320,2700832365,2554253242,2570011704,2892065183,2916299727,2921527701,2569987575,2562346386,2687491659,2570738870,2710272947,2554227769,2533336522,3222512621,2921518684,2767950434,2908129674,2781993208,2548880101,2772712368,2551876707,2548898756,2771092936,2545101253,2911952388,2728474043,2918579961,2794039088,2698193126,2772748352,2780662960,2787219210,2785127852,2911988452,2710284343,2569966972,2570725824,2918701004,2548160421,2904324362,2569998851,2794050950,2883481160,2767970730,2559240672,2883496334,2562359435,2530609156,2551171685,2542250083,2787698561,3222269254,2885601201,2908099601,2698148524,2542244513,2707416529,2540311885,2670614739,2701672420,2909722943,2535328097,2698175707,2778988034,2791687645,2916312274,2725997000,2698163285,2909732893,2722912816,2782241434,2559260280,2709497858,2678256308,2692840318,2707429111,2684465283,2912023241,2701658801,2561217148,2908072297,2699873934,2680332525,2690547395,2767900673,2704438744,2779018959,2771079091,2530671595,2542254897,2561016876,2916291076,2686591003,2530630931,2692783924,2704451131,2678269980,2546134057,2709528843,2788311617,2772682985,2915286909,2543117461,2912072020,2710259879,2790624026,2567031111,2684496579,2681622064,2530689472,2670645548,2701696558,2916346935,3220109956,2546150392,2775781645,2772655331,2775795383,2540338544,2791707060,2883472077,2915360699,2770146144,2788357594,2692870688,2700800398,2757922434,2681585956,2687476715,2793838585,2785162662,2770171968,2719823856,2709509447,2564390468,2707463395,2787182310,2546111639,2554211406,2913156391,2780751155,2788290813,2535374926,2548129771,3222408002,2722968628,2915307072,2545087725,2703192158,2775324950,2748328854,2566981078,2565101276,2567942967,2545122215,2913237736,2567015915,2545139532,2918483904,2781985846,2724004401,2703149561,2680307257,2777399927,2540373916,2790711986,2565073878,2551152087,2561131127,2684479399,2565089412,2793917459,2548911248,2704473606,2778998889,2704423505,2724019126,2545063514,2687454753,2567927795,2912053093,2909712042,2554269648,2748797020,2687513029,2793874406,2787243738,2908037149,2892096209,2542239740,2707446658,2915251235,2907996567,2913210869,2771113032,2772610806,2771063151,2915339092,2909702920,2533327431,2532925948,2680360934,2551841063,2892173838,2788327767,2678235916,2689570149,2533315455,2692884240,2554238923,2542231068,2561186700,2564410611,2725961220,2723983008,2683414528,2689521538,2906248664,2767918190,2562088341,2726049064,2548148538,2770182406,2783862200,2706390543,2790674882,2538999214,2690572856,2892155192,2686627925,2775822585,2778963540,2892131129,2785142255,2918549063,2570748666,2678188749,2566959522,2748786141,2909748066,2913196561,2791656424,2535356355,2775470814,2782283982,2767936009,2706444837,2699831796,2692898185,2913055414,2775503087,2684514885,2906289945,3223157976,2570022739,2790695886,2532930360,2532914756,2559212006,2683367338,2709475190,2780702732,3526363369,2543085756,2916323310,2770191322,2706422606,2695224322,2709520798,2540289778,2783888482,2787691267,2567907013,2785112335,2683397460,2883462328,2703177497,2530658403,2780725436,2775808530,2770161785,2551818658,2566999124,3219888827,2686532963,2791671042,2906013826,2782259585,2551163089,2913178374,2723007305,2699856017,2707488809,2551141832,2690522107,2775487808,2548931600,2567962652,2533353054,2723975972,2680385672,2564419452,2790655763,2689605468,2551127406,2532939791,2565121092,2690536173,2543101719,2681600831,2561096931,2918525110,2540352603,2684536965,2723008877,2542596023,2793897443,2559227893,2893343305,2722868876,2551855993) 
               --Overpayment from unmatched paid transaction
               --AND VT.TpTripID IN (1919887405, 1921007881,1921239894,1922171267,1922171268) -- 4256 BkrtDismiss
          );
          --SELECT * FROM CTE_VT_Receipts_Tracker ORDER BY TPTripID, TxnDate
          CREATE TEMPORARY TABLE cte_ali AS (
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
                 AND adj.approvedstatusid = 466 -- Approved
                 AND adj.lnd_updatetype <> 'D'
          );
          --SELECT * FROM CTE_ALI ORDER BY TPTripID, TxnDate, CTE_ALI.ALI_Seq
          CREATE TEMPORARY TABLE cte_viol_payments AS (
            SELECT
                cte_ali.tptripid,
                cte_ali.tripdate,
                cte_ali.tripwith,
                cte_ali.tripreceiptid,
                cte_ali.citationid,
                cte_ali.tollamount,
                cte_ali.outstandingamount,
                cte_ali.paymentstatusid,
                cte_ali.nonrevenueflag,
                cte_ali.txndate,
                cte_ali.txnamount,
                CASE
                  WHEN cte_ali.rt_linksourcename = 'FINANCE.PAYMENTTXNS'
                   OR NOT (cte_ali.ali_linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                   AND cte_ali.ali_linkid = cte_ali.citationid) THEN cte_ali.txnamount
                  ELSE 0
                END AS actualpaidamount,
                CASE
                  WHEN cte_ali.ali_linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                   AND cte_ali.ali_linkid = cte_ali.citationid THEN cte_ali.txnamount
                  ELSE 0
                END AS adjustedamount,
                CASE
                  WHEN cte_ali.rt_linksourcename = 'FINANCE.PAYMENTTXNS' THEN cte_ali.rt_linkid
                END AS paymentid,
                CASE
                  WHEN cte_ali.rt_linksourcename = 'FINANCE.ADJUSTMENTS' THEN cte_ali.rt_linkid
                END AS adjustmentid,
                cte_ali.rt_linksourcename,
                cte_ali.ali_linksourcename,
                cte_ali.ali_linkid,
                row_number() OVER (PARTITION BY cte_ali.citationid ORDER BY cte_ali.txndate) AS txnseq,
                cte_ali.ali_seq,
                sum(cte_ali.txnamount) OVER (PARTITION BY cte_ali.citationid ORDER BY cte_ali.txndate) AS runningtotalamount
              FROM
                cte_ali
              WHERE cte_ali.ali_seq = 1
          );
          --SELECT * FROM CTE_Viol_Payments ORDER BY TPTripID, TxnDate
          CREATE TEMPORARY TABLE cte_firstcreditadjtxndate AS (
            SELECT
                cte_viol_payments.tptripid,
                cte_viol_payments.citationid,
                max(cte_viol_payments.txndate) AS firstcreditadjtxndate
              FROM
                cte_viol_payments
              WHERE cte_viol_payments.adjustedamount < 0 -- Credit Adjustment
              GROUP BY cte_viol_payments.tptripid,
                cte_viol_payments.citationid
          );
          --SELECT * FROM CTE_FirstCreditAdjTxnDate -- 2021-09-14 13:40:59.197
          CREATE TEMPORARY TABLE cte_validlastzeroamounttxndate AS (
            SELECT
                p.tptripid,
                p.citationid,
                max(p.txndate) AS zeroamounttxndate
              FROM
                cte_viol_payments AS p
                INNER JOIN cte_firstcreditadjtxndate AS cad ON p.tptripid = cad.tptripid
              WHERE p.runningtotalamount = 0
               AND p.txndate < cad.firstcreditadjtxndate
              GROUP BY p.tptripid,
                p.citationid
          );
          --SELECT * FROM CTE_ValidLastZeroAmountTxnDate -- 2021-09-14 13:34:21.907
          CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.ViolatedTripPayment
          AS
          SELECT
              vp.tptripid,
              vp.citationid,
              vp.tripdate,
              vp.tripwith,
              vp.nonrevenueflag,
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
            GROUP BY vp.tptripid,
              vp.citationid,
              vp.tripdate,
              vp.tripwith,
              vp.nonrevenueflag,
              vp.tollamount,
              vp.outstandingamount,
              vp.paymentstatusid
      ;
      --ORDER BY vp.tptripid
      SET log_message = 'Loaded EDW_TRIPS_STAGE.ViolatedTripPayment';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      --table swap
      -- using Create ot replace instead of this SP in Bigquery
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS_STAGE.ViolatedTripPayment_NEW', 'EDW_TRIPS_STAGE.ViolatedTripPayment');
      
      --:: Soft delete IOP Duplicate TPTripIDs. Quick 1 sec check every time, but update happens in the first run or after the next full load of TP_Trips table. Performance optimization and query simplification measure. Automatically effective for other EDW ETL queries. 
      IF EXISTS (
        SELECT
            1
          FROM
            LND_TBOS.TollPlus_TP_Trips AS tt
            INNER JOIN LND_TBOS.dbo_IopOutBoundAndViolationLinking AS iop ON iop.outboundtptripid = tt.tptripid
          WHERE tt.lnd_updatetype <> 'D'
      ) THEN
        UPDATE LND_TBOS.TollPlus_TP_Trips SET lnd_updatetype = 'D' FROM LND_TBOS.dbo_IopOutBoundAndViolationLinking WHERE iopoutboundandviolationlinking.outboundtptripid = tp_trips.tptripid;
        SET log_message = 'Soft deleted IOP Duplicate trips in LND_TBOS.TollPlus_TP_Trips';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      END IF;

		/*
		--:: Soft delete Duplicate TPTripIDs in TRIPS. 
		IF   EXISTS (
						SELECT	1
						  FROM	LND_TBOS.TollPlus.TP_Trips TT
								JOIN Stage.DuplicateTrips DT ON DT.DuplicateTPTripID = TT.TPTripID
						WHERE	TT.LND_UpdateType <> 'D'
					)  
		BEGIN
			UPDATE	LND_TBOS.TollPlus.TP_Trips
			SET		LND_UpdateType = 'D'
			FROM	Stage.DuplicateTrips 
			WHERE	DuplicateTrips.DuplicateTPTripID = TP_Trips.TPTripID 

			SET  @Log_Message = 'Soft deleted TP_Trips Duplicate trips in LND_TBOS.TollPlus.TP_Trips' 
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		END
		*/

		--=============================================================================================================
		-- Load Stage.Tollrates
		--=============================================================================================================
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.TollRates
      CLUSTER by exitlaneid
        AS
          SELECT
              pvt.entryplazaid,
              pvt.exitplazaid,
              pvt.exitlaneid,
              pvt.lanetype,
              pvt.starteffectivedate,
              pvt.endeffectivedate,
              pvt.vehicleclass,
              pvt.scheduletype,
              pvt.fromtime,
              pvt.totime,
              pvt.avirate AS tagfare,
              pvt.videorate AS platefare
            FROM
              (
                SELECT
                    shdr.entryplazaid,
                    shdr.exitplazaid,
                    shdr.entrylaneid AS exitlaneid,
                    dtls.lanetype,
                    shdr.starteffectivedate,
                    shdr.endeffectivedate,
                    dtls.vehicleclass,
                    sdtls.fromtime,
                    sdtls.totime,
                    dtls.tollamount,
                    hdr.transactionmenthod,
                    scheduletype
                  FROM
                    LND_TBOS.TOLLPLUS_TP_TOLLRATE_HDR AS hdr
                    INNER JOIN LND_TBOS.TOLLPLUS_TP_TOLLRATE_DTLS AS dtls ON hdr.tollratehdrid = dtls.tollrateid
                    INNER JOIN LND_TBOS.TOLLPLUS_TOLLSCHEDULEDTL AS sdtls ON dtls.tollrateid = sdtls.tollrateid
                    INNER JOIN LND_TBOS.TOLLPLUS_TOLLSCHEDULEHDR AS shdr ON sdtls.tollschedulehdrid = shdr.tollschedulehdrid
              ) AS p PIVOT(max(p.tollamount) FOR p.transactionmenthod IN ('AVIRATE' AS avirate, 'VIDEORATE' AS videorate)) AS pvt
      ;
      SET log_message = 'Loaded EDW_TRIPS_STAGE.TollRates';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
  
		--=============================================================================================================
		-- Load Stage.Bubble_CustomerTags. Ensure {CustomerID, TagAgency, SerialNo} is unique in the table
		--============================================================================================================
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.Bubble_CustomerTags
      CLUSTER by customerid
        AS
          SELECT
              ct.custtagid,
              ct.customerid,
              ct.tagagency,
              ct.serialno
            FROM
              (
                SELECT
                    tp_customer_tags.custtagid,
                    tp_customer_tags.customerid,
                    tp_customer_tags.tagagency,
                    tp_customer_tags.serialno,
                    row_number() OVER (PARTITION BY tp_customer_tags.customerid, tp_customer_tags.tagagency, tp_customer_tags.serialno ORDER BY tp_customer_tags.custtagid DESC) AS rn
                  FROM
                    LND_TBOS.TollPlus_TP_Customer_Tags AS tp_customer_tags
              ) AS ct
            WHERE ct.rn = 1
      ;
      SET log_message = 'Loaded EDW_TRIPS_STAGE.Bubble_CustomerTags';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

		--=============================================================================================================
		-- Load Stage.UnifiedTransaction
		--============================================================================================================
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.UnifiedTransaction
      CLUSTER by tptripid 
        AS
        --EXPLAIN 
          SELECT
              ut.tptripid,
              ut.custtripid,
              ut.citationid,
              ut.tripdate,
              coalesce(ut.tripdayid, -1) AS tripdayid,
              ut.laneid,
              coalesce(nullif(ut.customerid, 0), -1) AS customerid,
              coalesce(om.operationsmappingid, -1) AS operationsmappingid,
              coalesce(ut.tripidentmethod, 'Unknown') AS tripidentmethod,
              coalesce(ut.lanetripidentmethod, 'Unknown') AS lanetripidentmethod,
              ut.recordtype,
              ut.tripwith,
              COALESCE(NULLIF(ut.transactionpostingtype, ''), 'Unknown') AS transactionpostingtype,
              coalesce(ut.tripstageid, -1) AS tripstageid,
              coalesce(tsg.tripstagecode, 'Unknown') AS tripstagecode,
              coalesce(ut.tripstatusid, -1) AS tripstatusid,
              coalesce(tst.tripstatuscode, 'Unknown') AS tripstatuscode,
              coalesce(ut.reasoncode, 'Unknown') AS reasoncode,
              coalesce(ut.citationstagecode, 'Unknown') AS citationstagecode,
              coalesce(ut.trippaymentstatusid, -1) AS trippaymentstatusid,
              coalesce(ps.trippaymentstatusdesc, 'Unknown') AS trippaymentstatusdesc,
              ut.sourcename,
              ut.operationsagency,
              ut.facilitycode,
              coalesce(ut.vehicleid, -1) AS vehicleid,
              ut.vehiclenumber,
              ut.vehiclestate,
              ut.tagrefid,
              ut.tagagency,
              ut.vehicleclass,
              ut.revenuevehicleclass,
              ut.sourceofentry,
              ut.sourcetripid,
              ut.disposition,
              ut.ipstransactionid,
              ut.vesserialnumber,
              ut.showbadaddressflag,
              coalesce(CAST( CASE
                WHEN ut.showbadaddressflag = 1 THEN c.badaddressflag
              END as INT64), -1) AS badaddressflag,
              ut.nonrevenueflag,
              ut.businessrulematchedflag,
              ut.manuallyreviewedflag,
              ut.oosplateflag,
              CASE
                WHEN ut.transactionpostingtype LIKE 'VToll%' THEN 1
                ELSE 0
              END AS vtollflag,
              ut.classadjustmentflag,
              CASE
                WHEN coalesce(ut.actualpaidamount, 0) = 0 THEN '0'
                WHEN coalesce(ut.actualpaidamount, 0) > coalesce(ut.adjustedexpectedamount, ut.expectedamount, CAST(0 as NUMERIC)) THEN '>AEA'
                WHEN coalesce(ut.actualpaidamount, 0) < coalesce(ut.adjustedexpectedamount, ut.expectedamount, CAST(0 as NUMERIC)) THEN '<AEA'
                WHEN coalesce(ut.actualpaidamount, 0) = coalesce(ut.adjustedexpectedamount, ut.expectedamount, CAST(0 as NUMERIC)) THEN '=AEA'
              END AS rpt_paidvsaea,
              --:: Metrics
              ut.expectedamount,
              coalesce(ut.adjustedexpectedamount, ut.expectedamount, CAST(0 as NUMERIC)) AS adjustedexpectedamount,
              coalesce(coalesce(ut.adjustedexpectedamount, ut.expectedamount, CAST(0 as NUMERIC)) - coalesce(ut.expectedamount, CAST(0 as NUMERIC)), CAST(0 as BIGNUMERIC)) AS calcadjustedamount,
              CAST( ut.tripwithadjustedamount as NUMERIC) AS tripwithadjustedamount,
              ut.tollamount,
              coalesce(CAST(ut.actualpaidamount as NUMERIC), CAST(0 as NUMERIC)) AS actualpaidamount,
              coalesce(ut.outstandingamount, CAST(0 as BIGNUMERIC)) AS outstandingamount,
              CASE
                WHEN ut.actualpaidamount > 0 THEN ut.firstpaiddate
              END AS firstpaiddate,
              CASE
                WHEN ut.actualpaidamount > 0 THEN ut.lastpaiddate
              END AS lastpaiddate,
              ut.txnagencyid,
              ut.accountagencyid,

              --:: Validation help
              ut.tp_posteddate,
              ut.custtrip_posteddate,
              ut.violatedtrip_posteddate,
              ut.adjustedexpectedamount AS ut_adjustedexpectedamount,
              ut.actualpaidamount AS ut_actualpaidamount,
              
              ut.expectedbase,
              ut.expectedpremium,
              ut.avitollamount,
              ut.pbmtollamount,
              ut.originalavitollamount,
              ut.originalpbmtollamount,

              ut.tp_receivedtollamount,
              ut.nraw_fareamount,
              ut.nraw_vehicleclass_tagfare,
              ut.nraw_vehicleclass_platefare,
              ut.tp_vehicleclass_tagfare,
              ut.tp_vehicleclass_platefare,

              ut.tsa_receivedtollamount,

              ut.violatedtrippayment_totaltxnamount,
              ut.violatedtrippayment_adjustedamount,
              ut.violatedtrippayment_actualpaidamount,

              ut.tollamount AS ut_tollamount,
              ut.tp_tollamount,
              ut.custtrip_tollamount,
              ut.violatedtrip_tollamount,

              ut.tp_outstandingamount,
              ut.custtrip_outstandingamount,
              ut.violatedtrip_outstandingamount,

              ut.tp_tripstatusid,
              ut.custtrip_tripstatusid,
              ut.violatedtrip_tripstatusid,
              ut.tp_tripstageid,
              ut.custtrip_tripstageid,
              ut.violatedtrip_tripstageid,
              ut.tp_paymentstatusid,
              ut.custtrip_paymentstatusid,
              ut.violatedtrip_paymentstatusid,
              ut.ttt_recordtype,
              ut.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              (
                SELECT  --TOP 1 
                    tt.tptripid,
                    ct.custtripid,
                    vt.citationid,
                    tt.exittripdatetime AS tripdate,
                    CAST(CAST( tt.exittripdatetime as STRING FORMAT 'YYYYMMDD') as INT64) AS tripdayid,
                    coalesce(ct.customerid, vt.violatorid) AS customerid,
                    CASE
                      WHEN tt.tripwith = 'V'
                       OR tt.tripwith = 'C'
                       AND ct.tripstatusid = 135 THEN 1
                      ELSE 0
                    END AS showbadaddressflag,
                    tt.exitlaneid AS laneid,
                    coalesce(ct.vehicleid, vt.vehicleid, tt.vehicleid) AS vehicleid,
                    tt.tripidentmethod, --1
                    CASE
                      WHEN ttt.tptripid IS NOT NULL
                       AND ttt.recordtype IN(
                        'RT21', 'RT24', 'RT25'
                      ) THEN 'AVITOLL'
                      WHEN ttt.tptripid IS NOT NULL
                       AND ttt.recordtype IN(
                        'RT22'
                      ) THEN 'VIDEOTOLL'
                      WHEN nraw.recordtype IN(
                        'RT21', 'RT24', 'RT25'
                      )
                       OR ta.transactiontype = 'T' THEN 'AVITOLL'
                      WHEN nraw.recordtype IN(
                        'RT22'
                      )
                       OR ta.transactiontype = 'V' THEN 'VIDEOTOLL'
                      ELSE tt.tripidentmethod
                    END AS lanetripidentmethod,
                    -- The RecordType for migrated data is picked up from the Ref.TartTPTrip (TTT) table generated by Bhanu from RITE Added By Shekhar on 7/20/2022
                    coalesce(CASE
                      WHEN ttt.tptripid IS NOT NULL THEN ttt.recordtype
                      WHEN tt.sourceofentry = 1 THEN nraw.recordtype
                      WHEN tt.sourceofentry = 3
                       AND ta.transactiontype IN(
                        'V', 'T'
                      ) THEN ta.transactiontype
                      ELSE 'V'
                    END, 'RT22') AS recordtype,
                    SUBSTR(CAST( tt.tripwith as STRING),1,1) AS tripwith, --2
                    coalesce(ct.transactionpostingtype, vt.transactionpostingtype, tt.transactionpostingtype) AS transactionpostingtype, --3
                    coalesce(ct.tripstageid, vt.tripstageid, tt.tripstageid) AS tripstageid, --4
                    coalesce(ct.tripstatusid, vt.tripstatusid, tt.tripstatusid) AS tripstatusid, --5
                    CASE
                      WHEN coalesce(tt.reasoncode, '') = ''
                       AND tt.tripstatusid = 2 THEN 'Posted'
                      ELSE coalesce(nullif(tt.reasoncode, ''), 'Unknown')
                    END AS reasoncode, --6
                    vt.citationstage AS citationstagecode, --7
                    CASE
                      WHEN tt.tripstageid = 31 /*QUALIFY_FOR_IOP*/
                       AND tt.tripstatusid = 2
                       AND aea.adjustedexpectedamount = aea.iop_outboundpaidamount THEN 456
                      ELSE nullif(coalesce(ct.paymentstatusid, vt.paymentstatusid, tt.paymentstatusid), 0)
                    END AS trippaymentstatusid, --8
                    tt.sourcename, --9
                    l.operationsagency, --10
                    l.facilitycode,
                    nullif(tt.vehiclenumber, '') AS vehiclenumber,
                    nullif(trim(tt.vehiclestate), '') AS vehiclestate,
                    tt.tagrefid,
                    tt.tagagency,
                    tt.vehicleclass,
                    nraw.revenuevehicleclass,
                    tt.sourceofentry,
                    tt.sourcetripid,
                    tt.disposition,
                    coalesce(tt.ipstransactionid, irr.ipstransactionid) AS ipstransactionid,
                    CAST( CASE
                      WHEN tt.sourceofentry = 3 THEN tt.tptripid
                      ELSE nraw.violationserialnumber
                    END as INT64) AS vesserialnumber,
                    --:: Flags
                    coalesce(CAST( tt.isnonrevenue as INT64), -1) AS nonrevenueflag, --12
                    coalesce(br.businessrulematchedflag, -1) AS businessrulematchedflag, --13
                    coalesce(CAST( irr.ismanuallyreviewed as INT64), -1) AS manuallyreviewedflag, --14
                    coalesce(CASE
                      WHEN nullif(trim(tt.vehiclestate), '') = 'TX' THEN 0
                      WHEN nullif(trim(tt.vehiclestate), '') <> 'TX' THEN 1
                      ELSE -1
                    END, -1) AS oosplateflag,
                    coalesce(CAST( aea.classadjustmentflag as INT64), -1) AS classadjustmentflag,
                    tt.agencyid AS txnagencyid,
                    tt.accountagencyid,

                    --:: Metrics
                    CAST(CASE
                      WHEN ttt.tptripid IS NOT NULL THEN ttt.earnedrev -- This is for migrated data. Updated By Shekhar on 7/13/2022 after Bhanu pull data into Ref.TartTPTrip from the RITE System
                      WHEN tt.sourceofentry = 1
                       AND tt.isnonrevenue = 1 THEN 0
                      WHEN tt.sourceofentry = 1
                       AND nraw.recordtype IN(
                        'RT21', 'RT24', 'RT25'
                      ) THEN tr1.tagfare    
                      WHEN tt.sourceofentry = 1
                       AND nraw.recordtype = 'RT22' THEN tr1.platefare
                      WHEN tt.sourceofentry = 1
                       AND nraw.recordtype IS NULL
                       AND tt.receivedtollamount > 0 THEN tt.receivedtollamount
                      WHEN tt.sourceofentry = 1
                       AND tt.tripidentmethod = 'AVITOLL' THEN tr2.tagfare
                      WHEN tt.sourceofentry = 1
                       AND tt.tripidentmethod = 'VIDEOTOLL' THEN tr2.platefare
                      WHEN tt.sourceofentry = 3 THEN coalesce(ta.tsa_receivedtollamount, nullif(tt.receivedtollamount, 0), tt.tollamount)
                    END as NUMERIC) AS expectedamount,
                    aea.adjustedexpectedamount,
                    aea.tripwithadjustedamount,
                    coalesce(ct.tollamount, vt.tollamount, tt.tollamount) AS tollamount,
                    coalesce(vp.actualpaidamount, CASE
                      WHEN tt.tripstageid = 31 /*QUALIFY_FOR_IOP*/
                       AND coalesce(tt.tripwith, 'I') = 'I' THEN aea.iop_outboundpaidamount
                      WHEN coalesce(ct.paymentstatusid, vt.paymentstatusid, tt.paymentstatusid) IN(
                        456, 457
                      ) -- Paid or Partial Paid
                      THEN CAST(coalesce(ct.tollamount - ct.outstandingamount, vt.tollamount - vt.outstandingamount, CAST(coalesce(tt.tollamount, 0) - coalesce(tt.outstandingamount, 0) as BIGNUMERIC)) + coalesce(aea.tripwithadjustedamount, 0) as BIGNUMERIC) /* Example: AdjustedAmount for CSR_ADJUSTED C Trips */ 
                      ELSE 0
                    END) AS actualpaidamount,
                    coalesce(CASE
                      WHEN tt.tripstageid = 31 /*QUALIFY_FOR_IOP*/
                       AND coalesce(tt.tripwith, 'I') = 'I' THEN aea.adjustedexpectedamount - aea.iop_outboundpaidamount
                    END, ct.outstandingamount, vt.outstandingamount, tt.outstandingamount) AS outstandingamount,
                    coalesce(vp.firstpaiddate, ct.posteddate, tt.posteddate) AS firstpaiddate,
                    coalesce(vp.lastpaiddate, ct.posteddate, tt.posteddate) AS lastpaiddate,
                    
                    --:: Validation help
                    tt.posteddate AS tp_posteddate,
                    ct.posteddate AS custtrip_posteddate,
                    vt.posteddate AS violatedtrip_posteddate,
                    CAST( CASE
                      WHEN tt.sourceofentry = 1 THEN tt.avitollamount
                      ELSE ta.tsa_base
                    END as NUMERIC) AS expectedbase,
                    CASE
                      WHEN tt.sourceofentry = 1 THEN tt.receivedtollamount - tt.avitollamount
                      ELSE tsa_premium
                    END AS expectedpremium,
                    coalesce(ct.avitollamount, vt.avitollamount, tt.avitollamount) AS avitollamount,
                    coalesce(ct.pbmtollamount, vt.pbmtollamount, tt.pbmtollamount) AS pbmtollamount,
                    tt.originalavitollamount,
                    tt.originalpbmtollamount,
                    tt.receivedtollamount AS tp_receivedtollamount,
                    nraw.fareamount AS nraw_fareamount,
                    tr1.tagfare AS nraw_vehicleclass_tagfare,
                    tr1.platefare AS nraw_vehicleclass_platefare,
                    tr2.tagfare AS tp_vehicleclass_tagfare,
                    tr2.platefare AS tp_vehicleclass_platefare,
                    ta.tsa_receivedtollamount AS tsa_receivedtollamount,
                    vp.totaltxnamount AS violatedtrippayment_totaltxnamount,
                    vp.adjustedamount AS violatedtrippayment_adjustedamount,
                    vp.actualpaidamount AS violatedtrippayment_actualpaidamount,
                    tt.tollamount AS tp_tollamount,
                    ct.tollamount AS custtrip_tollamount,
                    vt.tollamount AS violatedtrip_tollamount,
                    tt.outstandingamount AS tp_outstandingamount,
                    ct.outstandingamount AS custtrip_outstandingamount,
                    vt.outstandingamount AS violatedtrip_outstandingamount,
                    tt.paymentstatusid AS tp_paymentstatusid,
                    ct.paymentstatusid AS custtrip_paymentstatusid,
                    vt.paymentstatusid AS violatedtrip_paymentstatusid,
                    tt.tripstatusid AS tp_tripstatusid,
                    ct.tripstatusid AS custtrip_tripstatusid,
                    vt.tripstatusid AS violatedtrip_tripstatusid,
                    tt.tripstageid AS tp_tripstageid,
                    ct.tripstageid AS custtrip_tripstageid,
                    vt.tripstageid AS violatedtrip_tripstageid,
                    ttt.recordtype AS ttt_recordtype,
                    coalesce(ct.lnd_updatedate, vt.lnd_updatedate, tt.lnd_updatedate) AS lnd_updatedate
                    -- SELECT COUNT_BIG(1) RC 
                  FROM
                    LND_TBOS.TollPlus_TP_Trips AS tt
                    INNER JOIN EDW_TRIPS.Dim_Lane AS l ON l.laneid = tt.exitlaneid
                     AND tt.lnd_updatetype <> 'D'
                    LEFT OUTER JOIN LND_TBOS.TollPlus_TP_CustomerTrips AS ct ON ct.tptripid = tt.tptripid
                     AND ct.custtripid = tt.linkid
                     AND tt.tripwith = 'C'
                     AND ct.lnd_updatetype <> 'D'
                    LEFT OUTER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt ON vt.tptripid = tt.tptripid
                     AND vt.citationid = tt.linkid
                     AND tt.tripwith = 'V'
                     AND vt.lnd_updatetype <> 'D'
                    LEFT OUTER JOIN EDW_TRIPS_STAGE.IPS_Image_Review_Results AS irr ON irr.tptripid = tt.tptripid
                    LEFT OUTER JOIN EDW_TRIPS_STAGE.Uninvoiced_Citation_Summary_BR AS br ON br.citationid = vt.citationid
                    LEFT OUTER JOIN EDW_TRIPS_STAGE.ViolatedTripPayment AS vp ON vp.tptripid = tt.tptripid
                    LEFT OUTER JOIN EDW_TRIPS_STAGE.NTTARawTransactions AS nraw ON nraw.tptripid = tt.tptripid
                     AND tt.sourceofentry = 1
                    LEFT OUTER JOIN EDW_TRIPS_STAGE.TSATripAttributes AS ta ON ta.tptripid = tt.tptripid
                     AND tt.sourceofentry = 3
                    LEFT OUTER JOIN EDW_TRIPS.Fact_AdjExpectedAmount AS aea ON aea.tptripid = tt.tptripid
                    LEFT OUTER JOIN EDW_TRIPS_STAGE.TollRates AS tr1 ON tt.exitlaneid = tr1.exitlaneid
                     AND tt.exittripdatetime BETWEEN tr1.starteffectivedate AND tr1.endeffectivedate
                     AND nraw.revenuevehicleclass = CAST(tr1.vehicleclass AS INT64)
                     AND tt.isnonrevenue = 0
                    LEFT OUTER JOIN EDW_TRIPS_STAGE.TollRates AS tr2 ON tt.exitlaneid = tr2.exitlaneid
                     AND tt.exittripdatetime BETWEEN tr2.starteffectivedate AND tr2.endeffectivedate
                     AND tt.vehicleclass = tr2.vehicleclass
                     AND tt.isnonrevenue = 0
                     AND coalesce(tt.receivedtollamount, 0) = 0
                    LEFT OUTER JOIN EDW_TRIPS_SUPPORT.TartTPTrip AS ttt -- Join added by Shekhar on 7/13/2022 to fetch ExpectedAmount from RITE table for migrated data
                    ON tt.tptripid = ttt.tptripid
                  WHERE tt.sourceofentry IN(
                    1, 3
                  ) --TSA & NTTA 
                   AND tt.exit_tolltxnid >= 0
                   AND tt.exittripdatetime >= '2019-01-01' --@Load_Cutoff_Date
                   AND tt.exittripdatetime < current_datetime()
                   --AND TT.TpTripID = 4457612438
                   --AND TT.TpTripID IN (2417684979 /* RTM<>0, Nraw*/, 2417686387 /*RTM=0, Nraw*/, 12058155 /*No NRaw, RTM <>0*/, 163810219 /*No NRaw, RTM = 0*/)
                   --AND TT.TpTripID IN (1296825541, 1274319280) -- TSA ExpectedAmount = 0
                   --AND (TT.TpTripID IN (2394521987,2864601976,2874007937,3018338513,3035826778,3107276708, 1937242377,2123262841,2171601474,2171750141,2554758633, 1919833818) OR TT.ExitTripDateTime >= '2022-02-01' AND TT.ExitTripDateTime < '2022-02-02')
                   --AND TT.TpTripID IN (3425875794, 3352760210,896711050) -- IOP
                   --AND TT.TpTripID IN (3425165467,3426246820,3130269902) -- CT
                   --AND VT.TpTripID IN (2394521987,2864601976,2874007937,3018338513,3035826778,3107276708) -- VT credit adj examples 
                   -- VT.TpTripID IN (1937242377,2123262841,2171601474,2171750141,2554758633) -- VT debit adj or reversal examples 
                   --AND TT.TpTripID IN (2544273232, 2544623006, 2544433973, 2547735326) -- TSA
                   --AND TT.TpTripID IN (3058214815, 3531584534, 3527685824, 3526854024) -- IOP TSA
                   --AND TT.TpTripID IN (11,3036124,2311646450) -- Default RT Code cases
              ) AS ut
              INNER JOIN EDW_TRIPS.Dim_TripStage AS tsg ON tsg.tripstageid = ut.tripstageid
              INNER JOIN EDW_TRIPS.Dim_TripStatus AS tst ON tst.tripstatusid = ut.tripstatusid
              LEFT OUTER JOIN EDW_TRIPS.Dim_TripPaymentStatus AS ps ON ps.trippaymentstatusid = ut.trippaymentstatusid
              LEFT OUTER JOIN EDW_TRIPS.Dim_Customer AS c ON c.customerid = ut.customerid
              LEFT OUTER JOIN EDW_TRIPS.Dim_OperationsMapping AS om ON om.tripidentmethod = ut.tripidentmethod
               AND coalesce(om.tripwith, '') = coalesce(ut.tripwith, '')
               AND om.transactionpostingtype = coalesce(ut.transactionpostingtype, 'Unknown')
               AND om.tripstageid = coalesce(ut.tripstageid, -1)
               AND om.tripstatusid = coalesce(ut.tripstatusid, -1)
               AND om.reasoncode = coalesce(ut.reasoncode, 'Unknown')
               AND om.citationstagecode = coalesce(ut.citationstagecode, 'Unknown')
               AND om.trippaymentstatusid = coalesce(ut.trippaymentstatusid, -1)
               AND coalesce(om.sourcename, '') = coalesce(ut.sourcename, '')
               AND om.operationsagency = coalesce(ut.operationsagency, 'Unknown')
               AND coalesce(om.badaddressflag, -1) = coalesce(CAST( CASE
                WHEN ut.showbadaddressflag = 1 THEN c.badaddressflag
              END as INT64), -1)
               AND coalesce(om.nonrevenueflag, -1) = coalesce(ut.nonrevenueflag, -1)
               AND coalesce(om.businessrulematchedflag, -1) = coalesce(ut.businessrulematchedflag, -1)
      ;
      SET log_message = 'Loaded EDW_TRIPS_STAGE.UnifiedTransaction';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      --Table swap!
      --Using create ot replace in bigquery
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS_STAGE.UnifiedTransaction_NEW', 'EDW_TRIPS_stage.UnifiedTransaction');

		--=============================================================================================================
		-- dbo.Dim_OperationsMapping. Insert new combinations.
		--=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_TRIPS_STAGE.Dim_OperationsMapping_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.Dim_OperationsMapping_NEW
        AS
          SELECT DISTINCT
              --:: Mapping input key columns
              tim.tripidentmethod,
              ut.tripwith,
              tpt.transactionpostingtype,
              tsg.tripstagecode,
              tst.tripstatuscode,
              rc.reasoncode,
              cs.citationstagecode,
              ps.trippaymentstatusdesc,
              ut.sourcename,
              ut.operationsagency,
              ut.badaddressflag,
              ut.nonrevenueflag,
              ut.businessrulematchedflag,
              --:: Other columns
              coalesce(tim.tripidentmethodid, -1) AS tripidentmethodid,
              coalesce(tim.tripidentmethodcode, 'Unknown') AS tripidentmethodcode,
              tpt.transactionpostingtypeid,
              tpt.transactionpostingtypedesc,
              tsg.tripstageid,
              tsg.tripstagedesc,
              tst.tripstatusid,
              tst.tripstatusdesc,
              rc.reasoncodeid,
              cs.citationstageid,
              cs.citationstagedesc,
              ps.trippaymentstatusid,
              ps.trippaymentstatuscode,
              current_datetime() AS edw_updatedate
              --SELECT OM.OperationsMappingID, UT.CitationStageCode, UT.TripPaymentStatusDesc, UT.SourceName, *
            FROM
              EDW_TRIPS_STAGE.UnifiedTransaction AS ut
              LEFT OUTER JOIN EDW_TRIPS.Dim_TripIdentMethod AS tim ON tim.tripidentmethod = ut.tripidentmethod
              LEFT OUTER JOIN EDW_TRIPS.Dim_TransactionPostingType AS tpt ON tpt.transactionpostingtype = ut.transactionpostingtype
              LEFT OUTER JOIN EDW_TRIPS.Dim_TripStage AS tsg ON tsg.tripstagecode = ut.tripstagecode
              LEFT OUTER JOIN EDW_TRIPS.Dim_TripStatus AS tst ON tst.tripstatuscode = ut.tripstatuscode
              LEFT OUTER JOIN EDW_TRIPS.Dim_ReasonCode AS rc ON rc.reasoncode = ut.reasoncode
              LEFT OUTER JOIN EDW_TRIPS.Dim_CitationStage AS cs ON cs.citationstagecode = ut.citationstagecode
              LEFT OUTER JOIN EDW_TRIPS.Dim_TripPaymentStatus AS ps ON ps.trippaymentstatusdesc = ut.trippaymentstatusdesc
              LEFT OUTER JOIN EDW_TRIPS.Dim_OperationsMapping AS om ON om.tripidentmethod = ut.tripidentmethod
               AND coalesce(om.tripwith, '') = coalesce(ut.tripwith, '')
               AND om.transactionpostingtype = coalesce(ut.transactionpostingtype, 'Unknown')
               AND om.tripstageid = ut.tripstageid
               AND om.tripstatusid = ut.tripstatusid
               AND om.reasoncode = ut.reasoncode
               AND om.citationstagecode = coalesce(ut.citationstagecode, 'Unknown')
               AND om.trippaymentstatusid = ut.trippaymentstatusid
               AND coalesce(om.sourcename, '') = coalesce(ut.sourcename, '')
               AND om.operationsagency = ut.operationsagency
               AND om.badaddressflag = ut.badaddressflag
               AND om.nonrevenueflag = ut.nonrevenueflag
               AND om.businessrulematchedflag = ut.businessrulematchedflag
            WHERE ut.operationsmappingid = -1
             AND om.operationsmappingid IS NULL
      ;
      SET log_message = 'Loaded unknown combinations into EDW_TRIPS_STAGE.Dim_OperationsMapping_NEW';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      SET max_id = (SELECT
          max(dim_operationsmapping.operationsmappingid) 
        FROM
          EDW_TRIPS.Dim_OperationsMapping
      );
      INSERT INTO EDW_TRIPS.Dim_OperationsMapping (operationsmappingid, mapping, mappingdetailed, pursunpursstatus, tripidentmethod, tripwith, transactionpostingtype, tripstagecode, tripstatuscode, reasoncode, citationstagecode, trippaymentstatusdesc, sourcename, operationsagency, badaddressflag, nonrevenueflag, businessrulematchedflag, tripidentmethodid, tripidentmethodcode, transactionpostingtypeid, transactionpostingtypedesc, tripstageid, tripstagedesc, tripstatusid, tripstatusdesc, reasoncodeid, citationstageid, citationstagedesc, trippaymentstatusid, trippaymentstatuscode, edw_updatedate)
        SELECT
            coalesce(max_id, 0) + row_number() OVER (ORDER BY om.tripidentmethod, om.tripwith, om.transactionpostingtype, om.tripstagecode, om.tripstatuscode, om.reasoncode, om.citationstagecode, om.trippaymentstatusdesc, om.sourcename, om.nonrevenueflag, om.badaddressflag, om.businessrulematchedflag, om.operationsagency) AS operationsmappingid,
            --:: Mapping output
            'Unknown' AS mapping,
            'Unknown' AS mappingdetailed,
            'Unknown' AS pursunpursstatus,
            om.*
          FROM
            EDW_TRIPS_STAGE.Dim_OperationsMapping_NEW AS om
      ;
      SET log_message = 'Inserted unknown combinations into EDW_TRIPS.Dim_OperationsMapping';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      
      --:: Prepopulate Mapping column
      UPDATE EDW_TRIPS.Dim_OperationsMapping SET mapping = CASE
        WHEN dim_operationsmapping.operationsagency = 'IOP - NTTA Home' THEN 'NTTA-Home Agency IOP'
        WHEN dim_operationsmapping.tripidentmethod = 'AVITOLL'
         AND dim_operationsmapping.tripwith = 'C'
         OR dim_operationsmapping.tripidentmethod = 'AVITOLL'
         AND dim_operationsmapping.tripwith IS NULL
         AND dim_operationsmapping.tripstagecode IN(
          'UNQUALIFY', 'QUALIFY', 'QUALIFY_FOR_IMAGE_REVIEW'
        )
         OR dim_operationsmapping.tripidentmethod = 'AVITOLL'
         AND dim_operationsmapping.tripstagecode = 'VIOLATION' THEN 'Prepaid'
        WHEN dim_operationsmapping.tripidentmethod = 'AVITOLL'
         AND dim_operationsmapping.tripwith = 'I'
         OR dim_operationsmapping.tripidentmethod = 'AVITOLL'
         AND dim_operationsmapping.tripwith IS NULL
         AND dim_operationsmapping.tripstagecode IN(
          'QUALIFY_FOR_IOP'
        ) THEN 'IOP - AVI'
        WHEN dim_operationsmapping.tripidentmethod = 'VIDEOTOLL'
         AND dim_operationsmapping.tripwith = 'I'
         OR dim_operationsmapping.tripidentmethod = 'VIDEOTOLL'
         AND dim_operationsmapping.tripwith IS NULL
         AND dim_operationsmapping.tripstagecode IN(
          'QUALIFY_FOR_IOP'
        ) THEN 'IOP - Video'
        WHEN dim_operationsmapping.tripidentmethod = 'VIDEOTOLL'
         AND dim_operationsmapping.tripwith = 'C'
         OR dim_operationsmapping.tripidentmethod = 'VIDEOTOLL'
         AND dim_operationsmapping.tripwith IS NULL
         OR dim_operationsmapping.tripidentmethod = 'VIDEOTOLL'
         AND dim_operationsmapping.tripwith = 'V' THEN 'Video'
        ELSE 'Unknown'
      END WHERE dim_operationsmapping.mapping = 'Unknown';

      SET log_message = 'Updated Mapping column in EDW_TRIPS.Dim_OperationsMapping';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      -- No target-dialect support for source-dialect-specific Update Statistics
		
		--=============================================================================================================
		-- dbo.Fact_UnifiedTransaction 
		--=============================================================================================================
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_UnifiedTransaction
        AS
          SELECT
              tptripid,
              custtripid,
              citationid,
              tripdayid,
              tripdate,
              ut.tripwith,
              ut.sourceofentry,
              laneid,
              operationsmappingid,
              tim.tripidentmethodid,
              coalesce(ltim.tripidentmethodid, -1) AS lanetripidentmethodid,
              coalesce(rt.recordtypeid, -1) AS recordtypeid,
              transactionpostingtypeid,
              tripstageid,
              tripstatusid,
              reasoncodeid,
              citationstageid,
              trippaymentstatusid,
              ut.customerid,
              vehicleid,
              vehiclenumber,
              vehiclestate,
              ct.custtagid,
              ut.tagrefid,
              ut.tagagency,
              txnagencyid,
              accountagencyid,
              CASE
                WHEN vehicleclass IN(
                  '2', '3', '4', '5', '6', '7', '8', '11', '12', '13', '14', '15', '16', '17', '18'
                ) THEN CAST(vehicleclass AS INT64)
                ELSE -1
              END AS vehicleclassid,
              badaddressflag,
              nonrevenueflag,
              businessrulematchedflag,
              manuallyreviewedflag,
              oosplateflag,
              vtollflag,
              classadjustmentflag,
              rpt_paidvsaea,
              CAST( firstpaiddate as DATE) AS firstpaiddate,
              CAST( lastpaiddate as DATE) AS lastpaiddate,
              expectedbase,
              expectedpremium,
              expectedamount,
              adjustedexpectedamount,
              calcadjustedamount,
              tripwithadjustedamount,
              tollamount,
              actualpaidamount,
              outstandingamount,
              ut.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.UnifiedTransaction AS ut
              LEFT OUTER JOIN EDW_TRIPS.Dim_TripIdentMethod AS tim ON tim.tripidentmethod = ut.tripidentmethod
              LEFT OUTER JOIN EDW_TRIPS.Dim_TripIdentMethod AS ltim ON ltim.tripidentmethod = ut.lanetripidentmethod
              LEFT OUTER JOIN EDW_TRIPS.Dim_TransactionPostingType AS tpt ON tpt.transactionpostingtype = ut.transactionpostingtype
              LEFT OUTER JOIN EDW_TRIPS.Dim_ReasonCode AS rc ON rc.reasoncode = ut.reasoncode
              LEFT OUTER JOIN EDW_TRIPS.Dim_RecordType AS rt ON rt.recordtype = ut.recordtype
              LEFT OUTER JOIN EDW_TRIPS.Dim_CitationStage AS cs ON cs.citationstagecode = ut.citationstagecode
              LEFT OUTER JOIN EDW_TRIPS_STAGE.Bubble_CustomerTags AS ct ON ct.customerid = ut.customerid
               AND ct.serialno = trim(ut.tagrefid)
               AND ct.tagagency = trim(ut.tagagency)
            WHERE ut.operationsmappingid <> -1
          UNION ALL
          SELECT
              ut.tptripid,
              ut.custtripid,
              ut.citationid,
              ut.tripdayid,
              ut.tripdate,
              ut.tripwith,
              ut.sourceofentry,
              ut.laneid,
              om.operationsmappingid,
              om.tripidentmethodid,
              coalesce(ltim.tripidentmethodid, -1) AS lanetripidentmethodid,
              coalesce(rt.recordtypeid, -1) AS recordtypeid,
              om.transactionpostingtypeid,
              om.tripstageid,
              om.tripstatusid,
              om.reasoncodeid,
              om.citationstageid,
              om.trippaymentstatusid,
              ut.customerid,
              ut.vehicleid,
              ut.vehiclenumber,
              ut.vehiclestate,
              ct.custtagid,
              ut.tagrefid,
              ut.tagagency,
              ut.txnagencyid,
              ut.accountagencyid,
              CASE
                WHEN ut.vehicleclass IN(
                  '2', '3', '4', '5', '6', '7', '8', '11', '12', '13', '14', '15', '16', '17', '18'
                ) THEN CAST(ut.vehicleclass AS INT64)
                ELSE -1
              END AS vehicleclassid,
              om.badaddressflag,
              om.nonrevenueflag,
              om.businessrulematchedflag,
              ut.manuallyreviewedflag,
              ut.oosplateflag,
              ut.vtollflag,
              ut.classadjustmentflag,
              ut.rpt_paidvsaea,
              CAST( ut.firstpaiddate as DATE) AS firstpaiddate,
              CAST( ut.lastpaiddate as DATE) AS lastpaiddate,
              ut.expectedbase,
              ut.expectedpremium,
              ut.expectedamount,
              ut.adjustedexpectedamount,
              ut.calcadjustedamount,
              ut.tripwithadjustedamount,
              ut.tollamount,
              ut.actualpaidamount,
              ut.outstandingamount,
              ut.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.UnifiedTransaction AS ut --In Stage.UnifiedTransaction, OperationsMappingID remains -1 for new combination rows just inserted earlier in dbo.Dim_OperationsMapping table.
              LEFT OUTER JOIN EDW_TRIPS.Dim_TripIdentMethod AS ltim ON ltim.tripidentmethod = ut.lanetripidentmethod
              LEFT OUTER JOIN EDW_TRIPS.Dim_RecordType AS rt ON rt.recordtype = ut.recordtype
              LEFT OUTER JOIN EDW_TRIPS.Dim_OperationsMapping AS om ON om.tripidentmethod = ut.tripidentmethod
               AND coalesce(om.tripwith, '') = coalesce(ut.tripwith, '')
               AND om.transactionpostingtype = coalesce(ut.transactionpostingtype, 'Unknown')
               AND om.tripstageid = ut.tripstageid
               AND om.tripstatusid = ut.tripstatusid
               AND om.reasoncode = ut.reasoncode
               AND om.citationstagecode = coalesce(ut.citationstagecode, 'Unknown')
               AND om.trippaymentstatusid = ut.trippaymentstatusid
               AND coalesce(om.sourcename, '') = coalesce(ut.sourcename, '')
               AND om.operationsagency = ut.operationsagency
               AND om.badaddressflag = ut.badaddressflag
               AND om.nonrevenueflag = ut.nonrevenueflag
               AND om.businessrulematchedflag = ut.businessrulematchedflag
              LEFT OUTER JOIN EDW_TRIPS_STAGE.Bubble_CustomerTags AS ct ON ct.customerid = ut.customerid
               AND ct.serialno = trim(ut.tagrefid)
               AND ct.tagagency = trim(ut.tagagency)
            WHERE ut.operationsmappingid = -1
      ;
      SET log_message = 'Loaded EDW_TRIPS.Fact_UnifiedTransaction';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
    
      --Table swap!
      --Using create or replce in bigquery
      --CALL EDW_TRIPS_SUPPORT.TableSwap('dbo.Fact_UnifiedTransaction_NEW', 'dbo.Fact_UnifiedTransaction');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);

      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.UnifiedTransaction' AS tablename,
            *
          FROM
            EDW_TRIPS_STAGE.UnifiedTransaction
        ORDER BY
          tripdate DESC,
          tptripid
         LIMIT 1000
        ;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_UnifiedTransaction' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_UnifiedTransaction
        ORDER BY
          tripdate DESC,
          tptripid
        LIMIT 1000
        ;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_OperationsMapping' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_OperationsMapping
        ORDER BY
          operationsmappingid DESC
        LIMIT 1000
        ;
      END IF;


    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(`@log_source`, `@log_start_date`, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = error_message;-- Rethrow the error!
      END;
    END;
    
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================

EXEC dbo.Fact_UnifiedTransaction_Full_Load
EXEC dbo.Fact_UnifiedTransaction_Summary_Full_Load 
EXEC dbo.Fact_UnifiedTransaction_SummarySnapshot_Full_Load

SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_UnifiedTransaction_Full_Load' ORDER BY 1 DESC
SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_UnifiedTransaction_Full_Load' and LogMessage = 'Loaded Stage.Uninvoiced_Citation_Summary_BR. Min Txn Count: 3, Min Amount: $2.50' ORDER BY 1 DESC

SELECT TOP 1000 'Stage.UnifiedTransaction' TableName, * FROM Stage.UnifiedTransaction ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction' TableName, * FROM dbo.Fact_UnifiedTransaction ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_Summary' TableName, * FROM dbo.Fact_UnifiedTransaction_Summary ORDER BY 2 DESC,3,4
SELECT TOP 1000 'Fact_UnifiedTransaction_SummarySnapshot' TableName, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot 
ORDER BY SnapshotMonthID DESC, TripMonthID DESC, OperationsMappingID, FacilityID

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

--:: Ensure there are no duplicates in dbo.Dim_OperationsMapping
SELECT 
	  TripIdentMethod
	, TripWith
	, TransactionPostingType
	, TripStageCode
	, TripStatusCode
	, ReasonCode
	, CitationStageCode
	, TripPaymentStatusDesc
	, SourceName
	, OperationsAgency
	, BadAddressFlag
	, NonRevenueFlag
	, BusinessRuleMatchedFlag
    , COUNT(1) DupCount
FROM dbo.Dim_OperationsMapping
WHERE Mapping NOT LIKE '%Not Migrated%' AND Mapping NOT LIKE '%AVI-TSA Migrated%' -- exclude static rows
GROUP BY
	  TripIdentMethod
	, TripWith
	, TransactionPostingType
	, TripStageCode
	, TripStatusCode
	, ReasonCode
	, CitationStageCode
	, TripPaymentStatusDesc
	, SourceName
	, OperationsAgency
	, BadAddressFlag
	, NonRevenueFlag
	, BusinessRuleMatchedFlag
HAVING COUNT(1) > 1

--:: Ensure there are no duplicates in dbo.Fact_UnifiedTransaction
SELECT TPTripID, COUNT(*) FROM dbo.Fact_UnifiedTransaction GROUP BY TPTripID HAVING COUNT(1) > 1


--:: Sample data at a glance:


--:: Showing Fact and Dim table relationships nraw_re


--:: Stage.UnifiedTransaction column analysis for dbo.Dim_OperationsMapping lookup
SELECT 'TripIdentMethod' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.TripIdentMethod = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.TripIdentMethod = 'Unknown')unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.TripIdentMethod IS NULL) null_cnt							UNION ALL
SELECT 'TripWith' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.TripWith = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.TripWith = 'Unknown')unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.TripWith IS NULL) null_cnt														UNION ALL
SELECT 'TripStageID' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.TripStageID = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.TripStageID = -1)unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.TripStageID IS NULL) null_cnt													UNION ALL
SELECT 'TripStatusID' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.TripStatusID = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.TripStatusID = -1) unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.TripStatusID IS NULL) null_cnt												UNION ALL
SELECT 'ReasonCode' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.ReasonCode = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.ReasonCode = 'Unknown')unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.ReasonCode IS NULL) null_cnt												UNION ALL
SELECT 'CitationStageCode' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.CitationStageCode = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.CitationStageCode = 'Unknown')unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.CitationStageCode IS NULL) null_cnt					UNION ALL
SELECT 'TripPaymentStatusID' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.TripPaymentStatusID = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.TripPaymentStatusID = -1)unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.TripPaymentStatusID IS NULL) null_cnt					UNION ALL
SELECT 'SourceName' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.SourceName = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.SourceName = 'Unknown')unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.SourceName IS NULL) null_cnt												UNION ALL
SELECT 'OperationsAgency' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.OperationsAgency = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.OperationsAgency = 'Unknown')unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.OperationsAgency IS NULL) null_cnt						UNION ALL
SELECT 'BadAddressFlag' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.BadAddressFlag = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.BadAddressFlag = 0)unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.BadAddressFlag IS NULL) null_cnt										UNION ALL
SELECT 'NonRevenueFlag' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.NonRevenueFlag = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.NonRevenueFlag = 0)unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.NonRevenueFlag IS NULL) null_cnt										UNION ALL
SELECT 'BusinessRuleMatchedFlag' col_name, (SELECT COUNT(1) FROM Stage.UnifiedTransaction UT WHERE UT.BusinessRuleMatchedFlag = '')empty_cnt, (SELECT count(1)  FROM Stage.UnifiedTransaction UT WHERE UT.BusinessRuleMatchedFlag = 0)unk_cnt, (SELECT COUNT(1)  FROM Stage.UnifiedTransaction UT WHERE UT.BusinessRuleMatchedFlag IS NULL) null_cnt	UNION ALL

*/

  END;