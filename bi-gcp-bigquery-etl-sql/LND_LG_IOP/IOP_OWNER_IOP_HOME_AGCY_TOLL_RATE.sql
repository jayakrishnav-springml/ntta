--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Iop_Home_Agcy_Toll_Rate
(
  agcy_id FLOAT64 NOT NULL,
  rev_type STRING NOT NULL,
  last_update_type STRING DEFAULT 'I' NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
