# Chargeback 
This Directory Contians all the Information about  Data Components required for Chargeback Import & Export Cloud Function 

## Deployment 
- 4 Existing tables DDL's are Updated to Update Column Name and Schema , Please Drop These Tables Manually anr ReDeploy the Latest DDL
    ``` sql
    DROP TABLE LND_TBOS_STAGE_FULL.dbo_ChargeBack_Tracking;
    DROP TABLE LND_TBOS.dbo_CB_Amex_BadData;
    DROP TABLE LND_TBOS.dbo_CB_Tracking_BadData
    DROP TABLE LND_TBOS.dbo_ChargeBack_Tracking;
    ```
- Deploy/Redeploy all the required Components with Changes
    * #### 2 Stroed procedures 
        * ChargeBackExport.sql          /ChargeBack/Routines/ChargeBackExport.sql
        * ChargeBack_StageToMain.sql     /ChargeBack/Routines/ChargeBack_StageToMain.sql
    * #### 5 Tables
        * dbo_CB_Received_BadData.sql       /ChargeBack/dbo_CB_Received_BadData.sql
        * dbo_CB_Amex_BadData.sql           /LND_TBOS/dbo_CB_Amex_BadData.sql
        * dbo_CB_Tracking_BadData.sql       /LND_TBOS/dbo_CB_Tracking_BadData.sql
        * dbo_ChargeBack_Tracking.sql       /LND_TBOS/dbo_ChargeBack_Tracking.sql
        * Stage_ChargeBack_Tracking.sql     /LND_TBOS_STAGE_FULL/Stage_ChargeBack_Tracking.sql
    

