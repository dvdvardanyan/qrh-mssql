use master
go

select
	session_id as SPID
	, command
	, a.text AS Query
	, start_time
	, percent_complete
	, dateadd(second, estimated_completion_time/1000, getdate()) as estimated_completion_time
from sys.dm_exec_requests as r
cross apply sys.dm_exec_sql_text(r.sql_handle) as a
where r.command like '%DBCC%'
go
