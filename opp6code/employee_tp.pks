CREATE OR REPLACE PACKAGE EMPLOYEE_TP
/*
| Generated by or retrieved from Qnxo - DO NOT MODIFY!
| Qnxo - "Get it right, do it fast" - www.qnxo.com
| Qnxo Universal ID: 0b4b1015-32d7-4e94-94b2-245fbbd63544
| Created On: April     04, 2005 07:31:58 Created By: QNXO_DEMO
*/
/*
   The types package creates a set of SUBTYPES that you can use
   in place of %ROWTYPE and %TYPE declarations. It also defines
   a number of collection and REF CURSOR types. By using the
   types package, you can avoid the need to grant SELECT privileges
   on tables simply to perform anchored declarations. You will also
   have a standard set of advanced types to use (and re-use)
   throughout your application.
*/
IS
   -- Two alternatives for ROWTYPE declarations:
   SUBTYPE EMPLOYEE_rt IS EMPLOYEE%ROWTYPE;
   SUBTYPE rowtype IS EMPLOYEE%ROWTYPE;

   SUBTYPE EMPLOYEE_ID_t IS EMPLOYEE.EMPLOYEE_ID%TYPE;
   SUBTYPE LAST_NAME_t IS EMPLOYEE.LAST_NAME%TYPE;
   SUBTYPE FIRST_NAME_t IS EMPLOYEE.FIRST_NAME%TYPE;
   SUBTYPE MIDDLE_INITIAL_t IS EMPLOYEE.MIDDLE_INITIAL%TYPE;
   SUBTYPE JOB_ID_t IS EMPLOYEE.JOB_ID%TYPE;
   SUBTYPE MANAGER_ID_t IS EMPLOYEE.MANAGER_ID%TYPE;
   SUBTYPE HIRE_DATE_t IS EMPLOYEE.HIRE_DATE%TYPE;
   SUBTYPE SALARY_t IS EMPLOYEE.SALARY%TYPE;
   SUBTYPE COMMISSION_t IS EMPLOYEE.COMMISSION%TYPE;
   SUBTYPE DEPARTMENT_ID_t IS EMPLOYEE.DEPARTMENT_ID%TYPE;
   SUBTYPE EMPNO_t IS EMPLOYEE.EMPNO%TYPE;
   SUBTYPE ENAME_t IS EMPLOYEE.ENAME%TYPE;
   SUBTYPE CREATED_BY_t IS EMPLOYEE.CREATED_BY%TYPE;
   SUBTYPE CREATED_ON_t IS EMPLOYEE.CREATED_ON%TYPE;
   SUBTYPE CHANGED_BY_t IS EMPLOYEE.CHANGED_BY%TYPE;
   SUBTYPE CHANGED_ON_t IS EMPLOYEE.CHANGED_ON%TYPE;

    -- Ref cursors returning a row from EMPLOYEE
    -- and a weak REF CURSOR type to use with dynamic SQL.
   TYPE EMPLOYEE_rc IS REF CURSOR RETURN EMPLOYEE%ROWTYPE;
   TYPE table_refcur IS REF CURSOR RETURN EMPLOYEE%ROWTYPE;
   TYPE weak_refcur IS REF CURSOR;

   -- Collection of %ROWTYPE records based on "EMPLOYEE"
   TYPE EMPLOYEE_tc IS TABLE OF EMPLOYEE%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE employee_ntt IS TABLE OF EMPLOYEE%ROWTYPE;
   TYPE employee_vat IS VARRAY(100) OF EMPLOYEE%ROWTYPE;

   -- Same type structure, with a static name.
   TYPE aat IS TABLE OF EMPLOYEE%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE ntt IS TABLE OF EMPLOYEE%ROWTYPE;
   TYPE vat IS VARRAY(100) OF EMPLOYEE%ROWTYPE;
   --
   -- Column Collection based on column "EMPLOYEE_ID"
   TYPE EMPLOYEE_ID_cc IS TABLE OF EMPLOYEE.EMPLOYEE_ID%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "LAST_NAME"
   TYPE LAST_NAME_cc IS TABLE OF EMPLOYEE.LAST_NAME%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "FIRST_NAME"
   TYPE FIRST_NAME_cc IS TABLE OF EMPLOYEE.FIRST_NAME%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "MIDDLE_INITIAL"
   TYPE MIDDLE_INITIAL_cc IS TABLE OF EMPLOYEE.MIDDLE_INITIAL%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "JOB_ID"
   TYPE JOB_ID_cc IS TABLE OF EMPLOYEE.JOB_ID%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "MANAGER_ID"
   TYPE MANAGER_ID_cc IS TABLE OF EMPLOYEE.MANAGER_ID%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "HIRE_DATE"
   TYPE HIRE_DATE_cc IS TABLE OF EMPLOYEE.HIRE_DATE%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "SALARY"
   TYPE SALARY_cc IS TABLE OF EMPLOYEE.SALARY%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "COMMISSION"
   TYPE COMMISSION_cc IS TABLE OF EMPLOYEE.COMMISSION%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "DEPARTMENT_ID"
   TYPE DEPARTMENT_ID_cc IS TABLE OF EMPLOYEE.DEPARTMENT_ID%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "EMPNO"
   TYPE EMPNO_cc IS TABLE OF EMPLOYEE.EMPNO%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "ENAME"
   TYPE ENAME_cc IS TABLE OF EMPLOYEE.ENAME%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "CREATED_BY"
   TYPE CREATED_BY_cc IS TABLE OF EMPLOYEE.CREATED_BY%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "CREATED_ON"
   TYPE CREATED_ON_cc IS TABLE OF EMPLOYEE.CREATED_ON%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "CHANGED_BY"
   TYPE CHANGED_BY_cc IS TABLE OF EMPLOYEE.CHANGED_BY%TYPE INDEX BY BINARY_INTEGER;
   -- Column Collection based on column "CHANGED_ON"
   TYPE CHANGED_ON_cc IS TABLE OF EMPLOYEE.CHANGED_ON%TYPE INDEX BY BINARY_INTEGER;
END EMPLOYEE_TP;
/
