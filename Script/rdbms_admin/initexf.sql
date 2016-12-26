Rem
Rem $Header: initexf.sql 08-feb-2007.14:06:07 ayalaman Exp $
Rem
Rem initexf.sql
Rem
Rem Copyright (c) 2002, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      initexf.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    02/08/07 - bug 5709977
Rem    ayalaman    09/26/02 - ayalaman_expression_filter_support
Rem    ayalaman    09/06/02 - 
Rem    ayalaman    09/06/02 - Created
Rem


call sys.dbms_java.loadjava(' -v -f -r -schema exfsys rdbms/jlib/ExprFilter.jar');

grant execute on "oracle/expfil/ExpfilIndex" to public;

