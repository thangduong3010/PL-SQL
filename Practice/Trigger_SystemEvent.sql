CREATE OR REPLACE TRIGGER schemaerror
   AFTER SERVERERROR
   ON SCHEMA
DECLARE
   TriggeringSQLTable   ora_name_list_t;
   TriggeringSQLText    VARCHAR2 (2000);
   ElementCount         PLS_INTEGER;
BEGIN
   ElementCount := ora_sql_txt (TriggeringSQLTable);

   FOR i IN 1 .. ElementCount
   LOOP
      TriggeringSQLText := TriggeringSQLText || TriggeringSQLTable (i);
   END LOOP;

   INSERT INTO messages (MESSAGETEXT)
        VALUES (TriggeringSQLText);

   INSERT INTO messages (MESSAGETEXT)
        VALUES (ora_server_error (1));

   INSERT INTO messages (MESSAGETEXT)
        VALUES (ora_server_error_msg (1));
END;