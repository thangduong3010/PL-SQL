Rem
Rem $Header: rdbms/admin/caths.sql /main/39 2010/02/03 20:10:06 psuvarna Exp $
Rem
Rem caths.sql
Rem
Rem Copyright (c) 1997, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      caths.sql - CATalog script for Heterogeneous Services
Rem
Rem    DESCRIPTION
Rem      Create Heterogeneous Services data dictionary objects.
Rem
Rem      Contents of several tables and views are selected by
Rem      FDS_CLASS_ID and FDS_INST_ID columns.  FDS_INST_ID = NULL indicates
Rem      a default value; FDS_CLASS_ID cannot be defaulted.
Rem
Rem      Many HS data dictionary tables are populated automatically
Rem      by agent self-registration during normal server operation.
Rem
Rem
Rem      Objects created by this script are:
Rem
Rem        hs$_fds_class    Table:  FDS class definitions
Rem        hs_fds_class     View:   View of FDS class definitions
Rem        hs$_fds_class_date Table:FDS class timestamps for last access
Rem        hs_fds_class_date View:  View of FDS class timestamps
Rem        hs$_fds_inst     Table:  FDS instance definitions
Rem        hs_fds_inst      View:   View of FDS instance definitions
Rem        hs$_base_caps    Table:  Base capability definitions
Rem        hs_base_caps     View:   View of base capability definitions
Rem        hs$_class_caps   Table:  Class-specific FDS capabilities
Rem        hs_class_caps    View:   View of FDS class capabilities
Rem        hs$_inst_caps    Table:  Instance-specific FDS capabilities
Rem        hs_inst_caps     View:   View of instance capabilities
Rem        hs$_base_dd      Table:  Base DD translation definitions
Rem        hs_base_dd       View:   View of base DD translation definitions
Rem        hs$_class_dd     Table:  Class-specific FDS DD translations
Rem        hs_class_dd      View:   View of FDS class DD translations
Rem        hs$_inst_dd      Table:  Instance-specific FDS DD translations
Rem        hs_inst_dd       View:   View of FDS instance DD translations
Rem        hs$_class_init   Table:  Class-specific HS init parameters
Rem        hs_class_init    View:   View of class init parameters
Rem        hs$_inst_init    Table:  Instance-specific HS init parameters
Rem        hs_inst_init     View:   View of instance init parameters
Rem                                 Views of joined class & instance data:
Rem        hs_all_caps      View:   All FDS capabilities
Rem        hs_all_dd        View:   All FDS DD translations
Rem        hs_all_inits     View:   All HS initialization parameters
Rem
Rem    NOTES
Rem      This script must be run while connected as SYS.
Rem
Rem      The hs_all_* views represent only data recorded in
Rem      the server DD.  Additional instance capabilities ind
Rem      instance DD translations may be uploaded from HS agents
Rem      when each connection is established.  These uploaded
Rem      data are merged with data from the server DD for use
Rem      on the connection but are not visible in the server DD.
Rem
Rem      A similar upload of initialization parameters occurs,
Rem      with init parameters from agents logically being a properties
Rem      of the session rather than of a class or instance.
Rem      The
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    psuvarna    12/24/09 - 8858714: add capability for WAIT clause
Rem    aamor       09/20/08 - add capability for recursive WITH and for column
Rem                           alias list for WITH clause
Rem    kchen       05/05/08 - fixed bug 6943575
Rem    sbellamk    07/31/06 - add capability for native full outer join
Rem    kchen       06/02/06 - includes dbmshsld, prvthsld.plb 
Rem    jahuesva    05/15/06 - Added ODBC datetime datatypes 3066 to 3069
Rem    dtahara     08/02/04 - 3547585: added "new connect-by" capability
Rem    jahuesva    07/15/04 - Bug 3767742 - Addes missing entries to base caps
Rem    jahuesva    10/23/03 - Bug 3214442 - Fixed typo in cap # 169
Rem    jahuesva    10/08/03 - Added base capability for HOACdescParamAfterExec 
Rem                           (#1963)
Rem    jahuesva    10/01/03 - Added missing base Capabilities
Rem    jahuesva    08/22/03 - Added base capability for HOACsupportSchema 
Rem                           (#1964)
Rem    jahuesva    08/22/03 - Added base capability for HOACLtIsNull (#1965)
Rem    jahuesva    08/22/03 - Added base capability for HOACsupportSchema 
Rem                           (#1966)
Rem    jahuesva    07/15/03 - Added base capability for HOACOPTCTX (#392)
Rem    jahuesva    03/13/03 - Added base capability for HOACOPTFSTLST (#531)
Rem    kchen       08/22/02 - Add base capability for OPTPLS
Rem    pravelin    10/23/01 - Fix merge errors.
Rem    pravelin    10/19/01 - Merge main branch and log branch versions
Rem    rgmani      10/01/01 - Add cap 1966
Rem    srajagop    08/20/01 - lob support
Rem    pravelin    07/31/01 - Use [create/]replace ops to populate base tables
Rem    pravelin    07/26/01 - Eliminate drops, for use from catproc.
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    rgmani      03/08/01 - Add new base caps
Rem    pravelin    12/13/00 - Use index instead of name in hs_fds_class_date
Rem    kpeyetti    11/29/00 - privileges & synonyms for hs_fds_class_date
Rem    rhungund    10/09/00 - changes to accomodate the migration path
Rem    delson      08/28/00 - remove refernces to no-longer-implemented methods
Rem    srajagop    06/26/00 - piecewise base cap added
Rem    rgmani      07/18/00 - Add new HS base caps
Rem    rgmani      06/12/00 - Add base result set capabilities
Rem    rgmani      11/29/99 - Add base cap for HOACpublicSchema
Rem    rgmani      07/06/99 - Add base cap for 1970
Rem    rgmani      06/29/99 - Add base cap 1996
Rem    pravelin    01/12/99 - Bug 780957:  sqlplus doesn't recognize '#' commen
Rem    rgmani      10/20/98 - Add 1971 base cap
Rem    rgmani      10/12/98 - Add 1972 base cap
Rem    evoss       09/09/98 - bug 725369 (Subquery list in update capability)  
Rem    pravelin    09/03/98 - Bug 724831:  Eliminate 'set echo on'
Rem    ncramesh    08/06/98 - change for sqlplus
Rem    pravelin    07/20/98 - Eliminate comment referring to cathsAGT.sql scrip
Rem    pravelin    06/17/98 - Bug 679473:  Don't register TKHODDAU as base DD t
Rem    pravelin    02/04/98 - Bug 620715:  Add base_dd tables for test extensio
Rem    rgmani      08/13/97 - Add base cap for cap #1994
Rem    rgmani      07/24/97 - Add base cap for cap #1975
Rem    rgmani      07/23/97 - Add base caps for DB2-related capabilities
Rem    rgmani      07/10/97 - Add base caps for coercion capabilities
Rem    jdraaije    04/17/97 - remove ID columns from external objects view
Rem    jdraaije    03/26/97 - Name consistency: ho => hs
Rem    pravelin    03/20/97 - Eliminate 'use XA' capability, replaced by init p
Rem    pravelin    03/18/97 - Create pseudo-FDS class for BITE (Built-In Test E
Rem    ktarkhan    02/20/97 - add external grantees, change external objects
Rem    rgmani      02/13/97 - Add base caps for bundling and tcis call
Rem    pravelin    01/15/97 - Add setup for base dd translations
Rem    jdraaije    01/01/97 - external_procedures ==> external_objects
Rem    rgmani      11/06/96 - Add new base DD - TKHODDAU
Rem    celsbern    10/21/96 - Changed view names from hs to hs.
Rem    rgmani      10/25/96 - Add base caps for new HS datatypes
Rem    rgmani      10/14/96 - Add base caps for QuoteOwner and MapAlias
Rem    rgmani      09/18/96 - Add new capability 1992 (HOACdelimToFDS)
Rem    celsbern    09/06/96 - Removed dbms_hs.package and put in separate files
Rem    rgmani      08/21/96 - Add base cap 1993
Rem    asurpur     08/28/96 - Dictionary protection: granting execute on dbms_h
Rem    rgmani      07/16/96 - Fix bug
Rem    rgmani      07/15/96 - Switch to new HS data dictionary
Rem    asurpur     05/15/96 - Dictionary Protection: Granting privileges on vie
Rem    evoss       05/23/96 - add bind to parameter capability
Rem    jdraaije    04/03/96 - Add sys.hs_objects table for callouts
Rem    pravelin    03/13/96 - Create HS data dictionary tables and views
Rem    pravelin    03/13/96 - Created
Rem


-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- Create the role that is being used to protect access to the HS data
-- dictionary tables and to the dbms_hs, dbms_hs_extproc, and
-- dbms_hs_passthrough packages.
-- The role is immediately granted to select_catalog_role, and
-- execute_catalog_role such that users with generic data dictionary access
-- now also can access the HS data dictionary.
 
create role hs_admin_select_role;
create role hs_admin_execute_role;
create role hs_admin_role;

grant hs_admin_select_role to select_catalog_role;
grant hs_admin_execute_role to execute_catalog_role;
grant hs_admin_select_role to hs_admin_role;
grant hs_admin_execute_role to hs_admin_role;

-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- The intention of the FDS class is that it contains all the information, 
-- e.g. capabilities, data dictionary translations, etc. that are specific for 
-- a whole group of FDSs. In general this group will be accessed by the same 
-- HS driver. 
-- 
-- HS$_FDS_CLASS 
 
create table hs$_fds_class 
( 
   fds_class_id number not null, 
      constraint hs$_fds_class_pk primary key (fds_class_id), 
   fds_class_name varchar2(30) not null, 
      constraint hs$_fds_class_uk1 unique (fds_class_name), 
   fds_class_comments varchar2(255) 
 ); 
 
create sequence hs$_fds_class_s; 
 
-- hs_fds_class view 
create or replace view hs_fds_class  
(fds_class_name,fds_class_comments,fds_class_id) as 
select fds_class_name,fds_class_comments,fds_class_id 
from hs$_fds_class; 

grant select on  hs_fds_class to hs_admin_select_role;

create or replace public synonym hs_fds_class for hs_fds_class;
 
-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- Besides having FDS class specific information, users also need 
-- to be able to set capabilities, DD translations and init parameters on 
-- a per FDS basis. Every RDB database, for instance, requires the RDB$HANDLE 
-- environment variable to be set to the name and location of the actual 
-- database file. This type of information is set in the FDS table. 
-- 
-- HS$_FDS_INST 
 
create table hs$_fds_inst 
( 
   fds_inst_id                  number not null, 
      constraint hs$_fds_inst_pk primary key (fds_inst_id), 
   fds_class_id                 number not null, 
       constraint hs$_fds_inst_fk1 foreign key (fds_class_id) 
       references hs$_fds_class on delete cascade, 
   fds_inst_name                varchar2(30) not null, /*is this big enough?*/ 
      constraint hs$_fds_inst_uk1 unique (fds_inst_name,fds_class_id), 
   fds_inst_comments varchar2(255) 
); 
 
create sequence hs$_fds_inst_s; 
 
-- hs_fds_inst view 
create or replace view hs_fds_inst 
(fds_inst_name,fds_inst_comments,fds_class_name,fds_inst_id,fds_class_id) as 
select f.fds_inst_name,f.fds_inst_comments,fc.fds_class_name,f.fds_inst_id,
  f.fds_class_id 
from hs$_fds_class fc, 
hs$_fds_inst f 
where f.fds_class_id = fc.fds_class_id; 

grant select on hs_fds_inst to hs_admin_select_role;

create or replace public synonym hs_fds_inst for hs_fds_inst;

-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- This is the base capability table. Besides this table we'll also create 
-- a table for the DRIVER (fds_class or agent) specific capabilities, and 
-- one for the FDS specific capabilities. 
-- 
-- HS$_BASE_CAPS 
 
create table hs$_base_caps 
( 
   cap_number               number not null, 
      constraint hs$_base_caps_pk primary key (cap_number), 
   cap_description          varchar2(255) 
); 
 
create or replace view hs_base_caps 
(cap_number,cap_description) as 
select cap_number, cap_description
from hs$_base_caps; 

grant select on  hs_base_caps to hs_admin_select_role;

create or replace public synonym hs_base_caps for hs_base_caps;

-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- This is the FDS class (DRIVER) specific capability table.  
--  
-- HS$_CLASS_CAPS 
 
create table hs$_class_caps 
( 
   fds_class_cap_id        number not null, 
      constraint hs$_class_caps_pk primary key (fds_class_cap_id), 
   fds_class_id            number not null, 
      constraint hs$_class_caps_fk1 foreign key (fds_class_id) 
      references hs$_fds_class on delete cascade, 
   cap_number              number not null, 
      constraint hs$_class_caps_fk2 foreign key (cap_number) 
      references hs$_base_caps on delete cascade, 
      constraint hs$_class_caps_uk1 unique (fds_class_id,cap_number), 
   context                 number, 
   translation             varchar2(255), 
   additional_info         number 
); 
 
create sequence hs$_class_caps_s; 
 
create or replace view hs_class_caps 
(cap_number, cap_description, context, translation, additional_info, 
 fds_class_name,  fds_class_id) as 
select cc.cap_number, bc.cap_description, cc.context, cc.translation, 
       cc.additional_info, fc.fds_class_name, fc.fds_class_id 
from   hs$_class_caps cc,
       hs$_base_caps bc,
       hs$_fds_class fc
where  bc.cap_number = cc.cap_number 
and cc.fds_class_id = fc.fds_class_id; 

grant select on  hs_class_caps to hs_admin_select_role;

create or replace public synonym hs_class_caps for hs_class_caps;

-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- This is the FDS instance specific capability table.  
--  
-- HS$_INST_CAPS 
 
create table hs$_inst_caps 
( 
   fds_inst_cap_id         number not null,
      constraint hs$_inst_caps_pk primary key (fds_inst_cap_id), 
   fds_inst_id             number not null, 
      constraint hs$_inst_caps_fk1 foreign key (fds_inst_id) 
      references hs$_fds_inst on delete cascade, 
   cap_number              number not null, 
      constraint hs$_inst_caps_fk2 foreign key (cap_number) 
      references hs$_base_caps on delete cascade, 
      constraint hs$_inst_caps_uk1 unique (fds_inst_id,cap_number), 
   context                 number, 
   translation             varchar2(255), 
   additional_info         number 
); 
 
create sequence hs$_inst_caps_s; 
 
create or replace view hs_inst_caps 
(cap_number, cap_description, context, translation, additional_info, 
 fds_class_name, fds_inst_name, fds_class_id, fds_inst_id) as 
select bc.cap_number, bc.cap_description, ic.context, ic.translation, 
       ic.additional_info, fc.fds_class_name, f.fds_inst_name,
       fc.fds_class_id, f.fds_inst_id 
from   hs$_inst_caps ic, 
       hs$_base_caps bc, 
       hs$_fds_class fc, 
       hs$_fds_inst f 
where  bc.cap_number = ic.cap_number 
and    ic.fds_inst_id = f.fds_inst_id 
and    f.fds_class_id = fc.fds_class_id; 
 
grant select on  hs_inst_caps to hs_admin_select_role;

create or replace public synonym hs_inst_caps for hs_inst_caps;

-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- This is the base DD translation table. Besides this table we'll also create 
-- a table for the DRIVER (fds_class or agent) specific capabilities, and 
-- one for the FDS specific capabilities. 
-- 
-- HS$_BASE_DD 
 
create table hs$_base_dd 
( 
   dd_table_id              number not null, 
      constraint hs$_base_dd_pk primary key (dd_table_id), 
   dd_table_name            varchar2(30) not null, 
      constraint hs$_base_dd_uk1 unique (dd_table_name), 
   dd_table_desc            varchar2(255) 
); 
 
create sequence hs$_base_dd_s; 
 
create or replace view hs_base_dd 
(dd_table_name,dd_table_desc, dd_table_id) as 
select dd_table_name, dd_table_desc, dd_table_id 
from hs$_base_dd; 

grant select on  hs_base_dd to hs_admin_select_role; 

create or replace public synonym hs_base_dd for hs_base_dd;

-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- This is the FDS class specific DD translation table 
-- 
-- HS$_CLASS_DD 
 
create table hs$_class_dd 
( 
   fds_class_dd_id          number not null, 
      constraint hs$_class_dd_pk primary key (fds_class_dd_id), 
   fds_class_id             number not null, 
      constraint hs$_class_dd_fk1 foreign key (fds_class_id) 
      references hs$_fds_class on delete cascade, 
   dd_table_id              number not null, 
      constraint hs$_class_dd_fk2 foreign key (dd_table_id) 
      references hs$_base_dd on delete cascade, 
      constraint hs$_class_dd_uk1 unique (fds_class_id,dd_table_id), 
   translation_type         char(1) not null, 
      constraint hs$_class_dd_c1 check (translation_type in ('T','M','S')),
   translation_text         varchar2(4000),
      constraint hs$_class_dd_c2 check 
      ((translation_type in('S','T') and translation_text is not NULL) or 
       (translation_type = 'M'))
); 
 
create sequence hs$_class_dd_s; 
 
create or replace view hs_class_dd 
(dd_table_name, dd_table_desc, translation_type, translation_text,  
 fds_class_name, dd_table_id, fds_class_id) as 
select bd.dd_table_name, bd.dd_table_desc, cd.translation_type,  
       cd.translation_text, fc.fds_class_name, bd.dd_table_id, fc.fds_class_id 
from   hs$_base_dd bd, hs$_class_dd cd, hs$_fds_class fc 
where  (bd.dd_table_id = cd.dd_table_id) and (cd.fds_class_id = 
fc.fds_class_id); 

grant select on  hs_class_dd to hs_admin_select_role;

create or replace public synonym hs_class_dd for hs_class_dd;
 
-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- This is the FDS instance specific DD translation table 
-- 
-- HS$_INST_DD 
 
create table hs$_inst_dd 
( 
   fds_inst_dd_id          number not null, 
      constraint hs$_inst_dd_pk primary key (fds_inst_dd_id), 
   fds_inst_id             number not null, 
      constraint hs$_inst_dd_fk1 foreign key (fds_inst_id) 
      references hs$_fds_inst on delete cascade, 
   dd_table_id              number not null, 
      constraint hs$_inst_dd_fk2 foreign key (dd_table_id) 
      references hs$_base_dd on delete cascade, 
      constraint hs$_inst_dd_uk1 unique (fds_inst_id,dd_table_id), 
   translation_type         char(1) not null, 
      constraint hs$_inst_dd_c1 check (translation_type in ('T','M','S')),
   translation_text         varchar2(4000),
      constraint hs$_inst_dd_c2 check 
      ((translation_type in ('T','S') and translation_text is not NULL) or 
       (translation_type = 'M'))
); 
 
create sequence hs$_inst_dd_s; 
 
create or replace view hs_inst_dd 
(dd_table_name, dd_table_desc, translation_type, translation_text,  
 fds_class_name, fds_inst_name, dd_table_id, fds_class_id, fds_inst_id) as 
select bd.dd_table_name, bd.dd_table_desc, id.translation_type,  
       id.translation_text, fc.fds_class_name, f.fds_inst_name, 
bd.dd_table_id,  
       fc.fds_class_id, f.fds_inst_id 
from   hs$_base_dd bd, hs$_inst_dd id, hs$_fds_class fc, hs$_fds_inst f 
where  (bd.dd_table_id = id.dd_table_id) and (id.fds_inst_id = f.fds_inst_id) 
       and (f.fds_class_id = fc.fds_class_id); 

grant select on  hs_inst_dd to hs_admin_select_role; 

create or replace public synonym hs_inst_dd for hs_inst_dd;
 
-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- This is the FDS class specific init value table 
-- 
-- HS$_CLASS_INIT 
 
create table hs$_class_init 
( 
   fds_class_init_id        number not null, 
      constraint hs$_class_init_pk primary key (fds_class_init_id), 
   fds_class_id             number not null, 
      constraint hs$_class_init_fk1 foreign key (fds_class_id) 
      references hs$_fds_class on delete cascade, 
   init_value_name          varchar2(64) not null, 
      constraint hs$_class_init_uk1 unique (fds_class_id,init_value_name), 
   init_value               varchar2(255) not null, 
   init_value_type          varchar2(1) not null, 
      constraint hs$_class_init_c1 check (init_value_type in ('F','T')) 
); 
 
create sequence hs$_class_init_s; 
 
create or replace view hs_class_init 
(init_value_name, init_value, init_value_type, fds_class_name,  
 fds_class_init_id, fds_class_id) as 
select ci.init_value_name, ci.init_value, ci.init_value_type, 
       fc.fds_class_name, ci.fds_class_init_id, fc.fds_class_id 
from   hs$_class_init ci, hs$_fds_class fc 
where  (ci.fds_class_id = fc.fds_class_id); 

grant select on  hs_class_init to hs_admin_select_role;

create or replace public synonym hs_class_init for hs_class_init;
 
-- 
--############################################################################ 
-- 
--############################################################################ 
--  
-- This is the FDS class specific init value table 
-- 
-- HS$_INST_INIT 
 
create table hs$_inst_init 
( 
   fds_inst_init_id         number not null, 
      constraint hs$_inst_init_pk primary key (fds_inst_init_id), 
   fds_inst_id              number not null, 
      constraint hs$_inst_init_fk1 foreign key (fds_inst_id) 
      references hs$_fds_inst on delete cascade, 
   init_value_name          varchar2(64) not null, 
      constraint hs$_inst_init_uk1 unique (fds_inst_id,init_value_name), 
   init_value               varchar2(255) not null, 
   init_value_type          varchar2(1) not null, 
      constraint hs$_inst_init_c1 check (init_value_type in ('F','T')) 
); 
 
create sequence hs$_inst_init_s; 
create or replace view hs_inst_init 
(init_value_name, init_value, init_value_type, fds_class_name,  
 fds_inst_name, fds_inst_init_id, fds_class_id, fds_inst_id) as 
select ii.init_value_name, ii.init_value, ii.init_value_type,
  fc.fds_class_name, f.fds_inst_name, ii.fds_inst_init_id,  
  fc.fds_class_id, f.fds_inst_id 
from  hs$_inst_init ii, 
  hs$_fds_class fc, 
  hs$_fds_inst f 
where ii.fds_inst_id = f.fds_inst_id 
and f.fds_class_id = fc.fds_class_id; 

grant select on  hs_inst_init to hs_admin_select_role;

create or replace public synonym hs_inst_init for hs_inst_init;

-- 
--#############################################################################
-- 
--#############################################################################
-- 
-- HS_ALL_CAPS view
-- This view shows all of the available capabilities for a given class
-- and inst.  Class level capabilities override base capabilities and 
-- Inst level capabilities override class and base level capabilities.

create or replace view hs_all_caps
(cap_number, context, translation, additional_info, fds_class_name, 
fds_inst_name) as
/*clause for the fds_inst level*/
select ic.cap_number, ic.context, ic.translation, ic.additional_info, 
  fc.fds_class_name, fi.fds_inst_name
from hs$_inst_caps ic, hs$_fds_inst fi, hs$_fds_class fc
where ic.fds_inst_id = fi.fds_inst_id 
and fi.fds_class_id = fc.fds_class_id
union
/*clause for the fds_class level minus the fds_inst level*/
select cc.cap_number, cc.context, cc.translation, cc.additional_info,
  fc2.fds_class_name, fi2.fds_inst_name
from hs$_class_caps cc, hs$_fds_inst fi2, hs$_fds_class fc2
where cc.fds_class_id = fi2.fds_class_id 
and fi2.fds_class_id = fc2.fds_class_id 
and not exists 
  (select 1 from hs$_inst_caps ic2
   where ic2.cap_number = cc.cap_number 
   and ic2.fds_inst_id = fi2.fds_inst_id)
union
/*clause for the base level minus fds_inst and fds_class level*/
select bc.cap_number, 0, null, 0, fc.fds_class_name, 
  fi.fds_inst_name
from hs$_base_caps bc, hs$_fds_class fc, hs$_fds_inst fi
where fc.fds_class_id = fi.fds_class_id
and not exists
  (select 1 from hs$_inst_caps ic
   where ic.fds_inst_id = fi.fds_inst_id
   and ic.cap_number = bc.cap_number)
and not exists
  (select 1 from hs$_class_caps cc
   where cc.fds_class_id = fc.fds_class_id
   and cc.cap_number = bc.cap_number);

grant select on hs_all_caps to hs_admin_select_role;

create or replace public synonym hs_all_caps for hs_all_caps;

-- 
--#############################################################################
-- 
--#############################################################################
-- 
-- HS_ALL_DD
-- This view shows all of the data dictionary translations for a 
-- class and inst.  Class level translations override base translations
-- and inst level translations override class and base translations.

create or replace view hs_all_dd
(dd_table_name, translation_type, translation_text, fds_class_name, 
 fds_inst_name, dd_table_desc) as
/*clause for the inst level*/
select bd.dd_table_name, id.translation_type, id.translation_text, 
  fc.fds_class_name, fi.fds_inst_name, bd.dd_table_desc
from hs$_inst_dd id, hs$_base_dd bd, hs$_fds_inst fi, hs$_fds_class fc
where id.fds_inst_id = fi.fds_inst_id 
and id.dd_table_id = bd.dd_table_id 
and fc.fds_class_id = fi.fds_class_id
union
/*clause for the class level minus the inst level*/
select bd2.dd_table_name, cd.translation_type, cd.translation_text, 
  fc2.fds_class_name, fi2.fds_inst_name, bd2.dd_table_desc
from hs$_class_dd cd, hs$_base_dd bd2, hs$_fds_inst fi2, hs$_fds_class fc2
where cd.fds_class_id = fi2.fds_class_id 
and cd.dd_table_id = bd2.dd_table_id 
and fc2.fds_class_id = fi2.fds_class_id 
and not exists 
  (select 1 from hs$_inst_dd id2
   where id2.dd_table_id = cd.dd_table_id 
   and id2.fds_inst_id = fi2.fds_inst_id)
union
/*clause for the base level minus the class and inst levels*/
select bd.dd_table_name,NULL,NULL,fc.fds_class_name,fi.fds_inst_name,
  bd.dd_table_desc
from hs$_base_dd bd, hs$_fds_class fc, hs$_fds_inst fi
where fi.fds_class_id = fc.fds_class_id
and not exists
  (select 1 from hs$_class_dd cd2
   where cd2.dd_table_id = bd.dd_table_id
   and cd2.fds_class_id = fc.fds_class_id)
and not exists
  (select 1 from hs$_inst_dd id2
   where id2.dd_table_id = bd.dd_table_id
   and id2.fds_inst_id = fi.fds_inst_id);

grant select on  hs_all_dd to hs_admin_select_role;

create or replace public synonym hs_all_dd for hs_all_dd;

-- 
--#############################################################################
-- 
--#############################################################################
-- 
-- HS_ALL_INITS
-- This view shows all of the init values for a given class and inst.  Inst
-- level inits override inits defined at the class level.

create or replace view hs_all_inits
(init_value_name,init_value,init_value_type,fds_class_name,
fds_inst_name) as
/*this clause for the inst level inits*/
select i.init_value_name,i.init_value,i.init_value_type,fc.fds_class_name,
  fi.fds_inst_name
from hs$_inst_init i, hs$_fds_class fc, hs$_fds_inst fi
where i.fds_inst_id = fi.fds_inst_id
and fi.fds_class_id = fc.fds_class_id 
union
/*this clause for the class level inits*/
select c.init_value_name,c.init_value,c.init_value_type,fc.fds_class_name,
  fi.fds_inst_name
from hs$_class_init c, hs$_fds_class fc, hs$_fds_inst fi
where fc.fds_class_id = fi.fds_class_id
and fc.fds_class_id = c.fds_class_id
and not exists
  (select 1 from hs$_inst_init i
   where i.fds_inst_id = fi.fds_inst_id
   and i.init_value_name = c.init_value_name);
   
grant select on  hs_all_inits to hs_admin_select_role;

create or replace public synonym hs_all_inits for hs_all_inits;

--  For future use:
--  Maintaining timestamps for date of last use of agents
--  with a particular FDS class and version will permit
--  use of a utility program to automatically purge data from the DD
--  for agents no longer in use.

create table hs$_fds_class_date(
   fds_class_id number not null,
           constraint hs$_fds_class_date_uk1 unique (fds_class_id),
   fds_class_date date);

create or replace view hs_fds_class_date
   (fds_class_name, fds_class_date, fds_class_id)
   as select fc.fds_class_name, fd.fds_class_date, fc.fds_class_id
   from hs$_fds_class fc, hs$_fds_class_date fd
   where fc.fds_class_id = fd.fds_class_id;

grant select on hs_fds_class_date to hs_admin_select_role;

create or replace public synonym hs_fds_class_date for hs_fds_class_date;

-- Install the dbms_hs.package
@@dbmshs
@@prvths.plb

-- Install the dbms_hs_bulk_load package
@@dbmshsld
@@prvthsld.plb



-- Install base capability and DD translation definitions.
-- These are required at all times for reference by the kernel
-- and by dbms_hs functions.

begin
/*-------------------------------*/
/*  Base capability definitions  */
/*-------------------------------*/

  dbms_hs.replace_base_caps(1, 1, 'op1 > op2');
  dbms_hs.replace_base_caps(2, 2, 'op1 < op2');
  dbms_hs.replace_base_caps(3, 3, 'op1 >= op2');
  dbms_hs.replace_base_caps(4, 4, 'op1 <= op2');
  dbms_hs.replace_base_caps(5, 5, 'op1 = op2');
  dbms_hs.replace_base_caps(6, 6, 'op1 <> op2');
  dbms_hs.replace_base_caps(7, 7, 'INTERSECT');
  dbms_hs.replace_base_caps(8, 8, 'UNION');
  dbms_hs.replace_base_caps(9, 9, 'MINUS');
  dbms_hs.replace_base_caps(10, 10, 'op1 + op2 (arithmetic)');
  dbms_hs.replace_base_caps(11, 11, 'op1 - op2 (arithmetic)');
  dbms_hs.replace_base_caps(12, 12, 'op1 * op2 (arithmetic)');
  dbms_hs.replace_base_caps(13, 13, 'op1 / op2 (arithmetic)');
  dbms_hs.replace_base_caps(14, 14, '-op1 (arithmetic)');
  dbms_hs.replace_base_caps(15, 15, 'AVG(op1)');
  dbms_hs.replace_base_caps(16, 16, 'AVG(op1, op2)');
  dbms_hs.replace_base_caps(17, 17, 'SUM(op1)');
  dbms_hs.replace_base_caps(18, 18, 'SUM(op1, op2)');
  dbms_hs.replace_base_caps(19, 19, 'COUNT(op1)');
  dbms_hs.replace_base_caps(20, 20, 'COUNT(op1, op2)');
  dbms_hs.replace_base_caps(21, 21, 'MIN(op1)');
  dbms_hs.replace_base_caps(22, 22, 'MIN(op1, op2)');
  dbms_hs.replace_base_caps(23, 23, 'MAX(op1)');
  dbms_hs.replace_base_caps(24, 24, 'MAX(op1, op2)');
  dbms_hs.replace_base_caps(25, 25, 'DESC (descending)');
  dbms_hs.replace_base_caps(26, 26, 'TO_NUMBER(op1)');
  dbms_hs.replace_base_caps(27, 27, 'TO_NUMBER(op1, op2)');
  dbms_hs.replace_base_caps(28, 28, 'TO_NUMBER(op1, op2, op3)');
  dbms_hs.replace_base_caps(29, 29, 'TO_CHAR(op1)');
  dbms_hs.replace_base_caps(30, 30, 'TO_CHAR(op1, op2)');
  dbms_hs.replace_base_caps(31, 31, 'TO_CHAR(op1, op2, op3)');
  dbms_hs.replace_base_caps(32, 32, 'NVL(op1, op2)');
  dbms_hs.replace_base_caps(33, 33, 'CHARTOROWID(op1)');
  dbms_hs.replace_base_caps(34, 34, 'ROWIDTOCHAR(op1)');
  dbms_hs.replace_base_caps(35, 35, 'op1 LIKE op2');
  dbms_hs.replace_base_caps(36, 36, 'op1 NOT LIKE op2');
  dbms_hs.replace_base_caps(37, 37, 'op1 || op2');
  dbms_hs.replace_base_caps(38, 38, 'SUBSTR(op1, op2)');
  dbms_hs.replace_base_caps(39, 39, 'SUBSTR(op1, op2, op3)');
  dbms_hs.replace_base_caps(40, 40, 'LENGTH(op1)');
  dbms_hs.replace_base_caps(41, 41, 'INSTR(op1, op2)');
  dbms_hs.replace_base_caps(42, 42, 'INSTR(op1, op2, op3)');
  dbms_hs.replace_base_caps(43, 43, 'INSTR(op1, op2, op3, op4)');
  dbms_hs.replace_base_caps(44, 44, 'LOWER(op1)');
  dbms_hs.replace_base_caps(45, 45, 'UPPER(op1)');
  dbms_hs.replace_base_caps(46, 46, 'ASCII(op1)');
  dbms_hs.replace_base_caps(47, 47, 'CHR(op1)');
  dbms_hs.replace_base_caps(48, 48, 'SOUNDEX(op1)');
  dbms_hs.replace_base_caps(49, 49, 'ROUND(op1)');
  dbms_hs.replace_base_caps(50, 50, 'ROUND(op1, op2)');
  dbms_hs.replace_base_caps(51, 51, 'TRUNC(op1)');
  dbms_hs.replace_base_caps(52, 52, 'TRUNC(op1, op2)');
  dbms_hs.replace_base_caps(53, 53, 'MOD(op1, op2)');
  dbms_hs.replace_base_caps(54, 54, 'ABS(op1)');
  dbms_hs.replace_base_caps(55, 55, 'SIGN(op1)');
  dbms_hs.replace_base_caps(56, 56, 'VSIZE(op1)');
  dbms_hs.replace_base_caps(57, 57, 'op1 IS NULL');
  dbms_hs.replace_base_caps(58, 58, 'op1 IS NOT NULL');
  dbms_hs.replace_base_caps(59, 59, 'op1 + op2 (date + number)');
  dbms_hs.replace_base_caps(60, 60, 'op1 - op2 (date - number)');
  dbms_hs.replace_base_caps(61, 61, 'op1 - op2 (date - date)');
  dbms_hs.replace_base_caps(62, 62, 'ADD_MONTHS(op1, op2)');
  dbms_hs.replace_base_caps(63, 63, 'MONTHS_BETWEEN(op1, op2)');
  dbms_hs.replace_base_caps(64, 64, 'TO_DATE(op1)');
  dbms_hs.replace_base_caps(65, 65, 'TO_DATE(op1, op2)');
  dbms_hs.replace_base_caps(66, 66, 'TO_DATE(op1, op2, op3)');
  dbms_hs.replace_base_caps(67, 67, 'SYSDATE');
  dbms_hs.replace_base_caps(68, 68, 'LAST_DAY(op1)');
  dbms_hs.replace_base_caps(69, 69, 'NEW_TIME(op1, op2, op3)');
  dbms_hs.replace_base_caps(70, 70, 'NEXT_DAY(op1, op2)');
  dbms_hs.replace_base_caps(71, 71, 'Internal date-related conversion');
  dbms_hs.replace_base_caps(72, 72, 'Internal date-related conversion');
  dbms_hs.replace_base_caps(73, 73, 'Internal date-related conversion');
  dbms_hs.replace_base_caps(74, 74, 'TO_CHAR(op1) (date to string');
  dbms_hs.replace_base_caps(75, 75, 'TO_CHAR(op1, op2) (date to string)');
  dbms_hs.replace_base_caps(76, 76, 'TO_CHAR(op1, op2, op3) date to str');
  dbms_hs.replace_base_caps(77, 77, '');
  dbms_hs.replace_base_caps(78, 78, '');
  dbms_hs.replace_base_caps(79, 79, '');
  dbms_hs.replace_base_caps(80, 80, '');
  dbms_hs.replace_base_caps(81, 81, '');
  dbms_hs.replace_base_caps(82, 82, '');
  dbms_hs.replace_base_caps(83, 83, '');
  dbms_hs.replace_base_caps(84, 84, '');
  dbms_hs.replace_base_caps(85, 85, '');
  dbms_hs.replace_base_caps(86, 86, '');
  dbms_hs.replace_base_caps(87, 87, '');
  dbms_hs.replace_base_caps(88, 88, '');
  dbms_hs.replace_base_caps(89, 89, '');
  dbms_hs.replace_base_caps(90, 90, '');
  dbms_hs.replace_base_caps(91, 91, '');
  dbms_hs.replace_base_caps(92, 92, 'DUMP(op1)');
  dbms_hs.replace_base_caps(93, 93, 'DUMP(op1, op2)');
  dbms_hs.replace_base_caps(94, 94, 'DUMP(op1, op2, op3)');
  dbms_hs.replace_base_caps(95, 95, 'DUMP(op1, op2, op3, op4)');
  dbms_hs.replace_base_caps(96, 96, '');
  dbms_hs.replace_base_caps(97, 97, 'ROUND(op1) (date)');
  dbms_hs.replace_base_caps(98, 98, 'ROUND(op1, op2) (date)');
  dbms_hs.replace_base_caps(99, 99, 'TRUNC(op1) (date)');
  dbms_hs.replace_base_caps(100, 100, 'TRUNC(op1, op2) (date)');
  dbms_hs.replace_base_caps(101, 101, 'FLOOR(op1)');
  dbms_hs.replace_base_caps(102, 102, 'CEIL(op1)');
  dbms_hs.replace_base_caps(103, 103, 'DECODE(op1, op2, op3)');
  dbms_hs.replace_base_caps(104, 104, 'DECODE(op1, op2, op3, op4)');
  dbms_hs.replace_base_caps(105, 105, 'DECODE');
  dbms_hs.replace_base_caps(106, 106, 'LPAD(op1, op2)');
  dbms_hs.replace_base_caps(107, 107, 'LPAD(op1, op2, op3)');
  dbms_hs.replace_base_caps(108, 108, 'RPAD(op1, op2)');
  dbms_hs.replace_base_caps(109, 109, 'RPAD(op1, op2, op3)');
  dbms_hs.replace_base_caps(110, 110, '');
  dbms_hs.replace_base_caps(111, 111, 'POWER(op1, op2)');
  dbms_hs.replace_base_caps(112, 112, '');
  dbms_hs.replace_base_caps(113, 113, '');
  dbms_hs.replace_base_caps(114, 114, '');
  dbms_hs.replace_base_caps(115, 115, '');
  dbms_hs.replace_base_caps(116, 116, '');
  dbms_hs.replace_base_caps(117, 117, '');
  dbms_hs.replace_base_caps(118, 118, 'INITCAP(op1)');
  dbms_hs.replace_base_caps(119, 119, 'TRANSLATE(op1, op2, op3)');
  dbms_hs.replace_base_caps(120, 120, 'LTRIM(op1)');
  dbms_hs.replace_base_caps(121, 121, 'LTRIM(op1, op2)');
  dbms_hs.replace_base_caps(122, 122, 'RTRIM(op1)');
  dbms_hs.replace_base_caps(123, 123, 'RTRIM(op1, op2)');
  dbms_hs.replace_base_caps(124, 124, 'GREATEST(op1, op2)');
  dbms_hs.replace_base_caps(125, 125, 'GREATEST');
  dbms_hs.replace_base_caps(126, 126, 'LEAST(op1, op2)');
  dbms_hs.replace_base_caps(127, 127, 'LEAST');
  dbms_hs.replace_base_caps(128, 128, 'SQRT(op1)');
  dbms_hs.replace_base_caps(129, 129, 'VARIANCE(op1)');
  dbms_hs.replace_base_caps(130, 130, 'VARIANCE(op1, op2)');
  dbms_hs.replace_base_caps(131, 131, 'STDDEV(op1)');
  dbms_hs.replace_base_caps(132, 132, 'STDDEV(op1, op2)');
  dbms_hs.replace_base_caps(133, 133, 'op1 LIKE op2 (indexed column)');
  dbms_hs.replace_base_caps(134, 134, 'RAWTOHEX(op1)');
  dbms_hs.replace_base_caps(135, 135, 'HEXTORAW(op1)');
  dbms_hs.replace_base_caps(136, 136, '');
  dbms_hs.replace_base_caps(137, 137, 'NOT NVL(op1, op2)');
  dbms_hs.replace_base_caps(138, 138, 'USERENV(op1)');
  dbms_hs.replace_base_caps(139, 139, 'MERGE$ACTIONS');
  dbms_hs.replace_base_caps(140, 140, '');
  dbms_hs.replace_base_caps(141, 141, 'TO_CHAR(op1), (special case)');
  dbms_hs.replace_base_caps(142, 142, '');
  dbms_hs.replace_base_caps(143, 143, 'BITAND(op1, op2)');
  dbms_hs.replace_base_caps(144, 144, 'CONVERT(op1, op2)');
  dbms_hs.replace_base_caps(145, 145, 'CONVERT(op1, op2, op3)');
  dbms_hs.replace_base_caps(146, 146, 'REPLACE(op1, op2)');
  dbms_hs.replace_base_caps(147, 147, 'REPLACE(op1, op2, op3)');
  dbms_hs.replace_base_caps(148, 148, 'NLSSORT(op1)');
  dbms_hs.replace_base_caps(149, 149, 'NLSSORT(op1, op2)');
  dbms_hs.replace_base_caps(150, 150, '');
  dbms_hs.replace_base_caps(151, 151, '');
  dbms_hs.replace_base_caps(152, 152, '');
  dbms_hs.replace_base_caps(153, 153, 'op1 LIKE op2 ESCAPE op3');
  dbms_hs.replace_base_caps(154, 154, 'op1 NOT LIKE op2 ESCAPE op3');
  dbms_hs.replace_base_caps(155, 155, 'UNION ALL');
  dbms_hs.replace_base_caps(156, 156, 'COS(op1)');
  dbms_hs.replace_base_caps(157, 157, 'SIN(op1)');
  dbms_hs.replace_base_caps(158, 158, 'TAN(op1)');
  dbms_hs.replace_base_caps(159, 159, 'COSH(op1)');
  dbms_hs.replace_base_caps(160, 160, 'SINH(op1)');
  dbms_hs.replace_base_caps(161, 161, 'TANH(op1)');
  dbms_hs.replace_base_caps(162, 162, 'EXP(op1)');
  dbms_hs.replace_base_caps(163, 163, 'LN(op1)');
  dbms_hs.replace_base_caps(164, 164, 'LOG(op1)');
  dbms_hs.replace_base_caps(165, 165, '');
  dbms_hs.replace_base_caps(166, 166, 'op1 > op2');
  dbms_hs.replace_base_caps(167, 167, 'op1 < op2');
  dbms_hs.replace_base_caps(168, 168, 'op1 >= op2');
  dbms_hs.replace_base_caps(169, 169, 'op1 <= op2');
  dbms_hs.replace_base_caps(170, 170, 'op1 = op2');
  dbms_hs.replace_base_caps(171, 171, 'op1 <> op2');
  dbms_hs.replace_base_caps(172, 172, '');
  dbms_hs.replace_base_caps(173, 173, '');
  dbms_hs.replace_base_caps(174, 174, 'TO_SINGLE_BYTE(op1');
  dbms_hs.replace_base_caps(175, 175, 'TO_MULTI_BYTE(op1)');
  dbms_hs.replace_base_caps(176, 176, 'NLS_LOWER(op1)');
  dbms_hs.replace_base_caps(177, 177, 'NLS_UPPER(op1)');
  dbms_hs.replace_base_caps(178, 178, 'NLS_INITCAP(op1)');
  dbms_hs.replace_base_caps(179, 179, 'INSTRB(op1, op2)');
  dbms_hs.replace_base_caps(180, 180, 'INSTRB(op1, op2, op3)');
  dbms_hs.replace_base_caps(181, 181, 'INSTRB(op1, op2, op3, op4)');
  dbms_hs.replace_base_caps(182, 182, 'LENGTHB(op1)');
  dbms_hs.replace_base_caps(183, 183, 'SUBSTRB(op1, op2)');
  dbms_hs.replace_base_caps(184, 184, 'SUBSTRB(op1, op2, op3)');
  dbms_hs.replace_base_caps(185, 185, '');
  dbms_hs.replace_base_caps(186, 186, '');
  dbms_hs.replace_base_caps(187, 187, 'XMLPARSE(..)');
  dbms_hs.replace_base_caps(188, 188, '');
  dbms_hs.replace_base_caps(189, 189, '');
  dbms_hs.replace_base_caps(190, 190, '');
  dbms_hs.replace_base_caps(191, 191, '');
  dbms_hs.replace_base_caps(192, 192, '');
  dbms_hs.replace_base_caps(193, 193, '');
  dbms_hs.replace_base_caps(194, 194, 'LUB(op1)');
  dbms_hs.replace_base_caps(195, 195, 'GLB(op1)');
  dbms_hs.replace_base_caps(196, 196, 'LEAST_UB(op1, op2)');
  dbms_hs.replace_base_caps(197, 197, 'LEAST_UB');
  dbms_hs.replace_base_caps(198, 198, 'GREATEST_LB(op1, op2)');
  dbms_hs.replace_base_caps(199, 199, 'GREATEST_LB');
  dbms_hs.replace_base_caps(200, 200, '');
  dbms_hs.replace_base_caps(201, 201, '');
  dbms_hs.replace_base_caps(202, 202, '');
  dbms_hs.replace_base_caps(203, 203, '');
  dbms_hs.replace_base_caps(204, 204, '');
  dbms_hs.replace_base_caps(205, 205, '');
  dbms_hs.replace_base_caps(206, 206, '');
  dbms_hs.replace_base_caps(207, 207, 'NVL2(op1, op2, op3)');
  dbms_hs.replace_base_caps(208, 208, 'REVERSE(op1)');
  dbms_hs.replace_base_caps(209, 209, 'NLS_LOWER(op1, op2)');
  dbms_hs.replace_base_caps(210, 210, 'NLS_UPPER(op1, op2)');
  dbms_hs.replace_base_caps(211, 211, 'NLS_INITCAP(op1, op2)');
  dbms_hs.replace_base_caps(212, 212, '');
  dbms_hs.replace_base_caps(213, 213, '');
  dbms_hs.replace_base_caps(214, 214, '');
  dbms_hs.replace_base_caps(215, 215, '');
  dbms_hs.replace_base_caps(216, 216, '');
  dbms_hs.replace_base_caps(217, 217, 'op1 > op2');
  dbms_hs.replace_base_caps(218, 218, 'op1 < op2');
  dbms_hs.replace_base_caps(219, 219, 'op1 >= op2');
  dbms_hs.replace_base_caps(220, 220, 'op1 <= op2');
  dbms_hs.replace_base_caps(221, 221, 'op1 = op2');
  dbms_hs.replace_base_caps(222, 222, 'op1 <> op2');
  dbms_hs.replace_base_caps(223, 223, '');
  dbms_hs.replace_base_caps(224, 224, '');
  dbms_hs.replace_base_caps(225, 225, '');
  dbms_hs.replace_base_caps(226, 226, '');
  dbms_hs.replace_base_caps(227, 227, '');
  dbms_hs.replace_base_caps(228, 228, '');
  dbms_hs.replace_base_caps(229, 229, '');
  dbms_hs.replace_base_caps(230, 230, '');
  dbms_hs.replace_base_caps(231, 231, '');
  dbms_hs.replace_base_caps(232, 232, 'OPTPLS');
  dbms_hs.replace_base_caps(233, 233, 'ASIN(op1)');
  dbms_hs.replace_base_caps(234, 234, 'ACOS(op1)');
  dbms_hs.replace_base_caps(235, 235, 'ATAN(op1)');
  dbms_hs.replace_base_caps(236, 236, 'ATAN2(op1, op2)');
  dbms_hs.replace_base_caps(237, 237, '');
  dbms_hs.replace_base_caps(238, 238, 'SYS_OP_ATG(op1, op2, op3, op4)');
  dbms_hs.replace_base_caps(239, 239, '');
  dbms_hs.replace_base_caps(240, 240, '');
  dbms_hs.replace_base_caps(241, 241, '');
  dbms_hs.replace_base_caps(242, 242, '');
  dbms_hs.replace_base_caps(243, 243, 'CURSOR(op1)');
  dbms_hs.replace_base_caps(244, 244, '');
  dbms_hs.replace_base_caps(245, 245, 'DEREF(op1)');
  dbms_hs.replace_base_caps(246, 246, 'BLOB()');
  dbms_hs.replace_base_caps(247, 247, 'CLOB()');
  dbms_hs.replace_base_caps(248, 248, '');
  dbms_hs.replace_base_caps(249, 249, '');
  dbms_hs.replace_base_caps(250, 250, '');
  dbms_hs.replace_base_caps(251, 251, '');
  dbms_hs.replace_base_caps(252, 252, 'SYS_OP_MOID(op1)');
  dbms_hs.replace_base_caps(253, 253, 'MAKE_REF(op1)');
  dbms_hs.replace_base_caps(254, 254, 'SYS_OP_NIX(op1, op2)');
  dbms_hs.replace_base_caps(255, 255, 'SYS_OP_DUMP(op1)');
  dbms_hs.replace_base_caps(256, 256, '');
  dbms_hs.replace_base_caps(257, 257, 'REFTOHEX(op1)');
  dbms_hs.replace_base_caps(258, 258, '');
  dbms_hs.replace_base_caps(259, 259, '');
  dbms_hs.replace_base_caps(260, 260, 'SYS_OP_TOSETID(op1)');
  dbms_hs.replace_base_caps(261, 261, '');
  dbms_hs.replace_base_caps(262, 262, '');
  dbms_hs.replace_base_caps(263, 263, '');
  dbms_hs.replace_base_caps(264, 264, '');
  dbms_hs.replace_base_caps(265, 265, '');
  dbms_hs.replace_base_caps(266, 266, '');
  dbms_hs.replace_base_caps(267, 267, '');
  dbms_hs.replace_base_caps(268, 268, 'op1 IS DANGLING');
  dbms_hs.replace_base_caps(269, 269, 'op1 IS NOT DANGLING');
  dbms_hs.replace_base_caps(270, 270, 'SYS_OP_R20(op1)');
  dbms_hs.replace_base_caps(271, 271, 'EMPTY_BLOB()');
  dbms_hs.replace_base_caps(272, 272, 'EMPTY_CLOB()');
  dbms_hs.replace_base_caps(273, 273, '');
  dbms_hs.replace_base_caps(274, 274, '');
  dbms_hs.replace_base_caps(275, 275, '');
  dbms_hs.replace_base_caps(276, 276, '');
  dbms_hs.replace_base_caps(277, 277, '');
  dbms_hs.replace_base_caps(278, 278, 'SYS_OP_RMTD(op1, op2, op3)');
  dbms_hs.replace_base_caps(279, 279, '');
  dbms_hs.replace_base_caps(280, 280, 'SYS_OP_OIDVALUE(op1, op2, op3)');
  dbms_hs.replace_base_caps(281, 281, '');
  dbms_hs.replace_base_caps(282, 282, 'BFILENAME(op1, op2)');
  dbms_hs.replace_base_caps(283, 283, 'CSCONVERT(op1, op2)');
  dbms_hs.replace_base_caps(284, 284, 'NLS_CHARSET_NAME(op1)');
  dbms_hs.replace_base_caps(285, 285, 'NLS_CHARSET_ID(op1)');
  dbms_hs.replace_base_caps(286, 286, '');
  dbms_hs.replace_base_caps(287, 287, 'SYS_OP_LSVI(op1, op2, op3)');
  dbms_hs.replace_base_caps(288, 288, '');
  dbms_hs.replace_base_caps(289, 289, '');
  dbms_hs.replace_base_caps(290, 290, '');
  dbms_hs.replace_base_caps(291, 291, '');
  dbms_hs.replace_base_caps(292, 292, 'SYS_OP_MSR(op1)');
  dbms_hs.replace_base_caps(293, 293, 'SYS_OP_CSR(op1)');
  dbms_hs.replace_base_caps(294, 294, '');
  dbms_hs.replace_base_caps(295, 295, '');
  dbms_hs.replace_base_caps(296, 296, 'TRIM(op1)');
  dbms_hs.replace_base_caps(297, 297, 'TRIM(op1 FROM op2)');
  dbms_hs.replace_base_caps(298, 298, 'TRIM(LEADING op1)');
  dbms_hs.replace_base_caps(299, 299, 'TRIM(LEADING op1 FROM op2)');
  dbms_hs.replace_base_caps(300, 300, 'TRIM(TRAILING op1)');
  dbms_hs.replace_base_caps(301, 301, 'TRIM(TRAILING op1 FROM op2)');
  dbms_hs.replace_base_caps(302, 302, 'SYS_OP_RPB(op1)');
  dbms_hs.replace_base_caps(303, 303, '');
  dbms_hs.replace_base_caps(304, 304, 'SYS_OP_DESCEND(op1)');
  dbms_hs.replace_base_caps(305, 305, '');
  dbms_hs.replace_base_caps(306, 306, '');
  dbms_hs.replace_base_caps(307, 307, '');
  dbms_hs.replace_base_caps(308, 308, '');
  dbms_hs.replace_base_caps(309, 309, '');
  dbms_hs.replace_base_caps(310, 310, '');
  dbms_hs.replace_base_caps(311, 311, '');
  dbms_hs.replace_base_caps(312, 312, '');
  dbms_hs.replace_base_caps(313, 313, '');
  dbms_hs.replace_base_caps(314, 314, '');
  dbms_hs.replace_base_caps(315, 315, '');
  dbms_hs.replace_base_caps(316, 316, '');
  dbms_hs.replace_base_caps(317, 317, '');
  dbms_hs.replace_base_caps(318, 318, '');
  dbms_hs.replace_base_caps(319, 319, 'SYS_GUID()');
  dbms_hs.replace_base_caps(320, 320, 'EXTRACT(YEAR FROM op2)');
  dbms_hs.replace_base_caps(321, 321, 'EXTRACT(MONTH FROM op2)');
  dbms_hs.replace_base_caps(322, 322, 'EXTRACT(DAY FROM op2)');
  dbms_hs.replace_base_caps(323, 323, 'EXTRACT(HOUR FROM op2)');
  dbms_hs.replace_base_caps(324, 324, 'EXTRACT(MINUTE FROM op2)');
  dbms_hs.replace_base_caps(325, 325, 'EXTRACT(SECOND FROM op2)');
  dbms_hs.replace_base_caps(326, 326, 'EXTRACT(TIMEZONE_HOUR FROM op2)');
  dbms_hs.replace_base_caps(327, 327, 'EXTRACT(TIMEZONE_MINUTE FROM op2)');
  dbms_hs.replace_base_caps(328, 328, '');
  dbms_hs.replace_base_caps(329, 329, '');
  dbms_hs.replace_base_caps(330, 330, '');
  dbms_hs.replace_base_caps(331, 331, '');
  dbms_hs.replace_base_caps(332, 332, '');
  dbms_hs.replace_base_caps(333, 333, '');
  dbms_hs.replace_base_caps(334, 334, '');
  dbms_hs.replace_base_caps(335, 335, '');
  dbms_hs.replace_base_caps(336, 336, '');
  dbms_hs.replace_base_caps(337, 337, '');
  dbms_hs.replace_base_caps(338, 338, '');
  dbms_hs.replace_base_caps(339, 339, '');
  dbms_hs.replace_base_caps(340, 340, '');
  dbms_hs.replace_base_caps(341, 341, '');
  dbms_hs.replace_base_caps(342, 342, '');
  dbms_hs.replace_base_caps(343, 343, '');
  dbms_hs.replace_base_caps(344, 344, '');
  dbms_hs.replace_base_caps(345, 345, '');
  dbms_hs.replace_base_caps(346, 346, '');
  dbms_hs.replace_base_caps(347, 347, '');
  dbms_hs.replace_base_caps(348, 348, '');
  dbms_hs.replace_base_caps(349, 349, '');
  dbms_hs.replace_base_caps(350, 350, '');
  dbms_hs.replace_base_caps(351, 351, '');
  dbms_hs.replace_base_caps(352, 352, 'TO_TIME(op1)');
  dbms_hs.replace_base_caps(353, 353, 'TO_TIME(op1, op2)');
  dbms_hs.replace_base_caps(354, 354, 'TO_TIME(op1, op2, op3)');
  dbms_hs.replace_base_caps(355, 355, 'TO_TIME_TZ(op1)');
  dbms_hs.replace_base_caps(356, 356, 'TO_TIME_TZ(op1, op2)');
  dbms_hs.replace_base_caps(357, 357, 'TO_TIME_TZ(op1, op2, op3)');
  dbms_hs.replace_base_caps(358, 358, 'TO_TIMESTAMP(op1)');
  dbms_hs.replace_base_caps(359, 359, 'TO_TIMESTAMP(op1, op2)');
  dbms_hs.replace_base_caps(360, 360, 'TO_TIMESTAMP(op1, op2, op3)');
  dbms_hs.replace_base_caps(361, 361, 'TO_TIMESTAMP_TZ(op1)');
  dbms_hs.replace_base_caps(362, 362, 'TO_TIMESTAMP_TZ(op1, op2)');
  dbms_hs.replace_base_caps(363, 363, 'TO_TIMESTAMP_TZ(op1, op2, op3)');
  dbms_hs.replace_base_caps(364, 364, 'TO_YMINTERVAL(op1)');
  dbms_hs.replace_base_caps(365, 365, 'TO_DSINTERVAL(op1)');
  dbms_hs.replace_base_caps(366, 366, 'TO_DSINTERVAL(op1, op2)');
  dbms_hs.replace_base_caps(367, 367, 'NUMTOYMINTERVAL(op1, op2)');
  dbms_hs.replace_base_caps(368, 368, 'NUMTODSINTERVAL(op1, op2)');
  dbms_hs.replace_base_caps(369, 369, 'op1 + op2');
  dbms_hs.replace_base_caps(370, 370, 'op1 - op2');
  dbms_hs.replace_base_caps(371, 371, 'op1 - op2');
  dbms_hs.replace_base_caps(372, 372, 'op1 + op2');
  dbms_hs.replace_base_caps(373, 373, 'op1 - op2');
  dbms_hs.replace_base_caps(374, 374, 'op1 * op2');
  dbms_hs.replace_base_caps(375, 375, 'op1 / op2');
  dbms_hs.replace_base_caps(376, 376, 'op1 AT TIME ZONE op2');
  dbms_hs.replace_base_caps(377, 377, '(op1, op2) OVERLAPS (op3, op4)');
  dbms_hs.replace_base_caps(378, 378, 'NOT((op1, op2) OVERLAPS (op3, op4))');
  dbms_hs.replace_base_caps(379, 379, 'CURRENT_DATE');
  dbms_hs.replace_base_caps(380, 380, 'CURRENT_TIME(op1)');
  dbms_hs.replace_base_caps(381, 381, 'CURRENT_TIMESTAMP(op1)');
  dbms_hs.replace_base_caps(382, 382, 'LOCALTIME(op1)');
  dbms_hs.replace_base_caps(383, 383, 'LOCALTIMESTAMP(op1)');
  dbms_hs.replace_base_caps(384, 384, 'SYSTIMESTAMP(op1)');
  dbms_hs.replace_base_caps(385, 385, '');
  dbms_hs.replace_base_caps(386, 386, '');
  dbms_hs.replace_base_caps(387, 387, '');
  dbms_hs.replace_base_caps(388, 388, '');
  dbms_hs.replace_base_caps(389, 389, '');
  dbms_hs.replace_base_caps(390, 390, '');
  dbms_hs.replace_base_caps(391, 391, 'CAST(op1 AS op2)');
  dbms_hs.replace_base_caps(392, 392, 'SYS_CONTEXT(op1, op2)');
  dbms_hs.replace_base_caps(393, 393, 'SYS_EXTRACT_UTC(op1)');
  dbms_hs.replace_base_caps(394, 394, '');
  dbms_hs.replace_base_caps(395, 395, '');
  dbms_hs.replace_base_caps(396, 396, 'GROUPING(op1)');
  dbms_hs.replace_base_caps(397, 397, '');
  dbms_hs.replace_base_caps(398, 398, '');
  dbms_hs.replace_base_caps(399, 399, '');
  dbms_hs.replace_base_caps(400, 400, '');
  dbms_hs.replace_base_caps(401, 401, 'SYS_OP_MAP_NONNULL(op1)');
  dbms_hs.replace_base_caps(402, 402, '');
  dbms_hs.replace_base_caps(403, 403, '');
  dbms_hs.replace_base_caps(404, 404, '');
  dbms_hs.replace_base_caps(405, 405, '');
  dbms_hs.replace_base_caps(406, 406, '');
  dbms_hs.replace_base_caps(407, 407, '');
  dbms_hs.replace_base_caps(408, 408, '');
  dbms_hs.replace_base_caps(409, 409, '');
  dbms_hs.replace_base_caps(410, 410, '');
  dbms_hs.replace_base_caps(411, 411, 'SUM(op1)');
  dbms_hs.replace_base_caps(412, 412, 'AVG(op1)');
  dbms_hs.replace_base_caps(413, 413, 'COUNT(op1)');
  dbms_hs.replace_base_caps(414, 414, 'COUNT(op1, op2)');
  dbms_hs.replace_base_caps(415, 415, 'VARIANCE(op1)');
  dbms_hs.replace_base_caps(416, 416, 'VARIANCE(op1, op2)');
  dbms_hs.replace_base_caps(417, 417, 'STDDEV(op1)');
  dbms_hs.replace_base_caps(418, 418, 'STDDEV(op1, op2)');
  dbms_hs.replace_base_caps(419, 419, 'MIN(op1)');
  dbms_hs.replace_base_caps(420, 420, 'MAX(op1)');
  dbms_hs.replace_base_caps(421, 421, 'FIRST_VALUE(op1)');
  dbms_hs.replace_base_caps(422, 422, 'LAST_VALUE(op1)');
  dbms_hs.replace_base_caps(423, 423, 'LAG(op1)');
  dbms_hs.replace_base_caps(424, 424, 'LAG(op1, op2)');
  dbms_hs.replace_base_caps(425, 425, 'LAG(op1, op2, op3)');
  dbms_hs.replace_base_caps(426, 426, 'LEAD(op1)');
  dbms_hs.replace_base_caps(427, 427, 'LEAD(op1, op2)');
  dbms_hs.replace_base_caps(428, 428, 'LEAD(op1, op2, op3)');
  dbms_hs.replace_base_caps(429, 429, 'RANK()');
  dbms_hs.replace_base_caps(430, 430, 'DENSE_RANK()');
  dbms_hs.replace_base_caps(431, 431, '');
  dbms_hs.replace_base_caps(432, 432, 'NTILE()');
  dbms_hs.replace_base_caps(433, 433, 'RATIO_TO_REPORT()');
  dbms_hs.replace_base_caps(434, 434, 'ROW_NUMBER()');
  dbms_hs.replace_base_caps(435, 435, '');
  dbms_hs.replace_base_caps(436, 436, '');
  dbms_hs.replace_base_caps(437, 437, 'op1 DESC');
  dbms_hs.replace_base_caps(438, 438, 'op1 DESC NULLS LAST');
  dbms_hs.replace_base_caps(439, 439, 'op1 ASC NULLS FIRST');
  dbms_hs.replace_base_caps(440, 440, '');
  dbms_hs.replace_base_caps(441, 441, '');
  dbms_hs.replace_base_caps(442, 442, '');
  dbms_hs.replace_base_caps(443, 443, '');
  dbms_hs.replace_base_caps(444, 444, '');
  dbms_hs.replace_base_caps(445, 445, '');
  dbms_hs.replace_base_caps(446, 446, '');
  dbms_hs.replace_base_caps(447, 447, '');
  dbms_hs.replace_base_caps(448, 448, '');
  dbms_hs.replace_base_caps(449, 449, '');
  dbms_hs.replace_base_caps(450, 450, '');
  dbms_hs.replace_base_caps(451, 451, '');
  dbms_hs.replace_base_caps(452, 452, '');
  dbms_hs.replace_base_caps(453, 453, '');
  dbms_hs.replace_base_caps(454, 454, '');
  dbms_hs.replace_base_caps(455, 455, '');
  dbms_hs.replace_base_caps(456, 456, '');
  dbms_hs.replace_base_caps(457, 457, '');
  dbms_hs.replace_base_caps(458, 458, '');
  dbms_hs.replace_base_caps(459, 459, '');
  dbms_hs.replace_base_caps(460, 460, 'SESSIONTIMEZONE()');
  dbms_hs.replace_base_caps(461, 461, '');
  dbms_hs.replace_base_caps(462, 462, '');
  dbms_hs.replace_base_caps(463, 463, '');
  dbms_hs.replace_base_caps(464, 464, '');
  dbms_hs.replace_base_caps(465, 465, '');
  dbms_hs.replace_base_caps(466, 466, '');
  dbms_hs.replace_base_caps(467, 467, '');
  dbms_hs.replace_base_caps(468, 468, '');
  dbms_hs.replace_base_caps(469, 469, '');
  dbms_hs.replace_base_caps(470, 470, '');
  dbms_hs.replace_base_caps(471, 471, '');
  dbms_hs.replace_base_caps(472, 472, '');
  dbms_hs.replace_base_caps(473, 473, '');
  dbms_hs.replace_base_caps(474, 474, '');
  dbms_hs.replace_base_caps(475, 475, '');
  dbms_hs.replace_base_caps(476, 476, 'FROM_TZ(op1, op2)');
  dbms_hs.replace_base_caps(477, 477, 'PATH(op1, op2)');
  dbms_hs.replace_base_caps(478, 478, '');
  dbms_hs.replace_base_caps(479, 479, '');
  dbms_hs.replace_base_caps(480, 480, '');
  dbms_hs.replace_base_caps(481, 481, '');
  dbms_hs.replace_base_caps(482, 482, '');
  dbms_hs.replace_base_caps(483, 483, '');
  dbms_hs.replace_base_caps(484, 484, '');
  dbms_hs.replace_base_caps(485, 485, '');
  dbms_hs.replace_base_caps(486, 486, '');
  dbms_hs.replace_base_caps(487, 487, '');
  dbms_hs.replace_base_caps(488, 488, 'NULLIF(op1, op2)');
  dbms_hs.replace_base_caps(489, 489, 'COALESCE(op1, op2)');
  dbms_hs.replace_base_caps(490, 490, 'LENGTH(op1)');
  dbms_hs.replace_base_caps(491, 491, 'LENGTHB(op1)');
  dbms_hs.replace_base_caps(492, 492, 'SUBSTR(op1, op2)');
  dbms_hs.replace_base_caps(493, 493, 'SUBSTR(op1, op2, op3)');
  dbms_hs.replace_base_caps(494, 494, 'SUBSTRB(op1, op2)');
  dbms_hs.replace_base_caps(495, 495, 'SUBSTRB(op1, op2, op3)');
  dbms_hs.replace_base_caps(496, 496, 'INSTR(op1, op2)');
  dbms_hs.replace_base_caps(497, 497, 'INSTR(op1, op2, op3)');
  dbms_hs.replace_base_caps(498, 498, 'INSTR(op1, op2, op3, op4)');
  dbms_hs.replace_base_caps(499, 499, 'INSTRB(op1, op2)');
  dbms_hs.replace_base_caps(500, 500, 'INSTRB(op1, op2, op3)');
  dbms_hs.replace_base_caps(501, 501, 'INSTRB(op1, op2, op3, op4)');
  dbms_hs.replace_base_caps(502, 502, 'op1 || op2');
  dbms_hs.replace_base_caps(503, 503, 'LPAD(op1, op2)');
  dbms_hs.replace_base_caps(504, 504, 'LPAD(op1, op2, op3)');
  dbms_hs.replace_base_caps(505, 505, 'RPAD(op1, op2)');
  dbms_hs.replace_base_caps(506, 506, 'RPAD(op1, op2, op3)');
  dbms_hs.replace_base_caps(507, 507, 'LTRIM(op1)');
  dbms_hs.replace_base_caps(508, 508, 'LTRIM(op1, op2)');
  dbms_hs.replace_base_caps(509, 509, 'RTRIM(op1)');
  dbms_hs.replace_base_caps(510, 510, 'RTRIM(op1, op2)');
  dbms_hs.replace_base_caps(511, 511, 'TRIM(op1)');
  dbms_hs.replace_base_caps(512, 512, 'TRIM(op1 FROM op2)');
  dbms_hs.replace_base_caps(513, 513, 'LOWER(op1)');
  dbms_hs.replace_base_caps(514, 514, 'UPPER(op1)');
  dbms_hs.replace_base_caps(515, 515, 'NLS_LOWER(op1)');
  dbms_hs.replace_base_caps(516, 516, 'NLS_LOWER(op1, op2)');
  dbms_hs.replace_base_caps(517, 517, 'NLS_UPPER(op1)');
  dbms_hs.replace_base_caps(518, 518, 'NLS_UPPER(op1, op2)');
  dbms_hs.replace_base_caps(519, 519, 'NVL(op1, op2)');
  dbms_hs.replace_base_caps(520, 520, 'op1 LIKE op2');
  dbms_hs.replace_base_caps(521, 521, 'op1 NOT LIKE op2');
  dbms_hs.replace_base_caps(522, 522, 'REPLACE(op1, op2)');
  dbms_hs.replace_base_caps(523, 523, 'REPLACE(op1, op2, op3)');
  dbms_hs.replace_base_caps(524, 524, 'CLOB_TO_CHAR(op1)');
  dbms_hs.replace_base_caps(525, 525, 'PERCENTILE_CONT(op1)');
  dbms_hs.replace_base_caps(526, 526, 'PERCENTILE_DISC(op1)');
  dbms_hs.replace_base_caps(527, 527, 'RANK(op1)');
  dbms_hs.replace_base_caps(528, 528, 'DENSE_RANK(op1)');
  dbms_hs.replace_base_caps(529, 529, 'PERCENT_RANK(op1)');
  dbms_hs.replace_base_caps(530, 530, 'CUME_DIST(op1)');
  dbms_hs.replace_base_caps(531, 531, 'First/Last function');
  dbms_hs.replace_base_caps(532, 532, '');
  dbms_hs.replace_base_caps(533, 533, 'WIDTH_BUCKETop1, op2, op3, op4)');
  dbms_hs.replace_base_caps(534, 534, 'RANKM(op1)');
  dbms_hs.replace_base_caps(535, 535, 'DENSE_RANKM(op1)');
  dbms_hs.replace_base_caps(536, 536, 'PERCENT_RANKM(op1)');
  dbms_hs.replace_base_caps(537, 537, 'CUME_DISTM(op1)');
  dbms_hs.replace_base_caps(538, 538, 'FIRSTM(op1)');
  dbms_hs.replace_base_caps(539, 539, 'PERCENTILE_CONT(op1)');
  dbms_hs.replace_base_caps(540, 540, 'PERCENTILE_DISC(op1)');
  dbms_hs.replace_base_caps(541, 541, '');
  dbms_hs.replace_base_caps(542, 542, 'VECOR(op1, op2)');
  dbms_hs.replace_base_caps(543, 543, 'VECXOR(op1, op2)');
  dbms_hs.replace_base_caps(544, 544, 'VECAND(op1,op2)');
  dbms_hs.replace_base_caps(545, 545, 'GROUPING_ID(...)');
  dbms_hs.replace_base_caps(546, 546, 'GROUP_ID()');
  dbms_hs.replace_base_caps(547, 547, 'BIN_TO_NUM(...)');
  dbms_hs.replace_base_caps(548, 548, '');
  dbms_hs.replace_base_caps(549, 549, '');
  dbms_hs.replace_base_caps(550, 550, '');
  dbms_hs.replace_base_caps(551, 551, '');
  dbms_hs.replace_base_caps(552, 552, '');
  dbms_hs.replace_base_caps(553, 553, '');
  dbms_hs.replace_base_caps(554, 554, '');
  dbms_hs.replace_base_caps(555, 555, '');
  dbms_hs.replace_base_caps(556, 556, '');
  dbms_hs.replace_base_caps(557, 557, '');
  dbms_hs.replace_base_caps(558, 558, 'TZ_OFFSET(op1');
  dbms_hs.replace_base_caps(559, 559, 'ADJ_DATE(?)');
  dbms_hs.replace_base_caps(560, 560, 'SESSIONTZNAME');
  dbms_hs.replace_base_caps(561, 561, '');
  dbms_hs.replace_base_caps(562, 562, '');
  dbms_hs.replace_base_caps(563, 563, 'ROWIDTONCHAR(op1)');
  dbms_hs.replace_base_caps(564, 564, 'TO_NCHAR(op1)');
  dbms_hs.replace_base_caps(565, 565, 'TO_NCHAR(op1,op2)');
  dbms_hs.replace_base_caps(566, 566, 'TO_NCHAR(op1,op2,op3)');
  dbms_hs.replace_base_caps(567, 567, 'RAWTONHEX(op1)');
  dbms_hs.replace_base_caps(568, 568, 'NCHR(op1)');
  dbms_hs.replace_base_caps(569, 569, '');
  dbms_hs.replace_base_caps(570, 570, '');
  dbms_hs.replace_base_caps(571, 571, '');
  dbms_hs.replace_base_caps(572, 572, '');
  dbms_hs.replace_base_caps(573, 573, 'COMPOSE(op1)');
  dbms_hs.replace_base_caps(574, 574, 'DECOMPOSE(op1)');
  dbms_hs.replace_base_caps(575, 575, 'ASCIISTR(op1)');
  dbms_hs.replace_base_caps(576, 576, 'UNISTR(op1)');
  dbms_hs.replace_base_caps(577, 577, 'LENGTH2(op1)');
  dbms_hs.replace_base_caps(578, 578, 'LENGTH4(op1)');
  dbms_hs.replace_base_caps(579, 579, 'LENGTHC(op1)');
  dbms_hs.replace_base_caps(580, 580, 'INSTR2(op1,op2)');
  dbms_hs.replace_base_caps(581, 581, 'INSTR2(op1,op2,op3)');
  dbms_hs.replace_base_caps(582, 582, 'INSTR2(op1,op2,op3,op4)');
  dbms_hs.replace_base_caps(583, 583, 'INSTR4(op1,op2)');
  dbms_hs.replace_base_caps(584, 584, 'INSTR4(op1,op2,op3)');
  dbms_hs.replace_base_caps(585, 585, 'INSTR4(op1,op2,op3,op4)');
  dbms_hs.replace_base_caps(586, 586, 'INSTRC(op1,op2)');
  dbms_hs.replace_base_caps(587, 587, 'INSTRC(op1,op2,op3)');
  dbms_hs.replace_base_caps(588, 588, 'INSTRC(op1,op2,op3,op4)');
  dbms_hs.replace_base_caps(589, 589, 'SUBSTR2(op1,op2)');
  dbms_hs.replace_base_caps(590, 590, 'SUBSTR2(op1,op2,op3)');
  dbms_hs.replace_base_caps(591, 591, 'SUBSTR4(op1,op2)');
  dbms_hs.replace_base_caps(592, 592, 'SUBSTR4(op1,op2,op3)');
  dbms_hs.replace_base_caps(593, 593, 'SUBSTRC(op1,op2)');
  dbms_hs.replace_base_caps(594, 594, 'SUBSTRC(op1,op2,op3)');
  dbms_hs.replace_base_caps(595, 595, 'op1 LIKE2 op2');
  dbms_hs.replace_base_caps(596, 596, 'op1 NOT LIKE2 op2');
  dbms_hs.replace_base_caps(597, 597, 'op1 LIKE2 op2 ESCAPE op3');
  dbms_hs.replace_base_caps(598, 598, 'op1 NOT LIKE2 op2 ESCAPE op3');
  dbms_hs.replace_base_caps(599, 599, 'op1 LIKE4 op2');
  dbms_hs.replace_base_caps(600, 600, 'op1 NOT LIKE4 op2');
  dbms_hs.replace_base_caps(601, 601, 'op1 LIKE4 op2 ESCAPE op3');
  dbms_hs.replace_base_caps(602, 602, 'op1 NOT LIKE4 op2 ESCAPE op3');
  dbms_hs.replace_base_caps(603, 603, 'op1 LIKEC op2');
  dbms_hs.replace_base_caps(604, 604, 'op1 NOT LIKEC op2');
  dbms_hs.replace_base_caps(605, 605, 'op1 LIKEC op2 ESCAPE op3');
  dbms_hs.replace_base_caps(606, 606, 'op1 NOT LIKEC op2 ESCAPE op3');
  dbms_hs.replace_base_caps(607, 607, '');
  dbms_hs.replace_base_caps(608, 608, '');
  dbms_hs.replace_base_caps(609, 609, '');
  dbms_hs.replace_base_caps(610, 610, '');
  dbms_hs.replace_base_caps(611, 611, 'CONVERT(op1, op2)');
  dbms_hs.replace_base_caps(612, 612, 'CONVERT(op1, op2, op3)');
  dbms_hs.replace_base_caps(1000, 1000, 'multicolumn: (a,b,c)=');
  dbms_hs.replace_base_caps(1001, 1001, 'join');
  dbms_hs.replace_base_caps(1002, 1002, 'outer join');
  dbms_hs.replace_base_caps(1003, 1003, 'delimited IDs: "id"');
  dbms_hs.replace_base_caps(1004, 1004, 'SELECT DISTINCT');
  dbms_hs.replace_base_caps(1005, 1005, 'DISTINCT in aggregate functions');
  dbms_hs.replace_base_caps(1006, 1006, 'ROWNUM');
  dbms_hs.replace_base_caps(1007, 1007, 'subquery');
  dbms_hs.replace_base_caps(1008, 1008, 'GROUP BY');
  dbms_hs.replace_base_caps(1009, 1009, 'HAVING');
  dbms_hs.replace_base_caps(1010, 1010, 'ORDER BY');
  dbms_hs.replace_base_caps(1011, 1011, 'CONNECT BY');
  dbms_hs.replace_base_caps(1012, 1012, 'START WITH');
  dbms_hs.replace_base_caps(1013, 1013, 'WHERE');
  dbms_hs.replace_base_caps(1014, 1014, 'callback');
  dbms_hs.replace_base_caps(1015, 1015, 'add redundant local filters');
  dbms_hs.replace_base_caps(1016, 1016, 'ROWID');
  dbms_hs.replace_base_caps(1017, 1017, 'ANY');
  dbms_hs.replace_base_caps(1018, 1018, 'ALL');
  dbms_hs.replace_base_caps(1019, 1019, 'EXISTS');
  dbms_hs.replace_base_caps(1020, 1020, 'NOT EXISTS');
  dbms_hs.replace_base_caps(1021, 1021, 'nls parameters');
  dbms_hs.replace_base_caps(1022, 1022, 'describe index');
  dbms_hs.replace_base_caps(1023, 1023, 'distributed read consistency');
  dbms_hs.replace_base_caps(1024, 1024, 'bundled calls');
  dbms_hs.replace_base_caps(1025, 1025, 'evaluate USER, UID, SYDATE local');
  dbms_hs.replace_base_caps(1026, 1026, 'KGL operation for PL/SQL RPC');
  dbms_hs.replace_base_caps(1027, 1027, 'NVL: change ANSI to ORA compare');
  dbms_hs.replace_base_caps(1028, 1028, 'remote mapping of queries');
  dbms_hs.replace_base_caps(1029, 1029, '2PC type (RO-SS-CC-PREP/2P-2PCC)');
  dbms_hs.replace_base_caps(1030, 1030, 'streamed protocol version number');
  dbms_hs.replace_base_caps(1031, 1031, 'special non-optdef functions');
  dbms_hs.replace_base_caps(1032, 1032, 'CURRVAL and NEXTVAL');
  dbms_hs.replace_base_caps(1033, 1033, 'hints (inline comments and aliases');
  dbms_hs.replace_base_caps(1034, 1034, 'remote sort by index access');
  dbms_hs.replace_base_caps(1035, 1035, 'use universal rowid for rowids');
  dbms_hs.replace_base_caps(1036, 1036, 'wait option in select for update');
  dbms_hs.replace_base_caps(1037, 1037, 'connect by order siblings by');
  dbms_hs.replace_base_caps(1038, 1038, 'On clause');
  dbms_hs.replace_base_caps(1039, 1039, 'no supprt for rem extended partn');
  dbms_hs.replace_base_caps(1040, 1040, 'SPREADSHEET clause');
  dbms_hs.replace_base_caps(1041, 1041, 'Merge optional WHERE clauses');
  dbms_hs.replace_base_caps(1042, 1042, 'connect by nocycle');
  dbms_hs.replace_base_caps(1043, 1043, 'connect by enhancements: connect_by_iscycle, connect_by_isleaf');
  dbms_hs.replace_base_caps(1044, 1044, 'Group Outer-Join');
  dbms_hs.replace_base_caps(1045, 1045, ' u''xxx\ffff''');
  dbms_hs.replace_base_caps(1046, 1046, '"with check option" in from-clause subqueries');
  dbms_hs.replace_base_caps(1047, 1047, 'new connect-by');
  dbms_hs.replace_base_caps(1048, 1048, 'native full outer join');
  dbms_hs.replace_base_caps(1049, 1049, 'recursive WITH');
  dbms_hs.replace_base_caps(1050, 1050, 'column alias list for WITH clause');
  dbms_hs.replace_base_caps(1051, 1051, 'WAIT option in LOCK TABLE');
  dbms_hs.replace_base_caps(1963, 1963, 'FDS can not DescribeParam after Exec in Transact SQL');
  dbms_hs.replace_base_caps(1964, 1964, 'FDS can handle schema in queries');
  dbms_hs.replace_base_caps(1965, 1965, 'Null is Null');
  dbms_hs.replace_base_caps(1966, 1966, 'ANSI Decode (CASE) support');
  dbms_hs.replace_base_caps(1967, 1967, 'Result set support');
  dbms_hs.replace_base_caps(1968, 1968, 'Piecewise fetch and exec');
  dbms_hs.replace_base_caps(1969, 1969, 'How to handle PUBLIC schema');
  dbms_hs.replace_base_caps(1970, 1970, 'Subquery in having clause is supported');
  dbms_hs.replace_base_caps(1971, 1971, 'Do not close and re-parse on re-exec of SELECTs');
  dbms_hs.replace_base_caps(1972, 1972, 'Informix related cap: Add space before negative numeric literals');
  dbms_hs.replace_base_caps(1973, 1973, 'Informix related cap: Add extra parenthesis for update sub-queries to make it a list');
  dbms_hs.replace_base_caps(1974, 1974, 'DB2-related cap: Change empty str assigns to null assigns');
  dbms_hs.replace_base_caps(1975, 1975, 'DB2-related cap: Zero length bind not same as null bind');
  dbms_hs.replace_base_caps(1976, 1976, 'DB2-related cap: Add space after comma');
  dbms_hs.replace_base_caps(1977, 1977, 'DB2-related cap: Order-by clause contains only numbers');
  dbms_hs.replace_base_caps(1978, 1978, 'DB2-related cap: Change empty string comparisons to is null');
  dbms_hs.replace_base_caps(1979, 1979, 'Implicit Coercion cap: Comparison of two objrefs');
  dbms_hs.replace_base_caps(1980, 1980, 'Implicit Coercion cap: Comparison of objref and bindvar');
  dbms_hs.replace_base_caps(1981, 1981, 'Implicit Coercion cap: Comparison of objref and literal');
  dbms_hs.replace_base_caps(1982, 1982, 'Implicit Coercion cap: Comparison of two bindvars');
  dbms_hs.replace_base_caps(1983, 1983, 'Implicit Coercion cap: Comparison of bindvar and literal');
  dbms_hs.replace_base_caps(1984, 1984, 'Implicit Coercion cap: Comparison of two literals');
  dbms_hs.replace_base_caps(1985, 1985, 'Implicit Coercion cap: Assignment of objref to column');
  dbms_hs.replace_base_caps(1986, 1986, 'Implicit Coercion cap: Assignment of bindvar to column');
  dbms_hs.replace_base_caps(1987, 1987, 'Implicit Coercion cap: Assignment of literal to column');
  dbms_hs.replace_base_caps(1988, 1988, 'RPC Bundling Capability');
  dbms_hs.replace_base_caps(1989, 1989, 'hoatcis() call capability');
  dbms_hs.replace_base_caps(1990, 1990, 'Quote Owner names in SQL statements');
  dbms_hs.replace_base_caps(1991, 1991, 'Map Alias to table names in non-select statements');
  dbms_hs.replace_base_caps(1992, 1992, 'Send Delimited IDs to FDS');
  dbms_hs.replace_base_caps(1993, 1993, 'HOA Describe Table Call Capability');
  dbms_hs.replace_base_caps(1994, 1994, 'Raw literal format');
  dbms_hs.replace_base_caps(1995, 1995, 'FOR UPDATE syntax mapping');
  dbms_hs.replace_base_caps(1996, 1996, 'Replace NULLs in select list with other constant');
  dbms_hs.replace_base_caps(1997, 1997, 'flush describe table cache');
  dbms_hs.replace_base_caps(1998, 1998, 'length of physical part of rowid');
  dbms_hs.replace_base_caps(1999, 1999, 'Bind to parameter mapping');
  dbms_hs.replace_base_caps(2000, 2000, 'SELECT ... FOR UPDATE');
  dbms_hs.replace_base_caps(2001, 2001, 'SELECT');
  dbms_hs.replace_base_caps(2002, 2002, 'UPDATE');
  dbms_hs.replace_base_caps(2003, 2003, 'DELETE');
  dbms_hs.replace_base_caps(2004, 2004, 'INSERT ... VALUES (...)');
  dbms_hs.replace_base_caps(2005, 2005, 'INSERT ... SELECT ...');
  dbms_hs.replace_base_caps(2006, 2006, 'LOCK TABLE');
  dbms_hs.replace_base_caps(2007, 2007, 'ROLLBACK TO SAVEPOINT ...');
  dbms_hs.replace_base_caps(2008, 2008, 'SAVEPOINT ...');
  dbms_hs.replace_base_caps(2009, 2009, 'SET TRANSACTION READ ONLY');
  dbms_hs.replace_base_caps(2010, 2010, 'alter session set nls_* = ...');
  dbms_hs.replace_base_caps(2011, 2011, 'alter session set GLOBAL_NAMES, OPTIMIZER_GOAL = ..');
  dbms_hs.replace_base_caps(2012, 2012, 'alter session set REMOTE_DEPENDENCIES_MODE = ..');
  dbms_hs.replace_base_caps(2013, 2013, 'set transaction isolation level serializable');
  dbms_hs.replace_base_caps(2014, 2014, 'set constraints all immediate');
  dbms_hs.replace_base_caps(2015, 2015, 'alter session set SKIP_UNUSABLE_INDEXES = ..');
  dbms_hs.replace_base_caps(2016, 2016, 'alter session set time_zone - its absolete now');
  dbms_hs.replace_base_caps(2017, 2017, 'alter session set ERROR_ON_OVERLAP_TIME');
  dbms_hs.replace_base_caps(2018, 2018, 'Upsert');
  dbms_hs.replace_base_caps(3000, 3000, 'VARCHAR2');
  dbms_hs.replace_base_caps(3001, 3001, 'INTEGER');
  dbms_hs.replace_base_caps(3002, 3002, 'DECIMAL');
  dbms_hs.replace_base_caps(3003, 3003, 'FLOAT');
  dbms_hs.replace_base_caps(3004, 3004, 'DATE');
  dbms_hs.replace_base_caps(3005, 3005, 'VARCHAR');
  dbms_hs.replace_base_caps(3006, 3006, 'SMALL INTEGER');
  dbms_hs.replace_base_caps(3007, 3007, 'RAW');
  dbms_hs.replace_base_caps(3008, 3008, 'VAR RAW');
  dbms_hs.replace_base_caps(3009, 3009, '? RAW');
  dbms_hs.replace_base_caps(3010, 3010, 'SMALL FLOAT');
  dbms_hs.replace_base_caps(3011, 3011, 'LONG INT QUADWORD');
  dbms_hs.replace_base_caps(3012, 3012, 'LEFT OVERPUNCH');
  dbms_hs.replace_base_caps(3013, 3013, 'RIGHT OVERPUNCH');
  dbms_hs.replace_base_caps(3014, 3014, 'ROWID');
  dbms_hs.replace_base_caps(3015, 3015, 'LEFT SEPARATE');
  dbms_hs.replace_base_caps(3016, 3016, 'RIGHT SEPARATE');
  dbms_hs.replace_base_caps(3017, 3017, 'OS DATE');
  dbms_hs.replace_base_caps(3018, 3018, 'OS FULL ==> DATE + TIME');
  dbms_hs.replace_base_caps(3019, 3019, 'OS TIME');
  dbms_hs.replace_base_caps(3020, 3020, 'UNSIGNED SMALL INTEGER');
  dbms_hs.replace_base_caps(3021, 3021, 'BYTE');
  dbms_hs.replace_base_caps(3022, 3022, 'UNSIGNED BYTE');
  dbms_hs.replace_base_caps(3023, 3023, 'UNSIGNED INTEGER');
  dbms_hs.replace_base_caps(3024, 3024, 'CHAR INTEGER');
  dbms_hs.replace_base_caps(3025, 3025, 'CHAR FLOAT');
  dbms_hs.replace_base_caps(3026, 3026, 'CHAR DECIMAL');
  dbms_hs.replace_base_caps(3027, 3027, 'LONG');
  dbms_hs.replace_base_caps(3028, 3028, 'VARLONG');
  dbms_hs.replace_base_caps(3029, 3029, 'OS RDATE');
  dbms_hs.replace_base_caps(3030, 3030, '(RELATIVE) RECORD ADDRESS');
  dbms_hs.replace_base_caps(3031, 3031, '(RELATIVE) RECORD NUMBER');
  dbms_hs.replace_base_caps(3032, 3032, 'VARGRAPHIC');
  dbms_hs.replace_base_caps(3033, 3033, 'VARNUM');
  dbms_hs.replace_base_caps(3034, 3034, 'NUMBER');
  dbms_hs.replace_base_caps(3035, 3035, 'ANSI FIXED CHAR');
  dbms_hs.replace_base_caps(3036, 3036, 'LONG RAW');
  dbms_hs.replace_base_caps(3037, 3037, 'LONG VARRAW');
  dbms_hs.replace_base_caps(3038, 3038, 'MLSLABEL');
  dbms_hs.replace_base_caps(3039, 3039, 'RAW MLSLABEL');
  dbms_hs.replace_base_caps(3040, 3040, 'CHARZ');
  dbms_hs.replace_base_caps(3041, 3041, 'BINARY INTEGER');
  dbms_hs.replace_base_caps(3042, 3042, 'ORACLE DATE');
  dbms_hs.replace_base_caps(3043, 3043, 'BOOLEAN');
  dbms_hs.replace_base_caps(3044, 3044, 'CHAR ROWID');
  dbms_hs.replace_base_caps(3045, 3045, 'UNSIGNED LONG INTEGER');
  dbms_hs.replace_base_caps(3046, 3046, 'ODBC CHAR DECIMAL');
  dbms_hs.replace_base_caps(3047, 3047, 'TIMESTAMP');
  dbms_hs.replace_base_caps(3048, 3048, 'TIMESTAMP WITH TIME ZONE');
  dbms_hs.replace_base_caps(3049, 3049, 'INTERVAL - YEAR TO MONTH');
  dbms_hs.replace_base_caps(3050, 3050, 'INTERVAL - DAY TO SECOND');
  dbms_hs.replace_base_caps(3051, 3051, 'TIMESTAMP WITH IMPLICIT TIME ZONE');
  dbms_hs.replace_base_caps(3052, 3052, 'CHAR TIMESTAMP');
  dbms_hs.replace_base_caps(3053, 3053, 'CHAR TIMESTAMP WITH TIMEZONE');
  dbms_hs.replace_base_caps(3054, 3054, 'CHAR INTERVAL - YEAR TO MONTH');
  dbms_hs.replace_base_caps(3055, 3055, 'CHAR INTERVAL - DAY TO SECOND');
  dbms_hs.replace_base_caps(3056, 3056, 'CHAR TIMESTAMP WITH IMPLICIT TIME ZONE');
  dbms_hs.replace_base_caps(3057, 3057, 'STRUCT TIMESTAMP');
  dbms_hs.replace_base_caps(3058, 3058, 'STRUCT TIMESTAMP WITH TIMEZONE');
  dbms_hs.replace_base_caps(3059, 3059, 'STRUCT INTERVAL - YEAR TO MONTH');
  dbms_hs.replace_base_caps(3060, 3060, 'STRUCT INTERVAL - DAY TO SECOND');
  dbms_hs.replace_base_caps(3061, 3061, 'STRUCT TIMESTAMP WITH IMPLICIT TIME ZONE');
  dbms_hs.replace_base_caps(3062, 3062, 'RESULT SET HANDLE');
  dbms_hs.replace_base_caps(3063, 3063, 'CLOB');
  dbms_hs.replace_base_caps(3064, 3064, 'BLOB');
  dbms_hs.replace_base_caps(3065, 3065, 'BINARY FILE');
  dbms_hs.replace_base_caps(3066, 3066, 'ODBC DATE');
  dbms_hs.replace_base_caps(3067, 3067, 'ODBC TIMESTAMP STRUCT');
  dbms_hs.replace_base_caps(3068, 3068, 'ODBC INVERVAL YEAR TO MONTH');
  dbms_hs.replace_base_caps(3069, 3069, 'ODBC INTERVAL DATE TO SECOND');
  dbms_hs.replace_base_caps(3500, 3500, '');
  dbms_hs.replace_base_caps(3501, 3501, '');
  dbms_hs.replace_base_caps(3502, 3502, '');
  dbms_hs.replace_base_caps(3503, 3503, '');
  dbms_hs.replace_base_caps(3504, 3504, '');
  dbms_hs.replace_base_caps(3505, 3505, '');
  dbms_hs.replace_base_caps(3506, 3506, '');
  dbms_hs.replace_base_caps(3507, 3507, '');
  dbms_hs.replace_base_caps(3508, 3508, '');
  dbms_hs.replace_base_caps(3509, 3509, '');
  dbms_hs.replace_base_caps(3510, 3510, '');
  dbms_hs.replace_base_caps(3511, 3511, '');
  dbms_hs.replace_base_caps(3512, 3512, '');
  dbms_hs.replace_base_caps(3513, 3513, '');
  dbms_hs.replace_base_caps(3514, 3514, '');
  dbms_hs.replace_base_caps(3515, 3515, '');
  dbms_hs.replace_base_caps(3516, 3516, '');
  dbms_hs.replace_base_caps(3517, 3517, '');
  dbms_hs.replace_base_caps(3518, 3518, '');
  dbms_hs.replace_base_caps(3519, 3519, '');
  dbms_hs.replace_base_caps(4000, 4000, '');



/*------------------------------------------------*/
/*  DD translations used to test HS installation  */
/*------------------------------------------------*/

  dbms_hs.replace_base_dd('DD_TKHODDTR1', 'DD_TKHODDTR1', NULL);
  dbms_hs.replace_base_dd('DD_TKHODDTR3', 'DD_TKHODDTR3', NULL);
  dbms_hs.replace_base_dd('DD_TKHODDTR5', 'DD_TKHODDTR5', NULL);
  dbms_hs.replace_base_dd('DD_TKHODDTR6', 'DD_TKHODDTR6', NULL);
  dbms_hs.replace_base_dd('DD_TKHODDTR7', 'DD_TKHODDTR7', NULL);
  dbms_hs.replace_base_dd('DD_TKHODDTR8', 'DD_TKHODDTR8', NULL);
  dbms_hs.replace_base_dd('DD_TKHODDTR9', 'DD_TKHODDTR9', NULL);
  dbms_hs.replace_base_dd('DD_TKHODDTR10', 'DD_TKHODDTR10', NULL);
/*
    Registered elsewhere as a standard table name:
  dbms_hs.replace_base_dd('USER_SYNONYMS', USER_SYNONYMS', NULL);
    Self-registered:
  dbms_hs.replace_base_dd('TKHODDAU', TKHODDAU', NULL);
*/

/*--------------------------------------------*/
/*  DD translations accessible to all agents  */
/*--------------------------------------------*/

  dbms_hs.replace_base_dd('ALL_CATALOG', 'ALL_CATALOG', NULL);
  dbms_hs.replace_base_dd('ALL_COL_COMMENTS', 'ALL_COL_COMMENTS', NULL);
  dbms_hs.replace_base_dd('ALL_COL_PRIVS', 'ALL_COL_PRIVS', NULL);
  dbms_hs.replace_base_dd('ALL_COL_PRIVS_MADE', 'ALL_COL_PRIVS_MADE', NULL);
  dbms_hs.replace_base_dd('ALL_COL_PRIVS_RECD', 'ALL_COL_PRIVS_RECD', NULL);
  dbms_hs.replace_base_dd('ALL_CONSTRAINTS', 'ALL_CONSTRAINTS', NULL);
  dbms_hs.replace_base_dd('ALL_CONS_COLUMNS', 'ALL_CONS_COLUMNS', NULL);
  dbms_hs.replace_base_dd('ALL_DB_LINKS', 'ALL_DB_LINKS', NULL);
  dbms_hs.replace_base_dd('ALL_DEF_AUDIT_OPTS', 'ALL_DEF_AUDIT_OPTS', NULL);
  dbms_hs.replace_base_dd('ALL_DEPENDENCIES', 'ALL_DEPENDENCIES', NULL);
  dbms_hs.replace_base_dd('ALL_ERRORS', 'ALL_ERRORS', NULL);
  dbms_hs.replace_base_dd('ALL_INDEXES', 'ALL_INDEXES', NULL);
  dbms_hs.replace_base_dd('ALL_IND_COLUMNS', 'ALL_IND_COLUMNS', NULL);
  dbms_hs.replace_base_dd('ALL_OBJECTS', 'ALL_OBJECTS', NULL);
  dbms_hs.replace_base_dd('ALL_SEQUENCES', 'ALL_SEQUENCES', NULL);
  dbms_hs.replace_base_dd('ALL_SNAPSHOTS', 'ALL_SNAPSHOTS', NULL);
  dbms_hs.replace_base_dd('ALL_SOURCE', 'ALL_SOURCE', NULL);
  dbms_hs.replace_base_dd('ALL_SYNONYMS', 'ALL_SYNONYMS', NULL);
  dbms_hs.replace_base_dd('ALL_TABLES', 'ALL_TABLES', NULL);
  dbms_hs.replace_base_dd('ALL_TAB_COLUMNS', 'ALL_TAB_COLUMNS', NULL);
  dbms_hs.replace_base_dd('ALL_TAB_COMMENTS', 'ALL_TAB_COMMENTS', NULL);
  dbms_hs.replace_base_dd('ALL_TAB_PRIVS', 'ALL_TAB_PRIVS', NULL);
  dbms_hs.replace_base_dd('ALL_TAB_PRIVS_MADE', 'ALL_TAB_PRIVS_MADE', NULL);
  dbms_hs.replace_base_dd('ALL_TAB_PRIVS_RECD', 'ALL_TAB_PRIVS_RECD', NULL);
  dbms_hs.replace_base_dd('ALL_TRIGGERS', 'ALL_TRIGGERS', NULL);
  dbms_hs.replace_base_dd('ALL_USERS', 'ALL_USERS', NULL);
  dbms_hs.replace_base_dd('ALL_VIEWS', 'ALL_VIEWS', NULL);
  dbms_hs.replace_base_dd('AUDIT_ACTIONS', 'AUDIT_ACTIONS', NULL);
  dbms_hs.replace_base_dd('COLUMN_PRIVILEGES', 'COLUMN_PRIVILEGES', NULL);
  dbms_hs.replace_base_dd('DBA_CATALOG', 'DBA_CATALOG', NULL);
  dbms_hs.replace_base_dd('DBA_COL_COMMENTS', 'DBA_COL_COMMENTS', NULL);
  dbms_hs.replace_base_dd('DBA_COL_PRIVS', 'DBA_COL_PRIVS', NULL);
  dbms_hs.replace_base_dd('DBA_OBJECTS', 'DBA_OBJECTS', NULL);
  dbms_hs.replace_base_dd('DBA_ROLES', 'DBA_ROLES', NULL);
  dbms_hs.replace_base_dd('DBA_ROLE_PRIVS', 'DBA_ROLE_PRIVS', NULL);
  dbms_hs.replace_base_dd('DBA_SYS_PRIVS', 'DBA_SYS_PRIVS', NULL);
  dbms_hs.replace_base_dd('DBA_TABLES', 'DBA_TABLES', NULL);
  dbms_hs.replace_base_dd('DBA_TAB_COLUMNS', 'DBA_TAB_COLUMNS', NULL);
  dbms_hs.replace_base_dd('DBA_TAB_COMMENTS', 'DBA_TAB_COMMENTS', NULL);
  dbms_hs.replace_base_dd('DBA_TAB_PRIVS', 'DBA_TAB_PRIVS', NULL);
  dbms_hs.replace_base_dd('DBA_USERS', 'DBA_USERS', NULL);
  dbms_hs.replace_base_dd('DICTIONARY', 'DICTIONARY', NULL);
  dbms_hs.replace_base_dd('DICT_COLUMNS', 'DICT_COLUMNS', NULL);
  dbms_hs.replace_base_dd('DUAL', 'DUAL', NULL);
  dbms_hs.replace_base_dd('INDEX_STATS', 'INDEX_STATS', NULL);
  dbms_hs.replace_base_dd('PRODUCT_USER_PROFILE', 'PRODUCT_USER_PROFILE', NULL);
  dbms_hs.replace_base_dd('RESOURCE_COST', 'RESOURCE_COST', NULL);
  dbms_hs.replace_base_dd('ROLE_ROLE_PRIVS', 'ROLE_ROLE_PRIVS', NULL);
  dbms_hs.replace_base_dd('ROLE_SYS_PRIVS', 'ROLE_SYS_PRIVS', NULL);
  dbms_hs.replace_base_dd('ROLE_TAB_PRIVS', 'ROLE_TAB_PRIVS', NULL);
  dbms_hs.replace_base_dd('SESSION_PRIVS', 'SESSION_PRIVS', NULL);
  dbms_hs.replace_base_dd('SESSION_ROLES', 'SESSION_ROLES', NULL);
  dbms_hs.replace_base_dd('TABLE_PRIVILEGES', 'TABLE_PRIVILEGES', NULL);
  dbms_hs.replace_base_dd('USER_AUDIT_OBJECT', 'USER_AUDIT_OBJECT', NULL);
  dbms_hs.replace_base_dd('USER_AUDIT_SESSION', 'USER_AUDIT_SESSION', NULL);
  dbms_hs.replace_base_dd('USER_AUDIT_STATEMENT', 'USER_AUDIT_STATEMENT', NULL);
  dbms_hs.replace_base_dd('USER_AUDIT_TRAIL', 'USER_AUDIT_TRAIL', NULL);
  dbms_hs.replace_base_dd('USER_CATALOG', 'USER_CATALOG', NULL);
  dbms_hs.replace_base_dd('USER_CLUSTERS', 'USER_CLUSTERS', NULL);
  dbms_hs.replace_base_dd('USER_CLU_COLUMNS', 'USER_CLU_COLUMNS', NULL);
  dbms_hs.replace_base_dd('USER_COL_COMMENTS', 'USER_COL_COMMENTS', NULL);
  dbms_hs.replace_base_dd('USER_COL_PRIVS', 'USER_COL_PRIVS', NULL);
  dbms_hs.replace_base_dd('USER_COL_PRIVS_MADE', 'USER_COL_PRIVS_MADE', NULL);
  dbms_hs.replace_base_dd('USER_COL_PRIVS_RECD', 'USER_COL_PRIVS_RECD', NULL);
  dbms_hs.replace_base_dd('USER_CONSTRAINTS', 'USER_CONSTRAINTS', NULL);
  dbms_hs.replace_base_dd('USER_CONS_COLUMNS', 'USER_CONS_COLUMNS', NULL);
  dbms_hs.replace_base_dd('USER_DB_LINKS', 'USER_DB_LINKS', NULL);
  dbms_hs.replace_base_dd('USER_DEPENDENCIES', 'USER_DEPENDENCIES', NULL);
  dbms_hs.replace_base_dd('USER_ERRORS', 'USER_ERRORS', NULL);
  dbms_hs.replace_base_dd('USER_EXTENTS', 'USER_EXTENTS', NULL);
  dbms_hs.replace_base_dd('USER_FREE_SPACE', 'USER_FREE_SPACE', NULL);
  dbms_hs.replace_base_dd('USER_INDEXES', 'USER_INDEXES', NULL);
  dbms_hs.replace_base_dd('USER_IND_COLUMNS', 'USER_IND_COLUMNS', NULL);
  dbms_hs.replace_base_dd('USER_OBJECTS', 'USER_OBJECTS', NULL);
  dbms_hs.replace_base_dd('USER_OBJ_AUDIT_OPTS', 'USER_OBJ_AUDIT_OPTS', NULL);
  dbms_hs.replace_base_dd('USER_RESOURCE_LIMITS', 'USER_RESOURCE_LIMITS', NULL);
  dbms_hs.replace_base_dd('USER_ROLE_PRIVS', 'USER_ROLE_PRIVS', NULL);
  dbms_hs.replace_base_dd('USER_SEGMENTS', 'USER_SEGMENTS', NULL);
  dbms_hs.replace_base_dd('USER_SEQUENCES', 'USER_SEQUENCES', NULL);
  dbms_hs.replace_base_dd('USER_SNAPSHOT_LOGS', 'USER_SNAPSHOT_LOGS', NULL);
  dbms_hs.replace_base_dd('USER_SOURCE', 'USER_SOURCE', NULL);
  dbms_hs.replace_base_dd('USER_SYNONYMS', 'USER_SYNONYMS', NULL);
  dbms_hs.replace_base_dd('USER_SYS_PRIVS', 'USER_SYS_PRIVS', NULL);
  dbms_hs.replace_base_dd('USER_TABLES', 'USER_TABLES', NULL);
  dbms_hs.replace_base_dd('USER_TABLESPACES', 'USER_TABLESPACES', NULL);
  dbms_hs.replace_base_dd('USER_TAB_COLUMNS', 'USER_TAB_COLUMNS', NULL);
  dbms_hs.replace_base_dd('USER_TAB_COMMENTS', 'USER_TAB_COMMENTS', NULL);
  dbms_hs.replace_base_dd('USER_TAB_PRIVS', 'USER_TAB_PRIVS', NULL);
  dbms_hs.replace_base_dd('USER_TAB_PRIVS_MADE', 'USER_TAB_PRIVS_MADE', NULL);
  dbms_hs.replace_base_dd('USER_TAB_PRIVS_RECD', 'USER_TAB_PRIVS_RECD', NULL);
  dbms_hs.replace_base_dd('USER_TRIGGERS', 'USER_TRIGGERS', NULL);
  dbms_hs.replace_base_dd('USER_TS_QUOTAS', 'USER_TS_QUOTAS', NULL);
  dbms_hs.replace_base_dd('USER_USERS', 'USER_USERS', NULL);
  dbms_hs.replace_base_dd('USER_VIEWS', 'USER_VIEWS', NULL);


/*--------------------------------------------------------*/
/*  Pseudo-FDS class for BITE (Built-In Test Environment  */
/*--------------------------------------------------------*/

  dbms_hs.replace_fds_class('BITE', 'BITE', 'Built-In Test Environment');
end;
/

commit;
