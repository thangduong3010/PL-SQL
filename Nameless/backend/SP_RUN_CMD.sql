CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_RUN_CMD (p_command   IN   VARCHAR2) 
  AS LANGUAGE JAVA NAME
    'CommandUtil.execute (java.lang.String)';
/