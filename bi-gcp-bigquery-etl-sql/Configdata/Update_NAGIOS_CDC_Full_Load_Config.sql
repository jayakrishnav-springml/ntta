UPDATE LND_NAGIOS_SUPPORT.CDC_Full_Load_Config SET overlap_window_in_secs= 30 WHERE TRUE;
UPDATE LND_NAGIOS_SUPPORT.CDC_Full_Load_Config SET key_column="host_event_id" where target_table_name="Host_Event";
UPDATE LND_NAGIOS_SUPPORT.CDC_Full_Load_Config SET key_column="service_event_id" where target_table_name="Service_Event";