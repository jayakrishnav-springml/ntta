CREATE PROC [Utility].[Item90_TestResult_Load] AS
/*
#######################################################################################################################################################################
Proc Description: 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
This process runs the sequence of testcases on migrated and non migrated invoicenumbers available
in edw_trips.dbo.Fact_Invoice table and records the result in Utility.Item90_TestResult.

Example:-
TestDate  |TestRunID|TestCaseID| TestCaseDesc            |TestResultDesc          | TestStatus | InvoiceCount | SampleInvoiceNumber|DataCategory|EDW_UpdateDate
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
2023-02-17|1        | 1.97      |InvoiceAmount should    |155269 -Invoice(s) shows|Failed      |155269        |2953228             |MIGRATED    |2023-02-17 09:59:37.888
                                 always be greater than 0|   no InvoiceAmount
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
=======================================================================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0042529			Raj			2023-02-20			New!
###################################################################################################################
*/
BEGIN
BEGIN TRY

	DECLARE @Log_Source VARCHAR(100) = 'Utility.Item90_TestResult_Load', @Log_Start_Date DATETIME2(3) = SYSDateTIME();
	DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0; -- Testing
	EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started loading Utility.Item90_TestResult', 'I', NULL, NULL;

    DECLARE @TestDate DATETIME2(0)
	DECLARE @TestRunID  int 
    DECLARE @TestCaseID VARCHAR(15)
    DECLARE @TestCaseDesc VARCHAR(255)
	DECLARE @TestResultDesc VARCHAR(255)
    DECLARE @TestStatus VARCHAR(13)    
    DECLARE @Count BIGINT
    DECLARE @InvoiceCount BIGINT
    DECLARE @SampleInvoiceNumber BIGINT
	DECLARE @DataCategory VARCHAR(50)
	DECLARE @EDW_UpdateDate  DATETIME2(3)
 
    SELECT  @TestRunID = isnull(max(TestRunID) + 1, 1) from  Utility.Item90_TestResult
    SET     @TestDate = CAST(SYSDateTIME() AS DATETIME2(0))

    --- MIGRATED ----
	SET @DataCategory ='Migrated'
    ------------------------------------------------------------------------
    -- TestCase# 1
    -- InvoiceNumber should be not null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.001'
    
   set @TestCaseDesc = 'InvoiceNumber should not be NULL'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL
   

   select @Count = count(*) from edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND InvoiceNumber is Null
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND     InvoiceNumber is Null
   
   set @InvoiceCount = @Count;   set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with InvoiceNumber as NULL'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   

   ------------------------------------------------------------------------
   -- TestCase# 2
   ------------------------------------------------------------------------
   set @TestCaseID = '1.002'
   set @TestCaseDesc = 'InvoiceNumber should be unique'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   ;with cte1 as(
   select   InvoiceNumber,
            COUNT(*) X
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1   
   group by InvoiceNumber
   HAVING COUNT(*) > 1
   ) select @Count = count(*) from cte1

   set @InvoiceCount = @Count;   set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with Duplicate InvoiceNumbers.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
   -- TestCase# 3
   ------------------------------------------------------------------------
   set @TestCaseID = '1.003'
   set @TestCaseDesc = 'CustomerID should Not be NULL'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*) FROM edw_trips.dbo.Fact_Invoice    WHERE MigratedFlag=1 AND     CustomerID is Null
   
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND     CustomerID is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing CustomerID as NULL'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end
   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   
 
   ------------------------------------------------------------------------
   -- TestCase# 4
   ------------------------------------------------------------------------
   set @TestCaseID = '1.004'
   set @TestCaseDesc = 'AdjustedExpectedAmount should be total of AdjustedExpectedTolls,AdjustedExpectedFNfees & AdjustedExpectedSNfees'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*) FROM     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees
   
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees
   
   SET @InvoiceCount = @Count;    
   set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) having AdjustedExpectedAmount NOT equal to sum of AdjustedExpectedTolls,AdjustedExpectedFNfees & AdjustedExpectedSNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end
   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   

   ------------------------------------------------------------------------
   -- TestCase# 5
   -- AdjustedAmount and PaidAmount should be greater than 0 when Invoice is Paid
   ------------------------------------------------------------------------
   set @TestCaseID = '1.005'
   set @TestCaseDesc = 'When Invoice is in Paid State, AdjustedAmount & PaidAmount should be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*) FROM     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND EDW_invoicestatusid =516 and AdjustedAmount<=0 and PaidAmount<=0
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusid =516 and AdjustedAmount<=0 and PaidAmount<=0
   
   set @InvoiceCount = @Count; set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are showing AdjustedAmount & PaidAmount as 0 even the status is PAID'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
   -- TestCase# 6
   -- LastPaymentDate should be after the FirstPaymentDate.
   ------------------------------------------------------------------------
   set @TestCaseID = '1.006'
   set @TestCaseDesc = 'FirstPaymentDate should be BEFORE LastPaymentDate.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FirstPaymentDate>LastPaymentDate 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FirstPaymentDate>LastPaymentDate 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows FirstPaymentDate AFTER LastPaymentDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
   -- TestCase# 7
   -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
   ------------------------------------------------------------------------
   set @TestCaseID = '1.007'
   set @TestCaseDesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4370 and FirstPaymentDate<>'1900-01-01'    and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4370 and FirstPaymentDate<>'1900-01-01'    and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing FirstPaymentDate even the status is OPEN.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 8
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.008'
   set @TestCaseDesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4370 and LastPaymentDate<>'1900-01-01'    and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4370 and LastPaymentDate<>'1900-01-01'    and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing LastPaymentDate even the status is OPEN.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 9
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.009'
   set @TestCaseDesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99999 and (FirstPaymentDate ='1900-01-01' or FirstPaymentDate is null)   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99999 and (FirstPaymentDate ='1900-01-01' or FirstPaymentDate is null)   and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) Doesn''t have FirstPaymentDate even the status is VTolled.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 10
    -- FirstNotice Fee should be less than SecondNotice Fee
    ------------------------------------------------------------------------
   set @TestCaseID = '1.010'
   set @TestCaseDesc = 'FirstNotice Fee should be less than SecondNotice Fee'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FNfees>SNfees and SNfees>0  and ZipCashDate>='2019-01-01' 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FNfees>SNfees and SNfees>0  and ZipCashDate>='2019-01-01' 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has FirstNotice Fee more than SecondNotice Fee.' 
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 11
    -- if the invoice is in Citation Issued then the DueDate should be greater than CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.011'
   set @TestCaseDesc = 'if the invoice is in Citation Issued then the DueDate should be greater than CitationDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     CitationDate>DueDate and CitationDate<>'1900-01-01' and DueDate<>'1900-01-01' and AgeStageID = 6  and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     CitationDate>DueDate and CitationDate<>'1900-01-01' and DueDate<>'1900-01-01' and AgeStageID = 6  and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in Citation Issued state and has DueDate BEFORE CitationDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 12
    ------------------------------------------------------------------------
   set @TestCaseID = '1.012'
   set @TestCaseDesc = 'Unassigned Txn count comparision btw EDW & RITE-Item90'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   ;with cte1 as(
   SELECT InvoiceNumber, sum(TxnCnt) edw_count from EDW_TRIPS.dbo.Fact_Invoice EDW where LEFT(CONVERT(VARCHAR, ZipCashDate, 112), 4) in (2019, 2020) group by InvoiceNumber
   EXCEPT -- 7289
   SELECT InvoiceNumber, sum(TxnCnt) rite_count  FROM edw_trips.Ref.RiteMigratedInvoice  where LEFT(CONVERT(VARCHAR, ZipCashDate, 112), 4) in (2019, 2020) group by InvoiceNumber  
   ) select @Count = count(*) from cte1
   
     
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  -  Unassigned Txn count difference between EDW & RITE-Item90 '
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 13
    -- if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice
    ------------------------------------------------------------------------
   set @TestCaseID = '1.013'
   set @TestCaseDesc = 'if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     DueDate<ThirdNoticeDate and AgeStageID = 4 and DueDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'    and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     DueDate<ThirdNoticeDate and AgeStageID = 4 and DueDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'    and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) DueDate shows BEFORE 3rd Notice Date when they are in 3rd Notice state'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 14
    -- if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice
    ------------------------------------------------------------------------
   set @TestCaseID = '1.014'
   set @TestCaseDesc = 'if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     DueDate<SecondNoticeDate and AgeStageID = 3  and DueDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01' 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     DueDate<SecondNoticeDate and AgeStageID = 3  and DueDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01' 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) DueDate shows BEFORE 2nd Notice Date when they are in 2nd Notice state'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 15
    -- ZipCashDate should not be defaulted to 1900-01-01 when the invoice is in "ZipCash" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.015'
   set @TestCaseDesc = 'ZipCashDate should not be defaulted to "1900-01-01" when the invoice is in "ZipCash" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select  @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ZipCashDate='1900-01-01' and AgeStageID >= 1 AND FIRSTNOTICEDATE >='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ZipCashDate='1900-01-01' and AgeStageID >= 1 AND FIRSTNOTICEDATE >='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) doesn''t have ZipCashDate when they are in ZipCash Stage.' 
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 16
    -- FirstNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "First Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.016'
   set @TestCaseDesc = 'FirstNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "First Notice of non-Payment" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FirstNoticeDate='1900-01-01' and AgeStageID = 2
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FirstNoticeDate='1900-01-01' and AgeStageID = 2
   
   set @InvoiceCount = @Count;    
   set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) doesn''t have FirstNoticeDate when they are in "First Notice of non-Payment" Stage.' 
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 17
    -- SecondNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Second Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.017'
   set @TestCaseDesc = 'SecondNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "Second Notice of non-Payment" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     SecondNoticeDate='1900-01-01' and AgeStageID = 3
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     SecondNoticeDate='1900-01-01' and AgeStageID = 3
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) doesn''t have SecondNoticeDate when they are in "Second Notice of non-Payment" Stage.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 18
    -- ThirdNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Third Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.018'
   set @TestCaseDesc = 'ThirdNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "Third Notice of non-Payment" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ThirdNoticeDate='1900-01-01' and AgeStageID = 4
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ThirdNoticeDate='1900-01-01' and AgeStageID = 4
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) doesn''t have ThirdNoticeDate when they are in "Third Notice of non-Payment" Stage.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 19
    -- LegalActionPendingDate should not be defaulted to 1900-01-01 when the invoice is in "Legal Action Pending" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.019'
   set @TestCaseDesc = 'LegalActionPendingDate should not be defaulted to "1900-01-01" when the invoice is in "Legal Action Pending" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     LegalActionPendingDate='1900-01-01' and AgeStageID = 5 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     LegalActionPendingDate='1900-01-01' and AgeStageID = 5 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) doesn''t have LegalActionPendingDate when they are in "Legal Action Pending" Stage.' 
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 20
    -- CitationDate should not be defaulted to 1900-01-01 when the invoice is in "Citation Issued" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '1.020'
   set @TestCaseDesc = 'CitationDate should not be defaulted to "1900-01-01" when the invoice is in "Citation Issued" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     CitationDate='1900-01-01' and AgeStageID = 6 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     CitationDate='1900-01-01' and AgeStageID = 6 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) doesn''t have CitationDate when they are in "Citation Issued" Stage.' 
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 21
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.021'
   set @TestCaseDesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99999 and (LastPaymentDate ='1900-01-01' or LastPaymentDate is null)   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99999 and (LastPaymentDate ='1900-01-01' or LastPaymentDate is null)   and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) doesn''t have LastPaymentDate when they are in "VTolled" Stage.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 22
    -- ThirdNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.022'
   set @TestCaseDesc = 'ThirdNoticeDate should be before LegalActionPendingDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ThirdNoticeDate >LegalActionPendingDate  and ThirdNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ThirdNoticeDate >LegalActionPendingDate  and ThirdNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ThirdNoticeDate AFTER LegalActionPendingDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 23
    -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.023'
   set @TestCaseDesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99998 and (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01')   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99998 and (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01')   and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) doesn''t have FirstPaymentDate when they are in "DismissedUnassigned" Stage'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 24
    -- SecondNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.024'
   set @TestCaseDesc = ' SecondNoticeDate should be before LegalActionPendingDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     SecondNoticeDate>LegalActionPendingDate and SecondNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     SecondNoticeDate>LegalActionPendingDate and SecondNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows SecondNoticeDate AFTER LegalActionPendingDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 25
    -- SecondNoticeDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.025'
   set @TestCaseDesc = ' SecondNoticeDate should be before CitationDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     SecondNoticeDate>CitationDate  and SecondNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     SecondNoticeDate>CitationDate  and SecondNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows SecondNoticeDate AFTER CitationDate' 
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 26
    -- SecondNoticeDate should be before ThirdNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.026'
   set @TestCaseDesc = ' SecondNoticeDate should be before ThirdNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     SecondNoticeDate>ThirdNoticeDate and SecondNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     SecondNoticeDate>ThirdNoticeDate and SecondNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows SecondNoticeDate AFTER ThirdNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 27
    -- FirstNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.027'
   set @TestCaseDesc = ' FirstNoticeDate should be before LegalActionPendingDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FirstNoticeDate>LegalActionPendingDate and FirstNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FirstNoticeDate>LegalActionPendingDate and FirstNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows FirstNoticeDate AFTER LegalActionPendingDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 28
    -- FirstNoticeDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.028'
   set @TestCaseDesc = ' FirstNoticeDate should be before CitationDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FirstNoticeDate>CitationDate  and FirstNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'  and ZipCashDate>='2019-01-01' 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FirstNoticeDate>CitationDate  and FirstNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'  and ZipCashDate>='2019-01-01' 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows FirstNoticeDate AFTER CitationDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 29
    -- FirstNoticeDate should be before ThirdNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.029'
   set @TestCaseDesc = ' FirstNoticeDate should be before ThirdNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FirstNoticeDate>ThirdNoticeDate and FirstNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'  and ZipCashDate>='2019-01-01' 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FirstNoticeDate>ThirdNoticeDate and FirstNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'  and ZipCashDate>='2019-01-01' 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows FirstNoticeDate AFTER ThirdNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   
   ------------------------------------------------------------------------
    -- TestCase# 30
    -- FirstNoticeDate should be before SecondNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.030'
   set @TestCaseDesc = ' FirstNoticeDate should be before SecondNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FirstNoticeDate>SecondNoticeDate and FirstNoticeDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'
   and ZipCashDate>='2019-01-01'
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FirstNoticeDate>SecondNoticeDate and FirstNoticeDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'
   and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows FirstNoticeDate AFTER SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 31
    -- ZipCashDate should be before DueDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.031'
   set @TestCaseDesc = ' ZipCashDate should be before DueDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ZipCashDate>DueDate  and ZipCashDate<>'1900-01-01' and DueDate<>'1900-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ZipCashDate>DueDate  and ZipCashDate<>'1900-01-01' and DueDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER DueDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 32
    -- ZipCashDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.032'
   set @TestCaseDesc = ' ZipCashDate should be before LegalActionPendingDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ZipCashDate>LegalActionPendingDate and ZipCashDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ZipCashDate>LegalActionPendingDate and ZipCashDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER LegalActionPendingDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
   -- TestCase# 33
   -- ZipCashDate should be before CitationDate
   ------------------------------------------------------------------------
   set @TestCaseID = '1.033'
   set @TestCaseDesc = ' ZipCashDate should be before CitationDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ZipCashDate>CitationDate and ZipCashDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ZipCashDate>CitationDate and ZipCashDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER CitationDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
   -- TestCase# 34
   -- ZipCashDate should be before ThirdNoticeDate
   ------------------------------------------------------------------------
   set @TestCaseID = '1.034'
   set @TestCaseDesc = ' ZipCashDate should be before ThirdNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ZipCashDate>ThirdNoticeDate and ZipCashDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ZipCashDate>ThirdNoticeDate and ZipCashDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER ThirdNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 35
    -- ZipCashDate should be before SecondNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.035'
   set @TestCaseDesc = ' ZipCashDate should be before SecondNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ZipCashDate>SecondNoticeDate and ZipCashDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ZipCashDate>SecondNoticeDate and ZipCashDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'   and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 36
    -- ZipCashDate should be before FirstNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '1.036'
   set @TestCaseDesc = ' ZipCashDate should be before FirstNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ZipCashDate>FirstNoticeDate and ZipCashDate<>'1900-01-01' and FirstNoticeDate<>'1900-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ZipCashDate>FirstNoticeDate and ZipCashDate<>'1900-01-01' and FirstNoticeDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
   -- TestCase# 37
   -- PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)
   ------------------------------------------------------------------------
   set @TestCaseID = '1.037'
   set @TestCaseDesc = 'PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     PaidAmount<>TollsPaid+FNfeesPaid+SNfeesPaid   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     PaidAmount<>TollsPaid+FNfeesPaid+SNfeesPaid   and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) PaidAmount is not matching with sum of TollsPaid,FNfeesPaid,SNfeesPaid' 
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

    ------------------------------------------------------------------------
    -- TestCase# 38
    -- AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)
    ------------------------------------------------------------------------
   set @TestCaseID = '1.038'
   set @TestCaseDesc = ' AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees
   
   set @InvoiceCount = @Count;    
   set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) AdjustedExpectedAmount is not matching with sum of AdjustedExpectedTolls,AdjustedExpectedFNfees,AdjustedExpectedSNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

    ------------------------------------------------------------------------
    -- TestCase# 39
    -- ExpectedAmount should be equal to (Tolls+FNfees+SNfees)
    ------------------------------------------------------------------------
   set @TestCaseID = '1.039'
   set @TestCaseDesc = ' ExpectedAmount should be equal to (Tolls+FNfees+SNfees)'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ExpectedAmount<>Tolls+FNfees+SNfees
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ExpectedAmount<>Tolls+FNfees+SNfees
   
   set @InvoiceCount = @Count;    
   set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) ExpectedAmount is not matching with sum of Tolls,FNfees,SNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

    ------------------------------------------------------------------------
    -- TestCase# 40
    -- AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)
    ------------------------------------------------------------------------
   set @TestCaseID = '1.040'
   set @TestCaseDesc = ' AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     AdjustedAmount<>TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     AdjustedAmount<>TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) AdjustedAmount is not matching with sum of TollsAdjusted,FNfeesAdjusted,SNfeesAdjusted'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

    ------------------------------------------------------------------------
    -- TestCase# 41
    -- OutstandingAmount should be equal to (AdjustedExpectedAmount-PaidAmount)
    ------------------------------------------------------------------------
   set @TestCaseID = '1.041'
   set @TestCaseDesc = 'outstandingAmount should be equal to AdjustedExpectedAmount-PaidAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     OutstandingAmount<>(AdjustedExpectedAmount-PaidAmount)  and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     OutstandingAmount<>(AdjustedExpectedAmount-PaidAmount)  and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    
   set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) outstandingAmount is not matching with sum of TollsAdjusted,FNfeesAdjusted,SNfeesAdjusted'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 42
    -- outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '1.042'
   set @TestCaseDesc = 'outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     (outstandingAmount+PaidAmount)<>(ExpectedAmount-AdjustedAmount)   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     (outstandingAmount+PaidAmount)<>(ExpectedAmount-AdjustedAmount)   and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    
   set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) outstandingAmount+PaidAmount  is not matching with ExpectedAmount-AdjustedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 43
    -- InvoiceAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.043'
   set @TestCaseDesc = 'InvoiceAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     InvoiceAmount is Null
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     InvoiceAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL InvoiceAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 44
    -- Tolls should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.044'
   set @TestCaseDesc = 'Tolls should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     Tolls is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     Tolls is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL Tolls'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

    ------------------------------------------------------------------------
    -- TestCase# 45
    -- FNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.045'
   set @TestCaseDesc = 'FNfees should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FNfees is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FNfees is Null
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL FNFees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 46
    -- SNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.046'
   set @TestCaseDesc = 'SNfees should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     SNfees is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     SNfees is Null
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL SNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 47
    -- ExpectedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.047'
   set @TestCaseDesc = 'ExpectedAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     ExpectedAmount is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     ExpectedAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - Invoices with NULL ExpectedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 48
    -- TollsAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.048'
   set @TestCaseDesc = 'TollsAdjusted should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     TollsAdjusted is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     TollsAdjusted is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - Invoices with NULL TollsAdjusted'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 49
    -- FNfeesAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.049'
   set @TestCaseDesc = 'FNfeesAdjusted should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FNfeesAdjusted is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FNfeesAdjusted is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - Invoices with NULL FNfeesAdjusted'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 50
    -- SNfeesAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.050'
   set @TestCaseDesc = 'SNfeesAdjusted should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     SNfeesAdjusted is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     SNfeesAdjusted is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - Invoices with NULL SNfeesAdjusted'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 51
    -- AdjustedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.051'
   set @TestCaseDesc = 'AdjustedAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     AdjustedAmount is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     AdjustedAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL AdjustedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 52
    -- TollsPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.052'
   set @TestCaseDesc = 'TollsPaid should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     TollsPaid is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     TollsPaid is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL TollsPaid'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 53
    -- FNfeesPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.053'
   set @TestCaseDesc = 'FNfeesPaid should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FNfeesPaid is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FNfeesPaid is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL FNfeesPaid'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

    ------------------------------------------------------------------------
    -- TestCase# 54
    -- SNfeesPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.054'
   set @TestCaseDesc = 'SNfeesPaid should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     SNfeesPaid is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     SNfeesPaid is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL SNfeesPaid'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 55
    -- PaidAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.055'
   set @TestCaseDesc = 'PaidAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     PaidAmount is Null
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     PaidAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL PaidAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 56
    -- AdjustedExpectedTolls should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.056'
   set @TestCaseDesc = 'AdjustedExpectedTolls should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     AdjustedExpectedTolls is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     AdjustedExpectedTolls is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL AdjustedExpectedTolls'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 57
    -- AdjustedExpectedFNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.057'
   set @TestCaseDesc = 'AdjustedExpectedFNfees should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     AdjustedExpectedFNfees is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     AdjustedExpectedFNfees is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL AdjustedExpectedFNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 58
    -- AdjustedExpectedSNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.058'
   set @TestCaseDesc = 'AdjustedExpectedSNfees should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     AdjustedExpectedSNfees is Null
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     AdjustedExpectedSNfees is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL AdjustedExpectedSNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 59
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.059'
   set @TestCaseDesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99998 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01') and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=99998 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01') and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in DismissedUnassigned state with a LastPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

  
   ------------------------------------------------------------------------
    -- TestCase# 60
    -- AdjustedExpectedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.060'
   set @TestCaseDesc = 'AdjustedExpectedAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     AdjustedExpectedAmount is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     AdjustedExpectedAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL AdjustedExpectedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 61
    -- TollOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.061'
   set @TestCaseDesc = 'TollOutStandingAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     TollOutStandingAmount is Null
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     TollOutStandingAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL TollOutStandingAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    ------------------------------------------------------------------------
    -- TestCase# 62
    -- FNfeesOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.062'
   set @TestCaseDesc = 'FNfeesOutStandingAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     FNfeesOutStandingAmount is Null
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     FNfeesOutStandingAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL FNfeesOutStandingAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
     ------------------------------------------------------------------------
    -- TestCase# 63
    -- SNfeesOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.063'
   set @TestCaseDesc = 'SNfeesOutStandingAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     SNfeesOutStandingAmount is Null
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     SNfeesOutStandingAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL SNfeesOutStandingAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   
   ------------------------------------------------------------------------
    -- TestCase# 64
    -- OutstandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '1.064'
   set @TestCaseDesc = 'OutstandingAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     OutstandingAmount is Null
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     OutstandingAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL OutstandingAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
      
    ------------------------------------------------------------------------
    -- TestCase# 65
    -- When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"
    ------------------------------------------------------------------------
   set @TestCaseID = '1.065'
   set @TestCaseDesc = 'When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND    EDW_invoicestatusID not in (4434,516,513,99998,99999) and AdjustedAmount=0 and PaidAmount=0 and outstandingAmount=ExpectedAmount and EDW_invoicestatusID<>4370
	select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND    EDW_invoicestatusID not in (4434,516,513,99998,99999) and AdjustedAmount=0 and PaidAmount=0 and outstandingAmount=ExpectedAmount and EDW_invoicestatusID<>4370
   
   set @InvoiceCount = @Count;    
   set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) NOT in "OPEN" even there is no Amount Paid/Adjusted and outstanding Amount is same is Expected Amount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 66
    -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.066'
   set @TestCaseDesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4434 and  (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01') and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4434 and  (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01') and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in "CLOSED" state and showing FirstPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 67
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.067'
   set @TestCaseDesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4434 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01')
   and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=4434 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01')
   and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in "CLOSED" state and showing LastPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	
   ------------------------------------------------------------------------
    -- TestCase# 68
    -- When CitationDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.068'
   set @TestCaseDesc = 'When valid CitationDate is populated then valid ZipCashDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND    CitationDate >'2019-01-01' and ZipCashDate<'1901-01-01'   
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND    CitationDate >'2019-01-01' and ZipCashDate<'1901-01-01'  
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing CitationDate without ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 69
    -- When CitationDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.069'
   set @TestCaseDesc = 'When valid CitationDate is populated then valid FirstNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   CitationDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   CitationDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing CitationDate without FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 70
    -- When CitationDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.070'
   set @TestCaseDesc = 'When valid CitationDate is populated then valid SecondNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   CitationDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   CitationDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing CitationDate without SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 71
    -- ValiDate no Fees for Zipcash Invoices
    ------------------------------------------------------------------------
   set @TestCaseID = '1.071'
   set @TestCaseDesc = 'ValiDate no Fees for Zipcash Invoices'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag=1 AND AgeStageID=1 AND (FNfees>0 OR SNfees>0) AND (FNfeesAdjusted=0 OR SNfeesAdjusted=0)
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND AgeStageID=1 AND (FNfees>0 OR SNfees>0) AND (FNfeesAdjusted=0 OR SNfeesAdjusted=0)
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing Fees for Zip'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)	
	------------------------------------------------------------------------
    -- TestCase# 72
    -- Valiate no SNfees for FN Invoices
    ------------------------------------------------------------------------
   set @TestCaseID = '1.072'
   set @TestCaseDesc = 'Valiate no SNfees for FN Invoices'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag=1 AND AgeStageID=2 AND  SNfees>0 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND AgeStageID=2 AND  SNfees>0 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - FN Invoices showing SNFees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 73
    -- When LegalActionPendingDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.073'
   set @TestCaseDesc = 'When valid LegalActionPendingDate is populated then valid ZipCashDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   LegalActionPendingDate >'2019-01-01' and ZipCashDate<'1901-01-01' 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   LegalActionPendingDate >'2019-01-01' and ZipCashDate<'1901-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has LegalActionPendingDate without ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 74
    -- When LegalActionPendingDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.074'
   set @TestCaseDesc = 'When valid LegalActionPendingDate is populated then valid FirstNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   LegalActionPendingDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   LegalActionPendingDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has LegalActionPendingDate without FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 75
    -- When LegalActionPendingDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.075'
   set @TestCaseDesc = 'When valid LegalActionPendingDate is populated then valid SecondNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   LegalActionPendingDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   LegalActionPendingDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has LegalActionPendingDate without SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 76
    -- When LegalActionPendingDate is populated then valid thirdNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.076'
   set @TestCaseDesc = 'When valid LegalActionPendingDate is populated then valid thirdNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   LegalActionPendingDate<>'1900-01-01' and thirdNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   LegalActionPendingDate<>'1900-01-01' and thirdNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has LegalActionPendingDate without thirdNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 77
    -- When thirdNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.077'
   set @TestCaseDesc = 'When valid thirdNoticeDate is populated then valid ZipCashDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   thirdNoticeDate>'2019-01-01' and ZipCashDate<'1901-01-01'
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   thirdNoticeDate>'2019-01-01' and ZipCashDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has thirdNoticeDate without ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 78
    -- When thirdNoticeDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.078'
   set @TestCaseDesc = 'When valid thirdNoticeDate is populated then valid FirstNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   thirdNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   thirdNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01' and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has thirdNoticeDate without FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 79
    -- When thirdNoticeDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.079'
   set @TestCaseDesc = 'When valid thirdNoticeDate is populated then valid SecondNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   thirdNoticeDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
    WHERE MigratedFlag=1 AND   thirdNoticeDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has thirdNoticeDate without SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 80
    -- When SecondNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.080'
   set @TestCaseDesc = 'When valid SecondNoticeDate is populated then valid ZipCashDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   SecondNoticeDate >'2019-01-01' and ZipCashDate<'1901-01-01'
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   SecondNoticeDate >'2019-01-01' and ZipCashDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has SecondNoticeDate without ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

      ------------------------------------------------------------------------
    -- TestCase# 81
    -- When SecondNoticeDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.081'
   set @TestCaseDesc = 'When valid SecondNoticeDate is populated then valid FirstNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   SecondNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   SELECT  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   SecondNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has SecondNoticeDate without FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    
    ------------------------------------------------------------------------
    -- TestCase# 82
    -- When FirstNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '1.082'
   set @TestCaseDesc = 'When valid FirstNoticeDate is populated then valid ZipCashDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND   FirstNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'  AND FIRSTNOTICEDATE >='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND   FirstNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'  AND FIRSTNOTICEDATE >='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has FirstNoticeDate without ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)  

   ------------------------------------------------------------------------
    -- TestCase# 83
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.083'
   set @TestCaseDesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=516 and FirstPaymentDate='1900-01-01'    and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=516 and FirstPaymentDate='1900-01-01'    and ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in Paid status without FirstPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 84
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.084'
   set @TestCaseDesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=516 and LastPaymentDate='1900-01-01'    and ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=516 and LastPaymentDate='1900-01-01'    and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in Paid status without LastPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 85
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.085'
   set @TestCaseDesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=515 and FirstPaymentDate='1900-01-01' 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=515 and FirstPaymentDate='1900-01-01' 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in PartialPaid status without FirstPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 86
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.086'
   set @TestCaseDesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=515 and LastPaymentDate='1900-01-01' 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND     EDW_invoicestatusID=515 and LastPaymentDate='1900-01-01' 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in PartialPaid status without LastPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)


	------------------------------------------------------------------------
    -- TestCase# 87
    -- Unassigned Invoices should not have PaidAmount.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.087'
   set @TestCaseDesc = 'Unassigned Invoices should not have PaidAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND    EDW_InvoiceStatusID=99998 AND PaidAmount>0
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND    EDW_InvoiceStatusID=99998 AND PaidAmount>0
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -UnAssigned Invoices withPaidAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)



	------------------------------------------------------------------------
    -- TestCase# 88
    -- Unknown Statuse Validation.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.088'
   set @TestCaseDesc = 'Unknown Status Validation.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag=1 AND  EDW_InvoiceStatusID=-1   AND zipcashDate>='2019-01-01' 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND  EDW_InvoiceStatusID=-1   AND zipcashDate>='2019-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in Unknown Status'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)



	------------------------------------------------------------------------
    -- TestCase# 89
    -- PartialPaid Invoices should have valid PaidAmount.
    ------------------------------------------------------------------------
   set @TestCaseID = '1.089'
   set @TestCaseDesc = 'PartialPaid Invoices should have valid PaidAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag=1 AND  EDW_InvoiceStatusID=515 AND PaidAmount<=0
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND  EDW_InvoiceStatusID=515 AND PaidAmount<=0
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  - PartialPad Invoices without PaidAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)



	------------------------------------------------------------------------
    -- TestCase# 90
    -- Paid Invoices - PaidAmount should match with AdjustedExpectedTolls
    ------------------------------------------------------------------------
   set @TestCaseID = '1.090'
   set @TestCaseDesc = 'Paid Invoices - PaidAmount should match with AdjustedExpectedTolls'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag=1 AND EDW_InvoiceStatusID=516  AND AdjustedExpectedTolls<>TollsPaid AND zipcashDate>='2019-01-01' 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND EDW_InvoiceStatusID=516  AND AdjustedExpectedTolls<>TollsPaid AND zipcashDate>='2019-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Paid Invoices AdjustedExpectedTolls not matching with TollsPaid'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 91
    -- AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '1.091'
   set @TestCaseDesc = 'AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag=1 AND  ZipCashDate>='2019-01-01' AND (ExpectedAmount-AdjustedAmount)<>AdjustedExpectedAmount
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND  ZipCashDate>='2019-01-01' AND (ExpectedAmount-AdjustedAmount)<>AdjustedExpectedAmount
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) AdjustedExpectedAmount not matching with ExpectedAmount-AdjustedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 92
    -- Closed Invoices should have valid PaidAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '1.092'
   set @TestCaseDesc = 'Closed Invoices should have valid PaidAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag=1 AND EDW_InvoiceStatusID= 4434 AND PaidAmount>0  AND ZipCashDate>='2019-01-01' 
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND EDW_InvoiceStatusID= 4434 AND PaidAmount>0  AND ZipCashDate>='2019-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Closed Invoices without PaidAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 93
    -- Unassigned Invoices should not have AdjustedExpectedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '1.093'
   set @TestCaseDesc = 'Unassigned Invoices should not have AdjustedExpectedAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag=1 AND EDW_InvoiceStatusID=99998 AND AdjustedExpectedAmount<>0 AND ZipCashDate>='2019-01-01'
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND EDW_InvoiceStatusID=99998 AND AdjustedExpectedAmount<>0 AND ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Unassigned Invoices with AdjustedExpectedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)


	------------------------------------------------------------------------
    -- TestCase# 94
    -- First Notice Adjustment Fees  should not be more than First Notice Fees
    ------------------------------------------------------------------------
   set @TestCaseID = '1.094'
   set @TestCaseDesc = 'First Notice Adjustment Fees  should not be more than First Notice Fees'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select  @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag=1 AND FNfeesAdjusted>FNfees
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND FNfeesAdjusted>FNfees
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) First Notice Adjustment Fees is more than First Notice Fees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 95
    -- Second Notice Adjustment Fees  should not be more than Second Notice Fees
    ------------------------------------------------------------------------
   set @TestCaseID = '1.095'
   set @TestCaseDesc = 'Second Notice Adjustment Fees  should not be more than Second Notice Fees'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select  @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag=1 AND SNfeesAdjusted>SNfees
   select  top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag=1 AND SNfeesAdjusted>SNfees
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) Second Notice Adjustment Fees is more than Second Notice Fees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 96
    -- Invoice ExpectedAmount should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.096'
   set @TestCaseDesc = 'Invoice ExpectedAmount should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND ExpectedAmount <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND ExpectedAmount <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows no ExpectedAmount'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 97
    -- InvoiceAmount should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.097'
   set @TestCaseDesc = 'InvoiceAmount should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND ExpectedAmount <= 0 and ZipCashDate>='2019-01-01'
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND ExpectedAmount <= 0 and ZipCashDate>='2019-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows no InvoiceAmount'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
   -- TestCase# 98
   -- Invoice Tolls should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.098'
   set @TestCaseDesc = 'Invoice Tolls should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND Tolls <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND Tolls <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows no Tolls'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
   -- TestCase# 99
   -- Invoice AVITollAmount should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.099'
   set @TestCaseDesc = 'Invoice AVITollAmount should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND AVITollAmount <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND AVITollAmount <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows no AVITollAmount'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 100
    -- Invoice PBMTollAmount should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.100'
   set @TestCaseDesc = 'Invoice PBMTollAmount should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND PBMTollAmount <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND PBMTollAmount <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows no PBMTollAmount'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 101
    -- Invoice txncnt should always be greater than 0
   ------------------------------------------------------------------------
   set @TestCaseID = '1.101'
   set @TestCaseDesc = 'Invoice txncnt should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND txncnt <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag=1 AND txncnt <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows no txncnt'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

--- NON-MIGRATED ----

   SET @DataCategory ='Non-Migrated'
    ------------------------------------------------------------------------
    -- TestCase# 1
    -- InvoiceNumber should be not null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.001'
   set @TestCaseDesc = 'InvoiceNumber should be not null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     InvoiceNumber is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     InvoiceNumber is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with InvoiceNumber NULL'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   

    ------------------------------------------------------------------------
    -- TestCase# 2
    ------------------------------------------------------------------------
   set @TestCaseID = '2.002'
   set @TestCaseDesc = 'InvoiceNumber should be unique'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   ;with cte1 as(
   select   InvoiceNumber,
            COUNT(*) X
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1   
   group by InvoiceNumber
   HAVING COUNT(*) > 1
   ) select @Count = count(*) from cte1
   
     
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  -  Duplicate InvoiceNumbers found.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

    ------------------------------------------------------------------------
    -- TestCase# 3
    ------------------------------------------------------------------------
   set @TestCaseID = '2.003'
   set @TestCaseDesc = 'CustomerID should Not be NULL'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

      select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     CustomerID is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     CustomerID is Null

   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing CustomerID as NULL'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end
   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   
 
   ------------------------------------------------------------------------
    -- TestCase# 4
    ------------------------------------------------------------------------
   set @TestCaseID = '2.004'
   set @TestCaseDesc = 'AdjustedExpectedAmount should be total of AdjustedExpectedTolls,AdjustedExpectedFNfees & AdjustedExpectedSNfees'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees
  
   SELECT   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees
  
   SET @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) having AdjustedExpectedAmount NOT equal to sum of AdjustedExpectedTolls,AdjustedExpectedFNfees & AdjustedExpectedSNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end
   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   

   ------------------------------------------------------------------------
    -- TestCase# 5
    -- AdjustedAmount and PaidAmount should be greater than 0 when Invoice is Paid
    ------------------------------------------------------------------------
   set @TestCaseID = '2.005'
   set @TestCaseDesc = 'AdjustedAmount and PaidAmount should be greater than 0 when Invoice is Paid'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusid =516 and AdjustedAmount=0 and PaidAmount=0
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusid =516 and AdjustedAmount=0 and PaidAmount=0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  -  Paid Invoice having No AdjustedAmount and PaidAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 6
    -- LastPaymentDate should be after the FirstPaymentDate.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.006'
   set @TestCaseDesc = 'LastPaymentDate should be after the FirstPaymentDate.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FirstPaymentDate>LastPaymentDate 
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FirstPaymentDate>LastPaymentDate 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) LastPaymentDate shows BEFORE FirstPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 7
    -- PBMTollAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.007'
   set @TestCaseDesc = 'PBMTollAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     PBMTollAmount is null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     PBMTollAmount is null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with PBMTollAmount as NULL'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 8
    -- AVITollAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.008'
   set @TestCaseDesc = 'AVITollAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     AVITollAmount is null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AVITollAmount is null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with AVITollAmount as NULL'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 9
    -- PremiumAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.009'
   set @TestCaseDesc = 'PremiumAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     PremiumAmount is null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     PremiumAmount is null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with PremiumAmount as NULL'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 10
    -- FirstNotice Fee should be less than SecondNotice Fee
    ------------------------------------------------------------------------
   set @TestCaseID = '2.010'
   set @TestCaseDesc = 'FirstNotice Fee should be less than SecondNotice Fee'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FNfees>SNfees and SNfees>0
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FNfees>SNfees and SNfees>0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has FirstNotice Fee more than SecondNotice Fee.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 11
    -- if the invoice is in Citation Issued then the DueDate should be greater than CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.011'
   set @TestCaseDesc = 'if the invoice is in Citation Issued then the DueDate should be greater than CitationDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     CitationDate>DueDate and CitationDate<>'1900-01-01' and DueDate<>'1900-01-01' and AgeStageID = 6
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     CitationDate>DueDate and CitationDate<>'1900-01-01' and DueDate<>'1900-01-01' and AgeStageID = 6
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in Citation Issued state and has DueDate BEFORE CitationDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 12
    -- if the invoice is in Legal Action Pending then the DueDate should be greater than LegalActionPendingDate
    ------------------------------------------------------------------------------------------------------------
   set @TestCaseID = '2.012'
   set @TestCaseDesc = 'if the invoice is in Legal Action Pending then the DueDate should be greater than LegalActionPendingDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     LegalActionPendingDate>DueDate and LegalActionPendingDate<>'1900-01-01' and DueDate<>'1900-01-01' and AgeStageID = 5
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     LegalActionPendingDate>DueDate and LegalActionPendingDate<>'1900-01-01' and DueDate<>'1900-01-01' and AgeStageID = 5
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) are in Legal Action Pending state and has DueDate BEFORE LegalActionPendingDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 13
    -- if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice
    ------------------------------------------------------------------------
   set @TestCaseID = '2.013'
   set @TestCaseDesc = 'if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     DueDate<ThirdNoticeDate and AgeStageID = 4 and DueDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01' 
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     DueDate<ThirdNoticeDate and AgeStageID = 4 and DueDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01' 
  
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - 3rd Notice state Invoices shows DueDate BEFORE 3rd Notice Date'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 14
    -- if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice
    ------------------------------------------------------------------------
   set @TestCaseID = '2.014'
   set @TestCaseDesc = 'if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     DueDate<SecondNoticeDate and AgeStageID = 3  and DueDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01' 
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     DueDate<SecondNoticeDate and AgeStageID = 3  and DueDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01' 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - 2nd Notice state Invoices shows DueDate BEFORE 2nd Notice Date'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 15
    -- ZipCashDate should not be defaulted to 1900-01-01 when the invoice is in "ZipCash" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.015'
   set @TestCaseDesc = 'ZipCashDate should not be defaulted to "1900-01-01" when the invoice is in "ZipCash" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ZipCashDate='1900-01-01' and AgeStageID >= 1
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ZipCashDate='1900-01-01' and AgeStageID >= 1
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -ZipCash Stage Invoices missing ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 16
    -- FirstNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "First Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.016'
   set @TestCaseDesc = 'FirstNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "First Notice of non-Payment" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FirstNoticeDate='1900-01-01' and AgeStageID = 2
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FirstNoticeDate='1900-01-01' and AgeStageID = 2
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - "First Notice of non-Payment" Stage Invoices missing FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 17
    -- SecondNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Second Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.017'
   set @TestCaseDesc = 'SecondNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "Second Notice of non-Payment" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     SecondNoticeDate='1900-01-01' and AgeStageID = 3
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     SecondNoticeDate='1900-01-01' and AgeStageID = 3
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - "Second Notice of non-Payment" Stage Invoices missing SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 18
    -- ThirdNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Third Notice of non-Payment" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.018'
   set @TestCaseDesc = 'ThirdNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "Third Notice of non-Payment" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ThirdNoticeDate='1900-01-01' and AgeStageID = 4
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ThirdNoticeDate='1900-01-01' and AgeStageID = 4
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - "Third Notice of non-Payment" Stage Invoices missing ThirdNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 19
    -- LegalActionPendingDate should not be defaulted to 1900-01-01 when the invoice is in "Legal Action Pending" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.019'
   set @TestCaseDesc = 'LegalActionPendingDate should not be defaulted to "1900-01-01" when the invoice is in "Legal Action Pending" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     LegalActionPendingDate='1900-01-01' and AgeStageID = 5 
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     LegalActionPendingDate='1900-01-01' and AgeStageID = 5 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - "Legal Action Pending" Stage Invoices missing LegalActionPendingDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 20
    -- CitationDate should not be defaulted to 1900-01-01 when the invoice is in "Citation Issued" Stage
    ------------------------------------------------------------------------
   set @TestCaseID = '2.020'
   set @TestCaseDesc = 'CitationDate should not be defaulted to "1900-01-01" when the invoice is in "Citation Issued" Stage'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     CitationDate='1900-01-01' and AgeStageID = 6 
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     CitationDate='1900-01-01' and AgeStageID = 6 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - "Citation Issued" Stage Invoices missing CitationDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 21
    -- CitationDate should be after LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.021'
   set @TestCaseDesc = ' CitationDate should be after LegalActionPendingDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     CitationDate < LegalActionPendingDate and CitationDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01' 
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     CitationDate < LegalActionPendingDate and CitationDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01' 
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows CitationDate BEFORE LegalActionPendingDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 22
    -- ThirdNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.022'
   set @TestCaseDesc = ' ThirdNoticeDate should be before LegalActionPendingDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ThirdNoticeDate >LegalActionPendingDate  and ThirdNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ThirdNoticeDate >LegalActionPendingDate  and ThirdNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ThirdNoticeDate AFTER LegalActionPendingDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 23
    -- ThirdNoticeDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.023'
   set @TestCaseDesc = ' ThirdNoticeDate should be before CitationDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ThirdNoticeDate >CitationDate  and ThirdNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   
      select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ThirdNoticeDate >CitationDate  and ThirdNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'

	set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ThirdNoticeDate AFTER CitationDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 24
    -- SecondNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.024'
   set @TestCaseDesc = ' SecondNoticeDate should be before LegalActionPendingDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     SecondNoticeDate>LegalActionPendingDate and SecondNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     SecondNoticeDate>LegalActionPendingDate and SecondNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows SecondNoticeDate AFTER LegalActionPendingDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 25
    -- SecondNoticeDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.025'
   set @TestCaseDesc = ' SecondNoticeDate should be before CitationDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     SecondNoticeDate>CitationDate  and SecondNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     SecondNoticeDate>CitationDate  and SecondNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows SecondNoticeDate AFTER CitationDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 26
    -- SecondNoticeDate should be before ThirdNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.026'
   set @TestCaseDesc = ' SecondNoticeDate should be before ThirdNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     SecondNoticeDate>ThirdNoticeDate and SecondNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     SecondNoticeDate>ThirdNoticeDate and SecondNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows SecondNoticeDate AFTER ThirdNoticeDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 27
    -- FirstNoticeDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.027'
   set @TestCaseDesc = ' FirstNoticeDate should be before LegalActionPendingDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>LegalActionPendingDate and FirstNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>LegalActionPendingDate and FirstNoticeDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows FirstNoticeDate AFTER LegalActionPendingDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 28
    -- FirstNoticeDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.028'
   set @TestCaseDesc = ' FirstNoticeDate should be before CitationDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>CitationDate  and FirstNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>CitationDate  and FirstNoticeDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows FirstNoticeDate AFTER CitationDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 29
    -- FirstNoticeDate should be before ThirdNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.029'
   set @TestCaseDesc = ' FirstNoticeDate should be before ThirdNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>ThirdNoticeDate and FirstNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>ThirdNoticeDate and FirstNoticeDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows FirstNoticeDate AFTER ThirdNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   
   ------------------------------------------------------------------------
    -- TestCase# 30
    -- FirstNoticeDate should be before SecondNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.030'
   set @TestCaseDesc = ' FirstNoticeDate should be before SecondNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>SecondNoticeDate and FirstNoticeDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FirstNoticeDate>SecondNoticeDate and FirstNoticeDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows FirstNoticeDate AFTER SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 31
    -- ZipCashDate should be before DueDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.031'
   set @TestCaseDesc = ' ZipCashDate should be before DueDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ZipCashDate>DueDate  and ZipCashDate<>'1900-01-01' and DueDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ZipCashDate>DueDate  and ZipCashDate<>'1900-01-01' and DueDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER DueDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 32
    -- ZipCashDate should be before LegalActionPendingDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.032'
   set @TestCaseDesc = ' ZipCashDate should be before LegalActionPendingDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ZipCashDate>LegalActionPendingDate and ZipCashDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ZipCashDate>LegalActionPendingDate and ZipCashDate<>'1900-01-01' and LegalActionPendingDate<>'1900-01-01'
      
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER LegalActionPendingDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 33
    -- ZipCashDate should be before CitationDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.033'
   set @TestCaseDesc = ' ZipCashDate should be before CitationDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ZipCashDate>CitationDate and ZipCashDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ZipCashDate>CitationDate and ZipCashDate<>'1900-01-01' and CitationDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER CitationDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 34
    -- ZipCashDate should be before ThirdNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.034'
   set @TestCaseDesc = ' ZipCashDate should be before ThirdNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ZipCashDate>ThirdNoticeDate and ZipCashDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ZipCashDate>ThirdNoticeDate and ZipCashDate<>'1900-01-01' and ThirdNoticeDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER ThirdNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 35
    -- ZipCashDate should be before SecondNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.035'
   set @TestCaseDesc = ' ZipCashDate should be before SecondNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ZipCashDate>SecondNoticeDate and ZipCashDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ZipCashDate>SecondNoticeDate and ZipCashDate<>'1900-01-01' and SecondNoticeDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 36
    -- ZipCashDate should be before FirstNoticeDate
    ------------------------------------------------------------------------
   set @TestCaseID = '2.036'
   set @TestCaseDesc = ' ZipCashDate should be before FirstNoticeDate'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ZipCashDate>FirstNoticeDate and ZipCashDate<>'1900-01-01' and FirstNoticeDate<>'1900-01-01'
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ZipCashDate>FirstNoticeDate and ZipCashDate<>'1900-01-01' and FirstNoticeDate<>'1900-01-01'
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows ZipCashDate AFTER FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   
	------------------------------------------------------------------------
    -- TestCase# 37
    -- PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)
    ------------------------------------------------------------------------
   set @TestCaseID = '2.037'
   set @TestCaseDesc = 'PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     PaidAmount<>TollsPaid+FNfeesPaid+SNfeesPaid
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     PaidAmount<>TollsPaid+FNfeesPaid+SNfeesPaid
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) PaidAmount is not matching with sum of TollsPaid,FNfeesPaid,SNfeesPaid' 
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 38
    -- AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)
    ------------------------------------------------------------------------
   set @TestCaseID = '2.038'
   set @TestCaseDesc = ' AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AdjustedExpectedAmount<>AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) AdjustedExpectedAmount is not matching with sum of AdjustedExpectedTolls,AdjustedExpectedFNfees,AdjustedExpectedSNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 39
    -- ExpectedAmount should be equal to (Tolls+FNfees+SNfees)
    ------------------------------------------------------------------------
   set @TestCaseID = '2.039'
   set @TestCaseDesc = ' ExpectedAmount should be equal to (Tolls+FNfees+SNfees)'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ExpectedAmount<>Tolls+FNfees+SNfees
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ExpectedAmount<>Tolls+FNfees+SNfees
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) ExpectedAmount is not matching with sum of Tolls,FNfees,SNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 40
    -- AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)
    ------------------------------------------------------------------------
   set @TestCaseID = '2.040'
   set @TestCaseDesc = ' AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     AdjustedAmount<>TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AdjustedAmount<>TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+  ' -Invoice(s) AdjustedAmount is not matching with sum of TollsAdjusted,FNfeesAdjusted,SNfeesAdjusted'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 41
    -- First Notice Adjustment Fees  should not be more than First Notice Fees
    ------------------------------------------------------------------------
   set @TestCaseID = '2.041'
   set @TestCaseDesc = 'First Notice Adjustment Fees  should not be more than First Notice Fees'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select  @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND FNfeesAdjusted>FNfees

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND FNfeesAdjusted>FNfees
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+' -Invoice(s) First Notice Adjustment Fees is more than First Notice Fees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 42
    -- outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '2.042'
   set @TestCaseDesc = 'outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     (outstandingAmount+PaidAmount)<>(ExpectedAmount-AdjustedAmount)
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     (outstandingAmount+PaidAmount)<>(ExpectedAmount-AdjustedAmount)
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) outstandingAmount+PaidAmount  is not matching with ExpectedAmount-AdjustedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 43
    -- InvoiceAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.043'
   set @TestCaseDesc = 'InvoiceAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     InvoiceAmount is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     InvoiceAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+  ' -Invoice(s) with NULL InvoiceAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 44
    -- Tolls should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.044'
   set @TestCaseDesc = 'Tolls should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     Tolls is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     Tolls is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+  ' -Invoice(s) with NULL Tolls'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 45
    -- FNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.045'
   set @TestCaseDesc = 'FNfees should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FNfees is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FNfees is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL FNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 46
    -- SNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.046'
   set @TestCaseDesc = 'SNfees should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     SNfees is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     SNfees is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL SNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 47
    -- ExpectedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.047'
   set @TestCaseDesc = 'ExpectedAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     ExpectedAmount is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     ExpectedAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL ExpectedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 48
    -- TollsAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.048'
   set @TestCaseDesc = 'TollsAdjusted should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     TollsAdjusted is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     TollsAdjusted is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL TollsAdjusted'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 49
    -- FNfeesAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.049'
   set @TestCaseDesc = 'FNfeesAdjusted should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FNfeesAdjusted is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FNfeesAdjusted is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL FNfeesAdjusted'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 50
    -- SNfeesAdjusted should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.050'
   set @TestCaseDesc = 'SNfeesAdjusted should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     SNfeesAdjusted is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     SNfeesAdjusted is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL SNfeesAdjusted'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 51
    -- AdjustedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.051'
   set @TestCaseDesc = 'AdjustedAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     AdjustedAmount is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AdjustedAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL AdjustedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 52
    -- TollsPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.052'
   set @TestCaseDesc = 'TollsPaid should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     TollsPaid is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     TollsPaid is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL TollsPaid'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 53
    -- FNfeesPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.053'
   set @TestCaseDesc = 'FNfeesPaid should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FNfeesPaid is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FNfeesPaid is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL FNfeesPaid'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 54
    -- SNfeesPaid should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.054'
   set @TestCaseDesc = 'SNfeesPaid should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     SNfeesPaid is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     SNfeesPaid is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL SNfeesPaid'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 55
    -- PaidAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.055'
   set @TestCaseDesc = 'PaidAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     PaidAmount is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     PaidAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL PaidAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 56
    -- AdjustedExpectedTolls should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.056'
   set @TestCaseDesc = 'AdjustedExpectedTolls should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     AdjustedExpectedTolls is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AdjustedExpectedTolls is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL AdjustedExpectedTolls'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 57
    -- AdjustedExpectedFNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.057'
   set @TestCaseDesc = 'AdjustedExpectedFNfees should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     AdjustedExpectedFNfees is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AdjustedExpectedFNfees is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL AdjustedExpectedFNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 58
    -- AdjustedExpectedSNfees should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.058'
   set @TestCaseDesc = 'AdjustedExpectedSNfees should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     AdjustedExpectedSNfees is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AdjustedExpectedSNfees is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL AdjustedExpectedSNfees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   ------------------------------------------------------------------------
    -- TestCase# 60
    -- AdjustedExpectedAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.060'
   set @TestCaseDesc = 'AdjustedExpectedAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     AdjustedExpectedAmount is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     AdjustedExpectedAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL AdjustedExpectedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 61
    -- TollOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.061'
   set @TestCaseDesc = 'TollOutStandingAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     TollOutStandingAmount is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     TollOutStandingAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' - Invoices with NULL TollOutStandingAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 62
    -- FNfeesOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.062'
   set @TestCaseDesc = 'FNfeesOutStandingAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     FNfeesOutStandingAmount is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     FNfeesOutStandingAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL FNfeesOutStandingAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
  ------------------------------------------------------------------------
    -- TestCase# 63
    -- SNfeesOutStandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.063'
   set @TestCaseDesc = 'SNfeesOutStandingAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     SNfeesOutStandingAmount is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     SNfeesOutStandingAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL SNfeesOutStandingAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   
   ------------------------------------------------------------------------
    -- TestCase# 64
    -- OutstandingAmount should not be null
    ------------------------------------------------------------------------
   set @TestCaseID = '2.064'
   set @TestCaseDesc = 'OutstandingAmount should not be null'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     OutstandingAmount is Null
   
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     OutstandingAmount is Null
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with NULL OutstandingAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
      
   ------------------------------------------------------------------------
    -- TestCase# 65
    -- When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"
    ------------------------------------------------------------------------
   set @TestCaseID = '2.065'
   set @TestCaseDesc = 'When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND    EDW_invoicestatusID not in (4434,516,513,99998,99999) and AdjustedAmount=0 and PaidAmount=0 and outstandingAmount=ExpectedAmount and EDW_invoicestatusID<>4370

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND    EDW_invoicestatusID not in (4434,516,513,99998,99999) and AdjustedAmount=0 and PaidAmount=0 and outstandingAmount=ExpectedAmount and EDW_invoicestatusID<>4370

   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) NOT in "OPEN" even there is no Amount Paid/Adjusted and outstanding Amount is same is Expected Amount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 66
    -- firstinvoiceid should be Not NULL when invoicestatus in (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status
    ------------------------------------------------------------------------
   set @TestCaseID = '2.066'
   set @TestCaseDesc = 'firstinvoiceid should Not be NULL when invoicestatus in (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND  EDW_invoicestatusID in(4370,4434,99998,99999) and firstinvoiceid is null    

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND  EDW_invoicestatusID in(4370,4434,99998,99999) and firstinvoiceid is null    

   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status having firstinvoiceid as NULL'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
   
   ------------------------------------------------------------------------
    -- TestCase# 67
    -- currentinvoiceid should be Not NULL when invoicestatus in (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status
    ------------------------------------------------------------------------
   set @TestCaseID = '2.067'
   set @TestCaseDesc = 'currentinvoiceid should Not be NULL when invoicestatus in (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND  EDW_invoicestatusID in(4370,4434,99998,99999) and currentinvoiceid is null    

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND  EDW_invoicestatusID in(4370,4434,99998,99999) and currentinvoiceid is null    

   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) with (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status having currentinvoiceid as NULL'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 68
    -- When CitationDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.068'
   set @TestCaseDesc = 'When valid CitationDate is populated then valid ZipCashDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND    CitationDate<>'1900-01-01' and ZipCashDate<'1901-01-01'   

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND    CitationDate<>'1900-01-01' and ZipCashDate<'1901-01-01'   
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing CitationDate without ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 69
    -- When CitationDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.069'
   set @TestCaseDesc = 'When valid CitationDate is populated then valid FirstNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   CitationDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   CitationDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'

   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+  ' -Invoice(s) showing CitationDate without FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 70
    -- When CitationDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.070'
   set @TestCaseDesc = 'When valid CitationDate is populated then valid SecondNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   CitationDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND   CitationDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'

   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing CitationDate without SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
    INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 71
    -- When CitationDate is populated then valid thirdNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.071'
   set @TestCaseDesc = 'When valid CitationDate is populated then valid thirdNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

	select   @Count = count(*)
	from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND   CitationDate<>'1900-01-01' and thirdNoticeDate<'1901-01-01'

	select   top 1 @SampleInvoiceNumber = InvoiceNumber
	from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   CitationDate<>'1900-01-01' and thirdNoticeDate<'1901-01-01'

	SET @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) showing CitationDate without thirdNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)


	------------------------------------------------------------------------
    -- TestCase# 72
    -- Second Notice Adjustment Fees  should not be more than Second Notice Fees
    ------------------------------------------------------------------------
   set @TestCaseID = '2.072'
   set @TestCaseDesc = 'Second Notice Adjustment Fees  should not be more than Second Notice Fees'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select  @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND SNfeesAdjusted>SNfees

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND SNfeesAdjusted>SNfees
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) Second Notice Adjustment Fees is more than Second Notice Fees'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
     
	------------------------------------------------------------------------
    -- TestCase# 73
    -- When LegalActionPendingDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.073'
   set @TestCaseDesc = 'When valid LegalActionPendingDate is populated then valid ZipCashDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and ZipCashDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and ZipCashDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has LegalActionPendingDate without ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 74
    -- When LegalActionPendingDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.074'
   set @TestCaseDesc = 'When valid LegalActionPendingDate is populated then valid FirstNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has LegalActionPendingDate without FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 75
    -- When LegalActionPendingDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.075'
   set @TestCaseDesc = 'When valid LegalActionPendingDate is populated then valid SecondNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has LegalActionPendingDate without SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	------------------------------------------------------------------------
    -- TestCase# 76
    -- When LegalActionPendingDate is populated then valid thirdNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.076'
   set @TestCaseDesc = 'When valid LegalActionPendingDate is populated then valid thirdNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and thirdNoticeDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   LegalActionPendingDate<>'1900-01-01' and thirdNoticeDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has LegalActionPendingDate without thirdNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 77
    -- When thirdNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.077'
   set @TestCaseDesc = 'When valid thirdNoticeDate is populated then valid ZipCashDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   thirdNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   thirdNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has thirdNoticeDate without ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 78
    -- When thirdNoticeDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.078'
   set @TestCaseDesc = 'When valid thirdNoticeDate is populated then valid FirstNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   thirdNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   thirdNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+' -Invoice(s) has thirdNoticeDate without FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 79
    -- When thirdNoticeDate is populated then valid SecondNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.079'
   set @TestCaseDesc = 'When valid thirdNoticeDate is populated then valid SecondNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   thirdNoticeDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   thirdNoticeDate<>'1900-01-01' and SecondNoticeDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+  ' -Invoice(s) has thirdNoticeDate without SecondNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

   ------------------------------------------------------------------------
    -- TestCase# 80
    -- When SecondNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.080'
   set @TestCaseDesc = 'When valid SecondNoticeDate is populated then valid ZipCashDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   SecondNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   SecondNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has SecondNoticeDate without ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

      ------------------------------------------------------------------------
    -- TestCase# 81
    -- When SecondNoticeDate is populated then valid FirstNoticeDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.081'
   set @TestCaseDesc = 'When valid SecondNoticeDate is populated then valid FirstNoticeDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   SecondNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   SecondNoticeDate<>'1900-01-01' and FirstNoticeDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has SecondNoticeDate without FirstNoticeDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
    
    ------------------------------------------------------------------------
    -- TestCase# 82
    -- When FirstNoticeDate is populated then valid ZipCashDate should be populated
    ------------------------------------------------------------------------
   set @TestCaseID = '2.082'
   set @TestCaseDesc = 'When valid FirstNoticeDate is populated then valid ZipCashDate should be populated'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND   FirstNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND   FirstNoticeDate<>'1900-01-01' and ZipCashDate<'1901-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) has FirstNoticeDate without ZipCashDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

   
   insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)  

	------------------------------------------------------------------------
    -- TestCase# 83
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.083'
   set @TestCaseDesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=516 and FirstPaymentDate='1900-01-01' 
   
      select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=516 and FirstPaymentDate='1900-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Paid Invoices without FirstPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 84
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.084'
   set @TestCaseDesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=516 and LastPaymentDate='1900-01-01' 
   
      select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=516 and LastPaymentDate='1900-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+  ' -Paid Invoices without LastPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 85
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.085'
   set @TestCaseDesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=515 and FirstPaymentDate='1900-01-01' 
   
      select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=515 and FirstPaymentDate='1900-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -PartialPaid Invoices without FirstPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 86
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.086'
   set @TestCaseDesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=515 and LastPaymentDate='1900-01-01' 
   
      select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=515 and LastPaymentDate='1900-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -PartialPaid Invoices without LastPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)


	------------------------------------------------------------------------
    -- TestCase# 87
    -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.087'
   set @TestCaseDesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4370 and FirstPaymentDate<>'1900-01-01' 
   
      select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4370 and FirstPaymentDate<>'1900-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+  ' -Invoice(s) showing FirstPaymentDate even the status is OPEN.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 88
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.088'
   set @TestCaseDesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4370 and LastPaymentDate<>'1900-01-01' 

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4370 and LastPaymentDate<>'1900-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  -OPEN Invoices showing LastPaymentDate'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 89
    -- FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.089'
   set @TestCaseDesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99999 and (FirstPaymentDate ='1900-01-01' or FirstPaymentDate is null)
   
      select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99999 and (FirstPaymentDate ='1900-01-01' or FirstPaymentDate is null)
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -VTolled  Invoices Doesn''t have FirstPaymentDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 90
    -- LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.090'
   set @TestCaseDesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99999 and (LastPaymentDate ='1900-01-01' or LastPaymentDate is null)
 
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99999 and (LastPaymentDate ='1900-01-01' or LastPaymentDate is null)
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -VTolled  Invoices Doesn''t have LastPaymentDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)


	------------------------------------------------------------------------
    -- TestCase# 91
    -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.091'
   set @TestCaseDesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99998 and (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01')

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99998 and (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01')
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -DismissedUnassigned  Invoices shows FirstPaymentDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 92
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.092'
   set @TestCaseDesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99998 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01')

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=99998 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01')
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  -DismissedUnassigned  Invoices shows LastPaymentDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 93
    -- FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.093'
   set @TestCaseDesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4434 and  (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01')

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4434 and  (ISNULL(FirstPaymentDate,'1900-01-01') <>'1900-01-01')
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  -CLOSED  Invoices shows FirstPaymentDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 94
    -- LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.094'
   set @TestCaseDesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4434 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01')

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND     EDW_invoicestatusID=4434 and (ISNULL(LastPaymentDate,'1900-01-01') <>'1900-01-01')
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  -CLOSED  Invoices shows LastPaymentDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	INSERT into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	
	------------------------------------------------------------------------
    -- TestCase# 95
    -- ValiDate no Fees for Zipcash Invoices
    ------------------------------------------------------------------------
   set @TestCaseID = '2.095'
   set @TestCaseDesc = 'ValiDate no Fees for Zipcash Invoices'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND AgeStageID=1 AND (FNfees>0 OR SNfees>0) AND (FNfeesAdjusted=0 OR SNfeesAdjusted=0)

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND AgeStageID=1 AND (FNfees>0 OR SNfees>0) AND (FNfeesAdjusted=0 OR SNfeesAdjusted=0)
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  -Zipcash  Invoices shows ValiDate.'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)	
	------------------------------------------------------------------------
    -- TestCase# 96
    -- Valiate no SNfees for FN Invoices
    ------------------------------------------------------------------------
   set @TestCaseID = '2.096'
   set @TestCaseDesc = 'Valiate no SNfees for FN Invoices'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND AgeStageID=2 AND  SNfees>0 

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND AgeStageID=2 AND  SNfees>0 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -FN Invoices shows SNfees.' 
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 97
    -- Unassigned Invoices should not have PaidAmount.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.097'
   set @TestCaseDesc = 'Unassigned Invoices should not have PaidAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND    EDW_InvoiceStatusID=99998 AND PaidAmount>0

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND    EDW_InvoiceStatusID=99998 AND PaidAmount>0
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Unassigned Invoices shows PaidAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)



	------------------------------------------------------------------------
    -- TestCase# 98
    -- Unknown Statuse Validation.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.098'
   set @TestCaseDesc = 'Unknown Status Validation.'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
   WHERE MigratedFlag<>1 AND  EDW_InvoiceStatusID=-1   AND zipcashDate>='2019-01-01' 
 
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND  EDW_InvoiceStatusID=-1   AND zipcashDate>='2019-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) shows Unknown Status'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)



	------------------------------------------------------------------------
    -- TestCase# 99
    -- PartialPaid Invoices should have valid PaidAmount.
    ------------------------------------------------------------------------
   set @TestCaseID = '2.099'
   set @TestCaseDesc = 'PartialPaid Invoices should have valid PaidAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND  EDW_InvoiceStatusID=515 AND PaidAmount<=0
 
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND  EDW_InvoiceStatusID=515 AND PaidAmount<=0
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  -PartialPaid Invoices doesn''t show PaidAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)



	------------------------------------------------------------------------
    -- TestCase# 100
    -- Paid Invoices - PaidAmount should match with AdjustedExpectedTolls
    ------------------------------------------------------------------------
   set @TestCaseID = '2.100'
   set @TestCaseDesc = 'Paid Invoices - PaidAmount should match with AdjustedExpectedTolls'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND EDW_InvoiceStatusID=516  AND AdjustedExpectedAmount<>PaidAmount AND zipcashDate>='2019-01-01' 
 
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
    WHERE MigratedFlag<>1 AND EDW_InvoiceStatusID=516  AND AdjustedExpectedAmount<>PaidAmount AND zipcashDate>='2019-01-01' 

   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Paid Invoices AdjustedExpectedTolls not matching with TollsPaid'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 101
    -- OutstandingAmount should be equal to AdjustedExpectedAmount-PaidAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '2.101'
   set @TestCaseDesc = 'OutstandingAmount should be equal to AdjustedExpectedAmount-PaidAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND  ZipCashDate>='2019-01-01' AND (AdjustedExpectedAmount-PaidAmount) <> OutstandingAmount
  
   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
     WHERE MigratedFlag<>1 AND  ZipCashDate>='2019-01-01' AND (AdjustedExpectedAmount-PaidAmount) <> OutstandingAmount
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+  ' -Invoice(s) outstandingAmount is not matching with sum of TollsAdjusted,FNfeesAdjusted,SNfeesAdjusted'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)



	------------------------------------------------------------------------
    -- TestCase# 102
    -- AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '2.102'
   set @TestCaseDesc = 'AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND  ZipCashDate>='2019-01-01' AND (ExpectedAmount-AdjustedAmount)<>AdjustedExpectedAmount
   
      select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
	WHERE MigratedFlag<>1 AND  ZipCashDate>='2019-01-01' AND (ExpectedAmount-AdjustedAmount)<>AdjustedExpectedAmount
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+' -Invoice(s) AdjustedExpectedAmount not matching with ExpectedAmount-AdjustedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 103
    -- Closed Invoices should have valid PaidAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '2.103'
   set @TestCaseDesc = 'Closed Invoices should have valid PaidAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND EDW_InvoiceStatusID= 4434 AND PaidAmount>0  AND ZipCashDate>='2019-01-01' 

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND EDW_InvoiceStatusID= 4434 AND PaidAmount>0  AND ZipCashDate>='2019-01-01' 
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  - Closed Invoices without PaidAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 104
    -- Unassigned Invoices should not have AdjustedExpectedAmount
    ------------------------------------------------------------------------
   set @TestCaseID = '2.104'
   set @TestCaseDesc = 'Unassigned Invoices should not have AdjustedExpectedAmount'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice 
	WHERE MigratedFlag<>1 AND EDW_InvoiceStatusID=99998 AND AdjustedExpectedAmount<>0 AND ZipCashDate>='2019-01-01'

   select   top 1 @SampleInvoiceNumber = InvoiceNumber
   from     edw_trips.dbo.Fact_Invoice
   WHERE MigratedFlag<>1 AND EDW_InvoiceStatusID=99998 AND AdjustedExpectedAmount<>0 AND ZipCashDate>='2019-01-01'
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ '  - Unassigned Invoices shows AdjustedExpectedAmount'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	
	------------------------------------------------------------------------
    -- TestCase# 105
    -- TxnCnt validation between Fact and Lnd tables
    ------------------------------------------------------------------------
	set @TestCaseID = '2.105'
	set @TestCaseDesc = 'TxnCnt validation between Fact and Lnd tables'
	set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

	select   @Count = count(*)
	from 
	(SELECT H.InvoiceNumber,COUNT(DISTINCT TpTripID) TxnCnt
	FROM LND_TBOS.TollPlus.Invoice_Header H WITH (NOLOCK)
                JOIN LND_TBOS.TollPlus.Invoice_LineItems L WITH (NOLOCK)
                    ON L.InvoiceID = H.InvoiceID
                JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT WITH (NOLOCK)
                    ON L.LinkID = VT.CitationID
                        AND L.LinkSourceName = 'TollPLUS.TP_VIOLATEDTRIPS'
        WHERE H.InvoiceDate>='2019-01-01'
        GROUP BY H.InvoiceNumber) lnd
	INNER Join
	(select InvoiceNumber,txncnt edw_TxnCnt from edw_trips.dbo.fact_invoice  where MigratedFlag<>1)edw
	ON edw.InvoiceNumber=LND.InvoiceNumber
	WHERE edw_txncnt<>lnd.txncnt;

	select   top 1 @SampleInvoiceNumber = edw.InvoiceNumber
	from   (SELECT H.InvoiceNumber,COUNT(DISTINCT TpTripID) TxnCnt
	FROM LND_TBOS.TollPlus.Invoice_Header H WITH (NOLOCK)
                JOIN LND_TBOS.TollPlus.Invoice_LineItems L WITH (NOLOCK)
                    ON L.InvoiceID = H.InvoiceID
                JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT WITH (NOLOCK)
                    ON L.LinkID = VT.CitationID
                        AND L.LinkSourceName = 'TollPLUS.TP_VIOLATEDTRIPS'
        WHERE H.InvoiceDate>='2019-01-01'
        GROUP BY H.InvoiceNumber) lnd
	INNER Join
	(select InvoiceNumber,txncnt edw_TxnCnt from edw_trips.dbo.fact_invoice  where MigratedFlag<>1)edw
	ON edw.InvoiceNumber=LND.InvoiceNumber
	WHERE edw_txncnt<>lnd.txncnt;  


   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ 'TxnCnt not matching between Fact and Lnd tables'
   
   if @Count > 0 
   begin
        set @TestStatus = 'Failed'
   end
   else
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	
	------------------------------------------------------------------------
    -- TestCase# 106
    -- Invoice ExpectedAmount should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.106'
   set @TestCaseDesc = 'Invoice ExpectedAmount should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND ExpectedAmount <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND ExpectedAmount <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) without ExpectedAmount'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 107
    -- Invoice InvoiceAmount should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.107'
   set @TestCaseDesc = 'InvoiceAmount should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND InvoiceAmount <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND InvoiceAmount <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) without InvoiceAmount'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 108
    -- Invoice Tolls should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.108'
   set @TestCaseDesc = 'Invoice Tolls should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND Tolls <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND Tolls <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) without Tolls'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 109
    -- Invoice AVITollAmount should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.109'
   set @TestCaseDesc = 'Invoice AVITollAmount should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND AVITollAmount <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND AVITollAmount <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) without AVITollAmount'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 110
    -- Invoice PBMTollAmount should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.110'
   set @TestCaseDesc = 'Invoice PBMTollAmount should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND PBMTollAmount <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND PBMTollAmount <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) without PBMTollAmount'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)

	------------------------------------------------------------------------
    -- TestCase# 111
    -- Invoice txncnt should always be greater than 0
	------------------------------------------------------------------------
   set @TestCaseID = '2.111'
   set @TestCaseDesc = 'Invoice txncnt should always be greater than 0'
   set @EDW_UpdateDate = CAST(SYSDateTIME() AS DATETIME2(3));  set @Count = NULL;  set @SampleInvoiceNumber = NULL

   select   @Count = count(*)
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND txncnt <= 0
   
   select  top 1 @SampleInvoiceNumber = InvoiceNumber 
   from     edw_trips.dbo.Fact_Invoice WHERE MigratedFlag<>1 AND txncnt <= 0
   
   set @InvoiceCount = @Count;    set @TestResultDesc = cast(@InvoiceCount as varchar)+ ' -Invoice(s) without txncnt'
   
   if @Count > 0 
   
   begin
        set @TestStatus = 'Failed'
   end
   else
   
   begin
        set @TestStatus = 'Passed' 
   end

	insert into Utility.Item90_TestResult values (@TestDate,@TestRunID,@TestCaseID,@TestCaseDesc,@TestResultDesc,@TestStatus,@InvoiceCount,@SampleInvoiceNumber,@DataCategory,@EDW_UpdateDate)
	
	

	EXEC Utility.ToLog @Log_Source, @Log_Start_Date,'Completed loading Utility.Item90_TestResult', 'I',NULL,NULL;


	-- Show results

		IF @Trace_Flag = 1  EXEC Utility.FromLog @Log_Source, @Log_Start_Date;
	
	END	TRY
	
	BEGIN CATCH
	
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH;

END


