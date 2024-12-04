## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Reporting_vw_Dim_Month_Txn.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE VIEW EDW_TRIPS.vw_Dim_Month_Txn AS SELECT
    a.snapshotmonthid,
    a.tripmonthid,
    a.asofdayid,
    a.minasofdayid,
    a.maxasofdayid,
    row_number() OVER (PARTITION BY a.tripmonthid ORDER BY a.snapshotmonthid) - 1 AS monthcount
  FROM
    (
      SELECT DISTINCT
          fact_unifiedtransaction_summarysnapshot.tripmonthid,
          fact_unifiedtransaction_summarysnapshot.snapshotmonthid,
          fact_unifiedtransaction_summarysnapshot.asofdayid,
          CASE
            WHEN fact_unifiedtransaction_summarysnapshot.asofdayid = max(fact_unifiedtransaction_summarysnapshot.asofdayid) OVER (PARTITION BY fact_unifiedtransaction_summarysnapshot.tripmonthid ORDER BY fact_unifiedtransaction_summarysnapshot.snapshotmonthid) THEN 1
            ELSE 0
          END AS maxfirstentryflag,
          min(fact_unifiedtransaction_summarysnapshot.asofdayid) OVER (PARTITION BY fact_unifiedtransaction_summarysnapshot.tripmonthid) AS minasofdayid,
          max(fact_unifiedtransaction_summarysnapshot.asofdayid) OVER (PARTITION BY fact_unifiedtransaction_summarysnapshot.tripmonthid) AS maxasofdayid
        FROM
          EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot
        GROUP BY 1, 2, 3
    ) AS a
  WHERE a.maxfirstentryflag <> 0
;
