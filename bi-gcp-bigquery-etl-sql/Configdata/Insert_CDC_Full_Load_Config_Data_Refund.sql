/*  Use this once this SP moves to production
DECLARE input_tables STRING DEFAULT NULL;
DECLARE key_columns STRING DEFAULT NULL;
CALL LND_TBOS_SUPPORT.CDC_Config_Data_Generator('Tollplus_Caselinks,Finance_RefundResponseDetails','caselinkid,refundresponseid'); 
*/



INSERT INTO LND_TBOS_SUPPORT.CDC_Full_Load_Config(table_id,source_dataset_name,source_table_name,stage_cdc_dataset_name,stage_full_dataset_name,stage_table_name,target_dataset_name,target_table_name,key_column,target_table_columns_list,cdc_run_flag,full_or_partial_load_flag,cdc_batch_name,batch_window,clustering_columns,stage_insert_values_list,level2_comparison_flag,ct_data_retention_days,purge_run_flag,overlap_window_in_secs)
VALUES (267,"LND_TBOS_Qlik","TOLLPLUS_CaseLinks__ct","LND_TBOS_STAGE_CDC","LND_TBOS_STAGE_FULL","Tollplus_CaseLinks","LND_TBOS","Tollplus_CaseLinks","caselinkid","caselinkid,caseid,linkid,linksource,casestatus,remarks,linkstatus,imagereviewstatus,createduser,createddate,updateduser,updateddate,lnd_updatedate,lnd_updatetype,src_changedate","Y","N","TRIPS",3,"caselinkid","caselinkid,caseid,linkid,rtrim(linksource),casestatus,rtrim(remarks),rtrim(linkstatus),rtrim(imagereviewstatus),rtrim(createduser),createddate,rtrim(updateduser),updateddate,lnd_updatedate,RTRIM(LND_UpdateType),src_changedate","Y",30,"N",60);

INSERT INTO LND_TBOS_SUPPORT.CDC_Full_Load_Config(table_id,source_dataset_name,source_table_name,stage_cdc_dataset_name,stage_full_dataset_name,stage_table_name,target_dataset_name,target_table_name,key_column,target_table_columns_list,cdc_run_flag,full_or_partial_load_flag,cdc_batch_name,batch_window,clustering_columns,stage_insert_values_list,level2_comparison_flag,ct_data_retention_days,purge_run_flag,overlap_window_in_secs)
VALUES (268,"LND_TBOS_Qlik","FINANCE_RefundResponseDetails__ct","LND_TBOS_STAGE_CDC","LND_TBOS_STAGE_FULL","Finance_RefundResponseDetails","LND_TBOS","Finance_RefundResponseDetails","refundresponseId","RefundResponseId,CustomerId,DisbursementId,RefundAmount,CheckNumber,RefundRequestedDate,DisbursementDesc ,RefundIssuedDate,ErrorMessage,IsValid,Status,FileId,CreatedDate,CreatedUser ,UpdatedDate,UpdatedUser,PaymentId,lnd_updatedate,lnd_updatetype,src_changedate","Y","N","TRIPS",3,"refundresponseId","refundresponseid,customerid,disbursementid,refundamount,rtrim(checknumber),refundrequesteddate,rtrim(disbursementdesc),refundissueddate,rtrim(errormessage),isvalid,rtrim(status),fileid,createddate,rtrim(createduser),updateddate,rtrim(updateduser),paymentid,lnd_updatedate,RTRIM(LND_UpdateType),src_changedate","Y",30,"N",60);




