Rem  Copyright (c) 2004, Oracle. All rights reserved.
Rem    NAME
Rem      pubmat.sql - package of various OWA utility procedures
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_match   - Utitility procedures/functions for use
Rem                       with the Oracle Web Agent
Rem
Rem    NOTES
Rem      The Oracle Web Agent is needed to use these facilities.
Rem      The package owa_match is needed to use these facilities.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     dnonkin    08/12/04 -  Creation

create or replace package owa_match

as

    empty_vc_arr owa_util.vc_arr;

    function match_pattern
    (
        p_string            in varchar2,
        p_simple_pattern    in owa_util.vc_arr default empty_vc_arr,
        p_complex_pattern   in owa_util.vc_arr default empty_vc_arr,
        p_use_special_chars in boolean         default true
    )
    return boolean;

end owa_match;

/

show errors package owa_match


