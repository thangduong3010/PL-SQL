Rem
Rem $Header: utldim.sql 27-dec-2002.11:21:32 mxiao Exp $
Rem
Rem utldim.sql
Rem
Rem Copyright (c) 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      utldim.sql - UTiLity for dbms_dimension
Rem
Rem    DESCRIPTION
Rem      1. It creates a table DIMENSION_EXCEPTIONS IN the schema
Rem         of the current user.  The table is used
Rem         by DBMS_DIMENSION.VALIDATE_DIMENSION() to store
Rem         the results.  
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mxiao       12/27/02 - mxiao_dbms_dimension
Rem    mxiao       12/19/02 - Created
Rem

CREATE TABLE dimension_exceptions
  (statement_id    VARCHAR2(30),            -- Client-supplied unique statement identifier
   owner           VARCHAR2(30) NOT NULL,   -- Owner of the dimension 
   table_name      VARCHAR2(30) NOT NULL,   -- Name of the base table
   dimension_name  VARCHAR2(30) NOT NULL,   -- Name of the dimension
   relationship    VARCHAR2(11) NOT NULL,   -- Name of the relationship that cause the dimension
                                            --   invalid, e.g. ATTRIBUTE, FOREIGN KEY, CHILD OF, etc
   bad_rowid       ROWID        NOT NULL)   -- Rowid of the 'bad' row.
/
