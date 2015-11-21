/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE FUNCTION is_manager (input_ssn IN employee.ssn%TYPE)
RETURN BOOLEAN IS
    manager_count  NUMBER;
/*
Use the input parameter to see if this employee is currently the manager of any departments, as indicated by the MGRSSN column of the DEPARTMENT table. Return an appropriate function result based upon the finding.
*/
BEGIN
    SELECT  COUNT(mgrssn)
    INTO    manager_count
    FROM    department
    WHERE   mgrssn = input_ssn;

    IF manager_count > 0 THEN
         RETURN (TRUE);
    ELSE
         RETURN (FALSE);
    END IF;
END is_manager;
/
