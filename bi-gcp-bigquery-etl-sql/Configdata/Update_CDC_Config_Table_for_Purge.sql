UPDATE LND_TBOS_SUPPORT.CDC_Full_Load_Config SET ct_data_retention_days=30 WHERE true;

UPDATE LND_TBOS_SUPPORT.CDC_Full_Load_Config SET purge_run_flag='N' WHERE true;
