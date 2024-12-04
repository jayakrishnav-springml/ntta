# 1. Get_Select_String Stored Procedure
This proc creating and returning part of SQL statement of all table columns to use in queries like Select and Create as Select 
Depends on Parameters it can be just list of names divided by comma, or use cast, IFNULL and allias.

# Parameters:
1. table (STRING): table for get columns from.
   example:   "TollPlus_TP_Customers"

2. params_in_sql_out (STRING): Param to return SQL statement. Can take some secondary parameters
   can include values:  'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NoPrint'.

# 2. Get_SelectFromTable_SQL Stored Procedure
This proc creating and returning SQL SELECT statement for all table columns 
Depends on Parameters it can be just list of names divided by comma, or use cast, IFNULL and allias.

# Parameters:
1. table (STRING): table for get columns from.
   example:   "TollPlus_TP_Customers"

2. params_in_sql_out (STRING): Param to return SQL statement. Can take some secondary parameters
   can include values:  'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NoPrint'.

# 3. Get_CreateTableAs_SQL Stored Procedure
This proc creating and returning CREATE OR REPLACE TABLE AS SELECT statement for table from another table.

# Parameters:
1. table (STRING): Name of the table to get all data and Metadata from
2. new_table_name (STRING): Table name we need to create from the table. All metatadata and data will be the same. If empty or Null new name will be 'New.' + table
3. params_in_sql_out (STRING): Param to return string. 
	-- can be: 	'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NoPrint'.

# 4. Get_CreateEmptyCopy_SQL Stored Procedure
This proc creating and returning SQL statement to create empty new table as full copy of metadata from source table
New table has the same Columns, Indexes.

# Parameters:
1. table (STRING):  Name of the table to get Metadata from
2. new_table_name (STRING): Table name we need to create as empty. If empty or Null new name will be table + '_Copy'
3. params_in_sql_out (STRING): Param to return SQL statement. Can take some secondary parameters
	can include values: 	'No[],NoPrint'

# 5. Get_TableInfo Stored Procedure
This proc gives you possibility to kick off several GET SQL procs from one call.

# Parameters:
1. table (STRING): table name for all actions you want to apply
2. proc_name (STRING): List of the procs you want to use for the table you sent separated by comma.
3. params_in_sql_out (STRING): Param to return SQL statement. Can take some secondary parameters
	can include values: 	'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NewTable:NewTable,NoPrint'
	If NewTable  not chosen, it will be table + '_New' by default
	If NewTable starts from '_' - it thinks it is a suffix to add to the table name



# Notes:
1. The dataset name (LND_TBOS) has been hardcoded before tablenames in the respective SPs.
2. No[] parameter should be included always since BQ doesn't support columns enclosed in [].
3. tablename column in the TableAlias table has been changed to be compatible with respective BQ tablename.

