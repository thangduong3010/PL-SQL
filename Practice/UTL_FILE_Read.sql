SET SERVEROUTPUT ON

DECLARE
   TextRecord   utl_file.file_type;
   TextFile     UTL_FILE.file_type;
BEGIN
   TextFile := UTL_FILE.fopen ('MY_DIR', 'Employees.csv', 'r');

   IF NOT UTL_FILE.is_open (TextFile)
   THEN
      DBMS_OUTPUT.put_line ('Unable to open file.');
   ELSE
      LOOP
         UTL_FILE.get_line (TextFile, TextRecord);
         DBMS_OUTPUT.put_line (TextRecord);
      END LOOP;
   END IF;

   UTL_FILE.fclose (TextFile);
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      DBMS_OUTPUT.put_line ('File read in its entirety');
      UTL_FILE.fclose (TextFile);
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLCODE);
      DBMS_OUTPUT.put_line (SQLERRM);
      UTL_FILE.fclose_all;
END;