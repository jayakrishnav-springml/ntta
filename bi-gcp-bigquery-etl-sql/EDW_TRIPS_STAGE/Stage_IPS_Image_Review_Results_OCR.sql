--Created this ddls using the table created with sp run

CREATE TABLE IF NOT EXISTS EDW_TRIPS_Stage.IPS_Image_Review_Results_OCR
(
imagereviewresultid	INTEGER,
ipstransactionid INTEGER,
tptripid INTEGER,
manuallyreviewedflag INTEGER,
createduser STRING,
createddate DATETIME,
updateduser STRING,	
updateddate DATETIME,	
edw_updatedate DATETIME,
) cluster by tptripid;