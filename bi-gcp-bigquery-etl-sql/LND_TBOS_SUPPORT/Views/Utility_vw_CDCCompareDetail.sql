## Translation time: 2024-03-06T09:59:19.729172Z
## Translation job ID: 41d16c65-5f33-417b-8c07-cb221ef773e0
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Views/Utility_vw_CDCCompareDetail.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE VIEW LND_TBOS_SUPPORT.vw_CDCCompareDetail
AS
  WITH
    lastfullload_cte
    AS
    (
      SELECT
        vw_fullloadtracker.tablename,
        max(vw_fullloadtracker.loadfinishdate) AS lastfullloaddate
      FROM LND_TBOS_SUPPORT.vw_fullloadtracker
      GROUP BY 1
    )
  SELECT
    comparerunid,
    databasename,
    cdr.tablename,
    createddate,
    src_rowcount,
    aps_rowcount,
    rowcountdiff,
    diffpercent,
    lnd_updatedate AS comparedate,
    CAST(lfl.lastfullloaddate  as Date)AS lastfullloaddate
  FROM
    LND_TBOS_SUPPORT.comparedailyrowcount AS cdr
    LEFT OUTER JOIN lastfullload_cte AS lfl ON cdr.tablename = lfl.tablename
  WHERE comparerunid = (
    SELECT
      max(comparerunid)
    FROM
      LND_TBOS_SUPPORT.comparedailyrowcount
  )
    AND rowcountdiff <> 0
    AND createddate < CAST(lnd_updatedate as DATE)
;
