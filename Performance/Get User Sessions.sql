use master
go

select
	ssn.session_id as "Session ID",
	ssn.login_time as "Login Time",
	ssn.host_name as "Host Name",
	ssn.login_name as "Login Name",
	ssn.status as "Status",
	ssn.cpu_time as "CPU Time",
	ssn.memory_usage as "Memory Usage"
	ssn.total_elapsed_time / 1000 as "Total Elapsed Time (sec)",
	ssn.last_request_start_time as "Last Request Start Time",
	ssn.last_request_end_time as "Last Request End Time",
	ssn.reads as "Reads",
	ssn.writes as "Writes",
	DB_NAME(ssn.database_id) as "Session DB Name",
	ssn.open_transaction_count as "Open Tran. Count",
	con_sql.text as "Most Recent Connection SQL",
	DB_NAME(rqst.database_id) as "Request DB Name",
	USER_NAME(rqst.user_id) as "Request User Name",
	rqst.blocking_session_id as "Blocking Session ID",
	rqst.wait_type as "Wait Type",
	rqst.wait_time as "Wait Time",
	rqst.wait_resource as "Wait Resource"
	--, 'Sessions: -> ', ssn.*,
	--, 'Connections: -> ', con.*,
	--, 'Requests: -> ', rqst.*
from sys.dm_exec_sessions as ssn
left outer join sys.dm_exec_connections as con on ssn.session_id = con.session_id
left outer join sys.dm_exec_requests as rqst on con.connection_id = rqst.connection_id
cross apply sys.dm_exec_sql_text(con.most_recent_sql_handle) AS con_sql
where ssn.is_user_process = 1
order by ssn.session_id
go
