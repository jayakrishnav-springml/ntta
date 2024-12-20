CREATE PROC [Ref].[RiteMigratedInvoice_Full_Load] AS
BEGIN 

/*
########################################################################################################################
Proc Description: 
------------------------------------------------------------------------------------------------------------------------
========================================================================================================================
Change Log:
------------------------------------------------------------------------------------------------------------------------
CHG0042443	Gouthami		2023-02-09	New!
									  1) This Ref table is created using Fact_Invoice_Analysis table from RITE Database.
									  2) Migrated data for Item 90 is brought from RITE inorder to get the appropriate 
										 data for current Item 90 report. As TRIPS did not migrate the data properly for
										 all the invoices, this approach has been used.
									  3) Some of the case statements in this stored procedure is used from old Item 90
										 report.
									  4) First temp table #ViolNoVBI is created for the invoices which does not have 
										 VI Invoice ID prior to 2012 invoices.
																			 
========================================================================================================================
------------------------------------------------------------------------------------------------------------------------
EXEC [Ref].[RiteMigratedInvoice_Full_Load] 
########################################################################################################################
*/


IF OBJECT_ID('tempdb.dbo.#ViolNoVBI','U') IS NOT NULL DROP TABLE #ViolNoVBI;
CREATE  TABLE  #ViolNoVBI 
WITH  (clustered columnstore index, distribution= hash(InvoiceNumber))
as
	SELECT  CASE
               WHEN InvAn.viol_invoice_id = -1 THEN
                   InvAn.vbi_invoice_id
               ELSE
                   InvAn.viol_invoice_id
           END AS InvoiceNumber,
           InvAn.VBI_INVOICE_ID,
			InvAn.VIOL_INVOICE_ID,
            CASE WHEN InvSta.INVOICE_STATUS_DESCR_SUM_GROUP='ReAsgn_UnAsgn' THEN 'DismissedUnassigned'
			     WHEN InvSta.INVOICE_STATUS_DESCR_SUM_GROUP='Paid-VToll' THEN 'DismissedVtolled'
				 WHEN InvAn.VIOL_INV_STATUS IN ('L','V') AND InvSta.INVOICE_STATUS_DESCR_SUM_GROUP IS NULL THEN 'DismissedUnassigned'
				 WHEN InvAn.VBI_STATUS IN ('L','V') AND InvSta.INVOICE_STATUS_DESCR_SUM_GROUP IS NULL THEN 'DismissedUnassigned'
			ELSE InvSta.INVOICE_STATUS_DESCR_SUM_GROUP
			END   AS InvoiceStatus,
             CASE InvAn.INVOICE_STAGE_ID
               WHEN 1 THEN
                   1 -- ZipCash
               WHEN 2 THEN
                   2 -- First Notice    
               WHEN 6 THEN
                   3 -- Second Notice
               WHEN 7 THEN
                   4 -- Third Notice
               WHEN 4 THEN
                   5 -- Legal Action Pending
               WHEN 3 THEN
                   6 -- Citation Issued
               ELSE
                   -1
           END AS AgeStageID,
           case when   (CASE   WHEN InvSta.INVOICE_STATUS_DESCR_SUM_GROUP='ReAsgn_UnAsgn' THEN 'DismissedUnassigned'
			                    WHEN InvSta.INVOICE_STATUS_DESCR_SUM_GROUP='Paid-VToll' THEN 'DismissedVtolled'
				                WHEN InvAn.VIOL_INV_STATUS IN ('L','V') AND InvSta.INVOICE_STATUS_DESCR_SUM_GROUP IS NULL THEN 'DismissedUnassigned'
				                WHEN InvAn.VBI_STATUS IN ('L','V') AND InvSta.INVOICE_STATUS_DESCR_SUM_GROUP IS NULL THEN 'DismissedUnassigned'
			                    ELSE InvSta.INVOICE_STATUS_DESCR_SUM_GROUP
			            END) = 'DismissedUnassigned' then  0 
                else isnull(AMT_PAID,0) 
            end as PaidAmount,
             ISNULL(InvAn.ZI_LATE_FEES, 0) + ISNULL(ADMIN_FEE, 0) FNFees,
              ISNULL(InvAn.VI_LATE_FEES, 0) + ISNULL(ADMIN_FEE2, 0) SNFees,                        -- Need to check.
           ISNULL(InvAn.ZI_LATE_FEES, 0) + ISNULL(ADMIN_FEE, 0) + ISNULL(InvAn.VI_LATE_FEES, 0) + ISNULL(ADMIN_FEE2, 0) FEESDUE,
           (TOLL_DUE + ZI_LATE_FEES + ADMIN_FEE + VI_LATE_FEES + ADMIN_FEE2) ExpectedAmount,

			ROW_NUMBER() OVER (PARTITION BY InvAn.VBI_INVOICE_ID ORDER BY InvAn.VIOL_INVOICE_ID DESC) RN -- SELECT *
    FROM EDW_RITE.dbo.Fact_Invoice_ANALYSIS InvAn
       JOIN EDW_RITE.dbo.DIM_INVOICE_STATUS InvSta
            ON (
                   InvAn.VBI_STATUS = InvSta.VBI_STATUS
                   AND InvAn.VIOL_INV_STATUS = InvSta.VIOL_INV_STATUS
                   AND InvAn.ZI_STAGE_ID = InvSta.ZI_STAGE_ID
               )
    WHERE  PARTITION_DATE = '2021-01-01'
	AND  VIOL_INVOICE_ID<>-1 AND VBI_INVOICE_ID=-1
	AND CONVERTED_DATE<='2012-01-01';   

	
CREATE STATISTICS  stats_ViolNoVBI_001 ON  #ViolNoVBI (InvoiceNumber);
CREATE STATISTICS  stats_ViolNoVBI_002 ON  #ViolNoVBI (VBI_INVOICE_ID);
CREATE  STATISTICS stats_ViolNoVBI_003 ON  #ViolNoVBI (Viol_INVOICE_ID);


IF OBJECT_ID('tempdb.dbo.#Viol','U') IS NOT NULL DROP TABLE #Viol;
CREATE  TABLE  #Viol
WITH  (CLUSTERED  COLUMNSTORE  INDEX , DISTRIBUTION = HASH (InvoiceNumber))
AS 
	SELECT *  FROM (
	SELECT  CASE
               WHEN InvAn.viol_invoice_id = -1 THEN
                   InvAn.vbi_invoice_id
               ELSE
                   InvAn.viol_invoice_id
           END AS InvoiceNumber,
           InvAn.VBI_INVOICE_ID,
			InvAn.VIOL_INVOICE_ID,
            CASE WHEN InvSta.INVOICE_STATUS_DESCR_SUM_GROUP='ReAsgn_UnAsgn' THEN 'DismissedUnassigned'
			     WHEN InvSta.INVOICE_STATUS_DESCR_SUM_GROUP='Paid-VToll' THEN 'DismissedVtolled'
				 WHEN InvAn.VIOL_INV_STATUS IN ('L','V') AND InvSta.INVOICE_STATUS_DESCR_SUM_GROUP IS NULL THEN 'DismissedUnassigned'
				 WHEN InvAn.VBI_STATUS IN ('L','V') AND InvSta.INVOICE_STATUS_DESCR_SUM_GROUP IS NULL THEN 'DismissedUnassigned'
			ELSE InvSta.INVOICE_STATUS_DESCR_SUM_GROUP
			END   AS InvoiceStatus,
             CASE InvAn.INVOICE_STAGE_ID
               WHEN 1 THEN
                   1 -- ZipCash
               WHEN 2 THEN
                   2 -- First Notice    
               WHEN 6 THEN
                   3 -- Second Notice
               WHEN 7 THEN
                   4 -- Third Notice
               WHEN 4 THEN
                   5 -- Legal Action Pending
               WHEN 3 THEN
                   6 -- Citation Issued
               ELSE
                   -1
           END AS AgeStageID,
           case when   (CASE   WHEN InvSta.INVOICE_STATUS_DESCR_SUM_GROUP='ReAsgn_UnAsgn' THEN 'DismissedUnassigned'
			                    WHEN InvSta.INVOICE_STATUS_DESCR_SUM_GROUP='Paid-VToll' THEN 'DismissedVtolled'
				                WHEN InvAn.VIOL_INV_STATUS IN ('L','V') AND InvSta.INVOICE_STATUS_DESCR_SUM_GROUP IS NULL THEN 'DismissedUnassigned'
				                WHEN InvAn.VBI_STATUS IN ('L','V') AND InvSta.INVOICE_STATUS_DESCR_SUM_GROUP IS NULL THEN 'DismissedUnassigned'
			                    ELSE InvSta.INVOICE_STATUS_DESCR_SUM_GROUP
			            END) = 'DismissedUnassigned' then  0 
                else isnull(AMT_PAID,0) 
            end as PaidAmount,
             ISNULL(InvAn.ZI_LATE_FEES, 0) + ISNULL(ADMIN_FEE, 0) FNFees,
              ISNULL(InvAn.VI_LATE_FEES, 0) + ISNULL(ADMIN_FEE2, 0) SNFees,                        -- Need to check.
           ISNULL(InvAn.ZI_LATE_FEES, 0) + ISNULL(ADMIN_FEE, 0) + ISNULL(InvAn.VI_LATE_FEES, 0) + ISNULL(ADMIN_FEE2, 0) FEESDUE,
           (TOLL_DUE + ZI_LATE_FEES + ADMIN_FEE + VI_LATE_FEES + ADMIN_FEE2) ExpectedAmount,

			ROW_NUMBER() OVER (PARTITION BY InvAn.VBI_INVOICE_ID ORDER BY InvAn.VIOL_INVOICE_ID DESC) RN -- SELECT *
    FROM EDW_RITE.dbo.Fact_Invoice_ANALYSIS InvAn
       JOIN EDW_RITE.dbo.DIM_INVOICE_STATUS InvSta
            ON (
                   InvAn.VBI_STATUS = InvSta.VBI_STATUS
                   AND InvAn.VIOL_INV_STATUS = InvSta.VIOL_INV_STATUS
                   AND InvAn.ZI_STAGE_ID = InvSta.ZI_STAGE_ID
               )
    WHERE  PARTITION_DATE = '2021-01-01' -- Use the latest Item-90 shapshot. 2021-01-01 is the partition_date for the last RITE item-90
    AND vbi_invoice_id != -1
	) A WHERE RN=1	
	UNION 
	SELECT * FROM tempdb.dbo.#ViolNoVBI;


CREATE STATISTICS   stats_Viol_001 ON  #Viol (InvoiceNumber);
CREATE STATISTICS   stats_Viol_002 ON  #Viol (VBI_INVOICE_ID);
CREATE  STATISTICS  stats_Viol_003 ON  #Viol (Viol_INVOICE_ID);
CREATE  STATISTICS  stats_Viol_004 ON  #Viol (InvoiceStatus);



IF OBJECT_ID('tempdb.dbo.#Dates','U') IS NOT NULL DROP TABLE #Dates;
CREATE  TABLE  #Dates
WITH  (CLUSTERED  COLUMNSTORE  INDEX , DISTRIBUTION = HASH (Viol_invoice_id))
AS 	
		SELECT CAV.VIOL_INVOICE_ID,
		       MAX(CA.MAIL_DATE) MAIL_DATE,
		       MAX(CA.COURT_DATE) AS COURT_DATE
		FROM LND_LG_VPS.VP_OWNER.COURT_ACT_VIOL CAV
		    JOIN LND_LG_VPS.VP_OWNER.COURT_ACTIONS CA
		        ON CA.COURT_ACTION_ID = CAV.COURT_ACTION_ID
		GROUP BY CAV.VIOL_INVOICE_ID;
    
CREATE  STATISTICS  stats_dates_001 on #Dates (viol_invoice_id);
        


IF OBJECT_ID('tempdb.dbo.#ThirdNoticeDate','U') IS NOT NULL DROP TABLE #ThirdNoticeDate;
CREATE  TABLE  #ThirdNoticeDate
WITH   (CLUSTERED  COLUMNSTORE  INDEX , DISTRIBUTION = HASH (Viol_invoice_id))
AS 	
SELECT CAI.VIOL_INVOICE_ID,
		       MIN(CA.FILE_GEN_DATE) AS ThirdNoticeDate
		FROM LND_LG_VPS.VP_OWNER.CA_ACCT_INV_XREF CAI
		    JOIN LND_LG_VPS.VP_OWNER.CA_ACCTS CA
		        ON CA.CA_ACCT_ID = CAI.CA_ACCT_ID
   --where    viol_invoice_id = 810368980
		GROUP BY CAI.VIOL_INVOICE_ID;
CREATE  STATISTICS  stats_ThirdNoticeDate_001 ON  #ThirdNoticeDate (viol_invoice_id);

IF OBJECT_ID('tempdb.dbo.#LegalActionPendingDate','U') IS NOT NULL DROP TABLE #LegalActionPendingDate;
CREATE  TABLE  #LegalActionPendingDate 
WITH  (CLUSTERED  COLUMNSTORE  INDEX , DISTRIBUTION = HASH (VIOL_INVOICE_ID))
AS 
SELECT VIOL_INVOICE_ID,STATUS_DATE,VIOL_INV_STATUS
FROM EDW_RITE.dbo.VIOL_INVOICES
WHERE VIOL_INV_STATUS='D';

CREATE  STATISTICS  stats_LegalActionPendingDate003 ON  #LegalActionPendingDate (Viol_INVOICE_ID);
CREATE  STATISTICS  stats_LegalActionPendingDate_004 ON  #LegalActionPendingDate (STATUS_DATE);



IF OBJECT_ID('Ref.RiteMigratedInvoice') IS NOT NULL DROP TABLE Ref.RiteMigratedInvoice;
CREATE TABLE Ref.RiteMigratedInvoice WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber)) --98687304
AS 
--declare @InvoiceNumber int = 747739677 --506591578
with aaa
as (
SELECT      Viol.InvoiceNumber,
           NULL FirstInvoiceID,
           NULL CurrentInvoiceID,
           ISNULL(InvAn.VIOLATOR_ID,-1) CustomerID,
		   CASE WHEN Viol.AgeStageID=4 AND VI.VIOL_INV_STATUS ='D' THEN 5 ELSE  Viol.AgeStageID END AS  AgeStageID,
		   NULL CollectionStatusID,                                                          -- not availabnle in fact_analysis,
           NULL CurrMBSID, 
           ISNULL(IH.VehicleID,-1) VehicleID, 
           Viol8.LIC_PLATE_NBR LIC_PLATE_NBR,
           Viol8.LIC_PLATE_STATE LIC_PLATE_STATE,
           1 MigratedFlag,
           Viol.InvoiceStatus,
           InvS.InvoiceStatusID AS EDW_InvoiceStatusID,
          --- Dates
		   InvAn.VB_INV_DATE ZipCashDate,
          CASE
               WHEN InvAn.INVOICE_STAGE_ID IN ( 2, 6, 7, 4, 3 ) THEN
                   DATEADD(MONTH, 1, InvAn.VB_INV_DATE)		   
           END FirstNoticeDate,                                                              -- get from rite landing tables. cannot find out from fact_Unified_violation_invoice, RiteMigratedInvoice_analysis,
           CASE
               WHEN InvAn.INVOICE_STAGE_ID IN ( 6, 7, 4, 3 ) THEN
                   InvAn.VB_INV_DATE_MODIFIED
           END vb_inv_date_modified_SecondNoticeDate,
           CASE
               WHEN InvAn.INVOICE_STAGE_ID IN ( 6, 7, 4, 3 ) THEN
                   InvAn.CONVERTED_DATE
           END SecondNoticeDate,
           ThirdNoticeDate.ThirdNoticeDate ThirdNoticeDate,                                                              -- get from rite landing tables. cannot find out from fact_Unified_violation_invoice, RiteMigratedInvoice_analysis,
           Dates.MAIL_DATE CitationDate,
            -- Dates.COURT_DATE LegalActionPendingDate,
            CASE
               WHEN Viol.AgeStageID=4 AND VI.VIOL_INV_STATUS ='D' THEN VI.STATUS_DATE
               WHEN InvAn.INVOICE_STAGE_ID IN ( 4 ) THEN
               dateadd(year,2,ThirdNoticeDate)  -- After discussion with Pat on 12/15/2022, decided to add 2 years from the time time
                                                                     -- invoice was sent to collections(i.e.ThirdNoticeDate) 
           
           END as LegalActionPendingDate,
	   CASE
               WHEN Viol.viol_invoice_id = -1 THEN
                   InvAn.VB_INV_DUE_DATE
               ELSE
                   InvAn.VIOL_INV_DUE_DATE
           END DueDate,                                                               -- use voil_invoice_due_date if the invoice is in the 2nnd stage
                                                                                             -- vb_inv_date CurrMBSgeneratedDate, -- This logic needs to be tested.  use vb_inv_date for ZC/FN invoice & converted_date for SN
		  '1900-01-01' CurrMBSGeneratedDate,
           CASE
			   WHEN (InvAn.VBI_STATUS='E' OR InvAn.VIOL_INV_STATUS='E') AND InvAn.AMT_PAID=0 THEN '1900-01-01'
			   WHEN (InvAn.VBI_STATUS='L' OR  InvAn.VIOL_INV_STATUS='L') AND InvAn.AMT_PAID=0 THEN '1900-01-01'
               WHEN InvAn.VIOL_INV_STATUS IN ( 'TS', 'K', 'F' )
                    AND InvAn.VIOL_INV_DATE_EXCUSED > '1900-01-01'
                    AND InvAn.FIRST_PAID_DATE = '1900-01-01'
                    AND InvAn.VIOL_INV_DATE_MODIFIED > '1900-01-01' THEN
                   InvAn.VIOL_INV_DATE_EXCUSED
               WHEN InvAn.VIOL_INV_STATUS IN ( 'TS', 'K', 'F' )
                    AND InvAn.VIOL_INV_DATE_EXCUSED = '1900-01-01'
                    AND InvAn.FIRST_PAID_DATE = '1900-01-01'
                    AND InvAn.VIOL_INV_DATE_MODIFIED > '1900-01-01' THEN
                   InvAn.VIOL_INV_DATE_MODIFIED
			   WHEN InvAn.VBI_STATUS='TS' 
					THEN InvAn.VB_INV_DATE_EXCUSED 
			   WHEN InvAn.VIOL_INV_STATUS='TS'
					THEN InvAn.VIOL_INV_DATE_EXCUSED
               ELSE
                   InvAn.FIRST_PAID_DATE
           END FirstpaymentDate,
           CASE
			   WHEN (InvAn.VBI_STATUS='E' OR  InvAn.VIOL_INV_STATUS='E') AND InvAn.AMT_PAID=0 THEN '1900-01-01'
			    WHEN (InvAn.VBI_STATUS='L' OR  InvAn.VIOL_INV_STATUS='L') AND InvAn.AMT_PAID=0 THEN '1900-01-01'
               WHEN InvAn.VIOL_INV_STATUS IN ( 'TS', 'K', 'F' )
                    AND InvAn.VIOL_INV_DATE_EXCUSED > '1900-01-01'
                    AND InvAn.LAST_PAID_DATE = '1900-01-01'
                    AND InvAn.VIOL_INV_DATE_MODIFIED > '1900-01-01' THEN
                   InvAn.VIOL_INV_DATE_EXCUSED
               WHEN InvAn.VIOL_INV_STATUS IN ( 'TS', 'K', 'F' )
                    AND InvAn.VIOL_INV_DATE_EXCUSED = '1900-01-01'
                    AND InvAn.LAST_PAID_DATE = '1900-01-01'
                    AND InvAn.VIOL_INV_DATE_MODIFIED > '1900-01-01' THEN
                   InvAn.VIOL_INV_DATE_MODIFIED
               WHEN InvAn.VBI_STATUS IN ( 'TS', 'K', 'F' )
                    AND InvAn.VB_INV_DATE_EXCUSED > '1900-01-01'
                    AND InvAn.LAST_PAID_DATE = '1900-01-01'
                    AND InvAn.VB_INV_DATE_MODIFIED > '1900-01-01' THEN
                   InvAn.VB_INV_DATE_EXCUSED
               WHEN InvAn.VBI_STATUS IN ( 'TS', 'K', 'F' )
                    AND InvAn.VB_INV_DATE_EXCUSED = '1900-01-01'
                    AND InvAn.LAST_PAID_DATE = '1900-01-01'
                    AND InvAn.VB_INV_DATE_MODIFIED > '1900-01-01' THEN
                   InvAn.VB_INV_DATE_MODIFIED
			   WHEN InvAn.VBI_STATUS='TS' 
					THEN InvAn.VB_INV_DATE_EXCUSED 
			   WHEN InvAn.VIOL_INV_STATUS='TS'
					THEN InvAn.VIOL_INV_DATE_EXCUSED
               ELSE
                   InvAn.LAST_PAID_DATE
           END LastPaymentDate,


                                                                                             -- first_paid_date FirstPaidDate,
                                                                                             -- last_paid_date LastPaidDate,
                                                                                             ---- -- Get the status from Dim_invoice_status after joining with RiteMigratedInvoice_analysis. Use MSTR item-90 join 

           INVOICE_AMT InvoiceAmount,                                                        -- 100% correct
           NULL PBMTollAmount,                                                              -- ?
           NULL AVITollAmount,                                                               --?
           NULL PremiumAmount,                                                               --?
           VIOL_COUNT TxnCnt,                                                                -- 100% correct
           TOLL_DUE Tolls,                                                                   -- 100% correct
                                                                                             --zi_late_fees,
                                                                                             --vi_late_fees,
                                                                                             --admin_fee, -- Need to check.
                                                                                             --admin_fee2 , -- Need to check.
                                                                                             --vbi_status,

           Viol.FNFees,    
           Viol.SNFees,    
           Viol.FEESDUE FeesDue,  -- Modified By Shekhar on 12/6 as this calculation is easier than the below
           Viol.ExpectedAmount, -- -- 100% correct add the above 3 columns
                                                                                              --999 TollsAdjusted, -- perform calclculations based on invoice_amt_disc
           CASE
               WHEN  Viol.ExpectedAmount  - Viol.PaidAmount  = 0 THEN  -- i.e. if AdjustedAmount - PaidAmount = 0
                   0
               ELSE
                   CASE
                       WHEN  isnull(TOLL_DUE + ZI_LATE_FEES + ADMIN_FEE + VI_LATE_FEES + ADMIN_FEE2,0)  - Viol.PaidAmount
                            - (ISNULL(InvAn.VI_LATE_FEES, 0) + ISNULL(ADMIN_FEE2, 0) + ISNULL(InvAn.ZI_LATE_FEES, 0)
                               + ISNULL(ADMIN_FEE, 0)
                              ) < 0 THEN
                           0
                       ELSE
                            isnull(TOLL_DUE + ZI_LATE_FEES + ADMIN_FEE + VI_LATE_FEES + ADMIN_FEE2,0)  - Viol.PaidAmount
                           - (ISNULL(InvAn.VI_LATE_FEES, 0) + ISNULL(ADMIN_FEE2, 0) + ISNULL(InvAn.ZI_LATE_FEES, 0)
                              + ISNULL(ADMIN_FEE, 0)
                             )
                   END

           END AS TollsAdjusted,
            CASE
               WHEN Viol.PaidAmount > Viol.ExpectedAmount THEN  0
               WHEN Viol.ExpectedAmount  - Viol.PaidAmount  =   0         THEN    0
               WHEN Viol.ExpectedAmount  - Viol.PaidAmount  <   SNFees    THEN    0
               WHEN Viol.ExpectedAmount  - Viol.PaidAmount  >=  FeesDue  THEN    FNFees
               WHEN Viol.ExpectedAmount - Viol.PaidAmount   <   FeesDue   THEN    Viol.ExpectedAmount  - Viol.PaidAmount  - SNFees
               ELSE  99999
           END AS FNFeesAdjusted,

 
           CASE
               WHEN Viol.PaidAmount > Viol.ExpectedAmount THEN  0
               WHEN Viol.ExpectedAmount  - Viol.PaidAmount  = 0         THEN    0
               WHEN Viol.ExpectedAmount  - Viol.PaidAmount  >= SNFees   THEN    SNFees
               WHEN Viol.ExpectedAmount  - Viol.PaidAmount  < SNFees    THEN    Viol.ExpectedAmount  - Viol.PaidAmount 
               ELSE 99999 
           END AS SNFeesAdjusted,

           case WHEN Viol.PaidAmount > Viol.ExpectedAmount THEN  0
                else Viol.ExpectedAmount  - Viol.PaidAmount  
           end as AdjustedAmount,  -- Changed By Shekhar on 12/6/2022






           CASE
               WHEN Viol.PaidAmount = 0 THEN
                   0
               WHEN Viol.PaidAmount >= ISNULL(TOLL_DUE, 0) THEN
                   ISNULL(TOLL_DUE, 0)
               ELSE
                   Viol.PaidAmount
           END AS TollsPaid,                                                                
           CASE
               WHEN Viol.PaidAmount = 0 THEN
                   0
               WHEN (Viol.PaidAmount > ISNULL(TOLL_DUE, 0))
                    AND (Viol.PaidAmount <= (ISNULL(TOLL_DUE, 0) + ISNULL(InvAn.ZI_LATE_FEES, 0)
                                                 + ISNULL(ADMIN_FEE, 0)
                                                )
                        ) THEN
                   Viol.PaidAmount - ISNULL(TOLL_DUE, 0)
               WHEN Viol.PaidAmount >= (ISNULL(TOLL_DUE, 0) + ISNULL(InvAn.ZI_LATE_FEES, 0) + ISNULL(ADMIN_FEE, 0)) THEN
                   ISNULL(InvAn.ZI_LATE_FEES, 0) + ISNULL(ADMIN_FEE, 0)
               ELSE
                   0
           END FNFeesPaid,                                                                   -- fact_UVI.Fees_Paid as , -- split calculation needed
        
           
           
             CASE
               WHEN Viol.PaidAmount = 0 THEN
                   0
               WHEN Viol.PaidAmount >= ISNULL(TOLL_DUE, 0) + ISNULL(InvAn.ZI_LATE_FEES, 0) + ISNULL(ADMIN_FEE, 0)
                    AND Viol.PaidAmount < ISNULL(TOLL_DUE, 0) + ISNULL(InvAn.ZI_LATE_FEES, 0) + ISNULL(ADMIN_FEE, 0)
                                              + ISNULL(InvAn.VI_LATE_FEES, 0) + ISNULL(ADMIN_FEE2, 0) THEN
                   Viol.PaidAmount - ISNULL(TOLL_DUE, 0) - (ISNULL(InvAn.VI_LATE_FEES, 0) + ISNULL(ADMIN_FEE, 0))
               WHEN Viol.PaidAmount >= (ISNULL(TOLL_DUE, 0) + ISNULL(InvAn.ZI_LATE_FEES, 0) + ISNULL(ADMIN_FEE, 0)
                                            + ISNULL(InvAn.VI_LATE_FEES, 0) + ISNULL(ADMIN_FEE2, 0)
                                           ) THEN
                   ISNULL(InvAn.VI_LATE_FEES, 0) + ISNULL(ADMIN_FEE2, 0)
               ELSE
                   0
           END SNFeesPaid,   -- Fixed By Shekhar on 12/6/2022
           -- fact_UVI.Fees_Paid as , -- split calculation needed
           Viol.PaidAmount,                                                              -- Calculated by adding the above 3 columns.
           InvAn.LAST_CA_COMPANY_ID LastCACompanyID
		
        FROM #Viol Viol

        JOIN EDW_RITE.dbo.Fact_invoice_ANALYSIS InvAn 
            ON Viol.vbi_invoice_id = InvAn.VBI_INVOICE_ID
            AND Viol.viol_invoice_id = InvAn.VIOL_INVOICE_ID
	    JOIN EDW_RITE.dbo.DIM_INVOICE_STATUS InvSta
            ON (
                   InvAn.VBI_STATUS = InvSta.VBI_STATUS
                   AND InvAn.VIOL_INV_STATUS = InvSta.VIOL_INV_STATUS
                   AND InvAn.ZI_STAGE_ID = InvSta.ZI_STAGE_ID
               )
        LEFT JOIN #Dates Dates
            ON Dates.VIOL_INVOICE_ID = Viol.viol_invoice_id
		LEFT JOIN #ThirdNoticeDate ThirdNoticeDate
			ON ThirdNoticeDate.VIOL_INVOICE_ID = Viol.viol_invoice_id
        JOIN EDW_RITE.dbo.DIM_VIOLATOR_ASOF Viol8
            ON (
                   InvAn.PARTITION_DATE = Viol8.PARTITION_DATE
                   AND InvAn.VIOLATOR_ID = Viol8.VIOLATOR_ID
               )
        JOIN EDW_RITE.dbo.CA_COMPANIES Viol10
            ON (InvAn.FIRST_CA_COMPANY_ID = Viol10.CA_COMPANY_ID)
        JOIN EDW_RITE.dbo.CA_COMPANIES Viol11
            ON (InvAn.LAST_CA_COMPANY_ID = Viol11.CA_COMPANY_ID)
        JOIN EDW_RITE.dbo.CA_INV_STATUS Viol12
            ON (InvAn.CA_INV_STATUS = Viol12.CA_INV_STATUS)
        LEFT JOIN LND_TBOS.TollPlus.Invoice_Header IH 
            ON Viol.InvoiceNumber=IH.InvoiceNumber AND IH.InvoiceStatus<>'Transferred'
        LEFT JOIN edw_trips.dbo.Dim_InvoiceStatus InvS 
            ON InvS.InvoiceStatusDesc=Viol.InvoiceStatus
        LEFT JOIN dbo.#LegalActionPendingDate VI  
            ON Viol.viol_invoice_id = VI.VIOL_INVOICE_ID

   WHERE InvAn.PARTITION_DATE = '2021-01-01'
  
  )
  SELECT  aaa.InvoiceNumber,
          aaa.FirstInvoiceID,
          aaa.CurrentInvoiceID,
          aaa.CustomerID,
          aaa.AgeStageID,
          aaa.CollectionStatusID,
          aaa.CurrMBSID,
          aaa.VehicleID,
          aaa.LIC_PLATE_NBR,
          aaa.LIC_PLATE_STATE,
          aaa.MigratedFlag,
          aaa.InvoiceStatus,
          aaa.EDW_InvoiceStatusID,
          aaa.ZipCashDate,
          aaa.FirstNoticeDate,
          aaa.vb_inv_date_modified_SecondNoticeDate,
          aaa.SecondNoticeDate,
          aaa.ThirdNoticeDate,
          aaa.CitationDate,
          aaa.LegalActionPendingDate,
          aaa.DueDate,
          aaa.CurrMBSGeneratedDate,
          CASE WHEN aaa.FirstpaymentDate='1900-01-01' THEN NULL ELSE aaa.FirstpaymentDate END AS FirstpaymentDate,
          CASE WHEN aaa.LastPaymentDate='1900-01-01' THEN NULL ELSE aaa.LastPaymentDate END AS LastPaymentDate,
          aaa.InvoiceAmount,
          aaa.PBMTollAmount,
          aaa.AVITollAmount,
          aaa.PremiumAmount,
          aaa.TxnCnt,
          aaa.Tolls,
          aaa.FNFees,
          aaa.SNFees,
          aaa.FeesDue,
          aaa.ExpectedAmount,
          aaa.TollsAdjusted,
          aaa.FNFeesAdjusted,
          aaa.SNFeesAdjusted,
          aaa.AdjustedAmount,
          aaa.TollsPaid,
          aaa.FNFeesPaid,
          aaa.SNFeesPaid,
          aaa.PaidAmount,
          aaa.LastCACompanyID,
       (Tolls-TollsAdjusted) AS AdjustedExpectedTolls,
       (FNFees-FNFeesAdjusted) AS AdjustedExpectedFNFees,
       (SNFees-SNFeesAdjusted) AS AdjustedExpectedSNFees,
       (ExpectedAmount-AdjustedAmount) AS AdjustedExpectedAmount,
       ((Tolls-TollsAdjusted) - Tollspaid) AS  TollOutStandingAmount,
       ((FNFees-FNFeesAdjusted) - FNFeesPaid) AS FNFeesOutStandingAmount,
       ((SNFees-SNFeesAdjusted) - SNFeesPAid) AS SNFeesOutStandingAmount,
       case when PaidAmount > ExpectedAmount then 0 else ((ExpectedAmount-AdjustedAmount) - PaidAmount) end OutstandingAmount
FROM    aaa;

		CREATE STATISTICS STATS_RiteMigratedInvoice_000 ON Ref.RiteMigratedInvoice (InvoiceNumber);
		CREATE STATISTICS STATS_RiteMigratedInvoice_001 ON Ref.RiteMigratedInvoice (EDW_InvoiceStatusID);
		CREATE STATISTICS STATS_RiteMigratedInvoice_002 ON Ref.RiteMigratedInvoice (AgeStageID);
		CREATE STATISTICS STATS_RiteMigratedInvoice_003 ON Ref.RiteMigratedInvoice  (ZipCashDate);
		CREATE STATISTICS STATS_RiteMigratedInvoice_004 ON Ref.RiteMigratedInvoice (FirstNoticeDate);
		CREATE STATISTICS STATS_RiteMigratedInvoice_006 ON Ref.RiteMigratedInvoice  (SecondNoticeDate);
END; 


