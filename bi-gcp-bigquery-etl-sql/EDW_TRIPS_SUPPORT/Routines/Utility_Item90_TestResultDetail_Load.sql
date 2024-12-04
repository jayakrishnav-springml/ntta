CREATE OR REPLACE PROCEDURE `EDW_TRIPS_SUPPORT.Item90_TestResultDetail_Load`()
BEGIN
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
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS_SUPPORT.Item90_TestResultDetail_Load';
    DECLARE log_start_date DATETIME;
    DECLARE trace_flag INT64 DEFAULT 0; ## Testing
    BEGIN
      DECLARE testrunid INT64;
      DECLARE testcaseid STRING;
      DECLARE testcasedesc STRING;
      DECLARE testdate DATETIME;
      DECLARE edw_updatedate DATETIME;
      DECLARE log_message STRING;
      DECLARE row_count INT64;
      SET log_start_date = current_datetime();
      ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started EDW_TRIPS_SUPPORT.Item90_TestResultDetail_Load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      select log_source, log_start_date, 'Started EDW_TRIPS_SUPPORT.Item90_TestResultDetail_Load', 'I', CAST(NULL as INT64), CAST(NULL as STRING);
      ## Manually updated as follows
      SET (testdate,testrunid) =  (SELECT
          (max(testdate),
          max(testrunid)) 
          FROM
          EDW_TRIPS_SUPPORT.item90_testresult
          );
    ##- MIGRATED ####

    ########################################################################
    ## TestCase# 1
    ## InvoiceNumber should be not null
    ########################################################################
      SET testcaseid = '1.001';
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.invoicenumber IS NULL
      ;
    ########################################################################
    ## TestCase# 2
    ########################################################################
      SET testcaseid = '1.002';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            ct.invoicenumber,
            edw_updatedate
          FROM
            (
              SELECT
                  fact_invoice.invoicenumber,
                  count(*) AS x
                FROM
                  EDW_TRIPS.fact_invoice
                WHERE fact_invoice.migratedflag = 1
                GROUP BY 1
                HAVING count(*) > 1
            ) AS ct
      ;
    ########################################################################
    ## TestCase# 3
    ########################################################################
      SET testcaseid = '1.003';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.customerid IS NULL
      ;
    ########################################################################
    ## TestCase# 4
    ########################################################################
    
      SET testcaseid = '1.004';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      ;
    
    ########################################################################
    ## TestCase# 5
    ## AdjustedAmount and PaidAmount should be greater than 0 when Invoice is Paid
    ########################################################################

      SET testcaseid = '1.005';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 516
           AND fact_invoice.adjustedamount <= 0
           AND fact_invoice.paidamount <= 0
      ;

    ########################################################################
    ## TestCase# 6
    ## LastPaymentDate should be after the FirstPaymentDate.
    ########################################################################
      SET testcaseid = '1.006';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.firstpaymentdate > fact_invoice.lastpaymentdate
      ;
    ########################################################################
    ## TestCase# 7
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ########################################################################
      SET testcaseid = '1.007';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 4370
           AND fact_invoice.firstpaymentdate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 8
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ########################################################################
      SET testcaseid = '1.008';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 4370
           AND fact_invoice.lastpaymentdate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 9
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ########################################################################
      SET testcaseid = '1.009';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 99999
           AND (fact_invoice.firstpaymentdate = '1900-01-01'
           OR fact_invoice.firstpaymentdate IS NULL)
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 10
    ## FirstNotice Fee should be less than SecondNotice Fee
    ########################################################################
      SET testcaseid = '1.010';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.fnfees > fact_invoice.snfees
           AND fact_invoice.snfees > 0
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 11
    ## if the invoice is in Citation Issued then the DueDate should be greater than CitationDate
    ########################################################################
      SET testcaseid = '1.011';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.citationdate > fact_invoice.duedate
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.duedate <> '1900-01-01'
           AND fact_invoice.agestageid = 6
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 12
    ########################################################################

      SET testcaseid = '1.012';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            cte1.invoicenumber,
            edw_updatedate
          FROM
            (
              SELECT
                  edw.invoicenumber,
                  sum(edw.txncnt) AS edw_count
                FROM
                  EDW_TRIPS.fact_invoice AS edw
                WHERE CAST(left(CAST( edw.zipcashdate as STRING FORMAT 'yyyymmdd'), 4) as INT64) IN(
                  2019, 2020
                )
                GROUP BY 1
               EXCEPT DISTINCT SELECT
                  ritemigratedinvoice.invoicenumber,
                  sum(ritemigratedinvoice.txncnt) AS rite_count
                FROM
                  EDW_TRIPS_SUPPORT.ritemigratedinvoice
                WHERE CAST(left(CAST(ritemigratedinvoice.zipcashdate as STRING FORMAT 'yyyymmdd'), 4) as INT64) IN(
                  2019, 2020
                )
                GROUP BY 1
            ) AS cte1
      ;
    ########################################################################
    ## TestCase# 13
    ## if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice
    ########################################################################
      SET testcaseid = '1.013';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.duedate < fact_invoice.thirdnoticedate
           AND fact_invoice.agestageid = 4
           AND fact_invoice.duedate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 14
    ## if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice
    ########################################################################
      SET testcaseid = '1.014';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.duedate < fact_invoice.secondnoticedate
           AND fact_invoice.agestageid = 3
           AND fact_invoice.duedate <> '1900-01-01'
           AND fact_invoice.secondnoticedate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 15
    ## ZipCashDate should not be defaulted to 1900-01-01 when the invoice is in "ZipCash" Stage
    ########################################################################

      SET testcaseid = '1.015';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.zipcashdate = '1900-01-01'
           AND fact_invoice.agestageid >= 1
           AND fact_invoice.firstnoticedate >= '2019-01-01'
      ;

    ########################################################################
    ## TestCase# 16
    ## FirstNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "First Notice of non-Payment" Stage
    ########################################################################

      SET testcaseid = '1.016';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.firstnoticedate = '1900-01-01'
           AND fact_invoice.agestageid = 2
      ;

    ########################################################################
    ## TestCase# 17
    ## SecondNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Second Notice of non-Payment" Stage
    ########################################################################

      SET testcaseid = '1.017';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.secondnoticedate = '1900-01-01'
           AND fact_invoice.agestageid = 3
      ;
    ########################################################################
    ## TestCase# 18
    ## ThirdNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Third Notice of non-Payment" Stage
    ########################################################################

      SET testcaseid = '1.018';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.thirdnoticedate = '1900-01-01'
           AND fact_invoice.agestageid = 4
      ;
    ########################################################################
    ## TestCase# 19
    ## LegalActionPendingDate should not be defaulted to 1900-01-01 when the invoice is in "Legal Action Pending" Stage
    ########################################################################

      SET testcaseid = '1.019';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.legalactionpendingdate = '1900-01-01'
           AND fact_invoice.agestageid = 5
      ;

    ########################################################################
    ## TestCase# 20
    ## CitationDate should not be defaulted to 1900-01-01 when the invoice is in "Citation Issued" Stage
    ########################################################################

      SET testcaseid = '1.020';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.citationdate = '1900-01-01'
           AND fact_invoice.agestageid = 6
      ;
    ########################################################################
    ## TestCase# 21
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ########################################################################

      SET testcaseid = '1.021';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 99999
           AND (fact_invoice.lastpaymentdate = '1900-01-01'
           OR fact_invoice.lastpaymentdate IS NULL)
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 22
    ## ThirdNoticeDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '1.022';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.thirdnoticedate > fact_invoice.legalactionpendingdate
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 23
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ########################################################################

      SET testcaseid = '1.023';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 99998
           AND coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 24
    ## SecondNoticeDate should be before LegalActionPendingDate
    ########################################################################

      SET testcaseid = '1.024';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.secondnoticedate > fact_invoice.legalactionpendingdate
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 25
    ## SecondNoticeDate should be before CitationDate
    ########################################################################
      SET testcaseid = '1.025';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.secondnoticedate > fact_invoice.citationdate
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 26
    ## SecondNoticeDate should be before ThirdNoticeDate
    ########################################################################
      SET testcaseid = '1.026';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.secondnoticedate > fact_invoice.thirdnoticedate
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 27
    ## FirstNoticeDate should be before LegalActionPendingDate
    ########################################################################

      SET testcaseid = '1.027';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.firstnoticedate > fact_invoice.legalactionpendingdate
           AND fact_invoice.firstnoticedate <> '1900-01-01'
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 28
    ## FirstNoticeDate should be before CitationDate
    ########################################################################

      SET testcaseid = '1.028';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.firstnoticedate > fact_invoice.citationdate
           AND fact_invoice.firstnoticedate <> '1900-01-01'
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;

    ########################################################################
    ## TestCase# 29
    ## FirstNoticeDate should be before ThirdNoticeDate
    ########################################################################

      SET testcaseid = '1.029';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.firstnoticedate > fact_invoice.thirdnoticedate
           AND fact_invoice.firstnoticedate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 30
    ## FirstNoticeDate should be before SecondNoticeDate
    ########################################################################

      SET testcaseid = '1.030';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.firstnoticedate > fact_invoice.secondnoticedate
           AND fact_invoice.firstnoticedate <> '1900-01-01'
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 31
    ## ZipCashDate should be before DueDate
    ########################################################################

      SET testcaseid = '1.031';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.zipcashdate > fact_invoice.duedate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.duedate <> '1900-01-01'
      ;
    ########################################################################
    ## TestCase# 32
    ## ZipCashDate should be before LegalActionPendingDate
    ########################################################################

      SET testcaseid = '1.032';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.zipcashdate > fact_invoice.legalactionpendingdate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
   ## TestCase# 33
   ## ZipCashDate should be before CitationDate
   ########################################################################
      SET testcaseid = '1.033';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.zipcashdate > fact_invoice.citationdate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.citationdate <> '1900-01-01'
      ;
   ########################################################################
   ## TestCase# 34
   ## ZipCashDate should be before ThirdNoticeDate
   ########################################################################

      SET testcaseid = '1.034';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.zipcashdate > fact_invoice.thirdnoticedate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 35
    ## ZipCashDate should be before SecondNoticeDate
    ########################################################################

      SET testcaseid = '1.035';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.zipcashdate > fact_invoice.secondnoticedate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 36
    ## ZipCashDate should be before FirstNoticeDate
    ######################################################################## 
      SET testcaseid = '1.036';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.zipcashdate > fact_invoice.firstnoticedate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.firstnoticedate <> '1900-01-01'
      ;
    ########################################################################
   ## TestCase# 37
   ## PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)
   ########################################################################
      SET testcaseid = '1.037';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.paidamount <> fact_invoice.tollspaid + fact_invoice.fnfeespaid + fact_invoice.snfeespaid
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 38
    ## AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)
    ########################################################################
      SET testcaseid = '1.038';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      ;
      ########################################################################
    ## TestCase# 39
    ## ExpectedAmount should be equal to (Tolls+FNfees+SNfees)
    ########################################################################
      SET testcaseid = '1.039';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.expectedamount <> fact_invoice.tolls + fact_invoice.fnfees + fact_invoice.snfees
      ;
    ########################################################################
    ## TestCase# 40
    ## AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)
    ########################################################################

      SET testcaseid = '1.040';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.adjustedamount <> fact_invoice.tollsadjusted + fact_invoice.fnfeesadjusted + fact_invoice.snfeesadjusted
      ;

    ########################################################################
    ## TestCase# 41
    ## OutstandingAmount should be equal to (AdjustedExpectedAmount-PaidAmount)
    ########################################################################
      SET testcaseid = '1.041';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.outstandingamount <> (fact_invoice.adjustedexpectedamount - fact_invoice.paidamount)
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 42
    ## outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount
    ########################################################################

      SET testcaseid = '1.042';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND (fact_invoice.outstandingamount + fact_invoice.paidamount) <> (fact_invoice.expectedamount - fact_invoice.adjustedamount)
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
     ########################################################################
    ## TestCase# 43
    ## InvoiceAmount should not be null
    ########################################################################
      SET testcaseid = '1.043';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.invoiceamount IS NULL
      ;
     ########################################################################
    ## TestCase# 44
    ## Tolls should not be null
    ########################################################################

      SET testcaseid = '1.044';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.tolls IS NULL
      ;
    ########################################################################
    ## TestCase# 45
    ## FNfees should not be null
    ########################################################################

      SET testcaseid = '1.045';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.fnfees IS NULL
      ;

    ########################################################################
    ## TestCase# 46
    ## SNfees should not be null
    ########################################################################

      SET testcaseid = '1.046';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.snfees IS NULL
      ;
    ########################################################################
    ## TestCase# 47
    ## ExpectedAmount should not be null
    ########################################################################

      SET testcaseid = '1.047';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.expectedamount IS NULL
      ;
    ########################################################################
    ## TestCase# 48
    ## TollsAdjusted should not be null
    ########################################################################

      SET testcaseid = '1.048';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.tollsadjusted IS NULL
      ;

    ########################################################################
    ## TestCase# 49
    ## FNfeesAdjusted should not be null
    ########################################################################

      SET testcaseid = '1.049';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.fnfeesadjusted IS NULL
      ;
    ########################################################################
    ## TestCase# 50
    ## SNfeesAdjusted should not be null
    ########################################################################

      SET testcaseid = '1.050';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.snfeesadjusted IS NULL
      ;
    ########################################################################
    ## TestCase# 51
    ## AdjustedAmount should not be null
    ########################################################################

      SET testcaseid = '1.051';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.adjustedamount IS NULL
      ;
    ########################################################################
    ## TestCase# 52
    ## TollsPaid should not be null
    ########################################################################

      SET testcaseid = '1.052';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.tollspaid IS NULL
      ;
    ########################################################################
    ## TestCase# 53
    ## FNfeesPaid should not be null
    ########################################################################

      SET testcaseid = '1.053';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.fnfeespaid IS NULL
      ;
    ########################################################################
    ## TestCase# 54
    ## SNfeesPaid should not be null
    ########################################################################

      SET testcaseid = '1.054';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.snfeespaid IS NULL
      ;
    ########################################################################
    ## TestCase# 55
    ## PaidAmount should not be null
    ########################################################################

      SET testcaseid = '1.055';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.paidamount IS NULL
      ;
    ########################################################################
    ## TestCase# 56
    ## AdjustedExpectedTolls should not be null
    ########################################################################
      SET testcaseid = '1.056';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.adjustedexpectedtolls IS NULL
      ;
    ########################################################################
    ## TestCase# 57
    ## AdjustedExpectedFNfees should not be null
    ########################################################################
      SET testcaseid = '1.057';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.adjustedexpectedfnfees IS NULL
      ;
    ########################################################################
    ## TestCase# 58
    ## AdjustedExpectedSNfees should not be null
    ########################################################################

      SET testcaseid = '1.058';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.adjustedexpectedsnfees IS NULL
      ;
    ########################################################################
    ## TestCase# 59
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ########################################################################

      SET testcaseid = '1.059';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 99998
           AND (coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01')
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 60
    ## AdjustedExpectedAmount should not be null
    ########################################################################

      SET testcaseid = '1.060';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.adjustedexpectedamount IS NULL
      ;
    ########################################################################
    ## TestCase# 61
    ## TollOutStandingAmount should not be null
    ########################################################################

      SET testcaseid = '1.061';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.tolloutstandingamount IS NULL
      ;
    ########################################################################
    ## TestCase# 62
    ## FNfeesOutStandingAmount should not be null
    ########################################################################

      SET testcaseid = '1.062';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.fnfeesoutstandingamount IS NULL
      ;
    
     ########################################################################
    ## TestCase# 63
    ## SNfeesOutStandingAmount should not be null
    ########################################################################

      SET testcaseid = '1.063';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.snfeesoutstandingamount IS NULL
      ;
    
    ########################################################################
    ## TestCase# 64
    ## OutstandingAmount should not be null
    ########################################################################
      SET testcaseid = '1.064';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.outstandingamount IS NULL
      ;
    ########################################################################
    ## TestCase# 65
    ## When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"
    ########################################################################
      SET testcaseid = '1.065';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid NOT IN(
            4434, 516, 513, 99998, 99999
          )
           AND fact_invoice.adjustedamount = 0
           AND fact_invoice.paidamount = 0
           AND fact_invoice.outstandingamount = fact_invoice.expectedamount
           AND fact_invoice.edw_invoicestatusid <> 4370
      ;
    ########################################################################
    ## TestCase# 66
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ########################################################################

      SET testcaseid = '1.066';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 4434
           AND (coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01')
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 67
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ########################################################################
      SET testcaseid = '1.067';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 4434
           AND (coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01')
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 68
    ## When CitationDate is populated then valid ZipCashDate should be populated
    ########################################################################

      SET testcaseid = '1.068';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.citationdate > '2019-01-01'
           AND fact_invoice.zipcashdate < '1901-01-01'
      ;
    ########################################################################
    ## TestCase# 69
    ## When CitationDate is populated then valid FirstNoticeDate should be populated
    ########################################################################

      SET testcaseid = '1.069';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.firstnoticedate < '1901-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 70
    ## When CitationDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.070';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.secondnoticedate < '1901-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    	########################################################################
    ## TestCase# 71
    ## ValiDate no Fees for Zipcash Invoices
    ########################################################################
      SET testcaseid = '1.071';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.agestageid = 1
           AND (fact_invoice.fnfees > 0
           OR fact_invoice.snfees > 0)
           AND (fact_invoice.fnfeesadjusted = 0
           OR fact_invoice.snfeesadjusted = 0)
      ;
    ########################################################################
    ## TestCase# 72
    ## Valiate no SNfees for FN Invoices
    ########################################################################

      SET testcaseid = '1.072';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.agestageid = 2
           AND fact_invoice.snfees > 0
      ;
    ########################################################################
    ## TestCase# 73
    ## When LegalActionPendingDate is populated then valid ZipCashDate should be populated
    ########################################################################

      SET testcaseid = '1.073';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.legalactionpendingdate > '2019-01-01'
           AND fact_invoice.zipcashdate < '1901-01-01'
      ;
    ########################################################################
    ## TestCase# 74
    ## When LegalActionPendingDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.074';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.firstnoticedate < '1901-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 75
    ## When LegalActionPendingDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.075';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.secondnoticedate < '1901-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 76
    ## When LegalActionPendingDate is populated then valid thirdNoticeDate should be populated
    ########################################################################

      SET testcaseid = '1.076';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate < '1901-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 77
    ## When thirdNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '1.077';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.thirdnoticedate > '2019-01-01'
           AND fact_invoice.zipcashdate < '1901-01-01'
      ;
    
    ########################################################################
    ## TestCase# 78
    ## When thirdNoticeDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.078';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.firstnoticedate < '1901-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    
    ########################################################################
    ## TestCase# 79
    ## When thirdNoticeDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.079';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.secondnoticedate < '1901-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 80
    ## When SecondNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '1.080';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.secondnoticedate > '2019-01-01'
           AND fact_invoice.zipcashdate < '1901-01-01'
      ;
     ########################################################################
    ## TestCase# 81
    ## When SecondNoticeDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.081';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.firstnoticedate < '1901-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 82
    ## When FirstNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '1.082';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.firstnoticedate <> '1900-01-01'
           AND fact_invoice.zipcashdate < '1901-01-01'
           AND fact_invoice.firstnoticedate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 83
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ########################################################################
      SET testcaseid = '1.083';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 516
           AND fact_invoice.firstpaymentdate = '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;

    ########################################################################
    ## TestCase# 84
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ########################################################################
      SET testcaseid = '1.084';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 516
           AND fact_invoice.lastpaymentdate = '1900-01-01'
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 85
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ########################################################################
      SET testcaseid = '1.085';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 515
           AND fact_invoice.firstpaymentdate = '1900-01-01'
      ;
    ########################################################################
    ## TestCase# 86
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ########################################################################
      SET testcaseid = '1.086';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 515
           AND fact_invoice.lastpaymentdate = '1900-01-01'
      ;
    ########################################################################
    ## TestCase# 87
    ## Unassigned Invoices should not have PaidAmount.
    ########################################################################
      SET testcaseid = '1.087';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 99998
           AND fact_invoice.paidamount > 0
      ;
    
    ########################################################################
    ## TestCase# 88
    ## Unknown Statuse Validation.
    ########################################################################
      SET testcaseid = '1.088';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = -1
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 89
    ## PartialPaid Invoices should have valid PaidAmount.
    ########################################################################
      SET testcaseid = '1.089';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 515
           AND fact_invoice.paidamount <= 0
      ;
    ########################################################################
    ## TestCase# 90
    ## Paid Invoices - PaidAmount should match with AdjustedExpectedTolls
    ########################################################################
      SET testcaseid = '1.090';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 516
           AND fact_invoice.adjustedexpectedtolls <> fact_invoice.tollspaid
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;

    ########################################################################
    ## TestCase# 91
    ## AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount
    ########################################################################
      SET testcaseid = '1.091';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.zipcashdate >= '2019-01-01'
           AND (fact_invoice.expectedamount - fact_invoice.adjustedamount) <> fact_invoice.adjustedexpectedamount
      ;
    ########################################################################
    ## TestCase# 92
    ## Closed Invoices should have valid PaidAmount
    ########################################################################
      SET testcaseid = '1.092';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 4434
           AND fact_invoice.paidamount > 0
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 93
    ## Unassigned Invoices should not have AdjustedExpectedAmount
    ########################################################################
      SET testcaseid = '1.093';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.edw_invoicestatusid = 99998
           AND fact_invoice.adjustedexpectedamount <> 0
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 94
    ## First Notice Adjustment Fees  should not be more than First Notice Fees
    ########################################################################
      SET testcaseid = '1.094';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.fnfeesadjusted > fact_invoice.fnfees
      ;
    ########################################################################
    ## TestCase# 95
    ## Second Notice Adjustment Fees  should not be more than Second Notice Fees
    ########################################################################
      SET testcaseid = '1.095';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.snfeesadjusted > fact_invoice.snfees
      ;
    
     ########################################################################
    ## TestCase# 96
    ## Invoice ExpectedAmount should always be greater than 0
    ########################################################################
      SET testcaseid = '1.096';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.expectedamount <= 0
      ;
    
    ########################################################################
    ## TestCase# 97
    ## InvoiceAmount should always be greater than 0
    ########################################################################
      SET testcaseid = '1.097';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.expectedamount <= 0
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;
    ########################################################################
    ## TestCase# 98
    ## Invoice Tolls should always be greater than 0
    ########################################################################
      SET testcaseid = '1.098';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.tolls <= 0
      ;
    
    ########################################################################
    ## TestCase# 99
    ## Invoice AVITollAmount should always be greater than 0
    ########################################################################
      SET testcaseid = '1.099';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.avitollamount <= 0
      ;
    
    ########################################################################
    ## TestCase# 100
    ## Invoice PBMTollAmount should always be greater than 0
    ########################################################################
      SET testcaseid = '1.100';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.pbmtollamount <= 0
      ;

    ########################################################################
    ## TestCase# 101
    ## Invoice txncnt should always be greater than 0
    ########################################################################
      SET testcaseid = '1.101';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
           AND fact_invoice.txncnt <= 0
      ;

  ##- NON-MIGRATED ####

    ########################################################################
    ## InvoiceNumber should be not null
    ########################################################################
      SET testcaseid = '2.001';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.invoicenumber IS NULL
      ;
    ########################################################################
    ## TestCase# 2
    ########################################################################
      SET testcaseid = '2.002';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            ct.invoicenumber,
            edw_updatedate
          FROM
            (
              SELECT
                  fact_invoice.invoicenumber,
                  count(*) AS x
                FROM
                  EDW_TRIPS.fact_invoice
                WHERE fact_invoice.migratedflag <> 1
                GROUP BY 1
                HAVING count(*) > 1
            ) AS ct
      ;
    ########################################################################
    ## TestCase# 3
    ########################################################################
      SET testcaseid = '2.003';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.customerid IS NULL
      ;

    ########################################################################
    ## TestCase# 4
    ########################################################################
      SET testcaseid = '2.004';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      ;
    
    ########################################################################
    ## TestCase# 5
    ## AdjustedAmount and PaidAmount should be greater than 0 when Invoice is Paid
    ########################################################################
      SET testcaseid = '2.005';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 516
           AND fact_invoice.adjustedamount = 0
           AND fact_invoice.paidamount = 0
      ;

    ########################################################################
    ## TestCase# 6
    ## LastPaymentDate should be after the FirstPaymentDate.
    ########################################################################
      SET testcaseid = '2.006';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.firstpaymentdate > fact_invoice.lastpaymentdate
      ;
    ########################################################################
    ## TestCase# 7
    ## PBMTollAmount should not be null
    ########################################################################
      SET testcaseid = '2.007';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.pbmtollamount IS NULL
      ;
    
    ########################################################################
    ## TestCase# 8
    ## AVITollAmount should not be null
    ########################################################################
      SET testcaseid = '2.008';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.avitollamount IS NULL
      ;

    ########################################################################
    ## TestCase# 9
    ## PremiumAmount should not be null
    ########################################################################
      SET testcaseid = '2.009';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.premiumamount IS NULL
      ;

    ########################################################################
    ## TestCase# 10
    ## FirstNotice Fee should be less than SecondNotice Fee
    ########################################################################
      SET testcaseid = '2.010';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.fnfees > fact_invoice.snfees
           AND fact_invoice.snfees > 0
      ;

    ########################################################################
    ## TestCase# 11
    ## if the invoice is in Citation Issued then the DueDate should be greater than CitationDate
    ########################################################################
      SET testcaseid = '2.011';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.citationdate > fact_invoice.duedate
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.duedate <> '1900-01-01'
           AND fact_invoice.agestageid = 6
      ;
    ########################################################################
    ## TestCase# 12
    ## if the invoice is in Legal Action Pending then the DueDate should be greater than LegalActionPendingDate
    ############################################################################################################
      SET testcaseid = '2.012';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.legalactionpendingdate > fact_invoice.duedate
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.duedate <> '1900-01-01'
           AND fact_invoice.agestageid = 5
      ;
    ########################################################################
    ## TestCase# 13
    ## if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice
    ########################################################################
      SET testcaseid = '2.013';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.duedate < fact_invoice.thirdnoticedate
           AND fact_invoice.agestageid = 4
           AND fact_invoice.duedate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
      ;
    
    ########################################################################
    ## TestCase# 14
    ## if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice
    ########################################################################
      SET testcaseid = '2.014';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.duedate < fact_invoice.secondnoticedate
           AND fact_invoice.agestageid = 3
           AND fact_invoice.duedate <> '1900-01-01'
           AND fact_invoice.secondnoticedate <> '1900-01-01'
      ;
    
    ########################################################################
    ## TestCase# 15
    ## ZipCashDate should not be defaulted to 1900-01-01 when the invoice is in "ZipCash" Stage
    ########################################################################
      SET testcaseid = '2.015';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.zipcashdate = '1900-01-01'
           AND fact_invoice.agestageid >= 1
      ;

    ########################################################################
    ## TestCase# 16
    ## FirstNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "First Notice of non-Payment" Stage
    ########################################################################
      SET testcaseid = '2.016';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.firstnoticedate = '1900-01-01'
           AND fact_invoice.agestageid = 2
      ;

    ########################################################################
    ## TestCase# 17
    ## SecondNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Second Notice of non-Payment" Stage
    ########################################################################
      SET testcaseid = '2.017';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.secondnoticedate = '1900-01-01'
           AND fact_invoice.agestageid = 3
      ;

    ########################################################################
    ## TestCase# 18
    ## ThirdNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Third Notice of non-Payment" Stage
    ########################################################################
      SET testcaseid = '2.018';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.thirdnoticedate = '1900-01-01'
           AND fact_invoice.agestageid = 4
      ;

    ########################################################################
    ## TestCase# 19
    ## LegalActionPendingDate should not be defaulted to 1900-01-01 when the invoice is in "Legal Action Pending" Stage
    ########################################################################
      SET testcaseid = '2.019';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.legalactionpendingdate = '1900-01-01'
           AND fact_invoice.agestageid = 5
      ;
    
    ########################################################################
    ## TestCase# 20
    ## CitationDate should not be defaulted to 1900-01-01 when the invoice is in "Citation Issued" Stage
    ########################################################################
      SET testcaseid = '2.020';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.citationdate = '1900-01-01'
           AND fact_invoice.agestageid = 6
      ;

    ########################################################################
    ## TestCase# 21
    ## CitationDate should be after LegalActionPendingDate
    ########################################################################
      SET testcaseid = '2.021';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.citationdate < fact_invoice.legalactionpendingdate
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 22
    ## ThirdNoticeDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '2.022';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.thirdnoticedate > fact_invoice.legalactionpendingdate
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 23
    ## ThirdNoticeDate should be before CitationDate
    ########################################################################
      SET testcaseid = '2.023';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.thirdnoticedate > fact_invoice.citationdate
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.citationdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 24
    ## SecondNoticeDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '2.024';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.secondnoticedate > fact_invoice.legalactionpendingdate
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 25
    ## SecondNoticeDate should be before CitationDate
    ########################################################################
      SET testcaseid = '2.025';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.secondnoticedate > fact_invoice.citationdate
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.citationdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 26
    ## SecondNoticeDate should be before ThirdNoticeDate
    ########################################################################
      SET testcaseid = '2.026';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.secondnoticedate > fact_invoice.thirdnoticedate
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
      ;
    
    
	########################################################################
    ## TestCase# 27
    ## FirstNoticeDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '2.027';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.firstnoticedate > fact_invoice.legalactionpendingdate
           AND fact_invoice.firstnoticedate <> '1900-01-01'
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 28
    ## FirstNoticeDate should be before CitationDate
    ########################################################################
      SET testcaseid = '2.028';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.firstnoticedate > fact_invoice.citationdate
           AND fact_invoice.firstnoticedate <> '1900-01-01'
           AND fact_invoice.citationdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 29
    ## FirstNoticeDate should be before ThirdNoticeDate
    ########################################################################
      SET testcaseid = '2.029';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.firstnoticedate > fact_invoice.thirdnoticedate
           AND fact_invoice.firstnoticedate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 30
    ## FirstNoticeDate should be before SecondNoticeDate
    ########################################################################
      SET testcaseid = '2.030';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.firstnoticedate > fact_invoice.secondnoticedate
           AND fact_invoice.firstnoticedate <> '1900-01-01'
           AND fact_invoice.secondnoticedate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 31
    ## ZipCashDate should be before DueDate
    ########################################################################
      SET testcaseid = '2.031';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.zipcashdate > fact_invoice.duedate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.duedate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 32
    ## ZipCashDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '2.032';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.zipcashdate > fact_invoice.legalactionpendingdate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 33
    ## ZipCashDate should be before CitationDate
    ########################################################################
      SET testcaseid = '2.033';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.zipcashdate > fact_invoice.citationdate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.citationdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 34
    ## ZipCashDate should be before ThirdNoticeDate
    ########################################################################
      SET testcaseid = '2.034';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.zipcashdate > fact_invoice.thirdnoticedate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 35
    ## ZipCashDate should be before SecondNoticeDate
    ########################################################################
      SET testcaseid = '2.035';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.zipcashdate > fact_invoice.secondnoticedate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.secondnoticedate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 36
    ## ZipCashDate should be before FirstNoticeDate
    ########################################################################

      SET testcaseid = '2.036';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.zipcashdate > fact_invoice.firstnoticedate
           AND fact_invoice.zipcashdate <> '1900-01-01'
           AND fact_invoice.firstnoticedate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 37
    ## PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)
    ########################################################################
      SET testcaseid = '2.037';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.paidamount <> fact_invoice.tollspaid + fact_invoice.fnfeespaid + fact_invoice.snfeespaid
      ;

    ########################################################################
    ## TestCase# 38
    ## AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)
    ########################################################################
      SET testcaseid = '2.038';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      ;

    ########################################################################
    ## TestCase# 39
    ## ExpectedAmount should be equal to (Tolls+FNfees+SNfees)
    ########################################################################
      SET testcaseid = '2.039';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.expectedamount <> fact_invoice.tolls + fact_invoice.fnfees + fact_invoice.snfees
      ;

    ########################################################################
    ## TestCase# 40
    ## AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)
    ########################################################################
      SET testcaseid = '2.040';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.adjustedamount <> fact_invoice.tollsadjusted + fact_invoice.fnfeesadjusted + fact_invoice.snfeesadjusted
      ;

    ########################################################################
    ## TestCase# 41
    ## First Notice Adjustment Fees  should not be more than First Notice Fees
    ########################################################################
      SET testcaseid = '2.041';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.fnfeesadjusted > fact_invoice.fnfees
      ;

    ########################################################################
    ## TestCase# 42
    ## outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount
    ########################################################################
      SET testcaseid = '2.042';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND (fact_invoice.outstandingamount + fact_invoice.paidamount) <> (fact_invoice.expectedamount - fact_invoice.adjustedamount)
      ;

    ########################################################################
    ## TestCase# 43
    ## InvoiceAmount should not be null
    ########################################################################
      SET testcaseid = '2.043';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.invoiceamount IS NULL
      ;

    ########################################################################
    ## TestCase# 44
    ## Tolls should not be null
    ########################################################################
      SET testcaseid = '2.044';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.tolls IS NULL
      ;

    ########################################################################
    ## TestCase# 45
    ## FNfees should not be null
    ########################################################################
      SET testcaseid = '2.045';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.fnfees IS NULL
      ;

    ########################################################################
    ## TestCase# 46
    ## SNfees should not be null
    ########################################################################
      SET testcaseid = '2.046';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.snfees IS NULL
      ;

    ########################################################################
    ## TestCase# 47
    ## ExpectedAmount should not be null
    ########################################################################
      SET testcaseid = '2.047';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.expectedamount IS NULL
      ;
    
    ########################################################################
    ## TestCase# 48
    ## TollsAdjusted should not be null
    ########################################################################
      SET testcaseid = '2.048';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.tollsadjusted IS NULL
      ;

    ########################################################################
    ## TestCase# 49
    ## FNfeesAdjusted should not be null
    ########################################################################
      SET testcaseid = '2.049';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.fnfeesadjusted IS NULL
      ;

    ########################################################################
    ## TestCase# 50
    ## SNfeesAdjusted should not be null
    ########################################################################
      SET testcaseid = '2.050';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.snfeesadjusted IS NULL
      ;

    ########################################################################
    ## TestCase# 51
    ## AdjustedAmount should not be null
    ########################################################################
      SET testcaseid = '2.051';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.adjustedamount IS NULL
      ;

    ########################################################################
    ## TestCase# 52
    ## TollsPaid should not be null
    ########################################################################
      SET testcaseid = '2.052';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.tollspaid IS NULL
      ;

    ########################################################################
    ## TestCase# 53
    ## FNfeesPaid should not be null
    ########################################################################
      SET testcaseid = '2.053';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.fnfeespaid IS NULL
      ;

    ########################################################################
    ## TestCase# 54
    ## SNfeesPaid should not be null
    ########################################################################
      SET testcaseid = '2.054';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.snfeespaid IS NULL
      ;

    ########################################################################
    ## TestCase# 55
    ## PaidAmount should not be null
    ########################################################################
      SET testcaseid = '2.055';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.paidamount IS NULL
      ;

    ########################################################################
    ## TestCase# 56
    ## AdjustedExpectedTolls should not be null
    ########################################################################
      SET testcaseid = '2.056';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.adjustedexpectedtolls IS NULL
      ;

    ########################################################################
    ## TestCase# 57
    ## AdjustedExpectedFNfees should not be null
    ########################################################################
      SET testcaseid = '2.057';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.adjustedexpectedfnfees IS NULL
      ;

    ########################################################################
    ## TestCase# 58
    ## AdjustedExpectedSNfees should not be null
    ########################################################################
      SET testcaseid = '2.058';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.adjustedexpectedsnfees IS NULL
      ;

    ########################################################################
    ## TestCase# 60
    ## AdjustedExpectedAmount should not be null
    ########################################################################
      SET testcaseid = '2.060';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.adjustedexpectedamount IS NULL
      ;

    ########################################################################
    ## TestCase# 61
    ## TollOutStandingAmount should not be null
    ########################################################################
      SET testcaseid = '2.061';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.tolloutstandingamount IS NULL
      ;

    ########################################################################
    ## TestCase# 62
    ## FNfeesOutStandingAmount should not be null
    ########################################################################
      SET testcaseid = '2.062';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.fnfeesoutstandingamount IS NULL
      ;

    ########################################################################
    ## TestCase# 63
    ## SNfeesOutStandingAmount should not be null
    ########################################################################
      SET testcaseid = '2.063';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.snfeesoutstandingamount IS NULL
      ;

    ########################################################################
    ## TestCase# 64
    ## OutstandingAmount should not be null
    ########################################################################
      SET testcaseid = '2.064';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.outstandingamount IS NULL
      ;


    ########################################################################
    ## TestCase# 65
    ## When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"
    ########################################################################
      SET testcaseid = '2.065';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid NOT IN(
            4434, 516, 513, 99998, 99999
          )
           AND fact_invoice.adjustedamount = 0
           AND fact_invoice.paidamount = 0
           AND fact_invoice.outstandingamount = fact_invoice.expectedamount
           AND fact_invoice.edw_invoicestatusid <> 4370
      ;

    ########################################################################
    ## TestCase# 66
    ## firstinvoiceid should be Not NULL when invoicestatus in (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status
    ########################################################################
      SET testcaseid = '2.066';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid IN(
            4370, 4434, 99998, 99999
          )
           AND fact_invoice.firstinvoiceid IS NULL
      ;


    ########################################################################
    ## TestCase# 67
    ## currentinvoiceid should be Not NULL when invoicestatus in (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status
    ########################################################################
      SET testcaseid = '2.067';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid IN(
            4370, 4434, 99998, 99999
          )
           AND fact_invoice.currentinvoiceid IS NULL
      ;

    ########################################################################
    ## TestCase# 68
    ## When CitationDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '2.068';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.zipcashdate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 69
    ## When CitationDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.069';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.firstnoticedate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 70
    ## When CitationDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.070';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.secondnoticedate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 71
    ## When CitationDate is populated then valid thirdNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.071';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.citationdate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 72
    ## Second Notice Adjustment Fees  should not be more than Second Notice Fees
    ########################################################################
      SET testcaseid = '2.072';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.snfeesadjusted > fact_invoice.snfees
      ;

    ########################################################################
    ## TestCase# 73
    ## When LegalActionPendingDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '2.073';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.zipcashdate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 74
    ## When LegalActionPendingDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.074';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.firstnoticedate < '1901-01-01'
      ;
    
    ########################################################################
    ## TestCase# 75
    ## When LegalActionPendingDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.075';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.secondnoticedate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 76
    ## When LegalActionPendingDate is populated then valid thirdNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.076';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.legalactionpendingdate <> '1900-01-01'
           AND fact_invoice.thirdnoticedate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 77
    ## When thirdNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '2.077';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.zipcashdate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 78
    ## When thirdNoticeDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.078';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.firstnoticedate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 79
    ## When thirdNoticeDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.079';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.thirdnoticedate <> '1900-01-01'
           AND fact_invoice.secondnoticedate < '1901-01-01'
      ;

     ########################################################################
    ## TestCase# 80
    ## When SecondNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '2.080';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.zipcashdate < '1901-01-01'
      ;

      ########################################################################
    ## TestCase# 81
    ## When SecondNoticeDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.081';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.secondnoticedate <> '1900-01-01'
           AND fact_invoice.firstnoticedate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 82
    ## When FirstNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '2.082';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.firstnoticedate <> '1900-01-01'
           AND fact_invoice.zipcashdate < '1901-01-01'
      ;

    ########################################################################
    ## TestCase# 83
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ########################################################################
      SET testcaseid = '2.083';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 516
           AND fact_invoice.firstpaymentdate = '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 84
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ########################################################################
      SET testcaseid = '2.084';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 516
           AND fact_invoice.lastpaymentdate = '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 85
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ########################################################################
      SET testcaseid = '2.085';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 515
           AND fact_invoice.firstpaymentdate = '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 86
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ########################################################################
      SET testcaseid = '2.086';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 515
           AND fact_invoice.lastpaymentdate = '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 87
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ########################################################################
      SET testcaseid = '2.087';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 4370
           AND fact_invoice.firstpaymentdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 88
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ########################################################################
      SET testcaseid = '2.088';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 4370
           AND fact_invoice.lastpaymentdate <> '1900-01-01'
      ;

    ########################################################################
    ## TestCase# 89
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ########################################################################
      SET testcaseid = '2.089';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 99999
           AND (fact_invoice.firstpaymentdate = '1900-01-01'
           OR fact_invoice.firstpaymentdate IS NULL)
      ;

    ########################################################################
    ## TestCase# 90
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ########################################################################
      SET testcaseid = '2.090';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 99999
           AND (fact_invoice.lastpaymentdate = '1900-01-01'
           OR fact_invoice.lastpaymentdate IS NULL)
      ;

    ########################################################################
    ## TestCase# 91
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ########################################################################
      SET testcaseid = '2.091';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 99998
           AND (coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01')
      ;

    ########################################################################
    ## TestCase# 92
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ########################################################################
      SET testcaseid = '2.092';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 99998
           AND (coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01')
      ;

    ########################################################################
    ## TestCase# 93
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ########################################################################
      SET testcaseid = '2.093';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 4434
           AND (coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01')
      ;

    ########################################################################
    ## TestCase# 94
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ########################################################################
      SET testcaseid = '2.094';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 4434
           AND (coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01')
      ;
    
    ########################################################################
    ## TestCase# 95
    ## ValiDate no Fees for Zipcash Invoices
    ########################################################################
      SET testcaseid = '2.095';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.agestageid = 1
           AND (fact_invoice.fnfees > 0
           OR fact_invoice.snfees > 0)
           AND (fact_invoice.fnfeesadjusted = 0
           OR fact_invoice.snfeesadjusted = 0)
      ;

    ########################################################################
    ## TestCase# 96
    ## Valiate no SNfees for FN Invoices
    ########################################################################
      SET testcaseid = '2.096';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.agestageid = 2
           AND fact_invoice.snfees > 0
      ;

    ########################################################################
    ## TestCase# 97
    ## Unassigned Invoices should not have PaidAmount.
    ########################################################################
      SET testcaseid = '2.097';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 99998
           AND fact_invoice.paidamount > 0
      ;

    ########################################################################
    ## TestCase# 98
    ## Unknown Statuse Validation.
    ########################################################################
      SET testcaseid = '2.098';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = -1
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;

    ########################################################################
    ## TestCase# 99
    ## PartialPaid Invoices should have valid PaidAmount.
    ########################################################################
      SET testcaseid = '2.099';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 515
           AND fact_invoice.paidamount <= 0
      ;

    ########################################################################
    ## TestCase# 100
    ## Paid Invoices - PaidAmount should match with AdjustedExpectedTolls
    ########################################################################
      SET testcaseid = '2.100';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 516
           AND fact_invoice.adjustedexpectedamount <> fact_invoice.paidamount
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;

    ########################################################################
    ## TestCase# 101
    ## OutstandingAmount should be equal to AdjustedExpectedAmount-PaidAmount
    ########################################################################
      SET testcaseid = '2.101';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.zipcashdate >= '2019-01-01'
           AND (fact_invoice.adjustedexpectedamount - fact_invoice.paidamount) <> (fact_invoice.outstandingamount)
      ;

    ########################################################################
    ## TestCase# 102
    ## AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount
    ########################################################################
      SET testcaseid = '2.102';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.zipcashdate >= '2019-01-01'
           AND (fact_invoice.expectedamount - fact_invoice.adjustedamount) <> (fact_invoice.adjustedexpectedamount)
      ;

    ########################################################################
    ## TestCase# 103
    ## Closed Invoices should have valid PaidAmount
    ########################################################################
      SET testcaseid = '2.103';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 4434
           AND fact_invoice.paidamount > 0
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;

    ########################################################################
    ## TestCase# 104
    ## Unassigned Invoices should not have AdjustedExpectedAmount
    ########################################################################
      SET testcaseid = '2.104';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.edw_invoicestatusid = 99998
           AND fact_invoice.adjustedexpectedamount <> 0
           AND fact_invoice.zipcashdate >= '2019-01-01'
      ;


    /*
    ########################################################################
    ## TestCase# 105
    ## TxnCnt validation between Fact and Lnd tables
    ########################################################################
    SET testcaseid = '2.105';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            lnd.invoicenumber,
            edw_updatedate
          FROM
            (
              SELECT
                  h.invoicenumber,
                  count(DISTINCT tptripid) AS txncnt
                FROM
                  LND_TBOS.TollPlus_invoice_header AS h
                  INNER JOIN LND_TBOS.TollPlus_invoice_lineitems AS l ON l.invoiceid = h.invoiceid
                  INNER JOIN LND_TBOS.TollPlus_tp_violatedtrips AS vt ON l.linkid = vt.citationid
                   AND l.linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                WHERE h.invoicedate >= '2019-01-01'
                GROUP BY 1
            ) AS lnd
            INNER JOIN (
              SELECT
                  fact_invoice.invoicenumber,
                  fact_invoice.txncnt AS edw_txncnt
                FROM
                  dbo.fact_invoice
                WHERE fact_invoice.migratedflag <> 1
            ) AS edw ON edw.invoicenumber = lnd.invoicenumber
          WHERE edw.edw_txncnt <> lnd.txncnt
    */

    ########################################################################
    ## TestCase# 106
    ## Invoice ExpectedAmount should always be greater than 0
	  ########################################################################
    
      SET testcaseid = '2.106';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.expectedamount <= 0
      ;

      ########################################################################
    ## TestCase# 107
    ## Invoice InvoiceAmount should always be greater than 0
	  ########################################################################
      SET testcaseid = '2.107';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.invoiceamount <= 0
      ;

    ########################################################################
    ## TestCase# 108
    ## Invoice Tolls should always be greater than 0
	########################################################################
      SET testcaseid = '2.108';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.tolls <= 0
      ;

    ########################################################################
    ## TestCase# 109
    ## Invoice AVITollAmount should always be greater than 0
	  ########################################################################
      SET testcaseid = '2.109';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.avitollamount <= 0
      ;

    
    ########################################################################
    ## TestCase# 110
    ## Invoice PBMTollAmount should always be greater than 0
	  ########################################################################
      SET testcaseid = '2.110';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.pbmtollamount <= 0
      ;

    ########################################################################
    ## TestCase# 111
    ## Invoice txncnt should always be greater than 0
	  ########################################################################
      SET testcaseid = '2.111';
      SET edw_updatedate = current_datetime();
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresultdetail 
        SELECT
            testdate,
            testrunid,
            CAST (testcaseid AS NUMERIC),
            fact_invoice.invoicenumber,
            edw_updatedate
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
           AND fact_invoice.txncnt <= 0
      ;

      ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed Item90_TestResultDetail_Load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      select log_source, log_start_date, 'Completed Item90_TestResultDetail_Load', 'I', CAST(NULL as INT64), CAST(NULL as STRING);
      ########################################################################
      ## Updating TestCaseFailedFlag attribute in dbo.Fact_Invoice table
	    ########################################################################
      ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started Updating TestCaseFailedFlag column in dbo.Fact_Invoice table', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      select log_source, log_start_date, 'Started Updating TestCaseFailedFlag column in dbo.Fact_Invoice table', 'I', CAST(NULL as INT64), CAST(NULL as STRING);
      UPDATE EDW_TRIPS.fact_invoice SET testcasefailedflag = 1 WHERE fact_invoice.invoicenumber IN(
        SELECT DISTINCT
            invoicenumber
          FROM
            EDW_TRIPS_SUPPORT.item90_testresultdetail
          WHERE testrunid = testrunid
      );
      ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed Updating TestCaseFailedFlag column in dbo.Fact_Invoice table', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      select log_source, log_start_date, 'Completed Updating TestCaseFailedFlag column in dbo.Fact_Invoice table', 'I', CAST(NULL as INT64), CAST(NULL as STRING);
      
      ## Show results
      IF trace_flag = 1 THEN
        SELECT
            *
          FROM
            EDW_TRIPS_SUPPORT.item90_testresultdetail
          WHERE testrunid = testrunid
        ORDER BY
          CAST(testcaseid as NUMERIC)
        ;
        ## CALL EDW_TRIPS_SUPPORT.FromLog(log_source, substr(CAST(log_start_date as STRING), 1, 23));
        select log_source, substr(CAST(log_start_date as STRING), 1, 23);
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        select log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING);
        ## CALL EDW_TRIPS_SUPPORT.FromLog(log_source,  substr(CAST(log_start_date as STRING), 1, 23));
        select log_source,  substr(CAST(log_start_date as STRING), 1, 23);
        RAISE USING MESSAGE = error_message; ## Rethrow the error!
      END;
    END;
  END;