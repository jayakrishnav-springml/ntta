/* 05/17/2024 Updating clustering_columns in CDC_Full_Load_Config for On_demand fullload*/
UPDATE LND_TBOS_SUPPORT.CDC_Full_Load_Config  T
  SET clustering_columns =(SELECT
  string_agg(column_name, ",")
FROM
  `LND_TBOS.INFORMATION_SCHEMA.COLUMNS` S
WHERE
  S.clustering_ordinal_position >0
  AND S. table_name=T.target_table_name GROUP BY table_name )
  WHERE 1=1  ;

/* 05/20/2024 Updating target_table_columns_list for table IOP_BOS_IOP_OutboundTransactions in CDC_Full_Load_Config for CDC*/
UPDATE
  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
SET
  target_table_columns_list="bosioptransactionid,iopid,transactiontypeid,tagtype,transactiondate,agencyid,entryplaza,entrylane,tagstatus,licencenumber,licensestate,exitplaza,exitlane,transactionstatus,reconcilitionfileid,tollamount,acceptedamount,iscorrected,discountamount,tptripid,tagserialnumber,vehicleclass,tripmethod,posteddate,resubmitcount,tranfileid,facilitycode,plazacode,lanecode,entrytripdatetime,exittripdatetime,platetype,facilitydesc,entryplazadesc,exitplazadesc,licenseplatecountry,violationserialnumber,vestimestamp,tagagencyid,resubmitreasoncode,correctionreasoncode,transactionflatfee,transactionpercentfee,sourceofentry,correctioncount,sourcepkid,recordcode,accountagencyid,adjustmentdatetime,postingdisposition,postingdispositionreason,adjustmentresponsepayload,homeagencyrefid,spare1,spare2,spare3,spare4,spare5,othercorrectiondescription,createddate,createduser,updateddate,updateduser,lnd_updatedate,lnd_updatetype,src_changedate"
WHERE
  target_table_name='IOP_BOS_IOP_OutboundTransactions';  
  
/* 05/15/2024 Updating for CDC bug fix on CDC_Full_Load_Config */
UPDATE
  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
SET
  stage_table_name='TollPlus_Agencies'
WHERE
  stage_table_name='TOLLPLUS_TollPlus_Agencies';


UPDATE
  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
SET
  stage_table_name='History_TP_Customer_Attributes'
WHERE
  stage_table_name='History_History_TP_Customer_Attributes';


  UPDATE
  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
SET
  stage_table_name='History_TP_Customers'
WHERE
  stage_table_name='History_History_TP_Customers';  

UPDATE
  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
SET
  key_column='ZipCode'
WHERE
  stage_table_name='TollPlus_ZipCodes';  

UPDATE
  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
SET
  target_table_columns_list="tollschedulehdrid,entrylaneid,entryplazaid,exitplazaid,channelid,icnid,starteffectivedate,endeffectivedate,tollschedulehdrdesc,transactiontype,transactionmenthod,scheduletype,isactive,`interval`,createddate,createduser,updateddate,updateduser,lnd_updatedate,lnd_updatetype,src_changedate"
WHERE
  source_table_name='TOLLPLUS_TOLLSCHEDULEHDR__ct';

UPDATE
  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
SET
  source_table_name='FINANCE_BUSINESSPROCESSES__ct'
WHERE
  source_table_name='Finance_BusinessProcesses__ct';

UPDATE
  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
SET
  source_table_name='FINANCE_CHARTOFACCOUNTS__ct'
WHERE
  source_table_name='Finance_ChartOfAccounts__ct';