CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.Landing_Vs_Source_Comparison_Config
(   
    sourcedatabase STRING NOT NULL,
    sourceschema STRING NOT NULL,
    sourcetable STRING NOT NULL,
    keycolumn STRING NOT NULL,
    landingdataset STRING NOT NULL,
    landingtable STRING NOT NULL,
    comparisonrunflag STRING NOT NULL,
    level2checkflag STRING NOT NULL,
    groupbycolumn STRING
);