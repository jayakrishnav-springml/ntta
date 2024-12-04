/*
SELECT
  STRING_AGG( "SELECT "||"'"||target_table_name ||"' table_name, COUNT(1) archive_flag_row_count  FROM LND_TBOS."|| target_table_name || " WHERE lnd_updatetype ='A'", " UNION ALL "
              ORDER BY target_table_name) SQL_string
FROM `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
where target_table_name not in 
(  
  SELECT REPLACE(table_id,'_IDS','') table_id
  FROM LND_TBOS_ARCHIVE_IDS.__TABLES__
  WHERE table_id NOT IN ("BI_Archive_Reversal_IDS")
)
*/

select table_name, archive_flag_row_count
from ARCHIVE_IDS_VALIDATION.A_Flags_Not_IDS_Tables
where archive_flag_row_count <> 0 order by 1;

-- There is no data to display. 
 
 
CREATE OR REPLACE TABLE
  `ARCHIVE_IDS_VALIDATION.A_Flags_Not_IDS_Tables` AS -- change the table name. before and after.
SELECT
  'CaseManager_PmCase' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.CaseManager_PmCase
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'CaseManager_PmCaseTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.CaseManager_PmCaseTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Court_AdminHearing' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Court_AdminHearing
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Court_Counties' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Court_Counties
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Court_Courtjudges' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Court_Courtjudges
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Court_Courts' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Court_Courts
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Court_PlazaCourts' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Court_PlazaCourts
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'EIP_AuditTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.EIP_AuditTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'EIP_Image_Storage_Paths' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.EIP_Image_Storage_Paths
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'EIP_Results_Log' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.EIP_Results_Log
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'EIP_Transactions' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.EIP_Transactions
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'EIP_VehicleImages' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.EIP_VehicleImages
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Finance_BusinessProcess_TxnTypes_Associations' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Finance_BusinessProcess_TxnTypes_Associations
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Finance_BusinessProcesses' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Finance_BusinessProcesses
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Finance_ChartOfAccounts' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Finance_ChartOfAccounts
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Finance_GlDailySummaryByCoaIDBuID' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Finance_GlDailySummaryByCoaIDBuID
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Finance_RefundRequests_Queue' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Finance_RefundRequests_Queue
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Finance_RefundResponseDetails' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Finance_RefundResponseDetails
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Finance_TollAdjustments' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Finance_TollAdjustments
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Finance_TxnTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Finance_TxnTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Inventory_ItemTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Inventory_ItemTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'MIR_MST_DispositionCodes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.MIR_MST_DispositionCodes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'MIR_MST_ResponseTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.MIR_MST_ResponseTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'MIR_MST_SourceTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.MIR_MST_SourceTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'MIR_MST_TransactionTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.MIR_MST_TransactionTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'MIR_ReasonCodes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.MIR_ReasonCodes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'MIR_TxnQueues' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.MIR_TxnQueues
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'MIR_TxnStages' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.MIR_TxnStages
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'MIR_TxnStageTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.MIR_TxnStageTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'MIR_TxnStatuses' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.MIR_TxnStatuses
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Notifications_AlertChannels' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Notifications_AlertChannels
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Notifications_AlertTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Notifications_AlertTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Notifications_ConfigAlertTypeAlertChannels' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Notifications_ConfigAlertTypeAlertChannels
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Rbac_LocationRoles' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Rbac_LocationRoles
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_BanActions' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_BanActions
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_CitationNumberSequence' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_CitationNumberSequence
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_CollectionAgencies' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_CollectionAgencies
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_CollectionsOutboundUpdatePaymentPlan' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_CollectionsOutboundUpdatePaymentPlan
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_DPSBanActions' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_DPSBanActions
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_DPSTrooper' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_DPSTrooper
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_HVStatusLookup' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_HVStatusLookup
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_PaymentPlans' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_PaymentPlans
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_PaymentPlanTerms' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_PaymentPlanTerms
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_PaymentPlanViolator' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_PaymentPlanViolator
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_VehicleBan' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_VehicleBan
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_VehicleBanRequest' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_VehicleBanRequest
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_VRBAgencyLookup' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_VRBAgencyLookup
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_VRBRejectLookup' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_VRBRejectLookup
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_VRBRequestDallas' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_VRBRequestDallas
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TER_VRBRequestDMV' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TER_VRBRequestDMV
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_AddressSources' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_AddressSources
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Agencies' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Agencies
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_AppTxnTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_AppTxnTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_BalanceTransferQueue' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_BalanceTransferQueue
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_BankruptcyStatuses' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_BankruptcyStatuses
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_BankruptcyTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_BankruptcyTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'Tollplus_CaseLinks' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.Tollplus_CaseLinks
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Channels' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Channels
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_CustomerFlagReferenceLookup' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_CustomerFlagReferenceLookup
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_DMVExceptionQueue' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_DMVExceptionQueue
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_FleetCustomerAttributes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_FleetCustomerAttributes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_ICN' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_ICN
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_IOPTagAgencyMapping' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_IOPTagAgencyMapping
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_LaneCategories' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_LaneCategories
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Lanes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Lanes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_LocationChannels' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_LocationChannels
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Locations' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Locations
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_MbsProcessStatus' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_MbsProcessStatus
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_OperationalLocations' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_OperationalLocations
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Plans' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Plans
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_PlateTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_PlateTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Plaza_Types' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Plaza_Types
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Plazas' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Plazas
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Ref_FeeTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Ref_FeeTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Ref_Invoice_Workflow_Stage_Fees' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Ref_Invoice_Workflow_Stage_Fees
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Ref_Invoice_Workflow_Stages' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Ref_Invoice_Workflow_Stages
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Ref_LookupTypeCodes_Hierarchy' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_SubSystems' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_SubSystems
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TexasCounties' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TexasCounties
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TollScheduleDtl' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TollScheduleDtl
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TollScheduleHdr' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TollScheduleHdr
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TP_AppLication_Parameters' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TP_AppLication_Parameters
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TP_Bankruptcy_Filing' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TP_Bankruptcy_Filing
WHERE
  lnd_updatetype ='A'
--UNION ALL
--SELECT
--  'TollPlus_TP_Customer_Transponder_Request_Detail' table_name,
--  COUNT(1) archive_flag_row_count
--FROM
--  LND_TBOS.TollPlus_TP_Customer_Transponder_Request_Detail
--WHERE
--  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TP_TollRate_Dtls' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TP_TollRate_Dtls
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TP_TollRate_Hdr' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TP_TollRate_Hdr
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TP_TollTxn_ReasonCodes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TP_TollTxn_ReasonCodes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TP_Transaction_Types' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TP_Transaction_Types
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TP_Vehicle_Models' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TP_Vehicle_Models
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TpFileTracker' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TpFileTracker
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TripStages' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TripStages
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TripStatuses' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TripStatuses
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_TxnType_Categories' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_TxnType_Categories
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_VehicleClasses' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_VehicleClasses
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_Violation_Workflow' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_Violation_Workflow
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_ViolationVehicleTransferCustomers' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_ViolationVehicleTransferCustomers
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TollPlus_ZipCodes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TollPlus_ZipCodes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TranProcessing_RecordTypes' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TranProcessing_RecordTypes
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TranProcessing_TripSource' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TranProcessing_TripSource
WHERE
  lnd_updatetype ='A'
UNION ALL
SELECT
  'TranProcessing_TxnDispositions' table_name,
  COUNT(1) archive_flag_row_count
FROM
  LND_TBOS.TranProcessing_TxnDispositions
WHERE
  lnd_updatetype ='A'
