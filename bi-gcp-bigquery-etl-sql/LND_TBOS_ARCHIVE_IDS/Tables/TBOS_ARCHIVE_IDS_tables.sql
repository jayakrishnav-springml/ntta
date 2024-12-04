CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TranProcessing_NTTAHostBOSFileTracker_IDS (id INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (id) NOT ENFORCED
    )
CLUSTER BY
  id ;
  
CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Finance_PaymentTxn_LineItems_IDS (lineitemid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (lineitemid) NOT ENFORCED
    )
CLUSTER BY
  lineitemid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_EligibleForCitations_IDS (eligiblecitationid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (eligiblecitationid) NOT ENFORCED
    )
CLUSTER BY
  eligiblecitationid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.History_TP_Customer_Attributes_IDS (histid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (histid) NOT ENFORCED
    )
CLUSTER BY
  histid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_Mbsheader_IDS (mbsid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (mbsid) NOT ENFORCED
    )
CLUSTER BY
  mbsid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_DMVResponse_IDS (dmvresponseid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (dmvresponseid) NOT ENFORCED
    )
CLUSTER BY
  dmvresponseid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TranProcessing_NTTARawTransactions_IDS (txnid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (txnid) NOT ENFORCED
    )
CLUSTER BY
  txnid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Internal_Users_IDS (customerid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (customerid) NOT ENFORCED
    )
CLUSTER BY
  customerid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Vehicles_IDS (vehicleid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (vehicleid) NOT ENFORCED
    )
CLUSTER BY
  vehicleid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_Charges_Tracker_IDS (invoicechargeid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (invoicechargeid) NOT ENFORCED
    )
CLUSTER BY
  invoicechargeid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_HVEligibleTransactions_IDS (hveligibletxnid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (hveligibletxnid) NOT ENFORCED
    )
CLUSTER BY
  hveligibletxnid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Finance_Gl_Transactions_IDS (gl_txnid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (gl_txnid) NOT ENFORCED
    )
CLUSTER BY
  gl_txnid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Violated_Trip_Receipts_Tracker_IDS (tripreceiptid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (tripreceiptid) NOT ENFORCED
    )
CLUSTER BY
  tripreceiptid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_MbsInvoices_IDS (mbsinvoicesid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (mbsinvoicesid) NOT ENFORCED
    )
CLUSTER BY
  mbsinvoicesid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Logins_IDS (loginid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (loginid) NOT ENFORCED
    )
CLUSTER BY
  loginid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutboundStatus_IDS (viocolloutboundstatusupdateid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (viocolloutboundstatusupdateid) NOT ENFORCED
    )
CLUSTER BY
  viocolloutboundstatusupdateid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_Header_IDS (invoiceid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (invoiceid) NOT ENFORCED
    )
CLUSTER BY
  invoiceid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Addresses_IDS (custaddressid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (custaddressid) NOT ENFORCED
    )
CLUSTER BY
  custaddressid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_AccStatus_Tracker_IDS (accstatushistid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (accstatushistid) NOT ENFORCED
    )
CLUSTER BY
  accstatushistid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Finance_Adjustments_IDS (adjustmentid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (adjustmentid) NOT ENFORCED
    )
CLUSTER BY
  adjustmentid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Notifications_CustomerNotificationQueue_IDS (customernotificationqueueid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (customernotificationqueueid) NOT ENFORCED
    )
CLUSTER BY
  customernotificationqueueid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Finance_Gl_Txn_LineItems_IDS (pk_id INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (pk_id) NOT ENFORCED
    )
CLUSTER BY
  pk_id ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Business_IDS (customerid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (customerid) NOT ENFORCED
    )
CLUSTER BY
  customerid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Invoice_Receipts_Tracker_IDS (receiptid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (receiptid) NOT ENFORCED
    )
CLUSTER BY
  receiptid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Contacts_IDS (contactid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (contactid) NOT ENFORCED
    )
CLUSTER BY
  contactid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Finance_Adjustment_LineItems_IDS (adjlineitemid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (adjlineitemid) NOT ENFORCED
    )
CLUSTER BY
  adjlineitemid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsAgencyTracker_IDS (viocollagencytrackerid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (viocollagencytrackerid) NOT ENFORCED
    )
CLUSTER BY
  viocollagencytrackerid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Vehicle_Tags_IDS (vehicletagid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (vehicletagid) NOT ENFORCED
    )
CLUSTER BY
  vehicletagid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.IOP_BOS_IOP_OutboundTransactions_IDS (bosioptransactionid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (bosioptransactionid) NOT ENFORCED
    )
CLUSTER BY
  bosioptransactionid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_DMVRequestTracker_IDS (requesttrackerid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (requesttrackerid) NOT ENFORCED
    )
CLUSTER BY
  requesttrackerid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Finance_CustomerPayments_IDS (custpaymentid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (custpaymentid) NOT ENFORCED
    )
CLUSTER BY
  custpaymentid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_HabitualViolatorStatusTracker_IDS (hvstatusid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (hvstatusid) NOT ENFORCED
    )
CLUSTER BY
  hvstatusid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.History_TP_Customers_IDS (histid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (histid) NOT ENFORCED
    )
CLUSTER BY
  histid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TranProcessing_TSARawTransactions_IDS (txnid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (txnid) NOT ENFORCED
    )
CLUSTER BY
  txnid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_ViolatedTrips_IDS (citationid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (citationid) NOT ENFORCED
    )
CLUSTER BY
  citationid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutbound_IDS (viocolloutboundid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (viocolloutboundid) NOT ENFORCED
    )
CLUSTER BY
  viocolloutboundid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Attributes_IDS (customerid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (customerid) NOT ENFORCED
    )
CLUSTER BY
  customerid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Trip_Receipts_Tracker_IDS (tripreceiptid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (tripreceiptid) NOT ENFORCED
    )
CLUSTER BY
  tripreceiptid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Emails_IDS (custmailid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (custmailid) NOT ENFORCED
    )
CLUSTER BY
  custmailid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.History_TP_Customer_Addresses_IDS (customerid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (customerid) NOT ENFORCED
    )
CLUSTER BY
  customerid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Plans_IDS (custplanid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (custplanid) NOT ENFORCED
    )
CLUSTER BY
  custplanid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_CustTxns_IDS (custtxnid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (custtxnid) NOT ENFORCED
    )
CLUSTER BY
  custtxnid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Activities_IDS (activityid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (activityid) NOT ENFORCED
    )
CLUSTER BY
  activityid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Image_Review_Results_IDS (imagereviewresultid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (imagereviewresultid) NOT ENFORCED
    )
CLUSTER BY
  imagereviewresultid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_HabitualViolators_IDS (hvid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (hvid) NOT ENFORCED
    )
CLUSTER BY
  hvid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Finance_ChaseTransactions_IDS (chasetransactionid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (chasetransactionid) NOT ENFORCED
    )
CLUSTER BY
  chasetransactionid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Finance_ChequePayments_IDS (paymentid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (paymentid) NOT ENFORCED
    )
CLUSTER BY
  paymentid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Tags_IDS (custtagid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (custtagid) NOT ENFORCED
    )
CLUSTER BY
  custtagid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Phones_IDS (custphoneid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (custphoneid) NOT ENFORCED
    )
CLUSTER BY
  custphoneid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.DocMgr_TP_Customer_OutboundCommunications_IDS (outboundcommunicationid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (outboundcommunicationid) NOT ENFORCED
    )
CLUSTER BY
  outboundcommunicationid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_OverPaymentsLog_IDS (overpaymentlogid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (overpaymentlogid) NOT ENFORCED
    )
CLUSTER BY
  overpaymentlogid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TSA_TSATripAttributes_IDS (ttptripid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (ttptripid) NOT ENFORCED
    )
CLUSTER BY
  ttptripid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Finance_Overpayments_IDS (overpaymentid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (overpaymentid) NOT ENFORCED
    )
CLUSTER BY
  overpaymentid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Trips_IDS (tptripid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (tptripid) NOT ENFORCED
    )
CLUSTER BY
  tptripid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_Invoice_LineItems_IDS (invlineitemid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (invlineitemid) NOT ENFORCED
    )
CLUSTER BY
  invlineitemid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Trip_Charges_Tracker_IDS (tripchargeid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (tripchargeid) NOT ENFORCED
    )
CLUSTER BY
  tripchargeid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Tags_History_IDS (histid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (histid) NOT ENFORCED
    )
CLUSTER BY
  histid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Violated_Trip_Charges_Tracker_IDS (tripchargeid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (tripchargeid) NOT ENFORCED
    )
CLUSTER BY
  tripchargeid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsOutboundUpdate_IDS (viocolloutboundupdateid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (viocolloutboundupdateid) NOT ENFORCED
    )
CLUSTER BY
  viocolloutboundupdateid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_VehicleRegBlocks_IDS (vrbid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (vrbid) NOT ENFORCED
    )
CLUSTER BY
  vrbid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Flags_IDS (customerflagid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (customerflagid) NOT ENFORCED
    )
CLUSTER BY
  customerflagid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Notifications_CustNotifQueueTracker_IDS (custnotifqueuetrackerid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (custnotifqueuetrackerid) NOT ENFORCED
    )
CLUSTER BY
  custnotifqueuetrackerid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customers_IDS (customerid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (customerid) NOT ENFORCED
    )
CLUSTER BY
  customerid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Balance_Alert_Facts_IDS (customerid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (customerid) NOT ENFORCED
    )
CLUSTER BY
  customerid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_ViolatorCollectionsInbound_IDS (viocollinboundid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (viocollinboundid) NOT ENFORCED
    )
CLUSTER BY
  viocollinboundid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Balances_IDS (custbalid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (custbalid) NOT ENFORCED
    )
CLUSTER BY
  custbalid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TER_FailureToPayCitations_IDS (failurecitationid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (failurecitationid) NOT ENFORCED
    )
CLUSTER BY
  failurecitationid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TP_CustomerTrips_IDS (custtripid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (custtripid) NOT ENFORCED
    )
CLUSTER BY
  custtripid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.Finance_PaymentTxns_IDS (paymentid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (paymentid) NOT ENFORCED
    )
CLUSTER BY
  paymentid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_UnRegisteredCustomersMbsSchedules_IDS (unregmbsscheduleid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (unregmbsscheduleid) NOT ENFORCED
    )
CLUSTER BY
  unregmbsscheduleid ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS.TollPlus_TpFileTracker_IDS (fileid INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (fileid) NOT ENFORCED
    )
CLUSTER BY
  fileid