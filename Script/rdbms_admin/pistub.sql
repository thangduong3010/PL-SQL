rem
rem $Header: pistub.sql 15-may-2006.16:49:51 wxli Exp $
rem
Rem  Copyright (c) 1991, 1999 by Oracle Corporation
Rem    NAME
Rem      pistub.sql - subprogram stub generator
Rem    DESCRIPTION
Rem      equivalent to v7$pls:[qa]pstub.pls
Rem    MODIFIED   (MM/DD/YY)
Rem     wxli       05/15/06  - drop pstub and pstubt 
Rem     jmuller    05/28/99 -  Fix bug 708690: TAB -> blank
Rem     pshaw      10/21/92 -  modify script for bug 131187 
Rem     gclossma   09/08/92 -  allow null dbname in cursor in pstub 
Rem     gclossma   08/05/92 -  impl pstub in terms of pistub 
Rem     gclossma   07/14/92 -  pstubT: add constraints to CHARs; bigger pkgs 
Rem     gclossma   06/22/92 -  pstubt: gen stubs into table PSTUBTBL 
Rem     gclossma   05/08/92 -  simplify; check buffer lengths 
Rem     gclossma   04/10/92 -  gen CHAR stead of VARCHAR2 for sqlforms3 for v6 
Rem     ahong      03/24/92 -  add s_notInPackage 
Rem     ahong      03/13/92 -  rpc 
Rem     ahong      03/10/92 -  fix func stub 
Rem     ahong      02/26/92 -  fix subptxt 
Rem     ahong      01/07/92 -  icd for DESCRIBE
Rem     pdufour    01/03/92 -  remove connect internal and add drop package
Rem     gclossma   11/27/91 -  Creation


---------------------------------------------------------------------
--
--  subptxt2: returns the text of a subprogram source (DESCRIBE).
--      In: name - package or toplevel proc/func name;
--          subname - non-null to specify proc/func in package <name>.
--          usr - user name
--          dbname - database name, null or '' for current
--          dbowner - database owner, null or '' for current
--      Out:  subprogram text in txt
--          '$$$ s_subpNotFound' -> subprog not found; txt empty
--          '$$$ s_stubTooLong' -> stub text too long; txt empty
--          '$$$ s_logic' -> logic error; txt empty
--          '$$$ s_notInPackage' -> cannot find subname in package <name>
--          '$$$ s_other' -> other failure

drop procedure sys.subptxt2;
create procedure sys.subptxt2(name varchar2, subname varchar2, usr varchar2,
                             dbname varchar2, dbowner varchar2,
                             txt in out varchar2) is
status diutil.ub4;

begin -- main
    diutil.subptxt(name, subname, usr, dbname, dbowner, txt, status);
    if (status <> diutil.s_ok) then
        if (status = diutil.s_subpNotFound) then
            txt := '$$$ s_subpNotFound';
        elsif (status = diutil.s_stubTooLong) then
            txt := '$$$ s_stubTooLong';
        elsif (status = diutil.s_logic) then
            txt := '$$$ s_logic';
        elsif (status = diutil.s_notInPackage) then
            txt := '$$$ s_notInPackage';
        else txt := '$$$ s_other';
        end if;
    end if;
end subptxt2;
/

---------------------------------------------------------------------

-- subptxt - similar to subptxt2, but w/o dbname and dbowner


drop procedure sys.subptxt;
create procedure sys.subptxt(name varchar2, subname varchar2, usr varchar2,
                             txt in out varchar2) is
begin
    subptxt2(name, subname, usr, null, null, txt);
end;
/
grant execute on subptxt to public;

