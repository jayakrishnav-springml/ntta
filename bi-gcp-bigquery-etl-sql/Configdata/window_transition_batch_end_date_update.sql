/*Below script will generate Union all statment fetching table name and max(src_changedate)with all target tables from CDC_Full_Load_Config*/
SELECT STRING_AGG(" SELECT '"||target_table_name||"' table_name,DATETIME_SUB(max(src_changedate), INTERVAL 1 hour ) src_changedate_to from LND_TBOS."||target_table_name,' UNION ALL ') FROM `LND_TBOS_SUPPORT.CDC_Full_Load_Config`

/*Loads table_name and max(src_changedate) into a table */
create or replace table LND_TBOS_SUPPORT.cdc_batch_end_date
AS 
SELECT
  'TranProcessing_NTTAHostBOSFileTracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TranProcessing_NTTAHostBOSFileTracker
UNION ALL
SELECT
  'TollPlus_IOPTagAgencyMapping' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_IOPTagAgencyMapping
UNION ALL
SELECT
  'TER_HabitualViolators' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_HabitualViolators
UNION ALL
SELECT
  'TollPlus_ICN' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_ICN
UNION ALL
SELECT
  'TollPlus_Mbsheader' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Mbsheader
UNION ALL
SELECT
  'TranProcessing_RecordTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TranProcessing_RecordTypes
UNION ALL
SELECT
  'TranProcessing_NTTARawTransactions' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TranProcessing_NTTARawTransactions
UNION ALL
SELECT
  'TranProcessing_TSARawTransactions' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TranProcessing_TSARawTransactions
UNION ALL
SELECT
  'TER_VehicleRegBlocks' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_VehicleRegBlocks
UNION ALL
SELECT
  'TranProcessing_TxnDispositions' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TranProcessing_TxnDispositions
UNION ALL
SELECT
  'TollPlus_TpFileTracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TpFileTracker
UNION ALL
SELECT
  'TollPlus_TP_Customer_Tags_History' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Tags_History
UNION ALL
SELECT
  'History_TP_Customer_Attributes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.History_TP_Customer_Attributes
UNION ALL
SELECT
  'History_TP_Customers' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.History_TP_Customers
UNION ALL
SELECT
  'TollPlus_Lanes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Lanes
UNION ALL
SELECT
  'TollPlus_Plans' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Plans
UNION ALL
SELECT
  'CaseManager_PmCase' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.CaseManager_PmCase
UNION ALL
SELECT
  'EIP_AuditTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.EIP_AuditTypes
UNION ALL
SELECT
  'Court_Courts' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Court_Courts
UNION ALL
SELECT
  'Court_Courtjudges' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Court_Courtjudges
UNION ALL
SELECT
  'TollPlus_TP_Customer_Logins' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Logins
UNION ALL
SELECT
  'TollPlus_Plazas' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Plazas
UNION ALL
SELECT
  'MIR_TxnQueues' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.MIR_TxnQueues
UNION ALL
SELECT
  'MIR_TxnStages' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.MIR_TxnStages
UNION ALL
SELECT
  'TollPlus_Ref_Invoice_Workflow_Stages' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Ref_Invoice_Workflow_Stages
UNION ALL
SELECT
  'TollPlus_ZipCodes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_ZipCodes
UNION ALL
SELECT
  'TollPlus_Agencies' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Agencies
UNION ALL
SELECT
  'Court_Counties' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Court_Counties
UNION ALL
SELECT
  'TollPlus_TexasCounties' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TexasCounties
UNION ALL
SELECT
  'MIR_TxnStatuses' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.MIR_TxnStatuses
UNION ALL
SELECT
  'TollPlus_TP_Trips' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Trips
UNION ALL
SELECT
  'TollPlus_Channels' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Channels
UNION ALL
SELECT
  'TollPlus_TP_Customer_Tags' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Tags
UNION ALL
SELECT
  'TollPlus_TP_CustTxns' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_CustTxns
UNION ALL
SELECT
  'TollPlus_TP_Customer_Balances' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Balances
UNION ALL
SELECT
  'TollPlus_Ref_FeeTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Ref_FeeTypes
UNION ALL
SELECT
  'TollPlus_Invoice_Header' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Invoice_Header
UNION ALL
SELECT
  'Finance_PaymentTxns' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_PaymentTxns
UNION ALL
SELECT
  'Finance_ChequePayments' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_ChequePayments
UNION ALL
SELECT
  'TollPlus_TP_Invoice_Receipts_Tracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Invoice_Receipts_Tracker
UNION ALL
SELECT
  'TSA_TSATripAttributes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TSA_TSATripAttributes
UNION ALL
SELECT
  'Finance_TxnTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_TxnTypes
UNION ALL
SELECT
  'TollPlus_ViolationVehicleTransferCustomers' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_ViolationVehicleTransferCustomers
UNION ALL
SELECT
  'TollPlus_TP_Customer_Vehicles' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Vehicles
UNION ALL
SELECT
  'TollPlus_TP_Customer_Activities' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Activities
UNION ALL
SELECT
  'CaseManager_PmCaseTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.CaseManager_PmCaseTypes
UNION ALL
SELECT
  'TollPlus_TxnType_Categories' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TxnType_Categories
UNION ALL
SELECT
  'TollPlus_TP_ViolatedTrips' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_ViolatedTrips
UNION ALL
SELECT
  'TollPlus_TP_Customer_Emails' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Emails
UNION ALL
SELECT
  'TollPlus_TP_Customer_Plans' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Plans
UNION ALL
SELECT
  'TollPlus_TP_CustomerTrips' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_CustomerTrips
UNION ALL
SELECT
  'TollPlus_TP_Customer_Internal_Users' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Internal_Users
UNION ALL
SELECT
  'TollPlus_TP_Customers' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customers
UNION ALL
SELECT
  'TollPlus_TP_Customer_Balance_Alert_Facts' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Balance_Alert_Facts
UNION ALL
SELECT
  'TollPlus_TP_Customer_Business' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Business
UNION ALL
SELECT
  'History_TP_Customer_Addresses' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.History_TP_Customer_Addresses
UNION ALL
SELECT
  'TollPlus_TP_Customer_Attributes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Attributes
UNION ALL
SELECT
  'TollPlus_TP_Customer_Contacts' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Contacts
UNION ALL
SELECT
  'TER_HabitualViolatorStatusTracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_HabitualViolatorStatusTracker
UNION ALL
SELECT
  'Inventory_ItemTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Inventory_ItemTypes
UNION ALL
SELECT
  'Finance_PaymentTxn_LineItems' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_PaymentTxn_LineItems
UNION ALL
SELECT
  'TollPlus_Locations' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Locations
UNION ALL
SELECT
  'TER_CitationNumberSequence' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_CitationNumberSequence
UNION ALL
SELECT
  'TollPlus_Ref_Invoice_Workflow_Stage_Fees' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Ref_Invoice_Workflow_Stage_Fees
UNION ALL
SELECT
  'EIP_VehicleImages' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.EIP_VehicleImages
UNION ALL
SELECT
  'TollPlus_Violation_Workflow' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Violation_Workflow
UNION ALL
SELECT
  'Notifications_AlertTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Notifications_AlertTypes
UNION ALL
SELECT
  'TER_BanActions' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_BanActions
UNION ALL
SELECT
  'TollPlus_TP_Customer_Phones' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Phones
UNION ALL
SELECT
  'TollPlus_FleetCustomerAttributes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_FleetCustomerAttributes
UNION ALL
SELECT
  'TollPlus_TP_AppLication_Parameters' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_AppLication_Parameters
UNION ALL
SELECT
  'TollPlus_PlateTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_PlateTypes
UNION ALL
SELECT
  'TollPlus_Plaza_Types' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Plaza_Types
UNION ALL
SELECT
  'MIR_TxnStageTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.MIR_TxnStageTypes
UNION ALL
SELECT
  'TollPlus_SubSystems' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_SubSystems
UNION ALL
SELECT
  'TollPlus_TripStages' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TripStages
UNION ALL
SELECT
  'Finance_Adjustments' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_Adjustments
UNION ALL
SELECT
  'TER_CollectionAgencies' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_CollectionAgencies
UNION ALL
SELECT
  'TER_DPSTrooper' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_DPSTrooper
UNION ALL
SELECT
  'Court_PlazaCourts' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Court_PlazaCourts
UNION ALL
SELECT
  'TollPlus_TP_TollTxn_ReasonCodes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_TollTxn_ReasonCodes
UNION ALL
SELECT
  'MIR_ReasonCodes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.MIR_ReasonCodes
UNION ALL
SELECT
  'MIR_MST_SourceTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.MIR_MST_SourceTypes
UNION ALL
SELECT
  'TollPlus_TP_Violated_Trip_Charges_Tracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Violated_Trip_Charges_Tracker
UNION ALL
SELECT
  'TollPlus_TP_Customer_Trip_Charges_Tracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Trip_Charges_Tracker
UNION ALL
SELECT
  'TranProcessing_TripSource' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TranProcessing_TripSource
UNION ALL
SELECT
  'TollPlus_TripStatuses' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TripStatuses
UNION ALL
SELECT
  'TER_VehicleBan' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_VehicleBan
UNION ALL
SELECT
  'TollPlus_TP_Customer_Vehicle_Tags' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Vehicle_Tags
UNION ALL
SELECT
  'TollPlus_AppTxnTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_AppTxnTypes
UNION ALL
SELECT
  'Finance_Adjustment_LineItems' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_Adjustment_LineItems
UNION ALL
SELECT
  'TollPlus_TP_Bankruptcy_Filing' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Bankruptcy_Filing
UNION ALL
SELECT
  'TollPlus_TP_Customer_Addresses' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Addresses
UNION ALL
SELECT
  'Finance_CustomerPayments' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_CustomerPayments
UNION ALL
SELECT
  'TollPlus_DMVResponse' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_DMVResponse
UNION ALL
SELECT
  'TollPlus_Invoice_LineItems' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Invoice_LineItems
UNION ALL
SELECT
  'TollPlus_MbsInvoices' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_MbsInvoices
UNION ALL
SELECT
  'Finance_Overpayments' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_Overpayments
UNION ALL
SELECT
  'TER_PaymentPlans' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_PaymentPlans
UNION ALL
SELECT
  'TollPlus_TP_TollRate_Dtls' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_TollRate_Dtls
UNION ALL
SELECT
  'TollPlus_TP_TollRate_Hdr' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_TollRate_Hdr
UNION ALL
SELECT
  'EIP_Transactions' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.EIP_Transactions
UNION ALL
SELECT
  'TollPlus_TP_Customer_Trip_Receipts_Tracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Trip_Receipts_Tracker
UNION ALL
SELECT
  'TollPlus_TP_Violated_Trip_Receipts_Tracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Violated_Trip_Receipts_Tracker
UNION ALL
SELECT
  'Court_AdminHearing' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Court_AdminHearing
UNION ALL
SELECT
  'Notifications_AlertChannels' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Notifications_AlertChannels
UNION ALL
SELECT
  'TollPlus_TP_Customer_Flags' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_Flags
UNION ALL
SELECT
  'TER_DPSBanActions' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_DPSBanActions
UNION ALL
SELECT
  'TollPlus_LaneCategories' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_LaneCategories
UNION ALL
SELECT
  'Rbac_LocationRoles' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Rbac_LocationRoles
UNION ALL
SELECT
  'MIR_MST_ResponseTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.MIR_MST_ResponseTypes
UNION ALL
SELECT
  'TollPlus_VehicleClasses' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_VehicleClasses
UNION ALL
SELECT
  'TollPlus_TP_Vehicle_Models' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Vehicle_Models
UNION ALL
SELECT
  'TollPlus_TP_Customer_AccStatus_Tracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Customer_AccStatus_Tracker
UNION ALL
SELECT
  'TollPlus_AddressSources' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_AddressSources
UNION ALL
SELECT
  'TER_HVEligibleTransactions' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_HVEligibleTransactions
UNION ALL
SELECT
  'TollPlus_Invoice_Charges_Tracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Invoice_Charges_Tracker
UNION ALL
SELECT
  'Finance_RefundRequests_Queue' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_RefundRequests_Queue
UNION ALL
SELECT
  'TER_VRBRequestDMV' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_VRBRequestDMV
UNION ALL
SELECT
  'TollPlus_BankruptcyTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_BankruptcyTypes
UNION ALL
SELECT
  'Finance_ChartOfAccounts' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_ChartOfAccounts
UNION ALL
SELECT
  'TollPlus_DMVExceptionQueue' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_DMVExceptionQueue
UNION ALL
SELECT
  'TER_HVStatusLookup' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_HVStatusLookup
UNION ALL
SELECT
  'TollPlus_Ref_LookupTypeCodes_Hierarchy' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
UNION ALL
SELECT
  'TollPlus_DMVRequestTracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_DMVRequestTracker
UNION ALL
SELECT
  'Finance_TollAdjustments' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_TollAdjustments
UNION ALL
SELECT
  'Finance_BusinessProcess_TxnTypes_Associations' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_BusinessProcess_TxnTypes_Associations
UNION ALL
SELECT
  'TER_ViolatorCollectionsInbound' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_ViolatorCollectionsInbound
UNION ALL
SELECT
  'TollPlus_OverPaymentsLog' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_OverPaymentsLog
UNION ALL
SELECT
  'Finance_BusinessProcesses' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_BusinessProcesses
UNION ALL
SELECT
  'TER_FailureToPayCitations' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_FailureToPayCitations
UNION ALL
SELECT
  'TollPlus_LocationChannels' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_LocationChannels
UNION ALL
SELECT
  'TER_PaymentPlanTerms' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_PaymentPlanTerms
UNION ALL
SELECT
  'TollPlus_TollScheduleDtl' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TollScheduleDtl
UNION ALL
SELECT
  'TollPlus_TollScheduleHdr' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TollScheduleHdr
UNION ALL
SELECT
  'TollPlus_TP_Transaction_Types' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Transaction_Types
UNION ALL
SELECT
  'MIR_MST_TransactionTypes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.MIR_MST_TransactionTypes
UNION ALL
SELECT
  'TER_VRBAgencyLookup' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_VRBAgencyLookup
UNION ALL
SELECT
  'TER_VRBRejectLookup' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_VRBRejectLookup
UNION ALL
SELECT
  'TER_ViolatorCollectionsOutbound' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_ViolatorCollectionsOutbound
UNION ALL
SELECT
  'TollPlus_BankruptcyStatuses' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_BankruptcyStatuses
UNION ALL
SELECT
  'Finance_ChaseTransactions' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_ChaseTransactions
UNION ALL
SELECT
  'TER_EligibleForCitations' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_EligibleForCitations
UNION ALL
SELECT
  'TollPlus_MbsProcessStatus' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_MbsProcessStatus
UNION ALL
SELECT
  'TollPlus_UnRegisteredCustomersMbsSchedules' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_UnRegisteredCustomersMbsSchedules
UNION ALL
SELECT
  'TER_VRBRequestDallas' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_VRBRequestDallas
UNION ALL
SELECT
  'IOP_BOS_IOP_OutboundTransactions' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.IOP_BOS_IOP_OutboundTransactions
UNION ALL
SELECT
  'TollPlus_TP_Image_Review_Results' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_TP_Image_Review_Results
UNION ALL
SELECT
  'TER_VehicleBanRequest' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_VehicleBanRequest
UNION ALL
SELECT
  'MIR_MST_DispositionCodes' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.MIR_MST_DispositionCodes
UNION ALL
SELECT
  'TollPlus_OperationalLocations' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_OperationalLocations
UNION ALL
SELECT
  'TER_PaymentPlanViolator' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_PaymentPlanViolator
UNION ALL
SELECT
  'TER_ViolatorCollectionsAgencyTracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_ViolatorCollectionsAgencyTracker
UNION ALL
SELECT
  'TollPlus_BalanceTransferQueue' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_BalanceTransferQueue
UNION ALL
SELECT
  'Notifications_CustNotifQueueTracker' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Notifications_CustNotifQueueTracker
UNION ALL
SELECT
  'TollPlus_CustomerFlagReferenceLookup' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TollPlus_CustomerFlagReferenceLookup
UNION ALL
SELECT
  'TER_ViolatorCollectionsOutboundUpdate' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_ViolatorCollectionsOutboundUpdate
UNION ALL
SELECT
  'DocMgr_TP_Customer_OutboundCommunications' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.DocMgr_TP_Customer_OutboundCommunications
UNION ALL
SELECT
  'TER_CollectionsOutboundUpdatePaymentPlan' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_CollectionsOutboundUpdatePaymentPlan
UNION ALL
SELECT
  'Notifications_CustomerNotificationQueue' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Notifications_CustomerNotificationQueue
UNION ALL
SELECT
  'Notifications_ConfigAlertTypeAlertChannels' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Notifications_ConfigAlertTypeAlertChannels
UNION ALL
SELECT
  'TER_ViolatorCollectionsOutboundStatus' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.TER_ViolatorCollectionsOutboundStatus
UNION ALL
SELECT
  'EIP_Image_Storage_Paths' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.EIP_Image_Storage_Paths
UNION ALL
SELECT
  'EIP_Results_Log' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.EIP_Results_Log
UNION ALL
SELECT
  'Finance_Gl_Txn_LineItems' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_Gl_Txn_LineItems
UNION ALL
SELECT
  'Finance_Gl_Transactions' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_Gl_Transactions
UNION ALL
SELECT
  'Finance_GlDailySummaryByCoaIDBuID' table_name,
  DATETIME_SUB(MAX(src_changedate), INTERVAL 1 hour ) src_changedate_to
FROM
  LND_TBOS.Finance_GlDailySummaryByCoaIDBuID


/*Updates batch_end_date fro m table created in above script*/
UPDATE LND_TBOS_SUPPORT.CDC_Batch_Load

set batch_end_date = ed.src_changedate_to

from LND_TBOS_SUPPORT.cdc_batch_end_date

where CDC_Batch_Load.table_name = ed.table_name

and cdc_runid = <sutable cdc_runid based on analysis>