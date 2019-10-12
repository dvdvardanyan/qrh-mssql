use [YOUR_DB_HERE]
go

--> Missing Indexes

select
	obj.name
	, mid.equality_columns
	, mid.inequality_columns
	, mid.included_columns
	, stat.unique_compiles
	, stat.user_seeks
	, stat.last_user_seek
	, stat.user_scans
	, stat.last_user_scan
	, stat.avg_total_user_cost
	, stat.avg_user_impact
from sys.dm_db_missing_index_details as mid
inner join sys.objects as obj on mid.object_id = obj.object_id
inner join sys.dm_db_missing_index_groups as mid_grp on mid.index_handle = mid_grp.index_handle
inner join sys.dm_db_missing_index_group_stats as stat on mid_grp.index_group_handle = stat.group_handle
where mid.database_id = DB_ID()
order by stat.user_seeks desc, stat.avg_user_impact desc
--order by stat.avg_total_user_cost desc, stat.avg_user_impact desc
go
