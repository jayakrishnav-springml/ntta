## Translation time: 2024-03-06T12:00:18.105749Z
## Translation job ID: d4b7ca8f-acb6-42c7-87e7-c4d11bf0a997
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Views/dbo_vw_Fact_VRB.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE VIEW EDW_TRIPS.vw_Fact_VRB AS SELECT
    v.vrbid,
    v.hvid,
    v.customerid,
    v.vehicleid,
    v.vrbstatusid,
    v.vrbagencyid,
    v.vrbrejectreasonid,
    v.vrbremovalreasonid,
    vrbletterdeliverstatusid,
    hv.licenseplatenumber,
    hv.licenseplatestate,
    dv.county AS vehicleregistrationcounty,
    dc.state AS violatorstate,
    dc.zipcode AS violatorzip,
    vs.vrbstatusdescription,
    a.vrbagencydescription,
    rjr.vrbrejectreasondescription,
    rr.vrbremovalreasondescription,
    letterdeliverstatusdesc,
    hv.hvdeterminationdate AS hvdeterminationdate,
    hv.hvterminationdate,
    CAST(CAST(/* expression of unknown or erroneous type */ vrbrequesteddayid as STRING) as DATE) AS vrbrequesteddate,
    CAST(CAST(/* expression of unknown or erroneous type */ vrbapplieddayid as STRING) as DATE) AS vrbapplieddate,
    CAST(CAST(/* expression of unknown or erroneous type */ vrbremoveddayid as STRING) as DATE) AS vrbremoveddate,
    vrbcreateddate,
    vrblettermaileddate,
    vrbletterdelivereddate,
    v.edw_updatedate
  FROM
    EDW_TRIPS.Fact_VRB AS v
    INNER JOIN EDW_TRIPS.Dim_HabitualViolator AS hv ON hv.hvid = v.hvid
    LEFT OUTER JOIN EDW_TRIPS.dim_TER_Letterdeliverstatus AS lds ON v.vrbletterdeliverstatusid = lds.letterdeliverstatusid
    LEFT OUTER JOIN EDW_TRIPS.dim_VRBRemovalReason AS rr ON rr.vrbremovalreasonid = v.vrbremovalreasonid
    LEFT OUTER JOIN EDW_TRIPS.dim_VRBRejectReason AS rjr ON rjr.vrbrejectreasonid = v.vrbrejectreasonid
    LEFT OUTER JOIN EDW_TRIPS.dim_VRBAgency AS a ON a.vrbagencyid = v.vrbagencyid
    LEFT OUTER JOIN EDW_TRIPS.dim_VRBStatus AS vs ON vs.vrbstatusid = v.vrbstatusid
    LEFT OUTER JOIN EDW_TRIPS.dim_vehicle AS dv ON dv.vehicleid = hv.vehicleid
    LEFT OUTER JOIN EDW_TRIPS.Dim_Customer AS dc ON dc.customerid = hv.customerid
;
