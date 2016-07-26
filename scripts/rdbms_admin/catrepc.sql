rem
rem $Header: catrepc.sql 06-nov-2006.14:29:42 elu Exp $ 
rem 
Rem Copyright (c) 1993, 2006, Oracle. All rights reserved.  
Rem  ***** Oracle Proprietary                                           *****
Rem  ***** This file contains the embodiment of proprietary technology. *****
Rem  ***** It is for the sole use of Oracle employees and Oracle        *****
Rem  ***** customers who have executed non-disclosure agreements.      *****
Rem  ***** The contents of this file may not be disclosed to persons    *****
Rem  ***** or organization who have not executed a non-disclosure      *****
Rem  ***** agreement.                                                   *****
Rem    NAME
Rem      catrep.sql - replication catalog tables and views
Rem    DESCRIPTION
Rem      This file implements the repcat tables, views, and sequences.
Rem      Tables:
Rem         repcat$_repcat
Rem         repcat$_repschema
Rem         repcat$_repobject
Rem         repcat$_repcolumn
Rem         repcat$_key_columns
Rem         repcat$_generated
Rem         repcat$_repprop
Rem         repcat$_repcatlog
Rem         repcat$_ddl
Rem         repcat$_repgroup_privs
Rem         repcat$_flavors
Rem         repcat$_flavor_objects
Rem         repcat$_extension
Rem         repcat$_sites_new
Rem       Sequences
Rem         repcat$_repprop_key
Rem         repcat_log_sequence
Rem         repcat$_flavors_s
Rem
Rem      This following repcat tables are for conflict resolution 
Rem      Tables:
Rem         repcat$_audit_column
Rem         repcat$_audit_attribute
Rem         repcat$_parameter_column
Rem         repcat$_resolution
Rem         repcat$_resolution_method
Rem         repcat$_conflict
Rem         repcat$_grouped_column
Rem         repcat$_column_group
Rem         repcat$_priority
Rem         repcat$_priority_group
Rem         repcat$_statistics_control
Rem         repcat$_statistics
Rem
Rem     The following view replaces a simpler view defined in catdefer.sql
Rem     It reflects more repcat based deferred rpc destinations.
Rem         deftrandest
Rem     The following deferred RPC views are defined here.
Rem         defcall
Rem         defcalldest
Rem     The following package is created or replaced to make grants necessary
Rem     to enable SYS to grant select in defcalldest.
Rem         system.ora$_sys_rep_auth
Rem
Rem     The following repcat tables are to support refresh group templates:
Rem     Tables:
Rem        REPCAT$_USER_PARM_VALUES
Rem        REPCAT$_TEMPLATE_PARMS
Rem        REPCAT$_USER_AUTHORIZATIONS
Rem        REPCAT$_TEMPLATE_OBJECTS
Rem        REPCAT$_TEMPLATE_SITES
Rem        REPCAT$_REFRESH_TEMPLATES
Rem
Rem    NOTES
Rem      Must be run when connected to SYS or INTERNAL
Rem
Rem    DEPENDENCIES
Rem      
Rem    USAGE
Rem
Rem    SECURITY
Rem
Rem    COMPATIBILITY
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     elu        10/30/06 - modify for parallel upgrade
Rem     desingh    08/03/06 - lrg#2046364
Rem     desingh    01/27/06 - bug#4749532: add foreign key indexes to 
Rem                           repcat_audit_column 
Rem     desingh    02/14/05 - bug#4055881: modify _ALL_REP... views 
Rem     rburns     05/11/04 - use dynamic SQL 
Rem     liwong     10/06/03 - Recompile deftrandest synonym 
Rem     gviswana   05/21/02 - Grant LOCK ANY TABLE to SYS
Rem     desinha    04/29/02 - #2303866: change user => userenv('SCHEMAID')
Rem     jingliu    03/15/02 - suppress errors: DML on repcat$_resolution_method
Rem     celsbern   06/01/01 - Fixing typo
Rem     gviswana   05/24/01 - CREATE OR REPLACE SYNONYM
Rem     celsbern   05/17/01 - added CONFLICT_TYPE_ID to _ALL_REPRESOLUTION view
Rem     arrajara   04/18/01 - caching async_updatable_table is not supported
Rem     narora     04/17/01 - _REPL_NESTED_TABLE_NAMES: created
Rem     nshodhan   04/06/01 - bug 1725230: change snapshot->mview
Rem     htseng     04/12/01 - eliminate execute twice (remove ;).
Rem     sbalaram   04/04/01 - Bug #1717932: Fix repcat_repcolumn_base
Rem                           for datetime types
Rem     jingliu    03/22/01 - modify repcat$_template_targets
Rem     celsbern   02/28/01 - changed dba_instantiation_ddl to _all view.
Rem     liwong     02/13/01 - replace consistent_at by flashback_scn
Rem     narora     02/13/01 - fix repcat_repflavor_columns.type_mod
Rem     narora     02/13/01 - repcat_repcolumn_base r2 only for soidref_fk_attr
Rem     sbalaram   02/09/01 - Add more "_ALL_*" views for internal use
Rem     jingliu    01/29/01 - type support for iAS
Rem     narora     01/03/01 - repcat_repcolumn_base join r2 with r using lcname
Rem     narora     12/06/00 - repcat_repcolumn_base needs length of soidref_fk 
Rem                         - even if pos is null
Rem     dzhang     12/13/00 - Fix repcat_repflavor_columns for XMLType
Rem     liwong     11/16/00 - support XMLType
Rem     celsbern   11/15/00 - fixing seed data
Rem     arrajara   11/15/00 - "_ALL_REPCOLUMN": change internal_cname to cname
Rem     elu        11/02/00 - modify repcat$_parameter_column
Rem     liwong     10/27/00 - Add system.repcat$_resolution_idx2
Rem     dzhang     10/11/00 - move repcat$_repcolumn_fk_idx to system schema 
Rem     celsbern   10/10/00 - 8.2 IAS support added..
Rem     arrajara   09/24/00 - change repcat$_repcolumn, dba,all,user_repcolumn
Rem     liwong     09/21/00 - add indexes for FKs to minimize deadlocks
Rem     arrajara   09/01/00 - codepoint semantics support
Rem     liwong     09/01/00 - add master w/o quiesce: fixes
Rem     elu        08/21/00 - remove hashcode from repobject views
Rem     elu        08/14/00 - add repcat_repcolumn_base
Rem     sbalaram   07/13/00 - local tz and dls support
Rem     celsbern   06/30/00 - fixing merge problems.
Rem     celsbern   06/29/00 - fixed repcatlog views..
Rem     elu        06/26/00 - add column ddl_num to template_objects
Rem     rvenkate   06/23/00  - add username and remove userid from
Rem                            repcat$_repgroup_privs
Rem     elu        06/22/00 - add new column hashcode to repobject, repcolumn
Rem     elu        06/19/00 - add column ddl_num to views
Rem     liwong     06/13/00 - add_master_db w/o quiesce
Rem     elu        06/12/00 - add ddl_num to repcat$_ddl
Rem     liwong     05/16/00 - add_master_db w/o quiesce
Rem     jstamos    05/16/00 - add_master_db w/o quiesce
Rem     masubram   04/05/00  - add new types for template objects
Rem     masubram   03/29/00  - add new IAS object types
Rem     celsbern   03/29/00  - fixed template_objects constraints for IAS
Rem     celsbern   03/27/00  - modified template constraints for IAS.
Rem     celsbern   04/20/00 - moved repcat$_flavors_unq2 constraint back to 
Rem     celsbern   03/21/00  - modified repcatlog constraint for add_column & phases
Rem     celsbern   02/11/00  - added sequence for generating flavor names
Rem     sbalaram   12/01/99  - add repcat_repflavor_columns
Rem     sbalaram   11/23/99  - Change dba_repflavor_objects
Rem     sbalaram   10/27/99  - add type = -1 in dba_repflavor_columns
Rem     liwong     07/28/99  - replicated objects                              
Rem     schandar   07/25/99  - Modify script to work in SQL*Plus
Rem     celsbern   07/13/99  - fixed rgt_object views to correctly show 'PACKAG
Rem     nshodhan   06/29/99  - Bug# 684871: remove blank line                  
Rem     avaradar   06/04/99  - date time support                               
Rem     liwong     02/22/99  - Modify system.repcat$_flavors_s                
Rem     hasun      12/19/98  - Consider internal packages in repcat_repobject  
Rem     hasun      12/17/98  - Add comment on snapshot sites for repschema     
Rem     liwong     12/17/98  - Fix dba_repflavor_columns                       
Rem     hasun      12/07/98  - Fix user_repsites                               
Rem     hasun      12/05/98  - Fix user_repgroup                               
Rem     hasun      12/02/98  - Support multiple grps at same snap site         
Rem     celsbern   10/28/98  - changed shape of repcat$_template_sites table.  
Rem     celsbern   10/15/98  - added support for mviews on template tables.
Rem     celsbern   09/25/98  - added user and all views for templates.
Rem     nshodhan   09/09/98  - Modify views to exclude RepAPI snapshots
Rem     celsbern   08/03/98  - fixed bad comment lines for derived_from_oname
Rem     liwong     07/22/98  - Add repcat$_repcat.flag                       
Rem     liwong     07/22/98  - Add receiver_tracing_enabled to repcat_repobject
Rem     celsbern   06/29/98  - added derived_from_sname and derived_from_oname 
Rem     celsbern   06/19/98  - fixed repcat$_template_objects_c1 constraint.   
Rem     celsbern   06/16/98  - fixed object_type constraint on template_objects
Rem     liwong     06/13/98  - add repcat$_flavor_objects_fk2
Rem     celsbern   06/11/98  - removed repcat$_template_output table and change
Rem     celsbern   05/27/98  - changed temporary tables to global temporary tab
Rem     celsbern   05/14/98  - changed LONGs to CLOBs for rgt tables           
Rem     jstamos    05/04/98  - add unique index                                
Rem     celsbern   04/23/98  - fixed up repcat$_template_object table.         
Rem     jstamos    04/22/98  - change column comment                           
Rem     celsbern   04/21/98  - added database link object_type for templates.  
Rem     celsbern   04/20/98  - added user_override flag to repcat$_template_par
Rem     jstamos    04/20/98  - add type check for table in dba_repflavor_object
Rem     jstamos    04/20/98  - permit obsolete flavors in check constraint     
Rem     jstamos    04/10/98  - make repcolumn constraint deferrable            
Rem     jstamos    04/06/98  - change testing to waiting                       
Rem     celsbern   04/06/98 -  Fixed merge problems.
Rem     celsbern   04/06/98 - fixed creation of repcat$_template_objects_n1 ind
Rem     hasun      03/10/98  - Snapshots can be either a table or a view       
Rem     jstamos    02/19/98  - flavor support                                  
Rem     celsbern   02/17/98  - Added tables and view for refresh group template
Rem     wesmith    01/20/98 -  Add column global_flag to repcat$_repgroup_privs
Rem     liwong     12/23/97 -  add replication_trigger_eixsts
Rem                            internal_package_exists columns to repobject
Rem     wesmith    12/15/97 -  Untrusted security model code review
Rem     wesmith    09/03/97 -  Untrusted security model enhancements
Rem     liwong     09/15/97 -  add -4 to repcat$_repobject_type
Rem     liwong     06/23/97 -  add recipient_key in repprop_dblink_how index
Rem     jstamos    05/19/97 -  433036: record split update package
Rem     adowning   04/28/97 -  2k->4k varchar
Rem     adowning   04/27/97 -  fix typo
Rem     adowning   04/27/97 -  v8 column sizes for reppriority
Rem     jstamos    04/09/97 -  move defcall view to prvtdfri
Rem     jstamos    04/08/97 -  restore procname to defcall
Rem     jstamos    04/04/97 -  tighter AQ integration
Rem     liwong     04/02/97 -  Add system.repcat$_repprop_key
Rem     masubram   03/27/97 -  fix comment on repcat$_snapgroup.rep_type
Rem     liwong     03/24/97 -  Replace def$_aqcall.batch_no by def$_aqcall.cscn
Rem     masubram   03/13/97 -  Add table and views for snapshor group registrat
Rem     jnath      03/02/97 -  bug 429647: remove clauses that check standalone
Rem                            procedures for deferred RPC
Rem     liwong     03/06/97 -  merge bug 433785 manually
Rem     liwong     02/24/97 -  Optimize deftrandest
Rem     liwong     02/12/97 -  Add system.repcat$_repprop_dblink_how
Rem     liwong     02/11/97 -  Add comment for defcalldest
Rem     liwong     02/10/97 -  Add queue_batch, delivery_order in deftrandest
Rem     liwong     01/07/97 -  Added comments for populating
Rem                         -  repcat$_resolution_method
Rem     hasun      12/28/96 -  Add LOB PACKAGE to repcat_generated
Rem     liwong     12/13/96 -  Fixed bug 430300
Rem     celsbern   12/11/96 -  Added NCHAR support.
Rem     asgoel     10/23/96 -  fix - adding a repcatlog request
Rem     celsbern   10/03/96 -  moved repcat$_cdef view from prvtrepc to here.
Rem     sjain      10/01/96 -  AQ conversion
Rem     jstamos    09/16/96 -  send and compare old columns
Rem     asgoel     09/12/96 -  Fixes after code review
Rem     asgoel     08/22/96 -  Added validate flags to repcat table
Rem     ldoo       08/07/96 -  Fix typo
Rem     ldoo       07/31/96 -  Replace repgenerated with repgenobjects.
Rem     jstamos    07/30/96 -  minimize update comm: add %_repobject.flag
Rem     jstamos    07/17/96 -  support LOBs
Rem     ldoo       06/05/96 -  Fix resolution views
Rem     asgoel     06/13/96 -  Added a needs generation column to repobj table
Rem     tpystyne   06/01/96 -  change last type to type#
Rem     mmonajje   05/24/96 -  Replace type col name with type#
Rem     ldoo       05/17/96 -  Remove trigger_owner
Rem     ldoo       05/14/96 -  Fix repcolumn views
Rem     asurpur    04/08/96 -  Dictionary Protection Implementation
Rem     sbalaram   04/08/96 -  Bug# 328957 - Add delivery_order column to 
Rem                            system.repcat$_repprop table
Rem     sbalaram   03/15/96 -  Expose trigflag via repcat_repobject
Rem     ldoo       12/11/95 -  Add trigger_owner to repobject
Rem     sjain      10/10/95 -  Name changes of dba_repcat etc.
Rem     jstamos    09/21/95 -  null oname implies null sname: repcat_repcatlog
Rem     jstamos    08/17/95 -  code review changes for deferred RPCs
Rem     hasun      05/25/95 -  Create public synonyms for DBA_ views
Rem     hasun      05/10/95 -  Modify Deferred RPC views for Object Group
Rem     hasun      04/20/95 -  Restore Rep3 semantics to all_repcat, all_repsch
Rem     hasun      04/11/95 -  merge changes from branch 1.2.720.6
Rem     hasun      03/30/95 -  BUG#273284: Modify to support PUBLIC repschema
Rem     hasun      03/23/95 -  Replace foreign key contraint in reprop
Rem     hasun      03/20/95 -  Change RepCat for SYNC Replication
Rem     hasun      01/31/95 -  Modify tables and views for Rep3 - Object Groups
Rem     hasun      01/31/95 -  merge changes from branch 1.2.720.5
Rem     hasun      01/23/95 -  merge changes from branch 1.1.710.9
Rem     jstamos    01/20/95 -  add primary key and index
Rem     jstamos    01/20/95 -  merge changes from branch 1.2.720.4
Rem     hasun      01/11/95 -  Add fix to resolve duplicate SCNs
Rem     wmaimone   12/29/94 -  BUG#254503 commit is SQL
Rem     adowning   12/23/94 -  merge changes from branch 1.2.720.1
Rem     adowning   12/21/94 -  merge changes from branch 1.1.710.6-8
Rem     jstamos    12/08/94 -  foreign key in repschema to def$_destination
Rem     dsdaniel   12/05/94 -  eliminate deftrandest
Rem     adowning   12/05/94 -  fix all_repobject, all_repgenerated
Rem     dsdaniel   11/17/94 -  merge changes from branch 1.1.710.5
Rem     dsdaniel   11/11/94 -  defcalldest view
Rem     dsdaniel   10/13/94 -  merge changes from branch 1.1.710.3
Rem     jstamos    08/10/94 -  move trigger creation to prvtrepc.sql
Rem     adowning   06/14/94 -  made tables owned by system
Rem     ldoo       06/14/94 -  Creation of conflict resolution tables
Rem     adowning   02/04/94 -  Branch_for_patch
Rem     adowning   02/04/94 -  Creation
Rem     adowning   02/04/94 -  Official creation
Rem     jstamos    09/20/93 -  Creation
Rem     jstamos    09/20/93 -  Unofficial creation
Rem     ldoo       06/28/92 -  Added objects for collecting statistics.


--                               NOTE
-- the procedure dbms_repcat_utl.canonicalize converts names to a common form
-- the columns sname, oname, col, and rname_procedure in the following
--   repcat tables are canonicalized
-- each variable with the name canon_* must have been canonicalized
-- each IN parameter with the name canon_* must be canonicalized
--   unless specified otherwise, such a parameter must not be NULL

-- Sys is granted priviledges through roles, which don't apply to
-- packages owned by sys.  Explicitly grant permissions.
grant select any table to sys with admin option
/
grant insert any table to sys
/
grant update any table to sys
/
grant delete any table to sys
/
grant lock any table to sys
/
grant select any sequence to sys
/


--  create a table for replicated object groups
CREATE TABLE system.repcat$_repcat
(
  gowner          VARCHAR2(30) default 'PUBLIC', --- obj group's owner
  sname           VARCHAR2(30),  -- interpreted as object group name
                  CONSTRAINT repcat$_repcat_primary 
                    PRIMARY KEY(sname, gowner),
  master          VARCHAR2(1),   -- Y=master, N=snapshot
  status          INTEGER        -- master: NORMAL, QUIESCING, or QUIESCED
                                 -- snapshot: NULL
                    CONSTRAINT repcat$_repcat_status
                      CHECK (status IN (0, 1, 2)),
  schema_comment  VARCHAR2(80),
  flavor_id       NUMBER,        -- local flavor of object group
  flag            raw(4) default '00000000'
)
/
comment on table SYSTEM.REPCAT$_REPCAT is
'Information about all replicated object groups'
/
comment on column SYSTEM.REPCAT$_REPCAT.GOWNER is
'Owner of the object group'
/
comment on column SYSTEM.REPCAT$_REPCAT.SNAME is
'Name of the replicated object group'
/
comment on column SYSTEM.REPCAT$_REPCAT.MASTER is
'Is the site a master site for the replicated object group'
/
comment on column SYSTEM.REPCAT$_REPCAT.STATUS is
'If the site is a master, the master''s status'
/
comment on column SYSTEM.REPCAT$_REPCAT.SCHEMA_COMMENT is
'Description of the replicated object group'
/
comment on column SYSTEM.REPCAT$_REPCAT.FLAVOR_ID is
'Flavor identifier'
/
comment on column SYSTEM.REPCAT$_REPCAT.FLAG is
'Miscellaneous repgroup info'
/


-- create a top-level table to hold flavor definitions
CREATE TABLE system.repcat$_flavors
(
  flavor_id        NUMBER NOT NULL,
  gowner           VARCHAR2(30) DEFAULT 'PUBLIC', 
  gname            VARCHAR2(30) NOT NULL,
                     CONSTRAINT repcat$_flavors_unq1
                       UNIQUE (gname, flavor_id, gowner),
                     CONSTRAINT repcat$_flavors_fk1
                       FOREIGN KEY (gname, gowner)
                       REFERENCES system.repcat$_repcat(sname, gowner)
                       ON DELETE CASCADE,
  fname            VARCHAR2(30),
  creation_date    DATE DEFAULT SYSDATE,
  created_by       NUMBER DEFAULT UID,
  published        VARCHAR2(1) DEFAULT 'N',
                     CONSTRAINT repcat$_flavors_c2 CHECK
                       (published is NULL or (published in ('Y','N','O')))
)
/
CREATE INDEX system.repcat$_flavors_fname ON
  system.repcat$_flavors(fname)
/

CREATE UNIQUE INDEX system.repcat$_flavors_gname ON
  system.repcat$_flavors(gname, fname, gowner)
/
CREATE INDEX system.repcat$_flavors_fk1_idx ON
  system.repcat$_flavors(gname, gowner)
/
comment on table SYSTEM.REPCAT$_FLAVORS is
'Flavors defined for replicated object groups'
/
comment on column SYSTEM.REPCAT$_FLAVORS.FLAVOR_ID is
'Flavor identifier, unique within object group'
/
comment on column SYSTEM.REPCAT$_FLAVORS.GOWNER is
'Owner of the object group'
/
comment on column SYSTEM.REPCAT$_FLAVORS.GNAME is
'Name of the object group'
/
comment on column SYSTEM.REPCAT$_FLAVORS.FNAME is
'Name of the flavor'
/
comment on column SYSTEM.REPCAT$_FLAVORS.CREATION_DATE is
'Date on which the flavor was created'
/
comment on column SYSTEM.REPCAT$_FLAVORS.CREATED_BY is
'Identifier of user that created the flavor'
/
comment on column SYSTEM.REPCAT$_FLAVORS.PUBLISHED is
'Indicates whether flavor is published (Y/N) or obsolete (O)'
/

-- create a sequence to identify flavors within an object group
create sequence system.repcat$_flavors_s nocache
/

-- create a sequence used for automatic generation of flavor names
create sequence system.repcat$_flavor_name_s nocache
/

-- flavor ID is sb4 (see knift)
alter sequence system.repcat$_flavors_s
  increment by 1
  minvalue -2147483647
  maxvalue 2147483647
/
 
CREATE OR REPLACE VIEW repcat_repcat
  (sname, --- OBSOLETE
   master, status, schema_comment, gname, fname, rpc_processing_disabled,
   gowner) 
  AS
  SELECT r.sname, r.master,
         DECODE (r.status, 0,    'NORMAL',
                           1,    'QUIESCING',
                           2,    'QUIESCED',
                           NULL, 'NORMAL',
                                 'UNDEFINED'),
         r.schema_comment, r.sname, f.fname,
         DECODE(utl_raw.bit_and(utl_raw.substr(r.flag, 1, 1), '01'), 
                '00', 'N', 'Y'),
         r.gowner
  FROM system.repcat$_repcat r, system.repcat$_flavors f
  WHERE r.sname     = f.gname (+)
    AND r.flavor_id = f.flavor_id (+)
    AND r.gowner    = f.gowner (+)
/
comment on table REPCAT_REPCAT is
'Information about all replicated object groups'
/
comment on column REPCAT_REPCAT.SNAME is
'OBSOLETE COLUMN: Name of the replicated schema'
/
comment on column REPCAT_REPCAT.GOWNER is
'Owner of the replicated object group'
/
comment on column REPCAT_REPCAT.GNAME is
'Name of the replicated object group'
/
comment on column REPCAT_REPCAT.MASTER is
'Is the site a master site for the replicated object group'
/
comment on column REPCAT_REPCAT.STATUS is
'If the site is a master, the master''s status'
/
comment on column REPCAT_REPCAT.SCHEMA_COMMENT is
'Description of the replicated object group'
/
comment on column REPCAT_REPCAT.FNAME is
'Flavor name'
/
comment on column REPCAT_REPCAT.RPC_PROCESSING_DISABLED is
'Whether this site disables processing of replication RPC'
/
grant select on REPCAT_REPCAT to select_catalog_role
/


-- Create a table to hold the masters for replicated object groups.
-- If it is modified, modify the repcat_repschema view if appropriate.
-- For snapshot site (gowner, sname) will specify that this entry is for the 
-- snapshot object group. It does not imply that the owner of the group at 
-- master site (snapmaster == 'Y') is the same as the value of gowner
-- (the group owner of master groups is always PUBLIC).
CREATE TABLE system.repcat$_repschema
(
  gowner          VARCHAR2(30) DEFAULT 'PUBLIC',  -- owner of the object group
  sname           VARCHAR2(30),   -- interpreted as object group name
                    CONSTRAINT repcat$_repschema_prnt 
                      FOREIGN KEY(sname, gowner)
                      REFERENCES system.repcat$_repcat(sname, gowner)
                      ON DELETE CASCADE,
  dblink          VARCHAR2(128),  -- a master site (M_XDBI)
                    CONSTRAINT repcat$_repschema_primary
                      PRIMARY KEY(sname, dblink, gowner),
  masterdef       VARCHAR2(1),
                    -- Y: the master has the authoritative definition
                    -- N: the master has a copy
  snapmaster      VARCHAR2(1),
                    -- this col is maintained independently at each replica
                    -- master: NULL
                    -- snapshot: Y indicates current master for refreshing
                    -- snapshot: N for all other masters
  master_comment  VARCHAR2(80),
  master          VARCHAR2(1),
                    -- Y=master, N=snapshot
                    -- this column duplicates repcat$_repcat.master
                    -- it is here to improve deferred RPC performance
  prop_updates    NUMBER DEFAULT 0,
  my_dblink       VARCHAR2(1),
                    -- Y = the dblink is my global_name
                    -- N = ignore
                    -- this column is here to detect a problem during import
  extension_id    RAW(16) DEFAULT '00',
                    CONSTRAINT repcat$_repschema_dest
                      FOREIGN KEY(dblink, extension_id)
                      REFERENCES system.def$_destination(dblink, catchup)
)
/
-- index on foreign key to avoid deadlocks in
-- concurrent do_deferred_repcat_admin
create index system.repcat$_repschema_dest_idx on
  system.repcat$_repschema(dblink, extension_id)
/
create index system.repcat$_repschema_prnt_idx on
  system.repcat$_repschema(sname, gowner)
/
comment on table SYSTEM.REPCAT$_REPSCHEMA is
'N-way replication information'
/
comment on column SYSTEM.REPCAT$_REPSCHEMA.GOWNER is
'Owner of the replicated object group'
/
comment on column SYSTEM.REPCAT$_REPSCHEMA.SNAME is
'Name of the replicated object group'
/
comment on column SYSTEM.REPCAT$_REPSCHEMA.DBLINK is
'A database site replicating the object group'
/
comment on column SYSTEM.REPCAT$_REPSCHEMA.MASTERDEF is
'Is the database the master definition site for the replicated object group'
/
comment on column SYSTEM.REPCAT$_REPSCHEMA.SNAPMASTER is
'For a snapshot site, is this the current refresh_master'
/
comment on column SYSTEM.REPCAT$_REPSCHEMA.MASTER_COMMENT is
'Description of the database site'
/
comment on column SYSTEM.REPCAT$_REPSCHEMA.MASTER is
'Redundant information from repcat$_repcat.master'
/
comment on column SYSTEM.REPCAT$_REPSCHEMA.PROP_UPDATES is
'Number of requested updates for master in repcat$_repprop'
/
comment on column SYSTEM.REPCAT$_REPSCHEMA.MY_DBLINK is
'A sanity check after import: is this master the current site'
/
comment on column SYSTEM.REPCAT$_REPSCHEMA.EXTENSION_ID is
'Dummy column for foreign key'
/

-- hide unnormalized, duplicate data (master column) from users
CREATE OR REPLACE VIEW repcat_repschema 
(sname, --- OBSOLETE
 dblink, masterdef, snapmaster, master_comment, gname, master, gowner)
AS
SELECT sname, dblink, masterdef, snapmaster, master_comment, sname, master,
       gowner
FROM system.repcat$_repschema
/
comment on table REPCAT_REPSCHEMA is
'N-way replication information'
/
comment on column REPCAT_REPSCHEMA.GOWNER is
'Owner of the replicated object group'
/
comment on column REPCAT_REPSCHEMA.SNAME is
'OBSOLETE COLUMN: Name of the replicated schema'
/
comment on column REPCAT_REPSCHEMA.GNAME is
'Name of the replicated object group'
/
comment on column REPCAT_REPSCHEMA.DBLINK is
'A database site replicating the object group'
/
comment on column REPCAT_REPSCHEMA.MASTERDEF is
'Is the database the master definition site for the replicated object group'
/
comment on column REPCAT_REPSCHEMA.SNAPMASTER is
'For a snapshot site, is this the current refresh_master'
/
comment on column REPCAT_REPSCHEMA.MASTER_COMMENT is
'Description of the database site'
/
comment on column REPCAT_REPSCHEMA.MASTER is
'Redundant information from repcat_repcat.master'
/
grant select on REPCAT_REPSCHEMA to select_catalog_role
/


-- create a table to store snapshot repgroup registration information
create TABLE system.repcat$_snapgroup
(
  gowner        VARCHAR2(30) DEFAULT 'PUBLIC',  
  gname         VARCHAR2(30),  
  dblink        VARCHAR2(128),
  group_comment VARCHAR2(80),
  rep_type       NUMBER,
  flavor_id      NUMBER         -- flavor of object group at snapshot
)
/
comment on table SYSTEM.REPCAT$_SNAPGROUP is
'Snapshot repgroup registration information'
/
comment on column SYSTEM.REPCAT$_SNAPGROUP.GOWNER is
'Owner of the snapshot repgroup'
/
comment on column SYSTEM.REPCAT$_SNAPGROUP.GNAME is
'Name of the snapshot repgroup'
/
comment on column SYSTEM.REPCAT$_SNAPGROUP.DBLINK is
'Database site of the snapshot repgroup'
/
comment on column SYSTEM.REPCAT$_SNAPGROUP.GROUP_COMMENT is
'Description of the snapshot repgroup'
/
comment on column SYSTEM.REPCAT$_SNAPGROUP.REP_TYPE is
'Type of the snapshot repgroup'
/
comment on column SYSTEM.REPCAT$_SNAPGROUP.REP_TYPE is
'Identifier of flavor at snapshot'
/
CREATE UNIQUE INDEX system.i_repcat$_snapgroup1 ON 
  system.repcat$_snapgroup(gname, dblink, gowner)
/

-------------------------------------------------------------
--- This view is obsolete and has been replaced by
--- DBA_REGISTERED_MVIEW_GROUPS. This view is kept only for backwards 
--- compatibility. In the future, any modifications should be done
--- in DBA_REGISTERED_MVIEW_GROUPS.
-------------------------------------------------------------
CREATE OR REPLACE VIEW dba_registered_snapshot_groups
  (NAME, SNAPSHOT_SITE, GROUP_COMMENT, VERSION, FNAME, OWNER)
as select s.gname, s.dblink, s.group_comment,
          decode(s.rep_type, 1, 'ORACLE 7',
                             2, 'ORACLE 8',
                             3, 'REPAPI', 
                                'UNKNOWN'),
          f.fname, s.gowner
from system.repcat$_snapgroup s, system.repcat$_flavors f
  WHERE s.gname     = f.gname (+)
    AND s.flavor_id = f.flavor_id (+)
    AND s.gowner    = f.gowner (+)
/
create or replace public synonym DBA_REGISTERED_SNAPSHOT_GROUPS
  for DBA_REGISTERED_SNAPSHOT_GROUPS 
/
grant select on DBA_REGISTERED_SNAPSHOT_GROUPS to select_catalog_role
/
comment on table DBA_REGISTERED_SNAPSHOT_GROUPS is
'Snapshot repgroup registration information'
/
comment on column DBA_REGISTERED_SNAPSHOT_GROUPS.OWNER is
'Owner of the snapshot repgroup'
/
comment on column DBA_REGISTERED_SNAPSHOT_GROUPS.NAME is
'Name of the snapshot repgroup'
/
comment on column DBA_REGISTERED_SNAPSHOT_GROUPS.SNAPSHOT_SITE is
'Database site of the snapshot repgroup'
/
comment on column DBA_REGISTERED_SNAPSHOT_GROUPS.GROUP_COMMENT is
'Description of the snapshot repgroup'
/
comment on column DBA_REGISTERED_SNAPSHOT_GROUPS.VERSION is
'Version of the snapshot repgroup'
/
comment on column DBA_REGISTERED_SNAPSHOT_GROUPS.FNAME is
'Name of the flavor of the snapshot repgroup'
/

-------------------------------------------------------------
--- This view replaces DBA_REGISTERED_SNAPSHOT_GROUPS. 
-------------------------------------------------------------
CREATE OR REPLACE VIEW dba_registered_mview_groups
  (NAME, MVIEW_SITE, GROUP_COMMENT, VERSION, FNAME, OWNER)
as select s.gname, s.dblink, s.group_comment,
          decode(s.rep_type, 1, 'ORACLE 7',
                             2, 'ORACLE 8',
                             3, 'REPAPI', 
                                'UNKNOWN'),
          f.fname, s.gowner
from system.repcat$_snapgroup s, system.repcat$_flavors f
  WHERE s.gname     = f.gname (+)
    AND s.flavor_id = f.flavor_id (+)
    AND s.gowner    = f.gowner (+)
/
create or replace public synonym DBA_REGISTERED_MVIEW_GROUPS
  for DBA_REGISTERED_MVIEW_GROUPS 
/
grant select on DBA_REGISTERED_MVIEW_GROUPS to select_catalog_role
/
comment on table DBA_REGISTERED_MVIEW_GROUPS is
'Materialized view repgroup registration information'
/
comment on column DBA_REGISTERED_MVIEW_GROUPS.OWNER is
'Owner of the materialized view repgroup'
/
comment on column DBA_REGISTERED_MVIEW_GROUPS.NAME is
'Name of the materialized view repgroup'
/
comment on column DBA_REGISTERED_MVIEW_GROUPS.MVIEW_SITE is
'Database site of the materialized view repgroup'
/
comment on column DBA_REGISTERED_MVIEW_GROUPS.GROUP_COMMENT is
'Description of the materialized view repgroup'
/
comment on column DBA_REGISTERED_MVIEW_GROUPS.VERSION is
'Version of the materialized view repgroup'
/
comment on column DBA_REGISTERED_MVIEW_GROUPS.FNAME is
'Name of the flavor of the materialized view repgroup'
/


-- create a table that names the replicated objects
CREATE TABLE system.repcat$_repobject
(
  sname           VARCHAR2(30),  -- owner of replicated object
  oname           VARCHAR2(30),  -- replicated object name,
  type            INTEGER
                    CONSTRAINT repcat$_repobject_type
                      CHECK (type IN (-1, 1, 2, 4, 5, 7, 8, 9, 11, 12, -3,
                                      -4, 13, 14, 32, 33)),
                    --- type -4 (internal package) only exists in 
                    --- updatable snapshot sites
                    --- 13 = type, 14 = type body, 32 = indextype,
                    --- 33 = operator
                    CONSTRAINT repcat$_repobject_primary
                      PRIMARY KEY(sname, oname, type),
  version#        NUMBER -- Version# for TYPE
                  CONSTRAINT repcat$_repobject_version
                    CHECK (version# >= 0 AND version# < 65536),
  hashcode        RAW(17), -- hashcode for TYPE
  id              NUMBER,
  object_comment  VARCHAR2(80),
  status          INTEGER
                    -- this col is maintained independently at each replica
                    CONSTRAINT repcat$_repobject_status
                      CHECK (status IN (0, 1, 2, 3, 4, 5, 6)),
  genpackage   INTEGER
      -- this col is set and used at the master def site only
      CONSTRAINT repcat$_repobject_genpackage
        CHECK (genpackage IN (0, 1, 2)),
  genplogid       INTEGER,
  gentrigger   INTEGER
      -- this col is set and used at the master def site only
      CONSTRAINT repcat$_repobject_gentrigger
        CHECK (gentrigger IN (0, 1, 2)),
  gentlogid       INTEGER,
  --- For generated objects objects (include $RP/$RL/
  --- repobject_type_internal_pkg) for snapshots at snapshot sites,
  --- the value of (gowner, gname) pairs will be NULL. This is because multiple
  --- snapshot may use the same generated object.
  --- Generated objects for procedural replications at snapshot sites
  --- will have the (gowner, gname) pair as its base objects.
  ---
  --- Note that repobject_type_internal_pkg only appears in repcat$_repobject
  --- in snapshot site, it is not recorded in repcat$_generated table.
  ---
  --- Generated objects can only be dropped when the last object using the 
  --- generated object is dropped. The new relationship between REPOBJECT 
  --- and GENERATED is many-to-many.
  gowner          VARCHAR2(30),  --- owner of object group
  gname           VARCHAR2(30),  --- replicated object group name
                    CONSTRAINT repcat$_repobject_prnt 
                      FOREIGN KEY(gname, gowner)
                      REFERENCES system.repcat$_repcat(sname, gowner)
                      ON DELETE CASCADE,
  -- usage of flag:
  --   first bit in least significant byte for min_commmunication,
  --   second bit in least significant byte is used to remember whether
  --     generate_replication_support has been invoked,
  --   third bit in least significant byte to indicate the existence of
  --     internal pkgs
  -- Note: if you ever change size of flag, please
  --       make corresponding changes in KNIPFLEN
  flag raw(4) default '00000000'
)
/
comment on table SYSTEM.REPCAT$_REPOBJECT is
'Information about replicated objects'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.GOWNER is
'Owner of the object''s object group'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.GNAME is
'Name of the object''s object group'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.SNAME is
'Name of the object owner'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.ONAME is
'Name of the object'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.TYPE is
'Type of the object'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.VERSION# is
'Version of objects of TYPE'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.HASHCODE is
'Hashcode of objects of TYPE'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.STATUS is
'Status of the last create or alter request on the local object'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.GENPACKAGE is
'Status of whether the object needs to generate replication package'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.GENPLOGID is
'Log id of message sent for generating package support'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.GENTRIGGER is
'Status of whether the object needs to generate replication trigger'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.GENTLOGID is
'Log id of message sent for generating trigger support'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.ID is
'Identifier of the local object'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.OBJECT_COMMENT is
'Description of the replicated object'
/
comment on column SYSTEM.REPCAT$_REPOBJECT.FLAG is
'Information about replicated object'
/
--- create index on (gname, oname, type) for faster access
CREATE INDEX system.repcat$_repobject_gname ON
  system.repcat$_repobject(gname, oname, type, gowner)
/
CREATE INDEX system.repcat$_repobject_prnt_idx ON
  system.repcat$_repobject(gname, gowner)
/


-- Create a base view to make more complex views easier to understand.
-- This view is for internal use only and may change without notice.
-- This view is intended for code that needs fast access to repcat$_repobject
-- or to obtain a row-level lock.  
CREATE OR REPLACE VIEW repcat_repobject_base
  (
   sname, oname, type, status, generation_status, id, object_comment,
   gowner, gname, trigflag, min_communication, internal_package_exists,
   receiver_tracing_enabled, nested_table, hashcode
  ) 
  AS
  SELECT sname, oname,
         DECODE (type, -1, 'SNAPSHOT',
                        1, 'INDEX',
                        2, 'TABLE',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       -4, 'INTERNAL PACKAGE',
                   --- -3, 'UPDATABLE SNAPSHOT',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                           'UNDEFINED'),
         DECODE (status, 0, 'CREATE',
                         1, 'COMPARE',
                         2, 'VALID',
                         3, 'DROPPED',
                         4, 'ERROR',
                         5, 'ABSENT',
                         6, 'INCOMPLETE',
                            'UNDEFINED'),
         DECODE (DECODE (gentrigger, NULL, genpackage, gentrigger * 3 +
                         genpackage),
                 0, 'GENERATED',  -- 0, 0
                 1, 'NEEDSGEN',   -- 0, 1
                 2, 'DOINGGEN',   -- 0, 2
                 3, 'NEEDSGEN',   -- 1, 0
                 4, 'NEEDSGEN',   -- 1, 1
                 5, 'DOINGGEN',   -- 1, 2
                 6, 'DOINGGEN',   -- 2, 0
                 7, 'DOINGGEN',   -- 2, 1
                 8, 'DOINGGEN'),  -- 2, 2
         id, object_comment, gowner, gname,
         DECODE(o.type,
                2, DECODE(bitand(t.trigflag, 1), 1, 'Y', 'N'),
                -1, DECODE(bitand(t.trigflag, 1), 1, 'Y', 'N'),
                NULL),
         DECODE(o.type,
                -1, DECODE(utl_raw.bit_and(utl_raw.substr(o.flag, 1, 1), '01'),
                           '00', 'N',
                           'Y'),
                2, DECODE(utl_raw.bit_and(utl_raw.substr(o.flag, 1, 1), '01'),
                          '00', 'N',
                          'Y'),
                NULL),
         DECODE(o.type,
                2, DECODE(utl_raw.bit_and(utl_raw.substr(o.flag, 1, 1), '04'),
                          '00', 'N',
                          'Y'),
                -1, DECODE(utl_raw.bit_and(utl_raw.substr(o.flag, 1, 1), '04'),
                          '00', 'N',
                          'Y'),
                NULL),
         DECODE(o.type,
                2, DECODE(utl_raw.bit_and(utl_raw.substr(o.flag, 1, 1), '10'),
                          '00', 'N',
                          'Y'),
                9, DECODE(utl_raw.bit_and(utl_raw.substr(o.flag, 1, 1), '10'),
                          '00', 'N',
                          'Y'),
                -1, DECODE(utl_raw.bit_and(utl_raw.substr(o.flag, 1, 1), '10'),
                          '00', 'N',
                          'Y'),
                NULL),
         DECODE(bitand(t.property, 8192), 8192, 'Y', 0, 'N'),
         RAWTOHEX(o.hashcode)
  FROM system.repcat$_repobject o, sys.tab$ t
  WHERE o.id = t.obj# (+)
/
comment on table REPCAT_REPOBJECT_BASE is
'Information about replicated objects'
/
comment on column REPCAT_REPOBJECT_BASE.GOWNER is
'Owner of the object''s object group'
/
comment on column REPCAT_REPOBJECT_BASE.GNAME is
'Name of the object''s object group'
/
comment on column REPCAT_REPOBJECT_BASE.SNAME is
'Name of the object owner'
/
comment on column REPCAT_REPOBJECT_BASE.ONAME is
'Name of the object'
/
comment on column REPCAT_REPOBJECT_BASE.TYPE is
'Type of the object'
/
comment on column REPCAT_REPOBJECT_BASE.STATUS is
'Status of the last create or alter request on the local object'
/
comment on column REPCAT_REPOBJECT_BASE.GENERATION_STATUS is
'Status of whether the object needs to generate replication packages'
/
comment on column REPCAT_REPOBJECT_BASE.ID is
'Identifier of the local object'
/
comment on column REPCAT_REPOBJECT_BASE.OBJECT_COMMENT is
'Description of the replicated object'
/
comment on column REPCAT_REPOBJECT_BASE.TRIGFLAG is
'Inline trigger flag'
/
comment on column REPCAT_REPOBJECT_BASE.INTERNAL_PACKAGE_EXISTS is
'Internal package exists?'
/
comment on column REPCAT_REPOBJECT_BASE.RECEIVER_TRACING_ENABLED is
'Tracing at receiving site is enabled?'
/
comment on column REPCAT_REPOBJECT_BASE.MIN_COMMUNICATION is
'Send only necessary OLD and NEW values for an updated row?'
/
comment on column REPCAT_REPOBJECT_BASE.NESTED_TABLE is
'Storage table for a nested table column?'
/
comment on column REPCAT_REPOBJECT_BASE.HASHCODE is
'Hashcode of an object of TYPE'
/
grant select on REPCAT_REPOBJECT_BASE to select_catalog_role
/


-- create a table that stores the replicated columns in sorted order
CREATE TABLE system.repcat$_repcolumn(
  sname VARCHAR2(30),
  oname VARCHAR2(30),
  type  INTEGER,
  -- cname refers to SYS column name, i.e., SYS.COL$.NAME if exists.
  -- If the column is an attribute column and the local flavor does not
  -- contain this column, cname is REPCAT$_PO<POS> if POS is not NULL or
  -- REPCAT$_SQ<sequence_no> if POS is NULL.
  cname         VARCHAR2(30),
  -- lcname refers to long column names. This column is needed
  -- for vertical partitioning since there is no SYS.ATTRCOL$ entry for an
  -- absent column in the local flavor.
  lcname        VARCHAR2(4000),
  toid          RAW(16), -- type TOID.
  version#      NUMBER
                  CONSTRAINT repcat$_repcolumn_version
                    CHECK (version# >= 0 AND version# < 65536),
  hashcode      RAW(17), -- type hashcode
  -- name of type is in obj$.name and
  -- ctype_owner of type is in user$.name. They are needed since a replica may
  -- not have the type replicated locally.
  -- ctype_name and ctype_owner may vary between a snapshot and its
  -- master. During get_repcolumn_info, this may need to be fixed up
  -- based on TOID (if exists).
  -- If a snapshot does not
  -- have this type replicated, (ctype_owner, ctype_name) refers to the
  -- type in its master.
  ctype_name    VARCHAR2(30),
  ctype_owner   VARCHAR2(30),
  id    NUMBER,  -- must match col$.intcol# in the local database
  pos   NUMBER,  -- order by pos asc(alphabetically sorted at masterdef)
      CONSTRAINT repcat$_repcolumn_pk
          PRIMARY KEY (sname, oname, type, cname),
      CONSTRAINT repcat$_repcolumn_fk
         FOREIGN KEY (sname, oname, type)
          REFERENCES system.repcat$_repobject
          ON DELETE CASCADE,
  -- top refers to the long column name of the top
  -- of an attribute. TOP is NULL if the column is top-level.
  top        VARCHAR2(30),
  flag  RAW(2) default '0000',
  ctype NUMBER,
  length NUMBER,     -- length in bytes
  precision# NUMBER,
  scale NUMBER,
  null$ NUMBER,
  charsetid NUMBER,  -- must be the local db or nchar charset id
  charsetform NUMBER,
  property RAW(4) default '00000000',
  clength NUMBER     -- length in characters
)
/
create index system.repcat$_repcolumn_fk_idx on
  system.repcat$_repcolumn(sname, oname, type)
/

comment on table SYSTEM.REPCAT$_REPCOLUMN is
'Replicated columns for a table sorted alphabetically in ascending order'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.SNAME is
'Name of the object owner'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.ONAME is
'Name of the object'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.TYPE is
'Type of the object'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.CNAME is
'Column name'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.ID is
'Column ID'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.POS is
'Ordering of column used as IN parameter in the replication procedures'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.FLAG is
'Replication information about column'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.CTYPE is
'Type of the column'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.LENGTH is
'Length of the column in bytes'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.PRECISION# is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.SCALE is
'Digits to right of decimal point in a number'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.NULL$ is
'Does column allow NULL values?'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.CHARSETID is
'Character set identifier'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.CHARSETFORM is
'Character set form'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.version# is
'Version# of a column of user-defined type'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.hashcode is
'Hashcode of a column of user-defined type'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.lcname is
'Long column name'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.toid is
'Type object identifier of a user-defined type'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.top is
'Top column name for an attribute'
/
comment on column SYSTEM.REPCAT$_REPCOLUMN.clength is
'The maximum length of the column in characters'
/


-- create a table that names "primary-key" columns for column-level repl
CREATE TABLE system.repcat$_key_columns
(
  sname  VARCHAR2(30),  -- schema name
  oname  VARCHAR2(30),  -- replicated object name
  type   INTEGER,
           CONSTRAINT repcat$_key_columns_prnt
             FOREIGN KEY(sname, oname, type)
             REFERENCES system.repcat$_repobject(sname, oname, type)
             ON DELETE CASCADE,
  -- COL refers to the SYS column name (SYS.COL$.NAME).
  -- Since COL is a pk column and the maximum allowable length
  -- for an index record is less than 800 bytes, we can not use
  -- long column name for COL.
  -- Please note that key columns must be present in all replicas,
  -- hence SYS.COL$.NAME must exist.
  col    VARCHAR2(30),
           CONSTRAINT repcat$_key_columns_primary
             PRIMARY KEY(sname, oname, col)
)
/

-- index on foreign key to avoid deadlocks in
-- concurrent do_deferred_repcat_admin
create index system.repcat$_key_columns_prnt_idx on
  system.repcat$_key_columns(sname, oname, type)
/

comment on table SYSTEM.REPCAT$_KEY_COLUMNS is
'Primary columns for a table using column-level replication'
/
comment on column SYSTEM.REPCAT$_KEY_COLUMNS.SNAME is
'Schema containing table'
/
comment on column SYSTEM.REPCAT$_KEY_COLUMNS.ONAME is
'Name of the table'
/
comment on column SYSTEM.REPCAT$_KEY_COLUMNS.TYPE is
'Type identifier'
/
comment on column SYSTEM.REPCAT$_KEY_COLUMNS.COL is
'Column in the table'
/

-- track the objects generated to support row/column-level replication
-- as well as wrappers generated to support procedural replication
CREATE TABLE system.repcat$_generated
(
  sname              VARCHAR2(30),  -- schema of generated object
  oname              VARCHAR2(30),  -- name of generated object
  type               INTEGER,     -- type of generated object
                       CONSTRAINT repcat$_repgen_prnt
                         FOREIGN KEY(sname, oname, type)
                         REFERENCES system.repcat$_repobject(sname, oname,
                                                             type)
                         ON DELETE CASCADE,
  reason              NUMBER,
                       CONSTRAINT repcat$_generated_obj
                         CHECK (reason IN (0, 1, 2, 3, 4, 5, 6, 7, 9, 10)),
                         -- 0 = trigger (Rep2 async propagation) $RT          
                         -- 1 = replication package              $RP
                         -- 2 = resolution package               $RR
                         -- 3 = priority package                 $RV
                         -- 4 = auditing package                 $RA
                         -- 5 = procedural replication wrapper   
                         -- 6 = Rep3 trigger package             $TP
                         -- 7 = Rep3 trigger (mixed propagation) $RT
                         -- 9 = LOB package                      $RL
                         -- 10 = update package                  $RU
  base_sname         VARCHAR2(30),  -- schema of user's object
  base_oname         VARCHAR2(30),  -- name of user's object
  base_type          INTEGER,     -- type of user's object
                       CONSTRAINT repcat$_repgen_primary
                         PRIMARY KEY(sname, oname, type,
                                     base_sname, base_oname, base_type),
                       CONSTRAINT repcat$_repgen_prnt2
                         FOREIGN KEY(base_sname, base_oname, base_type)
                         REFERENCES system.repcat$_repobject(sname, oname,
                                                             type)
                         ON DELETE CASCADE,
  package_prefix    VARCHAR2(30),   -- for package wrappers
  procedure_prefix  VARCHAR2(30),   -- for procedure and package wrappers
        -- universal code will have two 'Y's below
  distributed       VARCHAR2(1)     -- 'Y' or 'N'
)
/
comment on table SYSTEM.REPCAT$_GENERATED is
'Objects generated to support replication'
/
comment on column SYSTEM.REPCAT$_GENERATED.SNAME is
'Schema containing the generated object'
/
comment on column SYSTEM.REPCAT$_GENERATED.ONAME is
'Name of the generated object'
/
comment on column SYSTEM.REPCAT$_GENERATED.TYPE is
'Type of the generated object'
/
comment on column SYSTEM.REPCAT$_GENERATED.BASE_SNAME is
'Name of the object''s owner'
/
comment on column SYSTEM.REPCAT$_GENERATED.BASE_ONAME is
'Name of the object'
/
comment on column SYSTEM.REPCAT$_GENERATED.BASE_TYPE is
'Type of the object'
/
comment on column SYSTEM.REPCAT$_GENERATED.REASON is
'Reason the object was generated'
/
comment on column SYSTEM.REPCAT$_GENERATED.PACKAGE_PREFIX is
'Prefix for package wrapper'
/
comment on column SYSTEM.REPCAT$_GENERATED.PROCEDURE_PREFIX is
'Procedure prefix for package wrapper or procedure wrapper'
/
comment on column SYSTEM.REPCAT$_GENERATED.DISTRIBUTED is
'Is the generated object separately generated at each master'
/

CREATE INDEX system.repcat$_generated_n1 ON
  system.repcat$_generated(base_sname, base_oname, base_type)
/

CREATE INDEX system.repcat$_repgen_prnt_idx ON
  system.repcat$_generated(sname, oname, type)
/

CREATE OR REPLACE VIEW repcat_generated
  (sname, oname, type, reason, base_sname, base_oname, base_type, 
   package_prefix, procedure_prefix, distributed) AS
  SELECT
    sname,
    oname,
    DECODE (type,
      -1, 'SNAPSHOT',
       1, 'INDEX',
       2, 'TABLE',
       4, 'VIEW',
       5, 'SYNONYM',
       6, 'SEQUENCE',
       7, 'PROCEDURE',
       8, 'FUNCTION',
       9, 'PACKAGE',
      11, 'PACKAGE BODY',
      12, 'TRIGGER',
      --- -3, 'UPDATABLE SNAPSHOT',
          'UNDEFINED'),
    DECODE (reason,
       0, 'REPLICATION TRIGGER',
       1, 'REPLICATION PACKAGE',
       2, 'RESOLUTION PACKAGE',
       3, 'PRIORITY PACKAGE',
       4, 'AUDIT PACKAGE',
       5, 'PROCEDURAL REPLICATION WRAPPER',
       6, 'TRIGGER PACKAGE',
       7, 'MIXED REPLICATION TRIGGER',
       8, 'MIXED REPLICATION WRAPPER',
       9, 'LOB PACKAGE',
      10, 'REPLICATION UPDATE PACKAGE',
          'UNDEFINED'),
    base_sname,
    base_oname,
    DECODE (base_type,
      -1, 'SNAPSHOT',
       1, 'INDEX',
       2, 'TABLE',
       4, 'VIEW',
       5, 'SYNONYM',
       6, 'SEQUENCE',
       7, 'PROCEDURE',
       8, 'FUNCTION',
       9, 'PACKAGE',
      11, 'PACKAGE BODY',
      12, 'TRIGGER',
      --- -3, 'UPDATABLE SNAPSHOT',
          'UNDEFINED'),
    package_prefix,
    procedure_prefix,
    distributed
  FROM system.repcat$_generated
/
comment on table REPCAT_GENERATED is
'Objects generated to support replication'
/
comment on column REPCAT_GENERATED.SNAME is
'Schema containing the generated object'
/
comment on column REPCAT_GENERATED.ONAME is
'Name of the generated object'
/
comment on column REPCAT_GENERATED.TYPE is
'Type of the generated object'
/
comment on column REPCAT_GENERATED.BASE_SNAME is
'Name of the object''s owner'
/
comment on column REPCAT_GENERATED.BASE_ONAME is
'Name of the object'
/
comment on column REPCAT_GENERATED.BASE_TYPE is
'Type of the object'
/
comment on column REPCAT_GENERATED.PACKAGE_PREFIX is
'Prefix for package wrapper'
/
comment on column REPCAT_GENERATED.PROCEDURE_PREFIX is
'Procedure prefix for package wrapper or procedure wrapper'
/
comment on column REPCAT_GENERATED.DISTRIBUTED is
'Is the generated object separately generated at each master'
/
grant select on REPCAT_GENERATED to select_catalog_role
/


--- Since (gowner,gname) may be NULL for generated objects ($RP/$RL/
--- repobject_type_internal_pkg) at snapshot sites.
--- We will need to join with REPCAT_GENERATED to get the correct
--- group name and owner (See repcat$_repobject)
--- This view is now a union of three queries:
--- Query 1: Get all objects explicitly registered with 
---          create_{snapshot,master}_repobject().
--- Query 2: Get all of the generated objects shared by any snapshot repobjects
---          where (gowner, gname) is NULL.
--- Query 3: Get the internal package for each snapshot. This is the tricky 
---          part because internal packages are not registered in 
---          repcat$_generated.
CREATE OR REPLACE VIEW repcat_repobject
(
   sname, oname, type, status, generation_status, id, object_comment,
   gowner, gname, trigflag, min_communication, internal_package_exists,
   receiver_tracing_enabled, nested_table, hashcode
)
AS 
SELECT sname, oname, type, status, generation_status, id, object_comment,
       gowner, gname, trigflag, min_communication, internal_package_exists,
       receiver_tracing_enabled, nested_table, hashcode
  FROM repcat_repobject_base
 WHERE gowner IS NOT NULL AND gname IS NOT NULL
UNION
SELECT o.sname, o.oname, o.type, o.status, o.generation_status, o.id, 
       o.object_comment, bo.gowner, bo.gname, o.trigflag, o.min_communication,
       o.internal_package_exists, o.receiver_tracing_enabled,
       o.nested_table, o.hashcode
  FROM repcat_repobject_base o, repcat_generated g, repcat_repobject_base bo
 WHERE (o.gowner IS NULL AND o.gname IS NULL)
   AND (o.sname = g.sname AND o.oname = g.oname AND o.type = g.type)
   AND (bo.sname = g.base_sname AND bo.oname = g.base_oname AND 
        bo.type = g.base_type)
   AND (bo.gowner IS NOT NULL AND bo.gname IS NOT NULL)
UNION
SELECT o.sname, o.oname, o.type, o.status, o.generation_status, o.id, 
       o.object_comment, bo.gowner, bo.gname, o.trigflag, o.min_communication,
       o.internal_package_exists, o.receiver_tracing_enabled,
       o.nested_table, o.hashcode
  FROM repcat_repobject_base o, repcat_repobject_base bo, sys.snap$ s
 WHERE (o.gowner IS NULL AND o.gname IS NULL AND o.type = 'INTERNAL PACKAGE')
   AND o.sname = s.mowner AND o.oname = s.master
   AND (bo.sname = s.sowner AND bo.oname = s.vname AND bo.type = 'SNAPSHOT')
   AND (s.mlink IS NOT NULL AND
        SUBSTR(s.mlink, 2) NOT IN (SELECT global_name from global_name))
   AND s.instsite = 0 
/
comment on table REPCAT_REPOBJECT is
'Information about replicated objects'
/
comment on column REPCAT_REPOBJECT.GOWNER is
'Owner of the object''s object group'
/
comment on column REPCAT_REPOBJECT.GNAME is
'Name of the object''s object group'
/
comment on column REPCAT_REPOBJECT.SNAME is
'Name of the object owner'
/
comment on column REPCAT_REPOBJECT.ONAME is
'Name of the object'
/
comment on column REPCAT_REPOBJECT.TYPE is
'Type of the object'
/
comment on column REPCAT_REPOBJECT.STATUS is
'Status of the last create or alter request on the local object'
/
comment on column REPCAT_REPOBJECT.GENERATION_STATUS is
'Status of whether the object needs to generate replication packages'
/
comment on column REPCAT_REPOBJECT.ID is
'Identifier of the local object'
/
comment on column REPCAT_REPOBJECT.OBJECT_COMMENT is
'Description of the replicated object'
/
comment on column REPCAT_REPOBJECT.TRIGFLAG is
'Inline trigger flag'
/
comment on column REPCAT_REPOBJECT.INTERNAL_PACKAGE_EXISTS is
'Internal package exists?'
/
comment on column REPCAT_REPOBJECT.RECEIVER_TRACING_ENABLED is
'Tracing at receiving site is enabled?'
/
comment on column REPCAT_REPOBJECT.MIN_COMMUNICATION is
'Send only necessary OLD and NEW values for an updated row?'
/
comment on column REPCAT_REPOBJECT.HASHCODE is
'Hashcode of an object of TYPE'
/
comment on column REPCAT_REPOBJECT.NESTED_TABLE is
'Storage table for a nested table column?'
/
grant select on REPCAT_REPOBJECT to select_catalog_role
/


-- create a table to hold propagation information
-- (row-level and column-level replication of tables)
-- (procedure wrappers)
CREATE TABLE system.repcat$_repprop
(
  sname              VARCHAR2(30),  -- schema name
  oname              VARCHAR2(30),  -- replicated object name
  type               INTEGER,
                       CONSTRAINT repcat$_repprop_prnt
                         FOREIGN KEY(sname, oname, type)
                         REFERENCES system.repcat$_repobject(sname, oname,
                                                             type)
                         ON DELETE CASCADE,
  dblink             VARCHAR2(128),  -- a master site (M_XDBI)
                       CONSTRAINT repcat$_repprop_primary
                         PRIMARY KEY(sname, oname, type, dblink),
---                       CONSTRAINT repcat$_repprop_prnt2
---                         FOREIGN KEY(sname, dblink)
---                         REFERENCES system.repcat$_repschema(sname, dblink)
---                         ON DELETE CASCADE,
  how                INTEGER
                       CONSTRAINT repcat$_repprop_how
                         CHECK (how IN (0, 1, 2, 3)),
                         --- 0 = None
                         --- 1 = Asynchronous
                         --- 2 = Synchronous
                         --- 3 = Sync optional async
  propagate_comment  VARCHAR2(80),
  delivery_order     NUMBER,
  recipient_key      NUMBER,              -- key of (sname, oname)
  extension_id       RAW(16) DEFAULT '00'
)
/
comment on table SYSTEM.REPCAT$_REPPROP is
'Propagation information about replicated objects'
/
comment on column SYSTEM.REPCAT$_REPPROP.SNAME is
'Name of the object owner'
/
comment on column SYSTEM.REPCAT$_REPPROP.ONAME is
'Name of the object'
/
comment on column SYSTEM.REPCAT$_REPPROP.TYPE is
'Type of the object'
/
comment on column SYSTEM.REPCAT$_REPPROP.DBLINK is
'Destination database for propagation'
/
comment on column SYSTEM.REPCAT$_REPPROP.HOW is
'Propagation choice for the destination database'
/
comment on column SYSTEM.REPCAT$_REPPROP.PROPAGATE_COMMENT is
'Description of the propagation choice'
/
comment on column SYSTEM.REPCAT$_REPPROP.DELIVERY_ORDER is
'Value of delivery order when the master was added'
/
comment on column SYSTEM.REPCAT$_REPPROP.RECIPIENT_KEY is
'Recipient key for sname and oname, used in joining with def$_aqcall'
/
comment on column SYSTEM.REPCAT$_REPPROP.EXTENSION_ID is
'Identifier of any active extension request'
/

-- make the global low water mark computation faster
-- since repcat$_repprop is for admin, read is a far more
-- frequent operations than update, it pays off to create such index
CREATE INDEX system.repcat$_repprop_dblink_how
  ON system.repcat$_repprop (dblink, how, extension_id, recipient_key)
/

-- make the join on recipient key faster
CREATE INDEX system.repcat$_repprop_key_index
  ON system.repcat$_repprop (recipient_key)
/

CREATE INDEX system.repcat$_repprop_prnt_idx
  ON system.repcat$_repprop (sname, oname, type)
/

CREATE INDEX system.repcat$_repprop_prnt2_idx
  ON system.repcat$_repprop (sname, dblink)
/

-- create sequence for recipient key 
-- (schema_name, package_name ---> recipient key)
CREATE SEQUENCE system.repcat$_repprop_key
/


CREATE OR REPLACE VIEW repcat_repprop
  (sname, oname, type, dblink, how, propagate_comment)
  AS SELECT
    p.sname,
    p.oname,
    DECODE (p.type,
      -1, 'SNAPSHOT',
       1, 'INDEX',
       2, 'TABLE',
       4, 'VIEW',
       5, 'SYNONYM',
       6, 'SEQUENCE',
       7, 'PROCEDURE',
       8, 'FUNCTION',
       9, 'PACKAGE',
      11, 'PACKAGE BODY',
      12, 'TRIGGER',
      -4, 'INTERNAL PACKAGE',
      --- -3, 'UPDATABLE SNAPSHOT',
          'UNDEFINED'),
    p.dblink,
    DECODE (p.how,
      0, 'NONE',
      1, 'ASYNCHRONOUS',
      2, 'SYNCHRONOUS',
      3, 'SYNC_OR_ASYNC',
         'UNDEFINED'),
    p.propagate_comment
  FROM system.repcat$_repprop p
  WHERE (p.sname, p.oname, p.type)
    NOT IN (SELECT sname, oname, type from system.repcat$_generated)
    AND p.oname != 'REP$WHAT_AM_I'
/
comment on table REPCAT_REPPROP is
'Propagation information about replicated objects'
/
comment on column REPCAT_REPPROP.SNAME is
'Name of the object owner'
/
comment on column REPCAT_REPPROP.ONAME is
'Name of the object'
/
comment on column REPCAT_REPPROP.TYPE is
'Type of the object'
/
comment on column REPCAT_REPPROP.DBLINK is
'Destination database for propagation'
/
comment on column REPCAT_REPPROP.HOW is
'Propagation choice for the destination database'
/
comment on column REPCAT_REPPROP.PROPAGATE_COMMENT is
'Description of the propagation choice'
/
grant select on REPCAT_REPPROP to select_catalog_role
/


-- create a table to hold the repcat intentions list and asynchronous errors
--- The sname column will always contain a schema name. This value may
--- also be the name of an existing object group.
--- The gname column contains a non-null only if gname != sname, otherwise
--- gname is NULL
CREATE TABLE system.repcat$_repcatlog
(
  version       NUMBER,           -- repcat version number
  id            NUMBER,           -- sequence number
  source        VARCHAR2(128),    -- where the request originated
  userid        VARCHAR2(30),     -- who made the request
  timestamp     DATE,             -- when the request was made
  role          VARCHAR2(1),      -- 'Y' for masterdef and 'N' for master
  master        VARCHAR2(128),    -- which master executes this intention
                  CONSTRAINT repcat$_repcatlog_primary
                    PRIMARY KEY(id, source, role, master),
  sname         VARCHAR2(30),     -- schema name
  request       INTEGER,          -- repcat administrative procedure name
                  CONSTRAINT repcat$_repcatlog_request
                    CHECK (request IN (-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                                       11, 12, 13, 14, 15, 16, 17,
                                       18, 19, 20, 21, 22, 23, 24, 25)),
  oname         VARCHAR2(30),     -- replicated object name, if applicable
  type          INTEGER,          -- replicated object type, if applicable
                  CONSTRAINT repcat$_repcatlog_type
                    CHECK (type IN (-1, 0, 1, 2, 4, 5, 7, 8, 9, 11, 12, -3,
                                    13, 14, 32, 33)),
  a_comment     VARCHAR2(2000),   -- replicated comment, if applicable
  bool_arg      VARCHAR2(1),      -- boolean argument, if applicable
  ano_bool_arg  VARCHAR2(1),      -- another boolean argument, if applicable
  int_arg       INTEGER,          -- integer argument, if applicable
  ano_int_arg   INTEGER,          -- another integer argument, if applicable
  lines         INTEGER,          -- number of lines in repcat$_ddl
  status        INTEGER
                  CONSTRAINT repcat$_repcatlog_status
                    CHECK (status IN (0, 1, 2, 3, 4)),
  message       VARCHAR2(200),    -- error message
  errnum        NUMBER,           -- Oracle error number
  gname         VARCHAR2(30)      -- replicated object group name
)
/
comment on table SYSTEM.REPCAT$_REPCATLOG is
'Information about asynchronous administration requests'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.VERSION is
'Version of the repcat log record'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.ID is
'Identifying number of repcat log record'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.SOURCE is
'Name of the database at which the request originated'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.USERID is
'Name of the user who submitted the request'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.TIMESTAMP is
'When the request was submitted'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.ROLE is
'Is this database the masterdef for the request'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.MASTER is
'Name of the database that processes this request$_ddl'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.GNAME is
'Name of the replicated object group'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.REQUEST is
'Name of the requested operation'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.SNAME is
'Schema of replicated object'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.ONAME is
'Replicated object name, if applicable'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.TYPE is
'Type of replicated object, if applicable'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.A_COMMENT is
'Textual argument used for comments'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.BOOL_ARG is
'Boolean argument'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.ANO_BOOL_ARG is
'Another Boolean argument'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.INT_ARG is
'Integer argument'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.ANO_INT_ARG is
'Another integer argument'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.LINES is
'The number of rows in system.repcat$_ddl at the processing site'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.STATUS is
'Status of the request at this database'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.MESSAGE is
'Error message associated with processing the request'
/
comment on column SYSTEM.REPCAT$_REPCATLOG.ERRNUM is
'Oracle error number associated with processing the request'
/

--- create index on (gname, sname, oname, type) for faster access
CREATE INDEX system.repcat$_repcatlog_gname ON
  system.repcat$_repcatlog(gname, sname, oname, type)
/


-- hide arguments and encodings from users
CREATE OR REPLACE VIEW repcat_repcatlog
  (id, source, status, userid, timestamp, role, master, request, 
   sname, oname, type, message, errnum, gname)
  AS SELECT
    id,
    source,
    DECODE(status,
      0, 'READY',
      1, 'DO_CALLBACK',
      2, 'AWAIT_CALLBACK',
      3, 'ERROR',
         'UNDEFINED'),
    userid,
    timestamp,
    DECODE (role,
      'Y', 'MASTERDEF',
      'N', 'MASTER',
           'UNDEFINED'),
    master,
    DECODE(request,
      -1, 'WAITING',
       0, 'CREATE_MASTER_REPOBJECT',
       1, 'DROP_MASTER_REPSCHEMA',
       2, 'ADD_MASTER_DATABASE',
       3, 'ALTER_MASTER_REPOBJECT',
       4, 'DROP_MASTER_REPOBJECT',
       5, 'SUSPEND_MASTER_ACTIVITY',
       6, 'RESUME_MASTER_ACTIVITY',
       7, 'EXECUTE_DDL',
       8, 'GENERATE_REPLICATION_SUPPORT',
       9, 'GENERATE_SUPPORT_PHASE_1',
      10, 'GENERATE_SUPPORT_PHASE_2',
      11, 'ALTER_MASTER_PROPAGATION',
      12, 'END_PHASE_2',
      13, 'GENERATE_INTERNAL_PKG_SUPPORT',
      14, 'END_GEN_INTERNAL_PKG_SUPPORT',
      15, 'COPY_FLAVOR_DEFINITIONS',
      16, 'COMPILE_MASTER_REPOBJECT',
      17, 'RENAME_SHADOW_COLUMN_GROUP',
      18, 'PULL_EXTENSION',
      19, 'CONTROL_PROPAGATION',
      20, 'WAIT_FOR_NEW_SITES_TO_PREPARE',
      21, 'ADD_COLUMN_PHASE_1',
      22, 'ADD_COLUMN_PHASE_2',
      23, 'ADD_COLUMN_PHASE_3',
      24, 'ADD_COLUMN_PHASE_4',
      25, 'PREPARE_FOR_IMPORT',
          'UNDEFINED'),
    DECODE(oname, NULL, NULL, sname),
    oname,
    DECODE (type,
      -1, 'SNAPSHOT',
       0, 'UNDEFINED',
       1, 'INDEX',
       2, 'TABLE',
       4, 'VIEW',
       5, 'SYNONYM',
       6, 'SEQUENCE',
       7, 'PROCEDURE',
       8, 'FUNCTION',
       9, 'PACKAGE',
      11, 'PACKAGE BODY',
      12, 'TRIGGER',
      13, 'TYPE',
      14, 'TYPE BODY',
      32, 'INDEXTYPE',
      33, 'OPERATOR',
      --- -3, 'UPDATABLE SNAPSHOT',
          'UNDEFINED'),
    message,
    errnum,
    NVL(gname, sname)
  FROM system.repcat$_repcatlog
/
comment on table REPCAT_REPCATLOG is
'Information about asynchronous administration requests'
/
comment on column REPCAT_REPCATLOG.ID is
'Identifying number of repcat log record'
/
comment on column REPCAT_REPCATLOG.SOURCE is
'Name of the database at which the request originated'
/
comment on column REPCAT_REPCATLOG.STATUS is
'Status of the request at this database'
/
comment on column REPCAT_REPCATLOG.USERID is
'Name of the user who submitted the request'
/
comment on column REPCAT_REPCATLOG.TIMESTAMP is
'When the request was submitted'
/
comment on column REPCAT_REPCATLOG.ROLE is
'Is this database the masterdef for the request'
/
comment on column REPCAT_REPCATLOG.MASTER is
'Name of the database that processes this request'
/
comment on column REPCAT_REPCATLOG.GNAME is
'Name of the replicated object group'
/
comment on column REPCAT_REPCATLOG.REQUEST is
'Name of the requested operation'
/
comment on column REPCAT_REPCATLOG.SNAME is
'Schema of replicated object, if applicable'
/
comment on column REPCAT_REPCATLOG.ONAME is
'Replicated object name, if applicable'
/
comment on column REPCAT_REPCATLOG.TYPE is
'Type of replicated object, if applicable'
/
comment on column REPCAT_REPCATLOG.MESSAGE is
'Error message associated with processing the request'
/
comment on column REPCAT_REPCATLOG.ERRNUM is
'Oracle error number associated with processing the request'
/
grant select on REPCAT_REPCATLOG to select_catalog_role
/


-- create a table that holds ddl
CREATE TABLE system.repcat$_ddl
(
  log_id  NUMBER,                 -- request identifier
  source  VARCHAR2(128),          -- where the request originated
  role    VARCHAR2(1),            -- 'Y' for masterdef and 'N' for master
  master  VARCHAR2(128),          -- 
            CONSTRAINT repcat$_ddl_prnt
              FOREIGN KEY(log_id, source, role, master)
              REFERENCES system.repcat$_repcatlog(id, source, role, master)
              ON DELETE CASCADE,
  line    INTEGER,
  text    VARCHAR2(2000),         -- ddl to execute
  ddl_num INTEGER DEFAULT 1       -- order of ddls to execute 
)
/
-- index on foreign key to avoid deadlocks in
-- concurrent do_deferred_repcat_admin
create index system.repcat$_ddl_index on
  system.repcat$_ddl(log_id, source, role, master)
/
comment on table SYSTEM.REPCAT$_DDL is
'Arguments that do not fit in a single repcat log record'
/
comment on column SYSTEM.REPCAT$_DDL.LOG_ID is
'Identifying number of the repcat log record'
/
comment on column SYSTEM.REPCAT$_DDL.SOURCE is
'Name of the database at which the request originated'
/
comment on column SYSTEM.REPCAT$_DDL.ROLE is
'Is this database the masterdef for the request'
/
comment on column SYSTEM.REPCAT$_DDL.MASTER is
'Name of the database that processes this request'
/
comment on column SYSTEM.REPCAT$_DDL.LINE is
'Ordering of records within a single request'
/
comment on column SYSTEM.REPCAT$_DDL.TEXT is
'Portion of an argument'
/
comment on column SYSTEM.REPCAT$_DDL.DDL_NUM is
'Ordering of DDLs to execute'
/

CREATE UNIQUE INDEX system.repcat$_ddl ON
  system.repcat$_ddl(log_id, source, role, master, line)
/


-- create a table that stores the users who are registered for 
-- object group privileges.
CREATE TABLE system.repcat$_repgroup_privs
(
  userid          NUMBER,                 -- OBSOLETE
  username        VARCHAR2(30) NOT NULL,  -- username 
  gowner          VARCHAR2(30),           -- owner of object group
  gname           VARCHAR2(30),           -- replicated object group name
                    CONSTRAINT repcat$_repgroup_privs_fk  
                      FOREIGN KEY (gname, gowner)
                      REFERENCES system.repcat$_repcat(sname, gowner)
                      ON DELETE CASCADE,
                    CONSTRAINT repcat$_repgroup_privs_uk 
                      UNIQUE (username, gname, gowner),
  global_flag     NUMBER NOT NULL,        -- 1 if gname is NULL, 0 otherwise
  created         DATE NOT NULL,          -- date of registration
  privilege       NUMBER                  -- registered privileges
)
/
comment on table SYSTEM.REPCAT$_REPGROUP_PRIVS is
'Information about users who are registered for object group privileges'
/
comment on column SYSTEM.REPCAT$_REPGROUP_PRIVS.USERID is
'OBSOLETE COLUMN: Identifying number of the user'
/
comment on column SYSTEM.REPCAT$_REPGROUP_PRIVS.USERNAME is
'Identifying name of the registered user'
/
comment on column SYSTEM.REPCAT$_REPGROUP_PRIVS.GOWNER is
'Owner of the replicated object group'
/
comment on column SYSTEM.REPCAT$_REPGROUP_PRIVS.GNAME is
'Name of the replicated object group'
/
comment on column SYSTEM.REPCAT$_REPGROUP_PRIVS.GLOBAL_FLAG is
'1 if gname is NULL, 0 otherwise'
/
comment on column SYSTEM.REPCAT$_REPGROUP_PRIVS.CREATED is
'Registration date'
/
comment on column SYSTEM.REPCAT$_REPGROUP_PRIVS.PRIVILEGE is
'Registered privileges'
/
CREATE INDEX system.repcat$_repgroup_privs_n1 ON
  system.repcat$_repgroup_privs(global_flag, username)
/
-- index on foreign key to avoid deadlocks in
-- concurrent do_deferred_repcat_admin
CREATE INDEX system.repcat$_repgroup_privs_fk_idx ON
  system.repcat$_repgroup_privs(gname, gowner)
/

create or replace view ALL_REPGROUP_PRIVILEGES
  (USERNAME, GNAME, CREATED, RECEIVER, PROXY_SNAPADMIN, OWNER)
as
select u.username, rp.gname, rp.created,
       decode(bitand(rp.privilege, 1), 1, 'Y', 'N'),
       decode(bitand(rp.privilege, 2), 2, 'Y', 'N'),
       rp.gowner
from  system.repcat$_repgroup_privs rp, all_users u
where rp.username = u.username
  and u.user_id = userenv('SCHEMAID')
/
comment on table ALL_REPGROUP_PRIVILEGES is
'Information about users who are registered for object group privileges'
/
comment on column ALL_REPGROUP_PRIVILEGES.USERNAME is
'Name of the user'
/
comment on column ALL_REPGROUP_PRIVILEGES.OWNER is
'Owner of the replicated object group'
/
comment on column ALL_REPGROUP_PRIVILEGES.GNAME is
'Name of the replicated object group'
/
comment on column ALL_REPGROUP_PRIVILEGES.CREATED is
'Registration date'
/
comment on column ALL_REPGROUP_PRIVILEGES.RECEIVER is
'Receiver privileges'
/
comment on column ALL_REPGROUP_PRIVILEGES.PROXY_SNAPADMIN is
'Proxy snapadmin privileges'
/
create or replace public synonym ALL_REPGROUP_PRIVILEGES
   for ALL_REPGROUP_PRIVILEGES
/
grant select on ALL_REPGROUP_PRIVILEGES to PUBLIC with grant option
/


create or replace view DBA_REPGROUP_PRIVILEGES 
  (USERNAME, GNAME, CREATED, RECEIVER, PROXY_SNAPADMIN, OWNER)
as
select u.username, rp.gname, rp.created,
       decode(bitand(rp.privilege, 1), 1, 'Y', 'N'),
       decode(bitand(rp.privilege, 2), 2, 'Y', 'N'),
       rp.gowner
from system.repcat$_repgroup_privs rp, dba_users u
where rp.username = u.username
/
comment on table DBA_REPGROUP_PRIVILEGES is
'Information about users who are registered for object group privileges'
/
comment on column DBA_REPGROUP_PRIVILEGES.USERNAME is
'Name of the user'
/
comment on column DBA_REPGROUP_PRIVILEGES.OWNER is
'Owner of the replicated object group'
/
comment on column DBA_REPGROUP_PRIVILEGES.GNAME is
'Name of the replicated object group'
/
comment on column DBA_REPGROUP_PRIVILEGES.CREATED is
'Registration date'
/
comment on column DBA_REPGROUP_PRIVILEGES.RECEIVER is
'Receiver privileges'
/
comment on column DBA_REPGROUP_PRIVILEGES.PROXY_SNAPADMIN is
'Proxy snapadmin privileges'
/
create or replace public synonym DBA_REPGROUP_PRIVILEGES
   for DBA_REPGROUP_PRIVILEGES
/
grant select on DBA_REPGROUP_PRIVILEGES to select_catalog_role
/


create or replace view USER_REPGROUP_PRIVILEGES 
  (USERNAME, GNAME, CREATED, RECEIVER, PROXY_SNAPADMIN, OWNER)
as
select u.username, rp.gname, rp.created,
       decode(bitand(rp.privilege, 1), 1, 'Y', 'N'),
       decode(bitand(rp.privilege, 2), 2, 'Y', 'N'),
       rp.gowner
from system.repcat$_repgroup_privs rp, all_users u
where rp.username = u.username
  and u.user_id =  userenv('SCHEMAID')
/
comment on table USER_REPGROUP_PRIVILEGES is
'Information about users who are registered for object group privileges'
/
comment on column USER_REPGROUP_PRIVILEGES.USERNAME is
'Name of the user'
/
comment on column USER_REPGROUP_PRIVILEGES.GNAME is
'Name of the replicated object group'
/
comment on column USER_REPGROUP_PRIVILEGES.CREATED is
'Registration date'
/
comment on column USER_REPGROUP_PRIVILEGES.RECEIVER is
'Receiver privileges'
/
comment on column USER_REPGROUP_PRIVILEGES.PROXY_SNAPADMIN is
'Proxy snapadmin privileges'
/
create or replace public synonym USER_REPGROUP_PRIVILEGES
   for USER_REPGROUP_PRIVILEGES
/
grant select on USER_REPGROUP_PRIVILEGES to PUBLIC with grant option
/

CREATE SEQUENCE system.repcat_log_sequence
/

create or replace view USER_REPGROUP
  (SNAME, --- OBSOLETE
   MASTER, STATUS, SCHEMA_COMMENT, GNAME, FNAME, 
   RPC_PROCESSING_DISABLED, OWNER)
as
select r.sname, r.master, r.status, r.schema_comment, r.sname, r.fname,
       r.rpc_processing_disabled, r.gowner
from repcat_repcat r, user_users u
where (r.sname = u.username)
   or r.gowner in 
      (select name from user$ 
        where user# = userenv('SCHEMAID') and type# = 1)
/
comment on table USER_REPGROUP is
'Replication information about the current user'
/
comment on column USER_REPGROUP.OWNER is
'Owner of the replicated object group'
/
comment on column USER_REPGROUP.GNAME is
'Name of the replicated object group'
/
comment on column USER_REPGROUP.SNAME is
'OBSOLETE COLUMN: Name of the user'
/
comment on column USER_REPGROUP.MASTER is
'Is the site a master site'
/
comment on column USER_REPGROUP.STATUS is
'If site is master, the master''s status'
/
comment on column USER_REPGROUP.SCHEMA_COMMENT is
'User description of the replicated object group'
/
comment on column USER_REPGROUP.FNAME is
'Flavor name'
/
comment on column USER_REPGROUP.RPC_PROCESSING_DISABLED is
'Whether this site disables processing of replication RPC'
/
Rem -- user_repcat is maintained for backwards compatability
create or replace view USER_REPCAT as select * from USER_REPGROUP
/
create or replace public synonym USER_REPCAT for USER_REPCAT
/
grant select on USER_REPCAT to PUBLIC with grant option
/
create or replace public synonym USER_REPGROUP for USER_REPGROUP
/
grant select on USER_REPGROUP to PUBLIC with grant option
/


create or replace view ALL_REPGROUP
  (SNAME, --- OBSOLETE
   MASTER, STATUS, SCHEMA_COMMENT, GNAME, FNAME, RPC_PROCESSING_DISABLED,
   OWNER)
as
select r.sname, r.master, r.status, r.schema_comment, r.sname, r.fname,
       r.rpc_processing_disabled, r.gowner
from repcat_repcat r
/
comment on table ALL_REPGROUP is
'Information about replicated object groups'
/
comment on column ALL_REPGROUP.OWNER is
'Owner of the replicated object group'
/
comment on column ALL_REPGROUP.GNAME is
'Name of the replicated object group'
/
comment on column ALL_REPGROUP.SNAME is
'OBSOLETE COLUMN: Name of the replicated schema'
/
comment on column ALL_REPGROUP.MASTER is
'Is the site a master site for the replicated object group'
/
comment on column ALL_REPGROUP.STATUS is
'If the site is a master, the master''s status'
/
comment on column ALL_REPGROUP.SCHEMA_COMMENT is
'Description of the replicated object group'
/
comment on column ALL_REPGROUP.FNAME is
'Flavor name'
/
comment on column USER_REPGROUP.RPC_PROCESSING_DISABLED is
'Whether this site disables processing of replication RPC'
/
Rem -- This synonym all_repcat is for backwards compatability
create or replace view ALL_REPCAT as select * from ALL_REPGROUP
/
create or replace public synonym ALL_REPCAT for ALL_REPCAT
/
grant select on ALL_REPCAT to PUBLIC with grant option
/
create or replace public synonym ALL_REPGROUP for ALL_REPGROUP
/
grant select on ALL_REPGROUP to PUBLIC with grant option
/


create or replace view DBA_REPGROUP
  (SNAME, --- OBSOLETE
   MASTER, STATUS, SCHEMA_COMMENT, GNAME, FNAME, RPC_PROCESSING_DISABLED,
   OWNER)
as
select r.sname, r.master, r.status, r.schema_comment, r.sname, r.fname,
       r.rpc_processing_disabled, r.gowner
from repcat_repcat r
/
comment on table DBA_REPGROUP is
'Information about all replicated object groups'
/
comment on column DBA_REPGROUP.OWNER is
'Owner of the replicated object group'
/
comment on column DBA_REPGROUP.GNAME is
'Name of the replicated object group'
/
comment on column DBA_REPGROUP.SNAME is
'OBSOLETE COLUMN: Name of the replicated schema'
/
comment on column DBA_REPGROUP.MASTER is
'Is the site a master site for the replicated object group'
/
comment on column DBA_REPGROUP.STATUS is
'If the site is a master, the master''s status'
/
comment on column DBA_REPGROUP.SCHEMA_COMMENT is
'Description of the replicated object group'
/
comment on column DBA_REPGROUP.FNAME is
'Flavor name'
/
comment on column USER_REPGROUP.RPC_PROCESSING_DISABLED is
'Whether this site disables processing of replication RPC'
/
grant select on DBA_REPGROUP to select_catalog_role
/


Rem -- Next two lines are for backwards compatability. In 7.3 we changed names
Rem -- from *_repcat to *_repgroup
create or replace view DBA_REPCAT as select * from DBA_REPGROUP
/
create or replace public synonym DBA_REPCAT for DBA_REPCAT
/
create or replace public synonym DBA_REPGROUP for DBA_REPGROUP
/
grant select on DBA_REPCAT to select_catalog_role
/


create or replace view USER_REPSITES
(GNAME, DBLINK, MASTERDEF, SNAPMASTER, MASTER_COMMENT, MASTER, GROUP_OWNER)
as
select r.sname, r.dblink, r.masterdef, r.snapmaster, r.master_comment,
       r.master, r.gowner
from repcat_repschema r, user_users u
where (r.sname = u.username)
   or r.gowner in
      (select name from user$
        where user# = userenv('SCHEMAID') and type# = 1)
/
comment on table USER_REPSITES is
'N-way replication information about the current user'
/
comment on column USER_REPSITES.GROUP_OWNER is
'Owner of the replicated object group'
/
comment on column USER_REPSITES.GNAME is
'Name of the replicated object group'
/
comment on column USER_REPSITES.DBLINK is
'A database site replicating the schema'
/
comment on column USER_REPSITES.MASTERDEF is
'Is the database the master definition site for the replicated object group'
/
comment on column USER_REPSITES.SNAPMASTER is
'For snapshot sites, is the database the current refresh master'
/
comment on column USER_REPSITES.MASTER_COMMENT is
'User description of the database site'
/
comment on column USER_REPSITES.MASTER is
'Redundant information from user_repcat.master'
/
create or replace public synonym USER_REPSITES for USER_REPSITES
/
grant select on USER_REPSITES to PUBLIC with grant option
/


create or replace view ALL_REPSITES
(GNAME, DBLINK, MASTERDEF, SNAPMASTER, MASTER_COMMENT, MASTER, GROUP_OWNER)
as
select r.sname, r.dblink, r.masterdef, r.snapmaster, r.master_comment,
       r.master, r.gowner
from repcat_repschema r
/
comment on table ALL_REPSITES is
'N-way replication information'
/
comment on column ALL_REPSITES.GROUP_OWNER is
'Owner of the replicated object group'
/
comment on column ALL_REPSITES.GNAME is
'Name of the replicated object group'
/
comment on column ALL_REPSITES.DBLINK is
'A database site replicating the schema'
/
comment on column ALL_REPSITES.MASTERDEF is
'Is the database the master definition site for the replicated object group'
/
comment on column ALL_REPSITES.SNAPMASTER is
'For a snapshot site, is the database the current refresh master'
/
comment on column ALL_REPSITES.MASTER_COMMENT is
'Description of the database site'
/
comment on column ALL_REPSITES.MASTER is
'Redundant information from all_repcat.master'
/
create or replace public synonym ALL_REPSITES for ALL_REPSITES
/
grant select on ALL_REPSITES to PUBLIC with grant option
/


create or replace view DBA_REPSITES
(GNAME, DBLINK, MASTERDEF, SNAPMASTER, MASTER_COMMENT, MASTER,
 PROP_UPDATES, MY_DBLINK, GROUP_OWNER)
as
select r.sname, r.dblink, r.masterdef, r.snapmaster, r.master_comment,
  r.master, r.prop_updates, r.my_dblink, r.gowner
from system.repcat$_repschema r
/
comment on table DBA_REPSITES is
'N-way replication information'
/
comment on column DBA_REPSITES.GROUP_OWNER is
'Owner of the replicated object group'
/
comment on column DBA_REPSITES.GNAME is
'Name of the replicated object group'
/
comment on column DBA_REPSITES.DBLINK is
'A database site replicating the schema'
/
comment on column DBA_REPSITES.MASTERDEF is
'Is the database the master definition site for the replicated object group'
/
comment on column DBA_REPSITES.SNAPMASTER is
'For a snapshot site, is the database the current refresh master'
/
comment on column DBA_REPSITES.MASTER_COMMENT is
'Description of the database site'
/
comment on column DBA_REPSITES.MASTER is
'Redundant information from dba_repcat.master'
/
comment on column DBA_REPSITES.PROP_UPDATES is
'Number of requested updates for master in repcat$_repprop'
/
comment on column DBA_REPSITES.MY_DBLINK is
'A sanity check after import: is this master the current site'
/
create or replace public synonym DBA_REPSITES for DBA_REPSITES
/
grant select on DBA_REPSITES to select_catalog_role
/


create or replace view USER_REPSCHEMA
    (SNAME, --- OBSOLETE
     DBLINK, MASTERDEF, SNAPMASTER, MASTER_COMMENT, GNAME, MASTER, GROUP_OWNER)
as
select r.sname, r.dblink, r.masterdef, r.snapmaster, r.master_comment, r.sname,
       r.master, r.gowner
from repcat_repschema r, user_users u
where (r.sname = u.username)
   or r.gowner in
      (select name from user$
        where user# = userenv('SCHEMAID') and type# = 1)
/
comment on table USER_REPSCHEMA is
'N-way replication information about the current user'
/
comment on column USER_REPSCHEMA.GROUP_OWNER is
'Owner of the replicated object group'
/
comment on column USER_REPSCHEMA.GNAME is
'Name of the replicated object group'
/
comment on column USER_REPSCHEMA.SNAME is
'OBSOLETE COLUMN: Name of the user'
/
comment on column USER_REPSCHEMA.DBLINK is
'A database site replicating the object group'
/
comment on column USER_REPSCHEMA.MASTERDEF is
'Is the database the master definition site for the replicated object group'
/
comment on column USER_REPSCHEMA.SNAPMASTER is
'For snapshot sites, is the database the current refresh master'
/
comment on column USER_REPSCHEMA.MASTER_COMMENT is
'User description of the database site'
/
comment on column USER_REPSCHEMA.MASTER is
'Redundant information from user_repcat.master'
/
create or replace public synonym USER_REPSCHEMA for USER_REPSCHEMA
/
grant select on USER_REPSCHEMA to PUBLIC with grant option
/


create or replace view ALL_REPSCHEMA
(SNAME, --- OBSOLETE
 DBLINK, MASTERDEF, SNAPMASTER, MASTER_COMMENT, GNAME, MASTER, GROUP_OWNER)
as
select r.sname, r.dblink, r.masterdef, r.snapmaster, r.master_comment, r.sname,
       r.master, r.gowner
from repcat_repschema r
/
comment on table ALL_REPSCHEMA is
'N-way replication information'
/
comment on column ALL_REPSCHEMA.GROUP_OWNER is
'Owner of the replicated object group'
/
comment on column ALL_REPSCHEMA.GNAME is
'Name of the replicated object group'
/
comment on column ALL_REPSCHEMA.SNAME is
'OBSOLETE COLUMN: Name of the replicated schema'
/
comment on column ALL_REPSCHEMA.DBLINK is
'A database site replicating the object group'
/
comment on column ALL_REPSCHEMA.MASTERDEF is
'Is the database the master definition site for the replicated object group'
/
comment on column ALL_REPSCHEMA.SNAPMASTER is
'For a snapshot site, is the database the current refresh master'
/
comment on column ALL_REPSCHEMA.MASTER_COMMENT is
'Description of the database site'
/
comment on column ALL_REPSCHEMA.MASTER is
'Redundant information from all_repcat.master'
/
create or replace public synonym ALL_REPSCHEMA for ALL_REPSCHEMA
/
grant select on ALL_REPSCHEMA to PUBLIC with grant option
/


create or replace view DBA_REPSCHEMA
    (SNAME, --- OBSOLETE
     DBLINK, MASTERDEF, SNAPMASTER, MASTER_COMMENT, MASTER,
     PROP_UPDATES, MY_DBLINK, GNAME, GROUP_OWNER)
as
select r.sname, r.dblink, r.masterdef, r.snapmaster, r.master_comment,
  r.master, r.prop_updates, r.my_dblink, r.sname, r.gowner
from system.repcat$_repschema r
/
comment on table DBA_REPSCHEMA is
'N-way replication information'
/
comment on column DBA_REPSCHEMA.GROUP_OWNER is
'Owner of the replicated object group'
/
comment on column DBA_REPSCHEMA.GNAME is
'Name of the replicated object group'
/
comment on column DBA_REPSCHEMA.SNAME is
'OBSOLETE COLUMN: Name of the replicated schema'
/
comment on column DBA_REPSCHEMA.DBLINK is
'A database site replicating the object group'
/
comment on column DBA_REPSCHEMA.MASTERDEF is
'Is the database the master definition site for the replicated object group'
/
comment on column DBA_REPSCHEMA.SNAPMASTER is
'For a snapshot site, is the database the current refresh master'
/
comment on column DBA_REPSCHEMA.MASTER_COMMENT is
'Description of the database site'
/
comment on column DBA_REPSCHEMA.MASTER is
'Redundant information from dba_repcat.master'
/
comment on column DBA_REPSCHEMA.PROP_UPDATES is
'Number of requested updates for master in repcat$_repprop'
/
comment on column DBA_REPSCHEMA.MY_DBLINK is
'A sanity check after import: is this master the current site'
/
create or replace public synonym DBA_REPSCHEMA for DBA_REPSCHEMA
/
grant select on DBA_REPSCHEMA to select_catalog_role
/


create or replace view USER_REPOBJECT
    (SNAME, ONAME, TYPE, STATUS, GENERATION_STATUS, ID, OBJECT_COMMENT, GNAME,
     MIN_COMMUNICATION, REPLICATION_TRIGGER_EXISTS, INTERNAL_PACKAGE_EXISTS,
     GROUP_OWNER, NESTED_TABLE)
as
select r.sname, r.oname, r.type, r.status, r.generation_status, r.id,
       r.object_comment, r.gname, r.min_communication, r.trigflag,
       r.internal_package_exists, r.gowner, r.nested_table
from repcat_repobject r, user_users u
where r.sname = u.username
  and r.type != 'INTERNAL PACKAGE'
/
comment on table USER_REPOBJECT is
'Replication information about the current user''s objects'
/
comment on column USER_REPOBJECT.GROUP_OWNER is
'Owner of the replicated objects group'
/
comment on column USER_REPOBJECT.GNAME is
'Name of the replicated objects group'
/
comment on column USER_REPOBJECT.SNAME is
'Name of the user'
/
comment on column USER_REPOBJECT.ONAME is
'Name of the object'
/
comment on column USER_REPOBJECT.TYPE is
'Type of the object'
/
comment on column USER_REPOBJECT.STATUS is
'Status of the last create or alter request on the local object'
/
comment on column USER_REPOBJECT.GENERATION_STATUS is
'Status of whether the object needs to generate replication packages'
/
comment on column USER_REPOBJECT.ID is
'Identifier of the local object'
/
comment on column USER_REPOBJECT.OBJECT_COMMENT is
'User description of the replicated object'
/
comment on column USER_REPOBJECT.REPLICATION_TRIGGER_EXISTS is
'Inline trigger flag exists?'
/
comment on column USER_REPOBJECT.INTERNAL_PACKAGE_EXISTS is
'Internal package exists?'
/
comment on column USER_REPOBJECT.MIN_COMMUNICATION is
'Send only necessary OLD and NEW values for an updated row?'
/
comment on column USER_REPOBJECT.NESTED_TABLE is
'Storage table for a nested table column?'
/
create or replace public synonym USER_REPOBJECT for USER_REPOBJECT
/
grant select on USER_REPOBJECT to PUBLIC with grant option
/


create or replace view ALL_REPOBJECT
    (SNAME, ONAME, TYPE, STATUS, GENERATION_STATUS, ID, OBJECT_COMMENT, GNAME,
     MIN_COMMUNICATION, REPLICATION_TRIGGER_EXISTS, INTERNAL_PACKAGE_EXISTS,
     GROUP_OWNER, NESTED_TABLE)
as
select r.sname, r.oname, r.type, r.status, r.generation_status, r.id,
       r.object_comment, r.gname, r.min_communication,
       r.trigflag replication_trigger_exists, r.internal_package_exists, 
       r.gowner, r.nested_table
from repcat_repobject r, all_objects o
where (r.sname = 'PUBLIC' or r.sname in (select u.username from all_users u))
  and r.sname = o.owner
  and r.oname = o.object_name
  and r.type != 'INTERNAL PACKAGE'
  and (r.type = o.object_type
       or (r.type = 'SNAPSHOT'
           and o.object_type IN ('VIEW','TABLE')))
union
select r.sname, r.oname, r.type, r.status, r.generation_status, r.id,
       r.object_comment, r.gname, r.min_communication,
       r.replication_trigger_exists, r.internal_package_exists, r.group_owner,
       r.nested_table
from user_repobject r
union
select r.sname, r.oname, r.type, r.status, r.generation_status,
       r.id, r.object_comment, r.gname, r.min_communication,
       r.trigflag replication_trigger_exists, r.internal_package_exists, 
       r.gowner, r.nested_table
from repcat_repobject r
where (r.sname = 'PUBLIC' or r.sname in 
        (select u.username from all_users u))
and (r.gname, r.gowner) in
(select nvl(rp.gname,r.gname), nvl(rp.owner, r.gowner)
 from user_repgroup_privileges rp
 where rp.proxy_snapadmin='Y')
/
comment on table ALL_REPOBJECT is
'Information about replicated objects'
/
comment on column ALL_REPOBJECT.GROUP_OWNER is
'Owner of the replicated object group'
/
comment on column ALL_REPOBJECT.GNAME is
'Name of the replicated object group'
/
comment on column ALL_REPOBJECT.SNAME is
'Name of the object owner'
/
comment on column ALL_REPOBJECT.ONAME is
'Name of the object'
/
comment on column ALL_REPOBJECT.TYPE is
'Type of the object'
/
comment on column ALL_REPOBJECT.STATUS is
'Status of the last create or alter request on the local object'
/
comment on column ALL_REPOBJECT.GENERATION_STATUS is
'Status of whether the object needs to generate replication packages'
/
comment on column ALL_REPOBJECT.ID is
'Identifier of the local object'
/
comment on column ALL_REPOBJECT.OBJECT_COMMENT is
'Description of the replicated object'
/
comment on column ALL_REPOBJECT.REPLICATION_TRIGGER_EXISTS is
'Internal replication trigger exists?'
/
comment on column ALL_REPOBJECT.INTERNAL_PACKAGE_EXISTS is
'Internal package exists?'
/
comment on column ALL_REPOBJECT.MIN_COMMUNICATION is
'Send only necessary OLD and NEW values for an updated row?'
/
comment on column ALL_REPOBJECT.NESTED_TABLE is
'Storage table for a nested table column?'
/
create or replace public synonym ALL_REPOBJECT for ALL_REPOBJECT
/
grant select on ALL_REPOBJECT to PUBLIC with grant option
/


create or replace view DBA_REPOBJECT
    (SNAME, ONAME, TYPE, STATUS, GENERATION_STATUS, ID, OBJECT_COMMENT, GNAME,
     MIN_COMMUNICATION, REPLICATION_TRIGGER_EXISTS, INTERNAL_PACKAGE_EXISTS,
     GROUP_OWNER, NESTED_TABLE)
as
select r.sname, r.oname, r.type, r.status, r.generation_status, r.id,
       r.object_comment, r.gname, r.min_communication,
       r.trigflag replication_trigger_exists, r.internal_package_exists, 
       r.gowner, r.nested_table
from repcat_repobject r
where r.type != 'INTERNAL PACKAGE'
/
comment on table DBA_REPOBJECT is
'Information about replicated objects'
/
comment on column DBA_REPOBJECT.GROUP_OWNER is
'Owner of the replicated object group'
/
comment on column DBA_REPOBJECT.GNAME is
'Name of the replicated object group'
/
comment on column DBA_REPOBJECT.SNAME is
'Name of the object owner'
/
comment on column DBA_REPOBJECT.ONAME is
'Name of the object'
/
comment on column DBA_REPOBJECT.TYPE is
'Type of the object'
/
comment on column DBA_REPOBJECT.STATUS is
'Status of the last create or alter request on the local object'
/
comment on column DBA_REPOBJECT.GENERATION_STATUS is
'Status of whether the object needs to generate replication packages'
/
comment on column DBA_REPOBJECT.ID is
'Identifier of the local object'
/
comment on column DBA_REPOBJECT.OBJECT_COMMENT is
'Description of the replicated object'
/
comment on column DBA_REPOBJECT.REPLICATION_TRIGGER_EXISTS is
'Internal replication trigger exists?'
/
comment on column DBA_REPOBJECT.INTERNAL_PACKAGE_EXISTS is
'Internal package exists?'
/
comment on column DBA_REPOBJECT.MIN_COMMUNICATION is
'Send only necessary OLD and NEW values for an updated row?'
/
comment on column DBA_REPOBJECT.NESTED_TABLE is
'Storage table for a nested table column?'
/
create or replace public synonym DBA_REPOBJECT for DBA_REPOBJECT
/
grant select on DBA_REPOBJECT to select_catalog_role
/

-- Create a base view on repcat$_repcolumn.
-- This view is for internal use only and may change without notice.
-- self join with r2 is to select the 'real' column for 'virtual' columns
-- we are currently only interested in the real column for soidref_fk
create or replace view repcat_repcolumn_base
(sname, oname, type, cname, id, pos, compare_old_on_delete,
 compare_old_on_update, send_old_on_delete, send_old_on_update,
 ctype, ctype_toid, ctype_owner, ctype_hashcode, ctype_version#,
 ctype_num, ctype_mod, data_length, data_precision, data_scale, 
 nullable, character_set_name, top, char_length, char_used, property, lpos)
as select r.sname,
       r.oname,
       decode(r.type,
         -1, 'SNAPSHOT',
          1, 'INDEX',
          2, 'TABLE',
          4, 'VIEW',
          5, 'SYNONYM'),
       r.lcname, -- cname, long column name
       r.id,
       -- we want to leave the pos as NULL for virtual columns
       r.pos,
       -- we want the send and compare bits from the 'real' column
       decode(nvl(r.pos,r2.pos), NULL, NULL,
         decode(utl_raw.bit_and(utl_raw.substr(nvl(r2.flag, 
                r.flag), 1, 1), '04'), '00', 'Y','N')),
       decode(nvl(r.pos,r2.pos), NULL, NULL,
         decode(utl_raw.bit_and(utl_raw.substr(nvl(r2.flag,
                r.flag), 1, 1), '08'), '00', 'Y','N')),
       decode(nvl(r.pos,r2.pos), NULL, NULL,
         decode(utl_raw.bit_and(utl_raw.substr(nvl(r2.flag, 
                r.flag), 1, 1), '01'), '00', 'Y','N')),
       decode(nvl(r.pos,r2.pos), NULL, NULL,
         decode(utl_raw.bit_and(utl_raw.substr(nvl(r2.flag, 
                r.flag), 1, 1), '02'), '00', 'Y','N')),
       decode(r.ctype,
         1, decode(r.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
         2, 'NUMBER',
         12, 'DATE',
         23, decode(utl_raw.bit_and(utl_raw.substr(r.property, 1, 1), '08'),
                    '08', r.ctype_name, 'RAW'),
         58, r.ctype_name,
         69, 'ROWID',
         96, decode(r.charsetform, 2, 'NCHAR', 'CHAR'),
         -- system provided type may be stored as clob, e.g., XMLType
         112, NVL(r.ctype_name, decode(r.charsetform, 2, 'NCLOB', 'CLOB')),
         113, 'BLOB',
         178, 'TIME(' ||r.scale|| ')',
         179, 'TIME(' ||r.scale|| ')' || ' WITH TIME ZONE',
         180, 'TIMESTAMP(' ||r.scale|| ')',
         181, 'TIMESTAMP(' ||r.scale|| ')' || ' WITH TIME ZONE',
         182, 'INTERVAL YEAR(' ||r.precision#||') TO MONTH',
         183, 'INTERVAL DAY(' ||r.precision#||') TO SECOND(' ||r.scale|| ')',
         111, r.ctype_name,
         121, r.ctype_name,
         122, r.ctype_name,
         123, r.ctype_name,
         231, 'TIMESTAMP(' ||r.scale|| ')' || ' WITH LOCAL TIME ZONE',
         'UNDEFINED'),
       r.toid,
       r.ctype_owner,
       RAWTOHEX(r.hashcode),
       r.version#,
       r.ctype,
       decode(r.ctype, 111, 'REF'),                       -- CTYPE_MOD
       decode(nvl(r.pos, r2.pos), NULL, NULL, r.length),
       decode(nvl(r.pos, r2.pos), NULL, NULL, r.precision#),
       decode(nvl(r.pos, r2.pos), NULL, NULL, r.scale),
       decode(nvl(r.pos, r2.pos), NULL, NULL, decode(sign(r.null$),-1,'D', 
                                                     0, 'Y', 'N')),
       decode(r.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(r.charsetid),
                             4, 'ARG:'||r.charsetid),
       decode(r.ctype, 23,
               -- nested table column SETID (in the parent table)
               decode(utl_raw.bit_and(utl_raw.substr(r.property, 1, 1), '08'),
                      '08',decode(r.top, r.lcname, NULL, r.top), r.top),
               -- for XMLType storage column
               112, decode(r.top, r.lcname, NULL, r.top),
              r.top),
       r.clength,
       decode(r.ctype, 
        1,
        decode(utl_raw.bit_and(utl_raw.substr(r.flag,1,1),'10'),'00','B','C'),
        96,
        decode(utl_raw.bit_and(utl_raw.substr(r.flag,1,1),'10'),'00','B','C'),
        ''),
        r.property,
        -- for soidref_fk we need to select the pos of the real column
        -- in the lpos field so that in the definition of dba_repcolumn we
        -- can say nvl(pos, lpos) showing the pos of the real column rather
        -- than null.
        decode(utl_raw.bit_and(utl_raw.substr(r.property,2,1),'01'),'01',
               r2.pos, null)
from system.repcat$_repcolumn r, system.repcat$_repcolumn r2
where r2.sname (+) = r.sname
and   r2.oname (+) = r.oname
and   r2.lcname (+) = r.lcname
and   r2.id (+) <> r.id
-- we select r2 only for soidref_fk_attr
and utl_raw.bit_and(utl_raw.substr(nvl(r2.property (+),'0000'),2,1),'02')='02'
-- filter out nested table column
and utl_raw.bit_and(utl_raw.substr(r.property, 1, 1), '01') != '01'
-- filter out special opaque type referenced in table opqtype$
and utl_raw.bit_and(utl_raw.substr(r.property, 2, 1), '08') != '08'
-- filter out soidref_fk_attr column
and utl_raw.bit_and(utl_raw.substr(r.property, 2, 1), '02') != '02'
/

comment on table REPCAT_REPCOLUMN_BASE is
'Replicated top-level columns (table) sorted alphabetically in ascending order'
/
comment on column REPCAT_REPCOLUMN_BASE.SNAME is
'Name of the object owner'
/
comment on column REPCAT_REPCOLUMN_BASE.ONAME is
'Name of the object'
/
comment on column REPCAT_REPCOLUMN_BASE.TYPE is
'Type of the object'
/
comment on column REPCAT_REPCOLUMN_BASE.CNAME is
'Name of the replicated column'
/
comment on column REPCAT_REPCOLUMN_BASE.ID is
'ID of the replicated column'
/
comment on column REPCAT_REPCOLUMN_BASE.POS is
'Ordering of the replicated column'
/
comment on column REPCAT_REPCOLUMN_BASE.COMPARE_OLD_ON_DELETE is
'Compare the old value of the column in replicated deletes'
/
comment on column REPCAT_REPCOLUMN_BASE.COMPARE_OLD_ON_UPDATE is
'Compare the old value of the column in replicated updates'
/
comment on column REPCAT_REPCOLUMN_BASE.SEND_OLD_ON_DELETE is
'Send the old value of the column in replicated deletes'
/
comment on column REPCAT_REPCOLUMN_BASE.SEND_OLD_ON_UPDATE is
'Send the old value of the column in replicated updates'
/
comment on column REPCAT_REPCOLUMN_BASE.CTYPE is
'Type of the column'
/
comment on column REPCAT_REPCOLUMN_BASE.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column REPCAT_REPCOLUMN_BASE.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column REPCAT_REPCOLUMN_BASE.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column REPCAT_REPCOLUMN_BASE.NULLABLE is
'Does column allow NULL values?'
/
comment on column REPCAT_REPCOLUMN_BASE.CHARACTER_SET_NAME is
'Name of character set for column, if applicable'
/
comment on column REPCAT_REPCOLUMN_BASE.CTYPE_OWNER is
'Type owner of a column of TYPE'
/
comment on column REPCAT_REPCOLUMN_BASE.CTYPE_TOID is
'Type OID of a column of TYPE'
/
comment on column REPCAT_REPCOLUMN_BASE.CTYPE_HASHCODE is
'Type hashcode of a column of TYPE'
/
comment on column REPCAT_REPCOLUMN_BASE.CTYPE_VERSION# is
'Type version# of a column of TYPE'
/
comment on column REPCAT_REPCOLUMN_BASE.CTYPE_NUM is
'Type of a column'
/
comment on column REPCAT_REPCOLUMN_BASE.CTYPE_MOD is
'Datatype modifier of a column'
/
comment on column REPCAT_REPCOLUMN_BASE.TOP is
'Top column name for an attribute'
/
comment on column REPCAT_REPCOLUMN_BASE.LPOS is
'Ordering of the real replicated column'
/
create or replace public synonym REPCAT_REPCOLUMN_BASE
   for REPCAT_REPCOLUMN_BASE
/
grant select on REPCAT_REPCOLUMN_BASE to select_catalog_role
/

create or replace view dba_repcolumn
(sname, oname, type, cname, id, pos, compare_old_on_delete,
 compare_old_on_update, send_old_on_delete, send_old_on_update,
 ctype, ctype_toid, ctype_owner, ctype_hashcode,
 ctype_mod, data_length, data_precision, data_scale, nullable,
 character_set_name, top, char_length, char_used)
as select sname, oname, type, cname, id, nvl(pos, lpos), compare_old_on_delete,
          compare_old_on_update, send_old_on_delete, send_old_on_update,
          ctype, ctype_toid, ctype_owner, ctype_hashcode, ctype_mod,
          data_length, data_precision, data_scale, nullable,
          character_set_name, top, char_length, char_used
from repcat_repcolumn_base
/

comment on table DBA_REPCOLUMN is
'Replicated top-level columns (table) sorted alphabetically in ascending order'
/
comment on column DBA_REPCOLUMN.SNAME is
'Name of the object owner'
/
comment on column DBA_REPCOLUMN.ONAME is
'Name of the object'
/
comment on column DBA_REPCOLUMN.TYPE is
'Type of the object'
/
comment on column DBA_REPCOLUMN.CNAME is
'Name of the replicated column'
/
comment on column DBA_REPCOLUMN.ID is
'ID of the replicated column'
/
comment on column DBA_REPCOLUMN.POS is
'Ordering of the replicated column'
/
comment on column DBA_REPCOLUMN.COMPARE_OLD_ON_DELETE is
'Compare the old value of the column in replicated deletes'
/
comment on column DBA_REPCOLUMN.COMPARE_OLD_ON_UPDATE is
'Compare the old value of the column in replicated updates'
/
comment on column DBA_REPCOLUMN.SEND_OLD_ON_DELETE is
'Send the old value of the column in replicated deletes'
/
comment on column DBA_REPCOLUMN.SEND_OLD_ON_UPDATE is
'Send the old value of the column in replicated updates'
/
comment on column DBA_REPCOLUMN.CTYPE is
'Type of the column'
/
comment on column DBA_REPCOLUMN.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column DBA_REPCOLUMN.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column DBA_REPCOLUMN.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_REPCOLUMN.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_REPCOLUMN.CHARACTER_SET_NAME is
'Name of character set for column, if applicable'
/
comment on column DBA_REPCOLUMN.CTYPE_OWNER is
'Type owner of a column of TYPE'
/
comment on column DBA_REPCOLUMN.CTYPE_TOID is
'Type OID of a column of TYPE'
/
comment on column DBA_REPCOLUMN.CTYPE_HASHCODE is
'Type hashcode of a column of TYPE'
/
comment on column DBA_REPCOLUMN.CTYPE_MOD is
'Datatype modifier of a column'
/
comment on column DBA_REPCOLUMN.TOP is
'Top column name for an attribute'
/
comment on column DBA_REPCOLUMN.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column DBA_REPCOLUMN.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/

create or replace public synonym DBA_REPCOLUMN for DBA_REPCOLUMN
/
grant select on DBA_REPCOLUMN to select_catalog_role
/

create or replace view "_DBA_REPL_NESTED_TABLE_NAMES"
(owner, table_name)
as
select u.name, o.name from sys.user$ u, sys.obj$ o, sys.tab$ t
where u.user# = o.owner#
  and o.obj# = t.obj#
  and bitand(t.property, 8192) = 8192
/

create or replace view "_ALL_REPL_NESTED_TABLE_NAMES"
(owner, table_name)
as
select nt.owner, nt.table_name 
from "_DBA_REPL_NESTED_TABLE_NAMES" nt, all_objects o
where nt.owner=o.owner and nt.table_name=o.object_name
/

create or replace view "_USER_REPL_NESTED_TABLE_NAMES"
(table_name)
as
select nt.table_name
from "_DBA_REPL_NESTED_TABLE_NAMES" nt, sys.user$ u
where nt.owner = u.name
and   u.user#  = userenv('SCHEMAID')
/

create or replace view all_repcolumn
(sname, oname, type, cname, id, pos, compare_old_on_delete,
 compare_old_on_update, send_old_on_delete, send_old_on_update,
 ctype, ctype_toid, ctype_owner, ctype_hashcode,
 ctype_mod, data_length, data_precision, data_scale, nullable,
 character_set_name, top, char_length, char_used)
as
select
 r.sname, r.oname, r.type, r.cname, r.id, r.pos, r.compare_old_on_delete,
 r.compare_old_on_update, r.send_old_on_delete, r.send_old_on_update,
 r.ctype, r.ctype_toid, r.ctype_owner, r.ctype_hashcode,
 r.ctype_mod, r.data_length, r.data_precision, r.data_scale, r.nullable,
 r.character_set_name, r.top, r.char_length, r.char_used
from all_tab_columns tc, sys.dba_repcolumn r
where r.sname = tc.owner
  and r.oname = tc.table_name
  and ((r.top IS NOT NULL AND r.top = tc.column_name) OR
       (r.top IS NULL AND r.cname = tc.column_name))
union
select
 r.sname, r.oname, r.type, r.cname, r.id, r.pos, r.compare_old_on_delete,
 r.compare_old_on_update, r.send_old_on_delete, r.send_old_on_update,
 r.ctype, r.ctype_toid, r.ctype_owner, r.ctype_hashcode,
 r.ctype_mod, r.data_length, r.data_precision, r.data_scale, r.nullable,
 r.character_set_name, r.top, r.char_length, r.char_used
from  "_ALL_REPL_NESTED_TABLE_NAMES" nt, sys.dba_repcolumn r
where r.sname = nt.owner
  and r.oname = nt.table_name
/

comment on table ALL_REPCOLUMN is
'Replicated top-level columns (table) sorted alphabetically in ascending order'
/
comment on column ALL_REPCOLUMN.SNAME is
'Name of the object owner'
/
comment on column ALL_REPCOLUMN.ONAME is
'Name of the object'
/
comment on column ALL_REPCOLUMN.TYPE is
'Type of the object'
/
comment on column ALL_REPCOLUMN.CNAME is
'Name of the replicated column'
/
comment on column ALL_REPCOLUMN.ID is
'ID of the replicated column'
/
comment on column ALL_REPCOLUMN.POS is
'Ordering of the replicated column'
/
comment on column ALL_REPCOLUMN.COMPARE_OLD_ON_DELETE is
'Compare the old value of the column in replicated deletes'
/
comment on column ALL_REPCOLUMN.COMPARE_OLD_ON_UPDATE is
'Compare the old value of the column in replicated updates'
/
comment on column ALL_REPCOLUMN.SEND_OLD_ON_DELETE is
'Send the old value of the column in replicated deletes'
/
comment on column ALL_REPCOLUMN.SEND_OLD_ON_UPDATE is
'Send the old value of the column in replicated updates'
/
comment on column ALL_REPCOLUMN.CTYPE is
'Type of the column'
/
comment on column ALL_REPCOLUMN.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column ALL_REPCOLUMN.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column ALL_REPCOLUMN.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column ALL_REPCOLUMN.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_REPCOLUMN.CHARACTER_SET_NAME is
'Name of character set for column, if applicable'
/
comment on column ALL_REPCOLUMN.CTYPE_OWNER is
'Type owner of a column of TYPE'
/
comment on column ALL_REPCOLUMN.CTYPE_TOID is
'Type OID of a column of TYPE'
/
comment on column ALL_REPCOLUMN.CTYPE_HASHCODE is
'Type hashcode of a column of TYPE'
/
comment on column ALL_REPCOLUMN.CTYPE_MOD is
'Datatype modifier of a column'
/
comment on column ALL_REPCOLUMN.TOP is
'Top column name for an attribute'
/
comment on column ALL_REPCOLUMN.CHAR_LENGTH is
'The maximim length of the column in characters'
/
comment on column ALL_REPCOLUMN.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/

create or replace public synonym ALL_REPCOLUMN for ALL_REPCOLUMN
/
grant select on ALL_REPCOLUMN to PUBLIC with grant option
/


-- Create a view suitable for remote access from repcat.
-- This view is for internal use only and may change without notice.
-- This view respects column-level security and it will not select
-- any column which does not exist locally.
create or replace view "_ALL_REPCOLUMN"
(SNAME, ONAME, TYPE, LONG_CNAME, ID, POS, FLAG, CTYPE, DATA_LENGTH,
 DATA_PRECISION, DATA_SCALE, NULL$, CHARSETID, CHARSETFORM,
 CNAME, CTYPE_TOID, CTYPE_OWNER, CTYPE_NAME, CTYPE_VERSION#,
 CTYPE_HASHCODE, TOP, PROPERTY, CHAR_LENGTH)
as
select r.sname, r.oname, r.type, r.lcname, r.id, r.pos, r.flag, r.ctype,
  r.length, r.precision#, r.scale, r.null$, r.charsetid, r.charsetform,
  r.cname, r.toid, r.ctype_owner, r.ctype_name, r.version#, r.hashcode,
  r.top, r.property, r.clength
from all_tab_columns tc, system.repcat$_repcolumn r
where r.sname = tc.owner
  and r.oname = tc.table_name
  and ((NVL(r.top, r.cname) = tc.column_name) OR
       (r.top IS NULL AND r.cname = 'SYS_NC_OID$' AND
        -- sOID column
        utl_raw.bit_and(utl_raw.substr(r.property, 1, 1), '10') = '10'))
union
select
  r.sname, r.oname, r.type, r.lcname, r.id, r.pos, r.flag, r.ctype,
  r.length, r.precision#, r.scale, r.null$, r.charsetid, r.charsetform,
  r.cname, r.toid, r.ctype_owner, r.ctype_name, r.version#, r.hashcode,
  r.top, r.property, r.clength
from "_ALL_REPL_NESTED_TABLE_NAMES" nt, system.repcat$_repcolumn r
where r.sname = nt.owner
  and r.oname = nt.table_name
/

comment on table "_ALL_REPCOLUMN" is
'Replicated top-level columns (table) sorted alphabetically in ascending order'
/
comment on column "_ALL_REPCOLUMN".SNAME is
'Name of the object owner'
/
comment on column "_ALL_REPCOLUMN".ONAME is
'Name of the object'
/
comment on column "_ALL_REPCOLUMN".TYPE is
'Type of the object'
/
comment on column "_ALL_REPCOLUMN".LONG_CNAME is
'Long column name of the replicated column'
/
comment on column "_ALL_REPCOLUMN".CNAME is
'Internal column name of the replicated column'
/
comment on column "_ALL_REPCOLUMN".ID is
'ID of the replicated column'
/
comment on column "_ALL_REPCOLUMN".POS is
'Ordering of the replicated column'
/
comment on column "_ALL_REPCOLUMN".FLAG is
'Replication information about column'
/
comment on column "_ALL_REPCOLUMN".CTYPE is
'Type name of the column'
/
comment on column "_ALL_REPCOLUMN".CTYPE_OWNER is
'Type owner of a column of TYPE'
/
comment on column "_ALL_REPCOLUMN".CTYPE_NAME is
'Type name of a column of TYPE'
/
comment on column "_ALL_REPCOLUMN".CTYPE_TOID is
'Type OID of a column of TYPE'
/
comment on column "_ALL_REPCOLUMN".CTYPE_VERSION# is
'Type version# of a column of TYPE'
/
comment on column "_ALL_REPCOLUMN".CTYPE_HASHCODE is
'Type hashcode of a column of TYPE'
/
comment on column "_ALL_REPCOLUMN".DATA_LENGTH is
'Length of the column in bytes'
/
comment on column "_ALL_REPCOLUMN".DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column "_ALL_REPCOLUMN".DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column "_ALL_REPCOLUMN".NULL$ is
'Does column allow NULL values?'
/
comment on column "_ALL_REPCOLUMN".CHARSETID is
'Character set identifier'
/
comment on column "_ALL_REPCOLUMN".CHARSETFORM is
'Character set form'
/
comment on column "_ALL_REPCOLUMN".TOP is
'Top column of this attribute column'
/
comment on column "_ALL_REPCOLUMN".CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column "_ALL_REPCOLUMN".PROPERTY is
'Property of this column'
/
grant select on "_ALL_REPCOLUMN" to PUBLIC with grant option
/

create or replace view user_repcolumn
(sname, oname, type, cname, id, pos, compare_old_on_delete,
 compare_old_on_update, send_old_on_delete, send_old_on_update,
 ctype, ctype_toid, ctype_owner, ctype_hashcode, ctype_mod,
 data_length, data_precision, data_scale, nullable,
 character_set_name, top, char_length, char_used)
as
select
 r.sname, r.oname, r.type, r.cname, r.id, r.pos, r.compare_old_on_delete,
 r.compare_old_on_update, r.send_old_on_delete, r.send_old_on_update,
 r.ctype, r.ctype_toid, r.ctype_owner, r.ctype_hashcode,
 r.ctype_mod, r.data_length, r.data_precision, r.data_scale, r.nullable,
 r.character_set_name, r.top, r.char_length, r.char_used
from user_tab_columns tc, sys.dba_repcolumn r, sys.user$ u
where r.sname = u.name
  and u.user# = userenv('SCHEMAID')
  and r.oname = tc.table_name
  and ((r.top IS NOT NULL AND r.top = tc.column_name) OR
       (r.top IS NULL AND r.cname = tc.column_name))
union
select
 r.sname, r.oname, r.type, r.cname, r.id, r.pos, r.compare_old_on_delete,
 r.compare_old_on_update, r.send_old_on_delete, r.send_old_on_update,
 r.ctype, r.ctype_toid, r.ctype_owner, r.ctype_hashcode,
 r.ctype_mod, r.data_length, r.data_precision, r.data_scale, r.nullable,
 r.character_set_name, r.top, r.char_length, r.char_used
from "_USER_REPL_NESTED_TABLE_NAMES" nt, sys.dba_repcolumn r, sys.user$ u
where r.sname = u.name
  and u.user# = userenv('SCHEMAID')
  and r.oname = nt.table_name
/

comment on table USER_REPCOLUMN is
'Replicated columns for the current user''s table in ascending order'
/
comment on column USER_REPCOLUMN.SNAME is
'Name of the user'
/
comment on column USER_REPCOLUMN.ONAME is
'Name of the object'
/
comment on column USER_REPCOLUMN.TYPE is
'Type of the object'
/
comment on column USER_REPCOLUMN.CNAME is
'Name of the replicated column'
/
comment on column USER_REPCOLUMN.ID is
'ID of the replicated column'
/
comment on column USER_REPCOLUMN.POS is
'Ordering of the replicated column'
/
comment on column USER_REPCOLUMN.COMPARE_OLD_ON_DELETE is
'Compare the old value of the column in replicated deletes'
/
comment on column USER_REPCOLUMN.COMPARE_OLD_ON_UPDATE is
'Compare the old value of the column in replicated updates'
/
comment on column USER_REPCOLUMN.SEND_OLD_ON_DELETE is
'Send the old value of the column in replicated deletes'
/
comment on column USER_REPCOLUMN.SEND_OLD_ON_UPDATE is
'Send the old value of the column in replicated updates'
/
comment on column USER_REPCOLUMN.CTYPE is
'Type of the column'
/
comment on column USER_REPCOLUMN.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column USER_REPCOLUMN.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column USER_REPCOLUMN.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_REPCOLUMN.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_REPCOLUMN.CHARACTER_SET_NAME is
'Name of character set for column, if applicable'
/
comment on column USER_REPCOLUMN.CTYPE_OWNER is
'Type owner of a column of TYPE'
/
comment on column USER_REPCOLUMN.CTYPE_TOID is
'Type OID of a column of TYPE'
/
comment on column USER_REPCOLUMN.CTYPE_HASHCODE is
'Type hashcode of a column of TYPE'
/
comment on column USER_REPCOLUMN.CTYPE_MOD is
'Datatype modifier of a column'
/
comment on column USER_REPCOLUMN.TOP is
'Top column name for an attribute'
/
comment on column USER_REPCOLUMN.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column USER_REPCOLUMN.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/

create or replace public synonym USER_REPCOLUMN for USER_REPCOLUMN
/
grant select on USER_REPCOLUMN to PUBLIC with grant option
/


create or replace view USER_REPPROP
    (SNAME, ONAME, TYPE, DBLINK, HOW, PROPAGATE_COMMENT)
as
select r.sname, r.oname, r.type, r.dblink, r.how, r.propagate_comment
from repcat_repprop r, repcat_repobject ro, user_users u
where r.sname = u.username
  and r.sname = ro.sname
  and r.oname = ro.oname
  and r.type = ro.type
  and ro.type in ('PROCEDURE', 'PACKAGE', 'PACKAGE BODY', 'TABLE', 'SNAPSHOT')
/
comment on table USER_REPPROP is
'Propagation information about the current user''s objects'
/
comment on column USER_REPPROP.SNAME is
'Name of the user'
/
comment on column USER_REPPROP.ONAME is
'Name of the object'
/
comment on column USER_REPPROP.TYPE is
'Type of the object'
/
comment on column USER_REPPROP.DBLINK is
'Destination database for propagation'
/
comment on column USER_REPPROP.HOW is
'Propagation choice for the destination database'
/
comment on column USER_REPPROP.PROPAGATE_COMMENT is
'User description of the propagation choice'
/
create or replace public synonym USER_REPPROP for USER_REPPROP
/
grant select on USER_REPPROP to PUBLIC with grant option
/
create or replace view ALL_REPPROP
    (SNAME, ONAME, TYPE, DBLINK, HOW, PROPAGATE_COMMENT)
as
select r.sname, r.oname, r.type, r.dblink, r.how, r.propagate_comment
from repcat_repprop r, all_users u, all_repobject ro
where r.sname = u.username
  and r.sname = ro.sname
  and r.oname = ro.oname
  and r.type = ro.type
  and ro.type in ('PROCEDURE', 'PACKAGE', 'PACKAGE BODY', 'TABLE', 'SNAPSHOT')
/
comment on table ALL_REPPROP is
'Propagation information about replicated objects'
/
comment on column ALL_REPPROP.SNAME is
'Name of the object owner'
/
comment on column ALL_REPPROP.ONAME is
'Name of the object'
/
comment on column ALL_REPPROP.TYPE is
'Type of the object'
/
comment on column ALL_REPPROP.DBLINK is
'Destination database for propagation'
/
comment on column ALL_REPPROP.HOW is
'Propagation choice for the destination database'
/
comment on column ALL_REPPROP.PROPAGATE_COMMENT is
'Description of the propagation choice'
/
create or replace public synonym ALL_REPPROP for ALL_REPPROP
/
grant select on ALL_REPPROP to PUBLIC with grant option
/


create or replace view DBA_REPPROP
    (SNAME, ONAME, TYPE, DBLINK, HOW, PROPAGATE_COMMENT)
as
select r.sname, r.oname, r.type, r.dblink, r.how, r.propagate_comment
from repcat_repprop r, repcat_repobject ro
where r.sname = ro.sname
  and r.oname = ro.oname
  and r.type = ro.type
  and ro.type in ('PROCEDURE', 'PACKAGE', 'PACKAGE BODY', 'TABLE', 'SNAPSHOT')
/
comment on table DBA_REPPROP is
'Propagation information about replicated objects'
/
comment on column DBA_REPPROP.SNAME is
'Name of the object owner'
/
comment on column DBA_REPPROP.ONAME is
'Name of the object'
/
comment on column DBA_REPPROP.TYPE is
'Type of the object'
/
comment on column DBA_REPPROP.DBLINK is
'Destination database for propagation'
/
comment on column DBA_REPPROP.HOW is
'Propagation choice for the destination database'
/
comment on column DBA_REPPROP.PROPAGATE_COMMENT is
'Description of the propagation choice'
/
create or replace public synonym DBA_REPPROP for DBA_REPPROP
/
grant select on DBA_REPPROP to select_catalog_role
/

create or replace view DBA_REPKEY_COLUMNS
    (SNAME, ONAME, COL)
as
select rk.sname, rk.oname, rc.lcname
from system.repcat$_key_columns rk, system.repcat$_repcolumn rc
where rk.sname   = rc.sname
  and rk.oname   = rc.oname
  and rk.col     = rc.cname  -- SYS column name
/
comment on table DBA_REPKEY_COLUMNS is
'Primary columns for a table using column-level replication'
/
comment on column DBA_REPKEY_COLUMNS.SNAME is
'Schema containing table'
/
comment on column DBA_REPKEY_COLUMNS.ONAME is
'Name of the table'
/
comment on column DBA_REPKEY_COLUMNS.COL is
'Column in the table'
/
create or replace public synonym DBA_REPKEY_COLUMNS for DBA_REPKEY_COLUMNS
/
grant select on DBA_REPKEY_COLUMNS to select_catalog_role
/


create or replace view USER_REPKEY_COLUMNS
    (SNAME, ONAME, COL)
as
select r.sname, r.oname, r.col
from sys.dba_repkey_columns r, user_users u
where r.sname = u.username
/
comment on table USER_REPKEY_COLUMNS is
'Primary columns for a table using column-level replication'
/
comment on column USER_REPKEY_COLUMNS.SNAME is
'Schema containing table'
/
comment on column USER_REPKEY_COLUMNS.ONAME is
'Name of the table'
/
comment on column USER_REPKEY_COLUMNS.COL is
'Column in the table'
/
create or replace public synonym USER_REPKEY_COLUMNS for USER_REPKEY_COLUMNS
/
grant select on USER_REPKEY_COLUMNS to PUBLIC with grant option
/


create or replace view ALL_REPKEY_COLUMNS
    (SNAME, ONAME, COL)
as
select r.sname, r.oname, r.col
from sys.dba_repkey_columns r, all_repobject ro
where r.sname = ro.sname
  and r.oname = ro.oname
  and ro.type IN ('TABLE', 'SNAPSHOT')
/
comment on table ALL_REPKEY_COLUMNS is
'Primary columns for a table using column-level replication'
/
comment on column ALL_REPKEY_COLUMNS.SNAME is
'Schema containing table'
/
comment on column ALL_REPKEY_COLUMNS.ONAME is
'Name of the table'
/
comment on column ALL_REPKEY_COLUMNS.COL is
'Column in the table'
/
create or replace public synonym ALL_REPKEY_COLUMNS for ALL_REPKEY_COLUMNS
/
grant select on ALL_REPKEY_COLUMNS to PUBLIC with grant option
/

create or replace view USER_REPGENOBJECTS
  (SNAME, ONAME, TYPE, BASE_SNAME, BASE_ONAME, BASE_TYPE, PACKAGE_PREFIX,
    PROCEDURE_PREFIX, DISTRIBUTED, REASON)
as
select r.sname, r.oname, r.type, r.base_sname, r.base_oname, r.base_type,
  r.package_prefix, r.procedure_prefix, r.distributed, r.reason
from repcat_generated r, user_users u
where r.base_sname = u.username
/
comment on table USER_REPGENOBJECTS is
'Objects generated for the current user to support replication'
/
comment on column USER_REPGENOBJECTS.SNAME is
'Schema containing the generated object'
/
comment on column USER_REPGENOBJECTS.ONAME is
'Name of the generated object'
/
comment on column USER_REPGENOBJECTS.TYPE is
'Type of the generated object'
/
comment on column USER_REPGENOBJECTS.BASE_SNAME is
'Name of the user'
/
comment on column USER_REPGENOBJECTS.BASE_ONAME is
'Name of the user''s object'
/
comment on column USER_REPGENOBJECTS.BASE_TYPE is
'Type of the user''s object'
/
comment on column USER_REPGENOBJECTS.PACKAGE_PREFIX is
'Prefix for package wrapper'
/
comment on column USER_REPGENOBJECTS.PROCEDURE_PREFIX is
'Procedure prefix for package wrapper or procedure wrapper'
/
comment on column USER_REPGENOBJECTS.DISTRIBUTED is
'Is the generated object separately generated at each master'
/
comment on column USER_REPGENOBJECTS.REASON is
'Reason the object was generated'
/
create or replace public synonym USER_REPGENOBJECTS for USER_REPGENOBJECTS
/
grant select on USER_REPGENOBJECTS to PUBLIC with grant option
/


create or replace view ALL_REPGENOBJECTS
  (SNAME, ONAME, TYPE, BASE_SNAME, BASE_ONAME, BASE_TYPE, PACKAGE_PREFIX,
    PROCEDURE_PREFIX, DISTRIBUTED, REASON)
as
select r.sname, r.oname, r.type, r.base_sname, r.base_oname, r.base_type,
  r.package_prefix, r.procedure_prefix, r.distributed, r.reason
from repcat_generated r, all_users u, all_objects o
where r.base_sname = u.username
  and r.base_sname = o.owner
  and r.base_oname = o.object_name
  and (r.base_type = o.object_type
       or (r.base_type = 'SNAPSHOT'
           and o.object_type IN ('VIEW','TABLE')))
union
select r.sname, r.oname, r.type, r.base_sname, r.base_oname, r.base_type,
  r.package_prefix, r.procedure_prefix, r.distributed, r.reason
from user_repgenobjects r
union
select r.sname, r.oname, r.type, r.base_sname, r.base_oname,
  r.base_type, r.package_prefix, r.procedure_prefix,
  r.distributed, r.reason
from repcat_generated r, all_users u, repcat_repobject ro
where r.base_sname = u.username
and r.base_sname = ro.sname
and r.base_oname = ro.oname
and r.base_type = ro.type
and (ro.gname, ro.gowner) in
(select nvl(rp.gname,ro.gname), nvl(rp.owner, ro.gowner)
 from user_repgroup_privileges rp
 where rp.proxy_snapadmin='Y')
/
comment on table ALL_REPGENOBJECTS is
'Objects generated to support replication'
/
comment on column ALL_REPGENOBJECTS.SNAME is
'Schema containing the generated object'
/
comment on column ALL_REPGENOBJECTS.ONAME is
'Name of the generated object'
/
comment on column ALL_REPGENOBJECTS.TYPE is
'Type of the generated object'
/
comment on column ALL_REPGENOBJECTS.BASE_SNAME is
'Name of the object''s owner'
/
comment on column ALL_REPGENOBJECTS.BASE_ONAME is
'Name of the object'
/
comment on column ALL_REPGENOBJECTS.BASE_TYPE is
'Type of the object'
/
comment on column ALL_REPGENOBJECTS.PACKAGE_PREFIX is
'Prefix for package wrapper'
/
comment on column ALL_REPGENOBJECTS.PROCEDURE_PREFIX is
'Procedure prefix for package wrapper or procedure wrapper'
/
comment on column ALL_REPGENOBJECTS.DISTRIBUTED is
'Is the generated object separately generated at each master'
/
comment on column ALL_REPGENOBJECTS.REASON is
'Reason the object was generated'
/
create or replace public synonym ALL_REPGENOBJECTS for ALL_REPGENOBJECTS
/
grant select on ALL_REPGENOBJECTS to PUBLIC with grant option
/
create or replace view DBA_REPGENOBJECTS
  (SNAME, ONAME, TYPE, BASE_SNAME, BASE_ONAME, BASE_TYPE, PACKAGE_PREFIX,
    PROCEDURE_PREFIX, DISTRIBUTED, REASON)
as
select r.sname, r.oname, r.type, r.base_sname, r.base_oname, r.base_type,
  r.package_prefix, r.procedure_prefix, r.distributed, r.reason
from repcat_generated r
/
comment on table DBA_REPGENOBJECTS is
'Objects generated to support replication'
/
comment on column DBA_REPGENOBJECTS.SNAME is
'Schema containing the generated object'
/
comment on column DBA_REPGENOBJECTS.ONAME is
'Name of the generated object'
/
comment on column DBA_REPGENOBJECTS.TYPE is
'Type of the generated object'
/
comment on column DBA_REPGENOBJECTS.BASE_SNAME is
'Name of the object''s owner'
/
comment on column DBA_REPGENOBJECTS.BASE_ONAME is
'Name of the object'
/
comment on column DBA_REPGENOBJECTS.BASE_TYPE is
'Type of the object'
/
comment on column DBA_REPGENOBJECTS.PACKAGE_PREFIX is
'Prefix for package wrapper'
/
comment on column DBA_REPGENOBJECTS.PROCEDURE_PREFIX is
'Procedure prefix for package wrapper or procedure wrapper'
/
comment on column DBA_REPGENOBJECTS.DISTRIBUTED is
'Is the generated object separately generated at each master'
/
comment on column DBA_REPGENOBJECTS.REASON is
'Reason the object was generated'
/
create or replace public synonym DBA_REPGENOBJECTS for DBA_REPGENOBJECTS
/
grant select on DBA_REPGENOBJECTS to select_catalog_role
/


create or replace view USER_REPGENERATED  -- obsolete, keep for compatibility
  (SNAME, ONAME, TYPE, BASE_SNAME, BASE_ONAME, BASE_TYPE, PACKAGE_PREFIX,
    PROCEDURE_PREFIX, DISTRIBUTED, REASON)
as
select r.sname, r.oname, r.type, r.base_sname, r.base_oname, r.base_type,
  r.package_prefix, r.procedure_prefix, r.distributed, r.reason
from repcat_generated r, user_users u
where r.base_sname = u.username
and ((r.reason  = 'PROCEDURAL REPLICATION WRAPPER' and r.type != 'SYNONYM')
   or r.reason != 'PROCEDURAL REPLICATION WRAPPER')
/
comment on table USER_REPGENERATED is
'Objects generated for the current user to support replication'
/
comment on column USER_REPGENERATED.SNAME is
'Schema containing the generated object'
/
comment on column USER_REPGENERATED.ONAME is
'Name of the generated object'
/
comment on column USER_REPGENERATED.TYPE is
'Type of the generated object'
/
comment on column USER_REPGENERATED.BASE_SNAME is
'Name of the user'
/
comment on column USER_REPGENERATED.BASE_ONAME is
'Name of the user''s object'
/
comment on column USER_REPGENERATED.BASE_TYPE is
'Type of the user''s object'
/
comment on column USER_REPGENERATED.PACKAGE_PREFIX is
'Prefix for package wrapper'
/
comment on column USER_REPGENERATED.PROCEDURE_PREFIX is
'Procedure prefix for package wrapper or procedure wrapper'
/
comment on column USER_REPGENERATED.DISTRIBUTED is
'Is the generated object separately generated at each master'
/
comment on column USER_REPGENERATED.REASON is
'Reason the object was generated'
/
create or replace public synonym USER_REPGENERATED for USER_REPGENERATED
/
grant select on USER_REPGENERATED to PUBLIC with grant option
/


create or replace view ALL_REPGENERATED  -- obsolete, keep for compatibility
  (SNAME, ONAME, TYPE, BASE_SNAME, BASE_ONAME, BASE_TYPE, PACKAGE_PREFIX,
    PROCEDURE_PREFIX, DISTRIBUTED, REASON)
as
select r.sname, r.oname, r.type, r.base_sname, r.base_oname, r.base_type,
  r.package_prefix, r.procedure_prefix, r.distributed, r.reason
from repcat_generated r, all_users u, all_objects o
where r.base_sname = u.username
  and r.base_sname = o.owner
  and r.base_oname = o.object_name
  and (r.base_type = o.object_type
       or (r.base_type = 'SNAPSHOT'
           and o.object_type IN ('VIEW','TABLE')))
  and ((r.reason  = 'PROCEDURAL REPLICATION WRAPPER' and r.type != 'SYNONYM')
     or r.reason != 'PROCEDURAL REPLICATION WRAPPER')
union
select r.sname, r.oname, r.type, r.base_sname, r.base_oname, r.base_type,
  r.package_prefix, r.procedure_prefix, r.distributed, r.reason
from user_repgenerated r
union
select r.sname, r.oname, r.type, r.base_sname, r.base_oname,
  r.base_type, r.package_prefix, r.procedure_prefix, 
  r.distributed, r.reason
from repcat_generated r, all_users u, repcat_repobject ro
where r.base_sname = u.username
and ((r.reason  = 'PROCEDURAL REPLICATION WRAPPER' 
  and r.type != 'SYNONYM')
or r.reason != 'PROCEDURAL REPLICATION WRAPPER')
and r.sname = ro.sname
and r.oname = ro.oname
and r.type = ro.type
and (ro.gname, ro.gowner) in
(select nvl(rp.gname,ro.gname), nvl(rp.owner, ro.gowner)
 from user_repgroup_privileges rp
 where rp.proxy_snapadmin='Y')
/
comment on table ALL_REPGENERATED is
'Objects generated to support replication'
/
comment on column ALL_REPGENERATED.SNAME is
'Schema containing the generated object'
/
comment on column ALL_REPGENERATED.ONAME is
'Name of the generated object'
/
comment on column ALL_REPGENERATED.TYPE is
'Type of the generated object'
/
comment on column ALL_REPGENERATED.BASE_SNAME is
'Name of the object''s owner'
/
comment on column ALL_REPGENERATED.BASE_ONAME is
'Name of the object'
/
comment on column ALL_REPGENERATED.BASE_TYPE is
'Type of the object'
/
comment on column ALL_REPGENERATED.PACKAGE_PREFIX is
'Prefix for package wrapper'
/
comment on column ALL_REPGENERATED.PROCEDURE_PREFIX is
'Procedure prefix for package wrapper or procedure wrapper'
/
comment on column ALL_REPGENERATED.DISTRIBUTED is
'Is the generated object separately generated at each master'
/
comment on column ALL_REPGENERATED.REASON is
'Reason the object was generated'
/
create or replace public synonym ALL_REPGENERATED for ALL_REPGENERATED
/
grant select on ALL_REPGENERATED to PUBLIC with grant option
/


create or replace view DBA_REPGENERATED  -- obsolete, keep for compatibility
  (SNAME, ONAME, TYPE, BASE_SNAME, BASE_ONAME, BASE_TYPE, PACKAGE_PREFIX,
    PROCEDURE_PREFIX, DISTRIBUTED, REASON)
as
select r.sname, r.oname, r.type, r.base_sname, r.base_oname, r.base_type,
  r.package_prefix, r.procedure_prefix, r.distributed, r.reason
from repcat_generated r
where ((r.reason  = 'PROCEDURAL REPLICATION WRAPPER' and r.type != 'SYNONYM')
     or r.reason != 'PROCEDURAL REPLICATION WRAPPER')
/
comment on table DBA_REPGENERATED is
'Objects generated to support replication'
/
comment on column DBA_REPGENERATED.SNAME is
'Schema containing the generated object'
/
comment on column DBA_REPGENERATED.ONAME is
'Name of the generated object'
/
comment on column DBA_REPGENERATED.TYPE is
'Type of the generated object'
/
comment on column DBA_REPGENERATED.BASE_SNAME is
'Name of the object''s owner'
/
comment on column DBA_REPGENERATED.BASE_ONAME is
'Name of the object'
/
comment on column DBA_REPGENERATED.BASE_TYPE is
'Type of the object'
/
comment on column DBA_REPGENERATED.PACKAGE_PREFIX is
'Prefix for package wrapper'
/
comment on column DBA_REPGENERATED.PROCEDURE_PREFIX is
'Procedure prefix for package wrapper or procedure wrapper'
/
comment on column DBA_REPGENERATED.DISTRIBUTED is
'Is the generated object separately generated at each master'
/
comment on column DBA_REPGENERATED.REASON is
'Reason the object was generated'
/
create or replace public synonym DBA_REPGENERATED for DBA_REPGENERATED
/
grant select on DBA_REPGENERATED to select_catalog_role
/
create or replace view USER_REPCATLOG
    (ID, SOURCE, USERID, TIMESTAMP, ROLE, MASTER, SNAME, REQUEST, 
     ONAME, TYPE, STATUS, MESSAGE, ERRNUM, GNAME)
as
select r.id, r.source, r.userid, r.timestamp, r.role, r.master, r.sname,
  r.request, r.oname, r.type, r.status, r.message, r.errnum, r.gname
from repcat_repcatlog r, user_users u
where r.sname = u.username or r.userid = u.username
/
comment on table USER_REPCATLOG is
'Information about the current user''s asynchronous administration requests'
/
comment on column USER_REPCATLOG.ID is
'Identifying number of repcat log record'
/
comment on column USER_REPCATLOG.SOURCE is
'Name of the database at which the request originated'
/
comment on column USER_REPCATLOG.USERID is
'Name of the user who submitted the request'
/
comment on column USER_REPCATLOG.TIMESTAMP is
'When the request was submitted'
/
comment on column USER_REPCATLOG.ROLE is
'Is this database the masterdef for the request'
/
comment on column USER_REPCATLOG.MASTER is
'Name of the database that processes this request'
/
comment on column USER_REPCATLOG.GNAME is
'Name of the replicated object group'
/
comment on column USER_REPCATLOG.REQUEST is
'Name of the requested operation'
/
comment on column USER_REPCATLOG.SNAME is
'Schema of replicated object name, if applicable'
/
comment on column USER_REPCATLOG.ONAME is
'Replicated object name, if applicable'
/
comment on column USER_REPCATLOG.TYPE is
'Type of replicated object, if applicable'
/
comment on column USER_REPCATLOG.STATUS is
'Status of the request at this database'
/
comment on column USER_REPCATLOG.MESSAGE is
'Error message associated with processing the request'
/
comment on column USER_REPCATLOG.ERRNUM is
'Oracle error number associated with processing the request'
/
create or replace public synonym USER_REPCATLOG for USER_REPCATLOG
/
grant select on USER_REPCATLOG to PUBLIC with grant option
/


create or replace view ALL_REPCATLOG
    (ID, SOURCE, USERID, TIMESTAMP, ROLE, MASTER, SNAME, REQUEST, 
     ONAME, TYPE, STATUS, MESSAGE, ERRNUM, GNAME)
as
select r.id, r.source, r.userid, r.timestamp, r.role, r.master, r.sname,
  r.request, r.oname, r.type, r.status, r.message, r.errnum, r.gname
from repcat_repcatlog r, all_objects o
where (r.sname = 'PUBLIC' or r.sname in (select u.username from all_users u))
  and r.sname = o.owner
  and r.oname = o.object_name
  and r.type = o.object_type
union
select r.id, r.source, r.userid, r.timestamp, r.role, r.master, r.sname,
  r.request, r.oname, r.type, r.status, r.message, r.errnum, r.gname
from user_repcatlog r
/
comment on table ALL_REPCATLOG is
'Information about asynchronous administration requests'
/
comment on column ALL_REPCATLOG.ID is
'Identifying number of repcat log record'
/
comment on column ALL_REPCATLOG.SOURCE is
'Name of the database at which the request originated'
/
comment on column ALL_REPCATLOG.USERID is
'Name of the user who submitted the request'
/
comment on column ALL_REPCATLOG.TIMESTAMP is
'When the request was submitted'
/
comment on column ALL_REPCATLOG.ROLE is
'Is this database the masterdef for the request'
/
comment on column ALL_REPCATLOG.MASTER is
'Name of the database that processes this request'
/
comment on column ALL_REPCATLOG.GNAME is
'Name of the replicated object group'
/
comment on column ALL_REPCATLOG.REQUEST is
'Name of the requested operation'
/
comment on column ALL_REPCATLOG.SNAME is
'Schema of replicated object name, if applicable'
/
comment on column ALL_REPCATLOG.ONAME is
'Replicated object name, if applicable'
/
comment on column ALL_REPCATLOG.TYPE is
'Type of replicated object, if applicable'
/
comment on column ALL_REPCATLOG.STATUS is
'Status of the request at this database'
/
comment on column ALL_REPCATLOG.MESSAGE is
'Error message associated with processing the request'
/
comment on column ALL_REPCATLOG.ERRNUM is
'Oracle error number associated with processing the request'
/
create or replace public synonym ALL_REPCATLOG for ALL_REPCATLOG
/
grant select on ALL_REPCATLOG to PUBLIC with grant option
/


create or replace view DBA_REPCATLOG
    (ID, SOURCE, STATUS, USERID, TIMESTAMP, ROLE, MASTER, SNAME, REQUEST,
     ONAME, TYPE, MESSAGE, ERRNUM, GNAME)
as
select r.id, r.source, r.status, r.userid, r.timestamp, r.role, r.master,
  r.sname, r.request, r.oname, r.type, r.message, r.errnum, r.gname
from repcat_repcatlog r
/
comment on table DBA_REPCATLOG is
'Information about asynchronous administration requests'
/
comment on column DBA_REPCATLOG.ID is
'Identifying number of repcat log record'
/
comment on column DBA_REPCATLOG.SOURCE is
'Name of the database at which the request originated'
/
comment on column DBA_REPCATLOG.STATUS is
'Status of the request at this database'
/
comment on column DBA_REPCATLOG.USERID is
'Name of the user who submitted the request'
/
comment on column DBA_REPCATLOG.TIMESTAMP is
'When the request was submitted'
/
comment on column DBA_REPCATLOG.ROLE is
'Is this database the masterdef for the request'
/
comment on column DBA_REPCATLOG.MASTER is
'Name of the database that processes this request'
/
comment on column DBA_REPCATLOG.GNAME is
'Name of the replicated object group'
/
comment on column DBA_REPCATLOG.REQUEST is
'Name of the requested operation'
/
comment on column DBA_REPCATLOG.SNAME is
'Schema of replicated object name, if applicable'
/
comment on column DBA_REPCATLOG.ONAME is
'Replicated object name, if applicable'
/
comment on column DBA_REPCATLOG.TYPE is
'Type of replicated object, if applicable'
/
comment on column DBA_REPCATLOG.MESSAGE is
'Error message associated with processing the request'
/
comment on column DBA_REPCATLOG.ERRNUM is
'Oracle error number associated with processing the request'
/
create or replace public synonym DBA_REPCATLOG for DBA_REPCATLOG
/
grant select on DBA_REPCATLOG to select_catalog_role
/


create or replace view USER_REPDDL
  (LOG_ID, SOURCE, ROLE, MASTER, LINE, TEXT, DDL_NUM)
as
select r.log_id, r.source, r.role, r.master, r.line, r.text, r.ddl_num
from system.repcat$_ddl r, user_repcatlog u
where r.log_id = u.id
  and r.source = u.source
/
comment on table USER_REPDDL is
'Arguments that do not fit in a single repcat log record'
/
comment on column USER_REPDDL.LOG_ID is
'Identifying number of the repcat log record'
/
comment on column USER_REPDDL.SOURCE is
'Name of the database at which the request originated'
/
comment on column USER_REPDDL.ROLE is
'Is this database the masterdef for the request'
/
comment on column USER_REPDDL.MASTER is
'Name of the database that processes this request'
/
comment on column USER_REPDDL.LINE is
'Ordering of records within a single request'
/
comment on column USER_REPDDL.TEXT is
'Portion of an argument'
/
comment on column USER_REPDDL.DDL_NUM is
'Order of ddls to execute'
/
create or replace public synonym USER_REPDDL for USER_REPDDL
/
grant select on USER_REPDDL to PUBLIC with grant option
/


create or replace view ALL_REPDDL
  (LOG_ID, SOURCE, ROLE, MASTER, LINE, TEXT, DDL_NUM)
as
select r.log_id, r.source, r.role, r.master, r.line, r.text, r.ddl_num
from system.repcat$_ddl r, all_repcatlog u
where r.log_id = u.id
  and r.source = u.source
/
comment on table ALL_REPDDL is
'Arguments that do not fit in a single repcat log record'
/
comment on column ALL_REPDDL.LOG_ID is
'Identifying number of the repcat log record'
/
comment on column ALL_REPDDL.SOURCE is
'Name of the database at which the request originated'
/
comment on column ALL_REPDDL.ROLE is
'Is this database the masterdef for the request'
/
comment on column ALL_REPDDL.MASTER is
'Name of the database that processes this request'
/
comment on column ALL_REPDDL.LINE is
'Ordering of records within a single request'
/
comment on column ALL_REPDDL.TEXT is
'Portion of an argument'
/
comment on column ALL_REPDDL.DDL_NUM is
'Order of ddls to execute'
/
create or replace public synonym ALL_REPDDL for ALL_REPDDL
/
grant select on ALL_REPDDL to PUBLIC with grant option
/


create or replace view DBA_REPDDL
  (LOG_ID, SOURCE, ROLE, MASTER, LINE, TEXT, DDL_NUM)
as
select r.log_id, r.source, r.role, r.master, r.line, r.text, r.ddl_num
from system.repcat$_ddl r
/
comment on table DBA_REPDDL is
'Arguments that do not fit in a single repcat log record'
/
comment on column DBA_REPDDL.LOG_ID is
'Identifying number of the repcat log record'
/
comment on column DBA_REPDDL.SOURCE is
'Name of the database at which the request originated'
/
comment on column DBA_REPDDL.ROLE is
'Is this database the masterdef for the request'
/
comment on column DBA_REPDDL.MASTER is
'Name of the database that processes this request'
/
comment on column DBA_REPDDL.LINE is
'Ordering of records within a single request'
/
comment on column DBA_REPDDL.TEXT is
'Portion of an argument'
/
comment on column DBA_REPDDL.DDL_NUM is
'Order of ddls to execute'
/
create or replace public synonym DBA_REPDDL for DBA_REPDDL
/
grant select on DBA_REPDDL to select_catalog_role
/


create table system.repcat$_priority_group
(
    sname                  varchar2(30), -- interpreted as gname
    priority_group         varchar2(30),
    data_type_id           integer
                               constraint repcat$_priority_group_nn1
                                 not null
                               constraint repcat$_priority_group_c1
                                check (data_type_id in (1, 2, 3, 4, 5, 6, 7)),
    fixed_data_length      integer,
    priority_comment      varchar2(80),
        constraint repcat$_priority_group_pk
          primary key (priority_group, sname),
        constraint repcat$_priority_group_u1
          unique (sname, priority_group, data_type_id, fixed_data_length),
        constraint repcat$_priority_group_c2
          check ((data_type_id in (4, 7) and
                  fixed_data_length is not null)
              or (data_type_id in (1, 2, 3, 5, 6) and
                  fixed_data_length is null))
)
/
comment on table system.repcat$_priority_group is
'Information about all priority groups in the database'
/
comment on column system.repcat$_priority_group.sname is
'Name of the replicated object group'
/
comment on column system.repcat$_priority_group.priority_group is
'Name of the priority group'
/
comment on column system.repcat$_priority_group.data_type_id is
'Datatype of the value in the priority group'
/
comment on column system.repcat$_priority_group.fixed_data_length is
'Length of the value in bytes if the datatype is CHAR'
/
comment on column system.repcat$_priority_group.priority_comment is
'Description of the priority group'
/


create or replace view dba_reppriority_group
(
    sname, --- OBSOLETE
    priority_group,
    data_type,
    fixed_data_length,
    priority_comment,
    gname
)
as
select
    sname,
    priority_group,
    decode(data_type_id,
           1, 'NUMBER',
           2, 'VARCHAR2',
           3, 'DATE',
           4, 'CHAR',
           5, 'RAW',
           6, 'NVARCHAR2',
           7, 'NCHAR',
           'UNDEFINED'),
    fixed_data_length,
    priority_comment,
    sname
from  system.repcat$_priority_group
/
comment on table dba_reppriority_group is
'Information about all priority groups in the database'
/
comment on column dba_reppriority_group.sname is
'OBSOLETE COLUMN: Name of the replicated schema'
/
comment on column dba_reppriority_group.gname is
'Name of the replicated object group'
/
comment on column dba_reppriority_group.priority_group is
'Name of the priority group'
/
comment on column dba_reppriority_group.data_type is
'Datatype of the value in the priority group'
/
comment on column dba_reppriority_group.fixed_data_length is
'Length of the value in bytes if the datatype is CHAR'
/
comment on column dba_reppriority_group.priority_comment is
'Description of the priority group'
/
create or replace public synonym dba_reppriority_group
   for dba_reppriority_group
/
grant select on dba_reppriority_group to select_catalog_role
/


create or replace view all_reppriority_group
(
    sname, --- OBSOLETE
    priority_group,
    data_type,
    fixed_data_length,
    priority_comment,
    gname
)
as
select
    sname,
    priority_group,
    decode(data_type_id,
           1, 'NUMBER',
           2, 'VARCHAR2',
           3, 'DATE',
           4, 'CHAR',
           5, 'RAW',
           6, 'NVARCHAR2',
           7, 'NCHAR',
           'UNDEFINED'),
    fixed_data_length,
    priority_comment,
    sname
from  system.repcat$_priority_group
/
comment on table all_reppriority_group is
'Information about all priority groups which are accessible to the user'
/
comment on column all_reppriority_group.sname is
'OBSOLETE COLUMN: Name of the replicated schema'
/
comment on column all_reppriority_group.gname is
'Name of the replicated object group'
/
comment on column all_reppriority_group.priority_group is
'Name of the priority group'
/
comment on column all_reppriority_group.data_type is
'Datatype of the value in the priority group'
/
comment on column all_reppriority_group.fixed_data_length is
'Length of the value in bytes if the datatype is CHAR'
/
comment on column all_reppriority_group.priority_comment is
'Description of the priority group'
/
create or replace public synonym all_reppriority_group
   for all_reppriority_group
/
grant select on all_reppriority_group to public with grant option
/


create or replace view user_reppriority_group
(
    priority_group,
    data_type,
    fixed_data_length,
    priority_comment
)
as
select
    r.priority_group,
    decode(r.data_type_id,
           1, 'NUMBER',
           2, 'VARCHAR2',
           3, 'DATE',
           4, 'CHAR',
           5, 'RAW',
           6, 'NVARCHAR2',
           7, 'NCHAR',
           'UNDEFINED'),
    r.fixed_data_length,
    r.priority_comment
from  system.repcat$_priority_group r, sys.user$ u
where r.sname = u.name
and   u.user# = userenv('SCHEMAID')
/
comment on table user_reppriority_group is
'Information about user''s priority groups'
/
comment on column user_reppriority_group.priority_group is
'Name of the priority group'
/
comment on column user_reppriority_group.data_type is
'Datatype of the value'
/
comment on column user_reppriority_group.fixed_data_length is
'Length of the value in bytes if the datatype is CHAR'
/
comment on column user_reppriority_group.priority_comment is
'Description of the priority group'
/
create or replace public synonym user_reppriority_group
   for user_reppriority_group
/
grant select on user_reppriority_group to public with grant option
/


-- the value columns in this table are of the maximum size of oracle.
-- Traditional chinese is a four byte character set, so the nchar
-- and nvarchar2 sizes are set to the most conservative number.
-- For interop with v7, the char_value must remain at 255 (due to
-- padding).  Values of length over 255 will be kept in large_char_value.
create table system.repcat$_priority
(
    sname                  varchar2(30) --- interpreted as gname
                               constraint repcat$_priority_nn1
                                 not null,
    priority_group         varchar2(30)
                               constraint repcat$_priority_nn2
                                 not null,
    priority               number
                               constraint repcat$_priority_nn3
                                 not null,
    raw_value              raw(2000),
    char_value             char(255),
    number_value           number,
    date_value             date,
    varchar2_value         varchar2(4000),
    nchar_value            nchar(500),        -- 4 * 500 = 2000 bytes
    nvarchar2_value        nvarchar2(1000),   -- 4 * 1000 = 4000 bytes
    large_char_value       char(2000),
        constraint repcat$_priority_pk
          primary key (sname, priority_group, priority),
        constraint repcat$_priority_f1
          foreign key (priority_group, sname)
          references system.repcat$_priority_group
)
/
-- index on foreign key to avoid deadlocks in
-- concurrent do_deferred_repcat_admin
create index system.repcat$_priority_f1_idx on
  system.repcat$_priority(priority_group, sname)
/
comment on table system.repcat$_priority is
'Values and their corresponding priorities in all priority groups in the database'
/
comment on column system.repcat$_priority.sname is
'Name of the replicated object group'
/
comment on column system.repcat$_priority.priority_group is
'Name of the priority group'
/
comment on column system.repcat$_priority.priority is
'Priority of the value'
/
comment on column system.repcat$_priority.raw_value is
'Raw value'
/
comment on column system.repcat$_priority.char_value is
'Blank-padded character string'
/
comment on column system.repcat$_priority.number_value is
'Numeric value'
/
comment on column system.repcat$_priority.date_value is
'Date value'
/
comment on column system.repcat$_priority.varchar2_value is
'Character string'
/
comment on column system.repcat$_priority.nchar_value is 
'NCHAR string'
/
comment on column system.repcat$_priority.nvarchar2_value is
'NVARCHAR2 string'
/
comment on column system.repcat$_priority.large_char_value is
'Blank-padded character string over 255 characters'
/

create or replace view dba_reppriority
(
    sname, --- OBSOLETE
    priority_group,
    priority,
    data_type,
    fixed_data_length,
    char_value,
    varchar2_value,
    number_value,
    date_value,
    raw_value,
    gname,
    nchar_value,
    nvarchar2_value,
    large_char_value
)
as
select
    p.sname,
    p.priority_group,
    v.priority,
    decode(p.data_type_id,
           1, 'NUMBER',
           2, 'VARCHAR2',
           3, 'DATE',
           4, 'CHAR',
           5, 'RAW',
           6, 'NVARCHAR2',
           7, 'NCHAR',
           'UNDEFINED'),
    p.fixed_data_length,
    v.char_value,
    v.varchar2_value,
    v.number_value,
    v.date_value,
    v.raw_value,
    p.sname,
    v.nchar_value,
    v.nvarchar2_value,
    v.large_char_value
from  system.repcat$_priority v,
      system.repcat$_priority_group p
where v.sname = p.sname
and   v.priority_group = p.priority_group
/
comment on table dba_reppriority is
'Values and their corresponding priorities in all priority groups in the database'
/
comment on column dba_reppriority.sname is
'OBSOLETE COLUMN: Name of the replicated schema'
/
comment on column dba_reppriority.gname is
'Name of the replicated object group'
/
comment on column dba_reppriority.priority_group is
'Name of the priority group'
/
comment on column dba_reppriority.priority is
'Priority of the value'
/
comment on column dba_reppriority.data_type is
'Datatype of the value'
/
comment on column dba_reppriority.fixed_data_length is
'Length of the value in bytes if the datatype is CHAR'
/
comment on column dba_reppriority.raw_value is
'Raw value'
/
comment on column dba_reppriority.char_value is
'Blank-padded character string'
/
comment on column dba_reppriority.number_value is
'Numeric value'
/
comment on column dba_reppriority.date_value is
'Date value'
/
comment on column dba_reppriority.varchar2_value is
'Character string'
/
comment on column dba_reppriority.nchar_value is 
'NCHAR string'
/
comment on column dba_reppriority.nvarchar2_value is
'NVARCHAR2 string'
/
comment on column dba_reppriority.large_char_value is
'Blank-padded character string over 255 characters'
/
create or replace public synonym dba_reppriority for dba_reppriority
/
grant select on dba_reppriority to select_catalog_role
/


create or replace view all_reppriority
(
    sname, --- OBSOLETE
    priority_group,
    priority,
    data_type,
    fixed_data_length,
    char_value,
    varchar2_value,
    number_value,
    date_value,
    raw_value,
    gname,
    nchar_value,
    nvarchar2_value,
    large_char_value
)
as
select
    p.sname,
    p.priority_group,
    v.priority,
    decode(p.data_type_id,
           1, 'NUMBER',
           2, 'VARCHAR2',
           3, 'DATE',
           4, 'CHAR',
           5, 'RAW',
           6, 'NVARCHAR2',
           7, 'NCHAR',
           'UNDEFINED'),
    p.fixed_data_length,
    v.char_value,
    v.varchar2_value,
    v.number_value,
    v.date_value,
    v.raw_value,
    p.sname,
    v.nchar_value,
    v.nvarchar2_value,
    v.large_char_value
from  system.repcat$_priority v,
      system.repcat$_priority_group p
where v.sname = p.sname
and   v.priority_group = p.priority_group
/
comment on table all_reppriority is
'Values and their corresponding priorities in all priority groups which are accessible to the user'
/
comment on column all_reppriority.sname is
'OBSOLETE COLUMN: Name of the replicated schema'
/
comment on column all_reppriority.gname is
'Name of the replicated object group'
/
comment on column all_reppriority.priority_group is
'Name of the priority group'
/
comment on column all_reppriority.priority is
'Priority of the value'
/
comment on column all_reppriority.data_type is
'Datatype of the value'
/
comment on column all_reppriority.fixed_data_length is
'Length of the value in bytes if the datatype is CHAR'
/
comment on column all_reppriority.raw_value is
'Raw value'
/
comment on column all_reppriority.char_value is
'Blank-padded character string'
/
comment on column all_reppriority.number_value is
'Numeric value'
/
comment on column all_reppriority.date_value is
'Date value'
/
comment on column all_reppriority.varchar2_value is
'Character string'
/
comment on column all_reppriority.nchar_value is
'NCHAR string'
/
comment on column all_reppriority.nvarchar2_value is
'NVARCHAR2 string'
/
comment on column all_reppriority.large_char_value is
'Blank-padded character string over 255 characters'
/

create or replace public synonym all_reppriority for all_reppriority
/
grant select on all_reppriority to public with grant option
/


create or replace view user_reppriority
(
    priority_group,
    priority,
    data_type,
    fixed_data_length,
    char_value,
    varchar2_value,
    number_value,
    date_value,
    raw_value,
    nchar_value,
    nvarchar2_value,
    large_char_value
)
as
select
    p.priority_group,
    v.priority,
    decode(p.data_type_id,
           1, 'NUMBER',
           2, 'VARCHAR2',
           3, 'DATE',
           4, 'CHAR',
           5, 'RAW',
           6, 'NVARCHAR2',
           7, 'NCHAR',
           'UNDEFINED'),
    p.fixed_data_length,
    v.char_value,
    v.varchar2_value,
    v.number_value,
    v.date_value,
    v.raw_value,
    v.nchar_value,
    v.nvarchar2_value,
    v.large_char_value
from  system.repcat$_priority v,
      system.repcat$_priority_group p,
      sys.user$ u
where v.sname = u.name
and   p.sname = u.name
and   u.user# = userenv('SCHEMAID')
and   v.priority_group = p.priority_group
/
comment on table user_reppriority is
'Values and their corresponding priorities in user''s priority groups'
/
comment on column user_reppriority.priority_group is
'Name of the priority group'
/
comment on column user_reppriority.priority is
'Priority of the value'
/
comment on column user_reppriority.data_type is
'Datatype of the value'
/
comment on column user_reppriority.fixed_data_length is
'Length of the value in bytes if the datatype is CHAR'
/
comment on column user_reppriority.raw_value is
'Raw value'
/
comment on column user_reppriority.char_value is
'Blank-padded character string'
/
comment on column user_reppriority.number_value is
'Numeric value'
/
comment on column user_reppriority.date_value is
'Date value'
/
comment on column user_reppriority.varchar2_value is
'Character string'
/
comment on column user_reppriority.nchar_value is 
'NCHAR string'
/
comment on column user_reppriority.nvarchar2_value is
'NVARCHAR2 string'
/
comment on column user_reppriority.large_char_value is
'Blank-padded character string over 255 characters'
/
create or replace public synonym user_reppriority for user_reppriority
/
grant select on user_reppriority to public with grant option
/


create table system.repcat$_column_group
(
    sname                  varchar2(30)
                               constraint repcat$_column_group_nn1
                                 not null,
    oname                  varchar2(30)
                               constraint repcat$_column_group_nn2
                                 not null,
    group_name             varchar2(30)
                               constraint repcat$_column_group_nn3
                                 not null,
    group_comment          varchar2(80),
        constraint repcat$_column_group_pk
          primary key (sname, oname, group_name)
)
/
comment on table system.repcat$_column_group is
'All column groups of replicated tables in the database'
/
comment on column system.repcat$_column_group.sname is
'Owner of replicated object'
/
comment on column system.repcat$_column_group.oname is
'Name of the replicated object'
/
comment on column system.repcat$_column_group.group_name is
'Name of the column group'
/
comment on column system.repcat$_column_group.group_comment is
'Description of the column group'
/


create or replace view dba_repcolumn_group
(
    sname,
    oname,
    group_name,
    group_comment
)
as
select
    sname,
    oname,
    group_name,
    group_comment
from  system.repcat$_column_group
/
comment on table dba_repcolumn_group is
'All column groups of replicated tables in the database'
/
comment on column dba_repcolumn_group.sname is
'Owner of replicated object'
/
comment on column dba_repcolumn_group.oname is
'Name of the replicated object'
/
comment on column dba_repcolumn_group.group_name is
'Name of the column group'
/
comment on column dba_repcolumn_group.group_comment is
'Description of the column group'
/
create or replace public synonym dba_repcolumn_group for dba_repcolumn_group
/
grant select on dba_repcolumn_group to select_catalog_role
/


create or replace view all_repcolumn_group
(
    sname,
    oname,
    group_name,
    group_comment
)
as
select
    c.sname,
    c.oname,
    c.group_name,
    c.group_comment
from system.repcat$_column_group c, all_repobject o
  where c.sname = o.sname and c.oname = o.oname
    and o.type in ('TABLE', 'SNAPSHOT')
/
comment on table all_repcolumn_group is
'All column groups of replicated tables which are accessible to the user'
/
comment on column all_repcolumn_group.sname is
'Owner of replicated object'
/
comment on column all_repcolumn_group.oname is
'Name of the replicated object'
/
comment on column all_repcolumn_group.group_name is
'Name of the column group'
/
comment on column all_repcolumn_group.group_comment is
'Description of the column group'
/
create or replace public synonym all_repcolumn_group for all_repcolumn_group
/
grant select on all_repcolumn_group to public with grant option
/


create or replace view user_repcolumn_group
(
    oname,
    group_name,
    group_comment
)
as
select
    r.oname,
    r.group_name,
    r.group_comment
from  system.repcat$_column_group r, sys.user$ u
where r.sname = u.name
and   u.user# = userenv('SCHEMAID')
/
comment on table user_repcolumn_group is
'All column groups of user''s replicated tables'
/
comment on column user_repcolumn_group.oname is
'Name of the replicated object'
/
comment on column user_repcolumn_group.group_name is
'Name of the column group'
/
comment on column user_repcolumn_group.group_comment is
'Description of the column group'
/
create or replace public synonym user_repcolumn_group for user_repcolumn_group
/
grant select on user_repcolumn_group to public with grant option
/


create table system.repcat$_grouped_column
(
    sname                  varchar2(30),
    oname                  varchar2(30),
    group_name             varchar2(30),
    -- The POS for a row in this table may not
    -- be the column position for the column with COLUMN_NAME
    column_name            varchar2(30),
    pos                    number,
        constraint repcat$_grouped_column_pk
          primary key (sname, oname, group_name, column_name, pos),
        constraint repcat$_grouped_column_f1
          foreign key (sname, oname, group_name)
          references system.repcat$_column_group
)
/
create index system.repcat$_grouped_column_f1_idx on
  system.repcat$_grouped_column(sname, oname, group_name)
/

comment on table system.repcat$_grouped_column is
'Columns in all column groups of replicated tables in the database'
/
comment on column system.repcat$_grouped_column.sname is
'Owner of replicated object'
/
comment on column system.repcat$_grouped_column.oname is
'Name of the replicated object'
/
comment on column system.repcat$_grouped_column.group_name is
'Name of the column group'
/
comment on column system.repcat$_grouped_column.column_name is
'Name of the column in the column group'
/
comment on column system.repcat$_grouped_column.pos is
'Position of a column or an attribute in the table'
/


create or replace view dba_repgrouped_column
(
    sname,
    oname,
    group_name,
    column_name
)
as
select distinct
    gc.sname,
    gc.oname,
    gc.group_name,
    gc.column_name
from  system.repcat$_grouped_column gc
/
comment on table dba_repgrouped_column is
'Columns in the all column groups of replicated tables in the database'
/
comment on column dba_repgrouped_column.sname is
'Owner of replicated object'
/
comment on column dba_repgrouped_column.oname is
'Name of the replicated object'
/
comment on column dba_repgrouped_column.group_name is
'Name of the column group'
/
comment on column dba_repgrouped_column.column_name is
'Name of the column in the column group'
/
create or replace public synonym dba_repgrouped_column
   for dba_repgrouped_column
/
grant select on dba_repgrouped_column to select_catalog_role
/


create or replace view all_repgrouped_column
(
    sname,
    oname,
    group_name,
    column_name
)
as
select
    g.sname,
    g.oname,
    g.group_name,
    g.column_name
from all_tab_columns tc, sys.dba_repgrouped_column g
where g.sname = tc.owner
  and g.oname = tc.table_name
  and g.column_name = tc.column_name
union
select
    g.sname,
    g.oname,
    g.group_name,
    g.column_name
from "_ALL_REPL_NESTED_TABLE_NAMES" nt, sys.dba_repgrouped_column g
where g.sname = nt.owner
  and g.oname = nt.table_name
/
comment on table all_repgrouped_column is
'Columns in the all column groups of replicated tables which are accessible to the user'
/
comment on column all_repgrouped_column.sname is
'Owner of replicated object'
/
comment on column all_repgrouped_column.oname is
'Name of the replicated object'
/
comment on column all_repgrouped_column.group_name is
'Name of the column group'
/
comment on column all_repgrouped_column.column_name is
'Name of the column in the column group'
/
create or replace public synonym all_repgrouped_column
   for all_repgrouped_column
/
grant select on all_repgrouped_column to public with grant option
/


create or replace view user_repgrouped_column
(
  oname, group_name, column_name
)
as
select
    g.oname,
    g.group_name,
    g.column_name
from  user_tab_columns tc, sys.dba_repgrouped_column g, sys.user$ u
where g.sname = u.name
  and u.user# = userenv('SCHEMAID')
  and g.oname = tc.table_name
  and g.column_name = tc.column_name
union
select
    g.oname,
    g.group_name,
    g.column_name
from  "_USER_REPL_NESTED_TABLE_NAMES" nt, sys.dba_repgrouped_column g,
      sys.user$ u
where g.sname = u.name
  and u.user# = userenv('SCHEMAID')
  and g.oname = nt.table_name
/
comment on table user_repgrouped_column is
'Columns in the all column groups of user''s replicated tables'
/
comment on column user_repgrouped_column.oname is
'Name of the replicated object'
/
comment on column user_repgrouped_column.group_name is
'Name of the column group'
/
comment on column user_repgrouped_column.column_name is
'Name of the column in the column group'
/
create or replace public synonym user_repgrouped_column
   for user_repgrouped_column
/
grant select on user_repgrouped_column to public with grant option
/

-- This view is for internal use only and may change without notice.
REM For the remote acess of POS in repcat$_grouped_column,
REM "_ALL_REPGROUPED_COLUMN" is added.
REM This view is for internal use only and may change without notice.
create or replace view "_ALL_REPGROUPED_COLUMN"
(
  sname, oname, group_name, column_name, pos
)
as
select
  gc.sname, gc.oname, gc.group_name,
  gc.column_name,
  gc.pos
from all_tab_columns tc, system.repcat$_grouped_column gc
where gc.sname = tc.owner
  and gc.oname = tc.table_name
  and (gc.column_name = tc.column_name OR
       (gc.column_name = 'SYS_NC_OID$' AND
        -- sOID column
        exists (select 1 from system.repcat$_repcolumn rc
                  where rc.sname = gc.sname
                    and rc.oname = gc.oname
                    and rc.cname = 'SYS_NC_OID$'
                    and utl_raw.bit_and(utl_raw.substr(rc.property, 1, 1),
                          '10') = '10')))
union
select
  gc.sname, gc.oname, gc.group_name,
  gc.column_name,
  gc.pos
from "_ALL_REPL_NESTED_TABLE_NAMES" nt, system.repcat$_grouped_column gc
where gc.sname = nt.owner
  and gc.oname = nt.table_name
/

comment on table "_ALL_REPGROUPED_COLUMN" is
'Columns in the all column groups of replicated tables which are accessible to the user'
/
comment on column "_ALL_REPGROUPED_COLUMN".sname is
'Owner of replicated object'
/
comment on column "_ALL_REPGROUPED_COLUMN".oname is
'Name of the replicated object'
/
comment on column "_ALL_REPGROUPED_COLUMN".group_name is
'Name of the column group'
/
comment on column "_ALL_REPGROUPED_COLUMN".column_name is
'Name of the column in the column group'
/
comment on column "_ALL_REPGROUPED_COLUMN".pos is
'Position of the column in the table'
/
grant select on "_ALL_REPGROUPED_COLUMN" to public with grant option
/

-- This view is for internal use only and may change without notice.
-- A column group is selected if at least one column in the column
-- group is present in this database
create or replace view "_ALL_REPCOLUMN_GROUP"
  (sname, oname, group_name, group_comment) as
select /*+ ALL_ROWS */ distinct cg.sname, cg.oname, cg.group_name,
 cg.group_comment
  from all_repcolumn_group cg, "_ALL_REPGROUPED_COLUMN" rcgcol
 where cg.group_name = rcgcol.group_name
      and cg.sname = rcgcol.sname
      and cg.oname = rcgcol.oname
 /
comment on table "_ALL_REPCOLUMN_GROUP" is
'All column groups of replicated tables which are accessible to the user'
/
comment on column "_ALL_REPCOLUMN_GROUP".sname is
'Owner of replicated object'
/
comment on column "_ALL_REPCOLUMN_GROUP".oname is
'Name of the replicated object'
/
comment on column "_ALL_REPCOLUMN_GROUP".group_name is
'Name of the column group'
/
comment on column "_ALL_REPCOLUMN_GROUP".group_comment is
'Description of the column group'
/
grant select on "_ALL_REPCOLUMN_GROUP" to PUBLIC with grant option
/


create table system.repcat$_conflict
(
    sname                  varchar2(30),
    oname                  varchar2(30),
    conflict_type_id       integer
                               constraint repcat$_conflict_c1
                                 check (conflict_type_id in (1, 2, 3)),
    reference_name         varchar2(30),
        constraint repcat$_conflict_pk
          primary key (sname,
                       oname,
                       conflict_type_id,
                       reference_name)
)
/
comment on table system.repcat$_conflict is
'All conflicts for which users have specified resolutions in the database'
/
comment on column system.repcat$_conflict.sname is
'Owner of replicated object'
/
comment on column system.repcat$_conflict.oname is
'Name of the replicated object'
/
comment on column system.repcat$_conflict.conflict_type_id is
'Type of conflict'
/
comment on column system.repcat$_conflict.reference_name is
'Table name, unique constraint name, or column group name'
/


create or replace view dba_repconflict
(
    sname,
    oname,
    conflict_type,
    reference_name
)
as
select
    sname,
    oname,
    decode(conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    reference_name
from  system.repcat$_conflict
/
comment on table dba_repconflict is
'All conflicts for which users have specified resolutions in the database'
/
comment on column dba_repconflict.sname is
'Owner of replicated object'
/
comment on column dba_repconflict.oname is
'Name of the replicated object'
/
comment on column dba_repconflict.conflict_type is
'Type of conflict'
/
comment on column dba_repconflict.reference_name is
'Table name, unique constraint name, or column group name'
/
create or replace public synonym dba_repconflict for dba_repconflict
/
grant select on dba_repconflict to select_catalog_role
/


create or replace view all_repconflict
(
    sname,
    oname,
    conflict_type,
    reference_name
)
as
select
    sname,
    oname,
    decode(conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    reference_name
from  system.repcat$_conflict,
      sys.user$ u, sys.obj$ o
where sname = u.name
  and oname = o.name
  and o.owner# = u.user#
  and o.type# = 2 /* tables */
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                   from objauth$
                   where grantee# in ( select kzsrorol
                                       from x$kzsro
                                     )
                  )
        or
  exists (select null from v$enabledprivs
          where priv_number in (-45 /* LOCK ANY TABLE */,
           -47 /* SELECT ANY TABLE */,
           -48 /* INSERT ANY TABLE */,
           -49 /* UPDATE ANY TABLE */,
           -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table all_repconflict is
'All conflicts with available resolutions for replicated tables which are accessible to the user'
/
comment on column all_repconflict.sname is
'Owner of replicated object'
/
comment on column all_repconflict.oname is
'Name of the replicated object'
/
comment on column all_repconflict.conflict_type is
'Type of conflict'
/
comment on column all_repconflict.reference_name is
'Table name, unique constraint name, or column group name'
/
create or replace public synonym all_repconflict for all_repconflict
/
grant select on all_repconflict to public with grant option
/


create or replace view user_repconflict
(
    oname,
    conflict_type,
    reference_name
)
as
select
    r.oname,
    decode(r.conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    r.reference_name
from  system.repcat$_conflict r, user$ u
where r.sname = u.name
and   u.user# = userenv('SCHEMAID')
/
comment on table all_repconflict is
'All conflicts with available resolutions for user''s replicated tables'
/
comment on column all_repconflict.oname is
'Name of the replicated object'
/
comment on column all_repconflict.conflict_type is
'Type of conflict'
/
comment on column all_repconflict.reference_name is
'Table name, unique constraint name, or column group name'
/
create or replace public synonym user_repconflict for user_repconflict
/
grant select on user_repconflict to public with grant option
/


create table system.repcat$_resolution_method
(
    conflict_type_id       integer,
    method_name            varchar2(80),
        constraint repcat$_resol_method_pk
          primary key (conflict_type_id, method_name)
)
/
comment on table system.repcat$_resolution_method is
'All conflict resolution methods in the database'
/
comment on column system.repcat$_resolution_method.conflict_type_id is
'Type of conflict'
/
comment on column system.repcat$_resolution_method.method_name is
'Name of the conflict resolution method'
/

create or replace view dba_represolution_method
(
    conflict_type,
    method_name
)
as
select
    decode(conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    method_name
from  system.repcat$_resolution_method
/
comment on table dba_represolution_method is
'All conflict resolution methods in the database'
/
comment on column dba_represolution_method.conflict_type is
'Type of conflict'
/
comment on column dba_represolution_method.method_name is
'Name of the conflict resolution method'
/
create or replace public synonym dba_represolution_method
   for dba_represolution_method
/
grant select on dba_represolution_method to select_catalog_role
/


create or replace view all_represolution_method
(
    conflict_type,
    method_name
)
as
select
    decode(conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    method_name
from  system.repcat$_resolution_method
/
comment on table all_represolution_method is
'All conflict resolution methods accessible to the user'
/
comment on column all_represolution_method.conflict_type is
'Type of conflict'
/
comment on column all_represolution_method.method_name is
'Name of the conflict resolution method'
/
create or replace public synonym all_represolution_method
   for all_represolution_method
/
grant select on all_represolution_method to public with grant option
/


create or replace view user_represolution_method
(
    conflict_type,
    method_name
)
as
select
    decode(conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    method_name
from  system.repcat$_resolution_method
/
comment on table user_represolution_method is
'All conflict resolution methods accessible to the user'
/
comment on column user_represolution_method.conflict_type is
'Type of conflict'
/
comment on column user_represolution_method.method_name is
'Name of the conflict resolution method'
/
create or replace public synonym user_represolution_method
   for user_represolution_method
/
grant select on user_represolution_method to public with grant option
/


create table system.repcat$_resolution
(
    sname                  varchar2(30),
    oname                  varchar2(30),
    conflict_type_id       integer,
    reference_name         varchar2(30),
    sequence_no            number,
    method_name            varchar2(80)
                               constraint repcat$_resolution_nn1
                                 not null,
    function_name          varchar2(92)
                               constraint repcat$_resolution_nn2
                                 not null,
    priority_group         varchar2(30),
    resolution_comment     varchar2(80),
        constraint repcat$_resolution_pk
          primary key (sname,
                       oname,
                       conflict_type_id,
                       reference_name,
                       sequence_no),
        constraint repcat$_resolution_f1
          foreign key (conflict_type_id,
                       method_name)
          references system.repcat$_resolution_method,
        constraint repcat$_resolution_f3
          foreign key (sname,
                       oname,
                       conflict_type_id,
                       reference_name)
          references system.repcat$_conflict
)
/
create index system.repcat$_resolution_f3_idx on
  system.repcat$_resolution(conflict_type_id, method_name)
/

CREATE INDEX system.repcat$_resolution_idx2 ON
  system.repcat$_resolution(sname, oname, conflict_type_id, reference_name)
/

comment on table system.repcat$_resolution is
'Description of all conflict resolutions in the database'
/
comment on column system.repcat$_resolution.sname is
'Owner of replicated object'
/
comment on column system.repcat$_resolution.oname is
'Name of the replicated object'
/
comment on column system.repcat$_resolution.conflict_type_id is
'Type of conflict'
/
comment on column system.repcat$_resolution.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column system.repcat$_resolution.sequence_no is
'Ordering on resolution'
/
comment on column system.repcat$_resolution.method_name is
'Name of the conflict resolution method'
/
comment on column system.repcat$_resolution.function_name is
'Name of the resolution function'
/
comment on column system.repcat$_resolution.priority_group is
'Name of the priority group used in conflict resolution'
/
comment on column system.repcat$_resolution.resolution_comment is
'Description of the conflict resolution'
/

create or replace view dba_represolution
(
    sname,
    oname,
    conflict_type,
    reference_name,
    sequence_no,
    method_name,
    function_name,
    priority_group,
    resolution_comment
)
as
select
    sname,
    oname,
    decode(conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    reference_name,
    sequence_no,
    method_name,
    function_name,
    priority_group,
    resolution_comment
from  system.repcat$_resolution
/
comment on table dba_represolution is
'Description of all conflict resolutions in the database'
/
comment on column dba_represolution.sname is
'Owner of replicated object'
/
comment on column dba_represolution.oname is
'Name of the replicated object'
/
comment on column dba_represolution.conflict_type is
'Type of conflict'
/
comment on column dba_represolution.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column dba_represolution.sequence_no is
'Ordering on resolution'
/
comment on column dba_represolution.method_name is
'Name of the conflict resolution method'
/
comment on column dba_represolution.function_name is
'Name of the resolution function'
/
comment on column dba_represolution.priority_group is
'Name of the priority group used in conflict resolution'
/
comment on column dba_represolution.resolution_comment is
'Description of the conflict resolution'
/
create or replace public synonym dba_represolution for dba_represolution
/
grant select on dba_represolution to select_catalog_role
/


create or replace view all_represolution
(
    sname,
    oname,
    conflict_type,
    reference_name,
    sequence_no,
    method_name,
    function_name,
    priority_group,
    resolution_comment
)
as
select
    sname,
    oname,
    decode(conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    reference_name,
    sequence_no,
    method_name,
    function_name,
    priority_group,
    resolution_comment
from  system.repcat$_resolution,
      sys.user$ u, sys.obj$ o
where sname = u.name
  and oname = o.name
  and o.owner# = u.user#
  and o.type# = 2 /* tables */
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                   from objauth$
                   where grantee# in ( select kzsrorol
                                       from x$kzsro
                                     )
                  )
        or
  exists (select null from v$enabledprivs
          where priv_number in (-45 /* LOCK ANY TABLE */,
           -47 /* SELECT ANY TABLE */,
           -48 /* INSERT ANY TABLE */,
           -49 /* UPDATE ANY TABLE */,
           -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table all_represolution is
'Description of all conflict resolutions for replicated tables which are accessible to the user'
/
comment on column all_represolution.sname is
'Owner of replicated object'
/
comment on column all_represolution.oname is
'Name of the replicated object'
/
comment on column all_represolution.conflict_type is
'Type of conflict'
/
comment on column all_represolution.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column all_represolution.sequence_no is
'Ordering on resolution'
/
comment on column all_represolution.method_name is
'Name of the conflict resolution method'
/
comment on column all_represolution.function_name is
'Name of the resolution function'
/
comment on column all_represolution.priority_group is
'Name of the priority group used in conflict resolution'
/
comment on column all_represolution.resolution_comment is
'Description of the conflict resolution'
/
create or replace public synonym all_represolution for all_represolution
/
grant select on all_represolution to public with grant option
/


create or replace view user_represolution
(
    oname,
    conflict_type,
    reference_name,
    sequence_no,
    method_name,
    function_name,
    priority_group,
    resolution_comment
)
as
select
    r.oname,
    decode(r.conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    r.reference_name,
    r.sequence_no,
    r.method_name,
    r.function_name,
    r.priority_group,
    r.resolution_comment
from  system.repcat$_resolution r, sys.user$ u
where r.sname = u.name
and   u.user# = userenv('SCHEMAID')
/
comment on table user_represolution is
'Description of all conflict resolutions for user''s replicated tables'
/
comment on column user_represolution.oname is
'Name of the replicated object'
/
comment on column user_represolution.conflict_type is
'Type of conflict'
/
comment on column user_represolution.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column user_represolution.sequence_no is
'Ordering on resolution'
/
comment on column user_represolution.method_name is
'Name of the conflict resolution method'
/
comment on column user_represolution.function_name is
'Name of the resolution function'
/
comment on column user_represolution.priority_group is
'Name of the priority group used in conflict resolution'
/
comment on column user_represolution.resolution_comment is
'Description of the conflict resolution'
/
create or replace public synonym user_represolution for user_represolution
/
grant select on user_represolution to public with grant option
/

-- This view is for internal use only and may change without notice.
-- o. Since the constraint information is not pulled over to the mview
--    site, it is not possible to find the columns with unique constraints
--    and then pull the UNIQUENESS conflict information from the master site.
--    Instead we pull all the UNIQUENESS conflict resolution information
--    down to the mview site for all flavors. This will not cause any
--    issues because there is no constraint information at mview site.
--
-- o. Since DELETE conflict involves the whole row, pull down the info
--    for DELETE conflict resolution down to the local site for all
--    flavors.
--
-- o. For UPDATE conflict resolution, pull down only the relevant 
--    information for the column groups with columns in the flavor
--    at the local site.
--
create or replace view "_ALL_REPRESOLUTION" (
        sname,
        oname,
        conflict_type,
        reference_name,
        sequence_no,
        method_name,
        function_name,
        priority_group,
        resolution_comment,
        conflict_type_id
) as
select  sname,
        oname,
        conflict_type,
        reference_name,
        sequence_no,
        method_name,
        function_name,
        priority_group,
        resolution_comment,
        decode(conflict_type,
               'UPDATE',1,
               'UNIQUENESS',2,
               'DELETE',3,
               -1)
  from all_represolution
 where conflict_type in ('UNIQUENESS', 'DELETE', 'UNDEFINED')
union
select  /*+ ALL_ROWS */ resol.sname,
        resol.oname,
        resol.conflict_type,
        resol.reference_name,
        resol.sequence_no,
        resol.method_name,
        resol.function_name,
        resol.priority_group,
        resol.resolution_comment,
        decode(resol.conflict_type,
               'UPDATE',1,
               'UNIQUENESS',2,
               'DELETE',3,
               -1)
  from all_represolution resol, "_ALL_REPCOLUMN_GROUP" rg
 where conflict_type = 'UPDATE'
   and resol.reference_name = rg.group_name
   and resol.sname = rg.sname
   and resol.oname = rg.oname
/
comment on table "_ALL_REPRESOLUTION" is
'Description of all conflict resolutions for replicated tables which are accessible to the user'
/
comment on column "_ALL_REPRESOLUTION".sname is
'Owner of replicated object'
/
comment on column "_ALL_REPRESOLUTION".oname is
'Name of the replicated object'
/
comment on column "_ALL_REPRESOLUTION".conflict_type is
'Type of conflict'
/
comment on column "_ALL_REPRESOLUTION".reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column "_ALL_REPRESOLUTION".sequence_no is
'Ordering on resolution'
/
comment on column "_ALL_REPRESOLUTION".method_name is
'Name of the conflict resolution method'
/
comment on column "_ALL_REPRESOLUTION".function_name is
'Name of the resolution function'
/
comment on column "_ALL_REPRESOLUTION".priority_group is
'Name of the priority group used in conflict resolution'
/
comment on column "_ALL_REPRESOLUTION".resolution_comment is
'Description of the conflict resolution'
/
comment on column "_ALL_REPRESOLUTION".conflict_type_id  is
'Internal id for the conflict type.'
/
grant select on "_ALL_REPRESOLUTION" to public with grant option
/

create table system.repcat$_resolution_statistics
(
    sname                  varchar2(30)
                               constraint repcat$_resolution_stats_nn1
                                 not null,
    oname                  varchar2(30)
                               constraint repcat$_resolution_stats_nn2
                                 not null,
    conflict_type_id       integer
                               constraint repcat$_resolution_stats_nn3
                                 not null,
    reference_name         varchar2(30)
                               constraint repcat$_resolution_stats_nn4
                                 not null,
    method_name            varchar2(80)
                               constraint repcat$_resolution_stats_nn5
                                 not null,
    function_name          varchar2(92)
                               constraint repcat$_resolution_stats_nn6
                                 not null,
    priority_group         varchar2(30),
    resolved_date          date
                               constraint repcat$_resolution_stats_nn7
                                 not null,
    primary_key_value      varchar2(2000)
                               constraint repcat$_resolution_stats_nn8
                                 not null
)
/
comment on table system.repcat$_resolution_statistics is
'Statistics for conflict resolutions for all replicated tables in the database'
/
comment on column system.repcat$_resolution_statistics.sname is
'Owner of replicated object'
/
comment on column system.repcat$_resolution_statistics.oname is
'Name of the replicated object'
/
comment on column system.repcat$_resolution_statistics.conflict_type_id is
'Type of conflict'
/
comment on column system.repcat$_resolution_statistics.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column system.repcat$_resolution_statistics.method_name is
'Name of the conflict resolution method'
/
comment on column system.repcat$_resolution_statistics.function_name is
'Name of the resolution function'
/
comment on column system.repcat$_resolution_statistics.priority_group is
'Name of the priority group used in conflict resolution'
/
comment on column system.repcat$_resolution_statistics.resolved_date is
'Timestamp for the resolution of the conflict'
/
comment on column system.repcat$_resolution_statistics.primary_key_value is
'Primary key of the replicated row (character data)'
/


create or replace view dba_represolution_statistics (
    sname,
    oname,
    conflict_type,
    reference_name,
    method_name,
    function_name,
    priority_group,
    resolved_date,
    primary_key_value
)
as
select
    sname,
    oname,
    decode(conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    reference_name,
    method_name,
    decode(method_name,
           'USER FUNCTION', function_name,
           'USER FLAVOR FUNCTION', function_name,
           NULL),
    priority_group,
    resolved_date,
    primary_key_value
from  system.repcat$_resolution_statistics
/
comment on table dba_represolution_statistics is
'Statistics for conflict resolutions for all replicated tables in the database'
/
comment on column dba_represolution_statistics.sname is
'Owner of replicated object'
/
comment on column dba_represolution_statistics.oname is
'Name of the replicated object'
/
comment on column dba_represolution_statistics.conflict_type is
'Type of conflict'
/
comment on column dba_represolution_statistics.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column dba_represolution_statistics.method_name is
'Name of the conflict resolution method'
/
comment on column dba_represolution_statistics.function_name is
'Name of the resolution function'
/
comment on column dba_represolution_statistics.priority_group is
'Name of the priority group used in conflict resolution'
/
comment on column dba_represolution_statistics.resolved_date is
'Timestamp for the resolution of the conflict'
/
comment on column dba_represolution_statistics.primary_key_value is
'Primary key of the replicated row (character data)'
/
create or replace public synonym dba_represolution_statistics for 
  dba_represolution_statistics
/
grant select on dba_represolution_statistics to select_catalog_role
/


create or replace view all_represolution_statistics
(
    sname,
    oname,
    conflict_type,
    reference_name,
    method_name,
    function_name,
    priority_group,
    resolved_date,
    primary_key_value
)
as
select
    sname,
    oname,
    decode(conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    reference_name,
    method_name,
    decode(method_name,
           'USER FUNCTION', function_name,
           'USER FLAVOR FUNCTION', function_name,
           NULL),
    priority_group,
    resolved_date,
    primary_key_value
from  system.repcat$_resolution_statistics,
      sys.user$ u, sys.obj$ o
where sname = u.name
  and oname = o.name
  and o.owner# = u.user#
  and o.type# = 2 /* tables */
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                   from objauth$
                   where grantee# in ( select kzsrorol
                                       from x$kzsro
                                     )
                  )
        or
  exists (select null from v$enabledprivs
          where priv_number in (-45 /* LOCK ANY TABLE */,
           -47 /* SELECT ANY TABLE */,
           -48 /* INSERT ANY TABLE */,
           -49 /* UPDATE ANY TABLE */,
           -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table all_represolution_statistics is
'Statistics for conflict resolutions for replicated tables which are accessible to the user'
/
comment on column all_represolution_statistics.sname is
'Owner of replicated object'
/
comment on column all_represolution_statistics.oname is
'Name of the replicated object'
/
comment on column all_represolution_statistics.conflict_type is
'Type of conflict'
/
comment on column all_represolution_statistics.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column all_represolution_statistics.method_name is
'Name of the conflict resolution method'
/
comment on column all_represolution_statistics.function_name is
'Name of the resolution function'
/
comment on column all_represolution_statistics.priority_group is
'Name of the priority group used in conflict resolution'
/
comment on column all_represolution_statistics.resolved_date is
'Timestamp for the resolution of the conflict'
/
comment on column all_represolution_statistics.primary_key_value is
'Primary key of the replicated row (character data)'
/
create or replace public synonym all_represolution_statistics for
  all_represolution_statistics
/
grant select on all_represolution_statistics to public with grant option
/


create or replace view user_represolution_statistics
(
    oname,
    conflict_type,
    reference_name,
    method_name,
    function_name,
    priority_group,
    resolved_date,
    primary_key_value
)
as
select
    r.oname,
    decode(r.conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    r.reference_name,
    r.method_name,
    decode(r.method_name,
           'USER FUNCTION', r.function_name,
           'USER FLAVOR FUNCTION', r.function_name,
           NULL),
    r.priority_group,
    r.resolved_date,
    r.primary_key_value
from  system.repcat$_resolution_statistics r, sys.user$ u
where r.sname = u.name
and   u.user# = userenv('SCHEMAID')
/
comment on table user_represolution_statistics is
'Statistics for conflict resolutions for user''s replicated tables'
/
comment on column user_represolution_statistics.oname is
'Name of the replicated object'
/
comment on column user_represolution_statistics.conflict_type is
'Type of conflict'
/
comment on column user_represolution_statistics.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column user_represolution_statistics.method_name is
'Name of the conflict resolution method'
/
comment on column user_represolution_statistics.function_name is
'Name of the resolution function'
/
comment on column user_represolution_statistics.priority_group is
'Name of the priority group used in conflict resolution'
/
comment on column user_represolution_statistics.resolved_date is
'Timestamp for the resolution of the conflict'
/
comment on column user_represolution_statistics.primary_key_value is
'Primary key of the replicated row (character data)'
/
create or replace public synonym user_represolution_statistics for
  user_represolution_statistics
/
grant select on user_represolution_statistics to public with grant option
/
CREATE INDEX system.repcat$_resolution_stats_n1 on
  system.repcat$_resolution_statistics
  (
   sname,
   oname,
   resolved_date,
   conflict_type_id,
   reference_name,
   method_name,
   function_name,
   priority_group
  )
/


create table system.repcat$_resol_stats_control
(
    sname                  varchar2(30),
    oname                  varchar2(30),
    created                date
                               constraint repcat$_resol_stats_ctrl_nn1
                                 not null,
    status                 integer
                               constraint repcat$_resol_stats_ctrl_nn2
                                 not null,
    status_update_date     date
                               constraint repcat$_resol_stats_ctrl_nn3
                                 not null,
    purged_date             date,
    last_purge_start_date   date,
    last_purge_end_date     date,
        constraint repcat$_resol_stats_ctrl_pk
          primary key (sname,
                       oname)
)
/
comment on table system.repcat$_resol_stats_control is
'Information about statistics collection for conflict resolutions for all replicated tables in the database'
/
comment on column system.repcat$_resol_stats_control.sname is
'Owner of replicated object'
/
comment on column system.repcat$_resol_stats_control.oname is
'Name of the replicated object'
/
comment on column system.repcat$_resol_stats_control.created is
'Timestamp for which statistics collection was first started'
/
comment on column system.repcat$_resol_stats_control.status is
'Status of statistics collection: ACTIVE, CANCELLED'
/
comment on column system.repcat$_resol_stats_control.status_update_date is
'Timestamp for which the status was last updated'
/
comment on column system.repcat$_resol_stats_control.purged_date is
'Timestamp for the last purge of statistics data'
/
comment on column system.repcat$_resol_stats_control.last_purge_start_date is
'The last start date of the statistics purging date range'
/
comment on column system.repcat$_resol_stats_control.last_purge_end_date is
'The last end date of the statistics purging date range'
/


create or replace view dba_represol_stats_control
(
    sname,
    oname,
    created,
    status,
    status_update_date,
    purged_date,
    last_purge_start_date,
    last_purge_end_date
)
as
select
    sname,
    oname,
    created,
    decode(status,
           1, 'ACTIVE',
           2, 'CANCELLED',
           'UNDEFINED'),
    status_update_date,
    purged_date,
    last_purge_start_date,
    last_purge_end_date
from  system.repcat$_resol_stats_control
/
comment on table dba_represol_stats_control is
'Information about statistics collection for conflict resolutions for all replicated tables in the database'
/
comment on column dba_represol_stats_control.sname is
'Owner of replicated object'
/
comment on column dba_represol_stats_control.oname is
'Name of the replicated object'
/
comment on column dba_represol_stats_control.created is
'Timestamp for which statistics collection was first started'
/
comment on column dba_represol_stats_control.status is
'Status of statistics collection: ACTIVE, CANCELLED'
/
comment on column dba_represol_stats_control.status_update_date is
'Timestamp for which the status was last updated'
/
comment on column dba_represol_stats_control.purged_date is
'Timestamp for the last purge of statistics data'
/
comment on column dba_represol_stats_control.last_purge_start_date is
'The last start date of the statistics purging date range'
/
comment on column dba_represol_stats_control.last_purge_end_date is
'The last end date of the statistics purging date range'
/
create or replace public synonym dba_represol_stats_control
   for dba_represol_stats_control
/
grant select on dba_represol_stats_control to select_catalog_role
/


create or replace view all_represol_stats_control
(
    sname,
    oname,
    created,
    status,
    status_update_date,
    purged_date,
    last_purge_start_date,
    last_purge_end_date
)
as
select
    c.sname,
    c.oname,
    c.created,
    decode(c.status,
           1, 'ACTIVE',
           2, 'CANCELLED',
           'UNDEFINED'),
    c.status_update_date,
    c.purged_date,
    c.last_purge_start_date,
    c.last_purge_end_date
from  system.repcat$_resol_stats_control c,
      sys.user$ u, sys.obj$ o
where c.sname = u.name
  and c.oname = o.name
  and o.owner# = u.user#
  and o.type# = 2 /* tables */
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                   from objauth$
                   where grantee# in ( select kzsrorol
                                       from x$kzsro
                                     )
                  )
        or
  exists (select null from v$enabledprivs
          where priv_number in (-45 /* LOCK ANY TABLE */,
           -47 /* SELECT ANY TABLE */,
           -48 /* INSERT ANY TABLE */,
           -49 /* UPDATE ANY TABLE */,
           -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table all_represol_stats_control is
'Information about statistics collection for conflict resolutions for replicated tables which are accessible to the user'
/
comment on column all_represol_stats_control.sname is
'Owner of replicated object'
/
comment on column all_represol_stats_control.oname is
'Name of the replicated object'
/
comment on column all_represol_stats_control.created is
'Timestamp for which statistics collection was first started'
/
comment on column all_represol_stats_control.status is
'Status of statistics collection: ACTIVE, CANCELLED'
/
comment on column all_represol_stats_control.status_update_date is
'Timestamp for which the status was last updated'
/
comment on column all_represol_stats_control.purged_date is
'Timestamp for the last purge of statistics data'
/
comment on column all_represol_stats_control.last_purge_start_date is
'The last start date of the statistics purging date range'
/
comment on column all_represol_stats_control.last_purge_end_date is
'The last end date of the statistics purging date range'
/
create or replace public synonym all_represol_stats_control for
  all_represol_stats_control
/
grant select on all_represol_stats_control to public with grant option
/


create or replace view user_represol_stats_control
(
    oname,
    created,
    status,
    status_update_date,
    purged_date,
    last_purge_start_date,
    last_purge_end_date
)
as
select
    r.oname,
    r.created,
    decode(r.status,
           1, 'ACTIVE',
           2, 'CANCELLED',
           'UNDEFINED'),
    r.status_update_date,
    r.purged_date,
    r.last_purge_start_date,
    r.last_purge_end_date
from  system.repcat$_resol_stats_control r, sys.user$ u
where r.sname = u.name
and   u.user# = userenv('SCHEMAID')
/
comment on table user_represol_stats_control is
'Information about statistics collection for conflict resolutions for user''s replicated tables'
/
comment on column user_represol_stats_control.oname is
'Name of the replicated object'
/
comment on column user_represol_stats_control.created is
'Timestamp for which statistics collection was first started'
/
comment on column user_represol_stats_control.status is
'Status of statistics collection: ACTIVE, CANCELLED'
/
comment on column user_represol_stats_control.status_update_date is
'Timestamp for which the status was last updated'
/
comment on column user_represol_stats_control.purged_date is
'Timestamp for the last purge of statistics data'
/
comment on column user_represol_stats_control.last_purge_start_date is
'The last start date of the statistics purging date range'
/
comment on column user_represol_stats_control.last_purge_end_date is
'The last end date of the statistics purging date range'
/
create or replace public synonym user_represol_stats_control for
  user_represol_stats_control
/
grant select on user_represol_stats_control to public with grant option
/


create table system.repcat$_parameter_column
(
    sname                  varchar2(30),
    oname                  varchar2(30),
    conflict_type_id       integer,
    reference_name         varchar2(30),
    sequence_no            number,
    parameter_table_name   varchar2(30),
    parameter_column_name  varchar2(4000),
    parameter_sequence_no  number,
    -- COLUMN_POS refers to repcat$_repcolumn.pos.
    column_pos   number,
    -- ATTRIBUTE_SEQUENCE_NO indicates the relative ordering of
    -- an attribute in its long column. For an ADT column,
    -- ATTRIBUTE_SEQUENCE_NO reflects the canonical order of
    -- the ADT definition.
    attribute_sequence_no  number,
        constraint repcat$_parameter_column_pk
          primary key (sname,
                       oname,
                       conflict_type_id,
                       reference_name,
                       sequence_no,
                       parameter_table_name,
                       parameter_sequence_no,
                       column_pos),
        constraint repcat$_parameter_column_f1
          foreign key (sname,
                       oname,
                       conflict_type_id,
                       reference_name,
                       sequence_no)
          references system.repcat$_resolution
)
/
create index system.repcat$_parameter_column_f1_i on
  system.repcat$_parameter_column(sname, oname, conflict_type_id,
                                  reference_name, sequence_no)
/

comment on table system.repcat$_parameter_column is
'All columns used for resolving conflicts in the database'
/
comment on column system.repcat$_parameter_column.sname is
'Owner of replicated object'
/
comment on column system.repcat$_parameter_column.oname is
'Name of the replicated object'
/
comment on column system.repcat$_parameter_column.conflict_type_id is
'Type of conflict'
/
comment on column system.repcat$_parameter_column.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column system.repcat$_parameter_column.sequence_no is
'Ordering on resolution'
/
comment on column system.repcat$_parameter_column.parameter_table_name is
'Name of the table to which the parameter column belongs'
/
comment on column system.repcat$_parameter_column.parameter_column_name is
'Name of the parameter column used for resolving the conflict'
/
comment on column system.repcat$_parameter_column.parameter_sequence_no is
'Ordering on parameter column'
/
comment on column system.repcat$_parameter_column.column_pos is
'Column position of an attribute or a column'
/
comment on column system.repcat$_parameter_column.attribute_sequence_no is
'Sequence number for an attribute of an ADT/pkREF column or a scalar column'
/

create or replace view dba_repparameter_column
(
    sname,
    oname,
    conflict_type,
    reference_name,
    sequence_no,
    method_name,
    function_name,
    priority_group,
    parameter_table_name,
    parameter_column_name,
    parameter_sequence_no
)
as
select
    p.sname,
    p.oname,
    decode(p.conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    p.reference_name,
    p.sequence_no,
    r.method_name,
    r.function_name,
    r.priority_group,
    p.parameter_table_name,
    decode(method_name, 'USER FUNCTION', NVL(rc.top, rc.lcname),
                        'USER FLAVOR FUNCTION', NVL(rc.top, rc.lcname),
           rc.lcname),
    p.parameter_sequence_no
from  system.repcat$_parameter_column p,
      system.repcat$_resolution r,
      system.repcat$_repcolumn rc
where p.sname = r.sname
and   p.oname = r.oname
and   p.conflict_type_id = r.conflict_type_id
and   p.reference_name = r.reference_name
and   p.sequence_no = r.sequence_no
and   p.oname = p.parameter_table_name
and   p.attribute_sequence_no = 1
and   p.sname = rc.sname
and   p.oname = rc.oname
and   p.column_pos = rc.pos
/
comment on table dba_repparameter_column is
'All columns used for resolving conflicts in the database'
/
comment on column dba_repparameter_column.sname is
'Owner of replicated object'
/
comment on column dba_repparameter_column.oname is
'Name of the replicated object'
/
comment on column dba_repparameter_column.conflict_type is
'Type of conflict'
/
comment on column dba_repparameter_column.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column dba_repparameter_column.sequence_no is
'Ordering on resolution'
/
comment on column dba_repparameter_column.parameter_table_name is
'Name of the table to which the parameter column belongs'
/
comment on column dba_repparameter_column.parameter_column_name is
'Name of the parameter column used for resolving the conflict'
/
comment on column dba_repparameter_column.parameter_sequence_no is
'Ordering on parameter column'
/
create or replace public synonym dba_repparameter_column
   for dba_repparameter_column
/
grant select on dba_repparameter_column to select_catalog_role
/

REM For the remote acess of attribute_sequence_no in repcat$_grouped_column,
REM "_ALL_REPPARAMETER_COLUMN" is added.
REM This view is for internal use only and may change without notice.
create or replace view "_ALL_REPPARAMETER_COLUMN"
(
    sname,
    oname,
    conflict_type,
    reference_name,
    sequence_no,
    method_name,
    function_name,
    priority_group,
    parameter_table_name,
    parameter_column_name,
    parameter_sequence_no,
    column_pos,
    attribute_sequence_no
)
as
select
    p.sname,
    p.oname,
    decode(p.conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    p.reference_name,
    p.sequence_no,
    r.method_name,
    r.function_name,
    r.priority_group,
    p.parameter_table_name,
    p.parameter_column_name,
    p.parameter_sequence_no,
    p.column_pos,
    p.attribute_sequence_no
from  system.repcat$_parameter_column p, all_tab_columns tc,
      system.repcat$_resolution r, system.repcat$_repcolumn rc
where p.sname = tc.owner
  and p.oname = tc.table_name
  and p.sname = rc.sname
  and p.oname = rc.oname
  and p.column_pos = rc.pos
  and ( (NVL(rc.top, rc.lcname) = tc.column_name) or
         -- SOID column
        (utl_raw.bit_and(utl_raw.substr(rc.property, 1, 1), '10') = '10') )
  and p.oname = p.parameter_table_name
  and p.sname = r.sname
  and p.oname = r.oname
  and p.conflict_type_id = r.conflict_type_id
  and p.reference_name = r.reference_name
  and p.sequence_no = r.sequence_no
union
select
    p.sname,
    p.oname,
    decode(p.conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    p.reference_name,
    p.sequence_no,
    r.method_name,
    r.function_name,
    r.priority_group,
    p.parameter_table_name,
    p.parameter_column_name,
    p.parameter_sequence_no,
    p.column_pos,
    p.attribute_sequence_no
from  system.repcat$_parameter_column p, "_ALL_REPL_NESTED_TABLE_NAMES" nt,
      system.repcat$_resolution r
where p.sname = nt.owner
  and p.parameter_table_name = nt.table_name
  and p.oname = p.parameter_table_name
  and p.sname = r.sname
  and p.oname = r.oname
  and p.conflict_type_id = r.conflict_type_id
  and p.reference_name = r.reference_name
  and p.sequence_no = r.sequence_no
/
comment on table "_ALL_REPPARAMETER_COLUMN" is
'All columns used for resolving conflicts in replicated tables which are accessible to the user'
/
comment on column "_ALL_REPPARAMETER_COLUMN".sname is
'Owner of replicated object'
/
comment on column "_ALL_REPPARAMETER_COLUMN".oname is
'Name of the replicated object'
/
comment on column "_ALL_REPPARAMETER_COLUMN".conflict_type is
'Type of conflict'
/
comment on column "_ALL_REPPARAMETER_COLUMN".reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column "_ALL_REPPARAMETER_COLUMN".sequence_no is
'Ordering on resolution'
/
comment on column "_ALL_REPPARAMETER_COLUMN".parameter_table_name is
'Name of the table to which the parameter column belongs'
/
comment on column "_ALL_REPPARAMETER_COLUMN".parameter_column_name is
'Name of the parameter column used for resolving the conflict'
/
comment on column "_ALL_REPPARAMETER_COLUMN".parameter_sequence_no is
'Ordering on parameter column'
/
comment on column "_ALL_REPPARAMETER_COLUMN".column_pos is
'Column position of a column or an attribute'
/
comment on column "_ALL_REPPARAMETER_COLUMN".attribute_sequence_no is
'Ordering of an attribute for a parameter column'
/
grant select on "_ALL_REPPARAMETER_COLUMN" to public with grant option
/

create or replace view all_repparameter_column
(
    sname,
    oname,
    conflict_type,
    reference_name,
    sequence_no,
    method_name,
    function_name,
    priority_group,
    parameter_table_name,
    parameter_column_name,
    parameter_sequence_no
)
as
select
    p.sname,
    p.oname,
    decode(p.conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    p.reference_name,
    p.sequence_no,
    r.method_name,
    r.function_name,
    r.priority_group,
    p.parameter_table_name,
    decode(method_name, 'USER FUNCTION', NVL(rc.top, rc.lcname),
                        'USER FLAVOR FUNCTION', NVL(rc.top, rc.lcname),
           rc.lcname),
    p.parameter_sequence_no
from  system.repcat$_parameter_column p,
      system.repcat$_resolution r,
      system.repcat$_repcolumn rc,
      all_tab_columns tc
where p.sname = r.sname
and   p.oname = r.oname
and   p.conflict_type_id = r.conflict_type_id
and   p.reference_name = r.reference_name
and   p.sequence_no = r.sequence_no
and   p.oname = p.parameter_table_name
and   p.attribute_sequence_no = 1
and   p.sname = rc.sname
and   p.oname = rc.oname
and   p.column_pos = rc.pos
and   p.sname = tc.owner
and   p.oname = tc.table_name
and   ((rc.top is null and rc.lcname = tc.column_name) or
       (rc.top is not null and rc.top = tc.column_name))
union
  select p.sname, p.oname, p.conflict_type, p.reference_name, p.sequence_no,
         p.method_name, p.function_name, p.priority_group,
         p.parameter_table_name, p.parameter_column_name,
         p.parameter_sequence_no
from  "_ALL_REPL_NESTED_TABLE_NAMES" nt, dba_repparameter_column p
where p.sname = nt.owner
  and p.parameter_table_name = nt.table_name
  and p.oname = p.parameter_table_name
/
comment on table all_repparameter_column is
'All columns used for resolving conflicts in replicated tables which are accessible to the user'
/
comment on column all_repparameter_column.sname is
'Owner of replicated object'
/
comment on column all_repparameter_column.oname is
'Name of the replicated object'
/
comment on column all_repparameter_column.conflict_type is
'Type of conflict'
/
comment on column all_repparameter_column.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column all_repparameter_column.sequence_no is
'Ordering on resolution'
/
comment on column all_repparameter_column.parameter_table_name is
'Name of the table to which the parameter column belongs'
/
comment on column all_repparameter_column.parameter_column_name is
'Name of the parameter column used for resolving the conflict'
/
comment on column all_repparameter_column.parameter_sequence_no is
'Ordering on parameter column'
/
create or replace public synonym all_repparameter_column
   for all_repparameter_column
/
grant select on all_repparameter_column to public with grant option
/

create or replace view user_repparameter_column
(
    sname,
    oname,
    conflict_type,
    reference_name,
    sequence_no,
    method_name,
    function_name,
    priority_group,
    parameter_table_name,
    parameter_column_name,
    parameter_sequence_no
)
as
select
    p.sname,
    p.oname,
    decode(p.conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    p.reference_name,
    p.sequence_no,
    r.method_name,
    r.function_name,
    r.priority_group,
    p.parameter_table_name,
    decode(method_name, 'USER FUNCTION', NVL(rc.top, rc.lcname),
                        'USER FLAVOR FUNCTION', NVL(rc.top, rc.lcname),
           rc.lcname),
    p.parameter_sequence_no
from  system.repcat$_parameter_column p,
      system.repcat$_resolution r,
      system.repcat$_repcolumn rc,
      user_tab_columns tc,
      sys.user$ u 
where p.sname = r.sname
and   p.oname = r.oname
and   p.conflict_type_id = r.conflict_type_id
and   p.reference_name = r.reference_name
and   p.sequence_no = r.sequence_no
and   p.oname = p.parameter_table_name
and   p.attribute_sequence_no = 1
and   p.sname = rc.sname
and   p.oname = rc.oname
and   p.column_pos = rc.pos
and   p.sname = u.name
and   u.user# = userenv('SCHEMAID')
and   p.oname = tc.table_name
and   ((rc.top is null and rc.lcname = tc.column_name) or
       (rc.top is not null and rc.top = tc.column_name))
union
  select p.sname, p.oname, p.conflict_type, p.reference_name, p.sequence_no,
         p.method_name, p.function_name, p.priority_group,
         p.parameter_table_name, p.parameter_column_name,
         p.parameter_sequence_no
from  "_USER_REPL_NESTED_TABLE_NAMES" nt, dba_repparameter_column p,
      sys.user$ u
where p.sname = u.name
  and u.user# = userenv('SCHEMAID')
  and p.parameter_table_name = nt.table_name
  and p.oname = p.parameter_table_name
/
comment on table user_repparameter_column is
'All columns used for resolving conflicts in user''s replicated tables'
/
comment on column user_repparameter_column.oname is
'Name of the replicated object'
/
comment on column user_repparameter_column.conflict_type is
'Type of conflict'
/
comment on column user_repparameter_column.reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column user_repparameter_column.sequence_no is
'Ordering on resolution'
/
comment on column user_repparameter_column.parameter_table_name is
'Name of the table to which the parameter column belongs'
/
comment on column user_repparameter_column.parameter_column_name is
'Name of the parameter column used for resolving the conflict'
/
comment on column user_repparameter_column.parameter_sequence_no is
'Ordering on parameter column'
/
create or replace public synonym user_repparameter_column
   for user_repparameter_column
/
grant select on user_repparameter_column to public with grant option
/

-- This view is for internal use only and may change without notice.
-- Pulls the conflict with available resolutions for columns
-- that belong to the flavor at the local site by doing a
-- join with _ALL_REPPARAMETER_COLUMN.
--
-- Since OVERWRITE and DISCARD do not have entries in the
-- _ALL_REPPARAMETER_COLUMN view, this pulls them seperately.
-- USER FUNCTION and USER FLAVOR FUNCTION may also be specified
-- with no paramater columns. In that case, they also may not have
-- entries in the _ALL_REPPARAMETER_COLUMN view. So pull them
-- also seperately.
--
create or replace view "_ALL_REPCONFLICT"
  (sname, oname, conflict_type, reference_name, conflict_type_id) as
select rc.sname, rc.oname, rc.conflict_type, rc.reference_name,
  decode(rc.conflict_type,
         'UPDATE',1,
         'UNIQUENESS',2,
         'DELETE',3, -1)
from all_repconflict rc
where rc.conflict_type in ('UNIQUENESS', 'DELETE')
union
select rc.sname, rc.oname, rc.conflict_type, rc.reference_name,
  decode(rc.conflict_type,
         'UPDATE',1,
         'UNIQUENESS',2,
         'DELETE',3, -1)
from all_repconflict rc, all_represolution resol
where rc.sname = resol.sname and
       rc.oname = resol.oname and
       rc.conflict_type = resol.conflict_type and
       resol.method_name in ('OVERWRITE', 'DISCARD', 'USER FUNCTION',
                             'USER FLAVOR FUNCTION')
union
select /*+ ALL_ROWS */ rc.sname, rc.oname, rc.conflict_type, rc.reference_name,
  decode(rc.conflict_type,
         'UPDATE',1,
         'UNIQUENESS',2,
         'DELETE',3, -1)
from all_repconflict rc, "_ALL_REPPARAMETER_COLUMN" rpcol
where rc.reference_name = rpcol.reference_name
and rc.sname = rpcol.sname 
and rc.oname = rpcol.oname 
/
comment on table "_ALL_REPCONFLICT" is
'All conflicts with available resolutions for replicated tables which are accessible to the user'
/
comment on column "_ALL_REPCONFLICT".sname is
'Owner of replicated object'
/
comment on column "_ALL_REPCONFLICT".oname is
'Name of the replicated object'
/
comment on column "_ALL_REPCONFLICT".conflict_type is
'Type of conflict'
/
comment on column "_ALL_REPCONFLICT".reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column "_ALL_REPCONFLICT".conflict_type_id is
'Internal ID for the type of conflict.'
/
grant select on "_ALL_REPCONFLICT" to PUBLIC with grant option
/

create table system.repcat$_audit_attribute
(
    attribute              varchar2(30)
                               constraint repcat$_audit_attribute_pk
                                 primary key,
    data_type_id           integer
                               constraint repcat$_audit_attribute_nn1
                                 not null,
    data_length            integer,
    source                 varchar2(92)
                               constraint repcat$_audit_attribute_nn2
                                 not null,
          constraint repcat$_audit_attribute_c1
          check ((data_type_id in (2, 4, 5, 6, 7) and
                  data_length is not null)
              or (data_type_id not in (2, 4, 5, 6, 7) and
                  data_length is null)
                 )
)
/
comment on table system.repcat$_audit_attribute is
'Information about attributes automatically maintained for replication'
/
comment on column system.repcat$_audit_attribute.attribute is
'Description of the attribute'
/
comment on column system.repcat$_audit_attribute.data_type_id is
'Datatype of the attribute value'
/
comment on column system.repcat$_audit_attribute.data_length is
'Length of the attribute value in byte'
/
comment on column system.repcat$_audit_attribute.source is
'Name of the function which returns the attribute value'
/


create or replace view dba_repaudit_attribute
(
    attribute,
    data_type,
    data_length,
    source
)
as
select
    attribute,
    decode(data_type_id,
           1, 'NUMBER',
           2, 'VARCHAR2',
           3, 'DATE',
           4, 'CHAR',
           5, 'RAW',
           6, 'NVARCHAR2',
           7, 'NCHAR',
           'UNDEFINED'),
    data_length,
    source
from  system.repcat$_audit_attribute
/
comment on table dba_repaudit_attribute is
'Information about attributes automatically maintained for replication'
/
comment on column dba_repaudit_attribute.attribute is
'Description of the attribute'
/
comment on column dba_repaudit_attribute.data_type is
'Datatype of the attribute value'
/
comment on column dba_repaudit_attribute.data_length is
'Length of the attribute value in byte'
/
comment on column dba_repaudit_attribute.source is
'Name of the function which returns the attribute value'
/
create or replace public synonym dba_repaudit_attribute
   for dba_repaudit_attribute
/
grant select on dba_repaudit_attribute to select_catalog_role
/


create or replace view all_repaudit_attribute
(
    attribute,
    data_type,
    data_length,
    source
)
as
select
    attribute,
    decode(data_type_id,
           1, 'NUMBER',
           2, 'VARCHAR2',
           3, 'DATE',
           4, 'CHAR',
           5, 'RAW',
           6, 'NVARCHAR2',
           7, 'NCHAR',
           'UNDEFINED'),
    data_length,
    source
from  system.repcat$_audit_attribute
/
comment on table all_repaudit_attribute is
'Information about attributes automatically maintained for replication'
/
comment on column all_repaudit_attribute.attribute is
'Description of the attribute'
/
comment on column all_repaudit_attribute.data_type is
'Datatype of the attribute value'
/
comment on column all_repaudit_attribute.data_length is
'Length of the attribute value in byte'
/
comment on column all_repaudit_attribute.source is
'Name of the function which returns the attribute value'
/
create or replace public synonym all_repaudit_attribute
   for all_repaudit_attribute
/
grant select on all_repaudit_attribute to public with grant option
/


create or replace view user_repaudit_attribute
(
    attribute,
    data_type,
    data_length,
    source
)
as
select
    attribute,
    decode(data_type_id,
           1, 'NUMBER',
           2, 'VARCHAR2',
           3, 'DATE',
           4, 'CHAR',
           5, 'RAW',
           6, 'NVARCHAR2',
           7, 'NCHAR',
           'UNDEFINED'),
    data_length,
    source
from  system.repcat$_audit_attribute
/
comment on table user_repaudit_attribute is
'Information about attributes automatically maintained for replication'
/
comment on column user_repaudit_attribute.attribute is
'Description of the attribute'
/
comment on column user_repaudit_attribute.data_type is
'Datatype of the attribute value'
/
comment on column user_repaudit_attribute.data_length is
'Length of the attribute value in byte'
/
comment on column user_repaudit_attribute.source is
'Name of the function which returns the attribute value'
/
create or replace public synonym user_repaudit_attribute
   for user_repaudit_attribute
/
grant select on user_repaudit_attribute to public with grant option
/


create table system.repcat$_audit_column
(
    sname                  varchar2(30),
    oname                  varchar2(30),
    column_name            varchar2(30),
    base_sname             varchar2(30)
                               constraint repcat$_audit_column_nn1
                                 not null,
    base_oname             varchar2(30)
                               constraint repcat$_audit_column_nn2
                                 not null,
    base_conflict_type_id  integer
                               constraint repcat$_audit_column_nn3
                                 not null,
    base_reference_name    varchar2(30)
                               constraint repcat$_audit_column_nn4
                                 not null,
    attribute              varchar2(30)
                               constraint repcat$_audit_column_nn5
                                 not null
                               constraint repcat$_audit_column_f1
                                 references system.repcat$_audit_attribute,
        constraint repcat$_audit_column_pk
          primary key (column_name, oname, sname),
        constraint repcat$_audit_column_f2
          foreign key (base_sname,
                       base_oname,
                       base_conflict_type_id,
                       base_reference_name)
          references system.repcat$_conflict
)
/
-- index on foreign key to avoid deadlocks
create index system.repcat$_audit_column_f1_idx on
system.repcat$_audit_column(attribute)
/
create index system.repcat$_audit_column_f2_idx on
system.repcat$_audit_column(base_sname,base_oname,base_conflict_type_id,
base_reference_name)
/
comment on table system.repcat$_audit_column is
'Information about columns in all shadow tables for all replicated tables in the database'
/
comment on column system.repcat$_audit_column.sname is
'Owner of the shadow table'
/
comment on column system.repcat$_audit_column.oname is
'Name of the shadow table'
/
comment on column system.repcat$_audit_column.column_name is
'Name of the column in the shadow table'
/
comment on column system.repcat$_audit_column.base_sname is
'Owner of replicated table'
/
comment on column system.repcat$_audit_column.base_oname is
'Name of the replicated table'
/
comment on column system.repcat$_audit_column.base_conflict_type_id is
'Type of conflict'
/
comment on column system.repcat$_audit_column.base_reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column system.repcat$_audit_column.attribute is
'Description of the attribute'
/


create or replace view dba_repaudit_column
(
    sname,
    oname,
    column_name,
    base_sname,
    base_oname,
    base_conflict_type,
    base_reference_name,
    attribute
)
as
select
    sname,
    oname,
    column_name,
    base_sname,
    base_oname,
    decode(base_conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    base_reference_name,
    attribute
from  system.repcat$_audit_column
/
comment on table dba_repaudit_column is
'Information about columns in all shadow tables for all replicated tables in the database'
/
comment on column dba_repaudit_column.sname is
'Owner of the shadow table'
/
comment on column dba_repaudit_column.oname is
'Name of the shadow table'
/
comment on column dba_repaudit_column.column_name is
'Name of the column in the shadow table'
/
comment on column dba_repaudit_column.base_sname is
'Owner of replicated table'
/
comment on column dba_repaudit_column.base_oname is
'Name of the replicated table'
/
comment on column dba_repaudit_column.base_conflict_type is
'Type of conflict'
/
comment on column dba_repaudit_column.base_reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column dba_repaudit_column.attribute is
'Description of the attribute'
/
create or replace public synonym dba_repaudit_column for dba_repaudit_column
/
grant select on dba_repaudit_column to select_catalog_role
/


create or replace view all_repaudit_column
(
    sname,
    oname,
    column_name,
    base_sname,
    base_oname,
    base_conflict_type,
    base_reference_name,
    attribute
)
as
select
    sname,
    oname,
    column_name,
    base_sname,
    base_oname,
    decode(base_conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    base_reference_name,
    attribute
from  system.repcat$_audit_column,
     sys.user$ u, sys.obj$ o
where sname = u.name
  and oname = o.name
  and o.owner# = u.user#
  and o.type# = 2 /* tables */
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                   from objauth$
                   where grantee# in ( select kzsrorol
                                       from x$kzsro
                                     )
                  )
        or
  exists (select null from v$enabledprivs
          where priv_number in (-45 /* LOCK ANY TABLE */,
           -47 /* SELECT ANY TABLE */,
           -48 /* INSERT ANY TABLE */,
           -49 /* UPDATE ANY TABLE */,
           -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table all_repaudit_column is
'Information about columns in all shadow tables for replicated tables which are accessible to the user'
/
comment on column all_repaudit_column.sname is
'Owner of the shadow table'
/
comment on column all_repaudit_column.oname is
'Name of the shadow table'
/
comment on column all_repaudit_column.column_name is
'Name of the column in the shadow table'
/
comment on column all_repaudit_column.base_sname is
'Owner of replicated table'
/
comment on column all_repaudit_column.base_oname is
'Name of the replicated table'
/
comment on column all_repaudit_column.base_conflict_type is
'Type of conflict'
/
comment on column all_repaudit_column.base_reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column all_repaudit_column.attribute is
'Description of the attribute'
/
create or replace public synonym all_repaudit_column for all_repaudit_column
/
grant select on all_repaudit_column to public with grant option
/


create or replace view user_repaudit_column
(
    oname,
    column_name,
    base_sname,
    base_oname,
    base_conflict_type,
    base_reference_name,
    attribute
)
as
select
    r.oname,
    r.column_name,
    r.base_sname,
    r.base_oname,
    decode(r.base_conflict_type_id,
           1, 'UPDATE',
           2, 'UNIQUENESS',
           3, 'DELETE',
           'UNDEFINED'),
    r.base_reference_name,
    r.attribute
from  system.repcat$_audit_column r, sys.user$ u
where r.sname = u.name
and   u.user# = userenv('SCHEMAID')
/
comment on table user_repaudit_column is
'Information about columns in all shadow tables for user''s replicated tables'
/
comment on column user_repaudit_column.oname is
'Name of the shadow table'
/
comment on column user_repaudit_column.column_name is
'Name of the column in the shadow table'
/
comment on column user_repaudit_column.base_sname is
'Owner of replicated table'
/
comment on column user_repaudit_column.base_oname is
'Name of the replicated table'
/
comment on column user_repaudit_column.base_conflict_type is
'Type of conflict'
/
comment on column user_repaudit_column.base_reference_name is
'Table name, unique constraint name, or column group name'
/
comment on column user_repaudit_column.attribute is
'Description of the attribute'
/
create or replace public synonym user_repaudit_column for user_repaudit_column
/
grant select on user_repaudit_column to public with grant option
/


--
-- Supported audit attributes.
--
delete from system.repcat$_audit_attribute
/
insert into system.repcat$_audit_attribute
  (attribute, data_type_id, data_length, source)
  values
  ('TIMESTAMP', 3, NULL, 'SYSDATE')
/
insert into system.repcat$_audit_attribute
  (attribute, data_type_id, data_length, source)
  values
  ('GLOBAL NAME', 2, 128, 'DBMS_REPUTIL.GLOBAL_NAME')
/


create or replace view DBA_REPFLAVORS
(FLAVOR_ID, GNAME, FNAME, CREATION_DATE, CREATED_BY, PUBLISHED, GROUP_OWNER)
as
select f.flavor_id, f.gname, f.fname, f.creation_date, u.name, f.published,
       f.gowner
from system.repcat$_flavors f, user$ u
where f.created_by = u.user# (+)
/
comment on table DBA_REPFLAVORS is
'Flavors defined for replicated object groups'
/
comment on column DBA_REPFLAVORS.FLAVOR_ID is
'Flavor identifier, unique within object group'
/
comment on column DBA_REPFLAVORS.GROUP_OWNER is
'Owner of the object group'
/
comment on column DBA_REPFLAVORS.GNAME is
'Name of the object group'
/
comment on column DBA_REPFLAVORS.FNAME is
'Name of the flavor'
/
comment on column DBA_REPFLAVORS.CREATION_DATE is
'Date on which the flavor was created'
/
comment on column DBA_REPFLAVORS.CREATED_BY is
'User that created the flavor'
/
comment on column DBA_REPFLAVORS.PUBLISHED is
'Indicates whether flavor is published (Y/N) or obsolete (O)'
/
create or replace public synonym DBA_REPFLAVORS for DBA_REPFLAVORS
/
grant select on DBA_REPFLAVORS to select_catalog_role
/


create or replace view ALL_REPFLAVORS
(FLAVOR_ID, GNAME, FNAME, CREATION_DATE, CREATED_BY, PUBLISHED, GROUP_OWNER)
as
select f.flavor_id, f.gname, f.fname, f.creation_date, u.name, f.published,
       f.gowner
from system.repcat$_flavors f, user$ u
where f.created_by = u.user# (+)
/
comment on table ALL_REPFLAVORS is
'Flavors defined for replicated object groups'
/
comment on column ALL_REPFLAVORS.FLAVOR_ID is
'Flavor identifier, unique within object group'
/
comment on column ALL_REPFLAVORS.GNAME is
'Name of the object group'
/
comment on column ALL_REPFLAVORS.FNAME is
'Name of the flavor'
/
comment on column ALL_REPFLAVORS.CREATION_DATE is
'Date on which the flavor was created'
/
comment on column ALL_REPFLAVORS.CREATED_BY is
'User that created the flavor'
/
comment on column ALL_REPFLAVORS.PUBLISHED is
'Indicates whether flavor is published (Y/N) or obsolete (O)'
/
create or replace public synonym ALL_REPFLAVORS for ALL_REPFLAVORS
/
grant select on ALL_REPFLAVORS to PUBLIC with grant option
/


create or replace view USER_REPFLAVORS
(FLAVOR_ID, GNAME, FNAME, CREATION_DATE, CREATED_BY, PUBLISHED, GROUP_OWNER)
as
select f.flavor_id, f.gname, f.fname, f.creation_date, 
 u.name, f.published, f.gowner
from system.repcat$_flavors f, sys.user$ u
where f.created_by = userenv('SCHEMAID')
and   f.created_by = u.user#
/
comment on table USER_REPFLAVORS is
'Flavors current user created for replicated object groups'
/
comment on column USER_REPFLAVORS.FLAVOR_ID is
'Flavor identifier, unique within object group'
/
comment on column USER_REPFLAVORS.GROUP_OWNER is
'Owner of the object group'
/
comment on column USER_REPFLAVORS.GNAME is
'Name of the object group'
/
comment on column USER_REPFLAVORS.FNAME is
'Name of the flavor'
/
comment on column USER_REPFLAVORS.CREATION_DATE is
'Date on which the flavor was created'
/
comment on column USER_REPFLAVORS.CREATED_BY is
'User that created the flavor'
/
comment on column USER_REPFLAVORS.PUBLISHED is
'Indicates whether flavor is published (Y/N) or obsolete (O)'
/
create or replace public synonym USER_REPFLAVORS for USER_REPFLAVORS
/
grant select on USER_REPFLAVORS to PUBLIC with grant option
/


-- create table to hold objects in each flavor
CREATE TABLE system.repcat$_flavor_objects
(flavor_id         NUMBER,
 gowner            VARCHAR2(30) DEFAULT 'PUBLIC',
 gname             VARCHAR2(30),
 sname             VARCHAR2(30),
 oname             VARCHAR2(30),
 type              NUMBER,
 version#          NUMBER
                     CONSTRAINT repcat$_flavor_objects_version
                      CHECK (version# >= 0 AND version# < 65536),
 hashcode          RAW(17),
 columns_present   RAW(125),
 CONSTRAINT repcat$_flavor_objects_pk
   PRIMARY KEY (sname, oname, type, gname, flavor_id, gowner),
 CONSTRAINT repcat$_flavor_objects_fk1
   FOREIGN KEY (gname, gowner)
   REFERENCES system.repcat$_repcat(sname, gowner)
   ON DELETE CASCADE,
 CONSTRAINT repcat$_flavor_objects_fk2
   FOREIGN KEY (gname, flavor_id, gowner)
   REFERENCES system.repcat$_flavors(gname, flavor_id, gowner)
   ON DELETE CASCADE)
/

CREATE INDEX system.repcat$_flavor_objects_fg ON
  system.repcat$_flavor_objects(flavor_id, gname, gowner)
/

-- index on foreign key to avoid deadlocks in
-- concurrent do_deferred_repcat_admin
CREATE INDEX system.repcat$_flavor_objects_fk1_idx ON
  system.repcat$_flavor_objects(gname, gowner)
/

CREATE INDEX system.repcat$_flavor_objects_fk2_idx ON
  system.repcat$_flavor_objects(gname, flavor_id, gowner)
/

comment on table SYSTEM.REPCAT$_FLAVOR_OBJECTS is
'Replicated objects in flavors'
/
comment on column SYSTEM.REPCAT$_FLAVOR_OBJECTS.FLAVOR_ID is
'Flavor identifier'
/
comment on column SYSTEM.REPCAT$_FLAVOR_OBJECTS.GOWNER is
'Owner of the object group containing object'
/
comment on column SYSTEM.REPCAT$_FLAVOR_OBJECTS.GNAME is
'Object group containing object'
/
comment on column SYSTEM.REPCAT$_FLAVOR_OBJECTS.SNAME is
'Schema containing object'
/
comment on column SYSTEM.REPCAT$_FLAVOR_OBJECTS.ONAME is
'Name of object'
/
comment on column SYSTEM.REPCAT$_FLAVOR_OBJECTS.TYPE is
'Object type'
/
comment on column SYSTEM.REPCAT$_FLAVOR_OBJECTS.VERSION# is
'Version# of a user-defined type'
/
comment on column SYSTEM.REPCAT$_FLAVOR_OBJECTS.HASHCODE is
'Hashcode of a user-defined type'
/
comment on column SYSTEM.REPCAT$_FLAVOR_OBJECTS.COLUMNS_PRESENT is
'For tables, encoded mapping of columns present'
/

CREATE OR REPLACE VIEW dba_repflavor_objects
(fname, gname, sname, oname, type, group_owner)
AS
SELECT fl.fname, fo.gname, fo.sname, fo.oname,
       DECODE (fo.type,
        -1, 'SNAPSHOT',
         1, 'INDEX',
         2, 'TABLE',
         4, 'VIEW',
         5, 'SYNONYM',
         6, 'SEQUENCE',
         7, 'PROCEDURE',
         8, 'FUNCTION',
         9, 'PACKAGE',
        11, 'PACKAGE BODY',
        12, 'TRIGGER',
        13, 'TYPE',
        14, 'TYPE BODY',
        32, 'INDEXTYPE',
        33, 'OPERATOR',
            'UNDEFINED'), 
        fo.gowner
from system.repcat$_flavors fl, system.repcat$_flavor_objects fo
where fo.gname     = fl.gname
  and fo.flavor_id = fl.flavor_id
  and fo.gowner    = fl.gowner
/
comment on table DBA_REPFLAVOR_OBJECTS is
'Replicated objects in flavors'
/
comment on column DBA_REPFLAVOR_OBJECTS.FNAME is
'Flavor name'
/
comment on column DBA_REPFLAVOR_OBJECTS.GROUP_OWNER is
'Object group owner'
/
comment on column DBA_REPFLAVOR_OBJECTS.GNAME is
'Object group name'
/
comment on column DBA_REPFLAVOR_OBJECTS.SNAME is
'Schema containing object'
/
comment on column DBA_REPFLAVOR_OBJECTS.ONAME is
'Name of object'
/
comment on column DBA_REPFLAVOR_OBJECTS.TYPE is
'Object type'
/
create or replace public synonym DBA_REPFLAVOR_OBJECTS
   for DBA_REPFLAVOR_OBJECTS
/
grant select on DBA_REPFLAVOR_OBJECTS to select_catalog_role
/


CREATE OR REPLACE VIEW all_repflavor_objects
(fname, gname, sname, oname, type, group_owner)
AS
SELECT UNIQUE fo.fname, fo.gname, fo.sname, fo.oname,
       fo.type, fo.group_owner
from dba_repflavor_objects fo, all_objects o
where fo.sname = o.owner
  and fo.oname = o.object_name
  and (fo.type = o.object_type OR
       fo.type = 'SNAPSHOT' and o.object_type IN ('VIEW', 'TABLE'))
/
comment on table ALL_REPFLAVOR_OBJECTS is
'Replicated objects in flavors'
/
comment on column ALL_REPFLAVOR_OBJECTS.FNAME is
'Flavor name'
/
comment on column ALL_REPFLAVOR_OBJECTS.GROUP_OWNER is
'Object group owner'
/
comment on column ALL_REPFLAVOR_OBJECTS.GNAME is
'Object group name'
/
comment on column ALL_REPFLAVOR_OBJECTS.SNAME is
'Schema containing object'
/
comment on column ALL_REPFLAVOR_OBJECTS.ONAME is
'Name of object'
/
comment on column ALL_REPFLAVOR_OBJECTS.TYPE is
'Object type'
/
create or replace public synonym ALL_REPFLAVOR_OBJECTS
   for ALL_REPFLAVOR_OBJECTS
/
grant select on ALL_REPFLAVOR_OBJECTS to PUBLIC with grant option
/


-- Create a view suitable for remote access from repcat.
-- This view is for internal use only and may change without notice.
CREATE OR REPLACE VIEW "_ALL_REPFLAVOR_OBJECTS"
(flavor_id, gname, sname, oname, type, columns_present, published, flag, 
 gowner, version#, hashcode)
AS
SELECT fo.flavor_id, fo.gname, fo.sname, fo.oname, fo.type, fo.columns_present,
       fl.published, ro.flag, fo.gowner, fo.version#, fo.hashcode
from system.repcat$_flavor_objects fo, all_objects o,
     system.repcat$_flavors fl, system.repcat$_repobject ro
where fo.gname     = fl.gname
  and fo.gowner    = fl.gowner
  and fo.flavor_id = fl.flavor_id
  and fo.sname     = ro.sname
  and fo.oname     = ro.oname
  and fo.type      = ro.type
  and fo.sname     = o.owner
  and fo.oname     = o.object_name
  and ro.id        = o.object_id
  and ((fo.type = -1 and o.object_type in ('VIEW', 'TABLE'))
       or
       (fo.type > 0 and o.object_type = 
       DECODE (fo.type,
        1, 'INDEX',
        2, 'TABLE',
        4, 'VIEW',
        5, 'SYNONYM',
        6, 'SEQUENCE',
        7, 'PROCEDURE',
        8, 'FUNCTION',
        9, 'PACKAGE',
       11, 'PACKAGE BODY',
       12, 'TRIGGER',
       13, 'TYPE',
       14, 'TYPE BODY',
       32, 'INDEXTYPE',
       33, 'OPERATOR',
           'UNDEFINED')))
/
comment on table "_ALL_REPFLAVOR_OBJECTS" is
'Replicated objects in flavors'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".FLAVOR_ID is
'Flavor identifier'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".GOWNER is
'Object group owner'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".GNAME is
'Object group name'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".SNAME is
'Schema containing object'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".ONAME is
'Name of object'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".TYPE is
'Object type'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".VERSION# is
'Object type version#'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".HASHCODE is
'Object type hashcode'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".COLUMNS_PRESENT is
'For tables, encoded mapping of columns present'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".PUBLISHED is
'Indicates whether flavor is published (Y/N) or obsolete (O)'
/
comment on column "_ALL_REPFLAVOR_OBJECTS".FLAG is
'Information about replicated object'
/
grant select on "_ALL_REPFLAVOR_OBJECTS" to PUBLIC with grant option
/


CREATE OR REPLACE VIEW user_repflavor_objects
(fname, gname, sname, oname, type, group_owner)
AS
SELECT UNIQUE fo.fname, fo.gname, fo.sname, fo.oname,
       fo.type, fo.group_owner
from dba_repflavor_objects fo, user_objects o, sys.user$ u
where fo.sname = u.name
  and u.user#  = userenv('SCHEMAID')
  and fo.oname = o.object_name
  and (fo.type = o.object_type OR
       fo.type = 'SNAPSHOT' and o.object_type IN ('VIEW', 'TABLE'))
/
comment on table USER_REPFLAVOR_OBJECTS is
'Replicated user objects in flavors'
/
comment on column USER_REPFLAVOR_OBJECTS.FNAME is
'Flavor name'
/
comment on column USER_REPFLAVOR_OBJECTS.GROUP_OWNER is
'Object group owner'
/
comment on column USER_REPFLAVOR_OBJECTS.GNAME is
'Object group name'
/
comment on column USER_REPFLAVOR_OBJECTS.SNAME is
'Schema containing object'
/
comment on column USER_REPFLAVOR_OBJECTS.ONAME is
'Name of object'
/
comment on column USER_REPFLAVOR_OBJECTS.TYPE is
'Object type'
/
create or replace public synonym USER_REPFLAVOR_OBJECTS
   for USER_REPFLAVOR_OBJECTS
/
grant select on USER_REPFLAVOR_OBJECTS to PUBLIC with grant option
/

-- This view is for internal use only and may change without notice.
CREATE OR REPLACE VIEW repcat_repflavor_columns
  (fname, gname, sname, oname, cname, type, pos, group_owner,
   type_toid, type_owner, type_hashcode, type_mod, top,
   internal_cname, property) AS
  -- include table columns and snapshot columns
  SELECT f.fname, fo.gname, rc.sname, rc.oname, rc.lcname,
         decode(rc.ctype,
           1, decode(rc.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
           2, 'NUMBER',
          12, 'DATE',
          23, decode(utl_raw.bit_and(utl_raw.substr(rc.property, 1, 1), '04'),
                  '04', rc.ctype_name,
               -- for soidref_fk_attr we want to display the real column type
               decode(utl_raw.bit_and(utl_raw.substr(rc.property, 2, 1), '02'),
                   '02', rc.ctype_name, 
                   'RAW')),
          58, rc.ctype_name,
          69, 'ROWID',
          96, decode(rc.charsetform, 2, 'NCHAR', 'CHAR'),
         112, NVL(rc.ctype_name, decode(rc.charsetform, 2, 'NCLOB', 'CLOB')),
         113, 'BLOB',
         111, rc.ctype_name,
         121, rc.ctype_name,
         122, rc.ctype_name,
         123, rc.ctype_name,
             'UNDEFINED'),
         rc.pos, fo.gowner,
         rc.toid,
         rc.ctype_owner,
         RAWTOHEX(rc.hashcode),
         DECODE(rc.ctype, 
                111, 'REF',
                23,
                decode(utl_raw.bit_and(utl_raw.substr(rc.property,2,1),'02'),
                       '02', 'REF')
                ),
         decode(rc.ctype, 23,
               -- nested table column SETID (in the parent table)
               decode(utl_raw.bit_and(utl_raw.substr(rc.property, 1, 1), '08'),
                      '08',decode(rc.top, rc.lcname, NULL, rc.top), rc.top),
               -- for XMLType storage column
               112, decode(rc.top, rc.lcname, NULL, rc.top),
              rc.top),
         rc.cname, rc.property
    FROM system.repcat$_repcolumn rc, system.repcat$_flavor_objects fo,
         system.repcat$_flavors f, system.repcat$_repobject ro
    WHERE f.flavor_id = fo.flavor_id
      AND f.gname     = fo.gname
      AND f.gowner    = fo.gowner
      AND rc.sname    = fo.sname AND rc.oname = fo.oname
      AND fo.type     in (2, -1)
      AND ro.sname    = rc.sname
      AND ro.oname    = rc.oname
      AND ro.type     = rc.type
      AND ro.gname    = fo.gname
      AND ro.gowner   = fo.gowner
      AND rc.pos IS NOT NULL
      AND
        ((mod(rc.pos-1,8) < 4
         AND fo.columns_present IS NOT NULL
         -- the following AND clauses are necessary to avoid
         -- invoking utl_raw.substr with fo.columns_present from one
         -- object while rc.pos is from another object.
         AND fo.sname = rc.sname
         AND fo.oname = rc.oname
         AND fo.type = rc.type
         AND utl_raw.bit_and(utl_raw.substr(fo.columns_present,
                                             floor((rc.pos-1)/8)+1, 1),
                              to_char(power(2, mod(rc.pos-1,8))))
                             != '00')
         OR
         (mod(rc.pos-1,8) >= 4
         AND fo.columns_present IS NOT NULL
         -- the following AND clauses are necessary to avoid
         -- invoking utl_raw.substr with fo.columns_present from one
         -- object while rc.pos is from another object.
         AND fo.sname = rc.sname
         AND fo.oname = rc.oname
         AND fo.type = rc.type
         AND utl_raw.bit_and(utl_raw.substr(fo.columns_present,
                                             floor((rc.pos-1)/8)+1, 1),
                              to_char(10*power(2, mod(rc.pos-1,8)-4)))
                             != '00'))
/
comment on table REPCAT_REPFLAVOR_COLUMNS is
'Replicated columns in flavors'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.FNAME is
'Flavor name'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.GROUP_OWNER is
'Object group owner'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.GNAME is
'Object group name'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.SNAME is
'Schema containing the object'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.ONAME is
'Object name'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.CNAME is
'Column name'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.INTERNAL_CNAME is
'Internal column name'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.TYPE is
'Column type'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.TYPE_OWNER is
'Type owner of a column of TYPE'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.TYPE_HASHCODE is
'Type hashcode of a column of TYPE'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.TYPE_TOID is
'Type OID of a column of TYPE'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.TYPE_MOD is
'Datatype modifier of a column'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.TOP is
'Top column of this attribute column'
/
comment on column REPCAT_REPFLAVOR_COLUMNS.POS is
'Ordering of column used as IN parameter in the replication procedures'
/
grant select on REPCAT_REPFLAVOR_COLUMNS to select_catalog_role
/


CREATE OR REPLACE VIEW dba_repflavor_columns
  (fname, gname, sname, oname, cname, type, pos, group_owner,
   type_toid, type_owner, type_hashcode, type_mod, top) AS
SELECT fname, gname, sname, oname, cname, type, pos, group_owner,
   type_toid, type_owner, type_hashcode, type_mod, top
  FROM repcat_repflavor_columns
/
comment on table DBA_REPFLAVOR_COLUMNS is
'Replicated columns in flavors'
/
comment on column DBA_REPFLAVOR_COLUMNS.FNAME is
'Flavor name'
/
comment on column DBA_REPFLAVOR_COLUMNS.GROUP_OWNER is
'Object group owner'
/
comment on column DBA_REPFLAVOR_COLUMNS.GNAME is
'Object group name'
/
comment on column DBA_REPFLAVOR_COLUMNS.SNAME is
'Schema containing the object'
/
comment on column DBA_REPFLAVOR_COLUMNS.ONAME is
'Object name'
/
comment on column DBA_REPFLAVOR_COLUMNS.CNAME is
'Column name'
/
comment on column DBA_REPFLAVOR_COLUMNS.TYPE is
'Column type'
/
comment on column DBA_REPFLAVOR_COLUMNS.TYPE_OWNER is
'Type owner of a column of TYPE'
/
comment on column DBA_REPFLAVOR_COLUMNS.TYPE_HASHCODE is
'Type hashcode of a column of TYPE'
/
comment on column DBA_REPFLAVOR_COLUMNS.TYPE_TOID is
'Type OID of a column of TYPE'
/
comment on column DBA_REPFLAVOR_COLUMNS.TYPE_MOD is
'Datatype modifier of a column'
/
comment on column DBA_REPFLAVOR_COLUMNS.TOP is
'Top column of this attribute column'
/
comment on column DBA_REPFLAVOR_COLUMNS.POS is
'Ordering of column used as IN parameter in the replication procedures'
/
create or replace public synonym DBA_REPFLAVOR_COLUMNS
   for DBA_REPFLAVOR_COLUMNS
/
grant select on DBA_REPFLAVOR_COLUMNS to select_catalog_role
/



CREATE OR REPLACE VIEW all_repflavor_columns
  (fname, gname, sname, oname, cname, type, pos, group_owner,
   type_toid, type_owner, type_hashcode, type_mod, top) AS
  SELECT fc.fname, fc.gname, fc.sname, fc.oname, fc.cname, fc.type, fc.pos,
         fc.group_owner, fc.type_toid, fc.type_owner,
         fc.type_hashcode, fc.type_mod, fc.top
    FROM dba_repflavor_columns fc, all_tab_columns tc
    WHERE fc.sname = tc.owner
      AND fc.oname = tc.table_name
      AND ((fc.top IS NOT NULL AND fc.top = tc.column_name) OR
           (fc.top IS NULL AND fc.cname = tc.column_name))
UNION
  SELECT fc.fname, fc.gname, fc.sname, fc.oname, fc.cname, fc.type, fc.pos,
         fc.group_owner, fc.type_toid, fc.type_owner,
         fc.type_hashcode, fc.type_mod, fc.top
    FROM dba_repflavor_columns fc, "_ALL_REPL_NESTED_TABLE_NAMES" nt
    WHERE fc.sname = nt.owner
      AND fc.oname = nt.table_name
/

comment on table ALL_REPFLAVOR_COLUMNS is
'Replicated columns in flavors'
/
comment on column ALL_REPFLAVOR_COLUMNS.FNAME is
'Flavor name'
/
comment on column ALL_REPFLAVOR_COLUMNS.GROUP_OWNER is
'Object group owner'
/
comment on column ALL_REPFLAVOR_COLUMNS.GNAME is
'Object group name'
/
comment on column ALL_REPFLAVOR_COLUMNS.SNAME is
'Schema containing the object'
/
comment on column ALL_REPFLAVOR_COLUMNS.ONAME is
'Object name'
/
comment on column ALL_REPFLAVOR_COLUMNS.CNAME is
'Column name'
/
comment on column ALL_REPFLAVOR_COLUMNS.TYPE is
'Column type'
/
comment on column ALL_REPFLAVOR_COLUMNS.POS is
'Ordering of column used as IN parameter in the replication procedures'
/
comment on column ALL_REPFLAVOR_COLUMNS.TYPE_OWNER is
'Type owner of a column of TYPE'
/
comment on column ALL_REPFLAVOR_COLUMNS.TYPE_HASHCODE is
'Type hashcode of a column of TYPE'
/
comment on column ALL_REPFLAVOR_COLUMNS.TYPE_TOID is
'Type OID of a column of TYPE'
/
comment on column ALL_REPFLAVOR_COLUMNS.TYPE_MOD is
'Datatype modifier of a column'
/
comment on column ALL_REPFLAVOR_COLUMNS.TOP is
'Top column of this attribute column'
/
create or replace public synonym ALL_REPFLAVOR_COLUMNS
   for ALL_REPFLAVOR_COLUMNS
/
grant select on ALL_REPFLAVOR_COLUMNS to PUBLIC with grant option
/

CREATE OR REPLACE VIEW user_repflavor_columns
  (fname, gname, sname, oname, cname, type, pos, group_owner,
   type_toid, type_owner, type_hashcode, type_mod, top) AS
  SELECT fc.fname, fc.gname, fc.sname, fc.oname, fc.cname, fc.type, fc.pos,
         fc.group_owner, fc.type_toid, fc.type_owner,
         fc.type_hashcode, fc.type_mod, fc.top
    FROM user_tab_columns tc, dba_repflavor_columns fc, sys.user$ u
    WHERE fc.sname = u.name
      AND u.user#  = userenv('SCHEMAID')
      AND fc.oname = tc.table_name
      AND ((fc.top IS NOT NULL AND fc.top = tc.column_name) OR
           (fc.top IS NULL AND fc.cname = tc.column_name))
UNION
  SELECT fc.fname, fc.gname, fc.sname, fc.oname, fc.cname, fc.type, fc.pos,
         fc.group_owner, fc.type_toid, fc.type_owner,
         fc.type_hashcode, fc.type_mod, fc.top
    FROM "_USER_REPL_NESTED_TABLE_NAMES" nt, dba_repflavor_columns fc, 
          sys.user$ u
    WHERE fc.sname = u.name
      AND  u.user#  = userenv('SCHEMAID')
      AND fc.oname = nt.table_name
/

comment on table USER_REPFLAVOR_COLUMNS is
'Replicated columns from current user''s tables in flavors'
/
comment on column USER_REPFLAVOR_COLUMNS.FNAME is
'Flavor name'
/
comment on column USER_REPFLAVOR_COLUMNS.GROUP_OWNER is
'Object group owner'
/
comment on column USER_REPFLAVOR_COLUMNS.GNAME is
'Object group name'
/
comment on column USER_REPFLAVOR_COLUMNS.SNAME is
'Schema containing the object'
/
comment on column USER_REPFLAVOR_COLUMNS.ONAME is
'Object name'
/
comment on column USER_REPFLAVOR_COLUMNS.CNAME is
'Column name'
/
comment on column USER_REPFLAVOR_COLUMNS.TYPE is
'Column type'
/
comment on column USER_REPFLAVOR_COLUMNS.POS is
'Ordering of column used as IN parameter in the replication procedures'
/
comment on column USER_REPFLAVOR_COLUMNS.TYPE_OWNER is
'Type owner of a column of TYPE'
/
comment on column USER_REPFLAVOR_COLUMNS.TYPE_HASHCODE is
'Type hashcode of a column of TYPE'
/
comment on column USER_REPFLAVOR_COLUMNS.TYPE_TOID is
'Type OID of a column of TYPE'
/
comment on column USER_REPFLAVOR_COLUMNS.TYPE_MOD is
'Datatype modifier of a column'
/
comment on column USER_REPFLAVOR_COLUMNS.TOP is
'Top column of this attribute column'
/
create or replace public synonym USER_REPFLAVOR_COLUMNS
   for USER_REPFLAVOR_COLUMNS
/
grant select on USER_REPFLAVOR_COLUMNS to PUBLIC with grant option
/


-----------------------------------------------------------------------------
--- In cleaning and populating repcat$_resolution_method, it's OK
--- if you see ORA-02292 (integrity constraint violated) and
--- ORA-00001 (unique constraint violated)
-----------------------------------------------------------------------------
--
-- Supported automatic conflict resolution methods.
--
-- UPDATE METHODS:
-- 'MINIMUM', 'EARLIEST TIMESTAMP', 'MAXIMUM', 'LATEST TIMESTAMP',
-- 'SITE PRIORITY', 'PRIORITY GROUP', 'ADDITIVE', 'AVERAGE',
-- 'OVERWRITE', 'DISCARD', 'USER FUNCTION', 'USER FLAVOR FUNCTION'
BEGIN
delete from system.repcat$_resolution_method
  where conflict_type_id = 1;
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -02292 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/

BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'MINIMUM');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name) 
  values (1, 'EARLIEST TIMESTAMP' );
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'MAXIMUM');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'LATEST TIMESTAMP');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'SITE PRIORITY');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'PRIORITY GROUP');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'ADDITIVE');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'AVERAGE');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'OVERWRITE');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'DISCARD');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'USER FUNCTION');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (1, 'USER FLAVOR FUNCTION');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/

-- INSERT METHODS:
-- 'APPEND SITE NAME', 'APPEND SEQUENCE', 'DISCARD', 'USER FUNCTION'
-- 'USER FLAVOR FUNCTION'
BEGIN
delete from system.repcat$_resolution_method
  where conflict_type_id = 2;
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -02292 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (2, 'APPEND SITE NAME');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (2, 'APPEND SEQUENCE');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (2, 'DISCARD');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (2, 'USER FUNCTION');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (2, 'USER FLAVOR FUNCTION');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/

-- DELETE METHODS:
-- 'USER FUNCTION', 'USER FLAVOR FUNCTION'
BEGIN
delete from system.repcat$_resolution_method
  where conflict_type_id = 3;
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -02292 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (3, 'USER FUNCTION');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
BEGIN
insert into system.repcat$_resolution_method (conflict_type_id, method_name)
  values (3, 'USER FLAVOR FUNCTION');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/
 
commit
/

Rem **********************************************************************
Rem For SYS to be able to grant select on defcalldest and deftrandest
Rem it need to be explictly
Rem granted priviledges on the underlying SYSTEM onwed tables.
Rem To get those priviledges, SYS creates and executes a package owned 
Rem by SYSTEM that issues the grants to SYS using DBMS_SQL.
create or replace procedure system.ora$_sys_rep_auth as
begin
  EXECUTE IMMEDIATE 'GRANT SELECT ON SYSTEM.repcat$_repschema TO SYS ' ||
                 'WITH GRANT OPTION';
  EXECUTE IMMEDIATE 'GRANT SELECT ON SYSTEM.repcat$_repprop TO SYS ' ||
                 'WITH GRANT OPTION';
  EXECUTE IMMEDIATE 'GRANT SELECT ON SYSTEM.def$_aqcall TO SYS ' ||
                 'WITH GRANT OPTION';
  EXECUTE IMMEDIATE 'GRANT SELECT ON SYSTEM.def$_calldest TO SYS ' ||
                 'WITH GRANT OPTION';
  EXECUTE IMMEDIATE 'GRANT SELECT ON SYSTEM.def$_error TO SYS ' ||
                 'WITH GRANT OPTION';
  EXECUTE IMMEDIATE 'GRANT SELECT ON SYSTEM.def$_destination TO SYS ' ||
                 'WITH GRANT OPTION';
end;
/

begin
 system.ora$_sys_rep_auth;
end;  
/

-- The following tables and views support refresh group templates
-- repcat$_template_status
create table system.repcat$_template_status
(template_status_id number,
   constraint repcat$_template_status_pk primary key (template_status_id),
status_type_name varchar2(100) not null)
/

comment on table SYSTEM.REPCAT$_TEMPLATE_STATUS is
'Table for template status and template status codes.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_STATUS.TEMPLATE_STATUS_ID is
'Internal primary key for the template status table.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_STATUS.STATUS_TYPE_NAME is
'User friendly name for the template status.'
/

-- seed data for the template_status table
insert into system.repcat$_template_status
(template_status_id,status_type_name)
select 0, 'Modifiable' 
from dual
where not exists
(select 1 from system.repcat$_template_status
where template_status_id = 0)
/

insert into system.repcat$_template_status
(template_status_id,status_type_name)
select 1, 'Frozen' 
from dual
where not exists
(select 1 from system.repcat$_template_status
where template_status_id = 1)
/

insert into system.repcat$_template_status
(template_status_id,status_type_name)
select 2, 'Deleted' 
from dual
where not exists
(select 1 from system.repcat$_template_status
where template_status_id = 2)
/

-- repcat$_template_types
create table system.repcat$_template_types
(template_type_id number,
   constraint repcat$_template_types_pk primary key (template_type_id),
template_description varchar2(200),
flags raw(255), 
spare1 varchar2(4000))
/

comment on table SYSTEM.REPCAT$_TEMPLATE_TYPES is
'Internal table for maintaining types of templates.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_TYPES.TEMPLATE_TYPE_ID is 
'Internal primary key of the template types table.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_TYPES.TEMPLATE_DESCRIPTION is 
'Description of the template type.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_TYPES.FLAGS is 
'Bitmap flags controlling each type of template.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_TYPES.SPARE1 is 
'Reserved for future expansion.'  
/  

-- seed data for repcat$_template_types
insert into system.repcat$_template_types
(template_type_id, template_description,flags)
select 1,'Deployment template',hextoraw('01')
from dual 
where not exists 
  (select 1 from system.repcat$_template_types
   where template_type_id = 1)
/

insert into system.repcat$_template_types
(template_type_id, template_description,flags)
select 2,'IAS template',hextoraw('02')
from dual 
where not exists 
  (select 1 from system.repcat$_template_types
   where template_type_id = 2)
/

-- repcat$_refresh_templates
create table system.repcat$_refresh_templates
(refresh_template_id number not null,
   constraint repcat$_refresh_templates_pk primary key (refresh_template_id),
 owner varchar2(30) not null,
 refresh_group_name varchar2(30) not null,
 refresh_template_name varchar2(30) not null,
 template_comment varchar2(2000),
 public_template varchar2(1),
   constraint refresh_templates_c1 check ((public_template in ('Y','N')) 
   or public_template is NULL),
 last_modified date,
 modified_by number,
 creation_date date,
 created_by number,
   constraint repcat$_refresh_templates_u1 unique (refresh_template_name),
 refresh_group_id number default 0 not null,
 template_type_id number default 1 not null,
   constraint repcat$_refresh_templates_fk1 foreign key (template_type_id)
     references system.repcat$_template_types,
 template_status_id number default 0 not null,
   constraint repcat$_refresh_templates_fk2 foreign key (template_status_id)
     references system.repcat$_template_status,
 flags raw(255),
 spare1 varchar2(4000))
/

create sequence system.repcat$_refresh_templates_s
/

comment on table SYSTEM.REPCAT$_REFRESH_TEMPLATES is 
'Primary table containing deployment template information.'
/

comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.REFRESH_TEMPLATE_ID is
'Internal primary key of the REPCAT$_REFRESH_TEMPLATES table.'
/
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.OWNER is
'Owner of the refresh group template.'
/
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.LAST_MODIFIED is
'Date the row was last modified.'
/
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.MODIFIED_BY is
'User id of the user that modified the row.'
/
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.CREATION_DATE is
'Date the row was created.'
/
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.CREATED_BY is
'User id of the user that created the row.'
/

comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.REFRESH_GROUP_ID is 
'Internal primary key to default refresh group for the template.'  
/  
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.TEMPLATE_TYPE_ID is 
'Internal primary key to the template types.'  
/  
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.TEMPLATE_STATUS_ID is 
'Internal primary key to the template status table.'  
/  
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.FLAGS is 
'Internal flags for the template.'  
/  
 
comment on column SYSTEM.REPCAT$_REFRESH_TEMPLATES.SPARE1 is 
'Reserved for future use.'  
/  

-- DBA view on the REPCAT$_REFRESH_TEMPLATES table.

create or replace view dba_repcat_refresh_templates as
select refresh_template_name,owner,refresh_group_name,template_comment,
 nvl(public_template,'N') public_template
from system.repcat$_refresh_templates t,
  system.repcat$_template_types tt
where tt.template_type_id = t.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
/

comment on column DBA_REPCAT_REFRESH_TEMPLATES.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/
 
comment on column DBA_REPCAT_REFRESH_TEMPLATES.OWNER is
'Owner of the refresh group template.'
/
 
comment on column DBA_REPCAT_REFRESH_TEMPLATES.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/
 
comment on column DBA_REPCAT_REFRESH_TEMPLATES.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/
 
comment on column DBA_REPCAT_REFRESH_TEMPLATES.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/

create or replace public synonym dba_repcat_refresh_templates for 
dba_repcat_refresh_templates
/

grant select on dba_repcat_refresh_templates to select_catalog_role
/

create table system.repcat$_user_authorizations
(user_authorization_id number not null,
 constraint repcat$_user_authorizations_pk primary key (user_authorization_id),
 user_id number not null,
 refresh_template_id number not null,
 constraint repcat$_user_authorization_fk2 foreign key (refresh_template_id)
 references system.repcat$_refresh_templates on delete cascade,
 constraint repcat$_user_authorizations_u1 unique
 (user_id,refresh_template_id)
 )
/

create index system.repcat$_user_authorizations_n1 on 
  system.repcat$_user_authorizations(refresh_template_id)
/

comment on column system.repcat$_USER_AUTHORIZATIONS.USER_AUTHORIZATION_ID is
'Internal primary key of the REPCAT$_USER_AUTHORIZATIONS table.'
/
 
comment on column system.repcat$_USER_AUTHORIZATIONS.USER_ID is
'Database user id.'
/
 
comment on column system.repcat$_USER_AUTHORIZATIONS.REFRESH_TEMPLATE_ID is
'Internal primary key of the REPCAT$_REFRESH_TEMPLATES table.'
/

create sequence system.repcat$_user_authorizations_s
/


create or replace view dba_repcat_user_authorizations
(refresh_template_name,owner,refresh_group_name,
 template_comment,public_template,user_name) as 
select rt.refresh_template_name,rt.owner,rt.refresh_group_name,
rt.template_comment, nvl(rt.public_template,'N'),
u.username
from system.repcat$_refresh_templates rt,
all_users u,
system.repcat$_user_authorizations ra,
system.repcat$_template_types tt
where u.user_id = ra.user_id
and ra.refresh_template_id = rt.refresh_template_id
and tt.template_type_id = rt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
/

comment on column DBA_REPCAT_USER_AUTHORIZATIONS.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/
 
comment on column DBA_REPCAT_USER_AUTHORIZATIONS.OWNER is
'Owner of the refresh group template.'
/
 
comment on column DBA_REPCAT_USER_AUTHORIZATIONS.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/
 
comment on column DBA_REPCAT_USER_AUTHORIZATIONS.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/
 
comment on column DBA_REPCAT_USER_AUTHORIZATIONS.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/
 
comment on column DBA_REPCAT_USER_AUTHORIZATIONS.USER_NAME is
'Database user name.'
/

create or replace public synonym dba_repcat_user_authorizations
   for dba_repcat_user_authorizations
/


grant select on DBA_REPCAT_USER_AUTHORIZATIONS to select_catalog_role
/


-- all_ view on repcat$_user_authorizations
create or replace view all_repcat_user_authorizations
(refresh_template_name,owner,refresh_group_name,
 template_comment,public_template,user_name) as 
select rt.refresh_template_name,rt.owner,rt.refresh_group_name,
rt.template_comment, nvl(rt.public_template,'N'),
u.username
from system.repcat$_refresh_templates rt,
  all_users u,
  system.repcat$_user_authorizations ra,
  system.repcat$_template_types tt
where u.user_id = ra.user_id
and ra.refresh_template_id = rt.refresh_template_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and rt.refresh_template_id in 
  (select rt.refresh_template_id 
  from system.repcat$_refresh_templates
  where public_template = 'Y'
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt,
  system.repcat$_user_authorizations at,
  sys.all_users au
  where at.refresh_template_id = rt.refresh_template_id
  and au.user_id = at.user_id
  and nvl(rt.public_template,'N') = 'N'
  and au.user_id = userenv('SCHEMAID')
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt
  where nvl(rt.public_template,'N') = 'N'
  and exists 
    (select 1 from v$enabledprivs
     where priv_number in (-174 /* alter any snapshot */))
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt, sys.user$ u
  where  nvl(rt.public_template,'N') = 'N'
  and rt.owner =  u.name
  and u.user#  =  userenv('SCHEMAID'))
/


comment on column ALL_REPCAT_USER_AUTHORIZATIONS.OWNER is
'Owner of the refresh group template.'
/

comment on column ALL_REPCAT_USER_AUTHORIZATIONS.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/

comment on column ALL_REPCAT_USER_AUTHORIZATIONS.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column ALL_REPCAT_USER_AUTHORIZATIONS.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column ALL_REPCAT_USER_AUTHORIZATIONS.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/

comment on column ALL_REPCAT_USER_AUTHORIZATIONS.USER_NAME is
'Database user name.'
/

create or replace public synonym all_repcat_user_authorizations for 
all_repcat_user_authorizations
/

grant select on all_repcat_user_authorizations to public with grant option
/


--user view on repcat$_user_authorizations
create or replace view user_repcat_user_authorization
(refresh_template_name,owner,refresh_group_name,
 template_comment,public_template,user_name) as 
select rt.refresh_template_name,rt.owner,rt.refresh_group_name,
  rt.template_comment, nvl(rt.public_template,'N'),
  u.username
from system.repcat$_refresh_templates rt,
  all_users u,
  system.repcat$_user_authorizations ra,
  system.repcat$_template_types tt
where u.user_id = ra.user_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and ra.refresh_template_id = rt.refresh_template_id
and rt.refresh_template_id in 
  (select rt.refresh_template_id
   from system.repcat$_refresh_templates rt
   where public_template = 'Y'
   union
   select rt.refresh_template_id
   from system.repcat$_refresh_templates rt,
   system.repcat$_user_authorizations at,
   sys.all_users au
   where at.refresh_template_id = rt.refresh_template_id
   and au.user_id = at.user_id
   and nvl(rt.public_template,'N') = 'N'
   and au.user_id = userenv('SCHEMAID'))
/


comment on column USER_REPCAT_USER_AUTHORIZATION.OWNER is
'Owner of the refresh group template.'
/

comment on column USER_REPCAT_USER_AUTHORIZATION.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/

comment on column USER_REPCAT_USER_AUTHORIZATION.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column USER_REPCAT_USER_AUTHORIZATION.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column USER_REPCAT_USER_AUTHORIZATION.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/

comment on column USER_REPCAT_USER_AUTHORIZATION.USER_NAME is
'Database user name.'
/

create or replace public synonym user_repcat_user_authorization for 
user_repcat_user_authorization
/


grant select on user_repcat_user_authorization to public with grant option
/


-- all_ view on repcat$_refresh_templates table

create or replace view all_repcat_refresh_templates as 
select refresh_template_name,owner,refresh_group_name,template_comment,
 nvl(public_template,'N') public_template
from system.repcat$_refresh_templates rt,
  system.repcat$_template_types tt
where public_template = 'Y'
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1 
union
select refresh_template_name,owner,refresh_group_name,template_comment,
 nvl(public_template,'N') public_template
from system.repcat$_refresh_templates rt,
  system.repcat$_user_authorizations at,
  sys.all_users au,
  system.repcat$_template_types tt
where at.refresh_template_id = rt.refresh_template_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1 
and au.user_id = at.user_id
and nvl(rt.public_template,'N') = 'N'
and au.user_id = userenv('SCHEMAID') 
union
select refresh_template_name,owner,refresh_group_name,template_comment,
 nvl(public_template,'N') public_template
from system.repcat$_refresh_templates rt,
  system.repcat$_template_types tt
where nvl(rt.public_template,'N') = 'N'
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and exists 
  (select 1 from v$enabledprivs
   where priv_number in (-174 /* alter any snapshot */))
union
select refresh_template_name,owner,refresh_group_name,template_comment,
 nvl(public_template,'N') public_template
from system.repcat$_refresh_templates rt,
  system.repcat$_template_types tt, sys.user$ u
where  nvl(rt.public_template,'N') = 'N'
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and rt.owner = u.name
and u.user# = userenv('SCHEMAID')
/


comment on column ALL_REPCAT_REFRESH_TEMPLATES.OWNER is
'Owner of the refresh group template.'
/

comment on column ALL_REPCAT_REFRESH_TEMPLATES.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/

comment on column ALL_REPCAT_REFRESH_TEMPLATES.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column ALL_REPCAT_REFRESH_TEMPLATES.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column ALL_REPCAT_REFRESH_TEMPLATES.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/

create or replace public synonym all_repcat_refresh_templates for
all_repcat_refresh_templates
/

grant select on all_repcat_refresh_templates to public with grant option
/


-- user view on repcat$_refresh_templates table

create or replace view user_repcat_refresh_templates as
select refresh_template_name,owner,refresh_group_name,template_comment,
 nvl(public_template,'N') public_template
from system.repcat$_refresh_templates rt,
  system.repcat$_template_types tt
where public_template = 'Y'
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
union
select refresh_template_name,owner,refresh_group_name,template_comment,
 nvl(public_template,'N') public_template
from system.repcat$_refresh_templates rt,
  system.repcat$_user_authorizations at,
  sys.all_users au,
  system.repcat$_template_types tt
where at.refresh_template_id = rt.refresh_template_id
and au.user_id = at.user_id
and nvl(rt.public_template,'N') = 'N'
and au.user_id = userenv('SCHEMAID') 
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
/


comment on column USER_REPCAT_REFRESH_TEMPLATES.OWNER is
'Owner of the refresh group template.'
/

comment on column USER_REPCAT_REFRESH_TEMPLATES.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/

comment on column USER_REPCAT_REFRESH_TEMPLATES.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column USER_REPCAT_REFRESH_TEMPLATES.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column USER_REPCAT_REFRESH_TEMPLATES.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/

create or replace public synonym user_repcat_refresh_templates for
user_repcat_refresh_templates
/

grant select on user_repcat_refresh_templates to public with grant option
/


-- repcat$_object_types
create table system.repcat$_object_types
(object_type_id number,
   constraint repcat$_object_type_pk primary key (object_type_id),
object_type_name varchar2(200),
flags raw(255),
spare1 varchar2(4000))
/

comment on table SYSTEM.REPCAT$_OBJECT_TYPES is 
'Internal table for template object types.'
/

comment on column SYSTEM.REPCAT$_OBJECT_TYPES.OBJECT_TYPE_ID is 
'Internal primary key of the template object types table.'  
/  
  
comment on column SYSTEM.REPCAT$_OBJECT_TYPES.OBJECT_TYPE_NAME is 
'Descriptive name for the object type.'  
/  
  
--# SYSTEM.REPCAT$_OBJECT_TYPES.FLAGS
-- '01' : accessible to regular templates
-- '02' : accessible to iAS
-- '00' : unsupported
comment on column SYSTEM.REPCAT$_OBJECT_TYPES.FLAGS is 
'Internal flags for object type processing.'  
/  
  
comment on column SYSTEM.REPCAT$_OBJECT_TYPES.SPARE1 is 
'Reserved for future use.'  
/  
  

-- seed data for repcat$_object_types
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1017,'GENERATED DDL',hextoraw('02')                          
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1017)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1016,'DUMMY MATERIALIZED VIEW',hextoraw('02')                          
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1016)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1015,'UPDATABLE MATERIALIZED VIEW LOG',hextoraw('02')                 
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1015)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1014,'REFRESH GROUP',hextoraw('02')                          
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1014)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1013,'SYNCHRONOUS MASTER REPGROUP',hextoraw('02')                    
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1013)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1012,'ASYNCHRONOUS MASTER REPGROUP',hextoraw('02')                   
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1012)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1011,'TEMPORARY TABLE',hextoraw('02')                             
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1011)                         
/                                         
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1005,'SYNCHRONOUS UPDATABLE TABLE',hextoraw('02')              
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1005)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1004,'ASYNCHRONOUS UPDATABLE TABLE',hextoraw('00')             
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1004)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1003,'READ ONLY TABLE',hextoraw('02')                          
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1003)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1002,'SITEOWNER',hextoraw('02')                            
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1002)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1001,'USER',hextoraw('02')                               
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1001)                         
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -5,'DATABASE LINK',hextoraw('01')                             
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -5)                          
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select -1,'MATERIALIZED VIEW',hextoraw('01')                           
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = -1)                          
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 1,'INDEX',hextoraw('01')                                
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 1)                           
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 2,'TABLE',hextoraw('01')                                
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 2)                           
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 4,'VIEW',hextoraw('03')                                 
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 4)                           
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 5,'SYNONYM',hextoraw('01')                                
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 5)                           
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 6,'SEQUENCE',hextoraw('03')                               
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 6)                           
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 7,'PROCEDURE',hextoraw('03')                              
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 7)                           
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 8,'FUNCTION',hextoraw('03')                               
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 8)                           
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 9,'PACKAGE',hextoraw('03')                                
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 9)                           
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 10,'PACKAGE BODY',hextoraw('01')                            
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 10)                          
/                                         
                                        
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 12,'TRIGGER',hextoraw('01')                               
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 12)                          
/                                         
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 13,'TYPE',hextoraw('03')                               
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 13)                          
/                                         
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 14,'TYPE BODY',hextoraw('01')                               
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 14)                          
/                                         
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 32,'INDEX TYPE',hextoraw('01')                               
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 32)                          
/                                         
insert into system.repcat$_object_types                     
(object_type_id,object_type_name, flags)                         
select 33,'OPERATOR',hextoraw('01')                               
from dual                                     
where not exists                                
  (select 1 from system.repcat$_object_types                  
  where object_type_id = 33)                          
/                                         

-- repcat$_template_refgroups
create table system.repcat$_template_refgroups
(refresh_group_id number not null,
   constraint repcat$_template_refgroups_pk primary key (refresh_group_id),
refresh_group_name varchar2(30) not null,
refresh_template_id number not null,
   constraint repcat$_template_refgroups_fk1 foreign key (refresh_template_id)
     references system.repcat$_refresh_templates on delete cascade,
rollback_seg varchar2(30),
start_date varchar2(200),
interval varchar2(200))
/

create sequence system.repcat$_template_refgroups_s
/

create index system.repcat$_template_refgroups_n1 on 
  system.repcat$_template_refgroups(refresh_group_name)
/

create index system.repcat$_template_refgroups_n2 on 
  system.repcat$_template_refgroups(refresh_template_id)
/

comment on table SYSTEM.REPCAT$_TEMPLATE_REFGROUPS is
'Table for maintaining refresh group information for template.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_REFGROUPS.REFRESH_GROUP_ID is 
'Internal primary key of the refresh groups table.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_REFGROUPS.REFRESH_GROUP_NAME is 
'Name of the refresh group'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_REFGROUPS.REFRESH_TEMPLATE_ID is 
'Primary key of the template containing the refresh group.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_REFGROUPS.ROLLBACK_SEG is 
'Name of the rollback segment to use during refresh.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_REFGROUPS.START_DATE is 
'Refresh start date.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_REFGROUPS.INTERVAL is 
'Refresh interval.'  
/  
 
create or replace view dba_template_refgroups 
(refresh_group_id,refresh_group_name,refresh_template_id,refresh_template_name,
rollback_seg, start_date, interval) as
select rg.refresh_group_id, rg.refresh_group_name, rt.refresh_template_id,
  rt.refresh_template_name, rg.rollback_seg, rg.start_date, rg.interval
from system.repcat$_refresh_templates rt,
  system.repcat$_template_refgroups rg,
  system.repcat$_template_types tt
where rt.refresh_template_id = rg.refresh_template_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
/

comment on table DBA_TEMPLATE_REFGROUPS is
'Table for maintaining refresh group information for template.'
/

comment on column DBA_TEMPLATE_REFGROUPS.REFRESH_GROUP_ID is 
'Internal primary key of the refresh groups table.'  
/  
 
comment on column DBA_TEMPLATE_REFGROUPS.REFRESH_GROUP_NAME is 
'Name of the refresh group'  
/  
 
comment on column DBA_TEMPLATE_REFGROUPS.REFRESH_TEMPLATE_ID is 
'Primary key of the template containing the refresh group.'  
/  

comment on column DBA_TEMPLATE_REFGROUPS.REFRESH_TEMPLATE_NAME is
'Name of the deployment template containing the refresh group.'
/
 
comment on column DBA_TEMPLATE_REFGROUPS.ROLLBACK_SEG is 
'Name of the rollback segment to use during refresh.'  
/  
 
comment on column DBA_TEMPLATE_REFGROUPS.START_DATE is 
'Refresh start date.'  
/  
 
comment on column DBA_TEMPLATE_REFGROUPS.INTERVAL is 
'Refresh interval.'  
/  

create or replace public synonym dba_template_refgroups
   for dba_template_refgroups
/

grant select on dba_template_refgroups to select_catalog_role
/

-- repcat$_template_objects table
create table system.repcat$_template_objects
(template_object_id number not null,
   constraint repcat$_template_objects_pk primary key (template_object_id),
 refresh_template_id number not null,
   constraint repcat$_template_objects_fk1 foreign key (refresh_template_id)
   references system.repcat$_refresh_templates on delete cascade,
 object_name varchar2(30) not null,
 object_type number not null,
   constraint repcat$_template_objects_fk3 foreign key (object_type)
     references system.repcat$_object_types,
 object_version#   NUMBER CONSTRAINT repcat$_template_objects_ver
                     CHECK (object_version# >= 0 AND object_version# < 65536),
 ddl_text clob,
 master_rollback_seg varchar2(30),
 derived_from_sname varchar2(30),
 derived_from_oname varchar2(30),
 flavor_id number,
 schema_name varchar2(30),
 ddl_num number default 1 not null,
   -- constraint repcat$_template_object_fk2 foreign key (flavor_id)
   -- references system.repcat$_flavors on delete cascade,
 constraint repcat$_template_objects_u1 unique 
   (object_name,object_type,refresh_template_id,schema_name, ddl_num),
 template_refgroup_id number default 0 not null,
   -- constraint repcat$_template_objects_fk4 foreign key (refresh_template_id)
   --   references system.repcat$_template_refgroups 
 flags raw(255),
 spare1 varchar2(4000)
)
/

create index system.repcat$_template_objects_n1 on 
  system.repcat$_template_objects (refresh_template_id, object_type)
/

comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.TEMPLATE_OBJECT_ID is
'Internal primary key of the REPCAT$_TEMPLATE_OBJECTS table.'
/
 
comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.REFRESH_TEMPLATE_ID is
'Internal primary key of the REPCAT$_REFRESH_TEMPLATES table.'
/
 
comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.OBJECT_NAME is
'Name of the database object.'
/
 
comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.OBJECT_TYPE is
'Type of database object.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.OBJECT_VERSION# is
'Version# of database object of TYPE.'
/
 
comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.DDL_TEXT is
'DDL string for creating the object or WHERE clause for snapshot query.'
/
 
comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.MASTER_ROLLBACK_SEG is
'Rollback segment for use during snapshot refreshes.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.DERIVED_FROM_SNAME is
'Schema name of schema containing object this was derived from.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.DERIVED_FROM_ONAME is
'Object name of object this object was derived from.'
/
 
comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.FLAVOR_ID is
'Foreign key to the REPCAT$_FLAVORS table.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.DDL_NUM is
'Order of ddls to execute.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.SCHEMA_NAME is 
'Schema containing the object.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.TEMPLATE_REFGROUP_ID is 
'Internal ID of the refresh group to contain the object.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.FLAGS is 
'Internal flags for the object.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_OBJECTS.SPARE1 is 
'Reserved for future use.'  
/  
 
create sequence system.repcat$_template_objects_s
/


create or replace view dba_repcat_template_objects 
(refresh_template_name,object_name,object_type,
ddl_num, ddl_text, master_rollback_segment,
derived_from_sname, derived_from_oname,flavor_id) as
select rt.refresh_template_name,
t.object_name, ot.object_type_name object_type, 
t.ddl_num,t.ddl_text,t.master_rollback_seg,
t.derived_from_sname,t.derived_from_oname,t.flavor_id
from system.repcat$_refresh_templates rt,
  system.repcat$_template_objects t,
  system.repcat$_object_types ot,
  system.repcat$_template_types tt
where t.refresh_template_id = rt.refresh_template_id
and ot.object_type_id = t.object_type
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
/

comment on column DBA_REPCAT_TEMPLATE_OBJECTS.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/
 
comment on column DBA_REPCAT_TEMPLATE_OBJECTS.OBJECT_NAME is
'Name of the database object.'
/
 
comment on column DBA_REPCAT_TEMPLATE_OBJECTS.OBJECT_TYPE is
'Type of database object.'
/
 

comment on column DBA_REPCAT_TEMPLATE_OBJECTS.DDL_NUM is
'Order of DDLs for creating the object.'
/
 
comment on column DBA_REPCAT_TEMPLATE_OBJECTS.DDL_TEXT is
'DDL string for creating the object or WHERE clause for snapshot query.'
/
 
comment on column DBA_REPCAT_TEMPLATE_OBJECTS.MASTER_ROLLBACK_SEGMENT is
'Rollback segment for use during snapshot refreshes.'
/
 
comment on column DBA_REPCAT_TEMPLATE_OBJECTS.DERIVED_FROM_SNAME is
'Schema name of schema containing object this was derived from.'
/

comment on column DBA_REPCAT_TEMPLATE_OBJECTS.DERIVED_FROM_ONAME is
'Object name of object this object was derived from.'
/

comment on column DBA_REPCAT_TEMPLATE_OBJECTS.FLAVOR_ID is
'Foreign key to the REPCAT$_FLAVORS table.'
/

create or replace public synonym dba_repcat_template_objects for 
dba_repcat_template_objects
/


grant select on DBA_REPCAT_TEMPLATE_OBJECTS to select_catalog_role
/


-- all_ view on repcat$_template_objects
create or replace view all_repcat_template_objects 
(refresh_template_name,object_name,object_type,
ddl_num, ddl_text, master_rollback_segment,
derived_from_sname, derived_from_oname,flavor_id) as
select rt.refresh_template_name,
t.object_name, ot.object_type_name object_type, 
t.ddl_num, t.ddl_text,t.master_rollback_seg,
t.derived_from_sname,t.derived_from_oname,t.flavor_id
from system.repcat$_refresh_templates rt,
  system.repcat$_template_objects t,
  system.repcat$_object_types ot,
  system.repcat$_template_types tt
where t.refresh_template_id = rt.refresh_template_id
and  ot.object_type_id = t.object_type
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and rt.refresh_template_id in 
  (select rt.refresh_template_id 
  from system.repcat$_refresh_templates
  where public_template = 'Y'
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt,
  system.repcat$_user_authorizations at,
  sys.all_users au
  where at.refresh_template_id = rt.refresh_template_id
  and au.user_id = at.user_id
  and nvl(rt.public_template,'N') = 'N'
  and au.user_id = userenv('SCHEMAID') 
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt
  where nvl(rt.public_template,'N') = 'N'
  and exists 
    (select 1 from v$enabledprivs
     where priv_number in (-174 /* alter any snapshot */))
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt, sys.user$ u
  where  nvl(rt.public_template,'N') = 'N'
  and rt.owner =  u.name
  and u.user#  = userenv('SCHEMAID'))
/


comment on column ALL_REPCAT_TEMPLATE_OBJECTS.DDL_NUM is
'Order of DDLs for creating the object.'
/

comment on column ALL_REPCAT_TEMPLATE_OBJECTS.DDL_TEXT is
'DDL string for creating the object or WHERE clause for snapshot query.'
/

comment on column ALL_REPCAT_TEMPLATE_OBJECTS.DERIVED_FROM_ONAME is
'Object name of object this object was derived from.'
/

comment on column ALL_REPCAT_TEMPLATE_OBJECTS.DERIVED_FROM_SNAME is
'Schema name of schema containing object this was derived from.'
/

comment on column ALL_REPCAT_TEMPLATE_OBJECTS.FLAVOR_ID is
'Foreign key to the REPCAT$_FLAVORS table.'
/

comment on column ALL_REPCAT_TEMPLATE_OBJECTS.MASTER_ROLLBACK_SEGMENT is
'Rollback segment for use during snapshot refreshes.'
/

comment on column ALL_REPCAT_TEMPLATE_OBJECTS.OBJECT_NAME is
'Name of the database object.'
/

comment on column ALL_REPCAT_TEMPLATE_OBJECTS.OBJECT_TYPE is
'Type of database object.'
/


comment on column ALL_REPCAT_TEMPLATE_OBJECTS.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

create or replace public synonym all_repcat_template_objects for
all_repcat_template_objects
/

grant select on all_repcat_template_objects to public
with grant option
/


-- user_ view on repcat$_template_objects

create or replace view user_repcat_template_objects 
(refresh_template_name,object_name,object_type,
ddl_num, ddl_text, master_rollback_segment,
derived_from_sname, derived_from_oname,flavor_id) as
select rt.refresh_template_name,
t.object_name, ot.object_type_name object_type, 
t.ddl_num, t.ddl_text,t.master_rollback_seg,
t.derived_from_sname,t.derived_from_oname,t.flavor_id
from system.repcat$_refresh_templates rt,
  system.repcat$_template_objects t,
  system.repcat$_object_types ot,
 system.repcat$_template_types tt 
where t.refresh_template_id = rt.refresh_template_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and ot.object_type_id = t.object_type
and rt.refresh_template_id in 
  (select rt.refresh_template_id
   from system.repcat$_refresh_templates rt
   where public_template = 'Y'
   union
   select rt.refresh_template_id
   from system.repcat$_refresh_templates rt,
   system.repcat$_user_authorizations at,
   sys.all_users au
   where at.refresh_template_id = rt.refresh_template_id
   and au.user_id = at.user_id
   and nvl(rt.public_template,'N') = 'N'
   and au.user_id = userenv('SCHEMAID'))
/


comment on column USER_REPCAT_TEMPLATE_OBJECTS.DDL_NUM is
'Order of DDLs for creating the object.'
/

comment on column USER_REPCAT_TEMPLATE_OBJECTS.DDL_TEXT is
'DDL string for creating the object or WHERE clause for snapshot query.'
/

comment on column USER_REPCAT_TEMPLATE_OBJECTS.DERIVED_FROM_ONAME is
'Object name of object this object was derived from.'
/

comment on column USER_REPCAT_TEMPLATE_OBJECTS.DERIVED_FROM_SNAME is
'Schema name of schema containing object this was derived from.'
/

comment on column USER_REPCAT_TEMPLATE_OBJECTS.FLAVOR_ID is
'Foreign key to the REPCAT$_FLAVORS table.'
/

comment on column USER_REPCAT_TEMPLATE_OBJECTS.MASTER_ROLLBACK_SEGMENT is
'Rollback segment for use during snapshot refreshes.'
/

comment on column USER_REPCAT_TEMPLATE_OBJECTS.OBJECT_NAME is
'Name of the database object.'
/

comment on column USER_REPCAT_TEMPLATE_OBJECTS.OBJECT_TYPE is
'Type of database object.'
/


comment on column USER_REPCAT_TEMPLATE_OBJECTS.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

create or replace public synonym user_repcat_template_objects for
user_repcat_template_objects
/

grant select on user_repcat_template_objects to public
with grant option
/

-- repcat$_template_parms table

create table system.repcat$_template_parms
(template_parameter_id number,
 constraint repcat$_template_parms_pk primary key (template_parameter_id),
 refresh_template_id number not null,
 constraint repcat$_template_parms_fk1 foreign key (refresh_template_id)
 references system.repcat$_refresh_templates on delete cascade, 
 parameter_name varchar2(30) not null,
 default_parm_value clob,
 prompt_string varchar2(2000),
 user_override varchar2(1) default 'Y',
 constraint repcat$_template_parms_c1 check (user_override in ('Y','N')),
 constraint repcat$_template_parms_u1 unique (refresh_template_id, 
   parameter_name))
/


comment on column system.repcat$_TEMPLATE_PARMS.TEMPLATE_PARAMETER_ID is
'Internal primary key of the REPCAT$_TEMPLATE_PARMS table.'
/
 
comment on column system.repcat$_TEMPLATE_PARMS.REFRESH_TEMPLATE_ID is
'Internal primary key of the REPCAT$_REFRESH_TEMPLATES table.'
/
 
comment on column system.repcat$_TEMPLATE_PARMS.PARAMETER_NAME is
'name of the parameter.'
/
 
comment on column system.repcat$_TEMPLATE_PARMS.DEFAULT_PARM_VALUE is
'Default value for the parameter.'
/
 
comment on column system.repcat$_TEMPLATE_PARMS.PROMPT_STRING is
'String for use in prompting for parameter values.'
/

comment on column system.REPCAT$_TEMPLATE_PARMS.USER_OVERRIDE is
'User override flag.'
/

-- Sequence used to populate the primary key of the 
-- REPCAT$_TEMPLATE_PARMS table.

create sequence system.repcat$_template_parms_s
/


-- DBA view on the REPCAT$_TEMPLATE_PARMS table.

create or replace view dba_repcat_template_parms 
(refresh_template_name,owner,refresh_group_name,
 template_comment,public_template,parameter_name,
 default_parm_value,prompt_string,user_override) as
select rt.refresh_template_name,rt.owner,
  rt.refresh_group_name,rt.template_comment,
  nvl(rt.public_template,'N'),tp.parameter_name,
  tp.default_parm_value, tp.prompt_string, tp.user_override
from system.repcat$_refresh_templates rt,
  system.repcat$_template_parms tp,
  system.repcat$_template_types tt
where tp.refresh_template_id = rt.refresh_template_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
/


comment on column DBA_REPCAT_TEMPLATE_PARMS.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/
 
comment on column DBA_REPCAT_TEMPLATE_PARMS.OWNER is
'Owner of the refresh group template.'
/
 
comment on column DBA_REPCAT_TEMPLATE_PARMS.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/
 
comment on column DBA_REPCAT_TEMPLATE_PARMS.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/
 
comment on column DBA_REPCAT_TEMPLATE_PARMS.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/
 
comment on column DBA_REPCAT_TEMPLATE_PARMS.PARAMETER_NAME is
'name of the parameter.'
/
 
comment on column DBA_REPCAT_TEMPLATE_PARMS.DEFAULT_PARM_VALUE is
'Default value for the parameter.'
/
 
comment on column DBA_REPCAT_TEMPLATE_PARMS.PROMPT_STRING is
'String for use in prompting for parameter values.'
/

comment on column DBA_REPCAT_TEMPLATE_PARMS.USER_OVERRIDE is
'User override flag.'
/

create or replace public synonym dba_repcat_template_parms
   for dba_repcat_template_parms
/

grant select on dba_repcat_template_parms to select_catalog_role
/

-- all_ view on repcat$_template_parms 

create or replace view all_repcat_template_parms 
(refresh_template_name,owner,refresh_group_name,
 template_comment,public_template,parameter_name,
 default_parm_value,prompt_string,user_override) as
select rt.refresh_template_name,rt.owner,
rt.refresh_group_name,rt.template_comment,
nvl(rt.public_template,'N'),tp.parameter_name,
tp.default_parm_value, tp.prompt_string, tp.user_override
from system.repcat$_refresh_templates rt,
  system.repcat$_template_parms tp,
  system.repcat$_template_types tt
where tp.refresh_template_id = rt.refresh_template_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and rt.refresh_template_id in 
  (select rt.refresh_template_id 
  from system.repcat$_refresh_templates
  where public_template = 'Y'
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt,
  system.repcat$_user_authorizations at,
  sys.all_users au
  where at.refresh_template_id = rt.refresh_template_id
  and au.user_id = at.user_id
  and nvl(rt.public_template,'N') = 'N'
  and au.user_id = userenv('SCHEMAID')
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt
  where nvl(rt.public_template,'N') = 'N'
  and exists 
    (select 1 from v$enabledprivs
     where priv_number in (-174 /* alter any snapshot */))
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt, sys.user$ u
  where  nvl(rt.public_template,'N') = 'N'
  and rt.owner = u.name
  and u.user#  = userenv('SCHEMAID') )
/


comment on column ALL_REPCAT_TEMPLATE_PARMS.DEFAULT_PARM_VALUE is
'Default value for the parameter.'
/

comment on column ALL_REPCAT_TEMPLATE_PARMS.OWNER is
'Owner of the refresh group template.'
/

comment on column ALL_REPCAT_TEMPLATE_PARMS.PARAMETER_NAME is
'name of the parameter.'
/

comment on column ALL_REPCAT_TEMPLATE_PARMS.PROMPT_STRING is
'String for use in prompting for parameter values.'
/

comment on column ALL_REPCAT_TEMPLATE_PARMS.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/

comment on column ALL_REPCAT_TEMPLATE_PARMS.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column ALL_REPCAT_TEMPLATE_PARMS.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column ALL_REPCAT_TEMPLATE_PARMS.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/

comment on column ALL_REPCAT_TEMPLATE_PARMS.USER_OVERRIDE is
'User override flag.'
/

create or replace public synonym all_repcat_template_parms for 
all_repcat_template_parms
/

grant select on all_repcat_template_parms to public with grant option
/


-- user_ view on repcat$_template_parms
create or replace view user_repcat_template_parms 
(refresh_template_name,owner,refresh_group_name,
 template_comment,public_template,parameter_name,
 default_parm_value,prompt_string,user_override) as
select rt.refresh_template_name,rt.owner,
  rt.refresh_group_name,rt.template_comment,
  nvl(rt.public_template,'N'),tp.parameter_name,
  tp.default_parm_value, tp.prompt_string, tp.user_override
from system.repcat$_refresh_templates rt,
  system.repcat$_template_parms tp,
  system.repcat$_template_types tt
where tp.refresh_template_id = rt.refresh_template_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and rt.refresh_template_id in 
  (select rt.refresh_template_id
   from system.repcat$_refresh_templates rt
   where public_template = 'Y'
   union
   select rt.refresh_template_id
   from system.repcat$_refresh_templates rt,
   system.repcat$_user_authorizations at,
   sys.all_users au
   where at.refresh_template_id = rt.refresh_template_id
   and au.user_id = at.user_id
   and nvl(rt.public_template,'N') = 'N'
   and au.user_id = userenv('SCHEMAID'))
/


comment on column USER_REPCAT_TEMPLATE_PARMS.DEFAULT_PARM_VALUE is
'Default value for the parameter.'
/

comment on column USER_REPCAT_TEMPLATE_PARMS.OWNER is
'Owner of the refresh group template.'
/

comment on column USER_REPCAT_TEMPLATE_PARMS.PARAMETER_NAME is
'name of the parameter.'
/

comment on column USER_REPCAT_TEMPLATE_PARMS.PROMPT_STRING is
'String for use in prompting for parameter values.'
/

comment on column USER_REPCAT_TEMPLATE_PARMS.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/

comment on column USER_REPCAT_TEMPLATE_PARMS.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column USER_REPCAT_TEMPLATE_PARMS.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column USER_REPCAT_TEMPLATE_PARMS.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/

comment on column USER_REPCAT_TEMPLATE_PARMS.USER_OVERRIDE is
'User override flag.'
/

create or replace public synonym user_repcat_template_parms for 
user_repcat_template_parms
/

grant select on user_repcat_template_parms to public with grant option
/

-- table for tracking which objects use which paramters
create table system.repcat$_object_parms 
(template_parameter_id number not null,
 constraint repcat$_object_parms_fk1 foreign key (template_parameter_id)
 references system.repcat$_template_parms,
 template_object_id number not null,
 constraint repcat$_object_parms_fk2 foreign key (template_object_id)
 references system.repcat$_template_objects on delete cascade,
 constraint repcat$_object_parms_pk primary key 
   (template_parameter_id,template_object_id))
/

 
comment on column system.repcat$_object_parms.template_parameter_id is 
'Primary key of template parameter.'
/

comment on column system.repcat$_object_parms.template_object_id is 
'Primary key of object using the paramter.'
/

create index system.repcat$_object_parms_n2 on 
  system.repcat$_object_parms(template_object_id)
/

--  storing parameters for each template/site

create table system.repcat$_user_parm_values
(user_parameter_id number,
  constraint repcat$_user_parm_values_pk primary key (user_parameter_id),
 template_parameter_id number not null,
  constraint repcat$_user_parm_values_fk1 foreign key (template_parameter_id)
   references system.repcat$_template_parms on delete cascade,
  user_id number not null,
  parm_value clob,
  constraint repcat$_user_parm_values_u1 unique (template_parameter_id,user_id))
/


comment on column system.repcat$_USER_PARM_VALUES.USER_PARAMETER_ID is
'Internal primary key of the REPCAT$_USER_PARM_VALUES table.'
/
 
comment on column system.repcat$_USER_PARM_VALUES.TEMPLATE_PARAMETER_ID is
'Internal primary key of the REPCAT$_TEMPLATE_PARMS table.'
/
 
comment on column system.repcat$_USER_PARM_VALUES.USER_ID is
'Database user id.'
/
 
comment on column system.repcat$_USER_PARM_VALUES.PARM_VALUE is
'Value of the parameter for this user.'
/

-- Sequence used to populate the primary key of the 
-- REPCAT$_USER_PARM_VALUES table.

create sequence system.repcat$_user_parm_values_s
/

-- DBA view on the REPCAT$_USER_PARM_VALUES table.

create or replace view dba_repcat_user_parm_values 
(refresh_template_name,owner,refresh_group_name,
 template_comment,public_template,parameter_name,
 default_parm_value,prompt_string,parm_value,
 user_name) as
select rt.refresh_template_name,rt.owner,
  rt.refresh_group_name,rt.template_comment,
  nvl(rt.public_template,'N'),tp.parameter_name,
  tp.default_parm_value, tp.prompt_string, sp.parm_value,
  u.username
from system.repcat$_refresh_templates rt,
  system.repcat$_template_parms tp,
  system.repcat$_user_parm_values sp,
  dba_users  u,
  system.repcat$_template_types tt
where tp.refresh_template_id = rt.refresh_template_id
and tp.template_parameter_id = sp.template_parameter_id
and sp.user_id = u.user_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
/

comment on column DBA_REPCAT_USER_PARM_VALUES.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/
 
comment on column DBA_REPCAT_USER_PARM_VALUES.OWNER is
'Owner of the refresh group template.'
/
 
comment on column DBA_REPCAT_USER_PARM_VALUES.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/
 
comment on column DBA_REPCAT_USER_PARM_VALUES.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/
 
comment on column DBA_REPCAT_USER_PARM_VALUES.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/
 
comment on column DBA_REPCAT_USER_PARM_VALUES.PARAMETER_NAME is
'name of the parameter.'
/
 
comment on column DBA_REPCAT_USER_PARM_VALUES.DEFAULT_PARM_VALUE is
'Default value for the parameter.'
/
 
comment on column DBA_REPCAT_USER_PARM_VALUES.PROMPT_STRING is
'String for use in prompting for parameter values.'
/
 
comment on column DBA_REPCAT_USER_PARM_VALUES.PARM_VALUE is
'Value of the parameter for this user.'
/
 
comment on column DBA_REPCAT_USER_PARM_VALUES.USER_NAME is
'Database user name.'
/

create or replace public synonym DBA_REPCAT_USER_PARM_VALUES
   for DBA_REPCAT_USER_PARM_VALUES
/

grant select on DBA_REPCAT_USER_PARM_VALUES to select_catalog_role
/


-- all_ view on repcat$_user_parm_values

create or replace view all_repcat_user_parm_values 
(refresh_template_name,owner,refresh_group_name,
 template_comment,public_template,parameter_name,
 default_parm_value,prompt_string,parm_value,
 user_name) as
select rt.refresh_template_name,rt.owner,
rt.refresh_group_name,rt.template_comment,
nvl(rt.public_template,'N'),tp.parameter_name,
tp.default_parm_value, tp.prompt_string, sp.parm_value,
u.username
from system.repcat$_refresh_templates rt,
  system.repcat$_template_parms tp,
  system.repcat$_user_parm_values sp,
  dba_users  u,
  system.repcat$_template_types tt
where tp.refresh_template_id = rt.refresh_template_id
and tp.template_parameter_id = sp.template_parameter_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and sp.user_id = u.user_id
and rt.refresh_template_id in 
  (select rt.refresh_template_id 
  from system.repcat$_refresh_templates
  where public_template = 'Y'
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt,
  system.repcat$_user_authorizations at,
  sys.all_users au
  where at.refresh_template_id = rt.refresh_template_id
  and au.user_id = at.user_id
  and nvl(rt.public_template,'N') = 'N'
  and au.user_id = userenv('SCHEMAID')
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt
  where nvl(rt.public_template,'N') = 'N'
  and exists 
    (select 1 from v$enabledprivs
     where priv_number in (-174 /* alter any snapshot */))
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt, sys.user$ u
  where  nvl(rt.public_template,'N') = 'N'
  and rt.owner =  u.name
  and u.user#  = userenv('SCHEMAID'))
/


comment on column ALL_REPCAT_USER_PARM_VALUES.DEFAULT_PARM_VALUE is
'Default value for the parameter.'
/

comment on column ALL_REPCAT_USER_PARM_VALUES.OWNER is
'Owner of the refresh group template.'
/

comment on column ALL_REPCAT_USER_PARM_VALUES.PARAMETER_NAME is
'name of the parameter.'
/

comment on column ALL_REPCAT_USER_PARM_VALUES.PARM_VALUE is
'Value of the parameter for this user.'
/

comment on column ALL_REPCAT_USER_PARM_VALUES.PROMPT_STRING is
'String for use in prompting for parameter values.'
/

comment on column ALL_REPCAT_USER_PARM_VALUES.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/

comment on column ALL_REPCAT_USER_PARM_VALUES.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column ALL_REPCAT_USER_PARM_VALUES.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column ALL_REPCAT_USER_PARM_VALUES.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/

comment on column ALL_REPCAT_USER_PARM_VALUES.USER_NAME is
'Database user name.'
/

create or replace public synonym all_repcat_user_parm_values for
all_repcat_user_parm_values
/

grant select on all_repcat_user_parm_values to public with grant option
/


-- user_ view on repcat_user_parm_values

create or replace view user_repcat_user_parm_values 
(refresh_template_name,owner,refresh_group_name,
 template_comment,public_template,parameter_name,
 default_parm_value,prompt_string,parm_value,
 user_name) as
select rt.refresh_template_name,rt.owner,
rt.refresh_group_name,rt.template_comment,
nvl(rt.public_template,'N'),tp.parameter_name,
tp.default_parm_value, tp.prompt_string, sp.parm_value,
u.username
from system.repcat$_refresh_templates rt,
  system.repcat$_template_parms tp,
  system.repcat$_user_parm_values sp,
  dba_users  u,
  system.repcat$_template_types tt
where tp.refresh_template_id = rt.refresh_template_id
and tp.template_parameter_id = sp.template_parameter_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and sp.user_id = u.user_id
and rt.refresh_template_id in 
  (select rt.refresh_template_id
   from system.repcat$_refresh_templates rt
   where public_template = 'Y'
   union
   select rt.refresh_template_id
   from system.repcat$_refresh_templates rt,
   system.repcat$_user_authorizations at,
   sys.all_users au
   where at.refresh_template_id = rt.refresh_template_id
   and au.user_id = at.user_id
   and nvl(rt.public_template,'N') = 'N'
   and au.user_id = userenv('SCHEMAID'))
/


comment on column USER_REPCAT_USER_PARM_VALUES.DEFAULT_PARM_VALUE is
'Default value for the parameter.'
/

comment on column USER_REPCAT_USER_PARM_VALUES.OWNER is
'Owner of the refresh group template.'
/

comment on column USER_REPCAT_USER_PARM_VALUES.PARAMETER_NAME is
'name of the parameter.'
/

comment on column USER_REPCAT_USER_PARM_VALUES.PARM_VALUE is
'Value of the parameter for this user.'
/

comment on column USER_REPCAT_USER_PARM_VALUES.PROMPT_STRING is
'String for use in prompting for parameter values.'
/

comment on column USER_REPCAT_USER_PARM_VALUES.PUBLIC_TEMPLATE is
'Flag specifying public template or private template.'
/

comment on column USER_REPCAT_USER_PARM_VALUES.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column USER_REPCAT_USER_PARM_VALUES.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column USER_REPCAT_USER_PARM_VALUES.TEMPLATE_COMMENT is
'Optional comment field for the refresh group template.'
/

comment on column USER_REPCAT_USER_PARM_VALUES.USER_NAME is
'Database user name.'
/

create or replace public synonym user_repcat_user_parm_values for
user_repcat_user_parm_values
/

grant select on user_repcat_user_parm_values to public with grant option
/


create table system.repcat$_template_sites
(template_site_id number,
 constraint repcat$_template_sites_pk primary key (template_site_id),
 refresh_template_name varchar2(30) not null,
 refresh_group_name varchar2(30),
 template_owner varchar2(30),
 user_name varchar2(30) not null,
 site_name varchar2(128),
 repapi_site_id number,
 status number not null,
 refresh_template_id number,                                     /* OBSOLETE */
 user_id number,                                                 /* OBSOLETE */
 instantiation_date date,
 constraint repcat$_template_sites_c1 check
   (status in (-100,-1,0,1)),  /* -100 used to flag IAS sites*/
 constraint repcat$_template_sites_c2 check
   ((site_name is not null and repapi_site_id is null) or
   (site_name is null and repapi_site_id is not null)),
 constraint repcat$_template_sites_u1 unique
   (refresh_template_name,user_name,site_name,repapi_site_id))
/


comment on column system.repcat$_TEMPLATE_SITES.TEMPLATE_SITE_ID is
'Internal primary key of the REPCAT$_TEMPLATE_SITES table.'
/
 
comment on column system.repcat$_TEMPLATE_SITES.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column system.repcat$_TEMPLATE_SITES.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column system.repcat$_template_sites.template_OWNER is
'Owner of the refresh group template.'
/
 
comment on column system.repcat$_template_sites.USER_NAME is
'Database user name.'
/

comment on column system.repcat$_TEMPLATE_SITES.SITE_NAME is
'Name of the site that has instantiated the template.'
/

comment on column system.repcat$_TEMPLATE_SITES.repapi_site_id is
'Name of the site that has instantiated the template.'
/

comment on column system.repcat$_TEMPLATE_SITES.STATUS is
'Status of the instantiation at the site.'
/

comment on column system.repcat$_TEMPLATE_SITES.refresh_template_id is
'Obsolete - do not use.'
/

comment on column system.repcat$_TEMPLATE_SITES.STATUS is
'Obsolete - do not use.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_SITES.USER_ID is 
'Obsolete - do not use.'  
/  

comment on column SYSTEM.REPCAT$_TEMPLATE_SITES.instantiation_date is 
'Date template was instantiated.'  
/  
 
create sequence system.repcat$_template_sites_s
/


create or replace view dba_repcat_template_sites
(refresh_template_name,refresh_group_name,template_owner,
user_name,site_name,repapi_site_name,status,instantiation_date) as
select ts.refresh_template_name, ts.refresh_group_name, ts.template_owner,
  ts.user_name,ts.site_name,ss.site_name,
  decode(status,-1,'DELETED',0,'INSTALLING',1,'INSTALLED','UNDEFINED'),
  instantiation_date
from system.repcat$_template_sites ts,
  sys.snap_site$ ss
where ts.status != -100
and ts.repapi_site_id = ss.site_id (+)
/

comment on column dba_repcat_template_sites.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column dba_repcat_template_sites.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column dba_repcat_template_sites.template_OWNER is
'Owner of the refresh group template.'
/
 
comment on column dba_repcat_template_sites.USER_NAME is
'Database user name.'
/

comment on column dba_repcat_template_sites.SITE_NAME is
'Name of the site that has instantiated the template.'
/

comment on column dba_repcat_template_sites.repapi_site_name is
'Name of the repapi site that has instantiated the template.'
/

comment on column dba_repcat_template_sites.STATUS is
'Status of the instantiation at the site.'
/

comment on column dba_repcat_template_sites.instantiation_date is
'Date template was instantiated.'
/

create or replace public synonym dba_repcat_template_sites
   for dba_repcat_template_sites
/

grant select on dba_repcat_template_sites to select_catalog_role
/


-- all_ view on repcat$_template_sites
create or replace view all_repcat_template_sites 
(refresh_template_name,refresh_group_name,template_owner,
user_name,site_name,repapi_site_name,status,instantiation_date) as
select ts.refresh_template_name, ts.refresh_group_name, ts.template_owner,
  ts.user_name,ts.site_name,ss.site_name,
  decode(status,-1,'DELETED',0,'INSTALLING',1,'INSTALLED','UNDEFINED'),
  instantiation_date
from system.repcat$_template_sites ts,
  sys.snap_site$ ss,
  system.repcat$_refresh_templates rt,
  system.repcat$_template_types tt
where ts.repapi_site_id = ss.site_id (+)
and ts.status != -100
and rt.refresh_template_name = ts.refresh_template_name
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and rt.refresh_template_id in 
  (select rt.refresh_template_id 
  from system.repcat$_refresh_templates
  where public_template = 'Y'
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt,
  system.repcat$_user_authorizations at,
  sys.all_users au
  where at.refresh_template_id = rt.refresh_template_id
  and au.user_id = at.user_id
  and nvl(rt.public_template,'N') = 'N'
  and au.user_id = userenv('SCHEMAID')
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt
  where nvl(rt.public_template,'N') = 'N'
  and exists 
    (select 1 from v$enabledprivs
     where priv_number in (-174 /* alter any snapshot */))
  union
  select rt.refresh_template_id
  from system.repcat$_refresh_templates rt, sys.user$ u
  where  nvl(rt.public_template,'N') = 'N'
  and rt.owner =  u.name
  and u.user#  = userenv('SCHEMAID'))
/


comment on column all_repcat_template_sites.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column all_repcat_template_sites.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column all_repcat_template_sites.TEMPLATE_OWNER is
'Owner of the refresh group template.'
/
 
comment on column all_repcat_template_sites.USER_NAME is
'Database user name.'
/

comment on column all_repcat_template_sites.SITE_NAME is
'Name of the site that has instantiated the template.'
/

comment on column all_repcat_template_sites.repapi_site_name is
'Name of the repapi site that has instantiated the template.'
/

comment on column all_repcat_template_sites.STATUS is
'Status of the instantiation at the site.'
/

comment on column all_repcat_template_sites.instantiation_date is
'Date template was instantiated.'
/

create or replace public synonym all_repcat_template_sites for
all_repcat_template_sites
/

grant select on all_repcat_template_sites to public with grant option
/


--user_ view on repcat$_template_sites

create or replace view user_repcat_template_sites 
(refresh_template_name,refresh_group_name,template_owner,
user_name,site_name,repapi_site_name,status, instantiation_date) as
select ts.refresh_template_name, ts.refresh_group_name, ts.template_owner,
  ts.user_name,ts.site_name,ss.site_name,
  decode(status,-1,'DELETED',0,'INSTALLING',1,'INSTALLED','UNDEFINED'),
  instantiation_date
from system.repcat$_template_sites ts,
  sys.snap_site$ ss,
  system.repcat$_refresh_templates rt,
  system.repcat$_template_types tt
where ts.repapi_site_id = ss.site_id (+)
and rt.refresh_template_name = ts.refresh_template_name
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),1) = 1
and rt.refresh_template_id in 
  (select rt.refresh_template_id
   from system.repcat$_refresh_templates rt
   where public_template = 'Y'
   union
   select rt.refresh_template_id
   from system.repcat$_refresh_templates rt,
   system.repcat$_user_authorizations at,
   sys.all_users au
   where at.refresh_template_id = rt.refresh_template_id
   and au.user_id = at.user_id
   and nvl(rt.public_template,'N') = 'N'
   and au.user_id = userenv('SCHEMAID'))
/


comment on column user_repcat_template_sites.REFRESH_TEMPLATE_NAME is
'Name of the refresh group template.'
/

comment on column user_repcat_template_sites.REFRESH_GROUP_NAME is
'Name of the refresh group to create during instantiation.'
/

comment on column user_repcat_template_sites.TEMPLATE_OWNER is
'Owner of the refresh group template.'
/
 
comment on column user_repcat_template_sites.USER_NAME is
'Database user name.'
/

comment on column user_repcat_template_sites.SITE_NAME is
'Name of the site that has instantiated the template.'
/

comment on column user_repcat_template_sites.repapi_site_name is
'Name of the repapi site that has instantiated the template.'
/

comment on column user_repcat_template_sites.STATUS is
'Status of the instantiation at the site.'
/

create or replace public synonym user_repcat_template_sites for
user_repcat_template_sites
/

grant select on user_repcat_template_sites to public with grant option
/
 
-- repcat$_site_objects
create table system.repcat$_site_objects 
(template_site_id  number not null,
   constraint repcat$_site_object_fk2 foreign key (template_site_id)
     references system.repcat$_template_sites on delete cascade,
 sname varchar2(30),
 oname varchar2(30) not null,
 object_type_id number not null,
   constraint repcat$_site_objects_fk1 foreign key (object_type_id)
     references system.repcat$_object_types,
 constraint repcat$_site_objects_u1 unique 
   (template_site_id,oname,object_type_id,sname))
/

create index system.repcat$_site_objects_n1 on 
  system.repcat$_site_objects(template_site_id)
/

-- create sequence used to populate the temp output table
create sequence system.repcat$_temp_output_s
/

comment on table SYSTEM.REPCAT$_SITE_OBJECTS is
'Table for maintaining database objects deployed at a site.'
/

comment on column SYSTEM.REPCAT$_SITE_OBJECTS.TEMPLATE_SITE_ID is 
'Internal primary key of the template sites table.'  
/  
 
comment on column SYSTEM.REPCAT$_SITE_OBJECTS.SNAME is 
'Schema containing the deployed database object.'  
/  
 
comment on column SYSTEM.REPCAT$_SITE_OBJECTS.ONAME is 
'Name of the deployed database object.'  
/  
 
comment on column SYSTEM.REPCAT$_SITE_OBJECTS.OBJECT_TYPE_ID is 
'Internal ID of the object type of the deployed database object.'  
/  

create table system.repcat$_runtime_parms
(runtime_parm_id number,
parameter_name varchar2(30),
parm_value clob)
/


comment on column SYSTEM.REPCAT$_RUNTIME_PARMS.RUNTIME_PARM_ID is
'Primary key of the parameter values table.'
/
 
comment on column SYSTEM.REPCAT$_RUNTIME_PARMS.PARAMETER_NAME is
'Name of the parameter.'
/
 
comment on column SYSTEM.REPCAT$_RUNTIME_PARMS.PARM_VALUE is
'Parameter value.'
/

-- need to create unique index to enforce the primary key constraint
-- because constraints are not supported on temp tables

create unique index system.repcat$_runtime_parms_pk on
system.repcat$_runtime_parms (runtime_parm_id,parameter_name)
/


-- sequence used to populate the table
create sequence system.repcat$_runtime_parms_s
/

create table system.repcat$_template_targets
(template_target_id number,
constraint template$_targets_pk primary key (template_target_id),
target_database varchar2(128) not null,
target_comment varchar2(2000),
connect_string varchar2(4000),
spare1 varchar2(4000))
/

create sequence system.template$_targets_s
/ 
create unique index system.repcat$_template_targets_u1 on
system.repcat$_template_targets(target_database)
/

comment on table system.repcat$_template_targets is
'Internal table for tracking potential target databases for templates.'
/

comment on column SYSTEM.REPCAT$_TEMPLATE_TARGETS.TEMPLATE_TARGET_ID is 
'Internal primary key of the template targets table.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_TARGETS.TARGET_DATABASE is 
'Global identifier of the target database.'  
/  
 
comment on column SYSTEM.REPCAT$_TEMPLATE_TARGETS.TARGET_COMMENT is 
'Comment on the target database.'  
/  
comment on column SYSTEM.REPCAT$_TEMPLATE_TARGETS.CONNECT_STRING is
'The connection descriptor used to connect to the target database.'
/
comment on column SYSTEM.REPCAT$_TEMPLATE_TARGETS.SPARE1 is
'The spare column'
/

create or replace view dba_template_targets
(template_target_id, target_database, target_comment, connect_string) as
select tt.template_target_id, tt.target_database, tt.target_comment,
       tt.connect_string
from system.repcat$_template_targets tt
/

comment on table DBA_TEMPLATE_TARGETS is
'Internal table for tracking potential target databases for templates.'
/

comment on column DBA_TEMPLATE_TARGETS.TEMPLATE_TARGET_ID is 
'Internal primary key of the template targets table.'  
/  
 
comment on column DBA_TEMPLATE_TARGETS.TARGET_DATABASE is 
'Global identifier of the target database.'  
/  
 
comment on column DBA_TEMPLATE_TARGETS.TARGET_COMMENT is 
'Comment on the target database.'  
/  

comment on column DBA_TEMPLATE_TARGETS.CONNECT_STRING is
'The connection descriptor used to connect to the target database.'
/

create or replace public synonym dba_template_targets for dba_template_targets
/

grant select on dba_template_targets to select_catalog_role
/

create table system.repcat$_exceptions
(exception_id NUMBER,
   constraint repcat$_exceptions_pk primary key (exception_id),
user_name varchar2(30),
request clob,
job number,
error_date date,
error_number number,
error_message varchar2(4000),
line_number number)
/

create sequence system.repcat$_exceptions_s
/

comment on table SYSTEM.REPCAT$_EXCEPTIONS is
'Repcat processing exceptions table.'
/

comment on column SYSTEM.REPCAT$_EXCEPTIONS.EXCEPTION_ID is 
'Internal primary key of the exceptions table.'  
/  
  
comment on column SYSTEM.REPCAT$_EXCEPTIONS.USER_NAME is 
'User name of user submitting the exception.'  
/  
  
comment on column SYSTEM.REPCAT$_EXCEPTIONS.REQUEST is 
'Originating request containing the exception.'  
/  
  
comment on column SYSTEM.REPCAT$_EXCEPTIONS.JOB is 
'Originating job containing the exception.'  
/  
  
comment on column SYSTEM.REPCAT$_EXCEPTIONS.ERROR_DATE is 
'Date of occurance for the exception.'  
/  
  
comment on column SYSTEM.REPCAT$_EXCEPTIONS.ERROR_NUMBER is 
'Error number generating the exception.'  
/  
  
comment on column SYSTEM.REPCAT$_EXCEPTIONS.ERROR_MESSAGE is 
'Error message associated with the error generating the exception.'  
/  
  
comment on column SYSTEM.REPCAT$_EXCEPTIONS.LINE_NUMBER is 
'Line number of the exception.'  
/  
  

create or replace view dba_repcat_exceptions 
(exception_id, user_name, request, job, error_date, error_number,
error_message, line_number) as
select re.exception_id, re.user_name, re.request, re.job,
  re.error_date,re.error_number,re.error_message,re.line_number
from system.repcat$_exceptions re
/

comment on table DBA_REPCAT_EXCEPTIONS is
'Repcat processing exceptions table.'
/

comment on column DBA_REPCAT_EXCEPTIONS.EXCEPTION_ID is 
'Internal primary key of the exceptions table.'  
/  
  
comment on column DBA_REPCAT_EXCEPTIONS.USER_NAME is 
'User name of user submitting the exception.'  
/  
  
comment on column DBA_REPCAT_EXCEPTIONS.REQUEST is 
'Originating request containing the exception.'  
/  
  
comment on column DBA_REPCAT_EXCEPTIONS.JOB is 
'Originating job containing the exception.'  
/  
  
comment on column DBA_REPCAT_EXCEPTIONS.ERROR_DATE is 
'Date of occurance for the exception.'  
/  
  
comment on column DBA_REPCAT_EXCEPTIONS.ERROR_NUMBER is 
'Error number generating the exception.'  
/  
  
comment on column DBA_REPCAT_EXCEPTIONS.ERROR_MESSAGE is 
'Error message associated with the error generating the exception.'  
/  

comment on column DBA_REPCAT_EXCEPTIONS.LINE_NUMBER is 
'Line number of the exception.'  
/  
  
create or replace public synonym dba_repcat_exceptions
   for dba_repcat_exceptions
/

grant select on dba_repcat_exceptions to select_catalog_role
/


create table system.repcat$_instantiation_ddl
(refresh_template_id number,
   constraint repcat$_instantiation_ddl_fk1 foreign key (refresh_template_id)
     references system.repcat$_refresh_templates on delete cascade,
ddl_text clob,
ddl_num number,
phase number,
constraint repcat$_instantiation_ddl_pk primary key
  (refresh_template_id,phase,ddl_num))
/

comment on table SYSTEM.REPCAT$_INSTANTIATION_DDL is
'Table containing supplementary DDL to be executed during instantiation.'
/

comment on column SYSTEM.REPCAT$_INSTANTIATION_DDL.REFRESH_TEMPLATE_ID is
'Primary key of template containing supplementary DDL.'
/

comment on column SYSTEM.REPCAT$_INSTANTIATION_DDL.DDL_TEXT is 
'Supplementary DDL string.'
/

comment on column SYSTEM.REPCAT$_INSTANTIATION_DDL.PHASE is
'Phase to execute the DDL string.'
/

comment on column SYSTEM.REPCAT$_INSTANTIATION_DDL.DDL_NUM is 
'Column for ordering of supplementary DDL.'
/

create or replace view "_ALL_INSTANTIATION_DDL" 
(refresh_template_id,ddl_text,ddl_num,phase) as
select refresh_template_id, ddl_text, ddl_num, phase 
from system.repcat$_instantiation_ddl 
/

comment on table "_ALL_INSTANTIATION_DDL" is
'Table containing supplementary DDL to be executed during instantiation.'
/

comment on column "_ALL_INSTANTIATION_DDL".REFRESH_TEMPLATE_ID is
'Primary key of template containing supplementary DDL.'
/

comment on column "_ALL_INSTANTIATION_DDL".DDL_TEXT is 
'Supplementary DDL string.'
/

comment on column "_ALL_INSTANTIATION_DDL".PHASE is
'Phase to execute the DDL string.'
/

comment on column "_ALL_INSTANTIATION_DDL".DDL_NUM is 
'Column for ordering of supplementary DDL.'
/
 
create or replace public synonym "_ALL_INSTANTIATION_DDL"
   for "_ALL_INSTANTIATION_DDL"
/

grant select on "_ALL_INSTANTIATION_DDL" to PUBLIC with grant option
/

-- support add_master_database without quiescing
create table system.repcat$_extension(
    extension_id                 RAW(16) PRIMARY KEY,
    extension_code               NUMBER,
             CONSTRAINT repcat$_extension_code
               CHECK (extension_code IN (0)),
    masterdef                    VARCHAR2(128),
    export_required              VARCHAR2(1), -- Y for YES, N for NO
             CONSTRAINT repcat$_extension_exportreq
               CHECK (export_required IN ('Y', 'N')),
    repcatlog_id                 NUMBER,
    extension_status             NUMBER,
             CONSTRAINT repcat$_extension_status
               CHECK (extension_status IN (0, 1, 2, 3, 4)),
    flashback_scn                NUMBER,
    push_to_mdef                 VARCHAR2(1), -- Y for YES, N for NO
             CONSTRAINT repcat$_extension_push_to_mdef
               CHECK (push_to_mdef IN ('Y', 'N')),
    push_to_new                  VARCHAR2(1), -- Y for YES, N for NO
             CONSTRAINT repcat$_extension_push_to_new
               CHECK (push_to_new IN ('Y', 'N')),
    percentage_for_catchup_mdef  NUMBER,
    cycle_seconds_mdef           NUMBER,
    percentage_for_catchup_new   NUMBER,
    cycle_seconds_new            NUMBER)
/

comment on table SYSTEM.REPCAT$_EXTENSION is
'Information about replication extension requests'
/

comment on column SYSTEM.REPCAT$_EXTENSION.EXTENSION_ID is
'Globally unique identifier for replication extension'
/

comment on column SYSTEM.REPCAT$_EXTENSION.EXTENSION_CODE is
'Kind of replication extension'
/

comment on column SYSTEM.REPCAT$_EXTENSION.MASTERDEF is
'Master definition site for replication extension'
/

comment on column SYSTEM.REPCAT$_EXTENSION.EXPORT_REQUIRED is
'YES if this extension requires an export, and NO if no export is required'
/

comment on column SYSTEM.REPCAT$_EXTENSION.REPCATLOG_ID is
'Identifier of repcatlog records related to replication extension'
/

comment on column SYSTEM.REPCAT$_EXTENSION.EXTENSION_STATUS is
'Status of replication extension'
/

comment on column SYSTEM.REPCAT$_EXTENSION.FLASHBACK_SCN is
'Flashback_scn for export or change-based recovery for replication extension'
/

comment on column SYSTEM.REPCAT$_EXTENSION.PUSH_TO_MDEF is
'YES if existing masters partially push to masterdef, NO if no pushing'
/

comment on column SYSTEM.REPCAT$_EXTENSION.PUSH_TO_NEW is
'YES if existing masters partially push to new masters, NO if no pushing'
/

comment on column SYSTEM.REPCAT$_EXTENSION.PERCENTAGE_FOR_CATCHUP_MDEF is
'Fraction of push to masterdef cycle devoted to catching up'
/

comment on column SYSTEM.REPCAT$_EXTENSION.CYCLE_SECONDS_MDEF is
'Length of push to masterdef cycle when catching up'
/

comment on column SYSTEM.REPCAT$_EXTENSION.PERCENTAGE_FOR_CATCHUP_NEW is
'Fraction of push to new masters cycle devoted to catching up'
/

comment on column SYSTEM.REPCAT$_EXTENSION.CYCLE_SECONDS_NEW is
'Length of push to new masters cycle when catching up'
/

create table system.repcat$_sites_new(
    extension_id       RAW(16),
             CONSTRAINT repcat$_sites_new_fk1
               FOREIGN KEY(extension_id)
               REFERENCES system.repcat$_extension(extension_id)
               ON DELETE CASCADE,
    gowner             VARCHAR2(30),
    gname              VARCHAR2(30),
             CONSTRAINT repcat$_sites_new_fk2
               FOREIGN KEY (gname, gowner)
               REFERENCES system.repcat$_repcat(sname, gowner)
               ON DELETE CASCADE,
    dblink             VARCHAR2(128),
             CONSTRAINT repcat$_sites_new_pk
               PRIMARY KEY(extension_id, gowner, gname, dblink),
    full_instantiation VARCHAR2(1),    -- Y for YES, N for NO
             CONSTRAINT repcat$_sites_new_full_inst
               CHECK (full_instantiation IN ('Y', 'N')),
    master_status      NUMBER)
/

-- index on foreign key to avoid deadlocks in
-- concurrent do_deferred_repcat_admin
create index system.repcat$_sites_new_fk2_idx on
  system.repcat$_sites_new(gname, gowner)
/

create index system.repcat$_sites_new_fk1_idx on
  system.repcat$_sites_new(extension_id)
/

comment on table SYSTEM.REPCAT$_SITES_NEW is
'Information about new masters for replication extension'
/

comment on column SYSTEM.REPCAT$_SITES_NEW.EXTENSION_ID is
'Globally unique identifier for replication extension'
/

comment on column SYSTEM.REPCAT$_SITES_NEW.GOWNER is
'Owner of the object group'
/

comment on column SYSTEM.REPCAT$_SITES_NEW.GNAME is
'Name of the replicated object group'
/

comment on column SYSTEM.REPCAT$_SITES_NEW.DBLINK is
'A database site that will replicate the object group'
/

comment on column SYSTEM.REPCAT$_SITES_NEW.FULL_INSTANTIATION is
'Y if the database uses full-database export or change-based recovery'
/

comment on column SYSTEM.REPCAT$_SITES_NEW.MASTER_STATUS is
'Instantiation status of the new master'
/

create or replace view DBA_REPEXTENSIONS
(extension_id, request, masterdef, export_required, repcatlog_id,
 extension_status, flashback_scn, break_trans_to_masterdef,
 break_trans_to_new_masters,
 percentage_for_catchup_mdef, cycle_seconds_mdef, percentage_for_catchup_new,
 cycle_seconds_new)
as
select
  r.extension_id,
  DECODE(r.extension_code,
         0, 'ADD_NEW_MASTERS') request,
  r.masterdef,
  DECODE(export_required, 'Y', 'YES', 'N', 'NO') export_required,
  r.repcatlog_id,
  DECODE(r.extension_status,
         0, 'READY',
         1, 'STOPPING',
         2, 'EXPORTING',
         3, 'INSTANTIATING',
         4, 'ERROR') extension_status,
  r.flashback_scn,
  DECODE(r.push_to_mdef, 'Y', 'YES', 'N', 'NO') break_trans_to_masterdef,
  DECODE(r.push_to_new, 'Y', 'YES', 'N', 'NO') break_trans_to_new_masters,
  r.percentage_for_catchup_mdef,
  r.cycle_seconds_mdef,
  r.percentage_for_catchup_new,
  r.cycle_seconds_new
from system.repcat$_extension r
/

comment on table DBA_REPEXTENSIONS is
'Information about replication extension requests'
/

comment on column DBA_REPEXTENSIONS.EXTENSION_ID is
'Globally unique identifier for replication extension'
/

comment on column DBA_REPEXTENSIONS.REQUEST is
'Kind of replication extension'
/

comment on column DBA_REPEXTENSIONS.MASTERDEF is
'Master definition site for replication extension'
/

comment on column DBA_REPEXTENSIONS.EXPORT_REQUIRED is
'YES if this extension requires an export, and NO if no export is required'
/

comment on column DBA_REPEXTENSIONS.REPCATLOG_ID is
'Identifier of repcatlog records related to replication extension'
/

comment on column DBA_REPEXTENSIONS.EXTENSION_STATUS is
'Status of replication extension'
/

comment on column DBA_REPEXTENSIONS.FLASHBACK_SCN is
'Flashback_scn for export or change-based recovery for replication extension'
/

comment on column DBA_REPEXTENSIONS.BREAK_TRANS_TO_MASTERDEF is
'YES if existing masters partially push to masterdef, NO if no pushing'
/

comment on column DBA_REPEXTENSIONS.BREAK_TRANS_TO_NEW_MASTERS is
'YES if existing masters partially push to new masters, NO if no pushing'
/

comment on column DBA_REPEXTENSIONS.PERCENTAGE_FOR_CATCHUP_MDEF is
'Fraction of push to masterdef cycle devoted to catching up'
/

comment on column DBA_REPEXTENSIONS.CYCLE_SECONDS_MDEF is
'Length of push to masterdef cycle when catching up'
/

comment on column DBA_REPEXTENSIONS.PERCENTAGE_FOR_CATCHUP_NEW is
'Fraction of push to new masters cycle devoted to catching up'
/

comment on column DBA_REPEXTENSIONS.CYCLE_SECONDS_NEW is
'Length of push to new masters cycle when catching up'
/

create or replace public synonym DBA_REPEXTENSIONS for DBA_REPEXTENSIONS
/
grant select on DBA_REPEXTENSIONS to select_catalog_role
/

-- Create a view suitable for remote access from repcat.
-- This view is for internal use only and may change without notice.
create or replace view "_ALL_REPEXTENSIONS"
(extension_id, request, masterdef, export_required, repcatlog_id,
 extension_status, flashback_scn, break_trans_to_masterdef,
 break_trans_to_new_masters,
 percentage_for_catchup_mdef, cycle_seconds_mdef, percentage_for_catchup_new,
 cycle_seconds_new)
as
select
  r.extension_id,
  r.request,
  r.masterdef,
  r.export_required,
  r.repcatlog_id,
  r.extension_status,
  r.flashback_scn,
  r.break_trans_to_masterdef,
  r.break_trans_to_new_masters,
  r.percentage_for_catchup_mdef,
  r.cycle_seconds_mdef,
  r.percentage_for_catchup_new,
  r.cycle_seconds_new
from dba_repextensions r
/

comment on table "_ALL_REPEXTENSIONS" is
'Information about replication extension requests'
/

comment on column "_ALL_REPEXTENSIONS".EXTENSION_ID is
'Globally unique identifier for replication extension'
/

comment on column "_ALL_REPEXTENSIONS".REQUEST is
'Kind of replication extension'
/

comment on column "_ALL_REPEXTENSIONS".MASTERDEF is
'Master definition site for replication extension'
/

comment on column "_ALL_REPEXTENSIONS".EXPORT_REQUIRED is
'Y if this extension requires an export, and N if no export is required'
/

comment on column "_ALL_REPEXTENSIONS".REPCATLOG_ID is
'Identifier of repcatlog records related to replication extension'
/

comment on column "_ALL_REPEXTENSIONS".EXTENSION_STATUS is
'Status of replication extension'
/

comment on column "_ALL_REPEXTENSIONS".FLASHBACK_SCN is
'FLASHBACK_SCN for export or change-based recovery for replication extension'
/

comment on column "_ALL_REPEXTENSIONS".BREAK_TRANS_TO_MASTERDEF is
'Y if existing masters partially push to masterdef, N if no pushing'
/

comment on column "_ALL_REPEXTENSIONS".BREAK_TRANS_TO_NEW_MASTERS is
'Y if existing masters partially push to new masters, N if no pushing'
/

comment on column "_ALL_REPEXTENSIONS".PERCENTAGE_FOR_CATCHUP_MDEF is
'Fraction of push to masterdef cycle devoted to catching up'
/

comment on column "_ALL_REPEXTENSIONS".CYCLE_SECONDS_MDEF is
'Length of push to masterdef cycle when catching up'
/

comment on column "_ALL_REPEXTENSIONS".PERCENTAGE_FOR_CATCHUP_NEW is
'Fraction of push to new masters cycle devoted to catching up'
/

comment on column "_ALL_REPEXTENSIONS".CYCLE_SECONDS_NEW is
'Length of push to new masters cycle when catching up'
/

create or replace public synonym "_ALL_REPEXTENSIONS" for "_ALL_REPEXTENSIONS"
/
grant select on "_ALL_REPEXTENSIONS" to PUBLIC with grant option
/

create or replace view DBA_REPSITES_NEW
(extension_id, gowner, gname, dblink, full_instantiation, master_status)
as
select
  r.extension_id,
  r.gowner,
  r.gname,
  r.dblink,
  r.full_instantiation,
  DECODE(r.master_status,
         0, 'READY',
         1, 'INSTANTIATING',
         2, 'INSTANTIATED',
         3, 'PREPARED') master_status
from system.repcat$_sites_new r
/

comment on table DBA_REPSITES_NEW is
'Information about new masters for replication extension'
/

comment on column DBA_REPSITES_NEW.EXTENSION_ID is
'Globally unique identifier for replication extension'
/

comment on column DBA_REPSITES_NEW.GOWNER is
'Owner of the object group'
/

comment on column DBA_REPSITES_NEW.GNAME is
'Name of the replicated object group'
/

comment on column DBA_REPSITES_NEW.DBLINK is
'A database site that will replicate the object group'
/

comment on column DBA_REPSITES_NEW.FULL_INSTANTIATION is
'Y if the database uses full-database export or change-based recovery'
/

comment on column DBA_REPSITES_NEW.MASTER_STATUS is
'Instantiation status of the new master'
/

create or replace public synonym DBA_REPSITES_NEW for DBA_REPSITES_NEW
/
grant select on DBA_REPSITES_NEW to select_catalog_role
/

-- Create a view suitable for remote access from repcat.
-- This view is for internal use only and may change without notice.
create or replace view "_ALL_REPSITES_NEW"
(extension_id, gowner, gname, dblink, full_instantiation, master_status)
as
select
  r.extension_id,
  r.gowner,
  r.gname,
  r.dblink,
  r.full_instantiation,
  r.master_status
from dba_repsites_new r
/

comment on table "_ALL_REPSITES_NEW" is
'Information about new masters for replication extension'
/

comment on column "_ALL_REPSITES_NEW".EXTENSION_ID is
'Globally unique identifier for replication extension'
/

comment on column "_ALL_REPSITES_NEW".GOWNER is
'Owner of the object group'
/

comment on column "_ALL_REPSITES_NEW".GNAME is
'Name of the replicated object group'
/

comment on column "_ALL_REPSITES_NEW".DBLINK is
'A database site that will replicate the object group'
/

comment on column "_ALL_REPSITES_NEW".FULL_INSTANTIATION is
'Y if the database uses full-database export or change-based recovery'
/

comment on column "_ALL_REPSITES_NEW".MASTER_STATUS is
'Instantiation status of the new master'
/

create or replace public synonym "_ALL_REPSITES_NEW" for "_ALL_REPSITES_NEW"
/
grant select on "_ALL_REPSITES_NEW" to PUBLIC with grant option
/

rem *********************************************************************
rem repcat$_cdef view.
rem 
CREATE OR REPLACE VIEW repcat$_cdef AS
  SELECT * FROM sys.cdef$ WHERE robj# != obj#
/
grant select on repcat$_cdef to select_catalog_role
/

Rem Deferred RPC views and reimplementation of views

Rem  ************************************************************
Rem AQ/propagation converge: 
Rem    sname, oname, type uniquely determines a recipient key
Rem

create or replace view defcalldest as
  select C1.step_no callno, C.enq_tid deferred_tran_id,
         D.dblink
    from system.def$_aqcall C, system.def$_aqcall C1,
         system.def$_destination D
    where C.cscn IS NOT NULL
      and C1.enq_tid = c.enq_tid
      AND C.cscn >= D.last_delivered
      AND (C.cscn > D.last_delivered
            OR
            (C.cscn = D.last_delivered
             AND (C.enq_tid > D.last_enq_tid)))
      and (( C1.recipient_key = 0
            AND EXISTS (
              select NULL
                from system.def$_calldest CD
                where  CD.enq_tid=C1.enq_tid
                  AND  CD.step_no=C1.step_no
                  AND  CD.dblink = D.dblink
                  AND  CD.catchup = D.catchup))
          OR ( C1.recipient_key > 0
              AND EXISTS (
              SELECT NULL
                from  system.repcat$_repprop P
                WHERE  D.dblink = P.dblink
                  AND  D.catchup = P.extension_id
                  AND  P.how = 1
                  AND  P.recipient_key = C1.recipient_key
                  AND  ((P.delivery_order is NULL) OR
                        (P.delivery_order < C.cscn)))))
/ 
grant select on defcalldest to select_catalog_role
/
comment on table DEFCALLDEST is
'Information about call destinations for deferred transactions'
/
comment on column DEFCALLDEST.CALLNO is
'Unique ID of call within transaction'
/
comment on column DEFCALLDEST.DEFERRED_TRAN_ID is
'Transaction ID'
/
comment on column DEFCALLDEST.DBLINK is
'The destination database'
/

CREATE OR REPLACE PUBLIC SYNONYM defcalldest for defcalldest
/

-- Note: any change to this query requires the corresponding changes
--       in all the expanded "deftrandest" view (e.g., the query in
--       purge_aq_precise). The expansion is for performance
-- This view is for internal use only and may change without notice.
create or replace view "_DEFTRANDEST" as
  select C.enq_tid deferred_tran_id, C.cscn delivery_order, D.dblink,
         D.catchup
    from system.def$_aqcall C, system.def$_destination D
    where C.cscn IS NOT NULL
      AND C.cscn >= D.last_delivered
      AND (C.cscn > D.last_delivered
          OR
          (C.cscn = D.last_delivered
           AND (C.enq_tid > D.last_enq_tid)))
      and (( C.recipient_key = 0
            AND EXISTS (
              select /*+ index(CD def$_calldest_primary) */ NULL
                from system.def$_calldest CD
                where  CD.enq_tid=C.enq_tid
                  AND  CD.dblink = D.dblink
                  AND  CD.catchup = D.catchup ))
          OR ( C.recipient_key > 0
            AND ( (EXISTS (
                     SELECT NULL
                       FROM system.repcat$_repprop p
                         WHERE D.dblink = P.dblink
                           AND D.catchup = P.extension_id
                           AND P.how = 1
                           AND P.recipient_key = C.recipient_key
                           AND ((P.delivery_order is NULL)
                              OR (P.delivery_order < C.cscn))))
               OR (EXISTS (
                     SELECT NULL
                       from system.def$_aqcall C2, system.repcat$_repprop P
                       WHERE C2.enq_tid=C.enq_tid
                         AND C2.cscn IS NULL
                         AND D.dblink = P.dblink
                         AND D.catchup = P.extension_id
                         AND P.how = 1
                         AND P.recipient_key = C2.recipient_key
                         AND ((P.delivery_order is NULL) OR
                              (P.delivery_order < C.cscn)))))))
/

create or replace view deftrandest as
  select deferred_tran_id, delivery_order, dblink
    from "_DEFTRANDEST"
/

grant select on deftrandest to select_catalog_role
/

-- ensure deftrandest synonym is valid
alter public synonym deftrandest compile
/

