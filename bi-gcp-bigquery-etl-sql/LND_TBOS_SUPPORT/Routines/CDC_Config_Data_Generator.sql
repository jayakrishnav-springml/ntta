CREATE OR REPLACE PROCEDURE `LND_TBOS_SUPPORT.CDC_Config_Data_Generator`(input_tables STRING, key_columns STRING)

BEGIN
  
  /* input_tables is a list of tables separated by comma */

  /* key_columns is a list of key_columns separated by comma corresponding to the tables in input_tables */

  DECLARE current_table_id INT64;
  DECLARE source_table STRING;
  DECLARE main_dataset STRING DEFAULT "LND_TBOS";
  DECLARE source_dataset STRING;
  DECLARE stage_cdc_dataset STRING;
  DECLARE stage_full_dataset STRING;
  DECLARE target_table_columns STRING;
  DECLARE clustering_columns_list STRING;
  DECLARE sql STRING DEFAULT '';
  DECLARE stage_insert_columns_list STRING DEFAULT '';

  SET source_dataset=concat(main_dataset,"_Qlik");
  SET stage_cdc_dataset=concat(main_dataset,"_STAGE_CDC");
  SET stage_full_dataset=concat(main_dataset,"_STAGE_FULL");


  /* Inserting , Updating Config Data for the input tables provided */

 FOR j IN (SELECT table_name as input_table, column_name as key_column_name
      FROM `LND_TBOS.INFORMATION_SCHEMA.COLUMNS` 
      WHERE lower(table_name) in (SELECT lower(ltrim(rtrim(split_value))) FROM UNNEST(SPLIT(input_tables, ",")) AS split_value) and lower(column_name) in (SELECT lower(ltrim(rtrim(key_value))) FROM UNNEST(SPLIT(key_columns, ",")) AS key_value))
  DO

    SET current_table_id=(SELECT coalesce(max(table_id),0)+1 FROM LND_TBOS_SUPPORT.CDC_Full_Load_Config);
    SET source_table=(SELECT table_name FROM LND_TBOS_Qlik.INFORMATION_SCHEMA.TABLES WHERE lower(table_name)= lower(concat(j.input_table,"__ct")));

    SET target_table_columns=(
      SELECT string_agg(column_name,',') FROM LND_TBOS.INFORMATION_SCHEMA.COLUMNS  S WHERE UPPER(S.table_name) =UPPER(j.input_table)
      ); 

    SET clustering_columns_list=(
      SELECT string_agg(column_name, ",") FROM
    `LND_TBOS.INFORMATION_SCHEMA.COLUMNS` S 
    WHERE S.clustering_ordinal_position >0
    AND UPPER(S.table_name) =UPPER(j.input_table) 
    ); 
    
    /* setting stage_insert_columns_list with  target_table_columns to fetch all the columns from target table */

		SET stage_insert_columns_list = target_table_columns;

    /* Removing trailing White Spaces from STRING columns for each table */

		FOR k IN
		(
			   SELECT
					  column_name
			   FROM
					  LND_TBOS_Qlik.INFORMATION_SCHEMA.COLUMNS a
			   WHERE
					  lower(table_name)             = lower(j.input_table)
					  AND column_name NOT LIKE 'header_%'
					  AND a.data_type        ='STRING'
		)
		DO

    
		SET stage_insert_columns_list =
		(
			   SELECT
					  replace (LOWER(stage_insert_columns_list), LOWER(','||k.column_name||','), ",RTRIM(" ||k.column_name||")," )
		);
		END FOR;

    /* Inserting Config Data if there is no record exists on target_dataset and target_table, else Updating the existing record */

    IF (SELECT count(1) FROM  LND_TBOS_SUPPORT.CDC_Full_Load_Config WHERE lower(target_dataset_name)=lower(main_dataset) and lower(target_table_name)=lower(j.input_table)) =0 THEN
    select "inserting";
    INSERT INTO LND_TBOS_SUPPORT.CDC_Full_Load_Config
        (
            table_id,
            source_dataset_name,
            source_table_name,
            stage_cdc_dataset_name,
            stage_full_dataset_name,
            stage_table_name,
            target_dataset_name,
            target_table_name,
            key_column,
            target_table_columns_list,
            cdc_run_flag,
            full_or_partial_load_flag,
            cdc_batch_name,
            batch_window,
            clustering_columns,
            stage_insert_values_list,
            level2_comparison_flag,
            ct_data_retention_days,
            purge_run_flag,
            overlap_window_in_secs
        )
    VALUES 
        (
            current_table_id,
            source_dataset,
            source_table,
            stage_cdc_dataset,
            stage_full_dataset,
            j.input_table,
            main_dataset,
            j.input_table,
            j.key_column_name,
            target_table_columns,
            'N',
            'N',
            'TRIPS',
            3,
            clustering_columns_list,
            stage_insert_columns_list,
            'Y',
            30,
            'N',
            60
        );

    ELSE


    UPDATE LND_TBOS_SUPPORT.CDC_Full_Load_Config

    SET 
        table_id = current_table_id,
        source_dataset_name = source_dataset,
        source_table_name = source_table,
        stage_cdc_dataset_name = stage_cdc_dataset,
        stage_full_dataset_name = stage_full_dataset,
        stage_table_name = j.input_table,
        target_dataset_name = main_dataset,
        key_column = j.key_column_name,
        target_table_columns_list = target_table_columns,
        cdc_run_flag = 'N',
        full_or_partial_load_flag = 'N',
        cdc_batch_name = 'TRIPS',
        batch_window = 3,
        clustering_columns = clustering_columns_list,
        stage_insert_values_list = stage_insert_columns_list,
        level2_comparison_flag = 'Y',
        ct_data_retention_days = 30,
        purge_run_flag = 'N',
        overlap_window_in_secs = 60

    WHERE lower(target_dataset_name)=lower(main_dataset) and
      lower(target_table_name)=lower(j.input_table);


    END IF;
  
  
  END FOR;

END;