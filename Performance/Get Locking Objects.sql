use [TARGET_DATABASE]
go

select
	TranLocks.request_session_id as [Session ID]
	, ExecSessions.login_name as [Login Name]
	, DB_NAME(TranLocks.resource_database_id) as [Database Name]
	, OBJECT_NAME(DBPartitions.object_id) as [Object Name]
	, DBPartitions.object_id as [Object ID]
	, DBIndexes.name as [Index Name]
	, DBIndexes.type_desc as [Index Type]
	, TranLocks.resource_type as [Lock Resource]
	, TranLocks.request_type as [Request]
	, TranLocks.request_mode as [Lock Type]
	, TranLocks.resource_description as [Record Hash]
	, DBPartitions.hobt_id AS HoBT
	, DBTransactions.database_transaction_begin_time as [Begin Time]
	, DBTransactions.database_transaction_log_bytes_used as [Log Bytes]
    , DBTransactions.database_transaction_log_bytes_reserved as [Log Rsvd]
	, ExecSessionst.[text] as [Last T-SQL Text]
    --, QueryPlan.query_plan as [Last Plan]
from sys.dm_tran_locks as TranLocks
left outer join sys.partitions as DBPartitions on TranLocks.resource_associated_entity_id <> 0 and TranLocks.resource_associated_entity_id = DBPartitions.hobt_id
left outer join sys.indexes as DBIndexes on DBPartitions.object_id = DBIndexes.object_id
inner join sys.dm_tran_database_transactions as DBTransactions on TranLocks.request_owner_id = DBTransactions.transaction_id
inner join sys.dm_tran_session_transactions as SessionTransactions on SessionTransactions.transaction_id = DBTransactions.transaction_id
inner join sys.dm_exec_sessions as ExecSessions on ExecSessions.session_id = SessionTransactions.session_id
inner join sys.dm_exec_connections as ExecConnections on ExecConnections.session_id = SessionTransactions.session_id
left outer join sys.dm_exec_requests as ExecRequests on ExecRequests.session_id = SessionTransactions.session_id
cross apply sys.dm_exec_sql_text (ExecConnections.most_recent_sql_handle) as ExecSessionst
-- outer apply sys.dm_exec_query_plan (ExecRequests.plan_handle) as QueryPlan
where request_session_id > 50
and TranLocks.resource_type <> 'DATABASE'
and resource_database_id = DB_ID()
and request_session_id <> @@SPID
order by request_session_id
go
