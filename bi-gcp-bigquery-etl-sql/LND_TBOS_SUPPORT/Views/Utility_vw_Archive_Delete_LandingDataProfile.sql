## Translation time: 2024-03-06T09:59:19.729172Z
## Translation job ID: 41d16c65-5f33-417b-8c07-cb221ef773e0
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Views/Utility_vw_Archive_Delete_LandingDataProfile.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE VIEW LND_TBOS_SUPPORT.vw_Archive_Delete_LandingDataProfile
AS
  SELECT
    CASE
      WHEN tlp.cdcflag = 1 THEN 'CDC'
      ELSE 'Full'
    END AS cdc_or_full,
    tlp.databasename,
    tlp.fullname AS tablename,
    replace(replace(tlp.uid_columns, '[', ''), ']', '') AS uid_columns,
    coalesce(cc.aps_rowcount,full_rc.row_count, tlp.rowcnt) AS totalrowcount,
    coalesce(arch.archiverowcount, 0) AS archiverowcount,
    CASE
      WHEN atl.tablename IS NOT NULL THEN 1
      ELSE 0
    END AS archivetablesmasterlistflag,
    tlp.archiveflag AS archiveenabledflag,
    CASE
      WHEN hd.tablename IS NOT NULL THEN 1
      ELSE 0
    END AS harddeletetableflag,
    coalesce(del.deleterowcount, 0) AS deleterowcount,
    DATE(current_datetime()) AS asofdate
  FROM
    LND_TBOS_SUPPORT.tableloadparameters AS tlp
    LEFT OUTER JOIN LND_TBOS_SUPPORT.archivemastertablelist AS atl ON tlp.fullname = atl.tablename ##WHERE tlp.FullName = 'TollPlus.TP_CustTxns'
    LEFT OUTER JOIN LND_TBOS_SUPPORT.harddeletetable AS hd ON tlp.fullname = hd.tablename
    LEFT OUTER JOIN LND_TBOS_SUPPORT.vw_cdccomparesummary AS cc ON tlp.fullname = cc.tablename
    LEFT OUTER JOIN (
      SELECT
      archivedeleterowcount.tablename,
      sum(archivedeleterowcount.row_count) AS archiverowcount
    FROM
      LND_TBOS_SUPPORT.archivedeleterowcount
    WHERE archivedeleterowcount.lnd_updatetype = 'A'
    GROUP BY 1
    ) AS arch ON tlp.fullname = arch.tablename
    LEFT OUTER JOIN (
      SELECT
      archivedeleterowcount.tablename,
      sum(archivedeleterowcount.row_count) AS deleterowcount
    FROM
      LND_TBOS_SUPPORT.archivedeleterowcount
    WHERE archivedeleterowcount.lnd_updatetype = 'D'
    GROUP BY 1
    ) AS del ON tlp.fullname = del.tablename
    LEFT OUTER JOIN (
      SELECT
      rc.tablename,
      rc.row_count
    FROM
      (
            SELECT
        processlog.logsource AS tablename,
        processlog.row_count,
        row_number() OVER (PARTITION BY processlog.logsource ORDER BY processlog.logdate DESC) AS rn
      FROM
        LND_TBOS_SUPPORT.processlog
      WHERE processlog.logdate > current_date() - 31
        AND processlog.logmessage = 'Step 2: SSIS load finished'
          ) AS rc
    WHERE rc.rn = 1
    ) AS full_rc ON tlp.fullname = full_rc.tablename
  WHERE active = 1
;
