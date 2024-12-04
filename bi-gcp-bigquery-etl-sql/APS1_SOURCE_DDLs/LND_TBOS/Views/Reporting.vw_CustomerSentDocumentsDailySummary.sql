CREATE VIEW [Reporting].[vw_CustomerSentDocumentsDailySummary] AS WITH CTE_SentDocuments
AS (
	SELECT d.customerid,
           MIN(cnqt.processedDateTime) AS GeneratedDate,
           AT.AlertTypeDesc AS DocumentType,
           ACS.AlertChannelName AS DeliveryMethod,
           RLH.LookupTypeCodeDesc AS DeliveryStatus,
           CAST(d.CommunicationDate AS DATE) AS MailedDate,
           CAST(d.DeliveryDate AS DATE) AS DeliveryDate,
           COUNT(DISTINCT d.QueueID) AS NoOfDocumentsSent -- select *
    FROM LND_TBOS.DocMgr.TP_Customer_OutboundCommunications d 
        INNER JOIN LND_TBOS.Notifications.CustomerNotificationQueue n
            ON d.QueueID = n.CustomerNotificationQueueID
        INNER JOIN LND_TBOS.Notifications.ConfigAlertTypeAlertChannels AC
            ON AC.ConfigAlertTypeAlertChannelID = n.ConfigAlertTypeAlertChannelID
        INNER JOIN  LND_TBOS.Notifications.AlertChannels ACS
            ON ACS.AlertChannelID = AC.AlertChannelID
        INNER JOIN LND_TBOS.Notifications.AlertTypes AT
            ON AT.AlertTypeID = AC.AlertTypeID
        INNER JOIN LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy RLH
            ON RLH.LookupTypeCodeID = n.NotifStatus
        INNER JOIN LND_TBOS.NOTIFICATIONS.CustNotifQueueTracker cnqt
            ON n.CustomerNotificationQueueID = cnqt.CustomerNotificationQueueID
               AND cnqt.NotifStatus IN (   3856, -- Exportcomplete						

                                           4349, -- MbsGen

                                           3855, -- init

                                           4173  -- Delivered
                                       )
    WHERE ACS.AlertChannelID IN ( 2, -- SMS
								  3, -- EMAIL
								  4  -- MAIL
								)
		-- AND d.customerid = 2013559555								

    GROUP BY 									

        AT.AlertTypeDesc,
        ACS.AlertChannelName,
        RLH.LookupTypeCodeDesc,
        CAST(d.CommunicationDate AS DATE),
        CAST(d.DeliveryDate AS DATE),
        d.customerid
)
SELECT 
	   CONVERT(VARCHAR,GeneratedDate,112) GeneratedDayID,   
       CONVERT(VARCHAR,MailedDate,112) MailedDayID,
       CONVERT(VARCHAR,DeliveryDate,112) DeliveryDayID,
	   DocumentType,
       DeliveryMethod,
       DeliveryStatus,
       SUM(a.NoOfDocumentsSent) AS NoOfDocumentsSent 
FROM CTE_SentDocuments A
GROUP BY a.GeneratedDate,
         a.MailedDate,
         a.DeliveryDate,
         a.DocumentType,
         a.DeliveryMethod,
         a.DeliveryStatus;