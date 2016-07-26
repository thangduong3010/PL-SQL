Rem
Rem $Header: initqsma.sql 17-aug-2001.07:57:22 gssmith Exp $
Rem
Rem initqsma.sql
Rem
Rem Copyright (c) 2000, 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      initqsma.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Loads the Java stored procedures as required by the
Rem      Summary Advisor.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gssmith     08/17/01 - Script bug
Rem    gssmith     09/05/00 - Optimization
Rem    gssmith     04/12/00 - Loads java components for Summary Advisor
Rem    gssmith     04/12/00 - Created
Rem

call sys.dbms_java.loadjava('-v -s -g public -f -r rdbms/jlib/qsma.jar');



