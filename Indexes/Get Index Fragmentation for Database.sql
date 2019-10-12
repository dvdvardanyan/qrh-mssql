use [YOUR_DB_HERE]
go

select
	
	obj.name as "Table Name"
	, inx.name as "Index Name"
	, inx.type as "Index Type Code"
	, inx.type_desc as "Index Type"
	, inx.fill_factor as "Fill Factor"

	, ips.index_depth as "Index Depth"
	, round(ips.avg_fragmentation_in_percent, 2) as "Fragmentation (%)"
	, ips.page_count as "Page Count"
	, cast(cast(ips.page_count * 8 as decimal(10, 2)) / 1024 as decimal(10, 2)) as "Space Used (MB)"
	, ips.forwarded_record_count as "Forwarded Record Count"

from sys.dm_db_index_physical_stats(DB_ID(), null, null, null, null) as ips
inner join sys.indexes as inx on ips.object_id = inx.object_id and ips.index_id = inx.index_id
inner join sys.objects as obj on inx.object_id = obj.object_id
where ips.page_count > 1000
go
