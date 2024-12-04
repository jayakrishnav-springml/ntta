## Translation time: 2024-03-06T12:00:18.105749Z
## Translation job ID: d4b7ca8f-acb6-42c7-87e7-c4d11bf0a997
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Views/dbo_vw_GL_IOP_UnidentifiedAgingTxn.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE VIEW EDW_TRIPS.vw_GL_IOP_UnidentifiedAgingTxn AS WITH cte_tt_dr AS (
  SELECT
      gl_txnid,
      linkid AS tptripid,
      customerid,
      a1.businessunitid,
      CAST(/* expression of unknown or erroneous type */ postingdate as DATE) AS postingdate,
      CAST(/* expression of unknown or erroneous type */ txndate as DATE) AS txndate,
      txnamount
    FROM
      EDW_TRIPS.Fact_GL_Transactions AS a1
      INNER JOIN EDW_TRIPS.Dim_GL_TxnType AS a2 ON a1.txntypeid = a2.txntypeid
    WHERE (txntype LIKE 'IOP%UNIDTTDR'
     OR txntype LIKE 'IOP%UNIDTT')
     AND status = 'Active'
     AND customerid = 100057393
), cte_tt_cr AS (
  SELECT
      gl_txnid,
      linkid AS tptripid,
      customerid,
      a1.businessunitid,
      CAST(/* expression of unknown or erroneous type */ postingdate as DATE) AS postingdate,
      CAST(/* expression of unknown or erroneous type */ txndate as DATE) AS txndate,
      txnamount
    FROM
      EDW_TRIPS.Fact_GL_Transactions AS a1
      INNER JOIN EDW_TRIPS.Dim_GL_TxnType AS a2 ON a1.txntypeid = a2.txntypeid
    WHERE (txntype LIKE 'IOP%UNIDTTCR'
     OR txntype LIKE 'IOP%UNIDTTREJ')
     AND status = 'Active'
     AND customerid = 100057393
), cte_vt_dr AS (
  SELECT
      gl_txnid,
      linkid AS tptripid,
      customerid,
      a1.businessunitid,
      CAST(/* expression of unknown or erroneous type */ postingdate as DATE) AS postingdate,
      CAST(/* expression of unknown or erroneous type */ txndate as DATE) AS txndate,
      txnamount
    FROM
      EDW_TRIPS.Fact_GL_Transactions AS a1
      INNER JOIN EDW_TRIPS.Dim_GL_TxnType AS a2 ON a1.txntypeid = a2.txntypeid
    WHERE (txntype LIKE 'IOP%UNIDVTDR'
     OR txntype LIKE 'IOP%UNIDVT')
     AND status = 'Active'
     AND customerid = 100057393
), cte_vt_cr AS (
  SELECT
      gl_txnid,
      linkid AS tptripid,
      customerid,
      a1.businessunitid,
      CAST(/* expression of unknown or erroneous type */ postingdate as DATE) AS postingdate,
      CAST(/* expression of unknown or erroneous type */ txndate as DATE) AS txndate,
      txnamount
    FROM
      EDW_TRIPS.Fact_GL_Transactions AS a1
      INNER JOIN EDW_TRIPS.Dim_GL_TxnType AS a2 ON a1.txntypeid = a2.txntypeid
    WHERE (txntype LIKE 'IOP%UNIDVTCR'
     OR a2.txntype LIKE 'IOP%UNIDVTREJ'
     AND a1.customerid = 100057393
     OR (a2.txntype LIKE 'IOPNTELBJ%VT'
     AND a2.txntype NOT IN(
      'IOPNTELBJUNIDVT'
    )
     OR a2.txntype LIKE 'IOPNTE12%VT'
     AND a2.txntype NOT IN(
      'IOPNTE12UNIDVT'
    )))
     AND status = 'Active'
)
SELECT
    t.gl_txnid,
    t.tptripid,
    ft.laneid,
    t.customerid,
    t.businessunitid,
    t.postingdate,
    t.txndate,
    t.txnamount,
    datetime_diff(current_datetime(), CAST(t.postingdate as DATETIME), DAY) AS daycountid
  FROM
    cte_tt_dr AS t
    INNER JOIN EDW_TRIPS.Fact_Transaction AS ft ON t.tptripid = ft.tptripid
  WHERE t.tptripid NOT IN(
    SELECT
        cte_tt_cr.tptripid
      FROM
        cte_tt_cr
  )
UNION DISTINCT
SELECT
    t.gl_txnid,
    t.tptripid,
    ft.laneid,
    t.customerid,
    t.businessunitid,
    t.postingdate,
    t.txndate,
    t.txnamount,
    datetime_diff(current_datetime(), CAST(t.postingdate as DATETIME), DAY) AS daycountid
  FROM
    cte_vt_dr AS t
    INNER JOIN EDW_TRIPS.Fact_Transaction AS ft ON t.tptripid = ft.tptripid
  WHERE t.tptripid NOT IN(
    SELECT
        cte_vt_cr.tptripid
      FROM
        cte_vt_cr
  )
;
