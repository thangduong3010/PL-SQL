REM $Id: active_patrons_t.typ,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 357

REM Support type for active_patrons pipelined function

CREATE OR REPLACE TYPE active_patrons_t AS TABLE OF NUMBER;
/

SHOW ERRORS

