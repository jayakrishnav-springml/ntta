
1.deploy_tables_<dataset>.sh
	
	Creates tables in BQ by executing scripts per dataset
	Pass project_id as parameter - sh deploy_tables_<dataset>.sh <project_id>

2.deploy_views_<dataset>.sh

	Creates views in BQ by executing scripts per dataset
	Pass project_id as parameter - sh deploy_views_<dataset>.sh <project_id>
	
3.deploy_storedprocedures.sh

	Creates Stored Procedures in BQ for all datasets
	Pass project_id as parameter - sh deploy_storedprocedures.sh <project_id>
	To create for one particular dataset, comment out the TYPE variable for the remaining datasets

4.deploy_tables_all_datasets.sh

	Creates tables in BQ for all datasets
	Pass project_id as parameter - sh deploy_tables_all_datasets.sh <project_id>

5.deploy_views_all_datasets.sh

	Creates views in BQ for all datasets
	Pass project_id as parameter - sh deploy_views_all_datasets.sh <project_id>

	