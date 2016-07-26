Rem
Rem $Header: dbmspp.sql 27-jun-2005.14:07:13 mxyang Exp $
Rem
Rem dbmspp.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmspp.sql - package of PL/SQL preprocessor utilities
Rem
Rem    DESCRIPTION
Rem      The package dbms_preprocessor provides subprograms to
Rem      print or retrieve source text of a stored PL/SQL unit
Rem      or an anonymous block in its post-processed form.
Rem
Rem    NOTES
Rem      This script should be run as user SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mxyang      06/20/05 - bug 4399593: add exception wrapped_input
Rem    mxyang      08/23/04 - mxyang_bug-3831885
Rem    mxyang      07/28/04 - Created
Rem

create or replace package dbms_preprocessor authid current_user as

  ------------
  --  OVERVIEW
  --
  --  This package provides subprograms to print or retrieve the source
  --  text of a PL/SQL unit in its post-processed form.
  --
  --  There are three styles of subprograms.
  --  (1) subprograms that take a schema name, a unit type name, and the
  --      unit name.
  --  (2) subprograms that take a VARCHAR2 string which contains the
  --      source text of an arbitrary PL/SQL compilation unit.
  --  (3) subprograms that take a VARCHAR2 index-by table which
  --      contains the segmented source text of an arbitrary PL/SQL
  --      PL/SQL compilation unit.
  -- 
  --  Subprograms of the first style are used to print or retrieve the
  --  post-processed source text of a stored PL/SQL unit. The user must
  --  have the privileges necessary to view the original source text of
  --  this unit. The user must also specify the schema in which the unit
  --  is defined, the type of the unit, and the name of the unit. If the
  --  schema is null, then the current user schema is used. If the status
  --  of the stored unit is VALID and the user has the required privilege,
  --  then the post-processed source text is guaranteed to be the same as
  --  that of the unit when it was last time compiled.
  --
  --  Subprograms of the second or third style are used to generate
  --  post-processed source text in the current user schema. The source
  --  text is passed in as a single VARCHAR2 string in the second style
  --  or as a VARCHAR2 index-by table in the third style. The source text
  --  can represent an arbitrary PL/SQL compilation unit. A typical usage
  --  is to pass the source text of an anonymous block and generate its
  --  post-processed source text in the current user schema. The third
  --  style can be useful when the source text exceeds the VARCHAR2 length
  --  limit.
  --
  --  NOTES:
  --  1. For subprograms of the first style, the status of the stored
  --     PL/SQL unit does not need to be VALID. Likewise, the source text
  --     passed in as a VARCHAR2 string or a VARCHAR2 index-by table may
  --     contain compile time errors. If errors are found when generating
  --     the post-processed source, the error message text will also appear
  --     at the end of the post-processed source text. In some cases,
  --     the preprocessing can be aborted because of errors. When this
  --     happens, the post-processed source text will appear to be
  --     incomplete and the associated error message can help to indicate
  --     that an error has occurred during preprocessing.
  --  2. For subprograms of the second or third style, the source text can
  --     represent any arbitrary PL/SQL compilation unit. However, the
  --     source text of a valid PL/SQL compilation unit cannot include
  --     commonly used prefixes such as "create or replace". In general,
  --     the input source should be syntactically prepared in a way as if
  --     it were obtained from the all_source view. The following list
  --     gives some examples of valid initial syntax for some PL/SQL
  --     compilation units.
  --       anonymous block   (begin | declare) ...
  --       package           package <name> ...
  --       package body      package body <name> ...
  --       procedure         procedure <name> ...
  --       function          function <name> ...
  --       type              type <name> ...
  --       type body         type body <name> ...
  --       trigger           (begin | declare) ... 
  --     If the source text represents a named PL/SQL unit that is valid,
  --     that unit will not be created after its post-processed source text
  --     is generated.
  -------------
  -- TYPES
  --
  -- Define type to store lines of post-processed source text

  type source_lines_t is
    table of varchar2(32767) index by binary_integer;

  wrapped_input exception;
  pragma exception_init(wrapped_input, -24241);

  empty_input exception;
  pragma exception_init(empty_input, -24236);

  ---------------------------
  -- PROCEDURES AND FUNCTIONS

  --  Name:
  --    print_post_processed_source
  --  Description:
  --    Given a stored PL/SQL unit, print its post-processed source text.
  --  Input arguments:
  --    object_type
  --      Must be one of "PACKAGE", "PACKAGE BODY", "PROCEDURE", "FUNCTION",
  --      "TYPE", "TYPE BODY", or "TRIGGER".
  --    schema_name
  --      The schema name. If NULL then use current schema.
  --    object_name
  --      The name of the object.
  --    The object_type is always case insensitive. The schema_name or
  --    object_name is case insensitive unless a quoted identifier is used.
  --  Exceptions:
  --    ORA-24234: insufficient privileges or object does not exist.
  --    ORA-24235: bad value for object type. Should be one of PACKAGE,
  --      PACKAGE BODY, PROCEDURE, FUNCTION, TYPE, TYPE BODY, or TRIGGER.
  --    ORA-00931: missing identifier. The object_name should not be null.
  --    ORA-06502: PL/SQL: numeric or value error: character string buffer
  --               too small. A line is too long ( > 32767 bytes).
  procedure print_post_processed_source(object_type varchar2,
                                        schema_name varchar2,
                                        object_name varchar2);

  --  Name:
  --    print_post_processed_source
  --  Description:
  --    Given the source text of a compilation unit, print its post-processed
  --    source text.
  --  Input arguments:
  --    source
  --      The source text of the compilation unit
  --  Exceptions:
  --    ORA-24236: source text is empty.
  --    ORA-24241: source text is wrapped.
  --    ORA-06502: PL/SQL: numeric or value error: character string buffer
  --               too small. A line is too long ( > 32767 bytes).

  procedure print_post_processed_source(source varchar2);

  --  Name:
  --    print_post_processed_source
  --  Description:
  --    Given the source text of a compilation unit, print its post-processed
  --    source text.
  --  Input arguments:
  --    source
  --      Index-by table containing the source text of the compilation
  --      unit. The source text is a concatenation of all the non-null
  --      index-by table elements in ascending index order.
  --  Exceptions:
  --    ORA-24236: source text is empty.
  --    ORA-24241: source text is wrapped.
  --    ORA-06502: PL/SQL: numeric or value error: character string buffer
  --               too small. A line is too long ( > 32767 bytes).
  --  Notes:
  --    The index-by table may contain holes. Null elements are ignored
  --    when doing the concatenation.

  procedure print_post_processed_source(source source_lines_t);

  --  Name:
  --    get_post_processed_source
  --  Description:
  --    Given a stored procedure, get its post-processed source text.
  --  Input arguments:
  --    object_type
  --      Must be one of "PACKAGE", "PACKAGE BODY", "PROCEDURE", "FUNCTION",
  --      "TYPE", "TYPE BODY", or "TRIGGER".
  --    schema_name
  --      The schema name. If NULL then use current schema.
  --    object_name
  --      The name of the object.
  --    The object_type is always case insensitive. The schema_name or
  --    object_name is case insensitive unless a quoted identifier is used.
  --  RETURNS:
  --    Index-by table containing the lines of the post-processed source
  --    text starting from index 1. Newline characters are not removed.
  --    Each line in the post-processed source text is mapped to a row
  --    in the index-by table. In the post-processed source, unselected
  --    text will have blank lines.
  --  Exceptions:
  --    ORA-24234: insufficient privileges or object does not exist.
  --    ORA-24235: bad value for object type. Should be one of PACKAGE,
  --      PACKAGE BODY, PROCEDURE, FUNCTION, TYPE, TYPE BODY, or TRIGGER.
  --    ORA-00931: missing identifier. The object_name should not be null.
  --    ORA-06502: PL/SQL: numeric or value error: character string buffer
  --               too small. A line is too long ( > 32767 bytes).

  function get_post_processed_source(object_type varchar2,
                                     schema_name varchar2,
                                     object_name varchar2)
    return source_lines_t;

  --  Name:
  --    get_post_processed_source
  --  Description:
  --    Given the source text of a compilation unit, get its post-processed
  --    source text.
  --  Input arguments:
  --    source
  --      The source text of a compilation unit
  --  RETURNS:
  --    Index-by table containing the lines of the post-processed source
  --    text starting from index 1. Newline characters are not removed.
  --    Each line in the post-processed source text is mapped to a row
  --    in the index-by table. In the post-processed source, unselected
  --    text will have blank lines.
  --  Exceptions:
  --    ORA-24236: source text is empty.
  --    ORA-24241: source text is wrapped.
  --    ORA-06502: PL/SQL: numeric or value error: character string buffer
  --               too small. A line is too long ( > 32767 bytes).

  function get_post_processed_source(source varchar2)
    return source_lines_t;

  --  Name:
  --    get_post_processed_source
  --  Description:
  --    Given the source text of a compilation unit, get its post-processed
  --    source text.
  --  Input arguments:
  --    source
  --      Index-by table containing the source text of the compilation unit
  --  RETURNS:
  --    Index-by table containing the lines of the post-processed source
  --    text starting from index 1. Newline characters are not removed.
  --    Each line in the post-processed source text is mapped to a row
  --    in the index-by table. In the post-processed source, unselected
  --    text will have blank lines.
  --  Exceptions:
  --    ORA-24236: source text is empty.
  --    ORA-24241: source text is wrapped.
  --    ORA-06502: PL/SQL: numeric or value error: character string buffer
  --               too small. A line is too long ( > 32767 bytes).

  function get_post_processed_source(source source_lines_t)
    return source_lines_t;

end;
/

create or replace public synonym dbms_preprocessor for sys.dbms_preprocessor
/

grant execute on dbms_preprocessor to public
/
