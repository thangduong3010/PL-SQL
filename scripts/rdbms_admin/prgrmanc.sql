Rem 
Rem $Header: rdbms/admin/prgrmanc.sql /main/10 2009/03/30 03:58:48 fsanchez Exp $
Rem
Rem prgrmanc.sql
Rem 
Rem Copyright (c) 1995, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      prgrmanc.sql
Rem    DESCRIPTION
Rem      Purges from RMAN Recovery Catalog the records marked as deleted by
Rem      the user.
Rem
Rem      It is up to the user to mark the records as deleted using the
Rem      RMAN command: CHANGE ... DELETE
Rem
Rem      The Media Manager catalog is not updated by this script, only
Rem      the recovery catalog
Rem
Rem      As of 8.1.6 records removed by this script will not be reinserted
Rem      if a "resync from backup controlfile" is performed.  
Rem      Versions previous to 8.1.6 might reinsert the records, this might undo
Rem      both the CHANGE...DELETE and the physical delete of the record.
Rem
Rem      This script removes records from the following tables:
Rem          AL 
Rem          RLH
Rem          BP
Rem          BS
Rem          BCF
Rem          BDF
Rem          BCB
Rem          BRL
Rem          CCF
Rem          CDF
Rem          CCB
Rem          XCF (for 8.1)
Rem          XDF (for 8.1)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    fsanchez    03/26/09 - qualify column
Rem    molagapp    04/13/05 - bug-4287189
Rem    fsanchez    03/31/03 - bug-2845436
Rem    molagapp    10/11/00 - bug-1398757
Rem    fsanchez    08/24/00 - bug_1188620_82
Rem    fsanchez    09/29/99 - Make proxy cursors dynamic so this can be
Rem                           used in 8.0 catalogs
Rem    fsanchez    09/22/99 - Delete AL records without BRL records
Rem    fsanchez    09/08/99 - Delete al records only if catalog is 8.1.6
Rem    fsanchez    08/13/98 - Add proxy tables
Rem    fsanchez    07/28/98 - Creation
Rem
Rem   NOTES
Rem      This script runs only with sqlplus (not svrmgrl)
Rem      To avoid using large amounts of rollback the script commits
Rem      every 500 records by default
Rem      This value can be changed by modyfing the following line
define csize=500

set serveroutput on
set verify off
declare
    i           number;
    delc        number;
    key         number;
    eoc         boolean;
    vsn         varchar2(20);
    xdf_present number;
    xcf_present number;

-- Cursors

-- Cursor to obtain AL records without BRL records
    cursor alrecs_noref is
        select al_key
          from al left outer join brl
            on al.thread#   = brl.thread#
           and al.sequence# = brl.sequence#
           and al.dbinc_key = brl.dbinc_key
         where al.status = 'D' 
           and brl.thread# is null
           and brl.sequence# is null
           and brl.dbinc_key is null
           and rownum <= &&csize
           for update of al.status;

-- Cursor to obtain all AL records
    cursor alrecs_all is
        select al_key
          from al
         where status = 'D'
           and rownum <= &&csize
           for update of status;

-- Cursor to obtain all BP records
    cursor bprecs is
        select bp_key
          from bp
         where status = 'D'
           and rownum <= &&csize
           for update of status;

-- Cursor to obtain all BS records
    cursor bsrecs is
        select bs.bs_key
          from bs left outer join bp
            on bs.bs_key = bp.bs_key
         where bp.bs_key is null
           and rownum <= &&csize
           for update of bs.status;

-- Cursor to obtain all CCF records
    cursor ccfrecs is
        select ccf_key
          from ccf
         where status = 'D'
           and rownum <= &&csize
           for update of status;

-- Cursor to obtain all CDF records
    cursor cdfrecs is
        select cdf_key
          from cdf
         where status = 'D'
           and rownum <= &&csize
           for update of status;

-- Cursor to obtain all XCF records
    cursor xcfrecs is
        select xcf_key
          from xcf
         where status = 'D'
           and rownum <= &&csize
           for update of status;

-- Cursor to obtain all XDF records
    cursor xdfrecs is
        select xdf_key
          from xdf
         where status = 'D'
           and rownum <= &&csize
           for update of status;

-- Cursor to obtain obsoleted RLH records

begin
    -- Check the version of dbms_rcvman package. We can delete
    -- al records if we are using the 8.1.7 or greater version.
    -- We check this rather than the config table because the config
    -- table is obsolete from 8.1.6.2 onwards.
    eoc := false;
    dbms_rcvman.resetAll;
    while not eoc loop 
       vsn := dbms_rcvman.getPackageVersion;
       if vsn is null or vsn >= '08.01.07' then
          eoc := true;
       end if;
    end loop;

    if vsn >= '08.01.07' then
        dbms_output.put_line('Catalog version is at least 8.1.7');
        -- Step 1) Remove al records marked as deleted.  
        eoc := false;
        delc := 0;
        while not eoc loop
            open alrecs_all;
            i := 0;
            while not eoc and i < &&csize loop
                fetch alrecs_all into key;
                if not alrecs_all%NOTFOUND then
                    -- Delete the current al record
                    delete al
                     where current of alrecs_all;
                    -- Increment counter
                    i := i + 1;
                else
                    -- signal that we have processed all al records
                    eoc := true;
                end if;
            end loop;
            delc := delc + i;
            --- close and commit changes
            close alrecs_all;
            commit;
        end loop;
        dbms_output.put_line('Removed '||to_char(delc)||' al records');
    else
--      cannot remove AL records blindly.  Once the BS records are removed
--      then it might be possible to remove AL record without BRL records
        dbms_output.put_line('Catalog version is lower than 8.1.7');
    end if;

    -- Step 2) Delete the bp records marked as deleted
    eoc := false;
    delc := 0;
    while not eoc loop
        open bprecs;
        i := 0;
        while not eoc and i < &&csize loop
            fetch bprecs into key;
            if not bprecs%NOTFOUND then
                -- Delete the current bp record
                delete bp
                 where current of bprecs;
                -- Increment counter
                i := i + 1;
            else
                -- signal that we have processed all bp records
                eoc := true;
            end if;
        end loop;
        delc := delc + i;
        --- close and commit changes
        close bprecs;
        commit;
    end loop;
    dbms_output.put_line('Removed '||to_char(delc)||' bp records');

    -- Step 3) Remove the bs records that do not have any pieces left.
    --         When the bs record is removed, the  bcf, bdf, bcb and brl
    --         records are removed automatically by the integrity constraints
    eoc := false;
    delc := 0;
    while not eoc loop
        open bsrecs;
        i := 0;
        while not eoc and i < &&csize loop
            fetch bsrecs into key;
            if not bsrecs%NOTFOUND then
                -- Delete the current bs record, that in turn will remove
                -- records from bcf, bdf and brl.
                -- If a bdf record is removed, the bcb record will
                -- also be deleted.
                delete bs
                 where current of bsrecs;
                -- Increment counter
                i := i + 1;
            else
                -- signal that we have processed all bs records
                eoc := true;
            end if;
        end loop;
        delc := delc + i;
        --- close and commit changes
        close bsrecs;
        commit;
    end loop;
    dbms_output.put_line('Removed '||to_char(delc)||' bs records');
    
    -- Step 4) Remove the ccf records that are marked as deleted
    eoc := false;
    delc := 0;
    while not eoc loop
        open ccfrecs;
        i := 0;
        while not eoc and i < &&csize loop
            fetch ccfrecs into key;
            if not ccfrecs%NOTFOUND then
                -- Delete the current ccf record
                delete ccf
                 where current of ccfrecs;
                -- Increment counter
                i := i + 1;
            else
                -- signal that we have processed all bs records
                eoc := true;
            end if;
        end loop;
        delc := delc + i;
        --- close and commit changes
        close ccfrecs;
        commit;
    end loop;
    dbms_output.put_line('Removed '||to_char(delc)||' ccf records');

    -- Step 5) Remove the cdf records that are marked as deleted
    eoc := false;
    delc := 0;
    while not eoc loop
        open cdfrecs;
        i := 0;
        while not eoc and i < &&csize loop
            fetch cdfrecs into key;
            if not cdfrecs%NOTFOUND then
                -- Delete the current cdf record.  This in turn will
                -- remove ccb records by integrity constraints
                delete cdf
                 where current of cdfrecs;
                -- Increment counter
                i := i + 1;
            else
                -- signal that we have processed all bs records
                eoc := true;
            end if;
        end loop;
        delc := delc + i;
        --- close and commit changes
        close cdfrecs;
        commit;
    end loop;
    dbms_output.put_line('Removed '||to_char(delc)||' cdf records');

    -- Step 6) Delete the xcf records marked as deleted
    eoc := false;
    delc := 0;
    select count(*)
      into xcf_present
      from user_tab_columns
     where table_name = 'XCF';

    while not eoc and xcf_present > 0 loop
        open xcfrecs;
        i := 0;
        while not eoc and i < &&csize loop
            fetch xcfrecs into key;
            if not xcfrecs%NOTFOUND then
                -- Delete the current xcf record.
                delete xcf
                 where current of xcfrecs;
                -- Increment counter
                i := i + 1;
            else
                -- signal that we have processed all bs records
                eoc := true;
            end if;
        end loop;
        delc := delc + i;
        --- close and commit changes
        close xcfrecs;
        commit;
    end loop;
    if xcf_present > 0 then
       dbms_output.put_line('Removed '||to_char(delc)||' xcf records');
    end if;

    -- Step 7) Delete the xdf records marked as deleted
    eoc := false;
    delc := 0;
    select count(*)
      into xdf_present
      from user_tab_columns
     where table_name = 'XDF';

    while not eoc and xdf_present > 0 loop
        open xdfrecs;
        i := 0;
        while not eoc and i < &&csize loop
            fetch xdfrecs into key;
            if not xdfrecs%NOTFOUND then
                -- Delete the current xdf record.
                delete xdf
                 where current of xdfrecs;
                -- Increment counter
                i := i + 1;
            else
                -- signal that we have processed all bs records
                eoc := true;
            end if;
        end loop;
        delc := delc + i;
        --- close and commit changes
        close xdfrecs;
        commit;
    end loop;
    if xdf_present > 0 then
       dbms_output.put_line('Removed '||to_char(delc)||' xdf records');
    end if;

    if vsn is null then
        -- Step 8) Remove al records without brl records marked as deleted.  
        --         If the al record does not have a brl record then it can
        --         be deleted as it cannot be restored anymore
        eoc := false;
        delc := 0;
        while not eoc loop
            open alrecs_noref;
            i := 0;
            while not eoc and i < &&csize loop
                fetch alrecs_noref into key;
                if not alrecs_noref%NOTFOUND then
                    -- Delete the current al record
                    delete al
                     where current of alrecs_noref;
                    -- Increment counter
                    i := i + 1;
                else
                    -- signal that we have processed all al records
                    eoc := true;
                end if;
            end loop;
            delc := delc + i;
            --- close and commit changes
            close alrecs_noref;
            commit;
        end loop;
        dbms_output.put_line('Removed '||to_char(delc)||' al records');
    end if;

    -- Step 9) Remove rlh that are not needed any more.
    declare
       loc_dbinc_key  number;
       lowscn         number;
       xlowscn        number;
       eoincs         boolean;

    cursor dbincrecs is
       select dbinc_key
         from dbinc;

    cursor rlhrecs(dbinc_key number) is
        select rlh_key
          from rlh
         where next_scn < lowscn
           and rlh.dbinc_key = rlhrecs.dbinc_key
           and rownum <= &&csize
           for update of next_scn;

    begin
       eoincs := false;
       open dbincrecs;
       delc := 0;
       while not eoincs loop
          fetch dbincrecs into loc_dbinc_key;
          if not dbincrecs%NOTFOUND then
             -- Obtain the minimum scn in all backups and copies
             xlowscn := null;
             if (xcf_present > 0 and xdf_present > 0) then
                select nvl(min(scn), power(2,48)-1)
                  into xlowscn
                  from
                     (
                       select min(xdf.ckp_scn) scn
                         from xdf
                        where xdf.dbinc_key = loc_dbinc_key
                      union
                       select min(xcf.ckp_scn) scn
                         from xcf
                        where xcf.dbinc_key = loc_dbinc_key
                     );
             end if;

             xlowscn := nvl(xlowscn, power(2,48)-1);

             select nvl(min(scn), xlowscn)
               into lowscn
               from
                  (
                    select min(brl.low_scn) scn
                      from brl 
                     where brl.dbinc_key = loc_dbinc_key
                   union
                    select min(al.low_scn)
                      from al 
                     where al.dbinc_key = loc_dbinc_key
                   union
                    select min(bdf.ckp_scn) scn
                      from bdf 
                     where bdf.dbinc_key = loc_dbinc_key
                   union
                    select min(cdf.ckp_scn) scn
                      from cdf 
                     where cdf.dbinc_key = loc_dbinc_key
                   union
                    select min(bcf.ckp_scn) scn
                      from bcf 
                     where bcf.dbinc_key = loc_dbinc_key
                   union
                    select min(ccf.ckp_scn) scn
                      from ccf 
                     where ccf.dbinc_key = loc_dbinc_key
                  );
             eoc := false;
             while not eoc loop
                 open rlhrecs(loc_dbinc_key);
                 i := 0;
                 while not eoc and i < &&csize loop
                     fetch rlhrecs into key;
                     if not rlhrecs%NOTFOUND then
                         -- Delete the current rlh record.  
                         delete rlh
                          where current of rlhrecs;
                         -- Increment counter
                         i := i + 1;
                     else
                         -- signal that we have processed all rlh records
                         eoc := true;
                     end if;
                 end loop;
                 delc := delc + i;
                 --- close and commit changes
                 close rlhrecs;
                 commit;
             end loop;
          else
             -- signal that we have processed all rlh records
             eoincs := true;
          end if;
       end loop;
       close dbincrecs;
       commit;
       dbms_output.put_line('Removed '||to_char(delc)||' rlh records');
    end;
end;

/

