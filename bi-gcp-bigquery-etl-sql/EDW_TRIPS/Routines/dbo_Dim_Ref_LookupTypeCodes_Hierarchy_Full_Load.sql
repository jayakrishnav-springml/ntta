CREATE OR REPLACE PROCEDURE EDW_TRIPS.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load all Lookup Dim Tables coming from Ref_LookupTypeCodes_Hierarchy table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Ranjith, Shankar		2020-08-28	New!
CHG0038319	Shankar					2021-02-24	Added Dim_VehicleStatus and Dim_ContractualType
CHG0040056  Shankar					2021-11-30	Added Dim_AutoReplenishment (Cash or CC backed TollTag Account?)\
CHG0040131	Gouthami				2021-12-16	Added a new Invoice Status(Dismissed Vtolled) to Dim_InvoiceStatus table.
CHG0042443	Gouthami				2023-02-09	Added a new Invoice Status(Dismissed Unassigned) to Dim_InvoiceStatus table.
            Gouthami        2024-09-11  Added a new dimension table Dim_PmCaseStatus for Refund project
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load

EXEC Utility.FromLog 'dbo.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load', 1

SELECT 'Stage.Ref_LookupTypeCodes_Hierarchy' TableName, * FROM Stage.Ref_LookupTypeCodes_Hierarchy ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');-- Testing
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
      
		--=============================================================================================================
		-- Load Stage.Ref_LookupTypeCodes_Hierarchy
		-- =============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS_STAGE.Ref_LookupTypeCodes_Hierarchy;
      CREATE OR replace TABLE EDW_TRIPS_STAGE.Ref_LookupTypeCodes_Hierarchy
        CLUSTER BY lookuptypecodeid
        AS
          SELECT
              coalesce(l4.lookuptypecodeid, l3.lookuptypecodeid, l2.lookuptypecodeid) AS lookuptypecodeid,
              l1.lookuptypecodeid AS l1_lookuptypecodeid,
              CAST(l1.lookuptypecode as STRING) AS l1_lookuptypecode,
              CAST(l1.lookuptypecodedesc as STRING) AS l1_lookuptypecodedesc,
              l2.lookuptypecodeid AS l2_lookuptypecodeid,
              CAST(l2.lookuptypecode as STRING) AS l2_lookuptypecode,
              CAST(l2.lookuptypecodedesc as STRING) AS l2_lookuptypecodedesc,
              l3.lookuptypecodeid AS l3_lookuptypecodeid,
              CAST(l3.lookuptypecode as STRING) AS l3_lookuptypecode,
              CAST(l3.lookuptypecodedesc as STRING) AS l3_lookuptypecodedesc,
              l4.lookuptypecodeid AS l4_lookuptypecodeid,
              CAST(l4.lookuptypecode as STRING) AS l4_lookuptypecode,
              CAST(l4.lookuptypecodedesc as STRING) AS l4_lookuptypecodedesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy AS l1
              INNER JOIN LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy AS l2 ON l1.lookuptypecodeid = l2.parent_lookuptypecodeid
               AND l1.parent_lookuptypecodeid = 0
              LEFT OUTER JOIN LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy AS l3 ON l2.lookuptypecodeid = l3.parent_lookuptypecodeid
              LEFT OUTER JOIN LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy AS l4 ON l3.lookuptypecodeid = l4.parent_lookuptypecodeid
      ;
      SET log_message = 'EDW_TRIPS_STAGE.Ref_LookupTypeCodes_Hierarchy';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

      
      
		--=============================================================================================================
		-- Load dbo.Dim_CollectionStatus
		--=============================================================================================================
	
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_CollectionStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_CollectionStatus
        CLUSTER BY collectionstatusid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS collectionstatusid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS collectionstatuscode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS collectionstatusdesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy 
            WHERE TollPlus_ref_lookuptypecodes_hierarchy.parent_lookuptypecodeid = 3647 -- CollectionStatus
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_CollectionStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);


      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_CollectionStatus', 'EDW_TRIPS.Dim_CollectionStatus');
      
		--=============================================================================================================
		-- Load dbo.Dim_AccountType
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_AccountType;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_AccountType
        CLUSTER BY accounttypeid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS accounttypeid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS accounttypecode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS accounttypedesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_ref_lookuptypecodes_hierarchy.parent_lookuptypecodeid = 1 -- User_Types
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_AccountType';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
    -- Table swap!
    --TableSwap is Not Required, using  Create or Replace Table
    --CALL utility.tableswap('EDW_TRIPS.Dim_AccountType', 'EDW_TRIPS.Dim_AccountType');
      
		--=============================================================================================================
		-- Load dbo.Dim_AccountStatus
		--=============================================================================================================
	
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_AccountStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_AccountStatus
        CLUSTER BY accountstatusid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS accountstatusid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS accountstatuscode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS accountstatusdesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_ref_lookuptypecodes_hierarchy.parent_lookuptypecodeid = 15 -- AccountStatus
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_AccountStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_AccountStatus', 'EDW_TRIPS.Dim_AccountStatus');
      
		--=============================================================================================================
		-- Load dbo.Dim_CustomerStatus
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_CustomerStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_CustomerStatus
        CLUSTER BY customerstatusid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS customerstatusid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS customerstatuscode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS customerstatusdesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.parent_lookuptypecodeid = 12 -- CustomerStatus
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_CustomerStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_CustomerStatus', 'EDW_TRIPS.Dim_CustomerStatus');
      
		--=============================================================================================================
		-- Load dbo.Dim_AutoReplenishment
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_AutoReplenishment;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_AutoReplenishment
        CLUSTER BY autoreplenishmentid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS autoreplenishmentid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS autoreplenishmentcode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS autoreplenishmentdesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.parent_lookuptypecodeid = 77 -- AutoReplenishment
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_AutoReplenishment';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_AutoReplenishment', 'EDW_TRIPS.Dim_AutoReplenishment');
      
		--=============================================================================================================
		-- Load dbo.Dim_VehicleStatus
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_VehicleStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_VehicleStatus
        CLUSTER by vehiclestatusid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS vehiclestatusid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS vehiclestatuscode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS vehiclestatusdesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.parent_lookuptypecodeid = 204 -- VehicleStatus
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_VehicleStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_VehicleStatus', 'EDW_TRIPS.Dim_VehicleStatus');
      
		--=============================================================================================================
		-- Load dbo.Dim_InvoiceStatus
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_InvoiceStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_InvoiceStatus
        CLUSTER by invoicestatusid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS invoicestatusid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS invoicestatuscode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS invoicestatusdesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.parent_lookuptypecodeid = 508 -- InvoiceStatus
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
          UNION ALL
          SELECT
              99999,
              'Vtolled',
              'DismissedVtolled',
              current_datetime()
          UNION ALL
          SELECT
              99998,
              'Unassigned',
              'DismissedUnassigned',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_InvoiceStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_InvoiceStatus', 'EDW_TRIPS.Dim_InvoiceStatus');
      
		--=============================================================================================================
		-- Load dbo.Dim_PaymentChannel
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_PaymentChannel;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_PaymentChannel
        CLUSTER by paymentchannelid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS paymentchannelid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS paymentchannelcode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS paymentchanneldesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.parent_lookuptypecodeid = 94 -- PaymentChannel
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_PaymentChannel';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_PaymentChannel', 'EDW_TRIPS.Dim_PaymentChannel');
      
		--=============================================================================================================
		-- Load dbo.Dim_PaymentStatus
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_PaymentStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_PaymentStatus
        CLUSTER by paymentstatusid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS paymentstatusid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS paymentstatuscode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS paymentstatusdesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy 
            WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.parent_lookuptypecodeid = 107 -- PaymentStatus
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_PaymentStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_PaymentStatus', 'EDW_TRIPS.Dim_PaymentStatus');
      --=============================================================================================================
		-- Load dbo.Dim_AdjApprovalStatus
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_AdjApprovalStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_AdjApprovalStatus
        cluster by adjapprovalstatusid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS adjapprovalstatusid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS adjapprovalstatuscode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS adjapprovalstatusdesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_ref_lookuptypecodes_hierarchy.parent_lookuptypecodeid = 465 -- AdjApproval_Status
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_AdjApprovalStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_AdjApprovalStatus', 'EDW_TRIPS.Dim_AdjApprovalStatus');
      
		--=============================================================================================================
		-- Load dbo.Dim_TransactionTypeCategory
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_TransactionTypeCategory;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_TransactionTypeCategory
        cluster by transactiontypecategoryid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS transactiontypecategoryid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS transactiontypecategorycode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS transactiontypecategorydesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.parent_lookuptypecodeid = 153 -- TxnType_Categories
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_TransactionTypeCategory';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_TransactionTypeCategory', 'EDW_TRIPS.Dim_TransactionTypeCategory');
      	
		--=============================================================================================================
		-- Load dbo.Dim_TripPaymentStatus
		--=============================================================================================================
	
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_TripPaymentStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_TripPaymentStatus
        cluster by trippaymentstatusid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS trippaymentstatusid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS trippaymentstatuscode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS trippaymentstatusdesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.parent_lookuptypecodeid = 455 -- TripPaymentStatus
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_TripPaymentStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_TripPaymentStatus', 'EDW_TRIPS.Dim_TripPaymentStatus');
      
		--**************** Russian Dolls Hierarchy Dim Modeling for PaymentMode and PaymentModeGroup ******************
		--=============================================================================================================
		-- Load dbo.Dim_PaymentModeGroup
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_PaymentModeGroup;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_PaymentModeGroup
        cluster by paymentmodegroupid
        AS
          SELECT DISTINCT
              ref_lookuptypecodes_hierarchy.l2_lookuptypecodeid AS paymentmodegroupid,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecode AS paymentmodegroupcode,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecodedesc AS paymentmodegroupdesc,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.ref_lookuptypecodes_hierarchy
            WHERE ref_lookuptypecodes_hierarchy.l1_lookuptypecodeid = 125 -- AllPMTModes
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_PaymentModeGroup';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_PaymentModeGroup', 'EDW_TRIPS.Dim_PaymentModeGroup');
      
		--=============================================================================================================
		-- Load dbo.Dim_PaymentMode
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_PaymentMode;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_PaymentMode
        cluster by paymentmodeid
        AS
          SELECT
              ref_lookuptypecodes_hierarchy.l3_lookuptypecodeid AS paymentmodeid,
              ref_lookuptypecodes_hierarchy.l3_lookuptypecode AS paymentmodecode,
              ref_lookuptypecodes_hierarchy.l3_lookuptypecodedesc AS paymentmodedesc,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecodeid AS paymentmodegroupid,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecode AS paymentmodegroupcode,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecodedesc AS paymentmodegroupdesc,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.Ref_LookupTypeCodes_Hierarchy
            WHERE Ref_LookupTypeCodes_Hierarchy.l1_lookuptypecodeid = 125 --  AllPMTModes
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_PaymentMode';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_PaymentMode', 'EDW_TRIPS.Dim_PaymentMode');
      
		--**************** Russian Dolls Hierarchy Dim Modeling for RevenueType and RevenueCategory ******************
		--=============================================================================================================
		-- Load dbo.Dim_RevenueCategory
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_RevenueCategory;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_RevenueCategory
        cluster by revenuecategoryid
        AS
          SELECT DISTINCT
              ref_lookuptypecodes_hierarchy.l2_lookuptypecodeid AS revenuecategoryid,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecode AS revenuecategorycode,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecodedesc AS revenuecategorydesc,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.Ref_LookupTypeCodes_Hierarchy
            WHERE Ref_LookupTypeCodes_Hierarchy.l1_lookuptypecodeid = 74 -- RevenueCategory
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_RevenueCategory';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_RevenueCategory', 'EDW_TRIPS.Dim_RevenueCategory');
      
		--=============================================================================================================
		-- Load dbo.Dim_RevenueType
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_RevenueType;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_RevenueType
        cluster by revenuetypeid
        AS
          SELECT
              coalesce(ref_lookuptypecodes_hierarchy.l3_lookuptypecodeid, ref_lookuptypecodes_hierarchy.l2_lookuptypecodeid) AS revenuetypeid,
              coalesce(replace(replace(ref_lookuptypecodes_hierarchy.l3_lookuptypecode, 'FirstResponder', 'FirstResponder'), 'Employee', 'Employee'), ref_lookuptypecodes_hierarchy.l2_lookuptypecode) AS revenuetypecode,
              coalesce(ref_lookuptypecodes_hierarchy.l3_lookuptypecodedesc, ref_lookuptypecodes_hierarchy.l2_lookuptypecodedesc) AS revenuetypedesc,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecodeid AS revenuecategoryid,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecode AS revenuecategorycode,
              ref_lookuptypecodes_hierarchy.l2_lookuptypecodedesc AS revenuecategorydesc,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.Ref_LookupTypeCodes_Hierarchy
            WHERE Ref_LookupTypeCodes_Hierarchy.l1_lookuptypecodeid = 74 -- RevenueCategory
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_RevenueType';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);


      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_RevenueType', 'EDW_TRIPS.Dim_RevenueType');
      
		--=============================================================================================================
		-- Load dbo.Dim_VehicleStatus
		--=============================================================================================================
	
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_VehicleStatus;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_VehicleStatus
        cluster by vehiclestatusid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS vehiclestatusid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS vehiclestatuscode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS vehiclestatusdesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.parent_lookuptypecodeid = 204 -- VehicleStatus
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_VehicleStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);


      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_VehicleStatus', 'EDW_TRIPS.Dim_VehicleStatus');
      
		--=============================================================================================================
		-- Load dbo.Dim_ContractualType
		--=============================================================================================================
	
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_ContractualType;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_ContractualType
       cluster by contractualtypeid
        AS
          SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS contractualtypeid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS contractualtypecode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS contractualtypedesc,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
            WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.parent_lookuptypecodeid = 2817 -- VEHICLECONTRACTUALTYPE
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_ContractualType';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
    

   --=============================================================================================================
		-- Load dbo.Dim_PmCaseStatus
		--=============================================================================================================


      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_PmCaseStatus
        CLUSTER BY customerstatusid
        AS
        SELECT DISTINCT
              TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodeid AS customerstatusid,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecode as STRING) AS customerstatuscode,
              CAST(TollPlus_ref_lookuptypecodes_hierarchy.lookuptypecodedesc as STRING) AS customerstatusdesc,
              current_datetime() AS edw_updatedate
          FROM
              LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy
          WHERE TollPlus_Ref_LookupTypeCodes_Hierarchy.lookuptypecodeid in (3230,4293,3233,3232,3234,3231)
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_PmCaseStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL); 


      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL utility.tableswap('EDW_TRIPS.Dim_ContractualType', 'EDW_TRIPS.Dim_ContractualType');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.Ref_LookupTypeCodes_Hierarchy' AS tablename,
            *
          FROM
            EDW_TRIPS_STAGE.Ref_LookupTypeCodes_Hierarchy
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_CollectionStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_CollectionStatus
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_AccountStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_AccountStatus
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_CustomerStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_CustomerStatus
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_AutoReplenishment' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_AutoReplenishment
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_InvoiceStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_InvoiceStatus
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_PaymentChannel' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_PaymentChannel
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_PaymentStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_PaymentStatus
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_TransactionTypeCategory' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_TransactionTypeCategory
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_TripPaymentStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_TripPaymentStatus
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_AccountType' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Accounttype
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_PaymentModeGroup' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_PaymentModeGroup
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_PaymentMode' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_PaymentMode
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_RevenueCategory' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_RevenueCategory
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_RevenueType' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Revenuetype
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_VehicleStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_VehicleStatus
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_ContractualType' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Contractualtype
        ORDER BY
          2
        LIMIT 100;
        SELECT
            'EDW_TRIPS.Dim_PmCaseStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_PmCaseStatus
        ORDER BY
          2
        LIMIT 100;        
      END IF;


     
    EXCEPTION WHEN ERROR THEN
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
EXEC dbo.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load
EXEC Utility.FromLog 'dbo.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load', 1

DELETE Utility.ProcessLog WHERE LogSource LIKE '%Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load%'

SELECT * FROM Stage.Ref_LookupTypeCodes_Hierarchy WHERE L1_LookupTypeCodeID = 1
SELECT * FROM Stage.Ref_LookupTypeCodes_Hierarchy WHERE L1_LookupTypeCodeDESC LIKE '%TXN%TYPE%'

SELECT 'Stage.Ref_LookupTypeCodes_Hierarchy' TableName, * FROM Stage.Ref_LookupTypeCodes_Hierarchy WHERE L1_LookupTypeCodeID IN (1, 3548) ORDER BY 3

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

SELECT	C.Parent_LookupTypeCodeID,
		P.LookupTypeCode AS Lookup_Dim,
		COUNT(1) Row_Count,
		MIN(LEN(C.LookupTypeCode)) AS LookupTypeCode_MinLen, MAX(LEN(C.LookupTypeCode)) AS LookupTypeCode_MaxLen, 
		MIN(LEN(C.LookupTypeCodeDesc)) AS LookupTypeCodeDesc_MinLen, MAX(LEN(C.LookupTypeCodeDesc)) AS LookupTypeCodeDesc_MaxLen
FROM	LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy C
		JOIN (SELECT DISTINCT LookupTypeCodeID, LookupTypeCode FROM LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy) P 
		ON C.Parent_LookupTypeCodeID = P.LookupTypeCodeID
WHERE  Parent_LookupTypeCodeID IN (
		1 		-- User_Types
		,15 	-- AccountStatus
		,12 	-- CustomerStatus
		,94 	-- PaymentChannel
		,107	-- PaymentStatus
		,153 	-- TxnType
		,204 	-- VehicleStatus
		,455 	-- TripPaymentStatus
		,465	-- AdjApproval_Status
		,508	-- InvoiceStatus
		,3647	-- CollectionStatus
)
GROUP BY C.Parent_LookupTypeCodeID, P.LookupTypeCode
ORDER BY 1
*/




  END;