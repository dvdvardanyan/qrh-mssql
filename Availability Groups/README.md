# Simple Scripts

Remove database from availability group:

```
alter database [DATABASE_NAME] set HADR OFF;
```

Add database to availability group:

```
alter database [DATABASE_NAME] set HADR AVAILABILITY GROUP = [AG_NAME];
alter database [DATABASE_NAME] set HADR RESUME;
```