Rem
Rem $Header: dbmsplsw.sql 28-apr-2006.11:37:21 achoi Exp $
Rem
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsplsw.sql - dbms_warning package and view definitions for
Rem      PL/SQL warning settings
Rem
Rem    DESCRIPTION
Rem      This file defines the dbms_warning package and various user and
Rem      dba views to access PL/SQL warning settings.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achoi       04/14/06 - support application edition 
Rem    ciyer       08/06/03 - cleanup 
Rem    sagrawal    06/06/03 - bug 2995317
Rem    sagrawal    04/18/03 - clean up
Rem    sagrawal    03/17/03 - fix permissions
Rem    sagrawal    03/06/03 - DBMS_PLSQL_warning library
Rem    sagrawal    01/08/03 - improve view performance
Rem    sagrawal    12/04/02 - package implementation
Rem    sagrawal    11/26/02 - clean up
Rem    sagrawal    11/18/02 - fix comments
Rem    sagrawal    11/08/02 - sagrawal_plsql_compiler_warning_framework
Rem    sagrawal    10/03/02 - PL/SQL compiler warnings package API
Rem    sagrawal    10/02/02 - move dbms_warning body INTO plb file
Rem    sagrawal    04/09/02 - PL/SQL warnings views
Rem    sagrawal    04/09/02 - Created
REM

-- DBMS_WARNING packages, exposes API's to set and get warning settings
-- for the SESSION or SYSTEM
CREATE OR replace PACKAGE sys.dbms_warning AUTHID CURRENT_USER AS
  
  /*
   * For the following functions, meanings of parameters are:
   *
   * 1. warning_category - one of:
   *    - 'ALL'
   *    - 'INFORMATIONAL'
   *    - 'SEVERE'
   *    - 'PERFORMANCE'
   *
   * 2. warning_value - one of:
   *    - 'ENABLE'
   *    - 'DISABLE'
   *    - 'ERROR'
   *
   * 3. scope - one of:
   *    - 'SYSTEM'
   *    - 'SESSION'
   *
   * 4. warning_number - any valid warning number
   */

  --
  -- This API changes the warning_category to warning value without affecting
  -- other independent categories.
  --
  PROCEDURE add_warning_setting_cat(warning_category IN VARCHAR2,
                                    warning_value    IN VARCHAR2,
                                    scope            IN VARCHAR2);

  --
  -- This API changes the warning_number to warning value without affecting
  -- other existing settings.
  --
  PROCEDURE add_warning_setting_num(warning_number IN PLS_INTEGER,
                                    warning_value  IN VARCHAR2,
                                    scope          IN VARCHAR2);

  --
  -- This API returns the session warning_value for a given warning_category
  -- If any of parameter values are incorrect or, if the function was
  -- unsuccessful 'INVALID' is returned, the session warning_value is
  -- returned on successful completion.
  --
  FUNCTION get_warning_setting_cat(warning_category IN VARCHAR2)
                                   RETURN VARCHAR2;

  --
  -- This API returns the session warning_value for a given warning_number
  -- If any of parameter values are incorrect or, if the function was
  -- unsuccessful 'INVALID' is returned, the session warning_value is
  -- returned on successful completion.
  --
  FUNCTION get_warning_setting_num(warning_number IN PLS_INTEGER)
                                   RETURN VARCHAR2;

  --
  -- This API returns the entire warning setting string for the current
  -- session
  --
  FUNCTION get_warning_setting_string RETURN VARCHAR2;

  --
  -- This API sets the entire warning string, replacing the old values.
  -- It can set the value for the SESSION or for SYSTEM depending on the
  -- value of the scope parameter.
  --
  PROCEDURE set_warning_setting_string(VALUE IN VARCHAR2, scope IN VARCHAR2);

  --
  -- This API returns the warning category name for the given warning number
  --
  FUNCTION get_category(warning_number IN  PLS_INTEGER) RETURN VARCHAR2;
  
END dbms_warning;
/

@@prvtplsw.plb

GRANT EXECUTE ON dbms_warning to PUBLIC WITH GRANT OPTION;

CREATE OR REPLACE
PUBLIC SYNONYM dbms_warning FOR dbms_warning;

CREATE OR REPLACE
VIEW user_warning_settings
  (object_name, object_id, object_type, warning, setting) AS
  SELECT o.name, o.obj#,
         DECODE(o.type#,
                 7, 'PROCEDURE',
                 8, 'FUNCTION',
                 9, 'PACKAGE',
                11, 'PACKAGE BODY',
                12, 'TRIGGER',
                13, 'TYPE',
                14, 'TYPE BODY',
                    'UNDEFINED'),
         DECODE(w.warning,
                -1, 'INFORMATIONAL',
                -2, 'PERFORMANCE',
                -3, 'SEVERE', 
                -4, 'ALL',
                w.warning),
         DECODE(w.setting,
                0, 'DISABLE', 
                1, 'ENABLE', 
                2, 'ERROR', 
                   'INVALID')
    FROM sys."_CURRENT_EDITION_OBJ" o,
    TABLE(dbms_warning_internal.show_warning_settings(o.obj#)) w
    WHERE o.linkname IS NULL
    AND o.obj# = w.obj_no
    AND o.type# IN (7, 8, 9, 11, 12, 13, 14)
    AND o.owner# = userenv('SCHEMAID')
/

comment on table user_warning_settings is
'Warning Parameter settings for objects owned by the user'
/
comment on column user_warning_settings.object_name is
'Name of the object'
/
comment on column user_warning_settings.object_id is
'Object number of the object'
/
comment on column user_warning_settings.object_type is
'Type of the object'
/
comment on column user_warning_settings.warning is
'Warning number or category'
/
comment on column user_warning_settings.setting is
'Value of the warning setting'
/

CREATE OR REPLACE
PUBLIC SYNONYM user_warning_settings FOR user_warning_settings;

GRANT SELECT ON user_warning_settings TO PUBLIC WITH GRANT OPTION;

CREATE OR REPLACE
VIEW all_warning_settings
  (owner, object_name, object_id, object_type,  warning, setting) AS
  SELECT u.name, o.name, o.obj#,
         DECODE(o.type#,
                 7, 'PROCEDURE',
                 8, 'FUNCTION',
                 9, 'PACKAGE',
                11, 'PACKAGE BODY',
                12, 'TRIGGER',
                13, 'TYPE',
                14, 'TYPE BODY',
                    'UNDEFINED'),
         DECODE(w.warning,
                -1, 'INFORMATIONAL',
                -2, 'PERFORMANCE',
                -3, 'SEVERE',
                -4, 'ALL',
                w.warning),
         DECODE(w.setting,
                0, 'DISABLE',
                1, 'ENABLE',
                2, 'ERROR',
                   'INVALID')
    FROM sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, 
    TABLE(dbms_warning_internal.show_warning_settings(o.obj#)) w
    WHERE o.owner# = u.user#
    AND o.linkname IS NULL
    AND o.type# IN (7, 8, 9, 11, 12, 13, 14)
    AND w.obj_no = o.obj#
    AND 
    (
      o.owner# IN (userenv('SCHEMAID'), 1 /* PUBLIC */)
      OR
      (
        (
          (
            (o.type# = 7 OR o.type# = 8 OR o.type# = 9 OR o.type# = 13)
             and
             o.obj# in (select obj# from sys.objauth$
             where grantee# in (select kzsrorol from x$kzsro)
                   and privilege#  = 12 /* EXECUTE */)
           )
           or
           exists
           (
              select null from sys.sysauth$
                where grantee# in (select kzsrorol from x$kzsro)
                      and
                      (
                        (
                          /* procedure */
                          (o.type# = 7 or o.type# = 8 or o.type# = 9)
                          and
                          (
                             privilege# = -144 /* EXECUTE ANY PROCEDURE */
                             or
                             privilege# = -141 /* CREATE ANY PROCEDURE */
                          ) 
                        )
                        or
                        (
                          /* package body */
                          o.type# = 11 and
                          privilege# = -141 /* CREATE ANY PROCEDURE */
                        )
                        or
                        (
                          /* type */
                          o.type# = 13
                          and
                          (
                             privilege# = -184 /* EXECUTE ANY TYPE */
                             or
                             privilege# = -181 /* CREATE ANY TYPE */
                          )
                        )
                        or
                        (
                          /* type body */
                          o.type# = 14 and
                          privilege# = -181 /* CREATE ANY TYPE */
                        )
                      ) 
           )
        )
      )
    )
/
comment on table all_warning_settings is
  'Warnings ettings for objects accessible to the user'
/
comment on column all_warning_settings.owner is
  'Username of the owner of the object'
/
comment on column all_warning_settings.object_name is
'Name of the object'
/
comment on column all_warning_settings.object_id is
'Object number of the object'
/
comment on column all_warning_settings.object_type is
'Type of the object'
/
comment on column all_warning_settings.warning is
'Warning number or category'
/
comment on column all_warning_settings.setting is
'Value of the warning setting'
/

CREATE OR REPLACE
PUBLIC SYNONYM all_warning_settings FOR all_warning_settings;

GRANT SELECT ON all_warning_settings TO PUBLIC WITH GRANT OPTION;

CREATE OR REPLACE
VIEW dba_warning_settings
  (owner, object_name, object_id, object_type, warning, setting) AS
  SELECT u.name, o.name, o.obj#,
         DECODE(o.type#,
                 7, 'PROCEDURE',
                 8, 'FUNCTION',
                 9, 'PACKAGE',
                11, 'PACKAGE BODY',
                12, 'TRIGGER',
                13, 'TYPE',
                14, 'TYPE BODY',
                    'UNDEFINED'),
         DECODE(w.warning,
                -1, 'INFORMATIONAL',
                -2, 'PERFORMANCE',
                -3, 'SEVERE',
                -4, 'ALL',
                w.warning),
         DECODE(w.setting,
                0, 'DISABLE',
                1, 'ENABLE',
                2, 'ERROR',
                   'INVALID')
    FROM sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
    TABLE(dbms_warning_internal.show_warning_settings(o.obj#)) w
    WHERE o.owner# = u.user#
    AND o.linkname is null
    AND o.type# IN (7, 8, 9, 11, 12, 13, 14)
    AND w.obj_no = o.obj#
/
comment on table dba_warning_settings is
'warning settings for all objects'
/
comment on column dba_warning_settings.owner is
'Username of the owner of the object'
/
comment on column dba_warning_settings.object_name is
'Name of the object'
/
comment on column dba_warning_settings.object_id is
'Object number of the object'
/
comment on column dba_warning_settings.object_type is
'Type of the object'
/
comment on column dba_warning_settings.warning is
'Warning number or category'
/
comment on column dba_warning_settings.setting is
'Value of the warning setting'
/
CREATE OR REPLACE
PUBLIC SYNONYM dba_warning_settings FOR dba_warning_settings;

GRANT SELECT ON dba_warning_settings TO select_catalog_role;

