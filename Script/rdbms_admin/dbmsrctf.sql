rem 
rem $Header: rdbms/admin/dbmsrctf.sql /main/8 2010/02/15 09:51:40 juyuan Exp $ 
rem 
Rem    NAME
Rem
Rem      dbmsrctf.sql - replication table comparison package spec.
Rem
Rem    NOTES
Rem
Rem      The procedural option is needed to use this facility.
Rem
Rem      This package is installed by sys (connect internal).
Rem
Rem      The repcat tables are defined in catrep.sql and owned by system.
Rem
Rem    DEPENDENCIES
Rem
Rem      The object generator (dbmsobjg) and the replication procedure/trigger
Rem      generator (dbmsgen) must be previously loaded.
Rem
Rem      Uses dynamic SQL (dbmssql.sql) heavily.
Rem
Rem    SECURITY
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     juyuan     01/27/10  - lrg-4098397: change dbms_rectifier_diff to
Rem                            invoker's right package
Rem     nlewis     01/15/98 -  remove mlslabel comment
Rem     liwong     11/18/96 -  Added removal of synonym dbms_rectifier_diff
Rem     asurpur    04/09/96 -  Dictionary Protection Implementation
Rem     boki       05/01/95 -  change specification
Rem     boki       03/30/95 -  add more specification to differences()
Rem     boki       02/10/95 -  add new exception for factoring
Rem     boki       02/06/95 -  Creation
Rem

Rem Drop synonym created in dbms_rectifier_diff in catreps.sql
DROP SYNONYM dbms_rectifier_diff
/

---------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_rectifier_diff AUTHID CURRENT_USER AS

  -------------
  -- TYPE DEFINITIONS
  --

  -------------
  -- EXCEPTIONS
  --

  nosuchsite EXCEPTION;
    PRAGMA exception_init(nosuchsite, -23365);
    nosuchsite_num NUMBER := -23365;

  badnumber EXCEPTION;
    PRAGMA exception_Init(badnumber, -23366);
    badnumber_num NUMBER := -23366;

  missingprimarykey EXCEPTION;
    PRAGMA exception_Init(missingprimarykey, -23367);
    missingprimarykey_num NUMBER := -23367;

  badname EXCEPTION;
    PRAGMA exception_Init(badname, -23368);
    badname_num NUMBER := -23368;

  cannotbenull EXCEPTION;
    PRAGMA exception_Init(cannotbenull, -23369);
    cannotbenull_num NUMBER := -23369;

  notshapeequivalent EXCEPTION;
    PRAGMA exception_Init(notshapeequivalent, -23370);
    notshapeequivalent_num NUMBER := -23370;

  unknowncolumn EXCEPTION;
    PRAGMA exception_Init(unknowncolumn, -23371);
    unknowncolumn_num NUMBER := -23371;

  unsupportedtype EXCEPTION;
    PRAGMA exception_Init(unsupportedtype, -23372);
    unsupportedtype_num NUMBER := -23372;

  badmrname EXCEPTION;
    PRAGMA exception_Init(badmrname, -23377);
    badmrname_num NUMBER := -23377;

  -------------
  -- PROCEDURES
  --

  -- Requires: The caller must have already created the tables named
  --   "missing_rows_oname1" and "missing_rows_oname2" in schema
  --   "missing_rows_sname" at the site "missing_rows_site" with the
  --   correct shapes. There must be no white space before or after
  --   commas in "column_list."
  -- Effects:  This routine compares the fragment defined by "column_list"
  --   and the "where_clause" of the table named "sname1.oname1" (truth) at site
  --   "reference_site" with the fragment defined by "column_list" and
  --   "where_clause" of the table  named "sname2.oname2" at site "comparison_site."
  --   It determines what is different and records this information in the
  --   pair of tables named "missing_rows_oname1" and "missing_rows_oname2"
  --   in schema "missing_rows_sname." If the fragments are exactly equivalent,
  --   then the tables "missing_rows_oname1" and "missing_rows_oname2" are
  --   unchanged.  If the fragments are not exactly equivalent, then those
  --   rows in "sname1.oname1" at the "reference_site" that are missing
  --   from "sname2.oname2" at the "comparison_site," and the rows in the
  --   table at "comparision_site" that are missing from the table at 
  --   "reference_site" are inserted into the tables "missing_rows_oname1" and 
  --   "missing_rows_oname2." The routine commits those rows that have been
  --   inserted into the pair of missing rows tables whenever "commit_row"
  --   number of rows have been inserted. Raises exception badnumber if
  --   "commit_rows" is less than 1. If "sname," "oname," "missing_rows_sname,"
  --   or "missing_rows_oname" is NULL or `' (empty string), raise exception 
  --   badname.  Raise badmrname if arguments "missing_rows_oname1" and "oname1"
  --   have the same name; the "oname1" truth table cannot be used as one
  --   of the missing rows tables. Raises exception unknowncolumn if any
  --   column specified in  "column_list" is missing from table 
  --   "sname1.oname1." or from table "sname2.oname2." 
  --   Raises exception missingobject if tables named "oname1," 
  --   "oname2," "missing_rows_oname1," or "missing_rows_oname2" do not exist.
  --   "max_missing" is an integer that refers to the maximum number of rows
  --   that should be inserted into the "missing_rows_oname" table.  If more 
  --   than "max_missing" number of rows is missing, that many rows will be
  --   inserted into the "missing_rows_oname," and  the routine then returns
  --   normally without determining whether more rows are missing; this
  --   argument is useful in the cases that the fragments are so different that
  --   the missing rows table will have too many entries and there's no
  --   point in continuing. Raises exception badnumber if "max_missing" is
  --   less than 1, or NULL.  Raises exception cannotbenull if "max_missing"
  --   is NULL.  Raises exception unsupportedtype if any column data type of
  --   any column in in "column_list" is a long or long raw.
  --       The "where_clause" is used as a predicate to restrict the query
  --   space; if `' (the empty string), then every row is selected, else,
  --   every row that satisfies the predicate is selected. Raises exception
  --   notshapeequivalent if "sname1.oname1" at site "reference_site" is not 
  --   shape equivalent to "sname2.oname2" at site "comparison_site" with
  --   respect to the specified columns in "column_list." 
  --      Duplicate rows are treated as one row under set semantics, and
  --   thus, if they are missing, will appear exactly once in "missing_rows_oname1"
  --   and "missing_rows_oname2" tables. (However, when the table at the
  --   comparison site is rectified, duplicate rows are handled correctly.)
  --      Routine raises exception nosuchsite if the "reference_site,"
  --   "comparison_site," or "missing_rows_site" does not name a site.
  --   Raises exception dbsm_repcat.commfailure if the remote site is inaccessible.
  --   Raises exception missingprimarykey if "column_list" does not contain
  --   the table's primary keys (if multiple columns constitute the primary
  --   key, then all columns must be specified in "column_list").
  --      Two successive invocations of this routine on the same pair of tables
  --   is equivalent to one invocation (without cleaning out the missing rows
  --   tables manually); the missing rows tables remain unchanged.
  --      If the replication option is not installed, then raise exception
  --   dbms_repcat.norepoption.
  --      The table "missing_rows_oname1" must have only the column names given in 
  --   "column_list" and the associated data types, which defines a fragment. The
  --   table "missing_rows_oname2" must have three columns with the associated
  --   datatypes: "present" (type varchar2(128))for the name of the site where
  --   the row appeared, "absent" (type varchar2(128)) for the name of the site
  --   where the row does not appear, and "r_id" (type rowid) to hold the rowid
  --   of the corresponding row in "missing_rows_oname1."
  -- 
  --  Arguments:
  --    *sname1: schema name at reference_site; need not be the fully qualified 
  --             canonical name
  --    *oname1: table name at reference_site
  --    *reference_site:   site name; need not be the fully qualified canonical name; 
  --          legal values are `' (empty string) or NULL, which refer to the
  --          site where this routine is invoked, or any other non-empty string.
  --          Defaults to `'.
  --    *sname2: schema name at comparison_site ; need not be the fully qualified 
  --          canonical name
  --    *oname2: table name at comparision_site
  --    *comparison_site: site name; need not be the fully qualified canonical
  --          name;legal values are `' (empty string) or NULL, which refer to
  --          the site where this routine is invoked, or any other non-empty
  --          string. Defaults to `'. 
  --    *where_clause:  meaningful value is either `' (empty string), NULL, or 
  --          non-empty string; empty string or NULL means no where clause
  --          is provided, so every  row is selected; otherwise, for the
  --          non-empty string, every row that satisfies the predicate is
  --          selected. Defaults to `'.
  --    *column_list: comma-separated list of one or more column names that
  --          define a fragment (partition) of table "sname.oname."  Legal
  --          values are `' (empty string), NULL, or comma-separated list.
  --          If `' or NULL, then all column names are used. Defaults to `'.
  --          Note that list must not have any white space before or 
  --          after the separating comma.
  --    *missing_rows_sname: schema name of schema where missing rows table is.
  --    *missing_rows_oname1: name of a table at "missing_rows_site"  that contains 
  --          information about the rows in "sname1.oname2" that are missing from 
  --          "sname2.oname2" at "comparison_site" and the rows at the
  --          "comparison_site" that are missing from the "reference_site." 
  --    *missing_rows_oname2: the name of the table at site "missing_rows_site"
  --          that holds information about whether a missing row is present at
  --          a site and absent from another site and links this table with
  --          "missing_rows_oname1" to identify the actual missing row.
  --    *missing_rows_site:  The site where the "missing_rows_oname1" and 
  --          "missing_rows_oname2" tables are located; legal values
  --          are `' (empty string) or NULL, which refers to the site where
  --          this routine is invoked, or legal site name. Defaults to `'.
  --    *max_missing: a number that refers to the maximum number of rows inserted 
  --         into the "missing_rows_tab" table; the routine returns normally
  --         when that limit is exceeded.  Legal  integer values must be
  --         greater than or equal to 1. Value cannot be NULL.
  --    *commit_rows:  commit the rows inserted into "missing_rows_tab" every 
  --         "commit_row" number of rows.  Legal values are `' (empty string),
  --         NULL, or an integer value that must start at 1. `' or NULL means
  --         that all rows are inserted before committing. Defaults to 500.
  --
  --  Exceptions:
  --      nosuchsite 
  --      badnumber
  --      missingprimarykey 
  --      badname
  --      cannotbenull
  --      notshapeequivalent
  --      unknowncolumn
  --      unsupportedtype
  --      badmrname
  --      dbms_repcat.commfailure 
  --      dbms_repcat.missingobject
  --      dbms_repcat.norepoption

  PROCEDURE differences	         (sname1	       IN VARCHAR2,
				  oname1	       IN VARCHAR2,
				  reference_site       IN VARCHAR2 := '',
				  sname2	       IN VARCHAR2,
				  oname2	       IN VARCHAR2,
				  comparison_site      IN VARCHAR2 := '',
				  where_clause	       IN VARCHAR2 := '',
				  column_list	       IN VARCHAR2 := '',
				  missing_rows_sname   IN VARCHAR2,
				  missing_rows_oname1  IN VARCHAR2,
				  missing_rows_oname2  IN VARCHAR2,
				  missing_rows_site    IN VARCHAR2 := '',
				  max_missing          IN INTEGER,
				  commit_rows	       IN INTEGER := 500);

  PROCEDURE differences          (sname1	       IN VARCHAR2,
  				  oname1	       IN VARCHAR2,
				  reference_site       IN VARCHAR2 := '',
				  sname2	       IN VARCHAR2,
  				  oname2	       IN VARCHAR2,
				  comparison_site      IN VARCHAR2 := '',
				  where_clause	       IN VARCHAR2 := '',
				  array_columns	       IN dbms_utility.name_array,
				  missing_rows_sname   IN VARCHAR2,
				  missing_rows_oname1  IN VARCHAR2,
				  missing_rows_oname2  IN VARCHAR2,
				  missing_rows_site    IN VARCHAR2 := '',
				  max_missing          IN INTEGER,
				  commit_rows	       IN INTEGER := 500);

  -- Requires:  The caller must have already created the tables named 
  --    "missing_rows_oname1" and "missing_rows_oname2" in schema
  --    "missing_rows_sname" at the site "missing_rows_site" with the
  --    correct shapes. "column_list" must specify the same number and
  --    same names of columns that are in "missing_rows_oname1;" both have 
  --    exactly the same column names. In short, all the same arguments
  --    used in a call to differences(..., column_list, ...) must be
  --    used in this routine to rectify the table at the comparison_site.
  --    The tables "sname1.oname1@reference_site" and "sname2.oname2@comparison_site"
  --    must be the same ones used in a previous invocation of differences().
  --    There must be no white space before or after commas in "column_list."
  -- Effects: This routine uses the information in table "missing_rows_oname1" and 
  --   "missing_rows_oname2" in schema "missing_rows_sname" to rectify table named 
  --   "sname2.oname2" at site "comparison_site."  Rows are deleted from 
  --   "sname2.oname2" at "comparison_site" that are not in "sname1.oname1" at 
  --   "reference_site."  Rows missing from "sname2.oname2" at "comparison_site" are 
  --   inserted. When this routine returns normally, the two tables are exactly
  --   equivalent.  In short, extraneous rows are deleted from the table
  --   "sname2.oname2" at "comparison_site" and missing rows are inserted
  --   into the table. If tables "missing_rows_oname1" and "missing_rows_oname2"
  --   are empty, then this routine has no effect.   Commit every "commit_rows"
  --   number of rows are deleted from "sname2.oname2"; commit every "commit_rows"
  --   number of rows are inserted into "sname2.oname2."
  --      Raises exception nosuchsite if the "reference_site," 
  --   "comparison_site,"  or "missing_rows_site" does not name a site.
  --   Raises exception badnumber if "commit_rows" is
  --   less than 1. Raises exception commfailure if the remote site 
  --   inaccessible. If "sname1," "oname2," "sname2," "oname2," "missing_rows_oname1," 
  --   or "missing_rows_oname2" is NULL or `' (empty string), raise exception badname. 
  --   Raise badmrname if "missing_rows_oname1" and "oname1"
  --   have the same name; the "oname1" truth table cannot be used as one
  --   of the missing rows tables.
  --   Raises exception missingobject if tables named "oname1," "oname2," 
  --   "missing_rows_oname1" or "missing_rows_oname2" do not exist.
  --      If table "sname1.oname1" (truth) at the reference site contains duplicate
  --   rows, those rows are treated under set semantics as one single row
  --   and will appear in the "missing_rows_oname1" and "missing_rows_oname2"
  --   exactly once.  When the table at the comparison site is rectified,
  --   the duplicate rows are in fact inserted into the table at the comparison_site.
  --   If there are duplicate rows at the table at the 
  --   comparison site, then all rows will be deleted. If replication is
  --   turned on, this routine will remember that state, turn replication
  --   off to allow rectifying to proceed, and then reinstate the original state.
  --      The tables  "missing_rows_oname1" and "missing_rows_oname2" cannot contain
  --   differences for different pairs; the routine must only be used to
  --   rectify a pair of table whose differences are in the associated
  --   missing rows tables.  The table "missing_rows_oname1"
  --   must have only the column names given in "column_list" and the
  --   associated data types, which defines a fragment. The table 
  --   "missing_rows_oname2" must have three columns with the associated datatypes: 
  --   "present" (type varchar2(128))for the name of the site where the row appeared, 
  --   "absent" (type varchar2(128)) for the name of the site where the row
  --   does not appear, and "r_id" (type rowid) to hold the rowid of the
  --   corresponding row in "missing_rows_oname1."
  --      If the replication option is not installed, then raise exception
  --   dbms_repcat.norepoption.
  -- 
  -- Arguments: 
  --    *sname1: name of schema at "reference_site;" need not be the
  --             fully qualified canonical name.
  --    *oname1: name of table at "reference_site"
  --    *reference_site:   site name; need not be the fully qualified
  --             canonical name;  legal values are `' (empty string) or
  --             NULL, which refer to the site where this routine is invoked,
  --             or any other non-empty string. Defaults to `'.
  --    *sname2: schema name at "comparison_site;" need not be the fully qualified 
  --             canonical name
  --    *oname2: name of table at "comparison_site"
  --    *comparison_site:  site name; need not be the fully qualified canonical
  --             name.  Legal values are `' (empty string) or NULL, which refer
  --             to the site where this routine is invoked, or any other
  --             non-empty string. Defaults to `'.
  --    *column_list: comma-separated list of one or more column names that
  --             define a fragment (partition) of table "sname.oname."  Legal
  --             values are `' (empty string), NULL, or comma-separated list.
  --             If `' or NULL, then all column names are used. Defaults to `'.
  --             Note that list must not have any white space before or 
  --             after the separating comma.
  --    *missing_rows_sname: schema name of schema where missing rows table
  --             is located.
  --    *missing_rows_oname1: name of a table at "missing_rows_site" that
  --             contains information about the rows in "sname1.oname2" that
  --             are missing from "sname2.oname2" at "comparison_site" and
  --             the rows at the "comparison_site" that are missing from
  --             the "reference_site." 
  --    *missing_rows_oname2: the name of the table at site "missing_rows_site"
  --             that holds information about whether a missing row is present
  --             at a site and absent from another site and links this table
  --             with "missing_rows_oname1" to identify the actual missing row.
  --    *missing_rows_site:  The site where the "missing_rows_oname1" and
  --             "missing_rows_oname2" tables are
  --             located; legal values are `' (empty string) or NULL, which
  --             refers to the site where this routine is invoked, or legal
  --             site name. Defaults to `'.
  --    *commit_rows:  commit the rows deleted from "sname2.oname2" every
  --             "commit_rows" number of rows. Similarly, commit the rows
  --             inserted intot "sname.oname2" "commit_rows" number of rows.
  --             Legal values are `' (empty string), NULL, or an integer value that must
  --             start at 1. `' or NULL means that all rows are deleted or inserted
  --             before committing. Defaults to 500.
  --
  -- Exceptions:
  --    nosuchsite 
  --    dbms_repcat.commfailure
  --    badnumber
  --    badname
  --    dbms_repcat.missingobject
  --    dbms_repcat.norepoption

  PROCEDURE rectify          (	sname1		       IN VARCHAR2,
				oname1		       IN VARCHAR2,
				reference_site         IN VARCHAR2 := '',
				sname2		       IN VARCHAR2,
				oname2		       IN VARCHAR2,
				comparison_site        IN VARCHAR2 := '',
			        column_list            IN VARCHAR2 := '',
				missing_rows_sname     IN VARCHAR2,
				missing_rows_oname1    IN VARCHAR2,
				missing_rows_oname2    IN VARCHAR2,
				missing_rows_site      IN VARCHAR2 := '',
				commit_rows	       IN INTEGER := 500);

  PROCEDURE rectify          (	sname1		       IN VARCHAR2,
				oname1		       IN VARCHAR2,
				reference_site         IN VARCHAR2 := '',
				sname2		       IN VARCHAR2,
				oname2		       IN VARCHAR2,
				comparison_site        IN VARCHAR2 := '',
			        array_columns          IN dbms_utility.name_array,
				missing_rows_sname     IN VARCHAR2,
				missing_rows_oname1    IN VARCHAR2,
				missing_rows_oname2    IN VARCHAR2,
				missing_rows_site      IN VARCHAR2 := '',
				commit_rows	       IN INTEGER := 500);


  PROCEDURE turn_replication_off;

  PROCEDURE turn_replication_on;

end;
/
grant execute on dbms_rectifier_diff to execute_catalog_role
/


