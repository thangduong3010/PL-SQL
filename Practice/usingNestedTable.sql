SET SERVEROUTPUT ON
-- create nested table type at schema level
CREATE OR REPLACE TYPE list_of_names IS TABLE OF VARCHAR2 (100);

DECLARE
	-- declare and call constructor to initialise nested table
   happyfamily   list_of_names := list_of_names ();
   children      list_of_names := list_of_names ();
   parents       list_of_names := list_of_names ();
BEGIN
	--  call EXTEND to make room in nested table. Must explicitly extend rows before adding value to nested table
   happyfamily.EXTEND (4);
   -- populate collection
   happyfamily (1) := 'Eli';
   happyfamily (2) := 'Steven';
   happyfamily (3) := 'Chris';
   happyfamily (4) := 'Veva';
	-- call EXTEND one at a time
   children.EXTEND;
   children (1) := 'Chris';
   children.EXTEND;
   children (2) := 'Eli';
	-- take childen out of happyfamily collection
   parents := happyfamily MULTISET EXCEPT children;

	-- use loop only when collection is dense
   FOR l_row IN parents.FIRST .. parents.LAST
   LOOP
      DBMS_OUTPUT.put_line (parents (l_row));
   END LOOP;
END;
/