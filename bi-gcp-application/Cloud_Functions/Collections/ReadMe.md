# Collections Export

This Cloud Function uses Python 3.10 and  performs below steps
* Run 2 Stored Procedures Required to Create Intermediate & Export tables
    - **EDW_TRIPS.CollectionsScript** : This Stored Procedure Loads Data into all Required tables along with  Main Collection Table Needed for Collection Exports 
    - **EDW_TRIPS.Collections_FileCreationScript** : This Stored Procedure Loads Data into all 4 Exports Tables

- Exports all 4 Final Collections Export Tables to GCS Bucket follwing below steps 
    - Create a Partitioned tables to Split the Table in 10 Partitions
    - Export each partitions into Seprate Export files in GCS Temp Path 
    - Merge all the Exports of Partitions into 1 Final File 


## Deployment

 ### This Deployment Script requires 2 inputs
 - Project ID 
 - Service Account Email to use as Runtime and Build the Cloud Function
```bash
sh deploy-collections-export.sh [Project ID] [Service account Email]
```

## Prerequisites
  Both Stored procedure Must be Compiled in BQ 
  

## Test
  - DEV,USandbox ,UAT and PROD Directories contains the Sample payload to be used 