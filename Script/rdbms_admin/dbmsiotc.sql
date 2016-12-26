Rem
Rem $Header: dbmsiotc.sql 10-jun-2005.11:30:10 geadon Exp $
Rem
Rem dbmsiotc.sql
Rem
Rem Copyright (c) 1996, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsiotc.sql - IOT CHained rows - create table
Rem
Rem    DESCRIPTION
Rem      this package creates a table into which references to the chained
Rem      rows for an iot can be placed using the analyze command.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    geadon      06/02/05 - bug 4357181: xxx_REDUNDANT_PKEY functions 
Rem    geadon      01/16/04 - bug 3566361: NUMBER_TO_UROWID as OCI callout
Rem    geadon      10/06/03 - bug 3175674: add NUMBER_TO_UROWID 
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    gdoherty    06/05/97 - invoke prvtiotc
Rem    jsriniva    10/01/96 - iot: add build_exceptions_table
Rem    jsriniva    07/24/96 - change package name
Rem    gdoherty    07/22/96 - formerly utliotch.sql
Rem    mmonajje    05/22/96 - Replace precision col name with precision#
Rem    aho         03/01/96 - change index type from 2 to 4
Rem    aho         02/27/96 - utliotch.sql
Rem    aho         02/27/96 - Created
Rem
 
create or replace package dbms_iot is
procedure build_chain_rows_table(owner in varchar2,
		      iot_name in varchar2,
		      chainrow_table_name in varchar2 
			    default 'IOT_CHAINED_ROWS');

procedure build_exceptions_table(owner in varchar2,
		      iot_name in varchar2,
		      exceptions_table_name in varchar2 
			    default 'IOT_EXCEPTIONS');

function number_to_urowid(n number, len out integer) return varchar2;

function number_to_urowid(n number) return varchar2;

function number_to_urowid(n SYS.ODCINumberList) return SYS.ODCIRidList;

procedure repair_redundant_pkey(schema varchar2);

function check_redundant_pkey(
    table_owner varchar2,
    table_name  varchar2,
    index_owner varchar2,
    index_name  varchar2,
    uniqueness  varchar2,
    nblk_uniq   binary_integer DEFAULT NULL)
  return varchar2;

pragma restrict_references (number_to_urowid, WNDS, RNDS, WNPS, RNPS);

end;
/

create or replace public synonym dbms_iot for sys.dbms_iot
/
grant execute on dbms_iot to public
/

create or replace library dbms_iot_lib trusted as static
/

@@prvtiotc.plb
