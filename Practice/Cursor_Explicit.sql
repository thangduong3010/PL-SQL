SET SERVEROUTPUT ON

DECLARE
   CURSOR c_emp_cursor
   IS
      SELECT id, customer_name
        FROM backend_dev.customer where rownum < 50;

   TYPE cust_type_record IS RECORD
   (
      cust_id    backend_dev.customer.id%TYPE,
      v_lname   backend_dev.customer.customer_name%TYPE
   );

   cust_record   cust_type_record;
BEGIN
   OPEN c_emp_cursor;

   LOOP
      FETCH c_emp_cursor INTO cust_record;

      EXIT WHEN c_emp_cursor%NOTFOUND;
      DBMS_OUTPUT.put_line (
            'Customer ID: '
         || cust_record.cust_id
         || ' '
         || 'Customer name: '
         || cust_record.v_lname);
   END LOOP;

   CLOSE c_emp_cursor;
END;
/
