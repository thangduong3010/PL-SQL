--  this file generated mechanically from dbmsbkrs.pls
create or replace
PACKAGE dbms_backup_restore IS

  -------------
  -- Version --
  -------------

  -- Advance the min numbers whenever support is removed for old
  -- versions of the RMAN client.  Advance the max number whenever
  -- new functions are added or existing ones are changed (once per release
  -- cycle).

  protocol_version_number_min     NUMBER := 8;  -- major release number
  protocol_release_number_min     NUMBER := 0;  -- maintenance release number
  protocol_update_number_min      NUMBER := 4;  -- application release number
  protocol_component_number_min   NUMBER := 0;  -- component release number

  protocol_version_number_max     NUMBER := 11; -- major release number
  protocol_release_number_max     NUMBER := 2;  -- maintenance release number
  protocol_update_number_max      NUMBER := 0;  -- application release number
  protocol_component_number_max   NUMBER := 4;  -- component release number

  snapshot_enqueue_busy EXCEPTION;
  PRAGMA EXCEPTION_INIT(snapshot_enqueue_busy, -230);

  snapshot_name_not_set EXCEPTION;
  PRAGMA EXCEPTION_INIT(snapshot_name_not_set, -231);

  snapshot_not_made EXCEPTION;
  PRAGMA EXCEPTION_INIT(snapshot_not_made, -232);

  inconsistant_read EXCEPTION;
  PRAGMA EXCEPTION_INIT(inconsistant_read, -235);

  record_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(record_not_found, -19571);

  inc_scn_matches_df_scn EXCEPTION;
  PRAGMA EXCEPTION_INIT(inc_scn_matches_df_scn, -19648);

  file_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(file_not_found, -19625);

  file_validation_failure EXCEPTION;
  PRAGMA EXCEPTION_INIT(file_validation_failure, -19563);

  archivelog_validate_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(archivelog_validate_error, -19582);

  archivelog_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(archivelog_not_found, -19579);

  different_resetlogs EXCEPTION;
  PRAGMA EXCEPTION_INIT(different_resetlogs, -19658);

  -- following are backuppiece failover exceptions
  not_a_backup_piece EXCEPTION;
  PRAGMA EXCEPTION_INIT(not_a_backup_piece, -19608);

  corrupt_directory EXCEPTION;
  PRAGMA EXCEPTION_INIT(corrupt_directory, -19610);

  corrupt_block EXCEPTION;
  PRAGMA EXCEPTION_INIT(corrupt_block, -19599);

  cant_identify_file EXCEPTION;
  PRAGMA EXCEPTION_INIT(cant_identify_file, -19505);

  retryable_error_exp EXCEPTION;
  PRAGMA EXCEPTION_INIT(retryable_error_exp, -19624);

  -- following exceptions are used in SPFILE and controlfile restore from
  -- autobackup
  spfile_not_in_bs EXCEPTION;
  PRAGMA EXCEPTION_INIT(spfile_not_in_bs, -19687);
  scf_not_in_bs EXCEPTION;
  PRAGMA EXCEPTION_INIT(scf_not_in_bs, -19695);

  -- this exception is used in copy code
  identical_input_output_file EXCEPTION;
  PRAGMA EXCEPTION_INIT(identical_input_output_file, -19635);

  -- this exception is signaled if recovery area is not set
  ra_not_set EXCEPTION;
  PRAGMA EXCEPTION_INIT(ra_not_set, -19801);

--***************
-- Record Types
--***************
-- DO NOT add new fields to existing record definition between releases. This
-- would cause RMAN executable incompatibility because the package definition
-- is also linked into RMAN executable. Rather define new record types if
-- existing record type doesn't suite your need.
--
-- It is better to have some spare fields in existing record type so as to
-- avoid definiting new record types.
--

  --
  -- This record captures block statistics for a file validation.
  --
  TYPE blockStat_t IS RECORD
  (
     filetype    binary_integer,  -- KSFD file type
     dfnumber    number,          -- datafile number
     thread      binary_integer,  -- archived log thread
     sequence    number,          -- archived log sequence
     highscn     number,          -- highest scn found in the datafile
     examined    number,          -- total blocks examined
     corrupt     number,          -- total blocks that are marked corrupt
     empty       number,          -- total empty blocks
     data_proc   number,          -- total data blocks that are processed
     data_fail   number,          -- total data blocks that failed
     index_proc  number,          -- total index blocks that are processed
     index_fail  number,          -- total index blocks that failed
     other_proc  number,          -- total other blocks that are processed
     other_fail  number,          -- total other blocks that failed

     -- Spare fields for future
     spare1      number,
     spare2      number,
     spare3      number,
     spare4      number,
     spare5      number,
     spare6      number,
     spare7      date,
     spare8      date 
  );

  --
  -- Table of block statistics
  --
  TYPE blockStatTable_t IS TABLE OF blockStat_t INDEX BY BINARY_INTEGER;

  --
  -- Record to describe a block range
  --
  TYPE blockRange_t IS RECORD
  (
     blknumber    number,
     dfnumber     number,
     range        number,
     spare1       number,
     spare2       number,
     spare3       number
  );
     
  --
  -- Table of block ranges
  --
  TYPE blockRangeTable_t IS TABLE OF blockRange_t INDEX BY BINARY_INTEGER;


  --
  -- Package constants
  --
  MAXSCNVAL     constant number := 281474976710655;

--***************
-- Introduction
--***************
  -- This package contains the interface to the kernel for creating and
  -- restoring backups of datafiles and archived logs. Backups can exist on
  -- sequential media such as tape. The kernel will read and write backups,
  -- but it is the responsibility of the caller to catalog the names of the
  -- backups.
  --
  -- None of the procedures in this package can be executed in a Multi
  -- Threaded Server process. A connection to a dedicated server is required.
  --
  -- Many of these procedures create or retrieve records from the controlfile.
  -- Each record is given a record ID and a stamp when it is created. The
  -- record ID is a monotonically increasing integer that is incremented for
  -- each new record that is created. A different counter is used for each
  -- type of record. Only a certain number of records of each type are kept.
  -- Thus records are overwritten when they get old, but the new record will
  -- have a new record ID. The record ID should normally be unique but there
  -- is the possibility of a backup controlfile restore or a create controlfile
  -- that allows record IDs to be reused. A stamp is also allocated with every
  -- new controlfile record to ensure there is no confusion between records
  -- with the same record ID. The stamp is based on the time and date.

--*****************
-- Device control
--*****************
  -- Unlike other Oracle files, backups may be put on removable media which
  -- must be written sequentially. This may involve using a device to mount
  -- the removable media. These procedures provide an interface for controlling
  -- the device used for creating and restoring backups.

  FUNCTION deviceAllocate( type    IN  varchar2 default NULL
                          ,name    IN  varchar2 default NULL
                          ,ident   IN  varchar2 default NULL
                          ,noio    IN  boolean  default FALSE
                          ,params  IN  varchar2 default NULL )
    RETURN varchar2;

  -- Describe the device to be used for sequential I/O. For device types where
  -- only one process at a time can use a device, this call allocates a device
  -- for exclusive use by this session. The device remains allocated until
  -- deviceDeallocate is called or session termination. The device can be used
  -- both for creating and restoring backups.
  --
  -- Specifying a device allocates a context that exists until the session
  -- terminates or deviceDeallocate is called. Only one device can be specified
  -- at a time for a particular session. Thus deviceDeallocate must be called
  -- before a different device can be specified. This is not a limitation since
  -- a session can only read or write one backup at a time.
  --
  -- The other major effect of allocating a device is to specify the name space
  -- for the backup handles (file names). The handle for a sequential file does
  -- not necessarily define the type of device used to write the file. Thus it
  -- is necessary to specify the device type in order to interpret the file
  -- handle. The NULL device type is defined for all systems. It is the file
  -- system supplied by the operating system. The sequential file handles are
  -- thus normal file names.
  --
  -- A device can be specified either by name or by type.
  --    If the type is specified but not the name, the system picks an
  --    available device of that type.
  --    If the name is specified but not the type, the type is determined
  --    from the device.
  --    If neither the type or the name is given, the backups are files in
  --    the operating system file system.

  -- Note that some types of devices, optical disks for example, can be shared
  -- by many processes, and thus do not really require allocation of the device
  -- itself. However we do need to allocate the context for accessing the
  -- device, and we do need to know the device type for proper interpretation
  -- of the file handle. Thus it is always necessary to make the device
  -- allocation call before making most other calls in this package.
  --
  -- Input parameters:
  --   type
  --     If specified, this gives the type of device to use for sequential
  --     I/O. The allowed types are port specific. For example a port may
  --     support the type "TAPE" which is implemented via the Oracle tape
  --     API. If no type is specified, it may be implied by specifying a
  --     particular device name to allocate. The type should be allowed to
  --     default to NULL if operating system files are to be used.
  --
  --   name
  --     If specified, this names a particular piece of hardware to use for
  --     accessing sequential files. If not specified, any available
  --     device of the correct type will be allocated. If the device cannot
  --     be shared, it is allocated to this session for exclusive use.
  --     The name should be allowed to default to NULL if operating system
  --     files are to be used.
  --
  --   ident
  --     This is the users identifier that he uses to name this device. It
  --     is only used to report the status of this session via
  --     dbms_application_info.  This value will be placed in the CLIENT_INFO
  --     column of the V$SESSION table, in the row corresponding to the
  --     session in which the device was allocated.  This value can also
  --     be queried with the dbms_application_info.read_client_info procedure.
  --
  --   noio
  --     If TRUE, the device will not be used for doing any I/O. This allows
  --     the specification of a device type for deleting sequential files
  --     without actually allocating a piece of hardware. An allocation for
  --     noio can also be used for issuing device commands. Note that some
  --     commands may actually require a physical device and thus will get
  --     an error if the allocate was done with noio set to TRUE.
  --
  --   params
  --     This string is simply passed to the device allocate OSD. It is
  --     completely port and device specific.
  --
  -- Returns:
  --   It returns a valid device type. This is the type that should be
  --   allocated to access the same sequential files at a later date. Note
  --   that this might not be exactly the same value as the input string.
  --   The allocate OSD may do some translation of the type passed in. The
  --   return value is NULL when using operating system files.
  --
  -- Exceptions:
  --   DEVICE-TYPE-TOO-LONG (ora-19700)
  --     The device type is longer than the port-specific maximum.
  --   DEVICE-NAME-TOO-LONG (ora-19701)
  --     The device name is longer than the port-specific maximum.
  --   MULTI-THREADED-SERVER (ora-19550)
  --     This session is not connected to a dedicated server.
  --   DEVICE-ALLOCATED (ora-19568)
  --     This session already has a device allocated.
  --   ALLOCATION-FAILURE (ora-19554)
  --     The allocation failed.  Other messages should also be issued.
  --   DEVICE-BUSY (ora-19551)
  --     The requested device is allocated to another session, or no
  --     device was named,or all devices of the requested type are busy.
  --   INVALID-DEVICE-TYPE (ora-19552)
  --     The device type is not a recognized type.
  --   INVALID-DEVICE-NAME (ora-19553)
  --     The device name is not a recognized device.
  --   DEVICE-ERROR (ora-19557)
  --     The OSD returned an error.

  PROCEDURE deviceCommand( cmd     IN  varchar2
                          ,params  IN  varchar2 default NULL );

  -- Send an arbitrary command to the currently allocated device.
  -- Input parameters:
  --   cmd
  --     A text string for the command.  The syntax and semantics of the text
  --     string are completely port and device specific.
  --   params
  --     A text string for the parameters. The syntax and semantics of the text
  --     string are completely port and device specific.
  --
  -- Exceptions:
  --   DEVICE-PARM-TOO-LONG (ora-19702)
  --     The device parameter is longer than the port-specific maximum.
  --   DEVICE-COMMAND-TOO-LONG (ora-19703)
  --     The device command is longer than the port-specific maximum.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   DEVICE-ERROR (ora-19557)
  --     The OSD returned an error.
  --   DEVICE-COMMAND-ERROR (ora-19559)
  --     The command failed.  Other messages should also be issued.

  PROCEDURE deviceDeallocate( params  IN  varchar2 default NULL );

  -- Release the currently allocated device. This also cleans up the context
  -- that was created by deviceAllocate. This must be done before ending
  -- the session. The current device must be deallocated before a different
  -- one can be allocated. This may be done in the middle of a backup or
  -- restore conversation for cases where different pieces of the same backup
  -- set are on different media.
  --
  -- Input parameters:
  --   params
  --     This string is simply passed to the device deallocate OSD. It is
  --     completely port and device specific.
  --
  -- Exceptions:
  --   DEVICE-PARM-TOO-LONG (ora-19702)
  --     The device parameter is longer than the port-specific maximum.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   DEVICE-ERROR (ora-19557)
  --     The OSD returned an error. The device will still be deallocated from
  --     this package even when this error is returned. Thus a different
  --     device may then be allocated
  --   DEVICE-DEALLOCATION-ERROR (ora-19558)
  --     The command failed.  Other messages should also be issued.

  PROCEDURE deviceStatus( state     OUT  binary_integer
                         ,type      OUT  varchar2
                         ,name      OUT  varchar2
                         ,bufsz     OUT  binary_integer
                         ,bufcnt    OUT  binary_integer
                         ,kbytes    OUT  number
                         ,readrate  OUT  binary_integer
                         ,parallel  OUT  binary_integer );

    NO_DEVICE     constant binary_integer := 0;
    NO_IO_ALLOC   constant binary_integer := 1;
    EXCL_ALLOC    constant binary_integer := 2;
    CONCUR_ALLOC  constant binary_integer := 3;
    FILESYSTEM    constant binary_integer := 4;

  -- deviceStatus returns information about the currently allocated device.
  -- It is useful for informational purposes only. It can be called even if
  -- there is no device allocated. When no device is allocated the state will
  -- be NO_DEVICE and all the other values will be NULL.
  --
  -- Note that there are no exceptions since this does nothing but return
  -- information about this session.
  --
  -- Output parameters:
  --   state
  --     This defines what kind of allocation has been done. The constants
  --     have the following meanings.
  --       NO_DEVICE
  --         No device has been allocated by this session. The other output
  --         values will be NULL when this state is returned. Note that this
  --         state does not signal an error.
  --       NO_IO_ALLOC
  --         A device, or at least a device type, has been allocated, but the
  --         noio parameter was TRUE when deviceAllocate was called. It is not
  --         possible to do a backup or restore, but changeBackupPiece can be
  --         called.
  --       EXCL_ALLOC
  --         A device has been exclusively allocated to this session. This type
  --         of device can not support access by more than one session. A tape
  --         drive is typical of this kind of allocate.
  --       CONCUR_ALLOC
  --         A device has been allocated which supports multiple processes
  --         concurrently accessing its storage. A hierarchical storage manager
  --         is an example of this kind of device. The device name may be NULL
  --         for this kind of allocation since there may not be any particular
  --         piece of hardware reserved.
  --       FILESYSTEM
  --         This means that deviceAllocate was called with NULL type and name.
  --         The allocated device is the operating system's file system. This
  --         naturally allows concurrent accesses. The type and name parameters
  --         returned will both be NULL.
  --   type
  --     This is the type name of the allocated device. This may be different
  --     than the value passed in to deviceAllocate if a generic device type
  --     was converted to a specific type when the allocation was done. For
  --     example maybe the type given to deviceAllocate was 'TAPE'. This value
  --     could then be 'IBM3490'. NULL may have been given to deviceAllocate
  --     and the type determined from the device name. The returned type will
  --     be NULL only when the state is FILESYSTEM.
  --   name
  --     This is the name of the particular piece of hardware that was
  --     allocated. For device types that do not reserve particular pieces
  --     of hardware this will be NULL.
  --   bufsz
  --   bufcnt
  --     These two arguments describe the memory buffers that were allocated
  --     to do I/O to this device. If opened for noio these values will be
  --     zero. The bufsz is in bytes.
  --   kbytes
  --   readrate
  --   parallel
  --     These are the current values of the backup limits that have been set
  --     by calls to setLimit.

 --***********************************
 -- Backup Limits Setting Procedures--
--***********************************--
  -- There are a few limits that can be set to control the performance of
  -- taking a backup, and the size of each piece of the backup. The limit
  -- values are kept per session. Limits are initially set to infinity. Once
  -- changed, they persist until the device is deallocated. They may be changed
  -- at any time while a device is allocated. For each limit there is a
  -- constant that names it for the purpose of changing it. The following
  -- limits are defined.

  KBYTES     constant binary_integer := 1;
  READRATE   constant binary_integer := 2;
  PARALLEL   constant binary_integer := 3;
  DUPCNT     constant binary_integer := 4;
  DUR_EST_SECS    constant  binary_integer := 5;
  DUR_ENDTIME     constant  binary_integer := 6;
  MAX_READ_KBYTES constant  binary_integer := 7;
  SLEEP_SECS      constant  binary_integer := 8;
  DUR_SOFTENDTIME constant  binary_integer := 9;

  -- KBYTES:   The number of bytes that may be written to a backup piece.
  --
  --           It is given in units of 1024 bytes to avoid a 4 gigabyte limit.
  --           Once this number of bytes have been written, the backup piece
  --           is closed and the currently executing backupPieceCreate
  --           procedure returns control. If the backup set is not complete,
  --           the backupPieceCreate must be called again to
  --           continue the backup into another backup piece.
  --
  --           This limit is useful for cases where the size of the output
  --           media is known to the user but not to the operating system.

  -- READRATE: The number of buffers that may be read per file per second.
  --
  --           Use of this option causes the backup to limit the rate at
  --           which it reads blocks from a file. This limit has no effect if
  --           it is greater than the actual capacity. For some output devices
  --           it may be necessary to read from multiple files in order to keep
  --           the device streaming.
  --
  --           This limit is useful to prevent the backup process from
  --           consuming too much disk bandwidth, thereby degrading on-line
  --           performance.
  --
  --           Note that this limit is implemented by counting down the limit
  --           number, and check if a second has passed since the counter was
  --           last initialized. Thus the limit is only an average over one
  --           second, not enforced on every I/O.

  -- PARALLEL: The maximum number of files that will be open for reading at
  --           the same time.
  --
  --           If this limit is greater than the number of files in the backup,
  --           all files can be open for reading. Note that each open file can
  --           be read at no more than READRATE I/O's per second, so this
  --           limits the rate at which the output file can be written.
  --           This limit is useful to keep the number of open files down to a
  --           reasonable value when there are a large number of small redo
  --           logs in a backup.
  --
  --           Note that changing this value during a conversation has no
  --           effect.
  -- DUPCNT:   Duplex count for the channel. Allowed range for values is 1-4.
  -- DUR_EST_SECS : Number of seconds estimated for the backupset/copy
  --           performed on this device.
  -- DUR_ENDTIME : Time limit for the backupset/copy performed on this device.
  --               If the backup/copy could not be completed by this time,
  --               server returns an time out error. Client can extend the time
  --               and re-try the operation if required.
  -- MAX_READ_KBYTES : This limits specifies the maximum number of kilo bytes
  --               that can be read during backup/copy.
  -- SLEEP_SECS    : This is artifial time introduced during the last
  --                  backup/copy on this channel.
  -- DUR_SOFTENDTIME : Time limit for the backupset/copy after which the job
  --               can run at full speed.

  PROCEDURE setLimit( name   IN  binary_integer
                     ,value  IN  number );

  -- Set a limit to a particular value. The limit keeps this value until
  -- the current device is deallocated, or a call is made to change the limit.
  --
  -- Input parameters:
  --   name
  --     The limit number to set. Valid limit numbers are the constants above.
  --   value
  --     The value of the limit.
  -- Exceptions:
  --   INVALID-LIMIT-NUMBER (ora-19560)
  --     An invalid limit number was specified.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   DEVICE-BUSY (ora-19551)
  --     The requested device is allocated to another session,
  --     or all devices of the requested type are busy.
  --   DEVICE-ERROR (ora-19557)
  --     The OSD returned an error.

  PROCEDURE reInit;

  -- Reset all limits to infinity.
  --
  -- Exceptions:
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.


 --********************************************
 -- Backup Conversation Initiation Procedures--
 --*******************************************--

  -- A backup conversation is a sequence of calls to create a backup of
  -- one or more files. The files may be either archived redo logs or
  -- datafiles. A controlfile may be included in a datafile backup. The backup
  -- consists of one or more sequential files called backup pieces. The pieces
  -- taken together make a backup set. A successful backup conversation
  -- consists of the following phases:
  --   1) Start conversation specifying the type of backup.
  --   2) Name the files that go into the backup.
  --   3) Create each piece of the backup.
  --   4) Collect data on the contents of the backup.

  PROCEDURE backupSetDataFile( set_stamp     OUT  number
                              ,set_count     OUT  number
                              ,nochecksum    IN   boolean         default FALSE
                              ,tag           IN   varchar2        default NULL
                              ,incremental   IN   boolean         default FALSE
                              ,backup_level  IN   binary_integer  default 0 );

  -- backupSetDataFile starts a backup conversation to backup datafiles and
  -- possibly a controlfile.

  PROCEDURE backupSetArchivedLog( set_stamp   OUT  number
                             ,set_count   OUT  number
                             ,nochecksum  IN   boolean        default FALSE );

  -- backupSetArchivedLog starts a backup conversation to backup archived redo
  -- logs.

  -- No information is placed into the controlfile until the entire backup
  -- set is complete.  The setid and stamp parameters returned by
  -- backupSetDataFile or backupSetArchivedLog are the key that can be used to
  -- identify all controlfile data created by this conversation.
  --
  -- The database must be mounted to create a backup set. A device must
  -- have already been allocated for creating backup pieces.
  --
  -- It is acceptable to create a backup when a backup controlfile has been
  -- mounted. However, note that the files named in the controlfile
  -- may no longer exist. Logs archived since the controlfile backup will
  -- not be in V$ARCHIVED_LOG. Missing files will not be detected until they
  -- are read while creating a backup piece. This makes it impossible to
  -- continue the backup conversation.
  --
  -- A row is also added to V$SESSION_LONGOPS to record the progress of
  -- the backup. The whole column will contain the number of blocks that
  -- will be read from the datafiles or archived redo logs. The total will be
  -- increased as files are added to the backup. Progress will be indicated
  -- as the backup pieces are created.
  --
  -- When backing up datafiles, blocks that have never been modified will
  -- not be put into the backup. Note that this does not avoid blocks that
  -- were once in use but are not part of any object at this time. A future
  -- version may avoid these blocks.
  --
  -- Input parameters:
  --   tag
  --     The tag stored in the file header of the copied and backed up files,
  --     and also in the controlfile records describing those files.
  --   incremental
  --     Specifies whether or not this backup set is part of the database's
  --     incremental backup hierarchy.  If false, then the backup is not part
  --     of the hierarchy.This does not affect the file backup process - it is
  --     simply stored in the controlfile and reflected in the V$BACKUP_SET and
  --     V$BACKUP_DATAFILE views.
  --   nochecksum
  --     If true, we will not calculate a checksum on blocks that
  --     do not have a checksum. If there is a checksum in a block it is
  --     always validated after reading, and it is saved in the backup.
  --   backup_level
  --     This indicates the location of this backup set in the database's
  --     incremental backup hierarchy.  If zero, then a full backup will be
  --     produced, which must be restored with restoreSetDataFile.  If
  --     non-zero, then a valid SCN must be supplied with all calls to
  --     backupDataFile[Copy], and an incremental backup set will be produced,
  --     which must be restored with applySetDataFile.
  --
  -- Output parameters:
  --   set_stamp and set_count, taken together, form the primary key used to
  --   identify records for this backup set in the following fixed views:
  --     V$BACKUP_SET
  --     V$BACKUP_PIECE
  --     V$BACKUP_DATAFILE
  --     V$BACKUP_REDOLOG
  --     V$BACKUP_CORRUPTION
  --
  --   Note that set_stamp and set_count are NOT the recid and stamp of the
  --   circular-reuse record that is created in v$backup_set for this backup
  --   set.  These separately maintained fields are used as the backup set
  --   key because they are obtained when the backup set is begun and can be
  --   placed in each backup piece.  The recid/stamp of the v$backup_set
  --   record are not obtained until the backup set is complete, and so cannot
  --   be placed in each backup piece.
  --
  --   set_stamp
  --     This is a timestamp that is used to identify the backup set.
  --   set_count
  --     This is a counter that is kept in the database information
  --     section of the mounted controlfile.  During backup set
  --     conversation initialization, a read/write controlfile transaction is
  --     used to increment this counter by one.

  -- Exceptions:
  --   TAG-TOO-LONG (ora-19705)
  --     The tag is longer than the port-specific maximum.
  --   CONVERSATION-ACTIVE (ora-19590)
  --     A backup or restore conversation is already active in this session.
  --   MULTI-THREADED-SERVER (ora-19550)
  --     This session is not connected to a dedicated server.
  --   ALTERNATE-CONTROLFILE-OPEN (ora-226)
  --     This session's fixed tables are currently re-directed to a snapshot
  --     or other alternate controlfile.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     No database is mounted.

 --*********************************
 -- Backup File List Specification
 --*********************************

  -- The second phase of taking a backup is to list the files that go into
  -- the backup. Files are listed by controlfile record. A number of files
  -- may need to be in a single backup in order to provide enough data to
  -- keep the output device streaming. However, backups of large databases
  -- should be partitioned into different backup conversations so that the
  -- conversations can be done in parallel, minimizing the restore times for
  -- any particular datafile. Restoring only one file from a backup set
  -- requires a sequential scan through the entire backup set, until the
  -- required file is completely restored.
  --
  -- Note that an error adding a file to a backup does not terminate the
  -- backup conversation. More files can still be added, or piece creation
  -- can begin, if at least one file has been successfully added.

  PROCEDURE backupDataFile( dfnumber      IN  binary_integer
                           ,since_change  IN  number          default 0
                           ,max_corrupt   IN  binary_integer  default 0 );

  -- Add a data file to a backup set. backupDataFile backups a current
  -- datafile in the database. The file may be either online or offline.

  PROCEDURE backupDataFileCopy( copy_recid    IN  number
                               ,copy_stamp    IN  number
                               ,since_change  IN  number          default 0
                               ,max_corrupt   IN  binary_integer  default 0 );

  -- Add a data file to a backup set. backupDataFileCopy backups a copy of
  -- a datafile that was made via copyDataFile or some operating system
  -- utility. If the copy was made by operation system utility, it may be
  -- necessary to call inspectDataFileCopy to build a controlfile record
  -- for this copy before calling backupDataFileCopy.

  -- From the time that a datafile is named as part of a backup set until
  -- the last backup piece containing any portion of the datafile is
  -- successfully created, the backup session holds a shared file access
  -- enqueue on the file, making it impossible to drop it from the database
  -- or take it offline normal. If the file goes offline immediate before
  -- it is opened for placing in the backup set, it will fail with an error
  -- reading the file.
  --
  -- Input parameters:
  --   dfnumber
  --     Data file number of a file to backup. This refers to the file that
  --     is currently accessible via SQL commands.
  --   copy_recid
  --     The record ID from V$DATAFILE_COPY for the datafile copy. This
  --     is the record ID returned from copyDataFile or inspectDataFileCopy.
  --   copy_stamp
  --     The stamp corresponding to copy_recid. This is to insure that the
  --     record is the same one that was selected.
  --   since_change
  --     Only blocks modified since this SCN will be included in the backup.
  --     This creates an incremental backup that can only be applied to a
  --     datafile that is checkpointed between this SCN and the backup's
  --     checkpoint. Note that an incremental backup cannot change the
  --     resetlogs stamp in a file, so this SCN may not be less than the
  --     ressetlogs SCN in the file header.
  --   max_corrupt
  --     Up to this many data blocks from this file can be made corrupt in the
  --     backup. The whole backup will fail if more blocks are found corrupt.
  --     This does not count blocks that were already marked corrupt in the
  --     datafile. It only counts blocks that failed verification when they
  --     were read, and had to be reformatted to be corrupt in the backup. Note
  --     that such blocks are always included in incremental backups since we
  --     cannot know when the last change was made.
  -- Exceptions:
  --   INVALID-SCN (ora-19706)
  --     The incremental start SCN could not be converted into the internal
  --     SCN representation because it is non-integral, less than zero, or
  --     greater than the highest possible SCN.
  --   CONVERSATION-NOT-ACTIVE (ora-19580)
  --     A backup conversation was not started before specifying files.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   WRONG-CONVERSATION-TYPE (ora-19592)
  --     The backup set is not for datafiles and controlfiles.
  --   NAMING-PHASE-OVER (ora-19604)
  --     backuppiececreate has already been called.  No files can be named
  --     after piececreate is called.
  --   INVALID-FILE-NUMBER (ora-19570)
  --     The specified real file number is out of range.
  --   DUPLICATE-DATAFILE (ora-19593)
  --     Only one version of a datafile can exist in the same backup set.
  --   DATABASE-NOT-OPEN (ora-1138)
  --     Some other instance is open, but this instance is not open.  Either
  --     open this instance or close all other instances.
  --   FILE-IS-FUZZY (ora-19602)
  --     The file is fuzzy and the database is in noarchivelog mode.
  --   FILE-BEING-RESIZED (ora-19572)
  --     The file is in the middle of a resize operation.  Wait for the
  --     resize to complete.
  --   CANT-GET-REAL-FILE-ENQUEUE (ora-19573)
  --     A datafile is locked. Another backup or restore could be in progress,
  --     or some other database activity, such as media recovery, holds an
  --     exclusive enqueue on the file.
  --   FILE-NOT-FOUND (ora-19625)
  --     The file can not be opened.
  --   BLOCKSIZE-MISMATCH (ora-19597)
  --     Only files with the same blocksize can be put into the same backup
  --     set. This is not really a restriction in 8.0 since there is only
  --     one datafile block size per database.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     The file is not the one described by the controlfile record.
  --   RECORD-NOT-FOUND (ora-19571)
  --     The specified datafile copy record does not exist.
  --   RECORD-NOT-VALID (ora-19588)
  --     The specified datafile copy record is no longer valid - it has been
  --     marked as deleted.
  --   RETRYABLE-ERROR (ora-19624)
  --     This is a pseudo-error that is placed on top of the stack when an
  --     error is signalled but it may be possible to continue the
  --     conversation.
  --   INCREMENTAL-TOO-FAR (ora-xxxx)
  --     The since_change value is less than the resetlogs SCN for the file.
  --   IO-ERROR
  --     An error occured attempting to read the file header.

  PROCEDURE backupControlFile( cfname  IN  varchar2  default NULL );

  -- Include the controlfile in the backup set. If a file name is given,
  -- it must be a backup or standby controlfile that will be copied into
  -- the backup set. If no file name is given, a backup is made from the
  -- snapshot controlfile. The snapshot controlfile enqueue will be acquired
  -- in mode S if it is not held already.
  --
  -- Input parameters:
  --   cfname
  --     Operating system file name of a standby or backup controlfile to
  --     include in the backup set.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified controlfile name is longer than the port-specific
  --     maximum file name length.
  --   CONVERSATION-NOT-ACTIVE (ora-19580)
  --     A backup conversation was not started before specifying files.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   WRONG-CONVERSATION-TYPE (ora-19592)
  --     The backup set is not for datafiles and controlfiles.
  --   NAMING-PHASE-OVER (ora-19604)
  --     backuppiececreate has already been called.  No files can be named
  --     after piececreate is called.
  --   DUPLICATE-CONTROLFILE (ora-19594)
  --     Only one version of the controlfile can exist in the same backup set.
  --   SNAPSHOT-ENQUEUE-ALREADY-HELD (ora-229)
  --     This process already holds the snapshot controlfile enqueue.
  --   SNAPSHOT-ENQUEUE-BUSY (ora-230)
  --     The snapshot controlfile enqueue is in use by another process.
  --   CONTROLFILE-IS-ACTIVE (ora-19607)
  --     The controlfile name is the same as one of the controlfiles specified
  --     in the init.ora file.
  --   FILE-NOT-FOUND (ora-19625)
  --     The file can not be opened.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     A file that was specified by name is not a controlfile for the current
  --     database.
  --   NOT-BACKUP-CONTROLFILE (ora-19589)
  --     A file that was specified by name is not a backup, standby, or
  --     snapshot controlfile. An image copy of a controlfile can not be put
  --     in a backup set.
  --   BLOCKSIZE-MISMATCH (ora-19597)
  --     Only files with the same blocksize can be put into the same backup
  --     set. This is not really a restriction in 8.0 since there is only
  --     one datafile block size per database.
  --   RETRYABLE-ERROR (ora-19624)
  --     This is a pseudo-error that is placed on top of the stack when an
  --     error is signalled but it may be possible to continue the
  --     conversation.
  --   IO-ERROR
  --     An error occured attempting to read the file header.

  PROCEDURE backupArchivedLog( arch_recid  IN  number
                          ,arch_stamp  IN  number );

  -- Add an archived log to the redo log backup set. It may be necessary to
  -- call inspectArchivedLog to build a controlfile record.
  --
  -- Input parameters:
  --   arch_recid
  --     The controlfile record where the archiving record was created. This
  --     is the RECID column from V$ARCHIVED_LOG or the record ID returned
  --     from inspectArchivedLog.
  --   arch_stamp
  --     The stamp that corresponds to the arch_recid. This is to insure that
  --     the correct record is identified.
  -- Exceptions:
  --   CONVERSATION-NOT-ACTIVE (ora-19580)
  --     A backup conversation was not started before specifying files.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   WRONG-CONVERSATION-TYPE (ora-19592)
  --     The backup set is not for archived logs.
  --   NAMING-PHASE-OVER (ora-19604)
  --     backuppiececreate has already been called.  No files can be named
  --     after piececreate is called.
  --   RECORD-NOT-FOUND (ora-19571)
  --     The specified archived log record does not exist.
  --   RECORD-NOT-VALID (ora-19588)
  --     The specified archived log record is no longer valid - it has been
  --     marked as deleted.
  --   DUPLICATE-BACKUP-ARCHIVELOG (ora-19595)
  --     Only one version of an archived log can exist in the same backup set.
  --   RESETLOGS-DATA-MISMATCH (ora-19617)
  --     This archived log has different resetlogs data than the other logs
  --     that have already been included.  All archived logs in the same
  --     backup set must have the same resetlogs data.
  --   FILE-NOT-FOUND (ora-19625)
  --     The file can not be opened.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     The file is not the one described by the controlfile record.
  --   BLOCKSIZE-MISMATCH (ora-19597)
  --     Only files with the same blocksize can be put into the same backup
  --     set. This is not really a restriction in 8.0 since there is only
  --     one datafile block size per database.
  --   RETRYABLE-ERROR (ora-19624)
  --     This is a pseudo-error that is placed on top of the stack when an
  --     error is signalled but it may be possible to continue the
  --     conversation.
  --   IO-ERROR
  --     An error occured attempting to read the file header.

 --************************
 -- Backup Piece Creation
 --************************
  -- After all files and limits have been specified the next phase is to create
  -- the pieces of a backup set.

  PROCEDURE backupPieceCreate( fname    IN  varchar2
                              ,pieceno  OUT binary_integer
                              ,done     OUT boolean
                              ,handle   OUT varchar2
                              ,comment  OUT varchar2
                              ,media    OUT varchar2
                              ,concur   OUT boolean
                              ,params   IN  varchar2  default NULL);

  -- This procedure should be called to create the first (and any subsequent)
  -- backup piece after all calls to specify the file list have been issued.
  -- Multiple backupPieceCreate calls may be necessary.
  --
  -- If any errors occur during the creation of a backup piece, the backup
  -- conversation is still intact. Another backupPieceCreate call can be
  -- made to retry.
  --
  -- The KBYTES and READRATE Limits may be changed between calls to
  -- backupPieceCreate.  The PARALLEL limit may not be changed between
  -- pieces.  The PARALLEL limit that is in effect at the start of the first
  -- backup piece will remain in effect for the entire backup set.
  --
  -- Input parameters:
  --   fname
  --     Filename of the backup piece to be created. This will be translated
  --     into a file handle after the piece is created.
  --   params
  --     This string is simply passed to the sequential file create OSD. It is
  --     completely port and device specific.
  -- Output parameters:
  --   pieceno
  --     The number of the successfully created piece. The first piece is
  --     number 1.
  --   done
  --     TRUE if the backup set, not backup piece, is completed, FALSE
  --     otherwise. If FALSE, backupPieceCreate must be called again to
  --     continue the backup.
  --
  --     When TRUE, the backup conversation is now complete and all resources
  --     associated with the conversation are freed.  The controlfile has
  --     been updated with all necessary records to describe the backup set.
  --     The controlfile fixed views may now be queried, using the setid and
  --     timestamp returned when the conversation was begun as the primary key,
  --     to gather statistics from this backup set.
  --   handle
  --     The handle for the backup piece that was created. This is a permanent
  --     name that can be used to read this sequential file for restore. It
  --     can only be used with the same device type that was allocated at
  --     this call.
  --   comment
  --     The comment for the backup piece. This is any string that the OSD
  --     decided was useful. It will be the null string for operating system
  --     files.
  --   media
  --     The media handle returned by the operating system. This is the name
  --     of media where the file was created. It is not needed for retrieving
  --     the backup piece. For some devices this information will not be
  --     provided.
  --   concur
  --     TRUE if the device type used to create this piece
  --     supports multiple processes concurrently accessing the same media.
  --     If FALSE, it is best to only have one process at a time
  --     doing a restore of backup pieces with the same media handle.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified backup piece name is longer than the port-specific
  --     maximum file name length.
  --   DEVICE-PARM-TOO-LONG (ora-19702)
  --     The device parameter is longer than the port-specific maximum.
  --   CONVERSATION-NOT-ACTIVE (ora-19580)
  --     A backup conversation was not started before specifying files.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   NO-FILES (ora-19581)
  --     No files have been specified for the backup set so there is nothing
  --     to backup.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     One of the files does not match the description in the control file
  --     or if specified by name the file header no longer matches the values
  --     it had originally.
  --   PIECE-TOO-SMALL (ora-19585)
  --     An end-of-volume condition was received before the backup set header,
  --     directory, and at least one data block were written to the backup
  --     piece.
  --   KBYTE_LIMIT-TOO-SMALL (ora-19586)
  --     The k-bytes per piece limit which was set with setLimit was reached
  --     before the backup set header, directory, and at least one data block
  --     were written to the backup piece.
  --   CORRUPT_LIMIT_EXCEEDED (ora-19566)
  --     Too many corrupt blocks were encountered in an input datafile.
  --   CORRUPT_BLOCK (ora-19599)
  --     A corrupt block was encountered in an input controlfile or archived
  --     log.  Corrupt blocks are not tolerated in these types of files.
  --   EMPTY_FILE (ora-19562)
  --     A file was valid when it was specified during the file naming phase,
  --     but is now empty.
  --   FILE-TRUNCATED (ora-19575)
  --     The file did not contain the number of blocks that the file's header
  --     said it should.
  --   SINGLE-BLOCK-READ-ERROR (ora-19587)
  --     An I/O error occurred while reading the indicated block from the
  --     input file.
  --   RETRYABLE-ERROR (ora-19624)
  --     This is a pseudo-error that is placed on top of the stack when an
  --     error is signalled but it may be possible to continue the
  --     conversation.
  --   IO-ERROR
  --     An error occured attempting to read a file.
  --   CREATE-ERROR
  --     An error was reported by the OSD to create the sequential file.
  --   WRITE-ERROR
  --     An error was reported by the sequential write OSD.
  --   CORRUPT_BLOCK
  --     Too many corrupt blocks were encountered in one of the files being
  --     backed up. No corrupt blocks are allowed in redo logs or controlfiles.
  --     Some corrupt blocks can be allowed in datafiles via the
  --     argument to backupDataFile.


 --*****************************
-- Backup Conversation Status--
--****************************--

  PROCEDURE backupStatus( state        OUT binary_integer
                         ,setid        OUT number
                         ,stamp        OUT number
                         ,pieceno      OUT binary_integer
                         ,files        OUT binary_integer
                         ,datafiles    OUT boolean
                         ,incremental  OUT boolean
                         ,nochecksum   OUT boolean
                         ,device       OUT boolean );

  BACKUP_NO_CONVERSATION constant binary_integer := 0;
  BACKUP_NAMING_FILES    constant binary_integer := 1;
  BACKUP_PIECE_CREATE    constant binary_integer := 2;
  BACKUP_PIECE_RETRY     constant binary_integer := 3;

  -- backupStatus returns information about the current backup conversation.
  -- It is useful for resyncing with a conversation after some error has
  -- interrupted normal execution, and it is now time to resume the
  -- conversation. It can also be called if there is no conversation.
  --
  -- Note that there are no exceptions since this does nothing but return
  -- information about this session.
  --
  -- Output parameters:
  --   state
  --     This defines the state of the backup conversation. It is one of the
  --     constants defined above. The constants have the following meanings.
  --       BACKUP_NO_CONVERSATION
  --         No backup conversation is currently active for this session. The
  --         other output values will be NULL when this state is returned. Note
  --         that this state does not signal an error.
  --       BACKUP_NAMING_FILES
  --         Still allowing more calls to add files to the backup. This is the
  --         state immediately after starting the conversation. This state
  --         continues until the first call to backupPieceCreate.
  --       BACKUP_PIECE_CREATE
  --         The last call to backupPieceCreate completed successfully. More
  --         pieces still need to be created to complete the backup set.
  --       BACKUP_PIECE_RETRY
  --         The session got an error while writing a backup piece.
  --         The error may have been from reading one of the input files
  --         or some other failure. The return value pieceno does not include
  --         the piece that was being written. The next call to
  --         backupPieceCreate will recreate the failed piece from its
  --         beginning.
  --
  --   setid and stamp are the key that will be used to identify the
  --         controlfile records that will be created when the backup set is
  --         complete.  See the description of these parameters under the
  --         backupSetDataFile procedure for more information.
  --   pieceno
  --     This is the number of backup pieces that have been successfully
  --     created. It is zero until the first backupPieceCreate returns
  --     successfully.
  --   files
  --     This is the number of files that have been named for inclusion
  --     in the backup set. It is zero immediately after the conversation
  --     begins.
  --   datafiles
  --     TRUE if the backup conversation was started by calling
  --     backupSetDataFile; FALSE if backupSetArchivedLog was called.
  --   incremental
  --     This is the incremental argument to backupSetDataFile.
  --   nochecksum
  --     This is the nochecksum argument to backupSetDataFile or
  --     backupSetArchivedLog.
  --   device
  --     TRUE if a device has been allocated to this session.

 --**********************************
 -- Backup Conversation Termination--
 --*********************************--

  PROCEDURE backupCancel;

  -- Cancels a backup conversation releasing the context. This needs to be
  -- done if a conversation is going to be abandoned without successfully
  -- completing the backup set. This can be done anytime within the
  -- conversation.  No data will be added to the controlfile to reflect this
  -- conversation. The row in V$SESSION_LONGOPS will be deleted.

 --***************
 -- File Copying--
 --**************--
  -- It is also possible to make image copies of some files. This is useful
  -- for staging backups on disk before copying them to sequential media.
  -- The READRATE limit applies to these procedures, but the other limits
  -- do not. The database must be mounted to execute these procedures.
  --
  -- Each of these operations create a row in V$SESSION_LONGOPS to track the
  -- progress of the copy in blocks.

  PROCEDURE backupBackupPiece( bpname   IN   varchar2
                              ,fname    IN   varchar2
                              ,handle   OUT  varchar2
                              ,comment  OUT  varchar2
                              ,media    OUT  varchar2
                              ,concur   OUT  boolean
                              ,recid    OUT  number
                              ,stamp    OUT  number
                              ,tag      IN   varchar2  default NULL
                              ,params   IN   varchar2  default NULL
                              ,media_pool IN binary_integer default 0
                              ,reuse    IN boolean default FALSE);

  -- This procedure copies a backup piece that was originally written to an
  -- operating system file, onto sequential media. This requires allocating
  -- a sequential device first. Of course, this could copy to another operating
  -- system file if the NULL device is allocated.
  --
  -- A record is made in the controlfile as if the piece was just created and
  -- written to this output file. It can be queried from V$BACKUP_PIECE using
  -- the record ID returned. Note that no new entries are made in V$BACKUP_SET,
  -- V$BACKUP_DATAFILE, V$BACKUP_REDOLOG, or V$BACKUP_CORRUPTION.
  --
  -- It is acceptable to copy a backup piece when a backup controlfile has been
  -- mounted. However, note that the files named in the control
  -- file may no longer exist.
  --
  -- Input parameters:
  --   bpname
  --     Operating system file name of the existing backup piece. This will be
  --     read and copied to sequential media.
  --   fname
  --     Filename of the backup piece to be created. This will be translated
  --     into a file handle after the piece is created.
  --   tag
  --     The tag stored in the file header of the copied and backed up files,
  --     and also in the controlfile records describing those files.
  --   params
  --     This string is simply passed to the sequential file create OSD. It is
  --     completely port and device specific.
  -- Output parameters:
  --   handle
  --     The handle for the backup piece that was created. This is a permanent
  --     name that can be used to read this sequential file for restore. It
  --     can only be used with the same device type that was allocated at
  --     this call.
  --   comment
  --     The comment for the backup piece. This is any string that the OSD
  --     decided was useful. It will be a null string for operating system
  --     files. Note that this comment is not the same as the comment where the
  --     original backup piece was created.
  --   media
  --     The media handle returned by the operating system. This is the name
  --     of media where the file was created. It is not needed for retrieving
  --     the backup piece. For some devices this information will not be
  --     provided.
  --   concur
  --     TRUE if the device type used to create this piece
  --     supports multiple processes concurrently accessing the same media.
  --     If FALSE, it is best to only have one process at a time
  --     doing a restore of backup pieces with the same media handle.
  --   recid
  --     This is the ID of the record in the controlfile where the
  --     information about this backup piece was recorded. It can be used as
  --     the primary key to query V$BACKUP_PIECE.
  --   stamp
  --     This is a number that can be used to verify that the row in
  --     V$BACKUP_PIECE is really for this backup piece. The stamp combined
  --     with recid makes a key that is unique for this backup piece for all
  --     time.
  --   media_pool
  --     a number from 0-255 whose meaning is defined by rman or by 3rd-party
  --     media management software.
  -- Exceptions:
  --   NO-INPUT-FILENAME (ora-19605)
  --     src_name must be assigned a non-NULL string in copyControlFile.
  --   NO-OUTPUT-FILENAME (ora-19574)
  --     dest_name must be assigned a non-NULL string in copyControlFile.
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   TAG-TOO-LONG (ora-19705)
  --     The tag is longer than the port-specific maximum.
  --   DEVICE-PARM-TOO-LONG (ora-19702)
  --     The device parameter is longer than the port-specific maximum.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile or online redo log.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   CANT-IDENTIFY-FILE (ora-19505)
  --     The file can not be opened.
  --   END-OF-VOLUME (ora-19630)
  --     end-of-volume was encountered while copying the backup piece.
  --   CORRUPT_BLOCK (ora-19599)
  --     A corrupt block was encountered.  Corrupt blocks are not tolerated
  --     in backup pieces.
  --   NOT-A-BACKUP-PIECE (ora-19608)
  --     The input file is not recognizable as a backup piece.
  --   CORRUPT-DIRECTORY (ora-19610)
  --     The backup piece directory is corrupt.
  --   IO-ERROR
  --     An error occured attempting to read the input file.
  --   CREATE-ERROR
  --     An error was reported by the OSD to create the sequential file.
  --   WRITE-ERROR
  --     An error was reported by the sequential write OSD.

  PROCEDURE copyDataFile( dfnumber     IN   binary_integer
                         ,fname        IN   varchar2
                         ,full_name    OUT  varchar2
                         ,recid        OUT  number
                         ,stamp        OUT  number
                         ,max_corrupt  IN   binary_integer default 0
                         ,tag          IN   varchar2  default NULL
                         ,nochecksum   IN   boolean   default FALSE
                         ,isbackup     IN   boolean   default FALSE );
  --
  -- copyDataFile copies the named file in the database. The datafile may be
  -- either online or offline.

  PROCEDURE copyDataFileCopy( copy_recid   IN   number
                             ,copy_stamp   IN   number
                             ,full_name    OUT  varchar2
                             ,recid        OUT  number
                             ,stamp        OUT  number
                             ,fname        IN   varchar2  default NULL
                             ,max_corrupt  IN   binary_integer  default 0
                             ,tag          IN   varchar2  default NULL
                             ,nochecksum   IN   boolean   default FALSE
                             ,isbackup     IN   boolean   default FALSE);
  --
  -- copyDataFileCopy is used to make a copy of a copy.

  -- These procedures make image copies of datafiles. An image copy is
  -- suitable for direct use by the database. Its name can be used in
  -- a rename command, then recovered to become current. It can also
  -- be copied to sequential media as part of a backup set. Some customers
  -- may want to keep an online image copy of all their datafiles as their
  -- most recent backup, then backup the image copy to tape. Note that
  -- these routines only make image copies on operating system files.
  -- It is impossible to put an image on sequential media. These procedures
  -- may NOT be executed during a backup or restore conversation. There must
  -- be a device allocated to the session and it must be the null device.
  --
  -- The procedure copyDataFile copies the current file in the database.
  -- The file may be either online or offline. The procedure copyDataFileCopy
  -- is used to make a copy of a copy. This may be advisable before using a
  -- copy for an incomplete recovery. If the incomplete recovery needs to
  -- be redone, the unrecovered file is still available on disk. For copying
  -- to the file specified by the controlfile, the fname parameter can be
  -- NULL. This is effectively a restore.  It is not permitted to overwrite
  -- the file named by the controlfile with a copy unless the creation time
  -- of the copy is the same as the creation time of the real file.
  --
  -- It is acceptable to copy a file when a backup controlfile has been
  -- mounted. However, note the files named in the control file may no
  -- longer exist.
  --
  -- In order to handle a failure during the copy, the output file header
  -- will have its file type set to zero until the copy is complete.  This
  -- insures it cannot be used until the copy is complete. When the copy is
  -- complete, a valid header, with all fuzziness removed except the
  -- calculated absolute fuzziness, is written to the file.
  --
  -- After the copy is complete, a record will be added to V$DATAFILE_COPY
  -- to describe the copied file.  If the destination was the named
  -- datafile (copyDataFileCopy was used and no filename was specified),
  -- then the underlying controlfile record will be immediately marked as
  -- obsolete, and will not appear in the V$DATAFILE_COPY view.  Before
  -- adding the new record to V$DATAFILE_COPY, the datafile copy record
  -- section of the controlfile will be scanned, looking for any existing
  -- copy records with the same filename.  If any such records are found,
  -- they will be marked obsolete.
  --
  -- If any corrupt blocks are found in the datafiles, then records will be
  -- inserted in V$COPY_CORRUPTION to describe the corrupt block ranges.
  --
  -- Input parameters:
  --   dfnumber
  --     Datafile number of a file to copy. This refers to the file that
  --     is currently accessible via SQL commands.
  --   copy_recid
  --     The record ID from V$DATAFILE_COPY for the datafile copy. This
  --     is the record ID returned from inspectDataFileCopy or a previous call
  --     to make a datafile copy.
  --   copy_stamp
  --     The stamp that corresponds to copy_recid. This is to insure that the
  --     record is the same one that was selected.
  --   max_corrupt
  --     Up to this many corrupt data blocks from this file can appear in the
  --     backup. The copy will fail if more blocks are found corrupt.
  --   fname
  --     File name to copy the image to. This name may not be useable by
  --     another process, so it will be expanded.
  --   tag
  --     The tag to be stored in the file header of the copied and backed up
  --     files, and also in the controlfile records describing those files.
  --   nochecksum
  --     If true, we will not calculate a checksum on blocks that
  --     do not have a checksum. If there is a checksum in a block it is
  --     always validated after reading, and it is saved in the copy.
  --   isbackup
  --     If true, then Recovery Manager is treating this file as a level 0
  --     backup in the database's recovery strategy.  This information is
  --     simply stored in the V$DATAFILE_COPY record created by this copy
  --     operation, and has no other effect.
  --
  -- Output parameters:
  --   full_name
  --     This is the fully expanded name of the file that was created. It will
  --     also appear in V$DATAFILE_COPY.
  --   recid
  --     This is the ID of the record that is created in the controlfile
  --     when the copy is successfully completed. It can be used to query
  --     information about the copy from V$DATAFILE_COPY.
  --   stamp
  --     This is a number that can be used to verify that the row in
  --     V$DATAFILE_COPY is really for this copy. The stamp combined with
  --     recid makes a key that is unique for this copy for all time.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   TAG-TOO-LONG (ora-19705)
  --     The tag is longer than the port-specific maximum.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   NO-OUTPUT-FILENAME (ora-19574)
  --     fname must be assigned a non-NULL string in copyDataFile.
  --   INVALID-FILE-NUMBER (ora-19570)
  --     The specified real file number is out of range.
  --   FILE-BEING-RESIZED (ora-19572)
  --     The file is in the middle of a resize operation.  Wait for the
  --     resize to complete.
  --   CANT-GET-REAL-FILE-ENQUEUE (ora-19573)
  --     A datafile is locked. Another backup or restore could be in progress,
  --     or some other database activity, such as media recovery, holds an
  --     exclusive enqueue on the file.
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile or online redo log.
  --   DATABASE-NOT-OPEN (ora-1138)
  --     Some other instance is open, but this instance is not open.  Either
  --     open this instance or close all other instances.
  --   FILE-IS-FUZZY (ora-19602)
  --     The file is fuzzy and the database is in noarchivelog mode.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     The file is not the one described by the controlfile record.
  --   RECORD-NOT-FOUND (ora-19571)
  --     The specified datafile copy record does not exist.
  --   RECORD-NOT-VALID (ora-19588)
  --     The specified datafile copy record is no longer valid - it has been
  --     marked as deleted.
  --   REAL-FILE-NOT-FOUND (ora-19576)
  --     When restoring a datafile copy to its original location, the
  --     datafile record describing the original file could no longer be
  --     found, probably because the file was dropped from the database.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   NULL-DEVICE-REQUIRED (ora-19561)
  --     A NULL device is required, but a non-null device was found.
  --   CANT-IDENTIFY-FILE (ora-19505)
  --     The file can not be opened.
  --   CORRUPT_LIMIT_EXCEEDED (ora-19566)
  --     Too many corrupt blocks were encountered in the input file.
  --   EMPTY_FILE (ora-19562)
  --     The input file is empty.
  --   FILE-TRUNCATED (ora-19575)
  --     The file did not contain the number of blocks that the file's header
  --     said it should.
  --   RETRYABLE-ERROR (ora-19624)
  --     This is a pseudo-error that is placed on top of the stack when an
  --     error is signalled but it may be possible to continue the
  --     conversation.
  --   IO-ERROR
  --     An error occured attempting to read a file.
  --   CREATE-ERROR
  --     An error was reported by the OSD to create the file.
  --   WRITE-ERROR
  --     An error was reported by the sequential write OSD.

  PROCEDURE copyArchivedLog( arch_recid  IN   number
                        ,arch_stamp  IN   number
                        ,fname       IN   varchar2
                        ,full_name   OUT  varchar2
                        ,recid       OUT  number
                        ,stamp       OUT  number
                        ,nochecksum  IN   boolean  default FALSE );

  -- This procedure makes a copy of a log that was already archived. This
  -- may be useful for moving redo to a different location, or for extra
  -- redundancy. A record is created in the controlfile as if this log was
  -- just archived.  Note that this cannot copy an online log. Copying an
  -- online log is actually archiving it, and has other implications. There
  -- are SQL commands for archiving.
  --
  -- It is acceptable to copy a file when a backup controlfile has been
  -- mounted. However, note the files named in the controlfile may no
  -- longer exist.
  --
  -- Input parameters:
  --   arch_recid
  --     The controlfile record where the archiving record was created. This
  --     is the RECID column from V$ARCHIVED_LOG or the record ID returned
  --     from inspectArchivedLog.
  --   arch_stamp
  --     The stamp that corresponds to the arch_recid. This is to insure that
  --     the correct record is identified.
  --   fname
  --     File name to copy the image to. This name may not be useable by
  --     another process, so it will be expanded.
  --   nochecksum
  --     If true, we will not calculate a checksum on blocks that
  --     do not have a checksum. If there is a checksum in a block it is
  --     always validated after reading, and it is saved in the backup.
  -- Output parameters:
  --   full_name
  --     This is the fully expanded name of the file that was created. It will
  --     also appear in V$ARCHIVED_LOG.
  --   recid
  --     This is the ID of the record that is created in the controlfile
  --     when the copy is successfully completed. It can be used to query
  --     information about the copy from V$ARCHIVED_LOG.
  --   stamp
  --     This is a number that can be used to verify that the row in
  --     V$ARCHIVED_LOG is really for this copy. The stamp combined with recid
  --     makes a key that is unique for this copy for all time.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   NO-OUTPUT-FILENAME (ora-19574)
  --     fname must be assigned a non-NULL string in copyArchivedLog
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile or online redo log.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     The file is not the one described by the controlfile record.
  --   RECORD-NOT-FOUND (ora-19571)
  --     The specified datafile copy record does not exist.
  --   RECORD-NOT-VALID (ora-19588)
  --     The specified datafile copy record is no longer valid - it has been
  --     marked as deleted.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   NULL-DEVICE-REQUIRED (ora-19561)
  --     A NULL device is required, but a non-null device was found.
  --   CANT-IDENTIFY-FILE (ora-19505)
  --     The file can not be opened.
  --   CORRUPT_BLOCK (ora-19599)
  --     A corrupt block was encountered in an input controlfile or archived
  --     log.  Corrupt blocks are not tolerated in these types of files.
  --   EMPTY_FILE (ora-19562)
  --     The input file is empty.
  --   FILE-TRUNCATED (ora-19575)
  --     The file did not contain the number of blocks that the file's header
  --     said it should.
  --   RETRYABLE-ERROR (ora-19624)
  --     This is a pseudo-error that is placed on top of the stack when an
  --     error is signalled but it may be possible to continue the
  --     conversation.
  --   IO-ERROR
  --     An error occured attempting to read a file.
  --   CREATE-ERROR
  --     An error was reported by the OSD to create the file.
  --   WRITE-ERROR
  --     An error was reported by the sequential write OSD.

  PROCEDURE copyControlFile( src_name   IN   varchar2
                            ,dest_name  IN   varchar2
                            ,recid      OUT  number
                            ,stamp      OUT  number
                            ,full_name  OUT  varchar2);

  -- This routine makes copies of a controlfile that is already on disk in an
  -- operating system file.  It is intended to be used to make copies of
  -- controlfiles for specifying multiple controlfiles in the initialization
  -- parameter.
  --
  -- If src_name is NULL, this function will make backup copy of a current
  -- controlfile. Backup controlfiles need modifications so that they can be
  -- recovered, so this command calls KCC layer to do that. You can also use
  -- ALTER DATABASE BACKUP CONTROLFILE.
  --
  -- If dest_name is NULL and database is not mounted, we restore and replicate
  -- the controlfiles to all names that match current controlfiles in
  -- parameter file.
  --
  -- Unlike the other copy procedures, copyControlFile works when the
  -- database is not mounted. Exception is when we make backup copy of a
  -- current controlfile.
  --
  -- When the database is mounted:
  --
  --   Neither the source nor destination file may be an active file as
  --   specified in the initialization parameter.
  --
  --   The destination file may not be the snapshot controlfile.
  --
  --   After the copy is complete, a record will be placed into the
  --   V$DATAFILE_COPY view (in the current controlfile, not the copy)
  --   describing the copy.  The datafile number will be zero and the
  --   the datafile checkpoint will be the set to the controlfile checkpoint
  --   taken from the kccfhx.
  --
  -- When the database is NOT mounted:
  --
  --   The source file must be specified.
  --
  --   There are no restrictions on either the input or output file, except
  --   that the input file must be a controlfile for the started instance.
  --
  --   No record is made to describe the copy.
  --
  -- Input parameters:
  --   src_name
  --     Operating system file name of the controlfile to copy from.
  --     If NULL, then we will make backup copy of the current controlfile.
  --   dest_name
  --     File name to copy the image to. This name may not be useable by
  --     another process, so it will be expanded.
  -- Output parameters:
  --   recid
  --     This is the ID of the record that is created in the controlfile
  --     when the copy is successfully completed. It can be used to query
  --     information about the copy from V$DATAFILE_COPY.  The controlfile is
  --     seen as datafile 0.
  --   stamp
  --     This is a number that can be used to verify that the row in
  --     V$DATAFILE_COPY is really for this copy. The stamp combined with
  --     recid makes a key that is unique for this copy for all time.
  --   full_name
  --     This is the fully expanded name of the file that was created.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   NO-OUTPUT-FILENAME (ora-19574)
  --     dest_name must be assigned a non-NULL string in copyControlFile.
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile or online redo log.
  --   FILE-NOT-FOUND (ora-19625)
  --     The file can not be opened.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     The file is not a controlfile for the current database.
  --   NOT-BACKUP-CONTROLFILE (ora-19589)
  --     The input file is not a backup, standby, or snapshot controlfile.
  --     An image copy of a controlfile can not be copied.
  --   CONTROLFILE-IS-ACTIVE (ora-19607)
  --     The controlfile name is the same as one of the controlfiles specified
  --     in the init.ora file.
  --   CONTROLFILE-IS-SNAPSHOT (ora-19606)
  --     The destination file is the snapshot controlfile.  You cannot use
  --     copyControlFile to create the snapshot controlfile.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   NULL-DEVICE-REQUIRED (ora-19561)
  --     A NULL device is required, but a non-null device was found.
  --   CORRUPT_BLOCK (ora-19599)
  --     A corrupt block was encountered in an input controlfile or archived
  --     log.  Corrupt blocks are not tolerated in these types of files.
  --   EMPTY_FILE (ora-19562)
  --     The input file is empty.
  --   FILE-TRUNCATED (ora-19575)
  --     The file did not contain the number of blocks that the file's header
  --     said it should.
  --   RETRYABLE-ERROR (ora-19624)
  --     This is a pseudo-error that is placed on top of the stack when an
  --     error is signalled but it may be possible to continue the
  --     conversation.
  --   IO-ERROR
  --     An error occured attempting to read a file.
  --   CREATE-ERROR
  --     An error was reported by the OSD to create the file.
  --   WRITE-ERROR
  --     An error was reported by the sequential write OSD.

  PROCEDURE inspectDataFileCopy( fname      IN   varchar2
                            ,full_name  OUT  varchar2
                            ,recid      OUT  number
                            ,stamp      OUT  number
                            ,tag        IN   varchar2  default NULL
                            ,isbackup   IN   boolean  default FALSE);

  -- This procedure reads the header from an operating system datafile copy,
  -- and makes a record in the controlfile as if the copy had just been made
  -- via copyDataFile. This is useful for registering a datafile copy that
  -- was made through the Oracle7 technique using an operating system copy
  -- utility. Some customers prefer to make backups by breaking a mirrored
  -- volume then reforming the mirror with a different drive. The broken off
  -- drive can then be registered for use by inspecting it. A datafile copy
  -- must be registered in the controlfile before it can be put in a backup
  -- on sequential media.
  --
  -- This may be called during a backup or restore conversation in order to
  -- have a record for the file. This is particularly advised when using a
  -- backup controlfile since the datafile information may be out of date.
  --
  -- Input parameters:
  --   fname
  --     File name of the datafile copy to inspect. This name may not be
  --     useable by another process, so it will be expanded.
  -- Output parameters:
  --   full_name
  --     This is the fully expanded name of the file that was inspected. It
  --     will also appear in V$DATAFILE_COPY.
  --   recid
  --     This is the ID of the record that is created in the controlfile
  --     when the copy is successfully inspected. It can be used to query
  --     information about the copy from V$DATAFILE_COPY.
  --   stamp
  --     This is a number that can be used to verify that the row in
  --     V$DATAFILE_COPY is really for this copy. The stamp combined with recid
  --     makes a key that is unique for this copy for all time.
  --   tag
  --     The tag to be stored in in the controlfile record describing this file
  --     InspectDataFileCopy does not store the tag in the file header
  --   isbackup
  --     If true, then Recovery Manager is treating this file as a level 0
  --     backup in the database's recovery strategy.  This information is
  --     simply stored in the V$DATAFILE_COPY record created by this inspect
  --     operation, and has no other effect.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile or online redo log.
  --   FILE-NOT-FOUND (ora-19625)
  --     The file can not be opened.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     The file is not a datafile from the current database.
  --   IO-ERROR
  --     An error occured attempting to read a file.

  PROCEDURE inspectArchivedLog( fname      IN   varchar2
                           ,full_name  OUT  varchar2
                           ,recid      OUT  number
                           ,stamp      OUT  number );

  -- This procedure reads the header from an archived redo log and constructs
  -- a record in the controlfile as if the file had just been archived or
  -- created via copyArchivedLog. This may be necessary in order to put the log
  -- in a backup on sequential media.
  --
  -- This may be called during a backup or restore conversation in order to
  -- have a record for the file. This is particularly advised when using a
  -- backup controlfile since the datafile information may be out of date.
  --
  -- Input parameters:
  --   fname
  --     File name of the archived log to inspect. This name may not be
  --     useable by another process, so it will be expanded.
  -- Output parameters:
  --   full_name
  --     This is the fully expanded name of the file that was inspected. It
  --     will also appear in V$ARCHIVED_LOG.
  --   recid
  --     This is the ID of the record that is created in the controlfile
  --     when the copy is successfully inspected. It can be used to query
  --     information about the copy from V$ARCHIVED_LOG.
  --   stamp
  --     This is a number that can be used to verify that the row in
  --     V$ARCHIVED_LOG is really for this copy. The stamp combined with recid
  --     makes a key that is unique for this copy for all time.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile or online redo log.
  --   FILE-NOT-FOUND (ora-19625)
  --     The file can not be opened.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     The file is not a datafile from the current database.
  --   IO-ERROR
  --     An error occured attempting to read a file.

  PROCEDURE inspectControlFile(fname       IN   varchar2
                               ,full_name  OUT  varchar2
                               ,recid      OUT  number
                               ,stamp      OUT  number );

  -- This procedure reads the header from a backup controlfile and creates
  -- a record in the current controlfile as if the file had just been
  -- created with 'alter database backup controlfile' or copyControlFile or
  -- restoreControlFileTo.  This may be necessary in order to put the log
  -- in a backup on sequential media.
  --
  -- This may be called during a backup or restore conversation in order to
  -- have a record for the file.
  --
  -- Input parameters:
  --   fname
  --     File name of the controlfile to inspect. This name may not be
  --     useable by another process, so it will be expanded.
  -- Output parameters:
  --   full_name
  --     This is the fully expanded name of the file that was inspected. It
  --     will also appear in V$DATAFILE_COPY.
  --   recid
  --   stamp
  --     These are the key of the record that is created in the controlfile
  --     when the copy is successfully inspected. It can be used to query
  --     information about the copy from V$DATAFILE_COPY.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile or online redo log.
  --   FILE-NOT-FOUND (ora-19625)
  --     The file can not be opened.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     The file is not a controlfile that was backed up from the current
  --     database.
  --   IO-ERROR
  --     An error occured attempting to read a file.

 --*********************************************
 -- Restore Conversation Initiation Procedures--
 --********************************************--

  -- A restore conversation is similar to a backup conversation except that
  -- it reads backups and creates operating system files. Either archived logs
  -- can be restored for use with recovery, or data files can be restored to
  -- be recovered. Restoring an incremental backup is equivalent to applying
  -- redo to an existing copy of the datafile. A successful restore
  -- conversation consists of the following phases:
  --   1) Start conversation specifying the type of backup.
  --   2) Specify which files to restore and where to restore them.
  --   3) Read consecutive pieces of the backup set until all the specified
  --      files have been restored.
  -- The restore conversation ends when the last file has been successfully
  -- restored.

  PROCEDURE restoreSetDataFile;
  -- restoreSetDataFile begins a conversation that will completely recreate
  -- datafiles and possibley a controlfile from the backup.

  PROCEDURE applySetDataFile;
  -- applySetDataFile begins a conversation that will apply incremental
  -- backups to existing datafiles.

  PROCEDURE restoreSetArchivedLog(destination IN varchar2 default NULL);
  -- restoreSetArchivedLog begins a conversation that will restore archived
  -- redo logs so that they can be applied by recovery.
  --
  -- These procedures begin a restore conversation. An appropriate context for
  -- the restore is allocated. The database does not need to be mounted to do a
  -- restore, but an instance must be started. A device must already be
  -- allocated for reading the backup pieces.
  --
  -- An instance must be started to call these procedures. If the controlfile
  -- is available, the database should be mounted. This provides better error
  -- checking, and allows specification of datafiles by file number
  --
  -- For a redo log conversation, a destination can be given for the
  -- location to create the logs. This is the same as giving a destination
  -- for archiving. The log_archive_format initialization parameter is used
  -- along with the destination to construct the name of the operating
  -- system files to create. If no destination is given, the current
  -- archiving destination is used.
  --
  -- Input parameters:
  --   destination
  --     This is used to construct the file name for creating the restored
  --     redo logs.
  -- Exceptions:
  --   DESTINATION-TOO-LONG (ora-19708)
  --     The specified archive log destination is longer than the port-
  --     specific maximum.
  --   CONVERSATION-ACTIVE (ora-19590)
  --     A backup or restore conversation is already active in this session.
  --   MULTI-THREADED-SERVER (ora-19550)
  --     This session is not connected to a dedicated server.
  --   ALTERNATE-CONTROLFILE-OPEN (ora-226)
  --     This session's fixed tables are currently re-directed to a snapshot
  --     or other alternate controlfile.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     No database is mounted.

 --**********************************
 -- Restore File List Specification--
 --*********************************--

  -- The second phase of a restore conversation is to specify what to
  -- restore from a backup set and where to restore it. This is
  -- accomplished by calling these routines. Since a single backup set may
  -- contain multiple files, it may be necessary to make multiple calls
  -- to specify all the files to be restored.  Any files that appear in
  -- the backup set, but are not mentioned in any calls, will be ignored
  -- by the restore. No files can be added to the list once the first
  -- backup piece is read. Only one destination can be given per file to
  -- restore. Errors while specifying the files to restore do not
  -- terminate the conversation.

  PROCEDURE restoreControlfileTo(cfname IN varchar2);

  -- This copies the controlfile from the backup set to an operating system
  -- file. If the database is mounted, the name must NOT match any of the
  -- current controlfiles.
  --
  -- Input parameters:
  --   cfname
  --     Name of file to create or overwrite with the controlfile from the
  --     backup set. When passed as NULL and database is not mounted, we
  --     restore and replicate the controlfiles to all names that match
  --     current controlfiles in parameter file.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   CONVERSATION-NOT-ACTIVE (ora-19580)
  --     A restore conversation was not started before specifying files.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   WRONG-CONVERSATION-TYPE (ora-19592)
  --     This restore conversation is not for datafiles and controlfiles.
  --   CONVERSATION-IS-VALIDATE-ONLY (ora-19618)
  --     No files can be named after restoreValidate has been called.
  --   NAMING-PHASE-OVER (ora-19604)
  --     The first backup piece has been restored.  No more files can be
  --     named.
  --   NO-OUTPUT-FILENAME (ora-19574)
  --     dest_name must be assigned a non-NULL string in copyControlFile.
  --   DUPLICATE-CONTROLFILE (ora-19594)
  --     The controlfile has already been specified for restoration.
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile or online redo log.
  --   CONTROLFILE-IS-ACTIVE (ora-19607)
  --     The destination file is the same as one of the controlfiles specified
  --     in the init.ora file.
  --   CONTROLFILE-IS-SNAPSHOT (ora-19606)
  --     The destination file is the snapshot controlfile.  You cannot restore
  --     to the snapshot controlfile.

  PROCEDURE restoreDataFileTo( dfnumber  IN  binary_integer
                              ,toname    IN  varchar2       default NULL);
  --
  -- restoreDataFileTo creates the output file from a complete backup in the
  -- backup set.

  PROCEDURE applyDataFileTo( dfnumber        IN  binary_integer
                            ,toname          IN  varchar2       default NULL
                            ,fuzziness_hint  IN  number         default 0);
  --
  -- applyDataFileTo applies an incremental backup from the backup set to an
  -- existing copy of the datafile. Note that the incremental backup and the
  -- datafile must have the same resetlogs stamp, but this can not be detected
  -- until the restore is begun.

  -- Add this file to the list of files to read from the backup. The file may
  -- be written to either the current version of the datafile, or to another
  -- copy. The current version is written if toname is NULL, or if it is the
  -- name of the current file.
  --
  -- If no database is mounted, toname must be given.
  -- If the database is open, the file must be offline to write to the current
  -- version.
  -- If there is a failure during a restore, the file will not be usable.
  --
  -- If there is a failure during an apply, the file's checkpoint will not
  -- be advanced, and its absolute fuzziness will be set to either the
  -- fuzziness hint passed by the caller or the greatest fuzziness found in
  -- the file itself, whichever is greater.  Redo may be applied to
  -- compensate for the failed apply.
  --
  -- For full restores, in order to handle a failure during the restore,
  -- the output file header will have its file type set to zero until the
  -- restore is complete.  This insures it cannot be used until the restore
  -- is complete. When the restore is complete, a valid header, with all
  -- fuzziness removed except the calculated absolute fuzziness, is written
  -- to the file.
  --
  -- When a datafile block in a backup set is found to be corrupt, we don't
  -- know which file it belongs to.  The block will be discarded and a
  -- message will be written to the alert log.  We will only know which
  -- files contained corrupt blocks when their DBA checksums (see next
  -- paragraph) are later found to be invalid.  This only applies to blocks
  -- which fail cache header validation when read from the backup set, not
  -- to blocks that were marked media-corrupt or logically-corrupt when the
  -- backup set was created, but had valid cache headers.
  --
  -- A checksum is kept on all the DBAs stored in a backup set for each
  -- datafile.  This checksum is stored in the datafile header, which is
  -- the last block in the backup set for each datafile.  If, when reading
  -- the datafile header, the checksum in the header does not match, then
  -- some blocks destined for that datafile must have been corrupt.  If
  -- this is an incremental restore, the file's checkpoint will not be
  -- advanced, although its absolute fuzziness may be increased.  If this
  -- is a full restore, the file is invalid, and the header is not restored
  -- to a valid state.
  --
  -- It may also happen that the header is corrupt, and so is never seen.
  -- We will detect this when, prior to encountering the file's header, a
  -- piece header is read that indicates that the datafile should be
  -- completely contained on the prior pieces.  This will also cause the
  -- restore of that datafile to fail.
  --
  -- Input parameters:
  --   dfnumber
  --     The datafile number of the datafile to restore.
  --   toname
  --     The name of a file to create or overwrite with the datafile from the
  --     backup set.  This parameter is useful to direct the restore to a
  --     location different from the current datafile location.  If this
  --     parameter is not used, the current datafile is overlaid with
  --     the restored file. This parameter must be specified if the database
  --     is not mounted.
  --
  --     The filename cannot already exist in the controlfile unless it is the
  --     current name of this file. (This check is not performed if the
  --     database is not mounted.) After completing the restore, an "ALTER
  --     DATABASE RENAME FILE 'xxx' TO 'yyy'" command command may be issued
  --     to point the controlfile to the restored datafile.
  --   fuzziness_hint
  --     This is the highest SCN that the client believes is contained in any
  --     block in the backup datafile.  If the client supplies an accurate SCN
  --     then restore performance will be slightly improved, because the file
  --     header will only be re-written before restoring blocks with a higher
  --     SCN.  If the client supplies a number that is greater than the actual
  --     fuzziness in the file, and the restore ends prematurely, then the
  --     datafile may require more redo than is truly necessary to bring the
  --     file to a consistent state.
  --
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   CONVERSATION-NOT-ACTIVE (ora-19580)
  --     A restore conversation was not started before specifying files.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   OUTPUT-NAME-MUST-BE-SPECIFIED (ora-19616)
  --     The database is not mounted, but no output name was specified for
  --     restoreDataFileTo.
  --   WRONG-CONVERSATION-TYPE (ora-19592)
  --     This restore conversation is not for datafiles and controlfiles.
  --   CONVERSATION-IS-VALIDATE-ONLY (ora-19618)
  --     No files can be named after restoreValidate has been called.
  --   NAMING-PHASE-OVER (ora-19604)
  --     The first backup piece has been restored.  No more files can be
  --     named.
  --   DUPLICATE-DATAFILE (ora-19593)
  --     This datafile has already been specified for restoration.
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile or online redo log.
  --   REAL-FILE-NOT-FOUND (ora-19576)
  --     When restoring a datafile to its original location, the
  --     datafile record describing the original file could no longer be
  --     found, probably because the file was dropped from the database.
  --

  PROCEDURE restoreArchivedLogRange(
                              low_change   IN number default 0
                             ,high_change  IN number default 281474976710655 );

  PROCEDURE restoreArchivedLog( thread    IN  binary_integer
                           ,sequence  IN  number );

  -- These procedures specify which logs to restore from a redo log backup
  -- set, and where to restore them. The logs can be specified either by
  -- giving an SCN range(restoreArchivedLogRange) or by giving a thread and
  -- sequence number(restoreArchivedLog). Multiple calls can be made to
  -- specify thread and sequence numbers, but only one SCN range and
  -- destination can be given per restore.
  --
  -- Input parameters:
  --   low_change
  --     Logs only containing redo below this SCN will not be restored unless
  --     explicitly requested by thread and sequence number. A log is not
  --     restored if its next SCN is less than or equal to low_change.
  --   high_change
  --     Logs only containing redo above this SCN will not be restored unless
  --     explicitly requested by thread and sequence number. A log is not
  --     restored if its low SCN is greater than high_change.
  --   thread
  --   sequence
  --     A log to be restored can be specified by giving its thread number and
  --     log sequence number.
  --
  -- Exceptions:
  --   INVALID-SCN (ora-19706)
  --     The incremental start SCN could not be converted into the internal
  --     SCN representation because it is non-integral, less than zero, or
  --     greater than the highest possible SCN.
  --   CONVERSATION-NOT-ACTIVE (ora-19580)
  --     A restore conversation was not started before specifying files.
  --   WRONG-CONVERSATION-TYPE (ora-19592)
  --     This restore conversation is not for archived logs.
  --   ARCHIVELOG-RANGE-ALREADY-SPECIFIED (ora-19621)
  --     Only one archivelog range can be specified per restore conversation.
  --   CONVERSATION-IS-VALIDATE-ONLY (ora-19618)
  --     No files can be named after restoreValidate has been called.
  --   NAMING-PHASE-OVER (ora-19604)
  --     The first backup piece has been restored.  No more files can be
  --     named.
  --   INVALID-RANGE (ora-19628)
  --     The value of high_change is less than the value of low_change.
  --   DUPLICATE-RESTORE-ARCHIVELOG (ora-19636)
  --     This archivelog has already been specified for restoration.


  PROCEDURE restoreValidate;

  -- This procedure is called to force the reading of the entire backup set as
  -- if all files in the backup were being restored. However no data will be
  -- written to any files. Incremental backup application does not require a
  -- valid file for applying the changes. No other calls to specify a restore
  -- file list may be made when this call is used.
  --
  -- After the conversation is complete, a report will be written to an oracle
  -- trace file, giving the status of all the files in the backup set.  The
  -- report looks like this:
  --
  -- Restore Conversation File Status Report
  --   File  Start Finish OK Name
  --   ----- ----- ------ -- --------------------
  --       2     Y      Y  Y
  --       4     Y      Y  Y
  --       6     Y      Y  Y
  --       3     Y      Y  Y
  --       5     Y      Y  Y
  --
  -- One row is printed for each file in the in the backup set.  The columns
  -- are as follows:
  --   start: at least one block for the indicated file was found in the backup
  --          set.
  --   finish: the header for the indicated file was found in the backup set.
  --   OK: the file's data in the backup set is complete and not corrupt.
  --   Name: for non-validation conversations, this is the target for this
  --         file.  This report is not printed for non-validation conversations
  --         unless the krb_trace event is turned on.



 --********************************
 -- Restoration from Backup Piece--
 --*******************************--

  -- The third phase of a restore conversation is to read the pieces that
  -- make up the backup set and write the output files specified in the second
  -- phase. It is impossible to check for errors such as specifying a file
  -- that is not in the backup set until the first piece is read. Errors while
  -- processing a backup piece do not terminate the conversation. If the error
  -- can be repaired (e.g. the correct file is found or the hardware is
  -- fixed), the piece may be successfully reread and restored. However if the
  -- conversation is terminated, the entire backup set must be reread in a new
  -- restore conversation.

  PROCEDURE restoreBackupPiece( handle   IN   varchar2
                               ,done     OUT  boolean
                               ,params   IN   varchar2  default NULL
                               ,fromdisk IN   boolean   default FALSE );

  PROCEDURE applyBackupPiece( handle  IN   varchar2
                             ,done    OUT  boolean
                             ,params  IN   varchar2  default NULL );

  -- These procedures read one backup piece and write its contents to the
  -- files in the restore list.
  -- restoreBackupPiece creates files from complete backups.
  -- applyBackupPiece applies incremental backups to existing datafiles.
  --
  -- As soon as each target file is complete, records will be created in
  -- the appropriate controlfile tables.  Records may be created in the
  -- following tables, depending on the type of restore conversation:
  --
  --   V$DATAFILE_COPY
  --   V$COPY_CORRUPTION
  --   V$ARCHIVED_LOG
  --
  -- If this was the last piece containing data required to restore the
  -- requested objects, then the "done" parameter is set to TRUE and the
  -- conversation is over.  All resources allocated for the conversation are
  -- released.
  --
  -- Input parameters:
  --   handle
  --     The handle of the backup piece to restore from.
  --   params
  --     This string is simply passed to the sequential file open OSD. It is
  --     completely port and device specific.
  --   fromdisk
  --     TRUE if the backuppiece is from device disk. Used to dynamically
  --     allocate a disk context in SBT channel
  -- Output parameters:
  --   done
  --     TRUE if all requested objects have been completely restored, FALSE
  --     otherwise.  Note that the restore may complete before we reach
  --     the last piece of the backup set.  It is an error to call any of
  --     these procedures after "done" is set to TRUE.
  -- Exceptions:
  --   CONVERSATION-NOT-ACTIVE (ora-19580)
  --     A restore conversation was not started before specifying files.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   NO-FILES (ora-19581)
  --     No files have been specified for restoration so there is nothing
  --     to restore.
  --   NOT-A-BACKUP-PIECE (ora-19608)
  --     The input file is not recognizable as a backup piece.
  --   WRONG-BACKUP-SET-TYPE
  --     This backup piece is from the wrong type of backup set.  It cannot
  --     be processed by this conversation.
  --   WRONG-SET (ora-19609)
  --     The backup piece is not part of the backup set being restored from.
  --   WRONG-ORDER (ora-19611)
  --     The backup piece was supplied in the wrong order.
  --   CORRUPT-DIRECTORY (ora-19610)
  --     The backup piece directory is corrupt.
  --   CANT-GET-REAL-FILE-ENQUEUE (ora-19573)
  --     A datafile is locked. Another backup or restore could be in progress,
  --     or some other database activity, such as media recovery, holds an
  --     exclusive enqueue on the file.
  --   FILE-NOT-IN-BACKUP-SET (ora-19615)
  --     At least one of the files which were explicitely named for restoration
  --     is not found in this backup set.  This applies only to
  --     files named by restoreControlFileTo, restoreDataFileTo,
  --     applyDataFileTo, and restoreArchivedLog.  This error is raised only
  --     on the first piece of a backup set.
  --   NO-ARCHIVELOGS-IN-SCN-RANGE (ora-19629)
  --     This backup set contains no archivelogs in the specified range.
  --   DATAFILE-NOT-RESTORED (ora-19612)
  --   ARCHIVELOG-NOT-RESTORED (ora-19622)
  --     The indicated file could not be restored, because some of its
  --     blocks were corrupt in the backup set.
  --   DATAFILE-TOO-OLD
  --     At least one of the datafiles passed to applyDataFileTo is not
  --     current enough to apply this backup set.  This error is raised
  --     only when applying an incremental backup set or a controlfile.
  --   DATAFILE-NOT-FOUND (ora-xxxx)
  --     At least one of the datafiles passed to applyDataFileTo can not
  --     be opened. This error is raised only when applying an incremental
  --     backup set.
  --   RECORD-NOT-FOUND (ora-xxxx)
  --     One of the files specified in the list of files to restore is not
  --     in the backup set. For applying offline ranges in a controlfile
  --     this error is returned when there is no offline range for the file.
  --     This error is only returned on the first piece of a backup set.
  --   WRONG-RESETLOGS
  --     Atempting to apply an incremental backup to a datafile with a
  --     different resetlogs time stamp. This error will not occur when
  --     applying a controlfile if the datafile is checkpointed cleanly
  --     at the beginning SCN of the offline range.

--******************************
-- Restore Conversation Status
--******************************

  PROCEDURE restoreStatus( state        OUT binary_integer
                          ,pieceno      OUT binary_integer
                          ,files        OUT binary_integer
                          ,datafiles    OUT boolean
                          ,incremental  OUT boolean
                          ,device       OUT boolean );

  RESTORE_NO_CONVERSATION  constant binary_integer := 0;
  RESTORE_NAMING_FILES     constant binary_integer := 1;
  RESTORE_PIECE_READ       constant binary_integer := 2;
  RESTORE_PIECE_RETRY      constant binary_integer := 3;

  -- restoreStatus returns information about the current restore
  -- conversation.  It is useful for resyncing with a conversation after
  -- some error has interrupted normal execution, and it is now time to
  -- resume the conversation. It can also be called when there is no
  -- conversation.
  --
  -- Note that there are no exceptions since this does nothing but return
  -- information about this session.
  --
  -- Output parameters:
  --   state
  --     This defines the state of the restore conversation. It is one of the
  --     constants defined above. The constants have the following meanings.
  --       RESTORE_NO_CONVERSATION
  --         No restore conversation is currently active for this session. The
  --         other output values will be NULL when this state is returned. Note
  --         that this state does not signal an error.
  --       RESTORE_NAMING_FILES
  --         Still allowing more calls to describe files to restore. This is
  --         the state immediately after starting the conversation. This state
  --         continues until the first call to read a backup piece.
  --       RESTORE_PIECE_READ
  --         The last call to read a piece completed successfully.
  --         More pieces must be read to complete the restore.
  --       RESTORE_PIECE_RETRY
  --         The most recent call to read a backup piece signalled an error.
  --         The error may have been from writing one of the output
  --         files or some other failure. The return value pieceno does not
  --         include the piece that was being read. The restore can be
  --         continued by reissuing the call to read the same piece or another
  --         copy of the piece.
  --   pieceno
  --     This is the number of backup pieces that have been successfully
  --     restored. It is zero until the first call to read a backup piece
  --     returns successfully.
  --   files
  --     This is the number of files, data files or log files, that have been
  --     named for restoration. It is zero immediately after the conversation
  --     begins.  If restoreArchivedLogRange has been called, then this value
  --     may change after the first backup piece has been read and the number
  --     of files in the backup set which match the specified range has been
  --     determined.
  --   datafiles
  --     TRUE if restoring datafiles; FALSE if restoring archived logs
  --   incremental
  --     TRUE if applying incremental backups of datafiles, or if using
  --     an offline range in a controlfile as an incremental backup.
  --   device
  --     TRUE if a device has been allocated to this session.

 --***********************************
 -- Restore Conversation Termination--
 --**********************************--

  PROCEDURE restoreCancel;

  -- This procedure should be called to abort a restore conversation. It may
  -- be called at any time during a restore conversation. Any resources
  -- acquired to perform the restore are released.  If this conversation
  -- is making full restores of datafiles, or restoring archived logs, then
  -- any partially restored files are unusable.  If this conversation is
  -- applying an incremental backup to existing datafiles, then partially
  -- restored files may still be usable, but their checkpoints may not be
  -- advanced, and they may be fuzzier than before the restore began.

 --*******************
 -- Retryable Errors--
 --******************--

  -- It may be desirable to retry certain backup, restore, or copy
  -- operations if they fail with an I/O error.  The following error code
  -- will be the top error on the stack when a retry may be possible.
  -- There will also be other messages on the error stack which may help a
  -- human to decide if a retry is possible.
  RETRYABLE_ERROR constant binary_integer := -19624;

 --*************************************************
 -- Controlfile Fixed Table Redirection Procedures--
 --***********************************************--

  -- These procedures allow the X$KCC fixed tables to be redirected to read
  -- a "snapshot controlfile" or a backup or standby controlfile rather than
  -- the current controlfile. A snapshot controlfile is a dynamically created
  -- "consistent-read" copy that is created under a dynamically specified
  -- filename. A snapshot controlfile enqueue is used to enforce serialization
  -- across instances of the creation and use of the snapshot controlfile.

  PROCEDURE cfileSetSnapshotName( fname  IN  varchar2 );

  -- This procedure sets the filename to be used for the snapshot
  -- controlfile during subsequent invocations of cfileMakeAndUseSnapshot
  -- and cfileUseSnapshot. However, in case that input filename is NULL,
  -- the procedure deletes the filename record for the snapshot controlfile.
  -- It attempts to acquire the snapshot controlfile enqueue in X mode,
  -- exiting with an exception if it is not available. On success, it exits
  -- with the snapshot controlfile enqueue released.
  --
  -- In case that the filename is not NULL, the file name is saved in the
  -- controlfile so that it is known database wide for the life of the
  -- database. However it will not be known in a standby database. It is
  -- preserved in backup controlfiles.
  -- In case that the filename is NULL, the snapshot controlfile name is
  -- deleted from the control file. In this case, cfileMakeAndUseSnapshot and
  -- cfileUseSnapshot will use default name snapshot controlfile name.
  --
  -- The invoker must not be inside a controlfile transaction when this
  -- routine is called; nor must he already hold the snapshot controlfile
  -- enqueue [as would result, e.g. from a prior invocation of
  -- cfileMakeAndUseSnapshot or cfileUseSnapshot without a matching invocation
  -- of cfileUseCurrent or cfileUseCopy]; nor must he have a copy controlfile
  -- in use [as would result, e.g. from a prior invocation of cfileUseCopy
  -- without a matching invocation of cfileUseCurrent].
  --
  -- Input parameters:
  --   fname
  --     Fully expanded operating system filename to be used for the snapshot
  --     controlfile during subsequent invocations of cfileMakeAndUseSnapshot
  --     and cfileUseSnapshot.
  -- Exceptions:
  --   MULTI-THREADED-SERVER (ora-19550)
  --     This session is not connected to a dedicated server.
  --   SNAPSHOT-ENQUEUE-BUSY (ora-230)
  --     The snapshot controlfile enqueue is in use by another process.
  --   DATABASE-NOT-MOUNTED (ora-xxxx)
  --     The database was not mounted when this procedure was invoked.

  PROCEDURE cfileMakeAndUseSnapshot;

  -- This procedure creates a snapshot of the current controlfile and stores
  -- it in a file it creates using the default filename or previously
  -- specified via cfileSetSnapshotName. It then sets up this process'
  -- PGA such that the X$KCC fixed tables will be redirected to read that
  -- snapshot controlfile rather than the current controlfile.
  -- At entry, it attempts to acquire the snapshot controlfile enqueue
  -- in X mode, exiting with an exception if it is not available, or if it
  -- is already held by this process.
  -- On success, it exits with the snapshot controlfile enqueue held in S mode.
  --
  -- The invoker must not be inside a controlfile transaction when this
  -- routine is called; nor must he already hold the snapshot controlfile
  -- enqueue [as would result, e.g. from a prior invocation of
  -- cfileMakeAndUseSnapshot or cfileUseSnapshot without a matching invocation
  -- of cfileUseCurrent or cfileUseCopy]; nor must he have a copy controlfile
  -- in use [as would result, e.g. from a prior invocation of cfileUseCopy
  -- without a matching invocation of cfileUseCurrent].
  --
  -- Exceptions:
  --   MULTI-THREADED-SERVER (ora-19550)
  --     This session is not connected to a dedicated server.
  --   SNAPSHOT-ENQUEUE-BUSY (ora-230)
  --     The snapshot controlfile enqueue is in use by another process.
  --   DATABASE-NOT-MOUNTED (ora-xxxx)
  --     The database was not mounted when this procedure was invoked.
  --   CREATE-ERROR
  --     An error was reported by the OSD invoked to create the file to hold
  --     the snapshot controlfile.

  PROCEDURE cfileUseSnapshot;

  -- This procedure sets up this process' PGA such that the X$KCC fixed tables
  -- will be redirected to read the snapshot controlfile previously created
  -- via (this or another process' invocation of) cfileMakeAndUseSnapshot.
  -- At entry, it attempts to acquire the snapshot controlfile enqueue in S
  -- mode, exiting with an exception if it is not available, or if it is
  -- already held by this process.  On success, it exits with the snapshot
  -- controlfile enqueue held in S mode.
  --
  -- The invoker must not be inside a controlfile transaction when this
  -- routine is called; nor must he already hold the snapshot controlfile
  -- enqueue [as would result, e.g. from a prior invocation of
  -- cfileMakeAndUseSnapshot or cfileUseSnapshot without a matching invocation
  -- of cfileUseCurrent or cfileUseCopy]; nor must he have a copy controlfile
  -- in use [as would result, e.g. from a prior invocation of cfileUseCopy
  -- without a matching invocation of cfileUseCurrent].
  --
  -- Exceptions:
  --   MULTI-THREADED-SERVER (ora-19550)
  --     This session is not connected to a dedicated server.
  --   SNAPSHOT-ENQUEUE-BUSY (ora-230)
  --     The snapshot controlfile enqueue is in use by another process.
  --   DATABASE-NOT-MOUNTED (ora-xxxx)
  --     The database was not mounted when this procedure was invoked.

  PROCEDURE cfileUseCurrent;

  -- This procedure sets up this process' PGA such that the X$KCC fixed tables
  -- will revert to reading the current controlfile. It releases the
  -- snapshot controlfile enqueue if it was held at entry.  Also closes any
  -- alternate controlfile that this process may currently have had in use for
  -- X$KCC fixed table redirection.
  --
  -- Exceptions:
  --   MULTI-THREADED-SERVER (ora-19550)
  --     This session is not connected to a dedicated server.
  --   DATABASE-NOT-MOUNTED (ora-xxxx)
  --     The database was not mounted when this procedure was invoked.

  PROCEDURE cfileUseCopy( fname  IN  varchar2 );

  -- This procedure sets up this process' PGA such that the X$KCC fixed tables
  -- will be redirected to read a backup or standby controlfile whose filename
  -- is specified.  At entry, it releases the snapshot controlfile enqueue if
  -- it was held at entry.  Also closes any alternate controlfile that this
  -- process may currently have had in use for X$KCC fixed table redirection.
  --
  -- The invoker must not be inside a controlfile transaction when this
  -- routine is called.
  --
  -- Input parameters:
  --   fname
  --     Operating system filename of a backup or standby controlfile to which
  --     all queries on X$KCC fixed tables will be redirected until one of the
  --     following procedures is invoked: cfileUseCurrent, cfileUseSnapshot,
  --     cfileMakeAndUseSnapshot.
  -- Exceptions:
  --   MULTI-THREADED-SERVER (ora-19550)
  --     This session is not connected to a dedicated server.
  --   SNAPSHOT-ENQUEUE-BUSY (ora-230)
  --     The snapshot controlfile enqueue is in use by another process.
  --   DATABASE-NOT-MOUNTED (ora-xxxx)
  --     The database was not mounted when this procedure was invoked.
  --   NOT-A-CONTROLFILE (ora-xxxx)
  --     The file specified by name is not a backup or standby controlfile.

 --********************************
 -- Controlfile Sizing Procedures--
 --******************************--

  -- These procedures are used to resize a record section of the controlfile
  -- and to calculate the size of a controlfile having specified counts of
  -- records of each type.
  --
  -- Valid record types are defined as the following constants:

  RTYP_DB_INFO                    constant binary_integer :=   0;
  RTYP_CKPTPROG                   constant binary_integer :=   1;
  RTYP_THREAD                     constant binary_integer :=   2;
  RTYP_LOGFILE                    constant binary_integer :=   3;
  RTYP_DATAFILE                   constant binary_integer :=   4;
  RTYP_FILENAME                   constant binary_integer :=   5;
  RTYP_TABLESPACE                 constant binary_integer :=   6;
  RTYP_RESERVED1                  constant binary_integer :=   7;
  RTYP_TEMPFILE                   constant binary_integer :=   7;
  RTYP_RMAN_CONFIGURATION         constant binary_integer :=   8;

  RTYP_LOG_HISTORY                constant binary_integer :=   9;
  RTYP_OFFLINE_RANGE              constant binary_integer :=  10;
  RTYP_ARCHIVED_LOG               constant binary_integer :=  11;
  RTYP_BACKUP_SET                 constant binary_integer :=  12;
  RTYP_BACKUP_PIECE               constant binary_integer :=  13;
  RTYP_BACKUP_DFILE               constant binary_integer :=  14;
  RTYP_BACKUP_LOG                 constant binary_integer :=  15;
  RTYP_DFILE_COPY                 constant binary_integer :=  16;
  RTYP_BACKUP_DFILE_CORR          constant binary_integer :=  17;
  RTYP_DFILE_COPY_CORR            constant binary_integer :=  18;
  RTYP_DELETED_OBJECT             constant binary_integer :=  19;
  RTYP_RESERVED3                  constant binary_integer :=  20;
  RTYP_PROXY                      constant binary_integer :=  20;
  RTYP_RESERVED4                  constant binary_integer :=  21;
  RTYP_BACKUP_SPFILE              constant binary_integer :=  21;
  RTYP_DB2                        constant binary_integer :=  22;
  RTYP_INCARNATION                constant binary_integer :=  23;
  RTYP_FLASHBACK                  constant binary_integer :=  24;
  RTYP_RA_INFO                    constant binary_integer :=  25;
  RTYP_INST_RSVT                  constant binary_integer :=  26;
  RTYP_AGED_FILES                 constant binary_integer :=  27;
  RTYP_RMAN_STATUS                constant binary_integer :=  28;
  RTYP_THREAD_INST                constant binary_integer :=  29;
  RTYP_MTR                        constant binary_integer :=  30;
  RTYP_DFH                        constant binary_integer :=  31;
  RTYP_SDM                        constant binary_integer :=  32;
  RTYP_RSP                        constant binary_integer :=  33;
  RTYP_NRR                        constant binary_integer :=  34;
  RTYP_BLOCK_CORRUPTION           constant binary_integer :=  35;
  RTYP_ACM_OPERATION              constant binary_integer :=  36;
  RTYP_FOREIGN_ARCHIVED_LOG       constant binary_integer :=  37;


  PROCEDURE cfileResizeSection( record_type     IN  binary_integer
                               ,before_numrecs  OUT binary_integer
                               ,after_numrecs   OUT binary_integer
                               ,delta_numrecs   IN  binary_integer default 0 );

  -- This procedure attempts to resize the controlfile, expanding or shrinking
  -- the section holding records of the specified "record_type" such that it
  -- will hold "desired_numrecs" (rounded up to the nearest block boundary).
  --
  -- Input parameters:
  --   record_type
  --     The record type whose controlfile section is to be resized.
  --     Valid values are between RTYP_LOG_HISTORY and RTYP_<KCCDIMAX>
  --   delta_numrecs
  --     Number of record slots to expend(+) or shrink(-).  The actual record
  --     slots might be rounded up(while expending) or rounded down(while
  --     shrinking) to the nearest block boundary.
  --     If delta_numrec == 0(default), both before_numrecs and after_numrecs
  --     return current record slots number.
  -- Output parameters:
  --   before_numrecs
  --     The number of record slots in the specified controlfile section at
  --     procedure entry time.
  --   after_numrecs
  --     The number of record slots in the specified controlfile section at
  --     procedure exit time.
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database was not mounted when this procedure was invoked.
  --   INVALID-RECTYPE (ora-xxxx)
  --     record_type was not between RTYP_LOG_HISTORY and RTYP_<KCCDIMAX>
  --   INVALID-DELTA-NUMRECS (ora-00219)
  --     "delta_numrecs" is invalid (either expand or shrink too much)
  --   RESIZE-ERROR
  --     The OSD invoked to resize the controlfile failed to accomplish the
  --     resize.


  FUNCTION cfileCalcSizeList(
                  num_ckptprog_recs          IN  binary_integer  default 0
                 ,num_thread_recs            IN  binary_integer  default 0
                 ,num_logfile_recs           IN  binary_integer  default 0
                 ,num_datafile_recs          IN  binary_integer  default 0
                 ,num_filename_recs          IN  binary_integer  default 0
                 ,num_tablespace_recs        IN  binary_integer  default 0
                 ,num_tempfile_recs          IN  binary_integer  default 0
                 ,num_rmanconfiguration_recs IN  binary_integer  default 0
                 ,num_loghistory_recs        IN  binary_integer  default 0
                 ,num_offlinerange_recs      IN  binary_integer  default 0
                 ,num_archivedlog_recs       IN  binary_integer  default 0
                 ,num_backupset_recs         IN  binary_integer  default 0
                 ,num_backuppiece_recs       IN  binary_integer  default 0
                 ,num_backedupdfile_recs     IN  binary_integer  default 0
                 ,num_backeduplog_recs       IN  binary_integer  default 0
                 ,num_dfilecopy_recs         IN  binary_integer  default 0
                 ,num_bkdfcorruption_recs    IN  binary_integer  default 0
                 ,num_dfcopycorruption_recs  IN  binary_integer  default 0
                 ,num_deletedobject_recs     IN  binary_integer  default 0
                 ,num_proxy_recs             IN  binary_integer  default 0
                 ,num_reserved4_recs         IN  binary_integer  default 0)
    return binary_integer;

  --
  -- Obsolete from 10gR2 onwards - always returns 0
  --
  -- cfileCalcSizeList takes a list of parameters, for each
  -- record type, the number of record slots postulated for the section
  -- containing records of that type.
  --

  TYPE nrecs_array IS TABLE OF binary_integer INDEX BY BINARY_INTEGER;

  FUNCTION cfileCalcSizeArray( num_recs  IN  nrecs_array )
    return binary_integer;

  --
  -- Obsolete from 10gR2 onwards - always returns 0
  --
  -- cfileCalcSizeArray takes an array of parameters, at indices
  -- corresponding to each of the record types RTYP_DB_INFO through
  -- RTYP_<KCCDIMAX>, the number of record slots postulated for the
  -- section containing records of that type.

  -- The two procedures return the size in blocks
  -- ,database blocksize, that the controlfile would have if it were sized
  -- to contain the specified counts of records of each type.
  -- If the number of records is missing for a type then the
  -- number of records in the current controlfile is used.

  -- Input parameters:
  --   num_xxxxx_recs
  --     The input parameters specify the number of records to presume for
  --     each type of record. If a parameter is 0, the value from the
  --     existing controlfile is used.
  --   num_recs
  --     A array giving the sizes of each record type. The indexes in the
  --     table are the record type constants defined above.  If 0, the
  --     values from the existing controlfile are used.
--
  -- Output parameter:
  --   param_in_error
  --     If any of the input parameters or num_recs contains an invalid
  --     number of record, e.g. a negative value or a value
  --     greater than the maximum number of records permitted in a
  --     controlfile section, then param_in_error will contain the index
  --     of the record type of the first parameter in error.  If no error,
  --     it is 0.
--
  -- Return value:
  --   Return the size in blocks needed to contain a controlfile having
  --   sections containing, at least, the specified number of record
  --   slots of each record type.



 --***************************
 -- Miscellaneous Procedures
 --***************************

  PROCEDURE deleteFile( fname  IN  varchar2 );

  -- Delete a file from the operating system. The operating system is called
  -- to delete the file name given. The effect of processes that already have
  -- the file open may differ between platforms. Note that this has no effect
  -- on the state of the database or controlfile. There are no checks to insure
  -- that the file is not part of the database. This may be done at any time.
  --
  -- WARNING! This procedure should not be used to delete files that are named
  -- by controlfile entries. Use deleteDataFile, or deleteRedoLog. Those
  -- routines will mark the controlfile entries as obsolete so that they no
  -- longer appear in V$ tables.
  --
  -- Input parameters:
  --   fname
  --     Name of the operating system file to delete
  -- Exceptions:
  --   FNAME-NOT-SPECIFIED (ora-19634)
  --     The fname must be specified and may not be null.
  --   DELETE-ERROR
  --     An error was reported by the OSD to delete the file.


  PROCEDURE deleteBackupPiece( recid      IN  number
                              ,stamp      IN  number
                              ,handle     IN  varchar2
                              ,set_stamp  IN  number
                              ,set_count  IN  number
                              ,pieceno    IN  binary_integer
                              ,params     IN  varchar2 default NULL );

  -- Delete a backup piece from the storage subsystem. If a controlfile record
  -- ID is given, it is marked as obsolete so that it will no longer appear in
  -- V$BACKUP_PIECE. If the stamp in the record does not match the stamp
  -- argument, the controlfile record will not be marked as obsolete. The
  -- record is marked as obsolete before the OSD is called to do the delete.
  -- Thus a failure could result in the piece continuing to exist while the
  -- controlfile record is marked obsolete. An I/O error during the delete
  -- will return an error, but still mark the controlfile record as obsolete.
  --
  -- A device must be allocated in order to specify the device type. It is
  -- acceptable for some device types to not allocate a specifically named
  -- device for deleting even though a specific device name is needed for
  -- other operations. This is indicated by setting the noio argument to TRUE
  -- for the deviceAllocate procedure.
  --
  -- Input parameters:
  --   recid
  --   stamp
  --     These are the key for the record in the controlfile where the
  --     information about the backup piece was recorded. This is the record
  --     that will be marked as obsolete.
  --   handle
  --     The sequential file handle of the backup piece to delete.  This is
  --     only used if the recid/stamp are not found in the controlfile.  This
  --     field also participates in validation - if the backup piece record
  --     identified by recid/stamp is found and the handle does not match the
  --     handle in that record, then an error is signalled.
  --   set_stamp
  --   set_count
  --   pieceno
  --     Used to validate that the file is the correct file.
  --   params
  --     This string is simply passed to the sequential file delete OSD. It is
  --     completely port and device specific.
  -- Exceptions:
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   RECOVERY-CATALOG-ERROR (ora-19633)
  --     The validation information passed to this function is out of sync
  --     with the information in the controlfile.
  --   FNAME-NOT-SPECIFIED (ora-19634)
  --     The handle must be specified and may not be null.
  --   DELETE-ERROR
  --     An error was reported by the OSD to delete the file.

  PROCEDURE deleteDataFileCopy( recid              IN  number
                               ,stamp              IN  number
                               ,fname              IN  varchar2
                               ,dfnumber           IN  binary_integer
                               ,resetlogs_change   IN  number
                               ,creation_change    IN  number
                               ,checkpoint_change  IN  number
                               ,blksize            IN  number
                               ,no_delete          IN  binary_integer );

  PROCEDURE deleteArchivedLog(recid             IN  number
                             ,stamp             IN  number
                             ,fname             IN  varchar2
                             ,thread            IN  number
                             ,sequence          IN  number
                             ,resetlogs_change  IN  number
                             ,first_change      IN  number
                             ,blksize           IN  number );

  -- These procedures delete an operating system file and mark its record in
  -- the controlfile as obsolete so that its row will not appear in the fixed
  -- view. If the stamp in the record does not match the stamp argument, the
  -- controlfile record will not be marked as obsolete. The record is marked
  -- as obsolete before the OSD is called to do the delete. Thus a failure
  -- could result in the piece continuing to exist while the controlfile record
  -- is marked obsolete. An I/O error during the delete will return an error,
  -- but still mark the controlfile record as obsolete.
  --
  -- Input parameters:
  --   recid
  --   stamp
  --     These are the key of the record in the controlfile where the
  --     information about the file was recorded. This is the record
  --     that will be marked as obsolete.
  --   fname
  --     Name of the operating system file to delete.  This is
  --     only used if the recid/stamp are not found in the controlfile.  This
  --     field also participates in validation - if the backup piece record
  --     identified by recid/stamp is found and the handle does not match the
  --     handle in that record, then an error is signalled.
  --   dfnumber
  --     Absolute file number.  This and the remaining parameters are used to
  --     validate the file if the record is not found in the controlfile.
  --   resetlogs_change
  --     Resetlogs SCN.
  --   creation_change
  --     Creation SCN.
  --   checkpoint_change
  --     Checkpoint SCN.
  --   blksize
  --     Blocksize.
  --   thread
  --     Log thread number.
  --   sequence
  --     Log sequence number.
  --   first_change
  --     Low SCN.
  --   no_delete
  --     Flag for UNCATALOG option, datafile'll not be deleted when set
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   RECOVERY-CATALOG-ERROR (ora-19633)
  --     The validation information passed to this function is out of sync
  --     with the information in the controlfile.
  --   FNAME-NOT-SPECIFIED (ora-19634)
  --     The handle must be specified and may not be null.
  --   DELETE-ERROR
  --     An error was reported by the OSD to delete the file.

  -- we need a placeholder for the deleted function, getDbInfo, in order
  -- to maintain pl/sql compatibility.
  PROCEDURE DELETED_getDbInfo;

  PROCEDURE getFno( name             IN   varchar2
                   ,dfnumber         OUT  binary_integer
                   ,creation_change  OUT  number );

  -- This procedure will expand the name and compare it with all the datafile
  -- names and return the file number for the matching file. The comparison is
  -- done through the operating system so that two different names for the same
  -- file will compare as equal. This is used to convert file names from the
  -- user into file numbers for use with the other procedures in this package.
  -- A straight string compare will no suffice because there maybe multiple
  -- names that refer to the same file. The database must be mounted so that
  -- the file names can be queried from the controlfile. Note that a call to
  -- switchControlfile will have no effect on getFno.
  --
  -- Input parameters:
  --   name
  --     The name of the file to lookup in the controlfile.
  -- Output parameters:
  --   dfnumber
  --     The number of the datafile with the matching name.
  --   creation_change
  --     The SCN that was allocated when the file was created.
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   FILE-NUMBER-NOT-FOUND (ora-19632)
  --     No datafile with this name could be found in the controlfile.

  FUNCTION scanDataFile(dfnumber     IN  binary_integer,
                        max_corrupt  IN  binary_integer default 0,
                        update_fuzziness IN boolean default true)
  return number;

  FUNCTION scanDataFileCopy(recid  IN number,
                            stamp  IN number,
                            max_corrupt IN binary_integer default 0,
                            isbackup    IN  boolean default FALSE,
                            update_fuzziness IN boolean default true)
  return number;

  PROCEDURE scanArchivedLog(recid IN number,
                            stamp IN number);

  -- Scans a file and verifies the checksum (if present) in each block.
  --
  -- If processing the current datafile, the database must be closed or the
  -- file must be offline.
  --
  -- Input parameters:
  --   dfnumber
  --     The real datafile to scan.
  --   recid, stamp
  --     The datafile copy or archivelog to scan.
  --   max_corrupt
  --     Up to this many corrupt data blocks (blocks that fail cache header
  --     validation) may appear in this file.  The file header will not be
  --     be updated if more blocks than this fail cache header validation.
  --   isbackup
  --     If true, then Recovery Manager is treating this file as a level 0
  --     backup in the database's recovery strategy.  This information is
  --     simply stored in the V$DATAFILE_COPY record created by this inspect
  --     operation, and has no other effect.
  --   update_fuzziness
  --     If true, then the fuzziness information in the header of a datafile
  --     will be updated.  The file's fuzziness is the highest SCN in the
  --     cache header of any block in the datafile, plus one.
  -- Returns:
  --   If update_fuzziness is true, then the return value is the absolute
  --   fuzzy SCN of the file, otherwise the return value is undefined.
  --

  PROCEDURE switchToCopy( copy_recid  IN  number
                         ,copy_stamp  IN  number );

  -- Causes the filename in the indicated datafile copy record to become
  -- the current named datafile.  The file number to rename is taken from
  -- the V$DATAFILE_COPY record.  Does the following:
  --
  -- 1. Begin a read/write controlfile transaction.
  -- 2. If the database is open, ensure that the named file is not open.
  -- 3. Validate that the data in the V$DATAFILE_COPY record matches the
  --    data in the file header of the copied file.
  -- 4. Alter the file name entry for the named file to point to the copy.
  -- 5. Mark the V$DATAFILE_COPY record as deleted.
  -- 6. End the controlfile transaction.
  --
  -- Much of what this function does could have been done in the ordinary
  -- 'alter database rename file' code - that code could scan the
  -- V$DATAFILE_COPY records and delete any that are consumed by the
  -- rename.  The code could also perform the additional header validations
  -- that are required when we know that the destination file exists.
  -- There are two reasons why we decided not to do this:
  -- 1. No matter how efficient we are in deleting obsolete V$DATFILE_COPY
  --    records, the Recovery Manager will still need its own algorithm to
  --    detect when some operation has caused a named file to consume a
  --    datafile copy.  This is because the appropriate datafile copy record
  --    may have been reused in the controlfile, and only exists in the
  --    recovery catalog when, for example, a user issues a 'rename' that
  --    consumes a datafile copy.
  -- 2. If we decide to add such special handling for 'rename', we would also
  --    have to add code to 'alter tablespace add datafile', and perhaps other
  --    functions as well, and we don't want to do all that right now.
  --
  -- Input parameters:
  --   copy_recid
  --     The record ID from V$DATAFILE_COPY for the datafile copy. This
  --     is the record ID returned from inspectDataFileCopy or a previous call
  --     to make a datafile copy.
  --   copy_stamp
  --     The stamp that corresponds to copy_recid. This is to insure that the
  --     record is the same one that was selected.
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   RECORD-NOT-FOUND (ora-19571)
  --     The specified datafile copy record does not exist.
  --   RECORD-NOT-VALID (ora-19588)
  --     The specified datafile copy record is no longer valid - it has been
  --     marked as deleted.
  --   CANNOT-RENAME-TO-FILE (ora-01523)
  --     The specified file is already part of the database.
  --   FILE-IS-OPEN (ora-19623)
  --     The controlfile record points to a file that is currently open
  --     by the database.
  --   FILE-NOT-FOUND (ora-19625)
  --     The file can not be opened.
  --   FILE-VALIDATION-FAILURE (ora-19563)
  --     The file is not the file described by the controlfile record.

  FUNCTION normalizeFileName (fname IN varchar2) RETURN varchar2;

  -- Normalizes the file name according to the rules of the target
  -- database and returns the normalized filename.
  --
  -- Input parameters:
  --   fname
  --     File name to be normalized.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.

  FUNCTION validateBackupPiece(recid      IN  number
                               ,stamp     IN  number
                               ,handle    IN  varchar2
                               ,set_stamp IN  number
                               ,set_count IN  number
                               ,pieceno   IN  binary_integer
                               ,params    IN  varchar2 default NULL)
                               return binary_integer;

  FUNCTION validateDataFileCopy(recid              IN  number
                                ,stamp             IN  number
                                ,fname             IN  varchar2
                                ,dfnumber          IN  binary_integer
                                ,resetlogs_change  IN  number
                                ,creation_change   IN  number
                                ,checkpoint_change IN  number
                                ,blksize           IN  number)
                                return binary_integer;

  FUNCTION validateArchivedLog(recid             IN  number
                               ,stamp            IN  number
                               ,fname            IN  varchar2
                               ,thread           IN  number
                               ,sequence         IN  number
                               ,resetlogs_change IN  number
                               ,first_change     IN  number
                               ,blksize          IN  number)
                               return binary_integer;

  VALIDATE_OK               constant binary_integer := 0;
  VALIDATE_RECORD_NOTFOUND  constant binary_integer := 1;
  VALIDATE_RECORD_DIFFERENT constant binary_integer := 2;
  VALIDATE_FILE_DIFFERENT   constant binary_integer := 4;
  VALIDATE_IN_USE           constant binary_integer := 8;
  VALIDATE_DEL_FOR_SPACE    constant binary_integer := 16;

  -- Validate the correctness of the information in the recovery catalog
  -- and the controlfile regarding a backup piece, datafile copy, or
  -- archived log.  Neither the controlfile record nor the file itself is
  -- deleted.  No errors are signalled.  The return code contains one or more
  -- of the above constants, which tell the caller whether the controlfile
  -- record and/or the file itself is valid.  These constants are bit-flags,
  -- so bitand() must be used to decode the return code's value.  The status
  -- of the file itself is independant of the status of the record in the
  -- controlfile.  If the file is not found or does not match the validation
  -- data, then the VALIDATE_FILE_DIFFERENT flag will be set.  If the
  -- record in the controlfile is not found or is different, the corresponding
  -- VALIDATE_RECORD_xxx flag will be set.  The two VALIDATE_RECORD_xxx flags
  -- are mutually exclusive.  Thus, the possible return codes from the validate
  -- functions are: 0, 1, 2, 4, 5, and 6.
  --
  -- These procedures do not update the controlfile.
  --
  -- Input parameters:
  --   stamp
  --   recid
  --     These are the key of the record in the controlfile where the
  --     information about the file was recorded.  This is the record
  --     that will be marked as obsolete if the file is no longer valid.
  --   handle
  --   fname
  --     The name or handle of the file/piece to validate.
  --   params
  --     This string is simply passed to the sequential file reading OSD. It
  --     is completely port and device specific.

  --   The remaining parameters are used to determine whether or not the
  --   file in question is the correct file.

  --   set_stamp
  --   set_count
  --     Backup set identification.
  --   pieceno
  --     Piece number within backup set.
  --   dfnumber
  --     Absolute file number.
  --   resetlogs_change
  --     Resetlogs SCN.
  --   creation_change
  --     Creation SCN.
  --   checkpoint_change
  --     Checkpoint SCN.
  --   blksize
  --     Blocksize.
  --   thread
  --     Log thread number.
  --   sequence
  --     Log sequence number.
  --   first_change
  --     Low SCN of archived log.
  -- Returns:
  --   VALIDATE_OK
  --     Both the record and file exist, and the contents of the controlfile
  --     record, the file header, and the caller's validation data are the
  --     same.
  --   VALIDATE_RECORD_NOTFOUND
  --     The specified recid/stamp is not found in the controlfile.
  --   VALIDATE_RECORD_DIFFERENT
  --     The specified recid/stamp is found in the controlfile but its contents
  --     don't match the user's validation data.
  --   VALIDATE_FILE_DIFFERENT
  --     The specified recid/stamp is found in the controlfile and its contents
  --     match the user's validation data, but the file is either not found or
  --     its contents don't match.
  -- Exceptions:
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --     Applies to validateBackupPiece only.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   RECOVERY-CATALOG-ERROR (ora-19633)
  --     The validation information passed to this function is out of sync
  --     with the information in the controlfile.
  --   FNAME-NOT-SPECIFIED (ora-19634)
  --     The handle or file name must be specified and may not be null.
  --   If signal is not zero, then krbcdie[] exceptions are possible.

  function getParm(parmid IN binary_integer,
                   parmno IN binary_integer default null) return varchar2;

  -- Return some parameter string value.
  -- The valid list of parmid's follows.

  -- Get the default value for the snapshot controlfile name.
  SNAPSHOT_NAME    constant binary_integer := 0;

  -- Get the controlfile name(s) from the parameter file.  parmno must be a
  -- value between 1 and the number of controlfiles defined in the
  -- CONTROL_FILES initialization parameter.
  CONTROL_FILE     constant binary_integer := 1;

  -- Get the pattern or replace string for db_file_name_convert
  -- parmno must be greater than 0
  DBF_CONVERT      constant binary_integer := 2;

  -- Get the pattern or replace string for log_file_name_convert
  -- parmno must be greater than 0
  LOG_CONVERT      constant binary_integer := 3;

  -- Get the default value for the SPFILE name.
  -- parmno is ignored
  -- The name is retrieved in following order:
  -- 1) If _restore_spfile is set to a non empty string, then return.
  -- 2) If _restore_spfile is not set, the parse default pfile location
  --    for a spfile value. If set to a non-empty string, then return.
  -- 3) Return default spfile location.
  SPFILE_DEFAULT   constant binary_integer := 4;

  -- Force the current incremental backup conversation to *not* attempt to
  -- accelerate using change tracking data
  INCR_NOCT        constant binary_integer := 5;

  -- Return the default format for controlfile autobackups on DISK devices.
  -- parmno is ignored
  CFAUTO_DISK_DEFAULT   constant binary_integer := 6;

  -- Return the default format for controlfile autobackups on TAPE devices.
  -- parmno is ignored
  CFAUTO_TAPE_DEFAULT   constant binary_integer := 7;

  -- Return the default format for datafilecopies and backups.
  -- parmno is ignored
  FORMAT_DEFAULT   constant binary_integer := 8;

  -- Force the current full backup conversation to *not* attempt to
  -- optimize backing up only the allocated blocks
  FULL_NOOPTIM     constant binary_integer := 9;

  -- Get the platform id of the database
  PLATFORM_ID      constant binary_integer := 10;

  -- Get trace file name
  TRACE_FILENAME   constant  binary_integer := 11;

  -- Get password file name
  PASSWORD_FILENAME constant binary_integer := 12;

  -- Check KD_ACO_ENABLED, return T is enabled, F otherwise
  ACO_ENABLED constant binary_integer := 13;

  -- Same as CONTROL_FILE, but also look at DB_FILE_CREATE_DEST, not only
  -- at v$parameter
  XCONTROL_FILE   constant binary_integer := 14;

  --  Required by instant restore feature to get the backing file name
  --  from an instantly restored datafile
  BACKING_FILENAME constant  binary_integer := 15;

  PROCEDURE applyOfflineRange(cfname  in varchar2 default null,
                              dfname  in varchar2 default null,
                              blksize in number   default null,
                              recid   in number   default null,
                              stamp   in number   default null,
                              fno     in binary_integer);

  -- This applies an offline range record from the named controlfile to the
  -- named datafile.  The controlfile can be either a backup controlfile or
  -- a current controlfile.  The datafile must be from the same database as
  -- the controlfile.  The offline range record identified by the
  -- recid/stamp parameters will be used as an incremental backup which
  -- contains no block images since there were no blocks changed.  If the
  -- datafile's checkpoint is exactly at the beginning of the offline
  -- range, and the file is not fuzzy, then it will have datafile with a
  -- checkpoint at the beginning of offline range will have its checkpoint
  -- updated to the end of the offline range.
  --
  -- This has one advantage over a real incremental backups: a controlfile
  -- can be applied to a file that has a different resetlogs stamp, but an
  -- incremental backup can not modify the resetlogs stamp in a file
  -- header.
  --
  -- Note that it is not necessary to apply the current controlfile if the
  -- database is mounted. That will be done automatically by applying either
  -- redo logs or incremental backup.
  --
  -- Input parameters:
  --   cfname
  --     the operating system filename of the controlfile that contains the
  --     desired offline range record.
  --   dfname
  --     the operating system name of the datafile whose checkpoint will
  --     be advanced if it meets the criteria described above.  if null,
  --     fno must not be null.
  --   blksize
  --     Oracle block size of the specified datafile.
  --   recid
  --   stamp
  --     the recid and stamp of the desired offline range record.
  --   fno
  --     datafile number.  if dfname is null, then apply to the current
  --     datafile with this number.  ignored unless dfname is null.
  -- Exceptions:
  --   CONVERSATION-ACTIVE (ora-19590)
  --     There is still either a backup or restore conversation still active
  --     in this session.

  procedure getCkpt(ckp_scn OUT number
                   ,high_cp_recid OUT number -- 1
                   ,high_rt_recid OUT number -- 2
                   ,high_le_recid OUT number -- 3
                   ,high_fe_recid OUT number -- 4
                   ,high_fn_recid OUT number -- 5
                   ,high_ts_recid OUT number -- 6
                   ,high_r1_recid OUT number -- 7
                   ,high_rm_recid OUT number -- 8
                   ,high_lh_recid OUT number -- 9
                   ,high_or_recid OUT number -- 10
                   ,high_al_recid OUT number -- 11
                   ,high_bs_recid OUT number -- 12
                   ,high_bp_recid OUT number -- 13
                   ,high_bf_recid OUT number -- 14
                   ,high_bl_recid OUT number -- 15
                   ,high_dc_recid OUT number -- 16
                   ,high_fc_recid OUT number -- 17
                   ,high_cc_recid OUT number -- 18
                   ,high_dl_recid OUT number -- 19
                   ,high_r3_recid OUT number -- 20
                   ,high_r4_recid OUT number -- 21
                   );

  -- Obtains an SCN and returns the high-recids from the controfile record
  -- section for each type of controlfile record.  The recids and the
  -- SCN are allocated from inside a controlfile transaction.  If the database
  -- is not open, then the SCN is calculated in the same way as for
  -- a backup controlfile.

  procedure sleep(secs IN binary_integer);

  -- Sleep for the specified number of seconds.

  function checkFileName(name IN varchar2) return number;
  -- Returns 0 if the filename is not in use by the database as a
  -- controlfile, datafile, or online logfile.  Returns 1 if the filename
  -- is in use.  The filename must be normalized by the caller.

  procedure set_client_info(client_info IN varchar2);
  -- This is equivalent to dbms_application_info.set_client_info, and was
  -- added so RMAN could call it from recover.bsq without needing to make
  -- the x$kqp326 package spec public.

  PROCEDURE set_charset(charset_name IN VARCHAR2);
  -- If the database is closed, then make the specified charset be
  -- the charset for this session.

  -- ********************************************************
  -- Proxy Copy procedures
  -- ********************************************************

  -- Proxy copy is a new backup paradigm.  Instead of Oracle reading
  -- the datafiles and passing the data to a storage subsystem (or doing
  -- the reverse when restoring), we simply pass the name of a file to be
  -- backed up, and a backup handle, to the storage subsystem, which
  -- handles all of the data movement.
  --
  -- These procedures are conversational, as are the backup/restore
  -- procedures above, and they also require that a device be allocated
  -- prior to calling them.  The allocated device may not be of type DISK,
  -- because the DISK device does not invoke an external media manager.
  --
  -- The parameters to these routines have the same semantics as the
  -- corresponding parameters to the non-proxy routines above.
  --
  -- A new controlfile record type is used to record the existence of proxy
  -- copies in the controlfile.  The same record type is used to store
  -- information about both proxy datafiles and proxy archived logs, but
  -- two different fixed views are used to display the information:
  -- v$proxy_datafile and v$proxy_archivedlog.

  PROCEDURE proxyBeginBackup(tag           IN   varchar2        default NULL
                            ,incremental   IN   boolean         default FALSE
                            ,media_pool    IN   binary_integer  default 0
                            ,set_stamp     OUT  number
                            ,set_count     OUT  number);

  -- Begin a proxy backup session.  The database must be mounted for proxy
  -- backups, so that the backups can be recorded in the controlfile.
  --
  -- Input Parameters
  --   tag
  --     An arbitrary user-defined tag, up to 30 characters long, that is
  --     stored in the controlfile record describing DATAFILES that are
  --     proxy backed up.  Proxy ARCHIVELOGS do not have a tag.
  --   incremental
  --     If TRUE, then this file will be considered as a level-0 incremental
  --     backup, which can be the basis for subsequent incremental backups.
  --     This applies only to datafiles, not archived logs.
  --   media_pool
  --     a number from 0-255 whose meaning is defined by rman or by 3rd-party
  --     media management software.
  --   set_stamp
  --   set_count
  --     a timestamp and counter that are used by recovery manager to generate
  --     unique file names.

  PROCEDURE proxyBeginRestore(destination IN varchar2 default NULL);

  -- Begin a proxy restore session.  The database does not have to be mounted,
  -- unless datafiles are to be restored to their default locations (see
  -- proxyRestoreDataFile).  However, if the database is mounted, then records
  -- describing the restored files will be added to the currently mounted
  -- controlfile.
  --
  -- Input Parameters
  --   destination
  --     This is used to construct the file name for creating restored
  --     archived logs.  It is ignored when restoring datafiles.  If not
  --     specified, the init.ora log_archive_dest parameter is used.

  PROCEDURE proxyBackupDatafile(file# IN binary_integer, handle IN varchar2);
  PROCEDURE proxyBackupDatafileCopy(copy_recid IN number,
                                    copy_stamp IN number,
                                    handle IN varchar2);
  -- Specify one datafile or datafile copy to be backed up during a
  -- proxy copy session.
  --
  -- Input Parameters:
  --   file#
  --     the absolute file number of a datafile to be backed up.
  --   copy_recid
  --   copy_stamp
  --     the controlfile identifiers of a controlfile to be backed up.
  --   handle
  --     the filename of this backup in the media management catalog.

  PROCEDURE proxyBackupControlfile(name IN varchar2 default NULL,
                                   handle IN varchar2);

  -- Specify one controlfile to be backed up with proxy copy.
  --
  -- Input Parameters:
  --   name
  --     the name of a backup controlfile to back up.  If NULL, the snapshot
  --     controlfile will be backed up.
  --   handle
  --     the filename of this backup in the media management catalog

  PROCEDURE proxyBackupArchivedlog(arch_recid IN number,
                                   arch_stamp IN number,
                                   handle IN varchar2);

  -- Specify one archived log to be backed up during a proxy copy session.
  -- Input Parameters:
  --   arch_recid
  --   arch_stamp
  --     the archivedlog identifiers of a log file to be backed up
  --   handle
  --     the filename of this backup in the media management catalog

  PROCEDURE proxyRestoreDatafile(handle IN varchar2,
                                 file# IN binary_integer,
                                 toname IN varchar2 default NULL);

  -- Specify one datafile to be restored during a proxy session.  An
  -- exclusive access enqueue will be obtained for this file at this time,
  -- so that multiple restores of the same file can not run concurrently.
  --
  -- Input Parameters:
  --   handle
  --     the filename that was extracted from the v$proxy_datafile.handle
  --     column after this file was proxy backed up.
  --   file#
  --     the absolute file number of the file to be restored
  --   toname
  --     the OS file name to which the file should be restored.  If this is
  --     null, then the file will be restored to the name indicated in the
  --     controlfile (and, in this case, the controlfile must be mounted).

  PROCEDURE proxyRestoreControlfile(handle IN varchar2,
                                    toname IN varchar2);

  -- Name a controlfile to be restored with proxy copy.
  --
  -- Input Parameters
  --   handle
  --     the filename that was extracted from the v$proxy_datafile.handle
  --     column after this file was proxy backed up.
  --   toname
  --     the OS file name to which the file should be restored.
  --     When passed as NULL and database is not mounted, we restore and
  --     replicate the controlfiles to all names that match current
  --     controlfiles in parameter file.


  PROCEDURE proxyRestoreArchivedlog(handle      IN varchar2,
                                    thread      IN binary_integer,
                                    sequence    IN number);

  -- Specify one archived log to be restored during a proxy session.
  --
  -- Input Parameters
  --   handle
  --     the filename that was extracted from the v$proxy_archivedlog.handle
  --     column after this file was proxy backed up.
  --   thread
  --   sequence
  --     these will be used in conjunction with the destination that was
  --     passed to proxyBeginRestore (or LOG_ARCHIVE_DEST, if that was not
  --     specified) to construct the file name to be restored.

  PROCEDURE proxyGo;

  -- Called after all the files have been named.  Does not return until the
  -- proxy copy is complete.  All of the data movement is performed here.

  FUNCTION proxyQueryBackup(name in varchar2) return binary_integer;
  -- check to see if this file can be backed up using proxy copy:

  FUNCTION proxyQueryRestore(handle IN varchar2,
                             toname IN varchar2) return binary_integer;
  -- Determine if the indicated datafile can be restored from the specified
  -- proxy backup file.
  --
  -- proxyQueryBackup and proxyQueryRestore each return one of the
  -- following values, indicating whether the requested operation can be
  -- performed or not.

  CAN_PROXY constant binary_integer := 0;
  CANNOT_PROXY constant binary_integer := 1;

  PROCEDURE proxyCancel;
  -- End the proxy conversation.  Note that this never stops an
  -- 'in-progress' backup, because proxyGo blocks until the proxy is
  -- complete.  This procedure simply clears out the file list if some
  -- files have been named for backup or restore but proxyGo was never
  -- called.

  PROCEDURE proxyDelete(recid  IN number,
                        stamp  IN number,
                        handle IN varchar2,
                        params IN varchar2 default NULL);
  FUNCTION proxyValidate(recid  IN number,
                         stamp  IN number,
                         handle IN varchar2,
                         params IN varchar2 default NULL)
    return binary_integer;

  -- Change proxy backup status, delete from the storage subsystem, or
  -- validate that a proxy backup exists in the storage subsystem.

  -- proxyValidate changes status in the controlfile to 'A' or 'X'
  -- appropriately.  The media management catalog is not affected.

  -- For proxyChange status=='D', if a controlfile record ID is given, it
  -- is marked obsolete so that it will no longer appear in V$PROXY_DATAFILE or
  -- V$PROXY_ARCHIVEDLOG. If the stamp in the record does not match the stamp
  -- argument, the controlfile record will not be marked as obsolete.  The
  -- record is marked as obsolete before the OSD is called to do the delete.
  -- Thus a failure could result in the backup file continuing to exist while
  -- the controlfile record is marked obsolete.

  -- A device must be allocated in order to specify the device type.  It is
  -- acceptable for some device types to not allocate a specifically named
  -- device for deleting even though a specific device name is needed for
  -- other operations. This is indicated by setting the noio argument to TRUE
  -- for the deviceAllocate procedure.
  --
  -- Input parameters:
  --   recid
  --   stamp
  --     These are the key for the record in the controlfile where the
  --     information about the backup piece was recorded. This is the record
  --     that will be marked as obsolete.  This will either be a record in
  --     v$proxy_datafile or v$proxy_archivedlog.  Note that these two tables
  --     share the same recid space, because they are based on the same
  --     underlying controlfile record section (kccpc).
  --   handle
  --     The handle of the proxy backup to delete.  This is only used if the
  --     recid/stamp are not found in the controlfile.  This
  --     field also participates in validation - if the record
  --     identified by recid/stamp is found and the handle does not match the
  --     handle in that record, then an error is signalled.
  --   params
  --     This string is simply passed to the sequential file delete OSD. It is
  --     completely port and device specific.

  PROCEDURE getMaxInfo(mlogf      OUT  binary_integer
                      ,mlogm      OUT  binary_integer
                      ,mdatf      OUT  binary_integer
                      ,minst      OUT  binary_integer
                      ,mlogh      OUT  binary_integer
                      ,chset      OUT  varchar2);
  -- This procedure is used to obtain the max values for the parameters used
  -- in the create controlfile command.  These values cannot be obtained
  -- from tables, as are only kept in the sga.
  --
  -- Input parameters:
  --   NONE
  --
  -- Output parameters:
  --   mlogf
  --     At end will contain the maximum number of logfiles
  --   mlogm
  --     At end will contain the maximum number of log members
  --   mdatf
  --     At end will contain the maximum number of datafiles
  --   minst
  --     At end will contain the maximum number of instances
  --   mlogh
  --     At end will contain the maximum number of log history
  --   chset
  --     At end will contain the character set of the database

  PROCEDURE zeroDbid(fno       IN   binary_integer);

  -- This procedure is used to update the header of a datafile so that the
  -- a new dbid would be calculated later on with a create controlfile
  -- statement.  This is necessary for the cloning of a database
  -- The file to update is identified by the fno input parameter, a special
  -- case is allowed when fno == 0, such that all the headers of the datafiles
  -- in the control file are zeroed out.
  -- Three fields in the datafile header (stored in the first block)
  -- are zeroed out:
  --     The field that holds the database id
  --     The checksum field
  --     The bit that signals that the checksum is valid
  --
  -- There are no return values
  --
  -- Input parameters:
  --   fno
  --     Identifies the file number of the datafile that will be modified
  --     If it is zero, all datafiles listed in the controlfile are updated.
  -- Output parameters:
  --   NONE

  FUNCTION ValidateTableSpace( tsid       IN binary_integer
                              ,cSCN       IN number )
           RETURN binary_integer;

  -- This procedure is used to validate that the tablespace has not
  -- been recreated when performing TSPITR.  To that effect it receives
  -- the id of the tablespace and the minimum creation scn of the
  -- datafiles at the PIT for the tablespace.
  -- This creation scn is checked against the current value stored in
  -- ts$, if the creation_scn is less than that value, it indicates
  -- that the TSPITR is trying to restore to a PIT before the recreation
  -- of the database, which is not allowed.
  --
  -- Return values
  --   0 if the tablespace has been recreated
  --   1 if the tablespace was not recreated
  --
  -- Input parameters:
  --   tsid
  --     Id of the tablespace that is being TSPITRed
  --   cSCN
  --     Minimum creation SCN of all datafiles of the tablespace at
  --     the PIT of the TSPITR
  -- Output parameters:
  --   NONE

  --
  -- Modified functions
  --

  FUNCTION deviceAllocate( type    IN  varchar2 default NULL
                          ,name    IN  varchar2 default NULL
                          ,ident   IN  varchar2 default NULL
                          ,noio    IN  boolean  default FALSE
                          ,params  IN  varchar2 default NULL
                          ,node    OUT varchar2
                          ,dupcnt  IN  binary_integer
                          ,trace   IN  binary_integer default 0)
    RETURN varchar2;


  --
  -- Description and return values can be found with original declaration
  -- above.  The new arguments are:
  --   node
  --     The node where this channel is allocated.  This is what ksxamn()
  --     returns.
  --
  --   In order to support duplexed channels we need new parameter to
  --   deviceAllocate.
  --
  --   dupcnt
  --     This number indicates how many copies of each backup piece should
  --     be made.  Default is 1, and current maximum is 4.
  --
  --   trace
  --     This number is passed to the underlying media management software.
  --     Its meaning is defined by the MMS.
  --



 --********************************************
 -- Backup Conversation Initiation Procedures--
 --*******************************************--

  PROCEDURE backupSetDataFile( set_stamp     OUT  number
                              ,set_count     OUT  number
                              ,nochecksum    IN   boolean         default FALSE
                              ,tag           IN   varchar2        default NULL
                              ,incremental   IN   boolean         default FALSE
                              ,backup_level  IN   binary_integer  default 0
                              ,check_logical IN   boolean);

  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  check_logical
  --    if set to true indicates that besides physical block validations,
  --    logical validations will be performed on each block


  PROCEDURE backupPieceCreate( fname    IN  varchar2
                              ,pieceno  OUT binary_integer
                              ,done     OUT boolean
                              ,handle   OUT varchar2
                              ,comment  OUT varchar2
                              ,media    OUT varchar2
                              ,concur   OUT boolean
                              ,params   IN  varchar2  default NULL
                              ,media_pool IN binary_integer);
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --   media_pool
  --     a number from 0-255 whose meaning is defined by rman or by 3rd-party
  --     media management software.

  PROCEDURE backupPieceCreate( fname    IN  varchar2
                              ,pieceno  OUT binary_integer
                              ,done     OUT boolean
                              ,handle   OUT varchar2
                              ,comment  OUT varchar2
                              ,media    OUT varchar2
                              ,concur   OUT boolean
                              ,params   IN  varchar2  default NULL
                              ,media_pool IN binary_integer  default 0
                              ,reuse    IN boolean);
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --   reuse
  --     indicates if the piece should be removed before creating it

  PROCEDURE backupBackupPiece( bpname   IN   varchar2
                              ,fname    IN   varchar2
                              ,handle   OUT  varchar2
                              ,comment  OUT  varchar2
                              ,media    OUT  varchar2
                              ,concur   OUT  boolean
                              ,recid    OUT  number
                              ,stamp    OUT  number
                              ,tag      IN   varchar2  default NULL
                              ,params   IN   varchar2  default NULL
                              ,media_pool IN binary_integer default 0
                              ,reuse    IN boolean default FALSE
                              ,check_logical   IN   boolean);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  check_logical
  --    if set to true indicates that besides physical block validations,
  --    logical validations will be performed on each block

  PROCEDURE copyDataFile( dfnumber     IN   binary_integer
                         ,fname        IN   varchar2
                         ,full_name    OUT  varchar2
                         ,recid        OUT  number
                         ,stamp        OUT  number
                         ,max_corrupt  IN   binary_integer default 0
                         ,tag          IN   varchar2  default NULL
                         ,nochecksum   IN   boolean   default FALSE
                         ,isbackup     IN   boolean   default FALSE
                         ,check_logical IN  boolean);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  check_logical
  --    if set to true indicates that besides physical block validations,
  --    logical validations will be performed on each block




  PROCEDURE copyDataFileCopy( copy_recid   IN   number
                             ,copy_stamp   IN   number
                             ,full_name    OUT  varchar2
                             ,recid        OUT  number
                             ,stamp        OUT  number
                             ,fname        IN   varchar2  default NULL
                             ,max_corrupt  IN   binary_integer  default 0
                             ,tag          IN   varchar2  default NULL
                             ,nochecksum   IN   boolean   default FALSE
                             ,isbackup     IN   boolean   default FALSE
                             ,check_logical IN boolean);
  -- Description and return values can be found with original declaration
  -- above.  New parameters
  --
  --  check_logical
  --    if set to true indicates that besides physical block validations,
  --    logical validations will be performed on each block




  PROCEDURE restoreSetDataFile(check_logical IN boolean);
  -- Description and return values can be found with original declaration
  -- above.  New parameters
  -- New parameters
  --
  --  check_logical
  --    if set to true indicates that besides physical block validations,
  --    logical validations will be performed on each block





  PROCEDURE applySetDataFile(check_logical IN boolean);
  -- Description and return values can be found with original declaration
  -- above.  New parameters
  -- New parameters
  --
  --  check_logical
  --    if set to true indicates that besides physical block validations,
  --    logical validations will be performed on each block





  FUNCTION scanDataFile(dfnumber     IN  binary_integer,
                        max_corrupt  IN  binary_integer default 0,
                        update_fuzziness IN boolean default true,
                        check_logical IN boolean)
  return number;
  -- Description and return values can be found with original declaration
  -- above.  New parameters
  --
  --  check_logical
  --    if set to true indicates that besides physical block validations,
  --    logical validations will be performed on each block





  FUNCTION scanDataFileCopy(recid  IN number,
                            stamp  IN number,
                            max_corrupt IN binary_integer default 0,
                            isbackup    IN  boolean default FALSE,
                            update_fuzziness IN boolean default true,
                            check_logical IN boolean)
  return number;
  -- Description and return values can be found with original declaration
  -- above.  New parameters
  --
  --  check_logical
  --    if set to true indicates that besides physical block validations,
  --    logical validations will be performed on each block





  PROCEDURE restoreDataFileTo( dfnumber    IN binary_integer
                              ,toname      IN varchar2       default NULL
                              ,max_corrupt IN binary_integer);
  -- Description and return values can be found with original declaration
  -- above.  New parameters
  --
  --   max_corrupt
  --     maximum number of corruptions allowed on datafile




  PROCEDURE applyDataFileTo( dfnumber        IN binary_integer
                            ,toname          IN varchar2       default NULL
                            ,fuzziness_hint  IN number         default 0
                            ,max_corrupt     IN binary_integer);
  -- Description and return values can be found with original declaration
  -- above.  New parameters
  --
  --   max_corrupt
  --     maximum number of corruptions allowed on datafile

  --
  --  NEW FUNCTIONS
  --

  FUNCTION deviceQuery(question IN binary_integer) return varchar2;

  DEVICEQUERY_VENDOR   constant binary_integer := 0;
  DEVICEQUERY_PROXY    constant binary_integer := 1;
  DEVICEQUERY_MAXSIZE  constant binary_integer := 2;
  DEVICEQUERY_MAXPROXY constant binary_integer := 3;

  -- Request information about the device
  -- Input parameters:
  --   question
  --     One of the above constants, which identifies the type of information
  --     desired.
  -- Returns:
  --   A character string containing the requested information:
  --     DEVICEQUERY_VENDOR
  --       For non-DISK devices, the vendor identification string.
  --       For DISK devices, NULL.
  --     DEVICEQUERY_PROXY
  --       "0": proxy copy is not supported.
  --       "1": proxy copy is supported.
  --       "2": proxy copy is supported, but can't be used because
  --            COMPATIBLE must be  >= 8.1.0.
  --     DEVICEQUERY_MAXSIZE
  --       Maximum backup piece size, in kilobytes.
  --       Returns 0 if there is no size limit.
  --     DEVICEQUERY_MAXPROXY
  --       Maximum number of files which should be proxy copied
  --       in a single session.
  --
  -- Exceptions:
  --   None
  --




  --   To allow for duplexed backup sets 2 new functions are used
  --   These functions are only used if actually having copies
  --   backupPieceCrtDupSet sets the name of the copy specified by copy_n
  --   into the device context for later usage
  --   backupPieceCrtDupGet gets the output information (media, handle and
  --   comment) for the copy specified by copy_n and places it in the
  --   output variables.  This information is retrieved from the device
  --   context and was created when the piece/copy was created by
  --   backupPieceCreate

  PROCEDURE backupPieceCrtDupSet( copy_n   IN  binary_integer
                                 ,fname    IN  varchar2);
  -- Input parameters:
  --   copy_n
  --     specifies the copy number that corresponds to the filename
  --   fname
  --     Filename of the copy of the backup piece to be created.
  --     This will be translated into a file handle after the piece is created.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified backup piece name is longer than the port-specific
  --     maximum file name length.

  PROCEDURE backupPieceCrtDupGet( copy_n   IN  binary_integer
                                 ,handle   OUT varchar2
                                 ,comment  OUT varchar2
                                 ,media    OUT varchar2);
  -- Input parameters:
  --   copy_n
  --     specifies the copy number for which we want the information
  --   handle
  --     The handle for the backup piece that was created. This is a permanent
  --     name that can be used to read this sequential file for restore. It
  --     can only be used with the same device type that was allocated at
  --     this call.
  --   comment
  --     The comment for the backup piece. This is any string that the OSD
  --     decided was useful. It will be the null string for operating system
  --     files.
  --   media
  --     The media handle returned by the operating system. This is the name
  --     of media where the file was created. It is not needed for retrieving
  --     the backup piece. For some devices this information will not be
  --     provided.


  -- See description of deleteBackupPiece for documentation for
  -- changeBackupPiece.  We have to put new functions at the end.
  PROCEDURE changeBackupPiece( recid      IN  number
                              ,stamp      IN  number
                              ,handle     IN  varchar2
                              ,set_stamp  IN  number
                              ,set_count  IN  number
                              ,pieceno    IN  binary_integer
                              ,status     IN  varchar2 -- 'D','S','A','U','X'
                              ,params     IN  varchar2 default NULL );
  -- Additional input parameters:
  --   status:
  --     specifies the new status for this backup piece.  These status codes
  --     mean the same in all of the xxxChange procedures.
  --       D: delete the piece from the media, and mark it deleted in the
  --          control file
  --       S: Same as D, except that the backup piece exists on device type
  --          DISK, regardless of what device type is currently allocated to
  --          this session.
  --       A: mark the piece in the controlfile as available, do not touch the
  --          piece on the media.
  --       U: mark the piece in the controlfile as unavailable, do not touch
  --          the piece on the media.
  --       X: mark the piece in the controlfile as expired, do not touch the
  --          piece on the media.
  --
  --

  -- See description of proxyDelete for documentation for
  -- proxyChange. Here we will explain just keep attributes.
  PROCEDURE proxyChange(recid  IN number,
                        stamp  IN number,
                        handle IN varchar2,
                        status IN varchar2, -- 'D','A','U','X'
                        params IN varchar2 default NULL);

  -- NOTE: crosscheckBackupPiece is obsolete
  -- See description of validateBackupPiece for documentation for
  -- crosscheckBackupPiece.  We have to put new functions at the end.
  -- The main difference between crosscheck* and validate* is that
  -- crosscheck* modifies the status to reflect the discovered status
  -- of the file/piece.
  FUNCTION crosscheckBackupPiece(recid      IN  number
                                 ,stamp     IN  number
                                 ,handle    IN  varchar2
                                 ,set_stamp IN  number
                                 ,set_count IN  number
                                 ,pieceno   IN  binary_integer
                                 ,params    IN  varchar2 default NULL)
                                 return binary_integer;

  PROCEDURE reNormalizeAllFileNames;

  PROCEDURE cfileMakeAndUseSnapshot(isstby            IN  boolean);
  --
  -- See description above
  --
  -- New Input parameters:
  --   isstby
  --     If TRUE, indicates that the controlfile to make is a
  --     standby controlfile, normal backup otherwise
  --

  --
  --  ADD NEW FUNCTIONS/PROCEDURES OR SIGNATURE CHANGES JUST BEFORE THIS LINE
  --


  -- backupValidate is called to perform a 'validation backup'.  The backup
  -- proceeds as normal WRT the input files, but no backup piece is created.
  -- The backup conversation must already have been started, and this function
  -- is called in place of backupPieceCreate.
  PROCEDURE backupValidate;

-- genPieceName is called to produce the name of the piece.  It receives
-- a format and various other information to produce a name of the piece
-- as described by the format

  FUNCTION genPieceName(pno IN number
                        ,set_count IN number
                        ,set_stamp IN number
                        ,format    IN varchar2
                        ,copyno    IN number
                        ,devtype   IN varchar2
                        ,year      IN varchar2
                        ,month     IN varchar2
                        ,day       IN varchar2
                        ,dbid      IN varchar2
                        ,ndbname   IN varchar2
                        ,pdbname   IN varchar2
                        ,cfseq     IN number)
                        return varchar2;
  -- Input parameters:
  --   pno
  --     Piece number within backup set.
  --   set_stamp
  --   set_count
  --     Backup set identification.
  --   format
  --     Piece format
  --   copyno
  --     Copy number for the piece
  --   devtype
  --     Device type where the piece will be created
  --   year
  --     Gregorian year when the piece is created
  --   month
  --     Gregorian month when the piece is created
  --   day
  --     Gregorian day of the monthe when the piece is created
  --   dbid
  --     Database identifier
  --   ndbname
  --     Database name
  --   pdbname
  --     Padded database name
  --   cfseq
  --     Controlfile sequence


  PROCEDURE backupPieceCreate( fname      IN  varchar2
                              ,pieceno    OUT binary_integer
                              ,done       OUT boolean
                              ,handle     OUT varchar2
                              ,comment    OUT varchar2
                              ,media      OUT varchar2
                              ,concur     OUT boolean
                              ,params     IN  varchar2  default NULL
                              ,sequence   IN binary_integer
                              ,year       IN binary_integer
                              ,month_day  IN binary_integer);

  PROCEDURE backupPieceCreate( fname      IN  varchar2
                              ,pieceno    OUT binary_integer
                              ,done       OUT boolean
                              ,handle     OUT varchar2
                              ,comment    OUT varchar2
                              ,media      OUT varchar2
                              ,concur     OUT boolean
                              ,params     IN  varchar2  default NULL
                              ,media_pool IN binary_integer
                              ,sequence   IN binary_integer
                              ,year       IN binary_integer
                              ,month_day  IN binary_integer);

  PROCEDURE backupPieceCreate( fname      IN  varchar2
                              ,pieceno    OUT binary_integer
                              ,done       OUT boolean
                              ,handle     OUT varchar2
                              ,comment    OUT varchar2
                              ,media      OUT varchar2
                              ,concur     OUT boolean
                              ,params     IN  varchar2  default NULL
                              ,media_pool IN binary_integer  default 0
                              ,reuse      IN boolean
                              ,sequence   IN binary_integer
                              ,year       IN binary_integer
                              ,month_day  IN binary_integer);
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --   sequence
  --     indicates the sequence for the controlfile autobackup
  --
  --   year
  --     indicates the year for the controlfile autobackup
  --
  --   day
  --     indicates the month-day for the controlfile autobackup


  FUNCTION setConfig (name               IN  varchar2,
                      value              IN  varchar2 default NULL)
    RETURN binary_integer;

  -- setConfig is called to perform a saving of configuration parameters.
  -- This procedure sets the Rman configuration.
  --
  -- Input parameters:
  --   name
  --      Text which is going to be stored in the first column of
  --      the configuration record. It can not be NULL.
  --   value
  --      Text which is going to be stored in the second column of
  --      the configuration record. It can be NULL.
  --
  -- Return parameters:
  --   conf#
  --      Configuration number (in fact, row number) for configuration.
  --
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   RMAN-CONF-NAME-TOO-LONG (ora-19677)
  --     Name of the configuration value is too long to
  --     fit in the control file.
  --   RMAN-CONF-VALUE-TOO-LONG (ora-19678)
  --     Configuration value specified is too long to fint in control file.

  PROCEDURE resetConfig;

  -- resetConfig is called to perform a deleting of all rman configurations.
  --
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.

  PROCEDURE deleteConfig (conf#          IN binary_integer);

  -- deleteConfig is called to perform a deleting of RMAN Configuration.
  -- This procedure deletes the Rman configuration(s).
  --
  -- Input parameters:
  --   conf#
  --      Configuration number which we want to delete.
  --
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   INVALID-CONF-RECORD (ora-19679)
  --     Invalid configuration record.


  PROCEDURE setDatafileAux( dfnumber  IN  binary_integer
                           ,fname     IN  varchar2 DEFAULT NULL);

  -- setDbfileAux sets auxilary filename.
  --
  -- Input parameters:
  --   dfnumber
  --     Data file number of a file to alter. This refers to the file that
  --     is currently accessible via SQL commands.
  --   fname
  --     Name of the file to be set as auxfilename.
  --
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   NAME-TOO-LONG (ora-19704)
  --     The specified name is longer than the port-specific
  --     maximum file name length.
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile, online redo log or auxname for some other file.


  PROCEDURE setTablespaceExclude( tsid  IN  binary_integer
                                 ,flag  IN  binary_integer);

  -- setTablespaceExclude sets tablespace "excluded from backup" flag
  --
  -- Input parameters:
  --   tsid
  --     Id of the tablespace that is being altered
  --   flag
  --     if equal to zero then set "excluded from backup" to NO
  --     if equal to one then set "excluded from backup" to YES
  --
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --


  -- This procedure has same arguments as backupsetArchivedLog. Additional
  -- argument tag is added to support tags for archivelog backups
  PROCEDURE backupSetArchivedLog( set_stamp   OUT  number
                             ,set_count       OUT  number
                             ,nochecksum      IN   boolean        default FALSE
                             ,tag             IN   varchar2);

  PROCEDURE backupBackupPiece( bpname         IN   varchar2
                              ,fname          IN   varchar2
                              ,handle         OUT  varchar2
                              ,comment        OUT  varchar2
                              ,media          OUT  varchar2
                              ,concur         OUT  boolean
                              ,recid          OUT  number
                              ,stamp          OUT  number
                              ,tag            IN   varchar2       default NULL
                              ,params         IN   varchar2       default NULL
                              ,media_pool     IN   binary_integer default 0
                              ,reuse          IN   boolean        default FALSE
                              ,check_logical  IN   boolean
                              ,copyno         IN   binary_integer );
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  copyno
  --    Record the backup piece copied in x$kccbp as this copy number
  --

  --
  -- bmr procedures and functions
  --
  -- bmrStart starts a bmr conversation
  PROCEDURE bmrStart( save_all_blocks   IN boolean,
                      save_final_blocks IN boolean,
                      nofileupdate      IN boolean);

  -- bmrCancel ends/cancels previously started conversation
  PROCEDURE bmrCancel;

  -- bmrAddBlock add each block in the range (starting from blknumber)
  -- to the bmr context
  PROCEDURE bmrAddBlock( dfnumber  IN binary_integer,
                         blknumber IN binary_integer,
                         range     IN binary_integer DEFAULT 1 );

  -- bmrIntialScan scans for newed blocks and eliminates the one in block list
  PROCEDURE bmrInitialScan;

  -- bmrGetFile returns file number for which blocks are to be restored
  FUNCTION bmrGetFile( firstcall IN boolean )
                       return number;

  -- dba2rfno translates DBA number to block# and relative_file#
  PROCEDURE dba2rfno( dbano   IN  number,
                      rfno    OUT number,
                      blockno OUT number );

  -- This procedure is called to copy blocks from datafilecopy.
  PROCEDURE bmrScanDataFileCopy(recid  IN number,
                                stamp  IN number);
  -- This procedure is called to recover after bmr is setup
  PROCEDURE bmrDoMediaRecovery(alname IN varchar2);

  PROCEDURE changeDataFileCopy( recid              IN  number
                               ,stamp              IN  number
                               ,fname              IN  varchar2
                               ,dfnumber           IN  binary_integer
                               ,resetlogs_change   IN  number
                               ,creation_change    IN  number
                               ,checkpoint_change  IN  number
                               ,blksize            IN  number
                               ,new_status         IN  varchar2 );

  PROCEDURE changeArchivedLog(recid             IN  number
                             ,stamp             IN  number
                             ,fname             IN  varchar2
                             ,thread            IN  number
                             ,sequence          IN  number
                             ,resetlogs_change  IN  number
                             ,first_change      IN  number
                             ,blksize           IN  number
                             ,new_status        IN  varchar2 );

  PROCEDURE backupSetDataFile( set_stamp     OUT  number
                              ,set_count     OUT  number
                              ,nochecksum    IN   boolean         default FALSE
                              ,tag           IN   varchar2        default NULL
                              ,incremental   IN   boolean         default FALSE
                              ,backup_level  IN   binary_integer  default 0
                              ,check_logical IN   boolean         default FALSE
                              ,keep_options  IN   binary_integer
                              ,keep_until    IN   number);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  keep_options
  --    if set to non zero than this is one of the following keep backups:
  --        0x0100 - RECOVERABLE
  --        0x0200 - UNRECOVERABLE
  --        0x0400 - CONSISTENT
  --  keep_until
  --    this option is valid only if keep_option is non zero
  --        0 - forever
  --       >0 - time when this backup will expire


  PROCEDURE copyDataFile( dfnumber      IN   binary_integer
                         ,fname         IN   varchar2
                         ,full_name     OUT  varchar2
                         ,recid         OUT  number
                         ,stamp         OUT  number
                         ,max_corrupt   IN   binary_integer default 0
                         ,tag           IN   varchar2       default NULL
                         ,nochecksum    IN   boolean        default FALSE
                         ,isbackup      IN   boolean        default FALSE
                         ,check_logical IN   boolean        default FALSE
                         ,keep_options  IN   binary_integer
                         ,keep_until    IN   number);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  keep_options
  --    if set to non zero than this is one of the following keep backups:
  --        0x0100 - RECOVERABLE
  --        0x0200 - UNRECOVERABLE
  --        0x0400 - CONSISTENT
  --  keep_until
  --    this option is valid only if keep_option is non zero
  --        0 - forever
  --       >0 - time when this backup will expire



  PROCEDURE copyDataFileCopy( copy_recid    IN   number
                             ,copy_stamp    IN   number
                             ,full_name     OUT  varchar2
                             ,recid         OUT  number
                             ,stamp         OUT  number
                             ,fname         IN   varchar2       default NULL
                             ,max_corrupt   IN   binary_integer default 0
                             ,tag           IN   varchar2       default NULL
                             ,nochecksum    IN   boolean        default FALSE
                             ,isbackup      IN   boolean        default FALSE
                             ,check_logical IN   boolean        default FALSE
                             ,keep_options  IN   binary_integer
                             ,keep_until    IN   number);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  keep_options
  --    if set to non zero than this is one of the following keep backups:
  --        0x0100 - RECOVERABLE
  --        0x0200 - UNRECOVERABLE
  --        0x0400 - CONSISTENT
  --  keep_until
  --    this option is valid only if keep_option is non zero
  --        0 - forever
  --       >0 - time when this backup will expire



  PROCEDURE  proxyBeginBackup( tag           IN   varchar2        default NULL
                              ,incremental   IN   boolean         default FALSE
                              ,media_pool    IN   binary_integer  default 0
                              ,set_stamp     OUT  number
                              ,set_count     OUT  number
                              ,keep_options  IN   binary_integer
                              ,keep_until    IN   number );
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  keep_options
  --    if set to non zero than this is one of the following keep backups:
  --        0x0100 - RECOVERABLE
  --        0x0200 - UNRECOVERABLE
  --        0x0400 - CONSISTENT
  --  keep_until
  --    this option is valid only if keep_option is non zero
  --        0 - forever
  --       >0 - time when this backup will expire



  PROCEDURE proxyChange( recid         IN number
                        ,stamp         IN number
                        ,handle        IN varchar2
                        ,status        IN varchar2 -- 'D','A','U','X','K'
                        ,params        IN varchar2 default NULL
                        ,keep_options  IN binary_integer
                        ,keep_until    IN number);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  -- keep_options
  --        0x0000 - No keep
  --        0x0100 - RECOVERABLE
  --        0x0200 - UNRECOVERABLE
  --        0x0400 - CONSISTENT
  -- keep_until
  --        0 - forever
  --       >0 - time when this backup will expire
  --

  PROCEDURE changeBackupSet( recid              IN  number
                            ,stamp              IN  number
                            ,set_count          IN  number
                            ,keep_options       IN  binary_integer
                            ,keep_until         IN  number );
  --
  -- Input parameters:
  --   recid
  --   stamp
  --     These are the key for the record in the controlfile where the
  --     information about the backup awr was recorded. This is the record
  --   count
  --  keep_options
  --        0      - No keep
  --        0x0100 - KRMIKEEP_RCVBL
  --        0x0200 - KRMIKEEP_UNRECOV
  ---       0x0400 - KRMIKEEP_CONSIST
  --  keep_until
  --        0 - forever
  --       >0 - time when this backup will expire
  --
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   RECOVERY-CATALOG-ERROR (ora-19633)
  --     The validation information passed to this function is out of sync
  --     with the information in the controlfile.


  PROCEDURE changeDataFileCopy( recid              IN  number
                               ,stamp              IN  number
                               ,fname              IN  varchar2
                               ,dfnumber           IN  binary_integer
                               ,resetlogs_change   IN  number
                               ,creation_change    IN  number
                               ,checkpoint_change  IN  number
                               ,blksize            IN  number
                               ,new_status         IN  varchar2
                               ,keep_options       IN  binary_integer
                               ,keep_until         IN  number );
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  -- keep_options
  --        0x0000 - No keep
  --        0x0100 - RECOVERABLE
  --        0x0200 - UNRECOVERABLE
  --        0x0400 - CONSISTENT
  -- keep_until
  --        0 - forever
  --       >0 - time when this backup will expire
  --

 PROCEDURE incrArchivedLogBackupCount(
                                fname            IN  varchar2
                               ,thread           OUT  number
                               ,sequence         OUT  number
                               ,first_change     OUT  number
                               ,all_logs         IN  boolean default TRUE );
  -- This procedure is called to increment BACKUP_COUNT column
  -- in V$ARCHIVED_LOG.
  --
  -- Input parameters:
  --   fname
  --     The name of archived log.
  --   all_logs
  --      If this value is TRUE, backup_count of all records corresponding
  --         to logseq, thread, and resetlogs_change of input archived log
  --         will be incremented.
  --      If this value is FALSE, backup_count of one record that matches
  --         input arhived log fname will be incremented.
  -- Output parameters:
  --   thread
  --     Log thread number.
  --   sequence
  --     Log sequence number.
  --   first_change
  --     Low SCN.
  -- Exceptions:
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   FNAME-NOT-SPECIFIED (ora-19634)
  --     The fname must be specified and may not be null.
  --   ARCHIVELOG-NOT-FOUND (ora-19579)
  --     Archivedlog corresponding to given fname not found in controlfile.
  --   DIFFERENT_RESETLOGS (ora-19658)
  --     The file is not valid archived log for this database.
  --   FILE-NOT-FOUND (ora-19625)
  --     Error identifying archived log.
  --   ARCHIVELOG-VALIDATE-ERROR (ora-19582)
  --     Error reading archvied log.

  PROCEDURE backupArchivedLog( arch_recid  IN  number
                          ,arch_stamp  IN  number
                          ,duplicate   OUT boolean);

  PROCEDURE getOMFFileName(tsname  IN  varchar2
                          ,omfname OUT varchar2);

  -- This procedure returns an OMF file name for a datafile in the given
  -- tablespace.  The name is suitable for passing to create.  The name
  -- will have a "%u" in it, which will get replaced when the file is created.
  --
  -- Input parameters:
  --   tsname
  --     The name of the file's tablespace.
  -- Output parameters:
  --   omfname
  --     An OMF file name template for a datafile in the given
  --     tablespace.
  -- Exceptions:

  PROCEDURE inspectArchivedLogSeq( log_dest   IN   varchar2
                                  ,format     IN   varchar2 DEFAULT NULL
                                  ,thread     IN   binary_integer
                                  ,sequence   IN   number
                                  ,full_name  OUT  varchar2 );

  -- This procedure is similar to inspectArchivedLogSeq in functionality
  -- except filename to be inspected (fname) is generated from
  -- LOG_ARCHIVE_DEST(log_dest), thread and sequence.
  --
  -- Input parameters:
  --   log_dest
  --     One of LOG_ARCHIVE_DEST format. This format together with thread
  --     and sequence generates name of logfile to be inspected.
  --   format
  --     format to be combined with log_dest. If format is NULL, then current
  --     instance format is used.
  --   thread
  --     Thread of archived log.
  --   sequence
  --     sequence of archived log.
  --
  -- Output parameters:
  --   full_name
  --     This is the fully expanded name of the file that was inspected. It
  --     will also appear in V$ARCHIVED_LOG.
  --

  PROCEDURE backupPieceCreate( fname      IN  varchar2
                              ,pieceno    OUT binary_integer
                              ,done       OUT boolean
                              ,handle     OUT varchar2
                              ,comment    OUT varchar2
                              ,media      OUT varchar2
                              ,concur     OUT boolean
                              ,params     IN  varchar2  default NULL
                              ,media_pool IN binary_integer  default 0
                              ,reuse      IN boolean default FALSE
                              ,sequence   IN binary_integer
                              ,year       IN binary_integer
                              ,month_day  IN binary_integer
                              ,archlog_failover OUT boolean);
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --   archlog_failover
  --     indicates if server did archivelog failover, user needs to look
  --     at alert log for further infomation on corrupted blocks and failover
  --     details.

  PROCEDURE backupValidate(archlog_failover OUT boolean);
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --   archlog_failover
  --     indicates if server did archivelog failover, user needs to look
  --     at alert log for further infomation on corrupted blocks and failover
  --     details.

  FUNCTION validateDataFileCopy(recid              IN     number
                                ,stamp             IN     number
                                ,fname             IN     varchar2
                                ,dfnumber          IN     binary_integer
                                ,resetlogs_change  IN     number
                                ,creation_change   IN     number
                                ,checkpoint_change IN OUT number
                                ,checkpoint_time   IN OUT binary_integer
                                ,blksize           IN     number
                                ,signal            IN     binary_integer)
                                return binary_integer;

  -- Description and return values can be found with original declaration
  -- above. New parameter:
  --
  --  checkpoint_time
  --     Input and output parameter with time when checkpoint was done.
  --  signal
  --     Ignore catalog delete ignorable error (see krbcdie) if zero,
  --     otherwise signal exceptions.
  --
  --  NOTE: The arguments checkpoint_time and checkpoint_change are both
  --        input and output.
  --

  FUNCTION convertFileName(fname IN varchar2,
                           ftype IN binary_integer) return varchar2;
  -- Converts a filename with the appropiate conversion pattern
  -- If there's no conversion, the function returns NULL
  --
  --   Input parameters
  --     fname - Filename to convert
  --     ftype - Type of filename, 1 for Datafiles, 2 for Logfiles
  --
  --   Return value
  --     NULL if no conversion
  --     Otherwise converted name

  PROCEDURE copyControlFile( src_name     IN   varchar2
                            ,dest_name    IN   varchar2
                            ,recid        OUT  number
                            ,stamp        OUT  number
                            ,full_name    OUT  varchar2
                            ,keep_options IN   binary_integer
                            ,keep_until   IN   number);

  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  keep_options
  --    if set to non zero, then this is one of the following keep backups:
  --        0x0100 - RECOVERABLE
  --        0x0200 - UNRECOVERABLE
  --        0x0400 - CONSISTENT
  --  keep_until
  --    this option is valid only if keep_option is non zero
  --        0 - forever
  --       >0 - time when this backup will expire

  PROCEDURE backupSpfile;

  -- Include the current SPFILE in the backup set.
  --
  -- Input parameters:
  ---  NONE
  -- Exceptions:
  --   CONVERSATION-NOT-ACTIVE (ora-19580)
  --     A backup conversation was not started before specifying files.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   WRONG-CONVERSATION-TYPE (ora-19592)
  --     The backup set is not for datafiles, controlfiles and SPFILE.
  --   NAMING-PHASE-OVER (ora-19604)
  --     backuppiececreate has already been called.  No files can be named
  --     after piececreate is called.
  --   DUPLICATE-SPFILE (ora-19596)
  --     The SPFILE has already been specified for backup.
  --   NO-SPFILE (ora-19598)
  --     The database was not started with SPFILE, so we cannot back up it.
  --   RETRYABLE-ERROR (ora-19624)
  --     This is a pseudo-error that is placed on top of the stack when an
  --     error is signalled but it may be possible to continue the
  --     conversation.

  PROCEDURE restoreSpfileTo( pfname IN varchar2 default NULL
                            ,sfname IN varchar2 default NULL);

  -- This copies the SPFILE from the backup set to an operating system
  -- file.
  --
  -- Input parameters:
  --   pfname
  --     Name of the pfile to create or overwrite with the SPFILE data from the
  --     backup set. If NULL, then then we will not create the pfile.
  --   sfname
  --     Name of the SPFILE file to create or overwrite with the SPFILE from
  --     the backup set. If NULL, then the file will be restored to the same
  --     location from where was backed up.
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   CONVERSATION-NOT-ACTIVE (ora-19580)
  --     A restore conversation was not started before specifying files.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   WRONG-CONVERSATION-TYPE (ora-19592)
  --     This restore conversation is not for datafiles, controlfiles,
  --     and SPFILE.
  --   CONVERSATION-IS-VALIDATE-ONLY (ora-19618)
  --     No files can be named after restoreValidate has been called.
  --   NAMING-PHASE-OVER (ora-19604)
  --     The first backup piece has been restored. No more files can be
  --     named.
  --   SPFILE-IS-ACTIVE (ora-32011)
  --     The destination file is the same as the SPFILE specified
  --     currently used.

  PROCEDURE deleteBackupPiece( recid      IN  number
                              ,stamp      IN  number
                              ,handle     IN  varchar2
                              ,set_stamp  IN  number
                              ,set_count  IN  number
                              ,pieceno    IN  binary_integer
                              ,params     IN  varchar2 default NULL
                              ,force      IN  binary_integer);
  -- Additional input parameters:
  --   force
  --     Flag to allow errors to be ignored

  PROCEDURE changeBackupPiece( recid      IN  number
                              ,stamp      IN  number
                              ,handle     IN  varchar2
                              ,set_stamp  IN  number
                              ,set_count  IN  number
                              ,pieceno    IN  binary_integer
                              ,status     IN  varchar2 -- 'D','S','A','U','X'
                              ,params     IN  varchar2 default NULL
                              ,force      IN  binary_integer );
  -- Additional input parameters:
  --   force
  --     Flag to allow errors to be ignored

  PROCEDURE changeDataFileCopy( recid              IN  number
                               ,stamp              IN  number
                               ,fname              IN  varchar2
                               ,dfnumber           IN  binary_integer
                               ,resetlogs_change   IN  number
                               ,creation_change    IN  number
                               ,checkpoint_change  IN  number
                               ,blksize            IN  number
                               ,new_status         IN  varchar2
                               ,keep_options       IN  binary_integer
                               ,keep_until         IN  number
                               ,force              IN  binary_integer);
  -- Description and return values can be found with original and
  -- modified declaration above. New parameters
  --
  -- force
  --     Flag to allow errors to be ignored
  --

  PROCEDURE deleteDataFileCopy( recid              IN  number
                               ,stamp              IN  number
                               ,fname              IN  varchar2
                               ,dfnumber           IN  binary_integer
                               ,resetlogs_change   IN  number
                               ,creation_change    IN  number
                               ,checkpoint_change  IN  number
                               ,blksize            IN  number
                               ,no_delete          IN  binary_integer
                               ,force              IN  binary_integer);
  -- Description and return values can be found with original and
  -- modified declaration above. New parameters
  --
  -- force
  --     Flag to allow errors to be ignored
  --

  PROCEDURE changeArchivedLog(recid             IN  number
                             ,stamp             IN  number
                             ,fname             IN  varchar2
                             ,thread            IN  number
                             ,sequence          IN  number
                             ,resetlogs_change  IN  number
                             ,first_change      IN  number
                             ,blksize           IN  number
                             ,new_status        IN  varchar2
                             ,force             IN  binary_integer );
  -- Description and return values can be found with original and
  -- modified declaration above. New parameters
  --
  -- force
  --     Flag to allow errors to be ignored
  --

  PROCEDURE deleteArchivedLog(recid             IN  number
                             ,stamp             IN  number
                             ,fname             IN  varchar2
                             ,thread            IN  number
                             ,sequence          IN  number
                             ,resetlogs_change  IN  number
                             ,first_change      IN  number
                             ,blksize           IN  number
                             ,force             IN  binary_integer );
  -- Description and return values can be found with original and
  -- modified declaration above. New parameters
  --
  -- force
  --     Flag to allow errors to be ignored
  --

  PROCEDURE proxyChange( recid         IN number
                        ,stamp         IN number
                        ,handle        IN varchar2
                        ,status        IN varchar2 -- 'D','A','U','X','K'
                        ,params        IN varchar2 default NULL
                        ,keep_options  IN binary_integer
                        ,keep_until    IN number
                        ,force         IN binary_integer);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  -- force
  --     Flag to allow errors to be ignored
  --

  PROCEDURE proxyDelete(recid  IN number,
                        stamp  IN number,
                        handle IN varchar2,
                        params IN varchar2 default NULL,
                        force  IN binary_integer);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  -- force
  --     Flag to allow errors to be ignored
  --

  FUNCTION proxyValonly(recid  IN number,
                        stamp  IN number,
                        handle IN varchar2,
                        params IN varchar2 default NULL)
    return binary_integer;

  -- Same as proxyValidate, except that it does not change the status in
  -- the controlfile, it just validates.

  FUNCTION validateBackupPiece(recid       IN  number
                               ,stamp      IN  number
                               ,handle     IN  varchar2
                               ,set_stamp  IN  number
                               ,set_count  IN  number
                               ,pieceno    IN  binary_integer
                               ,params     IN  varchar2 default NULL
                               ,hdl_isdisk IN  binary_integer)
                               return binary_integer;
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --   hdl_isdisk
  --     TRUE if the backuppiece is from device disk. Used to dynamically
  --     allocate a disk context in SBT channel
  --

  PROCEDURE DoAutoBackup(ncopies OUT binary_integer
                         ,cfaudate   IN DATE default   NULL
                         ,seq        IN binary_integer default NULL
                         ,format     IN varchar2       default NULL);
  --
  -- Generate an Auto backup if autobackup is enabled. If no channel is
  -- allocated, a copy of autobackup will be written in controlfile
  -- autoformat to disk. Autobackup will contain spfile if instance is started
  -- using an server parameter file.
  --
  -- If connection has already a channel allocated, all attributes of
  -- channels like maxopenfiles, rate, etc., except dupcnt, maxpiecesize apply.
  --
  -- It will always generate one copy of autobackup to disk. If this procedure
  -- is executed with tape channel allocated, it generates as many copies as
  -- dupcnt. Maxpiecesize is always ignored and assumed to be not set, so
  -- that only one backuppiece contains entire backup set.

  PROCEDURE AutobackupFlag(flag IN boolean);
  -- Above procedure turns OFF/ON Server tracking flag for generating
  -- autobackups on structural changes. By default this flag is TRUE;
  -- which means server will perform autobackups on structural changes
  -- if CONTROLFILE AUTOBACKUP configuration was turned ON.
  --
  -- This flag will be set to FALSE by RMAN whenever we don't want to generate
  -- autobackups on database structural change using ALTER DATABASE or ALTER
  -- TABLESPACE commands like during TSPITR.

  FUNCTION validateDataFileCopy(recid              IN  number
                                ,stamp             IN  number
                                ,fname             IN  varchar2
                                ,dfnumber          IN  binary_integer
                                ,resetlogs_change  IN  number
                                ,creation_change   IN  number
                                ,checkpoint_change IN  number
                                ,blksize           IN  number
                                ,signal            IN  binary_integer)
                                return binary_integer;
  -- Description and return values can be found with original declaration
  -- above. New parameter:
  --
  --   signal
  --     Ignore catalog delete ignorable error (see krbcdie) if zero,
  --     otherwise signal exceptions.
  --


  FUNCTION validateArchivedLog(recid             IN  number
                               ,stamp            IN  number
                               ,fname            IN  varchar2
                               ,thread           IN  number
                               ,sequence         IN  number
                               ,resetlogs_change IN  number
                               ,first_change     IN  number
                               ,blksize          IN  number
                               ,signal           IN  binary_integer)
                               return binary_integer;
  -- Description and return values can be found with original declaration
  -- above. New parameter:
  --
  --   signal
  --     Ignore catalog delete ignorable error (see krbcdie) if zero,
  --     otherwise signal exceptions.
  --

  FUNCTION cfileCalcSizeList(
                  num_ckptprog_recs          IN  binary_integer  default 0
                 ,num_thread_recs            IN  binary_integer  default 0
                 ,num_logfile_recs           IN  binary_integer  default 0
                 ,num_datafile_recs          IN  binary_integer  default 0
                 ,num_filename_recs          IN  binary_integer  default 0
                 ,num_tablespace_recs        IN  binary_integer  default 0
                 ,num_tempfile_recs          IN  binary_integer  default 0
                 ,num_rmanconfiguration_recs IN  binary_integer  default 0
                 ,num_loghistory_recs        IN  binary_integer  default 0
                 ,num_offlinerange_recs      IN  binary_integer  default 0
                 ,num_archivedlog_recs       IN  binary_integer  default 0
                 ,num_backupset_recs         IN  binary_integer  default 0
                 ,num_backuppiece_recs       IN  binary_integer  default 0
                 ,num_backedupdfile_recs     IN  binary_integer  default 0
                 ,num_backeduplog_recs       IN  binary_integer  default 0
                 ,num_dfilecopy_recs         IN  binary_integer  default 0
                 ,num_bkdfcorruption_recs    IN  binary_integer  default 0
                 ,num_dfcopycorruption_recs  IN  binary_integer  default 0
                 ,num_deletedobject_recs     IN  binary_integer  default 0
                 ,num_proxy_recs             IN  binary_integer  default 0
                 ,num_reserved4_recs         IN  binary_integer  default 0
                 ,num_db2_recs               IN  binary_integer
                 ,num_incarnation_recs       IN  binary_integer)
    return binary_integer;

  -- Description and return values can be found with original declaration
  -- above. New parameter:
  --
  --  num_db2_recs
  --     Number of KCCDEDB2 records. This is ignored internally. It does
  --     serve as a easy processing mech in krbicsl
  --
  --  num_incarnation_recs
  --     Number of KCCDEDIR records.
  --
  --  NOTE: The arguments checkpoint_time and checkpoint_change are both
  --        input and output.
  --

  PROCEDURE resDataFileCopy(  cname         IN   varchar2
                             ,fname         IN   varchar2
                             ,full_name     OUT  varchar2
                             ,max_corrupt   IN   binary_integer  default 0
                             ,check_logical IN   boolean
                             ,blksize       IN   binary_integer
                             ,blocks        IN   binary_integer
                             ,fno           IN   binary_integer
                             ,scnstr        IN   varchar2
                             ,rfno          IN   binary_integer);

  --
  -- copyDataFileCopy is used to restore a copy for duplicate.

  -- This is a special version of copyDataFileCopy, but it is used when
  -- performing a duplicate, in this case, there is no controlfile at the
  -- duplicate.  Thus the special handle used for copies cannot be performed
  -- Normally copydatafilecopy receives the recid-stamp of the copy and looks
  -- for it in the target controlfile.  In this case we have to operate with
  -- the input name and the output name only.
  -- Input parameters:
  --   cname
  --     File name of the copy to use.
  --   fname
  --     File name to copy the image to. This name may not be useable by
  --     another process, so it will be expanded.
  --   max_corrupt
  --     Up to this many corrupt data blocks from this file can appear in the
  --     backup. The copy will fail if more blocks are found corrupt.
  --   check_logical
  --    if set to true indicates that besides physical block validations,
  --    logical validations will be performed on each block
  --   blksize
  --     Block size of the datafile copy.
  --   blocks
  --     Number of   blocks in the datafile copy.
  --   fno
  --     File number that we are restoring.
  --   scnstr
  --     Checkpoint SCN of the datafilecopy for priting purposes.
  --   rfno
  --     Relative file number, required to calculate rdba
  -- Output parameters:
  --   full_name
  --     This is the fully expanded name of the file that was created.

  PROCEDURE restoreControlfileTo( cfname    IN  varchar2
                                 ,isstby    IN  boolean);
  -- Description and return values can be found with original declaration
  -- above. New parameters:
  --
  --   isstby
  --     If set to TRUE, then restore should extract standby controlfile.
  --     In case that standby controlfile is not found, then the restore will
  --     signal error scf_not_in_bs (ORA-19695).
  --

  FUNCTION cfileCalcSizeList(
                  num_ckptprog_recs          IN  binary_integer  default 0
                 ,num_thread_recs            IN  binary_integer  default 0
                 ,num_logfile_recs           IN  binary_integer  default 0
                 ,num_datafile_recs          IN  binary_integer  default 0
                 ,num_filename_recs          IN  binary_integer  default 0
                 ,num_tablespace_recs        IN  binary_integer  default 0
                 ,num_tempfile_recs          IN  binary_integer  default 0
                 ,num_rmanconfiguration_recs IN  binary_integer  default 0
                 ,num_loghistory_recs        IN  binary_integer  default 0
                 ,num_offlinerange_recs      IN  binary_integer  default 0
                 ,num_archivedlog_recs       IN  binary_integer  default 0
                 ,num_backupset_recs         IN  binary_integer  default 0
                 ,num_backuppiece_recs       IN  binary_integer  default 0
                 ,num_backedupdfile_recs     IN  binary_integer  default 0
                 ,num_backeduplog_recs       IN  binary_integer  default 0
                 ,num_dfilecopy_recs         IN  binary_integer  default 0
                 ,num_bkdfcorruption_recs    IN  binary_integer  default 0
                 ,num_dfcopycorruption_recs  IN  binary_integer  default 0
                 ,num_deletedobject_recs     IN  binary_integer  default 0
                 ,num_proxy_recs             IN  binary_integer  default 0
                 ,num_reserved4_recs         IN  binary_integer  default 0
                 ,num_db2_recs               IN  binary_integer
                 ,num_incarnation_recs       IN  binary_integer
                 ,num_flashback_recs         IN  binary_integer
                 ,num_rainfo_recs            IN  binary_integer
                 ,num_instrsvt_recs          IN  binary_integer
                 ,num_agedfiles_recs         IN  binary_integer
                 ,num_rmanstatus_recs        IN  binary_integer
                 ,num_threadinst_recs        IN  binary_integer
                 ,num_mtr_recs               IN  binary_integer
                 ,num_dfh_recs               IN  binary_integer)
    return binary_integer;

  -- Description and return values can be found with original declaration
  -- above. New parameter:
  --
  --  num_flashback_recs
  --     Number of KCCDEFLS records.
  --  num_rainfo_recs
  --     Number of KCCDERDI records.
  --  num_instrsvt_recs
  --     Number of KCCDEIRT records.
  --  num_agedfiles_recs
  --     Number of KCCDEAGF records.
  --  num_rmanstatus_recs
  --     Number of KCCDERSR records.
  --  num_threadinst_recs
  --     Number of KCCDETIR records.
  --  num_mtr_recs
  --     Number of KCCDEMTR records.
  --  num_dfh_recs
  --     Number of KCCDEFHR records.
  --
  --  NOTE: The arguments checkpoint_time and checkpoint_change are both
  --        input and output.

  PROCEDURE inspectBackupPiece( handle      IN   varchar2
                               ,full_handle OUT  varchar2
                               ,recid       OUT  number
                               ,stamp       OUT  number );
  -- This procedure reads the header from a backuppiece and creates the
  -- corresponding backupset, backuppiece, backup datafile or backup redo
  -- log records as if the file had just been created with RMAN backup
  -- command.
  -- The inspection is done on whatever device is currently allocated, or
  -- on disk if no device is allocated.
  --
  -- Input parameters:
  --   handle
  --     The handle for the backup piece to inspect. This is a permanent
  --     name that can be used to read this sequential file for restore. It
  --     can only be used with the same device type that was allocated at
  --     this call.
  -- Output parameters:
  --   full_handle
  --     This is the fully expanded handle for the backup piece
  --     that was inspected.
  --   recid
  --   stamp
  --     These are the key of the record that is created in the controlfile
  --     when the piece is successfully inspected. It can be used to query
  --     information about the copy from V$BACKUP_PIECE
  -- Exceptions:
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   CANT_IDENTIFY_FILE (ora-19505)
  --     The file can't be identified.
  --   NOT_A_BACKUP_PIECE (ora-19608)
  --     backuppiece header validation failed.
  --   IO-ERROR
  --     An error occured attempting to read a file.

  PROCEDURE backupPieceCreate( fname      IN  varchar2
                              ,pieceno    OUT binary_integer
                              ,done       OUT boolean
                              ,handle     OUT varchar2
                              ,comment    OUT varchar2
                              ,media      OUT varchar2
                              ,concur     OUT boolean
                              ,params     IN  varchar2  default NULL
                              ,media_pool IN  binary_integer  default 0
                              ,reuse      IN  boolean default FALSE
                              ,sequence   IN  binary_integer
                              ,year       IN  binary_integer
                              ,month      IN  binary_integer
                              ,day        IN  binary_integer
                              ,archlog_failover
                                          OUT boolean
                              ,deffmt     IN  binary_integer
                              ,recid      OUT number
                              ,stamp      OUT number
                              ,tag        OUT varchar2);
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --  month  - indicates the month of controlfile autobackup
  --  day    - indicates the day of controlfile autobackup
  --  deffmt - indicates if default format is used or not. Serves as a hint
  --           to use OMF name.
  --  recid  - recid of the copy (if one was created)
  --  stamp  - stamp of the copy (if one was created)
  --  tag    - tag of the piece/copy which is created
  --

  PROCEDURE backupBackupPiece( bpname         IN   varchar2
                              ,fname          IN   varchar2
                              ,handle         OUT  varchar2
                              ,comment        OUT  varchar2
                              ,media          OUT  varchar2
                              ,concur         OUT  boolean
                              ,recid          OUT  number
                              ,stamp          OUT  number
                              ,tag            IN   varchar2       default NULL
                              ,params         IN   varchar2       default NULL
                              ,media_pool     IN   binary_integer default 0
                              ,reuse          IN   boolean        default FALSE
                              ,check_logical  IN   boolean
                              ,copyno         IN   binary_integer
                              ,deffmt         IN   binary_integer
                              ,copy_recid     IN   number
                              ,copy_stamp     IN   number
                              ,npieces        IN   binary_integer );
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  deffmt -  indicates if default format is used or not. Serves as a hint
  --            to use OMF name.
  --  copy_recid
  --  copy_stamp
  --     the controlfile identifiers of a backuppiece to be backed up.
  --  npieces - number of backuppieces in this backupset.
  --

  PROCEDURE refreshAgedFiles;

  PROCEDURE applyDataFileTo( dfnumber        IN  binary_integer
                            ,toname          IN  varchar2       default NULL
                            ,fuzziness_hint  IN  number         default 0
                            ,max_corrupt     IN  binary_integer
                            ,islevel0        IN  binary_integer
                            ,recid           IN  number
                            ,stamp           IN  number);
  -- Description and return values can be found with original declaration
  -- above.  New parameters
  --
  --   islevel0
  --     >0 if the specified toname is level 0 copy. Otherwise 0.
  --   recid, stamp
  --     Controlfile record id and stamp associated with this datafilecopy.
  --     Pass it as 0 for real-datafiles.

  PROCEDURE dba2rfno( dbano   IN  number,
                      rfno    OUT number,
                      blockno OUT number,
                      tsnum   IN  binary_integer );
  --
  -- Description can be found with original declaration. New parameter:
  --
  --  tsnum
  --     tablespace number to which DBA belongs
  --

  PROCEDURE flashbackStart(flashbackSCN  IN number,
                           flashbackTime IN date,
                           scnBased      IN binary_integer,
                           toBefore      IN binary_integer);
  --
  -- Starts a flashback conversation to flashback the database to
  -- given flashbackSCN/flashbackTime.
  --
  --  flashbackSCN
  --     scn to which to flashback.
  --  flashbackTime
  --     time to which to flashback.
  --  scnBased
  --     TRUE(>0) if the flashback target is an SCN.
  --     FALSE(=0) if flashback target is a timestamp
  --  toBefore
  --     TRUE(>0) if transaction at SCN/timestamp should be rolled back
  --                       (user said "flashback to before")
  --     FALSE(=0) if transaction at SCN/timestamp should not be rolled back
  --


  PROCEDURE flashbackAddFile( fileno IN binary_integer );
  -- flashbackAddFile adds the given file to the list that needs a flashback.

  PROCEDURE flashbackFiles(alname IN varchar2);
  -- flashbackFiles does the real work of flashbacking the list
  -- added using flashbackAddFile to the SCN specified by flashbackStart.

  PROCEDURE flashbackCancel;
  -- flashbackCancel destroys the flashback conversation

  PROCEDURE restoreSetPiece   ( handle   IN   varchar2
                               ,tag      IN   varchar2
                               ,fromdisk IN   boolean
                               ,recid    IN   number
                               ,stamp    IN   number );
  -- restoreSetPiece sets up the handle for restoreBackupPiece to use.
  -- When multiple copies of piece exists, call restoreSetPiece to
  -- for each copy before calling restoreBackupPiece. This will enable
  -- RESTORE FAILOVER feature inside kernel
  -- Input parameters:
  --   handle
  --     The handle of the backup piece to restore from.
  --   tag
  --     The tag associated with the backup piece.
  --   fromdisk
  --     TRUE if the backuppiece is from device disk. Used to dynamically
  --     allocate a disk context in SBT channel
  --   recid, stamp
  --     controlfile record id and stamp associated with this handle
  --

  PROCEDURE restoreBackupPiece( done      OUT  boolean
                               ,params    IN   varchar2  default NULL
                               ,outhandle OUT  varchar2
                               ,outtag    OUT  varchar2
                               ,failover  OUT  boolean );
  -- Description and return values can be found in the original declaration.
  --
  -- New parameter:
  --
  -- Output parameters:
  --   outhandle
  --     The handle of the backup piece used for restore. When multiple copies
  --     of backuppiece are set during restore, then this handle is the
  --     last one which was used to successfully complete the restore.
  --   outtag
  --     The tag associated with that handle.
  --   failover
  --     TRUE when failover to other backuppieces were done due to various
  --     reasons like piece-not-found, piece-in-accessible,
  --     validation-failed, data-block-corruption etc.
  --

  FUNCTION fetchFileRestored(firstcall     IN  boolean
                             ,proxy        IN  boolean
                             ,ftype        OUT binary_integer
                             ,fno          OUT binary_integer
                             ,thread       OUT binary_integer
                             ,sequence     OUT number
                             ,resetSCN     OUT number
                             ,resetStamp   OUT number)
                         return binary_integer;
  --
  -- fetchFileRestored is used to get the files which were restored
  -- successfully by the restore conversation.
  -- Returns 0 when there are no more files to be returned, otherwise
  -- a non-zero value. This function should be called multiple times
  -- to fetch all files there were restored.
  --
  -- Input parameters:
  --   firstcall
  --     TRUE if it is first fetch, otherwise FALSE.
  --   proxy
  --     TRUE if it is a proxy restore, otherwise FALSE
  -- Output parameters:
  --   ftype
  --     file type constant (see KSFD_* constants in ksfd.h)
  --   fno
  --     datafile number
  --   thread, sequence, resetSCN, resetStamp
  --     archivelog information
  --

  PROCEDURE restoreCancel(check_files IN boolean);
  -- Description and return values can be found in the original declaration.
  --
  -- New parameter:
  --
  -- Input parameters:
  --   check_files
  --     TRUE to check if all files were restored in the restore conversation.
  --     Otherwise, just destroy the conversation.
  --

  PROCEDURE restoreSetDataFile( check_logical IN boolean
                               ,cleanup       IN boolean);
  PROCEDURE applySetDataFile( check_logical IN boolean
                             ,cleanup       IN boolean);
  PROCEDURE restoreSetArchivedLog( destination    IN varchar2 default NULL
                                  ,cleanup        IN boolean);
  PROCEDURE proxyBeginRestore( destination IN varchar2 default NULL
                              ,cleanup     IN boolean);
  -- Description and return values can be found with original declaration
  -- above.
  -- New parameters
  --
  -- Input parameters:
  --
  --  cleanup
  --     TRUE to cleanup restore conversation, otherwise leave the conversation
  --     context for further queries.
  --

  FUNCTION genPieceName(pno        IN number
                        ,set_count IN number
                        ,set_stamp IN number
                        ,format    IN varchar2
                        ,copyno    IN number
                        ,devtype   IN varchar2
                        ,year      IN binary_integer
                        ,month     IN binary_integer
                        ,day       IN binary_integer
                        ,dbid      IN number
                        ,ndbname   IN varchar2
                        ,cfseq     IN number
                        ,fileno    IN number
                        ,tsname    IN varchar2
                        ,logseq    IN varchar2
                        ,logthr    IN number
                        ,imagcp    IN boolean)
                        return varchar2;
  -- Removed pdbname
  -- Added new parameters for creating names:
  --   fileno
  --     Absolute datafile number
  --   tsname
  --     Tablespace name to which this datafile belongs
  --   logseq
  --     Log sequence for archivelogs
  --   logthr
  --     Log thread for archivelogs
  --   imagcp
  --     Generate a name for an image copy.


  PROCEDURE backupSetDataFile( set_stamp     OUT  number
                              ,set_count     OUT  number
                              ,nochecksum    IN   boolean         default FALSE
                              ,tag           IN   varchar2        default NULL
                              ,incremental   IN   boolean         default FALSE
                              ,backup_level  IN   binary_integer  default 0
                              ,check_logical IN   boolean         default FALSE
                              ,keep_options  IN   binary_integer  default 0
                              ,keep_until    IN   number          default 0
                              ,imagcp        IN   boolean 
                              ,convertto     IN   boolean
                              ,convertfr     IN   boolean
                              ,pltfrmto      IN   binary_integer
                              ,pltfrmfr      IN   binary_integer
                              ,sameen        IN   boolean);

  -- Description and return values can be found with original declaration
  -- above. New parameters

  --  imagcp
  --    Do not generate backup pieces, generate image copies.
  --  convertto
  --    If true indicates that we are doing convert at source.
  --  convertfr
  --    If true indicates that we are doing convert at source.
  --  pltfrmto
  --    NULL if this is not a convert command, otherwise is the id of the
  --    platform we are converting to.
  --  pltfrmfr
  --    NULL if this is not a convert command, otherwise is the id of the
  --    platform we are converting from.
  --  sameen
  --    If TRUE indicates this is a same endianess conversion
  --

  FUNCTION getTsNameFromDataFileCopy(fname      IN varchar2
                                    ,fno        IN number)
                                             return varchar2;

  -- Obtains the tablespace name to which this datafilecopy belonged
  --
  --   Input parameters
  --     fname - Datafile copy name
  --     fno - Datafile number of the copy
  --
  --   Return value
  --     Error if datafilecopy does not exist
  --     Otherwise the tablespace name of this datafilecopy

  PROCEDURE backupSetArchivedLog( set_stamp   OUT  number
                             ,set_count       OUT  number
                             ,nochecksum      IN   boolean        default FALSE
                             ,tag             IN   varchar2
                             ,imagcp          IN   boolean);

  -- Description and return values can be found with original declaration
  -- above. New parameters

  --  imagcp
  --    Do not generate backup pieces, generate image copies.

  PROCEDURE backupControlFile( cfname  IN  varchar2  default NULL,
                               isstby  IN  boolean );

  -- Description and return values can be found with original declaration
  -- above.  New parameters:
  --   isstby
  --     If TRUE, indicates that the controlfile to make is a
  --     standby controlfile, normal backup otherwise


  FUNCTION convertFileName(fname   IN varchar2,
                           ftype   IN binary_integer,
                           osftype IN boolean) return varchar2;

  -- Description and return values can be found with original declaration
  -- above.  New parameters:
  --   osftype
  --     If TRUE, indicates that the ftype passed is of KSFD_* type. Otherwise
  --     old protocol is followed (see original declaration).
  --

  PROCEDURE restoreDataFileTo( dfnumber    IN binary_integer
                              ,toname      IN varchar2       default NULL
                              ,max_corrupt IN binary_integer
                              ,tsname      IN varchar2);
  -- Description and return values can be found with original declaration
  -- above.  New parameters
  --
  --   tsname
  --     The name of the tablespace
  --
  -- restoreDataFileTo creates the output file from a complete backup in the
  -- backup set.


  PROCEDURE searchFiles(pattern IN OUT varchar2
                       ,ns      IN OUT varchar2
                       ,ccf     IN     boolean    default FALSE
                       ,omf     IN     boolean    default FALSE
                       ,ftype   IN     varchar2   default NULL);
  --
  -- This procedure populates X$KRBMSFT with list files that match specified
  -- pattern.
  --
  -- Input parameters:
  --    pattern
  --       Pattern to search. In case of OMF, it represents OMF location. If
  --       parameter is null and omf is true, then pattern will be set to
  --       DB_RECOVERY_FILE_DEST.
  --    ns
  --       Lock name space. Valid only in case of OMF. If parameter is null,
  --       it will be to DB_NAME or LOCK_NAME_SPACE.
  --    ccf
  --       Flag which tells whether to populate krbmsftp [KRMB Search File
  --       Table] with files known to the controlfile.
  --    omf
  --       Flag which tells whether to do OMF or non-OMF search.
  --    ftype
  --       File type to search for. It can be one of the following:
  --             'A' - Archive logs
  --             'B' - Backups
  --             'U' - aUtobackups
  --       For non-OMF case, the filetype is used to manipulate the pattern
  --       like adding '/' for archivelog search.
  --
  -- Exceptions:
  --    ra_not_set (-19801)
  --       Raised if recovery area is not set.

  PROCEDURE processSearchFileTable(catalog  IN boolean,
                                   implicit IN binary_integer);
  --
  -- This procedure will read header for all files from search file table
  -- (X$KRBMSFT). If the catalog is TRUE is will also try to catalog them.
  --
  -- Input parameters:
  --    catalog
  --      Flag which tell whether the function should catalog files.
  --    implicit
  --      0 if user invoked to catalog files. Otherwise, RMAN does
  --      implicit cataloging.
  --
  -- Output parameters:
  --    None.
  --

  FUNCTION findAutSearchFileTable( mustspfile IN  boolean
                                  ,until      IN  number
                                  ,fname      OUT varchar2
                                  ,year       OUT binary_integer
                                  ,month      OUT binary_integer
                                  ,day        OUT binary_integer
                                  ,sequence   OUT binary_integer
                                  ,ats        OUT number)
    RETURN boolean;
  --
  -- This procedure returns auto backup piece from X$KRBMSFT which match the
  -- input criteria (mustspfile and until).
  --
  -- Input parameters:
  --    mustspfile
  --      Flag which tell whether the returning autobackup should contain
  --      SPFILE.
  --    until
  --      Until timestamp. The autobackup should not be newer than until.
  --
  -- Output parameters:
  --    year
  --      Year of the autobackup.
  --    month
  --      Month of the autobackup.
  --    day
  --      Day of the autobackup.
  --    sequence
  --      Sequence of the autobackup.
  --    ats
  --      Autobackup Time Stamp. This is the timestamp of the autobackup we
  --      have found.
  --

  PROCEDURE bctSwitch(filelist IN varchar2 default NULL);
  -- This procedure switches change tracking bitmaps for the specified list
  -- of files.
  --
  -- Input parameters:
  --   filelist
  --     A list of files in the following format:
  --       filelist : filespec |
  --                  filelist , filespec
  --
  --       filespec : filenum |
  --                  filenum - filenum
  --
  --     The first form of filespec (single file number) causes the specified
  --     file to be switched.  The second form of filespec (two file numbers,
  --     separated by a dash) causes all of the files in the specified range,
  --     inclusive, to be switched.
  --
  --     Specify NULL to switch all files in the database.

  PROCEDURE bctSet(parmno  IN binary_integer,
                   numval  IN number default null,
                   charval IN varchar2 default null);

  BCTSET_CLEANLIMIT constant binary_integer := 1;
  BCTSET_CKPFREQ    constant binary_integer := 2;
  BCTSET_MAXPEND    constant binary_integer := 3;
  BCTSET_MAXEXT     constant binary_integer := 4;
  BCTSET_OPTIONS    constant binary_integer := 5;
  BCTSET_CTWR_EMPTY_THRESHOLD constant binary_integer := 6;
  BCTSET_CTWR_REAP_THRESHOLD  constant binary_integer := 7;
  BCTSET_CTWR_CIC_SECONDS     constant binary_integer := 8;


  -- This procedure allows for runtime adjustment of various constants
  -- that affect the operation of the CTWR process.  This routine should
  -- be used only by Oracle support personnel.


  PROCEDURE resetDatabase(dbinc_key      IN   number);
  -- resetDatabase is used to change the recovery destination incarnation.
  -- refer to krbcrdb() function for restrictions and errors returned.

  PROCEDURE proxyRestoreArchivedlog(handle       IN varchar2,
                                    thread       IN binary_integer,
                                    sequence     IN number,
                                    resetlogs_id IN number,
                                    blksize      IN binary_integer,
                                    blocks       IN number);

  -- Specify one archived log to be restored during a proxy session.
  --
  -- Following parameter added :
  --   resetlogs_id -
  --     resetlogs timestamp used to construct unique names
  --     for archived logs accross incarnations during proxy restores.
  --   blksize - block size of archive log to be restored
  --   blocks  - number of blocks in archivelog log to be restored

  PROCEDURE inspectArchivedLog( fname      IN   varchar2
                           ,full_name  OUT  varchar2
                           ,recid      OUT  number
                           ,stamp      OUT  number
                           ,change_rdi IN boolean );

  -- Specify archived log to inspected.
  --
  -- Following parameter added :
  --   change_rdi
  --     boolean value to indicate where recovery destination incarnation
  --     can be changed when inspecting this log. This flag is set to FALSE
  --     normally when RMAN is inspecting online logs for backup controlfile.

  PROCEDURE inspectArchivedLogSeq( log_dest   IN   varchar2
                                  ,format     IN   varchar2 DEFAULT NULL
                                  ,thread     IN   binary_integer
                                  ,sequence   IN   number
                                  ,full_name  OUT  varchar2
                                  ,resetlogs_id IN number );

  -- Specify archived log to inspected.
  --
  -- Following parameter added :
  --   resetlogs_id
  --     Incarnation's resetlogs timestamp.

  PROCEDURE createRmanStatusRow( level         IN  binary_integer
                                ,parent_id     IN  number
                                ,parent_stamp  IN  number
                                ,status        IN  binary_integer
                                ,command_id    IN  varchar2
                                ,operation     IN  varchar2
                                ,row_id        OUT number
                                ,row_stamp     OUT number);
  --
  -- Creates an row for V$RMAN_STATUS view. The function will create one
  -- row in SGA (krbmrsrt [Rman Status Row Table] and create one controlfile
  -- record (kccrsr).
  --
  -- Input paramters:
  --   level
  --      The level of the row. For example, if level is 0, then the operation
  --      desribed by this row contains all opeations with level=1 with
  --      parent_id equal to id of this row. If level is > 0, then
  --      patern_id must be specfied.
  --   parent_id
  --      Valid only if level > 0. Specified the recid of the parent row.
  --   parent_stamp
  --      Valid only if level > 0. Specified the timestamp of the parent row.
  --   status
  --      The status of the row.
  --   command_id
  --      Command id set by the user.
  --   operation
  --      The name of the operation.
  --
  -- Output paramters:
  --   row_id (OUT)
  --      The recid of the newly create row.
  --   row_stamp (OU)
  --      The timestamp of the newly create row.
  --

  PROCEDURE updateRmanStatusRow( row_id     IN number
                                ,row_stamp  IN number
                                ,status     IN binary_integer);
  --
  -- Updates a row in the V$RMAN_STATUS view. The function will update the
  -- status of the row in the SGA.
  --
  -- Input paramters:
  --   row_id
  --      The id of the row which to update
  --   row_stamp
  --      The stamp of the row which to update
  --   status
  --      The status of the operation.
  --
  -- Return value:
  --   None.
  --

  PROCEDURE commitRmanStatusRow( row_id    IN number
                                ,row_stamp IN number
                                ,mbytes    IN number
                                ,status    IN binary_integer);
  -- Commits the row into controlfile. The SGA version of the row is saved in
  -- the controlfile and the contolfile record is marked as finished.
  --
  --  Input paramters:
  --   row_id
  --      The recid of the row to commit
  --   row_stamp
  --      The timestamp of the row to commit
  --   mbytes
  --      The amout of MB processed.
  --   status
  --      The status of the operation.
  --
  --

  PROCEDURE createRmanOutputRow( l0row_id    IN number
                                ,l0row_stamp IN number
                                ,row_id      IN number
                                ,row_stamp   IN number
                                ,txt         IN varchar2);
  -- Creates an row in a V$RMAN_OUTPUT view. In other words, the function will
  -- create one row in SGA (krbmrort [Rman Outpur Row Table].
  --
  -- Input paramters:
  --   l0row_id
  --      The recid of the level 0 row in V$RMAN_STATUS (x$krbmrst/x$kccrsr)
  --   l0row_stamp
  --      The time stamp of the level 0 row in V$RMAN_STATUS
  --       (x$krbmrst/x$kccrsr)
  --   row_id
  --      The recid of the row in V$RMAN_STATUS (x$krbmrst/x$kccrsr)
  --   row_stamp
  --      The time stamp of the row in V$RMAN_STATUS (x$krbmrst/x$kccrsr)
  --   txt
  --      The text of the row
  --
  -- Return value:
  --   Nothing
  --
  --

  PROCEDURE setRmanStatusRowId( rsid    IN number
                               ,rsts    IN number);
  -- By calling this function all opeartion by this foreground will be
  -- associated with a V$RMAN_STATUS row.
  --
  -- rsid
  --   Recid of the RMAN command which is responsible for this conversation.
  -- rsts
  --    Timestamp of the RMAN command which is responsible for this
  --    conversation.
  --

  PROCEDURE readFileHeader(fname    IN varchar2,
                           dbname   OUT varchar2,
                           dbid     OUT number,
                           tsname   OUT varchar2,
                           fno      OUT binary_integer,
                           nblocks  OUT number,
                           blksize  OUT binary_integer,
                           plid     OUT binary_integer,
                           sameen   IN  binary_integer);

  -- This function is used to obtain information from the file header of
  -- a datafile that is being cross-platform converted at the target.
  -- In this case the file does not belong to the database (yet) and its
  -- block format is not the same of the database that is doing the
  -- conversion.
  --
  --   fname
  --     Name of the file that needs to be read.
  --   dbname
  --     Name of the database from which this file came.
  --   dbid
  --     dbid of the database from which this file came.
  --   tsname
  --     Name of the tablespace that this file belongs to.
  --   fno
  --     Absolute file number that this file had in its original database
  --   nblocks
  --     number of blocks in the file
  --   blksize
  --     blocksize of the file
  --   plid
  --     platform id from the header
  --   sameen
  --     TRUE if this is a same endianess conversion
  --
  --
  PROCEDURE getDefaultTag(deftag OUT varchar2);

  -- Constructs the default tag for backups and image copies.
  -- The default tag is a in the ISO 8601 compliance contaning the date and
  -- the time.

  PROCEDURE switchToCopy( copy_recid  IN  number
                         ,copy_stamp  IN  number
                         ,catalog     IN  boolean );
  -- Causes the filename in the indicated datafile copy record to become
  -- the current named datafile.  The file number to rename is taken from
  -- the V$DATAFILE_COPY record.
  -- Following parameter added :
  --   catalog
  --    If true, then after the switch, the function will catalog the original
  --    file (one which was before the switch in V$DATAFILE) as datafile copy.
  --



  PROCEDURE convertDataFileCopy(fname       IN varchar2,
                                max_corrupt IN binary_integer default 0);
  -- Name one file for conversion at the target database.


  PROCEDURE initnamespace;
  -- Used for testing to create locations because oratst doesn't support
  -- creating locations with uppercase. It initializes controlfile,
  -- logfile and datafile locations for db_create_file_dest


  PROCEDURE manageAuxInstance( orasid      IN      varchar2
                              ,cleanup     IN      binary_integer);

  -- This function is used by RMAN to manage the auxiliary
  -- instance for those OSs that require OS setup.
  -- If cleanup is FALSE, the tasks could include
  --   create 'services'
  -- If cleanup is TRUE, the taks could include:
  --   remove the 'services'
  -- Input parameters:
  --   orasid
  --     This is the ORACLE_SID of the database that will be created
  --   cleanup
  --     Non zero indicates to perform cleanup actions.

  PROCEDURE getCnctStr( cnctstr     OUT     varchar2
                       ,orasid      IN      varchar2
                       ,escaped     IN      boolean);

  -- This function obtains from the server the connect string to use
  -- as defined in sparams.h; if escaped is TRUE then it performs
  -- sosd specific conversion to allow connect string to be passed to
  -- RMAN host command.

  -- Output parameters:
  --   cnctstr
  --     This is the connect string that will be returned
  -- Input parameters:
  --   orasid
  --     This is the ORACLE_SID of the database to which we want to connect
  --   escaped
  --     This indicates if the connect string should be processed to
  --     be used by RMAN host command.


  VALIDATION_OK               constant binary_integer := 0;
  VALIDATION_RECORD_NOTFOUND  constant binary_integer := 1;
  VALIDATION_RECORD_DIFFERENT constant binary_integer := 2;
  VALIDATION_FILE_DIFFERENT   constant binary_integer := 4;


  -- Validate the correctness of the information in the recovery catalog
  -- and the controlfile regarding a backup piece, datafile copy, or
  -- archived log.  Neither the controlfile record nor the physical file itself
  -- is deleted. No errors are signalled. The return code contains one or more
  -- of the above constants, which tell the caller whether the controlfile
  -- record and/or the file itself is valid.  These constants are bit-flags,
  -- so bitand() must be used to decode the return code's value.  The status
  -- of the file itself is independant of the status of the record in the
  -- controlfile.  If the file is not found or does not match the validation
  -- data, then the VALIDATE_FILE_DIFFERENT flag will be set.  If the
  -- record in the controlfile is not found or is different, the corresponding
  -- VALIDATE_RECORD_xxx flag will be set.  The two VALIDATE_RECORD_xxx flags
  -- are mutually exclusive.  Thus, the possible return codes from the validate
  -- functions are: 0, 1, 2, and 4.
  --
  -- These procedures do not update the controlfile.
  --
  -- Input parameters:
  --   stamp
  --   recid
  --     These are the key of the record in the controlfile where the
  --     information about the file was recorded.
  --   handle
  --   fname
  --     The name or handle of the file/piece to validate.
  --   params
  --     This string is simply passed to the sequential file reading OSD. It
  --     is completely port and device specific.

  --   The remaining parameters are used to determine whether or not the
  --   file in question is the correct file.

  --   set_stamp
  --   set_count
  --     Backup set identification.
  --   pieceno
  --     Piece number within backup set.

  FUNCTION validateBackupPiece(recid       IN  number
                               ,stamp      IN  number
                               ,handle     IN  varchar2
                               ,set_stamp  IN  number
                               ,set_count  IN  number
                               ,pieceno    IN  binary_integer
                               ,params     IN  varchar2 default NULL
                               ,hdl_isdisk IN  binary_integer
                               ,media      OUT varchar2)
                               return binary_integer;
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --   media
  --     media handle on which piece exists
  --


  PROCEDURE validationStart;
  -- This procedure initializes restore conversation and
  -- the list of backup pieces to validate.
  -- Any pieces already in the list will be removed.


  PROCEDURE validationAddPiece( recid      IN  number
                               ,stamp      IN  number
                               ,handle     IN  varchar2
                               ,set_stamp  IN  number
                               ,set_count  IN  number
                               ,pieceno    IN  number
                               ,params     IN  varchar2 default NULL
                               ,hdl_isdisk IN  binary_integer);
  -- Adds a backup piece to the list of pieces to validate.


  PROCEDURE validationValidate;
  -- does the actual validation


  PROCEDURE validationNextResult( handle     OUT varchar2
                                 ,recid      OUT number
                                 ,set_stamp  OUT number
                                 ,set_count  OUT number
                                 ,pieceno    OUT number
                                 ,msca       OUT binary_integer
                                 ,m1         OUT varchar2
                                 ,m2         OUT varchar2
                                 ,m3         OUT varchar2
                                 ,m4         OUT varchar2
                                 ,m5         OUT varchar2
                                 ,m6         OUT varchar2
                                 ,m7         OUT varchar2
                                 ,m8         OUT varchar2
                                 ,m9         OUT varchar2
                                 ,m10        OUT varchar2
                                 ,m11        OUT varchar2
                                 ,m12        OUT varchar2
                                 ,m13        OUT varchar2
                                 ,m14        OUT varchar2
                                 ,m15        OUT varchar2
                                 ,m16        OUT varchar2
                                 ,m17        OUT varchar2
                                 ,m18        OUT varchar2
                                 ,m19        OUT varchar2
                                 ,m20        OUT varchar2);
  -- Gets the next result
  -- If no more results are found, then HANDLE is null.  The remaining
  -- output variables will have undefined values.
  --
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --   msca
  --     Media Supports Concurrent Access.  Set to 1 if the media allows
  --     concurrent access by more than one reader (e.g., hard disk), or
  --     0 if it does not (e.g., tape drives).
  --
  --   m1 - m20
  --     These are media handles on which a particular piece is stored.
  --     A piece may span any number of tapes, however we limit the
  --     number of tapes returned to 20.  If a piece spans more than 20
  --     tapes, then we return the first 19 and the last tape returned
  --     by the media management layer.  This is important because we
  --     want to remember which tape the channel currently holds when
  --     we assign steps.


  PROCEDURE validationEnd;
  -- This procedure ends the restore conversation.

  PROCEDURE backupPieceCreate( fname            IN  varchar2
                              ,pieceno          OUT binary_integer
                              ,done             OUT boolean
                              ,handle           OUT varchar2
                              ,comment          OUT varchar2
                              ,media            OUT varchar2
                              ,concur           OUT boolean
                              ,params           IN  varchar2       default NULL
                              ,media_pool       IN  binary_integer default 0
                              ,reuse            IN  boolean       default FALSE
                              ,archlog_failover OUT boolean
                              ,deffmt           IN  binary_integer
                              ,recid            OUT number
                              ,stamp            OUT number
                              ,tag              OUT varchar2
                              ,docompress       IN  boolean);
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --  docompress - compress this backup piece?
  --

  PROCEDURE getLimit( name   IN  binary_integer
                     ,value  OUT number );

  -- Get a limit to a particular value. This is a generic infra-structure to
  -- return values for conversation, after the conversation is destroyed.
  -- For the list of possible values <name> can have, refer to the constants
  --  defined in setLimit function.
  --
  -- Input parameters:
  --   name
  --     The limit number to set. Valid limit numbers are the constants above.
  --   value
  --     The value of the limit.
  -- Exceptions:
  --   INVALID-LIMIT-NUMBER (ora-19560)
  --     An invalid limit number was specified.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.

  PROCEDURE clearRecoveryDestFlag(rectype IN binary_integer,
                                  recid   IN number,
                                  stamp   IN number);
  --
  -- Set is_recovery_dest_file='NO' for the given record.
  --
  -- Input parameters:
  --   rectype
  --      The record type whose record needs to be cleared.
  --   recid, stamp
  --      The record-id, stamp to identify the record.

  PROCEDURE nidbegin(newdbname   IN  varchar2,
                     olddbname   IN  varchar2,
                     newdbid     IN  number,
                     olddbid     IN  number,
                     dorevert    IN  binary_integer,
                     dorestart   IN  binary_integer,
                     events      IN  number);

  PROCEDURE nidgetnewdbid(dbname    IN varchar2,
                          ndbid    OUT number);

  PROCEDURE nidend;

  PROCEDURE nidprocesscf(chgdbid     OUT binary_integer,
                         chgdbname   OUT binary_integer);

  PROCEDURE nidprocessdf(fno          IN number,
                         istemp       IN binary_integer,
                         skipped     OUT binary_integer,
                         chgdbid     OUT binary_integer,
                         chgdbname   OUT binary_integer);

  PROCEDURE isfileNameOMF(fname   IN  varchar2,
                          isOMF   OUT boolean,
                          isASM   OUT boolean);
  --
  -- Is given filename belongs to OMF family?
  --
  -- Input parameters:
  --   fname - Name of file in question.
  --   isOMF - TRUE if filename belongs to OMF family. Otherwise, FALSE.
  --           All filenames with prefix o1_mf (on unix and NT) and ASM
  --           system alias are considered as OMF files.
  --   isASM - TRUE if filename belongs to ASM family. Otherwise, FALSE.
  --           Note that this is TRUE even for ASM user alias.
  --

  PROCEDURE proxyRestoreDatafile(handle    IN varchar2,
                                 file#     IN binary_integer,
                                 toname    IN varchar2 default NULL,
                                 tsname    IN varchar2,
                                 blksize   IN binary_integer,
                                 blocks    IN number);
  -- Following parameter added :
  --   tsname  - tablespace name to which this datafile belongs
  --   blksize - block size of datafile to be restored
  --   blocks  - number of blocks in datafile to be restored

  PROCEDURE proxyRestoreControlfile(handle  IN varchar2,
                                    toname  IN varchar2,
                                    blksize IN binary_integer,
                                    blocks  IN number);
  -- Following parameter added :
  --   blksize - block size of controlfile to be restored
  --   blocks  - number of blocks in controlfile to be restored

  PROCEDURE clearOnlineLogNames;

  -- For TSPITR when AUXILIARY DESTINATION is used, we need to clear all
  -- names of the online logs so that they are created in the specified
  -- location.
  -- This is also used as a procedure to migrate online logs to OMF
  -- names using standby migration utility.

  PROCEDURE createDatafile(fno      IN number,
                           newomf   IN boolean,
                           recovery IN boolean,
                           fname    IN varchar2 default NULL);
  --
  -- re-createDatafile for RMAN. Functionally this is same as ALTER
  -- DATABASE CREATE DATAFILE from RMAN client point of view, when
  -- RMAN is doing recovery (i.e., recovery is TRUE).
  -- If called during restore (i.e., recovery is FALSE), then this
  -- function creates a datafile and adds datafile copy record to
  -- control file instead of updating kccfe datafile record. The
  -- created file can be treated same as level 0 datafile copy.
  --
  -- Input parameters:
  --   fno     - File number to create.
  --   newomf  - TRUE if server has to generate a new name for the file
  --             created.
  --   recovery- TRUE called during recovery.
  --   fname   - Name of the new file name. Used as input only if newname is
  --             FALSE.
  --             If input is NULL, the same name as in control file will be
  --             attempted to create.

  PROCEDURE applyOfflineRange(cfname  in varchar2 default null,
                              dfname  in varchar2 default null,
                              blksize in number   default null,
                              recid   in number   default null,
                              stamp   in number   default null,
                              fno     in binary_integer,
                              dfrecid in number,
                              dfstamp in number);

  -- Following parameters are added :
  --   dfrecid  - datafilecopy recid (valid only if dfname is not null)
  --   dfstamp  - datafilecopy stamp (valid only if dfname is not null)

  PROCEDURE resetCfileSection(record_type  IN  binary_integer );

  -- This procedure attempts to reset the circular controlfile section.
  --
  -- Input parameters:
  --   record_type
  --     The circular record type whose controlfile section is to be reset.

  PROCEDURE isfileNameOMF(fname   IN  varchar2,
                          isOMF   OUT boolean,
                          isASM   OUT boolean,
                          isTMPLT OUT boolean);

  -- Following parameters are added:
  --   isTMPLT - TRUE if fname is a template

  FUNCTION fetchFileRestored(firstcall     IN  boolean
                             ,proxy        IN  boolean
                             ,ftype        OUT binary_integer
                             ,fno          OUT binary_integer
                             ,thread       OUT binary_integer
                             ,sequence     OUT number
                             ,resetSCN     OUT number
                             ,resetStamp   OUT number
                             ,fname        OUT varchar2)
                         return binary_integer;

  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --  fname - Return restored filename
  --

  PROCEDURE resDataFileCopy(  cname         IN   varchar2
                             ,fname         IN   varchar2
                             ,full_name     OUT  varchar2
                             ,max_corrupt   IN   binary_integer  default 0
                             ,check_logical IN   boolean
                             ,blksize       IN   binary_integer
                             ,blocks        IN   binary_integer
                             ,fno           IN   binary_integer
                             ,scnstr        IN   varchar2
                             ,rfno          IN   binary_integer
                             ,tsname        IN   varchar2);

  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --  tsname - tablespace name to which this file belongs
  --

  PROCEDURE flashbackStart(flashbackSCN  IN number,
                           flashbackTime IN date,
                           scnBased      IN binary_integer,
                           toBefore      IN binary_integer,
                           resetSCN      IN number,
                           resetTime     IN date);
  -- Following parameters are added:
  --
  -- resetSCN, resetTime - resetlogs branch to which to flashback. Pass a
  --                       non-NULL value when flashbacked via RESTORE POINT.
  --                       If SCN/TIME/LOGSEQ was used, pass it as NULL to
  --                       indicate current incarnation.

  PROCEDURE backupSetDataFile( set_stamp     OUT  number
                              ,set_count     OUT  number
                              ,nochecksum    IN   boolean         default FALSE
                              ,tag           IN   varchar2        default NULL
                              ,incremental   IN   boolean         default FALSE
                              ,backup_level  IN   binary_integer  default 0
                              ,check_logical IN   boolean         default FALSE
                              ,keep_options  IN   binary_integer  default 0
                              ,keep_until    IN   number          default 0
                              ,imagcp        IN   boolean
                              ,convertto     IN   boolean
                              ,convertfr     IN   boolean
                              ,pltfrmto      IN   binary_integer
                              ,pltfrmfr      IN   binary_integer
                              ,sameen        IN   boolean
                              ,convertdb     IN   boolean);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  convertdb
  --    If TRUE indciates this is doing "convert database"
  --

  PROCEDURE switchTempfile(tsnum       IN number,
                           tsname      IN varchar2,
                           tfnum       IN number,
                           tfname      IN varchar2,
                           create_time IN date,
                           create_scn  IN number,
                           blocks      IN number,
                           blocksize   IN binary_integer,
                           rfnum       IN number,
                           exton       IN boolean,
                           isSFT       IN boolean,
                           maxsize     IN number,
                           nextsize    IN number);
  -- This procedure renames a tempfile record in controlfile section. If
  -- tempfile record doesn't exist, then it will add it to. If corresponding
  -- tablespace record doesn't exists, then it will also
  -- add it to fix controlfile.
  --
  -- Input parameters:
  --    tsnum - tablespace number (same as ts# in data dict)
  --    tsname - tablespace name
  --    tfnum - temporary file number
  --    tfname - temporary file name
  --    create_time - its creation time
  --    create_scn - and its creation scn
  --    blocks - creation file size in # logical blocks
  --    blocksize - logical block size for file
  --    rfnum - file's tablespace relative file number
  --    exton - TRUE - file autoextensible. Otherwise, FALSE
  --    isSFT - TRUE - single file tablespace. Otherwise, FALSE
  --    maxsize - maximum size to which file can extend in # logical blocks
  --    nextsize - incremental size of file expansion in # logical blocks

  PROCEDURE getOMFFileName(tsname  IN  varchar2
                          ,omfname OUT varchar2
                          ,isTemp  IN  boolean);

  -- This procedure returns an OMF file name for a datafile in the given
  -- tablespace.  The name is suitable for passing to create.  The name
  -- will have a "%u" in it, which will get replaced when the file is created.
  --
  -- Input parameters:
  --   tsname
  --     The name of the file's tablespace.
  -- Output parameters:
  --   omfname
  --     An OMF file name template for a datafile in the given
  --     tablespace.
  -- Exceptions:


  PROCEDURE genTransportScript( tscname       IN varchar2 default NULL
                               ,pfformat      IN varchar2 default NULL
                               ,rmtscname     IN varchar2 default NULL
                               ,pfname        OUT varchar2
                               ,newtscname    OUT varchar2
                               ,newrmtscname  OUT varchar2);


  -- This procedure generates the transport script, pfile and covnert script
  -- for transportable db
  --
  -- Input parameters:
  --   tscname 
  --     The name of the transport script.
  --   pfformat
  --     The format for the pfile specified by users.
  --   rmtscname
  --     The name of remote transport script(convert script).
  --   pfname
  --     The name of generated pfile
  --   newtscfname 
  --     Formatted transport script name 
  --   newrmtscname 
  --     Formatted remote transport script name(convert script).

  PROCEDURE TransportDBLock(newdbname IN varchar2 default NULL);
  -- This procedure sets a lock on transportable db coontext 
  -- The name of the new database to be created on the target platform
  -- can be passed to transportable db context, too.
  --
  -- Input parameters:
  --   newdbname
  --     The name of the new database to be created on the target platform.

  PROCEDURE TransportDBUnlock;
  -- This procedure frees the lock on transportable db context 

  PROCEDURE backupSetDataFile( set_stamp     OUT  number
                              ,set_count     OUT  number
                              ,nochecksum    IN   boolean         default FALSE
                              ,tag           IN   varchar2        default NULL
                              ,incremental   IN   boolean         default FALSE
                              ,backup_level  IN   binary_integer  default 0
                              ,check_logical IN   boolean         default FALSE
                              ,keep_options  IN   binary_integer  default 0
                              ,keep_until    IN   number          default 0
                              ,imagcp        IN   boolean
                              ,convertto     IN   boolean
                              ,convertfr     IN   boolean
                              ,pltfrmto      IN   binary_integer
                              ,pltfrmfr      IN   binary_integer
                              ,sameen        IN   boolean
                              ,convertdb     IN   boolean
                              ,nocatalog     IN   boolean);

  --  nocatalog
  --    If TRUE, do not record the backup meta information in repository.
  FUNCTION cfileCalcSizeList(
                  num_ckptprog_recs          IN  binary_integer  default 0
                 ,num_thread_recs            IN  binary_integer  default 0
                 ,num_logfile_recs           IN  binary_integer  default 0
                 ,num_datafile_recs          IN  binary_integer  default 0
                 ,num_filename_recs          IN  binary_integer  default 0
                 ,num_tablespace_recs        IN  binary_integer  default 0
                 ,num_tempfile_recs          IN  binary_integer  default 0
                 ,num_rmanconfiguration_recs IN  binary_integer  default 0
                 ,num_loghistory_recs        IN  binary_integer  default 0
                 ,num_offlinerange_recs      IN  binary_integer  default 0
                 ,num_archivedlog_recs       IN  binary_integer  default 0
                 ,num_backupset_recs         IN  binary_integer  default 0
                 ,num_backuppiece_recs       IN  binary_integer  default 0
                 ,num_backedupdfile_recs     IN  binary_integer  default 0
                 ,num_backeduplog_recs       IN  binary_integer  default 0
                 ,num_dfilecopy_recs         IN  binary_integer  default 0
                 ,num_bkdfcorruption_recs    IN  binary_integer  default 0
                 ,num_dfcopycorruption_recs  IN  binary_integer  default 0
                 ,num_deletedobject_recs     IN  binary_integer  default 0
                 ,num_proxy_recs             IN  binary_integer  default 0
                 ,num_reserved4_recs         IN  binary_integer  default 0
                 ,num_db2_recs               IN  binary_integer
                 ,num_incarnation_recs       IN  binary_integer
                 ,num_flashback_recs         IN  binary_integer
                 ,num_rainfo_recs            IN  binary_integer
                 ,num_instrsvt_recs          IN  binary_integer
                 ,num_agedfiles_recs         IN  binary_integer
                 ,num_rmanstatus_recs        IN  binary_integer
                 ,num_threadinst_recs        IN  binary_integer
                 ,num_mtr_recs               IN  binary_integer
                 ,num_dfh_recs               IN  binary_integer
                 ,num_sdm_recs               IN  binary_integer
                 ,num_grp_recs               IN  binary_integer
                 ,num_rp_recs                IN  binary_integer)
    return binary_integer;

  -- Description and return values can be found with original declaration
  -- above. New parameter:
  --
  --  num_sdm_recs
  --     Number of KCCDESDM records - Standby Database Matrix
  --  num_grp_recs
  --     Number of KCCDERSP records - Guaranteed restore points
  --  num_rp_recs
  --     Number of KCCDENRR records - restore points.
  
  PROCEDURE commitRmanStatusRow( row_id    IN number
                                ,row_stamp IN number
                                ,mbytes    IN number
                                ,status    IN binary_integer
                                ,ibytes    IN number
                                ,obytes    IN number
                                ,odevtype  IN varchar2);
  -- Following parameters are added:
  --   ibytes - input bytes
  --   obytes - output bytes

  PROCEDURE createRmanStatusRow( level         IN  binary_integer
                                ,parent_id     IN  number
                                ,parent_stamp  IN  number
                                ,status        IN  binary_integer
                                ,command_id    IN  varchar2
                                ,operation     IN  varchar2
                                ,row_id        OUT number
                                ,row_stamp     OUT number
                                ,flags         IN  binary_integer);
  -- Following parameters are added:
  --   flags - indicating user interested properties for the command
  --           like, DATABASE, DATAFILE, ARCHIVELOG, SPFILE, CONTROLFILE,
  --           OPTIMIZATION, etc.
  --           see krmk.h / kcc3.h for details on bits usage of the flag

  PROCEDURE createRmanOutputRow( l0row_id    IN number
                                ,l0row_stamp IN number
                                ,row_id      IN number
                                ,row_stamp   IN number
                                ,txt         IN varchar2
                                ,sameline    IN binary_integer);

  -- Following parameters are added:
  --   sameline - indicating client requested output to go to same previous
  --              line.

  FUNCTION genPieceName(pno        IN number
                        ,set_count IN number
                        ,set_stamp IN number
                        ,format    IN varchar2
                        ,copyno    IN number
                        ,devtype   IN varchar2
                        ,year      IN binary_integer
                        ,month     IN binary_integer
                        ,day       IN binary_integer
                        ,dbid      IN number
                        ,ndbname   IN varchar2
                        ,cfseq     IN number
                        ,fileno    IN number
                        ,tsname    IN varchar2
                        ,logseq    IN varchar2
                        ,logthr    IN number
                        ,imagcp    IN boolean
                        ,savepname IN boolean)
                        return varchar2;
  -- New parameters for creating names:
  --
  --   savepname 
  --     Save generated pname in SGA 

  
  PROCEDURE backupPieceCreate( fname            IN  varchar2
                              ,pieceno          OUT binary_integer
                              ,done             OUT boolean
                              ,handle           OUT varchar2
                              ,comment          OUT varchar2
                              ,media            OUT varchar2
                              ,concur           OUT boolean
                              ,params           IN  varchar2       default NULL
                              ,media_pool       IN  binary_integer default 0
                              ,reuse            IN  boolean       default FALSE
                              ,archlog_failover OUT boolean
                              ,deffmt           IN  binary_integer
                              ,recid            OUT number
                              ,stamp            OUT number
                              ,tag              OUT varchar2
                              ,docompress       IN  boolean
                              ,dest             IN  binary_integer);
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --  dest - When TRUE (non-zero), format specified is a OMF destination.
  --         The output file must be created as a OMF name with the format
  --         string as OMF destination. Otherwise, FALSE. 

  PROCEDURE OracleSbtVersion( isOracle         OUT boolean
                             ,version          OUT varchar2);
  -- Checks if our SBT tape channel is using Oracle Backup.
  -- If so, sets isOracle to TRUE and returns the version number as a 
  -- text string in the form of "AAA.BBB.CCC.DDD".
  --
  --
  -- Input parameters:
  --   isOracle
  --     Is this SBT channel using Oracle Backup?
  --   version
  --     The textual representation of the version string.  
  -- Returns:
  --   If isOracle is TRUE, then version will contain a string in the form
  --   of "A.B.C.D", where each of A,B,C,D can be between 0 and 255.  If
  --   isOracle is false, then the value of this version is undefined.
  --
  -- Gets the next result
  PROCEDURE validationNextResult( handle     OUT varchar2
                                 ,recid      OUT number
                                 ,set_stamp  OUT number
                                 ,set_count  OUT number
                                 ,pieceno    OUT number
                                 ,msca       OUT binary_integer
                                 ,m1         OUT varchar2
                                 ,m2         OUT varchar2
                                 ,m3         OUT varchar2
                                 ,m4         OUT varchar2
                                 ,m5         OUT varchar2
                                 ,m6         OUT varchar2
                                 ,m7         OUT varchar2
                                 ,m8         OUT varchar2
                                 ,m9         OUT varchar2
                                 ,m10        OUT varchar2
                                 ,m11        OUT varchar2
                                 ,m12        OUT varchar2
                                 ,m13        OUT varchar2
                                 ,m14        OUT varchar2
                                 ,m15        OUT varchar2
                                 ,m16        OUT varchar2
                                 ,m17        OUT varchar2
                                 ,m18        OUT varchar2
                                 ,m19        OUT varchar2
                                 ,m20        OUT varchar2
                                 ,attributes OUT binary_integer);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --   attributes
  --     Flags to indicate specific attribute of backup file.  These constants 
  --     are bit-flags, so bitand() must be used to decode the value.
  --     Values in this attributes are set by OSDS.
  --
  --  ATTRIBUTE_REMOTE bit set indicates that specific backup file
  --  is remote.
  ATTRIBUTE_REMOTE               constant binary_integer := 1;
  --  ATTRIBUTE_NOTFOUND bit set indicates that specific backup file
  --  was not found.
  ATTRIBUTE_NOTFOUND             constant binary_integer := 2;

  PROCEDURE validationValidate(flags IN binary_integer);
  -- does the actual validation
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --   flags
  --     flags for specific request.
  --
  --  VVFLAGS_RECALL bit flag indicate that server should request SBT
  --  to recall remote backups for current set of backup files.
  VVFLAGS_RECALL               constant binary_integer := 1;

  PROCEDURE bmrStart( save_all_blocks   IN boolean,
                      save_final_blocks IN boolean,
                      nofileupdate      IN boolean,
                      doclear           IN boolean);
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --  doclear - actually corrupt the block instead of fixing it
  --            used as an alternative to bbed
  --


  PROCEDURE backupPieceRestore(bpname         IN   varchar2
                              ,fname          IN   varchar2
                              ,handle         OUT  varchar2
                              ,recid          OUT  number
                              ,stamp          OUT  number
                              ,tag            IN   varchar2   default NULL
                              ,reuse          IN   boolean    default FALSE
                              ,check_logical  IN   boolean);
  -- Input parameters:
  --   bpname
  --     Operating system file name of the existing backup piece. This will be
  --     read and copied to sequential media.
  --   fname
  --     Filename of the backup piece to be created. This will be translated
  --     into a file handle after the piece is created.
  --   tag
  --     The tag stored in the file header of the copied and backed up files,
  --     and also in the controlfile records describing those files.
  --   reuse
  --     indicates if to reuse the output file if exists.
  --   check_logical
  --     if set to true indicates that besides physical block validations,
  --     logical validations will be performed on each block
  -- Output parameters:
  --   handle
  --     The handle for the backup piece that was created. This is a permanent
  --     name that can be used to read this sequential file for restore. It
  --     can only be used with the same device type that was allocated at
  --     this call.
  --   recid
  --     This is the ID of the record in the controlfile where the
  --     information about this backup piece was recorded. It can be used as
  --     the primary key to query V$BACKUP_PIECE.
  --   stamp
  --     This is a number that can be used to verify that the row in
  --     V$BACKUP_PIECE is really for this backup piece. The stamp combined
  --     with recid makes a key that is unique for this backup piece for all
  --     time.
  -- Exceptions:
  --   NO-INPUT-FILENAME (ora-19605)
  --     src_name must be assigned a non-NULL string in copyControlFile.
  --   NO-OUTPUT-FILENAME (ora-19574)
  --     dest_name must be assigned a non-NULL string in copyControlFile.
  --   NAME-TOO-LONG (ora-19704)
  --     The specified file name is longer than the port-specific
  --     maximum file name length.
  --   TAG-TOO-LONG (ora-19705)
  --     The tag is longer than the port-specific maximum.
  --   DEVICE-PARM-TOO-LONG (ora-19702)
  --     The device parameter is longer than the port-specific maximum.
  --   CANT-GET-INSTANCE-STATE-ENQUEUE (ora-1155)
  --     The database is in the process of being opened, closed, mounted,
  --     or dismounted.
  --   DATABASE-NOT-MOUNTED (ora-1507)
  --     The database is not mounted.
  --   FILE-IN-USE (ora-19584)
  --     The specified output file is already in use by the database as a
  --     datafile or online redo log.
  --   DEVICE-NOT-ALLOCATED (ora-19569)
  --     This session does not have a device allocated.
  --   CANT-IDENTIFY-FILE (ora-19505)
  --     The file can not be opened.
  --   END-OF-VOLUME (ora-19630)
  --     end-of-volume was encountered while copying the backup piece.
  --   CORRUPT_BLOCK (ora-19599)
  --     A corrupt block was encountered.  Corrupt blocks are not tolerated
  --     in backup pieces.
  --   NOT-A-BACKUP-PIECE (ora-19608)
  --     The input file is not recognizable as a backup piece.
  --   CORRUPT-DIRECTORY (ora-19610)
  --     The backup piece directory is corrupt.
  --   IO-ERROR
  --     An error occured attempting to read the input file.
  --   CREATE-ERROR
  --     An error was reported by the OSD to create the sequential file.
  --   WRITE-ERROR
  --     An error was reported by the sequential write OSD.

  PROCEDURE SetParms(p0 IN number   DEFAULT NULL,
                     p1 IN number   DEFAULT NULL,
                     p2 IN number   DEFAULT NULL,
                     p3 IN number   DEFAULT NULL,
                     p4 IN number   DEFAULT NULL,
                     p5 IN varchar2 DEFAULT NULL,
                     p6 IN varchar2 DEFAULT NULL,
                     p7 IN varchar2 DEFAULT NULL,
                     p8 IN varchar2 DEFAULT NULL,
                     p9 IN varchar2 DEFAULT NULL);

  PROCEDURE SetTableSpaceAttr(code  IN number,
                              tsid  IN  binary_integer,
                              clear IN  binary_integer,
                              onoff IN  binary_integer);
  
  TBS_ATTR_EXCLUDE    constant binary_integer := 0;
  TBS_ATTR_ENCRYPT    constant binary_integer := 1;

  PROCEDURE DoAutoBackup(ncopies OUT binary_integer
                         ,cfaudate   IN DATE           default   NULL
                         ,seq        IN binary_integer default NULL
                         ,format     IN varchar2       default NULL
                         ,p1         IN binary_integer
                         ,p2         IN binary_integer
                         ,p3         IN binary_integer
                         ,p4         IN varchar2);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --   p1, p2, p3, p4 additional attributes to DoAutoBackup

  FUNCTION getDiskGroupName(fname IN varchar2) return varchar2;

  -- Given an ASM filename, return the disk group name.
  --
  -- Input parameters:
  --   fname - ASM filename
  --
  -- Returns the diskgroup name

  PROCEDURE backupPieceCreate( fname            IN  varchar2
                              ,pieceno          OUT binary_integer
                              ,done             OUT boolean
                              ,handle           OUT varchar2
                              ,comment          OUT varchar2
                              ,media            OUT varchar2
                              ,concur           OUT boolean
                              ,params           IN  varchar2       default NULL
                              ,media_pool       IN  binary_integer default 0
                              ,reuse            IN  boolean       default FALSE
                              ,archlog_failover OUT boolean
                              ,deffmt           IN  binary_integer
                              ,recid            OUT number
                              ,stamp            OUT number
                              ,tag              OUT varchar2
                              ,docompress       IN  boolean
                              ,dest             IN  binary_integer
                              ,post10_2         IN  boolean);
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --  post10_2 - If TRUE (non-zero), this means that the rman client is from
  --         release 10.2 or higher. Therefore, the krbbx context should 
  --         not be cleared by the backupPieceCreate procedure. Use the 
  --         backupCancel procedure for cleanup. 

  PROCEDURE pieceContextGetNumber( parmid IN  binary_integer
                                  ,value  OUT binary_integer);

  -- Gets a numeric value from the backup piece context.
  --
  -- Input parameters:
  --   parmid
  --     Parameter to be retrieved.
  --
  -- Output parameters:
  --   value
  --     Value of parameter to be retrieved.
  --
  -- The valid list of parmid's follows.

  -- Get the value of the KRCBAD_KRBBX flag.
  SIGNAL_CHANGE_TRACKING_ERROR    constant binary_integer := 0;


  FUNCTION validateArchivedLog(recid             IN  number
                               ,stamp            IN  number
                               ,fname            IN  varchar2
                               ,thread           IN  number
                               ,sequence         IN  number
                               ,resetlogs_change IN  number
                               ,first_change     IN  number
                               ,blksize          IN  number
                               ,signal           IN  binary_integer
                               ,terminal         IN  binary_integer)
                               return binary_integer;

  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --   terminal : Log being validated is terminal EOR generated during
  --              standby failover operation.

  FUNCTION networkFileTransfer(dbname      IN varchar2
                              ,username    IN varchar2 default NULL
                              ,passwd      IN varchar2 default NULL
                              ,srcfile     IN varchar2
                              ,destfile    IN varchar2
                              ,operation   IN varchar2)
   RETURN boolean; 
  -- Copies files from/to remote database instnaces.
  -- Input parameters:
  --    dbname    - remote database name
  --    username  - user name
  --    passwd    - password
  --    srcfile   - source file
  --    destfile  - destination file
  --    operation - "read" or "write"
  -- Returns TRUE if succsessful. Otherwise, FALSE.

  PROCEDURE IncrementRecordStamp (rectype IN binary_integer,
                                  recid   IN number,
                                  stamp   IN number);

  --
  -- Increment record stamp for given record type.
  --
  -- Input parameters:
  --   rectype
  --      The record type whose record stamp needs to be incremented.
  --   recid, stamp
  --      The record-id, stamp to identify the record.

  PROCEDURE Fault_Injector(funcNo IN number, 
                           funcErr IN number,
                           funcCounter IN number DEFAULT 1);

  --
  -- Use this function to simulate any oracle error in a backup_restore
  -- function.  Used for testing
  --
  -- Input parameters
  --   funcNo
  --      The function number (based on the number it uses in icdstart)
  --      for which the error will be signaled
  --   funcErr
  --      The oracle error number to signal
  --   funcCounter
  --      The number of times the function has to be called before the
  --      error is signaled

  PROCEDURE initMSB( dfnumber      IN   number
                    ,file_size     OUT  number
                    ,set_stamp     OUT  number
                    ,set_count     OUT  number);

  -- Initialize multi-section backup processing for the specified file.
  --
  --   dfnumber:     file number that will be backed up in multiple sections
  --   file_size:    file size that needs to be backed up

  PROCEDURE setMSB( dfnumber      IN  number
                   ,section_size  IN  number
                   ,first_section IN  number
                   ,section_count IN  number
                   ,set_stamp     IN  number
                   ,set_count     IN  number
                   ,pieceno       IN  number
                   ,piececnt      IN  number);

  -- Set section size for multi-section backup
  --
  --   section_size:  number of blocks in one section
  --   first_section: first section to back up
  --   section_count: number of sections to back up
  --   set_stamp:     set_stamp to use for this backup piece
  --   set_count:     set_count to use for this backup piece
  --   pieceno:       piece number to use for this backup piece
  --   piececnt:      total number of pieces in this multi-section backup set

  PROCEDURE initMSR( dfnumber  IN  number
                    ,fname     OUT varchar2);

  -- Initialize file for multi-section full restore
  --
  --   dfnumber: file being restored
  --      fname: name of file

  -- Generates an archived log file name valid for a log file with
  -- the given thread, sequence, resetlog id.  Other values such as
  -- db id, activation number, log archive format and destination are
  -- taken from the mounted or open instance.
  --
  -- Input parameters:
  --   thread
  --     thread number for the log file name
  --   sequence
  --     sequence number for the log file name
  --   rls_id
  --     resetlog id for the log file name
  --
  -- Output parameters:
  --   arcName
  --     Name of archivelog to be created.
  --
  -- The valid list of parmid's follows.

  PROCEDURE getArcFileName( thread   IN number
                           ,sequence IN number
                           ,rls_id   IN number
                           ,arcName  OUT varchar2);

  -- Description and return values can be found with original declaration
  -- above.  New parameters:
  --
  --  netalias    - SQL*Net service name for remote creations
  --  compressalg - compression algorithm
  --
  PROCEDURE backupPieceCreate( fname            IN  varchar2
                              ,pieceno          OUT binary_integer
                              ,done             OUT boolean
                              ,handle           OUT varchar2
                              ,comment          OUT varchar2
                              ,media            OUT varchar2
                              ,concur           OUT boolean
                              ,params           IN  varchar2       default NULL
                              ,media_pool       IN  binary_integer default 0
                              ,reuse            IN  boolean       default FALSE
                              ,archlog_failover OUT boolean
                              ,deffmt           IN  binary_integer
                              ,recid            OUT number
                              ,stamp            OUT number
                              ,tag              OUT varchar2
                              ,docompress       IN  boolean
                              ,dest             IN  binary_integer
                              ,post10_2         IN  boolean
                              ,netalias         IN  varchar2
                              ,compressalg      IN  varchar2);

  PROCEDURE cfileMakeAndUseSnapshot( isstby         IN  boolean
                                    ,source_dbuname IN  varchar2
                                    ,dest_cs        IN  varchar2
                                    ,source_cs      IN  varchar2
                                    ,for_resync     IN  boolean);

  -- Description and return values can be found with original declaration
  -- above. 
  --
  -- The new parameters provide the capability for an instance with 
  -- connect string "dest_cs" to request the remote instance with the
  -- connect string "source_cs" for its current controlfile.
  -- The remote instance will copy its current controlfile to the 
  -- local instance's snapshot controlfile location.
  -- The db_unique_name of the remote instance is passed to ensure
  -- that we're copying the controlfile from the correct instance .
  --
  -- New parameters:
  --  source_dbuname  - db_unique_name of remote database
  --  source_cs       - SQL*Net service name for database whose CF is to be
  --                    copied.
  --  dest_cs         - SQL*Net service name for database which will receive
  --                    the controlfile.
  --  for_resync      - snapshot is created for RMAN resync operation
  -- NOTE: isstby is not used for remote controlfile copy operations.

  PROCEDURE bmrRestoreFromFlashback( limitSCN    IN number
                                    ,restoredNum OUT binary_integer);

  -- Restore blocks from flashback logs. This function searches
  -- flashback logs during block media recovery and restores them
  -- if found. BMR conversation should be active when called
  --
  -- Input parameters:
  --   limitSCN
  --     Stop SCN of the flashback log search
  --
  -- Output parameters:
  --   restoredNum
  --     Number of restored blocks

  PROCEDURE backupValidate(archlog_failover OUT boolean
                          ,nocleanup        IN  boolean);
  -- Description can be found with original declaration above.
  --
  -- New parameters
  --    nocleanup:  Pass it as TRUE if to keep backup conversation context
  --                at end of successful validation. Otherwise, FALSE.
  --

  PROCEDURE getBlockStat(blockStatTable OUT blockStatTable_t);
  --
  -- Copy all the statictics that was collected during a backup command.
  --
  -- Parameters:
  --    blockStatTable: copy block statistics into this table.
  --

  PROCEDURE validateBlock(blockRangeTable IN blockRangeTable_t);
  -- validateBlock adds the specified block range to the backup
  -- context for validation.

  PROCEDURE backupSetDataFile( set_stamp     OUT    number
                              ,set_count     OUT    number
                              ,nochecksum    IN     boolean        default FALSE
                              ,tag           IN     varchar2       default NULL
                              ,incremental   IN     boolean        default FALSE
                              ,backup_level  IN     binary_integer default 0
                              ,check_logical IN     boolean        default FALSE
                              ,keep_options  IN     binary_integer default 0
                              ,keep_until    IN     number         default 0
                              ,imagcp        IN     boolean
                              ,convertto     IN     boolean
                              ,convertfr     IN     boolean
                              ,pltfrmto      IN     binary_integer 
                              ,pltfrmfr      IN     binary_integer 
                              ,sameen        IN     boolean
                              ,convertdb     IN     boolean
                              ,nocatalog     IN     boolean
                              ,validate      IN     boolean
                              ,validateblk   IN     boolean
                              ,hdrupd        IN OUT boolean);

  -- Description can be found with original declaration above.
  -- 
  -- New parameters
  --    validate: Pass it as TRUE if this is a validate conversation context
  --    validateblk: Pass it as TRUE if this is a validate block conversation
  --    hdrupd: If FALSE as input, header update of locally managed files 
  --            will be not performed.  If set to TRUE as input, datafile 
  --            header checks will be done and hdrupd will be set accordingly.
  --            If TRUE as output, then datafile header update is required.
  --

  PROCEDURE backupSetArchivedLog( set_stamp   OUT  number
                             ,set_count       OUT  number
                             ,nochecksum      IN   boolean        default FALSE
                             ,tag             IN   varchar2
                             ,imagcp          IN   boolean
                             ,validate        IN   boolean);

  -- Description can be found with original declaration above.
  -- 
  -- New parameters
  --    validate: Pass it as TRUE if this is a validate conversation context
  --

  FUNCTION cfileCalcSizeList(
                  num_ckptprog_recs          IN  binary_integer  default 0
                 ,num_thread_recs            IN  binary_integer  default 0
                 ,num_logfile_recs           IN  binary_integer  default 0
                 ,num_datafile_recs          IN  binary_integer  default 0
                 ,num_filename_recs          IN  binary_integer  default 0
                 ,num_tablespace_recs        IN  binary_integer  default 0
                 ,num_tempfile_recs          IN  binary_integer  default 0
                 ,num_rmanconfiguration_recs IN  binary_integer  default 0
                 ,num_loghistory_recs        IN  binary_integer  default 0
                 ,num_offlinerange_recs      IN  binary_integer  default 0
                 ,num_archivedlog_recs       IN  binary_integer  default 0
                 ,num_backupset_recs         IN  binary_integer  default 0
                 ,num_backuppiece_recs       IN  binary_integer  default 0
                 ,num_backedupdfile_recs     IN  binary_integer  default 0
                 ,num_backeduplog_recs       IN  binary_integer  default 0
                 ,num_dfilecopy_recs         IN  binary_integer  default 0
                 ,num_bkdfcorruption_recs    IN  binary_integer  default 0
                 ,num_dfcopycorruption_recs  IN  binary_integer  default 0
                 ,num_deletedobject_recs     IN  binary_integer  default 0
                 ,num_proxy_recs             IN  binary_integer  default 0
                 ,num_reserved4_recs         IN  binary_integer  default 0
                 ,num_db2_recs               IN  binary_integer
                 ,num_incarnation_recs       IN  binary_integer
                 ,num_flashback_recs         IN  binary_integer
                 ,num_rainfo_recs            IN  binary_integer
                 ,num_instrsvt_recs          IN  binary_integer
                 ,num_agedfiles_recs         IN  binary_integer
                 ,num_rmanstatus_recs        IN  binary_integer
                 ,num_threadinst_recs        IN  binary_integer
                 ,num_mtr_recs               IN  binary_integer
                 ,num_dfh_recs               IN  binary_integer
                 ,num_sdm_recs               IN  binary_integer
                 ,num_grp_recs               IN  binary_integer
                 ,num_rp_recs                IN  binary_integer
                 ,num_bcr_recs               IN  binary_integer
                 ,num_acm_recs               IN  binary_integer
                 ,num_rlr_recs               IN  binary_integer)
    return binary_integer;

  -- Description and return values can be found with original declaration
  -- above. New parameter:
  --
  --  num_bcr_recs
  --     Number of KCCDEBCR records - Block Corruption Records
  --  num_acm_recs
  --     Number of KCCDEACM records
  --  num_rlr_recs
  --     Number of KCCDERLR records

  PROCEDURE VssBackedRecord (rectype IN binary_integer,
                             recid   IN number,
                             stamp   IN number);

  --
  -- All the record with stamp less than input stamp value are
  -- backed up by VSS infrastructure.
  -- 
  -- Input parameters:
  --   rectype
  --      The record type that are backed by VSS.
  --   recid, stamp
  --      The record-id, stamp to identify the last record.
  
  
  PROCEDURE backupSetArchivedLog( set_stamp     OUT  number
                                 ,set_count     OUT  number
                                 ,nochecksum    IN   boolean default FALSE
                                 ,tag           IN   varchar2
                                 ,imagcp        IN   boolean
                                 ,validate      IN   boolean
                                 ,keep_options  IN   binary_integer
                                 ,keep_until    IN   number);
  -- Description and return values can be found with original declaration
  -- above.
  -- New parameters
  --   keep_options: Bit mask indicating LOGS/NOLOGS/BACKUP_LOGS(consistent)
  --   keep_until:   Time when the backup expires


  PROCEDURE ir_icd_start(fn IN number);
  --
  -- This procedure is called at begining of DBMS_IR interface. It is same
  -- as icdStart in prvtbkrs.pls that increments the RPC count and sets the
  -- v$session.action field to STARTED.
  -- This is used so that RMAN can issue RPC call against DBMS_IR interface
  -- and DBMS_BACKUP_RESTORE in the same session.
  --
  -- Input parameters:
  --
  -- fn  - unique number that identifies the function call.
  --

  PROCEDURE ir_icd_finish;
  --
  -- This procedure is called at end of DBMS_IR interface. It is same as
  -- icdFinish in prvtbkrs.pls that sets the current RPC count as FINISHED
  -- in v$session.action.
  -- This is used so that RMAN can issue RPC call against DBMS_IR interface
  -- and DBMS_BACKUP_RESTORE in the same session.
  --

  FUNCTION UpdateHeaders return boolean;
  --
  -- This procedure is called by rman when datafile headers of locally 
  -- managed datafiles need to be updated after the database compatibility
  -- has been upgraded to 10.2 or above.
  -- This procedure can take several minutes for thousands of datafiles.
  -- Only one channel update the headers while the other channels block
  -- waiting for the enqueue.
  -- RETURNS
  --   TRUE if no errors during update
  --   FALSE otherwise
  -- 

  PROCEDURE cleanupBackupRecords;
  --
  -- This procedure is called by rman at end of delete/uncatalog command to
  -- mark bdf/bsf/brl/bs as deleted for which no backuppieces exists. This
  -- would save the processing time of query in nocatalog.
  --

  PROCEDURE readArchivedLogHeader( fname            IN  varchar2
                                  ,full_name        OUT varchar2
                                  ,thread           OUT number
                                  ,sequence         OUT number
                                  ,first_change     OUT number
                                  ,next_change      OUT number
                                  ,resetlogs_change OUT number
                                  ,resetlogs_time   OUT date);

  -- This procedure reads the header of a archived redo log and returns
  -- thread, sequence, first_change# and next_change#. No controlfile record
  -- is added.
  --
  -- Input parameters:
  --   fname
  --     File name of the archived log to inspect. This name may not be
  --     useable by another process, so it will be expanded.
  -- Output parameters:
  --   full_name
  --     This is the fully expanded name of the file that was inspected. It
  --     will also appear in V$ARCHIVED_LOG.
  --   thread, sequence, first_change, next_change
  --     thread, sequence, first_change and next_change present in
  --     archivelog header.
  --   resetlogs_change and resetlogs_time
  --     resetlogs information stored in archivelog header.

  PROCEDURE processSearchFileTable(catalog  IN boolean,
                                   implicit IN binary_integer,
                                   forftype IN binary_integer);
  --
  -- Description can be found with original declaration above.
  -- 
  -- New parameters
  --    forftype: one of KSFD filetypes to process. If all supported
  --              filetype has to be processed, then pass it as UB2MAXVAL.
  --

  FUNCTION validateArchivedLog(recid             IN  number
                               ,stamp            IN  number
                               ,fname            IN  varchar2
                               ,thread           IN  number
                               ,sequence         IN  number
                               ,resetlogs_change IN  number
                               ,first_change     IN  number
                               ,blksize          IN  number
                               ,signal           IN  binary_integer
                               ,terminal         IN  binary_integer
                               ,foreignal        IN  binary_integer)
                               return binary_integer;

  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  -- foreignal - If non-zero, then operate on foreign archived log entry.
  --             i.e kccrl that corresponds to v$foreign_archived_log
  --

  PROCEDURE changeArchivedLog(recid             IN  number
                             ,stamp             IN  number
                             ,fname             IN  varchar2
                             ,thread            IN  number
                             ,sequence          IN  number
                             ,resetlogs_change  IN  number
                             ,first_change      IN  number
                             ,blksize           IN  number
                             ,new_status        IN  varchar2
                             ,force             IN  binary_integer
                             ,foreignal         IN  binary_integer);

  -- Description and return values can be found with original and
  -- modified declaration above. New parameters  
  --                           
  -- foreignal - If non-zero, then operate on foreign archived log entry.
  --             i.e kccrl that corresponds to v$foreign_archived_log
  --

  PROCEDURE genTransportScript( tscname       IN varchar2 default NULL
                               ,pfformat      IN varchar2 default NULL
                               ,rmtscname     IN varchar2 default NULL
                               ,pfname        OUT varchar2
                               ,newtscname    OUT varchar2
                               ,newrmtscname  OUT varchar2
                               ,parallelism   IN number);

  -- Description and return values can be found with original and
  -- modified declaration above. New parameters  
  --                           
  -- parallelism - sets that value in the conversion script
  --

  FUNCTION remoteSQLExecute (source_dbuname IN varchar2,
                             source_cs      IN varchar2,
                             stmt           IN varchar2) return varchar2;


  -- This procedure allows executing a generic SQL statement at the
  -- remote database identified by source_cs connect string and source_dbuname
  -- db_unique_name parameter. It can be used to execute a simple SQL stmt
  -- or a SELECT statement that returns only one row, the value is returned
  -- by the function.
  --
  -- The length of column value can be up to 1024 characters.
  --
  --
  -- Input parameters:
  --  source_dbuname  - db_unique_name of remote database
  --  source_cs       - SQL*Net service name for database whose CF is to be
  --                    copied. No userid/password should be provided.
  --  stmt            - SQL Statement to execute at database instance
  --                    identified by source_cs and source_dbuname.

  FUNCTION getCkptSCN return number;
  -- This procedure is same getCkpt procedure described earlier, but returns
  -- only the ckp_scn.


  PROCEDURE backupControlFile( cfname      IN  varchar2  default NULL,
                               isstby      IN  boolean,
                               snapshot_cf IN  boolean);

  -- Description and return values can be found with original declaration
  -- above.  New parameters:
  --   snapshot_cf
  --     Ignored if the cfname is not NULL.
  --     If TRUE, indicates that the controlfile to be added is a snapshot
  --     controlfile.
  --     If FALSE, indicates that the controlfile to be added is current
  --     controlfile and backup conversation must be a validate.
  --
  
  PROCEDURE cleanupForeignArchivedLogs;
  -- This procedure will delete all foreign archivelogs created in FRA from
  -- disk as well as from the controlfile record. This is called when
  -- downgrading the database to pre 11 version. We need to cleanup all
  -- foreign archivedlogs because pre 11 version doesn't know how to manage
  -- foreign archivelogs in FRA.

  FUNCTION networkFileTransfer(dbname      IN  varchar2
                              ,username    IN  varchar2 default NULL
                              ,passwd      IN  varchar2 default NULL
                              ,role        IN  varchar2
                              ,srcfile     IN  varchar2
                              ,destfile    IN  varchar2
                              ,operation   IN  varchar2
                              ,retcode     OUT number)
   RETURN boolean; 

  -- Description and return values can be found with origianl declaration above.
  -- New parameters
  --
  -- role     - user role
  -- retcode  - 0 if successful. 
  --            1 to indicate client eror
  --            2 to indicate server error

  PROCEDURE backupBackupPiece( bpname         IN   varchar2
                              ,fname          IN   varchar2
                              ,handle         OUT  varchar2
                              ,comment        OUT  varchar2
                              ,media          OUT  varchar2
                              ,concur         OUT  boolean
                              ,recid          OUT  number
                              ,stamp          OUT  number
                              ,tag            IN   varchar2       default NULL
                              ,params         IN   varchar2       default NULL
                              ,media_pool     IN   binary_integer default 0
                              ,reuse          IN   boolean        default FALSE
                              ,check_logical  IN   boolean
                              ,copyno         IN   binary_integer
                              ,deffmt         IN   binary_integer
                              ,copy_recid     IN   number
                              ,copy_stamp     IN   number
                              ,npieces        IN   binary_integer
                              ,dest           IN   binary_integer);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  dest - indicates if the format is a destination or format. If > 0,
  --         then format is the destination and OMF name must be generated.
  --

  FUNCTION genPieceName(pno        IN number
                        ,set_count IN number
                        ,set_stamp IN number
                        ,format    IN varchar2
                        ,copyno    IN number
                        ,devtype   IN varchar2
                        ,year      IN binary_integer
                        ,month     IN binary_integer
                        ,day       IN binary_integer
                        ,dbid      IN number
                        ,ndbname   IN varchar2
                        ,cfseq     IN number
                        ,fileno    IN number
                        ,tsname    IN varchar2
                        ,logseq    IN varchar2
                        ,logthr    IN number
                        ,imagcp    IN boolean
                        ,savepname IN boolean
                        ,fname     IN varchar2
                        ,forcnvrt  IN boolean)
                        return varchar2;
  -- New parameters for creating names:
  --
  --   fname 
  --     original file name
  
  FUNCTION canKeepDatafiles RETURN binary_integer;
  -- This function checks if the compatible setting is high enough to allow
  -- the usage of KEEP DATAFILES subclause in DROP TABLESPACE by checking
  -- kck_rls_check(DTSKPDRLS).

  PROCEDURE setDbUniqNameTspitr(dbuname IN varchar2);
  -- This procedure sets (or resets if dbuname is NULL) the sga variable 
  -- krbdbutspitr, used to force a db_unique_name for ASM datafiles.

  FUNCTION bmrRestoreFromStandby(validate IN boolean) return number;

  -- Restore blocks from standby. This function establishes a connection
  -- to standby that is open during block media recovery and retrieves the
  -- block. BMR conversation should be active when called
  --
  -- Returns the number of restored blocks
  --

  PROCEDURE flashbackControlfile(flashbackSCN  IN number);
  --
  -- Flashes back the controlfile to a given SCN.
  --
  --  flashbackSCN
  --     scn to which to flashback.  SCN is equivalent to the "until
  --     change" SCN for media recovery.

  PROCEDURE inspectDataFileCopy( fname      IN   varchar2
                            ,full_name  OUT  varchar2
                            ,recid      OUT  number
                            ,stamp      OUT  number
                            ,tag        IN   varchar2  default NULL
                            ,isbackup   IN   boolean  default FALSE
                            ,change_rdi IN   boolean);
  -- New parameters:
  --
  --   change_rdi
  --     boolean value to indicate where recovery destination incarnation
  --     can be changed when inspecting this copy. This flag is set to FALSE
  --     normally when RMAN is inspecting datafilecopies for TSPITR.

  FUNCTION DuplicateFileExists RETURN binary_integer;
  -- This function check if a ?/dbs/_rm_dup_@.dat file exists from 
  -- a previous failed duplication.
  -- If it exists, it is read into the PGA memory of the channel and
  -- the function returns a non zero value. 
  -- If the file does not exist, the function returns a zero value and
  -- the file is created in anticipation of a duplicate run.
  -- If there is any error during the opening or reading of the file, the 
  -- failure is logged in the trace file but no error is signaled, however
  -- the return value will be zero.

  FUNCTION getDuplicatedDatafilecopy(fno IN number,
                                     newname IN varchar2, 
                                     crescn IN number,
                                     untscn IN number,
                                     dbid IN number,
                                     dbname IN varchar2,
                                     fname OUT varchar2,
                                     ckpscn OUT number)
           RETURN binary_integer;
  -- This function returns a non zero value if the filenumber is found in the 
  -- ?/dbs/_rm_dup_@.dat file, the name in the datafilecopy  
  -- matches the newname (for non-OMF newnames), the datafilecopy refers
  -- to an existing datafilecopy, the creation scn of the datafilecopy has
  -- to match the creation scn of the datafilecopy, the checkpoint of the
  -- datafilecopy is before the until scn, the dbid and the dbname of the 
  -- datafilecopy should also match.  If all these checks pass, then the
  -- datafilecopy name and checkpoint scn is returned to the caller together
  -- with the non-zero return value.
  -- If the filenumber is not found or the datafilecopy does not match the
  -- newname (for non-OMF newnames) or the datafilecopy fails any of the 
  -- validations, then a zero value is returned and the fname/ckpscn parameters 
  -- are invalid.
  -- Whenever an error is found during the lookup of the datafilecopy, the
  -- failure is logged in the trace file but no error is signaled, however
  -- the return value will be zero, fname/ckpscn in this case are invalid.

  PROCEDURE writeDuplicatedDatafilecopy(fno IN number, 
                                        fname IN varchar2);
  -- This procedure writes one record to the ?/dbs/_rm_dup_@.dat file and
  -- flushes the record to disk.
  -- If the write fails the failure is logged in the trace file but no error
  -- is signaled.

  PROCEDURE removeDuplicateFile;
  -- This procedure removes the ?/dbs/_rm_dup_@.dat file.
  -- If the file cannot be removed the failure is logged in the trace 
  -- file but no error is signaled.

  FUNCTION checkCompressionAlg(algname IN varchar2, asofrel IN number,
                               isvalid OUT binary_integer, 
                               mincompat OUT varchar2)
           return binary_integer;
  --
  -- Validates that the provided compression algorithm exists for the
  -- provided release
  -- Returns zero if algorithm name is not found for the specified release.
  -- Returns one if valid, output fileds are populated accordingly
  --
  --  algname
  --    name of the algorithm to validate
  --  asofrel
  --    release to which algname reffers, if 1 it indicates to use the
  --    release set in COMPRESSION_RELEASE initialization parameter
  --  isvalid
  --    1 if algorithm is valid (compatible and aco requirements met)
  --  mincompat
  --    mimimum release compatibility required for this algorithm


  -- Constants for backupPieceCreate
  --
  LOPT_FALSE    constant binary_integer := 1;
  LOPT_TRUE     constant binary_integer := 2;

  PROCEDURE backupPieceCreate( fname            IN  varchar2
                              ,pieceno          OUT binary_integer
                              ,done             OUT boolean
                              ,handle           OUT varchar2
                              ,comment          OUT varchar2
                              ,media            OUT varchar2
                              ,concur           OUT boolean
                              ,params           IN  varchar2       default NULL
                              ,media_pool       IN  binary_integer default 0
                              ,reuse            IN  boolean       default FALSE
                              ,archlog_failover OUT boolean
                              ,deffmt           IN  binary_integer
                              ,recid            OUT number
                              ,stamp            OUT number
                              ,tag              OUT varchar2
                              ,docompress       IN  boolean
                              ,dest             IN  binary_integer
                              ,post10_2         IN  boolean
                              ,netalias         IN  varchar2
                              ,compressalg      IN  varchar2
                              ,compressasof     IN  number         default 1
                              ,compresslopt     IN  binary_integer default
                                                                 LOPT_TRUE );

  -- Description and return values can be found with original declaration
  -- above.  New parameters:
  --
  --  compressasof - Release version for compression algorithm
  --  compresslopt - Type of optimize for load
  --

PROCEDURE clearControlfile;

  -- This procedure clears the circular sections of the controlfile to remove
  -- all the backups and image copy records and supporting controlfile
  -- records.  This is done in preparation for a no target, no recovery
  -- catalog duplicate, and should not be used lightly.

PROCEDURE switch_primary_bct;

  -- This procedure is executed only once per backup at a standby when 
  -- the backup is an incremental backup and the standby has block change
  -- tracking enabled.

FUNCTION networkFileTransfer(dbname      IN  varchar2
                            ,username    IN  varchar2 default NULL
                            ,passwd      IN  varchar2 default NULL
                            ,role        IN  varchar2
                            ,srcfile     IN  varchar2
                            ,destfile    IN  varchar2
                            ,operation   IN  varchar2
                            ,ftype_check IN  boolean
                            ,retcode     OUT number)
 RETURN boolean; 
  -- Description and return values can be found with original declaration above.
  -- New parameters
  --
  -- ftype_check     - file type check

  -- The following function returns the connect identifier using which
  -- a specific remote database can be connected.

FUNCTION get_connect_identifier(dbuname       IN varchar2)
                                return varchar2;

  PROCEDURE bmrStart( save_all_blocks   IN boolean,
                      save_final_blocks IN boolean,
                      nofileupdate      IN boolean,
                      doclear           IN boolean,
                      flags_clear       IN binary_integer default 0 );
  -- Description and return values can be found with original declaration
  -- above.  New parameter:
  --
  --  flags_clear - Indicates what kind of clearing should be performed
  --                see krbm0.h for details.

FUNCTION rman_usage(diskonly    IN boolean,
                    nondiskonly IN boolean,
                    encrypted   IN boolean,
                    compalg     IN varchar2)
return binary_integer;

   -- This procedure checks if backups with the specified characteristics
   -- are present in the system.
   --
   -- Parameters:
   --   diskonly     - If TRUE indicates that only copies and backups on disk
   --                  should be considered.
   --   nondiskonly  - If TRUE indicates that only backups on non disk devices
   --                  should be considered.  It is an error to specify this
   --                  parameter TRUE is diskonly is also TRUE, only one of them
   --                  can be specified.  It is OK that both are FALSE, as it
   --                  means that we want any backup.
   --   encrypted    - If TRUE indicates that we are looking for encrypted
   --                  backups only.  Currently it is an error that any other
   --                  parameter is specified if this is TRUE.
   --   compalg      - If not NULL indicates the compression algorithm that
   --                  the backups should be compressed with.  Currently it 
   --                  is an error that any other parameter is specified 
   --                  if this is not NULL.

  PROCEDURE restoreControlfileTo( cfname    IN  varchar2
                                 ,isstby    IN  boolean
                                 ,nocfconv  IN  boolean);
  -- Description and return values can be found with original declaration
  -- above. New parameters:
  -- 
  -- nocfconv 
  --   is set to TRUE when we don't want controfile conversion 
  
  PROCEDURE backupBackupPiece( bpname         IN   varchar2
                              ,fname          IN   varchar2
                              ,handle         OUT  varchar2
                              ,comment        OUT  varchar2
                              ,media          OUT  varchar2
                              ,concur         OUT  boolean
                              ,recid          OUT  number
                              ,stamp          OUT  number
                              ,tag            IN   varchar2       default NULL
                              ,params         IN   varchar2       default NULL
                              ,media_pool     IN   binary_integer default 0
                              ,reuse          IN   boolean        default FALSE
                              ,check_logical  IN   boolean
                              ,copyno         IN   binary_integer
                              ,deffmt         IN   binary_integer
                              ,copy_recid     IN   number
                              ,copy_stamp     IN   number
                              ,npieces        IN   binary_integer
                              ,dest           IN   binary_integer
                              ,pltfrmfr       IN   binary_integer);
  -- Description and return values can be found with original declaration
  -- above. New parameters
  --
  --  pltfrmfr - Id of platfrom to convert from.   0 if no conversion.

  PROCEDURE initFraMetaData;
  -- This procedure clears FRA meta-data and re-initializes it by inspecting
  -- each FRA file w.r.t current FRA setting. This is invented to re-init
  -- FRA meta-data on clone instance. Note that database isn't mounted as
  -- CLONE when rman does duplicate. So, this has be to re-initialized
  -- using explicit call.
  --

  PROCEDURE clearUnarchivedLogs;
  -- remove non archived entry from archived_log log

  PROCEDURE copyDataFileCopy( copy_recid       IN  number
                             ,copy_stamp       IN  number
                             ,full_name        OUT varchar2
                             ,recid            OUT number
                             ,stamp            OUT number
                             ,fname            IN  varchar2       default NULL
                             ,max_corrupt      IN  binary_integer default 0
                             ,tag              IN  varchar2       default NULL
                             ,nochecksum       IN  boolean        default FALSE
                             ,isbackup         IN  boolean        default FALSE
                             ,check_logical    IN  boolean        default FALSE
                             ,inst_restore     IN  binary_integer);
  -- This procedure is the same as copyDataFileCopy with the last
  -- two addtional parameters.
  --
  -- Two new input parameters:
  --   inst_restore
  --      Whether the instant restore option is exercised
  --      The value 0 is for no instant restore
  --      The value 1 is for instant restore full
  --      The value 2 is for instant restore sparse
  --  
  --   See the description of copyDataFileCopy for other parameters.

  PROCEDURE backupValidate(archlog_failover OUT boolean
                          ,nocleanup        IN  boolean
                          ,compress_set     IN  boolean);
  -- Description can be found with original declaration above.
  --
  -- New parameters
  --    compress_set:  Pass it as TRUE if validate as compressed backupset.
  --                 Otherwise, FALSE.
  --
  PROCEDURE OAMPolledRecord (rectype IN binary_integer,
                             recid   IN number,
                             stamp   IN number);

  --
  -- The record if belongs to FRA, will be marked as polled by OAM
  -- to enable automatic purging of file.
  -- 
  -- Input parameters:
  --   rectype
  --      The record type that are backed by VSS.
  --   recid, stamp
  --      The record-id, stamp to identify the record.
  
  pragma TIMESTAMP('2004-03-19:13:28:00');
end;

/
