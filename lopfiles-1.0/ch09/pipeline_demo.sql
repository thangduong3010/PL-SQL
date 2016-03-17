REM $Id: pipeline_demo.sql,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 358

REM Illustration of how to select from a PL/SQL function (which has been
REM created as a pipelined table function)

SELECT * FROM TABLE(CAST(active_patrons(SYSDATE-4) AS active_patrons_t));

