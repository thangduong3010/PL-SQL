Rem
Rem $Header: rdbms/admin/dbmsredacta.sql /st_rdbms_11.2.0/2 2012/09/11 13:55:06 pknaggs Exp $
Rem
Rem dbmsredacta.sql
Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsredacta.sql - Real-time Application-controlled Data Redaction
Rem                      Adminstrative interface
Rem
Rem    DESCRIPTION
Rem      dbms_redact package for real-time application-controlled data
Rem                            redaction adminstrative interface
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cslink      08/09/12 - LRG #7171823: comment change
Rem    cslink      07/31/12 - Bug #14285251: Add NCLOB full redaction value
Rem    cslink      06/28/12 - Bug #14228310: Re-order add_policy parameters
Rem    msleong     06/06/12 - Bug #14164426: additional aliases
Rem    cslink      06/04/12 - Bug #14151458: API to update radm_fptm$
Rem    cslink      05/30/12 - Bug #14133343: Add API to set policy descriptions
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    msleong     03/21/12 - Bug 13888310: masking aliases
Rem    pknaggs     10/15/11 - 13089377: Use current user, not login user.
Rem    pknaggs     10/03/11 - Add Regular Expression support.
Rem    cslink      09/14/11 - Apply suggested changes from review
Rem    cslink      09/13/11 - Change back numbering on redaction functions.
Rem    cslink      09/08/11 - New file to change radm->redact
Rem    cslink      09/08/11 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_redact AUTHID CURRENT_USER AS

  -- Values for "function_type" parameter of DBMS_REDACT.add_policy 
  -- and DBMS_REDACT.alter_policy API.
  NONE                       CONSTANT   BINARY_INTEGER := 0;
  FULL                       CONSTANT   BINARY_INTEGER := 1;
  PARTIAL                    CONSTANT   BINARY_INTEGER := 2;
  FORMAT_PRESERVING          CONSTANT   BINARY_INTEGER := 3;
  RANDOM                     CONSTANT   BINARY_INTEGER := 4;
  REGEXP                     CONSTANT   BINARY_INTEGER := 5;

  -- Values for "action" parameter of DBMS_REDACT.alter_policy API.
  ADD_COLUMN                 CONSTANT   BINARY_INTEGER := 1;
  DROP_COLUMN                CONSTANT   BINARY_INTEGER := 2;
  MODIFY_EXPRESSION          CONSTANT   BINARY_INTEGER := 3;
  MODIFY_COLUMN              CONSTANT   BINARY_INTEGER := 4;
  SET_POLICY_DESCRIPTION     CONSTANT   BINARY_INTEGER := 5;
  SET_COLUMN_DESCRIPTION     CONSTANT   BINARY_INTEGER := 6;

  -- Preset values for "function_parameters" parameter for use in
  -- partial redaction (function_type := dbms_redact.PARTIAL)
  REDACT_US_SSN_F5           CONSTANT   VARCHAR2(29) := 
    'VVVFVVFVVVV,VVV-VV-VVVV,X,1,5';
  REDACT_US_SSN_L4           CONSTANT   VARCHAR2(29) := 
    'VVVFVVFVVVV,VVV-VV-VVVV,X,6,9';
  REDACT_US_SSN_ENTIRE       CONSTANT   VARCHAR2(29) := 
    'VVVFVVFVVVV,VVV-VV-VVVV,X,1,9';
  REDACT_NUM_US_SSN_F5       CONSTANT   VARCHAR2(5)  := '9,1,5';
  REDACT_NUM_US_SSN_L4       CONSTANT   VARCHAR2(5)  := '9,6,9';
  REDACT_NUM_US_SSN_ENTIRE   CONSTANT   VARCHAR2(5)  := '9,1,9';
  REDACT_ZIP_CODE            CONSTANT   VARCHAR2(17) := 
    'VVVVV,VVVVV,X,1,5';
  REDACT_NUM_ZIP_CODE        CONSTANT   VARCHAR2(5)  := '9,1,5';
  REDACT_CCN16_F12           CONSTANT   VARCHAR2(46) := 
    'VVVVFVVVVFVVVVFVVVV,VVVV-VVVV-VVVV-VVVV,*,1,12';
  REDACT_DATE_MILLENNIUM     CONSTANT   VARCHAR2(9)  :=
    'm1d1y2000';
  REDACT_DATE_EPOCH          CONSTANT   VARCHAR2(9)  :=
    'm1d1y1970';

  -- Preset values for "regexp_pattern" parameter for use in
  -- regular expression redaction (function_type := dbms_redact.REGEXP)
  -- In general, this value determines what to recognize and replace.
  RE_PATTERN_US_SSN          CONSTANT   VARCHAR2(26) := 
    '(\d\d\d)-(\d\d)-(\d\d\d\d)';
  RE_PATTERN_CC_L6_T4        CONSTANT   VARCHAR2(33) := 
    '(\d\d\d\d\d\d)(\d\d\d*)(\d\d\d\d)';
  RE_PATTERN_ANY_DIGIT       CONSTANT   VARCHAR2(2)  := '\d';
  RE_PATTERN_US_PHONE        CONSTANT   VARCHAR2(39) := 
    '(\(\d\d\d\)|\d\d\d)-(\d\d\d)-(\d\d\d\d)';
  RE_PATTERN_EMAIL_ADDRESS   CONSTANT   VARCHAR2(51) := 
    '([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Za-z]{2,4})';
  RE_PATTERN_IP_ADDRESS      CONSTANT   VARCHAR2(36) :=
    '(\d{1,3}\.\d{1,3}\.\d{1,3})\.\d{1,3}'; 

  -- Preset values for "regexp_replace_string" parameter for use in
  -- regular expression redaction (function_type := dbms_redact.REGEXP)
  -- In general, this value determines how to redact the element found.
  --
  -- Common pairings might include the following:
  --
  --  RE_PATTERN_ANY_DIGIT		RE_REDACT_WITH_SINGLE_X
  --    Replaces any digit found with the 'X' character.
  --  RE_PATTERN_ANY_DIGIT		RE_REDACT_WITH_SINGLE_1
  --    Replaces any digit found with the '1' character.
  --  RE_PATTERN_CC_L6_T4		RE_REDACT_CC_MIDDLE_DIGITS
  --    Finds any credit card which could have 6 leading and
  --    4 trailing digits left as actual data and redacts the 
  --    middle digits.
  --  RE_PATTERN_US_PHONE		RE_REDACT_US_PHONE_L7
  --    Finds any US phone number and redacts the last 7 digits.
  --  RE_PATTERN_EMAIL_ADDRESS          RE_REDACT_EMAIL_NAME
  --    Finds any email address and redacts the email name.
  --  RE_PATTERN_EMAIL_ADDRESS          RE_REDACT_EMAIL_DOMAIN
  --    Finds any email address and redacts the email domain.
  --  RE_PATTERN_EMAIL_ADDRESS          RE_REDACT_EMAIL_ENTIRE
  --    Finds any email address and redacts the entire email.
  --
  RE_REDACT_CC_MIDDLE_DIGITS CONSTANT   VARCHAR2(10) := '\1XXXXXX\3';
  RE_REDACT_WITH_SINGLE_X    CONSTANT   VARCHAR2(1)  := 'X';
  -- We use 1 here because redacting a numeric field with 0 can lead
  -- to ambiguity caused by truncation of leading zeroes.
  RE_REDACT_WITH_SINGLE_1    CONSTANT   VARCHAR2(1)  := '1';
  RE_REDACT_US_PHONE_L7      CONSTANT   VARCHAR2(11) := '\1-XXX-XXXX';
  RE_REDACT_EMAIL_NAME       CONSTANT   VARCHAR2(7)  := 'xxxx@\2';
  RE_REDACT_EMAIL_DOMAIN     CONSTANT   VARCHAR2(12) := 
    '\1@xxxxx.com';
  RE_REDACT_EMAIL_ENTIRE     CONSTANT   VARCHAR2(14) := 
    'xxxx@xxxxx.com';
  RE_REDACT_IP_L3            CONSTANT   VARCHAR2(6)  :=
    '\1.999';

  -- Preset value for "regexp_position" parameter for use in
  -- regular expression redaction (function_type := dbms_redact.REGEXP)
  RE_BEGINNING               CONSTANT   BINARY_INTEGER := 1;

  -- Preset values for "regexp_occurrence" parameter for use in
  -- regular expression redaction (function_type := dbms_redact.REGEXP)
  RE_ALL                     CONSTANT   BINARY_INTEGER := 0;
  RE_FIRST                   CONSTANT   BINARY_INTEGER := 1;

  -- Preset values for "regexp_match_parameter" parameter for use in
  -- regular expression redaction (function_type := dbms_redact.REGEXP)
  -- 
  -- There is one constant for each individual option. Since more than one
  -- option can be specified, specify multiple options with concatenation
  --
  -- For example, to specify case insensitive matching which ignores whitespace,
  -- use regexp_match_parameter => RE_CASE_INSENSITIVE || RE_IGNORE_WHITESPACE
  RE_CASE_SENSITIVE          CONSTANT   VARCHAR2(1)  := 'c';
  RE_CASE_INSENSITIVE        CONSTANT   VARCHAR2(1)  := 'i';
  RE_MULTIPLE_LINES          CONSTANT   VARCHAR2(1)  := 'm';
  RE_NEWLINE_WILDCARD        CONSTANT   VARCHAR2(1)  := 'n';
  RE_IGNORE_WHITESPACE       CONSTANT   VARCHAR2(1)  := 'x';

  PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO_WITH_COMMIT);

  -- ------------------------------------------------------------------------
  -- add_policy - define a Data Redaction policy on an object (table/view) 
  --
  -- INPUT PARAMETERS
  --   object_schema          - schema owning the object, current user if NULL
  --   object_name            - name of object
  --   policy_name            - name of policy to be added
  --   policy_description     - policy description to set (optional)
  --   column_name            - name of the column (optional)
  --   column_description     - column description to set (optional)
  --   function_type          - the type of redaction function to use
  --   function_parameters    - parameters to the redaction function
  --   expression             - the Policy Expression for the object
  --   enable                 - TRUE: policy is enabled when defined,
  --                            FALSE: policy is disabled when defined.
  --                            (default: TRUE)
  --
  -- The following parameters are for redacting using a Regular Expression,
  -- and must be specified only if the function_type is dbms_redact.REGEXP,
  -- otherwise they must be omitted:
  --
  --   regexp_pattern         - Regular Expression pattern (up to 512 bytes).
  --   regexp_replace_string  - Replacement string (up to 4000 characters in
  --                            length) with up to 500 back-references to
  --                            subexpressions in the form \n, (where n is
  --                            a number from 1 to 9).
  --   regexp_position        - integer counting from 1, giving the position
  --                            where the search should begin.
  --   regexp_occurrence      - Either 0 (to replace all occurrences of the
  --                            match), or a positive integer n (to replace
  --                            the nth occurrence of the match).
  --   regexp_match_parameter - to change the default matching behavior,
  --                            possible values are a combination of 'i',
  --                            'c', 'n', 'm', 'x', see the documentation
  --                            of the match_parameter in the REGEXP_REPLACE
  --                            section of the SQL reference manual.

  PROCEDURE add_policy
    (object_schema          IN VARCHAR2       := NULL
    ,object_name            IN VARCHAR2
    ,policy_name            IN VARCHAR2
    ,policy_description     IN VARCHAR2       := NULL
    ,column_name            IN VARCHAR2       := NULL
    ,column_description     IN VARCHAR2       := NULL
    ,function_type          IN BINARY_INTEGER := dbms_redact.FULL
    ,function_parameters    IN VARCHAR2       := NULL
    ,expression             IN VARCHAR2
    ,enable                 IN BOOLEAN        := TRUE
    ,regexp_pattern         IN VARCHAR2       := NULL
    ,regexp_replace_string  IN VARCHAR2       := NULL
    ,regexp_position        IN BINARY_INTEGER := 1
    ,regexp_occurrence      IN BINARY_INTEGER := 0
    ,regexp_match_parameter IN VARCHAR2       := NULL
  );

  -- ------------------------------------------------------------------------
  -- drop_policy - drop a Data Redaction policy
  --
  -- INPUT PARAMETERS
  --   object_schema      - schema owning the object, current user if NULL
  --   object_name        - name of object
  --   policy_name        - name of policy to be dropped

  PROCEDURE drop_policy
    (object_schema          IN VARCHAR2       := NULL
    ,object_name            IN VARCHAR2
    ,policy_name            IN VARCHAR2
    );

  -- ------------------------------------------------------------------------
  -- alter_policy -  alter a Data Redaction policy for an object (table/view)
  --
  -- INPUT PARAMETERS
  --   object_schema          - schema owning the object, current user if NULL
  --   object_name            - name of object
  --   policy_name            - name of policy to be altered
  --   action                 - action to take 
  --                            (default: add redaction on a column)
  --   column_name            - name of the column
  --   function_type          - the type of redaction function to use
  --   function_parameters    - parameters to the redaction function
  --   expression             - the Policy Expression for the object
  --
  -- The following parameters are for redacting using a Regular Expression,
  -- and must be specified only if the function_type is dbms_redact.REGEXP,
  -- otherwise they must be omitted:
  --
  --   regexp_pattern         - Regular Expression pattern (up to 512 bytes).
  --   regexp_replace_string  - Replacement string (up to 4000 characters in
  --                            length) with up to 500 back-references to
  --                            subexpressions in the form \n, (where n is
  --                            a number from 1 to 9).
  --   regexp_position        - integer counting from 1, giving the position
  --                            where the search should begin.
  --   regexp_occurrence      - Either 0 (to replace all occurrences of the
  --                            match), or a positive integer n (to replace
  --                            the nth occurrence of the match).
  --   regexp_match_parameter - to change the default matching behavior,
  --                            possible values are a combination of 'i',
  --                            'c', 'n', 'm', 'x', see the documentation
  --                            of the match_parameter in the REGEXP_REPLACE
  --                            section of the SQL reference manual.
  --
  -- The following parameter only needs to be set if the action is
  -- dbms_redact.SET_POLICY_DESCRIPTION otherwise it may be omitted:
  --   policy_description     - Policy description to set
  --
  -- The following parameter only needs to be set if the action is
  -- dbms_redact.SET_COLUMN_DESCRIPTION otherwise it may be omitted:
  --   column_description     - Column description to set

  PROCEDURE alter_policy
    (object_schema          IN VARCHAR2       := NULL
    ,object_name            IN VARCHAR2
    ,policy_name            IN VARCHAR2
    ,action                 IN BINARY_INTEGER := dbms_redact.ADD_COLUMN
    ,column_name            IN VARCHAR2       := NULL
    ,function_type          IN BINARY_INTEGER := dbms_redact.FULL
    ,function_parameters    IN VARCHAR2       := NULL
    ,expression             IN VARCHAR2       := NULL
    ,regexp_pattern         IN VARCHAR2       := NULL
    ,regexp_replace_string  IN VARCHAR2       := NULL
    ,regexp_position        IN BINARY_INTEGER := 1
    ,regexp_occurrence      IN BINARY_INTEGER := 0
    ,regexp_match_parameter IN VARCHAR2       := NULL
    ,policy_description     IN VARCHAR2       := NULL
    ,column_description     IN VARCHAR2       := NULL
  );

  -- ------------------------------------------------------------------------
  -- disable_policy - disable a Data Redaction policy
  --
  -- INPUT PARAMETERS
  --   object_schema      - schema owning the object, current user if NULL
  --   object_name        - name of object
  --   policy_name        - name of policy to be disabled

  PROCEDURE disable_policy
    (object_schema          IN VARCHAR2       := NULL
    ,object_name            IN VARCHAR2
    ,policy_name            IN VARCHAR2
    );

  -- ------------------------------------------------------------------------
  -- enable_policy - enable a Data Redaction policy
  --
  -- INPUT PARAMETERS
  --   object_schema      - schema owning the object, current user if NULL
  --   object_name        - name of object
  --   policy_name        - name of policy to be enabled

  PROCEDURE enable_policy
    (object_schema          IN VARCHAR2       := NULL
    ,object_name            IN VARCHAR2
    ,policy_name            IN VARCHAR2
    );

  -- ------------------------------------------------------------------------
  -- fpm_mask - apply Format-preserving Data Redaction on the input
  --
  -- INPUT PARAMETERS
  --   input_format      - input format
  --   output_format     - output format
  --   input_value       - actual value to apply the mask to
  --   masking_key       - the FPM key, or the string 'wallet' indicating
  --                       that the key is available in the wallet.

  PROCEDURE fpm_mask
    (input_format           IN VARCHAR2
    ,output_format          IN VARCHAR2
    ,input_value            IN VARCHAR2
    ,masking_key            IN VARCHAR2
    );

  -- ------------------------------------------------------------------------
  -- fpm_unmask - remove Format-preserving Data Redaction from the input
  --
  -- INPUT PARAMETERS
  --   input_format      - input format
  --   output_format     - output format
  --   input_value       - value to unmask
  --   masking_key       - the FPM key, or the string 'wallet' indicating
  --                       that the key is available in the wallet.

  PROCEDURE fpm_unmask
    (input_format           IN VARCHAR2
    ,output_format          IN VARCHAR2
    ,input_value            IN VARCHAR2
    ,masking_key            IN VARCHAR2
    );

  -- ------------------------------------------------------------------------
  -- update_full_redaction_values - Update replacements for full redaction
  --
  -- INPUT PARAMETERS
  --   number_val     - value for NUMBER columns
  --   binfloat_val   - value for BINARY_FLOAT columns
  --   bindouble_val  - value for BINARY_DOUBLE columns
  --   char_val       - value for CHAR columns
  --   varchar_val    - value for VARCHAR2 columns
  --   nchar_val      - value for NCHAR columns
  --   nvarchar_val   - value for NVARCHAR2 columns
  --   date_val       - value for DATE columns
  --   ts_val         - value for TIMESTAMP columns
  --   tswtz_val      - value for TIMESTAMP WITH TIME ZONE columns
  --
  -- Note that in 11.2.0.4, the parameters blob_val, clob_val and nclob_val
  -- to the update_full_redaction_values call are not supported,
  -- because support for LOB parameter replication is not 
  -- available until 12.1.  Instead, the update of the FULL redaction
  -- values can be performed using SQL as follows:
  --
  -- To update the FULL redaction value for the BLOB datatype:
  --   update radm_fptm_lob$ set blobcol=blob_val where fpver=1;
  --
  -- To update the FULL redaction value for the CLOB datatype:
  --   update radm_fptm_lob$ set clobcol=clob_val where fpver=1;
  --
  -- To update the FULL redaction value for the NCLOB datatype:
  --   update radm_fptm_lob$ set nclobcol=nclob_val where fpver=1;
  --
  
  PROCEDURE update_full_redaction_values
    (number_val     IN NUMBER                   := NULL
    ,binfloat_val   IN BINARY_FLOAT             := NULL
    ,bindouble_val  IN BINARY_DOUBLE            := NULL
    ,char_val       IN CHAR                     := NULL
    ,varchar_val    IN VARCHAR2                 := NULL
    ,nchar_val      IN NCHAR                    := NULL
    ,nvarchar_val   IN NVARCHAR2                := NULL
    ,date_val       IN DATE                     := NULL
    ,ts_val         IN TIMESTAMP                := NULL
    ,tswtz_val      IN TIMESTAMP WITH TIME ZONE := NULL
    );

END dbms_redact;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_redact FOR sys.dbms_redact
/

--
-- Grant the EXECUTE privilege on the Data Redaction administrative API 
-- to the EXECUTE_CATALOG_ROLE role.
--
GRANT EXECUTE ON sys.dbms_redact TO execute_catalog_role
/
--
-- Grant the EXECUTE privilege on the Data Redaction administrative API 
-- to the IMP_FULL_DATABASE role.
--
GRANT EXECUTE ON sys.dbms_redact TO imp_full_database
/
