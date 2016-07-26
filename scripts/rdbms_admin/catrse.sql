Rem
Rem $Header: rdbms/admin/catrse.sql /main/2 2008/12/30 01:42:58 rmao Exp $
Rem
Rem catrse.sql
Rem
Rem Copyright (c) 2006, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catrse.sql - Recoverable Script Execution catalog views
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rmao        12/08/08 - add dba_recoverable_script_hist view
Rem    jinwu       11/03/06 - Created
Rem


-- Recoverable script : view showing recoverable script operation details
create or replace view DBA_RECOVERABLE_SCRIPT
(SCRIPT_ID, CREATION_TIME, INVOKING_PACKAGE_OWNER, INVOKING_PACKAGE,
 INVOKING_PROCEDURE, INVOKING_USER, STATUS, TOTAL_BLOCKS, DONE_BLOCK_NUM, 
 SCRIPT_COMMENT)
as
select oid, ctime, invoking_package_owner, invoking_package,
  invoking_procedure, invoking_user,
  decode(status, 1, 'GENERATING',
                 2, 'NOT EXECUTED',
                 3, 'EXECUTING',
                 4, 'EXECUTED',
                 5, 'ERROR'),
  total_blocks, done_block_num, script_comment
from sys.reco_script$
where status in (1,2,3,5)
/

comment on table DBA_RECOVERABLE_SCRIPT is
'Details about recoverable operations'
/
comment on column DBA_RECOVERABLE_SCRIPT.SCRIPT_ID is
'Unique id of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT.CREATION_TIME is
'Time the operation was invoked'
/
comment on column DBA_RECOVERABLE_SCRIPT.INVOKING_PACKAGE_OWNER is
'Invoking package owner of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT.INVOKING_PACKAGE is
'Invoking package of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT.INVOKING_PROCEDURE is
'Invoking procedure of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT.INVOKING_USER is
'Script owner'
/
comment on column DBA_RECOVERABLE_SCRIPT.STATUS is
'state of the recoverable script: EXECUTING, GENERATING'
/
comment on column DBA_RECOVERABLE_SCRIPT.DONE_BLOCK_NUM is
'last block so far executed'
/
comment on column DBA_RECOVERABLE_SCRIPT.TOTAL_BLOCKS is
'total number of blocks for the recoverable script to be executed'
/
comment on column DBA_RECOVERABLE_SCRIPT.SCRIPT_COMMENT is
'comment for the recoverable script'
/
create or replace public synonym DBA_RECOVERABLE_SCRIPT
  for DBA_RECOVERABLE_SCRIPT
/
grant select on DBA_RECOVERABLE_SCRIPT to select_catalog_role
/


-- view showing executed or (user) purged recoverable script operation details
create or replace view DBA_RECOVERABLE_SCRIPT_HIST
(SCRIPT_ID, CREATION_TIME, INVOKING_PACKAGE_OWNER, INVOKING_PACKAGE,
 INVOKING_PROCEDURE, INVOKING_USER, STATUS, TOTAL_BLOCKS, DONE_BLOCK_NUM, 
 SCRIPT_COMMENT)
as
select oid, ctime, invoking_package_owner, invoking_package,
  invoking_procedure, invoking_user,
  decode(status, 4, 'EXECUTED',
                 6, 'PURGED'),
  total_blocks, done_block_num, script_comment
from sys.reco_script$
where status in (4,6)
/

comment on table DBA_RECOVERABLE_SCRIPT_HIST is
'Details about executed or purged recoverable operations'
/
comment on column DBA_RECOVERABLE_SCRIPT_HIST.SCRIPT_ID is
'Unique id of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT_HIST.CREATION_TIME is
'Time the operation was invoked'
/
comment on column DBA_RECOVERABLE_SCRIPT_HIST.INVOKING_PACKAGE_OWNER is
'Invoking package owner of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT_HIST.INVOKING_PACKAGE is
'Invoking package of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT_HIST.INVOKING_PROCEDURE is
'Invoking procedure of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT_HIST.INVOKING_USER is
'Script owner'
/
comment on column DBA_RECOVERABLE_SCRIPT_HIST.STATUS is
'state of the recoverable script: EXECUTED, PURGED'
/
comment on column DBA_RECOVERABLE_SCRIPT_HIST.DONE_BLOCK_NUM is
'last block so far executed'
/
comment on column DBA_RECOVERABLE_SCRIPT_HIST.TOTAL_BLOCKS is
'total number of blocks for the recoverable script to be executed'
/
comment on column DBA_RECOVERABLE_SCRIPT_HIST.SCRIPT_COMMENT is
'comment for the recoverable script'
/
create or replace public synonym DBA_RECOVERABLE_SCRIPT_HIST
  for DBA_RECOVERABLE_SCRIPT_HIST
/
grant select on DBA_RECOVERABLE_SCRIPT_HIST to select_catalog_role
/

-- Recoverable script : view showing operation parameters
create or replace view DBA_RECOVERABLE_SCRIPT_PARAMS
(SCRIPT_ID, PARAMETER, PARAM_INDEX, VALUE)
as
select oid, name, param_index, value
from sys.reco_script_params$
/
comment on table DBA_RECOVERABLE_SCRIPT_PARAMS is
'Details about the recoverable operation parameters'
/
comment on column DBA_RECOVERABLE_SCRIPT_PARAMS.SCRIPT_ID is
'Unique id of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT_PARAMS.PARAMETER is
'Name of the parameter'
/
comment on column DBA_RECOVERABLE_SCRIPT_PARAMS.PARAM_INDEX is
'Index for multi-valued parameter' 
/
comment on column DBA_RECOVERABLE_SCRIPT_PARAMS.VALUE is
'Value of the parameter'
/
create or replace public synonym DBA_RECOVERABLE_SCRIPT_PARAMS
  for DBA_RECOVERABLE_SCRIPT_PARAMS
/
grant select on DBA_RECOVERABLE_SCRIPT_PARAMS to select_catalog_role
/


-- Recoverable script : view showing recoverable script blocks
create or replace view DBA_RECOVERABLE_SCRIPT_BLOCKS
(SCRIPT_ID, BLOCK_NUM, FORWARD_BLOCK, FORWARD_BLOCK_DBLINK, UNDO_BLOCK,
 UNDO_BLOCK_DBLINK, STATUS, BLOCK_COMMENT)
as
select oid, block_num, forward_block, forward_block_dblink, undo_block,
undo_block_dblink,
decode(status, 1, 'GENERATING',
               2, 'NOT EXECUTED',
               3, 'EXECUTING',
               4, 'EXECUTED',
               5, 'ERROR',
               6, 'PURGED'),
block_comment
from sys.reco_script_block$
/
comment on table DBA_RECOVERABLE_SCRIPT_BLOCKS is
'Details about the recoverable script blocks'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.SCRIPT_ID is
'global unique id of the recoverable script to which this block belongs'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.BLOCK_NUM is
'nth block in the recoverable script to be executed'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.FORWARD_BLOCK is
'forward block to be executed'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.FORWARD_BLOCK_DBLINK is
'database where the forward block is executed'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.UNDO_BLOCK is
'block to rollback the forward operation'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.UNDO_BLOCK_DBLINK is
'database where the undo block is executed'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.STATUS is
'status of the block execution - NOT_STARTED, EXECUTING, DONE, ERROR'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.BLOCK_COMMENT is
'comment for the block'
/
create or replace public synonym DBA_RECOVERABLE_SCRIPT_BLOCKS
  for DBA_RECOVERABLE_SCRIPT_BLOCKS
/
grant select on DBA_RECOVERABLE_SCRIPT_BLOCKS to select_catalog_role
/


-- Recoverable script : view showing recoverable script errors
create or replace view DBA_RECOVERABLE_SCRIPT_ERRORS
(SCRIPT_ID, BLOCK_NUM, ERROR_NUMBER, ERROR_MESSAGE, ERROR_CREATION_TIME)
as
select oid, block_num, error_number, error_message, error_creation_time
from sys.reco_script_error$ 
/
comment on table DBA_RECOVERABLE_SCRIPT_ERRORS is
'Details showing errors during script execution'
/
comment on column DBA_RECOVERABLE_SCRIPT_ERRORS.SCRIPT_ID is
'global unique id of the recoverable script'
/
comment on column DBA_RECOVERABLE_SCRIPT_ERRORS.BLOCK_NUM is
'nth block that failed'
/
comment on column DBA_RECOVERABLE_SCRIPT_ERRORS.ERROR_NUMBER is
'error number of error encountered while executing the block'
/
comment on column DBA_RECOVERABLE_SCRIPT_ERRORS.ERROR_MESSAGE is
'error message of error encountered while executing the block'
/
comment on column DBA_RECOVERABLE_SCRIPT_ERRORS.ERROR_CREATION_TIME is
'time error was created'
/
create or replace public synonym DBA_RECOVERABLE_SCRIPT_ERRORS
  for DBA_RECOVERABLE_SCRIPT_ERRORS
/
grant select on DBA_RECOVERABLE_SCRIPT_ERRORS to select_catalog_role
/
