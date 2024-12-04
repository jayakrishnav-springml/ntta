UPDATE LND_TBOS.TollPlus_TP_Customer_Vehicles a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.vehicleid NOT IN (SELECT b.vehicleid FROM LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Vehicles_IDS b); 
 
UPDATE LND_TBOS.Finance_Gl_Transactions a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.gl_txnid NOT IN (SELECT b.gl_txnid FROM LND_TBOS_ARCHIVE_IDS.Finance_Gl_Transactions_IDS b); 
 
UPDATE LND_TBOS.TollPlus_TP_Customer_Logins a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.loginid NOT IN (SELECT b.loginid FROM LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Logins_IDS b); 
 
UPDATE LND_TBOS.TollPlus_TP_Customer_Business a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.customerid NOT IN (SELECT b.customerid FROM LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Business_IDS b); 
 
UPDATE LND_TBOS.TollPlus_TP_Customer_Vehicle_Tags a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.vehicletagid NOT IN (SELECT b.vehicletagid FROM LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Vehicle_Tags_IDS b); 
 
UPDATE LND_TBOS.TollPlus_TP_Customer_Emails a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.custmailid NOT IN (SELECT b.custmailid FROM LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Emails_IDS b); 
 
UPDATE LND_TBOS.TollPlus_TP_Customer_Plans a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.custplanid NOT IN (SELECT b.custplanid FROM LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Plans_IDS b); 
 
UPDATE LND_TBOS.TollPlus_TP_CustTxns a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.custtxnid NOT IN (SELECT b.custtxnid FROM LND_TBOS_ARCHIVE_IDS.TollPlus_TP_CustTxns_IDS b); 
 
UPDATE LND_TBOS.TollPlus_TP_Customer_Activities a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.activityid NOT IN (SELECT b.activityid FROM LND_TBOS_ARCHIVE_IDS.TollPlus_TP_Customer_Activities_IDS b); 
 
UPDATE LND_TBOS.Finance_ChequePayments a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.paymentid NOT IN (SELECT b.paymentid FROM LND_TBOS_ARCHIVE_IDS.Finance_ChequePayments_IDS b); 
 
UPDATE LND_TBOS.TollPlus_UnRegisteredCustomersMbsSchedules a 
SET lnd_updatetype='D'
WHERE a.lnd_updatetype= 'A'
 AND a.unregmbsscheduleid NOT IN (SELECT b.unregmbsscheduleid FROM LND_TBOS_ARCHIVE_IDS.TollPlus_UnRegisteredCustomersMbsSchedules_IDS b); 
 