-- IDS to main LND tables reconciliation
select table_name, row_count 
from ARCHIVE_IDS_VALIDATION.MatchedArchive_IDS 
where row_count <> 0 order by 1;

--Fetching Matched archive ids counts for each table
CREATE OR REPLACE TABLE
  `ARCHIVE_IDS_VALIDATION.MatchedArchive_IDS` AS
SELECT
  COUNT(1) row_count,
  'TranProcessing_NTTAHostBOSFileTracker_IDS' table_name
FROM
  LND_TBOS_ARCHIVE_IDS.TranProcessing_NTTAHostBOSFileTracker_IDS a
JOIN
  LND_TBOS.TranProcessing_NTTAHostBOSFileTracker b
ON
  a.id= b.id
UNION ALL
SELECT
  COUNT(1),
  'Finance_PaymentTxn_LineItems_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Finance_PaymentTxn_LineItems_IDS a
JOIN
  LND_TBOS.Finance_PaymentTxn_LineItems b
ON
  a.lineitemid= b.lineitemid
UNION ALL
SELECT
  COUNT(1),
  'TER_EligibleForCitations_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_EligibleForCitations_IDS a
JOIN
  LND_TBOS.TER_EligibleForCitations b
ON
  a.eligiblecitationid= b.eligiblecitationid
UNION ALL
SELECT
  COUNT(1),
  'History_TP_Customer_Attributes_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.History_TP_Customer_Attributes_IDS a
JOIN
  LND_TBOS.History_TP_Customer_Attributes b
ON
  a.histid= b.histid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_Mbsheader_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_Mbsheader_IDS a
JOIN
  LND_TBOS.TollPlus_Mbsheader b
ON
  a.mbsid= b.mbsid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_DMVResponse_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_DMVResponse_IDS a
JOIN
  LND_TBOS.TollPlus_DMVResponse b
ON
  a.dmvresponseid= b.dmvresponseid
UNION ALL
SELECT
  COUNT(1),
  'TranProcessing_NTTARawTransactions_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TranProcessing_NTTARawTransactions_IDS a
JOIN
  LND_TBOS.TranProcessing_NTTARawTransactions b
ON
  a.txnid= b.txnid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Internal_Users_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Internal_Users_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Internal_Users b
ON
  a.customerid= b.customerid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Vehicles_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Vehicles_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Vehicles b
ON
  a.vehicleid= b.vehicleid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_Invoice_Charges_Tracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_Charges_Tracker_IDS a
JOIN
  LND_TBOS.TollPlus_Invoice_Charges_Tracker b
ON
  a.invoicechargeid= b.invoicechargeid
UNION ALL
SELECT
  COUNT(1),
  'TER_HVEligibleTransactions_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_HVEligibleTransactions_IDS a
JOIN
  LND_TBOS.TER_HVEligibleTransactions b
ON
  a.hveligibletxnid= b.hveligibletxnid
UNION ALL
SELECT
  COUNT(1),
  'Finance_Gl_Transactions_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Finance_Gl_Transactions_IDS a
JOIN
  LND_TBOS.Finance_Gl_Transactions b
ON
  a.gl_txnid= b.gl_txnid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Violated_Trip_Receipts_Tracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Violated_Trip_Receipts_Tracker_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Violated_Trip_Receipts_Tracker b
ON
  a.tripreceiptid= b.tripreceiptid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_MbsInvoices_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_MbsInvoices_IDS a
JOIN
  LND_TBOS.TollPlus_MbsInvoices b
ON
  a.mbsinvoicesid= b.mbsinvoicesid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Logins_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Logins_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Logins b
ON
  a.loginid= b.loginid
UNION ALL
SELECT
  COUNT(1),
  'TER_ViolatorCollectionsOutboundStatus_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutboundStatus_IDS a
JOIN
  LND_TBOS.TER_ViolatorCollectionsOutboundStatus b
ON
  a.viocolloutboundstatusupdateid= b.viocolloutboundstatusupdateid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_Invoice_Header_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_Header_IDS a
JOIN
  LND_TBOS.TollPlus_Invoice_Header b
ON
  a.invoiceid= b.invoiceid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Addresses_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Addresses_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Addresses b
ON
  a.custaddressid= b.custaddressid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_AccStatus_Tracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_AccStatus_Tracker_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_AccStatus_Tracker b
ON
  a.accstatushistid= b.accstatushistid
UNION ALL
SELECT
  COUNT(1),
  'Finance_Adjustments_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Finance_Adjustments_IDS a
JOIN
  LND_TBOS.Finance_Adjustments b
ON
  a.adjustmentid= b.adjustmentid
UNION ALL
SELECT
  COUNT(1),
  'Notifications_CustomerNotificationQueue_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Notifications_CustomerNotificationQueue_IDS a
JOIN
  LND_TBOS.Notifications_CustomerNotificationQueue b
ON
  a.customernotificationqueueid= b.customernotificationqueueid
UNION ALL
SELECT
  COUNT(1),
  'Finance_Gl_Txn_LineItems_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Finance_Gl_Txn_LineItems_IDS a
JOIN
  LND_TBOS.Finance_Gl_Txn_LineItems b
ON
  a.pk_id= b.pk_id
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Business_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Business_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Business b
ON
  a.customerid= b.customerid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Invoice_Receipts_Tracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Invoice_Receipts_Tracker_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Invoice_Receipts_Tracker b
ON
  a.receiptid= b.receiptid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Contacts_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Contacts_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Contacts b
ON
  a.contactid= b.contactid
UNION ALL
SELECT
  COUNT(1),
  'Finance_Adjustment_LineItems_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Finance_Adjustment_LineItems_IDS a
JOIN
  LND_TBOS.Finance_Adjustment_LineItems b
ON
  a.adjlineitemid= b.adjlineitemid
UNION ALL
SELECT
  COUNT(1),
  'TER_ViolatorCollectionsAgencyTracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsAgencyTracker_IDS a
JOIN
  LND_TBOS.TER_ViolatorCollectionsAgencyTracker b
ON
  a.viocollagencytrackerid= b.viocollagencytrackerid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Vehicle_Tags_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Vehicle_Tags_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Vehicle_Tags b
ON
  a.vehicletagid= b.vehicletagid
UNION ALL
SELECT
  COUNT(1),
  'IOP_BOS_IOP_OutboundTransactions_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.IOP_BOS_IOP_OutboundTransactions_IDS a
JOIN
  LND_TBOS.IOP_BOS_IOP_OutboundTransactions b
ON
  a.bosioptransactionid= b.bosioptransactionid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_DMVRequestTracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_DMVRequestTracker_IDS a
JOIN
  LND_TBOS.TollPlus_DMVRequestTracker b
ON
  a.requesttrackerid= b.requesttrackerid
UNION ALL
SELECT
  COUNT(1),
  'Finance_CustomerPayments_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Finance_CustomerPayments_IDS a
JOIN
  LND_TBOS.Finance_CustomerPayments b
ON
  a.custpaymentid= b.custpaymentid
UNION ALL
SELECT
  COUNT(1),
  'TER_HabitualViolatorStatusTracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_HabitualViolatorStatusTracker_IDS a
JOIN
  LND_TBOS.TER_HabitualViolatorStatusTracker b
ON
  a.hvstatusid= b.hvstatusid
UNION ALL
SELECT
  COUNT(1),
  'History_TP_Customers_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.History_TP_Customers_IDS a
JOIN
  LND_TBOS.History_TP_Customers b
ON
  a.histid= b.histid
UNION ALL
SELECT
  COUNT(1),
  'TranProcessing_TSARawTransactions_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TranProcessing_TSARawTransactions_IDS a
JOIN
  LND_TBOS.TranProcessing_TSARawTransactions b
ON
  a.txnid= b.txnid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_ViolatedTrips_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_ViolatedTrips_IDS a
JOIN
  LND_TBOS.TollPlus_TP_ViolatedTrips b
ON
  a.citationid= b.citationid
UNION ALL
SELECT
  COUNT(1),
  'TER_ViolatorCollectionsOutbound_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutbound_IDS a
JOIN
  LND_TBOS.TER_ViolatorCollectionsOutbound b
ON
  a.viocolloutboundid= b.viocolloutboundid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Attributes_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Attributes_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Attributes b
ON
  a.customerid= b.customerid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Trip_Receipts_Tracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Trip_Receipts_Tracker_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Trip_Receipts_Tracker b
ON
  a.tripreceiptid= b.tripreceiptid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Emails_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Emails_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Emails b
ON
  a.custmailid= b.custmailid
UNION ALL
SELECT
  COUNT(1),
  'History_TP_Customer_Addresses_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.History_TP_Customer_Addresses_IDS a
JOIN
  LND_TBOS.History_TP_Customer_Addresses b
ON
  a.customerid= b.customerid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Plans_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Plans_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Plans b
ON
  a.custplanid= b.custplanid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_CustTxns_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_CustTxns_IDS a
JOIN
  LND_TBOS.TollPlus_TP_CustTxns b
ON
  a.custtxnid= b.custtxnid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Activities_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Activities_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Activities b
ON
  a.activityid= b.activityid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Image_Review_Results_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Image_Review_Results_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Image_Review_Results b
ON
  a.imagereviewresultid= b.imagereviewresultid
UNION ALL
SELECT
  COUNT(1),
  'TER_HabitualViolators_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_HabitualViolators_IDS a
JOIN
  LND_TBOS.TER_HabitualViolators b
ON
  a.hvid= b.hvid
UNION ALL
SELECT
  COUNT(1),
  'Finance_ChaseTransactions_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Finance_ChaseTransactions_IDS a
JOIN
  LND_TBOS.Finance_ChaseTransactions b
ON
  a.chasetransactionid= b.chasetransactionid
UNION ALL
SELECT
  COUNT(1),
  'Finance_ChequePayments_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Finance_ChequePayments_IDS a
JOIN
  LND_TBOS.Finance_ChequePayments b
ON
  a.paymentid= b.paymentid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Tags_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Tags_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Tags b
ON
  a.custtagid= b.custtagid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Phones_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Phones_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Phones b
ON
  a.custphoneid= b.custphoneid
UNION ALL
SELECT
  COUNT(1),
  'DocMgr_TP_Customer_OutboundCommunications_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.DocMgr_TP_Customer_OutboundCommunications_IDS a
JOIN
  LND_TBOS.DocMgr_TP_Customer_OutboundCommunications b
ON
  a.outboundcommunicationid= b.outboundcommunicationid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_OverPaymentsLog_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_OverPaymentsLog_IDS a
JOIN
  LND_TBOS.TollPlus_OverPaymentsLog b
ON
  a.overpaymentlogid= b.overpaymentlogid
UNION ALL
SELECT
  COUNT(1),
  'TSA_TSATripAttributes_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TSA_TSATripAttributes_IDS a
JOIN
  LND_TBOS.TSA_TSATripAttributes b
ON
  a.ttptripid= b.ttptripid
UNION ALL
SELECT
  COUNT(1),
  'Finance_Overpayments_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Finance_Overpayments_IDS a
JOIN
  LND_TBOS.Finance_Overpayments b
ON
  a.overpaymentid= b.overpaymentid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Trips_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Trips_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Trips b
ON
  a.tptripid= b.tptripid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_Invoice_LineItems_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_LineItems_IDS a
JOIN
  LND_TBOS.TollPlus_Invoice_LineItems b
ON
  a.invlineitemid= b.invlineitemid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Trip_Charges_Tracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Trip_Charges_Tracker_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Trip_Charges_Tracker b
ON
  a.tripchargeid= b.tripchargeid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Tags_History_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Tags_History_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Tags_History b
ON
  a.histid= b.histid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Violated_Trip_Charges_Tracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Violated_Trip_Charges_Tracker_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Violated_Trip_Charges_Tracker b
ON
  a.tripchargeid= b.tripchargeid
UNION ALL
SELECT
  COUNT(1),
  'TER_ViolatorCollectionsOutboundUpdate_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutboundUpdate_IDS a
JOIN
  LND_TBOS.TER_ViolatorCollectionsOutboundUpdate b
ON
  a.viocolloutboundupdateid= b.viocolloutboundupdateid
UNION ALL
SELECT
  COUNT(1),
  'TER_VehicleRegBlocks_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_VehicleRegBlocks_IDS a
JOIN
  LND_TBOS.TER_VehicleRegBlocks b
ON
  a.vrbid= b.vrbid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Flags_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Flags_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Flags b
ON
  a.customerflagid= b.customerflagid
UNION ALL
SELECT
  COUNT(1),
  'Notifications_CustNotifQueueTracker_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Notifications_CustNotifQueueTracker_IDS a
JOIN
  LND_TBOS.Notifications_CustNotifQueueTracker b
ON
  a.custnotifqueuetrackerid= b.custnotifqueuetrackerid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customers_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customers_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customers b
ON
  a.customerid= b.customerid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Balance_Alert_Facts_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Balance_Alert_Facts_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Balance_Alert_Facts b
ON
  a.customerid= b.customerid
UNION ALL
SELECT
  COUNT(1),
  'TER_ViolatorCollectionsInbound_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsInbound_IDS a
JOIN
  LND_TBOS.TER_ViolatorCollectionsInbound b
ON
  a.viocollinboundid= b.viocollinboundid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_Customer_Balances_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Balances_IDS a
JOIN
  LND_TBOS.TollPlus_TP_Customer_Balances b
ON
  a.custbalid= b.custbalid
UNION ALL
SELECT
  COUNT(1),
  'TER_FailureToPayCitations_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TER_FailureToPayCitations_IDS a
JOIN
  LND_TBOS.TER_FailureToPayCitations b
ON
  a.failurecitationid= b.failurecitationid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_TP_CustomerTrips_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_CustomerTrips_IDS a
JOIN
  LND_TBOS.TollPlus_TP_CustomerTrips b
ON
  a.custtripid= b.custtripid
UNION ALL
SELECT
  COUNT(1),
  'Finance_PaymentTxns_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.Finance_PaymentTxns_IDS a
JOIN
  LND_TBOS.Finance_PaymentTxns b
ON
  a.paymentid= b.paymentid
UNION ALL
SELECT
  COUNT(1),
  'TollPlus_UnRegisteredCustomersMbsSchedules_IDS'
FROM
  LND_TBOS_ARCHIVE_IDS.TollPlus_UnRegisteredCustomersMbsSchedules_IDS a
JOIN
  LND_TBOS.TollPlus_UnRegisteredCustomersMbsSchedules b
ON
  a.unregmbsscheduleid= b.unregmbsscheduleid