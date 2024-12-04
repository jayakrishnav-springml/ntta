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

- **5001**: This folder contains child workflows for all Dim and Fact Stored Procedures within the `5001` Data Manager package. It includes one parent workflows: `EDW_NAGIOS_Dim_Fact_Run` which internally call respective Dim or Fact Stored Procedures.

- **Deployments**: This folder contains deployment scripts to deploy all workflows present in the subfolders. For more details, please refer to the README.md inside the folder.

- **Parent_Workflows**: Here, you'll find two workflows: `EDW_NAGIOS_Daily_Run`
  - `EDW_NAGIOS_Daily_Run`: This workflow calls the parent workflows in the following order: CDC child workflows -> EDW_NAGIOS_Dim_Fact_Run ->

