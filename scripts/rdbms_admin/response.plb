CREATE TABLE dbsnmp.mgmt_snapshot(
       instance_number 		NUMBER NOT NULL,
       snap_id         		NUMBER NOT NULL,
       capture_time    		DATE NOT NULL,
       db_time         		NUMBER,
       cpu_time        		NUMBER,
       application_wait_time	NUMBER,
       cluster_wait_time	NUMBER,
       user_io_wait_time	NUMBER,
       concurrency_wait_time	NUMBER,
       constraint inst_num_key unique (instance_number)
) NOLOGGING;
CREATE TABLE dbsnmp.mgmt_snapshot_sql(
       snap_id         NUMBER NOT NULL,
       sql_id          VARCHAR2(13),
       hash_value      NUMBER NOT NULL,
       child_number    NUMBER NOT NULL,
       elapsed_time    NUMBER NOT NULL,
       executions      NUMBER NOT NULL) NOLOGGING;
CREATE TABLE dbsnmp.mgmt_baseline(
       instance_number 		NUMBER NOT NULL,
       capture_time    		DATE NOT NULL,
       prev_capture_time 	DATE NOT NULL,
       db_time         		NUMBER,
       cpu_time                 NUMBER,
       application_wait_time    NUMBER,
       cluster_wait_time        NUMBER,
       user_io_wait_time        NUMBER,
       concurrency_wait_time    NUMBER);
CREATE TABLE dbsnmp.mgmt_baseline_sql(
       instance_number NUMBER NOT NULL,
       sql_text        VARCHAR2(1000),
       sql_id          VARCHAR2(13),
       hash_value      NUMBER NOT NULL,
       executions      NUMBER,
       elapsed_time    NUMBER,
       t_per_exec      NUMBER NOT NULL);
CREATE TABLE dbsnmp.mgmt_capture(
       instance_number 		NUMBER NOT NULL,
       capture_id      		NUMBER NOT NULL,
       capture_time    		DATE NOT NULL,
       db_time         		NUMBER,
       cpu_time                 NUMBER,
       application_wait_time    NUMBER,
       cluster_wait_time        NUMBER,
       user_io_wait_time        NUMBER,
       concurrency_wait_time    NUMBER);
CREATE TABLE dbsnmp.mgmt_capture_sql(
       capture_id      NUMBER NOT NULL,
       sql_id          VARCHAR2(13),
       hash_value      NUMBER NOT NULL,
       elapsed_time    NUMBER,
       executions      NUMBER);
CREATE TABLE dbsnmp.mgmt_response_config(
       instance_number NUMBER NOT NULL,
       startup_time    DATE);
CREATE TABLE dbsnmp.mgmt_latest(
       instance_number 		NUMBER NOT NULL,
       capture_id      		NUMBER NOT NULL,
       capture_time    		DATE NOT NULL,
       prev_capture_time 	DATE NOT NULL,
       sql_response_time 	NUMBER NOT NULL,
       adjusted_sql_response_time NUMBER NOT NULL,
       baseline_sql_response_time NUMBER NOT NULL,
       relative_sql_response_time NUMBER NOT NULL,
       db_time         		NUMBER,
       cpu_time                 NUMBER,
       application_wait_time    NUMBER,
       cluster_wait_time        NUMBER,
       user_io_wait_time        NUMBER,
       concurrency_wait_time    NUMBER);
CREATE TABLE dbsnmp.mgmt_latest_sql(
       capture_id      NUMBER NOT NULL,
       sql_id          VARCHAR2(13),
       hash_value      NUMBER NOT NULL,
       executions      NUMBER,
       elapsed_time    NUMBER,
       t_per_exec      NUMBER,
       adjusted_elapsed_time NUMBER);
CREATE TABLE dbsnmp.mgmt_history(
       instance_number 		NUMBER NOT NULL,
       capture_id      		NUMBER NOT NULL,
       capture_time    		DATE NOT NULL,
       prev_capture_time 	DATE NOT NULL,
       sql_response_time 	NUMBER NOT NULL,
       adjusted_sql_response_time NUMBER NOT NULL,
       baseline_sql_response_time NUMBER NOT NULL,
       relative_sql_response_time NUMBER NOT NULL,
       db_time         		NUMBER,
       cpu_time                 NUMBER,
       application_wait_time    NUMBER,
       cluster_wait_time        NUMBER,
       user_io_wait_time        NUMBER,
       concurrency_wait_time    NUMBER);
CREATE TABLE dbsnmp.mgmt_history_sql(
       capture_id       NUMBER NOT NULL,
       sql_id           VARCHAR2(13),
       hash_value       NUMBER NOT NULL,
       executions       NUMBER,
       elapsed_time     NUMBER,
       t_per_exec       NUMBER,
       adjusted_elapsed_time NUMBER);
CREATE GLOBAL TEMPORARY TABLE dbsnmp.mgmt_tempt_sql(
       sql_id          VARCHAR2(13),
       hash_value      NUMBER NOT NULL,
       elapsed_time    NUMBER NOT NULL,
       executions      NUMBER NOT NULL)
       ON COMMIT DELETE ROWS;
CREATE sequence dbsnmp.mgmt_response_capture_id 
       START WITH 1 INCREMENT BY 1 ORDER;
CREATE sequence dbsnmp.mgmt_response_snapshot_id 
       START WITH 1 INCREMENT BY 1 ORDER;
CREATE OR REPLACE VIEW dbsnmp.mgmt_response_baseline AS
   SELECT b.instance_number, s.sql_text, s.hash_value, v.address, s.t_per_exec
     FROM dbsnmp.mgmt_baseline b, dbsnmp.mgmt_baseline_sql s, v$sqlarea v
    WHERE b.instance_number = s.instance_number
      AND s.hash_value = v.hash_value;
CREATE OR REPLACE PACKAGE dbsnmp.mgmt_response wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
402 21f
FGzRNO47I7axCfXBmchUBiXIj/swg2NemMCGfHQ0PPmejj4aiHi+PJQur2/GBoamUK3qTWXq
Q3/B5LVG8QbbC/q+BsU1mG1spqz6tO0xqHpzQiPrndCwsZzB6+9Xh+GpdrasgKgXPckGWntn
Sje4me+guY0FdthTBKafFlsUuQvm+o6PcIVhQD/LFaKz4Le9r9OrNVUE1P9E2Fd1GuKzErj7
5jP9GpQ2AQgVD2kQQyVwB5UCqjJFY30kzQ4nssS1R9rZZFTmYLO8ZkgLvdvncpRUcouTt/KG
V+hMv3OyScnQI1MeEq0sTEIfjqqMc8k2PPUrxrrl1CjbVnjbPuvLKp/XfkQPfh5UZqRkMN9b
w/R4tMCBIy1iPel6wyFVGiPUa9W6r5skywbkxqkKyYLkTHSRRN9DPhEJ/G4qc8se1lJlzFYf
bemtvX6ck8iL6ci+adEZcCQA4BZiLzkSblw863hc7P0YCvIPFIOJqIH9s0lv27CUcBHouBA/
RowII5PDj7+HoNgnGDdSc4akQWOUkg==

/
CREATE OR REPLACE PACKAGE BODY dbsnmp.mgmt_response wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
7dd8 1ad6
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
/UCwa4Y=

/
show errors
