
# GIS Customer and Transaction Data Exports

This Cloud Function uses Python 3.10 to Export GIS customer and transaction data tp GCS as CSV Files. 

## Deployment

 ### This Deployment Script requires 2 inputs
 - Project ID 
 - Service Account Email to use as Runtime and Build the Cloud Function
```bash
sh deploy-gis.sh [Project ID] [Service account Email]
```
  

## Test
  - DEV,UAT and PROD Directories contains the payload to be used 