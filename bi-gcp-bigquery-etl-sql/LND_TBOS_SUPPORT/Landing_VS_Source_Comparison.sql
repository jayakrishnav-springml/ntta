CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.Landing_VS_Source_Comparison
(
  comparisondatetime DATETIME NOT NULL,
  sourcetablename STRING NOT NULL,
  landingtablename STRING NOT NULL,
  sourcerowcount INT64 NOT NULL,
  landingrowcount INT64 NOT NULL,
  comparisonstatus STRING NOT NULL,
  rowcountdiff INT64 NOT NULL
);  

ALTER TABLE LND_TBOS_SUPPORT.Landing_VS_Source_Comparison ADD COLUMN IF NOT EXISTS executionid INT64;
ALTER TABLE LND_TBOS_SUPPORT.Landing_VS_Source_Comparison ADD COLUMN IF NOT EXISTS sourceexectimeinsec FLOAT64;