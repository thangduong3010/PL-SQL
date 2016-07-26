Rem  Copyright (c) 1999, 2000 by Oracle Corp.  All Rights Reserved.
Rem
Rem   NAME
Rem     pubcach.sql - PUBlic CACHe package
Rem   PURPOSE
Rem     Provide cache functions for caching PL/SQL generated contents
Rem   NOTES
Rem     This file is used to implement PL/SQL caching in the PL/SQL Gateway.
Rem     This script should be run by the owner of the OWA packages.
Rem   MODIFIED   (MM/DD/YY)
Rem    ehlee      07/11/01 - adding Surrogate-Control reserve header
Rem    ehlee      12/28/00 - remove NOCOPY for 8.0.x compatibility
Rem    ehlee      06/20/00 - adding Expires model support
Rem    ehlee      05/11/00 - add check for GATEWAY_IVERSION
Rem    ehlee      05/02/00 - creation
Rem

CREATE OR replace PACKAGE owa_cache
AS
  -- 
  -- Public types and global variables
  --

  -- The different caching levels. For now, just user and system.
  system_level CONSTANT VARCHAR(6) := 'SYSTEM';
  user_level   CONSTANT VARCHAR(4) := 'USER';

  --
  -- PROCEDURE:
  --   init
  -- DESCRIPTION:
  --   Reserve header spaces
  -- PARAMS:
  --   p_htbuf    IN/OUT: the buffer to reserve the headers in
  --   p_rows_in  IN/OUT: the current row number in that buffer
  -- NOTE:
  --   Should only be called before any data is written to the htbuf
  --
  PROCEDURE init(p_htbuf IN OUT htp.htbuf_arr, p_rows_in IN OUT number);

  --
  -- PROCEDURE:
  --   disable
  -- DESCRIPTION:
  --   Disables the cache
  --
  PROCEDURE disable;

  --
  -- PROCEDURE:
  --   set_expires
  -- DESCRIPTION:
  --   Sets up the cache headers
  -- PARAMS:
  --   p_expires  IN: number of minutes this cached item is fresh
  --   p_level    IN: the caching level for it (USER or SYSTEM for now)
  -- EXCEPTIONS:
  --   VALUE_ERROR : If p_expires is negative or zero, or p_level is not
  --                 'USER' or 'SYSTEM', this exception is thrown
  --                 If p_expires is > 525600 (1 year), this exception is thrown
  PROCEDURE set_expires(p_expires IN number, p_level IN varchar2);

  --
  -- PROCEDURE:
  --   set_cache
  -- DESCRIPTION:
  --   Sets up the cache headers
  -- PARAMS:
  --   p_etag     IN: the ETag associated with this content
  --   p_level    IN: the caching level for it (USER or SYSTEM for now)
  -- EXCEPTIONS:
  --   VALUE_ERROR : If p_etag is greater than 55 in length or p_level is
  --                 not 'USER' or 'SYSTEM', this exception is thrown
  --
  PROCEDURE set_cache(p_etag IN varchar2, p_level IN varchar2);

  --
  -- PROCEDURE:
  --   set_not_modified
  -- DESCRIPTION:
  --   Sets up the headers for a not modified cache hit
  -- EXCEPTIONS:
  --   VALUE_ERROR : If the ETag wasn't passed in, this exception is thrown
  --
  PROCEDURE set_not_modified;

  --
  -- PROCEDURE:
  --   set_surrogate_control
  -- DESCRIPTION:
  --   Sets up the headers for a surrogate-control header for web cache
  -- PARAMS:
  --   p_value    IN: value to be passed as the Surrogate-Control header
  -- EXCEPTIONS:
  --   VALUE_ERROR : If p_value is greater than 55 in length
  --
  PROCEDURE set_surrogate_control(p_value IN varchar2);

  --
  -- FUNCTION:
  --   get_level
  -- DESCRIPTION:
  --   Returns the caching level
  -- PARAMS:
  --   none
  -- RETURN:
  --   The caching level string (USER or SYSTEM for now)
  --
  FUNCTION get_level
    RETURN VARCHAR2;

  --
  -- FUNCTION:
  --   get_etag
  -- DESCRIPTION:
  --   Returns the caching etag
  -- PARAMS:
  --   none
  -- RETURN:
  --   The caching etag string
  --
  FUNCTION get_etag
    RETURN VARCHAR2;

END owa_cache;
/
show errors package owa_cache



