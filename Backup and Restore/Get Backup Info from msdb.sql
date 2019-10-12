use msdb
go

with DatabaseFile as
(
	select bf.backup_set_id, sum(bf.file_size) as files_size
	from msdb.dbo.backupfile as bf
	group by bf.backup_set_id
)
select
	
	bset.database_name as "Database Name"
	, cast(round(df.files_size / 1024 / 1024 / 1024, 2) as decimal(10, 2)) as "Combined Files Size (GB)"
	, bset.backup_start_date as "Start Date"
	, bset.backup_finish_date as "End Date"
	, convert(varchar(30), bset.backup_finish_date - bset.backup_start_date, 108) as "Duration"
	, case bset.type
		when 'D' then 'Database'
		when 'I' then 'Differential database'
		when 'L' then 'Log'
		when 'F' then 'File or filegroup'
		when 'G' then 'Differential file'
		when 'P' then 'Partial'
		when 'Q' then 'Differential partial'
		else 'Unknown'
	end as "Backup Type"
	, cast(round(bset.backup_size / 1024 / 1024 / 1024, 2) as decimal(10, 2)) as "Backup Size (GB)"
	, cast(round(bset.compressed_backup_size / 1024 / 1024 / 1024, 2) as decimal(10, 2)) as "Compressed Backup Size (GB)"
	, bset.recovery_model as "Recovery Model"
	, iif(bset.is_copy_only = 0, 'No', 'Yes') as "Is Copy Only"
	, iif(bset.is_password_protected = 0, 'No', 'Yes') as "Is Password Protected"

	, media.physical_device_name as "Backup File Name"
	, case media.device_type
		when 2 then 'Disk'
		when 5 then 'Tape'
		when 7 then 'Virtual device'
		when 9 then 'Azure Storage'
		when 105 then 'A permanent backup device'
		else 'Unknown'
	end as "Device Type"

from msdb.sys.databases as db
inner join msdb.dbo.backupset as bset on db.name = bset.database_name
inner join msdb.dbo.backupmediafamily as media on bset.media_set_id = media.media_set_id
inner join DatabaseFile as df on bset.backup_set_id = df.backup_set_id
order by bset.database_name, bset.backup_start_date desc
go
