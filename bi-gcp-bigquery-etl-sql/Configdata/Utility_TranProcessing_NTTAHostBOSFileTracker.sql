## Merge query to merge JSON message from TBOS.

MERGE `LND_TBOS.TranProcessing_NTTAHostBOSFileTracker` AS t2
USING `LND_TBOS_SUPPORT.TranProcessing_NTTAHostBOSFileTracker` AS t1
ON t2.id = t1.id
WHEN MATCHED THEN
  UPDATE SET t2.recordmessage = t1.recordmessage;