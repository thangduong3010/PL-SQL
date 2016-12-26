Rem
Rem $Header: rdbms/admin/catstrc.sql /st_rdbms_11.2.0/6 2013/06/21 14:25:15 romorale Exp $
Rem
Rem catstrc.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catstrc.sql - STReams Compatibility catalog views
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      06/15/13 - Backport jovillag_bug-16590668 from main
Rem    jovillag    02/17/13 - Backport 14669017 from main
Rem    myuin       11/19/12 - Backport myuin_bug-14744396 from main
Rem    nijacob     04/27/12 - Lrg#6948561, 6949244
Rem    yurxu       04/12/11 - Backport yurxu_bug-11922716 from main
Rem    abrown      12/28/10 - Backport abrown_bug-10243237 from main
Rem    jovillag    04/10/13 - 16590668: added filtering to
Rem                           _DBA_XSTREAM_OUT_ALL_TABLES to exclude
Rem                           nested/external tables and removed
Rem                           DBA_NESTED_TABLES/DBA_EXTERNAL_TABLES 
Rem                           from DBA_XSTREAM_OUT_SUPPORT_MODE
Rem                           to improve performance. 
Rem                           Also changed 'NOT IN' for 'MINUS' in the query.
Rem    yurxu       01/24/10 - Bug 9216488: exclude ORDDATA
Rem    bpwang      10/13/09 - add DBA_XSTREAM_OUT_SUPPORT_MODE
Rem    juyuan      03/28/09 - bug-8360767:deduplicate lobs not supported
Rem    bvaranas    04/01/09 - Deferred Segment Creation: Read deferred_stg$ for
Rem                           compression instead of seg$
Rem    juyuan      12/26/08 - table with system partition not uspported
Rem    bpwang      12/01/08 - Lrg 3698017: Change compat to 11.2
Rem    bpwang      11/05/08 - Remove securefile from unsupported views
Rem    jibyun      05/23/08 - Bug 6967206: filter DVSYS schema
Rem    rmao        04/11/08 - Bug 6963505: add back compressed table to
Rem                           _dba_streams_unsupported_11_1, add
Rem                           _dba_streams_unsupported_11_2 and
Rem                           _dba_streams_newly_supted_11_2
Rem    juyuan      02/14/08 - bug-6523185: table with unused columns supported
Rem    rmao        01/23/08 - Bug6525460: remove compressed table from
Rem                           unsupported view
Rem    praghuna    11/21/07 - 6630424: virtual cols are supported
Rem    juyuan      07/05/07 - bug-6146393: flashback archive internal table not
Rem                           supported
Rem    juyuan      05/02/07 - compressed tables not supported
Rem    juyuan      02/20/07 - XML_OR bug fix
Rem    juyuan      12/14/06 - check enable_hierarchy flag of XMLType table
Rem    juyuan      11/28/06 - bug-5699173
Rem    jinwu       11/03/06 - Created
Rem

/* dba_streams_columns view lists compatibility for synchronous capture
 * and apply. 
 * Synchronous capture and apply does not support any columns of the 
 * following objects:
 *     Streams unsupported object
 *     object table
 *     subordinate table
 *     AQ queue table
 *     temporary table
 *     external table
 *     materialized view log
 *     domain index
 * 
 * Synchronous capture and apply does not support the following columns:
 *    securefile
 *    opaque
 *    rowid
 *    ADT
 *    nested table
 *    ref
 *    array
 *    pimary key based OID
 *    FILE
 *    system generated OID
 *    virtual
 *    OID
 *
 *  Synchronous capture does not support the following columns:
 *    NCLOB
 *    CLOB
 *    BLOB
 *    long
 *    long raw
 *    XMLType
 *
 * Apply supports the following since 11.2
 *    Securefile
 *
 * Apply supports the following types of columns, objects or properties
 * since 11.1
 *    XMLType
 *    TDE
 *
 * Apply supports complex IOT since 10.2
 *    IOT with row overflow
 *    IOT overflow segment
 *    IOT with row clustering
 *    IOT with user lob
 *    IOT with internal lob
 *    IOT with row movement
 *    IOT with physical rowid mapping
 *    mapping table for physical rowid of IOT
 *
 * Apply supports the following types of columns, objects or properties
 * since 10.1
 *    varying length CLOB
 *    urowid
 *    IOT
 *    materialized view
 *    materialized view container table
 *    function-based indexing
 *    long
 *    long raw
 *    binary_float
 *    binary_double
 *    NCLOB
 *
 * Apply supports the following types of columns since 9.2
 *    CHAR
 *    VARCHAR2
 *    NCHAR
 *    NVARCHAR2
 *    NUMBER
 *    DATE
 *    CLOB
 *    BLOB
 *    RAW
 *    TIMESTAMP
 *    TIMESTAMP WITH TIME ZONE
 *    TIMESTAMP WITH LOCAL TIME ZONE
 *    INTERVAL YEAR TO MONTH
 *    INTERVAL DAY TO SECOND
 */
create or replace view DBA_STREAMS_COLUMNS
(owner, table_name, column_name, sync_capture_version, 
 sync_capture_reason, apply_version, apply_reason)
as
  select distinct u.name, o.name, c.name,
                                                    /* sync capture version */
    (case
      when bitand(t.property, 1                              /* typed table */
                             + 131072                           /* AQ table */
                             + 134217728                       /* Sub table */
                             + 4194304                        /* temp table */
                             + 8388608                        /* temp table */
                             + 2147483648                 /* external table */
                 ) != 0 or 
            bitand(o.flags, 16) != 0 or                     /* domain index */
            (exists                                /* materialized view log */
              (select 1 
                from   sys.mlog$ ml 
                where  ml.mowner = u.name and ml.log = o.name)
            ) or
           bitand(t.trigflag, 268435456) != 0        /* streams unsupported */
       then NULL
      when c.segcol# = 0 and bitand(c.property, 65536+8) = 65544 and
                             bitand(c.property, 32) = 0
       then 11.1                                          /* virtual column */
      when c.type#  IN
                  (1,                                        /* (N)VARCHAR2 */
                   2,                                             /* NUMBER */
                   12,                                              /* DATE */
                   23,                                               /* RAW */
                   96,                                           /* (N)CHAR */
                   100,                                     /* BINARY_FLOAT */
                   101,                                    /* BINARY_DOUBLE */
                   180,                                        /* TIMESTAMP */
                   182,                           /* INTERVAL YEAR TO MONTH */
                   183,                           /* INTERVAL DAY TO SECOND */
                   181,                         /* TIMESTAMP WITH TIME ZONE */
                   208,                                           /* UROWID */
                   231) then 11.1         /* TIMESTAMP WITH LOCAL TIME ZONE */
      when c.type# in (112, 113) or                       /* securefile/lob */
            c.type# = 69 or
            bitand(t.property, 4                    /* nested table columns */
                            + 8                              /* REF columns */
                            + 4096                                /* pk OID */
                            + 8192 /* storage table for nested table column */
                            + 32768                   /* FILE column exists */
                            + 65536                                 /* sOID */
                    ) != 0 or
            c.type# = 123 or                                /* array column */ 
            bitand(c.property, 2) != 0 or                     /* OID column */
           c.type# = 121                                      /* ADT column */
        then NULL
      else NULL end) 
    sync_capture_version,
    (case
      when  bitand(t.property, 1) != 0                       /* typed table */
        then 'object table'
      when bitand(t.property, 131072) != 0                      /* AQ table */
        then 'AQ queue table'
       when bitand(t.property, 134217728) != 0                 /* Sub table */
        then 'sub table'
      when bitand(t.property, 4194304 + 8388608) != 0         /* temp table */
        then 'temp table'
      when bitand(t.property, 2147483648) !=0             /* external table */
        then 'external table'
      when bitand(o.flags, 16) != 0                         /* domain index */
        then 'domain index'
      when (exists                                 /* materialized view log */
             (select 1 
              from   sys.mlog$ ml 
              where  ml.mowner = u.name and ml.log = o.name)
            )
        then 'materialized view log'
      when  bitand(t.property, 8192) != 0
        then 'storage table for nested table column' 
      when bitand(t.trigflag, 268435456) != 0         /*streams unsupported */
         then 'streams unsupported object'
      when c.segcol# = 0 and 
           (bitand(c.property, 65536+8) != 65544 or  /* not virtual column */
            bitand(c.property, 32) = 32)               
         then 'unsupported column'
      when c.type#  IN
                  (1,                                        /* (N)VARCHAR2 */
                   2,                                             /* NUMBER */
                   12,                                              /* DATE */
                   23,                                               /* RAW */
                   96,                                           /* (N)CHAR */
                   100,                                     /* BINARY_FLOAT */
                   101,                                    /* BINARY_DOUBLE */
                   180,                                        /* TIMESTAMP */
                   182,                           /* INTERVAL YEAR TO MONTH */
                   183,                           /* INTERVAL DAY TO SECOND */
                   181,                         /* TIMESTAMP WITH TIME ZONE */
                   208,                                           /* UROWID */
                   231) then NULL         /* TIMESTAMP WITH LOCAL TIME ZONE */
      when (c.type# IN (112, 113) and                         /* securefile */
            (exists (select 1
                     from lob$ l
                     where c.obj#=l.obj# and
                           c.col#=l.col# and
                           c.obj#=t.obj# and
                           bitand(l.property, 2048) != 0   /* 11g LOCAL lob */
                     ) or
             exists (select 1                     /* partitioned securefile */
                     from lob$ l, lobfrag$ lf
                     where c.obj#=l.obj# and
                           c.col#=l.col# and
                           c.obj#=t.obj# and
                           l.lobj#=lf.parentobj# and
                           bitand(l.property, 4) != 0 and/* partitioned LOB */
                           bitand(lf.fragpro, 2048) != 0   /* 11g LOCAL lob */
                     ) or
             exists (select 1           /* composite-partitioned securefile */
                     from lob$ l, lobcomppart$ p, lobfrag$ lf
                     where c.obj#=l.obj# and
                           c.obj#=t.obj# and
                           c.col#=l.col# and 
                           l.lobj#=p.lobj# and
                           p.partobj#=lf.parentobj# and
                           bitand(l.property, 4) != 0 and/* partitioned LOB */
                           bitand(lf.fragpro, 2048) != 0)))/* 11g LOCAL lob */
         then 'securefile'
      when c.type# = 121 then 'ADT column'
      when c.type# = 69  then 'rowid column'
      when bitand(t.property, 8) != 0                         /* REF colunm */
        then 'table with REF column'
      when bitand(t.property, 4) != 0               /* nested table columns */
        then 'table with nested table column'
      when c.type# = 123                                   /* array columns */
        then 'array column'
      when bitand(t.property, 4096) != 0                          /* pk OID */
        then 'table with primary key based oid column'
      when bitand(t.property, 32768) != 0             /* FILE column exists */
        then 'table with FILE column'
      when bitand(t.property, 65536) != 0                           /* sOID */
        then 'table with system generated OID'
      when bitand(c.property, 2) != 0                         /* OID column */
        then 'table with OID column'
      when c.type# = 8 then  'long column'                          /* LONG */
      when c.type# = 24 then 'long raw column'                  /* LONG RAW */
      when c.type# = 112 then '(N)CLOB column'                   /* (N)CLOB */
      when c.type# = 113 then  'BLOB column'                        /* BLOB */
      else 'Streams unsupported object' end) sync_capture_reason,
                                                           /* apply version */
    (case
       when bitand(t.property, 1                             /* typed table */
                             + 131072                           /* AQ table */
                             + 134217728                       /* Sub table */
                             + 4194304                        /* temp table */
                             + 8388608                        /* temp table */
                             + 2147483648                 /* external table */
                  ) != 0 or
             bitand(o.flags, 16) != 0 or                    /* domain index */
             (exists                               /* materialized view log */
              (select 1 
                from   sys.mlog$ ml 
                where  ml.mowner = u.name and ml.log = o.name)
             ) or 
             bitand(t.trigflag, 268435456) != 0       /*streams unsupported */
         then NULL
       when exists (select 1 from sys.partobj$ p
                    where p.obj# = o.obj# and
                          p.parttype = 3)               /* system partition */
         then NULL
       when c.segcol# = 0 and bitand(c.property, 65544) = 65544 and
                              bitand(c.property, 32) = 0
         then 11.1                                        /* virtual column */
       when c.segcol# = 0 and bitand(c.property, 65536+32+8) = 65576 
         then 10.1                                      /* functional index */
       when (bitand(c.property, 67108864 + 536870912) != 0 and       /* TDE */
             c.type# IN
                  (1,                                        /* (N)VARCHAR2 */
                   2,                                             /* NUMBER */
                   8,                                               /* LONG */
                   12,                                              /* DATE */
                   23,                                               /* RAW */
                   24,                                          /* LONG RAW */
                   96,                                           /* (N)CHAR */
                   100,                                     /* BINARY_FLOAT */
                   101,                                    /* BINARY_DOUBLE */
                   112,                                          /* (N)CLOB */
                   113,                                             /* BLOB */
                   180,                                        /* TIMESTAMP */
                   182,                           /* INTERVAL YEAR TO MONTH */
                   183,                           /* INTERVAL DAY TO SECOND */
                   181,                         /* TIMESTAMP WITH TIME ZONE */
                   208,                                           /* UROWID */
                   231)) then 11.1        /* TIMESTAMP WITH LOCAL TIME ZONE */ 
       when ((bitand(t.property, 262208) = 262208 or      /* IOT + user LOB */
              bitand(t.property, 128 + 512) != 0 or/* IOT with row overflow */
              bitand(t.property, 2112) = 2122 or      /* IOT + internal LOB */
              bitand(t.property, 256) != 0 or    /* IOT with row clustering */ 
              (bitand(t.property, 64) != 0 and 
               bitand(t.flags, 131072) != 0) or    /* IOT with row movement */
                                         /* IOT with physical Rowid mapping */
             bitand(t.flags, 268435456) != 0 or
                                 /* Mapping table for physical rowid of IOT */
             bitand(t.flags, 536870912) != 0) and
             c.type# IN
                  (1,                                        /* (N)VARCHAR2 */
                   2,                                             /* NUMBER */
                   8,                                               /* LONG */
                   12,                                              /* DATE */
                   23,                                               /* RAW */
                   24,                                          /* LONG RAW */
                   96,                                           /* (N)CHAR */
                   100,                                     /* BINARY_FLOAT */
                   101,                                    /* BINARY_DOUBLE */
                   112,                                          /* (N)CLOB */
                   113,                                             /* BLOB */
                   180,                                        /* TIMESTAMP */
                   182,                           /* INTERVAL YEAR TO MONTH */
                   183,                           /* INTERVAL DAY TO SECOND */
                   181,                         /* TIMESTAMP WITH TIME ZONE */
                   208,                                           /* UROWID */
                   231)) then 10.2        /* TIMESTAMP WITH LOCAL TIME ZONE */
       when ((bitand(t.property, 64) != 0 or                         /* IOT */
                                                       /* materialized view */
              bitand(t.property, 33554432 + 67108864) != 0 or 
                                       /* materialized view container table */
              bitand(t.flags, 262144) != 0 ) and
             c.type# IN 
                  (1,                                        /* (N)VARCHAR2 */
                   2,                                             /* NUMBER */
                   8,                                               /* LONG */
                   12,                                              /* DATE */
                   23,                                               /* RAW */
                   24,                                          /* LONG RAW */
                   96,                                           /* (N)CHAR */
                   100,                                     /* BINARY_FLOAT */
                   101,                                    /* BINARY_DOUBLE */
                   112,                                          /* (N)CLOB */
                   113,                                             /* BLOB */
                   180,                                        /* TIMESTAMP */
                   182,                           /* INTERVAL YEAR TO MONTH */
                   183,                           /* INTERVAL DAY TO SECOND */
                   181,                         /* TIMESTAMP WITH TIME ZONE */
                   208,                                           /* UROWID */
                   231)) then 10.1        /* TIMESTAMP WITH LOCAL TIME ZONE */
       when c.type# in (1,                                   /* (N)VARCHAR2 */
                        2,                                        /* NUMBER */
                        12,                                         /* DATE */
                        23,                                          /* RAW */
                        96,                                      /* (N)CHAR */
                        113,                                        /* BLOB */
                        180,                                   /* TIMESTAMP */
                        181,                    /* TIMESTAMP WITH TIME ZONE */
                        182,                      /* INTERVAL YEAR TO MONTH */
                        183,                      /* INTERVAL DAY TO SECOND */
                        231) then 9.2     /* TIMESTAMP WITH LOCAL TIME ZONE */
       when c.type# in (8,                                          /* LONG */
                        24,                                     /* LONG RAW */
                        100,                                /* BINARY_FLOAT */
                        101,                               /* BINARY_DOUBLE */
                        208) then 10.1                            /* UROWID */
      when (c.type# IN (112, 113) and                         /* securefile */
            (exists (select 1
                    from lob$ l
                    where c.obj#=l.obj# and
                          c.obj#=t.obj# and
                          c.col#=l.col# and 
                          bitand(l.property, 2048) != 0     /* 11g LOCAL lob */
                    ) or
             exists (select 1                      /* partitioned securefile */
                   from lob$ l, lobfrag$ lf
                    where c.obj#=l.obj# and
                          c.obj#=t.obj# and
                          c.col#=l.col# and 
                          l.lobj#=lf.parentobj# and
                          bitand(l.property, 4) != 0 and  /* partitioned LOB */
                          bitand(lf.fragpro, 2048) != 0     /* 11g LOCAL lob */
                    ) or
             exists (select 1            /* composite-partitioned securefile */
                    from lob$ l, lobcomppart$ p, lobfrag$ lf
                    where c.obj#=l.obj# and
                          c.obj#=t.obj# and
                          c.col#=l.col# and 
                          l.lobj#=p.lobj# and
                          p.partobj#=lf.parentobj# and
                          bitand(l.property, 4) != 0 and /* partitioned LOB */
                          bitand(lf.fragpro, 2048) != 0))) /* 11g LOCAL lob */
         then 11.2
       when c.type# = 112 then
         (case 
            when c.charsetform = 2 or
                 c.charsetform = 1 and c.charsetid >= 800
              then 10.1                                            /* NCLOB */
              else 9.2 end)                                         /* CLOB */
       when c.type# = 69 or
            bitand(t.property, 4                    /* nested table columns */
                            + 8                              /* REF columns */
                            + 4096                                /* pk OID */
                            + 8192 /* storage table for nested table column */
                            + 32768                   /* FILE column exists */
                            + 65536                                 /* sOID */
                    ) != 0 or
            c.type# = 123 or                                /* array column */
            bitand(c.property, 2) != 0 or                     /* OID column */
            c.type# = 121                                     /* ADT column */
        then NULL
     end) apply_version,
                                                            /* apply reason */
    (case
      when exists (select 1 from sys.partobj$ p
                   where p.obj# = o.obj# and
                         p.parttype = 3)                /* system partition */
        then 'table with system partition'
      when  bitand(t.property, 1) != 0                       /* typed table */
        then 'object table'
      when bitand(t.property, 131072) != 0                      /* AQ table */
        then 'AQ queue table'
      when bitand(t.property, 134217728) != 0                  /* Sub table */
        then 'sub table'
      when bitand(t.property, 4194304 + 8388608) != 0         /* temp table */
        then 'temp table'
      when bitand(t.property, 2147483648) !=0             /* external table */
        then 'external table'
      when bitand(o.flags, 16) != 0                         /* domain index */
        then 'domain index'
                                   /* storage table for nested table column */
      when  bitand(t.property, 8192) != 0
        then 'storage table for nested table column'
      when (exists                                 /* materialized view log */
             (select 1 
              from   sys.mlog$ ml 
              where  ml.mowner = u.name and ml.log = o.name)
            )
        then 'materialized view log'
      when bitand(t.trigflag, 268435456) != 0        /* streams unsupported */
         then 'Streams unsupported object'
      when (c.type# IN (112, 113) and                         /* securefile */
            (exists (select 1
                    from lob$ l
                    where c.obj#=l.obj# and
                          c.obj#=t.obj# and
                          c.col#=l.col# and 
                          bitand(l.property, 2048) != 0    /* 11g LOCAL lob */
                    ) or
             exists (select 1                      /* partitioned securefile */
                   from lob$ l, lobfrag$ lf
                    where c.obj#=l.obj# and
                          c.obj#=t.obj# and
                          c.col#=l.col# and 
                          l.lobj#=lf.parentobj# and
                          bitand(l.property, 4) != 0 and  /* partitioned LOB */
                          bitand(lf.fragpro, 2048) != 0     /* 11g LOCAL lob */
                     ) or
              exists (select 1           /* composite-partitioned securefile */
                     from lob$ l, lobcomppart$ p, lobfrag$ lf
                     where c.obj#=l.obj# and
                           c.obj#=t.obj# and
                           c.col#=l.col# and 
                           l.lobj#=p.lobj# and
                           p.partobj#=lf.parentobj# and
                           bitand(l.property, 4) != 0 and/* partitioned LOB */
                           bitand(lf.fragpro, 2048) != 0)))/* 11g LOCAL lob */
        then 'securefile'
      when c.type# = 121 then 'ADT column'
      when c.type# = 69
        then 'rowid column'
      when c.type# = 123                                   /* array columns */
        then 'array column'
      when bitand(c.property, 67108864 + 536870912) != 0             /* TDE */
        then 'column encrypted'
      when bitand(t.property, 128 + 512) != 0      /* IOT with row overflow */
        then 'IOT with row overflow'  
      when bitand(t.property, 262208) = 262208            /* IOT + user LOB */
        then 'IOT with user LOBs'
      when bitand(t.property, 2112) = 2112            /* IOT + internal LOB */
        then 'IOT with internal LOBs'
      when (bitand(t.property, 64) != 0 and        /* IOT with row movement */
            bitand(t.flags, 131072) != 0)
        then 'IOT with row movement' 
                                         /* IOT with physical Rowid mapping */
      when bitand(t.flags, 268435456) != 0
        then 'IOT with physical rowid mapping'
                                 /* Mapping table for physical rowid of IOT */
      when bitand(t.flags, 536870912) != 0
        then 'mapping table for physical rowid of IOT '
      when bitand(t.property, 256) != 0          /* IOT with row clustering */
        then 'IOT with row clustering'
      when bitand(t.property, 64) != 0                         /* Basic IOT */
        then 'IOT'
      when bitand(t.property, 33554432 + 67108864) != 0/* materialized view */
        then 'materialized view'
      when bitand(t.flags, 262144) != 0/* materialized view container table */
        then 'materialized view container table'
      when c.segcol# = 0 and 
             bitand(c.property, 65536+8) != 65544 and /* not virtual column */
             bitand(c.property, 65536+32+8) != 65576/* not functional index */
        then 'unsupported column'                     /* unsupported column */
      when c.type# in (1,                                    /* (N)VARCHAR2 */
                       2,                                         /* NUMBER */
                       12,                                          /* DATE */
                       96,                                       /* (N)CHAR */
                       23,                                           /* RAW */
                       113,                                         /* BLOB */
                       180,                                    /* TIMESTAMP */
                       182,                       /* INTERVAL YEAR TO MONTH */
                       183,                       /* INTERVAL DAY TO SECOND */
                       181,                     /* TIMESTAMP WITH TIME ZONE */
                       231) then NULL     /* TIMESTAMP WITH LOCAL TIME ZONE */
      when c.type# = 8 then 'long column'                           /* LONG */
      when c.type# = 24 then 'long raw column'                  /* LONG RAW */
      when c.type# = 100 then 'binary_float column'         /* BINARY_FLOAT */
      when c.type# = 101 then 'binary_double column'       /* BINARY_DOUBLE */
      when c.type# = 112 then 
        (case 
          when c.charsetform = 2
            then 'NCLOB column'                                    /* NCLOB */
          when c.charsetform = 1 and c.charsetid >= 800
            then 'varing length CLOB column'
            else NULL end)                                          /* CLOB */
      when c.type# = 208 then 'urowid'                            /* UROWID */
      when bitand(t.property, 4) != 0               /* nested table columns */
        then 'table with nested table column'
      when bitand(t.property, 8) != 0                        /* REF columns */
        then 'table with REF column'
      when bitand(t.property, 4096) != 0                          /* pk OID */
        then 'table with primary key based OID column'
      when bitand(t.property, 32768) != 0             /* FILE column exists */
        then 'table with FILE column'
      when bitand(t.property, 65536) != 0                           /* sOID */
        then 'table with system generated OID'
      when bitand(c.property, 2) != 0                         /* OID column */
        then 'oid column'
      else 'Streams unsupported object' end) apply_reason
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.col$ c
  where c.obj# = o.obj# and
        c.type# <> 58 and
        o.obj# = t.obj# and
        o.owner# = u.user# and
        bitand(c.property, 32) = 0 and 
                  /* should be consistent with knlcfIsFilteredSpecialSchema */
        u.name not in ('SYS', 'SYSTEM', 'CTXSYS', 'DBSNMP', 'LBACSYS',
                       'MDDATA', 'MDSYS', 'DMSYS', 'OLAPSYS', 'ORDPLUGINS',
                       'ORDSYS', 'SI_INFORMTN_SCHEMA', 'SYSMAN', 'OUTLN',
                       'EXFSYS', 'WMSYS', 'XDB', 'DVSYS', 'ORDDATA') and 
        bitand(o.flags,
                  2                                     /* temporary object */
                + 4                              /* system generated object */
                + 32                                /* in-memory temp table */
                + 128                         /* dropped table (RecycleBin) */
                  ) = 0 and
        (
          bitand(t.property, 1                               /* typed table */
                             + 4                    /* nested table columns */
                             + 8                             /* REF columns */
                             + 4096                               /* pk OID */
                             + 8192/* storage table for nested table column */
                             + 32768                  /* FILE column exists */
                             + 65536                                /* sOID */
                             + 131072                           /* AQ table */
                             + 134217728                       /* Sub table */
                             + 4194304                        /* temp table */
                             + 8388608                        /* temp table */
                             + 2147483648                 /* external table */
                 ) != 0 or
          bitand(o.flags, 16) != 0 or                       /* domain index */
           (exists                                 /* materialized view log */
             (select 1 
              from   sys.mlog$ ml 
              where  ml.mowner = u.name and ml.log = o.name)
           ) or
           bitand(t.trigflag, 268435456) != 0 or     /* streams unsupported */
           (c.type# IN (112, 113) and                         /* securefile */
            (exists (select 1
                    from lob$ l
                    where c.obj#=l.obj# and c.col#=l.col# and 
                    c.obj#=t.obj# and
                    bitand(l.property, 2048) != 0)) or    /* 11g LOCAL lob */
             exists (select 1                     /* partitioned securefile */
                    from lob$ l, lobfrag$ lf
                    where c.obj#=l.obj# and
                          c.obj#=t.obj# and
                          c.col#=l.col# and 
                          l.lobj#=lf.parentobj# and
                          bitand(l.property, 4) != 0 and /* partitioned LOB */
                          bitand(lf.fragpro, 2048) != 0) or/* 11g LOCAL lob */
             exists (select 1           /* composite-partitioned securefile */
                     from lob$ l, lobcomppart$ p, lobfrag$ lf
                     where c.obj#=l.obj# and
                           c.obj#=t.obj# and
                           c.col#=l.col# and 
                           l.lobj#=p.lobj# and
                           p.partobj#=lf.parentobj# and
                           bitand(l.property, 4) != 0 and/* partitioned LOB */
                           bitand(lf.fragpro, 2048) != 0)) or/*11g LOCAL lob*/
            c.type# = 69 or
            c.type# = 123 or                                /* array column */ 
            c.segcol# = 0 or                              /* virtual column */
            bitand(c.property, 2) != 0 or                     /* OID column */
            c.type# = 121 or                                  /* ADT column */
            c.type# IN
                  (1,                                        /* (N)VARCHAR2 */
                   2,                                             /* NUMBER */
                   8,                                               /* LONG */
                   12,                                              /* DATE */
                   23,                                               /* RAW */
                   24,                                          /* LONG RAW */
                   96,                                           /* (N)CHAR */
                   100,                                     /* BINARY_FLOAT */
                   101,                                    /* BINARY_DOUBLE */
                   112,                                          /* (N)CLOB */
                   113,                                             /* BLOB */
                   180,                                        /* TIMESTAMP */
                   182,                           /* INTERVAL YEAR TO MONTH */
                   183,                           /* INTERVAL DAY TO SECOND */
                   181,                         /* TIMESTAMP WITH TIME ZONE */
                   208,                                           /* UROWID */
                   231)
        )
union all
  select distinct u.name, o.name, c.name, NULL,     /* sync_capture_version */
    (case                                            /* sync_capture_reason */
      when exists (select 1 from sys.partobj$ p
                   where p.obj# = o.obj# and
                         p.parttype = 3)                /* system partition */
        then 'table with system partition'
      when op.type = 1 then                                     /* XML Type */
        (case when bitand(op.flags,512) ! = 0
                   then 'hierarchy enabled XMLType table'
              when bitand(op.flags,
                                  1             /* XMLType stored as object */
                                + 2          /* XMLType schema is specified */
                                + 4                /* XMLType stored as lob */
                                + 8          /* XMLType stores extra column */
                                + 32        /* XMLType table is out-of-line */
                                + 64            /* XMLType stored as binary */
                                + 128           /* XMLType binary ANYSCHEMA */
                                + 256) != 0 /* XMLType binary NO non-schema */
                   then 'XMLType column'
              else 'streams unsupported object' 
         end) 
     else 'unsupported opaque type column' end) sync_capture_reason,
    (case                                                  /* apply_version */
      when exists (select 1 from sys.partobj$ p
                   where p.obj# = o.obj# and
                         p.parttype = 3)                /* system partition */
        then NULL
      when op.type = 1 then                                     /* XML Type */
        (case when bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 8                /* XMLType stores extra column */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                          + 256) != 0       /* XMLType binary NO non-schema */
              then NULL
              when bitand(op.flags,
                            2                /* XMLType schema is specified */
                          + 4                      /* XMLType stored as lob */ 
                          + 32 ) != 0       /* XMLType table is out-of-line */
                then 11.1
              else NULL end)
      else NULL end) apply_version,
    (case                                                   /* apply_reason */
      when exists (select 1 from sys.partobj$ p
                   where p.obj# = o.obj# and
                         p.parttype = 3)                /* system partition */
        then 'table with system partition'
      when op.type = 1 then                                     /* XML Type */
        (case when bitand(op.flags,
                                  1             /* XMLType stored as object */
                                + 8          /* XMLType stores extra column */
                                + 64            /* XMLType stored as binary */
                                + 128           /* XMLType binary ANYSCHEMA */
                                + 256) != 0 /* XMLType binary NO non-schema */
                   then 'unsupported XMLType column'             
              when bitand(op.flags,
                                + 2          /* XMLType schema is specified */
                                + 4                /* XMLType stored as lob */ 
                                + 32)       /* XMLType table is out-of-line */
                    != 0 then 'XMLType column'      
        else 'unsupported XMLType column' end)
      else 'unsupported opaque type column' end) apply_reason
    from sys.user$ u, sys.opqtype$ op, sys.obj$ o, sys.tab$ t, sys.col$ c 
    where c.intcol# = op.intcol# and
          c.obj# = op.obj# and
          u.user# = o.owner# and
          o.obj# = t.obj# and
          t.obj# = c.obj# and
          c.type# = 58 and                                  /* opaque types */
          bitand(c.property, 32) = 0 and                      /* not hidden */
                  /* should be consistent with knlcfIsFilteredSpecialSchema */
          u.name not in ('SYS', 'SYSTEM', 'CTXSYS', 'DBSNMP', 'LBACSYS',
                         'MDDATA', 'MDSYS', 'DMSYS', 'OLAPSYS', 'ORDPLUGINS',
                         'ORDSYS', 'SI_INFORMTN_SCHEMA', 'SYSMAN', 'OUTLN',
                         'EXFSYS', 'WMSYS', 'XDB', 'DVSYS', 'ORDDATA') and
          bitand(o.flags,
                  2                                     /* temporary object */
                + 4                              /* system generated object */
                + 32                                /* in-memory temp table */
                + 128                         /* dropped table (RecycleBin) */
                  ) = 0
/

comment on table DBA_STREAMS_COLUMNS is 
'Supportability info about streams columns'
/

comment on column DBA_STREAMS_COLUMNS.OWNER is
'Owner of the object'
/

comment on column DBA_STREAMS_COLUMNS.TABLE_NAME is
'Name of the object'
/

comment on column DBA_STREAMS_COLUMNS.COLUMN_NAME is
'Name of the column'
/

comment on column DBA_STREAMS_COLUMNS.SYNC_CAPTURE_VERSION is
'Version of sync capture which supports this column'
/

comment on column DBA_STREAMS_COLUMNS.SYNC_CAPTURE_REASON is
'Reason why this column is not supported by sync capture'
/

comment on column DBA_STREAMS_COLUMNS.APPLY_VERSION is
'Version of apply which supports this column'
/

comment on column DBA_STREAMS_COLUMNS.APPLY_REASON is
'Reason why this column is not supported by apply'
/

create or replace public synonym DBA_STREAMS_COLUMNS for DBA_STREAMS_COLUMNS
/

grant select on DBA_STREAMS_COLUMNS to select_catalog_role
/

create or replace view ALL_STREAMS_COLUMNS
as
  select s.* from dba_streams_columns s, all_objects a
    where s.owner = a.owner
      and s.table_name = a.object_name
      and a.object_type = 'TABLE';

comment on table ALL_STREAMS_COLUMNS is 
'Streams unsupported columns'
/

comment on column ALL_STREAMS_COLUMNS.OWNER is
'Owner of the object'
/

comment on column ALL_STREAMS_COLUMNS.TABLE_NAME is
'Name of the object'
/

comment on column ALL_STREAMS_COLUMNS.SYNC_CAPTURE_VERSION is
'Version of sync capture which supports this column'
/

comment on column ALL_STREAMS_COLUMNS.SYNC_CAPTURE_REASON is
'Reason why this column is not supported by sync capture'
/

comment on column ALL_STREAMS_COLUMNS.APPLY_VERSION is
'Version of apply which supports this column'
/

comment on column ALL_STREAMS_COLUMNS.APPLY_REASON is
'Reason why this column is not supported by apply'
/

create or replace public synonym ALL_STREAMS_COLUMNS for ALL_STREAMS_COLUMNS
/

grant select on ALL_STREAMS_COLUMNS to PUBLIC with grant option
/

create or replace view "_DBA_STREAMS_UNSUPPORTED_9_2"
  (owner, table_name, tproperty, ttrigflag, oflags, tflags, reason, compatible,
   auto_filtered)
as
  select
    distinct u.name, o.name,
             t.property, t.trigflag, o.flags, t.flags,
     (case
      when 
        ( (bitand(t.property, 
                64                                                    /* IOT */
              + 128         /* 0x00000080              IOT with row overflow */
              + 256         /* 0x00000100            IOT with row clustering */
              + 512         /* 0x00000200               IOT overflow segment */
             ) != 0
          ) or
          (bitand(t.flags,
                268435456    /* 0x10000000   IOT with Phys Rowid/mapping tab */
              + 536870912    /* 0x20000000 Mapping Tab for Phys rowid of IOT */
             ) != 0
          ) or
          (bitand(t.property, 262208) = 262208  /* 0x40+0x40000 IOT+user LOB */
          ) or
          (bitand(t.property, 2112) = 2112  /* 0x40+0x800 IOT + internal LOB */
          ) or
          (bitand(t.property, 64) != 0 and                           /* 0x40 */
             bitand(t.flags, 131072) != 0  /* 0x20000  IOT with row movement */
          )
        )
        then 'IOT'
      when exists (select 1 from sys.partobj$ p
                   where p.obj# = o.obj# and
                         p.parttype = 3)                 /* system partition */
        then 'table with system partition'
      when
        (exists 
          (select 1 
           from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
          )
        )
        then 'materialized view log'
      when bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192              /* storage table for nested table column */
                + 65536                                              /* sOID */
               ) != 0
         then 'column with user-defined type'
      when ( bitand(nvl(s.spare1, 0), 2048) = 2048  or  /* table compression */
             bitand(nvl(ds.flags_stg, 0), 4) = 4   /* DSC: table compression */
           )
         then 'table compression'
      when (exists                                                   /* long */
            (select 1 from sys.col$ c
             where t.obj# = c.obj# and c.type# = 8))
        then 'table with long column'
      when (exists                                                /* long raw*/
            (select 1 from sys.col$ c
             where t.obj# = c.obj# and c.type# = 24)) 
        then 'table with long raw column'
      when (exists                                           /* binary_float */
            (select 1 from sys.col$ c
             where t.obj# = c.obj# and c.type# = 100))
        then 'table with binary_float column'
      when (exists                                          /* binary_double */
            (select 1 from sys.col$ c
             where t.obj# = c.obj# and c.type# = 101))
        then 'table with binary_double column'
      when (exists 
            (select 1 from sys.col$ c                               /* nclob */
             where t.obj# = c.obj# and c.type# = 112 and c.charsetform = 2))
        then 'table with NCLOB column'
      when (exists                                                 /* urowid */
            (select 1 from sys.col$ c
             where t.obj# = c.obj# and c.type# = 208))
        then 'table with urowid column'
      when (exists                                 /* funtion-based indexing */
            (select 1 from sys.ind$ i
             where i.bo# = t.obj#
             and bitand(i.property, 16) = 16))
        then 'table with function-based indexing'
      when (exists
            (select 1 
             from   sys.col$ c 
             where  t.obj# = c.obj#
               and
               ( (bitand(c.property, 32) = 32 and                  /* hidden */
                  bitand (c.property, 32768) != 32768          /* not unused */
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     12,                                             /* date */
                     96,                                             /* char */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (c.segcol# = 0             /* virtual column: not supported */
                 ) or
                 (bitand(c.property, 
                         2                                     /* OID column */
                       + 67108864                             /* KQLDCOP_ENC */
                       ) != 0
                 ) or
                 (c.type# = 112 and c.charsetform = 2               /* NCLOB */
                 ) or
                 (c.type# = 112 and c.charsetform = 1 and
                  /* discussed with JIYANG, varying width CLOB */
                  c.charsetid >= 800
                 )
               )
             )
          )
         then 'unsupported column exists'
      when bitand(t.property, 1) = 1
        then 'object table'
      when bitand(t.property, 131072) = 131072
        then 'AQ queue table'
      /* x00400000 + 0x00800000 */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'temporary table'
      when bitand(t.property, 134217728) = 134217728          /* 0x08000000 */
        then 'sub object'
      when bitand(t.property, 2147483648) = 2147483648
        then 'external table'
      when bitand(t.property, 33554432 + 67108864) != 0
        then 'materialized view'
      when bitand(t.property, 32768) = 32768     /* 0x8000 has FILE columns */
        then 'FILE column exists'
      when bitand(t.flags, 262144) = 262144
        then 'materalized view container table'
      when bitand(t.trigflag, 268435456) = 268435456
        then 'streams unsupported object'
      when bitand(o.flags, 16) = 16
        then 'domain index'
      else 'Streams unsupported table' end) reason, 
      92,                                                      /* compatible */
      'NO'                                                  /* auto filtered */
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.deferred_stg$ ds
  where t.obj# = o.obj#
    and o.owner# = u.user#
    and t.file# = s.file# (+)
    and t.block# = s.block# (+)
    and t.ts# = s.ts# (+)
    and t.obj# = ds.obj# (+)
                   /* should be consistent with knlcfIsFilteredSpecialSchema */
    and u.name not in ('SYS', 'SYSTEM', 'CTXSYS', 'DBSNMP', 'LBACSYS',
                       'MDDATA', 'MDSYS', 'DMSYS', 'OLAPSYS', 'ORDPLUGINS',
                       'ORDSYS', 'SI_INFORMTN_SCHEMA', 'SYSMAN', 'OUTLN',
                       'EXFSYS', 'WMSYS', 'XDB', 'DVSYS', 'ORDDATA')
    and bitand(o.flags,
                  2                                      /* temporary object */
                + 4                               /* system generated object */
                + 32                                 /* in-memory temp table */
                + 128                          /* dropped table (RecycleBin) */
                  ) = 0
    and
      (  (bitand(t.property, 
                64                                                    /* IOT */
              + 128         /* 0x00000080              IOT with row overflow */
              + 256         /* 0x00000100            IOT with row clustering */
              + 512         /* 0x00000200               IOT overflow segment */
             ) != 0
          ) or
          (bitand(t.flags,
                268435456    /* 0x10000000   IOT with Phys Rowid/mapping tab */
              + 536870912    /* 0x20000000 Mapping Tab for Phys rowid of IOT */
             ) != 0
          ) or
          (bitand(t.property, 262208) = 262208  /* 0x40+0x40000 IOT+user LOB */
          ) or
          (bitand(t.property, 2112) = 2112  /* 0x40+0x800 IOT + internal LOB */
          ) or
          (bitand(t.property, 64) != 0 and                           /* 0x40 */
             bitand(t.flags, 131072) != 0                         /* 0x20000 */
          ) or                                    /* IOT with "Row Movement" */
          (bitand(nvl(s.spare1, 0), 2048) = 2048) or    /* table compression */
          (bitand(nvl(ds.flags_stg, 0), 4) = 4) or /* DSC: table compression */
          (bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192              /* storage table for nested table column */
                + 65536                                              /* sOID */
               ) != 0
          ) or
          (exists
            (select 1 from sys.partobj$ p
             where p.obj# = o.obj# and
                   p.parttype = 3)) or                   /* system partition */
          (exists                                      /* unsupported column */
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ( (bitand(c.property,          /* check for encrypted columns */
                       + 67108864                             /* KQLDCOP_ENC */
                       ) != 0) or
                 (c.segcol# != 0 and 
                  bitand(c.property, 32) = 32 and                  /* hidden */
                  bitand (c.property, 32768) != 32768          /* not unused */
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     12,                                             /* date */
                     96,                                             /* char */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (c.segcol# = 0             /* virtual column: not supported */
                 ) or
                 (bitand(c.property, 2) = 2                    /* OID column */
                 ) or
                 (c.type# = 112 and c.charsetform = 2               /* NCLOB */
                 ) or
                 (c.type# = 112 and c.charsetform = 1 and
                  /* discussed with JIYANG, varying width CLOB */
                  c.charsetid >= 800
                 )
               )
             )
          ) or
          (bitand(t.property, 1) = 1                         /* object table */
          ) or 
          (bitand(t.property,
                131072      /* 0x00020000 table is used as an AQ queue table */
              + 4194304     /* 0x00400000             global temporary table */
              + 8388608     /* 0x00800000   session-specific temporary table */
              + 33554432    /* 0x02000000        Read Only Materialized View */
              + 67108864    /* 0x04000000            Materialized View table */
              + 134217728   /* 0x08000000                    Is a Sub object */
              + 2147483648   /* 0x80000000                    eXternal TaBle */
             ) != 0
          ) or
          (bitand(t.flags,
                  262144              /* 0x00040000   MV Container Table, MV */
                 ) = 262144
          ) or 
          (bitand(t.property, 32768) = 32768      /* 0x8000 has FILE columns */
          ) or 
          (bitand(t.trigflag, 
                  65536     /* 0x00010000   server held key encrypted column */
                + 131072    /* 0x00020000     user held key encrypted column */
                + 268435456 /* 0x10000000                         strm unsup */
             ) != 0
          ) or 
          (exists 
            (select 1 
             from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
            )
          ) or
          (exists                                 /* funtion-based indexing */
            (select 1 from sys.ind$ i
             where i.bo# = t.obj#
             and bitand(i.property, 16) = 16))
        )
/

/*
** THE CASE STATEMENTS IN THE SELECT CLAUSE SHOULD BE IDENTICAL
** TO THE OR CLAUSES IN THE WHERE CLAUSE.
**
** It's pretty clear that we can't use dba_% views, e.g., dba_tab_columns
** due to the complexity of our logic.
**
** This view lists unsupported tables in 10.1.
*/
create or replace view "_DBA_STREAMS_UNSUPPORTED_10_1"
  (owner, table_name, tproperty, ttrigflag, oflags, tflags, reason, compatible,
   auto_filtered)
as
  select
    distinct u.name, o.name,
             t.property, t.trigflag, o.flags, t.flags,
    (case
      when bitand(t.property, 128 + 512 ) != 0             /* 0x080 + 0x200 */
        then 'IOT with row overflow'
      when bitand(t.property, 256 ) != 0                   /* 0x080 + 0x200 */
        then 'IOT with row clustering'
      when bitand(t.property, 262208) = 262208                   /* 0x40040 */
        then 'IOT with LOB'                                     /* user lob */
      when bitand(t.flags, 268435456) = 268435456             /* 0x10000000 */
        then 'IOT with physical Rowid mapping'
      when bitand(t.flags, 536870912) = 536870912             /* 0x20000000 */
        then 'mapping table for physical rowid of IOT'
      when bitand(t.property, 2112) = 2112 /* 0x40+0x800 IOT + internal LOB */
        then 'IOT with LOB'                                 /* internal lob */
      when (bitand(t.property, 64) = 64 and 
            bitand(t.flags, 131072) = 131072)
        then 'IOT with row movement'                             /* 0x20000 */
      when exists (select 1 from sys.partobj$ p
                   where p.obj# = o.obj# and
                         p.parttype = 3)                 /* system partition */
        then 'table with system partition'
      when
        (exists
          (select 1 
           from   sys.mlog$ ml 
           where  ml.mowner = u.name and ml.log = o.name)
        )
        then 'materialized view log'
      when bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0
        then 'column with user-defined type'
      when ( bitand(nvl(s.spare1, 0), 2048) = 2048  or  /* table compression */
             bitand(nvl(ds.flags_stg, 0), 4) = 4   /* DSC: table compression */
           )
        then 'table compression'
      when bitand(t.trigflag, 65536 + 131072) != 0                /* 0x10000 */
        then 'Table with encrypted column'
      when (exists                                                    /* TDE */
            (select 1 from sys.col$ c
             where t.obj# = c.obj# and 
                   bitand(c.property, 67108864 + 536870912) != 0))
        then 'table with encrypted column'
      when (exists                                                    /* oid */
            (select 1 from sys.col$ c
             where t.obj# = c.obj# and bitand(c.property, 2) = 2))
        then 'table with OID column'
      when (exists
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ((c.segcol# = 0 and bitand(c.property, 65536+32+8) != 65576 and
                              bitand(c.property, 131072) != 131072 ) or
                                                     /* not functional index */
                (c.segcol# != 0 and 
                 bitand(c.property, 32) = 32 and                   /* hidden */
                 bitand(c.property, 32768) != 32768) or        /* not unused */
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 )
               )
             )
          )
        then 'unsupported column exists'
      when bitand(t.property, 1) = 1
        then 'object table'
      when bitand(t.property, 131072) = 131072
        then 'AQ queue table'
      /* x00400000 + 0x00800000 */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'temporary table'
      when bitand(t.property, 134217728) = 134217728          /* 0x08000000 */
        then 'sub object'
      when bitand(t.property, 2147483648) = 2147483648        /* 0x80000000 */
        then 'external table'
      when bitand(t.property, 32768) = 32768     /* 0x8000 has FILE columns */
        then 'FILE column exists'
      when bitand(t.trigflag, 268435456) = 268435456
        then 'streams unsupported object'
      when bitand(o.flags, 16) = 16
        then 'domain index'
      else NULL end) reason, 
      100,                                                     /* compatible */
    (case
      when bitand(t.trigflag, 268435456) = 268435456  /* streams unsupported */
        then 'YES'
      /* x00400000 + 0x00800000  : Temp table */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'YES'
      when bitand(o.flags, 16) = 16                          /* domain index */
        then 'YES'
      else 'NO' end) auto_filtered     
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.deferred_stg$ ds
    where t.obj# = o.obj#
      and o.owner# = u.user#
      and t.file# = s.file# (+)
      and t.block# = s.block# (+)
      and t.ts# = s.ts# (+)
      and t.obj# = ds.obj# (+)
                   /* should be consistent with knlcfIsFilteredSpecialSchema */
      and u.name not in ('SYS', 'SYSTEM', 'CTXSYS', 'DBSNMP', 'LBACSYS',
                         'MDDATA', 'MDSYS', 'DMSYS', 'OLAPSYS', 'ORDPLUGINS',
                         'ORDSYS', 'SI_INFORMTN_SCHEMA', 'SYSMAN', 'OUTLN',
                         'EXFSYS', 'WMSYS', 'XDB', 'DVSYS', 'ORDDATA')
      and bitand(o.flags,
                  2                                      /* temporary object */
                + 4                               /* system generated object */
                + 32                                 /* in-memory temp table */
                + 128                          /* dropped table (RecycleBin) */
                  ) = 0
      and
      (  (bitand(t.property, 
                128         /* 0x00000080              IOT with row overflow */
              + 256         /* 0x00000100            IOT with row clustering */
              + 512         /* 0x00000200               IOT overflow segment */
             ) != 0
          ) or
          (bitand(t.flags,
                268435456    /* 0x10000000   IOT with Phys Rowid/mapping tab */
              + 536870912    /* 0x20000000 Mapping Tab for Phys rowid of IOT */
             ) != 0
          ) or
          (bitand(t.property, 262208) = 262208  /* 0x40+0x40000 IOT+user LOB */
          ) or
          (bitand(t.property, 2112) = 2112  /* 0x40+0x800 IOT + internal LOB */
          ) or
          (bitand(t.property, 64) != 0 and
             bitand(t.flags, 131072) != 0
          ) or                                    /* IOT with "Row Movement" */
          (bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0
          ) or
          (exists                                      /* unsupported column */
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ((c.segcol# = 0 and bitand(c.property, 65536+32+8) != 65576 and
                              bitand(c.property, 131072) != 131072 ) or
                                                     /* not functional index */
                (c.segcol# != 0 and 
                 bitand(c.property, 32) = 32 and            /* hidden column */
                 bitand(c.property, 32768) != 32768) or /* not unused column */
                 (bitand(c.property,          /* check for encrypted columns */
                         67108864           /* column encrypted without salt */
                       + 536870912             /* column encrypted with salt */
                       ) != 0 
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (bitand(c.property, 2) = 2                    /* OID column */
                 )
               )
             )
          ) or
          (bitand(nvl(s.spare1, 0), 2048) = 2048) or    /* table compression */
          (bitand(nvl(ds.flags_stg, 0), 4) = 4) or /* DSC: table compression */
          (bitand(t.property, 1) = 1                         /* object table */
          ) or 
          (bitand(t.property,
                131072      /* 0x00020000 table is used as an AQ queue table */
              + 4194304     /* 0x00400000             global temporary table */
              + 8388608     /* 0x00800000   session-specific temporary table */
              + 134217728   /* 0x08000000                    Is a Sub object */
              + 2147483648  /* 0x80000000                     eXternal TaBle */
             ) != 0
          ) or 
          (bitand(t.property, 32768) = 32768      /* 0x8000 has FILE columns */
          ) or   
          (bitand(t.trigflag, 
                  65536     /* 0x00010000   server held key encrypted column */
                + 131072    /* 0x00020000     user held key encrypted column */
                + 268435456 /* 0x10000000                         strm unsup */
             ) != 0
          ) or 
          (exists /* TO DO: add some bit to tab$.property */ 
            (select 1 
             from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
            )                                       /* materialized view log */
          ) or
          bitand(o.flags, 16) = 16  or                       /* domain index */
          (exists
            (select 1 from sys.partobj$ p
             where p.obj# = o.obj# and
                   p.parttype = 3))                      /* system partition */
        )
/

/*
** THE CASE STATEMENTS IN THE SELECT CLAUSE SHOULD BE IDENTICAL
** TO THE OR CLAUSES IN THE WHERE CLAUSE.
**
** It's pretty clear that we can't use dba_% views, e.g., dba_tab_columns
** due to the complexity of our logic.
**
** This view lists unsupported tables in 10.2.
*/
create or replace view "_DBA_STREAMS_UNSUPPORTED_10_2"
  (owner, table_name, tproperty, ttrigflag, oflags, tflags, reason, compatible,
   auto_filtered)
as
  select
    distinct u.name, o.name,
             t.property, t.trigflag, o.flags, t.flags,
    (case
       when exists (select 1 from sys.partobj$ p
                   where p.obj# = o.obj# and
                         p.parttype = 3)                 /* system partition */
         then 'table with system partition'
       when exists (select 1                                      /* XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                         bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 2                /* XMLType schema is specified */
                          + 4                      /* XMLType stored as lob */ 
                          + 8                /* XMLType stores extra column */
                          + 32              /* XMLType table is out-of-line */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                          + 256)           /*  XMLType binary NO non-schema */
                    != 0)
         then 'table with XMLType column'
       when
        (exists
          (select 1 
           from   sys.mlog$ ml 
           where  ml.mowner = u.name and ml.log = o.name)
        )
        then 'materialized view log'
       when bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0
        then 'column with user-defined type'
      when ( bitand(nvl(s.spare1, 0), 2048) = 2048  or  /* table compression */
             bitand(nvl(ds.flags_stg, 0), 4) = 4   /* DSC: table compression */
           )
        then 'table compression'
      when (exists                                                    /* TDE */
            (select 1 from sys.col$ c
             where t.obj# = c.obj# and 
                   bitand(c.property, 67108864 + 536870912) != 0))
        then 'table with encrypted column'
      when bitand(t.trigflag, 65536 + 131072) != 0
        then 'Table with encrypted column'
      when (exists                                                    /* oid */
            (select 1 from sys.col$ c
             where t.obj# = c.obj# and bitand(c.property, 2) = 2))
        then 'table with OID column'
      when (exists
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ((c.segcol# = 0 and bitand(c.property, 131072) != 131072 and 
                                                          /* not desc index */
                                   bitand(c.property, 65536+32+8) != 65576) or
                                                    /* not functional index */
                (c.segcol# != 0 and 
                 bitand(c.property, 32) = 32 and                   /* hidden */
                 bitand(c.property, 32768) != 32768) or        /* not unused */
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 bitand(c.property, 2) = 2                     /* OID column */
               )
             )
          )
        then 'unsupported column exists'
      when bitand(t.property, 1) = 1
        then 'object table'
      when bitand(t.property, 131072) = 131072
        then 'AQ queue table'
      /* x00400000 + 0x00800000 */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'temporary table'
      when bitand(t.property, 134217728) = 134217728          /* 0x08000000 */
        then 'sub object'
      when bitand(t.property, 2147483648) = 2147483648        /* 0x80000000 */
        then 'external table'
      when bitand(t.property, 32768) = 32768     /* 0x8000 has FILE columns */
        then 'FILE column exists'
      when bitand(t.trigflag, 268435456) = 268435456
        then 'streams unsupported object'
      when bitand(o.flags, 16) = 16
        then 'domain index'
      else 'Streams unsupported object' end) reason, 
      102,                                                     /* compatible */
    (case
      when bitand(t.trigflag, 268435456) = 268435456  /* streams unsupported */
        then 'YES'
      /* x00400000 + 0x00800000  : Temp table */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'YES'
      when bitand(o.flags, 16) = 16                          /* domain index */
        then 'YES'
      else 'NO' end) auto_filtered     
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.deferred_stg$ ds
    where t.obj# = o.obj#
      and o.owner# = u.user#
      and t.file# = s.file# (+)
      and t.block# = s.block# (+)
      and t.ts# = s.ts# (+)
      and t.obj# = ds.obj# (+)
                   /* should be consistent with knlcfIsFilteredSpecialSchema */
      and u.name not in ('SYS', 'SYSTEM', 'CTXSYS', 'DBSNMP', 'LBACSYS',
                         'MDDATA', 'MDSYS', 'DMSYS', 'OLAPSYS', 'ORDPLUGINS',
                         'ORDSYS', 'SI_INFORMTN_SCHEMA', 'SYSMAN', 'OUTLN',
                         'EXFSYS', 'WMSYS', 'XDB', 'DVSYS', 'ORDDATA')
      and bitand(o.flags,
                  2                                      /* temporary object */
                + 4                               /* system generated object */
                + 32                                 /* in-memory temp table */
                + 128                          /* dropped table (RecycleBin) */
                  ) = 0
      and
      (   (bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0
          ) or
          (bitand(nvl(s.spare1, 0), 2048) = 2048) or    /* table compression */
          (bitand(nvl(ds.flags_stg, 0), 4) = 4) or /* DSC: table compression */
          (exists                                      /* unsupported column */
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ((c.segcol# = 0 and bitand(c.property, 131072) != 131072 and 
                                                           /* not desc index */
                                   bitand(c.property, 65536+32+8) != 65576) or
                                                     /* not functional index */
                (c.segcol# != 0 and 
                 bitand(c.property, 32) = 32 and            /* hidden column */
                 bitand(c.property, 32768) != 32768) or /* not unused column */
                 (bitand(c.property,          /* check for encrypted columns */
                           67108864         /* column encrypted without salt */
                         + 536870912           /* column encrypted with salt */
                       ) != 0
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (bitand(c.property, 2) = 2                    /* OID column */
                 )
               )
             )
          ) or
          (bitand(t.property, 1) = 1                         /* object table */
          ) or 
          (bitand(t.property,
                131072      /* 0x00020000 table is used as an AQ queue table */
              + 4194304     /* 0x00400000             global temporary table */
              + 8388608     /* 0x00800000   session-specific temporary table */
              + 134217728   /* 0x08000000                    Is a sub object */
              + 2147483648  /* 0x80000000                     external table */
             ) != 0
          ) or 
          (bitand(t.property, 32768) = 32768      /* 0x8000 has FILE columns */
          ) or   
          (bitand(t.trigflag, 
                  65536     /* 0x00010000   server held key encrypted column */
                + 131072    /* 0x00020000     user held key encrypted column */
                + 268435456 /* 0x10000000                         strm unsup */
             ) != 0
          ) or 
          (exists /* TO DO: add some bit to tab$.property */
            (select 1 
             from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
            )                                      /* materialized view log */
          ) or
          bitand(o.flags, 16) = 16 or                       /* domain index */
          exists (select 1                                       /* XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                         bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 2                /* XMLType schema is specified */
                          + 4                      /* XMLType stored as lob */ 
                          + 8                /* XMLType stores extra column */
                          + 32              /* XMLType table is out-of-line */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                          + 256)           /*  XMLType binary NO non-schema */
                    != 0) or
          (exists
            (select 1 from sys.partobj$ p
             where p.obj# = o.obj# and
                   p.parttype = 3))                     /* system partition */
        )
/

/*
** THE CASE STATEMENTS IN THE SELECT CLAUSE SHOULD BE IDENTICAL
** TO THE OR CLAUSES IN THE WHERE CLAUSE.
**
** It's pretty clear that we can't use dba_% views, e.g., dba_tab_columns
** due to the complexity of our logic.
**
** This view lists unsupported tables in 11.1.
*/ 
create or replace view "_DBA_STREAMS_UNSUPPORTED_11_1"
  (owner, table_name, tproperty, ttrigflag, oflags, tflags, reason, compatible,
   auto_filtered)
as
  select
    distinct u.name, o.name,
             t.property, t.trigflag, o.flags, t.flags,
    (case
      when
        (exists
          (select 1 
           from   sys.mlog$ ml 
           where  ml.mowner = u.name and ml.log = o.name)
        )
        then 'materialized view log'
       when bitand(t.property,
                  1                                           /* typed table */
                + 2                                            /* ADT column */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0 and
        (not exists (select 1                                 /* XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                         bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 2                /* XMLType schema is specified */
                          + 4                      /* XMLType stored as lob */ 
                          + 8                /* XMLType stores extra column */
                          + 32              /* XMLType table is out-of-line */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                           + 256) != 0 ))   /* XMLType binary NO non-schema */
        then 'column with user-defined type'
      when exists (select 1 from sys.partobj$ p
                   where p.obj# = o.obj# and
                         p.parttype = 3)                 /* system partition */
        then 'table with system partition'
      when ( bitand(nvl(s.spare1, 0), 2048) = 2048  or  /* table compression */
             bitand(nvl(ds.flags_stg, 0), 4) = 4   /* DSC: table compression */
           )
        then 'table compression'
      when (exists (select 1                    /* hierarchy enabled XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                        bitand(op.flags,512) != 0 ))
        then 'hierarchy enabled XMLType table'
      when (exists (select 1                                     /* XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                         bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 8                /* XMLType stores extra column */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                          + 256) != 0))     /* XMLType binary NO non-schema */
        then 'unsupported XMLType column'
      when (exists
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ((c.segcol# = 0 and bitand(c.property, 65536+8) != 65544 and
                                                      /* not virtual column */
                                   bitand(c.property, 131072) != 131072 and 
                                                          /* not desc index */
                                   bitand(c.property, 65536+32+8) != 65576) or
                                                    /* not functional index */
                (c.segcol# != 0 and 
                 bitand(c.property, 32) = 32 and                   /* hidden */
                 bitand(c.property, 32768) != 32768) or        /* not unused */
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     58,                                           /* opaque */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (bitand(c.property, 2) != 0                   /* OID column */
                 )
               )
             ) 
          )
        then 'unsupported column exists'
      when bitand(t.property, 131072) = 131072
        then 'AQ queue table'
      /* x00400000 + 0x00800000 */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'temporary table'
      when bitand(t.property, 134217728) = 134217728          /* 0x08000000 */
        then 'sub object'
      when bitand(t.property, 2147483648) = 2147483648        /* 0x80000000 */
        then 'external table'
      when bitand(t.property, 32768) = 32768     /* 0x8000 has FILE columns */
        then 'FILE column exists'
      when bitand(t.property, 8589934592) = 8589934592
        then 'flashback archived table'
      when bitand(t.trigflag, 268435456) = 268435456
        then 'streams unsupported object'
      when bitand(o.flags, 16) = 16
        then 'domain index'
      when
        (exists (select 1                                      /* securefile */
                from col$ c, lob$ l
                where c.type# IN (112, 113) and
                      c.obj#=l.obj# and
                      c.obj#=t.obj# and
                      c.col#=l.col# and
                      bitand(l.property, 2048) != 0)) or    /* 11g LOCAL lob */
        (exists (select 1                          /* partitioned securefile */
                from col$ c, lob$ l, lobfrag$ lf
                where c.type# IN (112, 113) and
                      c.obj#=l.obj# and
                      c.obj#=t.obj# and
                      c.col#=l.col# and 
                      l.lobj#=lf.parentobj# and
                      bitand(l.property, 4) != 0 and     /* partitioned LOB */
                      bitand(lf.fragpro, 2048) !=0)) or    /* 11g LOCAL lob */
        (exists (select 1               /* composite-partitioned securefile */
                 from col$ c, lob$ l, lobcomppart$ p,
                      lobfrag$ lf
                 where c.type# IN (112, 113) and
                       c.obj#=l.obj# and
                       c.obj#=t.obj# and
                       c.col#=l.col# and 
                       l.lobj#=p.lobj# and
                       p.partobj#=lf.parentobj# and
                       bitand(l.property, 4) != 0 and    /* partitioned LOB */
                       bitand(lf.fragpro, 2048) !=0))      /* 11g LOCAL lob */
        then 'securefile'
      else 'Streams unsupported object' end) reason, 
      111,                                                     /* compatible */
    (case
      when bitand(t.trigflag, 268435456) = 268435456  /* streams unsupported */
        then 'YES'
      /* x00400000 + 0x00800000  : Temp table */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'YES'
      when bitand(o.flags, 16) = 16                          /* domain index */
        then 'YES'
      else 'NO' end) auto_filtered     
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.deferred_stg$ ds
    where t.obj# = o.obj#
      and o.owner# = u.user#
      and t.file# = s.file# (+)
      and t.block# = s.block# (+)
      and t.ts# = s.ts# (+)
      and t.obj# = ds.obj# (+)
                   /* should be consistent with knlcfIsFilteredSpecialSchema */
      and u.name not in ('SYS', 'SYSTEM', 'CTXSYS', 'DBSNMP', 'LBACSYS',
                         'MDDATA', 'MDSYS', 'DMSYS', 'OLAPSYS', 'ORDPLUGINS',
                         'ORDSYS', 'SI_INFORMTN_SCHEMA', 'SYSMAN', 'OUTLN',
                         'EXFSYS', 'WMSYS', 'XDB', 'DVSYS', 'ORDDATA')
      and bitand(o.flags,
                  2                                      /* temporary object */
                + 4                               /* system generated object */
                + 32                                 /* in-memory temp table */
                + 128                          /* dropped table (RecycleBin) */
                  ) = 0
      and
      (   (bitand(t.property,
                  1                                           /* typed table */
                + 2                                            /* ADT column */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0 and
            (not exists (select 1                                 /* XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                         bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 2                /* XMLType schema is specified */
                          + 4                      /* XMLType stored as lob */ 
                          + 8                /* XMLType stores extra column */
                          + 32              /* XMLType table is out-of-line */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                          + 256) != 0 and   /* XMLType binary NO non-schema */
                        bitand(op.flags,512) = 0 ))/* not hierarchy enabled */
          ) or
          (bitand(nvl(s.spare1, 0), 2048) = 2048) or   /* table compression */
          (bitand(nvl(ds.flags_stg, 0), 4) = 4) or /* DSC:table compression */
          (exists                                       /* system partition */
                (select 1 from sys.partobj$ p
                 where p.obj# = o.obj# and
                       p.parttype = 3)) or           
          (exists                                     /* unsupported column */
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ((c.segcol# = 0 and bitand(c.property, 65536+8) != 65544 and 
                                                      /* not virtual column */
                                   bitand(c.property, 65536+32+8) != 65576 and
                                                    /* not functional index */
                                   bitand(c.property, 131072) != 131072) or
                                                    /* not descending index */
                (c.segcol# != 0 and
                 bitand(c.property, 32) = 32 and           /* hidden column */
                 bitand(c.property, 32768) != 32768) or /* not unused column */
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     58,                                           /* opaque */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (bitand(c.property, 2) = 2                    /* OID column */
                 )
               )
             )
          ) or
          (bitand(t.property,
                131072      /* 0x00020000 table is used as an AQ queue table */
              + 4194304     /* 0x00400000             global temporary table */
              + 8388608     /* 0x00800000   session-specific temporary table */
              + 134217728   /* 0x08000000                    Is a sub object */
              + 2147483648  /* 0x80000000                     external table */
              + 8589934592  /* 0x200000000                      FBA Internal */
             ) != 0
          ) or 
          (bitand(t.property, 32768) = 32768      /* 0x8000 has FILE columns */
          ) or   
          (bitand(t.trigflag, 268435456) != 0     /* 0x10000000   strm unsup */
          ) or 
          (exists /* TO DO: add some bit to tab$.property */
            (select 1 
             from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
            )
          ) or 
          bitand(o.flags, 16) = 16 or                       /* domain index */
          (exists (select 1                                   /* securefile */
                  from sys.col$ c, sys.lob$ l
                  where c.type# IN (112, 113) and
                        c.obj#=t.obj# and
                        c.obj#=l.obj# and
                        c.col#=l.col# and
                        bitand(l.property, 2048) != 0)) or /* 11g LOCAL lob */
          (exists (select 1                       /* partitioned securefile */
                from col$ c, lob$ l, sys.lobfrag$ lf
                where c.type# IN (112, 113) and
                      c.obj#=l.obj# and
                      c.obj#=t.obj# and
                      c.col#=l.col# and 
                      l.lobj#=lf.parentobj# and
                      bitand(l.property, 4) != 0 and     /* partitioned LOB */
                      bitand(lf.fragpro, 2048) !=0)) or    /* 11g LOCAL lob */
          (exists (select 1              /*composite-partitioned securefile */
                   from sys.col$ c, sys.lob$ l, sys.lobcomppart$ p,
                        sys.lobfrag$ lf
                   where c.type# IN (112, 113) and
                         c.obj#=l.obj# and
                         c.obj#=t.obj# and
                         c.col#=l.col# and 
                         l.lobj#=p.lobj# and
                         p.partobj#=lf.parentobj# and
                         bitand(l.property, 4) != 0 and  /* partitioned LOB */
                         bitand(lf.fragpro, 2048) !=0)))   /* 11g LOCAL lob */
     and
        ( (not exists (select 1                          /* not opaque type */
                         from sys.col$ c
                         where c.type#=58 and 
                               t.obj#=c.obj#)) or
          ( not exists 
              (select 1                           /* opaque but not XMLType */
               from sys.col$ c, sys.opqtype$ op
               where c.type#=58 and
                     t.obj# = c.obj# and
                     c.obj# = op.obj# and
                     c.intcol# = op.intcol# and
                         bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 2                /* XMLType schema is specified */
                          + 4                      /* XMLType stored as lob */ 
                          + 8                /* XMLType stores extra column */
                          + 32              /* XMLType table is out-of-line */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                          + 256) != 0 )) or 
           ( exists 
                 (select 1                            /* unsupported XMLType */
                  from sys.col$ c, sys.opqtype$ op
                  where c.type#=58 and
                        t.obj# = c.obj# and
                        c.obj# = op.obj# and
                        c.intcol# = op.intcol# and
                        (bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 8                /* XMLType stores extra column */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                          + 256) != 0 or    /* XMLType binary NO non-schema */
                         bitand(op.flags,512) != 0))) or/* hierarchy enabled */
          (exists                                       /* system partition */
                (select 1 from sys.partobj$ p
                 where p.obj# = o.obj# and
                       p.parttype = 3)))
/

/*
** THE CASE STATEMENTS IN THE SELECT CLAUSE SHOULD BE IDENTICAL
** TO THE OR CLAUSES IN THE WHERE CLAUSE.
**
** It's pretty clear that we can't use dba_% views, e.g., dba_tab_columns
** due to the complexity of our logic.
**
** This view lists unsupported tables in 11.2.
*/ 
create or replace view "_DBA_STREAMS_UNSUPPORTED_11_2"
  (owner, table_name, tproperty, ttrigflag, oflags, tflags, reason, compatible,
   auto_filtered)
as
  select distinct u.name, o.name,
             t.property, t.trigflag, o.flags, t.flags,
    (case
      when
        (exists
          (select 1 
           from   sys.mlog$ ml 
           where  ml.mowner = u.name and ml.log = o.name)
        )
        then 'materialized view log'
       when bitand(t.property,
                  1                                           /* typed table */
                + 2                                            /* ADT column */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0 and
        (not exists (select 1                                 /* XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                         bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 2                /* XMLType schema is specified */
                          + 4                      /* XMLType stored as lob */ 
                          + 8                /* XMLType stores extra column */
                          + 32              /* XMLType table is out-of-line */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                          + 256) != 0 ))    /* XMLType binary NO non-schema */
        then 'column with user-defined type'
      when ((exists (select 1
                    from lob$ l, col$ c
                    where c.type# IN (112, 113) and 
                          c.obj#=l.obj# and
                          c.obj#=t.obj# and
                          c.col#=l.col# and 
                          bitand(l.property, 2048) != 0 and/* 11g LOCAL lob */
                          bitand(l.flags, 
                                   65536  /* 0x10000 = Sharing: LOB level */
                                 + 131072 /* 0x20000 = Sharing: Object level */
                                 + 262144 /* 0x40000 = Sharing: Validate */
                       ) != 0)) or
            (exists (select 1
                    from lob$ l, lobfrag$ lf, col$ c
                    where c.type# IN (112, 113) and
                          c.obj#=l.obj# and
                          c.obj#=t.obj# and
                          c.col#=l.col# and 
                          l.lobj#=lf.parentobj# and
                          bitand(l.property, 4) != 0 and /* partitioned LOB */
                          bitand(lf.fragpro, 2048) != 0 and/* 11g LOCAL lob */
                          bitand(lf.fragflags, 
                                   65536     /* 0x10000 = Sharing: LOB level */
                                 + 131072 /* 0x20000 = Sharing: Object level */
                                 + 262144     /* 0x40000 = Sharing: Validate */
                              ) != 0)) or
           (exists (select 1
                    from lob$ l, lobcomppart$ p, lobfrag$ lf, col$ c
                    where c.type# IN (112, 113) and
                          c.obj#=l.obj# and
                          c.col#=l.col# and
                          c.obj#=t.obj# and
                          l.lobj#=p.lobj# and
                          p.partobj#=lf.parentobj# and
                          bitand(l.property, 4) != 0 and  /* partitioned LOB */
                          bitand(lf.fragpro, 2048) != 0 and /* 11g LOCAL lob */
                          bitand(lf.fragflags, 
                                   65536     /* 0x10000 = Sharing: LOB level */
                                 + 131072 /* 0x20000 = Sharing: Object level */
                                 + 262144     /* 0x40000 = Sharing: Validate */
                          ) != 0)))
        then 'table with securefile and deduplicaiton'
      when exists (select 1 from sys.partobj$ p
                   where p.obj# = o.obj# and
                         p.parttype = 3)                 /* system partition */
        then 'table with system partition'
      when (exists (select 1                   /* hierarchy enabled XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                        bitand(op.flags,512) != 0 ))
        then 'hierarchy enabled XMLType table'
      when (exists (select 1                                     /* XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                         bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 8                /* XMLType stores extra column */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                          + 256) != 0 and   /* XMLType binary NO non-schema */
                          bitand(op.flags,
                            68) != 68 ))              /* XMLType 68 allowed */
        then 'unsupported XMLType column'
      when (exists
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ((c.segcol# = 0 and bitand(c.property, 65536+8) != 65544 and
                                                      /* not virtual column */
                                   bitand(c.property, 131072) != 131072 and 
                                                          /* not desc index */
                                   bitand(c.property, 65536+32+8) != 65576) or
                                                    /* not functional index */
                (c.segcol# != 0 and 
                 bitand(c.property, 32) = 32 and                   /* hidden */
                 bitand(c.property, 32768) != 32768) or        /* not unused */
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     58,                                           /* opaque */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (bitand(c.property, 2) != 0                   /* OID column */
                 )
               )
             ) 
          )
        then 'unsupported column exists'
      when bitand(t.property, 131072) = 131072
        then 'AQ queue table'
      /* x00400000 + 0x00800000 */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'temporary table'
      when bitand(t.property, 134217728) = 134217728          /* 0x08000000 */
        then 'sub object'
      when bitand(t.property, 2147483648) = 2147483648        /* 0x80000000 */
        then 'external table'
      when bitand(t.property, 32768) = 32768     /* 0x8000 has FILE columns */
        then 'FILE column exists'
      when bitand(t.property, 8589934592) = 8589934592
        then 'flashback archived table'
      when bitand(t.trigflag, 268435456) = 268435456
        then 'streams unsupported object'
      when bitand(o.flags, 16) = 16
        then 'domain index'
      else 'Streams unsupported object' end) reason, 
      112,                                                     /* compatible */
    (case
      when bitand(t.trigflag, 268435456) = 268435456  /* streams unsupported */
        then 'YES'
      /* x00400000 + 0x00800000  : Temp table */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'YES'
      when bitand(o.flags, 16) = 16                          /* domain index */
        then 'YES'
      else 'NO' end) auto_filtered     
  from sys.obj$ o, sys.user$ u, sys.tab$ t
    where t.obj# = o.obj#
      and o.owner# = u.user#
                   /* should be consistent with knlcfIsFilteredSpecialSchema */
      and u.name not in ('SYS', 'SYSTEM', 'CTXSYS', 'DBSNMP', 'LBACSYS',
                         'MDDATA', 'MDSYS', 'DMSYS', 'OLAPSYS', 'ORDPLUGINS',
                         'ORDSYS', 'SI_INFORMTN_SCHEMA', 'SYSMAN', 'OUTLN',
                         'EXFSYS', 'WMSYS', 'XDB', 'DVSYS', 'ORDDATA')
      and bitand(o.flags,
                  2                                      /* temporary object */
                + 4                               /* system generated object */
                + 32                                 /* in-memory temp table */
                + 128                          /* dropped table (RecycleBin) */
                  ) = 0
      and
      (   
         (bitand(t.property,
                  1                                           /* typed table */
                + 2                                            /* ADT column */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0 and
            (not exists (select 1                                 /* XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                         bitand(op.flags,
                            1                   /* XMLType stored as object */
                          + 2                /* XMLType schema is specified */
                          + 8                /* XMLType stores extra column */
                          + 32              /* XMLType table is out-of-line */
                          + 64                  /* XMLType stored as binary */
                          + 128                 /* XMLType binary ANYSCHEMA */
                          + 256) != 0 and   /* XMLType binary NO non-schema */
                        bitand(op.flags,512) = 0   /* not hierarchy enabled */
                                                 and
                         bitand(op.flags,
                            68) != 68 ))               /* XMLType 68 allowed */
          ) or
          (exists                                       /* system partition */
               (select 1 from sys.partobj$ p
                where p.obj# = o.obj# and
                      p.parttype = 3)) or 
          (exists                                     /* unsupported column */
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ((c.segcol# = 0 and bitand(c.property, 65536+8) != 65544 and 
                                                      /* not virtual column */
                                   bitand(c.property, 65536+32+8) != 65576 and
                                                    /* not functional index */
                                   bitand(c.property, 131072) != 131072) or
                                                    /* not descending index */
                (c.segcol# != 0 and
                 bitand(c.property, 32) = 32 and           /* hidden column */
                 bitand(c.property, 32768) != 32768) or /* not unused column */
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     58,                                           /* opaque */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (bitand(c.property, 2) = 2                    /* OID column */
                 )
               )
             )
          ) or
          (bitand(t.property,
                131072      /* 0x00020000 table is used as an AQ queue table */
              + 4194304     /* 0x00400000             global temporary table */
              + 8388608     /* 0x00800000   session-specific temporary table */
              + 134217728   /* 0x08000000                    Is a sub object */
              + 2147483648  /* 0x80000000                     external table */
              + 8589934592  /* 0x200000000                      FBA Internal */
             ) != 0
          ) or 
          (bitand(t.property, 32768) = 32768      /* 0x8000 has FILE columns */
          ) or   
          (bitand(t.trigflag, 268435456) != 0     /* 0x10000000   strm unsup */
          ) or 
          (exists /* TO DO: add some bit to tab$.property */
            (select 1 
             from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
            )
          ) or 
          (bitand(o.flags, 16) = 16) or                      /* domain index */
          exists (select 1
                    from lob$ l, col$ c
                    where c.type# IN (112, 113) and 
                          c.obj#=l.obj# and
                          c.col#=l.col# and 
                          c.obj#=t.obj# and 
                          bitand(l.property, 2048) != 0 and /* 11g LOCAL lob */
                          bitand(l.flags, 
                                   65536  /* 0x10000 = Sharing: LOB level */
                                 + 131072 /* 0x20000 = Sharing: Object level */
                                 + 262144 /* 0x40000 = Sharing: Validate */
                       ) != 0) or
            exists (select 1
                    from lob$ l, sys.lobfrag$ lf, col$ c
                    where c.type# IN (112, 113) and
                          c.obj#=l.obj# and
                          c.col#=l.col# and
                          c.obj#=t.obj# and
                          l.lobj#=lf.parentobj# and
                          bitand(l.property, 4) != 0 and /* partitioned LOB */
                          bitand(lf.fragpro, 2048) != 0 and/* 11g LOCAL lob */
                          bitand(lf.fragflags, 
                                   65536  /* 0x10000 = Sharing: LOB level */
                                 + 131072 /* 0x20000 = Sharing: Object level */
                                 + 262144 /* 0x40000 = Sharing: Validate */
                              ) != 0) or
            exists (select 1
                    from lob$ l, lobcomppart$ p, lobfrag$ lf, col$ c
                    where c.type# IN (112, 113) and
                          c.obj#=l.obj# and
                          c.col#=l.col# and 
                          c.obj#=t.obj# and
                          l.lobj#=p.lobj# and
                          p.partobj#=lf.parentobj# and
                          bitand(l.property, 4) != 0 and /* partitioned LOB */
                          bitand(lf.fragpro, 2048) != 0 and/* 11g LOCAL lob */
                          bitand(lf.fragflags, 
                                   65536  /* 0x10000 = Sharing: LOB level */
                                 + 131072 /* 0x20000 = Sharing: Object level */
                                 + 262144 /* 0x40000 = Sharing: Validate */
                          ) != 0))
    and       
      (        (not exists (select 1                      /* not opaque type */
                         from sys.col$ c
                         where c.type#=58 and 
                               t.obj#=c.obj#)) or
               ( not exists (select 1              /* opaque but not XMLType */
                   from sys.col$ c, sys.opqtype$ op
                   where c.type#=58 and
                         t.obj# = c.obj# and
                         c.obj# = op.obj# and
                         c.intcol# = op.intcol# and
                         bitand(op.flags,
                            1                    /* XMLType stored as object */
                          + 2                 /* XMLType schema is specified */
                          + 4                       /* XMLType stored as lob */
                          + 8                 /* XMLType stores extra column */
                          + 32               /* XMLType table is out-of-line */
                          + 64                   /* XMLType stored as binary */
                          + 128                  /* XMLType binary ANYSCHEMA */
                          + 256) != 0 )) or 
               ( exists 
                 (select 1                            /* unsupported XMLType */
                  from sys.col$ c, sys.opqtype$ op
                  where c.type#=58 and
                        t.obj# = c.obj# and
                        c.obj# = op.obj# and
                        c.intcol# = op.intcol# and
                        (bitand(op.flags,
                            1                    /* XMLType stored as object */
                          + 8                 /* XMLType stores extra column */
                          + 64                   /* XMLType stored as binary */
                          + 128                  /* XMLType binary ANYSCHEMA */
                          + 256) != 0 or     /* XMLType binary NO non-schema */
                         bitand(op.flags,512) != 0) and /* hierarchy enabled */
                         bitand(op.flags,
                            68) != 68 )) or            /* XMLType 68 allowed */
               (exists                                   /* system partition */
                (select 1 from sys.partobj$ p
                 where p.obj# = o.obj# and
                       p.parttype = 3)))
/

/*
** If we define "_DBA_STREAMS_UNSUPPORTED_%" for a new release,
** we need to add "_DBA_STREAMS_UNSUPPORTED_%" to the union.
** Also, a new return value for get_str_compat() will have to be added.
*/
create or replace view DBA_STREAMS_UNSUPPORTED
as select owner, table_name table_name, reason, auto_filtered
   from (select * from "_DBA_STREAMS_UNSUPPORTED_9_2" 
         where compatible = dbms_logrep_util.get_str_compat() union
         select * from "_DBA_STREAMS_UNSUPPORTED_10_1" 
         where compatible = dbms_logrep_util.get_str_compat() union
         select * from "_DBA_STREAMS_UNSUPPORTED_10_2" 
         where compatible = dbms_logrep_util.get_str_compat() union
         select * from "_DBA_STREAMS_UNSUPPORTED_11_1" 
         where compatible = dbms_logrep_util.get_str_compat() union
         select * from "_DBA_STREAMS_UNSUPPORTED_11_2" 
         where compatible = dbms_logrep_util.get_str_compat());

comment on table DBA_STREAMS_UNSUPPORTED is
'List of all the tables that are not supported by Streams in this release'
/

comment on column DBA_STREAMS_UNSUPPORTED.OWNER is
'Owner of the table'
/
comment on column DBA_STREAMS_UNSUPPORTED.TABLE_NAME is
'Name of the table'
/
comment on column DBA_STREAMS_UNSUPPORTED.REASON is
'Reason why the table is not supported'
/
comment on column DBA_STREAMS_UNSUPPORTED.AUTO_FILTERED is
'Does Streams automatically filter out this object'
/

create or replace public synonym DBA_STREAMS_UNSUPPORTED
  for DBA_STREAMS_UNSUPPORTED
/
grant select on DBA_STREAMS_UNSUPPORTED to select_catalog_role
/

/* we can't use all_tables because object tables aren't listed in it */
create or replace view ALL_STREAMS_UNSUPPORTED
as select s.* from DBA_STREAMS_UNSUPPORTED s, ALL_OBJECTS a
   where s.owner = a.owner
     and s.table_name = a.object_name
     and a.object_type = 'TABLE';

comment on table ALL_STREAMS_UNSUPPORTED is
'List of all the tables that are not supported by Streams in this release'
/

comment on column ALL_STREAMS_UNSUPPORTED.OWNER is
'Owner of the object'
/
comment on column ALL_STREAMS_UNSUPPORTED.TABLE_NAME is
'Name of the object'
/
comment on column ALL_STREAMS_UNSUPPORTED.REASON is
'Reason why the object is not supported'
/
comment on column ALL_STREAMS_UNSUPPORTED.AUTO_FILTERED is
'Does Streams automatically filter out this object'
/

create or replace public synonym ALL_STREAMS_UNSUPPORTED
  for ALL_STREAMS_UNSUPPORTED
/

grant select on ALL_STREAMS_UNSUPPORTED to PUBLIC with grant option
/

/*
** This view lists newly supported tables in 10.1, which are
** not supported in 9.2.
** We will need a similar view in a future release to list
** newly supported tables in that release, comparing with an
** immediate preceding release.
** We can union these "_DBA_STREAMS_NEWLY_SUPTED_%" views
** to construct DBA_STREAMS_NEWLY_SUPPORTED view.
*/
create or replace view "_DBA_STREAMS_NEWLY_SUPTED_10_1"
  (owner, table_name, reason, compatible, str_compat)
as
  select owner, table_name, reason, '10.1', 100
    from "_DBA_STREAMS_UNSUPPORTED_9_2" o
    where not exists
      (select 1 from "_DBA_STREAMS_UNSUPPORTED_10_1" i
         where i.owner = o.owner
           and i.table_name = o.table_name);
/

/*
** This view lists newly supported tables in 10.2
** We will need a similar view in a future release to list
** newly supported tables in that release, comparing with an
** immediate preceding release.
** We can union these "_DBA_STREAMS_NEWLY_SUPTED_%" views
** to construct DBA_STREAMS_NEWLY_SUPPORTED view.
*/
create or replace view "_DBA_STREAMS_NEWLY_SUPTED_10_2"
  (owner, table_name, reason, compatible, str_compat)
as
  select owner, table_name, reason, '10.2', 102
    from "_DBA_STREAMS_UNSUPPORTED_10_1" o
    where not exists
      (select 1 from "_DBA_STREAMS_UNSUPPORTED_10_2" i
         where i.owner = o.owner
           and i.table_name = o.table_name);
/

/*
** This view lists newly supported tables in 11.1
** We will need a similar view in a future release to list
** newly supported tables in that release, comparing with an
** immediate preceding release.
** We can union these "_DBA_STREAMS_NEWLY_SUPTED_%" views
** to construct DBA_STREAMS_NEWLY_SUPPORTED view.
*/ 
create or replace view "_DBA_STREAMS_NEWLY_SUPTED_11_1"
  (owner, table_name, reason, compatible, str_compat)
as
  select owner, table_name, reason, '11.1', 111
    from "_DBA_STREAMS_UNSUPPORTED_10_2" o
    where not exists
      (select 1 from "_DBA_STREAMS_UNSUPPORTED_11_1" i
         where i.owner = o.owner
           and i.table_name = o.table_name);
/

/*
** This view lists newly supported tables in 11.2
** We will need a similar view in a future release to list
** newly supported tables in that release, comparing with an
** immediate preceding release.
** We can union these "_DBA_STREAMS_NEWLY_SUPTED_%" views
** to construct DBA_STREAMS_NEWLY_SUPPORTED view.
*/ 
create or replace view "_DBA_STREAMS_NEWLY_SUPTED_11_2"
  (owner, table_name, reason, compatible, str_compat)
as
  select owner, table_name, reason, '11.2', 112
    from "_DBA_STREAMS_UNSUPPORTED_11_1" o
    where not exists
      (select 1 from "_DBA_STREAMS_UNSUPPORTED_11_2" i
         where i.owner = o.owner
           and i.table_name = o.table_name);
/

create or replace view DBA_STREAMS_NEWLY_SUPPORTED
  (owner, table_name, reason, compatible)
as
  select owner, table_name, reason, compatible
    from (select * from "_DBA_STREAMS_NEWLY_SUPTED_10_1" 
          where str_compat <= dbms_logrep_util.get_str_compat() union
          select * from "_DBA_STREAMS_NEWLY_SUPTED_10_2" 
          where str_compat <= dbms_logrep_util.get_str_compat() union
          select * from "_DBA_STREAMS_NEWLY_SUPTED_11_1" 
          where str_compat <= dbms_logrep_util.get_str_compat() union
          select * from "_DBA_STREAMS_NEWLY_SUPTED_11_2" 
          where str_compat <= dbms_logrep_util.get_str_compat());

comment on table DBA_STREAMS_NEWLY_SUPPORTED is
'List of tables that are newly supported by Streams capture'
/
comment on column DBA_STREAMS_NEWLY_SUPPORTED.OWNER is
'Owner of the table'
/
comment on column DBA_STREAMS_NEWLY_SUPPORTED.TABLE_NAME is
'Name of the table'
/
comment on column DBA_STREAMS_NEWLY_SUPPORTED.REASON is
'Reason why the table was not supported in some previous release'
/
comment on column DBA_STREAMS_NEWLY_SUPPORTED.COMPATIBLE is
'The latest compatible setting when this table was unsupported'
/

create or replace public synonym DBA_STREAMS_NEWLY_SUPPORTED
  for DBA_STREAMS_NEWLY_SUPPORTED
/
grant select on DBA_STREAMS_NEWLY_SUPPORTED to select_catalog_role
/

/* we can't use all_tables because object tables aren't listed in it */
create or replace view all_streams_newly_supported
as
  select s.* from dba_streams_newly_supported s, all_objects a
    where s.owner = a.owner
      and s.table_name = a.object_name
      and a.object_type = 'TABLE';

comment on table ALL_STREAMS_NEWLY_SUPPORTED is
'List of objects that are newly supported by Streams'
/
comment on column ALL_STREAMS_NEWLY_SUPPORTED.OWNER is
'Owner of the object'
/
comment on column ALL_STREAMS_NEWLY_SUPPORTED.TABLE_NAME is
'Name of the object'
/
comment on column ALL_STREAMS_NEWLY_SUPPORTED.REASON is
'Reason why the object was not supported in some previous release'
/
comment on column ALL_STREAMS_NEWLY_SUPPORTED.COMPATIBLE is
'The least compatible setting when this object is supported'
/

create or replace public synonym ALL_STREAMS_NEWLY_SUPPORTED
  for ALL_STREAMS_NEWLY_SUPPORTED
/

grant select on ALL_STREAMS_NEWLY_SUPPORTED to PUBLIC with grant option
/

----------------------------------------------------------------------------

create or replace view "_DBA_XSTREAM_OUT_ALL_TABLES"
 (owner, table_name, object_number)
as
  select u.name, o.name, o.obj# from sys.user$ u, sys.obj$ o, sys.tab$ t
where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.type# = 2              /*          2                      table */
  and bitand(o.flags, 128) = 0 /*       0x80 dropped table (RecycleBin) */
  and bitand(t.property,
              + 8192           /* 0x00002000               nested table */
              + 2147483648     /* 0x80000000             external table */
             ) = 0;

comment on table "_DBA_XSTREAM_OUT_ALL_TABLES" is
'Description of relational tables accessible to the user'
/
comment on column "_DBA_XSTREAM_OUT_ALL_TABLES".OWNER is
'Owner of the object'
/
comment on column "_DBA_XSTREAM_OUT_ALL_TABLES".TABLE_NAME is
'Name of the object'
/
comment on column "_DBA_XSTREAM_OUT_ALL_TABLES".OBJECT_NUMBER is
'Object number'
/

create or replace view "_DBA_XSTREAM_OUT_ADT_PK_TABLES"
  (owner, table_name, object_number)
as
  select u.name, o.name, o.obj# from sys.user$ u, sys.obj$ o, sys.col$ c
where o.owner# = u.user#
  and c.obj# = o.obj#
  and c.type# = 121
  and o.type# = 2
  and exists
  (select 1 from sys.ccol$ ccol, sys.col$ c2, sys.cdef$ cd
                              where c.obj# = c2.obj#
                                and c.obj# = cd.obj#
                                and c.obj# = ccol.obj#
                                and c.col# = c2.col#
                                and ccol.con# = cd.con#
                                and ccol.intcol# = c2.intcol#
                                and bitand(c2.property, 32) = 32 
                                and cd.type# = 2);

comment on table "_DBA_XSTREAM_OUT_ADT_PK_TABLES" is
'Tables with ADT attributes in the primary key'
/
comment on column "_DBA_XSTREAM_OUT_ADT_PK_TABLES".OWNER is
'Owner of the object'
/
comment on column "_DBA_XSTREAM_OUT_ADT_PK_TABLES".TABLE_NAME is
'Name of the object'
/
comment on column "_DBA_XSTREAM_OUT_ADT_PK_TABLES".OBJECT_NUMBER is
'Object number'
/

----------------------------------------------------------------------------

create or replace view DBA_XSTREAM_OUT_SUPPORT_MODE
  (owner, object_name, support_mode)
as
  select owner, table_name, 'FULL' from "_DBA_XSTREAM_OUT_ALL_TABLES" where owner not in 
    ('SYS', 'SYSTEM', 'CTXSYS', 'DBSNMP', 'LBACSYS', 'MDDATA', 'MDSYS', 
     'DMSYS', 'OLAPSYS', 'ORDPLUGINS', 'ORDSYS', 'SI_INFORMTN_SCHEMA', 
     'SYSMAN', 'OUTLN', 'EXFSYS', 'WMSYS', 'XDB', 'DVSYS', 'ORDDATA') 
  MINUS (select owner, table_name, 'FULL' from dba_logstdby_unsupported_table)
  UNION ALL
  /* Queue tables are unsupported, so exclude from 'ID KEY' query */
  select owner, table_name, 'ID KEY' from dba_logstdby_unsupported_table 
    where table_name not like 'AQ$_%' and (owner, table_name) not in 
      (select owner, queue_table from dba_queue_tables) and (owner, table_name) not in 
      (select owner, table_name from "_DBA_XSTREAM_OUT_ADT_PK_TABLES") union all
  /* Tables with ADT attributes on PK should show up as 'NONE' */
  select owner, table_name, 'NONE' from "_DBA_XSTREAM_OUT_ADT_PK_TABLES" union all
  /* For now, only queue tables have support mode 'NONE' */
  select owner, table_name, 'NONE' from dba_logstdby_unsupported_table
    where table_name like 'AQ$_%' or (owner, table_name) in
      (select owner, queue_table from dba_queue_tables);

comment on table DBA_XSTREAM_OUT_SUPPORT_MODE is
'List of support mode for objects by XStream Out'
/
comment on column DBA_XSTREAM_OUT_SUPPORT_MODE.OWNER is
'Owner of the object'
/
comment on column DBA_XSTREAM_OUT_SUPPORT_MODE.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_XSTREAM_OUT_SUPPORT_MODE.SUPPORT_MODE is
'Either FULL, ID KEY, or NONE'
/

create or replace public synonym DBA_XSTREAM_OUT_SUPPORT_MODE
  for DBA_XSTREAM_OUT_SUPPORT_MODE
/
grant select on DBA_XSTREAM_OUT_SUPPORT_MODE to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_XSTREAM_OUT_SUPPORT_MODE as
  select xosm.*
  from DBA_XSTREAM_OUT_SUPPORT_MODE xosm, ALL_APPLY aa
  where aa.apply_user = xosm.owner
/

comment on table ALL_XSTREAM_OUT_SUPPORT_MODE is
'List of support mode for objects by XStream Out'
/
comment on column ALL_XSTREAM_OUT_SUPPORT_MODE.OWNER is
'Owner of the object'
/
comment on column ALL_XSTREAM_OUT_SUPPORT_MODE.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_XSTREAM_OUT_SUPPORT_MODE.SUPPORT_MODE is
'Either FULL, ID KEY, or NONE'
/

create or replace public synonym ALL_XSTREAM_OUT_SUPPORT_MODE
  for ALL_XSTREAM_OUT_SUPPORT_MODE
/
grant select on ALL_XSTREAM_OUT_SUPPORT_MODE to select_catalog_role
/

-------------------------------------------------------------------------------
create or replace view DBA_GOLDENGATE_SUPPORT_MODE
  (owner, object_name, support_mode)
as
  select * from DBA_XSTREAM_OUT_SUPPORT_MODE
/

comment on table DBA_GOLDENGATE_SUPPORT_MODE is
'List of support mode for objects by GoldenGate'
/
comment on column DBA_GOLDENGATE_SUPPORT_MODE.OWNER is
'Owner of the object'
/
comment on column DBA_GOLDENGATE_SUPPORT_MODE.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_GOLDENGATE_SUPPORT_MODE.SUPPORT_MODE is
'Either FULL, ID KEY, or NONE'
/

create or replace public synonym DBA_GOLDENGATE_SUPPORT_MODE
  for DBA_GOLDENGATE_SUPPORT_MODE
/
grant select on DBA_GOLDENGATE_SUPPORT_MODE to select_catalog_role
/

