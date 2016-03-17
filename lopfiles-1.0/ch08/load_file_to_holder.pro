REM $Id$
REM From "Learning Oracle PL/SQL" page 281

REM Create procedure to load entire contents of file into file_holder table

CREATE OR REPLACE PROCEDURE load_file_to_holder (dirname_in IN VARCHAR2,
   filename_in IN VARCHAR2, eol_char_count IN PLS_INTEGER DEFAULT 1)
IS
   fh UTL_FILE.FILE_TYPE;
   buffer VARCHAR2(4000);
   lno PLS_INTEGER := 0;
   max_varchar_c CONSTANT PLS_INTEGER := 4000;
   eof BOOLEAN := FALSE;
BEGIN
   lopu.assert_notnull(dirname_in);
   lopu.assert_notnull(filename_in);
   lopu.assert(eol_char_count BETWEEN 0 AND 3,
     'eol_char_count not in range 0 to 3');

   fh := UTL_FILE.FOPEN(location => dirname_in, 
                        filename => filename_in, 
                        open_mode => 'r',
                        max_linesize => max_varchar_c + eol_char_count);

   DELETE file_holder
    WHERE dirname = dirname_in
      AND filename = filename_in;

   WHILE NOT eof
   LOOP
      get_nextline(fh, buffer, eof);
      lno := lno + 1;
      INSERT INTO file_holder (dirname, filename, line_no, text)
      VALUES (dirname_in, filename_in, lno, buffer);
   END LOOP;

   UTL_FILE.FCLOSE(fh);

EXCEPTION
   WHEN OTHERS
   THEN
      IF UTL_FILE.IS_OPEN(fh)
      THEN
         UTL_FILE.FCLOSE(fh);
      END IF;
      RAISE;

END load_file_to_holder;
/

SHOW ERRORS

