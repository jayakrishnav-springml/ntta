# Introduction 
Any application code you need to store related to the project.  Ideally, if we have multiple applications I would prefer to break this down by application so we can easily manage deployment pipelines in the future

# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
2.	Software dependencies
3.	Latest releases
4.	API references

# Build and Test
TODO: Describe and show how to build your code and run the tests. 

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)

## Parallel Full load
start "Parallel Full load" python data_parallel_export_all_tables.py .\config\LND_TBOS\parallel_LND_TBOS_active_1.json 

## Parallel Full load filecount
python data_parallel_filecount_all_tables.py .\config\LND_TBOS\parallel_LND_TBOS_active_1.json > filecount.txt

11/04/24 20:30:48 Finished
Filecount=13874 in Duration=27 seconds

python data_parallel_export_all_tables.py .\config\LND_TBOS\parallel_LND_TBOS_priority.json > parallel_extract_priority_956pm.txt

## Export for row count difference
python data_parallel_export_all_tables.py .\config\LND_TBOS\parallel_LND_TBOS_rowcountdiff.json > parallel_extract_rowcountdiff_1207pm.txt


python data_parallel_export_all_tables.py .\config\LND_TBOS\parallel_LND_TBOS_rowcountdiff.json > parallel_extract_rowcountdiff_211pm.txt


## Row Count Fixes in JSON

### TP_Customer_Tags
```json
{
        "table_name": "TP_Customer_Tags",
        "schema_name": "TollPlus",
        "gcs_upload_flag": "False",
        "id_field": "CustTagID",
        "row_chunk_size": "5000000",
        "chunk_flag": "True",
        "query": "SELECT CustTagID, CustomerID, TagStartDate, TagEndDate, TagType, TagStatus, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(TagAlias, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34))  as TagAlias, HexTagID, SerialNo, ReturnedOrAssignedType, ItemCode, IsNonRevenue, IsGroundTransPortation, TagAgency, SpecialityTag, Mounting, IsDFWBlocked, IsDALBlocked, TagAssignedDate, TagStatusDate, ChannelID, ICNID, TagAssignedEndDate, CreatedDate, CreatedUser, UpdatedDate, UpdatedUser,  LND_UpdateDate, LND_UpdateType FROM TollPlus.TP_Customer_Tags"
      }

```

### TP_Customer_Contacts
```json
{
        "table_name": "TP_Customer_Contacts",
        "schema_name": "TollPlus",
        "gcs_upload_flag": "False",
        "id_field": "ContactID",
        "row_chunk_size": "5000000",
        "chunk_flag": "True",
        "query": "SELECT ContactID, CustomerID, Title, Suffix, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(FirstName, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS FirstName, MiddleName, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(LastName, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as LastName, Gender, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(NameType, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS NameType, IsCommunication, DateOfBirth, FirstName2, LastName2, ICNID, ChannelID, Race, CreatedDate, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(CreatedUser, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS CreatedUser, UpdatedDate, UpdatedUser, LND_UpdateDate, LND_UpdateType FROM TollPlus.TP_Customer_Contacts WITH (NOLOCK)"
      }

```

python data_parallel_export_all_tables.py .\config\LND_TBOS\parallel_LND_TBOS_rowcountdiff.json > parallel_extract_rowcountdiff_customercontacts_313pm.txt


### LND_TBOS_TollPlus.TP_Customer_Vehicles 5m delta
Added Expression to all String columns 
CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(TABLENAME, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS TABLENAME
```json
{
        "table_name": "TP_Customer_Vehicles",
        "schema_name": "TollPlus",
        "gcs_upload_flag": "False",
        "id_field": "VehicleID",
        "row_chunk_size": "5000000",
        "chunk_flag": "True",
        "query": "SELECT VehicleID, CustomerID, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(VehicleNumber, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS VehicleNumber, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(VehicleCountry, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS VehicleCountry, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(VehicleState, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS VehicleState, Year, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(Make, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS  Make, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(Model, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS Model, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(Color, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS Color, StartEffectiveDate, EndEffectiveDate, VehicleStatusID, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(VehicleClassCode, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS  VehicleClassCode, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(VIN, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS VIN, IsProtected, IsExempted, IsTempNumber, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(TagID, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS TagID, ContractualTypeID, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(PlateType, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS PlateType, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(VehicleShape, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS VehicleShape, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(FuelEfficiency, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS FuelEfficiency, IsHamRadioOperator, IsTrailer, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(LicensePlateImagePath, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS LicensePlateImagePath, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(DepartmentName, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS DepartmentName, ExcessiveVTolls, IsInHV, Isvrh, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(DocNo, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS DocNo, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(VehicleBodyVIN, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS VehicleBodyVIN, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(County, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS County, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(Temp_Source, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS Temp_Source, Temp_PK, Temp_Key, ChannelID, ICNID, IsVTollEnabled, FilePathConfigurationID, CreatedDate, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(CreatedUser, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS CreatedUser, UpdatedDate, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(UpdatedUser, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS UpdatedUser, LND_UpdateDate, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(LND_UpdateType, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS LND_UpdateType FROM TollPlus.TP_Customer_Vehicles WITH (NOLOCK)"
      }
```

python data_parallel_export_all_tables.py .\config\LND_TBOS\parallel_LND_TBOS_rowcountdiff.json > parallel_extract_rowcountdiff_customervehicles_419pm.txt


### LND_TBOS_Finance.Gl_Txn_LineItem  92m delta

```json
{
        "table_name": "Gl_Txn_LineItems",
        "schema_name": "Finance",
        "gcs_upload_flag": "False",
        "id_field": "PK_ID",
        "row_chunk_size": "5000000",
        "chunk_flag": "True",
        "query": "SELECT PK_ID, Gl_TxnID, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(Description, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS Description, ChartOfAccountID, DebitAmount, CreditAmount, SpecialJournalID, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(Drcr_Flag, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS Drcr_Flag, TxnType_Li_ID, TxnTypeID, CreatedDate, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(CreatedUser, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS CreatedUser, UpdatedDate, UpdatedUser, LND_UpdateDate, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(LND_UpdateType, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) AS LND_UpdateType FROM Finance.Gl_Txn_LineItems WITH (NOLOCK)"        
      }
``
python data_parallel_export_all_tables.py .\config\LND_TBOS\parallel_LND_TBOS_rowcountdiff.json > parallel_extract_rowcountdiff_gltxnlineitems_535pm.txt

### LND_TBOS_TollPlus.TP_Violated_Trip_Receipts_Tracker  790m delta

```json

{
            "table_name": "TP_Violated_Trip_Receipts_Tracker",
            "schema_name": "TollPlus",
            "id_field": "TripReceiptID",
            "row_chunk_size": "5000000",
            "chunk_flag": "True",
            "query": "select TripReceiptID, CitationID, ViolatorID, LinkID, AmountReceived, TxnDate, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(LinkSourceName, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as LinkSourceName, TripChargeID, InvoiceID, OverpaymentID, CreatedDate, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(CreatedUser, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as CreatedUser, UpdatedDate, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(UpdatedUser, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as UpdatedUser, LND_UpdateDate, CONCAT(CHAR(34), REPLACE(REPLACE(REPLACE(LND_UpdateType, CHAR(34), '\"\"'), CHAR(147), '\"\"'), CHAR(148),'\"\"'), CHAR(34)) as LND_UpdateType from TollPlus.TP_Violated_Trip_Receipts_Tracker",
            "gcs_upload_flag": "FALSE"
}
``
python data_parallel_export_all_tables.py .\config\LND_TBOS\parallel_LND_TBOS_rowcountdiff.json > parallel_extract_rowcountdiff_TPViolatedTripReceiptsTracker_655am.txt

