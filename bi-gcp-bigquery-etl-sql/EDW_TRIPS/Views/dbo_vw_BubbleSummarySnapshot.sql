## Translation time: 2024-03-06T12:00:18.105749Z
## Translation job ID: d4b7ca8f-acb6-42c7-87e7-c4d11bf0a997
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Views/dbo_vw_BubbleSummarySnapshot.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE VIEW EDW_TRIPS.vw_BubbleSummarySnapshot AS SELECT
    ss.snapshotmonthid,
    ss.asofdayid,
    ss.rowseq,
    ss.tripmonthid,
    div(ss.tripmonthid, 100) AS tripyearid,
    ss.facilitycode,
    ss.operationsagency,
    ss.operationsmappingid,
    ss.mapping,
    ss.mappingdetailed,
    ss.pursunpursstatus,
    rt.recordtype,
    tim.tripidentmethod,
    ss.tripwith,
    tpt.transactionpostingtype,
    ss.tripstageid,
    tsg.tripstagecode,
    tsg.tripstagedesc,
    ss.tripstatusid,
    tst.tripstatuscode,
    tst.tripstatusdesc,
    rc.reasoncode,
    csg.citationstagecode,
    ps.trippaymentstatusdesc,
    ss.sourcename,
    ss.txncount,
    ss.expectedamount,
    ss.adjustedexpectedamount,
    ss.calcadjustedamount,
    ss.tripwithadjustedamount,
    ss.tollamount,
    ss.actualpaidamount,
    ss.outstandingamount,
    ss.badaddressflag,
    ss.nonrevenueflag,
    ss.businessrulematchedflag,
    ss.oosplateflag,
    ss.manuallyreviewedflag,
    ss.classadjustmentflag,
    0 AS iopduplicateflag,
    ss.firstpaidmonthid,
    ss.lastpaidmonthid,
    concat("\'", ss.rpt_paidvsaea) AS rpt_paidvsaea,
    ss.rpt_purunp,
    ss.rpt_lpstate,
    ss.rpt_invuninv,
    ss.rpt_vtoll,
    ss.rpt_irstatus,
    ss.rpt_processstatus,
    ss.rpt_paidstatus,
    ss.rpt_irrejectstatus
  FROM
    EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot AS ss
    INNER JOIN EDW_TRIPS.Dim_TripIdentMethod AS tim ON tim.tripidentmethodid = ss.tripidentmethodid
    INNER JOIN EDW_TRIPS.Dim_TransactionPostingType AS tpt ON tpt.transactionpostingtypeid = ss.transactionpostingtypeid
    INNER JOIN EDW_TRIPS.Dim_TripStage AS tsg ON tsg.tripstageid = ss.tripstageid
    INNER JOIN EDW_TRIPS.Dim_TripStatus AS tst ON tst.tripstatusid = ss.tripstatusid
    INNER JOIN EDW_TRIPS.Dim_ReasonCode AS rc ON rc.reasoncodeid = ss.reasoncodeid
    INNER JOIN EDW_TRIPS.Dim_CitationStage AS csg ON csg.citationstageid = ss.citationstageid
    INNER JOIN EDW_TRIPS.Dim_TripPaymentStatus AS ps ON ps.trippaymentstatusid = ss.trippaymentstatusid
    INNER JOIN EDW_TRIPS.Dim_RecordType AS rt ON rt.recordtypeid = ss.recordtypeid
;
