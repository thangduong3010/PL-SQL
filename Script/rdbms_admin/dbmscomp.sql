Rem
Rem $Header: rdbms/admin/dbmscomp.sql /st_rdbms_11.2.0/1 2011/08/10 17:42:14 alhollow Exp $
Rem
Rem dbmscomp.sql
Rem
Rem Copyright (c) 2007, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmscomp.sql - DBMS Compression package
Rem
Rem    DESCRIPTION
Rem      Contains package specification for the wrapper dbms_compression
Rem      package and internal prvt_compression package. We integrate these
Rem      packages with the advisor framework.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amylavar    07/29/11 - add a compression level
Rem    kshergil    10/06/09 - get_compression_ratio changes
Rem    amylavar    05/14/09 - Add autocompress option to incremental_compress
Rem    amylavar    05/04/09 - Add incremental_compress
Rem    amylavar    04/30/09 - Add get_compression_type function to figure out compression
Rem                           level/type per ROWID
Rem    apanagar    03/02/09 - change numerical compression level to support
Rem                           low, medium, high
Rem    amitsha     01/08/09 - make the package work for partitioned tables and
Rem                           an optional parameter for specifying partitions
Rem    amitsha     04/06/08 - make compression advisor functionally complete 
Rem    vmarwah     03/31/08 - remove the SET statements
Rem    vmarwah     03/26/08 - forward merge to MAIN
Rem    amitsha     03/12/08 - Implement Compression advisor using advisor
Rem                           framework
Rem    amitsha     12/17/07 - Created
Rem

create or replace package dbms_compression authid current_user is

COMP_NOCOMPRESS               CONSTANT NUMBER := 1;
COMP_FOR_OLTP                 CONSTANT NUMBER := 2;
COMP_FOR_QUERY_HIGH           CONSTANT NUMBER := 4;
COMP_FOR_QUERY_LOW            CONSTANT NUMBER := 8;
COMP_FOR_ARCHIVE_HIGH         CONSTANT NUMBER := 16;
COMP_FOR_ARCHIVE_LOW          CONSTANT NUMBER := 32; 
COMP_BLOCK                    CONSTANT NUMBER := 64;

COMP_RATIO_MINROWS            CONSTANT NUMBER := 1000000;
COMP_RATIO_ALLROWS            CONSTANT NUMBER := -1;

  PROCEDURE get_compression_ratio(
    scratchtbsname        IN     varchar2,
    ownname               IN     varchar2,
    tabname               IN     varchar2,
    partname              IN     varchar2,
    comptype              IN     number,
    blkcnt_cmp            OUT    PLS_INTEGER,
    blkcnt_uncmp          OUT    PLS_INTEGER,
    row_cmp               OUT    PLS_INTEGER,
    row_uncmp             OUT    PLS_INTEGER,
    cmp_ratio             OUT    NUMBER,
    comptype_str          OUT    varchar2,
    subset_numrows        IN     number  DEFAULT COMP_RATIO_MINROWS
  );

  function get_compression_type (
    ownname         IN varchar2,
    tabname         IN varchar2,
    row_id          IN rowid
    )
    return number;

/*      SYNTAX:                                                                                                                 
          call incremental_compress(<Owner name>, <Table name>, <Partition Name>, <Column Name>, [Dump], [Auto Compress], [Where Clause]);                   
          <Owner Name>:     Name of the owner of the table
          <Table Name>:     Name of table under consideration
          <Partition Name>: If the table is partitioned (or sub-partitioned), specify the specific partition (or sub-partition)
                            name here. If the table is sub-partitioned, then each sub-partition will have to be compressed
                            separately. For tables that are not partitioned, this parameter is ignored, so a '' can be specified.
                            NOTE: Each partition or subpartition will have to be compressed separately. It is erroneous to                                          
                            specify a partition name for a table with sub-partitions. The specific sub-partition name will                                 
                            have to be specified.
          <Column Name>:    This column can be any column name in the table. An update statement of the type
                            'update table_name set column_name = column_name' will be run, so choosing any column name should
                            not make any functional difference.
          [Dump]:           An optional parameter that dumps out the space saved in each block into the trace files. It is turned                             
                            OFF by default (set to 0). It is advised not to turn this feature on for large tables or partitions
                            because of excessive logging.
          [Auto Compress]:  If table is not created compressed or compression was never used on this table/partition, setting this to 1 will 
                            force an alter table to switch on and then switch off compression on this table/partition.
          [Where Clause]:   An optional where clause supplied to the update statement. */

  PROCEDURE incremental_compress (
        ownname            IN dba_objects.owner%type,
        tabname            IN dba_objects.object_name%type,
        partname           IN dba_objects.subobject_name%type,
        colname            IN varchar2,
        dump_on            IN number default 0,
        autocompress_on    IN number default 0,
        where_clause       IN varchar2 default '');

end dbms_compression;
/

create or replace public synonym dbms_compression for sys.dbms_compression
/

grant execute on dbms_compression to public
/

show errors;
