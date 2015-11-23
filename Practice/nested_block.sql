SET SERVEROUTPUT ON

BEGIN
  <<outer>>
   DECLARE
      v_sal       NUMBER (7, 2) := 60000;
      v_comm      NUMBER (7, 2) := v_sal * 0.20;
      v_message   VARCHAR2 (255) := ' eligible for commission';
   BEGIN
      DECLARE
         v_sal          NUMBER (7, 2) := 50000;
         v_comm         NUMBER (7, 2) := 0;
         v_total_comm   NUMBER (7, 2) := v_sal + outer.v_comm;
      BEGIN
         v_message := 'Clerk not' || v_message;
         outer.v_comm := outer.v_sal * 0.30;
         DBMS_OUTPUT.PUT_LINE(v_message);
         dbms_output.put_line(outer.v_comm);
         dbms_output.put_line(v_total_comm);
      END;

      v_message := 'Salesman' || v_message;
      dbms_output.put_line(v_message);
   END;
END outer;