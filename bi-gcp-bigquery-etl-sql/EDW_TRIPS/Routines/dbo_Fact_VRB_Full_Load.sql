CREATE OR REPLACE PROCEDURE EDW_TRIPS.Fact_VRB_Full_Load()

  BEGIN
  /*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_VRB table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0043961		    Gouthami	2023-10-30	New!
                                        1. This fact table is created to pull the Vehicle registration block 
                                          data for an HV. (For an HV, there are multiple VRB's)
CHG0044321		    Gouthami	2024-01-08	Pulled RITE data for VRB dates. TRIPS did not migrate the correct data
                                        for migrated VRB's
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_VRB_Full_Load

EXEC Utility.FromLog 'dbo.Fact_VRB', 1
SELECT TOP 100 'dbo.Fact_VRB' Table_Name, * FROM dbo.Fact_VRB ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_VRB_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0; -- Testing
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      select log_source, log_start_date, 'Started full load', 'I';
      --=============================================================================================================
      -- Load dbo.Fact_VRB
      --=============================================================================================================

      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_VRB CLUSTER BY hvid
      AS
        SELECT
            main.vrbid,
            coalesce(main.hvid, -1) AS hvid,
            coalesce(main.customerid, -1) AS customerid,
            coalesce(main.vehicleid, -1) AS vehicleid,
            coalesce(main.vrbstatuslookupid, -1) AS vrbstatusid,
            coalesce(main.vrbagencyid, -1) AS vrbagencyid,
            coalesce(main.vrbrejectreasonid, -1) AS vrbrejectreasonid,
            coalesce(main.vrbremovalreasonid, -1) AS vrbremovalreasonid,
            coalesce(l.letterdeliverstatusid, -1) AS vrbletterdeliverstatusid,
            CAST(left(CAST( main.vrbrequesteddate AS STRING FORMAT 'YYYYMMDD'), 8) as INT64) AS vrbrequesteddayid,
            CAST(left(CAST( main.vrbapplieddate as STRING FORMAT 'YYYYMMDD'), 8) as INT64) AS vrbapplieddayid,
            CAST(left(CAST(main.vrbremoveddate as STRING FORMAT 'YYYYMMDD'), 8) as INT64) AS vrbremoveddayid,
            main.vrbactiveflag,
            main.dallasscofflaw AS dallasscofflawflag,
            main.vrbcreateddate,
            main.vrbrejectiondate,
            l.vrblettermaileddate,
            l.vrbletterdelivereddate,
            coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate -- select *
        FROM
          (
            SELECT
                row_number() OVER (PARTITION BY vrb.hvid ORDER BY vrb.vrbid DESC) AS rn,
                vrb.vrbid,
                vrb.hvid,
                hv.customerid,
                hv.vehicleid,
                vrb.vrbagencylookupid AS vrbagencyid,
                vrb.vrbrejectlookupid AS vrbrejectreasonid,
                vrb.vrbremovallookupid AS vrbremovalreasonid,
                hvs.statusdescription AS vrbstatusdescription,
                hvs.hvstatuslookupid AS vrbstatuslookupid,
                ag.vrbagencydesc AS vrbagencyname,
                rej.vrbrejectdesc AS vrbrejectreason,
                hvs1.statusdescription AS vrbremovalreason,
                hv.licenseplatenumber,
                hv.licenseplatestate,
                vrb.isactive AS vrbactiveflag,
                vrd.dallasscofflaw,
                vrb.createddate AS vrbcreateddate,
                requesteddate AS vrbrequesteddate,
                CASE
                  WHEN vrb.removeddate < vrb.placeddate
                    AND vrb.removeddate IS NOT NULL THEN ref.applieddate
                  ELSE coalesce(placeddate, ref.applieddate)
                END AS vrbapplieddate,
                vrb.removeddate AS vrbremoveddate,
                vrb.rejectiondate AS vrbrejectiondate,
                vrb.lnd_updatedate --SELECT COUNT(*) -- 1155505
            FROM
              LND_TBOS.TER_VehicleRegBlocks AS vrb
              INNER JOIN EDW_TRIPS.Dim_HabitualViolator AS hv 
                ON hv.hvid = vrb.hvid
              LEFT OUTER JOIN EDW_TRIPS_SUPPORT.vw_Vrb AS ref 
                ON ref.vrbid = vrb.vrbid
              LEFT OUTER JOIN LND_TBOS.TER_VRBRejectLookup AS rej 
                ON rej.vrbrejectlookupid = vrb.vrbrejectlookupid
              LEFT OUTER JOIN LND_TBOS.TER_HVStatusLookup AS hvs 
                ON hvs.hvstatuslookupid = vrb.statuslookupid
              LEFT OUTER JOIN LND_TBOS.TER_HVStatusLookup AS hvs1 
                ON hvs1.hvstatuslookupid = vrb.vrbremovallookupid
              LEFT OUTER JOIN LND_TBOS.TER_VRBAgencyLookup AS ag 
                ON ag.vrbagencylookupid = vrb.vrbagencylookupid
              LEFT OUTER JOIN 
              (
                SELECT DISTINCT
                    vrd_0.vrbid,
                    vrd_0.dallasscofflaw
                  FROM
                    LND_TBOS.TER_VRBRequestDallas AS vrd_0   -- vrd is translated as vrd_0 as same alias is used again below
                  WHERE vrd_0.offencedate IS NOT NULL
              ) AS vrd ON vrd.vrbid = vrb.vrbid
          ) AS main

        LEFT OUTER JOIN 
          (
            SELECT
                hv.hvid,
                oc.communicationdate AS vrblettermaileddate,
                oc.deliverydate AS vrbletterdelivereddate,
                oc.description,
                r.lookuptypecodeid AS letterdeliverstatusid,
                row_number() OVER (PARTITION BY hv.hvid ORDER BY oc.communicationdate DESC) AS rn
            FROM
              LND_TBOS.TER_HabitualViolators AS hv
              INNER JOIN 
              (
                  SELECT DISTINCT
                    Notifications_CustomerNotificationQueue.linkid,
                    Notifications_CustomerNotificationQueue.customernotificationqueueid,
                    Notifications_CustomerNotificationQueue.notifstatus
                  FROM
                    LND_TBOS.Notifications_CustomerNotificationQueue
                  WHERE Notifications_CustomerNotificationQueue.linksource = 'TER.HabitualViolators'
              ) AS notif 
                ON hv.hvid = notif.linkid
              INNER JOIN LND_TBOS.DocMgr_TP_Customer_OutboundCommunications AS oc 
                ON oc.queueid = notif.customernotificationqueueid
                  AND oc.documenttype IN('VRBLetter', 'VRB')
              INNER JOIN LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy AS r 
                ON r.lookuptypecodeid = notif.notifstatus
                  AND parent_lookuptypecodeid = 3853
          ) AS l 
            ON l.hvid = main.hvid
              AND l.rn = main.rn
        ;

      SET log_message = 'Loaded EDW_TRIPS.Fact_VRB';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      ## Show results
      IF trace_flag = 1 THEN
        select log_source,  substr(CAST(log_start_date as STRING), 1, 23); -- Replacement for FromLog
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_VRB' AS tablename,
            *
        FROM
          EDW_TRIPS.Fact_VRB
        ORDER BY 2 DESC
        LIMIT 1000
        ;
      END IF;

      EXCEPTION WHEN ERROR THEN
        BEGIN
          DECLARE error_message STRING DEFAULT @@error.message;
          CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));

          select log_source, log_start_date;   -- Replacement for FromLog 
          RAISE USING MESSAGE = error_message; -- Rethrow the error!
        END;
    END;
  /*
  --===============================================================================================================
  -- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
  --===============================================================================================================
  EXEC dbo.Fact_VRB_Load

  EXEC Utility.FromLog 'dbo.Fact_VRB', 1
  SELECT TOP 100 'dbo.Fact_VRB' Table_Name, * FROM dbo.Fact_VRB ORDER BY 2


  select * FROM dbo.Fact_VRB ORDER BY 2
  select count(*) FROM dbo.Fact_VRB --110984 
  select * FROM edw_trips.dbo.Fact_VRB  where customerid = 806539432
  select * FROM edw_trips_dev.dbo.Fact_VRB  where customerid = 806539432


  WHERE VRB.HVID IN (185338,9,542089,542015)
  --ORDER BY HVID
  ---------------------------------------------------OLD CODE--------------------------------------------------------
            SELECT VRB.VRBID,
                VRB.HVID,  
                HV.ViolatorID CustomerID,
                VRB.StatusLookupID VRBStatusID,
                HVS.StatusDescription VRBStatusDescription,
                VRB.VRBAgencyLookupID VRBAgencyID,
                AG.VRBAgencyDesc VRBAgencyName,
                VRB.VRBRejectLookupID VRBRejectReasonID,
                Rej.VRBRejectDesc VRBRejectReason,
                --VRBremovalRejectionLookupID,
                VRBRemovalLookupID VRBRemovalReasonID,
                HVS1.StatusDescription VRBRemovalReason,	
                VRB.IsActive VRBActiveFlag,
                VRD.DallasScOffLaw,
                VRB.CreatedDate VRBCreatedDate,
                RequestedDate VRBRequestedDate,
                PlacedDate VRBAppliedDate,
                RemoveRequestedDate VRBRemoveRequestedDate,
                RemovedDate VRBRemovedDate,
                RemoveRejectionDate VRBRemoveRejectionDate,
                RejectionDate VRBRejectionDate, 	   
                        
                --RetryCount,
                VRB.LND_UpdateDate,
                ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate -- select count(*)
            FROM LND_TBOS.TER.VehicleRegBlocks VRB
            JOIN LND_TBOS.TER.HabitualViolators HV ON HV.HVID = VRB.HVID
            LEFT JOIN LND_TBOS.TER.VRBRejectLookup Rej ON Rej.VRBRejectLookupID = VRB.VRBRejectLookupID
            LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS ON HVS.HVStatusLookupID=VRB.StatusLookupID
            LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS1 ON HVS1.HVStatusLookupID = VRB.VRBRemovalLookupID
            LEFT JOIN LND_TBOS.TER.VRBAgencyLookup AG ON AG.VRBAgencyLookupID=VRB.VRBAgencyLookupID
            LEFT JOIN 
                ( 
                  SELECT DISTINCT
                          VRBID,
                          VRD.DallasScOffLaw
                  FROM LND_TBOS.TER.VRBRequestDallas VRD
                  WHERE OffenceDate IS NOT NULL
                  ) VRD 
                ON VRD.VRBID = VRB.VRBID

        )

  -- Testing
  SELECT * FROM dbo.Fact_VRB WHERE VRBAppliedDayID>VRBRemovedDayID

  SELECT * FROM dbo.Fact_VRB WHERE VRBRequestedDayID>VRBRemovedDayID
        

  */


 END;

