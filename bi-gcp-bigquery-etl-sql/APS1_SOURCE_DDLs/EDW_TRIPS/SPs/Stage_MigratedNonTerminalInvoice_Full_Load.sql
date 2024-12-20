CREATE PROC [Stage].[MigratedNonTerminalInvoice_Full_Load] AS
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
										  migrated at second notice stage, then trips tables doesn't have the dates 
										  prior to that stage. In order to bring the prior stages dates, RITE DB is 
										  used.
CHG0044458   Gouthami	     2024-01-26  1.Changed the logic to bring ThirdNotice from latest to earliest dates as there
										   can be multiple dates when invoice is in Collections.(MAX-->MIN)
										 2.Always take the first instance of date when an Invoice went to 
											ThirdNotice/Collections.
										 3.These changes are not applicable to downgraded invoices. This needs to be 
										   fixed with different logic.
===================================================================================================================

-------------------------------------------------------------------------------------------------------------------
EXEC [Stage].[MigratedNonTerminalInvoice_Full_Load]
EXEC Utility.FromLog 'Stage.MigratedNonTerminalInvoice', 1
SELECT TOP 100 'Stage.MigratedNonTerminalInvoice' Table_Name, * FROM Stage.MigratedNonTerminalInvoice ORDER BY 2
###################################################################################################################
*/
BEGIN
BEGIN TRY


		DECLARE @Log_Source VARCHAR(100) = 'Stage.MigratedNonTerminalInvoice_Full_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME();
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0; -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL;
		
		
		--=============================================================================================================
		-- Load Stage.MigratedInvoice -- list of invoices that needs to be executed in each run
		--=============================================================================================================
		
		
		IF OBJECT_ID('Stage.MigratedInvoice') IS NOT NULL DROP TABLE Stage.MigratedInvoice;
		CREATE  TABLE Stage.MigratedInvoice WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber))
		AS	
		SELECT * FROM  (
		SELECT ROW_NUMBER() OVER (PARTITION BY IHC.InvoiceNumber ORDER BY (IHC.InvoiceID) DESC) RN_MAX,
		           IHC.InvoiceNumber,
		           IHC.InvoiceID,
		           IHC.CustomerID,
		           IHC.AgeStageID,
		           IHC.CollectionStatus,
		           IHC.VehicleID,
				   IHC.InvoiceDate,
				   IHC.DueDate,
		           IHC.AdjustedAmount,
		           IHC.InvoiceStatus,
		           IHC.LND_UpdateType,				   
                   RI.AgeStageID AgeStageID_RI,
                   RI.ZipCashDate ZipCashDate_RI,
                   RI.FirstNoticeDate FirstNoticeDate_RI,
                   RI.SecondNoticeDate SecondNoticeDate_RI,
                   RI.ThirdNoticeDate ThirdNoticeDate_RI,
                   RI.CitationDate CitationDate_RI,
                   RI.LegalActionPendingDate LegalActionPendingDate_RI,
                   RI.DueDate DueDate_RI,
                   RI.CurrMBSGeneratedDate CurrMBSGeneratedDate_RI,
                   RI.FirstpaymentDate FirstpaymentDate_RI,
                   RI.LastPaymentDate LastPaymentDate_RI		
		    FROM LND_TBOS.TollPlus.Invoice_Header IHC
			JOIN REF.RiteMigratedInvoice  RI ON RI.InvoiceNumber = IHC.InvoiceNumber AND RI.EDW_InvoiceStatusID=4370
			WHERE IHC.LND_UpdateType <> 'D'  AND  IHC.CREATEDUSER <> 'DCBInvoiceGeneration' 
			AND RI.InvoiceNumber IS NOT NULL
		)A WHERE A.RN_MAX=1

		-- Log 
		SET  @Log_Message = 'Loaded Stage.MigratedInvoice'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, '-1', -1, 'I'
		
		-- Create statistics and swap table
		CREATE STATISTICS STATS_Stage_MigratedInvoice_000 ON Stage.MigratedInvoice (InvoiceNumber);


		IF @Trace_Flag = 1 SELECT TOP 100 'Stage.MigratedInvoice' TableName, * FROM Stage.MigratedInvoice ORDER BY 2 DESC


		--=============================================================================================================
		-- Load Stage.MigratedDimissedVToll  -- to bring dismissed Vtolls
		--=============================================================================================================
		IF OBJECT_ID('Stage.MigratedDimissedVToll') IS NOT NULL DROP TABLE Stage.MigratedDimissedVToll;
		CREATE TABLE Stage.MigratedDimissedVToll WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber)) 
        AS		
		WITH CTE_Vtolls AS 
		(
		SELECT  
				DISTINCT
				A.InvoiceNumber InvoiceNumber
				,COUNT(DISTINCT A.TpTripID) VTollTxnCnt
				,ISNULL(SUM(CASE WHEN A.TripStatusID IN (171,118) THEN 1 ELSE 0 END),0) AS UnassignedVtolledTxnCnt
				,SUM(CASE WHEN A.PaymentStatusID=456 THEN 1 ELSE 0 END ) VTollPaidTxnCnt
				,MIN(A.PostedDate) FirstPaymentDate
				,MAX(A.PostedDate) LastPaymentDate
				,SUM(A.Tolls) Tolls
				,SUM(A.PBMTollAmount) PBMTollAmount
				,SUM(A.AVITollAmount) AVITollAmount
				,SUM(A.PBMTollAmount-A.AVITollAmount) PremiumAmount
				,SUM(A.PaidAmount_VT) PaidAmount_VT
				,SUM(A.TollsAdjusted) TollsAdjusted
				,SUM(A.OutstandingAmount) OutstandingAmount
		FROM (
				SELECT  H.InvoiceNumber
					    ,TC.TpTripID
					    ,VT.TripStatusID
					    ,TC.PaymentStatusID
					    ,MAX(TC.PostedDate) PostedDate --Ex:1199596135
						,CASE WHEN TC.PaymentStatusID=3852 AND VT.TripStatusID<>154 AND TC.TripStatusID<>155 THEN 0 ELSE VT.PBMTollAmount END PBMTollAmount -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
						,CASE WHEN TC.PaymentStatusID=3852 AND VT.TripStatusID<>154 AND TC.TripStatusID<>155 THEN 0 ELSE VT.AVITollAmount END AVITollAmount -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
						,CASE WHEN TC.PaymentStatusID=3852 AND VT.TripStatusID<>154 AND TC.TripStatusID<>155 THEN 0 ELSE VT.TollAmount END Tolls -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
						,CASE WHEN COUNT(VT.tptripID)>1 THEN (SUM(CASE WHEN TC.PaymentStatusID=456 AND TC.TripStatusID=5  THEN TC.TollAmount 
								  WHEN TC.PaymentStatusID=456 THEN TC.TollAmount  						  
								  WHEN TC.PaymentStatusID=457 THEN 	 (TC.TollAmount - TC.OutstandingAmount) 
							 ELSE 0 END )/ COUNT(VT.tptripID))
						 ELSE 			
								SUM(CASE WHEN TC.PaymentStatusID=456 AND TC.TripStatusID=5  THEN TC.TollAmount 
								  WHEN TC.PaymentStatusID=456 THEN TC.TollAmount  						  
								  WHEN TC.PaymentStatusID=457 THEN 	 (TC.TollAmount - TC.OutstandingAmount) 
							 ELSE 0 END ) 
						 END AS PaidAmount_VT 
						,TC.OutstandingAmount   
						,SUM(CASE   WHEN  TC.PaymentStatusID=3852 AND TC.TripStatusID=135 AND  VT.PaymentStatusID=456 AND  vt.TripStatusID=2 THEN 0 -- these are the txns that got posted in VT table and paid in vtrt 
								    WHEN  TC.PaymentStatusID=458 AND TC.OutstandingAmount<>TC.TollAmount AND TC.OutstandingAmount=TC.PBMTollAmount AND TC.OutstandingAmount=TC.AVITollAmount THEN (TC.TollAmount-TC.OutstandingAmount)-- Ex:1236741507
									WHEN   TC.PaymentStatusID=3852 AND TC.TripStatusID=135 AND VT.PaymentStatusID=3852 THEN 0	--ex:1225983731
									WHEN   TC.PaymentStatusID=3852 AND TC.TripStatusID=154 THEN 0 --Ex:1222959778
									WHEN   TC.PaymentStatusID=3852 THEN L.amount 								
									WHEN   TC.TollAmount<>L.Amount THEN L.Amount-TC.TollAmount
									WHEN   TC.TollAmount=TC.PBMTollAmount AND TC.OutstandingAmount=TC.AVITollAmount AND TC.PaymentStatusID=458 THEN (TC.TollAmount-TC.OutstandingAmount) --Ex:1234342591
									WHEN   TC.TollAmount=TC.PBMTollAmount THEN 0 	
									WHEN   TC.TollAmount=0 AND (VT.TollAmount=TC.PBMTollAmount) THEN TC.PBMTollAmount
									WHEN   (TC.TollAmount=L.amount) AND tc.TollAmount<>TC.PBMTollAmount AND tc.TollAmount<>TC.AVITollAmount THEN 0
							ELSE (TC.PBMTollAmount-TC.AVITollAmount) END) TollsAdjusted 
							--SELECT *
				FROM LND_TBOS.TollPlus.Invoice_Header H WITH (NOLOCK)
				JOIN LND_TBOS.TollPlus.Invoice_LineItems L WITH (NOLOCK)
							ON L.InvoiceID = H.InvoiceID
				JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT WITH (NOLOCK)
							ON ABS(L.LinkID) = ABS(VT.CitationID)
								AND L.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips'
								AND (VT.PaymentStatusID<>456 AND  vt.TripStatusID<>2)  -- This is to avoid those Txns that are vtolled first and then moved back to Violated trips table	 
								AND VT.TripStatusID NOT IN (171,118) -- EX: 1233445625,1234165987,1230780604. This condition is for the Txns that are unassignd from an invoice and assigned to a different one and then gor VTOLLED.In this case, the citationID is going to change but TPTRIPID remains same. While joining this VT table to CT,we are goint to get all the txns assigned to the TPTRIPID(Assigned and Vtolled). 
				JOIN LND_TBOS.TollPlus.TP_Trips TT ON TT.TpTripID=VT.TpTripID 
							AND TT.TripWith IN ('C')		-- Ex:1201323030 Invoice can be vtolled and then go back to violations. In order to avoid those txns, using tripwith='C'
				JOIN Stage.MigratedInvoice Rite ON Rite.InvoiceNumber = H.InvoiceNumber 
				JOIN LND_TBOS.TollPlus.TP_CustomerTrips TC WITH (NOLOCK)
							 ON TC.TpTripID = VT.TpTripID
								AND TC.PaymentStatusID = 456		--Paid
								AND TC.TripStatusID <> 5			--Adjusted
								AND TC.TransactionPostingType NOT IN ( 'Prepaid AVI', 'NTTA Fleet' )
								AND TC.OutstandingAmount = 0
				--WHERE H.InvoiceNumber IN (1187146926,1041625728)--(PartialVtoll)--1187146926-- FullyVtoll
				--WHERE Rite.InvoiceNumber=747518360
				GROUP BY H.InvoiceNumber,TC.TpTripID,VT.TripStatusID,TC.PaymentStatusID,VT.TollAmount,TC.OutstandingAmount,
					         VT.TpTripID,
					         VT.TripStatusID,
					         VT.PaymentStatusID,
					         VT.OutstandingAmount,VT.PBMTollAmount,VT.AVITollAmount,TC.TripStatusID
					) A
		GROUP BY A.InvoiceNumber
		), 
		cte AS (
				SELECT 
							H.InvoiceNumber,
							SUM(CASE WHEN CustTxnCategory IN ('TOLL') THEN 1 ELSE 0 END) TotalTxnCnt,
							SUM(CASE WHEN L.SourceViolationStatus='L' AND (VT.PaymentStatusID=456 OR VT.PaymentStatusID IS NULL) THEN 1 ELSE 0 END ) UnassignedTxnCnt, -- Out of 4, 1 txn got unassigned from an invoice and rest are vtolled then the Invoice status should be Vtoll.Ex:1120029424		
							SUM(CASE WHEN L.SourceViolationStatus='L' AND VT.PaymentStatusID IS NULL THEN l.Amount ELSE 0 END ) ExcusedTollsAdjusted --1030630051
						--select * 
					FROM LND_TBOS.TollPlus.Invoice_Header H WITH (NOLOCK)
					  JOIN LND_TBOS.TollPlus.Invoice_LineItems L WITH (NOLOCK)
								ON L.InvoiceID = H.InvoiceID					
					  LEFT JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT WITH (NOLOCK)
								ON ABS(L.LinkID) = VT.CitationID	
								AND L.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips'
						JOIN Stage.MigratedInvoice Rite ON Rite.InvoiceNumber = H.InvoiceNumber 
						--WHERE H.InvoiceNumber IN (1187146926,1041625728)
					--WHERE H.InvoiceNumber=1120029424 -- 1 Unassigned and 3 vtoll
					GROUP BY H.InvoiceNumber
		)

		SELECT CTE_Vtolls.InvoiceNumber,
			   cte.TotalTxnCnt TotalTxnCnt,
               CTE_Vtolls.VTollTxnCnt,
			   CTE.UnassignedTxnCnt,
			   CTE_Vtolls.UnassignedVtolledTxnCnt,
			   CTE_VTOLLS.VTollPaidTxnCnt,
			   CASE WHEN paidamount_VT=0 THEN '1900-01-01' ELSE CTE_Vtolls.FirstPaymentDate END FirstPaymentDate,
			   CASE WHEN paidamount_VT=0 THEN '1900-01-01' ELSE CTE_Vtolls.LastPaymentDate END LastPaymentDate,
			   CTE_Vtolls.PBMTollAmount,
			   CTE_Vtolls.AVITollAmount,
			   CTE_Vtolls.PremiumAmount,
			   CTE_Vtolls.Tolls,
               CTE_Vtolls.PaidAmount_VT,
			   (cte.ExcusedTollsAdjusted+TollsAdjusted) TollsAdjusted,
			   0 AS TollsAdjustedAfterVtoll,
			   0 AS AdjustedAmount_Excused,
			   0 AS ClassAdj,
               CTE_Vtolls.OutstandingAmount,
			   0 AS PaidTnxs,
			   CASE WHEN VTollTxnCnt = TotalTxnCnt  THEN 1 ELSE 0 END AS VtollFlag,
			   CASE WHEN VTollTxnCnt = TotalTxnCnt THEN '1 - Vtoll Invoice' 
					WHEN (VTollTxnCnt+UnassignedTxnCnt) = TotalTxnCnt THEN '1 - Vtoll Invoice' 
			   ELSE '0 - PartialVtoll Invoice' END AS VtollFlagDescription,
			   ISNULL(CAST(SYSDATETIME() AS DATETIME2(7)), '1900-01-01') AS EDW_Update_Date		
              
		FROM CTE_Vtolls
		LEFT JOIN cte ON cte.InvoiceNumber = CTE_Vtolls.InvoiceNumber

	
		-- Log 
		SET  @Log_Message = 'Loaded Stage.MigratedDimissedVToll'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, '-1', -1, 'I'
		
		-- Create statistics and swap table
		CREATE STATISTICS STATS_Stage_MigratedDismissedVtoll_000 ON Stage.MigratedDimissedVToll (InvoiceNumber);


		IF @Trace_Flag = 1 SELECT TOP 100 'Stage.MigratedDimissedVToll' TableName, * FROM Stage.MigratedDimissedVToll ORDER BY 2 DESC

		--=============================================================================================================
         -- Load Stage.MigratedUnassignedInvoice  -- to bring dismissed Unassigned Invoices
        --=============================================================================================================
        IF OBJECT_ID('Stage.MigratedUnassignedInvoice') IS NOT NULL DROP TABLE Stage.MigratedUnassignedInvoice;
        CREATE TABLE Stage.MigratedUnassignedInvoice  WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber)) 
        AS
        WITH CTE_Unassigned AS (
		SELECT 
		 ih.InvoiceNumber InvoiceNumber_Unass
		,COUNT(DISTINCT vt.CitationID) UnassignedTxnCnt -- select *
		,SUM(vt.TollAmount) Tolls
		FROM ( 
        SELECT tptripid FROM LND_TBOS.TollPlus.TP_ViolatedTrips 
        GROUP BY TpTripID
        HAVING COUNT(1)>1
        ) A 
        JOIN LND_TBOS.TollPlus.TP_ViolatedTrips vt ON vt.TpTripID = A.TpTripID            
        JOIN LND_TBOS.TollPlus.Invoice_LineItems ili WITH (NOLOCK)
             ON ABS(vt.CitationID) = ABS(ili.LinkID) 
			 AND ili.LinkSourceName='TOLLPLUS.TP_ViolatedTrips'
        JOIN LND_TBOS.TollPlus.Invoice_Header ih WITH (NOLOCK)
              ON ili.InvoiceID = ih.InvoiceID
		JOIN Stage.MigratedInvoice Rite ON Rite.InvoiceNumber = IH.InvoiceNumber 
         WHERE tripstatusid IN (171,115) AND ih.InvoiceNumber NOT IN (SELECT InvoiceNumber FROM Stage.MigratedDimissedVToll)		 
		 GROUP BY ih.InvoiceNumber
		 ),

		CTE_All AS (
		SELECT 
				H.InvoiceNumber,COUNT(DISTINCT VT.CitationID) TotalTxnCnt
		FROM LND_TBOS.TollPlus.Invoice_Header H WITH (NOLOCK)
		  JOIN LND_TBOS.TollPlus.Invoice_LineItems L WITH (NOLOCK)
					ON L.InvoiceID = H.InvoiceID
		  JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT WITH (NOLOCK)
					ON ABS(vt.CitationID) = ABS(L.LinkID) 
						AND L.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips'
		 GROUP BY H.InvoiceNumber
		 )
		 SELECT CTE_Unassigned.InvoiceNumber_Unass,
                CTE_Unassigned.UnassignedTxnCnt,
                CTE_All.InvoiceNumber,
                CTE_All.TotalTxnCnt,
				CTE_Unassigned.Tolls,
				1 AS UnassignedFlag
		FROM CTE_Unassigned
		JOIN cte_All ON cte_All.InvoiceNumber = CTE_Unassigned.InvoiceNumber_Unass
		WHERE cte_All.TotalTxnCnt=CTE_Unassigned.UnassignedTxnCnt
		

        -- Log 
        SET  @Log_Message = 'Loaded Stage.MigratedUnassignedInvoice'
        EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, '-1', -1, 'I'
        
        -- Create statistics and swap table
        CREATE STATISTICS STATS_Stage_MigratedUnassignedInvoice_000 ON Stage.MigratedUnassignedInvoice (InvoiceNumber);


        IF @Trace_Flag = 1 SELECT TOP 100 'Stage.MigratedUnassignedInvoice' TableName, * FROM Stage.MigratedUnassignedInvoice ORDER BY 2 DESC
	
		--=============================================================================================================
		-- Load Stage.MigratedNonTerminalInvoice
		--=============================================================================================================
		IF OBJECT_ID('Stage.NonTerminalInvoice') IS NOT NULL DROP TABLE Stage.NonTerminalInvoice;
		CREATE  TABLE Stage.NonTerminalInvoice  WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber)) 
		AS
		WITH CTE_FIRST_INV
		AS (
				SELECT * FROM (
				SELECT ROW_NUMBER() OVER (PARTITION BY IHF.InvoiceNumber ORDER BY (IHF.InvoiceID) ASC) RN_MIN,
				           IHF.InvoiceNumber,
				           IHF.InvoiceID,
				           IHF.SourceName,
				           IHF.LND_UpdateType
				
				    FROM LND_TBOS.TollPlus.Invoice_Header IHF
				        JOIN Stage.MigratedInvoice RI
				            ON RI.InvoiceNumber = IHF.InvoiceNumber
				             
				    WHERE IHF.LND_UpdateType <> 'D'
				          AND IHF.CreatedUser <> 'DCBInvoiceGeneration'
				          --AND IHF.InvoiceNumber = @invoicenumber
						  ) A WHERE A.RN_MIN=1
				  
		) ,
		     CTE_INV_DATE
		AS (
			SELECT InvoiceNumber,
		           MAX(MbsID) MbsID,
		           MAX(FirstNoticeDate) FirstNoticeDate,
		           MAX(SecondNoticeDate) SecondNoticeDate,
		           MAX(ThirdNoticeDate) ThirdNoticeDate,
		           MAX(LegalActionPendingDate) LegalActionPendingDate,
		           MAX(CitationDate) CitationDate,
		           MAX(DueDate) DueDate,
		           MAX(MbsGeneratedDate) MbsGeneratedDate,
		           DeleteFlag DeleteFlag
		
		    FROM
		    (
							SELECT  IHD.Invoicenumber,
									MAX(MBSH.MbsID) MbsID,
									COALESCE(RI.FirstNoticeDate_RI,MAX(CASE WHEN IHD.AgeStageID = 2 THEN CAST(IHD.InvoiceDate AS DATE) ELSE '1900-01-01' END)) FirstNoticeDate,
									COALESCE(RI.SecondNoticeDate_RI,MAX(CASE WHEN IHD.AgeStageID = 3 THEN CAST(IHD.InvoiceDate AS DATE) ELSE '1900-01-01' END)) SecondNoticeDate,
									COALESCE(RI.ThirdNoticeDate_RI,MIN(CASE WHEN IHD.AgeStageID = 4 THEN CAST(IHD.InvoiceDate AS DATE) ELSE '1900-01-01' END)) ThirdNoticeDate,
									COALESCE(RI.LegalActionPendingDate_RI,MAX(CASE WHEN IHD.AgeStageID = 5 THEN CAST(IHD.InvoiceDate AS DATE) ELSE '1900-01-01' END)) LegalActionPendingDate,
									COALESCE(RI.CitationDate_RI,CASE WHEN IHD.AgeStageID = 6 THEN MIN(CAST(IHD.InvoiceDate AS DATE)) ELSE '1900-01-01' END ) CitationDate,
									MAX(CAST(IHD.DueDate AS DATE)) DueDate,
									MAX(CAST(MBSH.MbsGeneratedDate AS DATE)) MbsGeneratedDate,
									CAST(CASE WHEN IHD.LND_UpdateType = 'D' OR MBSI.LND_UpdateType = 'D' OR MBSH.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT) DeleteFlag
									--SELECT *  
							FROM LND_TBOS.TollPlus.Invoice_Header IHD
							JOIN Stage.MigratedInvoice RI ON RI.InvoiceNumber = IHD.InvoiceNumber
							LEFT JOIN LND_TBOS.TollPlus.MbsInvoices MBSI ON MBSI.InvoiceNumber = IHD.InvoiceNumber AND MBSI.LND_UpdateType<>'D'
							LEFT JOIN LND_TBOS.TollPlus.MbsHeader MBSH ON MBSH.MbsID = MBSI.MbsID AND MBSH.LND_UpdateType<>'D'
							WHERE IHD.LND_UpdateType<>'D' AND  IHD.CREATEDUSER <> 'DCBInvoiceGeneration'  	
							GROUP BY IHD.InvoiceNumber,CAST(CASE WHEN IHD.LND_UpdateType = 'D' OR MBSI.LND_UpdateType = 'D' OR MBSH.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT),IHD.AgeStageID
									 ,RI.FirstNoticeDate_RI,RI.SecondNoticeDate_RI,RI.ThirdNoticeDate_RI,RI.LegalActionPendingDate_RI,RI.CitationDate_RI,RI.DueDate_RI
						
			) a
		    GROUP BY InvoiceNumber,
		             a.DeleteFlag
		  ),
		 
		 CTE_Tolls AS 
		 (
			 SELECT ReferenceInvoiceID, SUM(invoiceamount) invoiceamount,SUM(Tolls) Tolls,
					SUM(A.PBMTollAmount) PBMTollAmount,
					SUM(A.AVITollAmount) AVITollAmount,
					SUM(PBMTollAmount-AVITollAmount) PremiumAmount
			 FROM (
						SELECT IL.ReferenceInvoiceID,
								CASE  WHEN  vt.TpTripID IS NULL THEN ISNULL(ABS(IL.LinkID),0) ELSE vt.TpTripID END AS TptripID,
								COUNT(CASE WHEN vt.TpTripID IS NULL THEN ISNULL(ABS(IL.LinkID),0) ELSE vt.TpTripID END)  TxnCnt,
								CASE 
									WHEN COUNT(vt.TpTripID)=1 THEN SUM(CASE
										                  WHEN CustTxnCategory IN ('TOLL','FEE' ) THEN
										                      IL.Amount
										                  ELSE
										                      0
														  END 
																		)
									 WHEN ISNULL(COUNT(DISTINCT VT.TpTripID),0) <> ISNULL(COUNT(VT.TpTripID),0) AND SUM(CASE WHEN vt.TripStatusID IN (171,170,118,115) THEN 1 ELSE 0 END)>0  THEN SUM(CASE
										                  WHEN CustTxnCategory IN ('TOLL','FEE' ) THEN
										                      IL.Amount
										                  ELSE
										                      0
														  END 
																		)
								 
									 WHEN ISNULL(COUNT(DISTINCT VT.TpTripID),0) <> ISNULL(COUNT(VT.TpTripID),0) AND SUM(CASE WHEN vt.TripStatusID IN (2,153,154) THEN 1 ELSE 0 END)>1 AND SUM(CASE WHEN vt.TripStatusID IN (171,170,118,115) THEN 1 ELSE 0 END)=0  THEN  (SUM(CASE
										                  WHEN CustTxnCategory IN ('TOLL','FEE' ) THEN
										                      IL.Amount
										                  ELSE
										                      0
														  END 
																		)/COUNT(vt.TpTripID))
									WHEN ISNULL(COUNT(VT.TpTripID),0)=0 THEN SUM(CASE
										                  WHEN CustTxnCategory IN ('TOLL','FEE' ) THEN
										                      IL.Amount
										                  ELSE
										                      0
														  END 
																		)
								
								ELSE 0 END 
														 InvoiceAmount,
								
								   CASE WHEN COUNT(vt.TpTripID)=1 THEN SUM(CASE
										                  WHEN IL.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips' THEN
										                      IL.Amount
										                  ELSE
										                      0
										              END
																		)
									WHEN COUNT(ISNULL(vt.TpTripID,0))= 0 THEN SUM(CASE
										                  WHEN IL.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips' THEN
										                      IL.Amount
										                  ELSE
										                      0
										              END		)
									 WHEN ISNULL(COUNT(DISTINCT VT.TpTripID),0) <> ISNULL(COUNT(VT.TpTripID),0) AND SUM(CASE WHEN vt.TripStatusID IN (171,170,118,115) THEN 1 ELSE 0 END)>0  THEN SUM(CASE
										                  WHEN IL.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips' THEN
										                      IL.Amount
										                  ELSE
										                      0
										              END
																		)
								 
									 WHEN ISNULL(COUNT(DISTINCT VT.TpTripID),0) <> ISNULL(COUNT(VT.TpTripID),0) AND SUM(CASE WHEN vt.TripStatusID IN (2,153,154) THEN 1 ELSE 0 END)>1 AND SUM(CASE WHEN vt.TripStatusID IN (171,170,118,115) THEN 1 ELSE 0 END)=0  THEN  (SUM(CASE
										                  WHEN IL.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips' THEN
										                      IL.Amount
										                  ELSE
										                      0
										              END
																		)/COUNT(vt.TpTripID))
									 WHEN ISNULL(COUNT(VT.TpTripID),0)=0 THEN SUM( CASE
										                  WHEN  IL.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips' THEN
										                      IL.Amount
										                  ELSE
										                      0
										              END
																			)
									ELSE 0
									END Tolls,
									CASE WHEN COUNT(vt.TpTripID)=1 THEN SUM(vt.PBMTollAmount)
							  WHEN Isnull(Count(Distinct VT.TpTripID),0) <> Isnull(Count(VT.TpTripID),0) AND SUM(CASE WHEN vt.TripStatusID IN (171,170,118,115) THEN 1 ELSE 0 END)>0  THEN SUM(vt.PBMTollAmount)
							  WHEN Isnull(Count(Distinct VT.TpTripID),0) <> Isnull(Count(VT.TpTripID),0) AND SUM(CASE WHEN vt.TripStatusID IN (2,153,154) THEN 1 ELSE 0 END)>1 AND SUM(CASE WHEN vt.TripStatusID IN (171,170,118,115) THEN 1 ELSE 0 END)=0 THEN (SUM(vt.PBMTollAmount)/COUNT(vt.TpTripID))
						 ELSE 0 END AS PBMTollAmount,
						 CASE WHEN COUNT(vt.TpTripID)=1 THEN SUM(vt.AVITollAmount)
							  WHEN Isnull(Count(Distinct VT.TpTripID),0) <> Isnull(Count(VT.TpTripID),0) AND SUM(CASE WHEN vt.TripStatusID IN (171,170,118,115) THEN 1 ELSE 0 END)>0  THEN SUM(vt.AVITollAmount)
							  WHEN Isnull(Count(Distinct VT.TpTripID),0) <> Isnull(Count(VT.TpTripID),0) AND SUM(CASE WHEN vt.TripStatusID IN (2,153,154) THEN 1 ELSE 0 END)>1 AND SUM(CASE WHEN vt.TripStatusID IN (171,170,118,115) THEN 1 ELSE 0 END)=0 THEN (SUM(vt.AVITollAmount)/COUNT(vt.TpTripID))
						 ELSE 0 END AS AVITollAmount
				FROM  Stage.MigratedInvoice RI 
				JOIN LND_TBOS.TollPlus.Invoice_LineItems IL  ON RI.InvoiceNumber = IL.ReferenceInvoiceID  
				LEFT JOIN LND_TBOS.TollPlus.TP_ViolatedTrips vt ON ABS(IL.LinkID)=vt.CitationID AND IL.CustTxnCategory='TOLL'
				GROUP BY IL.ReferenceInvoiceID,
						 CASE  WHEN  vt.TpTripID IS NULL THEN ISNULL(ABS(IL.LinkID),0) ELSE vt.TpTripID END
				) A GROUP BY A.ReferenceInvoiceID
		),
		
		MI AS (
		SELECT CAST(CTE_CURR_INV.InvoiceNumber AS BIGINT) InvoiceNumber,
		       CTE_FIRST_INV.InvoiceID FirstInvoiceID,
		       CTE_CURR_INV.InvoiceID CurrentInvoiceID,
		       CTE_CURR_INV.CustomerID,
		       CASE
		           WHEN CTE_FIRST_INV.SourceName IS NOT NULL THEN
		               1
		           ELSE
		               0
		       END MigratedFlag,
		       CTE_CURR_INV.AgeStageID AgeStageID,
		       ISNULL(CTE_CURR_INV.CollectionStatus, -1) CollectionStatusID,
		       ISNULL(CTE_INV_DATE.MbsID, -1) CurrMbsID,
		       CTE_CURR_INV.VehicleID,
		       COALESCE(CTE_CURR_INV.ZipCashDate_RI,MAX(   CASE
		                  WHEN IL.TxnType = 'VTOLL' THEN
		                      CAST(IL.CreatedDate AS DATE)
						END 
		          )) ZipCashDate,
		       CTE_INV_DATE.FirstNoticeDate,
			   CTE_INV_DATE.SecondNoticeDate,
			   CTE_INV_DATE.ThirdNoticeDate,
		       CTE_INV_DATE.LegalActionPendingDate,
		       CTE_INV_DATE.CitationDate,
			   CTE_INV_DATE.DueDate,
			   
		       ISNULL(CTE_INV_DATE.MbsGeneratedDate, '1900-01-01') CurrMbsGeneratedDate,
			   COALESCE(CTE_CURR_INV.FirstpaymentDate_RI,PMT.FirstPaymentDate) FirstPaymentDate,
			   COALESCE(CTE_CURR_INV.LastPaymentDate_RI,PMT.LastPaymentDate) LastPaymentDate,
			   FP.FirstFeePaymentDate,
			   FP.LastFeePaymentDate,

		       DIS.InvoiceStatusID,
		
			   ---------------------------------------TxnCounts
			   COUNT(DISTINCT TPV.TpTripID) AS TxnCnt,
		
			 ---------------------------------------- Amounts
		       CAST(SUM(   CASE
		                  WHEN CustTxnCategory IN ( 'TOLL', 'FEE' ) THEN
		                      IL.Amount
		                  ELSE
		                      0
		              END
		          ) AS DECIMAL(19,2)) AS InvoiceAmount,
		       CAST(SUM(   CASE
		                  WHEN IL.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips' THEN
		                      IL.Amount
		                  ELSE
		                      0
		              END
		          ) AS DECIMAL(19,2)) AS  Tolls,
		       CAST(ISNULL(F.FNFees, 0) AS DECIMAL(19,2)) AS  FNFees,
		       CAST(ISNULL(F.SNFees, 0) AS DECIMAL(19,2)) AS  SNFees, 
		
			   CAST(ISNULL(TP.TollsPaid,0) AS DECIMAL(19,2))  AS  TollsPaid,
			   CAST(ISNULL(FP.FNFeesPaid,0) AS DECIMAL(19,2))  AS FNFeesPaid,
			   CAST(ISNULL(FP.SNFeesPaid,0) AS DECIMAL(19,2))  AS SNFeesPaid,
			  
			   CAST(ISNULL(TA.TollsAdjusted,0) AS DECIMAL(19,2))   AS  TollsAdjusted,
			   CAST(ISNULL(FA.FNFeesAdjusted,0) AS DECIMAL(19,2))  AS FNFeesAdjusted,
			   CAST(ISNULL(FA.SNFeesAdjusted,0) AS DECIMAL(19,2))  AS SNFeesAdjusted,
			   SUM(   CASE
		                  WHEN TPV.TripStatusID = 170 THEN
		                      TPV.TollAmount
		                  ELSE
		                      0
		              END
		          ) ExcusedAmount,
		
		
		       ISNULL(CAST(SYSDATETIME() AS DATETIME2(7)), '1900-01-01') AS EDW_Update_Date
		
		FROM Stage.MigratedInvoice CTE_CURR_INV
		    JOIN CTE_FIRST_INV CTE_FIRST_INV
		        ON CTE_CURR_INV.InvoiceNumber = CTE_FIRST_INV.InvoiceNumber
		    JOIN CTE_INV_DATE CTE_INV_DATE
		        ON CTE_CURR_INV.InvoiceNumber = CTE_INV_DATE.InvoiceNumber
		    JOIN LND_TBOS.TollPlus.Invoice_LineItems IL
		        ON IL.ReferenceInvoiceID = CTE_CURR_INV.InvoiceNumber
		           AND IL.LND_UpdateType <> 'D'
		    LEFT JOIN LND_TBOS.TollPlus.TP_ViolatedTrips TPV
		        ON ABS(TPV.CitationID) = ABS(IL.LinkID)
		           AND LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips'
		           AND TPV.LND_UpdateType <> 'D'
		    LEFT JOIN EDW_TRIPS.dbo.Dim_InvoiceStatus DIS
		        ON CTE_CURR_INV.InvoiceStatus = DIS.InvoiceStatusCode
			LEFT JOIN EDW_TRIPS.dbo.Dim_InvoiceStage I
		        ON CTE_CURR_INV.AgeStageID = I.InvoiceStageID
		    LEFT JOIN
		    (
		        SELECT IL.ReferenceInvoiceID InvoiceNumber, ---- To calculate Fees Due
		
		               ISNULL(SUM(   CASE
		                                 WHEN IL.TxnType = 'FSTNTVFEE' THEN ICT.Amount
		                                 ELSE  0
		                             END
		                         ),
		                      0
		                     ) AS FNFees,
		               ISNULL(SUM(   CASE
		                                 WHEN IL.TxnType = 'SECNTVFEE' THEN ICT.Amount
		                                 ELSE  0
		                             END
		                         ),
		                      0
		                     ) AS SNFees
		        FROM LND_TBOS.TollPlus.Invoice_LineItems IL
		            JOIN LND_TBOS.TollPlus.Invoice_Charges_Tracker ICT
		                ON IL.LinkID = ICT.InvoiceChargeID
		                   AND ICT.LND_UpdateType <> 'D'
		        WHERE IL.LinkSourceName = 'TollPlus.Invoice_Charges_Tracker'
		              AND IL.TxnType IN ( 'SECNTVFEE', 'FSTNTVFEE' )
		              AND IL.LND_UpdateType <> 'D'
					  
		        GROUP BY IL.ReferenceInvoiceID
		    ) F
		        ON CTE_CURR_INV.InvoiceNumber = F.InvoiceNumber
			LEFT JOIN														 ---------------------- TollsPaid
			( 
				SELECT  IL.ReferenceInvoiceID InvoiceNumber,
						SUM(CASE WHEN IL.SourceViolationStatus='L' THEN 0 ELSE ISNULL((VTRT.AmountReceived * -1), 0) END) AS TollsPaid		 -- select * 
				FROM LND_TBOS.TollPlus.Invoice_LineItems IL 
				JOIN Stage.MigratedInvoice RI ON RI.InvoiceNumber=IL.ReferenceInvoiceID AND IL.LinkSourceName='TOLLPLUS.TP_ViolatedTrips'		
					 AND IL.LinkSourceName='TOLLPLUS.TP_ViolatedTrips'
				JOIN
									    (
									        SELECT CitationID,
									               VTRT.InvoiceID,
									               SUM(AmountReceived) AmountReceived
									        FROM LND_TBOS.TollPlus.TP_Violated_Trip_Receipts_Tracker VTRT
									        WHERE VTRT.LinkSourceName IN ('FINANCE.PAYMENTTXNS')
									              AND VTRT.LND_UpdateType <> 'D' 
									        GROUP BY CitationID,
									                 VTRT.InvoiceID
									    ) VTRT
									        ON VTRT.CitationID = ABS(IL.LinkID)
				
					GROUP BY IL.ReferenceInvoiceID
			 ) TP ON TP.InvoiceNumber = CTE_CURR_INV.InvoiceNumber
			
			LEFT JOIN (																----------------------- FN & SN Fees Paid
									SELECT IL.ReferenceInvoiceID,
										 MIN(IRT.TxnDate) FirstFeePaymentDate,
										 MAX(IRT.TxnDate) LastFeePaymentDate,
										 ISNULL(SUM(CASE WHEN IL.TxnType = 'FSTNTVFEE' THEN (IRT.AmountReceived * -1) ELSE 0 END),0) FNFeesPaid,
										 ISNULL(SUM(CASE WHEN IL.TxnType = 'SECNTVFEE' THEN (IRT.AmountReceived * -1) ELSE 0 END),0) SNFeesPaid 
									FROM  LND_TBOS.TollPlus.Invoice_LineItems IL
										  JOIN LND_TBOS.TollPlus.TP_Invoice_Receipts_Tracker IRT 
												ON IL.LinkID = IRT.Invoice_ChargeID	AND IRT.LND_UpdateType<>'D'
										  JOIN Stage.MigratedInvoice RI ON RI.InvoiceNumber=IL.ReferenceInvoiceID 
									   AND IRT.LinkSourceName = 'FINANCE.PAYMENTTXNS' 
									  WHERE  IL.LinkSourceName = 'TOLLPLUS.Invoice_Charges_tracker' AND IL.LND_UpdateType<>'D'							  
									  --AND IL.ReferenceInvoiceID=1236841109 (Invoice that has only Fee payments no toll payments							  
									  GROUP BY IL.ReferenceInvoiceID
						) FP ON FP.ReferenceInvoiceID = CTE_CURR_INV.InvoiceNumber
		
			LEFT JOIN																---------------------- TollsAdjusted
			( 
				SELECT IL.ReferenceInvoiceID InvoiceNumber,
					   SUM(CASE WHEN VTRT.UnassignedTxnFlag=1 AND IL.SourceViolationStatus<>'L' THEN 0 
							    WHEN VTRT.UnassignedTxnFlag=1 AND IL.SourceViolationStatus='L' AND (VTRT.AmountReceived*-1) = vtrt.CitationCnt*IL.Amount THEN IL.Amount --Ex: 1204001608,1179573904,1180506347- Txns on this(1180506347) invoice go unassigned from this and another invoice 1065912065. In order to show the adjustment only fom one invoice using this condition. currently this txn is on 1220573837 
								WHEN VTRT.UnassignedTxnFlag=1 AND IL.SourceViolationStatus='L' THEN ISNULL((VTRT.AmountReceived * -1),0)
								WHEN VTRT.UnassignedTxnFlag=0 AND IL.SourceViolationStatus='L' THEN 0
							ELSE ISNULL((VTRT.AmountReceived * -1), 0) END) AS  TollsAdjusted  -- select * 
				FROM 
				LND_TBOS.TollPlus.Invoice_LineItems IL 
				JOIN Stage.MigratedInvoice RI ON RI.InvoiceNumber=IL.ReferenceInvoiceID  AND IL.LinkSourceName='TOLLPLUS.TP_ViolatedTrips'
				JOIN
						 (
									        SELECT  ABS(CitationID) CitationID,
									               -- VTRT.InvoiceID InvoiceID,
												   COUNT(ABS(CitationID)) CitationCnt,
													CASE WHEN VTRT.CitationID<0 THEN 1 ELSE 0 END AS UnassignedTxnFlag,
												   SUM(ISNULL(VTRT.AmountReceived,0) ) AmountReceived -- select *									
											FROM  LND_TBOS.TollPlus.TP_Violated_Trip_Receipts_Tracker VTRT 									 
											WHERE VTRT.LinkSourceName IN ('FINANCE.ADJUSTMENTS') AND VTRT.LND_UpdateType <> 'D'	
											GROUP  BY ABS(CitationID),
		                                              CASE  WHEN VTRT.CitationID < 0 THEN 1 ELSE  0 END
		                                              --VTRT.InvoiceID 
						) VTRT
									        ON VTRT.CitationID = ABS(IL.LinkID)
				 
				 GROUP BY IL.ReferenceInvoiceID
			) TA ON TA.InvoiceNumber = CTE_CURR_INV.InvoiceNumber
			LEFT JOIN																	--- Bring the First and Second Notice Fee Adjustemnts to calculate the Invoice Status
				
		        (
						SELECT 
						IL.ReferenceInvoiceID,
						ISNULL (SUM(CASE WHEN IL.TxnType='FSTNTVFEE' THEN (AmountReceived*-1) ELSE 0 END),0)  FNFeesAdjusted ,
						ISNULL (SUM(CASE WHEN IL.TxnType='SECNTVFEE' THEN (AmountReceived*-1) ELSE 0 END),0)  SNFeesAdjusted 
						FROM LND_TBOS.Tollplus.Invoice_LineItems IL	
						JOIN LND_TBOS.TollPlus.TP_Invoice_Receipts_Tracker IRT	 ON IL.LinkID = IRT.Invoice_ChargeID  AND IRT.LND_UpdateType <> 'D'
						JOIN Stage.MigratedInvoice RI ON RI.InvoiceNumber=IL.ReferenceInvoiceID 
						WHERE IRT.LinkSourceName = 'FINANCE.ADJUSTMENTS' 
							  AND IL.TxnType IN ('SECNTVFEE','FSTNTVFEE')
							  AND IL.LinkSourceName = 'TOLLPLUS.invoice_Charges_tracker'
							  AND IL.LND_UpdateType <> 'D'
							  GROUP BY IL.ReferenceInvoiceID		
		
				) FA ON FA.ReferenceInvoiceID = CTE_CURR_INV.InvoiceNumber	
		   LEFT JOIN stage.InvoicePayment PMT ON PMT.InvoiceNumber = CTE_CURR_INV.InvoiceNumber
		
		--WHERE CAST(CTE_CURR_INV.InvoiceNumber AS BIGINT) = 733772415
		GROUP BY CAST(CTE_CURR_INV.InvoiceNumber AS BIGINT),
                 CASE
                 WHEN CTE_FIRST_INV.SourceName IS NOT NULL THEN
                 1
                 ELSE
                 0
                 END,
                 ISNULL(CTE_CURR_INV.CollectionStatus, -1),
                 ISNULL(CTE_INV_DATE.MbsID, -1),
				 CTE_CURR_INV.ZipCashDate_RI,
				 CTE_INV_DATE.FirstNoticeDate, 
                 CTE_INV_DATE.SecondNoticeDate, 
                 CTE_INV_DATE.ThirdNoticeDate, 
                 CTE_INV_DATE.LegalActionPendingDate,
                 CTE_INV_DATE.citationDate, 
                 CTE_INV_DATE.DueDate, 
                 ISNULL(CTE_INV_DATE.MbsGeneratedDate, '1900-01-01'),
				 COALESCE(CTE_CURR_INV.FirstpaymentDate_RI,pmt.FirstPaymentDate) ,
			     COALESCE(CTE_CURR_INV.LastPaymentDate_RI,PMT.LastPaymentDate),
				 FP.FirstFeePaymentDate,
				 FP.LastFeePaymentDate,
                 ISNULL(F.FNFees, 0),
                 ISNULL(F.SNFees, 0),
				 ISNULL(TP.TollsPaid, 0),
                 ISNULL(FP.FNFeesPaid, 0),
                 ISNULL(FP.SNFeesPaid, 0),
				 ISNULL(TA.TollsAdjusted, 0),
                 ISNULL(FA.FNFeesAdjusted, 0),
                 ISNULL(FA.SNFeesAdjusted, 0),
                 CTE_FIRST_INV.InvoiceID,
                 CTE_CURR_INV.InvoiceID,
                 CTE_CURR_INV.CustomerID,
                 CTE_CURR_INV.AgeStageID,
                 CTE_CURR_INV.VehicleID,
				 DIS.InvoiceStatusID
			) SELECT MI.InvoiceNumber,
                     MI.FirstInvoiceID,
                     MI.CurrentInvoiceID,
                     MI.CustomerID,
                     MI.MigratedFlag,
                     MI.AgeStageID,
                     MI.CollectionStatusID,
                     MI.CurrMbsID,
                     MI.VehicleID,
                     MI.ZipCashDate,
                     MI.FirstNoticeDate,
                     MI.SecondNoticeDate,
                     MI.ThirdNoticeDate,
                     MI.LegalActionPendingDate,
                     MI.CitationDate,
                     MI.DueDate,
                     MI.CurrMbsGeneratedDate,
					 MI.FirstPaymentDate,
					 MI.LastPaymentDate,
					 MI.FirstFeePaymentDate,
					 MI.LastFeePaymentDate,
                     MI.InvoiceStatusID,                     
                     MI.TxnCnt,
					 CAST(CASE WHEN VT.VtollFlag=1 THEN (VT.Tolls+MI.FNFees+MI.SNFees) ELSE T.InvoiceAmount END AS DECIMAL(19,2)) AS InvoiceAmount,
                     CAST(CASE WHEN VT.VtollFlag=1 THEN VT.PBMTollAmount ELSE T.PBMTollAmount END AS DECIMAL(19,2)) AS PBMTollAmount,
                     CAST(CASE WHEN VT.VtollFlag=1 THEN VT.AVITollAmount ELSE T.AVITollAmount END AS DECIMAL(19,2)) AS AVITollAmount,
                     CAST(CASE WHEN VT.VtollFlag=1 THEN VT.PremiumAmount ELSE T.PremiumAmount END AS DECIMAL(19,2)) AS PremiumAmount,
					 CAST(CASE WHEN VT.VtollFlag=1 THEN VT.Tolls ELSE T.Tolls END AS DECIMAL(19,2)) AS Tolls,
                     CAST(MI.FNFees AS DECIMAL(19,2)) AS FNFees,
                     CAST(MI.SNFees AS DECIMAL(19,2)) AS SNFees,
                     CAST(CASE WHEN VT.VTollFlag=1 THEN VT.PaidAmount_VT ELSE ISNULL(MI.TollsPaid,0) END AS DECIMAL(19,2))  AS  TollsPaid,
                     CAST(MI.FNFeesPaid AS DECIMAL(19,2)) AS FNFeesPaid,
                     CAST(MI.SNFeesPaid AS DECIMAL(19,2)) AS SNFeesPaid,
                     CAST(CASE WHEN VT.VTollFlag=1 THEN VT.TollsAdjusted ELSE ISNULL(MI.TollsAdjusted,0) END AS DECIMAL(19,2)) AS  TollsAdjusted,
                     CAST(MI.FNFeesAdjusted AS DECIMAL(19,2)) AS FNFeesAdjusted ,
                     CAST(MI.SNFeesAdjusted AS DECIMAL(19,2)) AS SNFeesAdjusted ,
                     CAST(MI.ExcusedAmount AS DECIMAL(19,2)) AS ExcusedAmount,
                     MI.EDW_Update_Date
					 FROM MI
					 JOIN CTE_Tolls T ON T.ReferenceInvoiceID = MI.InvoiceNumber
					 LEFT JOIN  Stage.MigratedDimissedVToll VT ON VT.InvoiceNumber = MI.InvoiceNumber
					 
					 
			 -- Log 
        SET  @Log_Message = 'Loaded Stage.NonTerminalInvoice'
        EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, '-1', -1, 'I'
        
        -- Create statistics and swap table
        CREATE STATISTICS STATS_Stage_NonTerminalInvoice_000 ON Stage.NonTerminalInvoice (InvoiceNumber);
		CREATE STATISTICS STATS_Stage_NonTerminalInvoice_001 ON Stage.NonTerminalInvoice (FirstInvoiceID)
		CREATE STATISTICS STATS_Stage_NonTerminalInvoice_002 ON Stage.NonTerminalInvoice (CurrentInvoiceID)
		CREATE STATISTICS STATS_Stage_NonTerminalInvoice_003 ON Stage.NonTerminalInvoice (CustomerID)
		CREATE STATISTICS STATS_Stage_NonTerminalInvoice_004 ON Stage.NonTerminalInvoice (AgeStageID)

        IF @Trace_Flag = 1 SELECT TOP 100 'Stage.NonTerminalInvoice' TableName, * FROM Stage.NonTerminalInvoice ORDER BY 2 DESC


		--=============================================================================================================
		-- Load Stage.MigratedNonTerminalInvoice
		--=============================================================================================================
		
		IF OBJECT_ID('Stage.MigratedNonTerminalInvoice') IS NOT NULL DROP TABLE Stage.MigratedNonTerminalInvoice;
		CREATE  TABLE Stage.MigratedNonTerminalInvoice  WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber)) 
		AS

			SELECT 
					* ,
					CASE WHEN ISNULL(A.VtollFlag,-1)=1 THEN 99999				
						WHEN A.UnassignedFlag=1 AND (A.FNFeesOutStandingAmount=0 AND A.SNFeesOutStandingAmount=0)  THEN 99998
						WHEN ISNULL(A.VtollFlag,-1) IN (0,-1) AND A.UnassignedFlag=-1  AND ((A.ExpectedAmount-A.AdjustedAmount)=A.PaidAmount) AND (A.ExpectedAmount-A.AdjustedAmount)>0 AND ((FnFeespaid+FnfeesAdjusted)=FNFees) AND ((SNFeespaid+SNFeesAdjusted)=SNFees)  THEN 516
						WHEN ISNULL(A.VtollFlag,-1) IN (0,-1) AND A.UnassignedFlag=-1  AND  A.PaidAmount>0  AND (A.ExpectedAmount-A.AdjustedAmount)>A.PaidAmount  THEN 515
						WHEN ISNULL(A.VtollFlag,-1)=-1 AND A.UnassignedFlag=-1  AND (A.PaidAmount=0 OR A.PaidAmount<0) AND (A.ExpectedAmount-A.AdjustedAmount)>0 AND (A.ExpectedAmount>A.AdjustedAmount) THEN 4370
						WHEN ISNULL(A.VtollFlag,-1)=-1 AND A.UnassignedFlag=-1  AND A.PaidAmount=0 AND A.AdjustedAmount=A.ExpectedAmount THEN 4434						
					ELSE -1
				   END EDW_InvoiceStatusID
			
			FROM (
			SELECT MI.InvoiceNumber,
		           MI.FirstInvoiceID,
		           MI.CurrentInvoiceID,
		           MI.CustomerID,
		           MI.MigratedFlag,
				   ISNULL(VT.VtollFlag,-1) VTollFlag,
				   (CASE WHEN UI.InvoiceNumber IS NOT NULL THEN 1 ELSE -1 END ) AS UnassignedFlag,
		           MI.AgeStageID,
		           MI.CollectionStatusID,
		           MI.CurrMbsID,
		           MI.VehicleID,
		           MI.ZipCashDate,
		           MI.FirstNoticeDate,
		           MI.SecondNoticeDate,
		           MI.ThirdNoticeDate,
		           MI.LegalActionPendingDate,
		           MI.CitationDate,
		           MI.DueDate,
		           MI.CurrMbsGeneratedDate,
				   COALESCE(CASE WHEN ISNULL(VT.VtollFlag,-1)=1 THEN CAST(ISNULL(VT.FirstPaymentDate,'1900-01-01') AS DATE)
								 WHEN ISNULL(VT.VtollFlag,-1)=1 AND VT.PaidAmount_VT=0 AND VT.Tolls=(CASE WHEN ISNULL(VT.VtollFlag,-1)=1 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)
																										ELSE MI.TollsAdjusted END) THEN '1900-01-01' -- This is because paid date is taken from customer trips posted date. eventhough there is no payment(tollspaid=0), there will be a posted date for that invoice
								 
							END,
							CASE WHEN ISNULL(VT.VtollFlag,-1)=0 THEN COALESCE(CAST(ISNULL(VT.FirstPaymentDate,'1900-01-01') AS DATE),CAST(ISNULL(MI.FirstPaymentDate,'1900-01-01') AS DATE))
							ELSE CAST(ISNULL(MI.FirstPaymentDate,'1900-01-01') AS DATE) END 
							)
				   AS FirstPaymentDate,
                        
				   COALESCE(CASE WHEN ISNULL(VT.VtollFlag,-1)=1 THEN CAST(ISNULL(VT.LastPaymentDate,'1900-01-01') AS DATE)
							WHEN ISNULL(VT.VtollFlag,-1)=1 AND VT.PaidAmount_VT=0 AND VT.Tolls=(CASE WHEN ISNULL(VT.VtollFlag,-1)=1 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)
																										ELSE MI.TollsAdjusted END) THEN '1900-01-01' -- This is because paid date is taken from customer trips posted date. eventhough there is no payment(tollspaid=0), there will be a posted date for that invoice
						
							END,
							CASE WHEN ISNULL(VT.VtollFlag,-1)=0 THEN COALESCE(CAST(ISNULL(VT.LastPaymentDate,'1900-01-01') AS DATE),CAST(ISNULL(MI.LastPaymentDate,'1900-01-01') AS DATE))
							ELSE CAST(ISNULL(MI.LastPaymentDate,'1900-01-01') AS DATE) END 
							)
					AS LastPaymentDate,
				   MI.FirstFeePaymentDate,
				   MI.LastFeePaymentDate,
		           MI.InvoiceStatusID,
		           MI.TxnCnt,
				   MI.InvoiceAmount,
		           MI.PBMTollAmount,
		           MI.AVITollAmount,
		           MI.PremiumAmount,
				   MI.ExcusedAmount,
		
				   ------- EA
				   MI.Tolls,
		           MI.FNFees,
		           MI.SNFees,
				   CAST((MI.Tolls+MI.FNFees+MI.SNFees) AS DECIMAL(19,2)) AS  ExpectedAmount,
		
				   ------- AA
		           CAST(CASE WHEN VT.VtollFlag=0 AND MI.TollsAdjusted=0 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+ISNULL (MI.TollsAdjusted,0) -- This is for the vtoll adjustments that is not coming from  VTRT.Tolladj table, so bringing it from Customer trips table for vtoll adj.Ex:1230002032
						WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 AND (VT.PaidAmount_VT) > ISNULL (MI.TollsAdjusted,0) THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+((VT.PaidAmount_VT)-ISNULL(MI.TollsAdjusted,0))+ISNULL(MI.ExcusedAmount,0) -- this condition is for credit adjustment and amount that is not coming from VTRT table ex:1234440179 
						WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 THEN ISNULL(MI.TollsAdjusted,0)-(VT.PaidAmount_VT)-- this is for adjustments that happened in VTRT table and vtoll adj (In order to avoid double adjustments from two tables. Ex:1225411445)
						ELSE ISNULL(MI.TollsAdjusted,0)
				   END AS DECIMAL(19,2)) AS TollsAdjusted,
				   CAST(MI.FNFeesAdjusted AS DECIMAL(19,2)) AS FNFeesAdjusted,
				   CAST(MI.SNFeesAdjusted AS DECIMAL(19,2)) AS SNFeesAdjusted,
		
				   CAST(((CASE WHEN VT.VtollFlag=0 AND MI.TollsAdjusted=0 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+ISNULL (MI.TollsAdjusted,0) -- This is for the vtoll adjustments that is not coming from  VTRT.Tolladj table, so bringing it from Customer trips table for vtoll adj.Ex:1230002032
						WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 AND (VT.PaidAmount_VT) > ISNULL (MI.TollsAdjusted,0) THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+((VT.PaidAmount_VT)-ISNULL(MI.TollsAdjusted,0))+ISNULL(MI.ExcusedAmount,0) -- this condition is for credit adjustment and amount that is not coming from VTRT table ex:1234440179 
						WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 THEN ISNULL(MI.TollsAdjusted,0)-(VT.PaidAmount_VT)-- this is for adjustments that happened in VTRT table and vtoll adj (In order to avoid double adjustments from two tables. Ex:1225411445)
						ELSE ISNULL(MI.TollsAdjusted,0)
				   END ) + MI.FNFeesAdjusted + MI.SNFeesAdjusted) AS DECIMAL(19,2)) 
				   AS AdjustedAmount,
		
				   --------- AEA
				   ---------- AET = ET-TA
				   CAST((MI.Tolls - 
									 CASE WHEN VT.VtollFlag=0 AND MI.TollsAdjusted=0 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+ISNULL (MI.TollsAdjusted,0) -- This is for the vtoll adjustments that is not coming from  VTRT.Tolladj table, so bringing it from Customer trips table for vtoll adj.Ex:1230002032
									 WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 AND (VT.PaidAmount_VT) > ISNULL (MI.TollsAdjusted,0) THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+((VT.PaidAmount_VT)-ISNULL(MI.TollsAdjusted,0))+ISNULL(MI.ExcusedAmount,0) -- this condition is for credit adjustment and amount that is not coming from VTRT table ex:1234440179 
									 WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 THEN ISNULL(MI.TollsAdjusted,0)-(VT.PaidAmount_VT)-- this is for adjustments that happened in VTRT table and vtoll adj (In order to avoid double adjustments from two tables. Ex:1225411445)
									 ELSE ISNULL(MI.TollsAdjusted,0) END ) AS DECIMAL(19,2)) 
					AS AdjustedExpectedTolls,
					---------- AEFn = EFn-FnA
					CAST((MI.FNFees-MI.FNFeesAdjusted) AS DECIMAL(19,2))  AS AdjustedExpectedFNFees,
					---------- AESn = ESn-SnA
					CAST((MI.SNFees-MI.SNFeesAdjusted) AS DECIMAL(19,2))  AS AdjustedExpectedSNFees,
		
					------- AEA = EA-AA
						CAST((
							(MI.Tolls - 
									 CASE WHEN VT.VtollFlag=0 AND MI.TollsAdjusted=0 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+ISNULL (MI.TollsAdjusted,0) -- This is for the vtoll adjustments that is not coming from  VTRT.Tolladj table, so bringing it from Customer trips table for vtoll adj.Ex:1230002032
									 WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 AND (VT.PaidAmount_VT) > ISNULL (MI.TollsAdjusted,0) THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+((VT.PaidAmount_VT)-ISNULL(MI.TollsAdjusted,0))+ISNULL(MI.ExcusedAmount,0) -- this condition is for credit adjustment and amount that is not coming from VTRT table ex:1234440179 
									 WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 THEN ISNULL(MI.TollsAdjusted,0)-(VT.PaidAmount_VT)-- this is for adjustments that happened in VTRT table and vtoll adj (In order to avoid double adjustments from two tables. Ex:1225411445)
									 ELSE ISNULL(MI.TollsAdjusted,0) END ) 
						+	(MI.FNFees-MI.FNFeesAdjusted) 
						+   (MI.SNFees-MI.SNFeesAdjusted)
						) AS DECIMAL(19,2)) 
					  AS AdjustedExpectedAmount,
		
		
				   ------- PA
		           CAST(CASE    WHEN VtollFlag=1 THEN  VT.PaidAmount_VT
							WHEN VtollFlag=0 THEN (VT.PaidAmount_VT)+ISNULL((MI.TollsPaid),0)
										  ELSE ISNULL((MI.TollsPaid),0) 
					END AS DECIMAL(19,2))  AS TollsPaid,	
					CAST(MI.FNFeesPaid AS DECIMAL(19,2)) AS FNFeesPaid ,
				    CAST(MI.SNFeesPaid AS DECIMAL(19,2)) AS SNFeesPaid ,
		
					CAST(((CASE   WHEN VtollFlag=1 THEN  VT.PaidAmount_VT
							WHEN VtollFlag=0 THEN (VT.PaidAmount_VT)+ISNULL((MI.TollsPaid),0)
										  ELSE ISNULL((MI.TollsPaid),0) 
					END ) + MI.FNFeesPaid+ MI.SNFeesPaid) AS DECIMAL(19,2))
					AS PaidAmount,
		
		
					-------- OA
							-------- TO = AEA-TP
					 CAST(CASE 
							 WHEN VTollFlag=1 THEN VT.outstandingamount
							 ELSE 
							 ( ----- AET=ET-TA
							(MI.Tolls - 
									 CASE WHEN VT.VtollFlag=0 AND MI.TollsAdjusted=0 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+ISNULL (MI.TollsAdjusted,0) -- This is for the vtoll adjustments that is not coming from  VTRT.Tolladj table, so bringing it from Customer trips table for vtoll adj.Ex:1230002032
									 WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 AND (VT.PaidAmount_VT) > ISNULL (MI.TollsAdjusted,0) THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+((VT.PaidAmount_VT)-ISNULL(MI.TollsAdjusted,0))+ISNULL(MI.ExcusedAmount,0) -- this condition is for credit adjustment and amount that is not coming from VTRT table ex:1234440179 
									 WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 THEN ISNULL(MI.TollsAdjusted,0)-(VT.PaidAmount_VT)-- this is for adjustments that happened in VTRT table and vtoll adj (In order to avoid double adjustments from two tables. Ex:1225411445)
									 ELSE ISNULL(MI.TollsAdjusted,0) END )
							 - ------PA
							 (CASE    WHEN VtollFlag=1 THEN  VT.PaidAmount_VT
							         WHEN VtollFlag=0 THEN (VT.PaidAmount_VT)+ISNULL((MI.TollsPaid),0)
										  ELSE ISNULL((MI.TollsPaid),0) 
							  END)
							  )
					 END AS DECIMAL(19,2)) AS TollOutStandingAmount,
		
							------ FnO = AEFn-FnP
					 
					 CAST(((MI.FNFees-MI.FNFeesAdjusted) - MI.FNFeesPaid) AS DECIMAL(19,2)) AS FNFeesOutStandingAmount,
					 CAST(((MI.SNFees-MI.SNFeesAdjusted) - MI.SNFeesPaid) AS DECIMAL(19,2)) AS SNFeesOutStandingAmount,
		
							----- OA = AEA-OA
		
					CAST((CASE 
							 WHEN VTollFlag=1 THEN VT.outstandingamount
							 ELSE 
							 ( ----- AET=ET-TA
							(MI.Tolls - 
									 CASE WHEN VT.VtollFlag=0 AND MI.TollsAdjusted=0 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+ISNULL (MI.TollsAdjusted,0) -- This is for the vtoll adjustments that is not coming from  VTRT.Tolladj table, so bringing it from Customer trips table for vtoll adj.Ex:1230002032
									 WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 AND (VT.PaidAmount_VT) > ISNULL (MI.TollsAdjusted,0) THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)+((VT.PaidAmount_VT)-ISNULL(MI.TollsAdjusted,0))+ISNULL(MI.ExcusedAmount,0) -- this condition is for credit adjustment and amount that is not coming from VTRT table ex:1234440179 
									 WHEN VT.VtollFlag=0 AND MI.TollsAdjusted<>0 THEN ISNULL(MI.TollsAdjusted,0)-(VT.PaidAmount_VT)-- this is for adjustments that happened in VTRT table and vtoll adj (In order to avoid double adjustments from two tables. Ex:1225411445)
									 ELSE ISNULL(MI.TollsAdjusted,0) END )
							 - ------PA
							 (CASE    WHEN VtollFlag=1 THEN  VT.PaidAmount_VT
							         WHEN VtollFlag=0 THEN (VT.PaidAmount_VT)+ISNULL((MI.TollsPaid),0)
										  ELSE ISNULL((MI.TollsPaid),0) 
							  END)
							  )
					 END )
					 +			 
					 ((MI.FNFees-MI.FNFeesAdjusted) - MI.FNFeesPaid) 
					 +
					 ((MI.SNFees-MI.SNFeesAdjusted) - MI.SNFeesPaid) AS DECIMAL(19,2)) 
					 AS OutstandingAmount,
		
		           
		           MI.EDW_Update_Date
			FROM Stage.NonTerminalInvoice MI
			LEFT JOIN Stage.MigratedDimissedVToll Vt ON Vt.InvoiceNumber=MI.InvoiceNumber
			LEFT JOIN Stage.MigratedUnassignedInvoice UI ON UI.InvoiceNumber=MI.InvoiceNumber
			--WHERE MI.InvoiceNumber=@invoicenumber		
			) A
		
					
			
		OPTION (LABEL = 'Stage.MigratedNonTerminalInvoice Load');

		SET @Log_Message = 'Loaded Stage.MigratedNonTerminalInvoice';
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message,'I',-1,NULL;
		
		-- Statistics
		CREATE STATISTICS STATS_MigratedNonTerminalInvoice_000 ON Stage.MigratedNonTerminalInvoice (InvoiceNumber)
		CREATE STATISTICS STATS_MigratedNonTerminalInvoice_001 ON Stage.MigratedNonTerminalInvoice (FirstInvoiceID)
		CREATE STATISTICS STATS_MigratedNonTerminalInvoice_002 ON Stage.MigratedNonTerminalInvoice (CurrentInvoiceID)
		CREATE STATISTICS STATS_MigratedNonTerminalInvoice_003 ON Stage.MigratedNonTerminalInvoice (CustomerID)
		CREATE STATISTICS STATS_MigratedNonTerminalInvoice_004 ON Stage.MigratedNonTerminalInvoice (AgeStageID)
		CREATE STATISTICS STATS_MigratedNonTerminalInvoice_006 ON Stage.MigratedNonTerminalInvoice (EDW_InvoiceStatusID)

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date,'Completed full load', 'I',NULL,NULL;

		-- Show results
		IF @Trace_Flag = 1  EXEC Utility.FromLog @Log_Source, @Log_Start_Date;
		IF @Trace_Flag = 1  SELECT TOP 1000 'Stage.MigratedNonTerminalInvoice' TableName, * FROM dbo.Fact_Invoice  ORDER BY 2 DESC;
	
	END	TRY
	
	BEGIN CATCH
	
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH;

END

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


