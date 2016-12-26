--
-- CREATE SQLJUTL PACKAGE
--
create or replace package sqljutl as

   -- The following is required at translate-time for SQLJ
   function has_default(oid number,
                        proc char,
                        seq number,
                        ovr number) return number;

   -- The following is required at translate-time for JPublisher
   procedure get_typecode(tid raw, code OUT number,
                          class OUT varchar2, typ OUT number);

   -- The following might be used at runtime for converting
   -- between SQL and PL/SQL types 
   function bool2int(b boolean) return integer;
   function int2bool(i integer) return boolean;
   function ids2char(iv DSINTERVAL_UNCONSTRAINED) return CHAR;
   function char2ids(ch CHAR) return DSINTERVAL_UNCONSTRAINED;
   function iym2char(iv YMINTERVAL_UNCONSTRAINED) return CHAR;
   function char2iym(ch CHAR) return YMINTERVAL_UNCONSTRAINED;
   function uri2vchar(uri SYS.URITYPE) return VARCHAR2;
end sqljutl;
/

create or replace package sqljutl2 AUTHID CURRENT_USER as

   -- The following APIs are used for native invocation of
   -- server-side Java code
   FUNCTION evaluate(args LONG RAW) RETURN LONG RAW;
   FUNCTION invoke(handle NUMBER, class VARCHAR2, name VARCHAR2, sig VARCHAR2, args LONG RAW) RETURN LONG RAW;
   FUNCTION invoke(class VARCHAR2, name VARCHAR2, sig VARCHAR2, args LONG RAW) RETURN LONG RAW;
   FUNCTION reflect(class_Or_Package VARCHAR2, only_Declared NUMBER) RETURN LONG;
   FUNCTION reflect2(class_Or_Package VARCHAR2, only_Declared NUMBER) RETURN CLOB;

end sqljutl2;
/

create or replace package body sqljutl is

   function has_default(oid number,
                        proc char,
                        seq number,
                        ovr number) return number is
            def number;
   begin
      if proc IS NULL
      then
         select DEFAULT# INTO def FROM ARGUMENT$
                WHERE PROCEDURE$ IS NULL AND OBJ# = oid
                      AND SEQUENCE# = seq AND OVERLOAD# = ovr;
      else 
         select DEFAULT# INTO def FROM ARGUMENT$
                WHERE PROCEDURE$ = proc AND OBJ# = oid
                      AND SEQUENCE# = seq AND OVERLOAD# = ovr;
      end if;

      if def IS NULL
      then return 0;
      else return 1;
      end if;
   end has_default;


   procedure get_typecode
               (tid raw, code OUT number,
                class OUT varchar2, typ OUT number) is
      m NUMBER;
   begin
      SELECT typecode, externname, externtype INTO code, class, typ
      FROM TYPE$ WHERE toid = tid;
   exception
      WHEN TOO_MANY_ROWS
      THEN
      begin
        SELECT max(version#) INTO m FROM TYPE$ WHERE toid = tid;
        SELECT typecode, externname, externtype INTO code, class, typ
        FROM TYPE$ WHERE toid = tid AND version# = m;
      end;
   end get_typecode;

   function bool2int(b BOOLEAN) return INTEGER is
   begin if b is null then return null;
         elsif b then return 1;
         else return 0; end if;
   end bool2int;

   function int2bool(i INTEGER) return BOOLEAN is
   begin if i is null then return null;
         else return i<>0;
         end if;
   end int2bool;

   function ids2char(iv DSINTERVAL_UNCONSTRAINED) return CHAR is
      res CHAR(19);
   begin
      res := iv;
      return res;
   end ids2char;

   function char2ids(ch CHAR) return DSINTERVAL_UNCONSTRAINED is
      iv DSINTERVAL_UNCONSTRAINED;
   begin
      iv := ch;
      return iv;
   end char2ids;

   function iym2char(iv YMINTERVAL_UNCONSTRAINED) return CHAR is
      res CHAR(9);
   begin
      res := iv;
      return res;
   end iym2char;

   function char2iym(ch CHAR) return YMINTERVAL_UNCONSTRAINED is
      iv YMINTERVAL_UNCONSTRAINED;
   begin
      iv := ch;
      return iv;
   end char2iym;

   -- SYS.URITYPE and VARCHAR2
   function uri2vchar(uri SYS.URITYPE) return VARCHAR2 is
   begin
      return uri.geturl;
   end uri2vchar;

end sqljutl;
/

create or replace package body sqljutl2 as

   FUNCTION evaluate(args LONG RAW) RETURN LONG RAW
   AS LANGUAGE JAVA
   NAME 'oracle.jpub.reflect.Server.evaluate(byte[]) return byte[]';

   FUNCTION invoke(handle NUMBER, class VARCHAR2, name VARCHAR2, sig VARCHAR2, args LONG RAW) RETURN LONG RAW
   AS LANGUAGE JAVA
   NAME 'oracle.jpub.reflect.Server.invoke(java.lang.Long,java.lang.String,java.lang.String,java.lang.String,byte[]) return byte[]';

   FUNCTION invoke(class VARCHAR2, name VARCHAR2, sig VARCHAR2, args LONG RAW) RETURN LONG RAW
   AS LANGUAGE JAVA
   NAME 'oracle.jpub.reflect.Server.invoke(java.lang.String,java.lang.String,java.lang.String,byte[]) return byte[]';

   FUNCTION reflect(class_Or_Package VARCHAR2, only_Declared NUMBER) RETURN LONG
   AS LANGUAGE JAVA
   NAME 'oracle.jpub.reflect.Server.reflect(java.lang.String,int) return java.lang.String';

   FUNCTION reflect2(class_Or_Package VARCHAR2, only_Declared NUMBER) RETURN CLOB 
   AS LANGUAGE JAVA
   NAME 'oracle.jpub.reflect.Server.reflect2(java.lang.String,int) return oracle.sql.CLOB';

end sqljutl2;
/

grant execute on sqljutl to public ;
grant execute on sqljutl2 to public ;

