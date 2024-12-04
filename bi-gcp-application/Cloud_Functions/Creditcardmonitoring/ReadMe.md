
# Creditcardmonitoring Import 

This Cloud Function uses Python 3.10 to Import creditcardmonitoring.dfr files from GCS Bucket to BQ 

## Deployment

 ### This Deployment Script requires 2 inputs
 - Project ID 
 - Service Account Email to use as Runtime and Build the Cloud Function
```bash
sh deploy-creditcardmonitoring.sh [Project ID] [Service account Email]
```

## Prerequisites
  NTTA Daily creditcardmonitoring.dfr files are uploaded into the gcs bucket
  

## Test