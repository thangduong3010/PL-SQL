Rem
Rem $Header: utlchn1.sql 24-jun-99.07:57:57 echong Exp $
Rem
Rem utlchn1.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem      utlchn1.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    echong      06/24/99 - rename
Rem    syeung      06/22/98 - add subpartition_name                            
Rem    echong      06/05/98 - chained rows table with urowid type
Rem    echong      06/05/98 - Created
Rem

create table CHAINED_ROWS (
  owner_name         varchar2(30),
  table_name         varchar2(30),
  cluster_name       varchar2(30),
  partition_name     varchar2(30),
  subpartition_name  varchar2(30),
  head_rowid         urowid,
  analyze_timestamp  date
);


