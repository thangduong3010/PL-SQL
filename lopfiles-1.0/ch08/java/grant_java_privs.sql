REM $Id: grant_java_privs.sql,v 1.1 2001/11/30 23:25:42 bill Exp $
REM From "Learning Oracle PL/SQL" page 298

REM Attempt to grant the necessary permissions to one user to execute Java
REM network "socket connects and resolves" from inside Oracle

REM Replace the "*" in permission_name with a specific hostname:port to
REM limit access to a specific destination

BEGIN
   DBMS_JAVA.GRANT_PERMISSION(
      grantee => UPPER('&&username'),
      permission_type => 'SYS:java.net.SocketPermission',
      permission_name => '*',
      permission_action => 'connect,resolve' );
END;
/

