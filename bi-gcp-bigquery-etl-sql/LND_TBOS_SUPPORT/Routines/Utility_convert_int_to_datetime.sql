CREATE OR REPLACE FUNCTION `LND_TBOS_SUPPORT.convert_int_to_datetime`(timestamp INT64) RETURNS DATETIME AS (
CASE LENGTH(RTRIM(CAST(timestamp AS string)))
      WHEN 10 THEN DATETIME_ADD(DATETIME '1970-01-01', INTERVAL timestamp SECOND)
      WHEN 13 THEN CAST(DATETIME_ADD( DATETIME_ADD(DATETIME '1970-01-01', INTERVAL DIV(timestamp, 1000) SECOND), INTERVAL MOD(timestamp, 1000) MILLISECOND) AS DATETIME)
      WHEN 14 THEN CAST(CONCAT(LEFT(CAST(timestamp AS STRING), 4), '-',SUBSTR(CAST(timestamp AS STRING), 5, 2), '-',SUBSTR(CAST(timestamp AS STRING), 7, 2), ' ', SUBSTR(CAST(timestamp AS STRING), 9, 2), ':', SUBSTR(CAST(timestamp AS STRING), 11, 2), ':', SUBSTR(CAST(timestamp AS STRING), 13, 2)) AS DATETIME)
  END
);