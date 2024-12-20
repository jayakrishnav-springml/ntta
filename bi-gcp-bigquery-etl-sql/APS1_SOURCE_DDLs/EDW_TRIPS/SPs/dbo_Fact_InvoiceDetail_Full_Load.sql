CREATE PROC [dbo].[Fact_InvoiceDetail_Full_Load] AS

/*
IF OBJECT_ID ('dbo.Fact_InvoiceDetail_Full_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_InvoiceDetail_Full_Load
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_InvoiceDetail table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838 	Bhanu/Gouthami	2020-01-04	New!
CHG0038039  Gouthami	    2021-01-27  Added Delete Flag
CHG0038304	Gouthami		2021-02-24	Changed the join condition on TransactionPostingType table to 
										ISNULL(TPV.TransactionPostingType,'Unknown') as it was eliminating the 
										TransactionPostingType = NULL records.
CHG0039112 	Gouthami 		2021-06-16  Modified the source column for Txndate from Invoice LineItems table
										to TP_Violatedtrips
CHG0039382 	Gouthami 		2021-07-26  Modified the ORDER BY clause from AgestageID column to Invoicedate for the 
										downgrading invoices.


===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_InvoiceDetail_Full_Load

EXEC Utility.FromLog 'dbo.Fact_InvoiceDetail', 1
SELECT TOP 100 'dbo.Fact_InvoiceDetail' Table_Name, * FROM dbo.Fact_InvoiceDetail ORDER BY 2
###################################################################################################################
*/



BEGIN
	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_InvoiceDetail_Full_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME();
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0; -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL;
		
		--=============================================================================================================
		-- Load dbo.Fact_InvoiceDetail
		--=============================================================================================================
		IF OBJECT_ID('dbo.Fact_InvoiceDetail_NEW') IS NOT NULL DROP TABLE dbo.Fact_InvoiceDetail_NEW;
		CREATE TABLE dbo.Fact_InvoiceDetail_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber),  PARTITION (TxnDate RANGE RIGHT FOR VALUES ('2011-01-01', '2012-01-01', '2013-01-01', '2014-01-01', '2015-01-01', '2015-02-01', '2015-03-01', '2015-04-01', '2015-05-01', '2015-06-01', '2015-07-01', '2015-08-01', '2015-09-01', '2015-10-01', '2015-11-01', '2015-12-01', '2016-01-01', '2016-02-01', '2016-03-01', '2016-04-01', '2016-05-01', '2016-06-01', '2016-07-01', '2016-08-01', '2016-09-01', '2016-10-01', '2016-11-01', '2016-12-01', '2017-01-01', '2017-02-01', '2017-03-01', '2017-04-01', '2017-05-01', '2017-06-01', '2017-07-01', '2017-08-01', '2017-09-01', '2017-10-01', '2017-11-01', '2017-12-01', '2018-01-01', '2018-02-01', '2018-03-01', '2018-04-01', '2018-05-01', '2018-06-01', '2018-07-01', '2018-08-01', '2018-09-01', '2018-10-01', '2018-11-01', '2018-12-01', '2019-01-01', '2019-02-01', '2019-03-01', '2019-04-01', '2019-05-01', '2019-06-01', '2019-07-01', '2019-08-01', '2019-09-01', '2019-10-01', '2019-11-01', '2019-12-01', '2020-01-01', '2020-02-01', '2020-03-01', '2020-04-01', '2020-05-01', '2020-06-01', '2020-07-01', '2020-08-01', '2020-09-01', '2020-10-01', '2020-11-01')))
		AS
		SELECT CAST(IH.InvoiceNumber AS BIGINT) AS InvoiceNumber,
		       ILT.LinkID CitationID,
		       ISNULL(TPV.TPTripID,-1) TPTripID,
		       IH.CustomerID,
		       TPV.ExitLaneID LaneID,
			   IH.AgeStageID,
			   CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN TPV.PaymentStatusID ELSE -1 END PaymentStatusID,
		       TPV.TripStageID,
		       TPV.TripStatusID,
		       TPV.TransactionTypeID,
			   PT.TransactionPostingTypeID,
			   CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 AND IH.InvoiceDate=MAX(IH.InvoiceDate) THEN InvSt.InvoiceStatusID ELSE -1 END AS InvoiceStatusID,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN 1 ELSE 0 END CurrentInvFlag,
			   TPV.IsWriteOff WriteOffFlag,
			   -1 HVFlag, --Null because on TBOS side TER was not ready . Need to work
		       -1 PPFLAG,  --Null because on TBOS side TER was not ready . Need to work
			   -1 InvoicedBadAddr,
		       CAST(CONVERT(VARCHAR, TPV.ExitTripDateTime, 112) AS DATE) AS TxnDate,
		       CAST(CONVERT(VARCHAR, TPV.PostedDate, 112) AS DATE) AS PostedDate,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN CAST(ILT.CreatedDate AS DATE) ELSE '1900-01-01' END ZCInvoiceDate,
		       CASE WHEN CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN 1 ELSE 0 END = 1 THEN FNFeesDate ELSE CAST ('1900-01-01' AS DATE) END FNFeesDate,
		       CASE WHEN CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN 1 ELSE 0 END = 1 THEN SNFeesDate ELSE CAST ('1900-01-01' AS DATE) END SNFeesDate,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN CAST( TPV.WriteOffDate AS DATE) ELSE '1900-01-01' END WriteOffDate,
			   ILT.TxnType, 
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN TPV.OutstandingAmount ELSE 0 END OutstandingAmount,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN TPV.PBMTollAmount ELSE 0 END PBMTollAmount,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN TPV.AVITollAmount ELSE 0 END AVITollAmount,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN ILT.Amount ELSE 0 END Tolls,
		       CASE CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN TPV.PaymentStatusID ELSE -1 END
		                  WHEN 456 THEN
		                      TPV.TollAmount
		                  WHEN 457 THEN
		                      TPV.TollAmount - TPV.OutstandingAmount
		                  ELSE
		                      0
		              END TollsPaid,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN MAX(ISNULL(ILTXN.Adminfee1,0))/NULLIF(MAX(ILTXN.TxnCnt),0) ELSE 0 END FNFees,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN MAX(ISNULL(ILTXN.Adminfee2,0))/NULLIF(MAX(ILTXN.TxnCnt),0) ELSE 0 END SNFees,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN MAX(ISNULL(ILTXN.PaIDAdminfee1,0))/NULLIF(MAX(ILTXN.TxnCnt),0) ELSE 0 END FNFeesPaid,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN MAX(ISNULL(ILTXN.PaIDAdminfee2,0))/NULLIF(MAX(ILTXN.TxnCnt),0) ELSE 0 END SNFeesPaid,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN MAX(ISNULL(ILTXN.FNFeesOutstandingAmount,0))/NULLIF(MAX(ILTXN.TxnCnt),0) ELSE 0 END FNFeesOutstandingAmount,
		       CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN MAX(ISNULL(ILTXN.SNFeesOutstandingAmount,0))/NULLIF(MAX(ILTXN.TxnCnt),0) ELSE 0 END SNFeesOutstandingAmount,
			   CASE WHEN ROW_NUMBER() OVER (PARTITION BY ILT.LinkID ORDER BY CAST(IH.InvoiceNumber AS BIGINT) DESC, IH.InvoiceDate DESC) = 1 THEN TPV.WriteOffAmount ELSE 0 END WriteOffAmount,
			   CAST(CASE WHEN IH.LND_UpdateType = 'D' OR ILT.LND_UpdateType = 'D' OR TPV.LND_UpdateType = 'D' OR TPCT.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT) DeleteFlag,
			   ISNULL(CAST(SYSDATETIME() AS DATETIME2(3)), '1900-01-01') AS EDW_UpdateDate			   
			 
		FROM LND_TBOS.TollPlus.Invoice_Header IH
		    JOIN LND_TBOS.TollPlus.Invoice_LineItems ILT
		        ON IH.InvoiceNumber = ILT.ReferenceInvoiceID
		           AND LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                   AND ILT.LinkID>0
				   AND ILT.LND_UpdateType<>'D'
		    JOIN LND_TBOS.TollPlus.TP_ViolatedTrips TPV
		        ON ILT.LinkID = TPV.CitationID 
				AND TPV.LND_UpdateType<>'D'
			JOIN dbo.Dim_TransactionPostingType PT ON PT.TransactionPostingType = ISNULL(TPV.TransactionPostingType,'Unknown') 
		    JOIN
		    (
		SELECT InvCurrTxn.InvoiceNumber,
		       SUM(   CASE
		                  WHEN InvCurrTxn.TxnFlag = 1 THEN
		                      1
		                  ELSE
		                      0
		              END
		          ) TxnCnt,
		       (Adminfee1) Adminfee1,
		       (Adminfee2) Adminfee2,
		       (ICT.PaidAdminfee1) PaidAdminfee1,
		       (ICT.PaidAdminfee2) PaidAdminfee2,
		   	    ICT.FNFeesDate,
				ICT.SNFeesDate,
				ICT.FNFeesOutstandingAmount,
				ICT.SNFeesOutstandingAmount
		FROM
		(

		    SELECT Invoice_Header.InvoiceNumber,
		           ROW_NUMBER() OVER (PARTITION BY Invoice_LineItems.LinkID
		                              ORDER BY CAST(Invoice_Header.InvoiceNumber AS BIGINT) DESC,
		                                       Invoice_Header.AgeStageID DESC
		                             ) TxnFlag
		    FROM LND_TBOS.TollPlus.Invoice_LineItems
		        JOIN LND_TBOS.TollPlus.Invoice_Header
		            ON InvoiceNumber = ReferenceInvoiceID
		               AND LinkSourceName IN ( 'TOLLPLUS.TP_VIOLATEDTRIPS' )
		               AND Invoice_Header.InvoiceID = Invoice_LineItems.InvoiceID
					   AND LinkID>0
		    WHERE  Invoice_LineItems.LND_UpdateType<>'D'
			   AND Invoice_Header.LND_UpdateType<>'D'
		) InvCurrTxn
		    LEFT JOIN
		    (
		        SELECT InvoiceNumber,
		               SUM(   CASE
		                          WHEN FeeCode = 'FSTNTVFEE' THEN
		                              Amount
		                          ELSE
		                              0
		                      END
		                  ) Adminfee1,
		               SUM(   CASE
		                          WHEN FeeCode = 'SECNTVFEE' THEN
		                              Amount
		                          ELSE
		                              0
		                      END
		                  ) Adminfee2,
		               SUM(   CASE
		                          WHEN FeeCode = 'FSTNTVFEE'
		                               AND PaymentStatusID = 456 THEN
		                              Amount
		                          WHEN FeeCode = 'FSTNTVFEE'
		                               AND PaymentStatusID = 457 THEN
		                              Amount - OutstandingAmount
		                          ELSE
		                              0
		                      END
		                  ) PaidAdminfee1,
		               SUM(   CASE
		                          WHEN FeeCode = 'SECNTVFEE'
		                               AND PaymentStatusID = 456 THEN
		                              Amount
		                          WHEN FeeCode = 'SECNTVFEE'
		                               AND PaymentStatusID = 457 THEN
		                              Amount - OutstandingAmount
		                          ELSE
		                              0
		                      END
		                  ) PaidAdminfee2, 
					    MAX(   CASE
		                          WHEN FeeCode = 'FSTNTVFEE' THEN
		                              CAST(Invoice_Charges_Tracker.CreatedDate AS DATE)
		                          ELSE
		                              CAST('1900-01-01'  AS DATE)
		                      END
		                  ) FNFeesDate,
						MAX(   CASE
		                          WHEN FeeCode = 'SECNTVFEE' THEN
		                              CAST(Invoice_Charges_Tracker.CreatedDate AS DATE)
		                          ELSE
		                               CAST('1900-01-01'  AS DATE) 
		                      END
		                  ) SNFeesDate ,
						SUM(   CASE
		                          WHEN FeeCode = 'FSTNTVFEE' THEN
		                              OutstandingAmount
		                          ELSE
		                              0
		                      END
		                  ) FNFeesOutstandingAmount,
						SUM(   CASE
		                          WHEN FeeCode = 'SECNTVFEE' THEN
		                              OutstandingAmount
		                          ELSE
		                              0
		                      END
		                  ) SNFeesOutstandingAmount
		        FROM LND_TBOS.TollPlus.Invoice_Charges_Tracker
		            JOIN LND_TBOS.TollPlus.Invoice_Header
		                ON Invoice_Header.InvoiceID = Invoice_Charges_Tracker.InvoiceID
			    WHERE Invoice_Charges_Tracker.LND_UpdateType<>'D'
				AND Invoice_Header.LND_UpdateType<>'D'
		        GROUP BY InvoiceNumber
		    ) ICT
		        ON ICT.InvoiceNumber = InvCurrTxn.InvoiceNumber
		GROUP BY (Adminfee1),
		         (Adminfee2),
		         (ICT.PaidAdminfee1),
		         (ICT.PaidAdminfee2),
		         InvCurrTxn.InvoiceNumber,
				 ICT.FNFeesDate,
				 ICT.SNFeesDate,
				 ICT.FNFeesOutstandingAmount,
				 ICT.SNFeesOutstandingAmount
				 
		    ) ILTXN
		        ON ILTXN.InvoiceNumber = IH.InvoiceNumber				
		LEFT JOIN LND_TBOS.TollPlus.TP_Violated_Trip_Charges_Tracker TPCT ON TPCT.CitationID = TPV.CitationID AND TPCT.LND_UpdateType<>'D'
		LEFT JOIN  dbo.Dim_InvoiceStatus InvSt ON InvSt.InvoiceStatuscode=IH.InvoiceStatus
		GROUP BY CAST(IH.InvoiceNumber AS BIGINT),
		         ISNULL(TPV.TPTripID, -1),
		         CAST(CONVERT(VARCHAR, ILT.TxnDate, 112) AS DATE),
		         IH.AgeStageID,
		         CAST(ILT.CreatedDate AS DATE),
		         ILT.LinkID,
		         TPV.ExitLaneID,
		         IH.CustomerID,
				 PT.TransactionPostingTypeID,
				 TPV.IsWriteOff,
		         ILT.TxnType,
				 TPV.ExitTripDateTime,
		         FNFeesDate,
		         SNFeesDate,
		         TPV.OutstandingAmount,
		         TPV.PBMTollAmount,
		         TPV.AVITollAmount,
		         TPV.TollAmount,
				 TPV.WriteOffAmount,
		         ILT.Amount,
		         CAST(CONVERT(VARCHAR, TPV.PostedDate, 112) AS DATE),
				 TPV.WriteOffDate,
		         TPV.PaymentStatusID,
		         TPV.TripStageID,
		         TPV.TripStatusID,
		         TPV.TransactionTypeID,
				 CAST(CASE WHEN IH.LND_UpdateType = 'D' OR ILT.LND_UpdateType = 'D' OR TPV.LND_UpdateType = 'D' OR TPCT.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT)
				 ,InvSt.InvoiceStatusID
				 ,IH.InvoiceDate
		OPTION (LABEL = 'dbo.Fact_InvoiceDetail_NEW Load');
				
		SET @Log_Message = 'Loaded dbo.Fact_InvoiceDetail_NEW';
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message,'I',-1,NULL;

		-- Statistics
		CREATE STATISTICS STATS_Fact_InvoiceDetail_000 ON dbo.Fact_InvoiceDetail_NEW (InvoiceNumber)
		CREATE STATISTICS STATS_Fact_InvoiceDetail_001 ON dbo.Fact_InvoiceDetail_NEW (TpTripID)
		CREATE STATISTICS STATS_Fact_InvoiceDetail_002 ON dbo.Fact_InvoiceDetail_NEW (CitationID)
		CREATE STATISTICS STATS_Fact_InvoiceDetail_003 ON dbo.Fact_InvoiceDetail_NEW (DeleteFlag)
		CREATE STATISTICS STATS_Fact_InvoiceDetail_004 ON dbo.Fact_InvoiceDetail_NEW (AgeStageID)
		CREATE STATISTICS STATS_Fact_InvoiceDetail_005 ON dbo.Fact_InvoiceDetail_NEW (InvoiceStatusID)


		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_InvoiceDetail_NEW', 'dbo.Fact_InvoiceDetail';
		
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date,'Completed full load', 'I',NULL,NULL;
		
		-- Show results
		IF @Trace_Flag = 1  EXEC Utility.FromLog @Log_Source, @Log_Start_Date;
		IF @Trace_Flag = 1  SELECT TOP 1000 'dbo.Fact_InvoiceDetail' TableName, * FROM dbo.Fact_InvoiceDetail  ORDER BY 2 DESC;
	
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
EXEC dbo.Fact_InvoiceDetail_Full_Load

EXEC Utility.FromLog 'dbo.Fact_InvoiceDetail', 1
SELECT TOP 100 'dbo.Fact_InvoiceDetail' Table_Name, * FROM dbo.Fact_InvoiceDetail ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================


*/


