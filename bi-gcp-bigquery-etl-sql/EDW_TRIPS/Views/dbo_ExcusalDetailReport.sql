## Translation time: 2024-03-06T12:00:18.105749Z
## Translation job ID: d4b7ca8f-acb6-42c7-87e7-c4d11bf0a997
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Views/dbo_ExcusalDetailReport.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE VIEW EDW_TRIPS.ExcusalDetailReport AS SELECT
    Reporting_ExcusalDetailReport.snapshotmonthid,
    Reporting_ExcusalDetailReport.tptripid,
    Reporting_ExcusalDetailReport.customerid,
    Reporting_ExcusalDetailReport.vehiclenumber,
    Reporting_ExcusalDetailReport.lanename,
    Reporting_ExcusalDetailReport.tripdate,
    Reporting_ExcusalDetailReport.excuseddatetime,
    Reporting_ExcusalDetailReport.tripstatusdate,
    Reporting_ExcusalDetailReport.tollamount,
    Reporting_ExcusalDetailReport.tollexcused,
    Reporting_ExcusalDetailReport.adminfee1,
    Reporting_ExcusalDetailReport.adminfee1waived,
    Reporting_ExcusalDetailReport.adminfee2,
    Reporting_ExcusalDetailReport.adminfee2waived,
    Reporting_ExcusalDetailReport.reasoncode,
    Reporting_ExcusalDetailReport.grouplevel,
    Reporting_ExcusalDetailReport.excuseby,
    Reporting_ExcusalDetailReport.lnd_updatedate AS edw_updatedate
  FROM
    LND_TBOS.Reporting_ExcusalDetailReport
;
