CREATE OR REPLACE VIEW EDW_TRIPS.vw_CustomerSentDocumentsDailySummary AS
WITH cte_sentdocuments AS (
  SELECT
      d.customerid,
      min(cnqt.processeddatetime) AS generateddate,
      at1.alerttypedesc AS documenttype,
      acs.alertchannelname AS deliverymethod,
      rlh.lookuptypecodedesc AS deliverystatus,
      CAST(d.communicationdate as DATE) AS maileddate,
      CAST( d.deliverydate as DATE) AS deliverydate,
      count(DISTINCT d.queueid) AS noofdocumentssent
    FROM
      LND_TBOS.DocMgr_TP_Customer_OutboundCommunications AS d
      INNER JOIN LND_TBOS.Notifications_CustomerNotificationQueue AS n ON d.queueid = n.customernotificationqueueid
      INNER JOIN LND_TBOS.Notifications_ConfigAlertTypeAlertChannels AS ac ON ac.configalerttypealertchannelid = n.configalerttypealertchannelid
      INNER JOIN LND_TBOS.Notifications_AlertChannels AS acs ON acs.alertchannelid = ac.alertchannelid
      INNER JOIN LND_TBOS.Notifications_AlertTypes AS at1 ON at1.alerttypeid = ac.alerttypeid
      INNER JOIN LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy AS rlh ON rlh.lookuptypecodeid = n.notifstatus
      INNER JOIN LND_TBOS.Notifications_CustNotifQueueTracker AS cnqt ON n.customernotificationqueueid = cnqt.customernotificationqueueid
       AND cnqt.notifstatus IN(
        3856, 4349, 3855, 4173
      )
    WHERE acs.alertchannelid IN(
      2, 3, 4
    )
    GROUP BY 3, 4, 5, 6, 7, 1
)
SELECT
    substr(CAST(a.generateddate as STRING), 1, 30) AS generateddayid,
    substr(CAST(a.maileddate as STRING), 1, 30) AS maileddayid,
    substr(CAST(a.deliverydate as STRING), 1, 30) AS deliverydayid,
    a.documenttype,
    a.deliverymethod,
    a.deliverystatus,
    sum(a.noofdocumentssent) AS noofdocumentssent
  FROM
    cte_sentdocuments AS a
  GROUP BY a.generateddate, a.maileddate, a.deliverydate,   a.DocumentType,
         a.DeliveryMethod,
         a.DeliveryStatus