INSERT INTO LND_TBOS_SUPPORT.CDC_Full_Load_Config(table_id,source_table_name,source_dataset_name,stage_table_name,stage_cdc_dataset_name,stage_full_dataset_name,target_table_name,target_dataset_name,key_column,target_table_columns_list,cdc_run_flag,fullload_run_flag,cdc_batch_name,batch_window,clustering_columns,stage_insert_values_list,level2_comparison_flag) VALUES (263,'TOLLPLUS_BalanceTransferQueue__ct','LND_TBOS_Qlik','TollPlus_BalanceTransferQueue','LND_TBOS_STAGE_CDC','LND_TBOS_STAGE_FULL','TollPlus_BalanceTransferQueue','LND_TBOS','balancetransferqueueid','balancetransferqueueid,fromcustomerid,tocustomerid,transferamount,reason,requesteddate,transferstatus,transferdate,createdate,createduser,updateddate,updateduser,fromadjustmentid,toadjustmentid,lnd_updatedate,lnd_updatetype,src_changedate','N','N','TRIPS',3,'balancetransferqueueid',NULL,'Y');

INSERT INTO LND_TBOS_SUPPORT.CDC_Full_Load_Config(table_id,source_table_name,source_dataset_name,stage_table_name,stage_cdc_dataset_name,stage_full_dataset_name,target_table_name,target_dataset_name,key_column,target_table_columns_list,cdc_run_flag,fullload_run_flag,cdc_batch_name,batch_window,clustering_columns,stage_insert_values_list,level2_comparison_flag) VALUES (264,'TOLLPLUS_OverPaymentsLog__ct','LND_TBOS_Qlik','TollPlus_OverPaymentsLog','LND_TBOS_STAGE_CDC','LND_TBOS_STAGE_FULL','TollPlus_OverPaymentsLog','LND_TBOS','overpaymentlogid','overpaymentlogid,customerid,paymentid,adjustmentid,amountreceived,linkid,linksource,reasoncode,createddate,createduser,updateddate,updateduser,overpaymentid,tripadjustmentid,lnd_updatedate,lnd_updatetype,src_changedate','N','N','TRIPS',3,'overpaymentlogid',NULL,'Y');

INSERT INTO LND_TBOS_SUPPORT.CDC_Full_Load_Config(table_id,source_table_name,source_dataset_name,stage_table_name,stage_cdc_dataset_name,stage_full_dataset_name,target_table_name,target_dataset_name,key_column,target_table_columns_list,cdc_run_flag,fullload_run_flag,cdc_batch_name,batch_window,clustering_columns,stage_insert_values_list,level2_comparison_flag) VALUES (265,'DOCMGR_TP_CUSTOMER_OUTBOUNDCOMMUNICATIONS__ct','LND_TBOS_Qlik','DocMgr_TP_Customer_OutboundCommunications','LND_TBOS_STAGE_CDC','LND_TBOS_STAGE_FULL','DocMgr_TP_Customer_OutboundCommunications','LND_TBOS','outboundcommunicationid','outboundcommunicationid,customerid,documenttype,communicationdate,generateddate,description,documentpath,initiatedby,queueid,isdelivered,paymentid,deliverydate,readdate,generatedby,filepathconfigurationid,createddate,createduser,updateddate,updateduser,lnd_updatedate,lnd_updatetype,src_changedate','N','N','TRIPS',3,'outboundcommunicationid',NULL,'Y');

INSERT INTO
  LND_TBOS_SUPPORT.CDC_Full_Load_Config(table_id,
    source_table_name,
    source_dataset_name,
    stage_table_name,
    stage_cdc_dataset_name,
    stage_full_dataset_name,
    target_table_name,
    target_dataset_name,
    key_column,
    target_table_columns_list,
    cdc_run_flag,
    fullload_run_flag,
    cdc_batch_name,
    batch_window,
    clustering_columns,
    stage_insert_values_list,
    level2_comparison_flag)
VALUES
  (266,'CaseManager_PmCase__ct','LND_TBOS_Qlik','CaseManager_PmCase','LND_TBOS_STAGE_CDC','LND_TBOS_STAGE_FULL','CaseManager_PmCase','LND_TBOS','caseid','caseid,casetypeid,casesource,casetitle,datereported,icnid,priorityid,statusid,currentcasetypeactivityid,assignedto,jsondata,customerid,duedate,slaexpirydate,remarks,createduser,createddate,updateduser,updateddate,currentactivitystatusid,rolecasetypeactcusttypestatusid,closurereasoncode,channelid,ismanual,caseapprovalnotification,casetypecomment,lnd_updatedate,lnd_updatetype,src_changedate','N','N','TRIPS',3,'caseid',NULL,'Y');