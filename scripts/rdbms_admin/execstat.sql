Rem
Rem $Header: execstat.sql5616 06-jan-2007.20:55:25 rburns Exp $
Rem
Rem execstat.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      execstat.sql - EXECute STATs packages
Rem
Rem    DESCRIPTION
Rem      Executes the stats initialization procedure
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      01/06/07 - initialize stats
Rem    rburns      01/06/07 - Created
Rem

begin
  dbms_stats.init_package;
end;
/

