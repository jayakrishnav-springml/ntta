def discover_idcolumn_minmaxcount(table_info, connection, log):
    """
    Discover the minimum and maximum values of an ID column in a specified table.

    Args:
        table_info (dict): Information about the table, including schema_name, table_name, and id_field.
        connection (object): A database connection object used to execute SQL queries.
        log (logging.Logger): Logger object for logging messages.

    Returns:
        tuple: A tuple containing:
            - The minimum value of the ID column (or 0 if there's no ID field).
            - The maximum value of the ID column (or 0 if there's no ID field).
            - An SQL query (string) to fetch all rows if the ID field is not specified, or None otherwise.
            - The SQL Server Big count value of the table (or 0 if there's no ID field).
    """
    schema_name = table_info["schema_name"]
    table_name = table_info["table_name"]
    id_field = table_info["id_field"]
    ## IMPORTANT !! If id_field is empty return SELECT * query with no min max values
    if id_field == "":
        return 0,0,f"SELECT * from {table_info['schema_name']}.{table_info['table_name']}",0
    min_max_query = f"SELECT min({id_field}), max({id_field}), count_big(*) from {schema_name}.{table_name} where {id_field} >=0"
    print("-----min_max_query: ------ "+min_max_query)
    cursor = connection.cursor()
    cursor.execute(min_max_query)
    while True:
        row = cursor.fetchone()
        if row == None:
            break
        print(f"minmax for {id_field} in {schema_name}.{table_name}: {row[0]}, {row[1]}")
        return row[0] if row[0] != None else 0, row[1] if row[1] != None else 0, None, row[2] if row[2] != None else 0

