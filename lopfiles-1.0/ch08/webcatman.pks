REM $Id$
REM From "Learning Oracle PL/SQL" page 291

REM Spec of package that will fetch data from Library of Congress

REM Supposedly SET SCAN OFF is deprecated, we are supposed to use SET DEFINE OFF
REM instead

SET DEFINE OFF
CREATE OR REPLACE PACKAGE webcatman
AS
   url_to_init VARCHAR2(2000) := 
      'http://lcweb.loc.gov/cgi-bin/zgate?ACTION=INIT'
      || '&FORM_HOST_PORT=/prod/www/data/z3950/locils.html,z3950.loc.gov,7090';

   url_frag_for_fetch VARCHAR2(2000) :=
      'http://lcweb.loc.gov/cgi-bin/zgate'
      || '?ESNAME=F&ACTION=SEARCH&DBNAME=VOYAGER&MAXRECORDS=1'
      || '&RECSYNTAX=1.2.840.10003.5.10'
      || '&USE_1=7';

   FUNCTION catdata (isbn IN VARCHAR2, retries IN PLS_INTEGER DEFAULT 1)
   RETURN VARCHAR2;
END;
/

SET DEFINE ON

