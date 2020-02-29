use master
go

select
	wtsk.session_id as "Waiting Task Session ID",
	wtsk.wait_duration_ms as "Wait Duration (ms)",
	wtsk.wait_type as "Wait Type",
	wtsk.blocking_session_id as "Blocking Session ID",
	wtsk.resource_description as "Resource Description",
	ssn.program_name as "Program Name",
	DB_NAME(rqst_sql.dbid) as "Query Database Name",
	rqst_sql.text as "Query SQL",
	rqst_plan.query_plan as "Query Plan",
	ssn.cpu_time as "CPU Time",
	ssn.memory_usage as "Memory Usage"
from sys.dm_os_waiting_tasks as wtsk
inner join sys.dm_exec_sessions as ssn on wtsk.session_id = ssn.session_id
inner join sys.dm_exec_requests as rqst on ssn.session_id = rqst.session_id
outer apply sys.dm_exec_sql_text(rqst.sql_handle) as rqst_sql
outer apply sys.dm_exec_query_plan(rqst.plan_handle) as rqst_plan
where ssn.is_user_process = 1
order by wtsk.session_id
go
