CREATE PROC [Utility].[Item90_TestResultDetail_Load] AS

/*
################################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------------------- 
This process runs the sequence of testcases on Migrated & Non Migrated invoicenumbers available in dbo.Fact_Invoice table & loads
the failed invoicenumbers along with testcase ID into Utility.Item90_TestResultDetail. 
Need to join Utility.Item90_TestResultDetail & Utility.Item90_TestResult table on Max(TestRundID) & TestCaseID to find 
header information like Test Case Description and No of Test Cased PASSED/FAILED along with failed Invoices count.
Example:-
TestDate   |TestRunID| TestCaseID | TestCaseDesc                                         | InvoiceNumber|EDW_UpdateDate
--------------------------------------------------------------------------------------------------------------------------------
2023-02-13 |1        |1.010       | firstNotice fee should be less than secondNotice fee | 1222758063   |2023-02-17 09:59:37.888
--------------------------------------------------------------------------------------------------------------------------------
================================================================================================================================
Change Log:
--------------------------------------------------------------------------------------------------------------------------------
CHG0042529	Raj 		2023-02-20	New!
################################################################################################################################
*/
BEGIN

  BEGIN TRY

	DECLARE @Log_Source VARCHAR(100) = 'Utility.Item90_TestResultDetail_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME();
	DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0; -- Testing
	EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started Utility.Item90_TestResultDetail_Load', 'I', NULL, NULL;
    

	   
    DECLARE @TestRunID  int 
    DECLARE @TestCaseID varchar(15)
    DECLARE @TestCaseDesc varchar(250)
    DECLARE @TestDate DATETIME2(0)
	DECLARE @EDW_UpdateDate  DATETIME2(3)
   
     
	SELECT @TestDate =MAX(TestDate), @TestRunID = MAX(TestRunID) FROM Utility.Item90_TestResult;
   
    --- MIGRATED ----

    ------------------------------------------------------------------------
    -- TestCase# 1
    -- InvoiceNumber should be not null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.001'
    
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate
   from dbo.Fact_Invoice WHERE MigratedFlag=1 AND InvoiceNumber is Null
   

   ------------------------------------------------------------------------
   -- TestCase# 2
   ------------------------------------------------------------------------
   set @TestCaseID = '1.002'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate
   FROM(
   select   InvoiceNumber,
            COUNT(*) X from dbo.Fact_Invoice
    WHERE MigratedFlag=1   
   group by InvoiceNumber
   HAVING COUNT(*) > 1
   )ct
   
   ------------------------------------------------------------------------
   -- TestCase# 3
   ------------------------------------------------------------------------
   set @TestCaseID = '1.003'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND CustomerID is Null   
 
   ------------------------------------------------------------------------
   -- TestCase# 4
   ------------------------------------------------------------------------
   set @TestCaseID = '1.004'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees
   
   ------------------------------------------------------------------------
   -- TestCase# 5
   -- AdjustedAmount and PaidAmount should be greater than 0 when Invoice is Paid
   ------------------------------------------------------------------------
   set @TestCaseID = '1.005'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND EDW_invoicestatusid =516 and AdjustedAmount<=0 and PaidAmount<=0

   ------------------------------------------------------------------------
   -- TestCase# 6
   -- LastPaymentDate should be after the FirstPaymentDate.
   ------------------------------------------------------------------------
   set @TestCaseID = '1.006'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FirstPaymentDate>LastPaymentDate
   ------------------------------------------------------------------------
   -- TestCase# 7
   -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
   ------------------------------------------------------------------------
   set @TestCaseID = '1.007'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4370 and FirstPaymentDate<>'1900-01-01'    and ZipCashDate>='2019-01-01'

	------------------------------------------------------------------------
    -- TestCase# 8
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.008'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))
   
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4370 and LastPaymentDate<>'1900-01-01'    and ZipCashDate>='2019-01-01'

	------------------------------------------------------------------------
    -- TestCase# 9
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.009'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))
   
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99999 and (FirstPaymentDate ='1900-01-01' or FirstPaymentDate is null)   and ZipCashDate>='2019-01-01'

	------------------------------------------------------------------------
    -- TestCase# 10
    -- FirstNotice Fee should be less than SecondNotice Fee
    ------------------------------------------------------------------------
   set @TestCaseID = '1.010'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))
   
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FNfees>SNfees and SNfees>0  and ZipCashDate>='2019-01-01' 
   
	------------------------------------------------------------------------
    -- TestCase# 11
    -- if the invoice is in Citation Issued then the DueDate should be greater than CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.011'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))
   
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     CitationDate>DueDate and CitationDate<>'1900-01-01' and DueDate<>'1900-01-01' and AgeStageID = 6  and ZipCashDate>='2019-01-01'

   ------------------------------------------------------------------------
    -- TestCase# 12
    ------------------------------------------------------------------------
   set @TestCaseID = '1.012'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate
   FROM (
   select InvoiceNumber, sum(TxnCnt) edw_count from dbo.Fact_Invoice EDW where LEFT(CONVERT(VARCHAR, ZipCashDate, 112), 4) in (2019, 2020) group by InvoiceNumber
   except
   select InvoiceNumber, sum(TxnCnt) rite_count  FROM Ref.RiteMigratedInvoice  where LEFT(CONVERT(VARCHAR, ZipCashDate, 112), 4) in (2019, 2020) group by InvoiceNumber  
   ) cte1
   ------------------------------------------------------------------------
    -- TestCase# 13
    -- if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice
    ------------------------------------------------------------------------
   set @TestCaseID = '1.013'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))
   
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     DueDate<ThirdNoticeDate and AgeStageID = 4 and DueDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'    and ZipCashDate>='2019-01-01'
   ------------------------------------------------------------------------
    -- TestCase# 14
    -- if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice
    ------------------------------------------------------------------------
   set @TestCaseID = '1.014'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     DueDate<SecondNoticeDate and AgeStageID = 3  and DueDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01' 
   
   ------------------------------------------------------------------------
    -- TestCase# 15
    -- ZipCashDate should not be defaulted to 1900-01-01 when the invoice is in "ZipCash" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.015'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ZipCashDate='1900-01-01' and AgeStageID >= 1 AND FIRSTNOTICEDATE >='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 16
    -- FirstNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "First Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.016'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     FirstNoticeDate='1900-01-01' and AgeStageID = 2
   
   ------------------------------------------------------------------------
    -- TestCase# 17
    -- SecondNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Second Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.017'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     SecondNoticeDate='1900-01-01' and AgeStageID = 3
   
   ------------------------------------------------------------------------
    -- TestCase# 18
    -- ThirdNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Third Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.018'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     ThirdNoticeDate='1900-01-01' and AgeStageID = 4
   
   ------------------------------------------------------------------------
    -- TestCase# 19
    -- LegalActionPendingDate should not be defaulted to 1900-01-01 when the invoice is in "Legal Action Pending" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.019'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))
   
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     LegalActionPendingDate='1900-01-01' and AgeStageID = 5 

   ------------------------------------------------------------------------
    -- TestCase# 20
    -- CitationDate should not be defaulted to 1900-01-01 when the invoice is in "Citation Issued" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.020'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))
   
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     CitationDate='1900-01-01' and AgeStageID = 6 
   
   ------------------------------------------------------------------------
    -- TestCase# 21
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.021'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))
   
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99999 and (LastPaymentDate ='1900-01-01' or LastPaymentDate is null)   and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 22
    -- ThirdNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.022'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     ThirdNoticeDate >LegalActionPendingDate  and ThirdNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 23
    -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.023'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99998 and (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01')   and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 24
    -- SecondNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.024'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     SecondNoticeDate>LegalActionPendingDate and SecondNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 25
    -- SecondNoticeDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.025'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     SecondNoticeDate>CitationDate  and SecondNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
      
   ------------------------------------------------------------------------
    -- TestCase# 26
    -- SecondNoticeDate should be before ThirdNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.026'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     SecondNoticeDate>ThirdNoticeDate and SecondNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
      
   ------------------------------------------------------------------------
    -- TestCase# 27
    -- FirstNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.027'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     FirstNoticeDate>LegalActionPendingDate and FirstNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 28
    -- FirstNoticeDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.028'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))
  
   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FirstNoticeDate>CitationDate  and FirstNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'  and ZipCashDate>='2019-01-01' 
   
   ------------------------------------------------------------------------
    -- TestCase# 29
    -- FirstNoticeDate should be before ThirdNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.029'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FirstNoticeDate>ThirdNoticeDate and FirstNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'  and ZipCashDate>='2019-01-01' 
      
   ------------------------------------------------------------------------
    -- TestCase# 30
    -- FirstNoticeDate should be before SecondNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.030'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     FirstNoticeDate>SecondNoticeDate and FirstNoticeDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01' and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 31
    -- ZipCashDate should be before DueDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.031'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     ZipCashDate>DueDate  and ZipCashDate<>'1900-01-01' and DueDate<>'1900-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 32
    -- ZipCashDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.032'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     ZipCashDate>LegalActionPendingDate and ZipCashDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
   -- TestCase# 33
   -- ZipCashDate should be before CitationDate
   ------------------------------------------------------------------------
   set @TestCaseID = '1.033'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     ZipCashDate>CitationDate and ZipCashDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   
   ------------------------------------------------------------------------
   -- TestCase# 34
   -- ZipCashDate should be before ThirdNoticeDate
   ------------------------------------------------------------------------
   set @TestCaseID = '1.034'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     ZipCashDate>ThirdNoticeDate and ZipCashDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
    ------------------------------------------------------------------------
    -- TestCase# 35
    -- ZipCashDate should be before SecondNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.035'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     ZipCashDate>SecondNoticeDate and ZipCashDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
    ------------------------------------------------------------------------
    -- TestCase# 36
    -- ZipCashDate should be before FirstNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.036'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     ZipCashDate>FirstNoticeDate and ZipCashDate<>'1900-01-01' and FirstNoticeDate<>'1900-01-01'

   ------------------------------------------------------------------------
   -- TestCase# 37
   -- PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)
   ------------------------------------------------------------------------
   set @TestCaseID = '1.037'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     PaidAmount<>TollsPaid+FNfeesPaid+SNfeesPaid   and ZipCashDate>='2019-01-01'   

    ------------------------------------------------------------------------
    -- TestCase# 38
    -- AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)
    ------------------------------------------------------------------------
   set @TestCaseID = '1.038'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees   

    ------------------------------------------------------------------------
    -- TestCase# 39
    -- ExpectedAmount should be equal to (Tolls+FNfees+SNfees)
    ------------------------------------------------------------------------
   set @TestCaseID = '1.039'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     ExpectedAmount<>Tolls+FNfees+SNfees
   
    ------------------------------------------------------------------------
    -- TestCase# 40
    -- AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)
    ------------------------------------------------------------------------
   set @TestCaseID = '1.040'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     AdjustedAmount<>TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted   

    ------------------------------------------------------------------------
    -- TestCase# 41
    -- OutstandingAmount should be equal to (AdjustedExpectedAmount-PaidAmount)
    ------------------------------------------------------------------------
   set @TestCaseID = '1.041'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     OutstandingAmount<>(AdjustedExpectedAmount-PaidAmount)  and ZipCashDate>='2019-01-01'
   
    ------------------------------------------------------------------------
    -- TestCase# 42
    -- outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '1.042'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     (outstandingAmount+PaidAmount)<>(ExpectedAmount-AdjustedAmount)   and ZipCashDate>='2019-01-01'
   
    ------------------------------------------------------------------------
    -- TestCase# 43
    -- InvoiceAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.043'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     InvoiceAmount is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 44
    -- Tolls should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.044'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     Tolls is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 45
    -- FNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.045'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     FNfees is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 46
    -- SNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.046'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     SNfees is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 47
    -- ExpectedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.047'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     ExpectedAmount is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 48
    -- TollsAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.048'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     TollsAdjusted is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 49
    -- FNfeesAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.049'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     FNfeesAdjusted is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 50
    -- SNfeesAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.050'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     SNfeesAdjusted is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 51
    -- AdjustedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.051'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     AdjustedAmount is Null
   
   ------------------------------------------------------------------------
    -- TestCase# 52
    -- TollsPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.052'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     TollsPaid is Null
   
   ------------------------------------------------------------------------
    -- TestCase# 53
    -- FNfeesPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.053'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     FNfeesPaid is Null

    ------------------------------------------------------------------------
    -- TestCase# 54
    -- SNfeesPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.054'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     SNfeesPaid is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 55
    -- PaidAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.055'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     PaidAmount is Null   
   
    ------------------------------------------------------------------------
    -- TestCase# 56
    -- AdjustedExpectedTolls should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.056'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     AdjustedExpectedTolls is Null
   
   ------------------------------------------------------------------------
    -- TestCase# 57
    -- AdjustedExpectedFNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.057'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     AdjustedExpectedFNfees is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 58
    -- AdjustedExpectedSNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.058'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     AdjustedExpectedSNfees is Null
   
   ------------------------------------------------------------------------
    -- TestCase# 59
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.059'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99998 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01') and ZipCashDate>='2019-01-01'
  
   ------------------------------------------------------------------------
    -- TestCase# 60
    -- AdjustedExpectedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.060'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     AdjustedExpectedAmount is Null   
   
    ------------------------------------------------------------------------
    -- TestCase# 61
    -- TollOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.061'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     TollOutStandingAmount is Null
   
    ------------------------------------------------------------------------
    -- TestCase# 62
    -- FNfeesOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.062'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     FNfeesOutStandingAmount is Null   
   
     ------------------------------------------------------------------------
    -- TestCase# 63
    -- SNfeesOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.063'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     SNfeesOutStandingAmount is Null
   
   ------------------------------------------------------------------------
    -- TestCase# 64
    -- OutstandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.064'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     OutstandingAmount is Null   
      
    ------------------------------------------------------------------------
    -- TestCase# 65
    -- When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"
    ------------------------------------------------------------------------
   set @TestCaseID = '1.065'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND    EDW_invoicestatusID not in (4434,516,513,99998,99999) and AdjustedAmount=0 and PaidAmount=0 and outstandingAmount=ExpectedAmount and EDW_invoicestatusID<>4370 

	------------------------------------------------------------------------
    -- TestCase# 66
    -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.066'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4434 and  (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01') and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 67
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.067'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4434 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01')
   and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 68
    -- When CitationDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.068'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND    CitationDate >'2019-01-01' and ZipCashDate<'1901-01-01'   
   ------------------------------------------------------------------------
    -- TestCase# 69
    -- When CitationDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.069'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND   CitationDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
   ------------------------------------------------------------------------
    -- TestCase# 70
    -- When CitationDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.070'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND   CitationDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
	------------------------------------------------------------------------
    -- TestCase# 71
    -- ValiDate no Fees for Zipcash Invoices
    ------------------------------------------------------------------------
   set @TestCaseID = '1.071'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND AgeStageID=1 AND (FNfees>0 OR SNfees>0) AND (FNfeesAdjusted=0 OR SNfeesAdjusted=0)
		
	------------------------------------------------------------------------
    -- TestCase# 72
    -- Valiate no SNfees for FN Invoices
    ------------------------------------------------------------------------
   set @TestCaseID = '1.072'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND AgeStageID=2 AND  SNfees>0

   ------------------------------------------------------------------------
    -- TestCase# 73
    -- When LegalActionPendingDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.073'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND   LegalActionPendingDate >'2019-01-01' and ZipCashDate<'1901-01-01' 
   ------------------------------------------------------------------------
    -- TestCase# 74
    -- When LegalActionPendingDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.074'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND   LegalActionPendingDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'   
   
   ------------------------------------------------------------------------
    -- TestCase# 75
    -- When LegalActionPendingDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.075'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND   LegalActionPendingDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 76
    -- When LegalActionPendingDate is populated then valid thirdNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.076'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice   
   WHERE MigratedFlag=1 AND   LegalActionPendingDate<>'1900-01-01' and thirdNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   ------------------------------------------------------------------------
    -- TestCase# 77
    -- When thirdNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.077'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   thirdNoticeDate>'2019-01-01' and ZipCashDate<'1901-01-01'   

   ------------------------------------------------------------------------
    -- TestCase# 78
    -- When thirdNoticeDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.078'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND   thirdNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 79
    -- When thirdNoticeDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.079'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND   thirdNoticeDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 80
    -- When SecondNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.080'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND   SecondNoticeDate >'2019-01-01' and ZipCashDate<'1901-01-01'

      ------------------------------------------------------------------------
    -- TestCase# 81
    -- When SecondNoticeDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.081'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND   SecondNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
    
    ------------------------------------------------------------------------
    -- TestCase# 82
    -- When FirstNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.082'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND   FirstNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'  AND FIRSTNOTICEDATE >='2019-01-01'

   ------------------------------------------------------------------------
    -- TestCase# 83
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.083'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=516 and FirstPaymentDate='1900-01-01'    and ZipCashDate>='2019-01-01'

	------------------------------------------------------------------------
    -- TestCase# 84
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.084'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=516 and LastPaymentDate='1900-01-01'    and ZipCashDate>='2019-01-01'   

   ------------------------------------------------------------------------
    -- TestCase# 85
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.085'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=515 and FirstPaymentDate='1900-01-01' 
   
   ------------------------------------------------------------------------
    -- TestCase# 86
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.086'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=515 and LastPaymentDate='1900-01-01' 

	------------------------------------------------------------------------
    -- TestCase# 87
    -- Unassigned Invoices should not have PaidAmount.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.087'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND    EDW_InvoiceStatusID=99998 AND PaidAmount>0

	------------------------------------------------------------------------
    -- TestCase# 88
    -- Unknown Statuse Validation.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.088'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag=1 AND  EDW_InvoiceStatusID=-1   AND zipcashDate>='2019-01-01' 

	------------------------------------------------------------------------
    -- TestCase# 89
    -- PartialPaid Invoices should have valid PaidAmount.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.089'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND  EDW_InvoiceStatusID=515 AND PaidAmount<=0

	------------------------------------------------------------------------
    -- TestCase# 90
    -- Paid Invoices - PaidAmount should match with AdjustedExpectedTolls
    ------------------------------------------------------------------------
   set @TestCaseID = '1.090'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND EDW_InvoiceStatusID=516  AND AdjustedExpectedTolls<>TollsPaid AND zipcashDate>='2019-01-01' 
	
	------------------------------------------------------------------------
    -- TestCase# 91
    -- AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '1.091'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND  ZipCashDate>='2019-01-01' AND (ExpectedAmount-AdjustedAmount)<>AdjustedExpectedAmount	

	------------------------------------------------------------------------
    -- TestCase# 92
    -- Closed Invoices should have valid PaidAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '1.092'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND EDW_InvoiceStatusID= 4434 AND PaidAmount>0  AND ZipCashDate>='2019-01-01' 	

	------------------------------------------------------------------------
    -- TestCase# 93
    -- Unassigned Invoices should not have AdjustedExpectedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '1.093'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND EDW_InvoiceStatusID=99998 AND AdjustedExpectedAmount<>0 AND ZipCashDate>='2019-01-01'
   ------------------------------------------------------------------------
    -- TestCase# 94
    -- First Notice Adjustment Fees  should not be more than First Notice Fees
    ------------------------------------------------------------------------
   set @TestCaseID = '1.094'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND FNfeesAdjusted>FNfees
   ------------------------------------------------------------------------
    -- TestCase# 95
    -- Second Notice Adjustment Fees  should not be more than Second Notice Fees
    ------------------------------------------------------------------------
   set @TestCaseID = '1.095'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND SNfeesAdjusted>SNfees
   
   ------------------------------------------------------------------------
    -- TestCase# 96
    -- Invoice ExpectedAmount should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.096'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND ExpectedAmount <= 0
   
   ------------------------------------------------------------------------
    -- TestCase# 97
    -- InvoiceAmount should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.097'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND ExpectedAmount <= 0 and ZipCashDate>='2019-01-01'
   
   ------------------------------------------------------------------------
   -- TestCase# 98
   -- Invoice Tolls should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.098'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND Tolls <= 0

   ------------------------------------------------------------------------
   -- TestCase# 99
   -- Invoice AVITollAmount should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.099'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND AVITollAmount <= 0

   ------------------------------------------------------------------------
    -- TestCase# 100
    -- Invoice PBMTollAmount should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.100'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND PBMTollAmount <= 0

   ------------------------------------------------------------------------
    -- TestCase# 101
    -- Invoice txncnt should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.101'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND txncnt <= 0
   
--- NON-MIGRATED ----

    ------------------------------------------------------------------------
    -- InvoiceNumber should be not null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.001'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     InvoiceNumber is Null   

    ------------------------------------------------------------------------
    -- TestCase# 2
    ------------------------------------------------------------------------
   set @TestCaseID = '2.002'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate 
   FROM (
   select   InvoiceNumber,
            COUNT(*) X
   from     dbo.Fact_Invoice WHERE MigratedFlag<>1   
   group by InvoiceNumber
   HAVING COUNT(*) > 1
   )ct   

    ------------------------------------------------------------------------
    -- TestCase# 3
    ------------------------------------------------------------------------
   set @TestCaseID = '2.003'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     CustomerID is Null
 
   ------------------------------------------------------------------------
    -- TestCase# 4
    ------------------------------------------------------------------------
   set @TestCaseID = '2.004'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees

   ------------------------------------------------------------------------
    -- TestCase# 5
    -- AdjustedAmount and PaidAmount should be greater than 0 when Invoice is Paid
    ------------------------------------------------------------------------
   set @TestCaseID = '2.005'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusid =516 and AdjustedAmount=0 and PaidAmount=0
   
   ------------------------------------------------------------------------
    -- TestCase# 6
    -- LastPaymentDate should be after the FirstPaymentDate.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.006'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FirstPaymentDate>LastPaymentDate 
   
   ------------------------------------------------------------------------
    -- TestCase# 7
    -- PBMTollAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.007'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     PBMTollAmount is null
   
   ------------------------------------------------------------------------
    -- TestCase# 8
    -- AVITollAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.008'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AVITollAmount is null
   
   ------------------------------------------------------------------------
    -- TestCase# 9
    -- PremiumAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.009'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     PremiumAmount is null
   ------------------------------------------------------------------------
    -- TestCase# 10
    -- FirstNotice Fee should be less than SecondNotice Fee
    ------------------------------------------------------------------------
   set @TestCaseID = '2.010'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FNfees>SNfees and SNfees>0
   
   ------------------------------------------------------------------------
    -- TestCase# 11
    -- if the invoice is in Citation Issued then the DueDate should be greater than CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.011'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     CitationDate>DueDate and CitationDate<>'1900-01-01' and DueDate<>'1900-01-01' and AgeStageID = 6
   
   ------------------------------------------------------------------------
    -- TestCase# 12
    -- if the invoice is in Legal Action Pending then the DueDate should be greater than LegalActionPendingDate
    ------------------------------------------------------------------------------------------------------------
   set @TestCaseID = '2.012'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     LegalActionPendingDate>DueDate and LegalActionPendingDate<>'1900-01-01' and DueDate<>'1900-01-01' and AgeStageID = 5
      
   ------------------------------------------------------------------------
    -- TestCase# 13
    -- if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice
    ------------------------------------------------------------------------
   set @TestCaseID = '2.013'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     DueDate<ThirdNoticeDate and AgeStageID = 4 and DueDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01' 
      
   ------------------------------------------------------------------------
    -- TestCase# 14
    -- if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice
    ------------------------------------------------------------------------
   set @TestCaseID = '2.014'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     DueDate<SecondNoticeDate and AgeStageID = 3  and DueDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01' 
   
   ------------------------------------------------------------------------
    -- TestCase# 15
    -- ZipCashDate should not be defaulted to 1900-01-01 when the invoice is in "ZipCash" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.015'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ZipCashDate='1900-01-01' and AgeStageID >= 1
	
	------------------------------------------------------------------------
    -- TestCase# 16
    -- FirstNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "First Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.016'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     FirstNoticeDate='1900-01-01' and AgeStageID = 2	
	------------------------------------------------------------------------
    -- TestCase# 17
    -- SecondNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Second Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.017'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     SecondNoticeDate='1900-01-01' and AgeStageID = 3
   
	------------------------------------------------------------------------
    -- TestCase# 18
    -- ThirdNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Third Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.018'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ThirdNoticeDate='1900-01-01' and AgeStageID = 4	

	------------------------------------------------------------------------
    -- TestCase# 19
    -- LegalActionPendingDate should not be defaulted to 1900-01-01 when the invoice is in "Legal Action Pending" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.019'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     LegalActionPendingDate='1900-01-01' and AgeStageID = 5 

	------------------------------------------------------------------------
    -- TestCase# 20
    -- CitationDate should not be defaulted to 1900-01-01 when the invoice is in "Citation Issued" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.020'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     CitationDate='1900-01-01' and AgeStageID = 6 

	------------------------------------------------------------------------
    -- TestCase# 21
    -- CitationDate should be after LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.021'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     CitationDate < LegalActionPendingDate and CitationDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01' 
   
	------------------------------------------------------------------------
    -- TestCase# 22
    -- ThirdNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.022'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ThirdNoticeDate >LegalActionPendingDate  and ThirdNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'
   
	------------------------------------------------------------------------
    -- TestCase# 23
    -- ThirdNoticeDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.023'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ThirdNoticeDate >CitationDate  and ThirdNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   
	------------------------------------------------------------------------
    -- TestCase# 24
    -- SecondNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.024'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     SecondNoticeDate>LegalActionPendingDate and SecondNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   
   
	------------------------------------------------------------------------
    -- TestCase# 25
    -- SecondNoticeDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.025'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     SecondNoticeDate>CitationDate  and SecondNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'
      
	------------------------------------------------------------------------
    -- TestCase# 26
    -- SecondNoticeDate should be before ThirdNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.026'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     SecondNoticeDate>ThirdNoticeDate and SecondNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'
   
	------------------------------------------------------------------------
    -- TestCase# 27
    -- FirstNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.027'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>LegalActionPendingDate and FirstNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   
   
	------------------------------------------------------------------------
    -- TestCase# 28
    -- FirstNoticeDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.028'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>CitationDate  and FirstNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'

   ------------------------------------------------------------------------
    -- TestCase# 29
    -- FirstNoticeDate should be before ThirdNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.029'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>ThirdNoticeDate and FirstNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'
   ------------------------------------------------------------------------
    -- TestCase# 30
    -- FirstNoticeDate should be before SecondNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.030'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>SecondNoticeDate and FirstNoticeDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'   
   
	------------------------------------------------------------------------
    -- TestCase# 31
    -- ZipCashDate should be before DueDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.031'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ZipCashDate>DueDate  and ZipCashDate<>'1900-01-01' and DueDate<>'1900-01-01'
	
	------------------------------------------------------------------------
    -- TestCase# 32
    -- ZipCashDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.032'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ZipCashDate>LegalActionPendingDate and ZipCashDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'
      
   ------------------------------------------------------------------------
    -- TestCase# 33
    -- ZipCashDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.033'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ZipCashDate>CitationDate and ZipCashDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   ------------------------------------------------------------------------
    -- TestCase# 34
    -- ZipCashDate should be before ThirdNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.034'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ZipCashDate>ThirdNoticeDate and ZipCashDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'   
   
	------------------------------------------------------------------------
    -- TestCase# 35
    -- ZipCashDate should be before SecondNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.035'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ZipCashDate>SecondNoticeDate and ZipCashDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'   
   
	------------------------------------------------------------------------
    -- TestCase# 36
    -- ZipCashDate should be before FirstNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.036'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ZipCashDate>FirstNoticeDate and ZipCashDate<>'1900-01-01' and FirstNoticeDate<>'1900-01-01'   
   
	------------------------------------------------------------------------
    -- TestCase# 37
    -- PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)
    ------------------------------------------------------------------------
   set @TestCaseID = '2.037'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     PaidAmount<>TollsPaid+FNfeesPaid+SNfeesPaid
	------------------------------------------------------------------------
    -- TestCase# 38
    -- AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)
    ------------------------------------------------------------------------
   set @TestCaseID = '2.038'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees   

	------------------------------------------------------------------------
    -- TestCase# 39
    -- ExpectedAmount should be equal to (Tolls+FNfees+SNfees)
    ------------------------------------------------------------------------
   set @TestCaseID = '2.039'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ExpectedAmount<>Tolls+FNfees+SNfees

	------------------------------------------------------------------------
    -- TestCase# 40
    -- AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)
    ------------------------------------------------------------------------
   set @TestCaseID = '2.040'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     AdjustedAmount<>TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted
	------------------------------------------------------------------------
    -- TestCase# 41
    -- First Notice Adjustment Fees  should not be more than First Notice Fees
    ------------------------------------------------------------------------
   set @TestCaseID = '2.041'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND FNfeesAdjusted>FNfees
	
	------------------------------------------------------------------------
    -- TestCase# 42
    -- outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '2.042'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     (outstandingAmount+PaidAmount)<>(ExpectedAmount-AdjustedAmount)  
   
	------------------------------------------------------------------------
    -- TestCase# 43
    -- InvoiceAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.043'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     InvoiceAmount is Null   
   
	------------------------------------------------------------------------
    -- TestCase# 44
    -- Tolls should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.044'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     Tolls is Null

	------------------------------------------------------------------------
    -- TestCase# 45
    -- FNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.045'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     FNfees is Null   
   
	------------------------------------------------------------------------
    -- TestCase# 46
    -- SNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.046'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     SNfees is Null   
   
	------------------------------------------------------------------------
    -- TestCase# 47
    -- ExpectedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.047'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     ExpectedAmount is Null
   
	------------------------------------------------------------------------
    -- TestCase# 48
    -- TollsAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.048'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     TollsAdjusted is Null
   
	------------------------------------------------------------------------
    -- TestCase# 49
    -- FNfeesAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.049'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     FNfeesAdjusted is Null   
   
	------------------------------------------------------------------------
    -- TestCase# 50
    -- SNfeesAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.050'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     SNfeesAdjusted is Null
   
	------------------------------------------------------------------------
    -- TestCase# 51
    -- AdjustedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.051'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     AdjustedAmount is Null
	------------------------------------------------------------------------
    -- TestCase# 52
    -- TollsPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.052'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     TollsPaid is Null
   ------------------------------------------------------------------------
    -- TestCase# 53
    -- FNfeesPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.053'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     FNfeesPaid is Null

	------------------------------------------------------------------------
    -- TestCase# 54
    -- SNfeesPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.054'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     SNfeesPaid is Null
   
	------------------------------------------------------------------------
    -- TestCase# 55
    -- PaidAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.055'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     PaidAmount is Null
   
	------------------------------------------------------------------------
    -- TestCase# 56
    -- AdjustedExpectedTolls should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.056'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     AdjustedExpectedTolls is Null   
   
   ------------------------------------------------------------------------
    -- TestCase# 57
    -- AdjustedExpectedFNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.057'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     AdjustedExpectedFNfees is Null   
   
	------------------------------------------------------------------------
    -- TestCase# 58
    -- AdjustedExpectedSNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.058'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice    
   WHERE MigratedFlag<>1 AND     AdjustedExpectedSNfees is Null
   
   ------------------------------------------------------------------------
    -- TestCase# 60
    -- AdjustedExpectedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.060'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AdjustedExpectedAmount is Null
   
	------------------------------------------------------------------------
    -- TestCase# 61
    -- TollOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.061'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     TollOutStandingAmount is Null
  
	------------------------------------------------------------------------
    -- TestCase# 62
    -- FNfeesOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.062'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FNfeesOutStandingAmount is Null
      
  ------------------------------------------------------------------------
    -- TestCase# 63
    -- SNfeesOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.063'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     SNfeesOutStandingAmount is Null
   ------------------------------------------------------------------------
    -- TestCase# 64
    -- OutstandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.064'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     OutstandingAmount is Null
      
   ------------------------------------------------------------------------
    -- TestCase# 65
    -- When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"
    ------------------------------------------------------------------------
   set @TestCaseID = '2.065'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND    EDW_invoicestatusID not in (4434,516,513,99998,99999) and AdjustedAmount=0 and PaidAmount=0 and outstandingAmount=ExpectedAmount and EDW_invoicestatusID<>4370

   ------------------------------------------------------------------------
    -- TestCase# 66
    -- firstinvoiceid should be Not NULL when invoicestatus in (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status
    ------------------------------------------------------------------------
   set @TestCaseID = '2.066'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND  EDW_invoicestatusID in(4370,4434,99998,99999) and firstinvoiceid is null    

   ------------------------------------------------------------------------
    -- TestCase# 67
    -- currentinvoiceid should be Not NULL when invoicestatus in (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status
    ------------------------------------------------------------------------
   set @TestCaseID = '2.067'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND  EDW_invoicestatusID in(4370,4434,99998,99999) and currentinvoiceid is null       

	------------------------------------------------------------------------
    -- TestCase# 68
    -- When CitationDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.068'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND    CitationDate<>'1900-01-01' and ZipCashDate<'1901-01-01'      

   ------------------------------------------------------------------------
    -- TestCase# 69
    -- When CitationDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.069'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   CitationDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'
   
	------------------------------------------------------------------------
    -- TestCase# 70
    -- When CitationDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.070'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   CitationDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'
    
	------------------------------------------------------------------------
    -- TestCase# 71
    -- When CitationDate is populated then valid thirdNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.071'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

	INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   CitationDate<>'1900-01-01' and thirdNoticeDate<'1901-01-01'

	------------------------------------------------------------------------
    -- TestCase# 72
    -- Second Notice Adjustment Fees  should not be more than Second Notice Fees
    ------------------------------------------------------------------------
   set @TestCaseID = '2.072'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND SNfeesAdjusted>SNfees
     
	------------------------------------------------------------------------
    -- TestCase# 73
    -- When LegalActionPendingDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.073'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and ZipCashDate<'1901-01-01'
   
	------------------------------------------------------------------------
    -- TestCase# 74
    -- When LegalActionPendingDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.074'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'
   
	------------------------------------------------------------------------
    -- TestCase# 75
    -- When LegalActionPendingDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.075'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'
      
	------------------------------------------------------------------------
    -- TestCase# 76
    -- When LegalActionPendingDate is populated then valid thirdNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.076'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and thirdNoticeDate<'1901-01-01'
   
	------------------------------------------------------------------------
    -- TestCase# 77
    -- When thirdNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.077'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   thirdNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'
   
	------------------------------------------------------------------------
    -- TestCase# 78
    -- When thirdNoticeDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.078'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   thirdNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'
   
	------------------------------------------------------------------------
    -- TestCase# 79
    -- When thirdNoticeDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.079'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   thirdNoticeDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'
   
   ------------------------------------------------------------------------
    -- TestCase# 80
    -- When SecondNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.080'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   SecondNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'
   
      ------------------------------------------------------------------------
    -- TestCase# 81
    -- When SecondNoticeDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.081'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   SecondNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'
    
    ------------------------------------------------------------------------
    -- TestCase# 82
    -- When FirstNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.082'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   FirstNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'
   
	------------------------------------------------------------------------
    -- TestCase# 83
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.083'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=516 and FirstPaymentDate='1900-01-01' 
   
	------------------------------------------------------------------------
    -- TestCase# 84
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.084'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=516 and LastPaymentDate='1900-01-01' 
   
	------------------------------------------------------------------------
    -- TestCase# 85
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.085'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=515 and FirstPaymentDate='1900-01-01' 
   
	------------------------------------------------------------------------
    -- TestCase# 86
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.086'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=515 and LastPaymentDate='1900-01-01' 
       
   	------------------------------------------------------------------------
    -- TestCase# 87
    -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.087'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4370 and FirstPaymentDate<>'1900-01-01' 
   
	------------------------------------------------------------------------
    -- TestCase# 88
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.088'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4370 and LastPaymentDate<>'1900-01-01' 
   
	------------------------------------------------------------------------
    -- TestCase# 89
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.089'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99999 and (FirstPaymentDate ='1900-01-01' or FirstPaymentDate is null)
   
	------------------------------------------------------------------------
    -- TestCase# 90
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.090'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99999 and (LastPaymentDate ='1900-01-01' or LastPaymentDate is null)
   
	------------------------------------------------------------------------
    -- TestCase# 91
    -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.091'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99998 and (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01')
   
	------------------------------------------------------------------------
    -- TestCase# 92
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.092'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99998 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01')
   
	------------------------------------------------------------------------
    -- TestCase# 93
    -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.093'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4434 and  (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01')
   
	------------------------------------------------------------------------
    -- TestCase# 94
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.094'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4434 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01')
   	
	------------------------------------------------------------------------
    -- TestCase# 95
    -- ValiDate no Fees for Zipcash Invoices
    ------------------------------------------------------------------------
   set @TestCaseID = '2.095'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND AgeStageID=1 AND (FNfees>0 OR SNfees>0) AND (FNfeesAdjusted=0 OR SNfeesAdjusted=0)
   	
	------------------------------------------------------------------------
    -- TestCase# 96
    -- Valiate no SNfees for FN Invoices
    ------------------------------------------------------------------------
   set @TestCaseID = '2.096'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND AgeStageID=2 AND  SNfees>0 
   
	------------------------------------------------------------------------
    -- TestCase# 97
    -- Unassigned Invoices should not have PaidAmount.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.097'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND    EDW_InvoiceStatusID=99998 AND PaidAmount>0
   
	------------------------------------------------------------------------
    -- TestCase# 98
    -- Unknown Statuse Validation.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.098'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND  EDW_InvoiceStatusID=-1   AND zipcashDate>='2019-01-01' 
   
	------------------------------------------------------------------------
    -- TestCase# 99
    -- PartialPaid Invoices should have valid PaidAmount.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.099'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND  EDW_InvoiceStatusID=515 AND PaidAmount<=0
   
	------------------------------------------------------------------------
    -- TestCase# 100
    -- Paid Invoices - PaidAmount should match with AdjustedExpectedTolls
    ------------------------------------------------------------------------
   set @TestCaseID = '2.100'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND EDW_InvoiceStatusID=516  AND AdjustedExpectedAmount<>PaidAmount AND zipcashDate>='2019-01-01' 

	------------------------------------------------------------------------
    -- TestCase# 101
    -- OutstandingAmount should be equal to AdjustedExpectedAmount-PaidAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '2.101'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND  ZipCashDate>='2019-01-01' AND (AdjustedExpectedAmount-PaidAmount) <> OutstandingAmount
   
	------------------------------------------------------------------------
    -- TestCase# 102
    -- AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '2.102'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND  ZipCashDate>='2019-01-01' AND (ExpectedAmount-AdjustedAmount)<>AdjustedExpectedAmount
   
	------------------------------------------------------------------------
    -- TestCase# 103
    -- Closed Invoices should have valid PaidAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '2.103'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND EDW_InvoiceStatusID= 4434 AND PaidAmount>0  AND ZipCashDate>='2019-01-01' 
   
	------------------------------------------------------------------------
    -- TestCase# 104
    -- Unassigned Invoices should not have AdjustedExpectedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '2.104'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND EDW_InvoiceStatusID=99998 AND AdjustedExpectedAmount<>0 AND ZipCashDate>='2019-01-01'
   	/*
	------------------------------------------------------------------------
    -- TestCase# 105
    -- TxnCnt validation between Fact and Lnd tables
    ------------------------------------------------------------------------
	set @TestCaseID = '2.105'
	
	set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

	INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate
	FROM   (SELECT H.InvoiceNumber,COUNT(DISTINCT TpTripID) TxnCnt
	FROM LND_TBOS.TollPlus.Invoice_Header H WITH (NOLOCK)
    JOIN LND_TBOS.TollPlus.Invoice_LineItems L WITH (NOLOCK)
    ON L.InvoiceID = H.InvoiceID
    JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT WITH (NOLOCK)
    ON L.LinkID = VT.CitationID
    AND L.LinkSourceName = 'TOLLPLUS.TP_VIOLATEDTRIPS'
    WHERE H.InvoiceDate>='2019-01-01'
    GROUP BY H.InvoiceNumber) lnd
	Inner Join (select InvoiceNumber,txncnt edw_TxnCnt from dbo.fact_invoice  where MigratedFlag<>1)edw
	on edw.InvoiceNumber=LND.InvoiceNumber
	where edw_txncnt<>lnd.txncnt;*/
	
	------------------------------------------------------------------------
    -- TestCase# 106
    -- Invoice ExpectedAmount should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.106'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND ExpectedAmount <= 0
   
	------------------------------------------------------------------------
    -- TestCase# 107
    -- Invoice InvoiceAmount should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.107'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND InvoiceAmount <= 0
   
	------------------------------------------------------------------------
    -- TestCase# 108
    -- Invoice Tolls should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.108'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND Tolls <= 0
   
	------------------------------------------------------------------------
    -- TestCase# 109
    -- Invoice AVITollAmount should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.109'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND AVITollAmount <= 0
   
	------------------------------------------------------------------------
    -- TestCase# 110
    -- Invoice PBMTollAmount should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.110'
   
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND PBMTollAmount <= 0
   
	------------------------------------------------------------------------
    -- TestCase# 111
    -- Invoice txncnt should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.111'

   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3))

   INSERT INTO Utility.Item90_TestResultDetail SELECT  @TestDate,@TestRunID,@TestCaseID,InvoiceNumber,@EDW_UpdateDate from dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND txncnt <= 0




   EXEC Utility.ToLog @Log_Source, @Log_Start_Date,'Completed Item90_TestResultDetail_Load', 'I',NULL,NULL;


	------------------------------------------------------------------------
    -- Updating TestCaseFailedFlag attribute in dbo.Fact_Invoice table
	------------------------------------------------------------------------
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Started Updating TestCaseFailedFlag column in dbo.Fact_Invoice table', 'I', NULL, NULL;
			
			UPDATE dbo.Fact_Invoice
			SET TestCaseFailedFlag = 1
			WHERE InvoiceNumber IN (	
									SELECT DISTINCT InvoiceNumber FROM Utility.Item90_TestResultDetail  WHERE  TestRunID = @TestRunID 
									)
		
   
	
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date,'Completed Updating TestCaseFailedFlag column in dbo.Fact_Invoice table', 'I',NULL,NULL;

	-- Show results

		IF @Trace_Flag = 1  
		BEGIN
			SELECT * FROM Utility.Item90_TestResultDetail WHERE TestRunID = @TestRunID
			ORDER BY CAST(TestCaseID AS DECIMAL (10,2));
			EXEC Utility.FromLog @Log_Source, @Log_Start_Date;
		END
	
  END TRY
	
  BEGIN CATCH
	
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
  END CATCH;
END

