use master
go

select
	rqst.session_id as "SPID",
	ssn.host_name as "Session Host Name",
	ssn.login_name as "Session Login Name",
	con.auth_scheme as "Authentication Scheme",
	rqst.start_time as RequestStartTime,
	rqst.status as RequestStatus,
	rqst.command as Command,
	db_name(rqst.database_id) as "Request Database Name",
	user_name(rqst.user_id) as "Request User Name",
	rqst.blocking_session_id as "Request Blocking SPID",
	rqst.wait_type as "Request Wait Type",
	rqst.wait_resource as "Request Wait Resource",
	rqst.wait_time as "Request Wait Time",
	rqst.cpu_time as CPU,
	ssn.reads as "Reads",
	ssn.writes as "Writes",
	ssn.logical_reads as "Logical Reads",
	rqst_sql.text as "Request SQL",
	con_sql.text as "Connection SQL"
	--, 'Sessions: -> ' , ssn.*
	--, 'Connections: -> ' , con.*
	--, 'Requests: -> ' , rqst.*
from sys.dm_exec_requests as rqst
inner join sys.dm_exec_connections as con
on rqst.connection_id = con.connection_id
inner join sys.dm_exec_sessions as ssn
on rqst.session_id = ssn.session_id
CROSS APPLY sys.dm_exec_sql_text(rqst.sql_handle) AS rqst_sql
CROSS APPLY sys.dm_exec_sql_text(con.most_recent_sql_handle) AS con_sql
order by rqst.session_id asc
go
