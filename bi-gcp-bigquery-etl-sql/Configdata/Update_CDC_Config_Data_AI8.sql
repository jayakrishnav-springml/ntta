ALTER TABLE `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
RENAME COLUMN fullload_run_flag TO full_or_partial_load_flag;

UPDATE `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
SET full_or_partial_load_flag='N'
WHERE 1=1