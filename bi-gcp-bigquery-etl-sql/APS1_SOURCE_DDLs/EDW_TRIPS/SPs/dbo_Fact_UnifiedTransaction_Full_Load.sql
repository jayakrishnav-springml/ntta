CREATE PROC [dbo].[Fact_UnifiedTransaction_Full_Load] AS

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

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_UnifiedTransaction_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL
		DECLARE @Load_Cutoff_Date DATE = '2019-01-01'
		
		--=============================================================================================================
		-- Load Stage.Uninvoiced_Citation_Summary_BR with Business Rule Matching Flag for unpaid Citations
		--=============================================================================================================
		DECLARE @Lv_MinTxnCntUnRegCustInv BIGINT, @Lv_MinAmtUnRegCustInv MONEY
		SELECT	@Lv_MinTxnCntUnRegCustInv = ParameterValue   FROM LND_TBOS.Tollplus.Tp_Application_Parameters WHERE ParameterKey = 'MinTxnCntUnRegCustInv'
		SELECT	@LV_MinAmtUnRegCustInv = ParameterValue      FROM LND_TBOS.Tollplus.Tp_Application_Parameters WHERE ParameterKey = 'MinAmtUnRegCustInv'

		IF OBJECT_ID('Stage.Uninvoiced_Citation_Summary_BR','U') IS NOT NULL DROP TABLE Stage.Uninvoiced_Citation_Summary_BR;
		CREATE TABLE Stage.Uninvoiced_Citation_Summary_BR WITH (CLUSTERED INDEX (CitationID), DISTRIBUTION = HASH(CitationID))
		AS
		WITH Uninvoiced_Citation_CTE AS
		(
			SELECT  VT.ViolatorID AS CustomerID, VT.TPTripID, VT.CitationID, ST.TripStatusCode, VT.PostedDate, VT.TollAmount  
			FROM	LND_TBOS.TollPlus.TP_ViolatedTrips VT
			JOIN    LND_TBOS.TollPlus.TripStatuses ST ON ST.TripStatusID = VT.TripStatusID
			WHERE   VT.CitationStage = 'INVOICE' /* UnInvoiced */
					AND VT.OutStandingAmount > 0 
					--AND VT.ViolatorID IN (810858671)
		)
		--SELECT * FROM Uninvoiced_Citation_CTE
		, MinTxnCnt_MinAmt_CTE AS
		(
			SELECT  UC.CustomerID, COUNT(1) TxnCount, SUM(TollAmount) TollAmount
			FROM    Uninvoiced_Citation_CTE UC
			JOIN    dbo.Dim_Customer C ON C.CustomerID = UC.CustomerID AND C.PaymentPlanEstablishedFlag = 0 AND C.BadAddressFlag = 0
			WHERE   UC.TripStatusCode NOT IN ('UNMATCHED', 'DISPUTE_ADJUSTED', 'HOLD')
					--AND UC.CustomerID IN (810858671)
			GROUP BY UC.CustomerID 
			--HAVING  COUNT(1) >= 3 OR SUM(TollAmount) >= 2.5
			HAVING  COUNT(1) >= @Lv_MinTxnCntUnRegCustInv OR SUM(TollAmount) >= @LV_MinAmtUnRegCustInv 
		)
		--SELECT * FROM MinTxnCnt_MinAmt_CTE
		SELECT  UC.CustomerID, UC.TPTripID, UC.CitationID, UC.TripStatusCode, UC.PostedDate, UC.TollAmount, CAST (CASE WHEN BR.CustomerID IS NOT NULL THEN 1 ELSE -1 END AS SMALLINT) AS BusinessRuleMatchedFlag
		FROM    Uninvoiced_Citation_CTE UC
		LEFT JOIN MinTxnCnt_MinAmt_CTE BR ON UC.CustomerID = BR.CustomerID AND UC.TripStatusCode NOT IN ('UNMATCHED', 'DISPUTE_ADJUSTED', 'HOLD')
		OPTION (LABEL = 'Stage.Uninvoiced_Citation_Summary_BR Load');

		SET  @Log_Message = 'Loaded Stage.Uninvoiced_Citation_Summary_BR. Min Txn Count: ' + ISNULL(CONVERT(VARCHAR,@Lv_MinTxnCntUnRegCustInv),'?') + ', Min Amount: $' + ISNULL(CONVERT(VARCHAR,@LV_MinAmtUnRegCustInv),'?') 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Create Statistics
		CREATE STATISTICS STATS_Stage_Uninvoiced_Citation_Summary_BR_001 ON Stage.Uninvoiced_Citation_Summary_BR(TPTripID)
		CREATE STATISTICS STATS_Stage_Uninvoiced_Citation_Summary_BR_002 ON Stage.Uninvoiced_Citation_Summary_BR(BusinessRuleMatchedFlag)
 
		--=============================================================================================================
		-- Load Stage.IPS_Image_Review_Results	02:46	(751481706 row(s) affected)
		--=============================================================================================================
		IF OBJECT_ID('Stage.IPS_Image_Review_Results','U') IS NOT NULL DROP TABLE Stage.IPS_Image_Review_Results -- (689882940 row(s) affected)
		CREATE TABLE Stage.IPS_Image_Review_Results WITH (CLUSTERED INDEX (TPTripID), DISTRIBUTION = HASH(TPTripID)) AS
		SELECT ImageReviewResultID, IPSTransactionID, TPTripID, IsManuallyReviewed, Timestamp, IRR_LaneID, IRR_FacilityCode, IRR_PlazaCode, IRR_LaneCode, VesSerialNumber, PlateRegistration, PlateJurisdiction, ReasonCode, Disposition, CreatedUser, CreatedDate, UpdatedUser, UpdatedDate, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
		FROM 
		(
			SELECT ImageReviewResultID, IPSTransactionID, SourceTransactionID AS TPTripID, IsManuallyReviewed, Timestamp, L.LaneID IRR_LaneID, IRR.FacilityCode IRR_FacilityCode, IRR.PlazaCode IRR_PlazaCode, IRR.LaneCode IRR_LaneCode, VesSerialNumber, PlateRegistration, PlateJurisdiction, ReasonCode, Disposition, IRR.CreatedUser, IRR.CreatedDate, IRR.UpdatedUser, IRR.UpdatedDate, ROW_NUMBER() OVER (PARTITION BY SourceTransactionID ORDER BY ImageReviewResultID DESC) RN
			FROM   LND_TBOS.TollPlus.TP_Image_Review_Results IRR																																																				 
			LEFT JOIN dbo.Dim_Lane L 
					ON L.IPS_FacilityCode = IRR.FacilityCode
					AND L.IPS_PlazaCode = IRR.PlazaCode
					AND L.LaneNumber = CONVERT(VARCHAR,IRR.LaneCode)
			WHERE  Timestamp >= '1/1/2021'  																																												 
				   AND IRR.LND_UpdateType <> 'D'																																																								 
		) T
		WHERE RN = 1
		OPTION (LABEL = 'Stage.IPS_Image_Review_Results Load');

		--:: Create Statistics
		CREATE STATISTICS STATS_Stage_IPS_Image_Review_Results_01 ON Stage.IPS_Image_Review_Results(IPSTransactionID)
		CREATE STATISTICS STATS_Stage_IPS_Image_Review_Results_02 ON Stage.IPS_Image_Review_Results(Timestamp)
		CREATE STATISTICS STATS_Stage_IPS_Image_Review_Results_03 ON Stage.IPS_Image_Review_Results(IRR_FacilityCode)
		CREATE STATISTICS STATS_Stage_IPS_Image_Review_Results_04 ON Stage.IPS_Image_Review_Results(IRR_PlazaCode)
		CREATE STATISTICS STATS_Stage_IPS_Image_Review_Results_05 ON Stage.IPS_Image_Review_Results(IRR_LaneCode)
		CREATE STATISTICS STATS_Stage_IPS_Image_Review_Results_06 ON Stage.IPS_Image_Review_Results(VesSerialNumber)
		CREATE STATISTICS STATS_Stage_IPS_Image_Review_Results_07 ON Stage.IPS_Image_Review_Results(IsManuallyReviewed)

		SET  @Log_Message = 'Loaded Stage.IPS_Image_Review_Results' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		 
		--=============================================================================================================
		-- Load Stage.ViolatedTripPayment
		--=============================================================================================================
		IF OBJECT_ID('Stage.ViolatedTripPayment_NEW','U') IS NOT NULL DROP TABLE Stage.ViolatedTripPayment_NEW
		CREATE TABLE Stage.ViolatedTripPayment_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID)) AS
		WITH CTE_VT_Receipts_Tracker AS
		(
			SELECT	TT.TPTripID, TT.TripWith, TT.ExitTripDateTime TripDate, TT.SourceOfEntry, 
					VT.CitationID, VT.TollAmount, VT.OutstandingAmount, VT.PaymentStatusID, TT.IsNonRevenue NonRevenueFlag, VT.IsWriteOff WriteOffFlag, VT.WriteOffDate, VT.WriteOffAmount,
					RT.TripReceiptID, RT.LinkID AS RT_LinkID, RT.LinkSourceName AS RT_LinkSourceName, RT.TxnDate, RT.AmountReceived TxnAmount
			FROM    LND_TBOS.TollPlus.TP_Trips TT
			JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips VT
					ON VT.TPTripID = TT.TPTripID AND VT.CitationID = TT.LinkID AND TT.TripWith = 'V' AND TT.LND_UpdateType <> 'D' AND VT.LND_UpdateType <> 'D'
			JOIN	LND_TBOS.TollPlus.TP_Violated_Trip_Receipts_Tracker RT
					ON VT.CitationID = RT.CitationID AND RT.LND_UpdateType <> 'D'
			WHERE   RT.LinkSourceName IN ('FINANCE.PAYMENTTXNS','FINANCE.ADJUSTMENTS') /* exclude TOLLPLUS.TP_CUSTOMERTRIPS */
					AND TT.SourceOfEntry IN (1,3) -- TSA & NTTA 
					AND TT.Exit_TollTxnID >= 0
					AND TT.ExitTripDateTime >= '2019-01-01' -- @Load_Cutoff_Date
					AND TT.ExitTripDateTime < SYSDATETIME()
					--AND (TT.TpTripID IN (2394521987,2864601976,2874007937,3018338513,3035826778,3107276708, 1937242377,2123262841,2171601474,2171750141,2554758633, 1919833818) OR TT.ExitTripDateTime >= '2021-03-22' AND TT.ExitTripDateTime < '2021-03-23')
					--AND VT.TpTripID IN ( 3528694386,3530036803,3533177703,3533218053,3533936506,3533947751,3534230983,3538888035) -- multiple adj lines for 1 adj id which is present multiple times in receipts tracker	
					--AND VT.TpTripID IN (2394521987,2864601976,2874007937,3018338513,3035826778,3107276708) -- credit adj examples -- 34 sec v1 vs 34 sec v2 vs 21 sec v3
					--AND VT.TpTripID IN (1937242377,2123262841,2171601474,2171750141,2554758633) -- debit adj or reversal examples -- 29 sec v1 vs 31 sec v2 vs 15 sec v3  
					--AND VT.TpTripID IN ( 2530609156, 2783824527,2567894441,2546175530,3220034386,2778945056,2771048636,2906264320,2700832365,2554253242,2570011704,2892065183,2916299727,2921527701,2569987575,2562346386,2687491659,2570738870,2710272947,2554227769,2533336522,3222512621,2921518684,2767950434,2908129674,2781993208,2548880101,2772712368,2551876707,2548898756,2771092936,2545101253,2911952388,2728474043,2918579961,2794039088,2698193126,2772748352,2780662960,2787219210,2785127852,2911988452,2710284343,2569966972,2570725824,2918701004,2548160421,2904324362,2569998851,2794050950,2883481160,2767970730,2559240672,2883496334,2562359435,2530609156,2551171685,2542250083,2787698561,3222269254,2885601201,2908099601,2698148524,2542244513,2707416529,2540311885,2670614739,2701672420,2909722943,2535328097,2698175707,2778988034,2791687645,2916312274,2725997000,2698163285,2909732893,2722912816,2782241434,2559260280,2709497858,2678256308,2692840318,2707429111,2684465283,2912023241,2701658801,2561217148,2908072297,2699873934,2680332525,2690547395,2767900673,2704438744,2779018959,2771079091,2530671595,2542254897,2561016876,2916291076,2686591003,2530630931,2692783924,2704451131,2678269980,2546134057,2709528843,2788311617,2772682985,2915286909,2543117461,2912072020,2710259879,2790624026,2567031111,2684496579,2681622064,2530689472,2670645548,2701696558,2916346935,3220109956,2546150392,2775781645,2772655331,2775795383,2540338544,2791707060,2883472077,2915360699,2770146144,2788357594,2692870688,2700800398,2757922434,2681585956,2687476715,2793838585,2785162662,2770171968,2719823856,2709509447,2564390468,2707463395,2787182310,2546111639,2554211406,2913156391,2780751155,2788290813,2535374926,2548129771,3222408002,2722968628,2915307072,2545087725,2703192158,2775324950,2748328854,2566981078,2565101276,2567942967,2545122215,2913237736,2567015915,2545139532,2918483904,2781985846,2724004401,2703149561,2680307257,2777399927,2540373916,2790711986,2565073878,2551152087,2561131127,2684479399,2565089412,2793917459,2548911248,2704473606,2778998889,2704423505,2724019126,2545063514,2687454753,2567927795,2912053093,2909712042,2554269648,2748797020,2687513029,2793874406,2787243738,2908037149,2892096209,2542239740,2707446658,2915251235,2907996567,2913210869,2771113032,2772610806,2771063151,2915339092,2909702920,2533327431,2532925948,2680360934,2551841063,2892173838,2788327767,2678235916,2689570149,2533315455,2692884240,2554238923,2542231068,2561186700,2564410611,2725961220,2723983008,2683414528,2689521538,2906248664,2767918190,2562088341,2726049064,2548148538,2770182406,2783862200,2706390543,2790674882,2538999214,2690572856,2892155192,2686627925,2775822585,2778963540,2892131129,2785142255,2918549063,2570748666,2678188749,2566959522,2748786141,2909748066,2913196561,2791656424,2535356355,2775470814,2782283982,2767936009,2706444837,2699831796,2692898185,2913055414,2775503087,2684514885,2906289945,3223157976,2570022739,2790695886,2532930360,2532914756,2559212006,2683367338,2709475190,2780702732,3526363369,2543085756,2916323310,2770191322,2706422606,2695224322,2709520798,2540289778,2783888482,2787691267,2567907013,2785112335,2683397460,2883462328,2703177497,2530658403,2780725436,2775808530,2770161785,2551818658,2566999124,3219888827,2686532963,2791671042,2906013826,2782259585,2551163089,2913178374,2723007305,2699856017,2707488809,2551141832,2690522107,2775487808,2548931600,2567962652,2533353054,2723975972,2680385672,2564419452,2790655763,2689605468,2551127406,2532939791,2565121092,2690536173,2543101719,2681600831,2561096931,2918525110,2540352603,2684536965,2723008877,2542596023,2793897443,2559227893,2893343305,2722868876,2551855993) 
					--Overpayment from unmatched paid transaction
					--AND VT.TpTripID IN (1919887405, 1921007881,1921239894,1922171267,1922171268) -- 4256 BkrtDismiss
		)
		--SELECT * FROM CTE_VT_Receipts_Tracker ORDER BY TPTripID, TxnDate
		, 	CTE_ALI AS
		(
			--:: Payment Txns
			SELECT	RT.*, CAST(NULL AS BIGINT) AdjustmentID, CAST(NULL AS BIGINT) AS ALI_LinkID, CAST(NULL AS VARCHAR(50)) ALI_LinkSourceName, CAST(1 AS SMALLINT) ALI_Seq
			FROM	CTE_VT_Receipts_Tracker RT
			WHERE	RT.RT_LinkSourceName = 'FINANCE.PAYMENTTXNS'
			UNION
			--:: Payment thru Adjustment and pure Adjustments
			SELECT	RT.*, ALI.AdjustmentID, ALI.LinkID AS ALI_LinkID, ALI.LinkSourceName AS ALI_LinkSourceName,
					ROW_NUMBER() OVER (	PARTITION BY RT.CitationID, RT.TripReceiptID, ALI.AdjustmentID 
										ORDER BY CASE WHEN (ALI.LinkSourceName = 'TOLLPLUS.INVOICE_HEADER') OR
												           (ALI.LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS' AND ALI.LinkID = RT.CitationID) THEN 1 
													  ELSE 2 END) ALI_Seq
			FROM	CTE_VT_Receipts_Tracker RT
			JOIN LND_TBOS.Finance.Adjustment_LineItems ALI
					ON ALI.AdjustmentID = RT.RT_LinkID
					AND ALI.LinkSourceName IN ('TOLLPLUS.TP_VIOLATEDTRIPS','TOLLPLUS.INVOICE_HEADER','FINANCE.ADJUSTMENTS') 
					AND RT.RT_LinkSourceName = 'FINANCE.ADJUSTMENTS'
					AND ALI.LND_UpdateType <> 'D'
			JOIN LND_TBOS.Finance.Adjustments ADJ
					ON ADJ.AdjustmentID = ALI.AdjustmentID
					AND ADJ.ApprovedStatusID = 466 -- Approved
					AND ADJ.LND_UpdateType <> 'D'
		)
		--SELECT * FROM CTE_ALI ORDER BY TPTripID, TxnDate, CTE_ALI.ALI_Seq
		,	CTE_Viol_Payments AS
		(
			SELECT	TpTripID, TripDate, TripWith, TripReceiptID, CitationID, TollAmount, OutstandingAmount, PaymentStatusID, NonRevenueFlag, TxnDate, TxnAmount, 
					CASE WHEN RT_LinkSourceName = 'FINANCE.PAYMENTTXNS' OR NOT (ALI_LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS' /*2539986413*/ AND ALI_LinkID = CitationID /*2530609156*/) THEN TxnAmount ELSE 0 END ActualPaidAmount,
					CASE WHEN ALI_LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS' AND ALI_LinkID = CitationID THEN TxnAmount ELSE 0 END AdjustedAmount,
					CASE WHEN RT_LinkSourceName = 'FINANCE.PAYMENTTXNS' THEN RT_LinkID END PaymentID,
					CASE WHEN RT_LinkSourceName = 'FINANCE.ADJUSTMENTS' THEN RT_LinkID END AdjustmentID,
					RT_LinkSourceName, ALI_LinkSourceName, ALI_LinkID,
					ROW_NUMBER() OVER (PARTITION BY CitationID ORDER BY TxnDate) TxnSeq, ALI_Seq,
					SUM(TxnAmount) OVER (PARTITION BY CitationID ORDER BY TxnDate) RunningTotalAmount
			FROM	CTE_ALI 
			WHERE	ALI_Seq = 1
		)
		--SELECT * FROM CTE_Viol_Payments ORDER BY TPTripID, TxnDate
		, CTE_FirstCreditAdjTxnDate AS
		(
			SELECT TpTripID, CitationID, MAX(TxnDate) FirstCreditAdjTxnDate
			FROM CTE_Viol_Payments 
			WHERE AdjustedAmount < 0 -- Credit Adjustment
			GROUP BY TpTripID, CitationID
		) 
		--SELECT * FROM CTE_FirstCreditAdjTxnDate -- 2021-09-14 13:40:59.197
		, CTE_ValidLastZeroAmountTxnDate AS
		(
			SELECT P.TpTripID, P.CitationID, MAX(P.TxnDate) ZeroAmountTxnDate
			FROM CTE_Viol_Payments P
			JOIN CTE_FirstCreditAdjTxnDate CAD ON P.TpTripID = CAD.TpTripID
			WHERE P.RunningTotalAmount = 0 AND P.TxnDate < CAD.FirstCreditAdjTxnDate /* Example: 2864601976 with Payment Reversal (that is, $0 Running Total) before the first Credit Adjustment */
			GROUP BY P.TpTripID, P.CitationID
		) 
		--SELECT * FROM CTE_ValidLastZeroAmountTxnDate -- 2021-09-14 13:34:21.907
		SELECT  VP.TpTripID, VP.CitationID, VP.TripDate, VP.TripWith, VP.NonRevenueFlag,
				CAST(SUM(TxnAmount) AS DECIMAL(19,2)) TotalTxnAmount, 
				VP.TollAmount, 
				CAST(SUM(AdjustedAmount) AS DECIMAL(19,2)) AdjustedAmount, 
				CAST(SUM(ActualPaidAmount) * -1 AS DECIMAL(19,2)) ActualPaidAmount, 
				VP.OutstandingAmount, 
				VP.PaymentStatusID,
				MIN(TxnDate) AS FirstPaidDate, 
				MAX(TxnDate) AS LastPaidDate
		FROM CTE_Viol_Payments VP
		WHERE NOT EXISTS (SELECT 1  FROM CTE_ValidLastZeroAmountTxnDate ZD WHERE ZD.CitationID = VP.CitationID AND VP.TxnDate <= ZD.ZeroAmountTxnDate)
		GROUP BY VP.TpTripID, VP.CitationID, VP.TripDate, VP.TripWith, VP.NonRevenueFlag, VP.TollAmount, VP.OutstandingAmount, VP.PaymentStatusID 
		--ORDER BY 1
		
		SET  @Log_Message = 'Loaded Stage.ViolatedTripPayment' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Create Statistics
		CREATE STATISTICS STATS_Stage_ViolatedTripPayment_001 ON Stage.ViolatedTripPayment_NEW (TPTripID)
		CREATE STATISTICS STATS_Stage_ViolatedTripPayment_002 ON Stage.ViolatedTripPayment_NEW (CitationID)
		CREATE STATISTICS STATS_Stage_ViolatedTripPayment_003 ON Stage.ViolatedTripPayment_NEW (TripWith)
		CREATE STATISTICS STATS_Stage_ViolatedTripPayment_004 ON Stage.ViolatedTripPayment_NEW (TripDate)

		SET  @Log_Message = 'Created STATISTICS on Stage.ViolatedTripPayment_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		EXEC Utility.TableSwap 'Stage.ViolatedTripPayment_NEW','Stage.ViolatedTripPayment'

		--:: Soft delete IOP Duplicate TPTripIDs. Quick 1 sec check every time, but update happens in the first run or after the next full load of TP_Trips table. Performance optimization and query simplification measure. Automatically effective for other EDW ETL queries. 
		IF   EXISTS (
						SELECT	1
						  FROM	LND_TBOS.TollPlus.TP_Trips TT
								JOIN LND_TBOS.dbo.IopOutBoundAndViolationLinking IOP ON IOP.OutboundTpTripId = TT.TPTripID
						WHERE	TT.LND_UpdateType <> 'D'
					)  
		BEGIN
			UPDATE	LND_TBOS.TollPlus.TP_Trips
			SET		LND_UpdateType = 'D'
			FROM	LND_TBOS.dbo.IopOutBoundAndViolationLinking 
			WHERE	IopOutBoundAndViolationLinking.OutboundTpTripId = TP_Trips.TPTripID 

			SET  @Log_Message = 'Soft deleted IOP Duplicate trips in LND_TBOS.TollPlus.TP_Trips' 
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		END

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

		IF OBJECT_ID('Stage.TollRates','U') IS NOT NULL DROP TABLE Stage.TollRates  
		CREATE TABLE Stage.TollRates 
						WITH (CLUSTERED INDEX (ExitlaneId), DISTRIBUTION = REPLICATE) 
						 
 		AS
					SELECT EntryPlazaId
					,ExitPlazaId
					,ExitlaneId
					,LaneType
					,StartEffectiveDate
					,EndEffectiveDate
					,VehicleClass
					,ScheduleType
					,FromTime
					,ToTime
					,AviRate AS TagFare
					,VideoRate AS PlateFare
					FROM (
					SELECT shdr.EntryPlazaId
					,SHDR.ExitPlazaId
					,SHDR.ENTRYLANEID AS ExitlaneId
					,dtls.LaneType
					,shdr.StartEffectiveDate
					,shdr.EndEffectiveDate
					,dtls.VehicleClass
					,sdtls.FromTime
					,SDTLS.ToTime
					,dtls.TollAmount
					,HDR.TransactionMenthod
					,ScheduleType
					FROM LND_TBOS.[TOLLPLUS].[TP_TOLLRATE_HDR] hdr(NOLOCK)
					INNER JOIN LND_TBOS.[TOLLPLUS].[TP_TOLLRATE_DTLS] dtls(NOLOCK) ON hdr.TOLLRATEHDRID = dtls.TOLLRATEID
					INNER JOIN LND_TBOS.[TOLLPLUS].[TOLLSCHEDULEDTL] sdtls(NOLOCK) ON dtls.TOLLRATEID = sdtls.TOLLRATEID
					INNER JOIN LND_TBOS.[TOLLPLUS].[TOLLSCHEDULEHDR] shdr(NOLOCK) ON sdtls.TOLLSCHEDULEHDRID = shdr.TOLLSCHEDULEHDRID
					) P
					PIVOT(MAX(TOLLAMOUNT) FOR TRANSACTIONMENTHOD IN (
					AviRate
					,VideoRate
					)) AS PVT
 		
		SET  @Log_Message = 'Loaded Stage.TollRates' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Create Statistics
		CREATE STATISTICS STATS_Stage_TollRates_001 ON Stage.TollRates (StartEffectiveDate, EndEffectiveDate)
		CREATE STATISTICS STATS_Stage_TollRates_002 ON Stage.TollRates (VehicleClass)

		--=============================================================================================================
		-- Load Stage.Bubble_CustomerTags. Ensure {CustomerID, TagAgency, SerialNo} is unique in the table
		--=============================================================================================================
		IF OBJECT_ID('Stage.Bubble_CustomerTags') IS NOT NULL DROP TABLE Stage.Bubble_CustomerTags
		CREATE TABLE Stage.Bubble_CustomerTags WITH (CLUSTERED INDEX (CustomerID), DISTRIBUTION = HASH(CustomerID)) AS
		SELECT CustTagID, CustomerID, TagAgency, SerialNo 
		FROM 
			(
			SELECT  CustTagID, CustomerID, TagAgency, SerialNo, ROW_NUMBER() OVER (PARTITION BY CustomerID, TagAgency, SerialNo ORDER BY CustTagID DESC) RN  
			FROM	LND_TBOS.TollPlus.TP_Customer_Tags
			) CT 
		WHERE RN = 1

		SET  @Log_Message = 'Loaded Stage.Bubble_CustomerTags' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Create Statistics
		CREATE STATISTICS STATS_Stage_Bubble_CustomerTags_001 ON Stage.Bubble_CustomerTags (CustTagID)
		CREATE STATISTICS STATS_Stage_Bubble_CustomerTags_002 ON Stage.Bubble_CustomerTags (TagAgency)
		CREATE STATISTICS STATS_Stage_Bubble_CustomerTags_003 ON Stage.Bubble_CustomerTags (SerialNo)

		--=============================================================================================================
		-- Load Stage.UnifiedTransaction
		--=============================================================================================================

		IF OBJECT_ID('Stage.UnifiedTransaction_NEW','U') IS NOT NULL DROP TABLE Stage.UnifiedTransaction_NEW  
		CREATE TABLE Stage.UnifiedTransaction_NEW 
						WITH (CLUSTERED INDEX (TPTripID), DISTRIBUTION = HASH(TPTripID)) 
						--WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID)) 
 		AS
		
		--EXPLAIN 
		SELECT 
			  TPTripID
			, CustTripID
			, CitationID
			, TripDate
			, ISNULL(TripDayID,-1) TripDayID
			, LaneID
			, ISNULL(NULLIF(UT.CustomerID,0),-1) CustomerID
			, ISNULL(OM.OperationsMappingID,-1) OperationsMappingID
			, ISNULL(UT.TripIdentMethod,'Unknown') TripIdentMethod
			, ISNULL(UT.LaneTripIdentMethod,'Unknown') LaneTripIdentMethod
			, UT.RecordType
			, UT.TripWith
			, ISNULL(UT.TransactionPostingType,'Unknown') TransactionPostingType
			, ISNULL(UT.TripStageID,-1) TripStageID
			, ISNULL(TSG.TripStageCode,'Unknown') TripStageCode
			, ISNULL(UT.TripStatusID,-1) TripStatusID
			, ISNULL(TST.TripStatusCode,'Unknown') TripStatusCode
			, ISNULL(UT.ReasonCode,'Unknown') ReasonCode
			, ISNULL(UT.CitationStageCode,'Unknown') CitationStageCode
			, ISNULL(UT.TripPaymentStatusID,-1) TripPaymentStatusID 
			, ISNULL(PS.TripPaymentStatusDesc,'Unknown') TripPaymentStatusDesc 
			, UT.SourceName
			, UT.OperationsAgency
			, UT.FacilityCode
			, ISNULL(VehicleID,-1) VehicleID
			, UT.VehicleNumber
			, UT.VehicleState
			, UT.TagRefID
			, UT.TagAgency 
			, UT.VehicleClass
			, UT.RevenueVehicleClass
			, UT.SourceOfEntry
			, UT.SourceTripID
			, UT.Disposition
			, IPSTransactionID
			, UT.VESSerialNumber
			, UT.ShowBadAddressFlag
			, ISNULL(CAST(CASE WHEN UT.ShowBadAddressFlag = 1 THEN C.BadAddressFlag END AS SMALLINT),-1) BadAddressFlag
			, UT.NonRevenueFlag
			, UT.BusinessRuleMatchedFlag
			, UT.ManuallyReviewedFlag
			, UT.OOSPlateFlag
			, CAST(CASE WHEN UT.TransactionPostingType LIKE 'VToll%' THEN 1 ELSE 0 END AS SMALLINT) AS VTollFlag
			, UT.ClassAdjustmentFlag
			, CAST(CASE	WHEN ISNULL(UT.ActualPaidAmount,0) = 0 THEN '0'
						WHEN ISNULL(UT.ActualPaidAmount,0) > COALESCE(UT.AdjustedExpectedAmount,UT.ExpectedAmount,0) THEN '>AEA'
						WHEN ISNULL(UT.ActualPaidAmount,0) < COALESCE(UT.AdjustedExpectedAmount,UT.ExpectedAmount,0) THEN '<AEA'
						WHEN ISNULL(UT.ActualPaidAmount,0) = COALESCE(UT.AdjustedExpectedAmount,UT.ExpectedAmount,0) THEN '=AEA'
					END AS VARCHAR(4))  Rpt_PaidvsAEA

			--:: Metrics
			, UT.ExpectedAmount
			, COALESCE(UT.AdjustedExpectedAmount,UT.ExpectedAmount,0) AS AdjustedExpectedAmount
			, ISNULL(CAST(COALESCE(UT.AdjustedExpectedAmount,UT.ExpectedAmount,0) - ISNULL(UT.ExpectedAmount,0) AS DECIMAL(19,2)),0) AS CalcAdjustedAmount
			, CAST(UT.TripWithAdjustedAmount AS DECIMAL(19,2)) AS TripWithAdjustedAmount
			, UT.TollAmount
			, ISNULL(CAST(UT.ActualPaidAmount AS DECIMAL(19,2)),0) AS ActualPaidAmount
			, ISNULL(CAST(UT.OutStandingAmount AS DECIMAL(19,2)),0) AS OutStandingAmount
			, CASE WHEN UT.ActualPaidAmount > 0 THEN UT.FirstPaidDate  END AS FirstPaidDate
			, CASE WHEN UT.ActualPaidAmount > 0 THEN UT.LastPaidDate   END AS LastPaidDate
			, UT.TxnAgencyID
			, UT.AccountAgencyID
 
			--:: Validation help
			, UT.TP_PostedDate  
			, UT.CustTrip_PostedDate
			, UT.ViolatedTrip_PostedDate
			, UT.AdjustedExpectedAmount UT_AdjustedExpectedAmount
			, UT.ActualPaidAmount UT_ActualPaidAmount
			
			, UT.ExpectedBase 
			, UT.ExpectedPremium
			, UT.AVITollAmount
			, UT.PBMTollAmount
			, UT.OriginalAVITollAmount
			, UT.OriginalPBMTollAmount

			, UT.TP_ReceivedTollAmount
			, UT.NRaw_FareAmount
			, UT.NRaw_VehicleClass_TagFare
			, UT.NRaw_VehicleClass_PlateFare
			, UT.TP_VehicleClass_TagFare
			, UT.TP_VehicleClass_PlateFare

			, UT.TSA_ReceivedTollAmount

			, UT.ViolatedTripPayment_TotalTxnAmount
			, UT.ViolatedTripPayment_AdjustedAmount
			, UT.ViolatedTripPayment_ActualPaidAmount

			, UT.TollAmount UT_TollAmount
			, UT.TP_TollAmount
			, UT.CustTrip_TollAmount
			, UT.ViolatedTrip_TollAmount
			
			, UT.TP_OutStandingAmount
			, UT.CustTrip_OutStandingAmount
			, UT.ViolatedTrip_OutStandingAmount

			, UT.TP_TripStatusID
			, UT.CustTrip_TripStatusID
			, UT.ViolatedTrip_TripStatusID

			, UT.TP_TripStageID
			, UT.CustTrip_TripStageID
			, UT.ViolatedTrip_TripStageID

			, UT.TP_PaymentStatusID
			, UT.CustTrip_PaymentStatusID
			, UT.ViolatedTrip_PaymentStatusID
			
			, UT.TTT_RecordType
			, UT.LND_UpdateDate
			, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
		
		FROM		

		(
			SELECT  --TOP 1 
					  TT.TPTripID
					, CT.CustTripID
					, VT.CitationID
					, TT.ExitTripDateTime																				AS TripDate
					, CAST(CONVERT(VARCHAR(8), TT.ExitTripDateTime, 112) AS INT)										AS TripDayID
					, ISNULL(CT.CustomerID,VT.ViolatorID)																AS CustomerID
					, CAST(CASE WHEN TT.TripWith = 'V' OR (TT.TripWith = 'C' AND CT.TripStatusID = 135 /*Customer Balance In Delinquent State*/) THEN 1 ELSE 0 END AS BIT) ShowBadAddressFlag
					, TT.ExitLaneID																						AS LaneID
					, COALESCE(CT.VehicleID,VT.VehicleID,TT.VehicleID)													AS VehicleID
					, TT.TripIdentMethod --#1
					, CAST(CASE WHEN TTT.TPTripID IS NOT NULL AND TTT.RecordType  IN ('RT21', 'RT24', 'RT25')	THEN 'AVITOLL'
								WHEN TTT.TPTripID IS NOT NULL AND TTT.RecordType  IN ('RT22')					THEN 'VIDEOTOLL'
								WHEN NRaw.RecordType IN ('RT21', 'RT24', 'RT25') OR TA.TransactionType = 'T'	THEN 'AVITOLL' 
								WHEN NRaw.RecordType IN ('RT22') OR TA.TransactionType = 'V'					THEN 'VIDEOTOLL'
								ELSE TT.TripIdentMethod
							END AS VARCHAR(10)) LaneTripIdentMethod  
					-- The RecordType for migrated data is picked up from the Ref.TartTPTrip (TTT) table generated by Bhanu from RITE Added By Shekhar on 7/20/2022
					, ISNULL(CAST(CASE WHEN TTT.TPTripID IS NOT NULL THEN TTT.RecordType WHEN TT.SourceOfEntry = 1 THEN NRaw.RecordType WHEN TT.SourceOfEntry = 3 AND TA.TransactionType IN ('V','T') THEN TA.TransactionType ELSE 'V' END AS VARCHAR(5)),'RT22') AS RecordType 
					, CAST(TT.TripWith AS CHAR(1))																		AS TripWith --#2
					, COALESCE(CT.TransactionPostingType,VT.TransactionPostingType,TT.TransactionPostingType)			AS TransactionPostingType --#3
					, COALESCE(CT.TripStageID, VT.TripStageID, TT.TripStageID)											AS TripStageID --#4
					, COALESCE(CT.TripStatusID, VT.TripStatusID, TT.TripStatusID)										AS TripStatusID --#5
					, CASE WHEN ISNULL(TT.ReasonCode,'') = '' AND TT.TripStatusID = 2 THEN 'Posted' ELSE ISNULL(NULLIF(TT.ReasonCode,''),'Unknown') END AS ReasonCode --#6
					, VT.CitationStage																					AS CitationStageCode --#7
					, CASE WHEN TT.TripStageID = 31 /*QUALIFY_FOR_IOP*/ AND TT.TripStatusID = 2 /*POSTED*/ AND AEA.AdjustedExpectedAmount = AEA.IOP_OutboundPaidAmount THEN  456
							ELSE NULLIF(COALESCE(CT.PaymentStatusID,VT.PaymentStatusID,TT.PaymentStatusID),0) END		AS TripPaymentStatusID --#8
					, TT.SourceName -- #9
					, L.OperationsAgency --#10
					, L.FacilityCode
					, NULLIF(TT.VehicleNumber,'')																		AS VehicleNumber
					, NULLIF(TT.VehicleState,'')																		AS VehicleState
					, TT.TagRefID
					, TT.TagAgency 
					, TT.VehicleClass
					, NRaw.RevenueVehicleClass
					, TT.SourceOfEntry
					, TT.SourceTripID
					, TT.Disposition
					, ISNULL(TT.IPSTransactionID,IRR.IPSTransactionID)													AS IPSTransactionID
					, CAST(CASE WHEN TT.SourceOfEntry = 3 THEN TT.TPTripID ELSE NRaw.ViolationSerialNumber END AS BIGINT) AS VESSerialNumber
					--:: Flags
					, ISNULL(CAST(TT.IsNonRevenue AS SMALLINT),-1) 														AS NonRevenueFlag --#12
					, ISNULL(CAST(BR.BusinessRuleMatchedFlag AS SMALLINT),-1)											AS BusinessRuleMatchedFlag -- #13  
					, ISNULL(CAST(IRR.IsManuallyReviewed AS SMALLINT),-1)												AS ManuallyReviewedFlag
					, ISNULL(CAST(CASE WHEN NULLIF(TT.VehicleState,'') = 'TX' THEN 0 WHEN NULLIF(TT.VehicleState,'') <> 'TX' THEN 1 ELSE -1 END AS SMALLINT),-1) AS OOSPlateFlag 
					, ISNULL(CAST(AEA.ClassAdjustmentFlag AS SMALLINT),-1)												AS ClassAdjustmentFlag 
					, TT.AgencyID																						AS TxnAgencyID
					, TT.AccountAgencyID
					
					--:: Metrics
					, CAST(CASE
								WHEN TTT.TPTripID IS NOT NULL  THEN TTT.EarnedRev -- This is for migrated data. Updated By Shekhar on 7/13/2022 after Bhanu pull data into Ref.TartTPTrip from the RITE System
								WHEN TT.SourceOfEntry = 1 AND TT.IsNonRevenue = 1 THEN 0
								WHEN TT.SourceOfEntry = 1 AND NRaw.RecordType IN ('RT21', 'RT24', 'RT25') THEN TR1.TagFare
								WHEN TT.SourceOfEntry = 1 AND NRaw.RecordType = 'RT22' THEN TR1.PlateFare 
								WHEN TT.SourceOfEntry = 1 AND NRaw.RecordType IS NULL AND TT.ReceivedTollAmount > 0 THEN TT.ReceivedTollAmount
								WHEN TT.SourceOfEntry = 1 AND TT.TripIdentMethod = 'AVITOLL' THEN TR2.TagFare
								WHEN TT.SourceOfEntry = 1 AND TT.TripIdentMethod = 'VIDEOTOLL' THEN TR2.PlateFare
								WHEN TT.SourceOfEntry = 3 THEN COALESCE(TA.TSA_ReceivedTollAmount, NULLIF(TT.ReceivedTollAmount,0),TT.TollAmount) END AS DECIMAL(19,2)) AS ExpectedAmount
					, AEA.AdjustedExpectedAmount
					, AEA.TripWithAdjustedAmount
					, COALESCE(CT.TollAmount, VT.TollAmount, TT.TollAmount)											AS TollAmount  
					, ISNULL(VP.ActualPaidAmount, 
							 CASE WHEN TT.TripStageID = 31 /*QUALIFY_FOR_IOP*/ AND ISNULL(TT.TripWith,'I') = 'I'
								  THEN AEA.IOP_OutboundPaidAmount
								  WHEN COALESCE(CT.PaymentStatusID,VT.PaymentStatusID,TT.PaymentStatusID) IN (456,457) -- Paid or Partial Paid
								  THEN COALESCE(CT.TollAmount - CT.OutStandingAmount, VT.TollAmount - VT.OutStandingAmount, ISNULL(TT.TollAmount,0) - ISNULL(TT.OutStandingAmount,0))  + ISNULL(AEA.TripWithAdjustedAmount,0) /* Example: AdjustedAmount for CSR_ADJUSTED C Trips */ 
							 ELSE 0 END)		AS ActualPaidAmount
					, COALESCE(CASE WHEN TT.TripStageID = 31 /*QUALIFY_FOR_IOP*/ AND ISNULL(TT.TripWith,'I') = 'I' THEN AEA.AdjustedExpectedAmount - AEA.IOP_OutboundPaidAmount END, CT.OutStandingAmount, VT.OutStandingAmount, TT.OutStandingAmount)	AS OutStandingAmount
					, COALESCE(VP.FirstPaidDate,CT.PostedDate, TT.PostedDate)														AS FirstPaidDate
					, COALESCE(VP.LastPaidDate ,CT.PostedDate, TT.PostedDate)														AS LastPaidDate
					
					--:: Validation help
					, TT.PostedDate				AS TP_PostedDate
					, CT.PostedDate				AS CustTrip_PostedDate
					, VT.PostedDate 			AS ViolatedTrip_PostedDate
					
					, CAST(CASE WHEN TT.SourceOfEntry = 1 THEN TT.AVITollAmount ELSE TA.TSA_Base END AS DECIMAL(19,2))							AS ExpectedBase
					, CAST(CASE WHEN TT.SourceOfEntry = 1 THEN TT.ReceivedTollAmount - TT.AVITollAmount ELSE TSA_Premium END AS DECIMAL(19,2))	AS ExpectedPremium
					, COALESCE(CT.AVITollAmount,VT.AVITollAmount,TT.AVITollAmount) AVITollAmount
					, COALESCE(CT.PBMTollAmount,VT.PBMTollAmount,TT.PBMTollAmount) PBMTollAmount
					, TT.OriginalAVITollAmount
					, TT.OriginalPBMTollAmount

					, TT.ReceivedTollAmount		AS TP_ReceivedTollAmount
					, NRaw.FareAmount			AS NRaw_FareAmount
					, TR1.TagFare				AS NRaw_VehicleClass_TagFare
					, TR1.PlateFare				AS NRaw_VehicleClass_PlateFare
					, TR2.TagFare				AS TP_VehicleClass_TagFare
					, TR2.PlateFare				AS TP_VehicleClass_PlateFare
					, TA.TSA_ReceivedTollAmount AS TSA_ReceivedTollAmount

					, VP.TotalTxnAmount 		AS ViolatedTripPayment_TotalTxnAmount
					, VP.AdjustedAmount			AS ViolatedTripPayment_AdjustedAmount
					, VP.ActualPaidAmount 		AS ViolatedTripPayment_ActualPaidAmount
					
					, TT.TollAmount				AS TP_TollAmount
					, CT.TollAmount				AS CustTrip_TollAmount
					, VT.TollAmount				AS ViolatedTrip_TollAmount
					
					, TT.OutStandingAmount		AS TP_OutStandingAmount
					, CT.OutStandingAmount		AS CustTrip_OutStandingAmount
					, VT.OutStandingAmount		AS ViolatedTrip_OutStandingAmount
					
					, TT.PaymentStatusID		AS TP_PaymentStatusID
					, CT.PaymentStatusID		AS CustTrip_PaymentStatusID
					, VT.PaymentStatusID		AS ViolatedTrip_PaymentStatusID
					
					, TT.TripStatusID			AS TP_TripStatusID
					, CT.TripStatusID			AS CustTrip_TripStatusID
					, VT.TripStatusID			AS ViolatedTrip_TripStatusID

					, TT.TripStageID			AS TP_TripStageID
					, CT.TripStageID			AS CustTrip_TripStageID
					, VT.TripStageID			AS ViolatedTrip_TripStageID

					, TTT.RecordType			AS TTT_RecordType

					, COALESCE(CT.LND_UpdateDate, VT.LND_UpdateDate,TT.LND_UpdateDate) AS LND_UpdateDate
					--SELECT COUNT_BIG(1) RC 
			FROM 
				LND_TBOS.TollPlus.TP_Trips TT
				 JOIN dbo.Dim_Lane L ON L.LaneID = TT.ExitLaneID AND TT.LND_UpdateType <> 'D'
				 LEFT JOIN LND_TBOS.TollPlus.TP_CustomerTrips CT ON CT.TPTripID = TT.TPTripID AND CT.CustTripID = TT.LinkID AND TT.TripWith = 'C' AND CT.LND_UpdateType <> 'D' 
				 LEFT JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT ON VT.TPTripID = TT.TPTripID AND VT.CitationID = TT.LinkID AND TT.TripWith = 'V' AND VT.LND_UpdateType <> 'D'
				 LEFT JOIN Stage.IPS_Image_Review_Results IRR ON IRR.TPTripID = TT.TpTripID
				 LEFT JOIN Stage.Uninvoiced_Citation_Summary_BR BR ON BR.CitationID = VT.CitationID
				 LEFT JOIN Stage.ViolatedTripPayment VP ON VP.TpTripID = TT.TpTripID
				 LEFT JOIN Stage.NTTARawTransactions NRaw ON NRaw.TPTripID = TT.TpTripID AND TT.SourceOfEntry = 1
				 LEFT JOIN Stage.TSATripAttributes TA ON TA.TPTripID = TT.TpTripID AND TT.SourceOfEntry = 3
				 LEFT JOIN dbo.Fact_AdjExpectedAmount AEA ON AEA.TPTripID = TT.TpTripID  
				 LEFT JOIN Stage.TollRates TR1
					ON  TT.ExitLaneID = TR1.ExitlaneId 
					AND TT.ExitTripDateTime BETWEEN TR1.StartEffectiveDate AND TR1.EndEffectiveDate
					AND NRaw.RevenueVehicleClass = TR1.VehicleClass 
					AND TT.IsNonRevenue = 0
				 LEFT JOIN Stage.TollRates TR2
					ON  TT.ExitLaneID = TR2.ExitlaneId 
					AND TT.ExitTripDateTime BETWEEN TR2.StartEffectiveDate AND TR2.EndEffectiveDate
					AND TT.VehicleClass = TR2.VehicleClass
					AND TT.IsNonRevenue = 0
					AND ISNULL(TT.ReceivedTollAmount,0) = 0
				LEFT JOIN Ref.TartTPTrip TTT  -- Join added by Shekhar on 7/13/2022 to fetch ExpectedAmount from RITE table for migrated data
					ON TT.TPTripID = TTT.TPTripID
			WHERE	
				TT.SourceOfEntry IN (1,3) -- TSA & NTTA 
				AND TT.Exit_TollTxnID >= 0
				AND TT.ExitTripDateTime >= '2019-01-01' -- @Load_Cutoff_Date
				AND TT.ExitTripDateTime < SYSDATETIME()
				--AND TT.TpTripID = 4457612438
				--AND TT.TpTripID IN (2417684979 /* RTM<>0, Nraw*/, 2417686387 /*RTM=0, Nraw*/, 12058155 /*No NRaw, RTM <>0*/, 163810219 /*No NRaw, RTM = 0*/)
				--AND TT.TpTripID IN (1296825541, 1274319280) -- TSA ExpectedAmount = 0
				--AND (TT.TpTripID IN (2394521987,2864601976,2874007937,3018338513,3035826778,3107276708, 1937242377,2123262841,2171601474,2171750141,2554758633, 1919833818) OR TT.ExitTripDateTime >= '2022-02-01' AND TT.ExitTripDateTime < '2022-02-02')
				--AND TT.TpTripID IN (3425875794, 3352760210,896711050) -- IOP
				--AND TT.TpTripID IN (3425165467,3426246820,3130269902) -- CT
				--AND VT.TpTripID IN (2394521987,2864601976,2874007937,3018338513,3035826778,3107276708) -- VT credit adj examples 
				--AND VT.TpTripID IN (1937242377,2123262841,2171601474,2171750141,2554758633) -- VT debit adj or reversal examples 
				--AND TT.TpTripID IN (2544273232, 2544623006, 2544433973, 2547735326) -- TSA
				--AND TT.TpTripID IN (3058214815, 3531584534, 3527685824, 3526854024) -- IOP TSA
				--AND TT.TpTripID IN (11,3036124,2311646450) -- Default RT Code cases
			) UT
			JOIN dbo.Dim_TripStage TSG ON TSG.TripStageID = UT.TripStageID
			JOIN dbo.Dim_TripStatus TST ON TST.TripStatusID = UT.TripStatusID
			LEFT JOIN dbo.Dim_TripPaymentStatus PS ON PS.TripPaymentStatusID =	UT.TripPaymentStatusID 
			LEFT JOIN dbo.Dim_Customer C ON C.CustomerID  = UT.CustomerID
			LEFT JOIN dbo.Dim_OperationsMapping OM 
				 ON	OM.TripIdentMethod                        = UT.TripIdentMethod
				 	AND ISNULL(OM.TripWith,'')                = ISNULL(UT.TripWith,'') 
				 	AND OM.TransactionPostingType             = ISNULL(UT.TransactionPostingType,'Unknown')
				 	AND OM.TripStageID						  = ISNULL(UT.TripStageID,-1)
				 	AND OM.TripStatusID						  = ISNULL(UT.TripStatusID,-1)
				 	AND OM.ReasonCode                         = ISNULL(UT.ReasonCode,'Unknown')
				 	AND OM.CitationStageCode                  = ISNULL(UT.CitationStageCode,'Unknown')
				 	AND OM.TripPaymentStatusID                = ISNULL(UT.TripPaymentStatusID,-1)
				 	AND ISNULL(OM.SourceName,'')              = ISNULL(UT.SourceName,'')
				 	AND OM.OperationsAgency                   = ISNULL(UT.OperationsAgency,'Unknown')
				 	AND ISNULL(OM.BadAddressFlag,-1)          = ISNULL(CAST(CASE WHEN UT.ShowBadAddressFlag = 1 THEN C.BadAddressFlag END AS SMALLINT),-1)
				 	AND ISNULL(OM.NonRevenueFlag,-1)          = ISNULL(UT.NonRevenueFlag,-1)
				 	AND ISNULL(OM.BusinessRuleMatchedFlag,-1) = ISNULL(UT.BusinessRuleMatchedFlag,-1)

		OPTION (LABEL = 'Stage.UnifiedTransaction Load_NEW');
		SET  @Log_Message = 'Loaded Stage.UnifiedTransaction_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Create Statistics
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_001 ON Stage.UnifiedTransaction_NEW (TPTripID)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_002 ON Stage.UnifiedTransaction_NEW (CustTripID)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_003 ON Stage.UnifiedTransaction_NEW (CitationID)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_004 ON Stage.UnifiedTransaction_NEW (TripIdentMethod)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_005 ON Stage.UnifiedTransaction_NEW (TripWith)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_006 ON Stage.UnifiedTransaction_NEW (TransactionPostingType)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_007 ON Stage.UnifiedTransaction_NEW (TripStageCode)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_008 ON Stage.UnifiedTransaction_NEW (TripStatusCode)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_009 ON Stage.UnifiedTransaction_NEW (ReasonCode)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_010 ON Stage.UnifiedTransaction_NEW (CitationStageCode)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_011 ON Stage.UnifiedTransaction_NEW (TripPaymentStatusDesc)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_012 ON Stage.UnifiedTransaction_NEW (SourceName)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_013 ON Stage.UnifiedTransaction_NEW (BadAddressFlag)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_014 ON Stage.UnifiedTransaction_NEW (NonRevenueFlag)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_015 ON Stage.UnifiedTransaction_NEW (BusinessRuleMatchedFlag)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_016 ON Stage.UnifiedTransaction_NEW (VESSerialNumber)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_017 ON Stage.UnifiedTransaction_NEW (IPSTransactionID)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_018 ON Stage.UnifiedTransaction_NEW (TripPaymentStatusID)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_019 ON Stage.UnifiedTransaction_NEW (TripStatusID)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_020 ON Stage.UnifiedTransaction_NEW (TripStageID)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_021 ON Stage.UnifiedTransaction_NEW (TripDayID)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_022 ON Stage.UnifiedTransaction_NEW (LaneTripIdentMethod)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_023 ON Stage.UnifiedTransaction_NEW (RecordType)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_024 ON Stage.UnifiedTransaction_NEW (Rpt_PaidvsAEA)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_025 ON Stage.UnifiedTransaction_NEW (RevenueVehicleClass)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_026 ON Stage.UnifiedTransaction_NEW (VehicleClass)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_027 ON Stage.UnifiedTransaction_NEW (VTollFlag)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_028 ON Stage.UnifiedTransaction_NEW (ClassAdjustmentFlag)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_029 ON Stage.UnifiedTransaction_NEW (VehicleID)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_030 ON Stage.UnifiedTransaction_NEW (VehicleNumber)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_031 ON Stage.UnifiedTransaction_NEW (VehicleState)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_032 ON Stage.UnifiedTransaction_NEW (TagRefID)
		CREATE STATISTICS STATS_Stage_UnifiedTransaction_033 ON Stage.UnifiedTransaction_NEW (TagAgency)
		
		SET  @Log_Message = 'Created STATISTICS on Stage.UnifiedTransaction_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Table swap!
		EXEC Utility.TableSwap 'Stage.UnifiedTransaction_NEW', 'stage.UnifiedTransaction'

		--=============================================================================================================
		-- dbo.Dim_OperationsMapping. Insert new combinations.
		--=============================================================================================================
		IF OBJECT_ID('Stage.Dim_OperationsMapping_NEW','U') IS NOT NULL DROP TABLE Stage.Dim_OperationsMapping_NEW  
		CREATE TABLE Stage.Dim_OperationsMapping_NEW 
						WITH (HEAP, DISTRIBUTION = ROUND_ROBIN) 
 		AS

		SELECT DISTINCT 
			--:: Mapping input key columns
			TIM.TripIdentMethod
			, UT.TripWith
			, TPT.TransactionPostingType
			, TSG.TripStageCode
			, TST.TripStatusCode
			, RC.ReasonCode
			, CS.CitationStageCode
			, PS.TripPaymentStatusDesc
			, UT.SourceName
			, UT.OperationsAgency
			, UT.BadAddressFlag
			, UT.NonRevenueFlag
			, UT.BusinessRuleMatchedFlag
			--:: Other columns
			, ISNULL(TIM.TripIdentMethodID,-1) TripIdentMethodID
			, ISNULL(TIM.TripIdentMethodCode,'Unknown') TripIdentMethodCode
			, TPT.TransactionPostingTypeID
			, TPT.TransactionPostingTypeDesc
			, TSG.TripStageID
			, TSG.TripStageDesc
			, TST.TripStatusID
			, TST.TripStatusDesc
			, RC.ReasonCodeID
			, CS.CitationStageID
			, CS.CitationStageDesc
			, PS.TripPaymentStatusID
			, PS.TripPaymentStatusCode
			, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
		--SELECT OM.OperationsMappingID, UT.CitationStageCode, UT.TripPaymentStatusDesc, UT.SourceName, *
		FROM 
			Stage.UnifiedTransaction UT
					LEFT JOIN dbo.Dim_TripIdentMethod TIM ON TIM.TripIdentMethod = UT.TripIdentMethod
					LEFT JOIN dbo.Dim_TransactionPostingType TPT ON  TPT.TransactionPostingType = UT.TransactionPostingType
					LEFT JOIN dbo.Dim_TripStage TSG ON TSG.TripStageCode = UT.TripStageCode
					LEFT JOIN dbo.Dim_TripStatus TST ON TST.TripStatusCode = UT.TripStatusCode
					LEFT JOIN dbo.Dim_ReasonCode RC ON RC.ReasonCode = UT.ReasonCode
					LEFT JOIN dbo.Dim_CitationStage CS ON CS.CitationStageCode = UT.CitationStageCode
					LEFT JOIN dbo.Dim_TripPaymentStatus PS ON PS.TripPaymentStatusDesc = UT.TripPaymentStatusDesc
					LEFT JOIN dbo.Dim_OperationsMapping OM  
						ON	OM.TripIdentMethod                        = UT.TripIdentMethod
							AND ISNULL(OM.TripWith,'')                = ISNULL(UT.TripWith,'') 
							AND OM.TransactionPostingType             = ISNULL(UT.TransactionPostingType,'Unknown')
							AND OM.TripStageID						  = UT.TripStageID
							AND OM.TripStatusID						  = UT.TripStatusID
							AND OM.ReasonCode                         = UT.ReasonCode
							AND OM.CitationStageCode                  = ISNULL(UT.CitationStageCode,'Unknown')
							AND OM.TripPaymentStatusID                = UT.TripPaymentStatusID
							AND ISNULL(OM.SourceName,'')              = ISNULL(UT.SourceName,'')
							AND OM.OperationsAgency                   = UT.OperationsAgency
							AND OM.BadAddressFlag					  = UT.BadAddressFlag 
							AND OM.NonRevenueFlag					  = UT.NonRevenueFlag
							AND OM.BusinessRuleMatchedFlag			  = UT.BusinessRuleMatchedFlag

		WHERE 
					UT.OperationsMappingID = -1 AND OM.OperationsMappingID IS NULL
		OPTION (LABEL = 'Load unknown combinations into Stage.Dim_OperationsMapping_NEW');

		SET  @Log_Message = 'Loaded unknown combinations into Stage.Dim_OperationsMapping_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		DECLARE @MAX_ID INT
		SELECT @MAX_ID = MAX(OperationsMappingID) FROM dbo.Dim_OperationsMapping 

		INSERT dbo.Dim_OperationsMapping
		(
			  OperationsMappingID
			, Mapping
			, MappingDetailed
			, PursUnpursStatus
			, TripIdentMethod
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
			, TripIdentMethodID
			, TripIdentMethodCode
			, TransactionPostingTypeID
			, TransactionPostingTypeDesc
			, TripStageID
			, TripStageDesc
			, TripStatusID
			, TripStatusDesc
			, ReasonCodeID
			, CitationStageID
			, CitationStageDesc
			, TripPaymentStatusID
			, TripPaymentStatusCode
			, EDW_UpdateDate
		)
		SELECT ISNULL(@MAX_ID,0) + ROW_NUMBER() OVER (ORDER BY  TripIdentMethod,TripWith,TransactionPostingType,TripStageCode,TripStatusCode,ReasonCode,CitationStageCode,TripPaymentStatusDesc,SourceName,NonRevenueFlag,BadAddressFlag,BusinessRuleMatchedFlag,OperationsAgency)  AS OperationsMappingID, 
				  --:: Mapping output
				  'Unknown' Mapping
				, 'Unknown' MappingDetailed
				, 'Unknown' PursUnpursStatus
				, *
		FROM Stage.Dim_OperationsMapping_NEW OM
		OPTION (LABEL = 'Insert unknown combinations into dbo.Dim_OperationsMapping');

		SET  @Log_Message = 'Inserted unknown combinations into dbo.Dim_OperationsMapping' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Prepopulate Mapping column
		UPDATE  dbo.Dim_OperationsMapping
		SET     Mapping = 
				CASE WHEN OperationsAgency = 'IOP - NTTA Home'
					 THEN 'NTTA-Home Agency IOP'
					 WHEN TripIdentMethod = 'AVITOLL' AND TripWith = 'C'
					   OR TripIdentMethod = 'AVITOLL' AND TripWith IS NULL AND TripStageCode IN ('UNQUALIFY','QUALIFY','QUALIFY_FOR_IMAGE_REVIEW')
					   OR TripIdentMethod = 'AVITOLL' AND TripStageCode = 'VIOLATION'
					 THEN 'Prepaid'
					 WHEN TripIdentMethod = 'AVITOLL' AND TripWith = 'I'
					   OR TripIdentMethod = 'AVITOLL' AND TripWith IS NULL AND TripStageCode IN ('QUALIFY_FOR_IOP')
					 THEN 'IOP - AVI'
					 WHEN TripIdentMethod = 'VIDEOTOLL' AND TripWith = 'I'
					   OR TripIdentMethod = 'VIDEOTOLL' AND TripWith IS NULL AND TripStageCode IN ('QUALIFY_FOR_IOP')
					 THEN 'IOP - Video'
					 WHEN TripIdentMethod = 'VIDEOTOLL' AND TripWith = 'C'
					   OR TripIdentMethod = 'VIDEOTOLL' AND TripWith IS NULL
					   OR TripIdentMethod = 'VIDEOTOLL' AND TripWith = 'V'
					 THEN 'Video'
				END  
		WHERE Mapping = 'Unknown'
		OPTION (LABEL = 'Update Mapping column in dbo.Dim_OperationsMapping');

		SET  @Log_Message = 'Updated Mapping column in dbo.Dim_OperationsMapping' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		UPDATE STATISTICS dbo.Dim_OperationsMapping
		
		--=============================================================================================================
		-- dbo.Fact_UnifiedTransaction 
		--=============================================================================================================
		IF OBJECT_ID('dbo.Fact_UnifiedTransaction_NEW','U') IS NOT NULL DROP TABLE dbo.Fact_UnifiedTransaction_NEW 
		CREATE TABLE dbo.Fact_UnifiedTransaction_NEW
				WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), 
				PARTITION (TripDayID RANGE RIGHT FOR VALUES (   20190101,20190201,20190301,20190401,20190501,20190601,20190701,20190801,20190901,20191001,20191101,20191201,
						                                        20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,
						                                        20210101,20210201,20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201,
						                                        20220101,20220201,20220301,20220401,20220501,20220601,20220701,20220801,20220901,20221001,20221101,20221201,
						                                        20230101,20230201,20230301,20230401,20230501,20230601,20230701,20230801,20230901,20231001,20231101,20231201,
						                                        20240101,20240201,20240301,20240401,20240501,20240601,20240701,20240801,20240901,20241001,20241101,20241201
						                                    ))) 
		AS 
		SELECT 
			  TPTripID
			, CustTripID
			, CitationID
			, TripDayID
			, TripDate
			, UT.TripWith
			, UT.SourceOfEntry
			, LaneID
			, OperationsMappingID
			, TIM.TripIdentMethodID
			, ISNULL(LTIM.TripIdentMethodID,-1) LaneTripIdentMethodID
			, ISNULL(RT.RecordTypeID,-1) RecordTypeID
			, TransactionPostingTypeID
			, TripStageID
			, TripStatusID
			, ReasonCodeID
			, CitationStageID
			, TripPaymentStatusID
			, UT.CustomerID
			, VehicleID
			, VehicleNumber
			, VehicleState
			, CT.CustTagID
			, UT.TagRefID
			, UT.TagAgency 
			, TxnAgencyID
			, AccountAgencyID
			, CAST(CASE WHEN VehicleClass IN ('2','3','4','5','6','7','8','11','12','13','14','15','16','17','18') THEN VehicleClass ELSE -1 END AS INT) VehicleClassID
			, BadAddressFlag		
			, NonRevenueFlag		
			, BusinessRuleMatchedFlag
			, ManuallyReviewedFlag	
			, OOSPlateFlag
			, VTollFlag
			, ClassAdjustmentFlag
			, Rpt_PaidvsAEA	
			, CAST(FirstPaidDate AS DATE) FirstPaidDate
			, CAST(LastPaidDate  AS DATE) LastPaidDate
			, ExpectedBase 
			, ExpectedPremium
			, ExpectedAmount
			, AdjustedExpectedAmount
			, CalcAdjustedAmount
			, TripWithAdjustedAmount
			, TollAmount
			, ActualPaidAmount
			, OutStandingAmount
			, UT.LND_UpdateDate
			, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
		FROM 
			Stage.UnifiedTransaction UT
			LEFT JOIN dbo.Dim_TripIdentMethod TIM ON TIM.TripIdentMethod = UT.TripIdentMethod
			LEFT JOIN dbo.Dim_TripIdentMethod LTIM ON LTIM.TripIdentMethod = UT.LaneTripIdentMethod
			LEFT JOIN dbo.Dim_TransactionPostingType TPT ON  TPT.TransactionPostingType = UT.TransactionPostingType
			LEFT JOIN dbo.Dim_ReasonCode RC ON RC.ReasonCode = UT.ReasonCode
			LEFT JOIN dbo.Dim_RecordType RT ON RT.RecordType = UT.RecordType
			LEFT JOIN dbo.Dim_CitationStage CS ON CS.CitationStageCode = UT.CitationStageCode
			LEFT JOIN Stage.Bubble_CustomerTags CT ON CT.CustomerID = UT.CustomerID AND CT.SerialNo = UT.TagRefID AND CT.TagAgency = UT.TagAgency
		WHERE UT.OperationsMappingID <> -1  
		UNION ALL
		SELECT 
			  UT.TPTripID
			, UT.CustTripID
			, UT.CitationID
			, UT.TripDayID
			, UT.TripDate
			, UT.TripWith
			, UT.SourceOfEntry
			, UT.LaneID
			, OM.OperationsMappingID
			, OM.TripIdentMethodID
			, ISNULL(LTIM.TripIdentMethodID,-1) LaneTripIdentMethodID 
			, ISNULL(RT.RecordTypeID,-1) RecordTypeID
			, OM.TransactionPostingTypeID
			, OM.TripStageID
			, OM.TripStatusID
			, OM.ReasonCodeID
			, OM.CitationStageID
			, OM.TripPaymentStatusID
			, UT.CustomerID
			, UT.VehicleID
			, UT.VehicleNumber
			, UT.VehicleState
			, CT.CustTagID
			, UT.TagRefID
			, UT.TagAgency 
			, UT.TxnAgencyID
			, UT.AccountAgencyID
			, CAST(CASE WHEN UT.VehicleClass IN ('2','3','4','5','6','7','8','11','12','13','14','15','16','17','18') THEN UT.VehicleClass ELSE -1 END AS INT) AS VehicleClassID
			, OM.BadAddressFlag
			, OM.NonRevenueFlag
			, OM.BusinessRuleMatchedFlag
			, UT.ManuallyReviewedFlag
			, UT.OOSPlateFlag
			, UT.VTollFlag
			, UT.ClassAdjustmentFlag
			, UT.Rpt_PaidvsAEA
			, CAST(UT.FirstPaidDate AS DATE) FirstPaidDate
			, CAST(UT.LastPaidDate AS DATE)  LastPaidDate
			, UT.ExpectedBase 
			, UT.ExpectedPremium
			, UT.ExpectedAmount
			, UT.AdjustedExpectedAmount
			, UT.CalcAdjustedAmount
			, UT.TripWithAdjustedAmount
			, UT.TollAmount
			, UT.ActualPaidAmount
			, UT.OutStandingAmount
			, UT.LND_UpdateDate
			, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
		FROM 
				Stage.UnifiedTransaction UT -- In Stage.UnifiedTransaction, OperationsMappingID remains -1 for new combination rows just inserted earlier in dbo.Dim_OperationsMapping table.
				LEFT JOIN dbo.Dim_TripIdentMethod LTIM ON LTIM.TripIdentMethod = UT.LaneTripIdentMethod
				LEFT JOIN dbo.Dim_RecordType RT ON RT.RecordType = UT.RecordType
				LEFT JOIN dbo.Dim_OperationsMapping OM 
						ON	OM.TripIdentMethod                        = UT.TripIdentMethod
							AND ISNULL(OM.TripWith,'')                = ISNULL(UT.TripWith,'') 
							AND OM.TransactionPostingType             = ISNULL(UT.TransactionPostingType,'Unknown')
							AND OM.TripStageID						  = UT.TripStageID
							AND OM.TripStatusID						  = UT.TripStatusID
							AND OM.ReasonCode                         = UT.ReasonCode
							AND OM.CitationStageCode                  = ISNULL(UT.CitationStageCode,'Unknown')
							AND OM.TripPaymentStatusID                = UT.TripPaymentStatusID
							AND ISNULL(OM.SourceName,'')              = ISNULL(UT.SourceName,'')
							AND OM.OperationsAgency                   = UT.OperationsAgency
							AND OM.BadAddressFlag					  = UT.BadAddressFlag 
							AND OM.NonRevenueFlag					  = UT.NonRevenueFlag
							AND OM.BusinessRuleMatchedFlag			  = UT.BusinessRuleMatchedFlag
			LEFT JOIN Stage.Bubble_CustomerTags CT 
					ON CT.CustomerID = UT.CustomerID 
						AND CT.SerialNo = UT.TagRefID 
						AND CT.TagAgency = UT.TagAgency
		WHERE UT.OperationsMappingID = -1  
		OPTION (LABEL = 'dbo.Fact_UnifiedTransaction_NEW Load');
		SET  @Log_Message = 'Loaded dbo.Fact_UnifiedTransaction_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Create Statistics
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_001 ON dbo.Fact_UnifiedTransaction_NEW(TpTripID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_002 ON dbo.Fact_UnifiedTransaction_NEW(TripDayID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_003 ON dbo.Fact_UnifiedTransaction_NEW(CustTripID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_004 ON dbo.Fact_UnifiedTransaction_NEW(CitationID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_005 ON dbo.Fact_UnifiedTransaction_NEW(OperationsMappingID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_006 ON dbo.Fact_UnifiedTransaction_NEW(TripWith)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_007 ON dbo.Fact_UnifiedTransaction_NEW(TripIdentMethodID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_008 ON dbo.Fact_UnifiedTransaction_NEW(TransactionPostingTypeID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_009 ON dbo.Fact_UnifiedTransaction_NEW(TripStageID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_010 ON dbo.Fact_UnifiedTransaction_NEW(TripStatusID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_011 ON dbo.Fact_UnifiedTransaction_NEW(ReasonCodeID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_012 ON dbo.Fact_UnifiedTransaction_NEW(CitationStageID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_013 ON dbo.Fact_UnifiedTransaction_NEW(TripPaymentStatusID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_014 ON dbo.Fact_UnifiedTransaction_NEW(TripStatusID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_015 ON dbo.Fact_UnifiedTransaction_NEW(CustomerID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_016 ON dbo.Fact_UnifiedTransaction_NEW(LaneID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_017 ON dbo.Fact_UnifiedTransaction_NEW(VehicleClassID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_018 ON dbo.Fact_UnifiedTransaction_NEW(VehicleID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_019 ON dbo.Fact_UnifiedTransaction_NEW(VehicleNumber)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_020 ON dbo.Fact_UnifiedTransaction_NEW(VehicleState)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_021 ON dbo.Fact_UnifiedTransaction_NEW(TagRefID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_022 ON dbo.Fact_UnifiedTransaction_NEW(TagAgency)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_023 ON dbo.Fact_UnifiedTransaction_NEW(TxnAgencyID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_024 ON dbo.Fact_UnifiedTransaction_NEW(AccountAgencyID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_025 ON dbo.Fact_UnifiedTransaction_NEW(BadAddressFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_026 ON dbo.Fact_UnifiedTransaction_NEW(NonRevenueFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_027 ON dbo.Fact_UnifiedTransaction_NEW(BusinessRuleMatchedFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_028 ON dbo.Fact_UnifiedTransaction_NEW(ManuallyReviewedFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_029 ON dbo.Fact_UnifiedTransaction_NEW(OOSPlateFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_030 ON dbo.Fact_UnifiedTransaction_NEW(ExpectedAmount)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_031 ON dbo.Fact_UnifiedTransaction_NEW(AdjustedExpectedAmount)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_032 ON dbo.Fact_UnifiedTransaction_NEW(CalcAdjustedAmount)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_033 ON dbo.Fact_UnifiedTransaction_NEW(TripWithAdjustedAmount)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_034 ON dbo.Fact_UnifiedTransaction_NEW(ActualPaidAmount)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_036 ON dbo.Fact_UnifiedTransaction_NEW(ExpectedBase)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_037 ON dbo.Fact_UnifiedTransaction_NEW(ExpectedPremium)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_038 ON dbo.Fact_UnifiedTransaction_NEW(OutStandingAmount)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_039 ON dbo.Fact_UnifiedTransaction_NEW(TollAmount)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_040 ON dbo.Fact_UnifiedTransaction_NEW(FirstPaidDate)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_041 ON dbo.Fact_UnifiedTransaction_NEW(LastPaidDate)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_042 ON dbo.Fact_UnifiedTransaction_NEW(SourceOfEntry)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_043 ON dbo.Fact_UnifiedTransaction_NEW(LaneTripIdentMethodID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_044 ON dbo.Fact_UnifiedTransaction_NEW(RecordTypeID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_045 ON dbo.Fact_UnifiedTransaction_NEW(VTollFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_046 ON dbo.Fact_UnifiedTransaction_NEW(ClassAdjustmentFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_047 ON dbo.Fact_UnifiedTransaction_NEW(CustTagID)
		 
		SET  @Log_Message = 'Created STATISTICS dbo.Fact_UnifiedTransaction_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_UnifiedTransaction_NEW', 'dbo.Fact_UnifiedTransaction'
		
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL

		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'Stage.UnifiedTransaction' TableName, * FROM Stage.UnifiedTransaction ORDER BY TripDate DESC,TPTripID
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_UnifiedTransaction' TableName, * FROM dbo.Fact_UnifiedTransaction ORDER BY TripDate DESC,TPTripID
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_OperationsMapping' TableName, * FROM dbo.Dim_OperationsMapping ORDER BY OperationsMappingID DESC

	END	TRY

	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH

END

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



