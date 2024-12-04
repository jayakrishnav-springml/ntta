CREATE OR REPLACE PROCEDURE `prj-ntta-ops-bi-prod-svc-01.EDW_TRIPS.Fact_Invoice_Full_Load`()
BEGIN
/*
##################################################################################################################################
Proc Description: 
----------------------------------------------------------------------------------------------------------------------------------
Load [dbo].[Fact_Invoice_Full_Load] table. 
EXEC [dbo].[Fact_Invoice_Full_Load]
==================================================================================================================================
Change Log:
----------------------------------------------------------------------------------------------------------------------------------
CHG0037838	Bhanu/Gouthami		2020-11-04	New!
CHG0037897  Gouthami			2021-01-13  Added left join to the MBS tables in CTE_INV_DATE for the missing 
											Citations.
CHG0038039	Gouthami			2021-01-27	Added Delete Flag
CHG0038304	Gouthami			2021-02-24	CTE_INV_DATE - Added the case statement for LND_UpdateType in group
											by as it is causing duplicates
CHG0039382	Gouthami			2021-08-11  Added the filter as it is causing duplicate invoices starting with 
											00 and 'DCBInvoiceGeneration' which should not be part of the invoice
											header table.
CHG0040131	Gouthami			2021-12-15	a. Changed the logic for Invoice Status as Source data is nor correct.
											b. Added news columns - FeesAdjusted,TollsAdjusted. 
											c. Modified the logic for Tolls Paid as the payments are showing correct.
											d. Created logic to find out the Dismissed Vtolls.
CHG0040437 	Gouthami			2021-02-16	Added ISNULL for SNFees and FNFees in the EDW_InvoiceStatusID logic. 
											This will fix -1 status ID.			

CHG0042443  Gouthami			2023-02-09	1.Divided this Stored Procedure in to 3 loads.
												1) Ref.RiteMigratedInvoice_Full_Load (Used to bring all the migrated data)
												2) Stage.MigratedNonTerminalInvoice_Full_Load (To bring all the migrated 
																		             non terminal invoices from REF table)
												3) Stage.NonMigratedInvoice_Full_Load ( to bring all the Non migrated invoices)
										    2. This load is the Union of all above tables.
											3. Below changes are done in this stored procedure for Item 90
											a. Added below metrics 
												1. EA  (Expected Amount)
												2. AA  (Adjusted Amount)= TA+FA+SA
												3. AET (Adjusted Expected Tolls) = ET-TA (ExpectedTolls-TollsAdjusted)
												4. AEF (Adjusted Expected FnFees) = EF - FA (ExpectedFnFees-FnFeesAdjusted)
												5. AES (Adjusted Expected SnFees) = ES - SA (ExpectedSnFees-SNfeesAdjusted)
												6. AEA (Adjusted Expected Amount) = EA-AA
												4. PA  (PaidAmount) = TP+FP+SP
												5. OA  (Outstanding Amount) = AEA- PA
											b. Modified Invoice Status logic 
											c. VTOLLS - Changed the logic for Dismissed Vtolled to avoid partial Vtolls 
														and added a different logic to bring rite data for VTOLLS.
											d. Unassigned - Added a logic to identify Unassigned Invoices. This should 
															give only those invoices where all the transactions are 
															Unassigned  and avoid partial Unassigned ones.Partial Unassigned
															will either go in to Parital Paid/Open based on the payments.
											e. Toll Adjustments - Modified Toll Adjustments in order to bring all the 
																	adjustments for Unassigned transactions as well.
																	Added Union all with two queries because there were few 
																	adjustments missing as TRIPS is assigning some of the 
																	adjustments to InvoiceID=0.
																	And also, added one more to bring the adjustments from RITE
																	tables only for migrated data
											f. Tolls Paid - Modified Tolls Paid logic in order to bring all the payments for 
															Unassigned transactions as well.Added Union all with two queries 
															because there were few payments missing as TRIPS is assigning some
															of the adjustments to InvoiceID=0.
											g. Changed the column from citationID/LinkID to ABS(CitationID)/ABS(LinkID) to bring 
												all the Unassigned Txns/ Invoices as well
											h. VTOLL logic - This created based on Pat's requirements. 
															 ExpectedAmount - This is calculated based on the toll amount and the 
																			  type of Vtoll. If an invoice is VTolled at PBMTAmount
																			  then the EA is PBMTAmount, if it is VTOLLED at AVI 
																			  rate then EA is AVI.
															 AdjustmentAmount - If an invoice is VTolled at PBMTAmount then there 
																				is no adjustment. If it is VTolled at AVI rate then 
																				the Adjustment is the delta beetween Tolls and 
																				PBMTAmount.
															 PaidAmount -	This is direct column from the Tollplus.TP_CustomerTrips
																			table.
															 OA - This is direct column from the Tollplus.TP_CustomerTrips table.
											I. InvoiceStatus
												1. Open					-- Paidamount=0 and AEA>0
												2. Partial Paid			-- AEA>0 and PA>0 and OA>0
												3. Paid					-- PA=AEA and OA=0
												4. Closed/Dimissed		-- AEA=AA and PA=0 (AA>AEA)
												5. Dismissed Vtolls		-- when invnum is in stage.dismissedvtolls table
												6. Dismissed Unassigned	-- when invnum is in stage.UnassignedInvoices table
												7. Unknown			-- If an invoice is not satisfying any of the above statuses then 
																		consider those as Unknown
											J. Stage.InvoicedViolatedTripPayment - Added this logic from bubble to bring the First and 
																					last paid dates

CHG0045358	  Gouthami			2024-06-17	 Added 13 column part of Phase 2.
											   VtollTxncnt
											   ExcusedTxnCnt
											   UnassignedTxncnt	
											   PaidTxncnt											   
											   NoOfTimesSentToPrimary
											   NoOfTimesSentToSecondary
											   Paymentchannel
											   POS
											   PrimaryCollectionAgency
											   SecondaryCollectionagency
											   PaymentPlanID
											   PrimaryCollectionAgencyDate
											   SecondaryCollectionAgencyDate	
		  Gouthami			2024-09-05	Fixed Firspayment date issue caused by phase3 changes.
								Fixed FirstFeepaymentdate columns for migrated invoices by pulling the data from TRIPS tables									

==================================================================================================================================================
Example:
--------------------------------------------------------------------------------------------------------------------------------------------------
EXEC Utility.FromLog 'dbo.Fact_Invoice_Full_Load', 1
SELECT TOP 100 'dbo.Fact_Invoice' Table_Name, * FROM dbo.Fact_Invoice ORDER BY 2
##################################################################################################################################################
*/

    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_Invoice_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
      
      --=================================================================================================================
      -- Load dbo.Fact_Invoice_New -- This table is being loaded by 3 tables  -- Ref.RiteMigratedInvoice
                                                                              -- Stage.MigratedNonTerminalInvoice 
                                                                              -- Stage.NonMigratedInvoice 
      --=================================================================================================================

      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_Invoice
        AS
          SELECT i.invoicenumber,
              i.firstinvoiceid,
              i.currentinvoiceid,
              coalesce(i.customerid, -1) AS customerid,
              NULL AS testcasefailedflag,
              i.migratedflag,
              CASE
                WHEN i.edw_invoicestatusid = 99999 THEN 1
                ELSE -1
              END AS vtollflag,

              -1 AS unassignedflag,
              i.agestageid,
              i.collectionstatusid,
              i.currmbsid,
              coalesce(i.vehicleid, -1) AS vehicleid,
              CASE
                WHEN i.invoicestatus = 'DismissedUnassigned'
                 AND i.edw_invoicestatusid IS NULL THEN 99998
                ELSE i.edw_invoicestatusid
              END AS edw_invoicestatusid,
              -1 AS paymentplanid,
              CAST( i.zipcashdate as DATE) AS zipcashdate,
              CAST( i.firstnoticedate as DATE) AS firstnoticedate,
              CAST( i.secondnoticedate as DATE) AS secondnoticedate,
              cast(i.thirdnoticedate as date) AS thirdnoticedate,
              cast(i.legalactionpendingdate as date) AS legalactionpendingdate,
              CAST( i.citationdate as DATE) AS citationdate,
              CAST( i.duedate as DATE) AS duedate,
              CAST( i.currmbsgenerateddate as DATE) AS currmbsgenerateddate,
              CAST( CASE WHEN i.firstpaymentdate IS NULL THEN coalesce(invp.firstpaymentdatepriortozc,              
                      invp.firstpaymentdateafterzc)
				            ELSE i.firstpaymentdate
				            END as DATE) AS firstpaymentdate,
			        CAST( CASE WHEN i.lastpaymentdate IS NULL THEN coalesce(invp.lastpaymentdatepriortozc,       
                          invp.lastpaymentdateafterzc)
					          ELSE i.lastpaymentdate
					          END as DATE) AS lastpaymentdate,
             CAST(fp.firstfeepaymentdate as DATE) AS firstfeepaymentdate,
			       CAST(fp.lastfeepaymentdate as DATE) AS lastfeepaymentdate,
              NULL AS primarycollectionagencydate,
              NULL AS secondarycollectionagencydate,
              i.txncnt,
              NULL AS vtolltxncnt,
              NULL AS excusedtxncnt,
              NULL AS unassignedtxncnt,
              NULL AS paidtxncnt,
              NULL AS nooftimessenttoprimary,
              NULL AS nooftimessenttosecondary,
              NULL AS paymentchannel,
              NULL AS pos,
              NULL AS primarycollectionagency,
              NULL AS secondarycollectionagency,


              --NULL PaidTxnCntPriortoZC,
              CAST( i.invoiceamount as NUMERIC) AS invoiceamount,
              CAST( i.pbmtollamount as NUMERIC) AS pbmtollamount,
              CAST( i.avitollamount as NUMERIC) AS avitollamount,
              CAST( i.premiumamount as NUMERIC) AS premiumamount,


              CAST( i.tolls as NUMERIC) AS tolls,
              --NULL VtollAmount,
			        --NULL ExcusedAmount,
              CAST( i.fnfees as NUMERIC) AS fnfees,
              CAST( i.snfees as NUMERIC) AS snfees,
              CAST( i.expectedamount as NUMERIC) AS expectedamount,
              --NULL VtollExpectedAmountPriortoZC,



              CAST( i.tollsadjusted as NUMERIC) AS tollsadjusted,
              CAST( i.fnfeesadjusted as NUMERIC) AS fnfeesadjusted,
              CAST( i.snfeesadjusted as NUMERIC) AS snfeesadjusted,
              CAST( i.adjustedamount as NUMERIC) AS adjustedamount,
              CAST( i.adjustedexpectedtolls as NUMERIC) AS adjustedexpectedtolls,



              --NULL AdjustedExpectedVTollsPriortoZC,
              CAST( i.adjustedexpectedfnfees as NUMERIC) AS adjustedexpectedfnfees,
              CAST( i.adjustedexpectedsnfees as NUMERIC) AS adjustedexpectedsnfees,
              CAST( i.adjustedexpectedamount as NUMERIC) AS adjustedexpectedamount,


              CAST( i.tollspaid as NUMERIC) AS tollspaid,
              --NULL VTollsPaidPriortoZC,
              CAST( i.fnfeespaid as NUMERIC) AS fnfeespaid,
              CAST( i.snfeespaid as NUMERIC) AS snfeespaid,
              CAST( i.paidamount as NUMERIC) AS paidamount,


              CAST( i.tolloutstandingamount as NUMERIC) AS tolloutstandingamount,
              CAST( i.fnfeesoutstandingamount as NUMERIC) AS fnfeesoutstandingamount,
              CAST( i.snfeesoutstandingamount as NUMERIC) AS snfeesoutstandingamount,
              CAST( i.outstandingamount as NUMERIC) AS outstandingamount,
              coalesce(current_datetime(), DATETIME '1900-01-01') AS edw_update_date
      FROM
        edw_trips_support.ritemigratedinvoice AS i
        LEFT OUTER JOIN edw_trips_stage.invoicepayment AS invp ON invp.invoicenumber = i.invoicenumber
        LEFT OUTER JOIN (
               SELECT
                  il.referenceinvoiceid,
                  min(irt.txndate) AS firstfeepaymentdate,
                  max(irt.txndate) AS lastfeepaymentdate,
                  coalesce(sum(CASE
                                WHEN il.txntype = 'FSTNTVFEE' THEN irt.amountreceived * -1
                                ELSE 0
                  END), 0) AS fnfeespaid,
                  coalesce(sum(CASE
                              WHEN il.txntype = 'SECNTVFEE' THEN irt.amountreceived * -1
                              ELSE 0
                              END), 0) AS snfeespaid
                FROM
                lnd_tbos.tollplus_invoice_lineitems AS il
                INNER JOIN lnd_tbos.tollplus_tp_invoice_receipts_tracker AS irt ON il.linkid = irt.invoice_chargeid
                  AND irt.lnd_updatetype <> 'D'
                  AND irt.linksourcename = 'FINANCE.PAYMENTTXNS'
                WHERE il.linksourcename = 'TOLLPLUS.Invoice_Charges_tracker'
                AND il.lnd_updatetype <> 'D'
                 GROUP BY 1
          ) AS fp ON cast(fp.referenceinvoiceid as INT64) = i.invoicenumber
          WHERE CASE
                WHEN invoicestatus = 'DismissedUnassigned'
                AND edw_invoicestatusid IS NULL THEN 99998
                ELSE edw_invoicestatusid
                END <> 4370 
          AND i.zipcashdate >= '2019-01-01'
          UNION DISTINCT

          SELECT
              mi.invoicenumber,
              mi.firstinvoiceid,
              mi.currentinvoiceid,
              coalesce(mi.customerid, -1) AS customerid,
              NULL AS testcasefailedflag,
              mi.migratedflag,
              mi.vtollflag,
              mi.unassignedflag,
              mi.agestageid,
              mi.collectionstatusid,
              mi.currmbsid,
              coalesce(mi.vehicleid, -1) AS vehicleid,
              CASE 
              
                -- Dismissed Vtolled
                WHEN mi.vtollflag = 1 THEN 99999 
                
                -- Paid -- AEA=PA and AEA>0
                WHEN mi.adjustedexpectedamount = mi.paidamount
                 AND mi.adjustedexpectedamount > 0
                 AND mi.outstandingamount = 0 THEN 516 
                 
                -- PartialPaid		 --PA>0 and EA-AA>PA
                WHEN mi.paidamount > 0
                 AND mi.expectedamount - mi.adjustedamount > mi.paidamount THEN 515 
                 
                -- Dismissed Unassigned	
                WHEN mi.unassignedflag = 1
                 AND mi.expectedamount - mi.adjustedamount = 0 THEN 99998 
                 
                -- Open -- PA=0 and EA-AA>0 and EA>AA
                WHEN mi.paidamount = 0
                 AND mi.expectedamount - mi.adjustedamount > 0
                 AND mi.expectedamount > mi.adjustedamount THEN 4370 -- Closed
                WHEN mi.invoicestatusid = 4434 THEN 4434
                WHEN mi.expectedamount = mi.adjustedamount
                 AND mi.paidamount = 0 THEN 4434
                ELSE -1
              END AS edw_invoicestatusid,
              coalesce(mi.paymentplanid, -1) AS paymentplanid,
              CAST( mi.zipcashdate as DATE) AS zipcashdate,
              CAST( mi.firstnoticedate as DATE) AS firstnoticedate,
              CAST( mi.secondnoticedate as DATE) AS secondnoticedate,
              CAST( mi.thirdnoticedate as DATE) AS thirdnoticedate,
              CAST( mi.legalactionpendingdate as DATE) AS legalactionpendingdate,
              CAST( mi.citationdate as DATE) AS citationdate,
              CAST( mi.duedate as DATE) AS duedate,
              CAST( mi.currmbsgenerateddate as DATE) AS currmbsgenerateddate,
              CASE 
					  WHEN MI.FirstPaymentDatePriortoZC IS NULL THEN MI.FirstPaymentDateAfterZC
					--WHEN --516
					--	AdjustedExpectedAmount=PaidAmount
					--	AND
     --                   AdjustedExpectedAmount>0
					--	AND 
					--	OutstandingAmount=0
					-- AND (MI.FirstPaymentDatePriortoZC='1900-01-01' OR FirstPaymentDatePriortoZC IS NULL) THEN CAST(FirstFeePaymentDate AS DATE)
					WHEN  --515
						  PaidAmount > 0 AND 
						  (ExpectedAmount-AdjustedAmount)> PaidAmount
					  AND (FirstPaymentDatePriortoZC='1900-01-01' OR FirstPaymentDatePriortoZC IS NULL) THEN CAST(FirstFeePaymentDate AS 
              DATE)
					WHEN EDW_InvoiceStatusID=4434 AND TollsPaid<=0 THEN '1900-01-01' --1236078604
					WHEN MI.EDW_InvoiceStatusID=516 AND MI.TollsPaid=0 AND (MI.FNFeespaid <> 0 OR MI.SNFeesPaid<>0)
						 THEN CAST(MI.FirstFeePaymentDate AS DATE)
				  ELSE FirstPaymentDatePriortoZC END 
				  AS FirstPaymentDate,
				  CASE
					WHEN MI.LastPaymentDatePriortoZC IS NULL THEN MI.LastPaymentDateAfterZC
					--WHEN 
					--	AdjustedExpectedAmount=PaidAmount
					--	AND
     --                   AdjustedExpectedAmount>0
					--	AND 
					--	OutstandingAmount=0
					--	AND (LastPaymentDatePriortoZC='1900-01-01' OR LastPaymentDatePriortoZC IS NULL) THEN CAST(LastFeePaymentDate AS DATE)					 
					    WHEN  --515
						  PaidAmount > 0 AND 
						  (ExpectedAmount-AdjustedAmount)> PaidAmount
						   AND LastPaymentDatePriortoZC='1900-01-01' THEN CAST(LastFeePaymentDate AS DATE)
				    	WHEN EDW_InvoiceStatusID=4434 AND TollsPaid<=0 THEN '1900-01-01' --1236078604
					    WHEN MI.EDW_InvoiceStatusID=516 AND MI.TollsPaid=0 AND (MI.FNFeespaid <> 0 OR MI.SNFeesPaid<>0)
						     THEN CAST(MI.LastFeePaymentDate AS DATE)
				    	ELSE LastPaymentDatePriortoZC END 
				      AS LastPaymentDate,
              CAST( mi.firstfeepaymentdate as DATE) AS firstfeepaymentdate,
              CAST( mi.lastfeepaymentdate as DATE) AS lastfeepaymentdate,
              CAST(mi.primarycollectionagencydate as DATE) AS primarycollectionagencydate,
              CAST(mi.secondarycollectionagencydate as DATE) AS secondarycollectionagencydate,
              mi.txncnt,
              mi.vtolltxncnt,
              mi.excusedtxncnt,
              mi.unassignedtxncnt,
              mi.paidtxncnt,
              mi.nooftimessenttoprimary,
              mi.nooftimessenttosecondary,
              mi.paymentchannel,
              mi.pos,
              mi.primarycollectionagency,
              mi.secondarycollectionagency,


              --PaidTxnCntPriortoZC, 
              CAST( mi.invoiceamount as NUMERIC) AS invoiceamount,
              CAST( mi.pbmtollamount as NUMERIC) AS pbmtollamount,
              CAST( mi.avitollamount as NUMERIC) AS avitollamount,
              CAST( mi.premiumamount as NUMERIC) AS premiumamount,


              CAST( mi.tolls as NUMERIC) AS tolls,
              --CAST(VtollAmount AS NUMERIC) AS VtollAmount,
			        --CAST(ExcusedAmount AS NUMERIC) AS ExcusedAmount
              CAST( mi.fnfees as NUMERIC) AS fnfees,
              CAST( mi.snfees as NUMERIC) AS snfees,
              CAST( mi.expectedamount as NUMERIC) AS expectedamount,


              --VtollExpectedAmountPriortoZC,
              CAST( mi.tollsadjusted as NUMERIC) AS tollsadjusted,
              CAST( mi.fnfeesadjusted as NUMERIC) AS fnfeesadjusted,
              CAST( mi.snfeesadjusted as NUMERIC) AS snfeesadjusted,
              CAST( mi.adjustedamount as NUMERIC) AS adjustedamount,

              
              CAST( mi.adjustedexpectedtolls as NUMERIC) AS adjustedexpectedtolls,


              --AdjustedExpectedVTollsPriortoZC,
              CAST( mi.adjustedexpectedfnfees as NUMERIC) AS adjustedexpectedfnfees,
              CAST( mi.adjustedexpectedsnfees as NUMERIC) AS adjustedexpectedsnfees,
              CAST( mi.adjustedexpectedamount as NUMERIC) AS adjustedexpectedamount,


              CAST( mi.tollspaid as NUMERIC) AS tollspaid,


              --VTollsPaidPriortoZC,
              CAST( mi.fnfeespaid as NUMERIC) AS fnfeespaid,
              CAST( mi.snfeespaid as NUMERIC) AS snfeespaid,
              CAST( mi.paidamount as NUMERIC) AS paidamount,
              CAST( mi.tolloutstandingamount as NUMERIC) AS tolloutstandingamount,
              CAST( mi.fnfeesoutstandingamount as NUMERIC) AS fnfeesoutstandingamount,
              CAST( mi.snfeesoutstandingamount as NUMERIC) AS snfeesoutstandingamount,
              CAST( mi.outstandingamount as NUMERIC) AS outstandingamount,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_update_date --55 select *
          FROM
            EDW_TRIPS_STAGE.MigratedNonTerminalInvoice AS mi

          UNION DISTINCT

          SELECT
              nmi.invoicenumber,
              nmi.firstinvoiceid,
              nmi.currentinvoiceid,
              nmi.customerid,
              NULL AS testcasefailedflag,
              nmi.migratedflag,
              nmi.vtollflag,
              nmi.unassignedflag,
              nmi.agestageid,
              nmi.collectionstatusid,
              nmi.currmbsid,
              nmi.vehicleid,
              CASE 
              
                -- Dismissed Vtolled
                WHEN nmi.vtollflag = 1 THEN 99999 
                
                -- Paid -- AEA=PA and AEA>0
                WHEN nmi.adjustedexpectedamount = nmi.paidamount
                 AND nmi.adjustedexpectedamount > 0
                 AND nmi.outstandingamount = 0 THEN 516 
                 
                -- PartialPaid		 --PA>0 and EA-AA>PA
                WHEN nmi.paidamount > 0
                 AND nmi.expectedamount - nmi.adjustedamount > nmi.paidamount THEN 515 
                 
                -- Dismissed Unassigned
                WHEN nmi.unassignedflag = 1
                 AND nmi.expectedamount - nmi.adjustedamount = 0 THEN 99998 
                 
                -- Open -- PA=0 and EA-AA>0 and EA>AA
                WHEN nmi.paidamount = 0
                 AND nmi.expectedamount - nmi.adjustedamount > 0
                 AND nmi.expectedamount > nmi.adjustedamount THEN 4370 
                 
                -- Closed
                WHEN nmi.invoicestatusid = 4434 THEN 4434
                WHEN nmi.expectedamount = nmi.adjustedamount
                 AND nmi.paidamount = 0 THEN 4434
                ELSE -1
              END AS edw_invoicestatusid,
              coalesce(nmi.paymentplanid, -1) AS paymentplanid,
              nmi.zipcashdate,
              CAST(nmi.firstnoticedate as DATE),
              CAST(nmi.secondnoticedate as DATE),
              CAST(nmi.thirdnoticedate as DATE),
              CAST(nmi.legalactionpendingdate as DATE),
              CAST(nmi.citationdate as DATE),
              nmi.duedate,
              nmi.currmbsgenerateddate,
              CASE 
					WHEN NMI.FirstPaymentDatePriortoZC IS NULL THEN NMI.FirstPaymentDateAfterZC
					--WHEN --516
					--	AdjustedExpectedAmount=PaidAmount
					--	AND
     --                   AdjustedExpectedAmount>0
					--	AND 
					--	OutstandingAmount=0
					-- AND (FirstPaymentDatePriortoZC='1900-01-01' OR FirstpaymentDatePriortoZC IS NULL) THEN CAST(FirstFeePaymentDate AS DATE)
					WHEN  --515
						  PaidAmount > 0 AND 
						  (ExpectedAmount-AdjustedAmount)> PaidAmount
						 AND FirstpaymentDatePriortoZC='1900-01-01' THEN CAST(FirstFeePaymentDate AS DATE)
					WHEN EDW_InvoiceStatusID=4434 AND TollsPaid<=0 THEN '1900-01-01' --1236078604
					WHEN NMI.EDW_InvoiceStatusID=516 AND NMI.TollsPaid=0 AND (NMI.FNFeespaid<> 0 OR NMI.SNFeesPaid<>0)
						 THEN CAST(NMI.FirstFeePaymentDate AS DATE)
					
					ELSE FirstpaymentDatePriortoZC END 
				FirstPaymentDate,
				CASE 
					WHEN NMI.LastPaymentDatePriortoZC IS NULL THEN NMI.LastPaymentDateAfterZC
					--WHEN --516
					--	AdjustedExpectedAmount=PaidAmount
					--	AND
          --  AdjustedExpectedAmount>0
					--	AND 
					--	OutstandingAmount=0
					-- AND (LastPaymentDatePriortoZC='1900-01-01' OR LastPaymentDatePriortoZC IS NULL)  THEN CAST(LastFeePaymentDate        
          --AS        DATE)
					 
					    WHEN  --515
						  PaidAmount > 0 AND 
						  (ExpectedAmount-AdjustedAmount)> PaidAmount
						  AND (LastPaymentDatePriortoZC='1900-01-01' or LastPaymentDatePriortoZC is null)  THEN CAST(LastFeePaymentDate AS DATE)
					    WHEN EDW_InvoiceStatusID=4434  AND TollsPaid<=0 THEN '1900-01-01' --1236078604
					    WHEN NMI.EDW_InvoiceStatusID=516 AND NMI.TollsPaid=0 AND (NMI.FNFeespaid <> 0 OR NMI.SNFeesPaid<>0)
						  THEN CAST(NMI.LastFeePaymentDate AS DATE)
					
				      ELSE LastPaymentDatePriortoZC END 
				      LastPaymentDate,
              CAST( nmi.firstfeepaymentdate as DATE) AS firstfeepaymentdate,
              CAST( nmi.lastfeepaymentdate as DATE) AS lastfeepaymentdate,


              CAST( nmi.primarycollectionagencydate as DATE) AS primarycollectionagencydate,
              CAST(nmi.secondarycollectionagencydate as DATE) AS secondarycollectionagencydate,


              nmi.txncnt,
              nmi.vtolltxncnt,
              nmi.excusedtxncnt,
              nmi.unassignedtxncnt,
              nmi.paidtxncnt,


              nmi.nooftimessenttoprimary,
              nmi.nooftimessenttosecondary,
              nmi.paymentchannel,
              nmi.pos,
              nmi.primarycollectionagency,
              nmi.secondarycollectionagency,


              --PaidTxnCntPriortoZC,
              CAST( nmi.invoiceamount as NUMERIC) AS invoiceamount,
              CAST( nmi.pbmtollamount as NUMERIC) AS pbmtollamount,
              CAST( nmi.avitollamount as NUMERIC) AS avitollamount,
              CAST( nmi.premiumamount as NUMERIC) AS premiumamount,


              CAST( nmi.tolls as NUMERIC) AS tolls,
              --CAST(VtollAmount AS DECIMAL(19,2)) AS VtollAmount,
			        --CAST(ExcusedAmount AS DECIMAL(19,2)) AS ExcusedAmount,
              CAST( nmi.fnfees as NUMERIC) AS fnfees,
              CAST( nmi.snfees as NUMERIC) AS snfees,
              CAST( nmi.expectedamount as NUMERIC) AS expectedamount,
              --ExpectedAmountPriortoZC,
			        --VtollExpectedAmountPriortoZC,
              CAST( nmi.tollsadjusted as NUMERIC) AS tollsadjusted,
              CAST( nmi.fnfeesadjusted as NUMERIC) AS fnfeesadjusted,
              CAST( nmi.snfeesadjusted as NUMERIC) AS snfeesadjusted,
              CAST( nmi.adjustedamount as NUMERIC) AS adjustedamount,


              CAST( nmi.adjustedexpectedtolls as NUMERIC) AS adjustedexpectedtolls,


              --AdjustedExpectedVTollsPriortoZC,
              CAST( nmi.adjustedexpectedfnfees as NUMERIC) AS adjustedexpectedfnfees,
              CAST( nmi.adjustedexpectedsnfees as NUMERIC) AS adjustedexpectedsnfees,
              CAST( nmi.adjustedexpectedamount as NUMERIC) AS adjustedexpectedamount,


              CAST( nmi.tollspaid as NUMERIC) AS tollspaid,


              --VTollsPaidPriortoZC,
              CAST( nmi.fnfeespaid as NUMERIC) AS fnfeespaid,
              CAST( nmi.snfeespaid as NUMERIC) AS snfeespaid,
              CAST( nmi.paidamount as NUMERIC) AS paidamount,


              CAST( nmi.tolloutstandingamount as NUMERIC) AS tolloutstandingamount,
              CAST( nmi.fnfeesoutstandingamount as NUMERIC) AS fnfeesoutstandingamount,
              CAST( nmi.snfeesoutstandingamount as NUMERIC) AS snfeesoutstandingamount,
              CAST( nmi.outstandingamount as NUMERIC) AS outstandingamount,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_update_date
            FROM
              EDW_TRIPS_STAGE.NonMigratedInvoice AS nmi 
              --WHERE InvoiceNumber=1225293772
      ;
      SET log_message = 'Loaded EDW_TRIPS.Fact_Invoice';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', NULL, NULL);
     
      -- PAID

      --- Closed invoices which has paidamount>0
      --- Updating all the invoices to Paid which are in Closed,Unknown and Unassigned statuses.
      --- Updating Unknowns to Paid - According to Pat, Marking all the Unknowns to paid which has payments and more adjustments.
      --- Updating Closed Invoices to Paid - Closed invoices are supposed to dismissed/completely closed with no payments. We see few closed invoices with payments and over adjustments. According to Pat, these invoices needs to be in Paid bucket
      --- Updating Unassigned to Paid - Eventhough these invoices are Unassigned, if there any payments to those invoices , we need to mark those as Paid
		      
      UPDATE EDW_TRIPS.Fact_Invoice 
      SET edw_invoicestatusid = 516, 
          firstpaymentdate = 
          CASE
            WHEN Fact_Invoice.firstpaymentdate = DATE '1900-01-01' THEN Fact_Invoice.firstfeepaymentdate
            ELSE Fact_Invoice.firstpaymentdate
          END, 
          lastpaymentdate = 
          CASE
            WHEN Fact_Invoice.lastpaymentdate = DATE '1900-01-01' THEN Fact_Invoice.lastfeepaymentdate
            ELSE Fact_Invoice.lastpaymentdate
          END 
      WHERE Fact_Invoice.edw_invoicestatusid IN(4434, -1) --99998 add unassigned for migrated ones after talking to pat
        AND (Fact_Invoice.paidamount > 0
        OR  Fact_Invoice.tollspaid > 0)
        AND Fact_Invoice.outstandingamount <= 0;
				
      --- UNASSIGNED

      --- Migrated closed Invoices needs to be updated to their original adjustment amount as we are not bringing the correct adjustment amount for these couple of invoices from Rite tables.
      --- The reason we are doing this as we cannot change the rite query logic only for these few invoices. 
      
      --UPDATE [dbo].[Fact_Invoice_New] 
      --SET TollsAdjusted=Tolls
      --	,AdjustedAmount=(tolls+FNFeesAdjusted+SNFeesAdjusted)
      --	,AdjustedExpectedTolls=0
      --	,AdjustedExpectedAmount=0
      --	,TollOutStandingAmount=0
      --	,OutstandingAmount=0
      --WHERE  EDW_InvoiceStatusID=99998 AND 
      --AdjustedExpectedAmount<>0
      --AND ZipCashDate>='2019-01-01'
      
      -- OPEN	

      -- There are Unknown status invoices which have -ve payments and adjustments. In this case, we are seeing nothing is paid on the invoice and need to mark those as OPEN
			
      UPDATE EDW_TRIPS.Fact_Invoice
        SET edw_invoicestatusid = 4370, 
            firstpaymentdate = DATE '1900-01-01', 
            lastpaymentdate = DATE '1900-01-01', 
            firstfeepaymentdate = DATE '1900-01-01', 
            lastfeepaymentdate = DATE '1900-01-01' 
        WHERE Fact_Invoice.edw_invoicestatusid IN(-1)
          AND Fact_Invoice.paidamount <= 0
          AND Fact_Invoice.outstandingamount > 0;

		
      -- PARTIAL PAID

      -- There are can be invoices which are partially paid in Closed and Unknown Statuses. In order to find those and update it to correct status, bring those invoices which has payments and outstanding amount. 		
		

      UPDATE EDW_TRIPS.Fact_Invoice 
      SET edw_invoicestatusid = 515, 
          firstpaymentdate = 
          CASE
            WHEN Fact_Invoice.firstpaymentdate = DATE '1900-01-01' THEN Fact_Invoice.firstfeepaymentdate
            ELSE Fact_Invoice.firstpaymentdate
          END, 
          lastpaymentdate = 
          CASE
            WHEN Fact_Invoice.lastpaymentdate = DATE '1900-01-01' THEN Fact_Invoice.lastfeepaymentdate
            ELSE Fact_Invoice.lastpaymentdate
          END 
      WHERE (Fact_Invoice.tollspaid > 0
        OR  Fact_Invoice.fnfeespaid > 0
        OR  Fact_Invoice.snfeespaid > 0)
        AND Fact_Invoice.outstandingamount > 0
        AND Fact_Invoice.edw_invoicestatusid IN(-1, 4434)
        AND Fact_Invoice.zipcashdate >= DATE '2019-01-01';
      -- CLOSED

      -- Finding out the closed invoices from Unknowns. According to Pat, If nothing is paid and over adjustments are happened then mark those to closed status.
      -- These are the invoices where Adjustments are more than the Expected amount.
		
      UPDATE EDW_TRIPS.Fact_Invoice 
      SET edw_invoicestatusid = 4434, 
          firstpaymentdate = DATE '1900-01-01', 
          lastpaymentdate = DATE '1900-01-01' 
      WHERE Fact_Invoice.adjustedamount > Fact_Invoice.expectedamount
        AND Fact_Invoice.paidamount <= 0
        AND Fact_Invoice.edw_invoicestatusid IN(-1)
        AND Fact_Invoice.zipcashdate >= DATE '2019-01-01';

		  ---====== PaymentDates fix ============-----------------    
      UPDATE EDW_TRIPS.Fact_Invoice 
      SET firstpaymentdate = DATE '1900-01-01', 
          lastpaymentdate = DATE '1900-01-01', 
          firstfeepaymentdate = DATE '1900-01-01', 
          lastfeepaymentdate = DATE '1900-01-01' 
      WHERE Fact_Invoice.edw_invoicestatusid = 4370;
      
      
      UPDATE EDW_TRIPS.Fact_Invoice 
      SET firstpaymentdate = Fact_Invoice.firstfeepaymentdate, 
          lastpaymentdate = Fact_Invoice.lastfeepaymentdate 
      WHERE Fact_Invoice.edw_invoicestatusid = 516
        AND Fact_Invoice.tollspaid = 0;
      --------==== Downgrading fix ==== -------
      ------ Fix the FN,SN,TN and otherr dates for the invoices that are downgraded.
      ---- Zipcash Invoices   
      
      UPDATE EDW_TRIPS.Fact_Invoice 
      SET firstnoticedate = DATE '1900-01-01', 
          secondnoticedate = DATE '1900-01-01', 
          thirdnoticedate = DATE '1900-01-01', 
          legalactionpendingdate = DATE '1900-01-01', 
          citationdate = DATE '1900-01-01' 
      WHERE Fact_Invoice.agestageid = 1
        AND Fact_Invoice.zipcashdate >= DATE '2019-01-01'
        AND Fact_Invoice.firstnoticedate <> DATE '1900-01-01';
        -- select * from dbo.fact_invoice_new
      
		  -- FirstNotice Invoices  
      
      UPDATE EDW_TRIPS.Fact_Invoice 
      SET secondnoticedate = DATE '1900-01-01', 
          thirdnoticedate = DATE '1900-01-01', 
          legalactionpendingdate = DATE '1900-01-01', 
          citationdate = DATE '1900-01-01' 
      WHERE Fact_Invoice.agestageid = 2
        AND Fact_Invoice.zipcashdate >= DATE '2019-01-01'
        AND Fact_Invoice.secondnoticedate <> DATE '1900-01-01';
       -- select * from dbo.fact_invoice_new
      
		  -- SecondNotice Invoices 
      
      UPDATE EDW_TRIPS.Fact_Invoice 
      SET thirdnoticedate = DATE '1900-01-01', 
          legalactionpendingdate = DATE '1900-01-01', 
          citationdate = DATE '1900-01-01' 
      WHERE Fact_Invoice.agestageid = 3
        AND Fact_Invoice.zipcashdate >= DATE '2019-01-01'
        AND Fact_Invoice.thirdnoticedate <> DATE '1900-01-01';
      
 		  -- ThirdNotice Invoices     
      
      UPDATE EDW_TRIPS.Fact_Invoice 
      SET legalactionpendingdate = DATE '1900-01-01', 
          citationdate = DATE '1900-01-01' 
      WHERE Fact_Invoice.agestageid = 4
        AND Fact_Invoice.zipcashdate >= DATE '2019-01-01'
        AND (Fact_Invoice.legalactionpendingdate <> DATE '1900-01-01'
        OR  Fact_Invoice.citationdate <> DATE '1900-01-01');
        -- select * from dbo.fact_invoice_new
      
		  -- LegalActionPending Invoices

      UPDATE EDW_TRIPS.Fact_Invoice 
      SET citationdate = DATE '1900-01-01' 
      WHERE Fact_Invoice.agestageid = 5
        AND Fact_Invoice.zipcashdate >= DATE '2019-01-01'
        AND Fact_Invoice.citationdate <> DATE '1900-01-01';
       -- select * from dbo.fact_invoice_new
      
		  --------- updating LAP dates for migrated ones using TER table.      
      
      UPDATE EDW_TRIPS.Fact_Invoice 
      SET legalactionpendingdate = 
          (
            SELECT
                cast(max(thirdnnpdate) as date) AS thirdnnpdate
              FROM
                LND_TBOS.TER_ViolatorCollectionsOutbound AS b
              WHERE CAST(b.invoicenumber AS INT64) = Fact_Invoice.invoicenumber 
          ) 
      WHERE Fact_Invoice.migratedflag = 1
        AND Fact_Invoice.firstnoticedate > Fact_Invoice.legalactionpendingdate
        AND Fact_Invoice.zipcashdate > DATE '1900-01-01'
        AND Fact_Invoice.agestageid = 5;

		  ---- Update paid txn counts for those invoices which are Vtolled & paid
        UPDATE EDW_TRIPS.Fact_Invoice SET paidtxncnt = Fact_Invoice.vtolltxncnt WHERE Fact_Invoice.edw_invoicestatusid = 99999
       AND Fact_Invoice.vtolltxncnt > 0
       AND Fact_Invoice.paidtxncnt = 0
       AND Fact_Invoice.tollspaid > 0
       AND Fact_Invoice.tollspaid = Fact_Invoice.adjustedexpectedtolls
       AND Fact_Invoice.outstandingamount = 0;
		  --- Updating Vtoll status to closed which are completely adjusted and assigned to some other Vtoll invoice
      UPDATE EDW_TRIPS.Fact_Invoice SET edw_invoicestatusid = 4434, vtolltxncnt = 0 WHERE Fact_Invoice.edw_invoicestatusid = 99999
       AND Fact_Invoice.vtolltxncnt > 0
       AND Fact_Invoice.paidtxncnt = 0
       AND Fact_Invoice.tolls > 0
       AND Fact_Invoice.tolls = Fact_Invoice.tollsadjusted;

       -------- Fix for PaiTxnts which are partial paid on excused txns. so when the math is done (paidtxncnt-PaidTxncntPrior) this showing up as -ve

      --UPDATE dbo.Fact_Invoice_New 
      --SET PaidTxncnt=PaidTxncntPriortoZC
      --WHERE PaidTxncnt<0

      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);

      IF trace_flag = 1 THEN
        SELECT log_source, log_start_date ; -- Replacement for fromlog
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_Invoice' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_Invoice
        ORDER BY
          2 DESC
        LIMIT 1000
        ;
      END IF; 
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = error_message;   -- Rethrow the error!
      END;
    END;
END;