CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Collections_FileCreationScript`()
BEGIN

/*
####################################################################################################
Proc Description: 
----------------------------------------------------------------------------------------------------
 1. Load all 4 Export Tables of Collections Export

================================================================================================
Change Log:
--------------------------------------------------------------------------------------------
********    EGen        07-29-2024     New!
================================================================================================
Example:   
--------------------------------------------------------------------------------------------------

#######################################################################################
*/

  DECLARE log_source STRING DEFAULT 'Collections_FileCreation Script';
  DECLARE log_start_date DATETIME;
 
  SET log_start_date = current_datetime('America/Chicago');

  CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started Collections_FileCreation Script Execution', 'I', CAST(NULL as INT64), CAST(NULL as STRING));

  --File1 Primary_Collection_Agency_File_LESPAM

  DROP TABLE IF EXISTS FILES_EXPORT.Primary_Collection_Agency_File_Lespam;
  CREATE TABLE FILES_EXPORT.Primary_Collection_Agency_File_Lespam
    AS
      SELECT
          Distinct tt.*
        FROM
          (
            SELECT
                tp1.violatorid,
                tp1.invoicenumber,
                tp1.zcinvoicedate,
                tp1.currentinvoicestatus,
                tp1.tolls,
                tp1.fees,
                tp1.invoiceamount,
                tp1.primary_collection_agency,
                tp1.no_of_times_sent_to_primary,
                tp1.created_at_primary_collection_agency,
                tp1.seconday_collection_agency,
                tp1.no_of_times_sent_to_secondary,
                tp1.created_at_secondary_collection_agency,
                tp2.paymentplanid,
                tp2.locationname,
                tp2.channelname,
                tp2.paymentdate,
                tp2.invoicepaid,
                tp2.tollpaid,
                tp2.feepaid,
                tp2.adjustmentamount,
                tp2.vtollamount,
                tp2.vtollposteddate
              FROM
                EDW_TRIPS.CollectionsInvoiceTotalPayments AS tp1
                LEFT OUTER JOIN EDW_TRIPS.CollectionsInvoiceTotalPayments AS tp2 ON tp1.invoicenumber = tp2.invoicenumber
				        AND coalesce(tp2.channelname, '-1') = coalesce(tp1.channelname, '-1')
				        AND coalesce(tp2.locationname, '-1') = coalesce(tp1.locationname, '-1')
				        AND coalesce(tp1.paymentdate, -1) = coalesce(tp2.paymentdate, -1)
                AND tp2.paymentdate >= CAST(CAST( tp1.created_at_primary_collection_agency as STRING FORMAT 'YYYYMMDD') as INT64)
                AND tp2.paymentdate < coalesce(CAST(CAST(tp1.created_at_secondary_collection_agency AS STRING FORMAT 'YYYYMMDD') as INT64), CAST(CAST(current_datetime() as STRING FORMAT 'YYYYMMDD') as INT64))
              WHERE tp1.primary_collection_agency = 'Duncan Solutions (LES/PAM)'
              AND tp1.vtollamount IS NULL
            UNION DISTINCT
            SELECT
                CollectionsInvoiceTotalPayments.violatorid,
                CollectionsInvoiceTotalPayments.invoicenumber,
                CollectionsInvoiceTotalPayments.zcinvoicedate,
                CollectionsInvoiceTotalPayments.currentinvoicestatus,
                CollectionsInvoiceTotalPayments.tolls,
                CollectionsInvoiceTotalPayments.fees,
                CollectionsInvoiceTotalPayments.invoiceamount,
                CollectionsInvoiceTotalPayments.primary_collection_agency,
                CollectionsInvoiceTotalPayments.no_of_times_sent_to_primary,
                CollectionsInvoiceTotalPayments.created_at_primary_collection_agency,
                CollectionsInvoiceTotalPayments.seconday_collection_agency,
                CollectionsInvoiceTotalPayments.no_of_times_sent_to_secondary,
                CollectionsInvoiceTotalPayments.created_at_secondary_collection_agency,
                CollectionsInvoiceTotalPayments.paymentplanid,
                NULL AS locationname,
                NULL AS channelname,
                NULL AS paymentdate,
                NULL AS invoicepaid,
                NULL AS tollpaid,
                NULL AS feepaid,
                NULL AS adjustmentamount,
                CollectionsInvoiceTotalPayments.vtollamount,
                CollectionsInvoiceTotalPayments.vtollposteddate
              FROM
                EDW_TRIPS.CollectionsInvoiceTotalPayments
              WHERE CollectionsInvoiceTotalPayments.primary_collection_agency = 'Duncan Solutions (LES/PAM)'
              AND CollectionsInvoiceTotalPayments.vtollamount > 0
              AND CollectionsInvoiceTotalPayments.vtollposteddate >= CollectionsInvoiceTotalPayments.created_at_primary_collection_agency
              AND CollectionsInvoiceTotalPayments.vtollposteddate < coalesce(CollectionsInvoiceTotalPayments.created_at_secondary_collection_agency, current_datetime())
          ) AS tt
          order by tt.invoicenumber,tt.violatorid
  ;

  ---FILE2  Primary_Collection_Agency_File_CPA 

  DROP TABLE IF EXISTS FILES_EXPORT.Primary_Collection_Agency_File_Cpa;
  CREATE TABLE FILES_EXPORT.Primary_Collection_Agency_File_Cpa
    AS
      SELECT
          DISTINCT tt.*
        FROM
          (
            SELECT
                tp1.violatorid,
                tp1.invoicenumber,
                tp1.zcinvoicedate,
                tp1.currentinvoicestatus,
                tp1.tolls,
                tp1.fees,
                tp1.invoiceamount,
                tp1.primary_collection_agency,
                tp1.no_of_times_sent_to_primary,
                tp1.created_at_primary_collection_agency,
                tp1.seconday_collection_agency,
                tp1.no_of_times_sent_to_secondary,
                tp1.created_at_secondary_collection_agency,
                tp2.paymentplanid,
                tp2.locationname,
                tp2.channelname,
                tp2.paymentdate,
                tp2.invoicepaid,
                tp2.tollpaid,
                tp2.feepaid,
                tp2.adjustmentamount,
                tp2.vtollamount,
                tp2.vtollposteddate
              FROM
                EDW_TRIPS.CollectionsInvoiceTotalPayments AS tp1
                LEFT OUTER JOIN EDW_TRIPS.CollectionsInvoiceTotalPayments AS tp2 ON tp1.invoicenumber = tp2.invoicenumber
                AND coalesce(tp2.channelname, '-1') = coalesce(tp1.channelname, '-1')
				        AND coalesce(tp2.locationname, '-1') = coalesce(tp1.locationname, '-1')
				        AND coalesce(tp1.paymentdate, -1) = coalesce(tp2.paymentdate, -1)
                AND tp2.paymentdate >= CAST(CAST( tp1.created_at_primary_collection_agency as STRING FORMAT 'YYYYMMDD') as INT64)
                AND tp2.paymentdate < coalesce(CAST(CAST(tp1.created_at_secondary_collection_agency AS STRING FORMAT 'YYYYMMDD') as INT64), CAST(CAST(current_datetime() as STRING FORMAT 'YYYYMMDD') as INT64))
              WHERE tp1.primary_collection_agency = 'Credit Protected Assoc. (CPA)'
              AND tp1.vtollamount IS NULL
            UNION DISTINCT
            SELECT
                CollectionsInvoiceTotalPayments.violatorid,
                CollectionsInvoiceTotalPayments.invoicenumber,
                CollectionsInvoiceTotalPayments.zcinvoicedate,
                CollectionsInvoiceTotalPayments.currentinvoicestatus,
                CollectionsInvoiceTotalPayments.tolls,
                CollectionsInvoiceTotalPayments.fees,
                CollectionsInvoiceTotalPayments.invoiceamount,
                CollectionsInvoiceTotalPayments.primary_collection_agency,
                CollectionsInvoiceTotalPayments.no_of_times_sent_to_primary,
                CollectionsInvoiceTotalPayments.created_at_primary_collection_agency,
                CollectionsInvoiceTotalPayments.seconday_collection_agency,
                CollectionsInvoiceTotalPayments.no_of_times_sent_to_secondary,
                CollectionsInvoiceTotalPayments.created_at_secondary_collection_agency,
                CollectionsInvoiceTotalPayments.paymentplanid,
                NULL AS locationname,
                NULL AS channelname,
                NULL AS paymentdate,
                NULL AS invoicepaid,
                NULL AS tollpaid,
                NULL AS feepaid,
                NULL AS adjustmentamount,
                CollectionsInvoiceTotalPayments.vtollamount,
                CollectionsInvoiceTotalPayments.vtollposteddate
              FROM
                EDW_TRIPS.CollectionsInvoiceTotalPayments
              WHERE CollectionsInvoiceTotalPayments.primary_collection_agency = 'Credit Protected Assoc. (CPA)'
              AND CollectionsInvoiceTotalPayments.vtollamount > 0
              AND CollectionsInvoiceTotalPayments.vtollposteddate >= CollectionsInvoiceTotalPayments.created_at_primary_collection_agency
              AND CollectionsInvoiceTotalPayments.vtollposteddate < coalesce(CollectionsInvoiceTotalPayments.created_at_secondary_collection_agency, current_datetime())
          ) AS tt
          order by tt.invoicenumber,tt.violatorid
  ;

  --File3 --Seconday_Collection_Agency_File_CMI

  DROP TABLE IF EXISTS FILES_EXPORT.Seconday_Collection_Agency_File_Cmi;
  CREATE TABLE FILES_EXPORT.Seconday_Collection_Agency_File_Cmi
    AS
      SELECT
        DISTINCT   tt.*
        FROM
          (
            SELECT
                tp1.violatorid,
                tp1.invoicenumber,
                tp1.zcinvoicedate,
                tp1.currentinvoicestatus,
                tp1.tolls,
                tp1.fees,
                tp1.invoiceamount,
                tp1.primary_collection_agency,
                tp1.no_of_times_sent_to_primary,
                tp1.created_at_primary_collection_agency,
                tp1.seconday_collection_agency,
                tp1.no_of_times_sent_to_secondary,
                tp1.created_at_secondary_collection_agency,
                tp2.paymentplanid,
                tp2.locationname,
                tp2.channelname,
                tp2.paymentdate,
                tp2.invoicepaid,
                tp2.tollpaid,
                tp2.feepaid,
                tp2.adjustmentamount,
                tp2.vtollamount,
                tp2.vtollposteddate
              FROM
                EDW_TRIPS.CollectionsInvoiceTotalPayments AS tp1
                LEFT OUTER JOIN EDW_TRIPS.CollectionsInvoiceTotalPayments AS tp2 ON tp1.invoicenumber = tp2.invoicenumber
                AND coalesce(tp2.channelname, '-1') = coalesce(tp1.channelname, '-1')
				        AND coalesce(tp2.locationname, '-1') = coalesce(tp1.locationname, '-1')
				        AND coalesce(tp1.paymentdate, -1) = coalesce(tp2.paymentdate, -1)               
                AND tp2.paymentdate >= coalesce(CAST(CAST(tp1.created_at_secondary_collection_agency AS STRING FORMAT 'YYYYMMDD') as INT64), CAST(CAST(current_datetime() as STRING FORMAT 'YYYYMMDD') as INT64))
              WHERE tp1.seconday_collection_agency = 'Credit Management Group (CMI)'
              AND tp1.vtollamount IS NULL
            UNION DISTINCT
            SELECT
                CollectionsInvoiceTotalPayments.violatorid,
                CollectionsInvoiceTotalPayments.invoicenumber,
                CollectionsInvoiceTotalPayments.zcinvoicedate,
                CollectionsInvoiceTotalPayments.currentinvoicestatus,
                CollectionsInvoiceTotalPayments.tolls,
                CollectionsInvoiceTotalPayments.fees,
                CollectionsInvoiceTotalPayments.invoiceamount,
                CollectionsInvoiceTotalPayments.primary_collection_agency,
                CollectionsInvoiceTotalPayments.no_of_times_sent_to_primary,
                CollectionsInvoiceTotalPayments.created_at_primary_collection_agency,
                CollectionsInvoiceTotalPayments.seconday_collection_agency,
                CollectionsInvoiceTotalPayments.no_of_times_sent_to_secondary,
                CollectionsInvoiceTotalPayments.created_at_secondary_collection_agency,
                CollectionsInvoiceTotalPayments.paymentplanid,
                NULL AS locationname,
                NULL AS channelname,
                NULL AS paymentdate,
                NULL AS invoicepaid,
                NULL AS tollpaid,
                NULL AS feepaid,
                NULL AS adjustmentamount,
                CollectionsInvoiceTotalPayments.vtollamount,
                CollectionsInvoiceTotalPayments.vtollposteddate
              FROM
                EDW_TRIPS.CollectionsInvoiceTotalPayments
              WHERE CollectionsInvoiceTotalPayments.seconday_collection_agency = 'Credit Management Group (CMI)'
              AND CollectionsInvoiceTotalPayments.vtollamount > 0
              AND CollectionsInvoiceTotalPayments.vtollposteddate >= coalesce(CollectionsInvoiceTotalPayments.created_at_secondary_collection_agency, current_datetime())
          ) AS tt
          order by tt.invoicenumber,tt.violatorid
  ;

  --File4 --Seconday_Collection_Agency_File_SWC

  DROP TABLE IF EXISTS FILES_EXPORT.Seconday_Collection_Agency_File_Swc;
  CREATE TABLE FILES_EXPORT.Seconday_Collection_Agency_File_Swc
    AS
      SELECT
         DISTINCT  tt.*
        FROM
          (
            SELECT
                tp1.violatorid,
                tp1.invoicenumber,
                tp1.zcinvoicedate,
                tp1.currentinvoicestatus,
                tp1.tolls,
                tp1.fees,
                tp1.invoiceamount,
                tp1.primary_collection_agency,
                tp1.no_of_times_sent_to_primary,
                tp1.created_at_primary_collection_agency,
                tp1.seconday_collection_agency,
                tp1.no_of_times_sent_to_secondary,
                tp1.created_at_secondary_collection_agency,
                tp2.paymentplanid,
                tp2.locationname,
                tp2.channelname,
                tp2.paymentdate,
                tp2.invoicepaid,
                tp2.tollpaid,
                tp2.feepaid,
                tp2.adjustmentamount,
                tp2.vtollamount,
                tp2.vtollposteddate
              FROM
                EDW_TRIPS.CollectionsInvoiceTotalPayments AS tp1
                LEFT OUTER JOIN EDW_TRIPS.CollectionsInvoiceTotalPayments AS tp2 ON tp1.invoicenumber = tp2.invoicenumber
                AND coalesce(tp2.channelname, '-1') = coalesce(tp1.channelname, '-1')
				        AND coalesce(tp2.locationname, '-1') = coalesce(tp1.locationname, '-1')
				        AND coalesce(tp1.paymentdate, -1) = coalesce(tp2.paymentdate, -1)                
                AND tp2.paymentdate >= coalesce(CAST(CAST(tp1.created_at_secondary_collection_agency AS STRING FORMAT 'YYYYMMDD') as INT64), CAST(CAST(current_datetime() as STRING FORMAT 'YYYYMMDD') as INT64))
              WHERE tp1.seconday_collection_agency = 'Southwest Credit Systems (SWC)'
              AND tp1.vtollamount IS NULL
            UNION DISTINCT
            SELECT
                CollectionsInvoiceTotalPayments.violatorid,
                CollectionsInvoiceTotalPayments.invoicenumber,
                CollectionsInvoiceTotalPayments.zcinvoicedate,
                CollectionsInvoiceTotalPayments.currentinvoicestatus,
                CollectionsInvoiceTotalPayments.tolls,
                CollectionsInvoiceTotalPayments.fees,
                CollectionsInvoiceTotalPayments.invoiceamount,
                CollectionsInvoiceTotalPayments.primary_collection_agency,
                CollectionsInvoiceTotalPayments.no_of_times_sent_to_primary,
                CollectionsInvoiceTotalPayments.created_at_primary_collection_agency,
                CollectionsInvoiceTotalPayments.seconday_collection_agency,
                CollectionsInvoiceTotalPayments.no_of_times_sent_to_secondary,
                CollectionsInvoiceTotalPayments.created_at_secondary_collection_agency,
                CollectionsInvoiceTotalPayments.paymentplanid,
                NULL AS locationname,
                NULL AS channelname,
                NULL AS paymentdate,
                NULL AS invoicepaid,
                NULL AS tollpaid,
                NULL AS feepaid,
                NULL AS adjustmentamount,
                CollectionsInvoiceTotalPayments.vtollamount,
                CollectionsInvoiceTotalPayments.vtollposteddate
              FROM
                EDW_TRIPS.CollectionsInvoiceTotalPayments
              WHERE CollectionsInvoiceTotalPayments.seconday_collection_agency = 'Southwest Credit Systems (SWC)'
              AND CollectionsInvoiceTotalPayments.vtollamount > 0
              AND CollectionsInvoiceTotalPayments.vtollposteddate >= coalesce(CollectionsInvoiceTotalPayments.created_at_secondary_collection_agency, current_datetime())
          ) AS tt
          order by tt.invoicenumber,tt.violatorid
  ;

  CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Collections_FileCreation Script Execution Completed Successfully', 'I', CAST(NULL as INT64), CAST(NULL as STRING));

  EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;
      END;

END;