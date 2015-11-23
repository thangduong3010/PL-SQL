/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE PROCEDURE clear_dependents (input_ssn IN employee.ssn%TYPE)
IS
BEGIN
    DELETE FROM dependent
    WHERE essn = input_ssn;  
END clear_dependents;
/