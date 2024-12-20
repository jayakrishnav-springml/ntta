CREATE PROC [dbo].[Clock] AS
IF OBJECT_ID('land.base10')<>0
drop table land.base10

IF OBJECT_ID('land.base10number')<>0
drop table land.base10number

create table land.base10 with (DISTRIBUTION = REPLICATE)
as
select	0  digit

insert into land.base10 values (1)
insert into land.base10 values (2)
insert into land.base10 values (3)
insert into land.base10 values (4)
insert into land.base10 values (5)
insert into land.base10 values (6)
insert into land.base10 values (7)
insert into land.base10 values (8)
insert into land.base10 values (9)

create table land.base10number with (DISTRIBUTION = REPLICATE)
as
select	(10000 * e.digit + 1000 * d.digit + 100 * c.digit + 10 * b.digit + a.digit) a_number
from	land.base10  a
,	land.base10  b
,	land.base10  c
,	land.base10  d
,	land.base10  e

truncate table dbo.DIM_TIME

insert into dbo.DIM_TIME
values  (
	-1
,	'(Null)'
,	'(Null)'
,	'(Null)'
,	'(Null)'
,	'(Null)'
,	'(Null)'
,	'(Null)'
,	'(Null)'
,	'(Null)'
	)

insert into dbo.DIM_TIME
select	a_number		[time_id]
,	right('00' + cast((a_number / 3600) as varchar), 2)
				[hour]
,	case (a_number / 3600)
	  when 0 then '12'
	  when 12 then '12'
	  else right('00' + cast((a_number / 3600 % 12) as varchar), 2)
	end
				[12_hour]
,	case (a_number / 43200)
	  when 0 then 'AM'
	  when 1 then 'PM'
	end
				[am_pm]
,	right('00' + cast((a_number / 1800 % 2 * 30) as varchar), 2)
				[30_minute]
,	right('00' + cast((a_number / 900 % 4 * 15) as varchar), 2)
				[15_minute]
,	right('00' + cast((a_number / 600 % 6 * 10) as varchar), 2)
				[10_minute]
,	right('00' + cast((a_number / 300 % 12 * 5) as varchar), 2)
				[5_minute]
,	right('00' + cast((a_number % 3600 / 60) as varchar), 2)
				[minute]
,	right('00' + cast((a_number % 60) as varchar), 2)
				[second]
from	land.base10number
where	a_number < 86400

IF OBJECT_ID('land.base10')<>0
drop table land.base10

IF OBJECT_ID('land.base10number')<>0
drop table land.base10number


