Rem
Rem $Header: rdbms/admin/dbmsrcad.sql /main/9 2010/02/19 19:32:38 achaudhr Exp $
Rem
Rem dbmsrcad.sql
Rem
Rem Copyright (c) 2005, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsrcad.sql - Result Cache ADministration
Rem
Rem    DESCRIPTION
Rem      A PL/SQL interface to manage the Result Cache.
Rem
Rem    NOTES
Rem      Use this package in conjuction with the relevant V$RESULT_CACHE_* views
Rem      (that show the contents and statistics of the Result Cache).
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achaudhr    02/04/10 - Add STATUS_CORR status
Rem    achaudhr    10/22/08 - Add API
Rem    achaudhr    07/23/08 - Flush: Optional global parameter
Rem    tbingol     06/18/07 - Rename open/close to enable/disable
Rem    achaudhr    05/10/07 - Change varchar to varchar2
Rem    kmuthukk    04/17/07 - add API for cache bypass
Rem    achaudhr    03/14/07 - Add (default) argument detailed to Memory_Report
Rem    achaudhr    02/02/07 - Add Memory_Report
Rem    achaudhr    09/28/05 - Result_Cache: Created
Rem


CREATE OR REPLACE PACKAGE DBMS_RESULT_CACHE as

  /**
   * NAME:
   *   Status
   * DESCRIPTION:
   *   Checks the status of the Result Cache.
   * PARAMETERS:
   *   None.
   * RETURNS:
   *   One of the following values.
   *     STATUS_DISA: Cache is NOT available. 
   *     STATUS_ENAB: Cache is available.
   *     STATUS_BYPS: Cache has been temporarily made unavailable.
   *     STATUS_SYNC: Cache is available, but is synchronizing with RAC nodes.
   *     STATUS_CORR: Cache is corrupt and thus unavailable.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  

  STATUS_DISA CONSTANT VARCHAR2(10) := 'DISABLED';
  STATUS_ENAB CONSTANT VARCHAR2(10) := 'ENABLED';
  STATUS_BYPS CONSTANT VARCHAR2(10) := 'BYPASS';
  STATUS_SYNC CONSTANT VARCHAR2(10) := 'SYNC';
  STATUS_CORR CONSTANT VARCHAR2(10) := 'CORRUPT';

  FUNCTION Status RETURN VARCHAR2;

  /**
   * NAME:
   *   Flush
   * DESCRIPTION:
   *   Attempts to remove all the objects from the Result Cache, and depending
   *   on the arguments retains/releases the memory and retains/clears the
   *   statistics.
   * PARAMETERS:
   *   retainMem - TRUE            => retains the free memory in the cache
   *               FALSE (default) => releases the free memory to the system
   *   retainSta - TRUE            => retains the existing cache statistics
   *               FALSE (default) => clears the existing cache statistics
   *   global    - TRUE            => flushes all caches in the RAC cluster
   *               FALSE (default) => flushes only the local instance cache
   * RETURNS:
   *   TRUE iff was successful in removing ALL the objects.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   Objects that are under an active scan are not removed. 
   */  
  FUNCTION  Flush(retainMem IN BOOLEAN DEFAULT FALSE,
                  retainSta IN BOOLEAN DEFAULT FALSE,
                  global    IN BOOLEAN DEFAULT FALSE) RETURN BOOLEAN;
  PROCEDURE Flush(retainMem IN BOOLEAN DEFAULT FALSE,
                  retainSta IN BOOLEAN DEFAULT FALSE,
                  global    IN BOOLEAN DEFAULT FALSE);

  /**
   * NAME:
   *   Memory_Report
   * DESCRIPTION:
   *   Produces the memory usage report for the Result Cache.
   * PARAMETERS:
   *   detailed - TRUE            => produces a more detailed report
   *              FALSE (default) => produces the standard report
   * RETURNS:
   *   Nothing
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   This procedure uses the DBMS_OUTPUT package; the report requires 
   *   "serveroutput" to be on in SQL*Plus.
   */  
  PROCEDURE Memory_Report(detailed IN BOOLEAN DEFAULT FALSE);


  /**
   * NAME:
   *   Delete_Dependency
   * DESCRIPTION:
   *   Deletes the specified dependency object from the Result Cache, while
   *   invalidating all results that used that dependency object.
   * PARAMETERS [Overload 0]:
   *   owner     - schema name
   *   name      - object name
   * PARAMETERS [Overload 1]:
   *   object_id - dictionary object number 
   * RETURNS:
   *   The number of objects that were invalidated.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  
  FUNCTION  Delete_Dependency(owner IN VARCHAR2, name IN VARCHAR2)RETURN NUMBER;
  PROCEDURE Delete_Dependency(owner IN VARCHAR2, name IN VARCHAR2);

  FUNCTION  Delete_Dependency(object_id IN NATURALN) RETURN NUMBER;
  PROCEDURE Delete_Dependency(object_id IN NATURALN);

  /**
   * NAME:
   *   Invalidate
   * DESCRIPTION:
   *   Invaidates all the result-set objects that dependent upon the specified 
   *   dependency object.
   * PARAMETERS [Overload 0]:
   *   owner     - schema name
   *   name      - object name
   * PARAMETERS [Overload 1]:
   *   object_id - dictionary object number 
   * RETURNS:
   *   The number of objects that were invalidated.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  
  FUNCTION  Invalidate(owner IN VARCHAR2, name IN VARCHAR2) RETURN NUMBER;
  PROCEDURE Invalidate(owner IN VARCHAR2, name IN VARCHAR2);

  FUNCTION  Invalidate(object_id IN NATURALN) RETURN NUMBER;
  PROCEDURE Invalidate(object_id IN NATURALN);

  /**
   * NAME:
   *   Invalidate_Object
   * DESCRIPTION:
   *   Invaidates the specified result-set object(s).
   * PARAMETERS [Overload 0]:
   *   id       - the address of the cache object in the Result Cache
   * PARAMETERS [Overload 1]:
   *   cache_id - the cache-id
   * RETURNS:
   *   The number of object that were invalidated.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  
  FUNCTION  Invalidate_Object(id IN NATURALN) RETURN NUMBER;
  PROCEDURE Invalidate_Object(id IN NATURALN);

  FUNCTION  Invalidate_Object(cache_id IN VARCHAR2) RETURN NUMBER;
  PROCEDURE Invalidate_Object(cache_id IN VARCHAR2);


  /**
   * NAME
   *   Bypass
   * DESCRIPTION
   *  Can be used to set the bypass mode for the Result Cache.
   *   o When bypass mode is turned on, it implies that cached results are
   *     no longer used and that no new results are saved in the cache.
   *   o When bypass mode is turned off, the cache resumes normal operation.
   * PARAMETERS
   *   bypass_mode - TRUE            => Result Cache usage is bypassed.
   *                 FALSE           => Result Cache usage is turned on.
   *   session     - TRUE            => Applies to current session.
   *                 FALSE (default) => Applies to all sessions.
   * RETURNS
   *  None.
   * EXCEPTIONS
   *  None.
   * NOTES
   *  This operation is database instance specific.
   *
   * USAGE SCENARIO(S):
   *
   *  (1) Hot Patching PL/SQL Code:
   *
   *   This operation can be used when there is a need to hot patch PL/SQL
   *   code in a running system. If a code-patch is applied to a PL/SQL module
   *   on which a result cached function directly or transitively depends,
   *   then the cached results  associated with the result cache function are
   *   not automatically flushed (if the instance is not restarted/bounced).
   *   This must be manually achieved.
   *   To ensure correctness during the patching process follow these steps:
   *
   *   a) Place the result cache in bypass mode, and flush existing results:
   *
   *         begin
   *           DBMS_RESULT_CACHE.Bypass(TRUE);
   *           DBMS_RESULT_CACHE.Flush;
   *         end;
   *         /
   *        This step must be performed on each instance (if in a RAC env).
   *   b) Apply the PL/SQL code patches.
   *   c) Resume use of the result cache, by turning off the cache bypass mode.
   *
   *        begin
   *          DBMS_RESULT_CACHE.Bypass(FALSE);
   *        end;
   *        /
   *      This step must be performed on each instance (if in a RAC env).
   *
   * (2) Other usage scenarios might be for debugging,
   *     diagnostic purposes.
   */
  PROCEDURE Bypass(bypass_mode IN BOOLEAN, 
                   session     IN BOOLEAN DEFAULT FALSE);

END DBMS_RESULT_CACHE;
/
show errors;

create or replace public synonym DBMS_RESULT_CACHE for SYS.DBMS_RESULT_CACHE;
grant execute on DBMS_RESULT_CACHE to DBA;


CREATE OR REPLACE PACKAGE DBMS_RESULT_CACHE_API as

  /**
   * NAME:
   *   Get
   * DESCRIPTION:
   *   Finds a given object in the cache or (optionally) creates one if one
   *   is not found.
   * PARAMETERS 
   *   name      - the key of the value to fetch
   *   value     - the value (or object) corresponding to the key
   *   isPublic  - 1(TRUE)          => result is public available all schemas 
   *               0(FALSE) DEFAULT => result is private to creator's schema
   *   noCreate  - 1(TRUE)          => does not create a new object
   *               0(FALSE) DEFAULT => creates a new object when one isn't found
   *   noFetch   - 1(TRUE)          => does not return the value 
   *               0(FALSE) DEFAULT => returns the value
   * RETURNS:
   *    0 => Failed to find/create.
   *    1 => Found the requested object.
   *    2 => Created an (empty) new object with the given key.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  
  FUNCTION Get(key      IN         VARCHAR2, 
               value    OUT NOCOPY RAW,
               isPublic IN         NUMBER DEFAULT 0,
               noCreate IN         NUMBER DEFAULT 0,
               noFetch  IN         NUMBER DEFAULT 0) RETURN NUMBER;
  pragma interface(C, Get);

  FUNCTION GetC(key      IN         VARCHAR2, 
                value    OUT NOCOPY VARCHAR2,
                isPublic IN         NUMBER DEFAULT 0,
                noCreate IN         NUMBER DEFAULT 0,
                noFetch  IN         NUMBER DEFAULT 0) RETURN NUMBER;
  pragma interface(C, GetC);

  /**
   * NAME:
   *   Set
   * DESCRIPTION:
   *   Stores the value with the key specified with the last
   *   call to Find (which had created an empty new object).
   * PARAMETERS 
   *   value   - the value (or object) to be stored
   *   discard - 1(TRUE)          => invalidates the key/value
   *             0(FALSE) DEFAULT => publishes the key/value
   * RETURNS:
   *   0      => Result was NOT published.
   *   Others => Result was published.
   * EXCEPTIONS:
   *   None.
   * NOTES:
   *   None.
   */  
  FUNCTION Set(value   IN  RAW, 
               discard IN  NUMBER DEFAULT 0) RETURN NUMBER;
  pragma interface(C, Set);

  FUNCTION SetC(value   IN  VARCHAR2, 
                discard IN  NUMBER DEFAULT 0) RETURN NUMBER;
  pragma interface(C, SetC);

                   

END DBMS_RESULT_CACHE_API;
/
show errors;

create or replace public synonym DBMS_RESULT_CACHE_API for SYS.DBMS_RESULT_CACHE_API;
grant execute on DBMS_RESULT_CACHE_API to PUBLIC;

