CREATE OR REPLACE PROCEDURE EDW_TRIPS.Fact_HV_FailuretopayCitation_Full_Load()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_HV_FailuretopayCitation table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0043993		Gouthami		2023-11-02	New!
											1. This proc loads the data for citations that's been given to the
											    Customers (HV).
											2. DPS officer can randomly give a citation to customer on one of their 
											   violated trip. They can cite another trip for the same customer only 
											   after 60 days.
											3. Don requested to add transaction details like Tolls & payments for that 
												trip and also Invoice related information for the same.
											
CHG0044527		Gouthami		 2024-02-08	 1. Pulled all the citations (49k) from RITE which are not migrated to TRIPS
											 2. Used Old query from Citation report (from Don) and created ref tables
												to use in this proc
===================================================================================================================
Example:
exec [dbo].[Fact_HV_FailuretopayCitation_Full_Load]
--EXEC Utility.FromLog 'dbo.Fact_HV_FailuretopayCitation', 1
SELECT TOP 100 'dbo.Fact_HV_FailuretopayCitation' Table_Name, * FROM dbo.Fact_HV_FailuretopayCitation ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'dbo.Fact_HV_FailuretopayCitation_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime();
      ##CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
      select log_source, log_start_date, 'Started full load', 'I', NULL, NULL;
      
      CREATE TEMPORARY TABLE _SESSION.cte_rite_customers AS (
            SELECT DISTINCT
                citation.violator_id
              FROM
                EDW_TRIPS_SUPPORT.Citation
              WHERE citation.violator_id NOT IN(
                SELECT
                    violatorid
                  FROM
                    LND_TBOS.TER_FailureToPayCitations
              )
          );
		  ##=============================================================================================================
		## Load dbo.Fact_HV_FailuretopayCitation
		##=============================================================================================================
          #DROP TABLE IF EXISTS EDW_TRIPS.Fact_HV_FailuretopayCitation_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_HV_FailuretopayCitation
	  CLUSTER BY FailureCitationID
        AS
          SELECT
              failurecitationid,
              coalesce(hv.hvid, -1) AS hvid,
              coalesce(ftp.violatorid, -1) AS customerid,
              coalesce(referencetripid, -1) AS citationid,
              coalesce(vt.tptripid, -1) AS tptripid,
              coalesce(ftp.citationinvoiceid, -1) AS citationinvoiceid,
              coalesce(fi.currmbsid, -1) AS mbsid,
              coalesce(ut.laneid, -1) AS laneid,
              coalesce(ftp.courtid, -1) AS courtid,
              coalesce(ftp.judgeid, -1) AS judgeid,
              coalesce(ftp.dpstrooperid, -1) AS dpstrooperid,
              coalesce(hvs.hvstatuslookupid, -1) AS citationstatusid,
              coalesce(ftp.agestageid, -1) AS invoiceagestageid,
              coalesce(fi.invoicenumber, -1) AS citationinvoicenumber,
              citationnumber,
              dpscitationnumber,
              ut.tripdayid,
              CAST(left(CAST(maildate as STRING FORMAT 'YYYYMMDD'), 8) as INT64) AS maildayid,
              CAST(left(CAST(dpscitationissueddate as STRING FORMAT 'YYYYMMDD'), 8) as INT64) AS dpscitationissueddayid,
              CAST(left(CAST(ftp.createddate as STRING FORMAT 'YYYYMMDD'), 8) as INT64) AS citationpackagecreateddayid,
              courtappearancedate,
              printdate,
              ut.firstpaiddate,
              ut.lastpaiddate,
              ftp.isactive AS activeflag,
              0 AS migratedflag,
              ut.tollamount AS txntollamount,
              ut.actualpaidamount AS txntollspaid,
              fi.tolls AS tollsoninvoice,
              fi.tollspaid AS tollspaidoninvoice,
              fi.fnfees + fi.snfees AS feesdueoninvoice,
              fi.fnfeespaid + fi.snfeespaid AS feespaidoninvoice,
              fi.tollsadjusted AS tollsadjustedoninvoice,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              LND_TBOS.TER_FailureToPayCitations AS ftp
              LEFT OUTER JOIN (
                SELECT
                    hv_0.violatorid,
                    hv_0.hvid,
                    hv_0.hvdesignationdate,
                    hv_0.hvterminationdate
                  FROM
                    LND_TBOS.TER_habitualviolators AS hv_0
              ) AS hv ON hv.violatorid = ftp.violatorid
               AND ftp.maildate BETWEEN hv.hvdesignationdate AND coalesce(hv.hvterminationdate, '2099-01-01 00:00:00.000')
              LEFT OUTER JOIN LND_TBOS.TER_HVStatusLookup AS hvs ON hvs.hvstatuslookupid = ftp.hvstatuslookupid
              LEFT OUTER JOIN LND_TBOS.TollPlus_TP_ViolatedTrips AS vt ON ftp.referencetripid = vt.citationid
              LEFT OUTER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS il ON vt.citationid = il.linkid
               AND il.txntype = 'VTOLL'
              LEFT OUTER JOIN EDW_TRIPS.Fact_Invoice AS fi ON CAST(fi.invoicenumber as STRING) = il.referenceinvoiceid
              LEFT OUTER JOIN EDW_TRIPS_STAGE.UnifiedTransaction AS ut ON ut.tptripid = vt.tptripid
            WHERE CAST(/* expression of unknown or erroneous type */ ftp.createddate as DATE) >= DATE "2013-01-01"
          UNION ALL
          SELECT
              row_number() OVER (ORDER BY hv.violatorid) + 9999999 AS failurecitationid,
              coalesce(hv.hvid, -1) AS hvid,
              coalesce(ftp.violator_id, -1) AS customerid,
              -1 AS citationid,
              viol.tptripid,
              -1 AS citationinvoiceid,
              -1 AS mbsid,
              l.laneid AS laneid,
              crt.courtid AS courtid,
              j.judgeid AS judgeid,
              -1 AS dpstrooperid,
              -1 AS citationstatusid,
              -1 AS invoiceagestageid,
              coalesce(c.vbi_invoice_id, -1) AS citationinvoicenumber,
              c.citation_nbr_list AS citationnumber,
              viol.dps_citation_nbr AS dpscitationnumber,
              NULL AS tripdayid,
              CAST(left(CAST(daydate as STRING FORMAT 'YYYYMMDD'), 8) as INT64) AS maildayid,
              NULL AS dpscitationissueddayid,
              NULL AS citationpackagecreateddayid,
              viol.appearance_date AS courtappearancedate,
              cast(NULL as datetime) AS printdate,
              cast(NULL as datetime) AS firstpaiddate,
              cast(NULL as datetime) AS lastpaiddate,
              NULL AS activeflag,
              1 AS migratedflag,
              c.tollsdue AS txntollamount,
              c.tollsonpaid AS txntollspaid,
              c.tollsdue AS tollsoninvoice,
              c.tollsonpaid AS tollspaidoninvoice,
              c.feesdue AS feesdueoninvoice,
              c.feespaid AS feespaidoninvoice,
              NULL AS tollsadjusted,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              _SESSION.cte_rite_customers AS ftp
              INNER JOIN EDW_TRIPS_SUPPORT.Citation AS c ON c.violator_id = ftp.violator_id
              LEFT OUTER JOIN (
                SELECT DISTINCT
                    viol_0.violator_id,
                    viol_0.tptripid,
                    viol_0.invoicenumber,
                    viol_0.appearance_date,
                    viol_0.dps_citation_nbr,
                    viol_0.lane_abbrev,
                    viol_0.court_name
                  FROM
                    EDW_TRIPS_SUPPORT.CitationViol AS viol_0
              ) AS viol ON c.violator_id = ftp.violator_id
               AND c.vbi_invoice_id = viol.invoicenumber
              LEFT OUTER JOIN EDW_TRIPS.Dim_Lane AS l ON viol.lane_abbrev = l.lanename
              LEFT OUTER JOIN EDW_TRIPS.Dim_Court AS crt ON crt.courtname = viol.court_name
              LEFT OUTER JOIN EDW_TRIPS.Dim_CourtJudge AS j ON j.courtid = crt.courtid
              LEFT OUTER JOIN (
                SELECT
                    hv_0.violatorid,
                    hv_0.hvid,
                    hv_0.hvdesignationdate,
                    hv_0.hvterminationdate
                  FROM
                    LND_TBOS.TER_HabitualViolators AS hv_0
              ) AS hv ON hv.violatorid = ftp.violator_id
               AND c.daydate BETWEEN hv.hvdesignationdate AND coalesce(hv.hvterminationdate, '2099-01-01 00:00:00.000')
      ;
      SET log_message = 'Loaded EDW_TRIPS.Fact_HV_FailuretopayCitation';
      ##CALL Utility.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      select log_source, log_start_date, log_message, 'I', -1, NULL;
      ## COLLECT STATISTICS is not supported in this dialect.
      ## COLLECT STATISTICS is not supported in this dialect.
      ## COLLECT STATISTICS is not supported in this dialect.
      ## COLLECT STATISTICS is not supported in this dialect.
      ## COLLECT STATISTICS is not supported in this dialect.
      ## COLLECT STATISTICS is not supported in this dialect.
      ## COLLECT STATISTICS is not supported in this dialect.
      ## COLLECT STATISTICS is not supported in this dialect.
      ## COLLECT STATISTICS is not supported in this dialect.
      #CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Fact_HV_FailuretopayCitation_NEW', 'EDW_TRIPS.Fact_HV_FailuretopayCitation');
      ##CALL Utility.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
      select log_source, log_start_date, 'Completed full load', 'I', NULL, NULL;

      IF trace_flag = 1 THEN
        ##CALL EDW_TRIPS_SUPPORT.FromLog(log_source, log_start_date);
        select log_source, log_start_date;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_HV_FailuretopayCitation' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_HV_FailuretopayCitation
        ORDER BY
          2 DESC
        LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        ##CALL utility.tolog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        ##CALL utility.fromlog(log_source, log_start_date);
        select log_source, log_start_date, error_message, 'E', NULL, NULL;
        select log_source, log_start_date;
        RAISE USING MESSAGE = error_message;
      END;
    END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Fact_HV_FailuretopayCitation_Full_Load

EXEC Utility.FromLog 'dbo.Fact_HV_FailuretopayCitation', 1
SELECT TOP 100 'dbo.Fact_HV_FailuretopayCitation' Table_Name, * FROM dbo.Fact_HV_FailuretopayCitation ORDER BY 2


Testing:
		--AND FTP.ReferenceTripID=1963099555
		--AND FTP.ViolatorID=2011319043 --(multiple Citations example)
		--FTP.ViolatorID=2011534070
		--WHERE FTP.FailureCitationID=72204
		--AND  FTP.ViolatorID=809137054

-- old code
--LEFT JOIN 
		--		( SELECT  A.InvoiceNumber
		--				  ,MAX(A.InvoiceID) InvoiceID 
		--				  ,MAX(MBSID) MBSID
		--		   FROM (
		--		   		  SELECT 
		--		   				InvoiceNumber,
		--		   				CASE WHEN AgeStageID=6 THEN MIN(InvoiceID) END AS InvoiceID,
		--		   				CASE WHEN AgeStageID=6 THEN MAX(MbsID) END AS MBSID -- select *
		--		   		   FROM LND_TBOS.TollPlus.MbsInvoices
		--		   		 -- WHERE InvoiceNumber=1223900310 
		--				  WHERE InvoiceID=89859664
		--		   		  GROUP BY InvoiceNumber,AgeStageID
		--		   	  ) A 
		--		   GROUP BY A.InvoiceNumber
		--		 ) MBS  ON MBS.InvoiceID=FTP.CitationInvoiceID


*/


  END;