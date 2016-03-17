REM $Id: droptable_enhanced.sql,v 1.1 2001/11/30 23:22:18 bill Exp $
REM From "Learning Oracle PL/SQL" page 213

REM Generate and execute a script that will drop a table supplied as a
REM command-line argument

REM Note: An enhancement in this version compared with that in the text is
REM the addition of a check for any tables with foreign keys to the one
REM being dropped.  If there are any, this script will simply disable the
REM foreign key constraint (as oppposed to dropping the dependent table,
REM which would work, but is less polite).

SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL drop.cmd

SELECT 'ALTER TABLE ' || table_name || ' DROP CONSTRAINT ' || constraint_name
   || ';'
  FROM user_constraints
 WHERE constraint_type = 'R'
   AND r_constraint_name IN
       (SELECT constraint_name
          FROM user_constraints
	 WHERE table_name LIKE UPPER ('&1%'));

SELECT 'DROP TABLE ' || table_name || ';'
  FROM user_tables
 WHERE table_name LIKE UPPER ('&1%');

SPOOL OFF
SET FEEDBACK 5
SET ECHO ON
@drop.cmd
SET ECHO OFF

