variable jvmrmaction varchar2(30)
execute :jvmrmaction := 'FULL_REMOVAL';
@@jvmrmdbj

create or replace package dbms_java authid current_user as

  type compiler_option_type is record(option_line varchar2(128));

  type compiler_option_type_table is table of compiler_option_type;

  PROCEDURE start_btl;

  PROCEDURE stop_btl;

  PROCEDURE terminate_btl;

  -- compile all methods defined by the class identified by
  -- classname in the current schema.
  -- return the number of methods successfully compiled
  --
  -- If the class does not exist an ORA-29532 (Uncaught Java
  -- exception) will occur.
  FUNCTION compile_class(classname VARCHAR2) return NUMBER;


  -- compile the method specified by name and Java type signature
  -- defined by the class identified by classname in the current
  -- schema.  
  -- return the number of methods successfully compiled
  --
  -- If the class does not exist, an ORA-29532 (Uncaught Java
  -- exception) will occur.
  FUNCTION compile_method(classname  VARCHAR2,
                          methodname VARCHAR2,
                          methodsig  VARCHAR2) return NUMBER;


  -- uncompile all methods defined by the class identified by
  -- classname in the current schema. 
  --
  -- return the number of methods successfully uncompiled.
  --
  -- If permanentp, then mark these methods as permanently dynamicaly
  -- un-compilable, otherwise, they are eligible for future dynamic
  -- recompilation.
  --
  -- If the class does not exist an ORA-29532 (Uncaught Java
  -- exception) will occur.
  FUNCTION uncompile_class(classname VARCHAR2,
                           permanentp NUMBER default 0) return NUMBER;


  -- uncompile the method specified by the name and Java type
  -- signature defined by the class identified by classname in the
  -- current schema.
  --
  -- return the number of methods successfully uncompiled.
  --
  -- If permanentp, then mark the method as permanently dynamicaly
  -- un-compilable, otherwise, it is eligible for future dynamic
  -- recompilation.
  --
  -- If the class does not exist an ORA-29532 (Uncaught Java
  -- exception) will occur.
  FUNCTION uncompile_method(classname  VARCHAR2,
                            methodname VARCHAR2,
                            methodsig  VARCHAR2,
                            permanentp NUMBER default 0) return NUMBER;

  --
  -- Dump the native code (if available) for the specified method to trace.
  --
  PROCEDURE dump_native_machine_code(classname  VARCHAR2,
                                     methodname VARCHAR2,
                                     methodsig  VARCHAR2);

  FUNCTION native_compiler_options return compiler_option_type_table pipelined;

  -- sets a native-compiler option to the specified value for the
  -- current schema
  PROCEDURE set_native_compiler_option(optionName VARCHAR2,
                                       value      VARCHAR2);

  -- decode, into a user-readable format, a persisted native-compiler
  -- option.  This function is not intended to be used by users
  -- directly
  FUNCTION decode_native_compiler_option(optionName VARCHAR2,
                                         value      VARCHAR2) RETURN VARCHAR2;

  -- unsets a native-compiler option given by the tuple
  --   [optionName, value].
  --
  -- if the option given by optionName is not allowed to have
  -- duplicate values, then the value is ignored.
  PROCEDURE unset_native_compiler_option(optionName VARCHAR2,
                                         value      VARCHAR2);

  FUNCTION init_btl(files_prefix VARCHAR2, type NUMBER,
                    sample_limit NUMBER, exclude_java NUMBER) return NUMBER;
  pragma restrict_references(init_btl, wnds, wnps);

  FUNCTION longname (shortname VARCHAR2) return VARCHAR2;
  pragma restrict_references(longname, wnds, wnps);

  FUNCTION shortname (longname VARCHAR2) RETURN VARCHAR2;
  pragma restrict_references(shortname, wnds, wnps);

  -- functions and procedures to manipulate the compiler option table
  -- what refers to a source name, package or class depending
  
  -- determine the option value for option optionName applied to 
  -- what
  FUNCTION get_compiler_option(what VARCHAR2, optionName VARCHAR2)
    return varchar2 ;
  pragma restrict_references (get_compiler_option, wnds, wnps);

  -- set the option value to value for option optionName applied to
  -- what.  And depending upon the characteristics of optionName 
  -- it may apply to "descendants" of what as well.
  PROCEDURE set_compiler_option(what VARCHAR2, optionName VARCHAR2, value VARCHAR2);

  -- reset the option value. That is, undo an action performed by
  -- set_compiler_option
  PROCEDURE reset_compiler_option(what VARCHAR2, optionName VARCHAR2);
  

  FUNCTION initGetSourceChunks (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
    RETURN NUMBER;
  pragma restrict_references(initGetSourceChunks, wnds);

  FUNCTION getSourceChunk RETURN VARCHAR2;
  pragma restrict_references(getSourceChunk, wnds);

  FUNCTION resolver (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN VARCHAR2;
  pragma restrict_references(resolver, wnds);
 
  FUNCTION derivedFrom (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN VARCHAR2;
  pragma restrict_references(derivedFrom, wnds);
 
  FUNCTION fixed_in_instance (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN NUMBER;
  pragma restrict_references(fixed_in_instance, wnds);

  PROCEDURE set_fixed_in_instance (name VARCHAR2, owner VARCHAR2,
                                   type VARCHAR2, value NUMBER);

  FUNCTION sharedPrivateClassName (name VARCHAR2)
     RETURN VARCHAR2;
  pragma restrict_references(sharedPrivateClassName, wnds);

  -- RUNJAVA interface.  RUNJAVA is a facility for running
  -- java in the OJVM server resident VM using a command line
  -- interface that emulates the JDK java shell command.  In
  -- particular, this interface allows the use of -classpath
  -- to run classes loaded directly from the file system without
  -- the intervening step of loading these classes into the database
  -- via loadjava or the equivalent.  It also supports use of -D
  -- arguments to set System property values.  There is an
  -- auxiliary facility for establishing System property values
  -- used by default (without requiring -D, in a manner intended
  -- to be analogous to the use of environment variable by the
  -- JDK in setting certain System properties).

  -- runjava:  This function takes a java command line as its
  -- only argument and executes that command in the OJVM.  The
  -- return value is null on successful completion, otherwise
  -- an error message.  The format of the command line is the
  -- same as that taken by the JDK java shell command, ie
  -- [option switches] name_of_class_to_execute [arg1 arg2 ... argn]
  -- The option switches -classpath and -D are supported.  Others
  -- may be supported if they make sense in the OJVM environment.
  -- This function differs from runjava_in_current_session in
  -- that it clears any java state remaining from previous use of
  -- java in the session prior to running the current command.
  -- This is necessary in particular to guarantee that static
  -- variable values derived at class initialization time from
  -- -classpath and -D arguments are reflect the values of those
  -- switches in the current command line.
  FUNCTION runjava(cmdline VARCHAR2) RETURN VARCHAR2;

  -- runjava_in_current_session:  This function is the same as the
  -- runjava function except that it does not clear java state
  -- remaining from previous use of java in the session prior to
  -- executing the current command line.  See the description
  -- of runjava for other details.
  FUNCTION runjava_in_current_session(cmdline VARCHAR2) RETURN VARCHAR2;

  -- endsession:  This function clears any java session state remaining
  -- from previous execution of java in the current RDBMS session.
  -- The return value is a message indicating the action taken.
  FUNCTION endsession RETURN VARCHAR2;

  -- endsession_and_related_state:  This function clears any java 
  -- session state remaining from previous execution of java in the 
  -- current RDBMS session and all supporting data related to running
  -- java, such as property settings and output specifications.
  -- The return value is a message indicating the action taken.
  FUNCTION endsession_and_related_state RETURN VARCHAR2;

  -- set_property:  This function provides for establishing
  -- a value for a System property which will be used thereafter for the
  -- duration of the current RDBMS session whenever a java session is 
  -- initialized.  The first argument is the name of the property
  -- and the second is the value to be established for it.  The return value
  -- from set_property is null unless some error occurred, such as an
  -- attempt to set a value for a prescribed property, in which case
  -- an error message is returned.
  FUNCTION set_property(name VARCHAR2, value VARCHAR2) RETURN VARCHAR2;

  -- get_property:  This function returns any value previously established
  -- by set_property, or null if there is no such value.
  FUNCTION get_property(name VARCHAR2) RETURN VARCHAR2;

  -- remove_property:  This function removes any value previously established
  -- by set_property.  The return value is null unless an error occurred,
  -- in which case an error message is returned.
  FUNCTION remove_property(name VARCHAR2) RETURN VARCHAR2;

  -- show_property.  This function prints a message of the form
  --   name = value for the input name, or for all established property
  -- bindings if name is null.  The return value is null on successful
  -- completion, otherwise it is an error message.  The output is
  -- printed to wherever java output is current directed.
  FUNCTION show_property(name VARCHAR2) RETURN VARCHAR2;

  -- Methods for controlling destination of java output
  PROCEDURE set_output (buffersize NUMBER);

  -- set_output_to_sql defines a named output specification which
  -- constitutes a prescription for executing a sql statement whenever
  -- output to the default System.out and System.err streams occurs.
  -- The specification is defined for the duration of the current
  -- session, or until remove_output_to_sql is called with its id.
  -- The sql actions the specification prescribes will occur whenever
  -- there is java output unless disable_output_to_sql has been called,
  -- in which case the actions will not occur again until
  -- enable_output_to_sql is called.
  --
  -- Arguments are
  --   id       The name of the specification.  Multiple specifications
  --            may exist in the same session, but each must have a distinct
  --            id.  The id is used to identify the specification in the
  --            functions remove, enable, disable and query_output_to_sql.
  --   stmt     The default sql statement to execute when java output occurs.
  --   bindings A string containing tokens from the set
  --            ID, TEXT, LENGTH, LINENO, SEGNO, NL and ERROUT.  This string
  --            defines how the sql statement stmt will be bound.  The
  --            position in the bindings string of a token corresponds to
  --            the bind position in the sql statement.  The meanings of the
  --            tokens are
  --            ID  the id of the specification, bound as a VARCHAR2
  --            TEXT  the text being output, bound as a VARCHAR2
  --            LENGTH the length of the text, bound as a NUMBER
  --            LINENO the line number (since the beginning of session output),
  --                   bound as a NUMBER
  --            SEGNO the segment number within a line that is being output
  --                   in more than one piece, bound as a NUMBER
  --            NL a boolean indicating whether the text is to be regarded
  --               as newline terminated, bound as a NUMBER.  The newline
  --               may or may not actually be included in the text, depending
  --               on the value of the include_newlines argument discussed
  --               below.
  --            ERROUT a boolean indicating whether the output came from
  --               System.out or System.err, bound as a NUMBER.  The value
  --               is 0 iff the output came from System.out.
  --   no_newline_stmt   An optional alternate sql statement to execute
  --                     when the output is not newline terminated.
  --   no_newline_bindings  A string with the same syntax as for the bindings
  --                        argument discussed above, describing how the
  --                        no_newline_stmt is bound.
  --   newline_only_stmt   An optional alternate sql statement to execute
  --                       when the output is a single newline.
  --   newline_only_bindings  A string with the same syntax as for the bindings
  --                          argument discussed above, describing how the
  --                          newline_only_stmt is bound.
  --   maximum_line_segment_length  The maximum number of characters that
  --                                will be bound in a given execution of
  --                                the sql statement.  Longer output
  --                                sequences will be broken up into
  --                                separate calls with distinct SEGNO
  --                                values.  A value of 0 means no maximum.
  --   allow_replace  Controls behavior when a previously defined specification
  --                  with the same id exists.  A value of 1 means replace the
  --                  old specification.  0 means return an error message
  --                  without modifying the old specification.
  --   from_stdout  Controls whether output from System.out causes execution
  --                of the sql statement prescribed by the specification.  A
  --                value of 0 means that if the output came from System.out
  --                the statement is not executed even if the specification is
  --                otherwise enabled.
  --   from_stderr  Controls whether output from System.err causes execution
  --                of the sql statement prescribed by the specification.  A
  --                value of 0 means that if the output came from System.err
  --                the statement is not executed even if the specification is
  --                otherwise enabled.
  --   include_newlines  Controls whether newline characters are left in the
  --                     output when it is bound to text.  A value of 0 means
  --                     newlines are not included (but the presence of the
  --                     newline is still indicated by the NL binding and
  --                     by whether the no_newline_stmt is used).
  --   eager  Controls whether output not terminated by a newline causes
  --          execution of the sql statement every time it is received vs
  --          accumulating such output until a newline is received.  A value
  --          of 0 means that unterminated output is accumulated.
  --
  -- Return value is null on success otherwise an error message.
  FUNCTION set_output_to_sql (id VARCHAR2,
                              stmt VARCHAR2,
                              bindings VARCHAR2,
                              no_newline_stmt VARCHAR2 default null,
                              no_newline_bindings VARCHAR2 default null,
                              newline_only_stmt VARCHAR2 default null,
                              newline_only_bindings VARCHAR2 default null,
                              maximum_line_segment_length NUMBER default 0,
                              allow_replace NUMBER default 1,
                              from_stdout NUMBER default 1,
                              from_stderr NUMBER default 1,
                              include_newlines NUMBER default 0,
                              eager NUMBER default 0) return VARCHAR2;

  -- remove_output_to_sql deletes a specification created by
  -- set_output_to_sql.  If no such specification exists, an error message
  -- is returned
  FUNCTION remove_output_to_sql (id VARCHAR2) return VARCHAR2;

  -- enable_output_to_sql (re)enables a specification created by
  -- set_output_to_sql and subsequently disabled by disable_output_to_sql.
  -- If no such specification exists, an error message is returned.  If
  -- the specification is not currently disabled, there is no change.
  FUNCTION enable_output_to_sql (id VARCHAR2) return VARCHAR2;

  -- disable_output_to_sql disables a specification created by
  -- set_output_to_sql.  The specification may be re-enabled by
  -- enable_output_to_sql.  While disabled, the sql statement prescribed
  -- by the specification is not executed.
  -- If no such specification exists, an error message is returned.  If
  -- the specification is already disabled, there is no change.
  FUNCTION disable_output_to_sql (id VARCHAR2) return VARCHAR2;

  -- query_output_to_sql returns a message describing a specification
  -- created by set_output_to_sql.  
  -- If no such specification exists, an error message is returned.
  FUNCTION query_output_to_sql (id VARCHAR2) return VARCHAR2;

  -- set_output_to_java defines a named output specification which
  -- constitutes a prescription for executing a java method whenever
  -- output to the default System.out and System.err streams occurs.
  -- See the comments for set_output_to_sql for discussion of the
  -- common arguments and the duration of the specifications.  The
  -- java method prescribed by the specification is executed in a
  -- separate VM context with separate java session state from the
  -- rest of the session.
  -- Arguments specific to this type of specification are
  --   class_name  The name of the class defining the method(s)
  --   class_schema  The schema in which the class is defined.  A null
  --                 value means the class is defined in the current schema,
  --                 or PUBLIC.
  --   method  The name of the method.
  --   bindings  A string that defines how arguments to the method are bound.
  --             This is a string of tokens with the same syntax as discussed
  --             under set_output_to_sql above.  The position of a token in
  --             the string determines the position of the argument it 
  --             describes.  All arguments must be of type int, except for
  --             those corresponding to the tokens ID or TEXT, which must be
  --             of type java.lang.String.
  --   no_newline_method   An optional alternate method to execute
  --                       when the output is not newline terminated.
  --   newline_only_method   An optional alternate method to execute
  --                         when the output is a single newline.
  --   initialization_statement  An optional sql statement that is executed
  --                             once per java session prior to the first
  --                             time the methods that receive output are
  --                             executed.  This statement is executed in
  --                             same java VM context as the output methods
  --                             will be.  Typically such a statement is
  --                             used to run a java stored procedure that
  --                             initializes conditions in the separate VM
  --                             context so that the methods that receive
  --                             output can function as intended.  For 
  --                             example such a procedure might open a
  --                             stream which the output methods write to.
  --   finalization_statement  An optional sql statement that is executed
  --                           once when the output specification is
  --                           about to be removed or the session is ending.
  --                           Like the initialization_statement this runs
  --                           in the same java VM context as the methods
  --                           that receive output.  It runs only if the
  --                           initialization method has run, or if there is
  --                           no initialization method.
  FUNCTION set_output_to_java (id VARCHAR2,
                               class_name VARCHAR2,
                               class_schema VARCHAR2,
                               method VARCHAR2,
                               bindings VARCHAR2,
                               no_newline_method VARCHAR2 default null,
                               no_newline_bindings VARCHAR2 default null,
                               newline_only_method VARCHAR2 default null,
                               newline_only_bindings VARCHAR2 default null,
                               maximum_line_segment_length NUMBER default 0,
                               allow_replace NUMBER default 1,
                               from_stdout NUMBER default 1,
                               from_stderr NUMBER default 1,
                               include_newlines NUMBER default 0,
                               eager NUMBER default 0,
                               initialization_statement VARCHAR2 default null,
                               finalization_statement VARCHAR2 default null)
         return VARCHAR2;

  -- remove_output_to_java deletes a specification created by
  -- set_output_to_java.  If no such specification exists, an error message
  -- is returned
  FUNCTION remove_output_to_java (id VARCHAR2) return VARCHAR2;

  -- enable_output_to_java (re)enables a specification created by
  -- set_output_to_java and subsequently disabled by disable_output_to_java.
  -- If no such specification exists, an error message is returned.  If
  -- the specification is not currently disabled, there is no change.
  FUNCTION enable_output_to_java (id VARCHAR2) return VARCHAR2;

  -- disable_output_to_java disables a specification created by
  -- set_output_to_java.  The specification may be re-enabled by
  -- enable_output_to_java.  While disabled, the sql statement prescribed
  -- by the specification is not executed.
  -- If no such specification exists, an error message is returned.  If
  -- the specification is already disabled, there is no change.
  FUNCTION disable_output_to_java (id VARCHAR2) return VARCHAR2;

  -- query_output_to_java returns a message describing a specification
  -- created by set_output_to_java.  
  -- If no such specification exists, an error message is returned.
  FUNCTION query_output_to_java (id VARCHAR2) return VARCHAR2;

  -- set_output_to_file defines a named output specification which
  -- constitutes a prescription to capture any output sent to the
  -- default System.out and System.err streams and append it to
  -- a specified file.  This is implemented using a special case
  -- of set_output_to_java.  Arguments are
  --   file_path  The path to the file to which to append the output
  --   allow_replace, from_stdout and from_stderr all analogous to
  --      those of the same name in set_output_to_java
  FUNCTION set_output_to_file (id VARCHAR2,
                               file_path VARCHAR2,
                               allow_replace NUMBER default 1,
                               from_stdout NUMBER default 1,
                               from_stderr NUMBER default 1)
         return VARCHAR2;

  -- The following four functions are analogous to their output_to_java
  -- counterparts
  FUNCTION remove_output_to_file (id VARCHAR2) return VARCHAR2;

  FUNCTION enable_output_to_file (id VARCHAR2) return VARCHAR2;

  FUNCTION disable_output_to_file (id VARCHAR2) return VARCHAR2;

  FUNCTION query_output_to_file (id VARCHAR2) return VARCHAR2;

  -- The following two procedures are for internal use in the 
  -- implementation of set_output_to_file
  PROCEDURE initialize_output_to_file (id VARCHAR2, path VARCHAR2);

  PROCEDURE finalize_output_to_file (id VARCHAR2);

  -- The following two procedures and one function control
  -- whether java output is sent to the .trc file (this is the
  -- case by default)
  PROCEDURE enable_output_to_trc;

  PROCEDURE disable_output_to_trc;

  FUNCTION query_output_to_trc return VARCHAR2;

  -- support for calling runjava from ojvmjava

  -- rjbc_init: setup back channel, return id that identifies it.  Called
  -- prior to runjava in the same session as runjava will run in.
  -- flags non zero means dont use back channel for file content
  -- this corresponds to the ojvmjava runjava mode server_file_system
  function rjbc_init(flags NUMBER) return VARCHAR2;
  
  -- rjbc_request: called from runjava to ask for contents or directoriness
  -- of file identified by pathname on the client filesystem.  Puts pathname 
  -- in the java$jvm$rjbc row then waits for client response.  rtype 0 means
  -- get content, 1 means ask if directory
  -- status returned is 0 if content returned or is directory, !0 otherwise
  -- lob returned if pathname found
  function rjbc_request(pathname VARCHAR2, rtype NUMBER, lob out BLOB)
    return NUMBER;

  -- rjbc_normalize: called from runjava to ask for the normalized, absolute
  -- pathname on the client filesystem of the file identified by the input
  -- argument pathname.  Puts pathname in the java$jvm$rjbc row then waits 
  ---for client response.
  -- rtype is not used.
  -- status returned is 0 if the file is a directory, non-zero otherwise.
  -- This value is also not used.
  -- normalized_pathname is returned containing the normalized path.
  function rjbc_normalize(pathname VARCHAR2, rtype NUMBER,
                          normalized_pathname out VARCHAR2)
    return NUMBER;

  -- rjbc_output: set_output_to_sql entrypoint used by runjava to pass
  -- output back to the client.
  -- Puts text in the java$jvm$rjbc row then waits for client response.
  procedure rjbc_output(text VARCHAR2, nl NUMBER);

  -- rjbc_done: called from client to shutdown back channel
  procedure rjbc_done(id VARCHAR2 := null);
  
  -- back channel entrypoint
  -- rjbc_respond. Called in loop by back channel client thread to respond
  -- to requests queued by rjbc_request, rjbc_normalize and rjbc_output.  
  -- status argument indicates result of processing the previous request.
  -- status values are: -1 = initial call (there was no previous request)
  --                     0 = file content found and returned
  --                     1 = file not found
  -- p in argument receives the normalized path for an rjbc_normalize request
  -- l in argument receives the lob containing the file content for an
  -- rjbc_request request.
  -- return values indicate the kind of the new request.  These values are:
  --   -1 = no request (ie, time to exit)
  --    0 = file content (rjbc_request)
  --    1 = normalize path (rjbc_normalize)
  --    2 = newline terminated output (rjbc_output)
  --    3 = nonnewline terminated output (rjbc_output)
  -- For return values 0 and 1, the p out argument contains the name of the
  -- file to be processed.  For return values 2 and 3 p contains the text
  -- to be output.
  function rjbc_respond(sid VARCHAR2, status NUMBER, p in out VARCHAR2, l BLOB)
    return NUMBER;


  -- import/export interface --
  function start_export(short_name in varchar2, 
                        schema in varchar2, 
                        flags in number,
                        type in number,
                        properties out number,
                        raw_chunk_count out number, 
                        total_raw_byte_count out number,
                        text_chunk_count out number, 
                        total_text_byte_count out number)
         return number;
  pragma restrict_references(start_export, wnds);

  function export_raw_chunk(chunk out raw, length out number)
           return number;
  pragma restrict_references(export_raw_chunk, wnds);

  function export_text_chunk(chunk out varchar2, length out number)
           return number;
  pragma restrict_references(export_text_chunk, wnds);


  function end_export return number;
  pragma restrict_references(end_export, wnds);


  function start_import(long_name in varchar2, 
                        flags in number,
                        type in number,
                        properties in number,
                        raw_chunk_count in number, 
                        total_raw_byte_count in number,
                        text_chunk_count in number)
         return number;
  pragma restrict_references(start_import, wnds);


  function import_raw_chunk(chunk in raw, length in number)
           return number;
  pragma restrict_references(import_raw_chunk, wnds);


  function import_text_chunk(chunk in varchar2, length in number)
           return number;
  pragma restrict_references(import_text_chunk, wnds);


  function end_import return number;
  pragma restrict_references(end_import, wnds);


  -- grant or revoke execute via Handle methods.  Needed with system class
  -- loading since SQL grant/revoke can't manipulate permanently kept objects
  procedure set_execute_privilege(object_name   varchar2,
                                  object_schema varchar2,
                                  object_type   varchar2,
                                  grantee_name  varchar2,
                                  grant_if_nonzero number)
  as language java name
  'oracle.aurora.rdbms.DbmsJava.setExecutePrivilege(java.lang.String,
                                                    oracle.sql.CHAR,
                                                    java.lang.String,
                                                    oracle.sql.CHAR,
                                                    boolean)';
                                    
  -- convenience functions to support development environments --
  -- There procedures allow PL/SQL to get at Java Schem Objects.
  -- There are a lot of them, but they can be understood from the
  -- grammar
  --     export_<what>(name, [schema,] lob)
  --
  -- <what> is either source, class or resource
  -- name a varchar argument that is the name of the java schema object
  -- schema is an optional argument, if it is present it is a varchar that
  --   names a schema, if it ommitted the current schema is used
  -- lob is either a BLOB or CLOB.  The contents of the object are placed
  --   into it. CLOB's are allowed only for source and resource (i.e. not
  --   for class). Note that the internal representation of source uses
  --   UTF8 and that is what is stored into the BLOB
  --
  -- If the java schema object does not exist an ORA-29532 (Uncaught Java
  -- exception) will occur.


  procedure export_source(name varchar2, schema varchar2, src BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportSource(java.lang.String, java.lang.String, oracle.sql.BLOB)';

  procedure export_source(name varchar2, src BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportSource(java.lang.String, oracle.sql.BLOB)';

  procedure export_source(name varchar2, schema varchar2, src CLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportSource(java.lang.String, java.lang.String, oracle.sql.CLOB)';

  procedure export_source(name varchar2, src CLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportSource(java.lang.String, oracle.sql.CLOB)';

  procedure export_class(name varchar2, schema varchar2, clz BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportClass(java.lang.String, java.lang.String, oracle.sql.BLOB)';

  procedure export_class(name varchar2, clz BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportClass(java.lang.String, oracle.sql.BLOB)';

  procedure export_resource(name varchar2, schema varchar2, res BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportResource(java.lang.String, java.lang.String, oracle.sql.BLOB)';

  procedure export_resource(name varchar2, res BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportResource(java.lang.String, oracle.sql.BLOB)';

  procedure export_resource(name varchar2, schema varchar2, res CLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportResource(java.lang.String, java.lang.String, oracle.sql.CLOB)';

  procedure export_resource(name varchar2, res CLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportResource(java.lang.String, oracle.sql.CLOB)';

  procedure loadjava(options varchar2)
  as language java name
  'oracle.aurora.server.tools.loadjava.LoadJavaMain.serverMain(java.lang.String)';

  procedure loadjava(options varchar2, resolver varchar2)
  as language java name
  'oracle.aurora.server.tools.loadjava.LoadJavaMain.serverMain(java.lang.String, java.lang.String)';

  procedure loadjava(options varchar2, resolver varchar2, status OUT number)
  as language java name
  'oracle.aurora.server.tools.loadjava.LoadJavaMain.serverMain(java.lang.String, java.lang.String, int[])';

  procedure dropjava(options varchar2)
  as language java name
  'oracle.aurora.server.tools.loadjava.DropJavaMain.serverMain(java.lang.String)';

  -- handleMd5 accesses information about schema objects that 
  -- is needed by loadjava
  function handleMd5(s varchar2, name varchar2, type number) return raw
  as language java name
  'oracle.aurora.server.tools.loadjava.HandleMd5.get
     (java.lang.String,java.lang.String,int) return oracle.sql.RAW';

  -- variant that looks in current schema
  function handleMd5(name varchar2, type number) return raw
  as language java name
  'oracle.aurora.server.tools.loadjava.HandleMd5.get
     (java.lang.String,int) return oracle.sql.RAW';


  -- jar loading
  function start_loading_jar(name    varchar2,
                             schema  varchar2,
                             path    varchar2,
                             flags   number,
                             content blob,
                             msg out varchar2) return number
  as language java name
  'oracle.aurora.rdbms.DbmsJava.startLoadingJar
     (java.lang.String,
      java.lang.String,
      java.lang.String,
      int,
      oracle.sql.BLOB,
      java.lang.String[])
   return int';

  function finish_loading_jar(flags   number,
                              msg out varchar2) return number
  as language java name
  'oracle.aurora.rdbms.DbmsJava.finishLoadingJar
     (int,
      java.lang.String[])
   return int';

  function jar_status(name    varchar2,
                      schema  varchar2,
                      msg out varchar2) return number
  as language java name
  'oracle.aurora.rdbms.DbmsJava.jarStatus
     (java.lang.String,
      java.lang.String,
      java.lang.String[])
   return int';

  function drop_jar(name    varchar2,
                    schema  varchar2,
                    msg out varchar2) return number
  as language java name
  'oracle.aurora.rdbms.DbmsJava.dropJar
     (java.lang.String,
      java.lang.String,
      java.lang.String[])
   return int';


  -- interface to manage Security Policy Table

  -- create an active row in the policy table granting the Permission
  -- as specified to grantee.  If a row already exists granting the
  -- exact Permission specified then the table is unmodifed. 
  -- If a row exists but is disabled then it is enabled.
  -- Finally if no row exists one is inserted.
  --
  -- the table 
  -- grantee is the name of a schema
  -- permission_type is the fully qualified name of a class that
  --    extends java.lang.security.Permission.  If the class does
  --    not have a public synonymn then the name should be prefixed
  --    by <schema>:.  For example 'myschema:scott.MyPermission'.
  -- permission_name is the name of the permission
  -- permission_action is the action of the permission
  -- key is set to the key of the created row or to -1 if an
  --    error occurs.
  --
  -- See ... for more details of the Security Policy Table

  procedure grant_permission(
        grantee varchar2, permission_type varchar2, 
        permission_name varchar2, permission_action varchar2,
        key OUT number)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.grant(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String, long[])';

  -- similar to grant except create a restrict row.
  procedure restrict_permission(
        grantee varchar2, permission_type varchar2, 
        permission_name varchar2, permission_action varchar2,
        key OUT number)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.restrict(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String, long[])';


  
  -- special case for granting PolicyTablePermission's.  The name of
  -- a PolicyTablePermission allows updates of rows relating to
  -- a particular type (i.e. class that extends Permission) to 
  -- specify the class you must specify the schema containing the
  -- class. In the table that is stored as the user number, but this
  -- procedure lets it be specified via a name.
  procedure grant_policy_permission(
        grantee varchar2, 
        permisssion_schema varchar2, permission_type varchar2, 
        permission_name varchar2, 
        key OUT number)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.grantPolicyPermission(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String, long[])';

  -- The follwing versions of grant_permission, restrict_permission
  -- and grant_policy permission are identical to the previous
  -- versions except that they do not have the key OUT parameter.

  procedure grant_permission(
        grantee varchar2, permission_type varchar2, 
        permission_name varchar2, permission_action varchar2)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.grant(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String)';

  procedure restrict_permission(
        grantee varchar2, permission_type varchar2, 
        permission_name varchar2, permission_action varchar2)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.restrict(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String)';

  procedure grant_policy_permission(
        grantee varchar2, 
        permisssion_schema varchar2, permission_type varchar2, 
        permission_name varchar2)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.grantPolicyPermission(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String)';

  -- revoke disables any permissions that might have been granted
  procedure revoke_permission(
        grantee varchar2, permission_type varchar2, 
        permission_name varchar2, permission_action varchar2)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.revoke(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String)';
 
  -- enable the existing row with specified key
  procedure enable_permission(key number)
  as language java name
  'oracle.aurora.rdbms.security.PolicyTableManager.enable(long)';

  -- disable the existing row with specified key
  procedure disable_permission(key number)
  as language java name
  'oracle.aurora.rdbms.security.PolicyTableManager.disable(long)';
  
  -- delete the existing row with specified key
  -- the row must be diabled, if it is still active then this
  -- procedure does nothing.
  procedure delete_permission(key number)
  as language java name
  'oracle.aurora.rdbms.security.PolicyTableManager.delete(long)';

  -- set debugging level 
  procedure set_permission_debug(level number)
  as language java name
  'oracle.aurora.rdbms.security.PolicyTableManager.setDebugLevel(int)';
    
  -- turn byte code verifier on or off for current session
  -- 0 is off, 1 is on
  -- you need JServerPermission("Verifier") to do this operation
  procedure set_verifier(flag number) 
  as language java name
  'oracle.aurora.rdbms.Compiler.sessionOptionController(int)';
  
  function option_controller(opt number, action number) return number
  as language java name
  'oracle.aurora.rdbms.Compiler.optionController(int, int) return boolean';
  
  -- turn system class loading on or off for current session
  -- 0 is off, 1 is on
  -- you need to be running as SYS to do this operation
  procedure set_system_class_loading(flag number);

  -- The following functions are used by loadjava

  -- starts the actions of copying a file to the server.
  -- b is used repeatedly to copy chuncks.
  procedure deploy_open(filename varchar, b out BLOB) 
  as language java name 
  'oracle.aurora.server.tools.loadjava.Deploy.open(java.lang.String, oracle.sql.BLOB[])' ;

  -- copys a chunk out of the BLOB
  procedure deploy_copy(b BLOB) 
  as language java name 'oracle.aurora.server.tools.loadjava.Deploy.copy(oracle.sql.BLOB)';

  -- invokes the a deployed class
  function deploy_invoke(schema varchar, classname varchar) return varchar
  as language java name 'oracle.aurora.server.tools.loadjava.Deploy.invoke(java.lang.String, java.lang.String) return java.lang.String' ;

  -- start_jmx_agent: Start an agent activating OJVM JMX server and remote listener.
  -- The JMX server starts as a collection of daemon threads in the current session.
  -- The session is expected to run with JMXSERVER role or a superset, otherwise
  -- JMX-related security exceptions will be raised.
  -- Arguments:
  -- port   the port for the JMX listener,
  --        the value for the property com.sun.management.jmxremote.port 
  -- ssl    the value for the property com.sun.management.jmxremote.ssl
  -- auth   the value for the property com.sun.management.jmxremote.authenticate
  -- Each argument can be null or omitted, with null as default. 
  -- When an argument is null, the corresponding property is not altered, 
  -- holding the value, if any, previously present in the session.
  -- These three and other JMX-related properties can be configured in a session prior
  -- to a call to start_jmx_agent by means of dbms_java.set_property.
  -- Examples:
  --   start_jmx_agent('9999', 'false', 'false')
  --      start JMX server and listener on port 9999 with no SSL and no authentication
  --   start_jmx_agent('9999')
  --      start JMX server and listener on port 9999 with the other JMX settings
  --      having the default values or the values set using dbms_java.set_property 
  --      earlier in the same session
  --   start_jmx_agent
  --      start JMX server and listener with the JMX settings
  --      having the default values or the values set using dbms_java.set_property 
  --      earlier in the same session
  procedure start_jmx_agent(port VARCHAR2 default NULL, 
                            ssl  VARCHAR2 default NULL, 
                            auth VARCHAR2 default NULL);

  -- Send command chunks to shell
  procedure send_command (chunk long raw);

  -- Get reply chunks  from shell
  function get_reply return long raw;

  -- add a preference to the database
  -- user     user schema name
  -- type     U for user or S for system
  -- abspath  absolute path of the preference
  -- key      key for value lookup
  -- value    value to be stored (string) 
  procedure set_preference(user varchar2,type varchar2, abspath varchar2,
                           key varchar2, value varchar2);

  function ncomp_status_msg return VARCHAR2 as language java name
  'oracle.aurora.rdbms.DbmsJava.ncompEnabledMsg() return java.lang.String';

  function full_ncomp_enabled return VARCHAR2;

  function get_ojvm_property(propstring VARCHAR2) return VARCHAR2 as language
  java name 'java.lang.System.getProperty(java.lang.String) 
  return java.lang.String';

  function getVersion return VARCHAR2;

  procedure dbms_feature_ojvm(ojvm_boolean    OUT NUMBER,
                              aux_count       OUT NUMBER,
                              ojvm_info       OUT CLOB); 

  procedure dbms_feature_system_ojvm(ojvm_boolean    OUT NUMBER,
                                     aux_count       OUT NUMBER,
                                     ojvm_info       OUT CLOB); 

  procedure set_runtime_exec_credentials(dbuser varchar2, 
                                         osuser varchar2, 
                                         ospass varchar2);
end;
/


--
-- definers-rights functions and procedures should live here
--
create or replace package dbms_java_definers authid definer as

  FUNCTION get_nth_native_compiler_option(n number) return VARCHAR2;


  -- sets a native-compiler option to the specified value for the
  -- given schema
  PROCEDURE set_native_compiler_option_(optionName VARCHAR2,
                                        value VARCHAR2,
                                        owner NUMBER);

  -- decode, into a user-readable format, a persisted native-compiler
  -- option.  This function is not intended to be used by users
  -- directly
  FUNCTION decode_native_compiler_option_(optionName VARCHAR2,
                                          value      VARCHAR2) RETURN VARCHAR2;

  -- unsets a native-compiler option given by the tuple
  --   [optionName, value] for the given schema
  --
  -- if the option given by optionName is not allowed to have
  -- duplicate values, then the value is ignored.
  PROCEDURE unset_native_compiler_option_(optionName VARCHAR2,
                                          value      VARCHAR2,
                                          owner      NUMBER);

  -- compile all methods defined by the class identified by
  -- classname in the supplied schema.
  -- return the number of methods successfully compiled
  --
  -- If the class does not exist in the schema, or the schema does not
  -- exist, an ORA-29532 (Uncaught Java exception) will occur.
  FUNCTION compile_class_(schema    VARCHAR2,
                          classname VARCHAR2) return NUMBER;

  -- compile the method specified by name and Java type signature
  -- defined by the class identified by classname in the supplied
  -- schema.  
  -- return the number of methods successfully compiled
  --
  -- If the class does not exist in the schema, or the schema does not
  -- exist, an ORA-29532 (Uncaught Java exception) will occur.
  FUNCTION compile_method_(schema     VARCHAR2,
                           classname  VARCHAR2,
                           methodname VARCHAR2,
                           methodsig  VARCHAR2) return NUMBER;

  -- uncompile all methods defined by the class identified by
  -- classname in the supplied schema.  
  --
  -- return the number of methods successfully uncompiled.
  --
  -- If permanentp, then mark these methods as permanently dynamicaly
  -- un-compilable, otherwise, they are eligible for future dynamic
  -- recompilation.
  --
  -- If the class does not exist in the schema, or the schema does not
  -- exist an ORA-29532 (Uncaught Java exception) will occur.
  FUNCTION uncompile_class_(schema    VARCHAR2,
                            classname VARCHAR2,
                            permanentp NUMBER) return NUMBER;

  -- uncompile the method specified by the name and Java type
  -- signature defined by the class identified by classname in the
  -- supplied schema.
  --
  -- return the number of methods successfully uncompiled.
  --
  -- If permanentp, then mark the method as permanently dynamicaly
  -- un-compilable, otherwise, it is eligible for future dynamic
  -- recompilation.
  --
  -- If the class does not exist in the schema, or the schema does not
  -- exist an ORA-29532 (Uncaught Java exception) will occur.
  FUNCTION uncompile_method_(schema     VARCHAR2,
                             classname  VARCHAR2,
                             methodname VARCHAR2,
                             methodsig  VARCHAR2,
                             permanentp NUMBER) return NUMBER;
end;
/


-- package defining api to java$jvm$rjbc
create or replace package jvmrjbc as
function init return VARCHAR2;
procedure putpath(sessid VARCHAR2, pathname VARCHAR2);
function getlob(sessid VARCHAR2) return BLOB;
function getpath(sessid VARCHAR2) return VARCHAR2;
procedure putlob(sessid VARCHAR2, l BLOB);
procedure done(sessid VARCHAR2);
end;
/

create or replace package body dbms_java as

  -- runjava back channel state
  rjbc_sessid VARCHAR2(100);
  rjbc_toclient VARCHAR2(120);
  rjbc_fromclient VARCHAR2(120);
  rjbc_client_started BOOLEAN;
  rjbc_action NUMBER;
  rjbc_flags NUMBER;

  PROCEDURE start_btl as language java name
    'oracle.aurora.perf.OracleBTL.startBTL()';

  PROCEDURE stop_btl as language java name
    'oracle.aurora.perf.OracleBTL.stopBTL()';

  PROCEDURE terminate_btl as language java name
    'oracle.aurora.perf.OracleBTL.terminateBTL()';

  FUNCTION init_btl(files_prefix VARCHAR2, type NUMBER,
                    sample_limit NUMBER, exclude_java NUMBER) return NUMBER as language java name
  'oracle.aurora.perf.OracleBTL.initBTL(java.lang.String, int, long, boolean)
          return boolean';

  FUNCTION compile_class(classname VARCHAR2) return NUMBER as 
    begin
      return dbms_java_definers.compile_class_(sys_context('userenv', 'current_schema'), 
                                               classname);
    end;

  FUNCTION compile_method(classname  VARCHAR2,
                          methodname VARCHAR2,
                          methodsig  VARCHAR2) return NUMBER as
    begin
      return dbms_java_definers.compile_method_(sys_context('userenv', 'current_schema'), 
                                                classname, methodname, 
                                                methodsig);
    end;

  FUNCTION uncompile_class(classname VARCHAR2,
                           permanentp NUMBER default 0) return NUMBER as
    begin
      -- call-specs can't have default params
      return dbms_java_definers.uncompile_class_(sys_context('userenv', 'current_schema'), 
                                                 classname, permanentp);
    end;

  FUNCTION uncompile_class(schema    VARCHAR2,
                           classname VARCHAR2,
                           permanentp NUMBER default 0) return NUMBER as
    begin
      -- call-specs can't have default params
      return dbms_java_definers.uncompile_class_(schema, classname, permanentp);
    end;


  FUNCTION uncompile_method(classname  VARCHAR2,
                            methodname VARCHAR2,
                            methodsig  VARCHAR2,
                            permanentp NUMBER default 0) return NUMBER as
    begin
      -- call-specs can't have default params
      return dbms_java_definers.uncompile_method_(sys_context('userenv', 'current_schema'), 
                                                  classname, methodname, 
                                                  methodsig, permanentp);
    end;

  FUNCTION uncompile_method(schema     VARCHAR2,
                            classname  VARCHAR2,
                            methodname VARCHAR2,
                            methodsig  VARCHAR2,
                            permanentp NUMBER default 0) return NUMBER as
    begin
      -- call-specs can't have default params
      return dbms_java_definers.uncompile_method_(schema, classname, 
                                                  methodname, methodsig, 
                                                  permanentp);
    end;

  PROCEDURE dump_native_machine_code(classname  VARCHAR2,
                                     methodname VARCHAR2,
                                     methodsig  VARCHAR2) as language java name
    'oracle.aurora.vm.OracleRuntime.dumpNativeMachineCode(java.lang.String,
                                                          java.lang.String,
                                                          java.lang.String)';

  FUNCTION native_compiler_options return compiler_option_type_table pipelined as 
    opstr  varchar2(4000);
    token  varchar2(4000);
    newline constant varchar2(2) := chr(10);
    opidx  number;
    lastidx   number;
    idx    number;
    n      number;
    line   compiler_option_type;
  begin
    opidx := 0;
    opstr := dbms_java_definers.get_nth_native_compiler_option(opidx);
    while opstr is not null loop
      idx := instr(opstr, newline);
      lastidx := 0;
      while idx <> 0 loop
        token := substr(opstr, lastidx + length(newline), idx - lastidx - length(newline));
        lastidx := idx;
        line.option_line := token;
        PIPE ROW(line);
        idx := instr(opstr, newline, idx + length(newline));
      end loop;
  
      opidx := opidx + 1;
      opstr := dbms_java_definers.get_nth_native_compiler_option(opidx);
    end loop;
  end;

  PROCEDURE set_native_compiler_option(optionName VARCHAR2,
                                       value VARCHAR2) as
    begin
      dbms_java_definers.set_native_compiler_option_(optionName, 
                                                     value,  
                                                     sys_context('userenv','current_schemaid'));
    end;


  PROCEDURE unset_native_compiler_option(optionName VARCHAR2,
                                         value      VARCHAR2) as
    begin
      dbms_java_definers.unset_native_compiler_option_(optionName, 
                                                       value,  
                                                       sys_context('userenv','current_schemaid'));
    end;

  FUNCTION decode_native_compiler_option(optionName VARCHAR2,
                                         value      VARCHAR2) RETURN VARCHAR2 as 
    begin
      return dbms_java_definers.decode_native_compiler_option_(optionName, value);
    end;


  FUNCTION longname (shortname VARCHAR2) RETURN VARCHAR2 as language java name
    'oracle.aurora.rdbms.DbmsJava.longNameForSQL(java.lang.String)
          return java.lang.String';

  FUNCTION shortname (longname VARCHAR2) RETURN VARCHAR2 as language java name
     'oracle.aurora.rdbms.DbmsJava.shortName(java.lang.String)
           return java.lang.String';

  FUNCTION get_compiler_option(what VARCHAR2, optionName VARCHAR2)
    RETURN varchar2
    as language java name 
    'oracle.aurora.jdkcompiler.CompilerOptions.get(java.lang.String, java.lang.String) return java.lang.String' ;

  PROCEDURE set_compiler_option(what VARCHAR2, optionName VARCHAR2, value VARCHAR2)
  as language java name
  'oracle.aurora.jdkcompiler.CompilerOptions.set(java.lang.String, java.lang.String, java.lang.String)' ;


  PROCEDURE reset_compiler_option(what VARCHAR2, optionName VARCHAR2)
  as language java name
  'oracle.aurora.jdkcompiler.CompilerOptions.reset(java.lang.String, java.lang.String)' ;


  FUNCTION initGetSourceChunks (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
    RETURN NUMBER as language java name
     'oracle.aurora.rdbms.DbmsJava.initGetSourceChunks(java.lang.String,
                                                       oracle.sql.CHAR,
                                                       java.lang.String)
           return int';

  FUNCTION getSourceChunk RETURN VARCHAR2 as language java name
     'oracle.aurora.rdbms.DbmsJava.getSourceChunk() return oracle.sql.CHAR';

  FUNCTION resolver (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN VARCHAR2 as language java name
     'oracle.aurora.rdbms.DbmsJava.resolver(java.lang.String,
                                            oracle.sql.CHAR,
                                            java.lang.String)
             return oracle.sql.CHAR';
 
  FUNCTION derivedFrom (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN VARCHAR2 as language java name
     'oracle.aurora.rdbms.DbmsJava.derivedFrom(java.lang.String,
                                               oracle.sql.CHAR,
                                               java.lang.String)
             return java.lang.String';

  FUNCTION sharedPrivateClassName (name VARCHAR2)
     RETURN VARCHAR2 as language java name
     'oracle.aurora.rdbms.DbmsJava.sharedPrivateClassName(java.lang.String)
             return java.lang.String';

  FUNCTION fixed_in_instance (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN NUMBER as language java name
     'oracle.aurora.rdbms.DbmsJava.fixedInInstance(java.lang.String,
                                                   oracle.sql.CHAR,
                                                   java.lang.String)
             return boolean';

  PROCEDURE set_fixed_in_instance (name VARCHAR2, owner VARCHAR2,
                                   type VARCHAR2, value NUMBER)
     as language java name
     'oracle.aurora.rdbms.DbmsJava.setFixedInInstance(java.lang.String,
                                                      oracle.sql.CHAR,
                                                      java.lang.String,
                                                      boolean)';

  -- RUNJAVA interface
  FUNCTION runjava(cmdline VARCHAR2) RETURN VARCHAR2 as
    begin
      return dbms_java_test.funcall('-runjava', ' ', cmdline,
                                    rjbc_sessid, rjbc_flags);
    end;

  FUNCTION runjava_in_current_session(cmdline VARCHAR2) RETURN VARCHAR2 as
    begin
      return dbms_java_test.funcall('-runjava', ' ', cmdline,
                                    rjbc_sessid, rjbc_flags, 'x');
    end;

  FUNCTION endsession RETURN VARCHAR2 as
    begin
      return dbms_java_test.funcall('-endsession', ' ');
    end;

  FUNCTION endsession_and_related_state RETURN VARCHAR2 as
    begin
      return dbms_java_test.funcall('-endsession', ' ', 'x');
    end;

  FUNCTION set_property(name VARCHAR2, value VARCHAR2) RETURN VARCHAR2 as
    begin
      return dbms_java_test.funcall('-setprop', ' ', name, value);
    end;

  FUNCTION get_property(name VARCHAR2) RETURN VARCHAR2 as
    begin
      return dbms_java_test.funcall('-getprop', ' ', name);
    end;

  FUNCTION remove_property(name VARCHAR2) RETURN VARCHAR2 as
    begin
      return dbms_java_test.funcall('-setprop', ' ', name, '', 'x');
    end;

  FUNCTION show_property(name VARCHAR2) RETURN VARCHAR2 as
    begin
      return dbms_java_test.funcall('-showprop', ' ', name);
    end;

  -- Methods for controlling destination of java output
  PROCEDURE set_output (buffersize NUMBER) as
     junk varchar2(20);
     sz number := buffersize;
     begin
       if sz <= 0 then sz := 20000; end if;
       if sz > 1000000 then sz := 1000000; end if;
       dbms_output.enable(sz);
       junk := set_output_to_sql('dbout',
                                 'begin dbms_output.put_line(:1);end;',
                                 'TEXT',
                                 'begin dbms_output.put(:1);end;',
                                 'TEXT',
                                 'begin dbms_output.new_line;end;',
                                 ' ',
                                 255,
                                 eager => 1);
     end;

  FUNCTION set_output_to_sql (id VARCHAR2,
                              stmt VARCHAR2,
                              bindings VARCHAR2,
                              no_newline_stmt VARCHAR2 default null,
                              no_newline_bindings VARCHAR2 default null,
                              newline_only_stmt VARCHAR2 default null,
                              newline_only_bindings VARCHAR2 default null,
                              maximum_line_segment_length NUMBER default 0,
                              allow_replace NUMBER default 1,
                              from_stdout NUMBER default 1,
                              from_stderr NUMBER default 1,
                              include_newlines NUMBER default 0,
                              eager NUMBER default 0) return VARCHAR2 as
    flags number := 0;
    replace number := allow_replace;
    maxlen number := maximum_line_segment_length;
  begin
    if id is null then return 'ID must not be null'; end if;
    if length(id) > 30 then
      return 'ID length must not be greater than 30'; end if;
    if stmt is null then return 'STMT must not be null'; end if;
    if bindings is null then return 'BINDINGS must not be null'; end if;
    if allow_replace !=0 then replace := 1; end if;
    if from_stdout != 0 then flags := flags + 1; end if;
    if from_stderr != 0 then flags := flags + 2; end if;
    if flags = 0 then
      return 'one of FROM_STDOUT or FROM_STDERR must be true (non zero)';
    end if;
    if eager != 0 then flags := flags + 4; end if;
    if include_newlines != 0 then flags := flags + 8; end if;
    if maxlen is null then maxlen := 0; end if;
    if maxlen < 0 or maxlen != floor(maxlen) then
      return 'MAXIMUM_LINE_SEGMENT_LENGTH must be a non zero integer'; end if;

    return dbms_java_test.funcall('-set_output_to_sql', ' ',
                                  id,
                                  replace,
                                  stmt,
                                  bindings,
                                  no_newline_stmt,
                                  no_newline_bindings,
                                  newline_only_stmt,
                                  newline_only_bindings,
                                  maximum_line_segment_length,
                                  flags);
  end;

  FUNCTION remove_output_to_sql (id VARCHAR2) return VARCHAR2 as
  begin
    return dbms_java_test.funcall('-remove_output_to_sql', ' ', id);
  end;

  FUNCTION enable_output_to_sql (id VARCHAR2) return VARCHAR2 as
  begin
    return dbms_java_test.funcall('-enable_output_to_sql', ' ', id);
  end;

  FUNCTION disable_output_to_sql (id VARCHAR2) return VARCHAR2 as
  begin
    return dbms_java_test.funcall('-disable_output_to_sql', ' ', id);
  end;

  FUNCTION query_output_to_sql (id VARCHAR2) return VARCHAR2 as
  begin
    return dbms_java_test.funcall('-query_output_to_sql', ' ', id);
  end;

  FUNCTION set_output_to_java_ (id VARCHAR2,
                               class_name VARCHAR2,
                               class_schema VARCHAR2,
                               method VARCHAR2,
                               bindings VARCHAR2,
                               no_newline_method VARCHAR2 default null,
                               no_newline_bindings VARCHAR2 default null,
                               newline_only_method VARCHAR2 default null,
                               newline_only_bindings VARCHAR2 default null,
                               maximum_line_segment_length NUMBER default 0,
                               allow_replace NUMBER default 1,
                               from_stdout NUMBER default 1,
                               from_stderr NUMBER default 1,
                               include_newlines NUMBER default 0,
                               eager NUMBER default 0,
                               initialization_statement VARCHAR2 default null,
                               finalization_statement VARCHAR2 default null,
                               call_type NUMBER)
         return VARCHAR2 as
    flags number := 0;
    replace number := allow_replace;
    maxlen number := maximum_line_segment_length;
  begin
    if id is null then return 'ID must not be null'; end if;
    if call_type != 1 and substr(ID, 1, 4) = '_tf_' then
      return 'ID must not begin with ''_tf_'''; end if;
    if length(id) > 30 then
      return 'ID length must not be greater than 30'; end if;
    if class_name is null then return 'CLASS_NAME must not be null'; end if;
    if method is null then return 'METHOD must not be null'; end if;
    if bindings is null then return 'BINDINGS must not be null'; end if;
    if allow_replace !=0 then replace := 1; end if;
    if from_stdout != 0 then flags := flags + 1; end if;
    if from_stderr != 0 then flags := flags + 2; end if;
    if flags = 0 then
      return 'one of FROM_STDOUT or FROM_STDERR must be true (non zero)';
    end if;
    if eager != 0 then flags := flags + 4; end if;
    if include_newlines != 0 then flags := flags + 8; end if;
    if maxlen is null then maxlen := 0; end if;
    if maxlen < 0 or maxlen != floor(maxlen) then
      return 'MAXIMUM_LINE_SEGMENT_LENGTH must be a non zero integer'; end if;

    return dbms_java_test.funcall('-set_output_to_java', ' ',
                                  id,
                                  replace,
                                  class_name,
                                  class_schema,
                                  method,
                                  bindings,
                                  no_newline_method,
                                  no_newline_bindings,
                                  newline_only_method,
                                  newline_only_bindings,
                                  maximum_line_segment_length,
                                  flags,
                                  initialization_statement,
                                  finalization_statement);
  end;

  FUNCTION set_output_to_java (id VARCHAR2,
                               class_name VARCHAR2,
                               class_schema VARCHAR2,
                               method VARCHAR2,
                               bindings VARCHAR2,
                               no_newline_method VARCHAR2 default null,
                               no_newline_bindings VARCHAR2 default null,
                               newline_only_method VARCHAR2 default null,
                               newline_only_bindings VARCHAR2 default null,
                               maximum_line_segment_length NUMBER default 0,
                               allow_replace NUMBER default 1,
                               from_stdout NUMBER default 1,
                               from_stderr NUMBER default 1,
                               include_newlines NUMBER default 0,
                               eager NUMBER default 0,
                               initialization_statement VARCHAR2 default null,
                               finalization_statement VARCHAR2 default null)
         return VARCHAR2 as
  begin
    return set_output_to_java_ (id,
                               class_name,
                               class_schema,
                               method,
                               bindings,
                               no_newline_method,
                               no_newline_bindings,
                               newline_only_method,
                               newline_only_bindings,
                               maximum_line_segment_length,
                               allow_replace,
                               from_stdout,
                               from_stderr,
                               include_newlines,
                               eager,
                               initialization_statement,
                               finalization_statement,
                               0);
  end;

  FUNCTION enable_output_to_java (id VARCHAR2) return VARCHAR2 as
  begin
    return dbms_java_test.funcall('-enable_output_to_java', ' ', id);
  end;

  FUNCTION disable_output_to_java (id VARCHAR2) return VARCHAR2 as
  begin
    return dbms_java_test.funcall('-disable_output_to_java', ' ', id);
  end;

  FUNCTION remove_output_to_java (id VARCHAR2) return VARCHAR2 as
  begin
    return dbms_java_test.funcall('-remove_output_to_java', ' ', id);
  end;

  FUNCTION query_output_to_java (id VARCHAR2) return VARCHAR2 as
  begin
    return dbms_java_test.funcall('-query_output_to_java', ' ', id);
  end;

  FUNCTION set_output_to_file (id VARCHAR2,
                               file_path VARCHAR2,
                               allow_replace NUMBER default 1,
                               from_stdout NUMBER default 1,
                               from_stderr NUMBER default 1)
         return VARCHAR2 as
    full_id varchar2(30);
  begin
    if id is null then return 'ID must not be null'; end if;
    if file_path is null then return 'FILE_PATH must not be null'; end if;
    if length(id) > 26 then
      return 'ID length must not be greater than 26'; end if;
    full_id := '_tf_'||id;
    return set_output_to_java_(full_id,
                               'oracle/aurora/rdbms/DbmsJava',
                               null,
                               'writeOutputToFile',
                               'ID TEXT',
                               null,
                               null,
                               null,
                               null,
                               0,
                               allow_replace,
                               from_stdout,
                               from_stderr,
                               1,
                               0,
                               'call dbms_java.initialize_output_to_file('||
                                  sys.dbms_assert.enquote_literal(full_id) ||','||
                                  sys.dbms_assert.enquote_literal(file_path) ||')',
                               'call dbms_java.finalize_output_to_file('||
                                  sys.dbms_assert.enquote_literal(full_id) ||')',
                               1);
  end;

  FUNCTION remove_output_to_file (id VARCHAR2) return VARCHAR2 as
  begin
    return remove_output_to_java('_tf_'||id);
  end;

  FUNCTION enable_output_to_file (id VARCHAR2) return VARCHAR2 as
  begin
    return enable_output_to_java('_tf_'||id);
  end;

  FUNCTION disable_output_to_file (id VARCHAR2) return VARCHAR2 as
  begin
    return disable_output_to_java('_tf_'||id);
  end;

  FUNCTION query_output_to_file (id VARCHAR2) return VARCHAR2 as
  begin
    return query_output_to_java('_tf_'||id);
  end;

  PROCEDURE initialize_output_to_file (id VARCHAR2, path VARCHAR2) as
    language java name
    'oracle.aurora.rdbms.DbmsJava.initializeOutputToFile(java.lang.String,
                                                         java.lang.String)';

  PROCEDURE finalize_output_to_file (id VARCHAR2) as
    language java name
    'oracle.aurora.rdbms.DbmsJava.finalizeOutputToFile(java.lang.String)';


  PROCEDURE enable_output_to_trc as
    trash varchar2(100) :=
      dbms_java_test.funcall('-output_to_trc', ' ', 'ENABLE');
  begin
    null;
  end;

  PROCEDURE disable_output_to_trc as
    trash varchar2(100) :=
      dbms_java_test.funcall('-output_to_trc', ' ', 'DISABLE');
  begin
    null;
  end;

  FUNCTION query_output_to_trc return VARCHAR2 as
  begin
    return dbms_java_test.funcall('-output_to_trc', ' ', 'QUERY');
  end;

  -- support for calling runjava from ojvmjava

  -- private subroutines
  procedure rjbc_send(pipename VARCHAR2) as
    s integer := dbms_pipe.send_message(pipename);
    begin
      if s <> 0 then
         raise_application_error(-20000,
                                 'rjbc_send pipe error:' || to_char(s));
      end if;
    end;

  procedure rjbc_receive(pipename VARCHAR2) as
    s integer := dbms_pipe.receive_message(pipename);
    begin
      if s <> 0 then
         raise_application_error(-20000,
                                 'rjbc_receive pipe error:' || to_char(s));
      end if;
    end;

  -- rjbc_ack: acknowledge client's startup message if not previously done
  procedure rjbc_ack as
    begin
      if not rjbc_client_started then
        rjbc_receive(rjbc_fromclient);
        dbms_pipe.reset_buffer;
        rjbc_client_started := true;
      end if;
    end;

  procedure rjbc_set_pipe_names as
  begin
      rjbc_toclient := rjbc_sessid||'_TO_CLIENT';
      rjbc_fromclient := rjbc_sessid||'_FROM_CLIENT';
  end;

  -- entrypoints for runjava session

  -- rjbc_init: setup back channel, return id that identifies it.  Called
  -- prior to runjava in the same session as runjava will run in.
  -- flags non zero means dont use back channel for file content
  -- this corresponds to the ojvmjava runjava mode server_file_system
  function rjbc_init(flags NUMBER) return VARCHAR2 as
    trash VARCHAR2(100);
  begin
    loop
      rjbc_sessid := jvmrjbc.init;
      rjbc_set_pipe_names;
      begin
        trash := dbms_pipe.remove_pipe(rjbc_toclient);
        trash := dbms_pipe.remove_pipe(rjbc_fromclient);
        trash := dbms_pipe.create_pipe(rjbc_toclient, private => true);
        trash := dbms_pipe.create_pipe(rjbc_fromclient, private => true);
        exit;
      exception when others then
        if sqlcode not in (-23322) then raise; end if;
        begin
          trash := dbms_pipe.remove_pipe(rjbc_toclient);
        exception when others then
          null;
        end;
        begin
          trash := dbms_pipe.remove_pipe(rjbc_fromclient);
        exception when others then
          null;
        end;
        jvmrjbc.done(rjbc_sessid);
      end;
    end loop;
    rjbc_flags := flags;
    rjbc_client_started := false;
    
    dbms_pipe.purge(rjbc_toclient);
    dbms_pipe.purge(rjbc_fromclient);
    trash :=
    remove_output_to_sql('___rjbc');
    trash :=
    set_output_to_sql('___rjbc',
                      'begin dbms_java.rjbc_output(:1,:2);end;',
                      'TEXT NL');
    return rjbc_sessid;
  end;

  -- rjbc_request: called from runjava to ask for the contents of
  -- the file identified by pathname on the client filesystem.  Puts pathname 
  -- in the java$jvm$rjbc row then waits for client response.
  -- rtype is not used.
  -- status returned is 0 if the file was found, non-zero otherwise.
  -- lob is returned containing the file content.
  function rjbc_request(pathname VARCHAR2, rtype NUMBER, lob out BLOB)
    return NUMBER as
    status NUMBER;
  begin
    rjbc_ack;
    jvmrjbc.putpath(rjbc_sessid, pathname);
    dbms_pipe.pack_message(rtype);
    rjbc_send(rjbc_toclient);
    rjbc_receive(rjbc_fromclient);
    dbms_pipe.unpack_message(status);
    if status = 0 and rtype = 0 then
      lob := jvmrjbc.getlob(rjbc_sessid);
    end if;
    return status;
  end;

  -- rjbc_normalize: called from runjava to ask for the normalized, absolute
  -- pathname on the client filesystem of the file identified by the input
  -- argument pathname.  Puts pathname in the java$jvm$rjbc row then waits 
  ---for client response.
  -- rtype is not used.
  -- status returned is 0 if the file is a directory, non-zero otherwise.
  -- This value is also not used.
  -- normalized_pathname is returned containing the normalized path.
  function rjbc_normalize(pathname VARCHAR2, rtype NUMBER,
                          normalized_pathname out VARCHAR2)
    return NUMBER as
    status NUMBER;
  begin
    rjbc_ack;
    jvmrjbc.putpath(rjbc_sessid, pathname);
    dbms_pipe.pack_message(rtype);
    rjbc_send(rjbc_toclient);
    rjbc_receive(rjbc_fromclient);
    dbms_pipe.unpack_message(status);
    normalized_pathname := jvmrjbc.getpath(rjbc_sessid);
    return status;
  end;

  -- rjbc_output: set_output_to_sql entrypoint used by runjava to pass
  -- output back to the client.
  -- Puts text in the java$jvm$rjbc row then waits for client response.
  procedure rjbc_output(text VARCHAR2, nl NUMBER) as
    trash number;
  begin
    rjbc_ack;
    jvmrjbc.putpath(rjbc_sessid, text);
    if nl = 0 then
      dbms_pipe.pack_message(3);
    else
      dbms_pipe.pack_message(2);
    end if;
    rjbc_send(rjbc_toclient);
    rjbc_receive(rjbc_fromclient);
    dbms_pipe.unpack_message(trash);
  end;

  -- rjbc_done: called from client to shutdown back channel
  procedure rjbc_done(id VARCHAR2 := null) as
    trash VARCHAR2(100);
  begin
    if id is not null then
      rjbc_sessid := id;
      rjbc_set_pipe_names;
      rjbc_client_started := true;
    end if;
    rjbc_ack;
    dbms_pipe.pack_message(-1);
    rjbc_send(rjbc_toclient);
    trash := dbms_pipe.remove_pipe(rjbc_toclient);
    trash := dbms_pipe.remove_pipe(rjbc_fromclient);
    jvmrjbc.done(rjbc_sessid);
    trash :=
    remove_output_to_sql('___rjbc');
    rjbc_sessid := null;
  end;

  -- back channel entrypoint
  -- rjbc_respond. Called in loop by back channel client thread to respond
  -- to requests queued by rjbc_request, rjbc_normalize and rjbc_output.  
  -- status argument indicates result of processing the previous request.
  -- status values are: -1 = initial call (there was no previous request)
  --                     0 = file content found and returned
  --                     1 = file not found
  -- p in argument receives the normalized path for an rjbc_normalize request
  -- l in argument receives the lob containing the file content for an
  -- rjbc_request request.
  -- return values indicate the kind of the new request.  These values are:
  --   -1 = no request (ie, time to exit)
  --    0 = file content (rjbc_request)
  --    1 = normalize path (rjbc_normalize)
  --    2 = newline terminated output (rjbc_output)
  --    3 = nonnewline terminated output (rjbc_output)
  -- For return values 0 and 1, the p out argument contains the name of the
  -- file to be processed.  For return values 2 and 3 p contains the text
  -- to be output.
  function rjbc_respond(sid VARCHAR2, status NUMBER, p in out VARCHAR2, l BLOB)
    return NUMBER as
  begin
    if status = -1 or rjbc_sessid is null then
      rjbc_sessid := sid;
      rjbc_set_pipe_names;
    end if;
    if status = 0 and rjbc_action = 0 then
      jvmrjbc.putlob(rjbc_sessid, l);
    end if;
    if rjbc_action = 1 then
      jvmrjbc.putpath(rjbc_sessid, p);
    end if;
    dbms_pipe.pack_message(status);
    rjbc_send(rjbc_fromclient);
    rjbc_receive(rjbc_toclient);
    dbms_pipe.unpack_message(rjbc_action);
    if rjbc_action <> -1 then
      p := jvmrjbc.getpath(rjbc_sessid);
    end if;
    return rjbc_action;
  end;

  -- import/export interface --
  function start_export(short_name in varchar2, 
                        schema in varchar2, 
                        flags in number,
                        type in number,
                        properties out number,
                        raw_chunk_count out number, 
                        total_raw_byte_count out number,
                        text_chunk_count out number, 
                        total_text_byte_count out number)
         return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         startExport(oracle.sql.CHAR, oracle.sql.CHAR,
                                     int, int, int[], int[], int[], int[],
                                     int[])
                                  return int';

  function export_raw_chunk(chunk out raw, length out number)
           return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         exportRawChunk(byte[][], int[]) return int';

  function export_text_chunk(chunk out varchar2, length out number)
           return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         exportTextChunk(oracle.sql.CHAR[], int[]) return int';

  function end_export return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.endExport() return int';

  function start_import(long_name in varchar2, 
                        flags in number,
                        type in number,
                        properties in number,
                        raw_chunk_count in number, 
                        total_raw_byte_count in number,
                        text_chunk_count in number)
         return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         startImport(oracle.sql.CHAR,
                                     int, int, int, int, int, int)
                                    return int';
  function import_raw_chunk(chunk in raw, length in number)
           return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         importRawChunk(byte[], int) return int';

  function import_text_chunk(chunk in varchar2, length in number)
           return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         importTextChunk(oracle.sql.CHAR, int) return int';

  function end_import return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.endImport() return int';


  -- call-specs can't have default params
  procedure start_jmx_agent_(port VARCHAR2, ssl VARCHAR2, auth VARCHAR2)
  as language java name 
  'oracle.aurora.rdbms.JMXAgent.startOJVMAgent(java.lang.String, java.lang.String, java.lang.String)';

  procedure start_jmx_agent(port VARCHAR2 default NULL, 
                            ssl  VARCHAR2 default NULL, 
                            auth VARCHAR2 default NULL) as
    begin
      -- call-specs can't have default params
      start_jmx_agent_(port, ssl, auth);
    end;

  -- Send command chunks to shell
  procedure send_command (chunk long raw)
  as language java name
  'oracle.aurora.server.tools.shell.ShellStoredProc.receive_command (byte[])';

  -- Get reply chunks from shell
  function get_reply return long raw
  as language java name
  'oracle.aurora.server.tools.shell.ShellStoredProc.get_reply () return byte[]';

  -- set a preference for the database
  procedure set_preference(user varchar2,type varchar2, abspath varchar2,
                           key varchar2, value varchar2)
  as language java name 
  'java.util.prefs.OraclePreferences.DbmsSetPreference(
        java.lang.String, java.lang.String, java.lang.String,
        java.lang.String, java.lang.String)';

  -- turn system class loading on or off for current session
  -- 0 is off, 1 is on
  -- you need to be running as SYS to do this operation
  procedure set_system_class_loading(flag number)
  as 
  x number := 3;
  begin
    if flag = 1 then x := 2; end if;
    x := option_controller(4, x);
  exception
  when others then
    if sqlcode not in (-29549) then raise; end if;
  end;

  function full_ncomp_enabled return VARCHAR2
  as
  -- RHLEE: 9/7/2006 disable this for now
  -- foo exception;
  -- x varchar2(100) := ncomp_status_msg;
  -- pragma exception_init(foo,-29558);
  begin
    -- if x = 'NComp status: DISABLED' then raise foo; end if;
    return 'OK';
  end;

  function getVersion return VARCHAR2 as
  begin
        return get_ojvm_property('oracle.jserver.version');
  end;

  procedure set_runtime_exec_credentials(dbuser varchar2, 
                                         osuser varchar2, 
                                         ospass varchar2)
  as
    msg varchar2(100);
  begin
    msg := dbms_java_test.funcall('-setrtexeccreds', ' ',
                                  UPPER(dbuser),
                                  osuser,
                                  ospass);
  end;

 -- OJVM version of user feature tracking procedure
  procedure dbms_feature_ojvm(ojvm_boolean    OUT NUMBER,
                              aux_count       OUT NUMBER,
                              ojvm_info       OUT CLOB) as

    TYPE data_arr is  varray(3) of INTEGER;
    TYPE user_data is table of data_arr index by varchar(30);
    ud user_data;
    owner     varchar2(30);
    otype     varchar2(30);
    tmp_info  varchar2(1000);
    cursor c1 is select owner, object_type    
                        from dba_objects where
                        (object_type='JAVA CLASS' or 
                         object_type='JAVA RESOURCE' or
                         object_type='JAVA SOURCE') and 
                        (owner != 'SYS' and owner != 'SYSTEM' and
                         owner != 'EXFSYS' and owner != 'MDSYS'
                         and owner != 'ORDSYS'); 
  begin
    aux_count := 0;
    ojvm_boolean := 0;
    tmp_info := NULL;
    open c1;
        
    loop 
      fetch c1 into owner, otype;
      exit when c1%NOTFOUND or c1%NOTFOUND is null;

-- this block will initialize the assoc array the first time it
-- is used

      begin
         if ud(owner).exists(1) then 
           null;
         end if;
      exception
        WHEN NO_DATA_FOUND THEN
          ud(owner) := data_arr(0,0,0);
      end;
        
      case 
        when otype = 'JAVA CLASS'    then ud(owner)(1) := ud(owner)(1) + 1;
        when otype = 'JAVA RESOURCE' then ud(owner)(2) := ud(owner)(2) + 1;
        when otype = 'JAVA SOURCES'  then ud(owner)(3) := ud(owner)(3) + 1;
        else null;
      end case;
    end loop;
    close c1;

    owner := ud.FIRST;
    tmp_info := 'Non-system users: ';
    while owner is not null loop
      aux_count := aux_count + ud(owner)(1) + ud(owner)(2) + ud(owner)(3);
      tmp_info := tmp_info || owner || ' with ' || 
                   ud(owner)(1) || ' classes, ' ||
                   ud(owner)(2) || ' resources, ' || 
                   ud(owner)(3) || ' sources. ';
      owner := ud.NEXT(owner);
    end loop;   

     if aux_count > 0 then
        ojvm_boolean := 1; -- we have user data;
        ojvm_info := tmp_info;
     end if;
  end;

 -- OJVM version of system feature tracking procedure
 --
 -- This procedure is problematic in that we do not
 -- know when someone adds classes to a product that 
 -- belongs to Oracle. This needs to be checked release to 
 -- release and != clauses will need to be added above to the
 -- user query.

  procedure dbms_feature_system_ojvm(ojvm_boolean    OUT NUMBER,
                                     aux_count       OUT NUMBER,
                                     ojvm_info       OUT CLOB) as
    TYPE data_arr is  varray(3) of INTEGER;
    TYPE user_data is table of data_arr index by varchar(30);
    owner     varchar2(30);
    otype     varchar2(30);
    tmp_info  varchar2(1000);
    cursor c1 is select owner, object_type    
                        from dba_objects where
                        (object_type='JAVA CLASS' or 
                         object_type='JAVA RESOURCE' or
                         object_type='JAVA SOURCE') and 
                        (owner = 'SYS' or owner = 'SYSTEM' or
                         owner = 'EXFSYS' or owner = 'MDSYS'
                         or owner = 'ORDSYS'); 
    ud user_data;
  begin
 -- this reflects the number schemas of Oracle products using java.
 -- OJVM is always installed
    ojvm_boolean := 1; -- always there.
    open c1;
    tmp_info := NULL;
    aux_count := 0;        
    loop 
      fetch c1 into owner, otype;
      exit when c1%NOTFOUND or c1%NOTFOUND is null;
-- this block will initialize the assoc array the first time it
-- is used

      begin
        if ud(owner).exists(1) then 
           null;
         end if;
      exception
        WHEN NO_DATA_FOUND THEN
          ud(owner) := data_arr(0,0,0);
      end;

      case 
      when otype = 'JAVA CLASS'    then ud(owner)(1) := ud(owner)(1) + 1;
      when otype = 'JAVA RESOURCE' then ud(owner)(2) := ud(owner)(2) + 1;
      when otype = 'JAVA SOURCES'  then ud(owner)(3) := ud(owner)(3) + 1;
      else null;
      end case;
    end loop;
    close c1;

    owner := ud.FIRST;
    tmp_info := 'System users: ';
    while owner is not null loop
      aux_count := aux_count + ud(owner)(1) + ud(owner)(2) + ud(owner)(3);
      tmp_info := tmp_info || owner || ' with ' || 
                   ud(owner)(1) || ' classes, ' ||
                   ud(owner)(2) || ' resources, ' || 
                   ud(owner)(3) || ' sources. ';
      owner := ud.NEXT(owner);
    end loop;   
    ojvm_info := tmp_info;
  end;
end;
/


CREATE PUBLIC SYNONYM dbms_java FOR dbms_java;

GRANT EXECUTE ON dbms_java TO PUBLIC;



create or replace package body dbms_java_definers as

  FUNCTION get_nth_native_compiler_option(n number) return VARCHAR2 as language java name
  'oracle.aurora.zephyr.CompilerOptions.describeOption(int) return java.lang.String';

  PROCEDURE set_native_compiler_option_(optionName VARCHAR2,
                                        value VARCHAR2,
                                        owner NUMBER) as language java name
  'oracle.aurora.zephyr.CompilerOptions.setCompilerOption(java.lang.String,java.lang.String,int)';


  FUNCTION decode_native_compiler_option_(optionName VARCHAR2,
                                          value      VARCHAR2) RETURN VARCHAR2 as language java name
  'oracle.aurora.zephyr.CompilerOptions.decodeCompilerOption(java.lang.String, java.lang.String) return java.lang.String';

  PROCEDURE unset_native_compiler_option_(optionName VARCHAR2,
                                          value      VARCHAR2,
                                          owner      NUMBER) as language java name 
  'oracle.aurora.zephyr.CompilerOptions.unsetCompilerOption(java.lang.String,java.lang.String,int)';

  FUNCTION compile_class_(schema    VARCHAR2,
                          classname VARCHAR2) return NUMBER as language java name
    'oracle.aurora.zephyr.AOTDriver.compileClass(java.lang.String, java.lang.String) return int';

  FUNCTION compile_method_(schema     VARCHAR2,
                           classname  VARCHAR2,
                           methodname VARCHAR2,
                           methodsig  VARCHAR2) return NUMBER as language java name
    'oracle.aurora.zephyr.AOTDriver.compileMethod(java.lang.String, java.lang.String, java.lang.String, java.lang.String) return int';

  FUNCTION uncompile_class_(schema    VARCHAR2,
                            classname VARCHAR2,
                            permanentp NUMBER) return NUMBER as language java name
    'oracle.aurora.zephyr.AOTDriver.uncompileClass(java.lang.String, java.lang.String, boolean) return int';


  FUNCTION uncompile_method_(schema     VARCHAR2,
                             classname  VARCHAR2,
                             methodname VARCHAR2,
                             methodsig  VARCHAR2,
                             permanentp NUMBER) return NUMBER as language java name
    'oracle.aurora.zephyr.AOTDriver.uncompileMethod(java.lang.String, java.lang.String, java.lang.String, java.lang.String, boolean) return int';

end;
/


--- The following is redundant but needed for the time being by existing
--- code, so leave it alone:

create or replace
FUNCTION dbj_long_name (shortname VARCHAR2) RETURN VARCHAR2 
as language java name
    'oracle.aurora.rdbms.DbmsJava.longNameForSQL(java.lang.String)
          return java.lang.String';
/

create or replace function "NameFromLastDDL" (longp number) return varchar2 as 
language java name 'oracle.aurora.rdbms.DbmsJava.NameFromLastDDL(boolean) return oracle.sql.CHAR';
/

CREATE PUBLIC SYNONYM "NameFromLastDDL" FOR sys."NameFromLastDDL";

GRANT EXECUTE ON "NameFromLastDDL" TO PUBLIC;


create or replace FUNCTION dbj_short_name (longname VARCHAR2)
  return VARCHAR2 as
begin
  return dbms_java.shortname(longname);
end dbj_short_name;
/

CREATE PUBLIC SYNONYM dbj_short_name FOR dbj_short_name;

GRANT EXECUTE ON dbj_short_name TO PUBLIC;

create or replace package body jvmrjbc as
function init return VARCHAR2 as
  sessid VARCHAR2(100);
begin
  loop
    begin
      sessid := dbms_pipe.unique_session_name||dbms_crypto.randombytes(35);
      insert into java$jvm$rjbc values (sessid, null, empty_blob);
      commit;
      return sessid;
    exception when others then
      if sqlcode not in (-1) then raise; end if;
    end;
  end loop;
end;

procedure putpath(sessid VARCHAR2, pathname VARCHAR2) as
begin
    update java$jvm$rjbc set path=pathname where id=sessid;
    commit;
end;

function getlob(sessid VARCHAR2) return BLOB as
      lob BLOB;
begin
      select lob into lob from java$jvm$rjbc where id=sessid;
      return lob;
end;

function getpath(sessid VARCHAR2) return VARCHAR2 as
      p VARCHAR2(4000);
begin
      select path into p from java$jvm$rjbc where id=sessid;
      return p;
end;

procedure putlob(sessid VARCHAR2, l BLOB) as
  tl BLOB;
begin
    select lob into tl from java$jvm$rjbc where id=sessid for update;
    dbms_lob.trim(tl, 0);
    dbms_lob.append(tl, l);
    commit;
end;

procedure done(sessid VARCHAR2) as
begin
    delete from java$jvm$rjbc where id=sessid;
    commit;
end;

end;
/

GRANT EXECUTE ON jvmrjbc TO PUBLIC;
