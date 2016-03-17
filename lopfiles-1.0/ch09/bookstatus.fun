REM $Id: bookstatus.fun,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 306

REM This is just a stub function to make available_copies.fun compile.
REM The library system does not yet have a true "bookstatus" indicator.

CREATE OR REPLACE FUNCTION bookstatus (barcode_id_in IN VARCHAR2)
RETURN VARCHAR2
AS
BEGIN
   RETURN 'SHELVED';
END;
/

SHOW ERRORS

