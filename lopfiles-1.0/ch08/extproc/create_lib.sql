REM $Id: create_lib.sql,v 1.1 2001/11/30 23:26:32 bill Exp $
REM From "Learning Oracle PL/SQL" page 300

REM Create Oracle "library" where external procedure can live

ACCEPT path PROMPT 'Fully qualified path and file name of shared object file: '
CREATE LIBRARY lplib AS '&&path';
/

