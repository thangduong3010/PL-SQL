Rem
Rem $Header: ovmdbmig.sql 26-oct-2006.13:44:57 bspeckha Exp $
Rem
Rem ovmdbmig.sql
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      ovmdbmig.sql - Invoked by RDBMS upgrade
Rem
Rem    DESCRIPTION
Rem      This script runs the OWM upgrade. It is invoked by RDBMS upgrade
Rem    script. It selects the owm upgrade script to be run depending on
Rem    the existing OWM_VERSION.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bspeckha    10/24/06 - moving everything to wmsys
Rem    saagarwa    11/19/02 - Add calls in the begining and end
Rem    saagarwa    11/12/02 - 
Rem    saagarwa    04/29/02 - 
Rem    saagarwa    04/05/02 - Account for 9.2.0.3
Rem    saagarwa    03/28/02 - saagarwa_generic_upgrade_script_main
Rem    saagarwa    03/28/02 - Created
Rem

Rem =========================================================================
Rem BEGIN: Upgrade OWM component
Rem =========================================================================

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem == dbms_registry.upgrading called in the following scripts ==

@@owmupgrd.plb

Rem == dbms_registry.loaded called in the above scripts ==

Rem =========================================================================
Rem END: Upgrade OWM component
Rem =========================================================================

