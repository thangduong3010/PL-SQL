rem
rem $Header: plsql/admin/pipidl.sql /main/16 2010/06/04 10:11:25 wxli Exp $
rem
Rem Copyright (c) 1991, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem    NAME
Rem      pidl.sql - package Portable IDL
Rem    DESCRIPTION
Rem      equivalent to v7$pls:[icd]PIPISPC.PLS and PIPIBDY.PLS
Rem    MODIFIED   (MM/DD/YY)
Rem     wxli       05/25/10 - XbranchMerge wxli_bug-9378982 from st_rdbms_10.2
Rem     wxli       03/25/10 - bug 9378982: remove ptfnxt ptftin
Rem     gviswana   10/06/04 - Remove hshbod 
Rem     jmuller    05/28/99 - Fix bug 708690: TAB -> blank
Rem     jmuller    02/11/98 -
Rem     jmuller    01/14/98 -  Add TRENULL
Rem     jmuller    08/27/96 -  So update it!
Rem     jmuller    05/23/96 -  Fix bug 338442: goodbye, byte4
Rem     kmuthukk   02/23/96 -  opls_be merge to mainline
Rem     mdevin     02/13/96 -  Merging /main/opls_be/LATEST
Rem     kmuthukk   01/29/96 -  opls_be: change pointers to number
Rem     usundara   04/08/94 -  merge changes from branch 1.9.710.1
Rem                            fix traversals - bug 161306,147036 (for pclare)
Rem     pshaw      10/21/92 -  modify script for bug 131187 
Rem     gclossma   05/08/92 -  cleaning 
Rem     ahong      02/18/92 -  use package diutil 
Rem     gclossma   01/22/92 -  functions may not have OUT parms 
Rem     gclossma   01/14/92 -  pkg PIDL mustn't call pkg DIANA: disable subptxt
Rem     ahong      01/07/92 -  icd for DESCRIBE
Rem     pdufour    01/03/92 -  remove connect internal and add drop package
Rem     gclossma   11/27/91 -  Creation
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
-- NOTE: you must be connected "internal" (as user SYS) to run this script.
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE

create or replace package sys.PIDL is


  ----------------------------------------------------------------------------
  -- Persistent IDL datatypes
  ----------------------------------------------------------------------------

  subtype ptnod     is binary_integer; -- generic IDL node type
  TRENULL CONSTANT ptnod := 0;         -- a NULL node
  subtype ub4       is binary_integer; -- Oracle C type, unsigned byte 4
  subtype ub2       is binary_integer; -- Oracle C type, unsigned byte 2
  subtype ub1       is binary_integer; -- Oracle C type, unsigned byte 1
  subtype sb4       is binary_integer; -- Oracle C type, signed byte 4 
  subtype sb2       is binary_integer; -- Oracle C type, signed byte 2

  ----------------------------------------------------------------------------
  -- Sequence datatypes.
  ----------------------------------------------------------------------------
  subtype ptseqtx   is ptnod;       -- seq of text/char
  subtype ptseqnd   is ptnod;       -- seq of IDL node
  subtype ptsequ4   is ptnod;       -- seq of ub4
  subtype ptsequ2   is ptnod;       -- seq of ub2
  subtype ptsequ1   is ptnod;       -- seq of ub1
  subtype ptseqs4   is ptnod;       -- seq of sb4
  subtype ptseqs2   is ptnod;       -- seq of sb2

  ----------------------------------------------------------------------------
  -- Non-persistent IDL datatypes
  ----------------------------------------------------------------------------
  subtype private_ptr_t is number;
  type    ptr_t     is record(private_ptr private_ptr_t);
  subtype ptseqpt   is ptnod;  -- seq of ptr_t

  ----------------------------------------------------------------------------
  -- Types used for the implementation of persistent-idl.
  ----------------------------------------------------------------------------
  subtype ptnty     is ub2;     -- node-type enumerators
  subtype ptaty     is ub2;     -- attr-type enumerators
  subtype ptbty     is ub2;     -- base-type enumerators for attributes
  subtype ptrty     is ub2;     -- rererence-type enumerators

  ----------------------------------------------------------------------------
  -- Enumerators for the kinds of reference (ptrty).
  ----------------------------------------------------------------------------
  PTA_REF       constant ptrty := 0; -- REF
  PTA_PART      constant ptrty := 1; -- PART
  PTA_PREF      constant ptrty := 2; -- PART REF

  ----------------------------------------------------------------------------
  -- Enumerators for the idl basetypes (ptbty).
  ----------------------------------------------------------------------------
  PTABTERR constant ptbty :=  0; -- error
  PTABT_ND constant ptbty :=  1; -- ptnod 
  PTABT_TX constant ptbty :=  2; -- text* 
  PTABT_U4 constant ptbty :=  3; -- ub4   
  PTABT_U2 constant ptbty :=  4; -- ptbty
  PTABT_U1 constant ptbty :=  5; -- ub1
  PTABT_S4 constant ptbty :=  6; -- sb4   
  PTABT_S2 constant ptbty :=  7; -- sb2
--PTABT_B4 constant ptbty :=  8; -- byte4: desupported: use ub4 instead
  PTABT_PT constant ptbty :=  9; -- dvoid*
  PTABT_RA constant ptbty := 10; -- s_opera 
                -- s_opera is an internal type, for diana's S_OPERAT
  PTABT_LS constant ptbty := 11; -- ptlis*
  PTABT_RS constant ptbty := 12; -- ub1* raw string, w/out null ind
  PTABT_CS constant ptbty := 13; -- char* w/out null ind
-- (pl)sql basetypes
  PTABT_NU constant ptbty := 14; -- sql number (with null ind)
  PTABT_RW constant ptbty := 15; -- sql raw (with null ind)
  PTABT_C2 constant ptbty := 18; -- sql varchar2 (with null ind)
  PTABT_DT constant ptbty := 19; -- sql date (with null ind)
  PTABT_BI constant ptbty := 20; -- (pl)sql binary_integer (w nullind)
  PTABT_BO constant ptbty := 21; -- (pl)sql boolean (with null ind)

-- ptabts: pt attribute base type sequences, idl bulk types, one of:
  PTABTS_0 constant ptbty := 29;
  PTABTSND constant ptbty := (PTABTS_0 +  1); -- seq of ptnod 
  PTABTSTX constant ptbty := (PTABTS_0 +  2); -- seq of text* 
  PTABTSU4 constant ptbty := (PTABTS_0 +  3); -- seq of ub4   
  PTABTSU2 constant ptbty := (PTABTS_0 +  4); -- seq of ptbty
  PTABTSU1 constant ptbty := (PTABTS_0 +  5); -- seq of ub1
  PTABTSS4 constant ptbty := (PTABTS_0 +  6); -- seq of sb4   
  PTABTSS2 constant ptbty := (PTABTS_0 +  7); -- seq of sb2
--PTABTSB4 constant ptbty := (PTABTS_0 +  8); -- seq of byte4: desupported
  PTABTSPT constant ptbty := (PTABTS_0 +  9); -- seq of dvoid*
  PTABTSRA constant ptbty := (PTABTS_0 + 10); -- seq of s_opera
--      PTABTSLS  (PTABTS_0 + 11);          -- seq of ptlis*: unsupported
  PTABTSRS constant ptbty := (PTABTS_0 + 12); -- seq of ub1*
  PTABTSCS constant ptbty := (PTABTS_0 + 13); -- seq of char*
-- (pl)sql basetypes
  PTABTSNU constant ptbty := (PTABTS_0 + 14); -- seq of sql number
  PTABTSRW constant ptbty := (PTABTS_0 + 15); -- seq of sql raw 
  PTABTSC2 constant ptbty := (PTABTS_0 + 18); -- seq of sql varchar2
  PTABTSDT constant ptbty := (PTABTS_0 + 19); -- seq of sql date
  PTABTSBI constant ptbty := (PTABTS_0 + 20); -- seq of (pl)sql
                                                          --  binary_integer
  PTABTSBO constant ptbty := (PTABTS_0 + 21); -- seq of (pl)sql
                                                          -- boolean

  ----------------------------------------------------------------------------
  -- Miscellaneous functions.
  ----------------------------------------------------------------------------
  function ptkin(obj ptnod) return ptnty;

        -- returns number of attributes for given node type
  function ptattcnt(node_enum ptnty) return ub2;

        -- returns attr-type enumerator for nth attr of given node type
  function ptatttyp(node_enum ptnty, nth ub2) return ptaty;

        -- returns text name of given node type
  function ptattnnm(node_enum ptnty) return varchar2;

        -- returns text name of given attr type
  function ptattanm(attr_enum ptaty) return varchar2;

        -- returns base-type enumerator for type of given attribute
  function ptattbty(node_enum ptnty, attr_enum ptaty) return ptbty;

        -- "ref type" returns PART, PART_REF, or REF
  function ptattrty(node_enum ptnty, attr_enum ptaty) return ptrty;

  ----------------------------------------------------------------------------
  -- Primitive IDL access methods.  See DEFS$:PT.H.
  -- 
  -- There is a "get" (ptg%) and a "put" (ptp%) for each IDL base type 
  --     tx: text*
  --     nd: ptnod
  --     u4: ub4
  --     u2: ub2
  --     u1: ub1
  --     s4: sb4
  --     s2: sb2
  --     ls: ptlis*             -- not persistent
  --     pt: ptr_t              -- not persistent
  --     dt: sql date
  --     nu: sql number
  --     ch: sql varchar2
  --     vc: sql varchar
  --     c2: sql varchar2
  --     bi: plsql binary integer
  --     bo: plsql boolean
  --
  -- The ptgs% calls get sequences of the above types, for example,
  -- ptgsnd() fetches a handle to a sequence of nodes from an attribute
  -- of type "sequence of <NODE or CLASS>".
  ----------------------------------------------------------------------------
  function ptg_tx(obj ptnod, aty ptaty) return varchar2;
  function ptg_nd(obj ptnod, aty ptaty) return ptnod;
  function ptg_u4(obj ptnod, aty ptaty) return ub4;
  function ptg_u2(obj ptnod, aty ptaty) return ub2;
  function ptg_u1(obj ptnod, aty ptaty) return ub1;
  function ptg_s4(obj ptnod, aty ptaty) return sb4;
  function ptg_s2(obj ptnod, aty ptaty) return sb2;
  function ptg_pt(obj ptnod, aty ptaty) return ptr_t;

  function ptgsnd(obj ptnod, aty ptaty) return ptseqnd;
  function ptslen(seq ptseqnd) return ub2; -- get length of sequence

  procedure ptp_tx(obj ptnod, val varchar2,   aty ptaty);
  procedure ptp_nd(obj ptnod, val ptnod,  aty ptaty);
  procedure ptp_u4(obj ptnod, val ub4,    aty ptaty);
  procedure ptp_u2(obj ptnod, val ub2,    aty ptaty);
  procedure ptp_u1(obj ptnod, val ub1,    aty ptaty);
  procedure ptp_s4(obj ptnod, val sb4,    aty ptaty);
  procedure ptp_s2(obj ptnod, val sb2,    aty ptaty);
  procedure ptp_pt(obj ptnod, val ptr_t,  aty ptaty);

--  procedure ptpsnd(obj ptnod, val ptseqnd, aty ptaty);

  ----------------------------------------------------------------------------
  -- Sequence element-indexing functions.
  ----------------------------------------------------------------------------
  function ptgetx(obj ptseqtx, ndx ub2) return varchar2;
  function ptgend(obj ptseqnd, ndx ub2) return ptnod;
  function ptgeu4(obj ptsequ4, ndx ub2) return ub4;
  function ptgeu2(obj ptsequ2, ndx ub2) return ub2;
  function ptgeu1(obj ptsequ1, ndx ub2) return ub1;
  function ptges4(obj ptseqs4, ndx ub2) return sb4;
  function ptges2(obj ptseqs2, ndx ub2) return sb2;
  function ptgept(obj ptseqpt, ndx ub2) return ptr_t;

-- NYI
--  procedure ptpetx(obj ptseqtx, ndx ub2, val varchar2);
--  procedure ptpend(obj ptseqnd, ndx ub2, val ptnod);
--  procedure ptpeu4(obj ptsequ4, ndx ub2, val ub4);
--  procedure ptpeu2(obj ptsequ2, ndx ub2, val ub2);
--  procedure ptpeu1(obj ptsequ1, ndx ub2, val ub1);
--  procedure ptpes4(obj ptseqs4, ndx ub2, val sb4);
--  procedure ptpes2(obj ptseqs2, ndx ub2, val sb2);

end pidl;

/
create or replace package body sys.PIDL is


  function pig_tx(obj ptnod, aty ptaty) return varchar2;
    pragma interface(c,pig_tx);
  function pig_nd(obj ptnod, aty ptaty) return ptnod;
    pragma interface(c,pig_nd);
  function pig_u4(obj ptnod, aty ptaty) return ub4;
    pragma interface(c,pig_u4);
  function pig_u2(obj ptnod, aty ptaty) return ub2;
    pragma interface(c,pig_u2);
  function pig_u1(obj ptnod, aty ptaty) return ub1;
    pragma interface(c,pig_u1);
  function pig_s4(obj ptnod, aty ptaty) return sb4;
    pragma interface(c,pig_s4);
  function pig_s2(obj ptnod, aty ptaty) return sb2;
    pragma interface(c,pig_s2);
  function pig_pt(obj ptnod, aty ptaty) return private_ptr_t;
    pragma interface(c,pig_pt);
  function pigsnd(obj ptnod, aty ptaty) return ptseqnd;
    pragma interface(c,pigsnd);

  procedure pip_tx(obj ptnod, val varchar2,   aty ptaty);
    pragma interface(c,pip_tx);
  procedure pip_nd(obj ptnod, val ptnod, aty ptaty);
    pragma interface(c,pip_nd);
  procedure pip_u4(obj ptnod, val ub4,    aty ptaty);
    pragma interface(c,pip_u4);
  procedure pip_u2(obj ptnod, val ub2,    aty ptaty);
    pragma interface(c,pip_u2);
  procedure pip_u1(obj ptnod, val ub1,    aty ptaty);
    pragma interface(c,pip_u1);
  procedure pip_s4(obj ptnod, val sb4,    aty ptaty);
    pragma interface(c,pip_s4);
  procedure pip_s2(obj ptnod, val sb2,    aty ptaty);
    pragma interface(c,pip_s2);
  procedure pip_pt(obj ptnod, val private_ptr_t,  aty ptaty);
    pragma interface(c,pip_pt);
--  procedure pipsnd(obj ptnod, val ptseqnd, aty ptaty);
--    pragma interface(c,pipsnd);

  -- pigeXX : Get sequence element.
  function pigetx(obj ptseqtx, ndx ub2) return varchar2;
    pragma interface(c,pigetx);
  function pigend(obj ptseqnd, ndx ub2) return ptnod;
    pragma interface(c,pigend);
  function pigeu4(obj ptsequ4, ndx ub2) return ub4;
    pragma interface(c,pigeu4);
  function pigeu2(obj ptsequ2, ndx ub2) return ub2;
    pragma interface(c,pigeu2);
  function pigeu1(obj ptsequ1, ndx ub2) return ub1;
    pragma interface(c,pigeu1);
  function piges4(obj ptseqs4, ndx ub2) return sb4;
    pragma interface(c,piges4);
  function piges2(obj ptseqs2, ndx ub2) return sb2;
    pragma interface(c,piges2);
  function pigept(obj ptseqpt, ndx ub2) return private_ptr_t;
    pragma interface(c,pigept);

  -- pipeXX : Put sequence element.
  -- Following put sequence element funcs not yet implemented;
--  procedure pipetx(obj ptseqtx, ndx ub2, val varchar2);
--    pragma interface(c,pipetx);
--  procedure pipend(obj ptseqnd, ndx ub2, val ptnod);
--    pragma interface(c,pipend);
--  procedure pipeu4(obj ptsequ4, ndx ub2, val ub4);
--    pragma interface(c,pipeu4);
--  procedure pipeu2(obj ptsequ2, ndx ub2, val ub2);
--    pragma interface(c,pipeu2);
--  procedure pipeu1(obj ptsequ1, ndx ub2, val ub1);
--    pragma interface(c,pipeu1);
--  procedure pipes4(obj ptseqs4, ndx ub2, val sb4);
--    pragma interface(c,pipes4);
--  procedure pipes2(obj ptseqs2, ndx ub2, val sb2);
--    pragma interface(c,pipes2);
--  procedure pipept(obj ptseqpt, ndx ub2, val private_ptr_t);
--    pragma interface(c,pipept);

  -- misc
  function pidkin(obj ptnod) return ptnty;
    pragma interface(c,pidkin);
  function pidacn(node_enum ptnty) return ub2;
    pragma interface(c,pidacn);
  function pidaty(node_enum ptnty, nth ub2) return ptaty;
    pragma interface(c,pidaty);
  function pidnnm(node_enum ptnty) return varchar2;
    pragma interface(c,pidnnm);
  function pidanm(attr_enum ptaty) return varchar2;
    pragma interface(c,pidanm);
  function pidbty(node_enum ptnty, attr_enum ptaty) return ptbty;
    pragma interface(c,pidbty);
  function pidrty(node_enum ptnty, attr_enum ptaty) return ptrty;
    pragma interface(c,pidrty);
  function pigsln(seq ptseqnd) return ub2;
    pragma interface(c,pigsln);

  function ptkin(obj ptnod) return ptnty is
  begin
    return pidkin(obj);
  end;

  function ptattcnt(node_enum ptnty) return ub2 is
  begin
    return pidacn(node_enum);
  end;

  function ptatttyp(node_enum ptnty, nth ub2) return ptaty is
  begin
    return pidaty(node_enum, nth);
  end;

  function ptattnnm(node_enum ptnty) return varchar2 is
  begin
    return pidnnm(node_enum);
  end;

  function ptattanm(attr_enum ptaty) return varchar2 is
  begin
    return pidanm(attr_enum);
  end;

  function ptattbty(node_enum ptnty, attr_enum ptaty) return ptbty is
  begin
    return pidbty(node_enum, attr_enum);
  end;

  function ptattrty(node_enum ptnty, attr_enum ptaty) return ptrty is
  begin
    return pidrty(node_enum, attr_enum);
  end;

  function ptg_tx(obj ptnod, aty ptaty) return varchar2 is
  begin
    return pig_tx(obj,aty);
  end;

  function ptg_nd(obj ptnod, aty ptaty) 
    return ptnod is
  begin
    return pig_nd(obj,aty);
  end;

  function ptg_u4(obj ptnod, aty ptaty) return ub4 is
  begin
    return pig_u4(obj,aty);
  end;

  function ptg_u2(obj ptnod, aty ptaty) return ub2 is
  begin
    return pig_u2(obj,aty);
  end;

  function ptg_u1(obj ptnod, aty ptaty) return ub1 is
  begin
    return pig_u1(obj,aty);
  end;

  function ptg_s4(obj ptnod, aty ptaty) return sb4 is
  begin
    return pig_s4(obj,aty);
  end;

  function ptg_s2(obj ptnod, aty ptaty) return sb2 is
  begin
    return pig_s2(obj,aty);
  end;

  function ptg_pt(obj ptnod, aty ptaty) return ptr_t is
    val ptr_t;
  begin
    val.private_ptr := pig_pt(obj, aty);
    return val;
  end;

  function ptgsnd(obj ptnod,
    aty ptaty) return ptseqnd is
  begin
    return pigsnd(obj,aty);
  end;

  function ptslen(seq ptseqnd) return ub2 is
  begin
    return pigsln(seq);
  end;
 

  procedure ptp_tx(obj ptnod, val varchar2,   
    aty ptaty) is
  begin
    pip_tx(obj,val,aty);
  end;

  procedure ptp_nd(obj ptnod, val ptnod, 
    aty ptaty) is
  begin
    pip_nd(obj,val,aty);
  end;

  procedure ptp_u4(obj ptnod, val ub4,    
    aty ptaty) is
  begin
    pip_u4(obj,val,aty);
  end;

  procedure ptp_u2(obj ptnod, val ub2,    
    aty ptaty) is
  begin
    pip_u2(obj,val,aty);
  end;

  procedure ptp_u1(obj ptnod, val ub1,    
    aty ptaty) is
  begin
    pip_u1(obj,val,aty);
  end;

  procedure ptp_s4(obj ptnod, val sb4,    
    aty ptaty) is
  begin
    pip_s4(obj,val,aty);
  end;

  procedure ptp_s2(obj ptnod, val sb2,    
    aty ptaty) is
  begin
    pip_s2(obj,val,aty);
  end;

  procedure ptp_pt(obj ptnod, val ptr_t,  
    aty ptaty) is
  begin
    pip_pt(obj, val.private_ptr, aty);
  end;

--  procedure ptpsnd(obj ptnod, val ptseqnd, 
--    aty ptaty) is
--  begin
--    pipsnd(obj,val,aty);
--  end;

  function ptgetx(obj ptseqtx, ndx ub2) return varchar2 is 
  begin
    return pigetx(obj,ndx);
  end;

  function ptgend(obj ptseqnd, ndx ub2) return ptnod is 
  begin
    return pigend(obj,ndx);
  end;

  function ptgeu4(obj ptsequ4, ndx ub2) return ub4 is 
  begin
    return pigeu4(obj,ndx);
  end;

  function ptgeu2(obj ptsequ2, ndx ub2) return ub2 is 
  begin
    return pigeu2(obj,ndx);
  end;

  function ptgeu1(obj ptsequ1, ndx ub2) return ub1 is 
  begin
    return pigeu1(obj,ndx);
  end;

  function ptges4(obj ptseqs4, ndx ub2) return sb4 is 
  begin
    return piges4(obj,ndx);
  end;

  function ptges2(obj ptseqs2, ndx ub2) return sb2 is 
  begin
    return piges2(obj,ndx);
  end;

  function ptgept(obj ptseqpt, ndx ub2) return ptr_t is 
    val ptr_t;
  begin
    val.private_ptr := pigept(obj, ndx);
    return val;
  end;

--  procedure ptpetx(obj ptseqtx, ndx ub2, val varchar2) is
--  begin
--    pipetx(obj,ndx,val);
--  end;

--  procedure ptpend(obj ptseqnd, ndx ub2, val ptnod) is
--  begin
--    pipend(obj,ndx,val);
--  end;

--  procedure ptpeu4(obj ptsequ4, ndx ub2, val ub4) is
--  begin
--    pipeu4(obj,ndx,val);
--  end;

--  procedure ptpeu2(obj ptsequ2, ndx ub2, val ub2) is
--  begin
--    pipeu2(obj,ndx,val);
--  end;

--  procedure ptpeu1(obj ptsequ1, ndx ub2, val ub1) is
--  begin
--    pipeu1(obj,ndx,val);
--  end;

--  procedure ptpes4(obj ptseqs4, ndx ub2, val sb4) is
--  begin
--    pipes4(obj,ndx,val);
--  end;

--  procedure ptpes2(obj ptseqs2, ndx ub2, val sb2) is
--  begin
--    pipes2(obj,ndx,val);
--  end;

--  procedure ptpept(obj ptseqpt, ndx ub2, val ptr_t) is
--  begin
--    pipept(obj, ndx, val.private_ptr);
--  end;

end pidl;
/
