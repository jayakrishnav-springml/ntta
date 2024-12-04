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

- **Deployments**: This folder contains deployment scripts to deploy all workflows present in the subfolders. For more details, please refer to the README.md inside the folder.

- **Parent_Workflows**: Here, you'll find three workflows: `LND_TBOS_Bankruptcy`,`LND_TBOS_Chargeback` and `LND_TBOS_Cheque_Payments_File_Export`
  - `LND_TBOS_Bankruptcy`: This workflow calls the cloud function `bankruptcy-import`
  - `LND_TBOS_Chargeback`: This workflow calls the cloud function `chargeback-import-export`
  - `LND_TBOS_Cheque_Payments_File_Export`: This workflow calls the SP LND_TBOS.Cheque_Payments_File_Export() and exports the result to GCS.

