Rem
Rem $Header: utledtol.sql 26-feb-2002.07:58:50 sbodagal Exp $
Rem
Rem utledtol.sql
Rem
Rem Copyright (c) 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      utledtol.sql - Outline editing utility file
Rem
Rem    DESCRIPTION
Rem      This file creates the outline tables OL$, OL$HINTS and OL$NODES
Rem      and the associated indices in the user schema. The created tables
Rem      will be used to store private outlines generated during an outline
Rem      editing session. Users are expected to create the outline tables
Rem      in their schemas before starting an outline editing session.
Rem
Rem    NOTES
Rem      Global temporary tables have been chosen for OL$, OL$HINTS and
Rem      OL$NODES in order to provide the appropriate level of isolation
Rem      between different editing sessions.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sbodagal    02/26/02 - sbodagal_bug-2229346
Rem    sbodagal    02/25/02 - #2095076 and #2229346 
Rem                         - rename utleditol.sql to utledtol.sql
Rem    svivian     08/15/00 - add new hash_value2 column
Rem    svivian     06/16/00 - add spare fields
Rem    sbodagal    06/05/00 - Created
Rem

create global temporary table ol$
(
  ol_name           varchar2(30),          /* name is potentially generated */
  sql_text          long,                    /* the SQL stmt being outlined */
  textlen           number,                           /* length of SQL stmt */
  signature         raw(16),                       /* signature of sql_text */
  hash_value        number,                  /* KGL's calculated hash value */
  hash_value2       number,                 /* hash value for stripped text */
  category          varchar2(30),                          /* category name */
  version           varchar2(64),          /* db version @ outline creation */
  creator           varchar2(30),         /* user from whom outline created */
  timestamp         date,                               /* time of creation */
  flags             number,              /* e.g. everUsed, bindVars, dynSql */
  hintcount         number                /* number of hints on the outline */
)
on commit preserve rows;

create global temporary table ol$hints
(
  ol_name           varchar2(30),                           /* outline name */
  hint#             number,               /* which hint for a given outline */
  category          varchar2(30),               /* collection/grouping name */
  hint_type         number,                                 /* type of hint */
  hint_text         varchar2(512),             /* hint specific information */
  stage#            number,            /* stage of hint generation/applic'n */
  node#             number,                                  /* QBC node id */
  table_name        varchar2(30),                       /* for ORDERED hint */
  table_tin         number,                        /* table instance number */
  table_pos         number,                             /* for ORDERED hint */
  ref_id            number,        /* node id that this hint is referencing */
  user_table_name   varchar2(64),  /* table name to which this hint applies */
  cost              double precision,    /* optimizer estimated cost of the */
                                                       /*  hinted operation */
  cardinality       double precision,    /* optimizer estimated cardinality */
                                                 /* of the hinted operation */
  bytes             double precision,     /* optimizer estimated byte count */
                                                 /* of the hinted operation */
  hint_textoff      number,             /* offset into the SQL statement to */
                                                 /* which this hint applies */
  hint_textlen      number,     /* length of SQL to which this hint applies */
  join_pred         varchar2(2000),     /* join predicate (applies only for */
                                                      /* join method hints) */
  spare1            number,         /* spare number for future enhancements */
  spare2            number          /* spare number for future enhancements */
)
on commit preserve rows;

create global temporary table ol$nodes
(
  ol_name       varchar2(30),                               /* outline name */
  category      varchar2(30),                           /* outline category */
  node_id       number,                              /* qbc node identifier */
  parent_id     number,      /* node id of the parent node for current node */
  node_type     number,                                    /* qbc node type */
  node_textlen  number,         /* length of SQL to which this node applies */
  node_textoff  number       /* offset into the SQL statement to which this */
                                                            /* node applies */
)
on commit preserve rows;

create unique index ol$name on ol$(ol_name);

create unique index ol$signature on ol$(signature,category);

create unique index ol$hnt_num on ol$hints(ol_name, hint#);
