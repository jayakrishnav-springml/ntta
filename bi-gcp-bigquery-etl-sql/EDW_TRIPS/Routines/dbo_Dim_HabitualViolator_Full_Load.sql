CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_HabitualViolator_Full_Load`()
BEGIN 
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_HabitualViolator table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
			Gouthami		2023-05-08	Created
			Shekhar			2023-07-18  Fixed bug identified in internal audit (EarliestHVTerminationLetterDeliveredDate)
			Shekhar			2023-07-24  Fixed AdminHearingStatus Bug
			Shekhar			2023-07-25  Fixed AdminHearingCounty Bug  (Worked with Sagarika)
			Shekhar			2023-07-25  Modified  in ('VehicleBanLetter', 'VEHBAN') & in('VRBLetter', 'VRB') for DocumentType
			Shekhar			2023-05-25  Added New columns and removed old columns for VRB and VB
CHG0043993	Gouthami		2023-11-02	Fixed duplicate issue caused by Admin hearing status. 
CHG0044527	Gouthami		2024-02-08	Added Earliest & Latest Citation dates for an HV/Customer
DFCT0013941 Dhanush     2024-09-04  Fixed the issue of duplicate records of mbsdueamount caused by archival data being loaded into table
===================================================================================================================
Example:
EXEC [dbo].[Dim_HabitualViolator_Full_Load]
--EXEC Utility.FromLog 'dbo.Dim_HabitualViolator', 1
SELECT TOP 100 'dbo.Dim_HabitualViolator' Table_Name, * FROM dbo.Dim_HabitualViolator ORDER BY 2
###################################################################################################################
*/
  DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_HabitualViolator_Load'; 
  DECLARE log_start_date DATETIME; 
  DECLARE log_message STRING; 
  DECLARE trace_flag INT64 DEFAULT 0; ## Testing
  BEGIN 
    DECLARE ROW_COUNT INT64;
    SET log_start_date = current_datetime('America/Chicago'); 
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
    --DROP TABLE IF EXISTS EDW_TRIPS.Dim_HabitualViolator_NEW;
    CREATE TEMPORARY TABLE _SESSION.cte_main AS
      (SELECT hv.hvid,
              hv.violatorid AS customerid,
              hv.vehicleid,
              v.licenseplatestate,
              v.licenseplatenumber,
              hvsts.hvstatuslookupid,
              hv.currentstatuscode AS hvcurrentstatus,
              -- Modified the following 3 lines by Shekhar on 7/25/2023
							-- CASE WHEN AH.AdminHearingCounty=TC3.CountyName THEN TC3.CountyNo ELSE -1 END AS AdminHearingCountyID,
              ah.countyid AS adminhearingcountyid,
              tc3.countyname AS adminhearingcountyname,
              ah.hvstatuslookupid AS adminhearingstatusid, -- Modified By Shekhar on 7/24/2023 after noticing the inaccurate AdminHearding status 
              hvsts1.statuscode AS adminheaderingstatus, -- Modified By Shekhar on 7/24/2023 after noticing the inaccurate AdminHearding status AH.HearingReason AdminHearingReason,
              ah.hearingreason AS adminhearingreason,
              ah.requesteddate AS adminhearingrequesteddate,
              hv.vehicleregistrationcounty AS vehicleregistrationcountyid,
              tc1.countyname AS vehicleregistrationcountyname,
              hv.rovaddresscounty AS rovaddresscountyid,
              tc2.countyname AS rovaddresscountyname,
              hv.hvfirstqualifiedtrandate,
              hv.hvlastqualifiedtrandate,
              hv.hvdesignationdate AS hvdeterminationdate,
              hv.hvterminationdate,
              ah.hearingdate AS scheduledhearingdate,
              ftp.earliestcitationdate,
              ftp.latestcitationdate,
              hv.hvterminationreason,
              hv.hvqualifiedtrancount AS hvtransactioncount,
              hv.totaltrancount,
              hv.totalcitationcount,
              hv.hvqualifiedtollsdue AS hvtollsdue,
              hv.hvqualifiedfeesdue AS hvfeesdue,
              hv.hvqualifiedamountdue AS hvcurrentdue,
              mbs.totalamount AS mbscurrentdue,
              hv.lnd_updatedate -- select *
      FROM LND_TBOS.TER_HabitualViolators AS hv
      LEFT OUTER JOIN LND_TBOS.TER_HVStatusLookup AS hvsts ON hv.currentstatuscode = hvsts.statuscode
      AND hvsts.parentstatusid IN(23,
                                  43,
                                  13,
                                  0)
      LEFT OUTER JOIN LND_TBOS.TollPlus_TexasCounties AS tc1 ON hv.vehicleregistrationcounty = tc1.countyno
      LEFT OUTER JOIN LND_TBOS.TollPlus_TexasCounties AS tc2 ON hv.rovaddresscounty = tc2.countyno
      LEFT OUTER JOIN
        (SELECT a.*
          FROM
            (SELECT Court_AdminHearing.adminhearingid,
                    Court_AdminHearing.hvid,
                    Court_AdminHearing.judgeid,
                    Court_AdminHearing.hvstatuslookupid,
                    Court_AdminHearing.hearingdate,
                    Court_AdminHearing.countyid,
                    Court_AdminHearing.requesteddate,
                    Court_AdminHearing.hearingreason,
                    Court_AdminHearing.comments,
                    row_number() OVER (PARTITION BY Court_AdminHearing.hvid
                                      ORDER BY Court_AdminHearing.requesteddate ASC) AS rn
            FROM LND_TBOS.Court_AdminHearing) AS a
          WHERE a.rn = 1 ) AS ah ON ah.hvid = hv.hvid
      LEFT OUTER JOIN LND_TBOS.TollPlus_TexasCounties AS tc3 ON ah.countyid = tc3.countyid
      LEFT OUTER JOIN EDW_TRIPS.Dim_Vehicle AS v ON v.vehicleid = hv.vehicleid
      LEFT OUTER JOIN LND_TBOS.TER_HVStatusLookup AS hvsts1 ON ah.hvstatuslookupid = hvsts1.hvstatuslookupid -- Added By Shekhar on 7/24/2023 after noticing the inaccurate AdminHearding status 
      LEFT OUTER JOIN
        (SELECT TollPlus_mbsheader.customerid,
                TollPlus_mbsheader.totalamount
          FROM LND_TBOS.TollPlus_MbsHeader
          WHERE TollPlus_mbsheader.ispresentmbs = 1 
          AND TollPlus_mbsheader.lnd_updatetype<>'A'--Added BY Dhanush on 09/04/2024 after identifying archival data in table 
          ) AS mbs ON mbs.customerid = hv.violatorid
      LEFT OUTER JOIN
        (SELECT TER_FailureToPayCitations.violatorid as violatorid,
                min(TER_FailureToPayCitations.maildate) AS earliestcitationdate,
                max(TER_FailureToPayCitations.maildate) AS latestcitationdate   -- A customer can be issued multiple citations (not in a month).
          FROM LND_TBOS.TER_FailureToPayCitations
          WHERE TER_FailureToPayCitations.dpscitationissueddate IS NOT NULL -- when DPS officer issue any citation to customer, then it is a valid citation
          GROUP BY violatorid) AS FTP ON ftp.violatorid = hv.violatorid);
    -- WHERE hv.hvid=20602 -- mbs due not same as GUI
    CREATE TEMPORARY TABLE _SESSION.cte_letterdates AS
      (SELECT b.hvid,
              max(b.latesthvdeterminationcommunicationdate) AS latesthvdeterminationcommunicationdate,
              max(b.latestvrbcommunicationdate) AS latestvrbcommunicationdate,
              max(b.latesthvterminationcommunicationdate) AS latesthvterminationcommunicationdate,
              max(b.latestvehiclebancommunicationdate) AS latestvehiclebancommunicationdate,
              max(b.earliesthvdeterminationcommunicationdate) AS earliesthvdeterminationcommunicationdate,
              max(b.earliestvrbcommunicationdate) AS earliestvrbcommunicationdate,
              max(b.earliesthvterminationcommunicationdate) AS earliesthvterminationcommunicationdate,
              max(b.earliestvehiclebancommunicationdate) AS earliestvehiclebancommunicationdate,
              max(b.latesthvdeterminationdeliverydate) AS latesthvdeterminationdeliverydate,
              max(b.latestvrbdeliverydate) AS latestvrbdeliverydate,
              max(b.latesthvterminationdeliverydate) AS latesthvterminationdeliverydate,
              max(b.latestvehiclebandeliverydate) AS latestvehiclebandeliverydate,
              max(b.earliesthvdeterminationdeliverydate) AS earliesthvdeterminationdeliverydate,
              max(b.earliestvrbdeliverydate) AS earliestvrbdeliverydate,
              max(b.earliesthvterminationdeliverydate) AS earliesthvterminationdeliverydate,
              max(b.earliestvehiclebandeliverydate) AS earliestvehiclebandeliverydate
      FROM
        (SELECT a.hvid,
                -- Latest Communication Dates
                CASE
                    WHEN a.documenttype = 'HVDeterminationLetter' THEN a.latestcommunicationdate
                END AS latesthvdeterminationcommunicationdate,
                CASE
                    WHEN a.documenttype IN('VRBLetter',
                                            'VRB') THEN a.latestcommunicationdate
                END AS latestvrbcommunicationdate,
                CASE
                    WHEN a.documenttype = 'HVTerminationLetter' THEN a.latestcommunicationdate
                END AS latesthvterminationcommunicationdate,
                CASE
                    WHEN a.documenttype IN('VehicleBanLetter',
                                            'VEHBAN') THEN a.latestcommunicationdate
                END AS latestvehiclebancommunicationdate,
                
                 -- Earliest Communication Dates
                CASE
                    WHEN a.documenttype = 'HVDeterminationLetter' THEN a.earliestcommunicationdate
                END AS earliesthvdeterminationcommunicationdate,
                CASE
                    WHEN a.documenttype IN('VRBLetter',
                                            'VRB') THEN a.earliestcommunicationdate
                END AS earliestvrbcommunicationdate,
                CASE
                    WHEN a.documenttype = 'HVTerminationLetter' THEN a.earliestcommunicationdate
                END AS earliesthvterminationcommunicationdate,
                CASE
                    WHEN a.documenttype IN('VehicleBanLetter',
                                            'VEHBAN') THEN a.earliestcommunicationdate
                END AS earliestvehiclebancommunicationdate,
                
                -- Latest Delivery Dates
                CASE
                    WHEN a.documenttype = 'HVDeterminationLetter' THEN a.latestdeliverydate
                END AS latesthvdeterminationdeliverydate,
                CASE
                    WHEN a.documenttype IN('VRBLetter',
                                            'VRB') THEN a.latestdeliverydate
                END AS latestvrbdeliverydate,
                CASE
                    WHEN a.documenttype = 'HVTerminationLetter' THEN a.latestdeliverydate
                END AS latesthvterminationdeliverydate,
                CASE
                    WHEN a.documenttype IN('VehicleBanLetter',
                                            'VEHBAN') THEN a.latestdeliverydate
                END AS latestvehiclebandeliverydate,
                
                -- Earliest Delivery Dates
                CASE
                    WHEN a.documenttype = 'HVDeterminationLetter' THEN a.earliestdeliverydate
                END AS earliesthvdeterminationdeliverydate,
                CASE
                    WHEN a.documenttype IN('VRBLetter',
                                            'VRB') THEN a.earliestdeliverydate
                END AS earliestvrbdeliverydate,
                CASE
                    WHEN a.documenttype = 'HVTerminationLetter' THEN a.earliestdeliverydate
                END AS earliesthvterminationdeliverydate,
                CASE
                    WHEN a.documenttype IN('VehicleBanLetter',
                                            'VEHBAN') THEN a.earliestdeliverydate
                END AS earliestvehiclebandeliverydate
          FROM
            (SELECT notif.linkid AS hvid,
                    oc.documenttype,
                    max(oc.communicationdate) AS latestcommunicationdate,
                    min(oc.communicationdate) AS earliestcommunicationdate,
                    max(oc.deliverydate) AS latestdeliverydate,
                    min(oc.deliverydate) AS earliestdeliverydate
            FROM LND_TBOS.TER_HabitualViolators AS hv
            INNER JOIN
              (SELECT DISTINCT Notifications_CustomerNotificationQueue.linkid,
                                Notifications_CustomerNotificationQueue.customernotificationqueueid
                FROM LND_TBOS.Notifications_CustomerNotificationQueue
                WHERE Notifications_CustomerNotificationQueue.linksource = 'TER.HabitualViolators' ) AS notif ON hv.hvid = notif.linkid
            INNER JOIN LND_TBOS.DocMgr_TP_Customer_OutboundCommunications AS oc ON oc.queueid = notif.customernotificationqueueid
            -- WHERE notif.LinkID=862444
            GROUP BY hvid,
                      oc.documenttype) AS a) AS b
      GROUP BY b.hvid);

    -------------------------------------------------------------
		-- Added by Shekhar
		-- VB Dates and Status from nd_tbos.TER.VehicleBan
		------------------------------------------------------------

    CREATE TEMPORARY TABLE _SESSION.cte_vbapplieddate AS
      (SELECT vb.hvid,
              vb.actiondate AS vbapplieddate
      FROM LND_TBOS.TER_VehicleBan AS vb
      WHERE vb.actiondate >= '2021-01-01'
        AND vb.vblookupid = 26); -- Ban Applied


    CREATE TEMPORARY TABLE _SESSION.cte_vbremovaldate AS
      (SELECT vb.hvid,
              vb.actiondate AS vbremoveddate,
              vb.removallookupid AS removalreasonid,
              hvs.statuscode AS removalreasoncode
      FROM LND_TBOS.TER_VehicleBan AS vb
      INNER JOIN LND_TBOS.TER_HVStatusLookup AS hvs ON hvs.hvstatuslookupid = vb.removallookupid
      WHERE vb.actiondate >= '2021-01-01'
        AND vb.vblookupid = 28);
         -- Ban Removed


    CREATE
    TEMPORARY TABLE _SESSION.cte_bandates AS
      (SELECT coalesce(cte_vbremovaldate.hvid, cte_vbapplieddate.hvid) AS hvid,
              cte_vbremovaldate.vbremoveddate,
              cte_vbremovaldate.removalreasonid,
              cte_vbremovaldate.removalreasoncode,
              cte_vbapplieddate.vbapplieddate
      FROM _SESSION.cte_vbapplieddate
      FULL OUTER JOIN _SESSION.cte_vbremovaldate ON cte_vbremovaldate.hvid = cte_vbapplieddate.hvid);

    -------------------------------------------------------------
		-- Added by Shekhar
		-- VRB Dates and Status from nd_tbos.TER.VehicleRegBlocks
		------------------------------------------------------------
    CREATE TEMPORARY TABLE _SESSION.cte_earliestvrbdates AS
      (SELECT a.*
      FROM
        (SELECT vrb.hvid,
                row_number() OVER (PARTITION BY vrb.hvid
                                    ORDER BY vrb.requesteddate ASC) AS rn,
                                  vrb.statuslookupid AS earliestvrbstatusid,
                                  vrb.vrbremovallookupid AS earliestvrbremovallookupid,
                                  vrb.requesteddate AS earliestvrbrequesteddate,
                                  vrb.placeddate AS earliestvrbplaceddate,
                                  vrb.removeddate AS earliestvrbremoveddate
          FROM LND_TBOS.TER_VehicleRegBlocks AS vrb
          --WHERE HVID = 230019
          GROUP BY vrb.hvid,
                  vrb.statuslookupid,
                  vrb.vrbremovallookupid,
                  vrb.requesteddate,
                  vrb.placeddate,
                  vrb.removeddate) AS a
      WHERE a.rn = 1 );


    CREATE TEMPORARY TABLE _SESSION.cte_latestdates AS
      (SELECT a.*
      FROM
        (SELECT vrb.hvid,
                row_number() OVER (PARTITION BY vrb.hvid
                                    ORDER BY vrb.requesteddate DESC) AS rn,
                                  vrb.statuslookupid AS latestvrbstatusid,
                                  vrb.vrbremovallookupid AS latestvrbremovallookupid,
                                  vrb.requesteddate AS latestvrbrequesteddate,
                                  vrb.placeddate AS latestvrbplaceddate,
                                  vrb.removeddate AS latestvrbremoveddate
          FROM LND_TBOS.TER_VehicleRegBlocks AS vrb
          --WHERE HVID = 230019
          GROUP BY vrb.hvid,
                  vrb.statuslookupid,
                  vrb.vrbremovallookupid,
                  vrb.requesteddate,
                  vrb.placeddate,
                  vrb.removeddate) AS a
      WHERE a.rn = 1 );


    CREATE TEMPORARY TABLE _SESSION.cte_vrbdates AS
      (SELECT e.hvid,
              e.earliestvrbstatusid,
              hvs.statusdescription AS earliestvrbstatusdescription,
              e.earliestvrbremovallookupid,
              hvsr.statusdescription AS earliestvrbremovallookupdescription,
              e.earliestvrbrequesteddate,
              e.earliestvrbplaceddate,
              e.earliestvrbremoveddate,
              l.latestvrbstatusid,
              hvs1.statusdescription AS latestvrbstatusdescription,
              l.latestvrbremovallookupid,
              hvsr1.statusdescription AS latestvrbremovallookupdescription,
              l.latestvrbrequesteddate,
              l.latestvrbplaceddate,
              l.latestvrbremoveddate
      FROM _SESSION.cte_earliestvrbdates AS e
      INNER JOIN _SESSION.cte_latestdates AS l ON l.hvid = e.hvid
      INNER JOIN LND_TBOS.TER_HVStatusLookup AS hvs ON e.earliestvrbstatusid = hvs.hvstatuslookupid
      INNER JOIN LND_TBOS.TER_HVStatusLookup AS hvs1 ON l.latestvrbstatusid = hvs1.hvstatuslookupid
      LEFT OUTER JOIN LND_TBOS.TER_HVStatusLookup AS hvsr ON hvsr.hvstatuslookupid = e.earliestvrbremovallookupid
      LEFT OUTER JOIN LND_TBOS.TER_HVStatusLookup AS hvsr1 ON hvsr1.hvstatuslookupid = l.latestvrbremovallookupid);


    CREATE OR REPLACE TABLE EDW_TRIPS.Dim_HabitualViolator CLUSTER BY hvid AS
    SELECT a.hvid,
          a.customerid,
          a.vehicleid,
          a.licenseplatestate,
          a.licenseplatenumber,
          a.hvstatuslookupid,
          a.hvcurrentstatus,
          a.hvterminationreason,
          a.hvtransactioncount,
          a.adminhearingcountyid,
          a.adminhearingcountyname,
          a.adminhearingstatusid,
          a.adminheaderingstatus,
          a.adminhearingreason,
          a.adminhearingrequesteddate,
          a.vehicleregistrationcountyid,
          a.vehicleregistrationcountyname,
          a.rovaddresscountyid,
          a.rovaddresscountyname,
          a.hvfirstqualifiedtrandate,
          a.hvlastqualifiedtrandate,
          a.hvdeterminationdate,
          ld.latesthvdeterminationcommunicationdate AS latesthvdeterminationlettermaileddate,
          ld.latesthvdeterminationdeliverydate AS latesthvdeterminationletterdelivereddate, --(deliverydate FROM outboundcommunications TABLE)
          ld.earliesthvdeterminationcommunicationdate AS earliesthvdeterminationlettermaileddate,
          ld.earliesthvdeterminationdeliverydate AS earliesthvdeterminationletterdelivereddate,
          
          a.hvterminationdate AS hvterminationdate,
          ld.latesthvterminationcommunicationdate AS latesthvterminationlettermaileddate,
          ld.latesthvterminationdeliverydate AS latesthvterminationletterdeliverydate,
          ld.earliesthvterminationcommunicationdate AS earliesthvterminationlettermaileddate,
          ld.earliesthvterminationdeliverydate AS earliesthvterminationletterdelivereddate, -- Modified by Shekhar on 7/18/2023. Copy paste bug (typo) in the previous program. Identified in TER audit
          
          -- VRB related Info & Dates
          vrb.earliestvrbstatusid,
          vrb.earliestvrbstatusdescription,
          vrb.earliestvrbremovallookupid,
          vrb.earliestvrbremovallookupdescription,
          vrb.earliestvrbrequesteddate,
          vrb.earliestvrbplaceddate,
          vrb.earliestvrbremoveddate,
          vrb.latestvrbstatusid,
          vrb.latestvrbstatusdescription,
          vrb.latestvrbremovallookupid,
          vrb.latestvrbremovallookupdescription,
          vrb.latestvrbrequesteddate,
          vrb.latestvrbplaceddate,
          vrb.latestvrbremoveddate,
          --HVS.LatestVRBPlacedDate LatestVRBDate,
          --HVS.EarliestVRBPlacedDate EarliestVRBDate,
          ld.latestvrbcommunicationdate AS latestvrblettermaileddate,
          ld.latestvrbdeliverydate AS latestvrbletterdelivereddate,
          ld.earliestvrbcommunicationdate AS earliestvrblettermaileddate,
          ld.earliestvrbdeliverydate AS earliestvrbletterdelivereddate,
          
          -- Ban related Dates
          vb.vbremoveddate,
          vb.removalreasonid,
          vb.removalreasoncode,
          vb.vbapplieddate,
           -- HVS.LatestVehicleBanPlacedDate LatestVehicleBanDate,
          -- HVS.EarliestVehicleBanPlacedDate EarliestVehicleBanDate,
          ld.latestvehiclebancommunicationdate AS latestvehiclebanlettermaileddate,
          ld.latestvehiclebandeliverydate AS latestvehiclebanletterdelivereddate,
          ld.earliestvehiclebancommunicationdate AS earliestvehiclebanlettermaileddate,
          ld.earliestvehiclebandeliverydate AS earliestvehiclebanletterdelivereddate,
          a.scheduledhearingdate,
          a.earliestcitationdate,
          a.latestcitationdate,
          a.hvtollsdue,
          a.hvfeesdue,
          a.hvcurrentdue,
          a.mbscurrentdue,
          coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
          --need to add
							   --NULL HVAddressStatus,  
							   --NULL FailuretoPayCitationIssued
    
    FROM _SESSION.cte_main as a
    LEFT OUTER JOIN _SESSION.cte_letterdates ld ON a.hvid = ld.hvid
    --LEFT JOIN CTE_StatustrackerDates HVS ON A.HVID=HVS.HVID
    LEFT OUTER JOIN _SESSION.cte_bandates vb ON a.hvid = vb.hvid
    LEFT OUTER JOIN _SESSION.cte_vrbdates vrb ON a.hvid = vrb.hvid ;


    SET log_message = 'Loaded EDW_TRIPS.Dim_HabitualViolator';

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

  	-- Table swap!
    --TableSwap is Not Required, using  Create or Replace Table 
    --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_HabitualViolator_NEW', 'EDW_TRIPS.Dim_HabitualViolator');
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
    -- Show results
    IF trace_flag = 1 THEN 
      --CALL EDW_TRIPS_SUPPORT.FromLog(log_source, log_start_date);
    END IF;
    
    IF trace_flag = 1 THEN
      SELECT 'EDW_TRIPS.Dim_HabitualViolator' AS tablename,
            *
      FROM EDW_TRIPS.Dim_HabitualViolator
      ORDER BY 2 DESC
      LIMIT 1000 ;

    END IF;

    EXCEPTION WHEN ERROR 
    THEN 
    BEGIN 
      DECLARE error_message STRING DEFAULT @@error.message;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
      RAISE USING MESSAGE = error_message; -- Rethrow the error!
    END;

  END;
  /*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_HabitualViolator_Load

EXEC Utility.FromLog 'dbo.Dim_HabitualViolator', 1
SELECT TOP 100 'dbo.Dim_HabitualViolator' Table_Name, * FROM dbo.Dim_HabitualViolator ORDER BY 2

Old Code 


		--CTE_StatustrackerDates AS 
		--(
		--		SELECT HVID,
		--			   MAX(S.LatestVRBPlaced) LatestVRBPlacedDate,
		--			   MAX(EarliestVRBPlaced) EarliestVRBPlacedDate,
		--			   MAX(LatestVehicleBanPlaced) LatestVehicleBanPlacedDate,
		--			   MAX(EarliestVehicleBanPlaced) EarliestVehicleBanPlacedDate
		--		FROM (
		--					SELECT HVS.HVID,
		--						   HVS.SubStatus,
		--						   CASE 
		--					         WHEN HVS.SubStatus = 'VRBPlaced' THEN
		--						                                        Max(HVS.StatusStartDate)
		--						   END LatestVRBPlaced,
		--						   CASE 
		--					         WHEN HVS.SubStatus = 'VRBPlaced' THEN
		--						                                        MIN(HVS.StatusStartDate)
		--						   END EarliestVRBPlaced,		
								   
		--						   CASE  WHEN HVS.SubStatus = 'VehicleBanPlaced' THEN
		--						                                        Max(HVS.StatusStartDate)
		--						   END AS LatestVehicleBanPlaced,
		--					       CASE WHEN HVS.SubStatus = 'VehicleBanPlaced' THEN
		--						                                        MIN(HVS.StatusStartDate)
		--					       END AS EarliestVehicleBanPlaced

		--					FROM LND_TBOS.TER.Habitualviolatorstatustracker HVS	WHERE HVS.HVID=342741 --862444
		--					GROUP BY HVS.HVID,
  --                                   HVS.SubStatus
		--					--OC.CustomerID = 799264020--799264020 
		--				) S	GROUP BY S.HVID		
		--),
*/


END;