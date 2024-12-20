CREATE PROC [Stage].[InvoicePayment_Full_Load] AS
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
EXEC Stage.InvoicePayment_Full_Load
EXEC Utility.FromLog 'Stage.InvoicePayment_Full_Load', 1
SELECT TOP 100 'Stage.InvoicePayment_Full_Load' Table_Name, * FROM Stage.InvoicePayment_Full_Load ORDER BY 2
################################################################################################################################
*/

BEGIN
BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'Stage.InvoicePayment_Full_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME();
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0; -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL;
	
	--=============================================================================================================
		-- Load Stage.ViolatedTripPayment
	--=============================================================================================================
		IF OBJECT_ID('Stage.ViolTripPayment','U') IS NOT NULL DROP TABLE  Stage.ViolTripPayment
		CREATE TABLE Stage.ViolTripPayment WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CitationID)) AS
		WITH CTE_VT_Receipts_Tracker AS
		(
			SELECT	VT.TPTripID, --TT.TripWith, 
					VT.CitationID, VT.TollAmount, VT.OutstandingAmount, VT.TripStatusID,
					VT.PaymentStatusID, RT.TripReceiptID, RT.LinkID AS RT_LinkID, RT.LinkSourceName AS RT_LinkSourceName,
					RT.TxnDate, RT.AmountReceived TxnAmount
			FROM   -- LND_TBOS.TollPlus.TP_Trips TT
			      	LND_TBOS.TollPlus.TP_ViolatedTrips VT
					--ON VT.TPTripID = TT.TPTripID AND VT.CitationID = TT.LinkID AND TT.TripWith = 'V' AND TT.LND_UpdateType <> 'D' AND VT.LND_UpdateType <> 'D'
			JOIN	LND_TBOS.TollPlus.TP_Violated_Trip_Receipts_Tracker RT
					ON VT.CitationID = RT.CitationID AND RT.LND_UpdateType <> 'D'
			WHERE   RT.LinkSourceName IN ('FINANCE.PAYMENTTXNS','FINANCE.ADJUSTMENTS') /* exclude TOLLPLUS.TP_CUSTOMERTRIPS */					
					--AND VT.TpTripID=3909830376

		)
		--SELECT * FROM CTE_VT_Receipts_Tracker ORDER BY TPTripID, TxnDate
		, 	CTE_ALI AS
		(
			--:: Payment Txns
			SELECT	RT.*, CAST(NULL AS BIGINT) AdjustmentID, 
				    CAST(NULL AS BIGINT) AS ALI_LinkID, 
					CAST(NULL AS VARCHAR(50)) ALI_LinkSourceName, 
					CAST(1 AS SMALLINT) ALI_Seq
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
			SELECT	TpTripID,  CitationID, TollAmount, OutstandingAmount, PaymentStatusID,A.TripStatusID, TxnDate, TxnAmount, 
					CASE WHEN RT_LinkSourceName = 'FINANCE.PAYMENTTXNS' OR NOT (ALI_LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS' /*2539986413*/ AND ALI_LinkID = CitationID /*2530609156*/) THEN TxnAmount ELSE 0 END ActualPaidAmount,
					CASE WHEN ALI_LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS' AND ALI_LinkID = CitationID THEN TxnAmount ELSE 0 END AdjustedAmount,
					CASE WHEN RT_LinkSourceName = 'FINANCE.PAYMENTTXNS' THEN RT_LinkID END PaymentID,
					CASE WHEN RT_LinkSourceName = 'FINANCE.ADJUSTMENTS' THEN RT_LinkID END AdjustmentID,
					RT_LinkSourceName, ALI_LinkSourceName, ALI_LinkID,
					ROW_NUMBER() OVER (PARTITION BY CitationID ORDER BY TxnDate) TxnSeq, ALI_Seq,
					SUM(TxnAmount) OVER (PARTITION BY CitationID ORDER BY TxnDate) RunningTotalAmount
			FROM	CTE_ALI A
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
		--CTE_TxnAmounts AS(
		SELECT  VP.TpTripID, VP.CitationID,VP.TripStatusID,
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
		GROUP BY VP.TpTripID, VP.CitationID, VP.TollAmount, VP.OutstandingAmount, VP.PaymentStatusID ,VP.TripStatusID

		CREATE STATISTICS STATS_Stage_ViolTripPayment_001 ON Stage.ViolTripPayment(CitationID)
		CREATE STATISTICS STATS_Stage_ViolTripPayment_002 ON Stage.ViolTripPayment(TpTripID)

		---------------------------------------------------------------------------------------------------------------------
		-- load Stage.InvoicePayment_NEW - This is to sum up at Invoice level
		---------------------------------------------------------------------------------------------------------------------

		IF OBJECT_ID('Stage.InvoicePayment_NEW','U') IS NOT NULL DROP TABLE Stage.InvoicePayment_NEW
		CREATE TABLE Stage.InvoicePayment_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(invoicenumber))
		AS
					SELECT  CAST(A.referenceInvoiceID AS BIGINT) InvoiceNumber,							
							CAST(SUM(A.InvoiceAmount) AS DECIMAL(19,2)) InvoiceAmount,
							CAST(SUM(A.PBMTollAmount) AS DECIMAL(19,2)) PBMTollAmount,
							CAST(SUM(A.AVITollAmount) AS DECIMAL(19,2)) AVITollAmount,
							CAST(SUM(A.Tolls) AS DECIMAL(19,2)) Tolls,
							CAST(SUM(A.TollsPaid) AS DECIMAL(19,2)) TollsPaid,
							CAST(SUM(A.TollsAdjusted) AS DECIMAL(19,2)) TollsAdjusted,							
							CAST(MIN(A.FirstPaymentDate)AS DATE) FirstPaymentDate, 
							CAST(MAX(A.LastPaymentDate) AS DATE) LastPaymentDate,
							CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
							-- select *
					FROM 
						(
							SELECT IL.ReferenceInvoiceID,
								   vt.TpTripID,
							       VT.CitationID,
							       VT.TripStatusID,
							       VT.PaymentStatusID,
							       ExitTripDateTime,vt.StageModifiedDate,
							       VT.TollAmount,
							       AVITollAmount,
							       PBMTollAmount,
								   CASE WHEN  IL.CustTxnCategory IN ('TOLL','FEE' ) THEN IL.Amount ELSE  0 END  InvoiceAmount,
								   CASE WHEN  IL.LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS' THEN IL.Amount ELSE  0 END  Tolls,
								   ISNULL(T.ActualPaidAmount,0) TollsPaid,
								   ISNULL(T.AdjustedAmount*-1,0) TollsAdjusted,
								   
									MIN(CASE WHEN T.ActualPaidAmount>0 THEN T.FirstPaidDate END) FirstPaymentDate, 
									MAX(CASE WHEN T.ActualPaidAmount>0 THEN T.Lastpaiddate END) LastPaymentDate,
							       ROW_NUMBER() OVER (PARTITION BY vt.TpTripID,IL.ReferenceInvoiceID
							                          ORDER BY vt.CitationID DESC,
							                                   vt.ExitTripDateTime DESC
							                         )    RN			--select *
							FROM LND_TBOS.TollPlus.Invoice_LineItems IL
							    JOIN LND_TBOS.TollPlus.TP_ViolatedTrips vt
							        ON IL.LinkID = vt.CitationID
							           AND IL.CustTxnCategory = 'TOLL'
								LEFT JOIN Stage.ViolTripPayment T ON VT.CitationID=T.CitationID
							--WHERE vt.TpTripID = 3432483382
							--WHERE vt.TpTripID IN (3968522557,3968531731,3969234413,3969252534)
							--WHERE IL.ReferenceInvoiceID IN (1237141486,1236141325,1237171775,1237206818,1237070055,1230776160,1227662935,1225424611,1232976582,1223907444,1227352365,1234364963)
							--WHERE IL.ReferenceInvoiceID IN (1240068046)
							
							GROUP BY CASE
                                     WHEN IL.CustTxnCategory IN ( 'TOLL', 'FEE' ) THEN
                                     IL.Amount
                                     ELSE
                                     0
                                     END,
                                     CASE
                                     WHEN IL.LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS' THEN
                                     IL.Amount
                                     ELSE
                                     0
                                     END,
                                     ISNULL(T.ActualPaidAmount, 0),
                                     ISNULL(T.AdjustedAmount * -1, 0),
                                     IL.ReferenceInvoiceID,
                                     vt.TpTripID,
                                     vt.CitationID,
                                     vt.TripStatusID,
                                     vt.PaymentStatusID,
                                     vt.ExitTripDateTime,
                                     vt.StageModifiedDate,
                                     vt.TollAmount,
                                     vt.AVITollAmount,
                                     vt.PBMTollAmount
						)A WHERE A.RN=1
					GROUP BY A.ReferenceInvoiceID

		SET  @Log_Message = 'Loaded Stage.InvoicePayment_New' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Create Statistics

		CREATE STATISTICS STATS_Stage_InvoicePayment_001 ON Stage.InvoicePayment_NEW (InvoiceNumber)
		EXEC Utility.TableSwap 'Stage.InvoicePayment_NEW','Stage.InvoicePayment'
		
		
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date,'Completed full load', 'I',NULL,NULL;

		-- Show results
		IF @Trace_Flag = 1  EXEC Utility.FromLog @Log_Source, @Log_Start_Date;
		IF @Trace_Flag = 1  SELECT TOP 1000 'Stage.InvoicePayment ' TableName, * FROM Stage.NonMigratedInvoice   ORDER BY 2 DESC;
	
	END	TRY
	
	BEGIN CATCH
	
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH;

END


		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
