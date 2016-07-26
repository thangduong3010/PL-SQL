Rem  Copyright (c) 2004, Oracle. All rights reserved.
Rem    NAME
Rem      privmat.sql - package of various OWA utility procedures
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

create or replace package body owa_match

as

    --- Special characters list, note 1 space in the beginning and 
    --- a single quote escaped at the end. 
    SPECIAL_CHARS constant varchar2(27) := ' @*()+-/=\<>;:"|&?{}[]''' 
        || chr(9)   -- tab 
        || chr(10)  -- new line 
        || chr(12)  -- form feed 
        || chr(13); -- cr

    TRANS_CHARS   constant varchar2(27) := '***************************';

    function match_pattern
    (
        p_string            in varchar2,
        p_simple_pattern    in owa_util.vc_arr default empty_vc_arr,
        p_complex_pattern   in owa_util.vc_arr default empty_vc_arr,
        p_use_special_chars in boolean         default true
    )
    return boolean is
        l_string        varchar2(512) := upper(p_string);
        l_count         integer := p_simple_pattern.count;
    begin

        if (p_use_special_chars) then
            --- First, check the string for any special characters,
            --- use translate function to replace any special character
            --- in the list with a '*'.
            --- Look for any '*' in the string, this means a special character
            --- has been found and the check failed.
            if (instr(translate(l_string, SPECIAL_CHARS, TRANS_CHARS),'*') > 0) then
                return true;
            end if;
        end if;

        --- Second, check the incoming string against default
        --- exclusions list
        for i in 1..l_count loop
            if (l_string like upper(p_simple_pattern(i)) escape '\') then
                return true;
            end if;
        end loop;

        --- Finally, check if we have any dynamic exclusions passed to us.
        --- If so, check the string against those exclusions as well.
        --- This is very slow, so should be used as the last resort, when
        --- cannot be covered by other checks.
        l_count := p_complex_pattern.count;
        if (l_count > 0) then
            for i in 1..l_count loop
                --- Use owa_pattern to do case-insensitive search
                if (owa_pattern.match(
                       line  => l_string,
                       pat   => upper(p_complex_pattern(i)),
                       flags => 'i'))
                then
                    return true; 
                end if;
            end loop;
        end if;

        return false; 

    end match_pattern;

end owa_match;

/

show errors package body owa_match


