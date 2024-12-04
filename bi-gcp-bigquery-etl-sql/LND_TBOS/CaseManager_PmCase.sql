CREATE TABLE IF NOT EXISTS LND_TBOS.CaseManager_PmCase
(
  caseid INT64 NOT NULL,
  casetypeid INT64 NOT NULL,
  casesource INT64 NOT NULL,
  casetitle STRING NOT NULL,
  datereported DATETIME NOT NULL,
  icnid INT64,
  priorityid INT64,
  statusid INT64,
  currentcasetypeactivityid INT64,
  assignedto INT64,
  jsondata STRING,
  customerid INT64,
  duedate DATETIME,
  slaexpirydate DATETIME,
  remarks STRING,
  createduser STRING NOT NULL,
  createddate DATETIME NOT NULL,
  updateduser STRING,
  updateddate DATETIME,
  currentactivitystatusid INT64,
  rolecasetypeactcusttypestatusid INT64,
  closurereasoncode INT64,
  channelid INT64,
  ismanual INT64 NOT NULL,
  caseapprovalnotification INT64,
  casetypecomment STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY 
caseid
;