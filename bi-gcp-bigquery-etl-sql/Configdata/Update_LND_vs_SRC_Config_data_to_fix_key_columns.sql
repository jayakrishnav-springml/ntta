-- Test
select * from LND_TBOS_SUPPORT.Landing_Vs_Source_Comparison_Config WHERE landingtable in ('History_TP_Customer_Addresses','TollPlus_TP_Customer_Contacts')
select * from LND_TBOS.History_TP_Customer_Addresses limit 1;
select * from LND_TBOS.TollPlus_TP_Customer_Contacts limit 1;

-- Fix
update LND_TBOS_SUPPORT.Landing_Vs_Source_Comparison_Config set keycolumn = 'histid' WHERE landingtable = 'History_TP_Customer_Addresses';
update LND_TBOS_SUPPORT.Landing_Vs_Source_Comparison_Config set keycolumn = 'contactid' WHERE landingtable = 'TollPlus_TP_Customer_Contacts';

