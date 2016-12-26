
create or replace PACKAGE dbms_drs IS
  -- ------------
  -- OVERVIEW
  -- ------------
  --
  -- This package contains procedures used in the DR Server (Hot Standby).
  -- There are two forms of each major function; one is a blocking procedure,
  -- which does not return until the command is completed. The other is a 
  -- non-blocking function which returns with a request identifier which may
  -- be used to return the result of the command. 
  --
  --------------------------
  -- NON-BLOCKING FUNCTIONS
  --------------------------
  -- 
  -- There is 1 non-blocking function:
  --    do_control
  -- 
  -- These functions take an incoming document type described in the
  -- Design Specification for DR Server API. Before the document is parsed
  -- and processed, it is added to a request queue with a request id returned.
  -- Therefore, the only reason why the non-blocking functions would raise 
  -- an exception is when the request cannot be added to the request queue.
  -- 
  -- Once all pieces of the outgoing document have been retrieved, the
  -- user should delete the request using the 'delete_request' procedure.
  --
  --------------------------
  -- BLOCKING PROCEDURES
  --------------------------
  -- 
  -- There are several blocking procedures:
  --    do_control
  --    delete_request
  --    cancel_request
  --    get_property
  -- 
  -- With the exception of delete_request, cancel_request and get_property*, 
  -- all the blocking procedures work the same way: as with the 
  -- non-blocking functions, each command takes an incoming document type 
  -- described in the Design Specification for the DR Server API. 
  -- Unlike the non-blocking functions, the blocking functions wait until 
  -- the command completes before returning the first piece of the document. 
  -- All initial requests should request the first piece (piece=1). 
  --
  -- If there is only one piece of the outgoing document, then the procedure 
  -- returns the first and only piece with a NULL request id. The request id 
  -- is automatically deleted prior to returning from the procedure.
  --
  -- If there is more than one piece of the outgoing document, then the 
  -- procedure returns the request id along with the first piece of the 
  -- outgoing document. The user should continue to call the blocking function
  -- with increasing piece numbers until the last piece is retrieved. Prior
  -- to returning the last piece, the function autmatically deletes the request
  -- id and a NULL request id is returned to the user.
  --
  -- As with the non-blocking functions, the blocking procedures will not
  -- raise an exception unless they cannot make the request. The user should
  -- check the outgoing document for the results of the command issued.
  --
  -- The remaining blocking functions (delete_request, cancel_request,
  -- get_property*) may
  -- be used to delete, cancel a request, or get a named non-XML property 
  -- respectively. delete_request may be used with a valid request id that 
  -- was retrieved using either the blocking or non-blocking functions. 
  -- Deleting a request that hasn't completed is not permitted and will 
  -- raise an exception. To cancel a request that is in progress, use the 
  -- cancel_request function. The cancel request function will automatically 
  -- delete the request information after cancelling the request.
  --
  -- Note: Do not mix blocking and non-blocking functions using the request_id.
  --
  -- get_property* returns the first piece of a named property value that is
  -- identified by name rather than by object id. 
  --
  --
  -- ------------------------
  -- EXAMPLES
  -- ------------------------
  --
  -- ------------------------
  -- Non-blocking example
  -- ------------------------
  --
  -- declare
  --  rid integer;
  --  indoc varchar2(4000);
  --  outdoc varchar2(4000);
  --  p integer;
  -- begin
  --  indoc:='<dummy>foo</dummy>';
  --
  --  rid :=dbms_drs.do_control(indoc);
  --  dbms_output.put_line('Request_id = '|| rid);
  --
  --  outdoc :=NULL;
  --  p:=1;
  --  while (outdoc is null)
  --  loop
  --    -- should really sleep a couple of ms
  --
  --    outdoc:=dbms_drs.get_response(rid,p);
  --  end loop;
  --
  --  dbms_output.put_line(outdoc);
  --  begin
  --    while (outdoc is not NULL)
  --    loop
  --      p:=p+1;
  --    
  --      outdoc:=dbms_drs.get_response(rid,p);
  --
  --      dbms_output.put_line(outdoc);
  --    end loop;
  --  exception
  --    when no_data_found then
  --    -- we got past last piece
  --    NULL;
  --  end;
  --  dbms_drs.delete_request(rid);
  -- end;
  --
  -- ------------------------
  -- Blocking example
  -- ------------------------
  -- 
  -- declare
  --  rid integer;
  --  indoc varchar2(4000);
  --  outdoc varchar2(4000);
  --  p integer;
  -- begin
  --  p:=1;
  --  indoc:='<dummy>foo</dummy>';
  --  dbms_drs.do_control(indoc,outdoc,rid,p);
  --  dbms_output.put_line(outdoc);
  --
  --  p:=2;
  --  while(rid is NOT NULL)
  --  loop
  --    dbms_drs.do_control(indoc,outdoc,rid,p);
  --    dbms_output.put_line(outdoc);
  --    p:=p+1;
  --  end loop;
  -- end;
  --
  --
  -- ------------------------
  -- PROCEDURES AND FUNCTIONS
  -- ------------------------

  procedure do_control(
        indoc      IN     VARCHAR2,
        outdoc     OUT    VARCHAR2, 
        request_id IN OUT INTEGER,
        piece      IN     INTEGER,
        context    IN     VARCHAR2 default NULL );
  -- Control blocking API - OBSELETE, for test use only 
  --                      - See do_control_raw below
  -- Perform a control operation. This is the blocking form of the procedure.
  -- Input parameters:
  --    indoc      - the document containing the control commands. The 
  --                 document type (DDT) is DO_CONTROL.
  --    request_id - the request id for returning multiple output pieces 
  --                 must be NULL for the first piece.
  --    piece      - the piece of the output document to return. For new
  --                 requests, the piece must be 1. For values greater than
  --                 1, a valid request_id must be supplied.
  --    context    - the context of command, usually NULL.
  -- Output parameters:
  --    outdoc - the result of the command. DDT may be either RESULT or VALUE. 
  --    request_id - the request id for returning the next output piece
  --                 will be NULL if the current piece does not exist
  --                 or is the last piece.
  -- Exceptions:
  --   bad_request (ORA-16508)
  --

  procedure do_control_raw(
        indoc      IN     RAW,
        outdoc     OUT    RAW,
        request_id IN OUT INTEGER,
        piece      IN     INTEGER,
        context    IN     VARCHAR2 default NULL,
        client_id  IN     INTEGER  default 0 );
  -- Control blocking API - designed for solving NLS problem
  -- Send DG Broker control request. It is blocking call.
  -- Input parameters:
  --    indoc      - the document containing the control commands. The 
  --                 document type (DDT) is DO_CONTROL.
  --    request_id - the request id for returning multiple output pieces 
  --                 must be NULL for the first piece.
  --    piece      - the piece of the output document to return. For new
  --                 requests, the piece must be 1. For values greater than
  --                 1, a valid request_id must be supplied.
  --    context    - the context of command, usually NULL.
  --    client_id  - For clients to identify itself - GUI or CLI.
  --                 Default value is 0, which means not GUI nor CLI.
  --
  -- Output parameters:
  --    outdoc - the result of the command. DDT may be either RESULT or VALUE. 
  --    request_id - the request id for returning the next output piece
  --                 will be NULL if the current piece does not exist
  --                 or is the last piece.
  -- Exceptions:
  --   bad_request (ORA-16508)
  --

  function do_control(indoc in varchar2) return integer;
  -- Control non-blocking API - OBSELETE, for test use only 
  --                          - See do_control_raw below
  -- Perform a control operation. This is the non-blocking form of the 
  -- procedure.
  -- Input parameters:
  --    indoc      - the document containing the control commands. The 
  --                 document type (DDT) is DO_CONTROL.
  -- Return Value: The request id for the request.
  --
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 

  function do_control_raw( indoc IN RAW ) return integer;
  -- Control non-blocking API - designed for solving NLS problem
  -- Perform a control operation. This is the non-blocking form of the 
  -- procedure.
  -- Input parameters:
  --    indoc      - the document containing the control commands. The 
  --                 document type (DDT) is DO_CONTROL.
  -- Return Value: The request id for the request.
  --
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 

  function get_response(rid in integer, piece in integer) return varchar2;
  -- Get Result (non-blocking) - OBSELETE, for test use only 
  --                           - See get_repsonse_raw below
  -- Get the result of a non-blocking command. If the command hasn't finished,
  -- the answer will be NULL. If the piece is beyond the end of the document
  -- the answer will be NULL.
  -- Input parameters:
  --    rid      - the request to delete.
  --    piece    - the piece to get, starting from 1.
  -- Returns:
  --    outdoc   - the answer to the request, if any, or NULL otherwise.
  -- 
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 

  function get_response_raw(rid in integer, piece in integer) return RAW;
  -- Get Result (non-blocking) - designed for solving NLS problem
  -- Get the result of a non-blocking command. If the command hasn't finished,
  -- the answer will be NULL. If the piece is beyond the end of the document
  -- the answer will be NULL.
  -- Input parameters:
  --    rid      - the request to delete.
  --    piece    - the piece to get, starting from 1.
  -- Returns:
  --    outdoc   - the answer to the request, if any, or NULL otherwise.
  -- 
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 

  procedure delete_request(rid in integer);
  -- Delete Request (blocking). 
  -- Input parameters:
  --    rid      - the request to delete.
  --
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 

  procedure cancel_request(rid in integer);
  -- Cancel Request (blocking).
  -- Input parameters:
  --    rid      - The request to cancel.
  --
  -- Exceptions:
  --   bad_request (ORA-16508)
  -- 
 
  function get_property( site_name in varchar2, 
                     resource_name in varchar2,
                     property_name in varchar2) return varchar2;
  -- get_property 
  -- get a named property. This function is equivalent to using
  -- getid to return the object id, followed by a <do_monitor><property>
  --   request.
  --
  -- Input parameters:
  --    site_name  - The name of the site (optional). If omitted,
  --                 resource_name must be NULL and DRC properties are 
  --                 retrieved.
  --    resource_name  - The name of the resource (optional). If omitted,
  --                 then site DRC properties are retrieved. Otherwise,
  --                 resource properties are retrieved.
  --
  --    property_name - the name of the property to return. 
  --                 
  -- Output parameters:
  --    none
  -- Returns:
  --    The property value converted to a string. If the value_type is XML
  --    then the first 4000 bytes of the XML document are returned.
  -- Exceptions:
  --
 
  function get_property_obj(object_id in integer, 
   property_name in varchar2) return varchar2;
  -- get_property 
  -- get a named property. This function is equivalent to 
  -- calling a <DO_MONITOR><PROPERTY>...
  --   request and parsing the resulting string.
  --
  -- Input parameters:
  --    object_id  - The object_handle. 
  --    property_name - the name of the property to return. 
  --                 
  -- Output parameters:
  --    none
  -- Returns:
  --    The property value converted to a string. If the value_type is XML
  --    then the first 4000 bytes of the XML document are returned.
  -- Exceptions:
  --

  function dg_broker_info( info_name in varchar2 ) return varchar2;
  -- get Data Guard Broker Information
  -- It now recognizes the following information names:
  --   'VERSION'   - the version of Data Guard Broker;
  --   'DMONREADY' - whether Data Guard Broker is ready to receive requests.
  -- Returns:
  --   The requested information specified by info_name, or
  --   'UNSUPPORTED' if info_name is not supported
  -- Exceptions:
  --   none
  --

  procedure sleep(seconds in integer);
  -- Sleep (blocking).
  -- Input parameters:
  --    seconds    - Number of seconds to sleep.
  --
  -- Output parameters:
  --    none
  --
  -- Exceptions:
  --   none
  -- 

  procedure dump_meta( options  IN integer,
                       metafile IN varchar2,
                       dumpfile IN varchar2 );
  -- DUMP data guard broker METAdata file content into a readable text file.
  -- Input parameters:
  --   options  - Indicates which metafile(s) to be dumped
  --                - the file indicated by fnam/fnamlen
  --                - the "current" metadata file
  --                - the "alternate" metadata file
  --                - first the "current", then the "alternate"
  --   metafile - Metadata filespec to be dumped. Ignored unless selected by
  --              the options argument.
  --   dumpfile - The readable output filespec.
  

  PROCEDURE Ping(iObid     IN  BINARY_INTEGER, 
                 iVersion  IN  BINARY_INTEGER,
                 iFlags    IN  BINARY_INTEGER,
                 iMiv      IN  BINARY_INTEGER,
                 iWaitStat IN  BINARY_INTEGER,
                 oVersion  OUT BINARY_INTEGER,
                 oFlags    OUT BINARY_INTEGER,
                 oFoCond   OUT VARCHAR2,
                 oStatus   OUT BINARY_INTEGER);

  PROCEDURE ReadyToFailover(iObid    IN  BINARY_INTEGER, 
                            iVersion IN  BINARY_INTEGER,
                            iFlags   IN  BINARY_INTEGER,
                            iMiv     IN  BINARY_INTEGER,
                            iFoCond  IN  VARCHAR2,
                            oStatus  OUT BINARY_INTEGER);

  PROCEDURE StateChangeRecorded(iObid IN BINARY_INTEGER, 
                                iVersion IN BINARY_INTEGER);

  PROCEDURE fs_failover_for_hc_cond(hc_cond IN BINARY_INTEGER,
                             status OUT BINARY_INTEGER);

  FUNCTION fs_failover_for_hc_cond(hc_cond IN BINARY_INTEGER) RETURN BOOLEAN;

  PROCEDURE initiate_fs_failover(condstr IN varchar2,
                                 status  OUT binary_integer);

pragma TIMESTAMP('2006-05-17:20:20:00');

end;
/

