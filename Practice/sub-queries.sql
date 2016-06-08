-- the expression repeats 2 times
SELECT sid, sname, gpa, gpa * (sizehs / 1000.0) AS scaledGPA
  FROM student
WHERE abs(gpa * (sizehs / 1000.0) - gpa) > 1.0;

-- using sub-query in FROM clause to avoid repetition
SELECT * FROM
(SELECT sid, sname, gpa, gpa * (sizehs / 1000.0) AS scaledGPA
  FROM student) G
WHERE abs(G.scaledGPA - gpa) > 1.0;
--------------------------------------------------------
SELECT DISTINCT college.cname, state, gpa
  FROM college, apply, student
WHERE college.cname = apply.cname
AND apply.sid = student.sid
AND gpa >= ALL (SELECT gpa FROM student, apply
                WHERE student.sid = apply.sid
                AND apply.cname = college.cname);

-- rewrite using sub-query in SELECT clause
SELECT cname, state,
  (SELECT DISTINCT gpa FROM apply, student
  WHERE college.cname = apply.cname AND apply.sid = student.sid
  AND gpa >= ALL (SELECT gpa FROM student, apply
                  WHERE student.sid = apply.sid
                  AND apply.cname = college.cname)) AS GPA
  FROM college;
