-- This is a hot fix to correct the CDC merge key column to match with source table PK column to ensure CDC merge happens correctly and does not lose change rows otherwise.
UPDATE `LND_TBOS_SUPPORT.CDC_Full_Load_Config` 
SET key_column = 'HistID'
WHERE target_table_name = 'History_TP_Customer_Addresses';

UPDATE `LND_TBOS_SUPPORT.CDC_Full_Load_Config` 
SET key_column = 'ContactID'
WHERE target_table_name = 'TollPlus_TP_Customer_Contacts';