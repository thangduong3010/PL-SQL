-- subscript for initjvm.sql and ilk

-- Java Sanity check for installation
-- If the following query returns 0, then the Java installation
-- did not succeed
select count(*) from all_objects where object_type like 'JAVA%';

-- Define package dbms_java
@@initdbj

