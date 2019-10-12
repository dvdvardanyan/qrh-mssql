use [YOUR_DB_HERE]
go

--> Index Utilization

select
	obj.object_id
	, obj.name
	, ind.index_id
	, ind.name
	, ind.is_disabled
	, usg.user_seeks
	, usg.last_user_seek
	, usg.user_scans
	, usg.last_system_scan
	, usg.user_lookups
	, usg.last_user_lookup
	, usg.user_updates
	, usg.last_user_update
from sys.dm_db_index_usage_stats as usg
inner join sys.objects as obj on usg.object_id = obj.object_id
inner join sys.indexes as ind on usg.object_id = ind.object_id and usg.index_id = ind.index_id
where ind.is_primary_key = 0 and ind.type > 1
order by usg.user_seeks + usg.user_scans + usg.user_lookups asc, usg.user_updates desc
go
