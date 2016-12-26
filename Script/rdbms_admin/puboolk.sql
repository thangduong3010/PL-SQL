rem
rem
Rem  Copyright (c) 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      puboolk.sql - package of various OWA OPTIMISTIC LOCKING procedures
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_opt_lock    - Utitility procedures/functions for use
Rem                           with the Oracle Web Agent
Rem
Rem    NOTES
Rem      The Oracle Web Agent is needed to use these facilities.
Rem      The package owa is needed to use these facilities.
Rem      The package owa_util is needed to use these facilities.
Rem      The packages htp and htf are needed to use these facilities.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     mpal	   06/24/96 -  Creation

REM Creating OWA_OPT_LOCK package...
create or replace package OWA_OPT_LOCK
as

	type vcArray is table of varchar2(2000) index by binary_integer;

	pragma restrict_references( owa_opt_lock, wnds, rnds, wnps, rnps );

	/* Function to calculate checksum values */
	function checksum( p_buff in varchar2 ) return number;
	pragma restrict_references( checksum, wnds, rnds, wnps, rnps );

	function checksum( p_owner in varchar2, 
					   p_tname in varchar2, 
					   p_rowid in rowid ) return number;

	/* Procedures to store and verify row values for optimistic locking */
	procedure store_values( p_owner in varchar2, 
						     p_tname in varchar2, 
						     p_rowid in rowid );
	
	function verify_values( p_old_values in vcArray ) return boolean;

	function get_rowid( p_old_values in vcArray ) return rowid;
	pragma restrict_references( get_rowid, wnds, rnds, wnps, rnps );

end;
/
show errors
