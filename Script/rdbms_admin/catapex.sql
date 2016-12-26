Rem
Rem $Header: rdbms/admin/catapex.sql /st_rdbms_11.2.0/1 2011/03/14 08:29:10 jstraub Exp $
Rem
Rem catapex.sql
Rem
Rem Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      catapex.sql
Rem
Rem    DESCRIPTION
Rem      Support the Application Express component in a DataPump export
Rem      /import operation.
Rem
Rem    NOTES
Rem      None.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jstraub     03/10/11 - For datapump support, bug 10392154
Rem    jstraub     03/10/11 - Created
Rem

delete from sys.impcalloutreg$ where tag='APEX';

insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
     values ('APEX_DATAPUMP_SUPPORT','SYS','APEX',3,1000,0,
             'SYS','WWV_DBMS_SQL',9,'Application Express');

insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
     values ('APEX_DATAPUMP_SUPPORT','SYS','APEX',3,1000,0,
             'SYS','WWV_FLOW_KEY',9,'Application Express');

insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
     values ('APEX_DATAPUMP_SUPPORT','SYS','APEX',3,1000,0,
             'SYS','VALIDATE_APEX',7,'Application Express');

commit;

