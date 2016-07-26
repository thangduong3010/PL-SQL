Rem
Rem $Header: catxdbvr.sql 17-mar-2006.00:03:28 thbaby Exp $
Rem
Rem catxdbvr.sql
Rem
Rem Copyright (c) 2001, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbvr.sql - all $table for versioning are defined here.
Rem
Rem    DESCRIPTION
Rem      WSINDEX: (workspace index) table for indexing a versioned table.
Rem               Each versioned table has one associated wsindex table.
Rem      CHECKOUTS: table for all checked-out rows.
Rem
Rem      For regular RDBMS, wsindex and checkouts tables should be
Rem      automatically created by the system for versioned table.
Rem      For XDB, wsindex is created together with workspace, and checkouts
Rem      is created together with the resource table.
Rem
Rem    NOTES
Rem      This file should be executed for each user who has versioned tables.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      03/17/06 - remove / after create table 
Rem    thbaby      11/14/05 - add xdb$workspace table 
Rem    spannala    12/16/03 - split the package into dbmxvr.sql 
Rem    sichandr    04/17/02 - add getContents* routines
Rem    sichandr    02/19/02 - fix getPredecessors
Rem    sichandr    02/21/02 - add GetResourceByResId
Rem    sichandr    02/07/02 - add GetPredessors/GetSuccessors
Rem    spannala    01/08/02 - incorporating fge_caxdb_priv_indx_fix
Rem    spannala    12/27/01 - setup should be run as SYS
Rem    najain      12/05/01 - change XDB_VERSION to DBMS_XDB_VERSION
Rem    nagarwal    10/23/01 - Merged nagarwal_deltav
Rem    nle         08/09/01 - Created
Rem

/* vers$wsindex: index table for a versioned table.
 *
 *  Each workspace will have one index table. This table should be created
 *  automatically by the system together with a workspace. We created it here
 *  for our code prototype. It has three columns.
 *
 *   - sys_primary: if the primary key of a row is changed, this is used to
 *     identified the row. This shouldn't be used in this table. It should be
 *     used in the versioned table (i.e. the $resource table for XDB). (???)
 *   - user_primary: its datatype and content are the same as the primary key
 *     of the versioned table. For XDB, the primary key is of varchar(128).
 *     This is the index key of the index table.
 *   - data: this is a rowid of a row in the versioned table (xdb$resource)

create table xdb$wsindex(sys_primary number(6),
                         user_primary varchar2(128),
                         data rowid)
*/

/*
   xdb$workspace has one row for each workspace, whether real or virtual. 
   It has the following columns:  

ws_name	    Workspace name
wsid	    Workspace identifier
vr_wsid	    Identifier for the real workspace on which the virtual 
            workspace is based. It is null for a real workspace. 
flags       Flag that includes the following bits:
            is_static: Is the workspace static?
            is_published: Is the workspace published? 
                          This bit is false for a virtual workspace. 
vh_bitmap   A bit-vector that uses the id of a version history as its index. 
            Its semantics is as follows.
            Real workspace: Does a VCR with this vhid exist in its workspace?
            Virtual workspace: Is the VCR with this vhid private in this 
                               workspace?
res_bitmap  A bit-vector that uses xdb$resource row-ID as its index. Its 
            semantics is as follows: 
            Real workspace: Does the resource corresponding to this row-ID
                            exist in the workspace? 
            Virtual workspace: Is the resource corresponding to this row-ID
                               private in this workspace?
vh_to_res_map An array of (vhid, xdb$resource row-id) pairs. It is null for a 
              real workspace. For a virtual workspace, it has one entry for 
              each private VCR. When a private VCR is made shared, the 
              corresponding entry in this mapping table is deleted. 
checkout_set  An array of OIDs of resources checked out in the workspace. 

The following indexes are maintained on this table:
1. An index on the wsid column to perform fast retrieval of workspace 
   properties by id. 
2. An index on the ws_name column to retrieve wsid of a workspace given its 
   name. 
3. An index on the vr_wsid column to check if a real workspace has dependent 
   virtual workspaces. 
*/
drop table xdb.xdb$workspace;
create table xdb.xdb$workspace(wsname        varchar2(1024),
                               wsid          raw(16),
                               vr_wsid       raw(16),
                               flags         raw(4),
                               vh_bitmap     blob,
                               res_bitmap    blob,
                               vh_to_res_map blob,
                               checkout_set  blob);

/* vers$checkouts: a table to maintain a list of checkouts.
 *  Checkout table helps to implement checkout/checkin operations.
 *  - version: this column point to the original version of a checked-out row.
 *             if this column is null, the resource has been deleted.
 *  - actid: id of an activity.
 *  - co_stat: checked-out/checked-in. This might not be necessary.
 */
drop table xdb.xdb$checkouts;
create table xdb.xdb$checkouts(vcruid raw(16),
                           workspaceid integer,
                           version raw(16),
                           actid integer,
                           constraint cokey primary key(vcruid, workspaceid));


create index xdb.xdb$checkouts_vcruid_idx on xdb.xdb$checkouts (vcruid);
create index xdb.xdb$checkouts_workspaceid_idx on xdb.xdb$checkouts (workspaceid);

-- The package definition has moved into dbmsxvr.sql
@@dbmsxvr.sql
