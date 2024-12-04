set GOOGLE_APPLICATION_CREDENTIALS=D:\GCP\ServiceAccountKeys\prod\prj-ntta-ops-bi-prod-svc-01-73b52dc8902e.json
rem TIMEOUT /T 15
cmd /c gcloud config set project prj-ntta-ops-bi-prod-svc-01
cmd /c gcloud auth activate-service-account svc-prj-ntta-bi-data-transfer@prj-ntta-ops-bi-prod-svc-01.iam.gserviceaccount.com --key-file=D:\GCP\ServiceAccountKeys\prod\prj-ntta-ops-bi-prod-svc-01-73b52dc8902e.json
rem TIMEOUT /T 60
echo "this is after gcloud"
rem TIMEOUT /T 30
E:
cd E:\GIT-prod-gcp-application\bi-gcp-application\Data_Extraction
echo ---------------------------------------------------------------------------- > InvoiceDetail_Tunned_PROD.log 2>&1
set _current_datetime=%date%_%time%
echo %_current_datetime% >> InvoiceDetail_Tunned_PROD.log 2>&1
python data_parallel_export_all_tables.py .\config\TBOSRPT\PROD\InvoiceDetail_Tunned.json [] >> InvoiceDetail_Tunned_PROD.log 2>&1
