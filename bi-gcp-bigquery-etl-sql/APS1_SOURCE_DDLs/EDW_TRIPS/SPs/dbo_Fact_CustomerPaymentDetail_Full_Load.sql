CREATE PROC [dbo].[Fact_CustomerPaymentDetail_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_CustomerPaymentDetail table for Recap Deferred Revenue Detail Report. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Shankar 	2020-11-24	New!
CHG0037922	Shankar		2021-01-20 	Change adjustment date to ApprovedStatusDate as per TollPlus updated logic
CHG0038039	Shankar		2021-01-27	Add DeleteFlag. Skip Deleted rows for now.
CHG0038104	Shankar		2021-02-03	Load missing adjustment transactions PRETOLLADJCR for “Account Level Fee Credit” 
CHG0038359	Shankar		2021-02-13	Added RefPaymentStatusID needed for Overpayment Txns
CHG0039407  Shankar		2021-08-05	1. Use OriginalPayTypeID column instead of PayTypeId in RefundRequests_Queue table
									2. Include. Adj Txn. PRESTMTREPRNTFEE, PRESTMTREPRNTFEENEGBAL
									3. Ignore. Payment Txn. CSCCCREFUND, CSCCHKREFUND
									4. Ignore. Adj Txn. ADJRFNDDR, PRECR, PREDR, PRETOLLADJDECEASEDCR
CHG0042378	Shankar		2023-01-30	"Account Level Fee Debit" logic change in Recap Detail report
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_CustomerPaymentDetail_Full_Load

EXEC Utility.FromLog 'dbo.Fact_CustomerPaymentDetail', 1
SELECT TOP 100 'dbo.Fact_CustomerPaymentDetail' Table_Name, * FROM dbo.Fact_CustomerPaymentDetail ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_CustomerPaymentDetail_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL
		DECLARE @Load_Cutoff_Date DATE = '2018-01-01'
		--=============================================================================================================
		-- Load Stage.CustomerPaymentDetail
		--=============================================================================================================

		IF OBJECT_ID('Stage.CustomerPaymentDetail') IS NOT NULL DROP TABLE Stage.CustomerPaymentDetail
		CREATE TABLE Stage.CustomerPaymentDetail 
		WITH (CLUSTERED INDEX ( PaymentLineItemID ASC ), DISTRIBUTION = HASH(PaymentLineItemID)) 
		AS
		SELECT
				LI.LineItemID  AS PaymentLineItemID
				, LI.PaymentID  
				, LI.CustomerID
				, CP.PlanID
				, P.CustomerPlanDesc
				, 'Payment' AS CustomerPaymentType
				, ATT.AppTxnTypeID
				, LI.AppTxnTypeCode
				, ATT.AppTxnTypeDesc
				, CASE
					-- Current Deferred Revenue --> Cash --> Total Bank Deposit --> Cash
					WHEN LI.AppTxnTypeCode IN ( 'CSCCASHPMT', 'CSCREVCASHPMT', 'CSCVOIDCASHPMT', 'APPZCTOPRECASHPMT', 'APPPREDQCASHPMT' ) 
					THEN 1	
					-- Current Deferred Revenue --> Cash --> Total Bank Deposit --> Checks
					WHEN LI.AppTxnTypeCode IN ( 'CSCCHKPMT', 'CSCCRTFIDCHKPMT', 'CSCCASHIERCHKPMT', 'CSCREVCHKPMT', 'CSCREVCRTFIDCHKPMT', 'CSCREVCASHIERCHKPMT', 'CSCVOIDCHKPMT', 'CSCVOIDCRTFIDCHKPMT'
												, 'CSCVOIDCASHIERCHKPMT', 'APPZCTOPRECHKPMT', 'APPZCTOPRECASHIERCHKPMT', 'APPZCTOPRECRTFIDCHKPMT', 'APPPREDQCHKPMT', 'APPPREDQCASHIERCHKPMT', 'APPPREDQCRTFIDCHKPMT')
					THEN 2	
					-- Current Deferred Revenue --> Cash --> Total Bank Deposit --> Money Order
					WHEN LI.AppTxnTypeCode IN ( 'CSCMOPMT', 'APPZCTOPREMOPMT', 'APPPREDQMOPMT' )
					THEN 3	
					-- Current Deferred Revenue --> Cash --> Total Refunds/Bounced Checks --> Bounced Checks
					WHEN LI.AppTxnTypeCode IN ( 'APPBOUNCEDCHK' )
					THEN 5	
					-- Current Deferred Revenue --> Credit --> Total Credit Card Charges --> Credit Card Charges
					WHEN LI.AppTxnTypeCode IN ( 'CSCCCPMT', 'CSCREVCCPMT', 'DALCCPMT', 'APPZCTOPRECCPMT', 'APPPREDQCCPMT', 'CSCVOIDCCPMT', 'DFWCCPMT' )
							AND PMT.PAYMENTSTATUSID IN ( 109, 119, 3182 ) -- Success, Reveresed, Voided
					THEN 6	
					-- Current Deferred Revenue --> Credit --> Total Credit Card Charges --> Autocharges
					WHEN LI.AppTxnTypeCode IN ( 'AUTOPAYCC', 'AUTOPAYDC' ) AND PMT.RefPaymentID = 0
					THEN 7	
					-- Current Deferred Revenue --> Credit --> Total Credit Refund/Chargebacks --> Credit Card Refund
					WHEN LI.AppTxnTypeCode IN ( 'DALCCPMTREF', 'DFWCCPMTREF' )
					THEN 8	
					-- Current Deferred Revenue --> Credit --> Total Credit Refund/Chargebacks --> Autocharge Refunds
					WHEN LI.AppTxnTypeCode = 'AUTOPAYCC' AND PMT.RefPaymentID > 0 -- Refund
					THEN 9	
					-- Current Deferred Revenue --> Credit --> Total Credit Refund/Chargebacks --> Chargebacks
					WHEN LI.AppTxnTypeCode IN ( 'CSCCBREVCCPMT' )
					THEN 10	
					-- Current Deferred Revenue --> Third Party --> Total Third Party Cash Receipt --> ACE Cash Express
					WHEN CH.ChannelName = 'ACECashExpress'
					THEN 11	
					-- Current Deferred Revenue --> Third Party --> Total Third Party Cash Receipt --> Lockbox Payment
					WHEN LI.AppTxnTypeCode = 'APPLOCKBOXPMT'
					THEN 12	
					-- Current Deferred Revenue --> Third Party --> Total Third Party Cash Receipt --> Lockbox Reversal
					WHEN LI.AppTxnTypeCode = 'APPLOCKBOXREV'
					THEN 13	
				  ELSE - 1	
				  END CustomerPaymentLevelID

				, CASE	
					WHEN LI.AppTxnTypeCode IN ( 
							/*  1. Reversal or Void of Cash payment  */  'CSCREVCASHPMT', 'CSCVOIDCASHPMT', 
							/*  2. Reversal or Void of Check payment */  'CSCREVCASHIERCHKPMT', 'CSCREVCHKPMT', 'CSCREVCRTFIDCHKPMT', 'CSCVOIDCASHIERCHKPMT', 'CSCVOIDCHKPMT', 'CSCVOIDCRTFIDCHKPMT',
							/*  5. Check Bounced  */					 'APPBOUNCEDCHK', 
							/*  8. Auto Parking CC Refund */			 'DALCCPMTREF', 'DFWCCPMTREF',  
							/* 10. Chargeback Reversal CC payment */	 'CSCCBREVCCPMT',
							/* 10. Lockbox Reversal */					 'APPLOCKBOXREV' 
					)
					THEN LI.LineItemAmount * -1 

					WHEN LI.AppTxnTypeCode IN ( 'CSCREVCCPMT', 'CSCVOIDCCPMT' ) /* 6. Reversal or Void of CC payment  */
							AND PMT.PAYMENTSTATUSID IN ( 109, 119, 3182 ) -- Success, Reveresed, Voided
					THEN LI.LineItemAmount * -1

					WHEN LI.AppTxnTypeCode IN ( 'AUTOPAYCC', 'AUTOPAYDC' ) /* 7. Autocharges */
							AND PMT.RefPaymentID = 0
					THEN LI.LineItemAmount

					WHEN LI.AppTxnTypeCode IN ( 'AUTOPAYCC' ) /* 9. Autocharge Refunds */
							AND PMT.RefPaymentID > 0
					THEN LI.LineItemAmount * -1
					ELSE LI.LineItemAmount
				END LineItemAmount

				, LI.PaymentDate AS PaymentDate
				, PMT.ChannelID AS ChannelID
				, CH.ChannelName AS PaymentChannelName
				, PMT.PaymentModeID
				, PM.PaymentModeCode
				, PMT.PaymentStatusID
				, PS.PaymentStatusCode
				, PMT.RefPaymentID
				, REF.RefPaymentStatusID
				, CAST(CASE WHEN PMT.LND_UpdateType = 'D' OR LI.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT) DeleteFlag
				, SYSDATETIME() AS EDW_Update_Date
			FROM LND_TBOS.Finance.PaymentTxns PMT
			JOIN LND_TBOS.Finance.PaymentTxn_LineItems LI
			ON LI.PAYMENTID = PMT.PAYMENTID
			JOIN LND_TBOS.TollPlus.TP_Customer_Plans CP
			ON LI.CustomerID = CP.CustomerID
			LEFT JOIN dbo.Dim_CustomerPlan P
			ON CP.PlanID = P.CustomerPlanID
			LEFT JOIN dbo.Dim_Channel CH
			ON PMT.ChannelID = CH.ChannelId
			LEFT JOIN dbo.Dim_PaymentStatus PS 
			ON PMT.PaymentStatusID = PS.PaymentStatusID
			LEFT JOIN dbo.Dim_AppTxnType ATT
			ON LI.AppTxnTypeCode = ATT.AppTxnTypeCode
			LEFT JOIN dbo.Dim_PaymentMode PM
			ON PMT.PaymentModeID = PM.PaymentModeID
			LEFT JOIN
			(
				SELECT ORIG_PMT.PaymentID, ORIG_PMT.PaymentStatusID RefPaymentStatusID
				FROM LND_TBOS.Finance.PaymentTxns ORIG_PMT
				JOIN
					(
						SELECT RefPaymentID
						FROM LND_TBOS.Finance.PaymentTxns PT
						WHERE RefPaymentID > 0
						AND PaymentStatusID = 109
						AND LND_UpdateType <> 'D'  
					) REF_PMT 
				ON REF_PMT.RefPaymentID = ORIG_PMT.PaymentID AND ORIG_PMT.LND_UpdateType <> 'D' 
			) REF ON REF.PaymentID = PMT.RefPaymentID 

		WHERE PMT.PAYMENTSTATUSID IN ( 109, 119, 3182 ) -- Success, Reveresed, Voided
		       AND LI.AppTxnTypeCode NOT IN ('CSCCHKREFUND','CSCCCREFUND') -- This code is used to affect refundbal of prepaid accounts. This can be ignored.
               AND PMT.LND_UpdateType <> 'D' AND LI.LND_UpdateType <> 'D'
		OPTION (LABEL = 'Stage.CustomerPaymentDetail Load');

		SET  @Log_Message = 'Loaded Stage.CustomerPaymentDetail' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--=============================================================================================================
		-- Load Stage.CustomerAdjustmentDetail
		--=============================================================================================================

		IF OBJECT_ID('Stage.CustomerAdjustmentDetail') IS NOT NULL DROP TABLE Stage.CustomerAdjustmentDetail
		CREATE TABLE Stage.CustomerAdjustmentDetail 
		WITH (CLUSTERED INDEX ( AdjLineItemID ASC ), DISTRIBUTION = HASH(AdjLineItemID)) 
		AS

		SELECT	       
				  LI.AdjLineItemID  AS AdjLineItemID        
				, LI.AdjustmentID     
				, ADJ.CustomerID     
				, CP.PlanID
				, P.CustomerPlanDesc
				, 'Adjustment' AS CustomerPaymentType     
				, ATT.AppTxnTypeID     
				, LI.AppTxnTypeCode     
				, ATT.AppTxnTypeDesc     
				, CASE
					-- Current Deferred Revenue --> Cash --> Total Refunds/Bounced Checks --> Refund Checks     
					WHEN LI.AppTxnTypeCode = 'ADJPRERFND' AND PM.PaymentModeCode = 'Cheque'      
					THEN 4     
					-- Current Deferred Revenue --> Credit --> Total Credit Refund/Chargebacks --> Credit Card Refund     
					WHEN LI.AppTxnTypeCode = 'ADJPRERFND' AND PM.PaymentModeCode = 'CreditCard'      
					THEN 8     
					-- Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Lost/Stolen Tag Fees     
					WHEN LI.AppTxnTypeCode IN ( 'TAGLOST', 'TAGSTOLEN' )     
					THEN 14      
					-- Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Recovered Tag Credit     
					WHEN LI.AppTxnTypeCode IN ( 'TAGLSTASGN', 'TAGSTLASGN' )     
					THEN 15      
					-- Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Statement Fee     
					WHEN LI.AppTxnTypeCode = 'STMNTCHRGFEE' AND ADJ.DRCRFLAG = 'D'     
					THEN 16     
					-- Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Statement Fee Credit    
					WHEN LI.AppTxnTypeCode = 'STMNTCHRGFEE' AND ADJ.DRCRFLAG = 'C'     
					THEN 17 
					-- Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Account Level Fee Debit     
					--WHEN LI.AppTxnTypeCode IN ( 'CSCUSPSFEE', 'CSCSTMTREPRINTFEE', 'CSCSMSFEE', 'CSCEMAILFEE', 'CSCCHARGEBACKFEE', 'CSCNSFFEE', 'CSCCOLLFEE', 'CSCSTMTDELFEE', 'SHIPPING',
					--							'ADJUSTMENT', 'TRANSRTBTOZIPCASH', 'ACCMERGECHILD', 'TRANSOVRPMTTOPRE', 'PRESTMTREPRNTFEE','PRESTMTREPRNTFEENEGBAL' ) AND ADJ.DRCRFLAG = 'D'     
					WHEN (
							LI.AppTxnTypeCode IN ( 'CSCUSPSFEE', 'CSCSTMTREPRINTFEE', 'CSCSMSFEE', 'CSCEMAILFEE', 'CSCCHARGEBACKFEE', 'CSCNSFFEE', 'CSCCOLLFEE', 'CSCSTMTDELFEE', 'SHIPPING',
													'ADJUSTMENT', 'TRANSRTBTOZIPCASH', 'ACCMERGECHILD', 'TRANSOVRPMTTOPRE', 'PRESTMTREPRNTFEE','PRESTMTREPRNTFEENEGBAL' 
												 )      
							OR  
							(LI.APPTXNTYPECODE = 'PRETOLLADJDR' AND LI.LINKSOURCENAME='TOLLPLUS.TP_CUSTOMERS')
						 ) AND ADJ.DRCRFLAG='D'    
					THEN 18 
					-- Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Account Level Fee Credit     
					WHEN ( 
							LI.AppTxnTypeCode IN ('CSCUSPSFEE','REVCSCSTMTREPRINTFEE','REVCSCSMSFEE','REVCSCEMAILFEE','REVCSCCHARGEBACKFEE','REVCSCNSFFEE','REVCSCCOLLFEE','TAGRQCANSHIPPING','TRANSRFNDTOTB'  
												 ,'TRANSRZIPCASHTOTB','TRANSOVRPMTTOPRE','ADJUSTMENT','ACCMERGE','REVCSCSTMTDELFEE'
												 )     
						OR  
						(LI.AppTxnTypeCode IN ('PRETOLLADJCR') and LI.LinkSourceName = 'TOLLPLUS.TP_CUSTOMERS') 
						) AND ADJ.DRCRFLAG='C'    
					THEN 19     
					-- Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Speciality Tag Fee    
					WHEN LI.AppTxnTypeCode = 'SPECIALITYTAGFEE'     
					THEN 20      
					-- Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Speciality Tag Fee Credit     
					WHEN LI.AppTxnTypeCode = 'TAGRQCANSPECFEE'     
					THEN 21      
					-- Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Escheatment     
					WHEN LI.AppTxnTypeCode = 'ADJTOLLAMTESCHEAT'     
					THEN 22      
					-- Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Close Out Balance     
					WHEN	LI.AppTxnTypeCode = 'ADJBDEXPDR'     
					THEN 23
					ELSE -1
					END CustomerPaymentLevelID       
			
				, CASE      
					WHEN	LI.AppTxnTypeCode IN (
						/*  4. Total Refunds/Bounced Checks       
							8.Credit Card Refunds  */			'ADJPRERFND',
						/* 14. Lost/Stolen Tag Fees */			'TAGLOST', 'TAGSTOLEN',       
						/* 24. Speciality Tag Fee */			'SPECIALITYTAGFEE',       
						/* 26. Escheatment */					'ADJTOLLAMTESCHEAT',       
						/* 27. Close Out Balance */				'ADJBDEXPDR' )     
					THEN LI.Amount * -1               
						/* 16. Statement Fee */      
					WHEN LI.AppTxnTypeCode =  'STMNTCHRGFEE' AND ADJ.DRCRFLAG = 'D'        
					THEN LI.Amount * -1            
					WHEN (  /* 18. Account Level Fee Debit */
							LI.AppTxnTypeCode IN ( 'CSCUSPSFEE', 'CSCSTMTREPRINTFEE', 'CSCSMSFEE', 'CSCEMAILFEE', 'CSCCHARGEBACKFEE', 'CSCNSFFEE', 'CSCCOLLFEE', 'CSCSTMTDELFEE', 'SHIPPING',
													'ADJUSTMENT', 'TRANSRTBTOZIPCASH', 'ACCMERGECHILD', 'TRANSOVRPMTTOPRE', 'PRESTMTREPRNTFEE','PRESTMTREPRNTFEENEGBAL' 
												 )      
							OR  
							(LI.APPTXNTYPECODE = 'PRETOLLADJDR' AND LI.LINKSOURCENAME='TOLLPLUS.TP_CUSTOMERS')
						 ) AND ADJ.DRCRFLAG='D'    
					THEN LI.Amount * -1            
					ELSE LI.Amount    
					END     AS LineItemAmount       
     
				, ADJ.ApprovedStatusDate    
				, RRQ.OriginalPayTypeID AS PaymentModeID     
				, PM.PaymentModeCode
				, ADJ.ApprovedStatusID AS AdjApprovalStatusID
				, ADJ.DRCRFlag
				, CAST(CASE WHEN ADJ.LND_UpdateType = 'D' OR LI.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT) DeleteFlag
		FROM LND_TBOS.Finance.Adjustments ADJ    
			JOIN LND_TBOS.Finance.Adjustment_LineItems LI   
	 			ON LI.AdjustmentID = ADJ.AdjustmentID    
			JOIN LND_TBOS.TollPlus.TP_Customer_Plans CP      
	 			ON ADJ.CustomerID = CP.CustomerID
			LEFT JOIN dbo.Dim_CustomerPlan P
				ON CP.PlanID = P.CustomerPlanID
			LEFT JOIN dbo.Dim_AdjApprovalStatus AAS      
	 			ON ADJ.ApprovedStatusID = AAS.AdjApprovalStatusID    
			LEFT JOIN dbo.Dim_AppTxnType ATT      
	 			ON LI.AppTxnTypeCode = ATT.AppTxnTypeCode     
			LEFT JOIN LND_TBOS.FINANCE.RefundRequests_Queue RRQ      
	 			ON ADJ.RefundRequestID = RRQ.RefundRequestID      
			LEFT JOIN dbo.Dim_PaymentMode PM      
	 			ON RRQ.OriginalPayTypeID  = PM.PaymentModeID   
		WHERE ADJ.ApprovedStatusID = 466
			AND ADJ.ApprovedStatusDate >= @Load_Cutoff_Date
			AND (
					LI.AppTxnTypeCode NOT IN
					(
					'ASSIGNTAG','PRETOLLADJCR','PRETOLLADJDR','PRETOLLADJFIRSTRESPONDERCR','TRIPDISMISS','PRETOLLADJEXCUSALCR', -- Traffic. Separate data source Fact_TollTransaction.
					'ADJRFNDCR', -- We should ignore this one. Not right one for PrePaid; This is for Refund. One Txn activity involves two AppTxnTypeCodes. TollPlus uses ADJPRERFND (1st Txn), we caught ADJRFNDCR (2nd Txn).
					'ADJRFNDDR', -- This code is used to affect refundbal of prepaid accounts. This can be ignored.
					'PRECR','PREDR', -- This code is used for prepaid toll adjustments. We donot use codes to derive toll adjustments.This is already included in recap traffic section. This can be ignored
					'PRETOLLADJDECEASEDCR' -- Included in the Traffic part
					)
					OR
					(LI.AppTxnTypeCode IN ('PRETOLLADJCR') AND LI.LinkSourceName = 'TOLLPLUS.TP_CUSTOMERS' AND ADJ.DRCRFLAG='C') /* 19. Account Level Fee Credit */
					OR
					(LI.AppTxnTypeCode IN ('PRETOLLADJDR') AND LI.LINKSOURCENAME='TOLLPLUS.TP_CUSTOMERS' AND ADJ.DRCRFLAG='D') /* 18. Account Level Fee Debit */
				)
			AND ADJ.LND_UpdateType <> 'D' AND LI.LND_UpdateType <> 'D'
		OPTION (LABEL = 'Stage.CustomerAdjustmentDetail Load');

		SET  @Log_Message = 'Loaded Stage.CustomerAdjustmentDetail' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		IF OBJECT_ID('dbo.Fact_CustomerPaymentDetail_NEW') IS NOT NULL DROP TABLE dbo.Fact_CustomerPaymentDetail_NEW
		CREATE Table dbo.Fact_CustomerPaymentDetail_NEW 
			WITH (	  DISTRIBUTION = HASH(CustomerPaymentDetailID)
					, CLUSTERED INDEX (CustomerPaymentDetailID ASC) 
					--, PARTITION (PaymentDayID RANGE RIGHT FOR VALUES ('20200701','20200801','20200901','20201001','20201101','20201201','20210101','20210201','20210301','20210401','20210501','20210601','20210701','20210801','20210901','20211001','20211101','20211201'))  
				 )
		AS
		SELECT 
			  ISNULL(CAST(100000000000 + PaymentLineItemID AS BIGINT), 0) AS CustomerPaymentDetailID
			, ISNULL(CAST(PaymentLineItemID AS BIGINT), 0) AS PaymentLineItemID
			, ISNULL(CAST(PaymentID AS BIGINT), 0) AS PaymentID
			, ISNULL(CAST(NULL AS BIGINT), 0) AS AdjLineItemID
			, ISNULL(CAST(NULL AS BIGINT), 0) AS AdjustmentID
			, ISNULL(CAST(CustomerID AS BIGINT),-1) AS CustomerID
			, CAST(1 AS SMALLINT) AS CustomerPaymentTypeID
			, ISNULL(CAST(AppTxnTypeID AS INT),-1) AS AppTxnTypeID
			, ISNULL(CAST(CustomerPaymentLevelID AS INT),-1) AS CustomerPaymentLevelID
			, ISNULL(CONVERT(INT,CONVERT(VARCHAR,PaymentDate,112)),-1) PaymentDayID
			, ISNULL(CAST(ChannelID AS INT),-1) AS ChannelID
			, ISNULL(CAST(PaymentModeID AS INT), 0) AS PaymentModeID
			, ISNULL(CAST(PaymentStatusID AS INT), 0) AS PaymentStatusID
			, CAST(RefPaymentID AS BIGINT) AS RefPaymentID
			, ISNULL(CAST(RefPaymentStatusID AS INT), 0) AS RefPaymentStatusID
			, CAST(NULL AS CHAR(1)) AS DRCRFlag
			, CAST(LineItemAmount AS DECIMAL(19,2)) AS LineItemAmount
			, ISNULL(CAST(DeleteFlag AS BIT),0) AS DeleteFlag
			, CAST(PaymentDate AS DATETIME2(3)) AS PaymentDate
			, ISNULL(CAST(EDW_Update_Date AS DATETIME2(3)), '1900-01-01') AS EDW_Update_Date
		FROM Stage.CustomerPaymentDetail
		UNION ALL
		SELECT 
			  ISNULL(CAST(200000000000 + AdjLineItemID AS BIGINT), 0) AS CustomerPaymentDetailID
			, ISNULL(CAST(NULL AS BIGINT), 0) AS PaymentLineItemID
			, ISNULL(CAST(NULL AS BIGINT), 0) AS PaymentID
			, ISNULL(CAST(AdjLineItemID AS BIGINT), 0) AS AdjLineItemID
			, ISNULL(CAST(AdjustmentID AS BIGINT), 0) AS AdjustmentID
			, ISNULL(CAST(CustomerID AS BIGINT),-1) AS CustomerID
			, CAST(2 AS SMALLINT) AS CustomerPaymentTypeID
			, ISNULL(CAST(AppTxnTypeID AS INT),-1) AS AppTxnTypeID
			, ISNULL(CAST(CustomerPaymentLevelID AS INT), -1) AS CustomerPaymentLevelID
			, ISNULL(CONVERT(INT,CONVERT(VARCHAR,ApprovedStatusDate,112)),-1) PaymentDayID
			, ISNULL(CAST(NULL AS INT),-1) AS ChannelID
			, ISNULL(CAST(PaymentModeID AS INT), -1) AS PaymentModeID
			, ISNULL(CAST(NULL AS INT), -1) AS PaymentStatusID
			, CAST(NULL AS BIGINT) AS RefPaymentID
			, CAST(NULL AS INT) AS RefPaymentStatusID
			, CAST(NULL AS CHAR(1)) AS DRCRFlag
			, CAST(LineItemAmount AS DECIMAL(19,2)) AS LineItemAmount
			, ISNULL(CAST(DeleteFlag AS BIT),0) AS DeleteFlag
			, CAST(ApprovedStatusDate AS DATETIME2(3)) AS ApprovedStatusDate
			, ISNULL(CAST(SYSDATETIME() AS DATETIME2(3)), '1900-01-01') AS EDW_Update_Date
		FROM Stage.CustomerAdjustmentDetail
		OPTION (LABEL = 'dbo.Fact_CustomerPaymentDetail Load');

		SET  @Log_Message = 'Loaded dbo.Fact_CustomerPaymentDetail_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_02 ON dbo.Fact_CustomerPaymentDetail_NEW (PaymentLineItemID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_03 ON dbo.Fact_CustomerPaymentDetail_NEW (PaymentID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_04 ON dbo.Fact_CustomerPaymentDetail_NEW (AdjLineItemID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_05 ON dbo.Fact_CustomerPaymentDetail_NEW (AdjustmentID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_06 ON dbo.Fact_CustomerPaymentDetail_NEW (CustomerID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_07 ON dbo.Fact_CustomerPaymentDetail_NEW (CustomerPaymentTypeID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_08 ON dbo.Fact_CustomerPaymentDetail_NEW (AppTxnTypeID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_09 ON dbo.Fact_CustomerPaymentDetail_NEW (CustomerPaymentLevelID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_10 ON dbo.Fact_CustomerPaymentDetail_NEW (PaymentDayID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_11 ON dbo.Fact_CustomerPaymentDetail_NEW (ChannelID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_12 ON dbo.Fact_CustomerPaymentDetail_NEW (PaymentStatusID);
		CREATE STATISTICS STATS_dbo_Fact_CustomerPaymentDetail_13 ON dbo.Fact_CustomerPaymentDetail_NEW (DeleteFlag);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_CustomerPaymentDetail_NEW', 'dbo.Fact_CustomerPaymentDetail'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'Stage.CustomerPaymentDetail' TableName, * FROM Stage.CustomerPaymentDetail ORDER BY 2 DESC
		IF @Trace_Flag = 1 SELECT TOP 1000 'Stage.CustomerAdjustmentDetail' TableName, * FROM Stage.CustomerAdjustmentDetail ORDER BY 2 DESC
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_CustomerPaymentDetail' TableName, * FROM dbo.Fact_CustomerPaymentDetail ORDER BY 2 DESC
	
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
EXEC dbo.Fact_CustomerPaymentDetail_Full_Load

EXEC Utility.FromLog 'dbo.Fact_CustomerPaymentDetail', 1
SELECT TOP 100 'dbo.Fact_CustomerPaymentDetail' Table_Name, * FROM dbo.Fact_CustomerPaymentDetail ORDER BY 2

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

-- Sample data at a glance:

--:: Dim Tables
SELECT TOP 1000 'dbo.Dim_CustomerPaymentLevel' TableName, * FROM dbo.Dim_CustomerPaymentLevel --> New!
SELECT TOP 1000 'dbo.Dim_CustomerPaymentType' TableName, * FROM dbo.Dim_CustomerPaymentType --> New!
SELECT TOP 1000 'dbo.Dim_AdjApprovalStatus' TableName,* from dbo.Dim_AdjApprovalStatus -- FYI
SELECT TOP 1000 'dbo.Dim_PaymentMode' TableName, * FROM dbo.Dim_PaymentMode ORDER BY PaymentModeGroupCode, PaymentModeCode
SELECT TOP 1000 'dbo.Dim_PaymentStatus' TableName, * FROM dbo.Dim_PaymentStatus ORDER BY 2
SELECT TOP 1000 'dbo.Dim_Channel' TableName, * FROM dbo.Dim_Channel ORDER BY 2 -- for AceCashExpress
SELECT TOP 1000 'dbo.Dim_Customer' TableName, * FROM dbo.Dim_Customer ORDER BY 2  

--:: Fact Table 
SELECT TOP 10000 'Stage.CustomerPaymentDetail' TableName, * FROM Stage.CustomerPaymentDetail ORDER BY 2 DESC
SELECT TOP 10000 'Stage.CustomerAdjustmentDetail' TableName, * FROM Stage.CustomerAdjustmentDetail ORDER BY 2 DESC
SELECT TOP 10000 'Stage.CustomerPaymentDetail' TableName, * FROM Stage.CustomerPaymentDetail WHERE CustomerPaymentLevelID = -1 ORDER BY 2 DESC
SELECT TOP 10000 'Stage.CustomerAdjustmentDetail' TableName, * FROM Stage.CustomerAdjustmentDetail WHERE CustomerPaymentLevelID = -1 ORDER BY 2 DESC
SELECT TOP 10000 'dbo.Fact_CustomerPaymentDetail' TableName, * FROM dbo.Fact_CustomerPaymentDetail ORDER BY 2 DESC
SELECT COUNT(1) [Fact_CustomerPaymentDetail] FROM dbo.Fact_CustomerPaymentDetail  

SELECT 'Stage.CustomerPaymentDetail' TableName, PaymentStatusCode, COUNT(1) RC FROM Stage.CustomerPaymentDetail GROUP BY PaymentStatusCode ORDER BY 3 DESC
SELECT CONVERT(DATE,PaymentDate) PaymentDate, COUNT(1) RC, SUM(LineItemAmount) LineItemAmount FROM Stage.CustomerPaymentDetail WHERE CustomerPaymentLevelID = -1 GROUP BY  CONVERT(DATE,PaymentDate)  ORDER BY 1 DESC

--:: Showing Fact and Dim table relationships 

SELECT CP.CustomerPaymentType, 
          CPL.CustomerPaymentLevelID, CPL.CustomerPaymentLevel1, CPL.CustomerPaymentLevel2, CPL.CustomerPaymentLevel3, CPL.CustomerPaymentLevel4, 
          ATT.AppTxnTypeCode, ATT.AppTxnTypeDesc, 
          CH.ChannelName,
          PM.PaymentModeCode, PM.PaymentModeGroupCode,
          PS.PaymentStatusCode,
          CPD.LineItemAmount 
--SELECT COUNT(1) RC, SUM(CPD.LineItemAmount) LineItemAmount -- 7962926 rows, none lost in any JOIN
FROM dbo.Fact_CustomerPaymentDetail CPD  
JOIN dbo.Dim_CustomerPaymentType CP
       ON CPD.CustomerPaymentTypeID = CP.CustomerPaymentTypeID
JOIN dbo.Dim_CustomerPaymentLevel CPL -- 97252
       ON CPD.CustomerPaymentLevelID = CPL.CustomerPaymentLevelID
JOIN dbo.Dim_AppTxnType ATT --  -1
       ON CPD.AppTxnTypeID = ATT.AppTxnTypeID
JOIN dbo.Dim_Channel CH --  -1
       ON CPD.ChannelID = CH.ChannelID
JOIN dbo.Dim_PaymentMode PM
       ON CPD.PaymentModeID = PM.PaymentModeID
JOIN dbo.Dim_PaymentStatus PS
       ON CPD.PaymentStatusID = PS.PaymentStatusID
WHERE CPD.PaymentDayID BETWEEN 20201101 AND 20201130
AND CPL.CustomerPaymentLevelID = 19
ORDER BY CPD.PaymentDayID DESC, CPL.SortSequenceNumber  

--:: Here is the Customer Level Payments Detail fact table data 360 degrees view

SELECT	pt.CustomerPaymentType, 
		c.CustomerPlanID, c.CustomerPlanDesc,
		c.FleetFlag,
		AppTxnTypeCode, AppTxnTypeDesc,
		pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4,  
		pm.PaymentModeCode,
		ps.PaymentStatusCode,
		DRCRFlag, 
		MIN(d.DayDate) PaymentDateFrom, MAX(d.DayDate) PaymentDateTo,
		ISNULL(COUNT(DISTINCT pd.CustomerID),0) CustomerCount, ISNULL(COUNT(DISTINCT PaymentID),0) PaymentTxnCount, ISNULL(COUNT(1),0) Row_Count, ISNULL(SUM(pd.LineItemAmount),0.00) Amount
FROM	dbo.Fact_CustomerPaymentDetail pd 
LEFT JOIN	dbo.Dim_CustomerPaymentLevel pl
			ON pd.CustomerPaymentLevelID = pl.CustomerPaymentLevelID 
LEFT JOIN	dbo.Dim_AppTxnType att
			ON pd.AppTxnTypeID = att.AppTxnTypeID
LEFT JOIN	dbo.Dim_Customer c
			ON pd.CustomerID = c.CustomerID
LEFT JOIN	dbo.Dim_CustomerPaymentType pt
			ON pd.CustomerPaymentTypeID = pt.CustomerPaymentTypeID
LEFT JOIN	dbo.Dim_PaymentMode pm
			ON pd.PaymentModeID = pm.PaymentModeID
LEFT JOIN	dbo.Dim_PaymentStatus ps
			ON pd.PaymentStatusID = ps.PaymentStatusID
LEFT JOIN	dbo.Dim_Day d
			ON pd.PaymentDayID = d.DayID
WHERE	pd.CustomerPaymentLevelID = -1
GROUP BY 
		pt.CustomerPaymentType, 
		c.CustomerPlanID, c.CustomerPlanDesc,
		c.FleetFlag,
		AppTxnTypeCode, AppTxnTypeDesc,
		pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4,  
		pm.PaymentModeCode,
		ps.PaymentStatusCode,
		DRCRFlag
ORDER BY c.CustomerPlanID, pt.CustomerPaymentType, PaymentTxnCount DESC

--:: Simpler view. 
SELECT CustomerPaymentType, PlanID, CustomerPlanDesc, AppTxnTypeCode, AppTxnTypeDesc, pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4, NULL DRCRFlag, COUNT(DISTINCT CustomerID) CustomerCount, COUNT(DISTINCT PaymentID) PaymentTxnCount, COUNT(1) Row_Count, SUM(pd.LineItemAmount) Amount
FROM Stage.CustomerPaymentDetail pd JOIN dbo.Dim_CustomerPaymentLevel pl ON pd.CustomerPaymentLevelID = pl.CustomerPaymentLevelID 
GROUP BY CustomerPaymentType, PlanID, CustomerPlanDesc, AppTxnTypeCode, AppTxnTypeDesc, pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4 
 
SELECT CustomerPaymentType, PlanID, CustomerPlanDesc, AppTxnTypeCode, AppTxnTypeDesc, pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4, DRCRFlag, COUNT(DISTINCT CustomerID) CustomerCount, COUNT(DISTINCT AdjustmentID) AdjTxnCount, COUNT(1) Row_Count, SUM(pd.LineItemAmount) Amount 
FROM Stage.CustomerAdjustmentDetail pd JOIN dbo.Dim_CustomerPaymentLevel pl ON pd.CustomerPaymentLevelID = pl.CustomerPaymentLevelID  
GROUP BY CustomerPaymentType, PlanID, CustomerPlanDesc, AppTxnTypeCode, AppTxnTypeDesc, pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4, DRCRFlag 
ORDER BY PlanID, CustomerPaymentType, PaymentTxnCount DESC

select * from  Stage.CustomerAdjustmentDetail 
*/


