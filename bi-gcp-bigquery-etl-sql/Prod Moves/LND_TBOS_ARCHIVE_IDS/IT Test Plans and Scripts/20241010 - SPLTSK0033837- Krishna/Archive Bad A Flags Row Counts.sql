  /*
SELECT
  STRING_AGG( "SELECT "||"'"||REPLACE(a.table_id,'_IDS','')||"' table_name, COUNT(1) row_count  FROM LND_TBOS."||REPLACE(a.table_id,'_IDS','') || " a  WHERE a.lnd_updatetype ='A' AND "||b.column_name ||" NOT IN (SELECT b."||b.column_name||" FROM LND_TBOS_ARCHIVE_IDS."||a.table_id||" b )",' UNION ALL '
  ORDER BY
    table_name)
FROM
  LND_TBOS_ARCHIVE_IDS.__TABLES__ a
JOIN (
  SELECT
    table_name,
    column_name
  FROM
    `LND_TBOS_ARCHIVE_IDS.INFORMATION_SCHEMA.COLUMNS`
  WHERE
    column_name NOT LIKE '%archivebatchdate%'
    AND column_name NOT LIKE '%lnd_updatedate%') b
ON
  a.table_id =b.table_name
WHERE
  table_id NOT IN ("BI_Archive_Reversal_IDS")
ORDER BY
  1*/

-- Quick check
select table_name, row_count
from ARCHIVE_IDS_VALIDATION.Bad_A_Flags_Before 
where row_count <> 0 order by 1;

select table_name, row_count
from ARCHIVE_IDS_VALIDATION.Bad_A_Flags_After 
where row_count <> 0 order by 1;

-- Validation results. before vs after.
CREATE OR REPLACE TABLE
  `ARCHIVE_IDS_VALIDATION.Bad_A_Flags_After` AS -- change the table name. before and after.
SELECT
  'DocMgr_TP_Customer_OutboundCommunications' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.DocMgr_TP_Customer_OutboundCommunications a
WHERE
  a.lnd_updatetype ='A'
  AND outboundcommunicationid NOT IN (
  SELECT
    b.outboundcommunicationid
  FROM
    LND_TBOS_ARCHIVE_IDS.DocMgr_TP_Customer_OutboundCommunications_IDS b )
UNION ALL
SELECT
  'Finance_Adjustment_LineItems' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Finance_Adjustment_LineItems a
WHERE
  a.lnd_updatetype ='A'
  AND adjlineitemid NOT IN (
  SELECT
    b.adjlineitemid
  FROM
    LND_TBOS_ARCHIVE_IDS.Finance_Adjustment_LineItems_IDS b )
UNION ALL
SELECT
  'Finance_Adjustments' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Finance_Adjustments a
WHERE
  a.lnd_updatetype ='A'
  AND adjustmentid NOT IN (
  SELECT
    b.adjustmentid
  FROM
    LND_TBOS_ARCHIVE_IDS.Finance_Adjustments_IDS b )
UNION ALL
SELECT
  'Finance_ChaseTransactions' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Finance_ChaseTransactions a
WHERE
  a.lnd_updatetype ='A'
  AND chasetransactionid NOT IN (
  SELECT
    b.chasetransactionid
  FROM
    LND_TBOS_ARCHIVE_IDS.Finance_ChaseTransactions_IDS b )
UNION ALL
SELECT
  'Finance_ChequePayments' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Finance_ChequePayments a
WHERE
  a.lnd_updatetype ='A'
  AND paymentid NOT IN (
  SELECT
    b.paymentid
  FROM
    LND_TBOS_ARCHIVE_IDS.Finance_ChequePayments_IDS b )
UNION ALL
SELECT
  'Finance_CustomerPayments' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Finance_CustomerPayments a
WHERE
  a.lnd_updatetype ='A'
  AND custpaymentid NOT IN (
  SELECT
    b.custpaymentid
  FROM
    LND_TBOS_ARCHIVE_IDS.Finance_CustomerPayments_IDS b )
UNION ALL
SELECT
  'Finance_Gl_Transactions' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Finance_Gl_Transactions a
WHERE
  a.lnd_updatetype ='A'
  AND gl_txnid NOT IN (
  SELECT
    b.gl_txnid
  FROM
    LND_TBOS_ARCHIVE_IDS.Finance_Gl_Transactions_IDS b )
UNION ALL
SELECT
  'Finance_Gl_Txn_LineItems' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Finance_Gl_Txn_LineItems a
WHERE
  a.lnd_updatetype ='A'
  AND pk_id NOT IN (
  SELECT
    b.pk_id
  FROM
    LND_TBOS_ARCHIVE_IDS.Finance_Gl_Txn_LineItems_IDS b )
UNION ALL
SELECT
  'Finance_Overpayments' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Finance_Overpayments a
WHERE
  a.lnd_updatetype ='A'
  AND overpaymentid NOT IN (
  SELECT
    b.overpaymentid
  FROM
    LND_TBOS_ARCHIVE_IDS.Finance_Overpayments_IDS b )
UNION ALL
SELECT
  'Finance_PaymentTxn_LineItems' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Finance_PaymentTxn_LineItems a
WHERE
  a.lnd_updatetype ='A'
  AND lineitemid NOT IN (
  SELECT
    b.lineitemid
  FROM
    LND_TBOS_ARCHIVE_IDS.Finance_PaymentTxn_LineItems_IDS b )
UNION ALL
SELECT
  'Finance_PaymentTxns' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Finance_PaymentTxns a
WHERE
  a.lnd_updatetype ='A'
  AND paymentid NOT IN (
  SELECT
    b.paymentid
  FROM
    LND_TBOS_ARCHIVE_IDS.Finance_PaymentTxns_IDS b )
UNION ALL
SELECT
  'History_TP_Customer_Addresses' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.History_TP_Customer_Addresses a
WHERE
  a.lnd_updatetype ='A'
  AND customerid NOT IN (
  SELECT
    b.customerid
  FROM
    LND_TBOS_ARCHIVE_IDS.History_TP_Customer_Addresses_IDS b )
UNION ALL
SELECT
  'History_TP_Customer_Attributes' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.History_TP_Customer_Attributes a
WHERE
  a.lnd_updatetype ='A'
  AND histid NOT IN (
  SELECT
    b.histid
  FROM
    LND_TBOS_ARCHIVE_IDS.History_TP_Customer_Attributes_IDS b )
UNION ALL
SELECT
  'History_TP_Customers' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.History_TP_Customers a
WHERE
  a.lnd_updatetype ='A'
  AND histid NOT IN (
  SELECT
    b.histid
  FROM
    LND_TBOS_ARCHIVE_IDS.History_TP_Customers_IDS b )
UNION ALL
SELECT
  'IOP_BOS_IOP_OutboundTransactions' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.IOP_BOS_IOP_OutboundTransactions a
WHERE
  a.lnd_updatetype ='A'
  AND bosioptransactionid NOT IN (
  SELECT
    b.bosioptransactionid
  FROM
    LND_TBOS_ARCHIVE_IDS.IOP_BOS_IOP_OutboundTransactions_IDS b )
UNION ALL
SELECT
  'Notifications_CustNotifQueueTracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Notifications_CustNotifQueueTracker a
WHERE
  a.lnd_updatetype ='A'
  AND custnotifqueuetrackerid NOT IN (
  SELECT
    b.custnotifqueuetrackerid
  FROM
    LND_TBOS_ARCHIVE_IDS.Notifications_CustNotifQueueTracker_IDS b )
UNION ALL
SELECT
  'Notifications_CustomerNotificationQueue' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.Notifications_CustomerNotificationQueue a
WHERE
  a.lnd_updatetype ='A'
  AND customernotificationqueueid NOT IN (
  SELECT
    b.customernotificationqueueid
  FROM
    LND_TBOS_ARCHIVE_IDS.Notifications_CustomerNotificationQueue_IDS b )
UNION ALL
SELECT
  'TER_EligibleForCitations' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_EligibleForCitations a
WHERE
  a.lnd_updatetype ='A'
  AND eligiblecitationid NOT IN (
  SELECT
    b.eligiblecitationid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_EligibleForCitations_IDS b )
UNION ALL
SELECT
  'TER_FailureToPayCitations' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_FailureToPayCitations a
WHERE
  a.lnd_updatetype ='A'
  AND failurecitationid NOT IN (
  SELECT
    b.failurecitationid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_FailureToPayCitations_IDS b )
UNION ALL
SELECT
  'TER_HVEligibleTransactions' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_HVEligibleTransactions a
WHERE
  a.lnd_updatetype ='A'
  AND hveligibletxnid NOT IN (
  SELECT
    b.hveligibletxnid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_HVEligibleTransactions_IDS b )
UNION ALL
SELECT
  'TER_HabitualViolatorStatusTracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_HabitualViolatorStatusTracker a
WHERE
  a.lnd_updatetype ='A'
  AND hvstatusid NOT IN (
  SELECT
    b.hvstatusid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_HabitualViolatorStatusTracker_IDS b )
UNION ALL
SELECT
  'TER_HabitualViolators' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_HabitualViolators a
WHERE
  a.lnd_updatetype ='A'
  AND hvid NOT IN (
  SELECT
    b.hvid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_HabitualViolators_IDS b )
UNION ALL
SELECT
  'TER_VehicleRegBlocks' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_VehicleRegBlocks a
WHERE
  a.lnd_updatetype ='A'
  AND vrbid NOT IN (
  SELECT
    b.vrbid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_VehicleRegBlocks_IDS b )
UNION ALL
SELECT
  'TER_ViolatorCollectionsAgencyTracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_ViolatorCollectionsAgencyTracker a
WHERE
  a.lnd_updatetype ='A'
  AND viocollagencytrackerid NOT IN (
  SELECT
    b.viocollagencytrackerid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsAgencyTracker_IDS b )
UNION ALL
SELECT
  'TER_ViolatorCollectionsInbound' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_ViolatorCollectionsInbound a
WHERE
  a.lnd_updatetype ='A'
  AND viocollinboundid NOT IN (
  SELECT
    b.viocollinboundid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsInbound_IDS b )
UNION ALL
SELECT
  'TER_ViolatorCollectionsOutboundStatus' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_ViolatorCollectionsOutboundStatus a
WHERE
  a.lnd_updatetype ='A'
  AND viocolloutboundstatusupdateid NOT IN (
  SELECT
    b.viocolloutboundstatusupdateid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutboundStatus_IDS b )
UNION ALL
SELECT
  'TER_ViolatorCollectionsOutboundUpdate' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_ViolatorCollectionsOutboundUpdate a
WHERE
  a.lnd_updatetype ='A'
  AND viocolloutboundupdateid NOT IN (
  SELECT
    b.viocolloutboundupdateid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutboundUpdate_IDS b )
UNION ALL
SELECT
  'TER_ViolatorCollectionsOutbound' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TER_ViolatorCollectionsOutbound a
WHERE
  a.lnd_updatetype ='A'
  AND viocolloutboundid NOT IN (
  SELECT
    b.viocolloutboundid
  FROM
    LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutbound_IDS b )
UNION ALL
SELECT
  'TSA_TSATripAttributes' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TSA_TSATripAttributes a
WHERE
  a.lnd_updatetype ='A'
  AND ttptripid NOT IN (
  SELECT
    b.ttptripid
  FROM
    LND_TBOS_ARCHIVE_IDS.TSA_TSATripAttributes_IDS b )
UNION ALL
SELECT
  'TollPlus_DMVRequestTracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_DMVRequestTracker a
WHERE
  a.lnd_updatetype ='A'
  AND requesttrackerid NOT IN (
  SELECT
    b.requesttrackerid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_DMVRequestTracker_IDS b )
UNION ALL
SELECT
  'TollPlus_DMVResponse' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_DMVResponse a
WHERE
  a.lnd_updatetype ='A'
  AND dmvresponseid NOT IN (
  SELECT
    b.dmvresponseid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_DMVResponse_IDS b )
UNION ALL
SELECT
  'TollPlus_Invoice_Charges_Tracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_Invoice_Charges_Tracker a
WHERE
  a.lnd_updatetype ='A'
  AND invoicechargeid NOT IN (
  SELECT
    b.invoicechargeid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_Charges_Tracker_IDS b )
UNION ALL
SELECT
  'TollPlus_Invoice_Header' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_Invoice_Header a
WHERE
  a.lnd_updatetype ='A'
  AND invoiceid NOT IN (
  SELECT
    b.invoiceid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_Header_IDS b )
UNION ALL
SELECT
  'TollPlus_Invoice_LineItems' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_Invoice_LineItems a
WHERE
  a.lnd_updatetype ='A'
  AND invlineitemid NOT IN (
  SELECT
    b.invlineitemid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_LineItems_IDS b )
UNION ALL
SELECT
  'TollPlus_MbsInvoices' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_MbsInvoices a
WHERE
  a.lnd_updatetype ='A'
  AND mbsinvoicesid NOT IN (
  SELECT
    b.mbsinvoicesid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_MbsInvoices_IDS b )
UNION ALL
SELECT
  'TollPlus_Mbsheader' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_Mbsheader a
WHERE
  a.lnd_updatetype ='A'
  AND mbsid NOT IN (
  SELECT
    b.mbsid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_Mbsheader_IDS b )
UNION ALL
SELECT
  'TollPlus_OverPaymentsLog' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_OverPaymentsLog a
WHERE
  a.lnd_updatetype ='A'
  AND overpaymentlogid NOT IN (
  SELECT
    b.overpaymentlogid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_OverPaymentsLog_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_CustTxns' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_CustTxns a
WHERE
  a.lnd_updatetype ='A'
  AND custtxnid NOT IN (
  SELECT
    b.custtxnid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_CustTxns_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_CustomerTrips' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_CustomerTrips a
WHERE
  a.lnd_updatetype ='A'
  AND custtripid NOT IN (
  SELECT
    b.custtripid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_CustomerTrips_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_AccStatus_Tracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_AccStatus_Tracker a
WHERE
  a.lnd_updatetype ='A'
  AND accstatushistid NOT IN (
  SELECT
    b.accstatushistid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_AccStatus_Tracker_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Activities' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Activities a
WHERE
  a.lnd_updatetype ='A'
  AND activityid NOT IN (
  SELECT
    b.activityid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Activities_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Addresses' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Addresses a
WHERE
  a.lnd_updatetype ='A'
  AND custaddressid NOT IN (
  SELECT
    b.custaddressid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Addresses_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Attributes' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Attributes a
WHERE
  a.lnd_updatetype ='A'
  AND customerid NOT IN (
  SELECT
    b.customerid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Attributes_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Balance_Alert_Facts' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Balance_Alert_Facts a
WHERE
  a.lnd_updatetype ='A'
  AND customerid NOT IN (
  SELECT
    b.customerid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Balance_Alert_Facts_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Balances' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Balances a
WHERE
  a.lnd_updatetype ='A'
  AND custbalid NOT IN (
  SELECT
    b.custbalid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Balances_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Business' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Business a
WHERE
  a.lnd_updatetype ='A'
  AND customerid NOT IN (
  SELECT
    b.customerid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Business_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Contacts' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Contacts a
WHERE
  a.lnd_updatetype ='A'
  AND contactid NOT IN (
  SELECT
    b.contactid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Contacts_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Emails' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Emails a
WHERE
  a.lnd_updatetype ='A'
  AND custmailid NOT IN (
  SELECT
    b.custmailid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Emails_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Flags' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Flags a
WHERE
  a.lnd_updatetype ='A'
  AND customerflagid NOT IN (
  SELECT
    b.customerflagid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Flags_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Internal_Users' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Internal_Users a
WHERE
  a.lnd_updatetype ='A'
  AND customerid NOT IN (
  SELECT
    b.customerid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Internal_Users_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Logins' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Logins a
WHERE
  a.lnd_updatetype ='A'
  AND loginid NOT IN (
  SELECT
    b.loginid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Logins_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Phones' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Phones a
WHERE
  a.lnd_updatetype ='A'
  AND custphoneid NOT IN (
  SELECT
    b.custphoneid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Phones_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Plans' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Plans a
WHERE
  a.lnd_updatetype ='A'
  AND custplanid NOT IN (
  SELECT
    b.custplanid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Plans_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Tags_History' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Tags_History a
WHERE
  a.lnd_updatetype ='A'
  AND histid NOT IN (
  SELECT
    b.histid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Tags_History_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Tags' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Tags a
WHERE
  a.lnd_updatetype ='A'
  AND custtagid NOT IN (
  SELECT
    b.custtagid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Tags_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Trip_Charges_Tracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Trip_Charges_Tracker a
WHERE
  a.lnd_updatetype ='A'
  AND tripchargeid NOT IN (
  SELECT
    b.tripchargeid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Trip_Charges_Tracker_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Trip_Receipts_Tracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Trip_Receipts_Tracker a
WHERE
  a.lnd_updatetype ='A'
  AND tripreceiptid NOT IN (
  SELECT
    b.tripreceiptid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Trip_Receipts_Tracker_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Vehicle_Tags' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Vehicle_Tags a
WHERE
  a.lnd_updatetype ='A'
  AND vehicletagid NOT IN (
  SELECT
    b.vehicletagid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Vehicle_Tags_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customer_Vehicles' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customer_Vehicles a
WHERE
  a.lnd_updatetype ='A'
  AND vehicleid NOT IN (
  SELECT
    b.vehicleid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Vehicles_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Customers' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Customers a
WHERE
  a.lnd_updatetype ='A'
  AND customerid NOT IN (
  SELECT
    b.customerid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customers_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Image_Review_Results' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Image_Review_Results a
WHERE
  a.lnd_updatetype ='A'
  AND imagereviewresultid NOT IN (
  SELECT
    b.imagereviewresultid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Image_Review_Results_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Invoice_Receipts_Tracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Invoice_Receipts_Tracker a
WHERE
  a.lnd_updatetype ='A'
  AND receiptid NOT IN (
  SELECT
    b.receiptid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Invoice_Receipts_Tracker_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Trips' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Trips a
WHERE
  a.lnd_updatetype ='A'
  AND tptripid NOT IN (
  SELECT
    b.tptripid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Trips_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_ViolatedTrips' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_ViolatedTrips a
WHERE
  a.lnd_updatetype ='A'
  AND citationid NOT IN (
  SELECT
    b.citationid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_ViolatedTrips_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Violated_Trip_Charges_Tracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Violated_Trip_Charges_Tracker a
WHERE
  a.lnd_updatetype ='A'
  AND tripchargeid NOT IN (
  SELECT
    b.tripchargeid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Violated_Trip_Charges_Tracker_IDS b )
UNION ALL
SELECT
  'TollPlus_TP_Violated_Trip_Receipts_Tracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_TP_Violated_Trip_Receipts_Tracker a
WHERE
  a.lnd_updatetype ='A'
  AND tripreceiptid NOT IN (
  SELECT
    b.tripreceiptid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Violated_Trip_Receipts_Tracker_IDS b )
UNION ALL
SELECT
  'TollPlus_UnRegisteredCustomersMbsSchedules' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TollPlus_UnRegisteredCustomersMbsSchedules a
WHERE
  a.lnd_updatetype ='A'
  AND unregmbsscheduleid NOT IN (
  SELECT
    b.unregmbsscheduleid
  FROM
    LND_TBOS_ARCHIVE_IDS.TollPlus_UnRegisteredCustomersMbsSchedules_IDS b )
UNION ALL
SELECT
  'TranProcessing_NTTAHostBOSFileTracker' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TranProcessing_NTTAHostBOSFileTracker a
WHERE
  a.lnd_updatetype ='A'
  AND id NOT IN (
  SELECT
    b.id
  FROM
    LND_TBOS_ARCHIVE_IDS.TranProcessing_NTTAHostBOSFileTracker_IDS b )
UNION ALL
SELECT
  'TranProcessing_NTTARawTransactions' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TranProcessing_NTTARawTransactions a
WHERE
  a.lnd_updatetype ='A'
  AND txnid NOT IN (
  SELECT
    b.txnid
  FROM
    LND_TBOS_ARCHIVE_IDS.TranProcessing_NTTARawTransactions_IDS b )
UNION ALL
SELECT
  'TranProcessing_TSARawTransactions' table_name,
  COUNT(1) row_count
FROM
  LND_TBOS.TranProcessing_TSARawTransactions a
WHERE
  a.lnd_updatetype ='A'
  AND txnid NOT IN (
  SELECT
    b.txnid
  FROM
    LND_TBOS_ARCHIVE_IDS.TranProcessing_TSARawTransactions_IDS b )