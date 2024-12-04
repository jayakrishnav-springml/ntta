CREATE OR REPLACE PROCEDURE `EDW_TRIPS_SUPPORT.Item90_TestResult_Load`()
BEGIN
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
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS_SUPPORT.Item90_TestResult_Load';
    DECLARE log_start_date DATETIME;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE testdate DATETIME;
      DECLARE testrunid INT64;
      DECLARE testcaseid STRING;
      DECLARE testcasedesc STRING;
      DECLARE testresultdesc STRING;
      DECLARE teststatus STRING;
      DECLARE count INT64;
      DECLARE invoicecount INT64;
      DECLARE sampleinvoicenumber INT64;
      DECLARE datacategory STRING;
      DECLARE edw_updatedate DATETIME;
      DECLARE log_message STRING;
      DECLARE row_count INT64;
      SET log_start_date = current_datetime();

      ## commenting EDW_TRIPS_SUPPORT.ToLog()
      ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started loading Utility.Item90_TestResult', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      SELECT log_source, log_start_date, 'Started loading Utility.Item90_TestResult', 'I';

    
      SET testrunid = (
        SELECT
            coalesce(max(testrunid) + 1, 1) AS __testrunid
          FROM
            EDW_TRIPS_SUPPORT.item90_testresult
      )
      ;
      SET testdate = current_datetime();

      ### MIGRATED ###

      SET datacategory = 'Migrated';
   
    #################################################################################
    ## TestCase# 1
    ## InvoiceNumber should be not null
    ################################################################################

      SET testcaseid = '1.001';
      SET testcasedesc = 'InvoiceNumber should not be NULL';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
          AND fact_invoice.invoicenumber IS NULL
      )
      ;
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
          AND fact_invoice.invoicenumber IS NULL
        LIMIT 1
      )
      ;
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with InvoiceNumber as NULL');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ####################################################################################################################################
    ## TestCase# 2
    ####################################################################################################################################

      SET testcaseid = '1.002';
      SET testcasedesc = 'InvoiceNumber should be unique';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      CREATE TEMPORARY TABLE cte1 AS (
        SELECT
            fact_invoice.invoicenumber,
            count(*) AS x
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
          GROUP BY 1
          HAVING count(*) > 1
      );
      SET count = (
        SELECT
            count(*) AS __count
          FROM
            cte1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with Duplicate InvoiceNumbers.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 3
    ########################################################################

      SET testcaseid = '1.003';
      SET testcasedesc = 'CustomerID should Not be NULL';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
          SELECT
            count(*) AS __count
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
          AND fact_invoice.customerid IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag = 1
          AND fact_invoice.customerid IS NULL
        LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing CustomerID as NULL');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 4
    ########################################################################
      SET testcaseid = '1.004';
      SET testcasedesc = 'AdjustedExpectedAmount should be total of AdjustedExpectedTolls,AdjustedExpectedFNfees & AdjustedExpectedSNfees';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      
      SET count = (
        SELECT
            count(*) AS __count
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
        LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) having AdjustedExpectedAmount NOT equal to sum of AdjustedExpectedTolls,AdjustedExpectedFNfees & AdjustedExpectedSNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 5
    ## AdjustedAmount and PaidAmount should be greater than 0 when Invoice is Paid
    ########################################################################
      SET testcaseid = '1.005';
      SET testcasedesc = 'When Invoice is in Paid State, AdjustedAmount & PaidAmount should be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.adjustedamount <= 0
         AND fact_invoice.paidamount <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.adjustedamount <= 0
         AND fact_invoice.paidamount <= 0
        LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are showing AdjustedAmount & PaidAmount as 0 even the status is PAID');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 6
    ## LastPaymentDate should be after the FirstPaymentDate.
    ########################################################################
      SET testcaseid = '1.006';
      SET testcasedesc = 'FirstPaymentDate should be BEFORE LastPaymentDate.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstpaymentdate > fact_invoice.lastpaymentdate
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstpaymentdate > fact_invoice.lastpaymentdate
        LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows FirstPaymentDate AFTER LastPaymentDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 7
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ########################################################################
      SET testcaseid = '1.007';
      SET testcasedesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 4370
         AND fact_invoice.firstpaymentdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 4370
         AND fact_invoice.firstpaymentdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
        LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing FirstPaymentDate even the status is OPEN.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 8
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ########################################################################
      SET testcaseid = '1.008';
      SET testcasedesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 4370
         AND fact_invoice.lastpaymentdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 4370
         AND fact_invoice.lastpaymentdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
        LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing LastPaymentDate even the status is OPEN.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 9
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ########################################################################
      SET testcaseid = '1.009';
      SET testcasedesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99999
         AND (fact_invoice.firstpaymentdate = '1900-01-01'
         OR fact_invoice.firstpaymentdate IS NULL)
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99999
         AND (fact_invoice.firstpaymentdate = '1900-01-01'
         OR fact_invoice.firstpaymentdate IS NULL)
         AND fact_invoice.zipcashdate >= '2019-01-01'
        LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) Doesn"t have FirstPaymentDate even the status is VTolled.');

      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 10
    ## FirstNotice Fee should be less than SecondNotice Fee
    ########################################################################
    
      SET testcaseid = '1.010';
      SET testcasedesc = 'FirstNotice Fee should be less than SecondNotice Fee';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfees > fact_invoice.snfees
         AND fact_invoice.snfees > 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfees > fact_invoice.snfees
         AND fact_invoice.snfees > 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has FirstNotice Fee more than SecondNotice Fee.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 11
    ## if the invoice is in Citation Issued then the DueDate should be greater than CitationDate
    ########################################################################

      SET testcaseid = '1.011';
      SET testcasedesc = 'if the invoice is in Citation Issued then the DueDate should be greater than CitationDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.citationdate > fact_invoice.duedate
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.agestageid = 6
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.citationdate > fact_invoice.duedate
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.agestageid = 6
         AND fact_invoice.zipcashdate >= '2019-01-01'
        LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in Citation Issued state and has DueDate BEFORE CitationDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 12
    ########################################################################
      SET testcaseid = '1.012';
      SET testcasedesc = 'Unassigned Txn count comparision btw EDW & RITE-Item90';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      CREATE TEMPORARY TABLE cte2 AS (
        SELECT
            edw.invoicenumber,
            sum(edw.txncnt) AS edw_count
          FROM
            EDW_TRIPS.fact_invoice AS edw
          WHERE CAST(left(CAST(edw.zipcashdate as STRING  FORMAT 'yyyymmdd'), 4) as INT64) IN(
            2019, 2020
          )
          GROUP BY 1
         EXCEPT ## 7289
         DISTINCT SELECT
            ritemigratedinvoice.invoicenumber,
            sum(ritemigratedinvoice.txncnt) AS rite_count
          FROM
            EDW_TRIPS_SUPPORT.ritemigratedinvoice
          WHERE CAST(left(CAST( ritemigratedinvoice.zipcashdate as STRING  FORMAT 'yyyymmdd'), 4) as INT64) IN(
            2019, 2020
          )
          GROUP BY 1
      );
      SET count = (
        SELECT
            count(*) AS __count
        FROM
          cte2
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  -  Unassigned Txn count difference between EDW & RITE-Item90 ');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 13
    ## if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice
    ########################################################################
    
      SET testcaseid = '1.013';
      SET testcasedesc = 'if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.duedate < fact_invoice.thirdnoticedate
         AND fact_invoice.agestageid = 4
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.duedate < fact_invoice.thirdnoticedate
         AND fact_invoice.agestageid = 4
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) DueDate shows BEFORE 3rd Notice Date when they are in 3rd Notice state');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 14
    ## if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice
    ########################################################################
      SET testcaseid = '1.014';
      SET testcasedesc = 'if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.duedate < fact_invoice.secondnoticedate
         AND fact_invoice.agestageid = 3
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.duedate < fact_invoice.secondnoticedate
         AND fact_invoice.agestageid = 3
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) DueDate shows BEFORE 2nd Notice Date when they are in 2nd Notice state');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 15
    ## ZipCashDate should not be defaulted to 1900-01-01 when the invoice is in "ZipCash" Stage
    ########################################################################
      SET testcaseid = '1.015';
      SET testcasedesc = 'ZipCashDate should not be defaulted to "1900-01-01" when the invoice is in "ZipCash" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate = '1900-01-01'
         AND fact_invoice.agestageid >= 1
         AND fact_invoice.firstnoticedate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate = '1900-01-01'
         AND fact_invoice.agestageid >= 1
         AND fact_invoice.firstnoticedate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) doesnt have ZipCashDate when they are in ZipCash Stage.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 16
    ## FirstNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "First Notice of non-Payment" Stage
    ######################################################################## 
      SET testcaseid = '1.016';
      SET testcasedesc = 'FirstNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "First Notice of non-Payment" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 2
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 2
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) doesnt have FirstNoticeDate when they are in "First Notice of non-Payment" Stage.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 17
    ## SecondNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Second Notice of non-Payment" Stage
    ########################################################################
      SET testcaseid = '1.017';
      SET testcasedesc = 'SecondNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "Second Notice of non-Payment" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 3
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 3
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) doesnt have SecondNoticeDate when they are in "Second Notice of non-Payment" Stage.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;


    ########################################################################
    ## TestCase# 18
    ## ThirdNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Third Notice of non-Payment" Stage
    ########################################################################
      SET testcaseid = '1.018';
      SET testcasedesc = 'ThirdNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "Third Notice of non-Payment" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.thirdnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 4
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.thirdnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 4
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) doesnt have ThirdNoticeDate when they are in "Third Notice of non-Payment" Stage.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 19
    ## LegalActionPendingDate should not be defaulted to 1900-01-01 when the invoice is in "Legal Action Pending" Stage
    ########################################################################
      SET testcaseid = '1.019';
      SET testcasedesc = 'LegalActionPendingDate should not be defaulted to "1900-01-01" when the invoice is in "Legal Action Pending" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.legalactionpendingdate = '1900-01-01'
         AND fact_invoice.agestageid = 5
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.legalactionpendingdate = '1900-01-01'
         AND fact_invoice.agestageid = 5
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) doesnt have LegalActionPendingDate when they are in "Legal Action Pending" Stage.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 20
    ## CitationDate should not be defaulted to 1900-01-01 when the invoice is in "Citation Issued" Stage
    ########################################################################
      SET testcaseid = '1.020';
      SET testcasedesc = 'CitationDate should not be defaulted to "1900-01-01" when the invoice is in "Citation Issued" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.citationdate = '1900-01-01'
         AND fact_invoice.agestageid = 6
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.citationdate = '1900-01-01'
         AND fact_invoice.agestageid = 6
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) doesnt have CitationDate when they are in "Citation Issued" Stage.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 21
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ########################################################################
      SET testcaseid = '1.021';
      SET testcasedesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99999
         AND (fact_invoice.lastpaymentdate = '1900-01-01'
         OR fact_invoice.lastpaymentdate IS NULL)
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99999
         AND (fact_invoice.lastpaymentdate = '1900-01-01'
         OR fact_invoice.lastpaymentdate IS NULL)
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) doesnt have LastPaymentDate when they are in "VTolled" Stage.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 22
    ## ThirdNoticeDate should be before LegalActionPendingDate
    ########################################################################
    
      SET testcaseid = '1.022';
      SET testcasedesc = 'ThirdNoticeDate should be before LegalActionPendingDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.thirdnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.thirdnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ThirdNoticeDate AFTER LegalActionPendingDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 23
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ########################################################################
      SET testcaseid = '1.023';
      SET testcasedesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND (coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01')
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND (coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01')
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) doesnt have FirstPaymentDate when they are in "DismissedUnassigned" Stage');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 24
    ## SecondNoticeDate should be before LegalActionPendingDate
    ########################################################################
    
      SET testcaseid = '1.024';
      SET testcasedesc = ' SecondNoticeDate should be before LegalActionPendingDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows SecondNoticeDate AFTER LegalActionPendingDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 25
    ## SecondNoticeDate should be before CitationDate
    ########################################################################
    
      SET testcaseid = '1.025';
      SET testcasedesc = ' SecondNoticeDate should be before CitationDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate > fact_invoice.citationdate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate > fact_invoice.citationdate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows SecondNoticeDate AFTER CitationDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 26
    ## SecondNoticeDate should be before ThirdNoticeDate
    ########################################################################
      SET testcaseid = '1.026';
      SET testcasedesc = ' SecondNoticeDate should be before ThirdNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate > fact_invoice.thirdnoticedate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate > fact_invoice.thirdnoticedate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows SecondNoticeDate AFTER ThirdNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 27
    ## FirstNoticeDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '1.027';
      SET testcasedesc = ' FirstNoticeDate should be before LegalActionPendingDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows FirstNoticeDate AFTER LegalActionPendingDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 28
    ## FirstNoticeDate should be before CitationDate
    ########################################################################
      SET testcaseid = '1.028';
      SET testcasedesc = ' FirstNoticeDate should be before CitationDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate > fact_invoice.citationdate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate > fact_invoice.citationdate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows FirstNoticeDate AFTER CitationDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 29
    ## FirstNoticeDate should be before ThirdNoticeDate
    ########################################################################
      SET testcaseid = '1.029';
      SET testcasedesc = ' FirstNoticeDate should be before ThirdNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate > fact_invoice.thirdnoticedate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate > fact_invoice.thirdnoticedate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows FirstNoticeDate AFTER ThirdNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 30
    ## FirstNoticeDate should be before SecondNoticeDate
    ########################################################################
      SET testcaseid = '1.030';
      SET testcasedesc = ' FirstNoticeDate should be before SecondNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate > fact_invoice.secondnoticedate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate > fact_invoice.secondnoticedate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows FirstNoticeDate AFTER SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 31
    ## ZipCashDate should be before DueDate
    ########################################################################
      SET testcaseid = '1.031';
      SET testcasedesc = ' ZipCashDate should be before DueDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.duedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.duedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.duedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.duedate <> '1900-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER DueDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 32
    ## ZipCashDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '1.032';
      SET testcasedesc = ' ZipCashDate should be before LegalActionPendingDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.legalactionpendingdate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.legalactionpendingdate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
        LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER LegalActionPendingDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 33
    ## ZipCashDate should be before CitationDate
    ########################################################################
      SET testcaseid = '1.033';
      SET testcasedesc = ' ZipCashDate should be before CitationDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.citationdate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.citationdate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER CitationDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
   ## TestCase# 34
   ## ZipCashDate should be before ThirdNoticeDate
   ########################################################################
      SET testcaseid = '1.034';
      SET testcasedesc = ' ZipCashDate should be before ThirdNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.thirdnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.thirdnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER ThirdNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 35
    ## ZipCashDate should be before SecondNoticeDate
    ########################################################################
      SET testcaseid = '1.035';
      SET testcasedesc = ' ZipCashDate should be before SecondNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.secondnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.secondnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 36
    ## ZipCashDate should be before FirstNoticeDate
    ########################################################################
      SET testcaseid = '1.036';
      SET testcasedesc = ' ZipCashDate should be before FirstNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.firstnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate > fact_invoice.firstnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate <> '1900-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 37
    ## PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)
    ########################################################################
      SET testcaseid = '1.037';
      SET testcasedesc = 'PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.paidamount <> fact_invoice.tollspaid + fact_invoice.fnfeespaid + fact_invoice.snfeespaid
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.paidamount <> fact_invoice.tollspaid + fact_invoice.fnfeespaid + fact_invoice.snfeespaid
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) PaidAmount is not matching with sum of TollsPaid,FNfeesPaid,SNfeesPaid');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 38
    ## AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)
    ########################################################################
      SET testcaseid = '1.038';
      SET testcasedesc = ' AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) AdjustedExpectedAmount is not matching with sum of AdjustedExpectedTolls,AdjustedExpectedFNfees,AdjustedExpectedSNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 39
    ## ExpectedAmount should be equal to (Tolls+FNfees+SNfees)
    ########################################################################
      SET testcaseid = '1.039';
      SET testcasedesc = ' ExpectedAmount should be equal to (Tolls+FNfees+SNfees)';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.expectedamount <> fact_invoice.tolls + fact_invoice.fnfees + fact_invoice.snfees
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.expectedamount <> fact_invoice.tolls + fact_invoice.fnfees + fact_invoice.snfees
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) ExpectedAmount is not matching with sum of Tolls,FNfees,SNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 40
    ## AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)
    ########################################################################
      SET testcaseid = '1.040';
      SET testcasedesc = ' AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedamount <> fact_invoice.tollsadjusted + fact_invoice.fnfeesadjusted + fact_invoice.snfeesadjusted
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedamount <> fact_invoice.tollsadjusted + fact_invoice.fnfeesadjusted + fact_invoice.snfeesadjusted
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) AdjustedAmount is not matching with sum of TollsAdjusted,FNfeesAdjusted,SNfeesAdjusted');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 41
    ## OutstandingAmount should be equal to (AdjustedExpectedAmount-PaidAmount)
    ########################################################################
      SET testcaseid = '1.041';
      SET testcasedesc = 'outstandingAmount should be equal to AdjustedExpectedAmount-PaidAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.outstandingamount <> fact_invoice.adjustedexpectedamount - fact_invoice.paidamount
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.outstandingamount <> fact_invoice.adjustedexpectedamount - fact_invoice.paidamount
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) outstandingAmount is not matching with sum of TollsAdjusted,FNfeesAdjusted,SNfeesAdjusted');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 42
    ## outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount
    ########################################################################
      SET testcaseid = '1.042';
      SET testcasedesc = 'outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.outstandingamount + fact_invoice.paidamount <> fact_invoice.expectedamount - fact_invoice.adjustedamount
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.outstandingamount + fact_invoice.paidamount <> fact_invoice.expectedamount - fact_invoice.adjustedamount
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) outstandingAmount+PaidAmount  is not matching with ExpectedAmount-AdjustedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 43
    ## InvoiceAmount should not be null
    ########################################################################
      SET testcaseid = '1.043';
      SET testcasedesc = 'InvoiceAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.invoiceamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.invoiceamount IS NULL
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL InvoiceAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 44
    ## Tolls should not be null
    ########################################################################
      SET testcaseid = '1.044';
      SET testcasedesc = 'Tolls should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.tolls IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.tolls IS NULL
      LIMIT 1
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL Tolls');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 45
    ## FNfees should not be null
    ########################################################################
      SET testcaseid = '1.045';
      SET testcasedesc = 'FNfees should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfees IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfees IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL FNFees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 46
    ## SNfees should not be null
    ########################################################################
      SET testcaseid = '1.046';
      SET testcasedesc = 'SNfees should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.snfees IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.snfees IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL SNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 47
    ## ExpectedAmount should not be null
    ########################################################################

      SET testcaseid = '1.047';
      SET testcasedesc = 'ExpectedAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.expectedamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.expectedamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - Invoices with NULL ExpectedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 48
    ## TollsAdjusted should not be null
    ########################################################################
      SET testcaseid = '1.048';
      SET testcasedesc = 'TollsAdjusted should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.tollsadjusted IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.tollsadjusted IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - Invoices with NULL TollsAdjusted');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 49
    ## FNfeesAdjusted should not be null
    ########################################################################
      SET testcaseid = '1.049';
      SET testcasedesc = 'FNfeesAdjusted should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfeesadjusted IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfeesadjusted IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - Invoices with NULL FNfeesAdjusted');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 50
    ## SNfeesAdjusted should not be null
    ########################################################################
      SET testcaseid = '1.050';
      SET testcasedesc = 'SNfeesAdjusted should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.snfeesadjusted IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.snfeesadjusted IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - Invoices with NULL SNfeesAdjusted');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 51
    ## AdjustedAmount should not be null
    ########################################################################
      SET testcaseid = '1.051';
      SET testcasedesc = 'AdjustedAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL AdjustedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 52
    ## TollsPaid should not be null
    ########################################################################
      SET testcaseid = '1.052';
      SET testcasedesc = 'TollsPaid should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.tollspaid IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.tollspaid IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL TollsPaid');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 53
    ## FNfeesPaid should not be null
    ########################################################################
      SET testcaseid = '1.053';
      SET testcasedesc = 'FNfeesPaid should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfeespaid IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfeespaid IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL FNfeesPaid');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 54
    ## SNfeesPaid should not be null
    ########################################################################
      SET testcaseid = '1.054';
      SET testcasedesc = 'SNfeesPaid should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.snfeespaid IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.snfeespaid IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL SNfeesPaid');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 55
    ## PaidAmount should not be null
    ########################################################################
      SET testcaseid = '1.055';
      SET testcasedesc = 'PaidAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.paidamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.paidamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL PaidAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 56
    ## AdjustedExpectedTolls should not be null
    ########################################################################
      SET testcaseid = '1.056';
      SET testcasedesc = 'AdjustedExpectedTolls should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedtolls IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedtolls IS NULL
      LIMIT 1 
      );

      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL AdjustedExpectedTolls');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 57
    ## AdjustedExpectedFNfees should not be null
    ########################################################################
      SET testcaseid = '1.057';
      SET testcasedesc = 'AdjustedExpectedFNfees should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedfnfees IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedfnfees IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL AdjustedExpectedFNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 58
    ## AdjustedExpectedSNfees should not be null
    ########################################################################
      SET testcaseid = '1.058';
      SET testcasedesc = 'AdjustedExpectedSNfees should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedsnfees IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedsnfees IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL AdjustedExpectedSNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 59
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ########################################################################
      SET testcaseid = '1.059';
      SET testcasedesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in DismissedUnassigned state with a LastPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 60
    ## AdjustedExpectedAmount should not be null
    ########################################################################
      SET testcaseid = '1.060';
      SET testcasedesc = 'AdjustedExpectedAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.adjustedexpectedamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL AdjustedExpectedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 61
    ## TollOutStandingAmount should not be null
    ########################################################################
      SET testcaseid = '1.061';
      SET testcasedesc = 'TollOutStandingAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.tolloutstandingamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.tolloutstandingamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL TollOutStandingAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 62
    ## FNfeesOutStandingAmount should not be null
    ########################################################################
      SET testcaseid = '1.062';
      SET testcasedesc = 'FNfeesOutStandingAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfeesoutstandingamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfeesoutstandingamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL FNfeesOutStandingAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 63
    ## SNfeesOutStandingAmount should not be null
    ########################################################################
      SET testcaseid = '1.063';
      SET testcasedesc = 'SNfeesOutStandingAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.snfeesoutstandingamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.snfeesoutstandingamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL SNfeesOutStandingAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 64
    ## OutstandingAmount should not be null
    ########################################################################
      SET testcaseid = '1.064';
      SET testcasedesc = 'OutstandingAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.outstandingamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.outstandingamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL OutstandingAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 65
    ## When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"
    ########################################################################

      SET testcaseid = '1.065';
      SET testcasedesc = 'When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

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
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
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
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) NOT in "OPEN" even there is no Amount Paid/Adjusted and outstanding Amount is same is Expected Amount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 66
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ########################################################################
      SET testcaseid = '1.066';
      SET testcasedesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in "CLOSED" state and showing FirstPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 67
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ########################################################################
      SET testcaseid = '1.067';
      SET testcasedesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in "CLOSED" state and showing LastPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 68
    ## When CitationDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '1.068';
      SET testcasedesc = 'When valid CitationDate is populated then valid ZipCashDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.citationdate > '2019-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.citationdate > '2019-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing CitationDate without ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 69
    ## When CitationDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.069';
      SET testcasedesc = 'When valid CitationDate is populated then valid FirstNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing CitationDate without FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 70
    ## When CitationDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.070';
      SET testcasedesc = 'When valid CitationDate is populated then valid SecondNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing CitationDate without SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 71
    ## ValiDate no Fees for Zipcash Invoices
    ########################################################################
      SET testcaseid = '1.071';
      SET testcasedesc = 'ValiDate no Fees for Zipcash Invoices';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.agestageid = 1
         AND (fact_invoice.fnfees > 0
         OR fact_invoice.snfees > 0)
         AND (fact_invoice.fnfeesadjusted = 0
         OR fact_invoice.snfeesadjusted = 0)
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.agestageid = 1
         AND (fact_invoice.fnfees > 0
         OR fact_invoice.snfees > 0)
         AND (fact_invoice.fnfeesadjusted = 0
         OR fact_invoice.snfeesadjusted = 0)
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing Fees for Zip');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 72
    ## Valiate no SNfees for FN Invoices
    ########################################################################
      SET testcaseid = '1.072';
      SET testcasedesc = 'Valiate no SNfees for FN Invoices';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.agestageid = 2
         AND fact_invoice.snfees > 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.agestageid = 2
         AND fact_invoice.snfees > 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - FN Invoices showing SNFees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 73
    ## When LegalActionPendingDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '1.073';
      SET testcasedesc = 'When valid LegalActionPendingDate is populated then valid ZipCashDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.legalactionpendingdate > '2019-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.legalactionpendingdate > '2019-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has LegalActionPendingDate without ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 74
    ## When LegalActionPendingDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.074';
      SET testcasedesc = 'When valid LegalActionPendingDate is populated then valid FirstNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has LegalActionPendingDate without FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 75
    ## When LegalActionPendingDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.075';
      SET testcasedesc = 'When valid LegalActionPendingDate is populated then valid SecondNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has LegalActionPendingDate without SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 76
    ## When LegalActionPendingDate is populated then valid thirdNoticeDate should be populated
    ########################################################################
    
      SET testcaseid = '1.076';
      SET testcasedesc = 'When valid LegalActionPendingDate is populated then valid thirdNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has LegalActionPendingDate without thirdNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 77
    ## When thirdNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '1.077';
      SET testcasedesc = 'When valid thirdNoticeDate is populated then valid ZipCashDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.thirdnoticedate > '2019-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.thirdnoticedate > '2019-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has thirdNoticeDate without ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 78
    ## When thirdNoticeDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.078';
      SET testcasedesc = 'When valid thirdNoticeDate is populated then valid FirstNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has thirdNoticeDate without FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 79
    ## When thirdNoticeDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.079';
      SET testcasedesc = 'When valid thirdNoticeDate is populated then valid SecondNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has thirdNoticeDate without SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 80
    ## When SecondNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '1.080';
      SET testcasedesc = 'When valid SecondNoticeDate is populated then valid ZipCashDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate > '2019-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate > '2019-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has SecondNoticeDate without ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 81
    ## When SecondNoticeDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '1.081';
      SET testcasedesc = 'When valid SecondNoticeDate is populated then valid FirstNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has SecondNoticeDate without FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 82
    ## When FirstNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '1.082';
      SET testcasedesc = 'When valid FirstNoticeDate is populated then valid ZipCashDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
         AND fact_invoice.firstnoticedate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
         AND fact_invoice.firstnoticedate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has FirstNoticeDate without ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 83
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ########################################################################
      SET testcaseid = '1.083';
      SET testcasedesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.firstpaymentdate = '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.firstpaymentdate = '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in Paid status without FirstPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 84
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ########################################################################
      SET testcaseid = '1.084';
      SET testcasedesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.lastpaymentdate = '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.lastpaymentdate = '1900-01-01'
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in Paid status without LastPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 85
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ########################################################################
      SET testcaseid = '1.085';
      SET testcasedesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.firstpaymentdate = '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.firstpaymentdate = '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in PartialPaid status without FirstPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 86
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ########################################################################
      SET testcaseid = '1.086';
      SET testcasedesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.lastpaymentdate = '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.lastpaymentdate = '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in PartialPaid status without LastPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 87
    ## Unassigned Invoices should not have PaidAmount.
    ########################################################################
      SET testcaseid = '1.087';
      SET testcasedesc = 'Unassigned Invoices should not have PaidAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND fact_invoice.paidamount > 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND fact_invoice.paidamount > 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -UnAssigned Invoices withPaidAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 88
    ## Unknown Statuse Validation.
    ########################################################################
      SET testcaseid = '1.088';
      SET testcasedesc = 'Unknown Status Validation.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = -1
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = -1
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in Unknown Status');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 89
    ## PartialPaid Invoices should have valid PaidAmount.
    ########################################################################
      SET testcaseid = '1.089';
      SET testcasedesc = 'PartialPaid Invoices should have valid PaidAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.paidamount <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.paidamount <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  - PartialPad Invoices without PaidAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 90
    ## Paid Invoices - PaidAmount should match with AdjustedExpectedTolls
    ########################################################################
      SET testcaseid = '1.090';
      SET testcasedesc = 'Paid Invoices - PaidAmount should match with AdjustedExpectedTolls';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.adjustedexpectedtolls <> fact_invoice.tollspaid
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.adjustedexpectedtolls <> fact_invoice.tollspaid
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Paid Invoices AdjustedExpectedTolls not matching with TollsPaid');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 91
    ## AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount
    ########################################################################
      SET testcaseid = '1.091';
      SET testcasedesc = 'AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate >= '2019-01-01'
         AND fact_invoice.expectedamount - fact_invoice.adjustedamount <> fact_invoice.adjustedexpectedamount
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.zipcashdate >= '2019-01-01'
         AND fact_invoice.expectedamount - fact_invoice.adjustedamount <> fact_invoice.adjustedexpectedamount
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) AdjustedExpectedAmount not matching with ExpectedAmount-AdjustedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 92
    ## Closed Invoices should have valid PaidAmount
    ########################################################################
      SET testcaseid = '1.092';
      SET testcasedesc = 'Closed Invoices should have valid PaidAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND fact_invoice.paidamount > 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND fact_invoice.paidamount > 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Closed Invoices without PaidAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 93
    ## Unassigned Invoices should not have AdjustedExpectedAmount
    ########################################################################
      SET testcaseid = '1.093';
      SET testcasedesc = 'Unassigned Invoices should not have AdjustedExpectedAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND fact_invoice.adjustedexpectedamount <> 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND fact_invoice.adjustedexpectedamount <> 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Unassigned Invoices with AdjustedExpectedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 94
    ## First Notice Adjustment Fees  should not be more than First Notice Fees
    ########################################################################
      SET testcaseid = '1.094';
      SET testcasedesc = 'First Notice Adjustment Fees  should not be more than First Notice Fees';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfeesadjusted > fact_invoice.fnfees
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.fnfeesadjusted > fact_invoice.fnfees
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) First Notice Adjustment Fees is more than First Notice Fees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 95
    ## Second Notice Adjustment Fees  should not be more than Second Notice Fees
    ########################################################################
      SET testcaseid = '1.095';
      SET testcasedesc = 'Second Notice Adjustment Fees  should not be more than Second Notice Fees';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.snfeesadjusted > fact_invoice.snfees
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.snfeesadjusted > fact_invoice.snfees
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) Second Notice Adjustment Fees is more than Second Notice Fees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 96
    ## Invoice ExpectedAmount should always be greater than 0
    ########################################################################
      SET testcaseid = '1.096';
      SET testcasedesc = 'Invoice ExpectedAmount should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.expectedamount <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.expectedamount <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows no ExpectedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 97
    ## InvoiceAmount should always be greater than 0
    ########################################################################
      SET testcaseid = '1.097';
      SET testcasedesc = 'InvoiceAmount should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.expectedamount <= 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.expectedamount <= 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows no InvoiceAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
   ## TestCase# 98
   ## Invoice Tolls should always be greater than 0
   ########################################################################
      SET testcaseid = '1.098';
      SET testcasedesc = 'Invoice Tolls should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.tolls <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.tolls <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows no Tolls');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
   ## TestCase# 99
   ## Invoice AVITollAmount should always be greater than 0
   ########################################################################

      SET testcaseid = '1.099';
      SET testcasedesc = 'Invoice AVITollAmount should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.avitollamount <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.avitollamount <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows no AVITollAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 100
    ## Invoice PBMTollAmount should always be greater than 0
    ########################################################################
      SET testcaseid = '1.100';
      SET testcasedesc = 'Invoice PBMTollAmount should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.pbmtollamount <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.pbmtollamount <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows no PBMTollAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 101
    ## Invoice txncnt should always be greater than 0
    ########################################################################
      SET testcaseid = '1.101';
      SET testcasedesc = 'Invoice txncnt should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.txncnt <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag = 1
         AND fact_invoice.txncnt <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows no txncnt');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ### NON-MIGRATED ###
      SET datacategory = 'Non-Migrated';
    ########################################################################
    ## TestCase# 1
    ## InvoiceNumber should be not null
    ########################################################################
      SET testcaseid = '2.001';
      SET testcasedesc = 'InvoiceNumber should be not null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.invoicenumber IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.invoicenumber IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with InvoiceNumber NULL');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 2
    ########################################################################
      SET testcaseid = '2.002';
      SET testcasedesc = 'InvoiceNumber should be unique';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      CREATE TEMPORARY TABLE cte3 AS (
        SELECT
            fact_invoice.invoicenumber,
            count(*) AS x
          FROM
            EDW_TRIPS.fact_invoice
          WHERE fact_invoice.migratedflag <> 1
          GROUP BY 1
          HAVING count(*) > 1
      );
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          cte3
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  -  Duplicate InvoiceNumbers found.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 3
    ########################################################################
      SET testcaseid = '2.003';
      SET testcasedesc = 'CustomerID should Not be NULL';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.customerid IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.customerid IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing CustomerID as NULL');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 4
    ########################################################################
      SET testcaseid = '2.004';
      SET testcasedesc = 'AdjustedExpectedAmount should be total of AdjustedExpectedTolls,AdjustedExpectedFNfees & AdjustedExpectedSNfees';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) having AdjustedExpectedAmount NOT equal to sum of AdjustedExpectedTolls,AdjustedExpectedFNfees & AdjustedExpectedSNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 5
    ## AdjustedAmount and PaidAmount should be greater than 0 when Invoice is Paid
    ########################################################################
      SET testcaseid = '2.005';
      SET testcasedesc = 'AdjustedAmount and PaidAmount should be greater than 0 when Invoice is Paid';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.adjustedamount = 0
         AND fact_invoice.paidamount = 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.adjustedamount = 0
         AND fact_invoice.paidamount = 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  -  Paid Invoice having No AdjustedAmount and PaidAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 6
    ## LastPaymentDate should be after the FirstPaymentDate.
    ########################################################################
      SET testcaseid = '2.006';
      SET testcasedesc = 'LastPaymentDate should be after the FirstPaymentDate.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstpaymentdate > fact_invoice.lastpaymentdate
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstpaymentdate > fact_invoice.lastpaymentdate
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) LastPaymentDate shows BEFORE FirstPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 7
    ## PBMTollAmount should not be null
    ########################################################################
      SET testcaseid = '2.007';
      SET testcasedesc = 'PBMTollAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.pbmtollamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.pbmtollamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with PBMTollAmount as NULL');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 8
    ## AVITollAmount should not be null
    ########################################################################
      SET testcaseid = '2.008';
      SET testcasedesc = 'AVITollAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.avitollamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.avitollamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with AVITollAmount as NULL');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 9
    ## PremiumAmount should not be null
    ########################################################################
      SET testcaseid = '2.009';
      SET testcasedesc = 'PremiumAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.premiumamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.premiumamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with PremiumAmount as NULL');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 10
    ## FirstNotice Fee should be less than SecondNotice Fee
    ########################################################################
      SET testcaseid = '2.010';
      SET testcasedesc = 'FirstNotice Fee should be less than SecondNotice Fee';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfees > fact_invoice.snfees
         AND fact_invoice.snfees > 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfees > fact_invoice.snfees
         AND fact_invoice.snfees > 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has FirstNotice Fee more than SecondNotice Fee.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 11
    ## if the invoice is in Citation Issued then the DueDate should be greater than CitationDate
    ########################################################################
      SET testcaseid = '2.011';
      SET testcasedesc = 'if the invoice is in Citation Issued then the DueDate should be greater than CitationDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate > fact_invoice.duedate
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.agestageid = 6
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate > fact_invoice.duedate
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.agestageid = 6
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in Citation Issued state and has DueDate BEFORE CitationDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 12
    ## if the invoice is in Legal Action Pending then the DueDate should be greater than LegalActionPendingDate
    ############################################################################################################
      SET testcaseid = '2.012';
      SET testcasedesc = 'if the invoice is in Legal Action Pending then the DueDate should be greater than LegalActionPendingDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate > fact_invoice.duedate
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.agestageid = 5
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate > fact_invoice.duedate
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.agestageid = 5
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) are in Legal Action Pending state and has DueDate BEFORE LegalActionPendingDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 13
    ## if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice
    ########################################################################

      SET testcaseid = '2.013';
      SET testcasedesc = 'if the invoice is in 3rd notice then the DueDate should be greater than 3rd notice';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.duedate < fact_invoice.thirdnoticedate
         AND fact_invoice.agestageid = 4
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.duedate < fact_invoice.thirdnoticedate
         AND fact_invoice.agestageid = 4
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - 3rd Notice state Invoices shows DueDate BEFORE 3rd Notice Date');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 14
    ## if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice
    ########################################################################
      SET testcaseid = '2.014';
      SET testcasedesc = 'if the invoice is in 2nd notice then the DueDate should be greater than 2nd notice';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.duedate < fact_invoice.secondnoticedate
         AND fact_invoice.agestageid = 3
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.duedate < fact_invoice.secondnoticedate
         AND fact_invoice.agestageid = 3
         AND fact_invoice.duedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - 2nd Notice state Invoices shows DueDate BEFORE 2nd Notice Date');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 15
    ## ZipCashDate should not be defaulted to 1900-01-01 when the invoice is in "ZipCash" Stage
    ########################################################################
      SET testcaseid = '2.015';
      SET testcasedesc = 'ZipCashDate should not be defaulted to "1900-01-01" when the invoice is in "ZipCash" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate = '1900-01-01'
         AND fact_invoice.agestageid >= 1
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate = '1900-01-01'
         AND fact_invoice.agestageid >= 1
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -ZipCash Stage Invoices missing ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 16
    ## FirstNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "First Notice of non-Payment" Stage
    ########################################################################
      SET testcaseid = '2.016';
      SET testcasedesc = 'FirstNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "First Notice of non-Payment" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 2
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 2
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - "First Notice of non-Payment" Stage Invoices missing FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 17
    ## SecondNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Second Notice of non-Payment" Stage
    ########################################################################
      SET testcaseid = '2.017';
      SET testcasedesc = 'SecondNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "Second Notice of non-Payment" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 3
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 3
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - "Second Notice of non-Payment" Stage Invoices missing SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 18
    ## ThirdNoticeDate should not be defaulted to 1900-01-01 when the invoice is in "Third Notice of non-Payment" Stage
    ########################################################################
      SET testcaseid = '2.018';
      SET testcasedesc = 'ThirdNoticeDate should not be defaulted to "1900-01-01" when the invoice is in "Third Notice of non-Payment" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 4
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate = '1900-01-01'
         AND fact_invoice.agestageid = 4
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - "Third Notice of non-Payment" Stage Invoices missing ThirdNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 19
    ## LegalActionPendingDate should not be defaulted to 1900-01-01 when the invoice is in "Legal Action Pending" Stage
    ########################################################################
      SET testcaseid = '2.019';
      SET testcasedesc = 'LegalActionPendingDate should not be defaulted to "1900-01-01" when the invoice is in "Legal Action Pending" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate = '1900-01-01'
         AND fact_invoice.agestageid = 5
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate = '1900-01-01'
         AND fact_invoice.agestageid = 5
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - "Legal Action Pending" Stage Invoices missing LegalActionPendingDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 20
    ## CitationDate should not be defaulted to 1900-01-01 when the invoice is in "Citation Issued" Stage
    ########################################################################
      SET testcaseid = '2.020';
      SET testcasedesc = 'CitationDate should not be defaulted to "1900-01-01" when the invoice is in "Citation Issued" Stage';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate = '1900-01-01'
         AND fact_invoice.agestageid = 6
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate = '1900-01-01'
         AND fact_invoice.agestageid = 6
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - "Citation Issued" Stage Invoices missing CitationDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 21
    ## CitationDate should be after LegalActionPendingDate
    ########################################################################
      SET testcaseid = '2.021';
      SET testcasedesc = ' CitationDate should be after LegalActionPendingDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate < fact_invoice.legalactionpendingdate
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate < fact_invoice.legalactionpendingdate
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows CitationDate BEFORE LegalActionPendingDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 22
    ## ThirdNoticeDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '2.022';
      SET testcasedesc = ' ThirdNoticeDate should be before LegalActionPendingDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ThirdNoticeDate AFTER LegalActionPendingDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 23
    ## ThirdNoticeDate should be before CitationDate
    ########################################################################
      SET testcaseid = '2.023';
      SET testcasedesc = ' ThirdNoticeDate should be before CitationDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate > fact_invoice.citationdate
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate > fact_invoice.citationdate
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ThirdNoticeDate AFTER CitationDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 24
    ## SecondNoticeDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '2.024';
      SET testcasedesc = ' SecondNoticeDate should be before LegalActionPendingDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows SecondNoticeDate AFTER LegalActionPendingDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 25
    ## SecondNoticeDate should be before CitationDate
    ########################################################################
      SET testcaseid = '2.025';
      SET testcasedesc = ' SecondNoticeDate should be before CitationDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate > fact_invoice.citationdate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate > fact_invoice.citationdate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows SecondNoticeDate AFTER CitationDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 26
    ## SecondNoticeDate should be before ThirdNoticeDate
    ########################################################################
      SET testcaseid = '2.026';
      SET testcasedesc = ' SecondNoticeDate should be before ThirdNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate > fact_invoice.thirdnoticedate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate > fact_invoice.thirdnoticedate
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows SecondNoticeDate AFTER ThirdNoticeDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 27
    ## FirstNoticeDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '2.027';
      SET testcasedesc = ' FirstNoticeDate should be before LegalActionPendingDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate > fact_invoice.legalactionpendingdate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows FirstNoticeDate AFTER LegalActionPendingDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 28
    ## FirstNoticeDate should be before CitationDate
    ########################################################################
      SET testcaseid = '2.028';
      SET testcasedesc = ' FirstNoticeDate should be before CitationDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate > fact_invoice.citationdate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate > fact_invoice.citationdate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows FirstNoticeDate AFTER CitationDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 29
    ## FirstNoticeDate should be before ThirdNoticeDate
    ########################################################################
      SET testcaseid = '2.029';
      SET testcasedesc = ' FirstNoticeDate should be before ThirdNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate > fact_invoice.thirdnoticedate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate > fact_invoice.thirdnoticedate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows FirstNoticeDate AFTER ThirdNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 30
    ## FirstNoticeDate should be before SecondNoticeDate
    ########################################################################
      SET testcaseid = '2.030';
      SET testcasedesc = ' FirstNoticeDate should be before SecondNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate > fact_invoice.secondnoticedate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate > fact_invoice.secondnoticedate
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows FirstNoticeDate AFTER SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 31
    ## ZipCashDate should be before DueDate
    ########################################################################
      SET testcaseid = '2.031';
      SET testcasedesc = ' ZipCashDate should be before DueDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.duedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.duedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.duedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.duedate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER DueDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 32
    ## ZipCashDate should be before LegalActionPendingDate
    ########################################################################
      SET testcaseid = '2.032';
      SET testcasedesc = ' ZipCashDate should be before LegalActionPendingDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.legalactionpendingdate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.legalactionpendingdate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER LegalActionPendingDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 33
    ## ZipCashDate should be before CitationDate
    ########################################################################
      SET testcaseid = '2.033';
      SET testcasedesc = ' ZipCashDate should be before CitationDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.citationdate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.citationdate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.citationdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER CitationDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 34
    ## ZipCashDate should be before ThirdNoticeDate
    ########################################################################
      SET testcaseid = '2.034';
      SET testcasedesc = ' ZipCashDate should be before ThirdNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.thirdnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.thirdnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER ThirdNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 35
    ## ZipCashDate should be before SecondNoticeDate
    ########################################################################
      SET testcaseid = '2.035';
      SET testcasedesc = ' ZipCashDate should be before SecondNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.secondnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.secondnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 36
    ## ZipCashDate should be before FirstNoticeDate
    ########################################################################
      SET testcaseid = '2.036';
      SET testcasedesc = ' ZipCashDate should be before FirstNoticeDate';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.firstnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate > fact_invoice.firstnoticedate
         AND fact_invoice.zipcashdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows ZipCashDate AFTER FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 37
    ## PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)
    ########################################################################
      SET testcaseid = '2.037';
      SET testcasedesc = 'PaidAmount should be equal to (TollsPaid+FNfeesPaid+SNfeesPaid)';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.paidamount <> fact_invoice.tollspaid + fact_invoice.fnfeespaid + fact_invoice.snfeespaid
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.paidamount <> fact_invoice.tollspaid + fact_invoice.fnfeespaid + fact_invoice.snfeespaid
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) PaidAmount is not matching with sum of TollsPaid,FNfeesPaid,SNfeesPaid');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 38
    ## AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)
    ########################################################################
      SET testcaseid = '2.038';
      SET testcasedesc = ' AdjustedExpectedAmount should be equal to (AdjustedExpectedTolls+AdjustedExpectedFNfees+AdjustedExpectedSNfees)';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedamount <> fact_invoice.adjustedexpectedtolls + fact_invoice.adjustedexpectedfnfees + fact_invoice.adjustedexpectedsnfees
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) AdjustedExpectedAmount is not matching with sum of AdjustedExpectedTolls,AdjustedExpectedFNfees,AdjustedExpectedSNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 39
    ## ExpectedAmount should be equal to (Tolls+FNfees+SNfees)
    ########################################################################
      SET testcaseid = '2.039';
      SET testcasedesc = ' ExpectedAmount should be equal to (Tolls+FNfees+SNfees)';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.expectedamount <> fact_invoice.tolls + fact_invoice.fnfees + fact_invoice.snfees
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.expectedamount <> fact_invoice.tolls + fact_invoice.fnfees + fact_invoice.snfees
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) ExpectedAmount is not matching with sum of Tolls,FNfees,SNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 40
    ## AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)
    ########################################################################
      SET testcaseid = '2.040';
      SET testcasedesc = ' AdjustedAmount should be equal to (TollsAdjusted+FNfeesAdjusted+SNfeesAdjusted)';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedamount <> fact_invoice.tollsadjusted + fact_invoice.fnfeesadjusted + fact_invoice.snfeesadjusted
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedamount <> fact_invoice.tollsadjusted + fact_invoice.fnfeesadjusted + fact_invoice.snfeesadjusted
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) AdjustedAmount is not matching with sum of TollsAdjusted,FNfeesAdjusted,SNfeesAdjusted');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 41
    ## First Notice Adjustment Fees  should not be more than First Notice Fees
    ########################################################################
      SET testcaseid = '2.041';
      SET testcasedesc = 'First Notice Adjustment Fees  should not be more than First Notice Fees';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfeesadjusted > fact_invoice.fnfees
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfeesadjusted > fact_invoice.fnfees
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) First Notice Adjustment Fees is more than First Notice Fees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 42
    ## outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount
    ########################################################################
      SET testcaseid = '2.042';
      SET testcasedesc = 'outstandingAmount+PaidAmount should be equal to ExpectedAmount-AdjustedAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.outstandingamount + fact_invoice.paidamount <> fact_invoice.expectedamount - fact_invoice.adjustedamount
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.outstandingamount + fact_invoice.paidamount <> fact_invoice.expectedamount - fact_invoice.adjustedamount
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) outstandingAmount+PaidAmount  is not matching with ExpectedAmount-AdjustedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 43
    ## InvoiceAmount should not be null
    ########################################################################
      SET testcaseid = '2.043';
      SET testcasedesc = 'InvoiceAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.invoiceamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.invoiceamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL InvoiceAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 44
    ## Tolls should not be null
    ########################################################################
      SET testcaseid = '2.044';
      SET testcasedesc = 'Tolls should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.tolls IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.tolls IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL Tolls');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 45
    ## FNfees should not be null
    ########################################################################
      SET testcaseid = '2.045';
      SET testcasedesc = 'FNfees should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfees IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfees IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL FNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 46
    ## SNfees should not be null
    ########################################################################
      SET testcaseid = '2.046';
      SET testcasedesc = 'SNfees should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.snfees IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.snfees IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL SNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 47
    ## ExpectedAmount should not be null
    ########################################################################
      SET testcaseid = '2.047';
      SET testcasedesc = 'ExpectedAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.expectedamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.expectedamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL ExpectedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 48
    ## TollsAdjusted should not be null
    ########################################################################
      SET testcaseid = '2.048';
      SET testcasedesc = 'TollsAdjusted should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.tollsadjusted IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.tollsadjusted IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL TollsAdjusted');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 49
    ## FNfeesAdjusted should not be null
    ########################################################################
      SET testcaseid = '2.049';
      SET testcasedesc = 'FNfeesAdjusted should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfeesadjusted IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfeesadjusted IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL FNfeesAdjusted');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 50
    ## SNfeesAdjusted should not be null
    ########################################################################
      SET testcaseid = '2.050';
      SET testcasedesc = 'SNfeesAdjusted should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.snfeesadjusted IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.snfeesadjusted IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL SNfeesAdjusted');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 51
    ## AdjustedAmount should not be null
    ########################################################################
      SET testcaseid = '2.051';
      SET testcasedesc = 'AdjustedAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL AdjustedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 52
    ## TollsPaid should not be null
    ########################################################################
      SET testcaseid = '2.052';
      SET testcasedesc = 'TollsPaid should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.tollspaid IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.tollspaid IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL TollsPaid');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    ########################################################################
    ## TestCase# 53
    ## FNfeesPaid should not be null
    ########################################################################
    
      SET testcaseid = '2.053';
      SET testcasedesc = 'FNfeesPaid should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfeespaid IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfeespaid IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL FNfeesPaid');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 54
    ## SNfeesPaid should not be null
    ########################################################################
      SET testcaseid = '2.054';
      SET testcasedesc = 'SNfeesPaid should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.snfeespaid IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.snfeespaid IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL SNfeesPaid');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 55
    ## PaidAmount should not be null
    ########################################################################
      SET testcaseid = '2.055';
      SET testcasedesc = 'PaidAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.paidamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.paidamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL PaidAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 56
    ## AdjustedExpectedTolls should not be null
    ########################################################################
      SET testcaseid = '2.056';
      SET testcasedesc = 'AdjustedExpectedTolls should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedtolls IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedtolls IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL AdjustedExpectedTolls');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 57
    ## AdjustedExpectedFNfees should not be null
    ########################################################################
      SET testcaseid = '2.057';
      SET testcasedesc = 'AdjustedExpectedFNfees should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedfnfees IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedfnfees IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL AdjustedExpectedFNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 58
    ## AdjustedExpectedSNfees should not be null
    ########################################################################
      SET testcaseid = '2.058';
      SET testcasedesc = 'AdjustedExpectedSNfees should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedsnfees IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedsnfees IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL AdjustedExpectedSNfees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 60
    ## AdjustedExpectedAmount should not be null
    ########################################################################
      SET testcaseid = '2.060';
      SET testcasedesc = 'AdjustedExpectedAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.adjustedexpectedamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL AdjustedExpectedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 61
    ## TollOutStandingAmount should not be null
    ########################################################################
      SET testcaseid = '2.061';
      SET testcasedesc = 'TollOutStandingAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.tolloutstandingamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.tolloutstandingamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' - Invoices with NULL TollOutStandingAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 62
    ## FNfeesOutStandingAmount should not be null
    ########################################################################
      SET testcaseid = '2.062';
      SET testcasedesc = 'FNfeesOutStandingAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfeesoutstandingamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.fnfeesoutstandingamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL FNfeesOutStandingAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 63
    ## SNfeesOutStandingAmount should not be null
    ########################################################################
      SET testcaseid = '2.063';
      SET testcasedesc = 'SNfeesOutStandingAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.snfeesoutstandingamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.snfeesoutstandingamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL SNfeesOutStandingAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 64
    ## OutstandingAmount should not be null
    ########################################################################
      SET testcaseid = '2.064';
      SET testcasedesc = 'OutstandingAmount should not be null';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.outstandingamount IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.outstandingamount IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with NULL OutstandingAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 65
    ## When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"
    ########################################################################
      SET testcaseid = '2.065';
      SET testcasedesc = 'When there is no Amount Paid or Adjusted and outstanding Amount is same is Expected Amount then invoice status should be "Open"';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

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
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
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
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) NOT in "OPEN" even there is no Amount Paid/Adjusted and outstanding Amount is same is Expected Amount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 66
    ## firstinvoiceid should be Not NULL when invoicestatus in (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status
    ########################################################################
      SET testcaseid = '2.066';
      SET testcasedesc = 'firstinvoiceid should Not be NULL when invoicestatus in (\'Paid\',\'DismissedVTolled\',\'DismissedUnassigned\',\'Closed\') status';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid IN(
          4370, 4434, 99998, 99999
        )
         AND fact_invoice.firstinvoiceid IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid IN(
          4370, 4434, 99998, 99999
        )
         AND fact_invoice.firstinvoiceid IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with (\'Paid\',\'DismissedVTolled\',\'DismissedUnassigned\',\'Closed\') status having firstinvoiceid as NULL');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 67
    ## currentinvoiceid should be Not NULL when invoicestatus in (''Paid'',''DismissedVTolled'',''DismissedUnassigned'',''Closed'') status
    ########################################################################
      SET testcaseid = '2.067';
      SET testcasedesc = 'currentinvoiceid should Not be NULL when invoicestatus in (\'Paid\',\'DismissedVTolled\',\'DismissedUnassigned\',\'Closed\') status';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid IN(
          4370, 4434, 99998, 99999
        )
         AND fact_invoice.currentinvoiceid IS NULL
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid IN(
          4370, 4434, 99998, 99999
        )
         AND fact_invoice.currentinvoiceid IS NULL
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) with (\'Paid\',\'DismissedVTolled\',\'DismissedUnassigned\',\'Closed\') status having currentinvoiceid as NULL');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 68
    ## When CitationDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '2.068';
      SET testcasedesc = 'When valid CitationDate is populated then valid ZipCashDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing CitationDate without ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 69
    ## When CitationDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.069';
      SET testcasedesc = 'When valid CitationDate is populated then valid FirstNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing CitationDate without FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 70
    ## When CitationDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.070';
      SET testcasedesc = 'When valid CitationDate is populated then valid SecondNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing CitationDate without SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 71
    ## When CitationDate is populated then valid thirdNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.071';
      SET testcasedesc = 'When valid CitationDate is populated then valid thirdNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.citationdate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing CitationDate without thirdNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 72
    ## Second Notice Adjustment Fees  should not be more than Second Notice Fees
    ########################################################################
      SET testcaseid = '2.072';
      SET testcasedesc = 'Second Notice Adjustment Fees  should not be more than Second Notice Fees';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.snfeesadjusted > fact_invoice.snfees
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.snfeesadjusted > fact_invoice.snfees
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) Second Notice Adjustment Fees is more than Second Notice Fees');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 73
    ## When LegalActionPendingDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '2.073';
      SET testcasedesc = 'When valid LegalActionPendingDate is populated then valid ZipCashDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has LegalActionPendingDate without ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 74
    ## When LegalActionPendingDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.074';
      SET testcasedesc = 'When valid LegalActionPendingDate is populated then valid FirstNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has LegalActionPendingDate without FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 75
    ## When LegalActionPendingDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.075';
      SET testcasedesc = 'When valid LegalActionPendingDate is populated then valid SecondNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has LegalActionPendingDate without SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 76
    ## When LegalActionPendingDate is populated then valid thirdNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.076';
      SET testcasedesc = 'When valid LegalActionPendingDate is populated then valid thirdNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.legalactionpendingdate <> '1900-01-01'
         AND fact_invoice.thirdnoticedate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has LegalActionPendingDate without thirdNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 77
    ## When thirdNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '2.077';
      SET testcasedesc = 'When valid thirdNoticeDate is populated then valid ZipCashDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has thirdNoticeDate without ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 78
    ## When thirdNoticeDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.078';
      SET testcasedesc = 'When valid thirdNoticeDate is populated then valid FirstNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has thirdNoticeDate without FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 79
    ## When thirdNoticeDate is populated then valid SecondNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.079';
      SET testcasedesc = 'When valid thirdNoticeDate is populated then valid SecondNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.thirdnoticedate <> '1900-01-01'
         AND fact_invoice.secondnoticedate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has thirdNoticeDate without SecondNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 80
    ## When SecondNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '2.080';
      SET testcasedesc = 'When valid SecondNoticeDate is populated then valid ZipCashDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has SecondNoticeDate without ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

     ########################################################################
    ## TestCase# 81
    ## When SecondNoticeDate is populated then valid FirstNoticeDate should be populated
    ########################################################################
      SET testcaseid = '2.081';
      SET testcasedesc = 'When valid SecondNoticeDate is populated then valid FirstNoticeDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.secondnoticedate <> '1900-01-01'
         AND fact_invoice.firstnoticedate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has SecondNoticeDate without FirstNoticeDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 82
    ## When FirstNoticeDate is populated then valid ZipCashDate should be populated
    ########################################################################
      SET testcaseid = '2.082';
      SET testcasedesc = 'When valid FirstNoticeDate is populated then valid ZipCashDate should be populated';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.firstnoticedate <> '1900-01-01'
         AND fact_invoice.zipcashdate < '1901-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) has FirstNoticeDate without ZipCashDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 83
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ########################################################################
      SET testcaseid = '2.083';
      SET testcasedesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.firstpaymentdate = '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.firstpaymentdate = '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Paid Invoices without FirstPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 84
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status.
    ########################################################################
      SET testcaseid = '2.084';
      SET testcasedesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in Paid status';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.lastpaymentdate = '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.lastpaymentdate = '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Paid Invoices without LastPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 85
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ########################################################################
      SET testcaseid = '2.085';
      SET testcasedesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.firstpaymentdate = '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.firstpaymentdate = '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -PartialPaid Invoices without FirstPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 86
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status.
    ########################################################################
      SET testcaseid = '2.086';
      SET testcasedesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in PartialPaid status';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.lastpaymentdate = '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.lastpaymentdate = '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -PartialPaid Invoices without LastPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 87
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ########################################################################
      SET testcaseid = '2.087';
      SET testcasedesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 4370
         AND fact_invoice.firstpaymentdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 4370
         AND fact_invoice.firstpaymentdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) showing FirstPaymentDate even the status is OPEN.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 88
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status.
    ########################################################################
      SET testcaseid = '2.088';
      SET testcasedesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in Open status';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 4370
         AND fact_invoice.lastpaymentdate <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 4370
         AND fact_invoice.lastpaymentdate <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  -OPEN Invoices showing LastPaymentDate');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 89
    ## FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ########################################################################
      SET testcaseid = '2.089';
      SET testcasedesc = 'FirstPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99999
         AND (fact_invoice.firstpaymentdate = '1900-01-01'
         OR fact_invoice.firstpaymentdate IS NULL)
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99999
         AND (fact_invoice.firstpaymentdate = '1900-01-01'
         OR fact_invoice.firstpaymentdate IS NULL)
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -VTolled  Invoices Doesnt have FirstPaymentDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 90
    ## LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.
    ########################################################################
      SET testcaseid = '2.090';
      SET testcasedesc = 'LastPaymentDate should not be defaulted to 1900-01-01 when Invoice is in VTolled status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99999
         AND (fact_invoice.lastpaymentdate = '1900-01-01'
         OR fact_invoice.lastpaymentdate IS NULL)
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99999
         AND (fact_invoice.lastpaymentdate = '1900-01-01'
         OR fact_invoice.lastpaymentdate IS NULL)
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -VTolled  Invoices Doesnt have LastPaymentDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 91
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ########################################################################
      SET testcaseid = '2.091';
      SET testcasedesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -DismissedUnassigned  Invoices shows FirstPaymentDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 92
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.
    ########################################################################
      SET testcaseid = '2.092';
      SET testcasedesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in DismissedUnassigned status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  -DismissedUnassigned  Invoices shows LastPaymentDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 93
    ## FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ########################################################################
      SET testcaseid = '2.093';
      SET testcasedesc = 'FirstPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND coalesce(fact_invoice.firstpaymentdate, '1900-01-01') <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  -CLOSED  Invoices shows FirstPaymentDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 94
    ## LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.
    ########################################################################
      SET testcaseid = '2.094';
      SET testcasedesc = 'LastPaymentDate should be defaulted to 1900-01-01 when Invoice is in CLOSED status.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND coalesce(fact_invoice.lastpaymentdate, '1900-01-01') <> '1900-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  -CLOSED  Invoices shows LastPaymentDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;
    
    ########################################################################
    ## TestCase# 95
    ## ValiDate no Fees for Zipcash Invoices
    ########################################################################
      SET testcaseid = '2.095';
      SET testcasedesc = 'ValiDate no Fees for Zipcash Invoices';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.agestageid = 1
         AND (fact_invoice.fnfees > 0
         OR fact_invoice.snfees > 0)
         AND (fact_invoice.fnfeesadjusted = 0
         OR fact_invoice.snfeesadjusted = 0)
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.agestageid = 1
         AND (fact_invoice.fnfees > 0
         OR fact_invoice.snfees > 0)
         AND (fact_invoice.fnfeesadjusted = 0
         OR fact_invoice.snfeesadjusted = 0)
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  -Zipcash  Invoices shows ValiDate.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 96
    ## Valiate no SNfees for FN Invoices
    ########################################################################
      SET testcaseid = '2.096';
      SET testcasedesc = 'Valiate no SNfees for FN Invoices';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.agestageid = 2
         AND fact_invoice.snfees > 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.agestageid = 2
         AND fact_invoice.snfees > 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -FN Invoices shows SNfees.');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 97
    ## Unassigned Invoices should not have PaidAmount.
    ########################################################################
      SET testcaseid = '2.097';
      SET testcasedesc = 'Unassigned Invoices should not have PaidAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND fact_invoice.paidamount > 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND fact_invoice.paidamount > 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Unassigned Invoices shows PaidAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 98
    ## Unknown Statuse Validation.
    ########################################################################
      SET testcaseid = '2.098';
      SET testcasedesc = 'Unknown Status Validation.';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = -1
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = -1
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) shows Unknown Status');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 99
    ## PartialPaid Invoices should have valid PaidAmount.
    ########################################################################
      SET testcaseid = '2.099';
      SET testcasedesc = 'PartialPaid Invoices should have valid PaidAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.paidamount <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 515
         AND fact_invoice.paidamount <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  -PartialPaid Invoices doesnt show PaidAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 100
    ## Paid Invoices - PaidAmount should match with AdjustedExpectedTolls
    ########################################################################
      SET testcaseid = '2.100';
      SET testcasedesc = 'Paid Invoices - PaidAmount should match with AdjustedExpectedTolls';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.adjustedexpectedamount <> fact_invoice.paidamount
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 516
         AND fact_invoice.adjustedexpectedamount <> fact_invoice.paidamount
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Paid Invoices AdjustedExpectedTolls not matching with TollsPaid');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 101
    ## OutstandingAmount should be equal to AdjustedExpectedAmount-PaidAmount
    ########################################################################
      SET testcaseid = '2.101';
      SET testcasedesc = 'OutstandingAmount should be equal to AdjustedExpectedAmount-PaidAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate >= '2019-01-01'
         AND fact_invoice.adjustedexpectedamount - fact_invoice.paidamount <> fact_invoice.outstandingamount
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate >= '2019-01-01'
         AND fact_invoice.adjustedexpectedamount - fact_invoice.paidamount <> fact_invoice.outstandingamount
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) outstandingAmount is not matching with sum of TollsAdjusted,FNfeesAdjusted,SNfeesAdjusted');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 102
    ## AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount
    ########################################################################
      SET testcaseid = '2.102';
      SET testcasedesc = 'AdjustedExpectedAmount should be equal to ExpectedAmount-AdjustedAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate >= '2019-01-01'
         AND fact_invoice.expectedamount - fact_invoice.adjustedamount <> fact_invoice.adjustedexpectedamount
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.zipcashdate >= '2019-01-01'
         AND fact_invoice.expectedamount - fact_invoice.adjustedamount <> fact_invoice.adjustedexpectedamount
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) AdjustedExpectedAmount not matching with ExpectedAmount-AdjustedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 103
    ## Closed Invoices should have valid PaidAmount
    ########################################################################
      SET testcaseid = '2.103';
      SET testcasedesc = 'Closed Invoices should have valid PaidAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND fact_invoice.paidamount > 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 4434
         AND fact_invoice.paidamount > 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  - Closed Invoices without PaidAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 104
    ## Unassigned Invoices should not have AdjustedExpectedAmount
    ########################################################################
      SET testcaseid = '2.104';
      SET testcasedesc = 'Unassigned Invoices should not have AdjustedExpectedAmount';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND fact_invoice.adjustedexpectedamount <> 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.edw_invoicestatusid = 99998
         AND fact_invoice.adjustedexpectedamount <> 0
         AND fact_invoice.zipcashdate >= '2019-01-01'
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), '  - Unassigned Invoices shows AdjustedExpectedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 105
    ## TxnCnt validation between Fact and Lnd tables
    ########################################################################
      SET testcaseid = '2.105';
      SET testcasedesc = 'TxnCnt validation between Fact and Lnd tables';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          (
            SELECT
                h.invoicenumber,
                count(DISTINCT tptripid) AS txncnt
              FROM
                LND_TBOS.TollPlus_Invoice_Header AS h
                INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS l ON l.invoiceid = h.invoiceid
                INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt ON l.linkid = vt.citationid
                 AND l.linksourcename = 'TollPLUS.TP_VIOLATEDTRIPS'
              WHERE h.invoicedate >= '2019-01-01'
              GROUP BY 1
          ) AS lnd
          INNER JOIN (
            SELECT
                fact_invoice.invoicenumber,
                fact_invoice.txncnt AS edw_txncnt
              FROM
                EDW_TRIPS.fact_invoice
              WHERE fact_invoice.migratedflag <> 1
          ) AS edw ON  CAST(edw.invoicenumber AS STRING) = lnd.invoicenumber
        WHERE edw.edw_txncnt <> lnd.txncnt
      );
      SET sampleinvoicenumber = 
      ( 
        SELECT
          edw.invoicenumber AS __sampleinvoicenumber
        FROM
          (
            SELECT
                h.invoicenumber,
                count(DISTINCT tptripid) AS txncnt
              FROM
                LND_TBOS.TollPlus_Invoice_Header AS h
                INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS l ON l.invoiceid = h.invoiceid
                INNER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt ON l.linkid = vt.citationid
                 AND l.linksourcename = 'TollPLUS.TP_VIOLATEDTRIPS'
              WHERE h.invoicedate >= '2019-01-01'
              GROUP BY 1
          ) AS lnd
          INNER JOIN (
            SELECT
                fact_invoice.invoicenumber,
                fact_invoice.txncnt AS edw_txncnt
              FROM
                EDW_TRIPS.fact_invoice
              WHERE fact_invoice.migratedflag <> 1
          ) AS edw ON CAST(edw.invoicenumber AS STRING) = lnd.invoicenumber
        WHERE edw.edw_txncnt <> lnd.txncnt
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), 'TxnCnt not matching between Fact and Lnd tables');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 106
    ## Invoice ExpectedAmount should always be greater than 0
	  ########################################################################
      SET testcaseid = '2.106';
      SET testcasedesc = 'Invoice ExpectedAmount should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.expectedamount <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.expectedamount <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) without ExpectedAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 107
    ## Invoice InvoiceAmount should always be greater than 0
	  ########################################################################
      SET testcaseid = '2.107';
      SET testcasedesc = 'InvoiceAmount should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.invoiceamount <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.invoiceamount <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) without InvoiceAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 108
    ## Invoice Tolls should always be greater than 0
	  ########################################################################
      SET testcaseid = '2.108';
      SET testcasedesc = 'Invoice Tolls should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.tolls <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.tolls <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) without Tolls');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 109
    ## Invoice AVITollAmount should always be greater than 0
	  ########################################################################
      SET testcaseid = '2.109';
      SET testcasedesc = 'Invoice AVITollAmount should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.avitollamount <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.avitollamount <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) without AVITollAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 110
    ## Invoice PBMTollAmount should always be greater than 0
	  ########################################################################
      SET testcaseid = '2.110';
      SET testcasedesc = 'Invoice PBMTollAmount should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.pbmtollamount <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.pbmtollamount <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) without PBMTollAmount');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

    ########################################################################
    ## TestCase# 111
    ## Invoice txncnt should always be greater than 0
	  ########################################################################
      SET testcaseid = '2.111';
      SET testcasedesc = 'Invoice txncnt should always be greater than 0';
      SET edw_updatedate = current_datetime();
      SET count = NULL;
      SET sampleinvoicenumber = NULL;
      SET count = (
        SELECT
            count(*) AS __count

        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.txncnt <= 0
      );
      SET sampleinvoicenumber = (
        SELECT
            fact_invoice.invoicenumber AS __sampleinvoicenumber
        FROM
          EDW_TRIPS.fact_invoice
        WHERE fact_invoice.migratedflag <> 1
         AND fact_invoice.txncnt <= 0
      LIMIT 1 
      );
      SET invoicecount = count;
      SET testresultdesc = concat(substr(CAST(invoicecount as STRING), 1, 30), ' -Invoice(s) without txncnt');
      IF count > 0 THEN
        SET teststatus = 'Failed';
      ELSE
        SET teststatus = 'Passed';
      END IF;
      INSERT INTO EDW_TRIPS_SUPPORT.item90_testresult
        VALUES (testdate, testrunid, CAST (testcaseid AS NUMERIC), testcasedesc, testresultdesc, teststatus, invoicecount, sampleinvoicenumber, datacategory, edw_updatedate)
      ;

      ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed loading Utility.Item90_TestResult', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      SELECT log_source, log_start_date, 'Completed loading Utility.Item90_TestResult', 'I';
      ## IF trace_flag = 1 THEN
      ##   CALL EDW_TRIPS_SUPPORT.FromLog(log_source, substr(CAST(log_start_date as STRING), 1, 23));
      SELECT log_source, substr(CAST(log_start_date as STRING), 1, 23);
      ## END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        SELECT log_source, log_start_date, error_message, 'E';
        ## CALL EDW_TRIPS_SUPPORT.FromLog(log_source, log_start_date);
        SELECT log_source, log_start_date;
        RAISE USING MESSAGE = error_message;
      END;
    END;
  END;