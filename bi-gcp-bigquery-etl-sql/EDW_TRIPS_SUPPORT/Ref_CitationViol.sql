CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.CitationViol
(
  violator_id INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  invoicenumber INT64,
  violation_id FLOAT64 NOT NULL,
  tptripid INT64,
  court_id INT64 NOT NULL,
  court_name STRING NOT NULL,
  judge STRING,
  lane_abbrev STRING NOT NULL,
  dps_citation_nbr STRING,
  citation_nbr STRING,
  appearance_date DATETIME,
  edw_updatedate DATETIME NOT NULL
)
;
