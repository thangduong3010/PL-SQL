CREATE OR REPLACE PACKAGE EMPLOYEE_UP
/*
| Generated by or retrieved from Qnxo - DO NOT MODIFY!
| Qnxo - "Get it right, do it fast" - www.qnxo.com
| Qnxo Universal ID: c8fc32f5-c8b1-4369-8d59-4582d567465c
| Created On: April     04, 2005 07:31:59 Created By: QNXO_DEMO
*/
IS

   -- Converts a record to a string that can be displayed.
   -- Currently only supports number, date and strings columns
   -- (anything that can be converted using STANDARD.TO_CHAR).
   FUNCTION to_char (
        rec_in IN EMPLOYEE_TP.EMPLOYEE_rt
      , delimiter_in IN VARCHAR2 := CHR(10) -- Carriage return
      )
   RETURN VARCHAR2;

   -- Displays a record of information as returned by the
   -- utility_package.to_char function.
   PROCEDURE display_row (
        rec_in IN EMPLOYEE_TP.EMPLOYEE_rt
      , delimiter_in IN VARCHAR2 := CHR(10) -- Carriage return
      );

   -- Converts a row to a string that can be displayed.
   -- Currently only supports number, date and strings columns
   -- (anything that can be converted using STANDARD.TO_CHAR).
   FUNCTION to_char (
      employee_id_in IN EMPLOYEE_TP.EMPLOYEE_ID_t,
      delimiter_in IN VARCHAR2 := CHR(10) -- Carriage return
      )
   RETURN VARCHAR2;

    -- Displays a row of information as returned by the
   -- utility_package.to_char function.
   PROCEDURE display_row (
      employee_id_in IN EMPLOYEE_TP.EMPLOYEE_ID_t,
      delimiter_in IN VARCHAR2 := CHR(10) -- Carriage return
      );

    -- Write the specified rows of the table to a file.
   -- This program uses UTL_FILE; you are responsible for making
   -- sure UTL_FILE is enabled for the specified directory.
   PROCEDURE dump_to_file (
      loc_in IN VARCHAR2
    , file_in IN VARCHAR2
    , where_in IN VARCHAR2 := NULL
    , delimiter_in IN VARCHAR2 := '|'
    );
   -- Copy the specified row to another row in the table,
   -- using the new values specified by the NV parameters
   -- below. NULL values will be ignored. If you specify
   -- prefix and/or suffix values then those strings are
   -- applied to all VARCHAR2 columns in the table.
   PROCEDURE copy (
      -- Primary key to identify source row
      employee_id_in IN EMPLOYEE_TP.EMPLOYEE_ID_t,
      -- New value parameters, overriding existing ones.
      LAST_NAME_nv IN EMPLOYEE_TP.LAST_NAME_t DEFAULT NULL,
      FIRST_NAME_nv IN EMPLOYEE_TP.FIRST_NAME_t DEFAULT NULL,
      MIDDLE_INITIAL_nv IN EMPLOYEE_TP.MIDDLE_INITIAL_t DEFAULT NULL,
      JOB_ID_nv IN EMPLOYEE_TP.JOB_ID_t DEFAULT NULL,
      MANAGER_ID_nv IN EMPLOYEE_TP.MANAGER_ID_t DEFAULT NULL,
      HIRE_DATE_nv IN EMPLOYEE_TP.HIRE_DATE_t DEFAULT NULL,
      SALARY_nv IN EMPLOYEE_TP.SALARY_t DEFAULT NULL,
      COMMISSION_nv IN EMPLOYEE_TP.COMMISSION_t DEFAULT NULL,
      DEPARTMENT_ID_nv IN EMPLOYEE_TP.DEPARTMENT_ID_t DEFAULT NULL,
      EMPNO_nv IN EMPLOYEE_TP.EMPNO_t DEFAULT NULL,
      ENAME_nv IN EMPLOYEE_TP.ENAME_t DEFAULT NULL,
      -- Generated primary key value
      employee_id_out IN OUT EMPLOYEE_TP.EMPLOYEE_ID_t,
      prefix_in IN VARCHAR2 DEFAULT NULL,
      suffix_in IN VARCHAR2 DEFAULT NULL
      );
END EMPLOYEE_UP;
/
