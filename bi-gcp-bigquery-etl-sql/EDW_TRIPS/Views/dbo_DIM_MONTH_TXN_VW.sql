CREATE OR REPLACE VIEW EDW_TRIPS.DIM_MONTH_TXN_VW AS SELECT
    a.tripmonthid,
    a.snapshotmonthid,
    a.asofdayid,
    a.maxasofdayid,
    a.minasofdayid,
    row_number() OVER (PARTITION BY a.tripmonthid ORDER BY a.snapshotmonthid) - 1 AS mthcount
  FROM
    (
      SELECT DISTINCT
          Fact_UnifiedTransaction_SummarySnapshot.tripmonthid,
          Fact_UnifiedTransaction_SummarySnapshot.snapshotmonthid,
          Fact_UnifiedTransaction_SummarySnapshot.asofdayid,
          CASE
            WHEN Fact_UnifiedTransaction_SummarySnapshot.asofdayid = max(Fact_UnifiedTransaction_SummarySnapshot.asofdayid) OVER (PARTITION BY Fact_UnifiedTransaction_SummarySnapshot.tripmonthid ORDER BY Fact_UnifiedTransaction_SummarySnapshot.snapshotmonthid) THEN 1
            ELSE 0
          END AS maxfirstentryflag,
          max(Fact_UnifiedTransaction_SummarySnapshot.asofdayid) OVER (PARTITION BY Fact_UnifiedTransaction_SummarySnapshot.tripmonthid) AS maxasofdayid,
          min(Fact_UnifiedTransaction_SummarySnapshot.asofdayid) OVER (PARTITION BY Fact_UnifiedTransaction_SummarySnapshot.tripmonthid) AS minasofdayid
        FROM
          EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot
        GROUP BY 1, 2, 3
    ) AS a
  WHERE a.maxfirstentryflag <> 0
;
