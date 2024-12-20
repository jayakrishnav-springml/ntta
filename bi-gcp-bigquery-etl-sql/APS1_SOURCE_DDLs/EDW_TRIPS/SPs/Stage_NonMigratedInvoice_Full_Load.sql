CREATE PROC [Stage].[NonMigratedInvoice_Full_Load] AS
/*
#################################################################################################################################
Proc Description: 
---------------------------------------------------------------------------------------------------------------------------------
Exec  [Stage].[NonMigratedInvoice_Full_Load] table. 
=================================================================================================================================
Change Log:
---------------------------------------------------------------------------------------------------------------------------------
CHG0042443	Gouthami		2023-02-09	New!
									  1) This Stored procedure loads the data for all non migrated Invoices. (>=2021)
									  2) Payments and Adjustments for the Invoices are taken from bubble logic table 
										 Stage.InvoicePAyment
CHG0044458  Gouthami	    2024-01-26  1.Changed the logic to bring ThirdNotice from latest to earliest dates as there
										   can be multiple dates when invoice is in Collections.(MAX-->MIN)
										2.Always take the first instance of date when an Invoice went to 
											ThirdNotice/Collections.
										3.These changes are not applicable to downgraded invoices. This needs to be 
										   fixed with different logic.

																			 
==================================================================================================================================

----------------------------------------------------------------------------------------------------------------------------------
EXEC Stage.NonMigratedInvoice_Full_Load
EXEC Utility.FromLog 'Stage.NonMigratedInvoice_Full_Load', 1
SELECT TOP 100 'Stage.NonMigratedInvoice_Full_Load' Table_Name, * FROM Stage.NonMigratedInvoice_Full_Load ORDER BY 2
##################################################################################################################################
*/




BEGIN
BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'Stage.NonMigratedInvoice_Full_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME();
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0; -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL;

		--=============================================================================================================
		-- Load Stage.NonMigInvoice -- list of invoices that needs to be executed in each run
		--=============================================================================================================
		IF OBJECT_ID('Stage.NonMigInvoice') IS NOT NULL DROP TABLE Stage.NonMigInvoice;
		CREATE  TABLE Stage.NonMigInvoice WITH (CLUSTERED INDEX ( InvoiceNumber), DISTRIBUTION = HASH(InvoiceNumber))
		AS	

		SELECT * FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY IHC.InvoiceNumber ORDER BY (InvoiceID) DESC) RN_MAX,
				   IHC.InvoiceNumber,
				   InvoiceID,
				   IHC.CustomerID,
				   IHC.AgestageID,
				   IHC.VehicleID,				   
				   CollectionStatus,
				   IHC.InvoiceStatus,
				   IHC.InvoiceDate,
				   IHC.LND_UpdateType -- select count(distinct IHC.invoicenumber)
			FROM LND_TBOS.TollPlus.Invoice_Header IHC
			LEFT JOIN Ref.RiteMigratedInvoice  RI ON RI.InvoiceNumber = IHC.InvoiceNumber
			WHERE LND_UpdateType <> 'D'  AND  IHC.CREATEDUSER <> 'DCBInvoiceGeneration' 
			AND RI.InvoiceNumber IS NULL 

			) A WHERE A.RN_MAX=1
			

		-- Log 
		SET  @Log_Message = 'Loaded Stage.NonMigInvoice'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, '-1', -1, 'I'
		
		-- Create statistics and swap table
		CREATE STATISTICS STATS_Stage_NonMigInvoice_000 ON Stage.NonMigInvoice (InvoiceNumber);


		IF @Trace_Flag = 1 SELECT TOP 100 'Stage.NonMigInvoice' TableName, * FROM Stage.NonMigInvoice ORDER BY 2 DESC

		
		--=============================================================================================================
		-- Load Stage.DismissedVtoll  -- to bring dismissed Vtolls
		--=============================================================================================================
		IF OBJECT_ID('Stage.DismissedVToll') IS NOT NULL DROP TABLE Stage.DismissedVToll;
		CREATE  TABLE Stage.DismissedVToll WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber)) 
		AS	
		WITH CTE_Vtolls AS 
		(
		SELECT  
				DISTINCT
				A.InvoiceNumber InvoiceNumber
				,COUNT(DISTINCT A.TpTripID) VTollTxnCnt
				,COUNT(custtripID) CustTxnCnt
				,ISNULL(SUM(CASE WHEN A.TripStatusID_VT IN (171,118) THEN 1 ELSE 0 END),0) AS UnassignedVtolledTxnCnt
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
				SELECT  VT.ReferenceInvoiceID InvoiceNumber
					    ,TC.TpTripID,Vt.TpTripID TpTripID_VT
						,TC.CustTripID
					    ,VT.TripStatusID TripStatusID_VT
						,TC.TripStatusID TripStatusID_CT
					    ,TC.PaymentStatusID
					    ,TC.PostedDate
						,CASE WHEN COUNT(VT.tptripID)>1 AND SUM(CASE WHEN TC.TripStatusID=2 THEN 1 ELSE 0 END )>1 
								THEN CAST((VT.PBMTollAmount)/COUNT(VT.tptripID) AS DECIMAL(16,2)) 
						 ELSE (CASE WHEN TC.PaymentStatusID=3852 AND VT.TripStatusID<>154 AND TC.TripStatusID NOT IN (155,159,135,170)  THEN 0 ELSE VT.PBMTollAmount END) -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
						 END
						 AS PBMTollAmount
						 ,CASE WHEN COUNT(VT.tptripID)>1 AND SUM(CASE WHEN TC.TripStatusID=2 THEN 1 ELSE 0 END )>1 
								THEN CAST((VT.AVITollAmount)/COUNT(VT.tptripID) AS DECIMAL(16,2)) 
						 ELSE (CASE WHEN TC.PaymentStatusID=3852 AND VT.TripStatusID<>154 AND  TC.TripStatusID NOT IN (155,159,135,170)  THEN 0 ELSE VT.AVITollAmount END) -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
						 END
						 AS AVITollAmount
						 
						,CASE WHEN COUNT(VT.tptripID)>1 AND SUM(CASE WHEN TC.TripStatusID=2 THEN 1 ELSE 0 END )>1 
								THEN CAST((VT.TollAmount)/COUNT(VT.tptripID) AS DECIMAL(16,2))							--Ex:1226708097 
							 
						 ELSE (CASE WHEN TC.PaymentStatusID=3852 AND VT.TripStatusID<>154 AND TC.TripStatusID NOT IN (155,159,135,170) THEN 0 ELSE VT.TollAmount END) -- PaymentstatusID 3852 and tripstatusID=153 is not considered as tollamount, as the trips are posted multilple times.There can be Adjustments from CSR and status is 155. We need to consider the toll amount. 
						 END
						 AS Tolls
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
						,SUM((CASE  
									WHEN  TC.PaymentStatusID=3852 AND TC.TripStatusID=135 AND  VT.PaymentStatusID=456 AND  vt.TripStatusID=2 THEN 0 -- these are the txns that got posted in VT table and paid in vtrt 
								    WHEN  TC.PaymentStatusID=3852  AND TC.TripStatusID =118/* 118 - Unmatched , 135 - CSR Adjusted*/ THEN 0 -- 1223509842
									WHEN  TC.PaymentStatusID=458 AND TC.OutstandingAmount<>TC.TollAmount AND TC.OutstandingAmount=TC.PBMTollAmount AND TC.OutstandingAmount=TC.AVITollAmount THEN (TC.TollAmount-TC.OutstandingAmount)-- Ex:1236741507	
									WHEN  VT.TripStatusID=154 AND TC.TripStatusID=135 AND TT.PaymentStatusID=456 THEN  VT.TollAmount -- Trips that got vtolled and posted to different zipcash account
									WHEN   TC.PaymentStatusID=3852 AND TC.TripStatusID=135 AND VT.PaymentStatusID=3852 THEN vt.TollAmount	--ex:1225983731
									WHEN   TC.PaymentStatusID=3852 AND TC.TripStatusID=154 THEN 0 --Ex:1222959778
									WHEN   TC.PaymentStatusID=3852 THEN VT.amount 								
									WHEN   TC.TollAmount<>VT.Amount THEN VT.Amount-TC.TollAmount
									WHEN   TC.TollAmount=TC.PBMTollAmount AND TC.OutstandingAmount=TC.AVITollAmount AND TC.PaymentStatusID=458 THEN (TC.TollAmount-TC.OutstandingAmount) --Ex:1234342591
									WHEN   TC.TollAmount=TC.PBMTollAmount THEN 0 	
									WHEN   TC.TollAmount=0 AND (VT.TollAmount=TC.PBMTollAmount) THEN TC.PBMTollAmount
									WHEN   (TC.TollAmount=VT.amount) AND tc.TollAmount<>TC.PBMTollAmount AND tc.TollAmount<>TC.AVITollAmount THEN 0
									
							ELSE (TC.PBMTollAmount-TC.AVITollAmount) END)) TollsAdjusted --
				FROM 
				(
						SELECT * FROM (
						SELECT ROW_NUMBER() OVER (PARTITION BY vt.TpTripID,L.ReferenceInvoiceID
									                          ORDER BY vt.CitationID DESC,
									                                   vt.ExitTripDateTime DESC) RN_VT,					
								VT.CitationID,VT.TpTripID,VT.ViolatorID,VT.TollAmount,VT.OutstandingAmount,VT.PBMTollAmount,VT.AVITollAmount,
								VT.CitationStage,VT.TripStageID,VT.TripStatusID,VT.StageModifiedDate,
						        VT.EntryTripDateTime,VT.ExitTripDateTime,VT.PaymentStatusID,VT.PostedDate,
								L.LinkID,L.Amount,L.LinkSourceName,L.TxnDate,L.ReferenceInvoiceID
						FROM LND_TBOS.TollPlus.Invoice_Header H WITH (NOLOCK)
						JOIN LND_TBOS.TollPlus.Invoice_LineItems L WITH (NOLOCK)
							ON L.InvoiceID = H.InvoiceID
						JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT WITH (NOLOCK)
							ON L.LinkID = VT.CitationID
								AND L.LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS'
								AND (VT.PaymentStatusID<>456 AND  vt.TripStatusID<>2)  -- This is to avoid those Txns that are vtolled first and then moved back to Violated trips table
								AND VT.TripStatusID NOT IN (171,118) -- EX: 1233445625,1234165987,1230780604. This condition is for the Txns that are unassignd from an invoice and assigned to a different one and then gor VTOLLED.In this case, the citationID is going to change but TPTRIPID remains same. While joining this VT table to CT,we are goint to get all the txns assigned to the TPTRIPID(Assigned and Vtolled). 
							) VT WHERE  RN_VT=1 --AND VT.ReferenceInvoiceID=1223304290
				) VT 
				JOIN 
					( 
						SELECT * FROM (
						SELECT TC.TpTripID,TC.CustTripID,TC.TripStatusID,TC.PaymentStatusID,TC.PostedDate,TC.TollAmount,TC.PBMTollAmount,TC.AVITollAmount,TC.OutStandingAmount,
							  ROW_NUMBER() OVER (PARTITION BY TC.TpTripID ORDER BY TC.CustTripID DESC, TC.PostedDate DESC) RN
						 FROM LND_TBOS.TollPlus.TP_CustomerTrips TC 
						 WHERE  TC.TransactionPostingType NOT IN ( 'Prepaid AVI', 'NTTA Fleet' )
						 ) A WHERE RN=1
					) TC
					 ON TC.TpTripID = VT.TpTripID						
				JOIN lnd_tbos.TollPlus.TP_Trips TT ON TT.TpTripID=TC.TpTripID 
					AND TT.TripWith IN ('C')
				JOIN Stage.NonMigInvoice Inv ON  Inv.InvoiceNumber = VT.ReferenceInvoiceID
					--WHERE H.InvoiceNumber=1230002032 --partial vtoll
					--WHERE H.InvoiceNumber=1237067582 -- issue in stage table joining to customer trips as these trips have 135 and 2 statuses	
					--H.InvoiceNumber= 1227517722  -- some of the Txns on these invoice are on the customer account first, and then moved to Violated trips and got invoiced as the auto payment was not done on the account
		            --WHERE H.InvoiceNumber IN (1030630051,1120029424)	
					GROUP BY VT.ReferenceInvoiceID,TC.TpTripID,VT.TripStatusID,TC.PaymentStatusID,TC.PostedDate,VT.TollAmount,TC.OutstandingAmount,
					         VT.TpTripID,TC.CusttripID,
					         VT.TripStatusID,
					         VT.PaymentStatusID,
					         VT.PostedDate,
					         VT.OutstandingAmount,TC.TripStatusID,VT.PBMTollAmount,VT.AVITollAmount
						
			) A
		GROUP BY A.InvoiceNumber
		), 
		cte AS (
      SELECT 
				H.InvoiceNumber,
				COUNT(DISTINCT VT.TpTripID) TotalTxnCnt,
				SUM(CASE WHEN L.SourceViolationStatus='L' AND (VT.PaymentStatusID=456 OR VT.PaymentStatusID IS NULL) THEN 1 ELSE 0 END ) UnassignedTxnCnt, -- Out of 4, 1 txn got unassigned from an invoice and rest are vtolled then the Invoice status should be Vtoll.Ex:1120029424
				SUM(CASE WHEN L.SourceViolationStatus='L' AND VT.PaymentStatusID IS NULL THEN l.Amount ELSE 0 END ) ExcusedTollsAdjusted --1030630051
	--select * 
		FROM LND_TBOS.TollPlus.Invoice_Header H WITH (NOLOCK)
		  JOIN LND_TBOS.TollPlus.Invoice_LineItems L WITH (NOLOCK)
					ON L.InvoiceID = H.InvoiceID					
		  LEFT JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT WITH (NOLOCK)
					ON ABS(L.LinkID) = VT.CitationID	
					AND L.LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS'
		JOIN Stage.NonMigInvoice Inv ON  Inv.InvoiceNumber = H.InvoiceNumber
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
			   CTE_Vtolls.Tolls,
			   CTE_Vtolls.PBMTollAmount,
			   CTE_Vtolls.AVITollAmount,
			   CTE_Vtolls.PremiumAmount,
               CTE_Vtolls.PaidAmount_VT,
			   (cte.ExcusedTollsAdjusted+TollsAdjusted) TollsAdjusted,
			   0 AS TollsAdjustedAfterVtoll,
			   0 AS AdjustedAmount_Excused,
			   0 AS ClassAdj,
               CTE_Vtolls.OutstandingAmount,
			   0 AS PaidTnxs,
			   CASE WHEN CTE_Vtolls.VTollTxnCnt = cte.TotalTxnCnt  THEN 1 ELSE 0 END AS VtollFlag,
			   CASE WHEN CTE_Vtolls.VTollTxnCnt = cte.TotalTxnCnt THEN '1 - Vtoll Invoice' 
					WHEN (CTE_Vtolls.VTollTxnCnt+UnassignedTxnCnt) = cte.TotalTxnCnt THEN '1 - Vtoll Invoice' 
			   ELSE '0 - PartialVtoll Invoice' END AS VtollFlagDescription,
			   ISNULL(CAST(SYSDATETIME() AS DATETIME2(7)), '1900-01-01') AS EDW_Update_Date		
              
		FROM CTE_Vtolls
		LEFT JOIN cte ON cte.InvoiceNumber = CTE_Vtolls.InvoiceNumber	
		OPTION (LABEL = 'Stage.DismissedVToll Load');
		
		
		-- Log 
		SET  @Log_Message = 'Loaded Stage.DismissedVToll'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, '-1', -1, 'I'
		
		-- Create statistics and swap table
		CREATE STATISTICS STATS_Stage_DismissedVToll_000 ON Stage.DismissedVToll (InvoiceNumber);


		IF @Trace_Flag = 1 SELECT TOP 100 'Stage.DismissedVtoll' TableName, * FROM Stage.DismissedVtoll ORDER BY 2 DESC

		--=============================================================================================================
         -- Load Stage.UnassignedInvoice  -- to bring dismissed Unassigned Invoices
        --=============================================================================================================
        IF OBJECT_ID('Stage.UnassignedInvoice') IS NOT NULL DROP TABLE Stage.UnassignedInvoice;
        CREATE TABLE Stage.UnassignedInvoice  WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber)) 
        AS
        WITH CTE_Unassigned AS (
		SELECT 
		 ih.InvoiceNumber InvoiceNumber_Unass		 
		,COUNT(DISTINCT vt.CitationID) CitationID_Unassgned -- select *
		,SUM(vt.TollAmount) Tolls
		FROM 
		( 
        SELECT tptripid,ROW_NUMBER() OVER (PARTITION BY VT.tptripID ORDER BY vt.CitationID ASC) AS RN
		FROM LND_TBOS.TollPlus.TP_ViolatedTrips VT       
        ) A 
        JOIN  LND_TBOS.TollPlus.TP_ViolatedTrips vt   ON vt.TpTripID = A.TpTripID    
        JOIN LND_TBOS.TollPlus.Invoice_LineItems ili WITH (NOLOCK)
             ON vt.CitationID = ili.LinkID
			 AND ili.LinkSourceName='Tollplus.TP_Violatedtrips'
        JOIN LND_TBOS.TollPlus.Invoice_Header ih WITH (NOLOCK)
              ON ili.InvoiceID = ih.InvoiceID
		JOIN Stage.NonMigInvoice Inv ON  Inv.InvoiceNumber = ih.InvoiceNumber
         WHERE A.RN=2 AND tripstatusid IN (171,115,118) AND ih.InvoiceNumber NOT IN (SELECT InvoiceNumber FROM Stage.DismissedVtoll)
		 --AND ili.ReferenceInvoiceID=1230780604
		 GROUP BY ih.InvoiceNumber
		 ),
		
		CTE_All AS (
		SELECT 
				H.InvoiceNumber,COUNT(DISTINCT VT.CitationID) CitationID_All
		FROM LND_TBOS.TollPlus.Invoice_Header H WITH (NOLOCK)
		  JOIN LND_TBOS.TollPlus.Invoice_LineItems L WITH (NOLOCK)
					ON L.InvoiceID = H.InvoiceID
		  JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT WITH (NOLOCK)
					ON vt.CitationID = L.LinkID 
						AND L.LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS'
		 JOIN Stage.NonMigInvoice Inv ON  Inv.InvoiceNumber = h.InvoiceNumber
		-- WHERE H.InvoiceNumber=1230780604
		 GROUP BY H.InvoiceNumber
		 )
		 SELECT CTE_Unassigned.InvoiceNumber_Unass,
                CTE_Unassigned.CitationID_Unassgned,
                CTE_All.InvoiceNumber,
                CTE_All.CitationID_All,
				CTE_Unassigned.Tolls,
				1 AS UnassignedFlag
		FROM CTE_Unassigned
		JOIN cte_All ON cte_All.InvoiceNumber = CTE_Unassigned.InvoiceNumber_Unass
		WHERE cte_All.CitationID_All=CTE_Unassigned.CitationID_Unassgned
		

        -- Log 
        SET  @Log_Message = 'Loaded Stage.UnassignedInvoice'
        EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, '-1', -1, 'I'
        
        -- Create statistics and swap table
        CREATE STATISTICS STATS_Stage_UnassignedInvoice_000 ON Stage.UnassignedInvoice (InvoiceNumber);


        IF @Trace_Flag = 1 SELECT TOP 100 'Stage.UnassignedInvoice' TableName, * FROM Stage.UnassignedInvoice ORDER BY 2 DESC

		--=============================================================================================================
         -- Load Stage.Invoice  -- to bring dismissed Unassigned Invoices
        --=============================================================================================================
		IF OBJECT_ID('Stage.Invoice') IS NOT NULL DROP TABLE Stage.Invoice;
		CREATE  TABLE Stage.Invoice  WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber)) 
		AS
				
		WITH CTE_CURR_INV
		AS (SELECT ROW_NUMBER() OVER (PARTITION BY IHC.InvoiceNumber ORDER BY (IHC.InvoiceID) DESC) RN_MAX,
				   IHC.InvoiceNumber,
				   IHC.InvoiceID,
				   IHC.CustomerID,
				   IHC.AgestageID,
				   IHC.CollectionStatus,
				   IHC.VehicleID,
				   IHC.AdjustedAmount,
				   IHC.InvoiceStatus,
				   IHC.LND_UpdateType
			FROM LND_TBOS.TollPlus.Invoice_Header IHC
			JOIN Stage.NonMigInvoice Inv ON Inv.InvoiceNumber = IHC.InvoiceNumber
			WHERE IHC.LND_UpdateType <> 'D'  AND  IHC.CREATEDUSER <> 'DCBInvoiceGeneration' 
			),
			 CTE_FIRST_INV
		AS (SELECT ROW_NUMBER() OVER (PARTITION BY IHF.InvoiceNumber ORDER BY (IHF.InvoiceID) ASC) RN_MIN,
				   IHF.InvoiceNumber,
				   IHF.InvoiceID,
				   IHF.SourceName,
				   IHF.LND_UpdateType
			FROM LND_TBOS.TollPlus.Invoice_Header IHF
			JOIN Stage.NonMigInvoice Inv ON Inv.InvoiceNumber = IHF.InvoiceNumber
			WHERE IHF.LND_UpdateType <> 'D'  AND  IHF.CREATEDUSER <> 'DCBInvoiceGeneration' 
			),

			CTE_INV_DATE
			AS (
			SELECT 
				   InvoiceNumber,
				   MAX(MbsID) MbsID,
				   MAX(FirstNoticeDate) FirstNoticeDate,
				   MAX(SecondNoticeDate) SecondNoticeDate,
				   MAX(ThirdNoticeDate) ThirdNoticeDate,
				   MAX(LegalActionPendingDate) LegalActionPendingDate,
				   MAX(CitationDate) CitationDate,
				   MAX(DueDate) DueDate,
				   MAX(MbsGeneratedDate) MbsGeneratedDate,
				   DeleteFlag DeleteFlag
			FROM (
					 SELECT IHD.InvoiceNumber,
							MAX(MBSH.MbsID) MbsID,
							MAX(CASE WHEN IHD.AgeStageID = 2 THEN CAST(IHD.InvoiceDate AS DATE) ELSE '1900-01-01' END) FirstNoticeDate,
							MAX(CASE WHEN IHD.AgeStageID = 3 THEN CAST(IHD.InvoiceDate AS DATE) ELSE '1900-01-01' END) SecondNoticeDate,
							MIN(CASE WHEN IHD.AgeStageID = 4 THEN CAST(IHD.InvoiceDate AS DATE) ELSE '1900-01-01' END) ThirdNoticeDate,
							MAX(CASE WHEN IHD.AgeStageID = 5 THEN CAST(IHD.InvoiceDate AS DATE) ELSE '1900-01-01' END) LegalActionPendingDate,
							CASE WHEN IHD.AgeStageID = 6 THEN MIN(CAST(IHD.InvoiceDate AS DATE)) ELSE '1900-01-01' END CitationDate,
							MAX(CAST(IHD.DueDate AS DATE)) DueDate,
							MAX(CAST(MBSH.MbsGeneratedDate AS DATE)) MbsGeneratedDate,
							CAST(CASE WHEN IHD.LND_UpdateType = 'D' OR MBSI.LND_UpdateType = 'D' OR MBSH.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT) DeleteFlag
							--SELECT *  
					FROM LND_TBOS.TollPlus.Invoice_Header IHD
					JOIN Stage.NonMigInvoice Inv ON Inv.InvoiceNumber = IHD.InvoiceNumber
					LEFT JOIN LND_TBOS.TollPlus.MbsInvoices MBSI ON MBSI.InvoiceNumber = IHD.InvoiceNumber AND MBSI.LND_UpdateType<>'D'
					LEFT JOIN LND_TBOS.TollPlus.MbsHeader MBSH ON MBSH.MbsID = MBSI.MbsID AND MBSH.LND_UpdateType<>'D'
					WHERE IHD.LND_UpdateType<>'D' AND  IHD.CREATEDUSER <> 'DCBInvoiceGeneration' 
					
					GROUP BY IHD.InvoiceNumber,CAST(CASE WHEN IHD.LND_UpdateType = 'D' OR MBSI.LND_UpdateType = 'D' OR MBSH.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT),IHD.AgeStageID
			) a
			GROUP BY Invoicenumber,a.DeleteFlag

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
		       MAX(   CASE
		                  WHEN IL.TxnType = 'VTOLL' THEN
		                      CAST(IL.CreatedDate AS DATE)
		                  ELSE
		                      CAST('1900-01-01' AS DATE)
		              END
		          ) ZipCashDate,
		       CTE_INV_DATE.FirstNoticeDate,
		       CTE_INV_DATE.SecondNoticeDate,
		       CTE_INV_DATE.ThirdNoticeDate,
		       CTE_INV_DATE.LegalActionPendingDate,
		       CTE_INV_DATE.CitationDate,
		       CTE_INV_DATE.DueDate,
		       ISNULL(CTE_INV_DATE.MbsGeneratedDate, '1900-01-01') CurrMbsGeneratedDate,
			   InvP.FirstPaymentDate,
			   InvP.LastPaymentDate,
			   FP.FirstFeePaymentDate,
			   FP.LastFeePaymentDate,
		       DIS.InvoiceStatusID,
		
			   ---------------------------------------TxnCounts
			   COUNT(DISTINCT TPV.TpTripID) TxnCnt,
		
			 ---------------------------------------- Amounts
			   CAST(ISNULL(InvP.InvoiceAmount,0) AS DECIMAL(19,2)) AS InvoiceAmount,
		       CAST(ISNULL(InvP.PBMTollAmount,0) AS DECIMAL(19,2)) AS PBMTollAmount,
		       CAST(ISNULL(InvP.AVITollAmount,0) AS DECIMAL(19,2)) AS AVITollAmount,
		       CAST(ISNULL(InvP.PBMTollAmount,0) - ISNULL(InvP.AVITollAmount,0) AS DECIMAL(19,2)) AS PremiumAmount,

			   CAST(ISNULL(InvP.Tolls,0) AS DECIMAL(19,2)) AS Tolls,
		       CAST(ISNULL(F.FNFees, 0) AS DECIMAL(19,2)) AS FNFees,
		       CAST(ISNULL(F.SNFees, 0) AS DECIMAL(19,2)) AS SNFees, 
		
			   CAST(ISNULL(InvP.TollsPaid,0) AS DECIMAL(19,2)) AS TollsPaid,
			   CAST(ISNULL(FP.FNFeesPaid,0) AS DECIMAL(19,2)) AS FNFeesPaid,
			   CAST(ISNULL(FP.SNFeesPaid,0) AS DECIMAL(19,2)) AS SNFeesPaid,
		
			   CAST(ISNULL(InvP.TollsAdjusted,0) AS DECIMAL(19,2)) AS  TollsAdjusted,
			   CAST( ISNULL(FA.FNFeesAdjusted,0) AS DECIMAL(19,2)) AS FNFeesAdjusted,
			   CAST(ISNULL(FA.SNFeesAdjusted,0) AS DECIMAL(19,2)) AS SNFeesAdjusted,
		
		
		       ISNULL(CAST(SYSDATETIME() AS DATETIME2(7)), '1900-01-01') AS EDW_Update_Date,
		       CASE
		           WHEN SUM(   CASE
		                           WHEN TPV.PaymentStatusID = 458 THEN
		                               1
		                           ELSE
		                               0
		                       END
		                   ) = COUNT(TPV.CitationID) THEN
		               'Open'
		           WHEN SUM(   CASE
		                           WHEN IL.LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS'
		                                AND TPV.PaymentStatusID = 458 THEN
		                               IL.Amount
		                           ELSE
		                               0
		                       END
		                   ) = 0
		                AND COUNT(TPV.CitationID) = 0 THEN
		               'Closed'
		           WHEN SUM(   CASE
		                           WHEN TPV.PaymentStatusID = 456 THEN
		                               1
		                           ELSE
		                               0
		                       END
		                   ) > 0
		                AND SUM(   CASE
		                               WHEN TPV.PaymentStatusID = 456 THEN
		                                   1
		                               ELSE
		                                   0
		                           END
		                       ) < COUNT(TPV.CitationID) THEN
		               'PartialPaid'
		           WHEN SUM(   CASE
		                           WHEN TPV.PaymentStatusID = 456 THEN
		                               1
		                           ELSE
		                               0
		                       END
		                   ) = 0
		                AND SUM(   CASE
		                               WHEN TPV.PaymentStatusID = 458 THEN
		                                   1
		                               ELSE
		                                   0
		                           END
		                       ) <> COUNT(TPV.CitationID)
		                AND SUM(   CASE
		                               WHEN TPV.PaymentStatusID = 458 THEN
		                                   1
		                               ELSE
		                                   0
		                           END
		                       ) <> 0
		                AND COUNT(TPV.CitationID) <> 0 THEN
		               'PartialPaid'
		           WHEN SUM(   CASE
		                           WHEN TPV.PaymentStatusID = 456 THEN
		                               1
		                           ELSE
		                               0
		                       END
		                   ) = COUNT(TPV.CitationID) THEN
		               'Paid'
		           WHEN CTE_CURR_INV.InvoiceStatus = 'Closed' THEN
		               'Closed'
		           ELSE
		               CTE_CURR_INV.InvoiceStatus
		       END AS InvoiceStatus

		      	
		FROM CTE_CURR_INV CTE_CURR_INV
		    JOIN CTE_FIRST_INV CTE_FIRST_INV
		        ON CTE_CURR_INV.InvoiceNumber = CTE_FIRST_INV.InvoiceNumber
		           AND RN_MAX = 1
		           AND RN_MIN = 1
		    JOIN CTE_INV_DATE CTE_INV_DATE
		        ON CTE_CURR_INV.InvoiceNumber = CTE_INV_DATE.InvoiceNumber
		    JOIN LND_TBOS.TollPlus.Invoice_LineItems IL
		        ON IL.ReferenceInvoiceID = CTE_CURR_INV.InvoiceNumber
		           AND IL.LND_UpdateType <> 'D'
			LEFT JOIN  stage.InvoicePayment Invp ON CTE_CURR_INV.InvoiceNumber=InvP.invoicenumber
		    LEFT JOIN LND_TBOS.TollPlus.TP_ViolatedTrips TPV
		        ON TPV.CitationID = IL.LinkID
		           AND LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS'
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

			LEFT JOIN (																----------------------- FN & SN Fees Paid
									SELECT IL.ReferenceInvoiceID,
										 MIN(IRT.TxnDate) FirstFeePaymentDate,
										 MAX(IRT.TxnDate) LastFeePaymentDate,
										 ISNULL(SUM(CASE WHEN IL.TxnType = 'FSTNTVFEE' THEN (IRT.AmountReceived * -1) ELSE 0 END),0) FNFeesPaid,
										 ISNULL(SUM(CASE WHEN IL.TxnType = 'SECNTVFEE' THEN (IRT.AmountReceived * -1) ELSE 0 END),0) SNFeesPaid 
									FROM  LND_TBOS.TollPlus.Invoice_LineItems IL
										  JOIN LND_TBOS.TollPlus.TP_Invoice_Receipts_Tracker IRT 
												ON IL.LinkID = IRT.Invoice_ChargeID	AND IRT.LND_UpdateType<>'D'
										  JOIN Stage.NonMigInvoice RI ON RI.InvoiceNumber=IL.ReferenceInvoiceID 
									   AND IRT.LinkSourceName = 'FINANCE.PAYMENTTXNS' 
									  WHERE  IL.LinkSourceName = 'TOLLPLUS.Invoice_Charges_tracker' AND IL.LND_UpdateType<>'D'							  
									  --AND IL.ReferenceInvoiceID=1236841109 (Invoice that has only Fee payments no toll payments							  
									  GROUP BY IL.ReferenceInvoiceID
						) FP ON FP.ReferenceInvoiceID = CTE_CURR_INV.InvoiceNumber
			LEFT JOIN																	--- Bring the First and Second Notice Fee Adjustemnts to calculate the Invoice Status
				
		        (
						SELECT 
						IL.ReferenceInvoiceID,
						ISNULL (SUM(CASE WHEN IL.TxnType='FSTNTVFEE' THEN (AmountReceived*-1) ELSE 0 END),0)  FNFeesAdjusted ,
						ISNULL (SUM(CASE WHEN IL.TxnType='SECNTVFEE' THEN (AmountReceived*-1) ELSE 0 END),0)  SNFeesAdjusted 
						FROM lnd_tbos.Tollplus.invoice_lineitems IL	
						JOIN LND_TBOS.TollPlus.TP_Invoice_Receipts_Tracker IRT	 ON IL.LinkID = IRT.Invoice_ChargeID  AND IRT.LND_UpdateType <> 'D'
						JOIN Stage.NonMigInvoice RI ON RI.InvoiceNumber=IL.ReferenceInvoiceID 
						WHERE IRT.LinkSourceName = 'FINANCE.ADJUSTMENTS' 
							  AND IL.TxnType IN ('SECNTVFEE','FSTNTVFEE')
							  AND IL.LinkSourceName = 'TOLLPLUS.invoice_Charges_tracker'
							  AND IL.LND_UpdateType <> 'D'
							  GROUP BY IL.ReferenceInvoiceID		
		
				) FA ON FA.ReferenceInvoiceID = CTE_CURR_INV.InvoiceNumber	
			
		--WHERE CAST(CTE_CURR_INV.InvoiceNumber AS BIGINT) = @invoicenumber
		GROUP BY CAST(CTE_CURR_INV.InvoiceNumber AS  BIGINT),
						 CASE
						 WHEN CTE_FIRST_INV.SourceName IS NOT NULL THEN
						 1
						 ELSE
						 0
						 END,
						 ISNULL(CTE_CURR_INV.CollectionStatus, -1),
						 ISNULL(CTE_INV_DATE.MbsID, -1),
						 ISNULL(CTE_INV_DATE.MbsGeneratedDate, '1900-01-01'),
						 CTE_FIRST_INV.InvoiceID,
						 CTE_CURR_INV.InvoiceID,
						 CTE_CURR_INV.CustomerID,
						 CTE_CURR_INV.AgeStageID,
						 CTE_CURR_INV.VehicleID,
						 CTE_INV_DATE.FirstNoticeDate,
						 CTE_INV_DATE.SecondNoticeDate,
						 CTE_INV_DATE.ThirdNoticeDate,
						 CTE_INV_DATE.LegalActionPendingDate,
						 CTE_INV_DATE.CitationDate,
						 CTE_INV_DATE.DueDate,
						 FP.FirstFeePaymentDate,
						 FP.LastFeePaymentDate,
						 DIS.InvoiceStatusID,
						 CTE_FIRST_INV.LND_UpdateType, 
						 CTE_CURR_INV.LND_UpdateType,
						 ISNULL(Invp.InvoiceAmount,0),
						 ISNULL(InvP.PBMTollAmount,0),
						 ISNULL(InvP.AVITollAmount,0) ,
						 ISNULL(InvP.Tolls,0),
						 ISNULL(F.FNFees, 0),
						 ISNULL(F.SNFees, 0),
						 ISNULL(InvP.TollsPaid,0),				
						 ISNULL(FP.FNFeesPaid,0),
						 ISNULL(FP.SNFeesPaid,0),
						 ISNULL(FA.SNFeesAdjusted,0),
						 ISNULL(FA.FNFeesAdjusted,0),
						 CTE_CURR_INV.InvoiceStatus,
						 ISNULL(InvP.TollsAdjusted,0),
						  InvP.FirstPaymentDate,
						  InvP.LastPaymentDate
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
                     --MI.InvoiceAmount InvoiceAmount_Old,
					 CAST(CASE WHEN VT.VtollFlag=1 THEN (VT.Tolls+MI.FNFees+MI.SNFees) ELSE MI.InvoiceAmount END AS DECIMAL(19,2)) AS InvoiceAmount,
                     CAST(CASE WHEN VT.VtollFlag=1 THEN VT.PBMTollAmount ELSE MI.PBMTollAmount END AS DECIMAL(19,2)) AS PBMTollAmount,
                     CAST(CASE WHEN VT.VtollFlag=1 THEN VT.AVITollAmount ELSE MI.AVITollAmount END AS DECIMAL(19,2)) AS AVITollAmount,
                     CAST(CASE WHEN VT.VtollFlag=1 THEN VT.PremiumAmount ELSE MI.PremiumAmount END AS DECIMAL(19,2)) AS PremiumAmount,
                     --MI.Tolls Tolls_Old,
					 CAST(CASE WHEN VT.VtollFlag=1 THEN VT.Tolls ELSE MI.Tolls END AS DECIMAL(19,2)) AS Tolls,
                     CAST(MI.FNFees AS DECIMAL(19,2)) AS FNFees,
                     CAST(MI.SNFees AS DECIMAL(19,2)) AS SNFees,				
                     CAST(CASE WHEN VT.VTollFlag=1 THEN VT.paidAmount_VT 
						  WHEN VT.VtollFlag=0 THEN (MI.TollsPaid+VT.PaidAmount_VT)
					 ELSE ISNULL(MI.TollsPaid,0) END AS DECIMAL(19,2)) AS  TollsPaid,
                     CAST(MI.FNFeesPaid AS DECIMAL(19,2)) AS FNFeesPaid,
                     CAST(MI.SNFeesPaid AS DECIMAL(19,2)) AS SNFeesPaid,
                     CAST(CASE WHEN VT.VTollFlag=1 THEN VT.TollsAdjusted 
						  WHEN VT.VtollFlag=0 THEN (MI.TollsAdjusted - VT.Tolls) + (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)
					 ELSE ISNULL(MI.TollsAdjusted,0) END AS DECIMAL(19,2)) AS  TollsAdjusted,
                     CAST(MI.FNFeesAdjusted AS DECIMAL(19,2)) AS FNFeesAdjusted,
                     CAST(MI.SNFeesAdjusted AS DECIMAL(19,2)) AS SNFeesAdjusted,
                     MI.EDW_Update_Date,
                     MI.InvoiceStatus
			FROM MI
			LEFT JOIN stage.DismissedVToll VT ON VT.InvoiceNumber = MI.InvoiceNumber




	    OPTION (LABEL = 'Stage.Invoice Load');
		
		SET @Log_Message = 'Loaded Stage.Invoice';
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message,'I',-1,NULL;
		
		-- Statistics
		CREATE STATISTICS STATS_Stage_Invoice_000 ON Stage.Invoice (InvoiceNumber)
		CREATE STATISTICS STATS_Stage_Invoice_001 ON Stage.Invoice (FirstInvoiceID)
		CREATE STATISTICS STATS_Stage_Invoice_002 ON Stage.Invoice (CurrentInvoiceID)
		CREATE STATISTICS STATS_Stage_Invoice_003 ON Stage.Invoice (CustomerID)
		CREATE STATISTICS STATS_Stage_Invoice_004 ON Stage.Invoice (AgeStageID)


		--=============================================================================================================
		-- Load Stage.NonMigratedInvoice
		--=============================================================================================================
		 IF OBJECT_ID('Stage.NonMigratedInvoice') IS NOT NULL DROP TABLE Stage.NonMigratedInvoice
		 CREATE TABLE Stage.NonMigratedInvoice WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber)) 
		 AS 
		  
		 SELECT 
					* ,
					CASE WHEN ISNULL(A.VtollFlag,-1)=1 THEN 99999				
						WHEN A.UnassignedFlag=1 AND (A.FNFeesOutStandingAmount=0 AND A.SNFeesOutStandingAmount=0)  THEN 99998
						WHEN ISNULL(A.VtollFlag,-1) IN (0,-1) AND A.UnassignedFlag=-1  AND ((A.ExpectedAmount-A.AdjustedAmount)=A.PaidAmount) AND (A.ExpectedAmount-A.AdjustedAmount)>0 AND ((FnFeespaid+FnfeesAdjusted)=FNFees) AND ((SNFeespaid+SNFeesAdjusted)=SNFees)  THEN 516
						WHEN ISNULL(A.VtollFlag,-1) IN (0,-1) AND A.UnassignedFlag=-1  AND  A.PaidAmount>0  AND (A.ExpectedAmount-A.AdjustedAmount)>A.PaidAmount OR (A.TollsPaid>0 /*1233478597*/)  THEN 515
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
							CASE WHEN ISNULL(VT.VtollFlag,-1)=0 THEN (CASE WHEN CAST(ISNULL(MI.FirstPaymentDate,'1900-01-01') AS DATE)<CAST(ISNULL(VT.FirstPaymentDate,'1900-01-01') AS DATE) 
																			   AND CAST(ISNULL(MI.FirstPaymentDate,'1900-01-01') AS DATE)<>'1900-01-01' THEN CAST(ISNULL(MI.FirstPaymentDate,'1900-01-01') AS DATE)  
																		   WHEN CAST(ISNULL(MI.FirstPaymentDate,'1900-01-01') AS DATE)>CAST(ISNULL(VT.FirstPaymentDate,'1900-01-01') AS DATE) 
																		       AND CAST(ISNULL(VT.FirstPaymentDate,'1900-01-01') AS DATE) ='1900-01-01'
																			   THEN CAST(ISNULL(MI.FirstPaymentDate,'1900-01-01') AS DATE) 
																	  ELSE CAST(ISNULL(VT.FirstPaymentDate,'1900-01-01') AS DATE) END )
								 WHEN UI.UnassignedFlag=1 THEN NULL 
							ELSE CAST(MI.FirstPaymentDate AS DATE) END 
							)
				   AS FirstPaymentDate, 				   
				   COALESCE(CASE WHEN ISNULL(VT.VtollFlag,-1)=1 THEN CAST(ISNULL(VT.LastPaymentDate,'1900-01-01') AS DATE)
								 WHEN ISNULL(VT.VtollFlag,-1)=1 AND VT.PaidAmount_VT=0 AND VT.Tolls=(CASE WHEN ISNULL(VT.VtollFlag,-1)=1 THEN (VT.TollsAdjusted+VT.TollsAdjustedAfterVtoll+AdjustedAmount_Excused+ClassAdj)
																										ELSE MI.TollsAdjusted END) THEN '1900-01-01' -- This is because paid date is taken from customer trips posted date. eventhough there is no payment(tollspaid=0), there will be a posted date for that invoice
						
							END,
							CASE WHEN ISNULL(VT.VtollFlag,-1)=0 THEN (CASE WHEN CAST(ISNULL(MI.LastPaymentDate,'1900-01-01') AS DATE)>CAST(ISNULL(VT.LastPaymentDate,'1900-01-01') AS DATE) 
																				 THEN CAST(ISNULL(MI.LastPaymentDate,'1900-01-01') AS DATE)  
																	  ELSE CAST(ISNULL(VT.LastPaymentDate,'1900-01-01') AS DATE) END )
								 WHEN UI.UnassignedFlag=1 THEN NULL 
							ELSE CAST(MI.LastPaymentDate AS DATE) END 
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
		
				   ------- EA - Expected Amount
				   MI.Tolls,
		           MI.FNFees,
		           MI.SNFees,
				   (MI.Tolls+MI.FNFees+MI.SNFees) AS  ExpectedAmount,

				   ------- AA - AdjustedAmount
				   MI.TollsAdjusted,
				   MI.FNFeesAdjusted,
				   MI.SNFeesAdjusted,
				   ( MI.TollsAdjusted + MI.FNFeesAdjusted + MI.SNFeesAdjusted)
				   AS AdjustedAmount,
		
				   --------- AEA - AdjustedExpectedAmount
				   ---------- AET = ET-TA
				   (MI.Tolls -  MI.TollsAdjusted)
					AS AdjustedExpectedTolls,
					---------- AEFn = EFn-FnA
					(MI.FNFees-MI.FNFeesAdjusted) AS AdjustedExpectedFNFees,
					---------- AESn = ESn-SnA
					(MI.SNFees-MI.SNFeesAdjusted) AS AdjustedExpectedSNFees,
		
					------- AEA = EA-AA
						(
							(MI.Tolls -  MI.TollsAdjusted) 
						+	(MI.FNFees-MI.FNFeesAdjusted) 
						+   (MI.SNFees-MI.SNFeesAdjusted)
						)
					  AS AdjustedExpectedAmount,
		
		
				   ------- PA - PaidAmount
					MI.TollsPaid,	
					MI.FNFeesPaid,
				    MI.SNFeesPaid,
		
					(MI.TollsPaid + MI.FNFeesPaid+ MI.SNFeesPaid)
					AS PaidAmount,
		
		
					-------- OA  - OutstandingAmount
							-------- TO = AEA-TP
					 CASE 
							 WHEN VTollFlag=1 THEN VT.outstandingamount
							 ELSE 
							 ( ----- AET=ET-TA
							(MI.Tolls -  MI.TollsAdjusted)
							 - ------PA
							 (MI.TollsPaid)
							  )
					 END AS TollOutStandingAmount,
		
							------ FnO = AEFn-FnP
					 
					 ((MI.FNFees-MI.FNFeesAdjusted) - MI.FNFeesPaid) AS FNFeesOutStandingAmount,
					 ((MI.SNFees-MI.SNFeesAdjusted) - MI.SNFeesPaid) AS SNFeesOutStandingAmount,
		
							----- OA = AEA-OA
		
					(CASE 
							 WHEN VTollFlag=1 THEN VT.outstandingamount
							 ELSE 
							 ( ----- AET=ET-TA
							(MI.Tolls -  MI.TollsAdjusted)
							 - ------PA
							 ( MI.TollsPaid)
							  )
					 END )
					 +			 
					 ((MI.FNFees-MI.FNFeesAdjusted) - MI.FNFeesPaid) 
					 +
					 ((MI.SNFees-MI.SNFeesAdjusted) - MI.SNFeesPaid) 
					 AS OutstandingAmount,		
		           
		           MI.EDW_Update_Date,	
				   MI.InvoiceStatus

			FROM Stage.Invoice MI
			LEFT JOIN Stage.DismissedVtoll Vt ON Vt.InvoiceNumber=MI.InvoiceNumber
			LEFT JOIN Stage.UnassignedInvoice UI ON UI.InvoiceNumber=MI.InvoiceNumber
			
			) A

	    OPTION (LABEL = 'Stage.NonMigratedInvoice Load');
		
		SET @Log_Message = 'Loaded Stage.NonMigratedInvoice';
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message,'I',-1,NULL;
		
		-- Statistics
		CREATE STATISTICS STATS_NonMigratedInvoice_000 ON Stage.NonMigratedInvoice (InvoiceNumber)
		CREATE STATISTICS STATS_NonMigratedInvoice_001 ON Stage.NonMigratedInvoice (FirstInvoiceID)
		CREATE STATISTICS STATS_NonMigratedInvoice_002 ON Stage.NonMigratedInvoice (CurrentInvoiceID)
		CREATE STATISTICS STATS_NonMigratedInvoice_003 ON Stage.NonMigratedInvoice (CustomerID)
		CREATE STATISTICS STATS_NonMigratedInvoice_004 ON Stage.NonMigratedInvoice (AgeStageID)
		CREATE STATISTICS STATS_NonMigratedInvoice_006 ON Stage.NonMigratedInvoice (EDW_InvoiceStatusID)


		EXEC Utility.ToLog @Log_Source, @Log_Start_Date,'Completed full load', 'I',NULL,NULL;

		-- Show results
		IF @Trace_Flag = 1  EXEC Utility.FromLog @Log_Source, @Log_Start_Date;
		IF @Trace_Flag = 1  SELECT TOP 1000 'stage.NonMigratedInvoice ' TableName, * FROM Stage.NonMigratedInvoice   ORDER BY 2 DESC;
	
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


SELECT * FROM lnd_tbos.tollplus.invoice_header WHERE invoicenumber=1204145788

Multiple TpTripID's posted to VT table -- Ex:1230780604
SELECT * FROM LND_TBOS.TollPlus.TP_ViolatedTrips WHERE CitationID IN (
SELECT linkID FROM LND_TBOS.TollPlus.Invoice_LineItems WHERE ReferenceInvoiceID=1226708097 AND CustTxnCategory='Toll') order by tptripID

Invoices Paid using Overpayment

SELECT * FROM  LND_TBOS.TollPlus.TP_Violated_Trip_Receipts_Tracker WHERE CitationID IN 
(SELECT linkid FROM LND_TBOS.TollPlus.Invoice_LineItems WHERE ReferenceInvoiceID=1237618377 /*908343647*/ AND CustTxnCategory='TOLL')

Overpayments in receipts tracker table

SELECT * FROM  LND_TBOS.TollPlus.TP_Violated_Trip_Receipts_Tracker VTRT
join LND_TBOS.TollPlus.TP_ViolatedTrips VT on VT.CitationID=VTRT.CitationID
WHERE VTRT.CitationID IN 
(SELECT * FROM LND_TBOS.TollPlus.Invoice_LineItems WHERE ReferenceInvoiceID=1228683740 /*908343647*/ AND CustTxnCategory='TOLL')
and VTRT.citationID=2083171984
order by VTRT.citationID

select * from edw_TRIPS_OLD.dbo.fact_invoice where invoicenumber=1228683740
*/



