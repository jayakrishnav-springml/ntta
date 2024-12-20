CREATE PROC [dbo].[Fact_PaymentDetail_Full_Load] AS
/*
GO
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_PaymentDetail_Full_Load table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838 	Bhanu	2020-10-21	New!
				1. PMTLI.CustomerID,--Removed By Bhanu to fix Duplicate Issue because if a Payment ID has multiple 
				   customers then Amount Received is Multiplied example Payment ID: 113812182
				2. Cannot Bring OverPayments because they are not reverted back to customer instead they are stores
				   in Customer Account. So, Customer Payment Table will/should have these records
CHG0037897 	Bhanu	2021-01-13
				1. Cannot Bring Postpaid Fleet OverPayments because they are not reverted back to customer instead 
				   they are stored in Customer Account. So, Customer Payment Table will/should have these records
				2. Added Left join for Reversals/VOID to all 3(TXN/FEE/Fleet Payments) tables and added RefPaymentStatusID 
				   to make sure MSTR query picks up the proper buckets.

CHG0038039	Gouthami  2021-01-27 Added DeleteFlag
CHG0038359	Bhanu	  2021-03-15 Added OverPaymentID, Receipttracker.txndate to Fact_PaymentDetail for MSTR to show
								 only the data with OverpaymentId=0
CHG0038749	Gouthami  2021-04-27 Added POSID
CHG0042740	Gouthami  2022-03-23 Removed A.LND_UpdateType from Stage.TransactionPayment as this is causing double 
								 payments


-------------------------------------------------------------------------------------------------------------------
Run script:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_PaymentDetail_Full_Load
EXEC Utility.FromLog 'dbo.Fact_PaymentDetail_Full_Load', 1

SELECT TOP 1000 'Stage.TransactionPayment' TableName, * FROM Stage.TransactionPayment ORDER BY 2 DESC 
SELECT TOP 1000 'Stage.InvoicedFeePayment' TableName, * FROM Stage.InvoicedFeePayment ORDER BY 2 DESC 
SELECT TOP 1000 'Stage.PostpaidFleetPayment' TableName, * FROM Stage.PostpaidFleetPayment ORDER BY 2 DESC 
SELECT TOP 1000 'dbo.Fact_PaymentDetail' TableName, * FROM Fact_PaymentDetail ORDER BY 2 DESC 

###################################################################################################################
*/

BEGIN 

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_PaymentDetail_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load of Fact tables', 'I', '-1', NULL

		--=============================================================================================================
		-- Load Stage.TransactionPayment         --TXN Payments
		--=============================================================================================================

		IF OBJECT_ID('Stage.TransactionPayment') IS NOT NULL DROP TABLE Stage.TransactionPayment
		CREATE TABLE Stage.TransactionPayment WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CitationID),  PARTITION (PaymentDayId RANGE RIGHT FOR VALUES (20110101, 20120101, 20130101, 20140101, 20150101, 20150201, 20150301, 20150401, 20150501, 20150601, 20150701, 20150801, 20150901, 20151001, 20151101, 20151201, 20160101, 20160201, 20160301, 20160401, 20160501, 20160601, 20160701, 20160801, 20160901, 20161001, 20161101, 20161201, 20170101, 20170201, 20170301, 20170401, 20170501, 20170601, 20170701, 20170801, 20170901, 20171001, 20171101, 20171201, 20180101, 20180201, 20180301, 20180401, 20180501, 20180601, 20180701, 20180801, 20180901, 20181001, 20181101, 20181201, 20190101, 20190201, 20190301, 20190401, 20190501, 20190601, 20190701, 20190801, 20190901, 20191001, 20191101, 20191201, 20200101, 20200201, 20200301, 20200401, 20200501, 20200601, 20200701, 20200801, 20200901, 20201001, 20201101)))
		AS
		SELECT ISNULL(CAST(ReferenceInvoiceID AS BIGINT), -1) InvoiceNumber,
				VTRT.InvoiceID,
				VTRT.CitationID,
				PMTIDPMTS.PaymentID,
				VTRT.OverPaymentID,
				C.CustomerID,
				C.CustomerStatusID,
				C.UserTypeID,
				CPL.PlanID,
				CAST(CONVERT(VARCHAR, PMTIDPMTS.PaymentDate, 112) AS INT) PaymentDayID,
				VTRT.TxnDate TxnPaymentDate,
				PMTIDPMTS.PaymentModeID,
				--PMTIDPMTS.ActivityType,
				PMTIDPMTS.PaymentStatusID,
				PMTIDPMTS.RefPaymentID,
				PMTIDPMTS.RefPaymentStatusID,
				PMTIDPMTS.VoucherNo,
				PMTIDPMTS.RefType,
				PMTIDPMTS.AccountStatusID,
				PMTIDPMTS.ChannelID,
				PMTIDPMTS.LocationID,
				PMTIDPMTS.IcnID,
				PMTIDPMTS.IsvirtualCheck,
				PMTIDPMTS.PmtTxnType,
				PMTIDPMTS.SubSystemID,
				PMTIDPMTS.AppTxnTypeID,
				PMTIDPMTS.ApprovedBy,
				PMTIDPMTS.Reasontext,
				PMTIDPMTS.TxnAmount,
				PMTIDPMTS.LineItemAmount / PMTIDPMTS.PaidTxnCnt LineItemAmount,
				VTRT.AmountReceived,
				CAST(CASE WHEN PMTIDPMTS.DeleteFlag = 1 OR VTRT.LND_UpdateType = 'D' OR Invoice_LineItems.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT) DeleteFlag

		FROM
				(
					SELECT PTXN.PaymentID,
							--PMTLI.CustomerID,-----Removed By Bhanu to fix Duplicate Issue because if a Payment ID has multiple customers then Amount Received is Multiplied example Payment ID: 113812182
							PTXN.PaymentDate,
							PTXN.VoucherNo,
							PTXN.PaymentModeID,
							PTXN.ActivityType,
							PTXN.PaymentStatusID,
							REF.RefPaymentStatusID,
							PTXN.RefPaymentID,
							PTXN.RefType,
							PTXN.AccountStatusID,
							PTXN.ApprovedBy,
							PTXN.ChannelID,
							PTXN.LocationID,
							PTXN.Reasontext,
							PTXN.ICNID IcnID,
							PTXN.IsvirtualCheck,
							PTXN.PmtTxnType,
							SUB.SubSystemID,
							AppTxn.AppTxnTypeID,
							PTXN.TxnAmount TxnAmount,
							SUM(PMTLI.LineItemAmount) LineItemAmount,
							A.TxnCnt PaidTxnCnt, 
							CAST(CASE WHEN PMTLI.LND_UpdateType = 'D' OR PTXN.LND_UpdateType = 'D' OR REF.LND_UpdateType = 'D'  THEN 1 ELSE 0 END AS BIT) DeleteFlag
					FROM  LND_TBOS.Finance.PaymentTxn_LineItems PMTLI
						JOIN
						(
							SELECT LinkID PaymentID,
									--LND_UpdateType, -- Remove to avoid double counting
									COUNT(DISTINCT CitationID) TxnCnt
							FROM LND_TBOS.TollPlus.TP_Violated_Trip_Receipts_Tracker
							WHERE TP_Violated_Trip_Receipts_Tracker.LinkSourceName = 'Finance.PaymentTxns'
							AND LND_UpdateType <> 'D'
							GROUP BY LinkID --, LND_UpdateType -- Remove to avoid double counting
						) A
							ON A.PaymentID = PMTLI.PaymentID
							AND PMTLI.LND_UpdateType <> 'D'
						JOIN LND_TBOS.Finance.PaymentTxns PTXN
							ON PTXN.PaymentID = PMTLI.PaymentID
							AND PTXN.LND_UpdateType <> 'D'
						JOIN LND_TBOS.TollPlus.SubSystems SUB
							ON SUB.SubSystemCode = PTXN.SubSystem
						JOIN LND_TBOS.TollPlus.AppTxnTypes AppTxn
							ON AppTxn.AppTxnTypeCode = PMTLI.AppTxnTypeCode
							AND AppTxn.AppTxnTypeID NOT IN (2541,2627,2540,2628,2539,2646,2647,2626) ----Cannot Bring Zipcash OverPayments because they are not reverted back to customer instead they are stores in Customer Account. So, Customer Payment Table will/should have these records
					LEFT JOIN (SELECT ORIG_PMT.PaymentID, ORIG_PMT.PaymentStatusID RefPaymentStatusID, ORIG_PMT.LND_UpdateType
									FROM LND_TBOS.Finance.PaymentTxns ORIG_PMT
									JOIN
										 (
											SELECT RefPaymentID
											FROM LND_TBOS.Finance.PaymentTxns
											WHERE RefPaymentID > 0
											AND PaymentStatusID = 109
											AND LND_UpdateType <> 'D'
										  ) REF_PMT ON REF_PMT.RefPaymentID = ORIG_PMT.PaymentID AND ORIG_PMT.LND_UpdateType <> 'D') REF 
					ON PTXN.RefPaymentID = REF.PaymentID
					GROUP BY PTXN.PaymentID,
								--PMTLI.CustomerID,-----Removed By Bhanu to fix Duplicate Issue because if a Payment ID has multiple customers then Amount Received is Multiplied example Payment ID: 113812182
								PTXN.PaymentDate,
								PTXN.VoucherNo,
								PTXN.PaymentModeID,
								PTXN.ActivityType,
								PTXN.PaymentStatusID,
								REF.RefPaymentStatusID,
								PTXN.RefPaymentID,
								PTXN.RefType,
								PTXN.AccountStatusID,
								PTXN.ApprovedBy,
								PTXN.ChannelID,
								PTXN.LocationID,
								PTXN.Reasontext,
								PTXN.ICNID,
								PTXN.IsvirtualCheck,
								PTXN.PmtTxnType,
								SUB.SubSystemID,
								A.TxnCnt,
								PTXN.TxnAmount,
								AppTxn.AppTxnTypeID,
								CAST(CASE WHEN PMTLI.LND_UpdateType = 'D'  OR PTXN.LND_UpdateType = 'D' OR REF.LND_UpdateType = 'D'  THEN 1 ELSE 0 END AS BIT)
				) PMTIDPMTS
					JOIN LND_TBOS.TollPlus.TP_Violated_Trip_Receipts_Tracker VTRT
						ON VTRT.LinkID = PMTIDPMTS.PaymentID
							AND VTRT.LinkSourceName = 'FINANCE.PAYMENTTXNS'
							AND VTRT.LND_UpdateType <> 'D'
					JOIN LND_TBOS.TollPlus.TP_Customers C
						ON C.CustomerID = VTRT.ViolatorID----PMTIDPMTS.CustomerID-----Removed By Bhanu to fix Duplicate Issue because if a Payment ID has multiple customers then Amount Received is Multiplied example Payment ID :113812182
					JOIN LND_TBOS.TollPlus.TP_Customer_Plans CPL
						ON C.CustomerID = CPL.CustomerID
					JOIN LND_TBOS.TollPlus.Plans
						ON Plans.PlanID = CPL.PlanID
					LEFT JOIN ( SELECT ROW_NUMBER() OVER (PARTITION BY LinkID  ORDER BY CAST(ReferenceInvoiceID AS BIGINT) DESC) AS RN, *
								FROM LND_TBOS.TollPlus.Invoice_LineItems WHERE CustTxnCategory = 'TOLL' AND LND_UpdateType <> 'D'
								) Invoice_LineItems
						ON Invoice_LineItems.LinkID = VTRT.CitationID
							AND RN = 1
				
		OPTION (LABEL = 'Stage.TransactionPayment Load');
	
		-- Log 
		SET  @Log_Message = 'Loaded Stage.TransactionPayment'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, '-1', -1, 'I'
		
		-- Create statistics and swap table
		CREATE STATISTICS STATS_Stage_TransactionPayment_000 ON Stage.TransactionPayment (InvoiceNumber);
		CREATE STATISTICS STATS_Stage_TransactionPayment_001 ON Stage.TransactionPayment (InvoiceID);
		CREATE STATISTICS STATS_Stage_TransactionPayment_002 ON Stage.TransactionPayment (PaymentID);
		CREATE STATISTICS STATS_Stage_TransactionPayment_003 ON Stage.TransactionPayment (PaymentDayID);
		CREATE STATISTICS STATS_Stage_TransactionPayment_004 ON Stage.TransactionPayment (OverPaymentID);


		IF @Trace_Flag = 1 SELECT TOP 100 'Stage.TransactionPayment' TableName, * FROM Stage.TransactionPayment ORDER BY 2 DESC
		--SELECT * FROM stage.InvoicedFeePayment WHERE InvoiceNumber=1226895319 ORDER BY CitationID
		--=============================================================================================================
		-- Load Stage.InvoicedFeePayment	->	 Invoice Fee Payments
		--=============================================================================================================
		IF OBJECT_ID('Stage.InvoicedFeePayment') IS NOT NULL DROP TABLE Stage.InvoicedFeePayment
		CREATE TABLE Stage.InvoicedFeePayment WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CitationID),  PARTITION (PaymentDayId RANGE RIGHT FOR VALUES (20110101, 20120101, 20130101, 20140101, 20150101, 20150201, 20150301, 20150401, 20150501, 20150601, 20150701, 20150801, 20150901, 20151001, 20151101, 20151201, 20160101, 20160201, 20160301, 20160401, 20160501, 20160601, 20160701, 20160801, 20160901, 20161001, 20161101, 20161201, 20170101, 20170201, 20170301, 20170401, 20170501, 20170601, 20170701, 20170801, 20170901, 20171001, 20171101, 20171201, 20180101, 20180201, 20180301, 20180401, 20180501, 20180601, 20180701, 20180801, 20180901, 20181001, 20181101, 20181201, 20190101, 20190201, 20190301, 20190401, 20190501, 20190601, 20190701, 20190801, 20190901, 20191001, 20191101, 20191201, 20200101, 20200201, 20200301, 20200401, 20200501, 20200601, 20200701, 20200801, 20200901, 20201001, 20201101)))
			AS
			SELECT ISNULL(CAST(IH.InvoiceNumber AS BIGINT), -1) InvoiceNumber,
			       IRCT.InvoiceID,
			       ICT.InvoiceChargeID,
			       Invoice_LineItems.LinkID CitationID,
			       PTXN.PaymentID,
				   IRCT.OverPaymentID,
			       PMTLI.CustomerID,
			       C.CustomerStatusID,
			       C.UserTypeID,
			       CPL.PlanID,
			       CAST(CONVERT(VARCHAR, PTXN.PaymentDate, 112) AS INT) PaymentDayID,
				   IRCT.TxnDate TxnPaymentDate,
			       PTXN.PaymentModeID,
			       PTXN.PaymentStatusID,
				   REF.RefPaymentStatusID,
			       PTXN.RefPaymentID,
			       PTXN.VoucherNo,
			       PTXN.RefType,
			       PTXN.AccountStatusID,
			       PTXN.ChannelID,
			       PTXN.LocationID,
			       PTXN.ICNID,
			       PTXN.IsvirtualCheck,
			       PTXN.PmtTxnType,
			       SUB.SubSystemID,
			       AppTxn.AppTxnTypeID,
			       PTXN.ApprovedBy,
			       PTXN.Reasontext,
			       PTXN.TxnAmount,
			       PMTLI.LineItemAmount,
			       0. AmountReceived,
			       CASE
			           WHEN ICT.FeeCode = 'FSTNTVFEE' THEN
			               IRCT.AmountReceived
			           ELSE
			               0
			       END/A.TxnCnt AS FNFeesPaid,
			       CASE
			           WHEN ICT.FeeCode = 'SECNTVFEE' THEN
			               IRCT.AmountReceived
			           ELSE
			               0
			       END/A.TxnCnt AS SNFeesPaid,
				   CAST(CASE WHEN PTXN.LND_UpdateType = 'D' OR PMTLI.LND_UpdateType = 'D' OR IRCT.LND_UpdateType = 'D' OR ICT.LND_UpdateType = 'D'  OR REF.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT) DeleteFlag -- select *
			FROM LND_TBOS.Finance.PaymentTxns PTXN
			    INNER JOIN  LND_TBOS.Finance.PaymentTxn_LineItems PMTLI
			        ON PMTLI.PaymentID = PTXN.PaymentID AND PTXN.LND_UpdateType <> 'D' AND PMTLI.LND_UpdateType <> 'D'
			    INNER JOIN LND_TBOS.TollPlus.TP_Customers C
			        ON PMTLI.CustomerID = C.CustomerID
			    INNER JOIN LND_TBOS.TollPlus.Channels CN
			        ON PTXN.ChannelID = CN.ChannelID
			    INNER JOIN LND_TBOS.TollPlus.TP_Invoice_Receipts_Tracker IRCT
			        ON IRCT.LInkID = PTXN.PaymentID
			           AND IRCT.InvoiceID = PMTLI.LinkID
			           AND IRCT.LInkSourceName = 'FINANCE.PAYMENTTXNS'
			           AND PMTLI.LinkSourceName = 'TOLLPLUS.INVOICE_HEADER'
					   AND IRCT.LND_UpdateType <> 'D'
			    INNER JOIN LND_TBOS.TollPlus.Invoice_Charges_Tracker ICT
			        ON ICT.InvoiceChargeID = IRCT.Invoice_ChargeID AND ICT.LND_UpdateType <> 'D'
			    JOIN LND_TBOS.TollPlus.SubSystems SUB
			        ON SUB.SubSystemCode = PTXN.SubSystem
			    JOIN LND_TBOS.TollPlus.AppTxnTypes AppTxn
			        ON AppTxn.AppTxnTypeCode = PMTLI.AppTxnTypeCode
			    JOIN
			    (
			        SELECT DISTINCT
			               InvoiceNumber,
			               Invoice_Header.InvoiceID
						-- ,TP_Invoice_Receipts_Tracker.LND_UpdateType -- Removed this to avoid doubling	
			        FROM LND_TBOS.TollPlus.Invoice_Header
			            JOIN LND_TBOS.TollPlus.TP_Invoice_Receipts_Tracker
			                ON TP_Invoice_Receipts_Tracker.InvoiceID = Invoice_Header.InvoiceID
							AND TP_Invoice_Receipts_Tracker.LND_UpdateType <> 'D'
					--WHERE InvoiceNumber=1226895319
			    ) IH
			        ON IRCT.InvoiceID = IH.InvoiceID
			    JOIN LND_TBOS.TollPlus.TP_Customer_Plans CPL
			        ON C.CustomerID = CPL.CustomerID
			    JOIN LND_TBOS.TollPlus.Plans
			        ON Plans.PlanID = CPL.PlanID 
			    JOIN
			    (
			        SELECT ReferenceInvoiceID InvoiceNumber,
			               COUNT(DISTINCT LinkID) TxnCnt
						   --LND_UpdateType --Removed this to avoid doubling	
			        FROM LND_TBOS.TollPlus.Invoice_LineItems
			        WHERE CustTxnCategory = 'TOLL'
					AND LinkID > 0-----This is to avoid duplicate count of Unassigned TXNs
					AND LND_UpdateType<>'D'
			        GROUP BY ReferenceInvoiceID
			    ) A
			        ON A.InvoiceNumber = IH.InvoiceNumber
			JOIN (            SELECT ROW_NUMBER() OVER (PARTITION BY LinkID
			                                      ORDER BY CAST(ReferenceInvoiceID AS BIGINT) DESC
			                                     ) AS RN,
			                   *
			            FROM LND_TBOS.TollPlus.Invoice_LineItems WHERE CustTxnCategory = 'TOLL' AND LinkID > 0-----This is to avoid duplicate count of Unassigned TXNs
						--AND ReferenceInvoiceID=1226895319
			) Invoice_LineItems
			        ON Invoice_LineItems.ReferenceInvoiceID = IH.InvoiceNumber
			LEFT JOIN (SELECT ORIG_PMT.PaymentID, ORIG_PMT.PaymentStatusID RefPaymentStatusID,ORIG_PMT.LND_UpdateType
									FROM LND_TBOS.Finance.PaymentTxns ORIG_PMT
									JOIN
										 (
											SELECT RefPaymentID
											FROM LND_TBOS.Finance.PaymentTxns
											WHERE RefPaymentID > 0
											AND PaymentStatusID = 109
											AND LND_UpdateType <> 'D'
											--AND RefPaymentID=181058859
										  ) REF_PMT ON REF_PMT.RefPaymentID = ORIG_PMT.PaymentID AND ORIG_PMT.LND_UpdateType <> 'D') REF 
					ON PTXN.RefPaymentID = REF.PaymentID

		--WHERE ISNULL(CAST(IH.InvoiceNumber AS BIGINT), -1)=1226895319 AND PTXN.PaymentID=181058859 AND Invoice_LineItems.LinkID=2044144627
		OPTION (LABEL = 'Stage.InvoicedFeePayment Load');

		-- Log 
		SET  @Log_Message = 'Loaded Stage.InvoicedFeePayment'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', '-1', -1

		-- Create statistics and swap table
		CREATE STATISTICS STATS_Stage_InvoicedFeePayment_000 ON Stage.InvoicedFeePayment (InvoiceNumber);
		CREATE STATISTICS STATS_Stage_InvoicedFeePayment_001 ON Stage.InvoicedFeePayment (InvoiceID);
		CREATE STATISTICS STATS_Stage_InvoicedFeePayment_002 ON Stage.InvoicedFeePayment (PaymentID); 
		CREATE STATISTICS STATS_Stage_InvoicedFeePayment_003 ON Stage.InvoicedFeePayment (PaymentDayID);
		CREATE STATISTICS STATS_Stage_InvoicedFeePayment_004 ON Stage.InvoicedFeePayment (CitationID);
		CREATE STATISTICS STATS_Stage_InvoicedFeePayment_005 ON Stage.InvoicedFeePayment (OverPaymentID);


		IF @Trace_Flag = 1 SELECT TOP 100 'Stage.InvoicedFeePayment' TableName, * FROM Stage.InvoicedFeePayment ORDER BY 2 DESC

		--=============================================================================================================
		-- Load Stage.PostpaidFleetPayment		->	 PostPaid Fleet Payments
		--=============================================================================================================

		IF OBJECT_ID('Stage.PostpaidFleetPayment') IS NOT NULL DROP TABLE Stage.PostpaidFleetPayment

		CREATE TABLE Stage.PostpaidFleetPayment WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CustTripID),  PARTITION (PaymentDayId RANGE RIGHT FOR VALUES (20110101, 20120101, 20130101, 20140101, 20150101, 20150201, 20150301, 20150401, 20150501, 20150601, 20150701, 20150801, 20150901, 20151001, 20151101, 20151201, 20160101, 20160201, 20160301, 20160401, 20160501, 20160601, 20160701, 20160801, 20160901, 20161001, 20161101, 20161201, 20170101, 20170201, 20170301, 20170401, 20170501, 20170601, 20170701, 20170801, 20170901, 20171001, 20171101, 20171201, 20180101, 20180201, 20180301, 20180401, 20180501, 20180601, 20180701, 20180801, 20180901, 20181001, 20181101, 20181201, 20190101, 20190201, 20190301, 20190401, 20190501, 20190601, 20190701, 20190801, 20190901, 20191001, 20191101, 20191201, 20200101, 20200201, 20200301, 20200401, 20200501, 20200601, 20200701, 20200801, 20200901, 20201001, 20201101)))
		AS
		SELECT ISNULL(CAST(INVOICE.InvoiceNumber AS BIGINT), -1) InvoiceNumber,
			   CT.CustTripID,
		       PMLI.CustomerID,
		       CustomerStatusID,
		       UserTypeID,
		       CP.PlanID,
		       CAST(CONVERT(VARCHAR, PMTXN.PaymentDate, 112) AS INT) PaymentDayID,
			   CT.TxnDate TxnPaymentDate,
		       ISNULL(CT.InvoiceID, 0) InvoiceID,
		       PMTXN.AccountStatusID,
		       ISNULL(AppTxn.AppTxnTypeID, -1) AppTxnTypeID,
		       PMTXN.VoucherNo,
		       Sub.SubSystemID,
		       PMTXN.PaymentModeID,
		       PMTXN.PaymentStatusID,
			   REF.RefPaymentStatusID,
		       PMTXN.PaymentID,
			   CT.OverPaymentID,
		       PMTXN.RefPaymentID,
		       ISNULL(PMTXN.IsvirtualCheck, -1) IsvirtualCheck,
		       ISNULL(PMTXN.ChannelID, -1) ChannelID,
		       ISNULL(PMTXN.ICNID, -1) IcnID,
		       ISNULL(PMTXN.LocationID, -1) LocationID,
		       ISNULL(PMTXN.RefType, '-1') RefType,
		       ISNULL(PMTXN.Reasontext, '-1') Reasontext,
		       --PMTXN.ActivityType,
		       ISNULL(PMTXN.ApprovedBy, '-1') ApprovedBy,
		       ISNULL(PMTXN.PmtTxnType, '-1') PmtTxnType,
		       ISNULL(CT.AmountReceived, 0) AmountReceived,
		       PMTXN.TxnAmount,
		       PMLI.LineItemAmount,
		       0 FNFeesPaid,
		       0 SNFeesPaid,
			   CAST(CASE WHEN CT.LND_UpdateType = 'D' OR PMTXN.LND_UpdateType = 'D' OR PMLI.LND_UpdateType = 'D' OR INVOICE.LND_UpdateType = 'D' OR REF.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT) DeleteFlag
			   ---select COUNT(*)
		FROM LND_TBOS.TollPlus.TP_Customer_Trip_Receipts_Tracker CT
		    JOIN LND_TBOS.Finance.PaymentTxns PMTXN
		        ON CT.LinkID = PMTXN.PaymentID
	           AND CT.LinkSourceName = 'FINANCE.PAYMENTTXNS'	
			   AND PMTXN.LND_UpdateType <> 'D'
		    JOIN LND_TBOS.Finance.PaymentTxn_LineItems PMLI
		        ON CT.LinkID = PMLI.PaymentID AND PMLI.LND_UpdateType <> 'D'
		    JOIN LND_TBOS.TollPlus.AppTxnTypes AppTxn
		        ON PMLI.AppTxnTypeCode = AppTxn.AppTxnTypeCode
				AND AppTxn.AppTxnTypeID NOT IN (2541,2627,2540,2628,2539,2646,2647,2626) ----Cannot Bring Postpaid Fleet OverPayments because they are not reverted back to customer instead they are stores in Customer Account. So, Customer Payment Table will/should have these records
		    JOIN LND_TBOS.TollPlus.SubSystems Sub
		        ON PMTXN.SubSystem = Sub.SubSystemName
		    JOIN LND_TBOS.TollPlus.TP_Customers C
		        ON C.CustomerID = CT.CustomerID
		           AND C.UserTypeID IN ( 2, 3 )
		    JOIN LND_TBOS.TollPlus.TP_Customer_Plans CP
		        ON C.CustomerID = CP.CustomerID
		    JOIN LND_TBOS.TollPlus.Plans
		        ON Plans.PlanID = CP.PlanID
		           AND PlanName = 'Postpaid'
		    LEFT JOIN
		    (
		        SELECT DISTINCT
		               InvoiceNumber,
		               InvoiceID,
					   LND_UpdateType
		        FROM LND_TBOS.TollPlus.Invoice_Header
		    ) INVOICE
		        ON INVOICE.InvoiceID = CT.InvoiceID
	LEFT JOIN (SELECT ORIG_PMT.PaymentID, ORIG_PMT.PaymentStatusID RefPaymentStatusID,ORIG_PMT.LND_UpdateType
				FROM LND_TBOS.Finance.PaymentTxns ORIG_PMT
				JOIN
					 (
						SELECT RefPaymentID
						FROM LND_TBOS.Finance.PaymentTxns
						WHERE RefPaymentID > 0
						AND PaymentStatusID = 109
						
					  ) REF_PMT ON REF_PMT.RefPaymentID = ORIG_PMT.PaymentID AND ORIG_PMT.LND_UpdateType <> 'D') REF 
		ON PMTXN.RefPaymentID = REF.PaymentID
		OPTION (LABEL = 'Stage.PostpaidFleetPayment Load');
		
		-- Log
		SET  @Log_Message = 'Loaded Stage.PostpaidFleetPayment'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', '-1', -1

		-- Create statistics and swap table
		CREATE STATISTICS STATS_Stage_PostpaidFleetPayment_000 ON Stage.PostpaidFleetPayment (InvoiceNumber);
		CREATE STATISTICS STATS_Stage_PostpaidFleetPayment_001 ON Stage.PostpaidFleetPayment (InvoiceID);
		CREATE STATISTICS STATS_Stage_PostpaidFleetPayment_002 ON Stage.PostpaidFleetPayment (PaymentID);
		CREATE STATISTICS STATS_Stage_PostpaidFleetPayment_003 ON Stage.PostpaidFleetPayment (PaymentDayID);
		CREATE STATISTICS STATS_Stage_PostpaidFleetPayment_004 ON Stage.PostpaidFleetPayment (OverPaymentID);


		IF @Trace_Flag = 1 SELECT TOP 100 'Stage.PostpaidFleetPayment' TableName, * FROM Stage.PostpaidFleetPayment ORDER BY 2 DESC

		--=============================================================================================================
		-- Load dbo.Fact_PaymentDetail						   
		--=============================================================================================================
		IF OBJECT_ID('dbo.Fact_PaymentDetail_NEW') IS NOT NULL DROP TABLE dbo.Fact_PaymentDetail_NEW
		CREATE TABLE dbo.Fact_PaymentDetail_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TpTripID),  PARTITION (PaymentDayId RANGE RIGHT FOR VALUES (20110101, 20120101, 20130101, 20140101, 20150101, 20150201, 20150301, 20150401, 20150501, 20150601, 20150701, 20150801, 20150901, 20151001, 20151101, 20151201, 20160101, 20160201, 20160301, 20160401, 20160501, 20160601, 20160701, 20160801, 20160901, 20161001, 20161101, 20161201, 20170101, 20170201, 20170301, 20170401, 20170501, 20170601, 20170701, 20170801, 20170901, 20171001, 20171101, 20171201, 20180101, 20180201, 20180301, 20180401, 20180501, 20180601, 20180701, 20180801, 20180901, 20181001, 20181101, 20181201, 20190101, 20190201, 20190301, 20190401, 20190501, 20190601, 20190701, 20190801, 20190901, 20191001, 20191101, 20191201, 20200101, 20200201, 20200301, 20200401, 20200501, 20200601, 20200701, 20200801, 20200901, 20201001, 20201101)))
		AS
		SELECT	   IUF.InvoiceNumber,
				   IUF.InvoiceID,
				   IUF.TpTripID,
				   IUF.CitationID,
				   IUF.PaymentID,
				   IUF.OverPaymentID,
				   IUF.PaymentDayID,
				   IUF.PaymentModeID,
				   IUF.PaymentStatusID,
				   IUF.RefPaymentStatusID,
				   IUF.AppTxnTypeID,
				   IUF.LaneID,
				   IUF.CustomerID,
				   IUF.CustomerStatusID,
				   IUF.UserTypeID AS AccountTypeID,
				   IUF.AccountStatusID,
				   IUF.PlanID,
				   IUF.RefPaymentID,
				   IUF.VoucherNo,
				   IUF.ChannelID,
				   ISNULL(IUF.locationId,-1) AS POSID,
				   IUF.ICNID,
				   IUF.IsvirtualCheck,
				   IUF.PmtTxnType,
				   IUF.SubSystemID,
				   IUF.TxnPaymentDate,
				   IUF.ApprovedBy,
				   IUF.Reasontext,
				   IUF.TxnAmount,
				   SUM(IUF.LineItemAmount) LineItemAmount,
				   SUM(IUF.AmountReceived)*-1 AmountReceived,
				   SUM(IUF.FNFeesPaid)*-1 FNFeesPaid,
				   SUM(IUF.SNFeesPaid)*-1 SNFeesPaid,
				   IUF.DeleteFlag,
				   ISNULL(CAST(SYSDATETIME() AS DATETIME2(3)), '1900-01-01') AS EDW_Update_Date

			FROM 
			(
			SELECT InvoiceNumber,
				   InvoiceID,
				   TpTripID,
				   TransactionPayment.CitationID,
				   ExitLaneID LaneID,
				   PaymentID,
				   OverPaymentID,
				   CustomerID,
				   CustomerStatusID,
				   UserTypeID,
				   PlanID,
				   PaymentDayID,
				   PaymentModeID,
				   TransactionPayment.PaymentStatusID,
				   RefPaymentStatusID,
				   RefPaymentID,
				   VoucherNo,
				   RefType,
				   AccountStatusID,
				   ChannelID,
				   TransactionPayment.LocationID,
				   IcnID,
				   IsvirtualCheck,
				   PmtTxnType,
				   SubSystemID,
				   AppTxnTypeID,
				   TxnPaymentDate,
				   ApprovedBy,
				   Reasontext,
				   TxnAmount,
				   LineItemAmount,
				   AmountReceived,
				   0 FNFeesPaid,
				   0 SNFeesPaid,
				   ISNULL(CAST(DeleteFlag AS BIT),0) AS DeleteFlag
			FROM Stage.TransactionPayment
			LEFT JOIN LND_TBOS.TollPlus.TP_ViolatedTrips ON TP_ViolatedTrips.CitationID = Stage.TransactionPayment.CitationID			
			
			UNION ALL
			
			SELECT InvoiceNumber,
				   InvoiceID,
				   TpTripID,
				   InvoicedFeePayment.CitationID,
				   ExitLaneID LaneID,
				   PaymentID,
				   OverPaymentID,
				   CustomerID,
				   CustomerStatusID,
				   UserTypeID,
				   PlanID,
				   PaymentDayID,
				   PaymentModeID,
				   InvoicedFeePayment.PaymentStatusID,
				   RefPaymentStatusID,
				   RefPaymentID,
				   VoucherNo,
				   RefType,
				   AccountStatusID,
				   ChannelID,
				   InvoicedFeePayment.LocationID,
				   IcnID,
				   IsvirtualCheck,
				   PmtTxnType,
				   SubSystemID,
				   AppTxnTypeID,
				   TxnPaymentDate,
				   ApprovedBy,
				   Reasontext,
				   TxnAmount,
				   LineItemAmount,
				   AmountReceived,
				   FNFeesPaid,
				   SNFeesPaid,
				   ISNULL(CAST(DeleteFlag AS BIT),0) AS DeleteFlag
			FROM Stage.InvoicedFeePayment
			LEFT JOIN LND_TBOS.TollPlus.TP_ViolatedTrips ON TP_ViolatedTrips.CitationID = Stage.InvoicedFeePayment.CitationID

			UNION ALL
			
			SELECT InvoiceNumber,
				   InvoiceID,
				   TpTripID,
				   PostpaidFleetPayment.CustTripID,
				   ExitLaneID LaneID,
				   PaymentID,
				   OverPaymentID,
				   PostpaidFleetPayment.CustomerID,
				   CustomerStatusID,
				   UserTypeID,
				   PlanID,
				   PaymentDayID,
				   PaymentModeID,
				   PostpaidFleetPayment.PaymentStatusID,
				   RefPaymentStatusID,
				   RefPaymentID,
				   VoucherNo,
				   RefType,
				   AccountStatusID,
				   ChannelID,
				   PostpaidFleetPayment.LocationID,
				   IcnID,
				   IsvirtualCheck,
				   PmtTxnType,
				   SubSystemID,
				   AppTxnTypeID,
				   TxnPaymentDate,
				   ApprovedBy,
				   Reasontext,
				   TxnAmount,
				   LineItemAmount,
				   AmountReceived,
				   FNFeesPaid,
				   SNFeesPaid,
				   ISNULL(CAST(DeleteFlag AS BIT),0) AS DeleteFlag
			FROM Stage.PostpaidFleetPayment
			LEFT JOIN LND_TBOS.TollPlus.TP_CustomerTrips ON TP_CustomerTrips.CustTripID = Stage.PostpaidFleetPayment.CustTripID) IUF
			WHERE IUF.DeleteFlag<>1
			GROUP BY IUF.InvoiceNumber,
					 IUF.InvoiceID,
					 IUF.CitationID,
					 TpTripID,
					 IUF.LaneID,
					 IUF.PaymentID,
					 IUF.OverPaymentID,
					 IUF.CustomerID,
					 IUF.CustomerStatusID,
					 IUF.UserTypeID,
					 IUF.PlanID,
					 IUF.PaymentDayID,
					 IUF.PaymentModeID,
					 IUF.PaymentStatusID,
					 IUF.RefPaymentStatusID,
					 IUF.RefPaymentID,
					 IUF.VoucherNo,
					 IUF.RefType,
					 IUF.AccountStatusID,
					 IUF.ChannelID,
					 IUF.LocationID,
					 IUF.ICNID,
					 IUF.IsvirtualCheck,
					 IUF.PmtTxnType,
					 IUF.SubSystemID,
					 IUF.AppTxnTypeID,
					 IUF.TxnPaymentDate,
					 IUF.ApprovedBy,
					 IUF.Reasontext,
					 IUF.TxnAmount,
					 IUF.DeleteFlag
			OPTION (LABEL = 'Fact_PaymentDetail_NEW Load')

		-- Log
		SET  @Log_Message = 'Loaded dbo.Fact_PaymentDetail_NEW'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', '-1', -1

		-- Create statistics and swap table
		CREATE STATISTICS STATS_Fact_PaymentDetail_000 ON dbo.Fact_PaymentDetail_NEW (InvoiceNumber);
		CREATE STATISTICS STATS_Fact_PaymentDetail_001 ON dbo.Fact_PaymentDetail_NEW (InvoiceID);
		CREATE STATISTICS STATS_Fact_PaymentDetail_002 ON dbo.Fact_PaymentDetail_NEW (PaymentID);
		CREATE STATISTICS STATS_Fact_PaymentDetail_003 ON dbo.Fact_PaymentDetail_NEW (PaymentDayID);
		CREATE STATISTICS STATS_Fact_PaymentDetail_004 ON dbo.Fact_PaymentDetail_NEW (TpTripID);
		CREATE STATISTICS STATS_Fact_PaymentDetail_005 ON dbo.Fact_PaymentDetail_NEW (CitationID);
		CREATE STATISTICS STATS_Fact_PaymentDetail_006 ON dbo.Fact_PaymentDetail_NEW (DeleteFlag);
		CREATE STATISTICS STATS_Fact_PaymentDetail_007 ON dbo.Fact_PaymentDetail_NEW (OverPaymentID);

		EXEC Utility.TableSwap 'dbo.Fact_PaymentDetail_NEW', 'dbo.Fact_PaymentDetail'

        EXEC Utility.ToLog @Log_Source, @Log_Start_Date,'Completed full load', 'I',NULL,NULL;

        -- Show results
		IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Fact_PaymentDetail' TableName, * FROM dbo.Fact_PaymentDetail ORDER BY 2 DESC
	
	END	TRY	

	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error all the way to Data Manager
	
	END CATCH
END

/*

--:: Testing Zone

EXEC dbo.Fact_PaymentDetail_Full_Load
EXEC Utility.FromLog 'dbo.Fact_PaymentDetail_Full_Load', 1

SELECT 'Stage.TransactionPayment' TableName, * FROM Stage.TransactionPayment ORDER BY 2 DESC 
SELECT 'Stage.InvoicedFeePayment' TableName, * FROM Stage.InvoicedFeePayment ORDER BY 2 DESC 
SELECT 'Stage.PostpaidFleetPayment' TableName, * FROM Stage.PostpaidFleetPayment ORDER BY 2 DESC 
SELECT 'dbo.Fact_PaymentDetail' TableName, * FROM Fact_PaymentDetail ORDER BY 2 DESC 


*/
	

