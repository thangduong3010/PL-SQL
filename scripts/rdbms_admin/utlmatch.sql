Rem
Rem $Header: utlmatch.sql 28-may-2004.12:27:31 rdecker Exp $
Rem
Rem utlmatch.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utlmatch.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rdecker     05/28/04 - rdecker_utl_match
Rem    rdecker     03/02/04 - Created
Rem

CREATE OR REPLACE PACKAGE utl_match IS
   FUNCTION edit_distance(s1 IN VARCHAR2, s2 IN VARCHAR2)
                          RETURN pls_integer;
   PRAGMA interface(c, edit_distance);
   
   FUNCTION jaro_winkler(s1 IN VARCHAR2, s2 IN VARCHAR2)
                         RETURN binary_double;
   PRAGMA interface(c, jaro_winkler);
   
   FUNCTION edit_distance_similarity(s1 IN VARCHAR2, s2 IN VARCHAR2)
                                     RETURN pls_integer;
   PRAGMA interface(c, edit_distance_similarity);

   FUNCTION jaro_winkler_similarity(s1 IN VARCHAR2, s2 IN VARCHAR2)
                                    RETURN pls_integer;
   PRAGMA interface(c, jaro_winkler_similarity);

END utl_match;
/
show errors;

GRANT EXECUTE ON utl_match TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_match FOR sys.utl_match;
