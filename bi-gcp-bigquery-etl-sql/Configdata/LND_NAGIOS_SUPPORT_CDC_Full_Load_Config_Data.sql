INSERT INTO LND_NAGIOS_SUPPORT.CDC_Full_Load_Config( table_id, source_dataset_name, source_table_name, stage_cdc_dataset_name, stage_full_dataset_name, stage_table_name, target_dataset_name, target_table_name, key_column, target_table_columns_list, cdc_run_flag, fullload_run_flag, cdc_batch_name, batch_window, clustering_columns, stage_insert_values_list, level2_comparison_flag)
VALUES (100, "LND_NAGIOS_Qlik", "nagios_hostgroup_members__ct", "LND_NAGIOS_STAGE_CDC", "LND_NAGIOS_STAGE_FULL", "Nagios_HostGroup_Members", "LND_NAGIOS", "nagios_hostgroup_members","hostgroup_member_id","hostgroup_member_id,instance_id,hostgroup_id,host_object_id,lnd_updatedate,lnd_updatetype,src_changedate", "N", "N", "NAGIOS", 3,"", NULL, "Y" );

INSERT INTO LND_NAGIOS_SUPPORT.CDC_Full_Load_Config( table_id, source_dataset_name, source_table_name, stage_cdc_dataset_name, stage_full_dataset_name, stage_table_name, target_dataset_name, target_table_name, key_column, target_table_columns_list, cdc_run_flag, fullload_run_flag, cdc_batch_name, batch_window, clustering_columns, stage_insert_values_list, level2_comparison_flag)
VALUES (101, "LND_NAGIOS_Qlik", "nagios_hostgroups__ct", "LND_NAGIOS_STAGE_CDC", "LND_NAGIOS_STAGE_FULL", "Nagios_HostGroups", "LND_NAGIOS", "nagios_hostgroups","hostgroup_id","hostgroup_id,instance_id,config_type,hostgroup_object_id,alias,lnd_updatedate,lnd_updatetype,src_changedate", "N", "N", "NAGIOS", 3,"", NULL, "Y" );

INSERT INTO LND_NAGIOS_SUPPORT.CDC_Full_Load_Config( table_id, source_dataset_name, source_table_name, stage_cdc_dataset_name, stage_full_dataset_name, stage_table_name, target_dataset_name, target_table_name, key_column, target_table_columns_list, cdc_run_flag, fullload_run_flag, cdc_batch_name, batch_window, clustering_columns, stage_insert_values_list, level2_comparison_flag)
VALUES (102, "LND_NAGIOS_Qlik", "nagios_hosts__ct", "LND_NAGIOS_STAGE_CDC", "LND_NAGIOS_STAGE_FULL", "Nagios_Hosts", "LND_NAGIOS", "nagios_hosts","host_id","host_id,instance_id,config_type,host_object_id,alias,display_name,address,importance,check_command_object_id,check_command_args,eventhandler_command_object_id,eventhandler_command_args,notification_timeperiod_object_id,check_timeperiod_object_id,failure_prediction_options,check_interval,retry_interval,max_check_attempts,first_notification_delay,notification_interval,notify_on_down,notify_on_unreachable,notify_on_recovery,notify_on_flapping,notify_on_downtime,stalk_on_up,stalk_on_down,stalk_on_unreachable,flap_detection_enabled,flap_detection_on_up,flap_detection_on_down,flap_detection_on_unreachable,low_flap_threshold,high_flap_threshold,process_performance_data,freshness_checks_enabled,freshness_threshold,passive_checks_enabled,event_handler_enabled,active_checks_enabled,retain_status_information,retain_nonstatus_information,notifications_enabled,obsess_over_host,failure_prediction_enabled,notes,notes_url,action_url,icon_image,icon_image_alt,vrml_image,statusmap_image,have_2d_coords,x_2d,y_2d,have_3d_coords,x_3d,y_3d,z_3d,lnd_updatedate,lnd_updatetype,src_changedate", "N", "N", "NAGIOS", 3,"", NULL, "Y" );

INSERT INTO LND_NAGIOS_SUPPORT.CDC_Full_Load_Config( table_id, source_dataset_name, source_table_name, stage_cdc_dataset_name, stage_full_dataset_name, stage_table_name, target_dataset_name, target_table_name, key_column, target_table_columns_list, cdc_run_flag, fullload_run_flag, cdc_batch_name, batch_window, clustering_columns, stage_insert_values_list, level2_comparison_flag)
VALUES (103, "LND_NAGIOS_Qlik", "nagios_objects__ct","LND_NAGIOS_STAGE_CDC", "LND_NAGIOS_STAGE_FULL", "Nagios_Objects", "LND_NAGIOS", "nagios_objects","object_id","object_id,instance_id,objecttype_id,name1,name2,is_active,lnd_updatedate,lnd_updatetype,src_changedate", "N", "N", "NAGIOS", 3,"", NULL, "Y" );

INSERT INTO LND_NAGIOS_SUPPORT.CDC_Full_Load_Config( table_id, source_dataset_name, source_table_name, stage_cdc_dataset_name, stage_full_dataset_name, stage_table_name, target_dataset_name, target_table_name, key_column, target_table_columns_list, cdc_run_flag, fullload_run_flag, cdc_batch_name, batch_window, clustering_columns, stage_insert_values_list, level2_comparison_flag)
VALUES (104, "LND_NAGIOS_Qlik", "nagios_services__ct","LND_NAGIOS_STAGE_CDC", "LND_NAGIOS_STAGE_FULL", "Nagios_Services", "LND_NAGIOS", "nagios_services","service_object_id","service_id,instance_id,config_type,host_object_id,service_object_id,display_name,importance,check_command_object_id,check_command_args,eventhandler_command_object_id,eventhandler_command_args,notification_timeperiod_object_id,check_timeperiod_object_id,failure_prediction_options,check_interval,retry_interval,max_check_attempts,first_notification_delay,notification_interval,notify_on_warning,notify_on_unknown,notify_on_critical,notify_on_recovery,notify_on_flapping,notify_on_downtime,stalk_on_ok,stalk_on_warning,stalk_on_unknown,stalk_on_critical,is_volatile,flap_detection_enabled,flap_detection_on_ok,flap_detection_on_warning,flap_detection_on_unknown,flap_detection_on_critical,low_flap_threshold,high_flap_threshold,process_performance_data,freshness_checks_enabled,freshness_threshold,passive_checks_enabled,event_handler_enabled,active_checks_enabled,retain_status_information,retain_nonstatus_information,notifications_enabled,obsess_over_service,failure_prediction_enabled,notes,notes_url,action_url,icon_image,icon_image_alt,lnd_updatedate,lnd_updatetype,src_changedate", "N", "N", "NAGIOS", 3,"", NULL, "Y" );

INSERT INTO LND_NAGIOS_SUPPORT.CDC_Full_Load_Config( table_id, source_dataset_name, source_table_name, stage_cdc_dataset_name, stage_full_dataset_name, stage_table_name, target_dataset_name, target_table_name, key_column, target_table_columns_list, cdc_run_flag, fullload_run_flag, cdc_batch_name, batch_window, clustering_columns, stage_insert_values_list, level2_comparison_flag)
VALUES (106, "LND_NAGIOS_Qlik", "nagios_hoststatus__ct", "LND_NAGIOS_STAGE_CDC", "LND_NAGIOS_STAGE_FULL", "Nagios_HostStatus", "LND_NAGIOS", "Host_Event","","", "N", "N", "HOST_EVENT", 5,"host_event_id", NULL, "Y" );

INSERT INTO LND_NAGIOS_SUPPORT.CDC_Full_Load_Config( table_id, source_dataset_name, source_table_name, stage_cdc_dataset_name, stage_full_dataset_name, stage_table_name, target_dataset_name, target_table_name, key_column, target_table_columns_list, cdc_run_flag, fullload_run_flag, cdc_batch_name, batch_window, clustering_columns, stage_insert_values_list, level2_comparison_flag)
VALUES (105, "LND_NAGIOS_Qlik", "nagios_servicestatus__ct", "LND_NAGIOS_STAGE_CDC", "LND_NAGIOS_STAGE_FULL", "Nagios_ServiceStatus", "LND_NAGIOS", "Service_Event","","", "N", "N", "SERVICE_EVENT", 5,"service_event_id", NULL, "Y" );