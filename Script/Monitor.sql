/* Formatted on 28/Dec/15 5:11:39 PM (QP5 v5.252.13127.32847) */
/* Available free space (MB)
This component monitor returns the available free space of the database in MB. This value should be as high as possible.*/
SELECT  SUM(bytes/1024/1024) "Total_free_space, MB"
FROM dba_free_space;

/* Buffer cache hit ratio (%)
This component monitor returns the percentage of pages found in the buffer cache without having to read from the disk.
This ratio should exceed 90%, and ideally be over 99%. If your Buffer Cache Hit Ratio is lower than 90%, you should consider adding more RAM, if possible.
A higher ratio value returned indicates improved performance by your Oracle Server. 
Note: If your database is very large, you may not be able to get close to 99%, even if you put the maximum amount of RAM in your server.*/
SELECT ROUND(((1 -
 (SUM(DECODE(name,'physical reads cache', VALUE,0))/
 (SUM(DECODE(name, 'db block gets from cache', VALUE,0))+
    (SUM(DECODE(name, 'consistent gets from cache',VALUE, 0))))))*100),2)
     "Buffer Cache Hit Ratio, %"
FROM v$sysstat;

/* Dictionary cache hit ratio (%)
This component monitor returns the ratio of dictionary cache hits to total requests
•	70% or above. 99% would be ideal. 
•	If the ratio is below 70%, increase the value of the initialization parameter, SHARED_POOL_SIZE.
It is recommended that the SHARED_POOL_SIZE parameter be at least 4 MB. 
o	Large databases may require a shared pool of at least 10 MB. 
Note: Increasing the SHARED_POOL_SIZE parameter will increase the size of the System Global Area (SGA) */
SELECT rest.hr "dictionary cache hit ratio, %"
FROM ( SELECT  SUM(GETS), SUM(GETMISSES),
 ROUND((1 - (SUM(GETMISSES) / SUM(GETS))) * 100,2) hr
 FROM v$rowcache ) rest;

/* Library cache hit ratio (%)
This component monitor returns the percentage of Pin requests that result in hits. 
•	PINS - Defined as the number of times an item in the library cache was executed.
•	PINHITS - Defined as the number of times an item was executed without reloads.

The library cache stores the executable form of recently referenced SQL and PL/SQL code.
Ideally, the value of this component monitor should be greater than 95%. If the value is less than 95%

•	Increase the SHARED_POOL_SIZE parameter.
•	The CURSOR_SHARING parameter may need to be set to FORCE.
•	Increase the size of the SHARED_POOL_RESERVED_SIZE parameter.
•	Sharing of SQL, PLSQL or JAVA code may be inefficient.
•	Use of bind variables may be insufficient. */
SELECT rest.hit_ratio "library cache hit ratio, %"
FROM (
 SELECT  SUM(PINS) Executions,
 SUM(RELOADS) cache_misses,
 ROUND((1 - (SUM(RELOADS) / SUM(PINS))) * 100,2) hit_ratio
  FROM  v$librarycache ) rest;

/* Available free memory (MB)
This component monitor returns the free memory in MB, of all SGA pools. This value should be as high as possible. */
SELECT SUM(rt.fm) "available free memory, MB"
FROM (
  SELECT name, bytes/1024/1024 fm
         FROM v$sgastat
     WHERE name='free memory') rt;

/* Number of connected users
This component monitor returns the number of currently connected users. */
SELECT COUNT(users.username) "number of connected users"
FROM (
  SELECT s.username
  FROM v$session s
  WHERE TYPE = 'USER') users;

/* Total short table scans
This component monitor returns the total number of full table scans that were performed on tables
	having less than five Oracle data blocks since database instance startup. 
Note: It is generally more efficient to perform full table scans on short tables rather than access the data using indexes. */
SELECT VALUE "Total_short_table_scans" FROM v$sysstat WHERE name LIKE 'table scans (short tables)';

/* Total long table scans
This component monitor returns the total number of full table scans done on tables
	containing five or more Oracle data blocks since database instance startup. 
Note: It may be advantageous to access long tables using indexes. */
SELECT VALUE "Total_long_table_scans" FROM v$sysstat WHERE name LIKE 'table scans (long tables)';

/* User transactions
This component monitor returns the total number of users’ transactions. */
SELECT VALUE "User_transactions" FROM v$sysstat WHERE name LIKE 'user commits';

/* Disk sort operations
This component monitor returns the number of sort operations that require at least one disk write.
This value should be as low as possible. 
Note: Sorts that require continual reading and writing to disk can consume a great deal of resources.
If this monitor returns a high value, consider increasing the size of the initialization parameter, SORT_AREA_SIZE. */
SELECT VALUE "Disk_sort_operations" FROM v$sysstat WHERE name LIKE 'sorts (disk)';

/* Memory sort operations
This component monitor returns the number of sort operations that were performed completely in memory
meaning no disk writes were required. */
SELECT VALUE "Memory_sort_operations" FROM v$sysstat WHERE name LIKE 'sorts (memory)';

/* User rollbacks
This component monitor returns the number of times that users manually issued the Rollback statement.
Use of the Rollback statement may also indicate an error occurred during a user's transactions.
This value should be as low as possible. */
SELECT VALUE "User_rollbacks" FROM v$sysstat WHERE name LIKE 'user rollbacks';

/* Free Space in Tablespace (%) */
SELECT NVL(ROUND(SUM(fs.bytes) * 100 / df.bytes),1) "% Free", df.tablespace_name "Tablespace"
FROM dba_free_space fs,
       (SELECT tablespace_name,SUM(bytes) bytes
        FROM dba_data_files
        GROUP BY tablespace_name) df
WHERE fs.tablespace_name (+)  = df.tablespace_name
 AND fs.tablespace_name = 'DM_AUDITTRAIL_S_IDX'
GROUP BY df.tablespace_name,df.bytes;

/* High Watermark on Temp */
SELECT ROUND(100*(SELECT SUM(BYTES_FREE)
FROM V$TEMP_SPACE_HEADER
WHERE tablespace_name IN
 (SELECT property_value FROM database_properties WHERE property_name='DEFAULT_TEMP_TABLESPACE') ) /
          (SELECT SUM(BYTES) FROM DBA_TEMP_FILES WHERE tablespace_name IN (
             SELECT property_value FROM database_properties WHERE property_name='DEFAULT_TEMP_TABLESPACE')),1)  FREE
FROM DUAL;

/* Active session */
SELECT COUNT(a.username), a.username FROM v$session a, v$sqlarea b
WHERE a.sql_hash_value = b.hash_value
 AND a.sql_address = b.address
 AND a.username IS NOT NULL 
 GROUP BY a.username;