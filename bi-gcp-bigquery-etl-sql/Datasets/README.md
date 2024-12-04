To run from command line:

    sh create_datasets.sh <PROJECT_ID>

To run from BQ console:

    Ensure that the region in query settings is set to 'us-south1' before executing the query

EDW_TRIPS_datasets.sql creates

    1.EDW_TRIPS
    2.EDW_TRIPS_STAGE
    3.EDW_TRIPS_SUPPORT

LND_TBOS_datasets.sql creates

    1.LND_TBOS
    2.LND_TBOS_STAGE_CDC
    3.LND_TBOS_STAGE_FULL
    4.LND_TBOS_SUPPORT
    5.LND_TBOS_CDC
    6.LND_TBOS_DELETE
    7.LND_TBOS_ARCHIVE

APS_datasets.sql creates

    1.EDW_TRIPS_APS
    2.EDW_TRIPS_STAGE_APS
