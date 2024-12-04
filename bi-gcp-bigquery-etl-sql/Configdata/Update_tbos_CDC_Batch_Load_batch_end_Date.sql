UPDATE
  `LND_TBOS_SUPPORT.CDC_Batch_Load`
SET
  cdc_merge_status='I'
WHERE
  cdc_merge_status='C'
  AND batch_end_date IS NULL;