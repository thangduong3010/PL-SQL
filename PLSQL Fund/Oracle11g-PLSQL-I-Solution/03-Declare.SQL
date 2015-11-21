/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM DECLARE-1
SET SERVEROUTPUT ON;

DECLARE
  xSSN      CHAR(9);
  xLNname   VARCHAR2(10);
  xSalary   NUMBER(6);
  xBdate    DATE;
  xDno      NUMBER(2);
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Compiled declarations successfully');
END;

REM DECLARE-2
DECLARE
       xSSN      CHAR(9);
       xLNname   VARCHAR2(10);
       xSalary   NUMBER(6);
       xBdate    DATE;
       xDno      NUMBER(2);

       xDname   department.dname%TYPE;
       xMgrSSN  department.mgrssn%TYPE;

BEGIN
       DBMS_OUTPUT.PUT_LINE ('Compiled declarations successfully');
END;
/

REM DECLARE-3
DECLARE
       xSSN        CHAR(9);
       xLNname     VARCHAR2(10);
       xSalary     NUMBER(6);
       xBdate      DATE;
       xDno        NUMBER(2);

       xDname      department.dname%TYPE;
       xMgrSSN     department.mgrssn%TYPE;

       ProjectRec  project%ROWTYPE;

BEGIN
     DBMS_OUTPUT.PUT_LINE ('Compiled declarations successfully');
END;
/

REM DECLARE-4
DECLARE
       xSSN        CHAR(9);
       xLNname     VARCHAR2(10);
       xSalary     NUMBER(6);
       xBdate      DATE;
       xDno        NUMBER(2);

       xDname      department.dname%TYPE;
       xMgrSSN     department.mgrssn%TYPE;

       ProjectRec  project%ROWTYPE;

       TYPE HoursTable IS TABLE OF works_on.hours%TYPE
          INDEX BY SIMPLE_INTEGER;

       HoursWorked  HoursTable;

BEGIN
     DBMS_OUTPUT.PUT_LINE ('Compiled declarations successfully');
END;
/

REM DECLARE-5
DECLARE
       xSSN        CHAR(9);
       xLNname     VARCHAR2(10);
       xSalary     NUMBER(6);
       xBdate      DATE;
       xDno        NUMBER(2);

       xDname      department.dname%TYPE;
       xMgrSSN     department.mgrssn%TYPE;

       ProjectRec  project%ROWTYPE;

       TYPE HoursTable IS TABLE OF works_on.hours%TYPE
          INDEX BY SIMPLE_INTEGER;

       HoursWorked  HoursTable;

       TYPE EmpProjectInfo IS RECORD
         (ssn     employee.ssn%TYPE,
          pno     works_on.pno%TYPE,
          hours   works_on.hours%TYPE);
   
       EmpProjectRecord EmpProjectInfo;

BEGIN
     DBMS_OUTPUT.PUT_LINE ('Compiled declarations successfully');
END;
/













      