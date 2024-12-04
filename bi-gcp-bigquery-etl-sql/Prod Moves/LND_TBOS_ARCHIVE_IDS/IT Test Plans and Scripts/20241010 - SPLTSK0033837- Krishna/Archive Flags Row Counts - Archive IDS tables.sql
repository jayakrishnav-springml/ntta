-- Archve Flag Row Counts on Archive ID rows

select table_name, lnd_updatetype, row_count, 		
from ARCHIVE_IDS_VALIDATION.ArchiveFlagsRowCount_Before			
where row_count <> 0 order by 1,2;			

-- This means... IDS are not yet applied to turn flags to A.
select distinct table_name 	
from ARCHIVE_IDS_VALIDATION.ArchiveFlagsRowCount_Before			
where row_count <> 0 and lnd_updatetype <> 'A' order by 1;	
/*
table_name
Finance_ChaseTransactions
Finance_ChequePayments
Finance_CustomerPayments
TollPlus_OverPaymentsLog
TranProcessing_NTTAHostBOSFileTracker
TranProcessing_NTTARawTransactions
TSA_TSATripAttributes
*/

-- After Archive Flag Update by IDS is done, all Archive ID tables should have IDS in main tables showing only A flag.
select table_name, lnd_updatetype, row_count, 		
from ARCHIVE_IDS_VALIDATION.ArchiveFlagsRowCount_After
where row_count <> 0 order by 1,2;	

CREATE OR REPLACE TABLE			
  `ARCHIVE_IDS_VALIDATION.ArchiveFlagsRowCount_After` AS			
SELECT			
  lnd_updatetype,			
  'TranProcessing_NTTAHostBOSFileTracker' table_name,			
  COUNT(1) row_count			
FROM			
  LND_TBOS.TranProcessing_NTTAHostBOSFileTracker a			
WHERE			
  a.id IN (			
  SELECT			
    b.id			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TranProcessing_NTTAHostBOSFileTracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Finance_PaymentTxn_LineItems',			
  COUNT(1)			
FROM			
  LND_TBOS.Finance_PaymentTxn_LineItems a			
WHERE			
  a.lineitemid IN (			
  SELECT			
    b.lineitemid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Finance_PaymentTxn_LineItems_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_EligibleForCitations',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_EligibleForCitations a			
WHERE			
  a.eligiblecitationid IN (			
  SELECT			
    b.eligiblecitationid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_EligibleForCitations_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'History_TP_Customer_Attributes',			
  COUNT(1)			
FROM			
  LND_TBOS.History_TP_Customer_Attributes a			
WHERE			
  a.histid IN (			
  SELECT			
    b.histid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.History_TP_Customer_Attributes_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_Mbsheader',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_Mbsheader a			
WHERE			
  a.mbsid IN (			
  SELECT			
    b.mbsid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_Mbsheader_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_DMVResponse',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_DMVResponse a			
WHERE			
  a.dmvresponseid IN (			
  SELECT			
    b.dmvresponseid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_DMVResponse_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TranProcessing_NTTARawTransactions',			
  COUNT(1)			
FROM			
  LND_TBOS.TranProcessing_NTTARawTransactions a			
WHERE			
  a.txnid IN (			
  SELECT			
    b.txnid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TranProcessing_NTTARawTransactions_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Internal_Users',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Internal_Users a			
WHERE			
  a.customerid IN (			
  SELECT			
    b.customerid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Internal_Users_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Vehicles',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Vehicles a			
WHERE			
  a.vehicleid IN (			
  SELECT			
    b.vehicleid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Vehicles_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_Invoice_Charges_Tracker',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_Invoice_Charges_Tracker a			
WHERE			
  a.invoicechargeid IN (			
  SELECT			
    b.invoicechargeid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_Charges_Tracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_HVEligibleTransactions',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_HVEligibleTransactions a			
WHERE			
  a.hveligibletxnid IN (			
  SELECT			
    b.hveligibletxnid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_HVEligibleTransactions_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Finance_Gl_Transactions',			
  COUNT(1)			
FROM			
  LND_TBOS.Finance_Gl_Transactions a			
WHERE			
  a.gl_txnid IN (			
  SELECT			
    b.gl_txnid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Finance_Gl_Transactions_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Violated_Trip_Receipts_Tracker',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Violated_Trip_Receipts_Tracker a			
WHERE			
  a.tripreceiptid IN (			
  SELECT			
    b.tripreceiptid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Violated_Trip_Receipts_Tracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_MbsInvoices',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_MbsInvoices a			
WHERE			
  a.mbsinvoicesid IN (			
  SELECT			
    b.mbsinvoicesid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_MbsInvoices_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Logins',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Logins a			
WHERE			
  a.loginid IN (			
  SELECT			
    b.loginid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Logins_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_ViolatorCollectionsOutboundStatus',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_ViolatorCollectionsOutboundStatus a			
WHERE			
  a.viocolloutboundstatusupdateid IN (			
  SELECT			
    b.viocolloutboundstatusupdateid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutboundStatus_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_Invoice_Header',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_Invoice_Header a			
WHERE			
  a.invoiceid IN (			
  SELECT			
    b.invoiceid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_Header_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Addresses',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Addresses a			
WHERE			
  a.custaddressid IN (			
  SELECT			
    b.custaddressid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Addresses_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_AccStatus_Tracker',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_AccStatus_Tracker a			
WHERE			
  a.accstatushistid IN (			
  SELECT			
    b.accstatushistid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_AccStatus_Tracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Finance_Adjustments',			
  COUNT(1)			
FROM			
  LND_TBOS.Finance_Adjustments a			
WHERE			
  a.adjustmentid IN (			
  SELECT			
    b.adjustmentid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Finance_Adjustments_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Notifications_CustomerNotificationQueue',			
  COUNT(1)			
FROM			
  LND_TBOS.Notifications_CustomerNotificationQueue a			
WHERE			
  a.customernotificationqueueid IN (			
  SELECT			
    b.customernotificationqueueid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Notifications_CustomerNotificationQueue_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Finance_Gl_Txn_LineItems',			
  COUNT(1)			
FROM			
  LND_TBOS.Finance_Gl_Txn_LineItems a			
WHERE			
  a.pk_id IN (			
  SELECT			
    b.pk_id			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Finance_Gl_Txn_LineItems_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Business',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Business a			
WHERE			
  a.customerid IN (			
  SELECT			
    b.customerid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Business_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Invoice_Receipts_Tracker',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Invoice_Receipts_Tracker a			
WHERE			
  a.receiptid IN (			
  SELECT			
    b.receiptid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Invoice_Receipts_Tracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Contacts',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Contacts a			
WHERE			
  a.contactid IN (			
  SELECT			
    b.contactid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Contacts_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Finance_Adjustment_LineItems',			
  COUNT(1)			
FROM			
  LND_TBOS.Finance_Adjustment_LineItems a			
WHERE			
  a.adjlineitemid IN (			
  SELECT			
    b.adjlineitemid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Finance_Adjustment_LineItems_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_ViolatorCollectionsAgencyTracker',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_ViolatorCollectionsAgencyTracker a			
WHERE			
  a.viocollagencytrackerid IN (			
  SELECT			
    b.viocollagencytrackerid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsAgencyTracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Vehicle_Tags',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Vehicle_Tags a			
WHERE			
  a.vehicletagid IN (			
  SELECT			
    b.vehicletagid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Vehicle_Tags_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'IOP_BOS_IOP_OutboundTransactions',			
  COUNT(1)			
FROM			
  LND_TBOS.IOP_BOS_IOP_OutboundTransactions a			
WHERE			
  a.bosioptransactionid IN (			
  SELECT			
    b.bosioptransactionid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.IOP_BOS_IOP_OutboundTransactions_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_DMVRequestTracker',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_DMVRequestTracker a			
WHERE			
  a.requesttrackerid IN (			
  SELECT			
    b.requesttrackerid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_DMVRequestTracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Finance_CustomerPayments',			
  COUNT(1)			
FROM			
  LND_TBOS.Finance_CustomerPayments a			
WHERE			
  a.custpaymentid IN (			
  SELECT			
    b.custpaymentid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Finance_CustomerPayments_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_HabitualViolatorStatusTracker',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_HabitualViolatorStatusTracker a			
WHERE			
  a.hvstatusid IN (			
  SELECT			
    b.hvstatusid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_HabitualViolatorStatusTracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'History_TP_Customers',			
  COUNT(1)			
FROM			
  LND_TBOS.History_TP_Customers a			
WHERE			
  a.histid IN (			
  SELECT			
    b.histid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.History_TP_Customers_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TranProcessing_TSARawTransactions',			
  COUNT(1)			
FROM			
  LND_TBOS.TranProcessing_TSARawTransactions a			
WHERE			
  a.txnid IN (			
  SELECT			
    b.txnid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TranProcessing_TSARawTransactions_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_ViolatedTrips',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_ViolatedTrips a			
WHERE			
  a.citationid IN (			
  SELECT			
    b.citationid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_ViolatedTrips_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_ViolatorCollectionsOutbound',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_ViolatorCollectionsOutbound a			
WHERE			
  a.viocolloutboundid IN (			
  SELECT			
    b.viocolloutboundid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutbound_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Attributes',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Attributes a			
WHERE			
  a.customerid IN (			
  SELECT			
    b.customerid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Attributes_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Trip_Receipts_Tracker',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Trip_Receipts_Tracker a			
WHERE			
  a.tripreceiptid IN (			
  SELECT			
    b.tripreceiptid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Trip_Receipts_Tracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Emails',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Emails a			
WHERE			
  a.custmailid IN (			
  SELECT			
    b.custmailid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Emails_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'History_TP_Customer_Addresses',			
  COUNT(1)			
FROM			
  LND_TBOS.History_TP_Customer_Addresses a			
WHERE			
  a.customerid IN (			
  SELECT			
    b.customerid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.History_TP_Customer_Addresses_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Plans',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Plans a			
WHERE			
  a.custplanid IN (			
  SELECT			
    b.custplanid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Plans_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_CustTxns',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_CustTxns a			
WHERE			
  a.custtxnid IN (			
  SELECT			
    b.custtxnid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_CustTxns_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Activities',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Activities a			
WHERE			
  a.activityid IN (			
  SELECT			
    b.activityid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Activities_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Image_Review_Results',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Image_Review_Results a			
WHERE			
  a.imagereviewresultid IN (			
  SELECT			
    b.imagereviewresultid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Image_Review_Results_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_HabitualViolators',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_HabitualViolators a			
WHERE			
  a.hvid IN (			
  SELECT			
    b.hvid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_HabitualViolators_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Finance_ChaseTransactions',			
  COUNT(1)			
FROM			
  LND_TBOS.Finance_ChaseTransactions a			
WHERE			
  a.chasetransactionid IN (			
  SELECT			
    b.chasetransactionid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Finance_ChaseTransactions_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Finance_ChequePayments',			
  COUNT(1)			
FROM			
  LND_TBOS.Finance_ChequePayments a			
WHERE			
  a.paymentid IN (			
  SELECT			
    b.paymentid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Finance_ChequePayments_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Tags',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Tags a			
WHERE			
  a.custtagid IN (			
  SELECT			
    b.custtagid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Tags_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Phones',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Phones a			
WHERE			
  a.custphoneid IN (			
  SELECT			
    b.custphoneid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Phones_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'DocMgr_TP_Customer_OutboundCommunications',			
  COUNT(1)			
FROM			
  LND_TBOS.DocMgr_TP_Customer_OutboundCommunications a			
WHERE			
  a.outboundcommunicationid IN (			
  SELECT			
    b.outboundcommunicationid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.DocMgr_TP_Customer_OutboundCommunications_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_OverPaymentsLog',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_OverPaymentsLog a			
WHERE			
  a.overpaymentlogid IN (			
  SELECT			
    b.overpaymentlogid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_OverPaymentsLog_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TSA_TSATripAttributes',			
  COUNT(1)			
FROM			
  LND_TBOS.TSA_TSATripAttributes a			
WHERE			
  a.ttptripid IN (			
  SELECT			
    b.ttptripid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TSA_TSATripAttributes_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Finance_Overpayments',			
  COUNT(1)			
FROM			
  LND_TBOS.Finance_Overpayments a			
WHERE			
  a.overpaymentid IN (			
  SELECT			
    b.overpaymentid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Finance_Overpayments_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Trips',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Trips a			
WHERE			
  a.tptripid IN (			
  SELECT			
    b.tptripid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Trips_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_Invoice_LineItems',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_Invoice_LineItems a			
WHERE			
  a.invlineitemid IN (			
  SELECT			
    b.invlineitemid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_LineItems_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Trip_Charges_Tracker',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Trip_Charges_Tracker a			
WHERE			
  a.tripchargeid IN (			
  SELECT			
    b.tripchargeid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Trip_Charges_Tracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Tags_History',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Tags_History a			
WHERE			
  a.histid IN (			
  SELECT			
    b.histid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Tags_History_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Violated_Trip_Charges_Tracker',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Violated_Trip_Charges_Tracker a			
WHERE			
  a.tripchargeid IN (			
  SELECT			
    b.tripchargeid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Violated_Trip_Charges_Tracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_ViolatorCollectionsOutboundUpdate',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_ViolatorCollectionsOutboundUpdate a			
WHERE			
  a.viocolloutboundupdateid IN (			
  SELECT			
    b.viocolloutboundupdateid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutboundUpdate_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_VehicleRegBlocks',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_VehicleRegBlocks a			
WHERE			
  a.vrbid IN (			
  SELECT			
    b.vrbid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_VehicleRegBlocks_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Flags',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Flags a			
WHERE			
  a.customerflagid IN (			
  SELECT			
    b.customerflagid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Flags_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Notifications_CustNotifQueueTracker',			
  COUNT(1)			
FROM			
  LND_TBOS.Notifications_CustNotifQueueTracker a			
WHERE			
  a.custnotifqueuetrackerid IN (			
  SELECT			
    b.custnotifqueuetrackerid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Notifications_CustNotifQueueTracker_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customers',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customers a			
WHERE			
  a.customerid IN (			
  SELECT			
    b.customerid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customers_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Balance_Alert_Facts',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Balance_Alert_Facts a			
WHERE			
  a.customerid IN (			
  SELECT			
    b.customerid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Balance_Alert_Facts_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_ViolatorCollectionsInbound',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_ViolatorCollectionsInbound a			
WHERE			
  a.viocollinboundid IN (			
  SELECT			
    b.viocollinboundid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsInbound_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_Customer_Balances',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_Customer_Balances a			
WHERE			
  a.custbalid IN (			
  SELECT			
    b.custbalid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Balances_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TER_FailureToPayCitations',			
  COUNT(1)			
FROM			
  LND_TBOS.TER_FailureToPayCitations a			
WHERE			
  a.failurecitationid IN (			
  SELECT			
    b.failurecitationid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TER_FailureToPayCitations_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_TP_CustomerTrips',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_TP_CustomerTrips a			
WHERE			
  a.custtripid IN (			
  SELECT			
    b.custtripid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_TP_CustomerTrips_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'Finance_PaymentTxns',			
  COUNT(1)			
FROM			
  LND_TBOS.Finance_PaymentTxns a			
WHERE			
  a.paymentid IN (			
  SELECT			
    b.paymentid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.Finance_PaymentTxns_IDS b)			
GROUP BY			
  a.lnd_updatetype			
UNION ALL			
SELECT			
  lnd_updatetype,			
  'TollPlus_UnRegisteredCustomersMbsSchedules',			
  COUNT(1)			
FROM			
  LND_TBOS.TollPlus_UnRegisteredCustomersMbsSchedules a			
WHERE			
  a.unregmbsscheduleid IN (			
  SELECT			
    b.unregmbsscheduleid			
  FROM			
    LND_TBOS_ARCHIVE_IDS.TollPlus_UnRegisteredCustomersMbsSchedules_IDS b)			
GROUP BY			
  a.lnd_updatetype			
order by table_name, lnd_updatetype			
