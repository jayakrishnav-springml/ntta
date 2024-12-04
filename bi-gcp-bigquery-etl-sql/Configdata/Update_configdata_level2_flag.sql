UPDATE
  LND_TBOS_SUPPORT.CDC_Full_load_config
SET
  level2_comparison_flag = 'Y'
WHERE
  TRUE;


UPDATE
  LND_TBOS_SUPPORT.CDC_Full_load_config
SET
  level2_comparison_flag = 'N'
WHERE
  target_table_name='TollPlus_TP_Trips';  
