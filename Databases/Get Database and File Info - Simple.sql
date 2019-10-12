use master
go

with DatabaseInfo as
(
	select
		db.database_id
		, db.name
		, db.compatibility_level
		, db.user_access_desc
		, db.state_desc
		, db.snapshot_isolation_state_desc
		, db.recovery_model_desc
		, db.page_verify_option_desc
		, db.is_db_chaining_on
		, db.log_reuse_wait_desc
		, db.is_cdc_enabled
		, db.is_read_only
	from sys.databases as db
	where db.database_id not in (1, 2, 3, 4)
)
, DatabaseFileInfo as
(
	select

		mf.database_id

		, max(case when mf.type = 0 then mf.size else null end) as data_size
		, max(case when mf.type = 0 then mf.physical_name else null end) as data_physical_name

		, max(case when mf.type = 1 then mf.size else null end) as log_size
		, max(case when mf.type = 1 then mf.physical_name else null end) as log_physical_name

	from DatabaseInfo as di
	inner join sys.master_files as mf on di.database_id = mf.database_id
	group by mf.database_id
)
select
	di.database_id as "Database Id"
	, di.name as "Database Name"
	--, case when di.is_read_only = 1 then 'Read Only' else '' end as "State"
	--, di.compatibility_level as "Compatibility Level"
	--, di.user_access_desc as "User Access"
	--, di.state_desc as "State"
	--, di.snapshot_isolation_state_desc as "Snapshot Isolation"
	, di.recovery_model_desc as "Recovery Model"
	--, di.page_verify_option_desc as "Page Verify"
	--, di.is_db_chaining_on as "DB Chaining"
	--, di.log_reuse_wait_desc as "Log Reuse Wait"
	--, is_cdc_enabled as "CDC Enabled"

	--, SUBSTRING(dfi.data_physical_name, 1, 1) as "Data File Drive"
	--, dfi.data_physical_name as "Data File Path"
	, cast((dfi.data_size * 8) as decimal(18, 2)) / 1024 as "Data File Size (MB)"
	
	--, SUBSTRING(dfi.log_physical_name, 1, 1) as "Log File Drive"
	--, dfi.log_physical_name as "Log File Path"
	, cast((dfi.log_size * 8) as decimal(18, 2)) / 1024 as "Log File Size (MB)"

	--, (dfi.data_size + dfi.log_size) * 8 / 1024 as "Total Database Size (MB)"
	
from DatabaseInfo as di
inner join DatabaseFileInfo as dfi on di.database_id = dfi.database_id
order by di.name
go
