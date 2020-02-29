use [TARGET_DATABASE]
go

select
	obj.object_id
	, obj.name
	, sts.stats_id
	, sts.name
	, sts.auto_created
	, sts.user_created
	, sts.no_recompute
	, sts.has_filter
	, sts.filter_definition
	, sts.is_temporary
	, col.name
	, sts_prop.rows
	, sts_prop.rows_sampled
	, sts_prop.modification_counter
	, sts_prop.last_updated
from sys.objects as obj
inner join sys.stats as sts on obj.object_id = sts.object_id
inner join sys.stats_columns as stcol on sts.object_id = stcol.object_id and sts.stats_id = stcol.stats_id
inner join sys.columns as col on stcol.object_id = col.object_id and stcol.column_id = col.column_id
outer apply sys.dm_db_stats_properties(sts.object_id, sts.stats_id) as sts_prop
where obj.name = '[TARGET_TABLE]'
go
