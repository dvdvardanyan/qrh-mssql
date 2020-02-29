use [YOUR_DB_NAME]
go

declare @TableName varchar(128) = 'YOUR_TABLE_NAME';

--------------------------------------------------------------------------------------------------------------

set nocount on;

exec('select count(*) from ' + @TableName)
exec('select top 3 * from ' + @TableName)

declare @DB_ID int = db_id();

if(exists(select * from sys.views as VW where name = @TableName))
begin
	select name as "Object Name", type_desc as "Object Type"
	from sys.tables as TAB where name = @TableName
	union all
	select name as "Object Name", type_desc as "Object Type"
	from sys.views as VW where name = @TableName
end;

if(object_id('tempdb..#index_info') is not null) drop table #index_info

select
	
	t.object_id
	, s.name as schema_name
	, t.name as table_name
	, i.index_id
	, i.name as index_name
	, i.type as index_type_code
	, i.type_desc as index_type_desc
	, iif(i.is_primary_key = 1, 'Y', '') as is_primary
	, iif(i.is_unique = 1, 'Y', '') as is_unique
	, iif(i.is_unique_constraint = 1, 'Y', '') as is_unique_constraint
	, i.fill_factor as index_fill_factor

	, stuff((
		select
			', ' + COL.name as [text()]
		from sys.index_columns as ic		
		inner join sys.columns as COL
		on ic.object_id = COL.object_id and ic.column_id = COL.column_id
		where i.object_id = ic.object_id and i.index_id = ic.index_id and ic.is_included_column = 0
		order by ic.index_column_id
		for xml path('')
	), 1, 2, '') 
	--+ iif(i.type = 1 and i.is_primary_key != 1 and i.is_unique != 1, ', UNIQUEFIER', '')
	as indexed_columns

	, (
		select
			'_K' + cast(COL.column_id as varchar(10)) as [text()]
		from sys.index_columns as ic		
		inner join sys.columns as COL
		on ic.object_id = COL.object_id and ic.column_id = COL.column_id
		where i.object_id = ic.object_id and i.index_id = ic.index_id and ic.is_included_column = 0
		order by ic.index_column_id
		for xml path('')
	) as indexed_column_ids

	, stuff((
		select
			', ' + COL.name as [text()]
		from sys.index_columns as ic		
		inner join sys.columns as COL
		on ic.object_id = COL.object_id and ic.column_id = COL.column_id
		where i.object_id = ic.object_id and i.index_id = ic.index_id and ic.is_included_column = 1
		order by ic.index_column_id
		for xml path('')
	), 1, 2, '') as included_columns

	, (
		select
			'_' + cast(COL.column_id as varchar(10)) as [text()]
		from sys.index_columns as ic		
		inner join sys.columns as COL
		on ic.object_id = COL.object_id and ic.column_id = COL.column_id
		where i.object_id = ic.object_id and i.index_id = ic.index_id and ic.is_included_column = 1
		order by ic.index_column_id
		for xml path('')
	) as included_column_ids

	, p.rows as rows_in_index
	, a.type_desc as page_type_desc
	, a.total_pages as pages_count
	, cast(cast(a.total_pages * 8 as decimal(10, 2)) / 1024 as decimal(10, 2)) as TotalSpaceInMB

	--, ius.user_seeks
	--, ius.user_scans
	--, ius.user_lookups
	--, ius.user_updates
	--, ius.last_user_seek
	--, ius.last_system_scan
	--, ius.last_user_lookup
	--, ius.last_user_update

	, ips.*
	--, ios.*
--into #index_info
from sys.tables as t
inner join sys.schemas as s on t.schema_id = s.schema_id
inner join sys.indexes as i on t.object_id = i.object_id
inner join sys.partitions as p on i.object_id = p.object_id and i.index_id = p.index_id
inner join sys.allocation_units as a on p.partition_id = a.container_id
--inner join sys.data_spaces as DS on i.data_space_id = DS.data_space_id
--left outer join SYS.DM_DB_INDEX_USAGE_STATS as ius on IX.object_id = ius.object_id and IX.index_id = ius.index_id and ius.database_id = @DB_ID
cross apply sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, null, 'DETAILED') as ips
--cross apply sys.dm_db_index_operational_stats(DB_ID(), i.object_id, i.index_id, null) as ios
where t.name = @TableName
order by i.index_id;
go
