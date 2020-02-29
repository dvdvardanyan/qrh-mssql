use msdb
go

--> Database Backups for all databases For Previous Week 

select
	CONVERT(char(100), SERVERPROPERTY('Servername')) as server
	, BS.database_name
	, BS.backup_start_date
	, BS.backup_finish_date
	, BS.expiration_date
	, case BS.type
		when 'D' then 'Database'
		when 'L' then 'Log'
	end as backup_type
	, BS.backup_size
	, BMF.logical_device_name
	, BMF.physical_device_name
	, BS.name as backupset_name
	, BS.description
from msdb.dbo.backupmediafamily as BMF
inner join msdb.dbo.backupset as BS on BMF.media_set_id = BS.media_set_id
where (CONVERT(datetime, BS.backup_start_date, 102) >= GETDATE() - 7)
order by cast(BS.backup_start_date as date) desc, BS.backup_start_date asc, BS.database_name asc

--> Most Recent Database Backup for Each Database 

select
	CONVERT(char(100), SERVERPROPERTY('Servername')) as server
	, BS.database_name
	, MAX(BS.backup_finish_date) as last_db_backup_date
from msdb.dbo.backupmediafamily as BMF
inner join msdb.dbo.backupset as BS on BMF.media_set_id = BS.media_set_id
where BS.type = 'D'
group by BS.database_name
order by BS.database_name

--> Most Recent Database Backup for Each Database - Detailed

select A.[Server]
	, A.last_db_backup_date
	, B.backup_start_date
	, B.expiration_date
	, B.backup_size
	, B.logical_device_name
	, B.physical_device_name
	, B.backupset_name
	, B.description
from (
	select CONVERT(char(100), SERVERPROPERTY('Servername')) as server
		, msdb.dbo.backupset.database_name
		, MAX(msdb.dbo.backupset.backup_finish_date) as last_db_backup_date
	from msdb.dbo.backupmediafamily
	inner join msdb.dbo.backupset on msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
	where msdb..backupset.type = 'D'
	group by msdb.dbo.backupset.database_name
	) as A
left join (
	select CONVERT(char(100), SERVERPROPERTY('Servername')) as server
		, msdb.dbo.backupset.database_name
		, msdb.dbo.backupset.backup_start_date
		, msdb.dbo.backupset.backup_finish_date
		, msdb.dbo.backupset.expiration_date
		, msdb.dbo.backupset.backup_size
		, msdb.dbo.backupmediafamily.logical_device_name
		, msdb.dbo.backupmediafamily.physical_device_name
		, msdb.dbo.backupset.name as backupset_name
		, msdb.dbo.backupset.description
	from msdb.dbo.backupmediafamily
	inner join msdb.dbo.backupset on msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
	where msdb..backupset.type = 'D'
	) as B on A.[server] = B.[server] and A.[database_name] = B.[database_name] and A.[last_db_backup_date] = B.[backup_finish_date]
order by A.database_name

--> Databases Missing a Data (aka Full) Back-Up Within Past 24 Hours

--> Databases with data backup over 24 hours old 
select CONVERT(char(100), SERVERPROPERTY('Servername')) as server
	, msdb.dbo.backupset.database_name
	, MAX(msdb.dbo.backupset.backup_finish_date) as last_db_backup_date
	, DATEDIFF(hh, MAX(msdb.dbo.backupset.backup_finish_date), GETDATE()) as [Backup Age (Hours)]
from msdb.dbo.backupset
where msdb.dbo.backupset.type = 'D'
group by msdb.dbo.backupset.database_name
having (MAX(msdb.dbo.backupset.backup_finish_date) < DATEADD(hh, - 24, GETDATE()))

union

--> Databases without any backup history 
select CONVERT(char(100), SERVERPROPERTY('Servername')) as server
	, master.dbo.sysdatabases.name as database_name
	, null as [Last Data Backup Date]
	, 9999 as [Backup Age (Hours)]
from master.dbo.sysdatabases
left join msdb.dbo.backupset on master.dbo.sysdatabases.name = msdb.dbo.backupset.database_name
where msdb.dbo.backupset.database_name is null and master.dbo.sysdatabases.name <> 'tempdb'
order by msdb.dbo.backupset.database_name

----------------------------------------------------------------------------------------------------

use msdb
go

-- Get Backup History for required database
select top 100 s.database_name
	, m.physical_device_name
	, CAST(CAST(s.backup_size / 1000000 as int) as varchar(14)) + ' ' + 'MB' as bkSize
	, CAST(DATEDIFF(second, s.backup_start_date, s.backup_finish_date) as varchar(4)) + ' ' + 'Seconds' TimeTaken
	, s.backup_start_date
	, CAST(s.first_lsn as varchar(50)) as first_lsn
	, CAST(s.last_lsn as varchar(50)) as last_lsn
	, case s.[type]
		when 'D'
			then 'Full'
		when 'I'
			then 'Differential'
		when 'L'
			then 'Transaction Log'
		end as BackupType
	, s.server_name
	, s.recovery_model
from msdb.dbo.backupset s
inner join msdb.dbo.backupmediafamily m on s.media_set_id = m.media_set_id
where s.database_name = 'GEMS'
order by backup_start_date desc
	, backup_finish_date
go
