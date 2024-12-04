# ChargeBack Import & Export

This Cloud Function uses Python 3.10 and  performs below steps
- Import 3 ChargeBack Files :  AMEX ,  Tracking & Received 
- Process the files and Load into Stage tables or into Bad Data tables in case of Data Error 
- Executes a Bigquery Stored procedure which Reloads data into Export Tables ( Matching & not matching Data )
- Generates an Excel File on top of the Export table and Uploads the excel File into GCS Bucket's Export Directory 
- Executes a Bigquery Stored Procedure to Inserts data from Stage table to Main Tables for Future References 


## Deployment

 ### This Deployment Script requires 2 inputs
 - Project ID 
 - Service Account Email to use as Runtime and Build the Cloud Function
```bash
sh deploy-chargeback.sh [Project ID] [Service account Email]
```

## Prerequisites
  All 3 csv files must be present in the Import Directory else the function will terminate.
  

## Test
  - DEV,USandbox ,UAT and PROD Directories contains the Sample payload to be used 