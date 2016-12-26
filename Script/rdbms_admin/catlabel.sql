--
-- $Header: zlaslab.sql 09-jan-2003.08:10:33 nireland Exp $
--
-- zlaslab.sql
--
--  Copyright (c) Oracle Corporation 2000, 2001. All Rights Reserved.
--
--    NAME
--      zlaslab.sql - script to set opaque/numeric label
--
--    DESCRIPTION
--      Based on an input parameter, sets the POLICY_COLUMN_DATATYPE
--      property to LBAC_LABEL or NUMBER
--
--    NOTES
--      Run LBACSYS or SYSDBA after both LBAC and SA packages installed
--
--    MODIFIED   (MM/DD/YY)
--    nireland    01/09/03 - Expose merge_label to world. #2567363
--    srtata      10/07/02 - insert to props
--    srtata      10/09/02 - insert oid flag in props
--    nireland    12/19/01 - Fix synonym problem. #2149987
--    gmurphy     04/08/01 - add 2001 to copyright
--    gmurphy     04/02/01 - clean up synonyms
--    gmurphy     02/26/01 - qualify objects for install as SYSDBA
--    gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--    rsripada    12/29/00 - accept only NUMBER datatype
--    rsripada    07/16/00 - create synonyms for tag sequence to char
--    rsripada    05/18/00 - fix typo
--    rburns      03/09/00 - Created
--

-- lbac framework synonyms in zllc.pkb
DROP PUBLIC SYNONYM label_to_char;
DROP PUBLIC SYNONYM tagseq_to_char;
DROP PUBLIC SYNONYM char_to_label;
DROP PUBLIC SYNONYM to_data_label;

-- sa policy synonyms in zlasu.pkb
DROP PUBLIC SYNONYM dominates;
DROP PUBLIC SYNONYM strictly_dominates;
DROP PUBLIC SYNONYM dominated_by;
DROP PUBLIC SYNONYM strictly_dominated_by;
DROP PUBLIC SYNONYM least_ubound;
DROP PUBLIC SYNONYM merge_label;
DROP PUBLIC SYNONYM greatest_lbound;
DROP PUBLIC SYNONYM dom;
DROP PUBLIC SYNONYM s_dom;
DROP PUBLIC SYNONYM dom_by;
DROP PUBLIC SYNONYM s_dom_by;
DROP PUBLIC SYNONYM lubd;
DROP PUBLIC SYNONYM glbd;


DECLARE
  datatype        VARCHAR(30);
  lbac_datatype   VARCHAR2(30) := 'LBAC_LABEL';
  number_datatype VARCHAR2(30) := 'NUMBER';
BEGIN

  datatype:=number_datatype;

  DELETE FROM LBACSYS.lbac$props WHERE name='POLICY_COLUMN_DATATYPE';

  INSERT INTO LBACSYS.lbac$props VALUES (
            'POLICY_COLUMN_DATATYPE', datatype,
            'Determines the datatype for all policy related columns');

  -- set the default debug level for the DIP callback function to 0
  DELETE FROM LBACSYS.lbac$props WHERE name='DIP_DEBUG_LEVEL';

  INSERT into LBACSYS.lbac$props values ('DIP_DEBUG_LEVEL', 0,
            'Determines the Debug level of the dip callback function');

  DELETE FROM LBACSYS.lbac$props WHERE name='OID_STATUS_FLAG';

  -- set the default value to indicate that OID is not enabled with OLS
  INSERT INTO LBACSYS.lbac$props VALUES (
            'OID_STATUS_FLAG', 0,
            'Determines if OID is enabled with OLS');

  IF datatype = lbac_datatype THEN
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM label_to_char FOR ' ||
                       'LBACSYS.lbac_label_to_char';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM tagseq_to_char FOR ' ||
                       'LBACSYS.lbac_label_tagseq_to_char';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM char_to_label FOR ' || 
                       'LBACSYS.to_lbac_label';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM to_data_label FOR ' ||
                       'LBACSYS.to_lbac_data_label';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM dominates FOR ' ||
                       'LBACSYS.lbac_dominates';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM strictly_dominates FOR ' ||
                       'LBACSYS.lbac_strictly_dominates';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM dominated_by FOR ' ||
                       'LBACSYS.lbac_dominated_by';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM strictly_dominated_by FOR ' ||
                       'LBACSYS.lbac_strictly_dominated_by';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM least_ubound FOR ' ||
                       'LBACSYS.lbac_least_ubound';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM merge_label FOR ' ||
                       'LBACSYS.lbac_merge_label';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM greatest_lbound FOR ' ||
                       'LBACSYS.lbac_greatest_lbound';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM dom FOR ' ||
                       'LBACSYS.lbac_dominates';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM s_dom FOR ' ||
                       'LBACSYS.lbac_strictly_dominates';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM dom_by FOR ' ||
                       'LBACSYS.lbac_dominated_by';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM s_dom_by FOR ' ||
                       'LBACSYS.lbac_strictly_dominated_by';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM lubd FOR ' ||
                       'LBACSYS.lbac_least_ubound';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM glbd FOR ' ||
                       'LBACSYS.lbac_greatest_lbound';
  ELSE
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM label_to_char FOR ' ||
                       'LBACSYS.numeric_label_to_char';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM tagseq_to_char FOR ' ||
                       'LBACSYS.numeric_label_tagseq_to_char';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM char_to_label FOR ' ||
                       'LBACSYS.to_numeric_label';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM to_data_label FOR ' ||
                       'LBACSYS.to_numeric_data_label';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM dominates FOR ' ||
                       'LBACSYS.numeric_dominates';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM strictly_dominates FOR ' ||
                       'LBACSYS.numeric_strictly_dominates';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM dominated_by FOR ' ||
                       'LBACSYS.numeric_dominated_by';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM strictly_dominated_by FOR ' ||
                       'LBACSYS.numeric_strictly_dominated_by';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM least_ubound FOR ' ||
                       'LBACSYS.numeric_least_ubound';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM merge_label FOR ' ||
                       'LBACSYS.numeric_merge_label';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM greatest_lbound FOR ' ||
                       'LBACSYS.numeric_greatest_lbound';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM dom FOR ' ||
                       'LBACSYS.numeric_dominates';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM s_dom FOR ' ||
                       'LBACSYS.numeric_strictly_dominates';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM dom_by FOR ' ||
                       'LBACSYS.numeric_dominated_by';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM s_dom_by FOR ' ||
                       'LBACSYS.numeric_strictly_dominated_by';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM lubd FOR ' ||
                       'LBACSYS.numeric_least_ubound';
     EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM glbd FOR ' ||
                       'LBACSYS.numeric_greatest_lbound';
  END IF;

END;
/
