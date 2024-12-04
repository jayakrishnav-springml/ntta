CREATE OR REPLACE PROCEDURE `LND_TBOS_SUPPORT.ChargeBack_StageToMain`(stage_dataset STRING, main_datset STRING)
BEGIN
/*
####################################################################################################
Proc Description: 
----------------------------------------------------------------------------------------------------
 1. Insert latest chargeback data from Stage Table to Main Tables 

================================================================================================
Change Log:
--------------------------------------------------------------------------------------------
********    EGen        07-18-2024     New!
================================================================================================
Example:   
--------------------------------------------------------------------------------------------------

#######################################################################################
*/

  DECLARE sql STRING;
  DECLARE sql1 STRING;

  SET sql = "Insert into main_datset_name.table_name select * from stage_dataset_name.table_name";

  SET sql = Replace(sql,"main_datset_name" , main_datset );
  SET sql = Replace(sql,"stage_dataset_name" , stage_dataset );

  SET sql1 = REPLACE(sql,'table_name' ,'dbo_ChargeBack_AMEX' );
  EXECUTE IMMEDIATE sql1 ;

  SET sql1 = REPLACE(sql,'table_name' ,'dbo_ChargeBack_Tracking' );
  EXECUTE IMMEDIATE sql1 ;

  SET sql1 = REPLACE(sql,'table_name' ,'dbo_ChargeBack_Received' );
  EXECUTE IMMEDIATE sql1 ;


  EXCEPTION WHEN ERROR THEN
    BEGIN
      DECLARE error_message STRING DEFAULT @@error.message;
      Select Concat("Error : ",error_message);
      RAISE USING MESSAGE = error_message;  -- Rethrow the error!
    END;
END;