CREATE or Replace  PROCEDURE `EDW_NAGIOS_SUPPORT.Prepare_Env_For_Test`(last_run_date DATETIME)
BEGIN
/*
#####################################################################################################
Proc Description: 
----------------------------------------------------------------------------------------------------
 This Sp is Designed for Snadbox testing  -- Loading Data from APS Dataset to Main Dataset for Data Validation and Simulated Incremental Load 
 Loads Date into 6 Mian Dim & Fact Tables of Nagios 
    'Dim_Host_Service',
    'Dim_Host_Service_Metric',
    'Fact_Host_Service_Event' ,
    'Fact_Host_Service_Event_Metric' ,
    'Fact_Host_Service_Event_Summary' ,
    'Fact_Host_Service_Event_Metric_Summary' 

================================================================================================
Change Log:
--------------------------------------------------------------------------------------------
********    EGen        26-06-2024     New!
================================================================================================
Example:   
--------------------------------------------------------------------------------------------------
EXEC 

#######################################################################################
*/
  DECLARE last_updated_date  DATETIME;
  DECLARE Tables_To_Load ARRAY<STRING>;
  DECLARE i INT64 DEFAULT 0;
  DECLARE sql1 STRING;
  DECLARE sql2 STRING;
  DECLARE cur_table_name STRING;


  
  CALL EDW_NAGIOS_SUPPORT.Set_UpdatedDate('Nagios Host_Service_Event Dim & Fact Tables', 'EDW_NAGIOS_APS.Fact_Host_Service_Event_Metric_Summary', last_updated_date);
  
  -- Set Default Date , when Not Dates Provided in Input 
  IF last_run_date is NULL
  THEN 
    SET last_run_date = '2024-06-17 07:02:43.453'; -- Based on APS3 Last Run From ProcessLog Table
  END IF;

  UPDATE  `EDW_NAGIOS_SUPPORT.LoadProcessControl` set lastupdateddate = last_run_date where tablename = 'Nagios Host_Service_Event Dim & Fact Tables';

  Select Concat("lastupdateddate is Updated From ",last_updated_date ," To :",last_run_date , " To Simulated Incremental Load");

  SET Sql1 = "Truncate Table  EDW_NAGIOS.Table_Name";
  SET Sql2 = "Insert into EDW_NAGIOS.Table_Name select * from EDW_NAGIOS_APS.Table_Name where lnd_updatedate <= ( select lastupdateddate from EDW_NAGIOS_SUPPORT.LoadProcessControl )";

  SET Tables_To_Load =  ['Dim_Host_Service', 'Dim_Host_Service_Metric', 'Fact_Host_Service_Event' , 'Fact_Host_Service_Event_Metric' ,'Fact_Host_Service_Event_Summary' , 'Fact_Host_Service_Event_Metric_Summary' ];

  LOOP
    SET i = i + 1;
      
      IF i > ARRAY_LENGTH(Tables_To_Load) THEN 
        LEAVE; 
      END IF;
      
      SET cur_table_name = Tables_To_Load[ORDINAL(i)];
      Select Concat("Loading Table " , cur_table_name);

      EXECUTE IMMEDIATE Replace(Sql1 ,'Table_Name', cur_table_name ) ;
      EXECUTE IMMEDIATE Replace(Sql2 ,'Table_Name', cur_table_name );

      Select Concat("Data Loaded in " ,cur_table_name , " Untill last_updated_date ",last_run_date);
      
  END LOOP;
  
  

END;