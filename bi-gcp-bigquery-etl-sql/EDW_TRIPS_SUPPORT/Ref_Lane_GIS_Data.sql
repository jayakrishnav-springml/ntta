CREATE TABLE IF NOT EXISTS `EDW_TRIPS_SUPPORT.Lane_GIS_Data`(
laneid		INTEGER,	
lanename		STRING,	
tolllocation		STRING,	
zipcode		INTEGER,	
city		STRING,	
county		STRING,	
latitude	NUMERIC(37, 8),	
longitude	NUMERIC(37, 8),
plazadirectionid		STRING,	
EDW_Updatedate		DATETIME);