CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_TERStatus_Full_Load`()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_TERStatus table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0043961		Gouthami		2023-10-30 	New!
											1. Created this to populate TER statuses into multiple dimension tables
											2. This dimension load includes all TER statuses pulled into a stage 
											   table and created multiple dim status tables using stage.
											3. Created below tables
												Stage.Dim_TERStatus
												dbo.Dim_HVStatus
												dbo.Dim_PaymentPlanStatus
												dbo.Dim_VRBStatus
												dbo.Dim_VBStatus
												dbo.Dim_VRBRemovalReason
												dbo.Dim_VBRemovalReason
												dbo.Dim_VRBRejectReason
												dbo.Dim_VRBAgency
												dbo.Dim_TER_LetterDeliverStatus
												dbo.Dim_Court
												dbo.Dim_CourtJudge
												dbo.Dim_DPSTrooper
CHG0044527		Gouthami		 2024-02-08 	Added Dim_Citationstatus

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_TERStatus_Full_Load

EXEC Utility.FromLog 'dbo.Dim_TERStatus_Full_Load', 1
SELECT TOP 100 'dbo.Dim_TERStatus' Table_Name, * FROM  dbo.Dim_TERStatus ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_TERStatus_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0; ## Testing
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    
    --=============================================================================================================
		-- Load Stage.Dim_TERStatus
		--=============================================================================================================
      --DROP TABLE IF EXISTS EDW_TRIPS_STAGE.Dim_TERStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.Dim_TERStatus CLUSTER BY statusid
        AS
          SELECT
              TER_HVStatusLookup.hvstatuslookupid AS statusid,
              TER_HVStatusLookup.statuscode,
              TER_HVStatusLookup.statusdescription,
              TER_HVStatusLookup.parentstatusid,
              TER_HVStatusLookup.isactive AS activeflag,
              TER_HVStatusLookup.detaileddesc,
              TER_HVStatusLookup.createddate,
              TER_HVStatusLookup.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TER_HVStatusLookup
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              0,
              'Unknown',
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS_STAGE.Dim_TERStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
     
		--=============================================================================================================
		-- Load dbo.Dim_PaymentPlanStatus
		--=============================================================================================================
      

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_PaymentPlanStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_PaymentPlanStatus CLUSTER BY paymentplanstatusid
        AS
          SELECT
              Dim_TERStatus.statusid AS paymentplanstatusid,
              Dim_TERStatus.statuscode AS paymentplanstatuscode,
              Dim_TERStatus.statusdescription AS paymentplanstatusdescription,
              Dim_TERStatus.parentstatusid,
              Dim_TERStatus.activeflag,
              Dim_TERStatus.detaileddesc,
              Dim_TERStatus.createddate,
              Dim_TERStatus.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.Dim_TERStatus
            WHERE Dim_TERStatus.parentstatusid = 43
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              0,
              'Unknown',
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_PaymentPlanStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));

      
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_PaymentPlanStatus_NEW', 'EDW_TRIPS.Dim_PaymentPlanStatus');

    --=============================================================================================================
		-- Load EDW_TRIPS.Dim_HVStatus
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_HVStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_HVStatus CLUSTER BY HVStatusID
        AS
          SELECT
              Dim_TERStatus.statusid AS hvstatusid,
              Dim_TERStatus.statuscode AS hvstatuscode,
              Dim_TERStatus.statusdescription AS hvstatusdescription,
              Dim_TERStatus.parentstatusid,
              Dim_TERStatus.activeflag,
              Dim_TERStatus.detaileddesc,
              Dim_TERStatus.createddate,
              Dim_TERStatus.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.Dim_TERStatus
            WHERE Dim_TERStatus.parentstatusid IN(
              0, 13, 23, 43
            )
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              0,
              'Unknown',
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_HVStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_HVStatus_NEW', 'EDW_TRIPS.Dim_HVStatus');

    --=============================================================================================================
		-- Load EDW_TRIPS.Dim_VRBStatus
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_VRBStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_VRBStatus CLUSTER BY vrbstatusid
        AS
          SELECT
              Dim_TERStatus.statusid AS vrbstatusid,
              Dim_TERStatus.statuscode AS vrbstatuscode,
              Dim_TERStatus.statusdescription AS vrbstatusdescription,
              Dim_TERStatus.parentstatusid,
              Dim_TERStatus.activeflag,
              Dim_TERStatus.detaileddesc,
              Dim_TERStatus.createddate,
              Dim_TERStatus.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.Dim_TERStatus
            WHERE Dim_TERStatus.parentstatusid = 13
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              0,
              'Unknown',
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_VRBStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
    
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_VRBStatus_NEW', 'EDW_TRIPS.Dim_VRBStatus');

    --=============================================================================================================
		-- Load EDW_TRIPS.Dim_VRBRemovalReason
		--=============================================================================================================
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_VRBRemovalReason;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_VRBRemovalReason CLUSTER BY vrbremovalreasonid
        AS
          SELECT
              Dim_TERStatus.statusid AS vrbremovalreasonid,
              Dim_TERStatus.statuscode AS vrbremovalreasoncode,
              Dim_TERStatus.statusdescription AS vrbremovalreasondescription,
              Dim_TERStatus.parentstatusid,
              Dim_TERStatus.activeflag,
              Dim_TERStatus.detaileddesc,
              Dim_TERStatus.createddate,
              Dim_TERStatus.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.Dim_TERStatus
            WHERE Dim_TERStatus.parentstatusid IN(
              21, 3
            )
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              0,
              'Unknown',
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_VRBRemovalReason';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      

      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_VRBRemovalReason_NEW', 'EDW_TRIPS.Dim_VRBRemovalReason');

    --=============================================================================================================
		-- Load EDW_TRIPS.Dim_VRBRejectReason
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_VRBRejectReason;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_VRBRejectReason CLUSTER BY vrbrejectreasonid
        AS
          SELECT
              TER_vrbrejectlookup.vrbrejectlookupid AS vrbrejectreasonid,
              TER_vrbrejectlookup.vrbrejectcode AS vrbrejectreasoncode,
              TER_vrbrejectlookup.vrbrejectdesc AS vrbrejectreasondescription,
              TER_vrbrejectlookup.isactive AS activeflag,
              TER_vrbrejectlookup.createddate,
              TER_vrbrejectlookup.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TER_vrbrejectlookup
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              0,
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_VRBRejectReason';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      

      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_VRBRejectReason_NEW', 'EDW_TRIPS.Dim_VRBRejectReason');

    --=============================================================================================================
		-- Load EDW_TRIPS.Dim_VRBAgency
		--=============================================================================================================
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_VRBAgency;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_VRBAgency CLUSTER BY vrbagencyid
        AS
          SELECT
              TER_vrbagencylookup.vrbagencylookupid AS vrbagencyid,
              TER_vrbagencylookup.vrbagencycode AS vrbagencycode,
              TER_vrbagencylookup.vrbagencydesc AS vrbagencydescription,
              TER_vrbagencylookup.isactive AS activeflag,
              TER_vrbagencylookup.createddate,
              TER_vrbagencylookup.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TER_vrbagencylookup
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              0,
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_VRBAgency';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      

      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_VRBAgency_NEW', 'EDW_TRIPS.Dim_VRBAgency');

    --=============================================================================================================
		-- Load EDW_TRIPS.Dim_VBStatus
		--=============================================================================================================
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_VBStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_VBStatus CLUSTER BY vbstatusid
        AS
          SELECT
              Dim_TERStatus.statusid AS vbstatusid,
              Dim_TERStatus.statuscode AS vbstatuscode,
              Dim_TERStatus.statusdescription AS vbstatusdescription,
              Dim_TERStatus.parentstatusid,
              Dim_TERStatus.activeflag,
              Dim_TERStatus.detaileddesc,
              Dim_TERStatus.createddate,
              Dim_TERStatus.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.Dim_TERStatus
            WHERE Dim_TERStatus.parentstatusid = 23
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              0,
              'Unknown',
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.dim_VBStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));

      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_VBStatus_NEW', 'EDW_TRIPS.Dim_VBStatus');

    --=============================================================================================================
		-- Load EDW_TRIPS.Dim_VBRemovalReason
		--=============================================================================================================
		
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_VBRemovalReason;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_VBRemovalReason CLUSTER BY vbremovalreasonid
        AS
          SELECT
              Dim_TERStatus.statusid AS vbremovalreasonid,
              Dim_TERStatus.statuscode AS vbremovalreasoncode,
              Dim_TERStatus.statusdescription AS vbremovalreasondescription,
              Dim_TERStatus.parentstatusid,
              Dim_TERStatus.activeflag,
              Dim_TERStatus.detaileddesc,
              Dim_TERStatus.createddate,
              Dim_TERStatus.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.Dim_TERStatus
            WHERE Dim_TERStatus.parentstatusid IN(
              3, 27
            )
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              0,
              'Unknown',
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_VBRemovalReason';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
     
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_VBRemovalReason_NEW', 'EDW_TRIPS.Dim_VBRemovalReason');

    --=============================================================================================================
		-- Load EDW_TRIPS.Dim_TER_LetterDeliverStatus
		--=============================================================================================================
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_TER_LetterDeliverStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_TER_LetterDeliverStatus CLUSTER BY letterdeliverstatusid
        AS
          SELECT
              ref_lookuptypecodes_hierarchy.l2_lookuptypecodeid AS letterdeliverstatusid,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecode AS letterdeliverstatuscode,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecodedesc AS letterdeliverstatusdesc,
              ref_lookuptypecodes_hierarchy.l1_lookuptypecodeid,
              ref_lookuptypecodes_hierarchy.l1_lookuptypecode,
              ref_lookuptypecodes_hierarchy.l1_lookuptypecodedesc,
              ref_lookuptypecodes_hierarchy.edw_updatedate
            FROM
              EDW_TRIPS_STAGE.ref_lookuptypecodes_hierarchy
            WHERE ref_lookuptypecodes_hierarchy.l1_lookuptypecodeid = 3853
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              'Unknown',
              'Unknown',
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_TER_LetterDeliverStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_TER_LetterDeliverStatus_NEW', 'EDW_TRIPS.Dim_TER_LetterDeliverStatus');

    --=============================================================================================================
		-- Load EDW_TRIPS.Dim_CitationStatus
		--=============================================================================================================
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_CitationStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_CitationStatus CLUSTER BY citationstatusid
        AS
          SELECT
              Dim_TERStatus.statusid AS citationstatusid,
              Dim_TERStatus.statuscode AS citationstatuscode,
              Dim_TERStatus.statusdescription AS citationstatusdescription,
              Dim_TERStatus.parentstatusid,
              Dim_TERStatus.activeflag,
              Dim_TERStatus.detaileddesc,
              Dim_TERStatus.createddate,
              Dim_TERStatus.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.Dim_TERStatus
            WHERE Dim_TERStatus.parentstatusid IN(
              117, 69, 118
            )
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              0,
              'Unknown',
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_CitationStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_CitationStatus_NEW', 'EDW_TRIPS.Dim_CitationStatus');

    --=============================================================================================================
		-- Load EDW_TRIPS.Dim_Court
		--=============================================================================================================
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_Court;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Court CLUSTER BY courtid
        AS
          SELECT
              Court_courts.courtid,
              Court_courts.countyid,
              Court_courts.courtname,
              Court_courts.addressline1,
              Court_courts.addressline2,
              Court_courts.city,
              Court_courts.state,
              CAST (Court_courts.zip1 AS INT64) as zip1,
              CAST(Court_courts.zip2 AS INT64) as zip2,
              Court_courts.starteffectivedate,
              Court_courts.endeffectivedate,
              Court_courts.precinctnumber,
              Court_courts.placenumber,
              Court_courts.telephonenumber,
              Court_courts.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.Court_courts
          UNION ALL
          SELECT
              -1,
              -1,
              'Unknown',
              'Unknown',
              'Unknown',
              'Unknown',
              'Unknown',
              -1,
              -1,
              current_datetime(),
              current_datetime(),
              'Unknown',
              'Unknown',
              'Unknown',
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_Court';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap( 'EDW_TRIPS.Dim_Court_NEW',  'EDW_TRIPS.Dim_Court');

      --=============================================================================================================
      -- Load dbo.Dim_CourtJudge
      --=============================================================================================================
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_CourtJudge;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_CourtJudge CLUSTER BY judgeid
        AS
          SELECT
              Court_courtjudges.judgeid,
              Court_courtjudges.courtid,
              Court_courtjudges.lastname,
              Court_courtjudges.firstname,
              Court_courtjudges.starteffectivedate,
              Court_courtjudges.endeffectivedate,
              Court_courtjudges.createddate,
              Court_courtjudges.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.Court_courtjudges
          UNION ALL
          SELECT
              -1,
              -1,
              'Unknown',
              'Unknown',
              current_datetime(),
              current_datetime(),
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_CourtJudge';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));

      
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap( 'EDW_TRIPS.Dim_CourtJudge_NEW',  'EDW_TRIPS.Dim_CourtJudge');

    --=============================================================================================================
		-- Load dbo.Dim_DPSTrooper
		--=============================================================================================================
		

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_DPSTrooper;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_DPSTrooper CLUSTER BY dpstrooperid
        AS
          SELECT
              TER_dpstrooper.dpstrooperid,
              TER_dpstrooper.firstname,
              TER_dpstrooper.lastname,
              TER_dpstrooper.area,
              TER_dpstrooper.district,
              TER_dpstrooper.idnumber,
              TER_dpstrooper.region,
              TER_dpstrooper.channelid,
              TER_dpstrooper.icnid,
              TER_dpstrooper.troopersignatureimage,
              TER_dpstrooper.isactive,
              TER_dpstrooper.filepathconfigurationid,
              TER_dpstrooper.createddate,
              TER_dpstrooper.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TER_dpstrooper
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              'Unknown',
              'Unknown',
              CAST(-1 as string),
              'Unknown',
              -1,
              -1,
              'Unknown',
              -1,
              -1,
              current_datetime(),
              current_datetime(),
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_DPSTrooper';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      
      -- Table swap
      --TableSwap is Not Required, using  Create or Replace Table!
      --CALL EDW_TRIPS_SUPPORT.TableSwap( 'EDW_TRIPS.Dim_DPSTrooper_NEW',  'EDW_TRIPS.Dim_DPSTrooper');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    
      -- Show results
      IF trace_flag = 1 THEN
        -- CALL EDW_TRIPS_SUPPORT.FromLog(log_source, substr(CAST(log_start_date as STRING), 1, 23));
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'Stage.Dim_TERStatus' AS tablename,
            Dim_TERStatus.*
          FROM
            EDW_TRIPS_STAGE.Dim_TERStatus
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_HVStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_HVStatus
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_PaymentPlanStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_PaymentPlanStatus
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_VRBStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_VRBStatus
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_VBStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_VBStatus
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_VRBRemovalReason' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_VRBRemovalReason
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_VBRemovalReason' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_VBRemovalReason
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_VRBRejectReason' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_VRBRejectReason
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_VRBAgency' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_VRBAgency
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_TER_LetterDeliverStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_TER_LetterDeliverStatus
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_Court' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Court
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_CourtJudge' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_CourtJudge
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_DPSTrooper' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_DPSTrooper
        ORDER BY 2
           LIMIT 100
        ;
        SELECT
             'EDW_TRIPS.Dim_CitationStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_CitationStatus
        ORDER BY 2
           LIMIT 100
        ;
      END IF;  
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;
    END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_TERStatus_Load

EXEC Utility.FromLog 'dbo.Dim_TERStatus', 1
SELECT TOP 100 'dbo.Dim_TERStatus' Table_Name, * FROM dbo.Dim_TERStatus ORDER BY 2

SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_TERStatus%' ORDER BY logdate desc


--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/
  END;