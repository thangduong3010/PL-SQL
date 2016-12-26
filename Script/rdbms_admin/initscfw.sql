Rem
Rem $Header: rdbms/admin/initscfw.sql /main/2 2009/02/25 12:59:46 rgmani Exp $
Rem
Rem initscfw.sql
Rem
Rem Copyright (c) 2008, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      initscfw.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rgmani      02/23/09 - Fix trace issue
Rem    rgmani      04/02/08 - Scheduler file watch java code
Rem    rgmani      04/02/08 - Created
Rem

begin
  dbms_java.loadjava('-v -r -s rdbms/jlib/schagent.jar');
end;
/

CREATE OR REPLACE
  AND COMPILE JAVA SOURCE NAMED "dbFWTrace"
AS

import oracle.scheduler.agent.fileWatchTrace;
import oracle.jdbc.*;
import oracle.jdbc.pool.OracleDataSource;
import java.sql.Connection;

public class dbFWTrace implements fileWatchTrace
{
  public void writeTrace(String do_trc, String trc_string)
  {
    if (do_trc.equals("Y"))
    {
      try
      {
        OracleDataSource ods = new OracleDataSource();
        ods.setURL("jdbc:default:connection");
        Connection conn = ods.getConnection();
        OracleCallableStatement ocs = (OracleCallableStatement)conn.prepareCall(
            "{call dbms_isched.write_file_watch_trace(?, ?)}");
        ocs.setString(1, do_trc);
        ocs.setString(2, trc_string);
        ocs.executeUpdate();
        ocs.close();
      }
      catch (java.sql.SQLException sqlexception)
      {
        // ignore for now
      }
    }
  }
}
/

CREATE OR REPLACE 
  AND COMPILE JAVA SOURCE NAMED "schedFileWatcherJava"
AS
import java.util.ArrayList;
import oracle.scheduler.agent.fileWatchRequest;
import oracle.scheduler.agent.fileWatchHistory;
import oracle.scheduler.agent.fileWatchResult;
import oracle.scheduler.agent.fileWatch;
import oracle.scheduler.agent.fileWatchTrace;
import oracle.scheduler.agent.fwRequestWrapper;
import oracle.scheduler.agent.fwReqListWrapper;
import oracle.scheduler.agent.fwResultWrapper;
import oracle.scheduler.agent.fwResListWrapper;
import oracle.scheduler.agent.fwHistoryWrapper;
import oracle.scheduler.agent.fwHstListWrapper;

public class schedFileWatcherJava
{
  public static fwResListWrapper 
     fwWrapper(fwReqListWrapper reqarr, fwHstListWrapper[] histarr,
               String ohome, String hostname, String do_trc) 
       throws java.sql.SQLException, java.lang.InterruptedException
  {
    ArrayList<fileWatchRequest> fwreq_list;
    ArrayList<fileWatchHistory> fwhist_list;
    ArrayList<fileWatchResult> fwres_list;
    fwResListWrapper resarr;
    fileWatch   fw;
    dbFWTrace   dbtrc;

    dbtrc = new dbFWTrace();
    fwreq_list = reqarr.toFWReqList();
    fwhist_list = (histarr[0]).toFWHstList();
    fw = new fileWatch();
    fwres_list = fw.WatchForFile(fwreq_list, fwhist_list,
                                 ohome, hostname, do_trc, dbtrc);
    resarr = new fwResListWrapper(fwres_list);
    histarr[0] = new fwHstListWrapper(fwhist_list);
    return resarr;
  }
}
/

show errors
