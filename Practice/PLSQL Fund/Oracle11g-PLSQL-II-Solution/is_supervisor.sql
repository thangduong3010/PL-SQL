/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE FUNCTION is_supervisor (input_ssn IN employee.ssn%TYPE)
RETURN BOOLEAN IS
    supervisor_count  NUMBER;
BEGIN
    SELECT  COUNT(superssn)
    INTO    supervisor_count
    FROM    employee
    WHERE   superssn = input_ssn;

    IF supervisor_count > 0 THEN
         RETURN (TRUE);
    ELSE
         RETURN (FALSE);
    END IF;
END is_supervisor;
/