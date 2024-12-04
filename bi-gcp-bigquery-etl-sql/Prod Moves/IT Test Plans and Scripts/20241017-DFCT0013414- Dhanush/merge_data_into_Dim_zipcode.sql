MERGE `EDW_TRIPS.Dim_ZipCode` z
Using `prj-ntta-ops-bi-devt-svc-01.EDW_TRIPS_SUPPORT.Ref_Zipcode_Gis` r
on z.zipcode=cast(r.zipcode as String)
when matched then
update set
z.city=r.city,
z.county=r.county,
z.state=r.state,
z.edw_updatedate=current_datetime() 
when not matched then
Insert(zipcode,city,county,state,edw_updatedate)
Values(cast(r.zipcode as STRING),
r.city,
r.county,
r.state,
current_datetime() );