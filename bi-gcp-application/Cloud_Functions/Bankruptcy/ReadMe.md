
# Bankruptcy Import 

This Cloud Function uses Python 3.10 to Import Zipped files from GCS Bucket to BQ 

## Deployment

 ### This Deployment Script requires 2 inputs
 - Project ID 
 - Service Account Email to use as Runtime and Build the Cloud Function
```bash
sh deploy-bankruptcy.sh [Project ID] [Service account Email]
```

## Prerequisites
  NTTA Unzip Secret key is used in Bankruptcy Import  to Unzip the zipped files uploaded in gcs bucket use below 

  Use given gcloud command to create Secret in Google Cloud Secret manager . 
  ```bash
  printf ["Key to unzip Bankruptcy File"] | gcloud secrets create BANKRUPTCY_SECRET_KEY --data-file=- --replication-policy=user-managed --locations=us-south1
  ``` 
  

## Test
  - DEV,UAT and PROD Directories contains the payload to be used 
  - Secret key needs to be created first to ensure smooth execution of Workflow & cloud function