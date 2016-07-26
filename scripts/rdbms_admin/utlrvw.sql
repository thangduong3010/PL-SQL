Rem
Rem $Header: rdbms/admin/utlrvw.sql /st_rdbms_11.2.0/1 2012/03/20 03:49:38 apfwkr Exp $
Rem
Rem utlrvw.sql
Rem
Rem Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      utlrvw.sql - Recompile all views while still in UPGRADE mode
Rem
Rem    DESCRIPTION
Rem      This script recompiles all views in UPGRADE mode.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      03/19/12 - Backport sanagara_bug-13719081 from main
Rem    nlee        04/02/09 - Created
Rem

DEFINE UPGRADE_NUMBER = 8289601 
DEFINE CPU_PATCH_NUMBER = 6452863 
DEFINE UPGRADE_DESC   = 'view invalidation'
SET VERIFY OFF
SET SERVEROUTPUT ON

Rem =======================================================================
Rem Create table registry$history.
Rem Supress error message if table "already exists".
Rem =======================================================================

BEGIN
  EXECUTE IMMEDIATE
    'CREATE TABLE registry$history (
       action_time     DATE,         /* time stamp */
       action          VARCHAR2(30), /* name of action */
       namespace       VARCHAR2(30), /* upgrade namespace */
       version         VARCHAR(30),  /* server version */
       id              NUMBER,       /* Upgrade ID */
       comments        VARCHAR2(255) /* comments */)';
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -955 THEN
        NULL;
      ELSE 
        RAISE;
      END IF;
END;
/

Rem =======================================================================
Rem Invalidate views.
Rem =======================================================================

DECLARE
  CURSOR invalidate1(objectno NUMBER) IS
    SELECT o.obj#
      FROM obj$ o, user$ u 
        WHERE o.type#=4 AND u.user# = o.owner# AND o.obj# IN 
              (SELECT UNIQUE d_obj# FROM access$ WHERE types=9) AND 
              o.obj# > objectno ORDER BY obj#;

  my_err        NUMBER;
  objnum        NUMBER;
  upgrade_entry NUMBER;

BEGIN
  -- skip invalidation if either 6452863 or 8289601 were previously
  -- applied
  SELECT DISTINCT COUNT(id) INTO upgrade_entry FROM registry$history
    WHERE id = '&&UPGRADE_NUMBER' or id = '&&CPU_PATCH_NUMBER';

  IF upgrade_entry > 0 THEN
    dbms_output.put_line ('** utlrvw.sql script is already applied **');
    RETURN;
  ELSE
    -- check if this db was originally created at version 11.2.0.1
    -- or higher
    SELECT COUNT(*) INTO upgrade_entry
    FROM registry$
    WHERE cid = 'CATPROC'
    AND (org_version >= '11.2.0.1.0' OR
        (org_version IS NULL AND version >= '11.2.0.1.0'));

    IF upgrade_entry > 0 THEN
      dbms_output.put_line ('** utlrvw.sql script is not needed **');
      RETURN;
    END IF;
  END IF;

  objnum := 0;

  OPEN invalidate1(objnum);

  LOOP
    BEGIN
      FETCH invalidate1 INTO objnum;
      EXIT WHEN invalidate1%NOTFOUND;
    EXCEPTION
      WHEN OTHERS THEN
        my_err := SQLCODE;
        IF my_err = -1555 THEN -- snapshot too old, re-execute fetch query
          CLOSE invalidate1;
          OPEN  invalidate1(objnum);
          GOTO continue;
        ELSE
          RAISE;
        END IF;
    END;

    BEGIN
      -- Invalidate the view
      DBMS_UTILITY.INVALIDATE (objnum, 0, 0);
    EXCEPTION
      WHEN OTHERS THEN
      null; -- ignore, and proceed.
    END;

<<continue>>
  null;

  END LOOP;

  CLOSE invalidate1;
END;
/

Rem =======================================================================
Rem Insert values for upgrade into registry.
Rem =======================================================================

INSERT INTO registry$history (action_time, action, id, comments)
  VALUES ( SYSTIMESTAMP, 'VIEW INVALIDATE', &&UPGRADE_NUMBER, '&&UPGRADE_DESC' );

COMMIT;

EXECUTE dbms_session.reset_package;

SET SERVEROUTPUT OFF
