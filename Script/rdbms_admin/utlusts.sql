Rem
Rem $Header: rdbms/admin/utlusts.sql /st_rdbms_11.2.0/3 2012/06/12 18:46:33 mdietric Exp $
Rem
Rem utlusts.sql
Rem
Rem Copyright (c) 2004, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      utlusts.sql - UTiLity Upgrade STatuS
Rem
Rem    DESCRIPTION
Rem      Presents Post-upgrade Status in either TEXT or XML
Rem
Rem    NOTES
Rem      Invoked by utlu112s.sql with TEXT parameter
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mdietric    05/18/12 - Backport mdietric_bug-11901407 from main
Rem    jerrede     04/06/11 - Backport jerrede_bug-11837389 from main
Rem    cmlim       04/01/11 - Backport cmlim_bug-11842119 from main
Rem    cdilling    12/01/08 - change banner to 11.2
Rem    cdilling    04/18/07 - add stats gathering time
Rem    rburns      08/14/06 - limit error output lines
Rem    cdilling    06/08/06 - add support for error logging 
Rem    rburns      05/24/06 - parallel upgrade 
Rem    rburns      07/21/04 - add elapsed time 
Rem    rburns      06/22/04 - rburns_pre_upgrade_util
Rem    rburns      06/16/04 - Created
Rem

SET SERVEROUTPUT ON
SET VERIFY OFF

DECLARE

   display_mode       VARCHAR2(4) := '&1';
   display_xml        BOOLEAN := FALSE;
   comp_name          registry$.cname%type;
   prev_comp_name   registry$.cname%type := 'Oracle Server';
   p_id               registry$.cid%type;
   status             VARCHAR2(30);
   start_time         TIMESTAMP; 
   end_time           TIMESTAMP; 
   up_start_time      TIMESTAMP := NULL;
   up_end_time        TIMESTAMP := NULL; 
   actions_start_time TIMESTAMP := NULL;
   actions_end_time   TIMESTAMP := NULL;
   message            VARCHAR2(128);
   elapsed_time       INTERVAL DAY TO SECOND(9) := 
                      INTERVAL '0 00:00:00.00' DAY TO SECOND; 
   time_result        VARCHAR2(30); 

BEGIN
   IF display_mode = 'XML' THEN
      display_xml := TRUE;
      DBMS_OUTPUT.PUT_LINE('<RDBMSUP version="11.2">');
      DBMS_OUTPUT.PUT_LINE('<Components>');
   ELSE
      DBMS_OUTPUT.PUT_LINE('.');
      DBMS_OUTPUT.PUT_LINE(
             'Oracle Database 11.2 Post-Upgrade Status Tool    ' ||
             LPAD(TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'),26));
      DBMS_OUTPUT.PUT_LINE('.');
      DBMS_OUTPUT.PUT_LINE(RPAD('Component', 40) || RPAD('Current',13) ||
              RPAD('Version', 12) || RPAD('Elapsed Time', 15));
      DBMS_OUTPUT.PUT_LINE(RPAD('Name', 40) || RPAD('Status',13) ||
              RPAD('Number', 12) || RPAD('HH:MM:SS', 15));
      DBMS_OUTPUT.PUT_LINE('.');
   END IF;

   BEGIN
      -- get upgrade start/end times
      SELECT optime INTO up_start_time 
      FROM dba_registry_log
      WHERE comp_id='UPGRD_BGN';
      start_time := up_start_time;
	
      SELECT optime INTO up_end_time 
      FROM dba_registry_log
      WHERE comp_id='UPGRD_END';

      -- get 'final actions' start/end times
      SELECT optime INTO actions_start_time 
      FROM dba_registry_log
      WHERE comp_id='ACTIONS_BGN';
	
      SELECT optime INTO actions_end_time 
      FROM dba_registry_log
      WHERE comp_id='ACTIONS_END';

      -- get RDBMS end time
      SELECT optime, operation, message INTO end_time, status, message
      FROM dba_registry_log
      WHERE comp_id='RDBMS' AND 
            optime = (SELECT MAX(optime) FROM dba_registry_log
                      WHERE comp_id = 'RDBMS');

      -- get RDBMS (catproc) status
      SELECT status into status
      FROM dba_registry
      WHERE comp_id = 'CATPROC' AND namespace = 'SERVER';

   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
  
   IF start_time IS NOT NULL AND end_time IS NOT NULL THEN
      elapsed_time := end_time - start_time;
      time_result := to_char(elapsed_time);
   ELSE
      time_result := NULL;
   END IF;

   IF display_xml THEN
       DBMS_OUTPUT.PUT_LINE ('<Component id="Oracle Server"' ||
                   '" cid="RDBMS"' ||
                   '">');
   ELSE
      DBMS_OUTPUT.PUT_LINE(rpad('Oracle Server',35));
   END IF;

   FOR err in (SELECT message FROM sys.registry$error
               WHERE identifier = 'RDBMS' AND ROWNUM < 25
               ORDER BY timestamp) LOOP
      IF display_xml THEN
         DBMS_OUTPUT.PUT_LINE ('"error="' || err.message || '" ');
      ELSE
         DBMS_OUTPUT.PUT_LINE('.   ' || err.message);
      END IF;
   END LOOP; -- registry$error loop

   IF display_xml THEN
       DBMS_OUTPUT.PUT_LINE ('" status="' || status ||
                   '" upgradeTime="' || substr(time_result,5,8) ||
                   '">');
   ELSE
      DBMS_OUTPUT.PUT_LINE('.' ||
                        LPAD(status,46) || ' ' ||
                        LPAD(substr(message,1,15),15) ||
                        LPAD(substr(time_result,5,8),10));
   END IF;

   -- look for all SERVER components 
   FOR i IN 1..SYS.dbms_registry_server.component.last LOOP
      p_id := dbms_registry_server.component(i);
      IF p_id != 'ODM' THEN  -- ODM has status REMOVED
         start_time := NULL;
         end_time := NULL;
         FOR log IN (SELECT operation, optime, message
               FROM dba_registry_log WHERE namespace = 'SERVER' AND
               comp_id = p_id ORDER BY optime) LOOP

            comp_name :=  dbms_registry.comp_name(p_id);

            --
            -- Always display component name but only when
            -- the component changes.  In dba_registry_log
            -- you will have component with multiple operations.
            -- For example JAVAVM is the p_id (component) and
            -- START and VALID are the operations.
            -- We only display the corresponding component
            -- name associated with the p_id once.  In this
            -- example the component name is JServer JAVA Virtual
            -- Machine that is assocatied with the p_id JAVAVM.
            --
            IF (prev_comp_name != comp_name) THEN
               prev_comp_name :=  comp_name;
               IF display_xml THEN
                  DBMS_OUTPUT.PUT_LINE ('<Component id="' || comp_name ||
                         '" cid="' || p_id || '" ');
               ELSE
                  DBMS_OUTPUT.PUT_LINE(rpad(comp_name,35));
               END IF;
            END IF;

            IF log.operation = 'START' THEN
               start_time := log.optime;

	       -- For each Component output up to 25 upgrade errors	
               FOR err in (SELECT message FROM sys.registry$error
                           WHERE identifier = p_id AND ROWNUM < 25
                           ORDER BY timestamp) LOOP
                  IF display_xml THEN
                    DBMS_OUTPUT.PUT_LINE ('"error="' || err.message || '" ');
                  ELSE
                     DBMS_OUTPUT.PUT_LINE('.   ' || err.message);
                  END IF;
               END LOOP; -- registry$error loop
            ELSE
               BEGIN
                 SELECT status into status
                 FROM dba_registry
                 WHERE namespace = 'SERVER' AND comp_id = p_id;
               END;
               elapsed_time := log.optime - start_time;
               time_result := to_char(elapsed_time);

               IF display_xml THEN
                  DBMS_OUTPUT.PUT_LINE ('" status="' || LOWER(status) ||
                         '" upgradeTime="' || substr(time_result,5,8) ||
                         '">');
               ELSE
                  DBMS_OUTPUT.PUT_LINE('.' ||
                                    LPAD(status,46) || ' ' ||
                                    LPAD(substr(log.message,1,15),15) ||
                                    LPAD(substr(time_result,5,8),10));
               END IF;
            END IF;
        
         END LOOP;  -- log loop 
      END IF;  -- not ODM
   END LOOP;  -- component loop

   IF actions_end_time IS NOT NULL THEN
      elapsed_time := actions_end_time - actions_start_time; 
      time_result := to_char(elapsed_time);
      IF display_xml THEN
         DBMS_OUTPUT.PUT_LINE ('<Component id="Final Actions"' ||
                   '" cid="ACTIONS"');
      ELSE
         DBMS_OUTPUT.PUT_LINE(rpad('Final Actions',35));
      END IF;
      -- For 'Final Actions' phase -  output up to 25 upgrade errors	
      FOR err in (SELECT message FROM sys.registry$error
                  WHERE identifier = 'ACTIONS' AND ROWNUM < 25
                  ORDER BY timestamp) LOOP
          IF display_xml THEN
             DBMS_OUTPUT.PUT_LINE ('"error="' || err.message || '" ');
          ELSE
             DBMS_OUTPUT.PUT_LINE('.   ' || err.message);
          END IF;
      END LOOP; -- registry$error loop
      -- Output final actions time
      IF display_xml THEN
         DBMS_OUTPUT.PUT_LINE (
                         '" upgradeTime="' || substr(time_result,5,8) ||
                         '">');
      ELSE
         DBMS_OUTPUT.PUT_LINE('.' ||
                              LPAD(' ',46) || ' ' ||
                              LPAD(' ',15) ||
                              LPAD(substr(time_result,5,8),10));
      END IF;
   END IF; -- actions_end_time is not null

   IF up_end_time IS NOT NULL THEN
      elapsed_time := up_end_time - up_start_time; 
      time_result := to_char(elapsed_time); 
      IF display_xml THEN
         DBMS_OUTPUT.PUT_LINE('<totalUpgrade time="' || 
                  substr(time_result, 5,8) || '">');
      ELSE
         DBMS_OUTPUT.PUT_LINE('Total Upgrade Time: ' || 
                  substr(time_result, 5,8));
      END IF;
   ELSE
      IF display_xml THEN
            DBMS_OUTPUT.PUT_LINE('<Upgrade incomplete/>');
      ELSE
         DBMS_OUTPUT.PUT_LINE('Upgrade Incomplete');
      END IF;
   END IF;
      IF display_xml THEN
       DBMS_OUTPUT.PUT_LINE('</Components>');
         DBMS_OUTPUT.PUT_LINE('</RDBMSUP>');
      END IF;
END;
/

SET SERVEROUTPUT OFF
SET VERIFY ON
