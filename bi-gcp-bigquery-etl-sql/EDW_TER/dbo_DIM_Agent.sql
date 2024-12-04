CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Agent
(
  agentid INT64 NOT NULL,
  agent STRING NOT NULL,
  insert_datetime DATETIME NOT NULL
)
cluster by agentid
;
