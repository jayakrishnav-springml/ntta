CREATE TABLE IF NOT EXISTS EDW_TER.Transaction_Types
(
  trans_type_id NUMERIC(29),
  trans_type_descr STRING,
  insert_date DATETIME NOT NULL
)
cluster by trans_type_id
;