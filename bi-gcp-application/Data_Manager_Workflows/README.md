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


# Workflows 

This folder contains various subfolders, each with specific descriptions detailed below.

## Description

- **9001**: This folder contains child workflows for all Dim and Fact Stored Procedures within the `9001` Data Manager package. It includes two parent workflows: `EDW_TRIPS_Dim_Daily_Run` and `EDW_TRIPS_Fact_Daily_Run`, which internally call respective Dim or Fact Stored Procedures.

- **9005**: This folder contains child workflows for all Stored Procedures within the `9005` Data Manager package. It also includes a parent workflow named `EDW_TRIPS_GL_Daily_Run`, which internally calls child workflows.

- **9012**: Here, you'll find child workflows for all Stored Procedures within the `9012` Data Manager package. It also includes a parent workflow named `EDW_TRIPS_Bubble_ETL_Daily_Run`, which internally calls child workflows.

- **9013**: This folder contains child workflows for all Stored Procedures within the `9013` Data Manager package. It also includes a parent workflow named `EDW_TRIPS_Item_90_ETL_Daily_Run`, which internally calls child workflows.

- **CDC**: In this folder, you'll find child workflows that call the CDC Stored Procedure and check for errors after the CDC process is completed by processing the table `LND_TBOS_SUPPORT.CDC_BATCH_LOAD_TABLE`.

- **Deployments**: This folder contains deployment scripts to deploy all workflows present in the subfolders. For more details, please refer to the README.md inside the folder.

- **Parent_Workflows**: Here, you'll find two workflows: `EDW_TRIPS_Daily_Run` and `EDW_TRIPS_Finance_Gl_Daily_Run`.
  - `EDW_TRIPS_Daily_Run`: This workflow calls the parent workflows in the following order: CDC child workflow -> EDW_TRIPS_Dim_Daily_Run -> EDW_TRIPS_Bubble_ETL_Daily_Run -> EDW_TRIPS_Fact_Daily_Run -> EDW_TRIPS_Item_90_ETL_Daily_Run.
  - `EDW_TRIPS_Finance_Gl_Daily_Run`: This workflow calls the parent workflows in the following order: CDC child workflow -> EDW_TRIPS_GL_Daily_Run.
