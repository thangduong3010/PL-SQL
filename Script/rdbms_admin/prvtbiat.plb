CREATE OR REPLACE VIEW  DBA_CACHEABLE_NONTABLE_OBJECTS
(OWNER, OBJECT_NAME, OBJECT_TYPE)
AS
SELECT u.username owner, u.username object_name, 'USER'
FROM   dba_users u
WHERE  u.username NOT IN ('SYS', 'SYSTEM', 'OUTLN', 'ORDSYS', 'CTXSYS', 
                          'MDSYS', 'ORDPLUGINS', 'PUBLIC','DBSNMP',
                          'AURORA$JIS$UTILITY$', 'AURORA$ORB$UNAUTHENTICATED',
                          'LBACSYS', 'OSE$HTTP$ADMIN', 'ICPB', 'TRACESVR',
                          'XDB', 'PERFSTAT', 'RMAIL')
UNION ALL
SELECT o.owner, o.object_name, o.object_type
FROM   dba_objects o
WHERE  owner NOT IN ('SYS', 'SYSTEM', 'OUTLN', 'ORDSYS', 'CTXSYS', 
                     'MDSYS', 'ORDPLUGINS', 'PUBLIC','DBSNMP',
                          'AURORA$JIS$UTILITY$', 'AURORA$ORB$UNAUTHENTICATED',
                          'LBACSYS', 'OSE$HTTP$ADMIN', 'ICPB', 'TRACESVR',
                          'XDB', 'PERFSTAT', 'RMAIL')
        AND
        ((object_type = 'VIEW'
            AND NOT EXISTS (SELECT 1 FROM dba_snapshots s
                            WHERE  s.owner = o.owner
                            AND    s.name  = o.object_name))
        OR 
        (object_type IN ('TYPE', 'PACKAGE', 'PROCEDURE', 'FUNCTION', 'SEQUENCE')))
MINUS
SELECT r.sname, r.oname, r.type
 FROM  dba_repgenerated r
/
comment on table DBA_CACHEABLE_NONTABLE_OBJECTS is
'This view is obsolete'
/
CREATE OR REPLACE VIEW DBA_CACHEABLE_TABLES_BASE
(OWNER, TABLE_NAME, TEMPORARY, PROPERTY)
AS SELECT u.name, o.name, decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
         tab.property
   FROM   sys.user$ u, 
          sys.obj$ o, 
          (SELECT t.obj#, t.property 
           FROM   sys.tab$ t
           WHERE  /* Exclude the following tables
                   * 0x00008000    FILE columns
                   * 0x00020000    AQ table
                   * 0x08000000    sub-object
                   */
                  bitand(t.property,134381568) = 0 
             AND  
                  NOT EXISTS (SELECT 1 FROM   sys.col$ c
                              WHERE  t.obj# = c.obj#
                              AND  c.type# IN (8, 24) /* DTYLNG,DTYLBI */)) tab
   WHERE  o.owner# = u.user#
     AND  o.obj#   = tab.obj#
     AND  
          u.name NOT IN ('SYS', 'SYSTEM', 'ORDSYS', 'CTXSYS', 'MDSYS', 
                         'ORDPLUGINS', 'OUTLN', 'DBSNMP','AURORA$JIS$UTILITY$',
                          'AURORA$ORB$UNAUTHENTICATED',
                          'LBACSYS', 'OSE$HTTP$ADMIN', 'ICPB', 'TRACESVR',
                          'XDB', 'PERFSTAT', 'RMAIL')
     AND 
          NOT EXISTS (SELECT 1 FROM sys.snap$ s
                      WHERE  s.sowner = u.name
                        AND ((s.tname = o.name) OR (s.uslog = o.name)))
     AND 
          NOT EXISTS (SELECT 1 from sys.mlog$ m
                      WHERE  m.mowner = u.name
                        AND  m.log    = o.name)
/
comment on table DBA_CACHEABLE_TABLES_BASE is
'This view is obsolete'
/
CREATE OR REPLACE VIEW DBA_CACHEABLE_TABLES
(OWNER, TABLE_NAME)
AS SELECT t.owner, t.table_name 
   FROM   dba_cacheable_tables_base t
   WHERE  temporary = 'N'
    AND   bitand(t.property,16785439) = 0  
/
create or replace public synonym DBA_CACHEABLE_TABLES for DBA_CACHEABLE_TABLES
/
comment on table DBA_CACHEABLE_TABLES is
'This view is obsolete'
/
CREATE OR REPLACE VIEW DBA_CACHEABLE_OBJECTS_BASE
(OWNER, OBJECT_NAME, OBJECT_TYPE)
AS 
SELECT OWNER, OBJECT_NAME, OBJECT_TYPE
FROM   dba_cacheable_nontable_objects
UNION ALL
SELECT t.owner, t.table_name object_name, 
       decode(t.temporary, 'Y', 'TEMP TABLE', 'TABLE')
FROM   dba_cacheable_tables_base t
/
create or replace public synonym DBA_CACHEABLE_OBJECTS_BASE
   for DBA_CACHEABLE_OBJECTS_BASE
/
comment on table DBA_CACHEABLE_OBJECTS_BASE is
'This view is obsolete'
/
CREATE OR REPLACE VIEW  DBA_CACHEABLE_OBJECTS
(OWNER, OBJECT_NAME, OBJECT_TYPE)
AS
SELECT * FROM dba_cacheable_nontable_objects o
WHERE o.object_type != 'TYPE'
UNION ALL
SELECT t.owner, t.table_name object_name, 
       decode(t.temporary, 'Y', 'TEMP TABLE', 'TABLE')
FROM   dba_cacheable_tables_base t
WHERE  /* Exclude the following tables
                  - * 0x00000001    typed tables
                  - * 0x00000002    having ADT cols
                  - * 0x00000004    having nested table columns
                  - * 0x00000008    having REF cols
                  - * 0x00000010    having array cols
                  - * 0x00002000    nested table
                  - * 0x01000000    user-defined REF columns
         */
     bitand(t.property,16785439) = 0  
/
create or replace public synonym DBA_CACHEABLE_OBJECTS
   for DBA_CACHEABLE_OBJECTS
/
comment on table DBA_CACHEABLE_OBJECTS is
'This view is obsolete'
/
CREATE OR REPLACE PACKAGE dbms_ias_template_utl wrapped 
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
22c 124
lpjGzJmnLb1doZ9PQnfgSB3yanYwgztyAJkVfC+pOMH5GP2UbnZiy7Fdd3DsQM/n3ICVy+aZ
5h61sc43V+PLHHhG77ulVI79cfN2M0xyxkXBaynceQAhzxyjaSLZpuJtPxc2gNV/cGv0HToO
R54OTcUuEXC8qWwnrkKnnh7FNWV74e7nHS3mcodEq7CADiX89SpU0xYduvXg8Ejf7ehPSYH+
Xa0ksLO3+HWsGmxgpEidGzqE5BCabiVcMyiXnAjGj2z41hZrhVrI6Sk61y/W/4AfY0Iy/g==


/
CREATE OR REPLACE PACKAGE BODY dbms_ias_template_utl wrapped 
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
987 384
/Jq0Q+u2QbMt0t/kOWNlWuV7Jvcwg5VcDNCDfC+5rZ0VB/I2veli7cNtVwQSpgr0t4PcxNLT
s0jL1WLNJzgg5M6D/2pS4dXyxCcUFBIcQTqLCPc4m71kpmIJRTW/mr/4Bj+YlstDuQg4EhZt
wWodFWXnL5ei8qmL4S/zqZSOdNnmZURrrRZawrRardymf0q8cDU8VFlJg4HkF+TVnIuYtCqc
yv9FZp4MbsaXo/Dztzlnf1mgLSgkNP1y2PDZTT3tTz/YjdHJmveLocImTlR8SpXocHGvnkaz
rC96rsj5Yl9nDG9L4GgGjG2ib+FlrFz3CldFlBsdbHw3uNKGJiFMfGIxmiyX/Y4jVTq+VY23
swgRLKuIbfLSNJZPit56KA0jqfgwdojEb/YQKDRFJ+4wka+oCgSR1Stc1DZOiYKsCzOyFRm4
ota0LuquoAsJH04YfGKO/jS2KrI0BlVhq7lMScIpo772F0ywyWZIi9Z1FJwnqz03o+Sft9w9
GkysSJEoh5RrHt4K0ZQrvm59Jm2GqyLPbMg+p5sb+gUquInlKuf0ia2M33Ef8YE7yVQd8U8L
8Ql1Mol+MX1bMO/sFy3QA3xA3276O/jL29PI3VkjZB2we6y3fRIQLbAOwn0NSIu3b5TeM56J
Q33u5luAiJaztpKx5Il+xa5gZHBrmLAP0LWc1vmpqTRggJa565ovyCyLDX3GqoHhmy2evX8v
AuSkCyFN+Y5cgym8jWLp7Mq+94Oo5cJCHpZNGx2Id+QOv4CheWGOyrHtCG5PxVEy2yOoDRMT
PELEFEy2eANO0bw8GlEtQOr/S3EAqLAmPG89SaPqyMlT3F7vrpkYlNGn3kjCzV48qSL2/OWI
+h7op6OTLAKIrDETmk53UkU=

/
create or replace package body sys.dbms_ias_template wrapped 
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
39a3 df4
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

/
CREATE OR REPLACE PACKAGE dbms_ias_template_internal wrapped 
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
174 ff
Mfp0MhozRyVm0OXjA2xJx9KjICEwg43I7Z7WZy9GXviOuhvIxTs9I8R17xkoEhOgB6hvrPLj
vCTMSy33kbTg7CB1Man8QGyvHjHQJjvGISpzmAqwGw1qd89ARR22A3TKS+oau1kOdWkWvcCh
8VHze+KHjHA3991XMMoK1ZtDegOYo5NDO2xJpR8KNMcai9MV1I39M4mWO/5ImPIDKJ1I7AP+
wPreUALw+nBZ5t/D2Z1ftuAHXD/O4a59Xu0=

/
grant execute on dbms_ias_template_internal to execute_catalog_role
/
CREATE OR REPLACE PACKAGE BODY dbms_ias_template_internal wrapped 
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
7ab 357
uC+4pnt25Ar3jg3tEREbS9Ir1HYwg1VcLiAFfHRVvp2sHXvbOeEdzd72yPsYRxoVfvq3XWEx
6bhejOdQGukGCz/kETGh7Nt9xgEHOuBYZpXGgCKtC+QfE8pfw3oCB/iVg9dtDQqXldlezI1I
vNiXPcIw4Tj//6ZlO1fUvmCPq1jpF1hBDjJgVHSDMkdW/X/WyhRofNdkWLyKXooTrv3ZXOxR
oKUmVOIaotzK2G/AwC/9CVaoSSwbjfXG58RIr5VD0C/iQMpOFIjI+OdJ5pI0CBYq3AvUWDK+
LlG6YvzCKoYE0skKwhsmxSvQAUM8TuU0rA5zIxblBrxUnHMZyYau/A39A8GVUXErczFOwJP/
Ftij15zQ7nzKxu+pEy4gHz+FaZjHVHuIaodXV075SX2BGibdXqhXDNtPt0GB7gDCupeYfYqE
LoYe0uB0vZf07RxEkPOo5DRT5MszqwETsR3fXoZp9mPv10avkgXgg3WssWyVhbeF3IJ2gvdX
WLBz0K+a676EZaX3FgvhADBcNyFNYu3YrDlgd10iv6D/8e05WVCgKVD8omjAI1krgF79BTiu
hCCYOKFKeUBiSnnoTmKmF2b0v6fPuqtFmHe5kH14/OHrQ782UHh2u1fJKxa9xHdZ405H88uA
KQJfCEix4KpNuycuwC7+3uF7pY/l9A2XIiOzzwmluu3GQuzcoXMp54FJ0rVLIz9CunPw2Jg5
j0/0gaqxJ2qkGxHz1KNjuymOWbd1OY1A2aLGgmWKyUdJZvFHu10TK8RxQ9JPkntGma69ivTS
eqnDIiXw+pYZ/yOZxIccKCp5MMfXdXDJ0OziHHfxbNaWqvsIm4oo

/
