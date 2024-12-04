## Translation time: 2024-03-06T09:59:19.729172Z
## Translation job ID: 41d16c65-5f33-417b-8c07-cb221ef773e0
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Views/Utility_vw_CDCCompareSummary.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE VIEW LND_TBOS_SUPPORT.vw_CDCCompareSummary AS 
WITH lastfullload_cte AS (
  SELECT
      vw_fullloadtracker.tablename,
      max(vw_fullloadtracker.loadfinishdate) AS lastfullloaddate
    FROM
      LND_TBOS_SUPPORT.vw_fullloadtracker
    GROUP BY 1
)
SELECT
    max(comparerunid) AS comparerunid,
    databasename,
    cdr.tablename,
    ##:: Daily Matching or NonMatching Row Counts numbers
    sum(src_rowcount) AS src_rowcount,
    sum(aps_rowcount) AS aps_rowcount,
    sum(CASE
      WHEN rowcountdiff = 0 THEN src_rowcount
      ELSE 0
    END) AS matching_rowcount,
    sum(CASE
      WHEN rowcountdiff <> 0 THEN rowcountdiff
      ELSE 0
    END) AS nonmatching_rowcount,
    sum(CASE
      WHEN rowcountdiff <> 0 THEN rowcountdiff
      ELSE 0
    END) / (CASE
      WHEN sum(src_rowcount) = 0 THEN sum(aps_rowcount)
      ELSE sum(src_rowcount)
    END * NUMERIC '1.0') * 100 AS nonmatching_rowpercent,

		##:: Matching or NonMatching Row Create Day Counts numbers
    count(1) AS daycount,
    sum(CASE
      WHEN rowcountdiff = 0 THEN 1
      ELSE 0
    END) AS matching_daycount,
    sum(CASE
      WHEN rowcountdiff <> 0 THEN 1
      ELSE 0
    END) AS nonmatching_daycount,
    sum(CASE
      WHEN rowcountdiff <> 0 THEN 1
      ELSE 0
    END) / (count(1) * NUMERIC '1.0') * 100 AS nonmatching_daypercent,
    min(CASE
      WHEN rowcountdiff <> 0 THEN createddate
    END) AS nonmatching_mindate,
    max(CASE
      WHEN rowcountdiff <> 0 THEN createddate
    END) AS nonmatching_maxdate,
    min(lfl.lastfullloaddate) AS lastfullloaddate,
    min(lnd_updatedate) AS comparedate
  FROM
    LND_TBOS_SUPPORT.comparedailyrowcount AS cdr
    LEFT OUTER JOIN lastfullload_cte AS lfl ON cdr.tablename = lfl.tablename
  WHERE comparerunid = (
    SELECT
        max(comparerunid)
      FROM
        LND_TBOS_SUPPORT.comparedailyrowcount
  ) AND createddate < CAST( lnd_updatedate as DATE)
  GROUP BY 2, 3
;