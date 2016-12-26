Rem
Rem $Header: rdbms/admin/catdef.sql /st_rdbms_11.2.0/1 2013/04/24 13:57:42 yanlili Exp $
Rem
Rem catdef.sql
Rem
Rem Copyright (c) 2007, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catdef.sql - Create a view for default users with default passwords
Rem
Rem    DESCRIPTION
Rem      SYS.DBA_USERS_WITH_DEFPWD view shows list of users with default
Rem      passwords. This view is being used by DB Security scanners and other
Rem      tools to warn DBAs on such users.
Rem
Rem    NOTES
Rem      Each default account must have an entry in SYS.DEFAULT_PWD$ table.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yanlili     04/18/13 - Backport minx_bug-16369584 from main
Rem    rkgautam    04/09/09 - Bug 8420947, removing internal references
Rem    sarchak     03/02/09 - Bug 7829203,default_pwd$ should not be recreated
Rem    ssonawan    02/24/09 - bug-8260171: add account plm/plm
Rem    rkgautam    02/03/09 - bug-8214972: adding rdw13dev/retek
Rem    rlong       09/25/08 - 
Rem    rkgautam    08/26/08 - bug-7347131: add user$ verifiers
Rem    rkgautam    08/25/08 - 
Rem    rmir        08/12/08 - bug-7218953: add additional entry for OLAPSYS 
Rem    rkgautam    07/30/08 - bug-7341968: Verifier corrected for PM
Rem    rkgautam    07/30/08 - bug-7269805: added default account ORDDATA
Rem    dsemler     06/05/08 - add appqossys to the default password table
Rem    rkgautam    05/19/08 - bug-6998975: added default account FOD
Rem    rkgautam    04/22/08 - bug-6952604: added default account SRDEMO
Rem    rkgautam    01/09/08 - bug-6659094: added missing default accounts
Rem    rkgautam    01/08/08 - 
Rem    ssonawan    07/11/07 - bug-6020455: update DBA_USERS_WITH_DEFPWD 
Rem    shan        06/21/07 - remove grant on USERS_WITH_DEFPWD and
Rem                           SYS.DEFAULT_PWD$
Rem    shan        04/30/07 - update default password list
Rem    shan        04/12/07 - users with default password view
Rem    shan        04/12/07 - Created
Rem

-- For adding entry to DEFAULT_PWD$. Please follow the below mentioned steps
-- 1) Add the entry in dsec.bsq
--    ex: For example, if you insert a user SCOTT and his default password
--        verifier BFE9361CDAE2A11C (o3 hash value of "foobar") in this table
--        insert into SYS.DEFAULT_PWD$(user_name,pwd_verifier,pv_type)
--        values ('SCOTT', 'BFE9361CDAE2A11C', 0);
--        Then user SCOTT will show up in the DBA_USERS_WITH_DEFPWD view
--        as long as his password is "foobar".
-- 2) Add the entry in c1101000.sql
--    ex: exec insert_into_defpwd('SCOTT', 'BFE9361CDAE2A11C',pv_type default 0);

-- A table in SYS schema to store a list of users who are still using the 
-- default passwords. DBA should populate this table with the following
-- information: 
--   user_name     : A user name
--   pwd_verifier  : The default password verifier
--   pv_type       : Password veriifer type. 
--                     0 - O3logon verifier. ie, password column in user$ table
--                    -1 - default accounts do not have default passwords
--                     Other values undefined as of now. Will be defined as we
--                           support new verifier types
-- 
 
-- Create a DBA view to show what users are still using their passwords

CREATE OR REPLACE VIEW SYS.DBA_USERS_WITH_DEFPWD (USERNAME) AS
  SELECT DISTINCT u.name
    FROM SYS.user$ u, SYS.default_pwd$ dp
   WHERE 
     (u.type#  = 1 
      AND bitand(u.astatus, 16) = 16
      AND dp.pv_type >= 0
     ) OR 
     (u.type#    = 1
     AND u.password = dp.pwd_verifier
     AND u.name     = dp.user_name
     AND dp.pv_type = 0);

-- Add comments on the DBA view

COMMENT ON TABLE DBA_USERS_WITH_DEFPWD is 
'Users that are still using their default passwords';


COMMENT ON COLUMN DBA_USERS_WITH_DEFPWD.USERNAME is
'Name of the user';


-- Create public synonym for DBA_USERS_WITH_DEFPWD view

CREATE OR REPLACE PUBLIC SYNONYM DBA_USERS_WITH_DEFPWD 
   FOR SYS.DBA_USERS_WITH_DEFPWD;

-- Grant privs on the view and the base table we newly created
-- GRANT select ON DBA_USERS_WITH_DEFPWD TO dba;
-- GRANT select, insert, delete, update ON  SYS.DEFAULT_PWD$ TO dba;


