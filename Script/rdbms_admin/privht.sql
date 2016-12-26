Rem Copyright (c) 1994, 2006, Oracle. All rights reserved.  
Rem
Rem   NAME
Rem     ht.sql - Hyper Text packages
Rem   PURPOSE
Rem     Provide utility functions for producing HTML documents
Rem     from pl/sql.
Rem   NOTES
Rem
Rem     Two sets of packages - one is all functions/constants (htf)
Rem                          - one is all procedures (htp)
Rem
Rem     A PL/SQL table of varchar2 is used to buffer output.
Rem       htp.print() buffers the output.
Rem       owa.get_page() fetches it out using htp.get_page().
Rem
Rem     This script should be run by the owner of the OWA packages.
Rem
Rem   HISTORY
Rem     pkapasi    10/18/06 -  Enhancement#5610575: Allow get_page to start over
Rem     akatti     08/10/06 -  Fix bug# 5409563 - REQUEST_CHARSET is obtained in the proc
Rem     mmuppago   10/03/05 -  Fix bug#4608020: suppress content-length if dad charset <> db charset 
Rem     pkapasi    11/27/03 -  Fix bug#3284896 - showpage truncates output
Rem     pkapasi    06/20/03 -  Fix bug#1301623 : handle https in function base 
Rem     pkapasi    05/09/03 -  Add more charsets (bug#2944980)
Rem     pkapasi    04/21/03 -  Fix bug#2915488 (incorrect Oracle charset)
Rem     vshimizu   12/23/02 -  Perf fixes (2694343, 2698205)
Rem     pkapasi    10/07/02 -  Perf issue with mod_plsql<902 (bug#2609772)
Rem     pkapasi    07/25/02 -  Perf fixes (2460224, 2470207, 2482024, 2483760)
Rem     ehlee      06/10/02 -  Fix bug# 2305168
Rem     ihonda     06/10/02 -  Fix bug# 2093593
Rem     ehlee      10/29/01 -  Fix bug# 2060664
Rem     ehlee      10/17/01 -  Fix bug# 2050633
Rem     pkapasi    09/17/01 -  Workaround any_cs bug#1994862
Rem     skwong     09/04/01 -  Performance fix for raw mode
Rem     ehlee      08/16/01 -  Fix date printing problem with htp.p
Rem     skwong     07/20/01 -  Added support for NCHAR
Rem     skwong     07/20/01 -  Added support for RAW content transfers
Rem     pkapasi    06/12/01 -  Merge OAS specific helper functions
Rem     pkapasi    01/11/01 -  Fix bug#1580414
Rem     ehlee      08/25/00 -  Fix showpage miscalculation
Rem     rdecker    07/17/00 -  USE PACKAGE vars FOR quot,amp,lt,gt
Rem     rdecker    07/13/00 -  USE chr(38) IN place OF '&' FOR sqlplus
Rem     ehlee      05/10/00 -  Add check for Gateway version 2
Rem     ehlee      05/05/00 -  Call owa_cache.init in init procedure
Rem     ehlee      01/14/00 -  Add default charset support
Rem     rdasarat   01/12/99 -  Fix 791217
Rem     rdasarat   12/31/98 -  Fix 788285
Rem     rdasarat   11/19/98 -  Add addDefaultHTMLHdr procedure
Rem     rdasarat   10/26/98 -  Fix 735061
Rem     rdasarat   06/02/98 -  Fix for Content-length
Rem     rdasarat   04/02/98 -  Add file upload/download functionality
Rem     rdasarat   02/03/98 -  Optimize prn, add get_line, get_page...
Rem     rdasarat   01/14/98 -  Optimize prn
Rem     mpal       01/06/98 -  Fix bug# 607288 - Correct typo in CTARGET
Rem     mpal       12/23/97 -  Fix bug# 563953 - Correct typo in STYLE
Rem     rdasarat   11/13/97 -  Add init procedure
Rem     rdasarat   10/20/97 -  Optimize htp.print and htp.prn
Rem     mpal       04/23/97 -  Fix bug# #482019 - added escape_url for '%'
Rem     mpal       01/29/97 -  Fix bug# #444697 - Restore pragma references
Rem                            for anchor, anchor2, mail
Rem     mpal       11/15/96 -  Adding formFile procedure
Rem     mpal       11/12/96 -  Adding NLS char conversion 
Rem     mpal       08/22/96 -  HTML 3.2 support
Rem     mpal       08/19/96 -  Fix bug #393305
Rem     mpal       06/24/96 -  Adding escape sequence support '%'    
Rem     mbookman   03/11/96 -  Adding NLS fixes (substrB and lengthB)
Rem     kireland   02/02/96 -  HTML 3.0, Netscape and Microsoft extensions
Rem     mbookman   07/26/95 -  Added mailto support
Rem     mbookman   05/23/95 -  Full HTML 2.0 support
Rem                            Numerous function/procedure name
Rem                            changes for standardization
Rem     mloennro   09/05/94 -  Creation
Rem
  
REM Creating HTF package body...
create or replace package body htf as
  
/* This function is private to the HTF package */
function IFNOTNULL(str1 in varchar2 character set any_cs, 
                   str2 in varchar2 character set any_cs) 
                   return varchar2 character set str2%charset
is
begin
   if (str1 is NULL)
     then return (NULL);
     else return (str2);
   end if;
end;

/* STRUCTURE tags */
function bodyOpen(cbackground in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
    l_str varchar2(32767);
begin 
    l_str := '<BODY';
    if cbackground is not null then
        l_str := l_str||' BACKGROUND="'||cbackground||'"';
    end if;
    if cattributes is not null then
        l_str := l_str||' '||cattributes;
    end if;
    l_str := l_str||'>';
    return l_str;
end;
/* END STRUCTURE tags */

/* HEAD Related elements tags */
function title  (ctitle in varchar2 character set any_cs) return varchar2 character set ctitle%charset is
begin return ('<TITLE>'||ctitle||'</TITLE>'); end;

function htitle(ctitle      in varchar2 character set any_cs,
                nsize       in integer  DEFAULT 1,
                calign      in varchar2 DEFAULT NULL,
                cnowrap     in varchar2 DEFAULT NULL,
                cclear      in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) 
                return varchar2 character set ctitle%charset is
begin return (title(ctitle)||
              header(nsize,ctitle,calign,cnowrap,cclear,cattributes)); end;

function base(ctarget   in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) return varchar2 is
   protocol varchar2(2000);
begin
   protocol := owa_util.get_cgi_env ('REQUEST_PROTOCOL');
   if (protocol is null) then
      protocol := 'http';
   else
      protocol := lower (protocol);
   end if;

   return('<BASE'||
       IFNOTNULL(ctarget,' TARGET="'||ctarget||'"')||
            IFNOTNULL(cattributes,' '||cattributes)||
       ' HREF="' || protocol || '://'||
                 owa_util.get_cgi_env('SERVER_NAME')||':'||
                 owa_util.get_cgi_env('SERVER_PORT')||
                 owa_util.get_cgi_env('SCRIPT_NAME')||
                 owa_util.get_cgi_env('PATH_INFO')||'">');
end;

function isindex(cprompt in varchar2 character set any_cs DEFAULT NULL,
                 curl    in varchar2 DEFAULT NULL) 
                 return varchar2 character set cprompt%charset is
begin return('<ISINDEX'||
              IFNOTNULL(cprompt,' PROMPT="'||cprompt||'"')||
              IFNOTNULL(curl,' HREF="'||curl||'"')||
             '>'); end;

function linkRel(crel   in varchar2, 
                 curl   in varchar2, 
                 ctitle in varchar2 character set any_cs DEFAULT NULL)
                 return varchar2 character set ctitle%charset is
begin return('<LINK REL="'||crel||'"'||
                  ' HREF="'||curl||'"'||
               IFNOTNULL(ctitle,' TITLE="'||ctitle||'"')||
             '>'); end;

function linkRev(crev   in varchar2, 
                 curl   in varchar2, 
                 ctitle in varchar2 character set any_cs DEFAULT NULL)
                 return varchar2 character set ctitle%charset is
begin return('<LINK REV="'||crev||'"'||
                  ' HREF="'||curl||'"'||
               IFNOTNULL(ctitle,' TITLE="'||ctitle||'"')||
             '>'); end;

function meta(chttp_equiv in varchar2,
              cname       in varchar2,
              ccontent    in varchar2) return varchar2 is
begin return('<META HTTP-EQUIV="'||chttp_equiv||
                       '" NAME="'||cname||
                    '" CONTENT="'||ccontent||
                    '">');
end;

function nextid(cidentifier in varchar2) return varchar2 is
begin return ('<NEXTID N="'||cidentifier||'>'); end;

function style(cstyle in varchar2 character set any_cs) 
              return varchar2 character set cstyle%charset is
begin return ('<STYLE>'||cstyle||'</STYLE>'); end;

function script(cscript in varchar2,
                clanguage in varchar2 DEFAULT NULL) return varchar2 is
begin return('<SCRIPT'||
       IFNOTNULL(clanguage,' LANGUAGE='''||clanguage||'''')||
       '>'||cscript||
       '</SCRIPT>');
end;

/* END HEAD Related elements tags */

/* BODY ELEMENT tags */
function hr  (cclear      in varchar2 DEFAULT NULL,
              csrc        in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<HR'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(csrc,' SRC="'||csrc||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function line(cclear      in varchar2 DEFAULT NULL,
              csrc        in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return(hr(cclear, csrc, cattributes)); end;

function br(cclear      in varchar2 DEFAULT NULL,
            cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<BR'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function nl(cclear      in varchar2 DEFAULT NULL,
            cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return(br(cclear, cattributes)); end;

function header(nsize   in integer,
                cheader in varchar2 character set any_cs,
                calign  in varchar2 DEFAULT NULL,
                cnowrap in varchar2 DEFAULT NULL,
                cclear  in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) 
                return varchar2 character set cheader%charset is
    ch varchar2(2);
begin
    ch := 'H'||to_char(least(abs(nsize),6));
    return('<'||ch||
                IFNOTNULL(calign,' ALIGN="'||calign||'"')||
                IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
                IFNOTNULL(cnowrap,' NOWRAP')||
                IFNOTNULL(cattributes,' '||cattributes)||
               '>'||cheader||
               '</'||ch||'>');
end;

function anchor(curl        in varchar2,
                ctext       in varchar2 character set any_cs,
                cname       in varchar2 character set any_cs DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) 
                return varchar2 character set ctext%charset is
begin return(anchor2(curl,
          ctext,
          cname,
          NULL,
          cattributes));
          end;

function anchor2(curl       in varchar2,
                ctext       in varchar2 character set any_cs,
                cname       in varchar2 character set any_cs DEFAULT NULL,
                ctarget     in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) 
                return varchar2 character set ctext%charset is
    curl_cname_null EXCEPTION;
    l_str varchar2(32767);
begin 
    if curl is NULL and cname is NULL then
        l_str := '<!-- ERROR in anchor2 usage, curl and cname cannot be NULL --><A NAME=" "';
        if ctext is not null then
            l_str := l_str||'> '||ctext||' </A';
        end if;
        l_str := l_str||'>';
        return l_str;
    end if;

    if curl is NULL then
        l_str := '<A NAME="'||cname||'"';
        if ctext is not null then
            l_str := l_str||'> '||ctext||' </A';
        end if;
        l_str := l_str||'>';
    else
        l_str := '<A HREF="'||curl||'"';
        if cname is not null then
            l_str := l_str||' NAME="'||cname||'"';
        end if;
        if ctarget is not null then
            l_str := l_str||' TARGET="'||ctarget||'"';
        end if;
        if cattributes is not null then
            l_str := l_str||' '||cattributes;
        end if;
        l_str := l_str||'>'||ctext||'</A>';
    end if;
    return l_str;
end;


function mailto(caddress in varchar2,
                ctext    in varchar2 character set any_cs,
                cname       in varchar2 character set any_cs DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) 
                return varchar2 character set ctext%charset is
begin return (anchor('mailto:'||caddress,ctext,cname,cattributes)); end;

function img(curl        in varchar2,
             calign      in varchar2 DEFAULT NULL,
             calt        in varchar2 DEFAULT NULL,
             cismap      in varchar2 DEFAULT NULL,
             cattributes in varchar2 DEFAULT NULL
             ) return varchar2 is
    l_str varchar2(32767);
begin 
    l_str := '<IMG SRC="'||curl||'"';
    if calign is not null then
        l_str := l_str||' ALIGN="'||calign||'"';
    end if;
    if calt is not null then
        l_str := l_str||' ALT="'||calt||'"';
    end if;
    if cismap is not null then 
        l_str := l_str||' ISMAP';
    end if;
    if cattributes is not null then
        l_str := l_str||' '||cattributes;
    end if;
    l_str := l_str||'>'; 
    return l_str;
end;

function img2(curl        in varchar2,
             calign      in varchar2 DEFAULT NULL,
             calt        in varchar2 DEFAULT NULL,
             cismap      in varchar2 DEFAULT NULL,
             cusemap     in varchar2 DEFAULT NULL,
             cattributes in varchar2 DEFAULT NULL
             ) return varchar2 is
begin return('<IMG SRC="'||curl||'"'||
               IFNOTNULL(calign,' ALIGN="'||calign||'"')||
               IFNOTNULL(calt,' ALT="'||calt||'"')||
               IFNOTNULL(cismap,' ISMAP')||
               IFNOTNULL(cusemap,' USEMAP="'||cusemap||'"')||
               IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;


function area(    ccoords    in varchar2,
                 cshape    in varchar2 DEFAULT NULL,
                 chref    in varchar2 DEFAULT NULL,
                 cnohref    in varchar2 DEFAULT NULL,
        ctarget in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<AREA'||
        IFNOTNULL(cshape,' SHAPE="'||cshape||'"')||
        ' COORDS="'||ccoords||'"'||
                IFNOTNULL(chref,' HREF="'||chref||'"')||
                IFNOTNULL(cnohref,' NOHREF')||
                IFNOTNULL(ctarget,' TARGET="'||ctarget||'"')||
        IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function mapOpen(cname    in varchar2,cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<MAP NAME="'||cname||'"'||
        IFNOTNULL(cattributes,' '||cattributes)||
        '>'); end;

function bgsound(csrc    in varchar2,
         cloop    in varchar2 DEFAULT NULL,
         cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<BGSOUND SRC="'||csrc||'"'||
        IFNOTNULL(cloop,' LOOP="'||cloop||'"')||
        IFNOTNULL(cattributes,' '||cattributes)||
        '>');end;


function paragraph(calign       in varchar2 DEFAULT NULL,
                   cnowrap      in varchar2 DEFAULT NULL,
                   cclear       in varchar2 DEFAULT NULL,
                   cattributes  in varchar2 DEFAULT NULL) return varchar2 is
begin return('<P'||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cnowrap,' NOWRAP')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function div(    calign       in varchar2 DEFAULT NULL,
                   cattributes  in varchar2 DEFAULT NULL) return varchar2 is
begin return('<DIV'||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function address(cvalue       in varchar2 character set any_cs,
                 cnowrap      in varchar2 DEFAULT NULL,
                 cclear       in varchar2 DEFAULT NULL,
                 cattributes  in varchar2 DEFAULT NULL)
                 return varchar2 character set cvalue%charset is
begin return('<ADDRESS'||
               IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
               IFNOTNULL(cnowrap,' NOWRAP')||
               IFNOTNULL(cattributes,' '||cattributes)||
             '>'||cvalue||
             '</ADDRESS>'); end;

function comment(ctext in varchar2 character set any_cs) 
                 return varchar2 character set ctext%charset is
begin return('<!-- '||ctext||' -->'); end;

function preOpen(cclear      in varchar2 DEFAULT NULL,
                 cwidth      in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<PRE'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cwidth,' WIDTH="'||cwidth||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function nobr(ctext in varchar2 character set any_cs) 
              return varchar2 character set ctext%charset is
begin return('<NOBR>'||ctext||'</NOBR>'); end;

function center(ctext in varchar2 character set any_cs) 
                return varchar2 character set ctext%charset is
begin return('<CENTER>'||ctext||'</CENTER>'); end;


function blockquoteOpen(cnowrap      in varchar2 DEFAULT NULL,
                        cclear       in varchar2 DEFAULT NULL,
                        cattributes  in varchar2 DEFAULT NULL) return varchar2
 is
begin return('<BLOCKQUOTE'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cnowrap,' NOWRAP')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

/* LIST tags */
function listHeader(ctext in varchar2 character set any_cs,
                    cattributes in varchar2 DEFAULT NULL) 
                    return varchar2 character set ctext%charset is
begin return('<LH'||
              IFNOTNULL(cattributes,' '||cattributes)||
            '>'||ctext||
            '</LH>'); end;

function listItem(ctext       in varchar2 character set any_cs DEFAULT NULL,
                  cclear      in varchar2 DEFAULT NULL,
                  cdingbat    in varchar2 DEFAULT NULL,
                  csrc        in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) 
                  return varchar2 character set ctext%charset is
begin return('<LI'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cdingbat,' DINGBAT="'||cdingbat||'"')||
              IFNOTNULL(csrc,' SRC="'||csrc||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext);
end;

function ulistOpen(cclear      in varchar2 DEFAULT NULL,
                   cwrap       in varchar2 DEFAULT NULL,
                   cdingbat    in varchar2 DEFAULT NULL,
                   csrc        in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<UL'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cwrap,' WRAP="'||cwrap||'"')||
              IFNOTNULL(cdingbat,' DINGBAT="'||cdingbat||'"')||
              IFNOTNULL(csrc,' SRC="'||csrc||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function olistOpen(cclear      in varchar2 DEFAULT NULL,
                   cwrap       in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<OL'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cwrap,' WRAP="'||cwrap||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function dlistOpen(cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<DL'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function dlistTerm(ctext       in varchar2 character set any_cs DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) 
                   return varchar2 character set ctext%charset is
begin return('<DT'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext);
end;

function dlistDef(ctext       in varchar2 character set any_cs DEFAULT NULL,
                  cclear      in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) 
                  return varchar2 character set ctext%charset is
begin return('<DD'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext);
end;
/* END LIST tags */

/* SEMANTIC FORMAT ELEMENTS */
function dfn(ctext in varchar2 character set any_cs,
              cattributes in varchar2 DEFAULT NULL) 
              return varchar2 character set ctext%charset is
begin return('<DFN'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</DFN>'); end;

function cite(ctext in varchar2 character set any_cs,
               cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<CITE'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</CITE>'); end;

function code(ctext in varchar2 character set any_cs,
              cattributes in varchar2 DEFAULT NULL) return varchar2  character set ctext%charset is
begin return('<CODE'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</CODE>'); end;

function em   (ctext  in varchar2 character set any_cs,
               cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<EM'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</EM>'); end;

function emphasis(ctext in varchar2 character set any_cs,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return(em(ctext,cattributes)); end;

function kbd(ctext in varchar2 character set any_cs,
             cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<KBD'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</KBD>'); end;

function keyboard(ctext in varchar2 character set any_cs,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return(kbd(ctext,cattributes)); end;

function sample(ctext in varchar2 character set any_cs,
                cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<SAMP'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</SAMP>'); end;

function strong   (ctext  in varchar2 character set any_cs,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<STRONG'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</STRONG>'); end;

function variable(ctext in varchar2 character set any_cs,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<VAR'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</VAR>'); end;

function big(    ctext          in varchar2 character set any_cs,
                cattributes     in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<BIG'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</BIG>'); end;

function small(    ctext          in varchar2 character set any_cs,
                cattributes     in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<SMALL'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</SMALL>'); end;

function sub(     ctext          in varchar2 character set any_cs,
        calign        in varchar2 DEFAULT NULL,
                cattributes     in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<SUB'||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</SUB>'); end;

function sup(    ctext          in varchar2 character set any_cs,
        calign        in varchar2 DEFAULT NULL,
                cattributes     in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<SUP'||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</SUP>'); end;

/* END SEMANTIC FORMAT ELEMENTS */

/* PHYSICAL FORMAT ELEMENTS */
function basefont(nsize in integer,
          cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<BASEFONT SIZE="'||nsize||'"'||
        IFNOTNULL(cattributes,' '||cattributes)||
        '>'); end;


function fontOpen(    ccolor    in varchar2 DEFAULT NULL,
        cface    in varchar2 DEFAULT NULL,
        csize    in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL) return varchar2 is
    l_str varchar2(32767);
begin 
    l_str := '<FONT';
    if ccolor is not null then
        l_str := l_str||' COLOR="'||ccolor||'"';
    end if;
    if cface is not null then
        l_str := l_str||' FACE="'||cface||'"';
    end if;
    if csize is not null then
        l_str := l_str||' SIZE="'||csize||'"';
    end if;
    if cattributes is not null then
        l_str := l_str||' '||cattributes;
    end if;
    l_str := l_str||'>';
    return l_str;
end;

function bold   (ctext  in varchar2 character set any_cs,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<B'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</B>'); end;

function italic (ctext  in varchar2 character set any_cs,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<I'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</I>'); end;

function teletype(ctext in varchar2 character set any_cs,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<TT'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</TT>'); end;

function plaintext   (ctext  in varchar2 character set any_cs,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<PLAINTEXT'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</PLAINTEXT>'); end;
function s   (ctext  in varchar2 character set any_cs,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<S'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</S>'); end;
function strike   (ctext  in varchar2 character set any_cs,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<STRIKE'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</STRIKE>'); end;
function underline   (ctext  in varchar2 character set any_cs,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset is
begin return('<U'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</U>'); end;
/* END PHYSICAL FORMAT ELEMENTS */


/* HTML FORMS */

function formOpen(curl in varchar2,
                  cmethod  in varchar2 DEFAULT 'POST',
          ctarget  in varchar2 DEFAULT NULL,
          cenctype in varchar2 DEFAULT NULL,
          cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<FORM ACTION="'||curl||'" METHOD="'||cmethod||'"'||
        IFNOTNULL(ctarget,' TARGET="'||ctarget||'"')||
        IFNOTNULL(cenctype,' ENCTYPE="'||cenctype||'"')||
        IFNOTNULL(cattributes,' '||cattributes)||
        '>'); end;

function formCheckbox(cname in varchar2,
                      cvalue      in varchar2 character set any_cs DEFAULT 'on',
                      cchecked    in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) 
                      return varchar2 character set cvalue%charset is
begin 
   return('<INPUT TYPE="checkbox" NAME="'||cname||'"'||
           IFNOTNULL(cvalue,' VALUE="'||cvalue||'"')||
           IFNOTNULL(cchecked,' CHECKED')||
           IFNOTNULL(cattributes,' '||cattributes)||
          '>');
end;

function formFile(cname       in varchar2,
                  caccept     in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<INPUT TYPE="file"'||
              IFNOTNULL(cname,' NAME="'||cname||'"')||
              IFNOTNULL(caccept,' ACCEPT="'||caccept||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function formHidden(cname       in varchar2,
                    cvalue      in varchar2 character set any_cs DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) return varchar2 character set cvalue%charset is
begin 
   return('<INPUT TYPE="hidden" NAME="'||cname||'"'||' VALUE="'||cvalue||'"'||
           IFNOTNULL(cattributes,' '||cattributes)||
          '>'); 
end;

function formImage(cname       in varchar2,
                   csrc        in varchar2,
                   calign      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<INPUT TYPE="image" NAME="'||cname||'"'||
                                 ' SRC="'||csrc||'"'||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end; 

function formPassword(cname       in varchar2,
                      csize       in varchar2 DEFAULT NULL,
                      cmaxlength  in varchar2 DEFAULT NULL,
                      cvalue      in varchar2 character set any_cs DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) 
                      return varchar2 character set cvalue%charset is
begin
   return('<INPUT TYPE="password" NAME="'||cname||'"'||
           IFNOTNULL(csize,' SIZE="'||csize||'"')||
           IFNOTNULL(cmaxlength,' MAXLENGTH="'||cmaxlength||'"')||
           IFNOTNULL(cvalue,' VALUE="'||cvalue||'"')||
           IFNOTNULL(cattributes,' '||cattributes)||
          '>'); 
end;

function formRadio(cname       in varchar2,
                   cvalue      in varchar2 character set any_cs,
                   cchecked    in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) 
                   return varchar2 character set cvalue%charset is
begin return('<INPUT TYPE="radio" NAME="'||cname||'"'||
                               ' VALUE="'||cvalue||'"'||
              IFNOTNULL(cchecked,' CHECKED')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function formReset(cvalue      in varchar2 character set any_cs DEFAULT 'Reset',
                   cattributes in varchar2 DEFAULT NULL) 
                   return varchar2 character set cvalue%charset is
begin return('<INPUT TYPE="reset" VALUE="'||cvalue||'"'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function formSubmit(cname       in varchar2 DEFAULT NULL,
                    cvalue      in varchar2 character set any_cs DEFAULT 'Submit',
                    cattributes in varchar2 DEFAULT NULL) return varchar2 character set cvalue%charset is
begin return('<INPUT TYPE="submit"'||
              IFNOTNULL(cname,' NAME="'||cname||'"')||
              IFNOTNULL(cvalue,' VALUE="'||cvalue||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function formText(cname       in varchar2,
                  csize       in varchar2 DEFAULT NULL,
                  cmaxlength  in varchar2 DEFAULT NULL,
                  cvalue      in varchar2 character set any_cs DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) return varchar2  character set cvalue%charset is
begin
   return('<INPUT TYPE="text" NAME="'||cname||'"'||
           IFNOTNULL(csize,' SIZE="'||csize||'"')||
           IFNOTNULL(cmaxlength,' MAXLENGTH="'||cmaxlength||'"')||
           IFNOTNULL(cvalue,' VALUE="'||cvalue||'"')||
           IFNOTNULL(cattributes,' '||cattributes)||
          '>'); 
end;

function formSelectOpen(cname       in varchar2,
                        cprompt     in varchar2 character set any_cs DEFAULT NULL,
                        nsize       in integer  DEFAULT NULL,
                        cattributes in varchar2 DEFAULT NULL) 
                        return varchar2 character set cprompt%charset is
begin return(cprompt||
            '<SELECT NAME="'||cname||'"'||
             IFNOTNULL(nsize,' SIZE="'||nsize||'"')||
             IFNOTNULL(cattributes,' '||cattributes)||
            '>');
end;

function formSelectOption(cvalue      in varchar2 character set any_cs,
                          cselected   in varchar2 DEFAULT NULL,
                          cattributes in varchar2) return varchar2 character set cvalue%charset is 
begin return('<OPTION'||
              IFNOTNULL(cselected,' SELECTED')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||cvalue); end;

function formTextarea(cname       in varchar2,
                      nrows       in integer,
                      ncolumns    in integer,
                      calign      in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<TEXTAREA NAME="'||cname||'"'||
                      ' ROWS='||to_char(nrows)||
                      ' COLS='||to_char(ncolumns)||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '></TEXTAREA>');
end;


function formTextarea2(cname       in varchar2,
                      nrows       in integer,
                      ncolumns    in integer,
                      calign      in varchar2 DEFAULT NULL,
                      cwrap       in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<TEXTAREA NAME="'||cname||'"'||
                      ' ROWS='||to_char(nrows)||
                      ' COLS='||to_char(ncolumns)||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cwrap,' WRAP="'||cwrap||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '></TEXTAREA>');
end;

function formTextareaOpen(cname       in varchar2,
                          nrows       in integer,
                          ncolumns    in integer,
                          calign      in varchar2 DEFAULT NULL,
                          cattributes in varchar2 DEFAULT NULL) return varchar2
 is
begin return('<TEXTAREA NAME="'||cname||'"'||
                      ' ROWS='||to_char(nrows)||
                      ' COLS='||to_char(ncolumns)||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;


function formTextareaOpen2(cname       in varchar2,
                          nrows       in integer,
                          ncolumns    in integer,
                          calign      in varchar2 DEFAULT NULL,
                          cwrap       in varchar2 DEFAULT NULL,
                          cattributes in varchar2 DEFAULT NULL) return varchar2
 is
begin return('<TEXTAREA NAME="'||cname||'"'||
                      ' ROWS='||to_char(nrows)||
                      ' COLS='||to_char(ncolumns)||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cwrap,' WRAP="'||cwrap||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;
/* END HTML FORMS */

/* HTML TABLES */
function tableOpen(cborder     in varchar2 DEFAULT NULL,
                   calign      in varchar2 DEFAULT NULL,
                   cnowrap     in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
    l_str varchar2(32767);
begin 
    l_str := '<TABLE ';
    if cborder is not null then
        l_str := l_str||' '||cborder;
    end if;
    if cnowrap is not null then
        l_str := l_str||' NOWRAP';
    end if;
    if calign is not null then
        l_str := l_str||' ALIGN="'||calign||'"';
    end if;
    if cclear is not null then
        l_str := l_str||' CLEAR="'||cclear||'"';
    end if;
    if cattributes is not null then
        l_str := l_str||' '||cattributes;
    end if;
    l_str := l_str||'>';
    return l_str;
end;

function tableCaption(ccaption in varchar2 character set any_cs,
                      calign   in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) 
                      return varchar2 character set ccaption%charset is
begin return ('<CAPTION'||
               IFNOTNULL(calign,' ALIGN="'||calign||'"')||
               IFNOTNULL(cattributes,' '||cattributes)||
              '>'||
              ccaption||'</CAPTION>'); end;

function tableRowOpen(calign      in varchar2 DEFAULT NULL,
                      cvalign     in varchar2 DEFAULT NULL,
                      cdp         in varchar2 DEFAULT NULL,
                      cnowrap     in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 is
    l_str varchar2(32767);
begin 
    l_str := '<TR';
    if calign is not null then
        l_str := l_str||' ALIGN="'||calign||'"';
    end if;
    if cvalign is not null then
        l_str := l_str||' VALIGN="'||cvalign||'"';
    end if;
    if cdp is not null then
        l_str := l_str||' DP="'||cdp||'"';
    end if;
    if cnowrap is not null then
        l_str := l_str||' NOWRAP';
    end if;
    if cattributes is not null then
        l_str := l_str||' '||cattributes;
    end if;
    l_str := l_str||'>';
    return l_str;
end;

function tableHeader(cvalue      in varchar2 character set any_cs DEFAULT NULL,
                     calign      in varchar2 DEFAULT NULL,
                     cdp         in varchar2 DEFAULT NULL,
                     cnowrap     in varchar2 DEFAULT NULL,
                     crowspan    in varchar2 DEFAULT NULL,
                     ccolspan    in varchar2 DEFAULT NULL,
                     cattributes in varchar2 DEFAULT NULL) 
                     return varchar2 character set cvalue%charset is
begin return ('<TH'||
               IFNOTNULL(calign,' ALIGN="'||calign||'"')||
               IFNOTNULL(cdp,' DP="'||cdp||'"')||
               IFNOTNULL(crowspan,' ROWSPAN="'||crowspan||'"')||
               IFNOTNULL(ccolspan,' COLSPAN="'||ccolspan||'"')||
               IFNOTNULL(cnowrap,' NOWRAP')||
               IFNOTNULL(cattributes,' '||cattributes)||
              '>'||
              cvalue||'</TH>'); end;
 
function tableData(cvalue      in varchar2 character set any_cs DEFAULT NULL,
                   calign      in varchar2 DEFAULT NULL,
                   cdp         in varchar2 DEFAULT NULL,
                   cnowrap     in varchar2 DEFAULT NULL,
                   crowspan    in varchar2 DEFAULT NULL,
                   ccolspan    in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL)
                   return varchar2 character set cvalue%charset is
    l_str varchar2(32767);
begin 
    l_str := '<TD';
    if calign is not null then
        l_str := l_str||' ALIGN="'||calign||'"';
    end if;
    if cdp is not null then
        l_str := l_str||' DP="'||cdp||'"';
    end if;
    if crowspan is not null then
        l_str := l_str||' ROWSPAN="'||crowspan||'"';
    end if;
    if ccolspan is not null then
        l_str := l_str||' COLSPAN="'||ccolspan||'"';
    end if;
    if cnowrap is not null then
        l_str := l_str||' NOWRAP';
    end if;
    if cattributes is not null then 
        l_str := l_str||' '||cattributes;
    end if;
    l_str := l_str||'>'||cvalue||'</TD>'; 
    return l_str;
end;

function format_cell( columnValue in varchar2 character set any_cs, 
                      format_numbers in varchar2 default null) 
                      return varchar2 character set columnvalue%charset is
   dummy    number;
   function tochar(d in number, f in varchar2) return varchar2 is
   begin
      return nvl(ltrim(to_char(d,f)), '(null)');
   end tochar;
begin
   if (format_numbers is NULL) then
      return(tableData(columnValue));
   end if;

   dummy := to_number(columnValue);
   if (trunc(dummy) = dummy) then
      return(tableData(tochar(dummy,'999,999,999,999'), 'right'));
   else
      return(tableData(tochar(dummy,'999,999,990.99'), 'right'));
   end if;
   exception
   when others then
       return(tableData(nvl(columnValue, '(null)')));
end format_cell;
/* END HTML TABLES */

/* BEGIN HTML FRAMES - Netscape Extensions FRAMESET, FRAME tags */
function framesetOpen(crows in varchar2 DEFAULT NULL,/* row height value list */
            ccols    in varchar2 DEFAULT NULL,
cattributes in varchar2 DEFAULT NULL) return varchar2 is /* column width list */
begin  
 return('<FRAMESET'||
    IFNOTNULL(crows, ' ROWS="'||crows||'"')||
    IFNOTNULL(ccols, ' COLS="'||ccols||'"')||
    IFNOTNULL(cattributes,' '||cattributes)||
    '>'); 
end framesetOpen;


function frame(        csrc    in varchar2,                /* URL */
            cname    in varchar2 DEFAULT NULL,        /* Window name */
            cmarginwidth     in varchar2 DEFAULT NULL,    /* value in pixels */
            cmarginheight    in varchar2 DEFAULT NULL,    /* value in pixels */
            cscrolling    in varchar2 DEFAULT NULL,    /* yes | no | auto */
            cnoresize    in varchar2 DEFAULT NULL,
            cattributes    in varchar2 DEFAULT NULL) return varchar2 is    /* user cannot resize frame */
begin 
 return('<FRAME SRC="'||csrc||'"'||
    IFNOTNULL(cname, ' NAME="'||cname||'"')||
    IFNOTNULL(cmarginwidth, ' MARGINWIDTH="'||cmarginwidth||'"')||
    IFNOTNULL(cmarginheight, ' MARGINHEIGHT="'||cmarginheight||'"')||
    IFNOTNULL(cscrolling, ' SCROLLING="'||cscrolling||'"')||
    IFNOTNULL(cnoresize, ' NORESIZE')||
    IFNOTNULL(cattributes,' '||cattributes)||
    '>');
end frame;


/* END HTML FRAMES */

/* SPECIAL HTML TAGS */
function appletOpen(ccode     in varchar2,
            cwidth    in integer,
            cheight    in integer,
            cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<APPLET CODE='||ccode||
        ' WIDTH='||cwidth||
        ' HEIGHT='||cheight||
        IFNOTNULL(cattributes,' '||cattributes)||
        '>');
end;

function param(cname    in varchar2,
           cvalue    in varchar2 character set any_cs) 
               return varchar2 character set cvalue%charset is
begin return('<PARAM NAME='||cname||' VALUE= "'||cvalue||
        '" >'); 
end;

/* END SPECIAL HTML TAGS */

/* SPECIAL FUNCTIONS */
function escape_sc(ctext in varchar2 character set any_cs) 
         return varchar2 character set ctext%charset is 
begin return(replace(
             replace(
             replace(
             replace(ctext, '&', '&' || 'amp;'),
                            '"', '&' || 'quot;'),
                            '<', '&' || 'lt;'),
                            '>', '&' || 'gt;'));
end;

function escape_url(p_url in varchar2 character set any_cs) 
                    return varchar2 character set p_url%charset is
begin
        return replace(escape_sc(p_url), '%', '%25');
end;
/* END SPECIAL FUNCTIONS */

/* END BODY ELEMENT tags */
end;
/
show errors package body htf

REM Creating HTP package body...
create or replace package body htp as
 
   db_charset constant varchar2(30) :=
                         substr(userenv('LANGUAGE'),
                                instr(userenv('LANGUAGE'),'.')+1);
   req_charset         varchar2(30) := null;
/*
**    Add these globals to cache the character set information 
**    used in setHTTPCharset(). The character set IDs are used
**    for comparison to determine if conversion is required.
*/
   db_charset_ID  pls_integer := 0;
   nc_charset varchar2(30);
   nc_charset_ID  pls_integer := 0;
   ht_charset varchar2(30) := db_charset;
   ht_charset_ID  pls_integer := db_charset_ID;
   last_iana_charset varchar(40) := null;
   got_ht_charset boolean := FALSE;

   NL_CHAR   constant varchar2(10) := owa_cx.nl_char;
   NLNL_CHAR constant varchar2(10) := NL_CHAR||NL_CHAR;

   htcurline  varchar2(256) := ''; -- htbuf_arr element size
   htbuf      htbuf_arr; 
   rows_in    pls_integer;
   rows_out   pls_integer;
   --
   -- pack_after :
   -- Legacy constant used by OAS to denote the line after which htbuf rows
   -- should be packed. This constant was being used to avoid packing multiple
   -- HTTP header lines in the same row. We now optimize such that we start
   -- packing as soon as we see the end of headers. 
   -- Refer to bug#2609772 for more details on packing related issues
   --
   pack_after number := 60;

   htraws     htraw_arr;
   RAW_MAX    constant pls_integer := 256;
   bRawMode   boolean := false;
   contentLen pls_integer := 0; 

   sContentType        constant varchar2(16) := 'CONTENT-TYPE:';
   sContentLength      constant varchar2(16) := 'CONTENT-LENGTH:';
   sLocation           constant varchar2(16) := 'LOCATION:';
   sStatus             constant varchar2(16) := 'STATUS:';
   sSetCookie          constant varchar2(16) := 'SET-COOKIE:';
   sTextHtml           constant varchar2(16) := 'text/html';

   nContentTypeLen     constant number := length(sContentType);
   nContentLengthLen   constant number := length(sContentLength);
   nLocationLen        constant number := length(sLocation);
   nStatusLen          constant number := length(sStatus);
   nSetCookieLen       constant number := length(sSetCookie);

   bAddDefaultHTMLHdr  boolean := TRUE;
   bHTMLPageReady      boolean := FALSE;
   bHasContentLength   boolean := FALSE;
   nEndOfHdrIx         pls_integer := -1;
   nContentLengthIx    binary_integer := -1;

   sDownloadFilesList     varchar2(256); -- for file download feature
   nCompressDownloadFiles binary_integer;

   bFirstCall          boolean := TRUE;
   nGatewayVersion     pls_integer := 0;       /* Unknown gateway */

   -- Forward declaration of local procedure
   procedure prn_raw(cbuf in varchar2 character set any_cs);

/* STRUCTURE tags */
procedure htmlOpen is
begin p(htf.htmlOpen); end;

procedure htmlClose is
begin p(htf.htmlClose); end;

procedure headOpen is
begin p(htf.headOpen); end;

procedure headClose is
begin p(htf.headClose); end;

procedure bodyOpen(cbackground in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.bodyOpen(cbackground,cattributes)); end;

procedure bodyClose is
begin p(htf.bodyClose); end;
/* END STRUCTURE tags */

/* HEAD Related elements tags */
procedure title  (ctitle in varchar2 character set any_cs) is
begin p(htf.title(ctitle)); end;

procedure htitle(ctitle      in varchar2 character set any_cs,
                 nsize       in integer  DEFAULT 1,
                 calign      in varchar2 DEFAULT NULL,
                 cnowrap     in varchar2 DEFAULT NULL,
                 cclear      in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.htitle(ctitle,nsize,calign,cnowrap,cclear,cattributes)); end;

procedure base(    ctarget     in varchar2 DEFAULT NULL,
        cattributes    in varchar2 DEFAULT NULL) is
begin p(htf.base(ctarget,cattributes)); end;

procedure isindex(cprompt in varchar2 character set any_cs DEFAULT NULL,
                  curl    in varchar2  DEFAULT NULL) is
begin p(htf.isindex(cprompt, curl)); end;

procedure linkRel(crel   in varchar2,
                  curl   in varchar2, 
                  ctitle in varchar2 character set any_cs DEFAULT NULL) is
begin p(htf.linkRel(crel, curl, ctitle)); end;

procedure linkRev(crev   in varchar2,
                  curl   in varchar2, 
                  ctitle in varchar2 character set any_cs DEFAULT NULL) is
begin p(htf.linkRev(crev, curl, ctitle)); end;

procedure meta(chttp_equiv in varchar2,
               cname       in varchar2,
               ccontent    in varchar2) is 
begin p(htf.meta(chttp_equiv, cname, ccontent)); end;

procedure nextid(cidentifier in varchar2) is 
begin p(htf.nextid(cidentifier)); end;

procedure style(cstyle in varchar2 character set any_cs) is
begin p(htf.style(cstyle)); end;

procedure script(cscript     in varchar2,
                 clanguage   in varchar2 DEFAULT NULL) is
begin p(htf.script(cscript, clanguage)); end;

/* END HEAD Related elements tags */

/* BODY ELEMENT tags */
procedure hr  (cclear      in varchar2 DEFAULT NULL,
               csrc        in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.hr(cclear, csrc, cattributes)); end;

procedure line(cclear      in varchar2 DEFAULT NULL,
               csrc        in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL) is 
begin htp.hr(cclear, csrc, cattributes); end;

procedure nl  (cclear      in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.nl(cclear,cattributes)); end;

procedure br  (cclear      in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL) is 
begin htp.nl(cclear,cattributes); end;

procedure header(nsize   in integer,
                 cheader in varchar2 character set any_cs,
                 calign  in varchar2 DEFAULT NULL,
                 cnowrap in varchar2 DEFAULT NULL,
                 cclear  in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.header(nsize,cheader,calign,cnowrap,cclear,cattributes)); end;

procedure anchor(curl        in varchar2,
                 ctext       in varchar2 character set any_cs,
                 cname       in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.anchor(curl,ctext,cname,cattributes)); end;

procedure anchor2(curl       in varchar2,
                 ctext       in varchar2 character set any_cs,
                 cname       in varchar2 DEFAULT NULL,
                 ctarget     in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.anchor2(curl,ctext,cname,ctarget,cattributes)); end;

procedure mailto(caddress    in varchar2,
                 ctext       in varchar2 character set any_cs,
                 cname       in varchar2 character set any_cs DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.mailto(caddress,ctext,cname,cattributes)); end;

procedure img(curl        in varchar2,
              calign      in varchar2 DEFAULT NULL,
              calt        in varchar2 DEFAULT NULL,
              cismap      in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) is
begin p(htf.img(curl,calign,calt,cismap,cattributes)); end;

procedure img2(curl       in varchar2,
              calign      in varchar2 DEFAULT NULL,
              calt        in varchar2 DEFAULT NULL,
              cismap      in varchar2 DEFAULT NULL,
              cusemap     in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) is
begin p(htf.img2(curl,calign,calt,cismap,cusemap,cattributes)); end;

procedure area(    ccoords  in varchar2,
                  cshape    in varchar2 DEFAULT NULL,
                  chref     in varchar2 DEFAULT NULL,
                 cnohref    in varchar2 DEFAULT NULL,
        ctarget in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL) is
begin p(htf.area(ccoords,cshape,chref,cnohref,ctarget,cattributes));end;

procedure mapOpen(cname    in varchar2,cattributes in varchar2 DEFAULT NULL) is
begin p(htf.mapOpen(cname,cattributes)); end;
procedure mapClose is
begin p(htf.mapClose); end;

procedure bgsound(csrc    in varchar2,
          cloop    in varchar2 DEFAULT NULL,
          cattributes in varchar2 DEFAULT NULL) is
begin p(htf.bgsound(csrc,cloop,cattributes));end;

procedure para is
begin p(htf.para); end;

procedure paragraph(calign       in varchar2 DEFAULT NULL,
                    cnowrap      in varchar2 DEFAULT NULL,
                    cclear       in varchar2 DEFAULT NULL,
                    cattributes  in varchar2 DEFAULT NULL) is
begin p(htf.paragraph(calign,cnowrap,cclear,cattributes)); end;

procedure div(    calign       in varchar2 DEFAULT NULL,
                cattributes  in varchar2 DEFAULT NULL) is
begin p(htf.div(calign,cattributes)); end;

procedure address(cvalue       in varchar2 character set any_cs,
                  cnowrap      in varchar2 DEFAULT NULL,
                  cclear       in varchar2 DEFAULT NULL,
                  cattributes  in varchar2 DEFAULT NULL) is
begin p(htf.address(cvalue, cnowrap, cclear, cattributes)); end;

procedure comment(ctext in varchar2 character set any_cs) is
begin p(htf.comment(ctext)); end;

procedure preOpen(cclear      in varchar2 DEFAULT NULL,
                  cwidth      in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.preOpen(cclear,cwidth,cattributes)); end;

procedure preClose is
begin p(htf.preClose); end;

procedure listingOpen is
begin p(htf.listingOpen); end;
procedure listingClose is
begin p(htf.listingClose); end;

procedure nobr(ctext in varchar2 character set any_cs) is
begin p(htf.nobr(ctext)); end;
procedure wbr is
begin p(htf.wbr); end;

procedure center(ctext in varchar2 character set any_cs) is
begin p(htf.center(ctext)); end;

procedure centerOpen is
begin p(htf.centerOpen); end;

procedure centerClose is
begin p(htf.centerClose); end;



procedure blockquoteOpen(cnowrap      in varchar2 DEFAULT NULL,
                         cclear       in varchar2 DEFAULT NULL,
                         cattributes  in varchar2 DEFAULT NULL) is
begin p(htf.blockquoteOpen(cnowrap,cclear,cattributes)); end;

procedure blockquoteClose is
begin p(htf.blockquoteClose); end;

/* LIST tags */
procedure listHeader(ctext in varchar2 character set any_cs,
                     cattributes in varchar2 DEFAULT NULL) is
begin p(htf.listHeader(ctext,cattributes)); end;

procedure listItem(ctext       in varchar2 character set any_cs DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cdingbat    in varchar2 DEFAULT NULL,
                   csrc        in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.listItem(ctext,cclear,cdingbat,csrc,cattributes)); end;

procedure ulistOpen(cclear      in varchar2 DEFAULT NULL,
                    cwrap       in varchar2 DEFAULT NULL,
                    cdingbat    in varchar2 DEFAULT NULL,
                    csrc        in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.ulistOpen(cclear,cwrap,cdingbat,csrc,cattributes)); end;

procedure ulistClose is
begin p(htf.ulistClose); end;

procedure olistOpen(cclear      in varchar2 DEFAULT NULL,
                    cwrap       in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.olistOpen(cclear,cwrap,cattributes)); end;

procedure olistClose is
begin p(htf.olistClose); end;

procedure dlistOpen(cclear      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.dlistOpen(cclear,cattributes)); end;

procedure dlistTerm(ctext       in varchar2 character set any_cs DEFAULT NULL,
                    cclear      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.dlistTerm(ctext,cclear,cattributes)); end;

procedure dlistDef(ctext       in varchar2 character set any_cs DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is 
begin p(htf.dlistDef(ctext,cclear,cattributes)); end;

procedure dlistClose is
begin p(htf.dlistClose); end;

procedure menulistOpen is
begin p(htf.menulistOpen); end;

procedure menulistClose is
begin p(htf.menulistClose); end;

procedure dirlistOpen is
begin p(htf.dirlistOpen); end;

procedure dirlistClose is
begin p(htf.dirlistClose); end;
/* END LIST tags */

/* SEMANTIC FORMAT ELEMENTS */
procedure dfn(ctext in varchar2 character set any_cs,
               cattributes in varchar2 DEFAULT NULL) is
begin p(htf.dfn(ctext,cattributes)); end;

procedure cite(ctext in varchar2 character set any_cs,
               cattributes in varchar2 DEFAULT NULL) is
begin p(htf.cite(ctext,cattributes)); end;

procedure code(ctext in varchar2 character set any_cs,
               cattributes in varchar2 DEFAULT NULL) is
begin p(htf.code(ctext,cattributes)); end;

procedure em(ctext  in varchar2 character set any_cs,
             cattributes in varchar2 DEFAULT NULL) is
begin p(htf.em(ctext,cattributes)); end;

procedure emphasis(ctext in varchar2 character set any_cs,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.emphasis(ctext,cattributes)); end;

procedure kbd(ctext in varchar2 character set any_cs,
              cattributes in varchar2 DEFAULT NULL) is
begin p(htf.kbd(ctext,cattributes)); end;

procedure keyboard(ctext in varchar2 character set any_cs,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.keyboard(ctext,cattributes)); end;

procedure sample(ctext in varchar2 character set any_cs,
                 cattributes in varchar2 DEFAULT NULL) is
begin p(htf.sample(ctext,cattributes)); end;

procedure strong (ctext  in varchar2 character set any_cs,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.strong(ctext,cattributes)); end;

procedure variable(ctext in varchar2 character set any_cs,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.variable(ctext,cattributes)); end;

procedure big(    ctext          in varchar2 character set any_cs,
                  cattributes    in varchar2 DEFAULT NULL) is
begin p(htf.big(ctext,cattributes)); end;

procedure small(ctext          in varchar2 character set any_cs,
                cattributes     in varchar2 DEFAULT NULL) is
begin p(htf.small(ctext,cattributes)); end;

procedure sub(    ctext          in varchar2 character set any_cs,
                  calign         in varchar2 DEFAULT NULL,
                  cattributes    in varchar2 DEFAULT NULL) is
begin p(htf.sub(ctext,calign,cattributes)); end;

procedure sup(    ctext         in varchar2 character set any_cs,
                  calign        in varchar2 DEFAULT NULL,
                  cattributes   in varchar2 DEFAULT NULL) is
begin p(htf.sup(ctext,calign,cattributes)); end;


/* END SEMANTIC FORMAT ELEMENTS */

/* PHYSICAL FORMAT ELEMENTS */
procedure basefont(nsize in integer) is
begin p(htf.basefont(nsize));end;

procedure fontOpen(ccolor    in varchar2 DEFAULT NULL,
           cface    in varchar2 DEFAULT NULL,
           csize     in varchar2 DEFAULT NULL,
           cattributes    in varchar2 DEFAULT NULL) is
begin p(htf.fontOpen(ccolor,cface,csize,cattributes)); end;
    
procedure fontClose is
begin p(htf.fontClose); end;

procedure bold   (ctext  in varchar2 character set any_cs,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.bold(ctext,cattributes)); end;

procedure italic (ctext  in varchar2 character set any_cs,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.italic(ctext,cattributes)); end;

procedure teletype(ctext in varchar2 character set any_cs,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.teletype(ctext,cattributes)); end;

procedure plaintext(ctext  in varchar2 character set any_cs,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.plaintext(ctext,cattributes)); end;

procedure s(ctext  in varchar2 character set any_cs,
            cattributes in varchar2 DEFAULT NULL) is
begin p(htf.s(ctext,cattributes)); end;

procedure strike (ctext  in varchar2 character set any_cs,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.strike(ctext,cattributes)); end;

procedure underline (ctext  in varchar2 character set any_cs,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.underline(ctext,cattributes)); end;

/* END PHYSICAL FORMAT ELEMENTS */

/* HTML FORMS */

procedure formOpen(curl     in varchar2,
                   cmethod  in varchar2 DEFAULT 'POST',
           ctarget  in varchar2 DEFAULT NULL,
           cenctype in varchar2 DEFAULT NULL,
           cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formOpen(curl,cmethod,ctarget,cenctype,cattributes)); end;

procedure formCheckbox(cname       in varchar2,
                      cvalue      in varchar2 character set any_cs DEFAULT 'on',
                       cchecked    in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formCheckbox(cname,cvalue,cchecked,cattributes)); end;

procedure formFile(cname       in varchar2, 
                   caccept     in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formFile(cname,caccept,cattributes)); end;

procedure formHidden(cname       in varchar2,
                     cvalue      in varchar2 character set any_cs DEFAULT NULL,
                     cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formHidden(cname,cvalue,cattributes)); end;

procedure formImage(cname       in varchar2,
                    csrc        in varchar2,
                    calign      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formImage(cname,csrc,calign,cattributes)); end;

procedure formPassword(cname       in varchar2,
                       csize       in varchar2 DEFAULT NULL,
                       cmaxlength  in varchar2 DEFAULT NULL,
                       cvalue      in varchar2 character set any_cs DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formPassword(cname,csize,cmaxlength,cvalue,cattributes)); end;

procedure formRadio(cname       in varchar2,
                    cvalue      in varchar2 character set any_cs,
                    cchecked    in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formRadio(cname,cvalue,cchecked,cattributes)); end;

procedure formReset(cvalue     in varchar2 character set any_cs DEFAULT 'Reset',
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formReset(cvalue,cattributes)); end;

procedure formSubmit(cname       in varchar2 DEFAULT NULL,
                  cvalue      in varchar2 character set any_cs DEFAULT 'Submit',
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formSubmit(cname,cvalue,cattributes)); end;

procedure formText(cname       in varchar2,
                   csize       in varchar2 DEFAULT NULL,
                   cmaxlength  in varchar2 DEFAULT NULL,
                   cvalue      in varchar2 character set any_cs DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formText(cname,csize,cmaxlength,cvalue,cattributes)); end;

procedure formSelectOpen(cname       in varchar2,
                      cprompt     in varchar2 character set any_cs DEFAULT NULL,
                         nsize       in integer  DEFAULT NULL,
                         cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formSelectOpen(cname,cprompt,nsize,cattributes)); end;

procedure formSelectOption(cvalue      in varchar2 character set any_cs,
                           cselected   in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formSelectOption(cvalue,cselected,cattributes)); end;

procedure formSelectClose is
begin p(htf.formSelectClose); end;

procedure formTextarea(cname       in varchar2,
                       nrows       in integer,
                       ncolumns    in integer,
                       calign      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formTextarea(cname,nrows,ncolumns,calign,cattributes)); end;
 

procedure formTextarea2(cname       in varchar2,
                       nrows       in integer,
                       ncolumns    in integer,
                       calign      in varchar2 DEFAULT NULL,
                       cwrap       in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formTextarea2(cname,nrows,ncolumns,calign,cwrap,cattributes)); end;
 

procedure formTextareaOpen(cname       in varchar2,
                           nrows       in integer,
                           ncolumns    in integer,
                           calign      in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formTextareaOpen(cname,nrows,ncolumns,calign,cattributes)); end;
 

procedure formTextareaOpen2(cname       in varchar2,
                           nrows       in integer,
                           ncolumns    in integer,
                           calign      in varchar2 DEFAULT NULL,
                           cwrap       in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL) is
begin
   p(htf.formTextareaOpen2(cname,nrows,ncolumns,calign,cwrap,cattributes));
end;
 
procedure formTextareaClose is
begin p(htf.formTextareaClose); end;

procedure formClose is
begin p(htf.formClose); end;
/* END HTML FORMS */

/* HTML TABLES */
procedure tableOpen(cborder in varchar2 DEFAULT NULL,
                   calign in varchar2 DEFAULT NULL,
                   cnowrap in varchar2 DEFAULT NULL,
                   cclear in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.tableOpen(cborder,calign,cnowrap,cclear,cattributes)); end;

procedure tableCaption(ccaption    in varchar2 character set any_cs,
                       calign      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.tableCaption(ccaption,calign,cattributes)); end;

procedure tableRowOpen(calign      in varchar2 DEFAULT NULL,
                       cvalign     in varchar2 DEFAULT NULL,
                       cdp         in varchar2 DEFAULT NULL,
                       cnowrap     in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.tableRowOpen(calign,cvalign,cdp,cnowrap,cattributes)); end;

procedure tableHeader(cvalue      in varchar2 character set any_cs DEFAULT NULL,
                      calign      in varchar2 DEFAULT NULL,
                      cdp         in varchar2 DEFAULT NULL,
                      cnowrap     in varchar2 DEFAULT NULL,
                      crowspan    in varchar2 DEFAULT NULL,
                      ccolspan    in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) is
begin p(htf.tableHeader(cvalue,calign,cdp,cnowrap,
                        crowspan,ccolspan,cattributes)); end;

procedure tableData(cvalue      in varchar2 character set any_cs DEFAULT NULL,
                    calign      in varchar2 DEFAULT NULL,
                    cdp         in varchar2 DEFAULT NULL,
                    cnowrap     in varchar2 DEFAULT NULL,
                    crowspan    in varchar2 DEFAULT NULL,
                    ccolspan    in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.tableData(cvalue,calign,cdp,cnowrap,
                      crowspan,ccolspan,cattributes)); end;

procedure tableRowClose is
begin p(htf.tableRowClose); end;

procedure tableClose is
begin p(htf.tableClose); end;
/* END HTML TABLES */

/* BEGIN HTML FRAMES - Netscape Extensions FRAMESET, FRAME tags */
procedure framesetOpen(    crows    in varchar2 DEFAULT NULL,    /* row height value list */
            ccols    in varchar2 DEFAULT NULL,
            cattributes in varchar2 DEFAULT NULL) is    /* column width list */
begin 
 p(htf.framesetOpen( crows, ccols, cattributes )); 
end framesetOpen;

procedure framesetClose is
begin 
 p(htf.framesetClose); 
end framesetClose;

procedure frame(    csrc    in varchar2,                /* URL */
            cname    in varchar2 DEFAULT NULL,        /* Window Name */
            cmarginwidth     in varchar2 DEFAULT NULL,    /* Value in pixels */
            cmarginheight    in varchar2 DEFAULT NULL,    /* Value in pixels */
            cscrolling    in varchar2 DEFAULT NULL,    /* yes | no | auto */
            cnoresize    in varchar2 DEFAULT NULL,
            cattributes     in varchar2 DEFAULT NULL) is    /* Not resizable by user */
begin 
 p(htf.frame( csrc, cname, cmarginwidth, cmarginheight, cscrolling, cnoresize, cattributes )); 
end frame;

procedure noframesOpen is
begin 
 p(htf.noframesOpen); 
end noframesOpen;

procedure noframesClose is
begin 
 p(htf.noframesClose); 
end noframesClose;

/* END HTML FRAMES */

/* SPECIAL HTML TAGS */
procedure appletOpen(    ccode        in varchar2,
            cwidth        in integer,
            cheight        in integer,
            cattributes    in varchar2 DEFAULT NULL) is
begin p(htf.appletOpen(ccode,cwidth,cheight,cattributes));end;

procedure param(    cname        in varchar2,
            cvalue        in varchar2 character set any_cs) is
begin p(htf.param(cname,cvalue));end;

procedure appletClose is 
begin p(htf.appletClose);end;

/* END SPECIAL HTML TAGS */


/* SPECIAL PROCEDURES */

/* This procedure sets the value of CGI env var REQUEST_CHARSET in a global var */
procedure set_request_charset
is
begin
    if (req_charset is null)
    then
        req_charset := owa_util.get_cgi_env('REQUEST_CHARSET');
        if (req_charset is null)
        then
            -- set req_charset to match DB_CHARSET if not set
            req_charset := db_charset;
        end if;
        req_charset := UPPER(req_charset);
    end if;
end set_request_charset;

function getContentLength return number is
   len      pls_integer := 0;
   nFromIx  pls_integer;
begin
   -- Check to see if we have a BLOB download, and if so,
   -- return the length of the BLOB
   IF (wpg_docload.is_file_download)
   THEN
      RETURN wpg_docload.get_content_length;
   END IF;
   if (bRawMode) then
      return contentLen ;
   end if;

   nFromIx := nEndOfHdrIx + 1;
   for nIx in nFromIx..rows_in loop
     len := len + lengthb(htbuf(nIx)); -- use lengthb to get in bytes
   end loop;
   return(len);
end getContentLength;

/* Start of OAS specific helper procedure */
function getContentLength_cs_convert ( charset in varchar2) return number is
   len      binary_integer := 0;
   nFromIx  binary_integer;
begin
   nFromIx := nEndOfHdrIx + 1;
   for nIx in nFromIx..rows_in
   loop
      len := len + lengthb( convert (htbuf(nIx), charset));
   end loop;
   return(len);
end getContentLength_cs_convert;
/* End of OAS specific helper procedure */

procedure init is
begin
   htcurline := '';
   rows_in := 0;
   rows_out := 0;
   htbuf.delete;
   pack_after := 60;             /* see comments on 'pack_after' */

   bAddDefaultHTMLHdr := TRUE;
   bHTMLPageReady := FALSE;
   bHasContentLength := FALSE;
   nEndOfHdrIx := -1;
   nContentLengthIx := -1;

   sDownloadFilesList := '';
   nCompressDownloadFiles := 0;

   addDefaultHTMLHdr(TRUE);
   htraws.delete;

   bRawMode := false;
   contentLen := 0;
   got_ht_charset := FALSE;

   bFirstCall := TRUE;
   owa_cookie.init;
   nGatewayVersion := 0;
end init;

procedure flush_raw is
  len  pls_integer;
begin
   if (not bHTMLPageReady)
   then
      if (nEndOfHdrIx < 0) -- how come?
      then
         nEndOfHdrIx := rows_in;
      end if;
      if (nContentLengthIx > 0)
      then
         htbuf(nContentLengthIx) := 'Content-length: '
            || getContentLength || NL_CHAR;
      end if;
      bHTMLPageReady := TRUE;
   end if;
end flush_raw;
  
procedure flush is
begin
   set_request_charset;
   if (htcurline is not null)
   then
      rows_in := rows_in + 1;
      htbuf(rows_in) := htcurline;
      htcurline := '';
   end if;
   if (not bHTMLPageReady)
   then
      if (nEndOfHdrIx < 0) -- how come?
      then
         nEndOfHdrIx := rows_in;
      end if;
      if (nContentLengthIx > 0)
      then
         if (db_charset != req_charset)
         then 
            htbuf(nContentLengthIx) := 'X-DB-Content-length: ' || getContentLength || NL_CHAR;
         else 
            htbuf(nContentLengthIx) := 'Content-length: '
               || getContentLength || NL_CHAR;
         end if;
      end if;
      bHTMLPageReady := TRUE;
   end if;
end flush;

/* Start of OAS specific helper procedure */
procedure flush_charset_convert ( charset in varchar2)  is
begin
   if (htcurline is not null)
   then
      rows_in := rows_in + 1;
      htbuf(rows_in) := htcurline;
      htcurline := '';
   end if;
   if (not bHTMLPageReady)
   then
      if (nEndOfHdrIx < 0) -- how come?
      then
         nEndOfHdrIx := rows_in;
      end if;
      if (nContentLengthIx > 0)
      then
         htbuf(nContentLengthIx) := 'Content-length: '
            || getContentLength_cs_convert ( charset) || NL_CHAR;
      end if;
      bHTMLPageReady := TRUE;
   end if;
end flush_charset_convert;
/* End of OAS specific helper procedure */

function get_line (irows out integer) return varchar2 is
   cnt      number;
begin
   flush;

   cnt := rows_in - rows_out;

   if (cnt > 1)
   then
      irows := 1;
   else
      irows := 0;
      if (cnt < 1)
      then
         return(NULL);
      end if;
   end if;

   rows_out := rows_out + 1;
   return(htbuf(rows_out));
end;

procedure get_page (thepage     out NOCOPY htbuf_arr, 
                    irows    in out integer ) is 
  nrows       integer; 
  tmpbuf      varchar2(256); 
  num_headers pls_integer; 
  len         pls_integer;
begin 

   --
   -- Flush any remaining data from htcurline into htbuf and setup the
   -- content-length
   --
   flush; 
 
   if (db_charset != req_charset)
   then 
      irows := least(irows, rows_in - rows_out);
      if (irows = 0)
      then
	 return;
      end if;

      for i in 1..irows
      loop
	 thepage(i) := htbuf(rows_out + i);
      end loop;

      rows_out := rows_out + irows;
   else 
      --
      -- We can completely avoid packing response data in the following situations
      --
      -- 1. HTBUF_LEN was not reduced from its default value of 255 (single-byte
      --    database)
      --
      -- 2. the user supplied buffer is large enough to hold the response (we
      --    are aiming to achieve this by configuring the number of rows
      --    in the user's buffer
      --
      -- This optimization will avoid some string manipulation/concatenation
      -- operations and some lengthb calls as well
      --
      -- We should also avoid packing in situations where we are talking to the
      -- older gateway (iversion <= 2)
      --

      if ((HTBUF_LEN = 255) or (irows >= (rows_in - rows_out)) or
	  (nGatewayVersion <= 2)) then

	 -- Rows to fetch = min (size of user supplied buffer, rows_left)
	 irows := least(irows, rows_in - rows_out);
	 if (irows = 0)
	 then
	    return;
	 end if;

	 -- Transfer rows to user supplied buffer
	 for i in 1..irows
	 loop
	    thepage(i) := htbuf(rows_out + i);
	 end loop;

	 -- Update rows_out for next fetch
	 rows_out := rows_out + irows;

	 return;

      end if;

      --
      -- We need to start packing lines in htbuf so that there are minimal
      -- round trips from the client while making get_page calls
      --
      -- 1. We will not be packing response header lines due to dependencies
      --    in the PL/SQL Gateway to expect each header line to start in a
      --    new row
      --
      -- 2. Consecutive rows will be packed as long as the total size does
      --    not exceed the width of a buffer row in bytes. No attempts will be
      --    made to pack the row to the fullest.
      --
      -- 3. If a line is sufficiently packed (200 bytes), we will make no attempt
      --    to pack anything else in it. The flip side is that we will flush
      --    tmpbuf in such situations. So, some lines could end up with a
      --    lot lesser packing. 
      --

      nrows := 0; 
      tmpbuf := ''; 

      -- Do not pack header lines
      if (rows_out <= nEndOfHdrIx) then 
	 num_headers := least (irows, nEndOfHdrIx - rows_out); 
	 for i in 1..num_headers 
	 loop 
	    thepage(i) := htbuf(rows_out + i); 
	 end loop; 
	 rows_out := rows_out + num_headers; 
	 nrows := num_headers; 
      end if; 

      while (nrows < irows)
      loop 
	 if (rows_out = rows_in) then 
	    -- No more data in internal buffer, write last row and return
	    if (tmpbuf is null) then 
	       irows := nrows; 
	    else 
	       irows := nrows + 1; 
	       thepage(irows) := tmpbuf; 
	    end if; 
	    return; 
	 end if; 

	 rows_out := rows_out + 1; 

	 len := lengthb (htbuf(rows_out));
	 if (len >= 200) then 

	    --
	    -- Make no attempt to pack sufficiently packed lines
	    -- 1. Copy exisiting data in tmpbuf to a new row in the response
	    -- 2. Copy current data row to the next row in the response
	    --

	    -- Step 1
	    if (tmpbuf is not null) then 
	       nrows := nrows + 1; 
	       thepage(nrows) := tmpbuf; 
	       tmpbuf := ''; 
	       if (nrows = irows) then 
		  rows_out := rows_out - 1; 
		  return; 
	       end if; 
	    end if; 

	    -- Step 2
	    nrows := nrows + 1; 
	    thepage(nrows) := htbuf(rows_out); 

	 elsif ((len + lengthb(tmpbuf)) > 255) then 

	    --
	    -- Concatenation would result in buffer overflow
	    -- 1. Move tmpbuf to a new row
	    -- 2. Setup tmpbuf to the current input row
	    --

	    -- Step 1
	    nrows := nrows + 1; 
	    thepage(nrows) := tmpbuf; 
	    if (nrows = irows) then 
	      rows_out := rows_out - 1; 
	    else 
	      -- Step 2
	      tmpbuf := htbuf(rows_out); 
	    end if; 
	 else 

	    --
	    -- Pack lines into tmpbuf
	    -- It is more efficient to pack data in a scalar as opposed to
	    -- doing it directly in the array. This is an artifact of how
	    -- arrays are implemented using BTree and there is a cost of
	    -- log(n) for array access. But, using scalars will add extra
	    -- cost while updating the response row with contents of tmpbuf
	    --
	    tmpbuf := tmpbuf || htbuf(rows_out); 

	 end if; 
      end loop;
   end if;
end;

procedure get_page_raw (thepage     out NOCOPY htraw_arr,
                        irows    in out integer  ) is
  i       pls_integer;
  j       pls_integer;
  k       pls_integer;
  loc     pls_integer;
  len     pls_integer;
  tempraw raw(2000);
begin
   flush_raw;
   irows := least(irows, rows_in - rows_out);
   if (irows > 0) then
     J := rows_out;
     I := 0;
     while (I < irows) loop
       J := J + 1;
       if (J > nEndOfHdrIx) then
          -- If transferring raw data, just copy it
          i := i + 1;
          thepage(i) := htraws(J);
       elsif (ht_charset_ID = db_charset_ID) then
          -- if transferring headers with identical charsets, cast it
          i := i + 1;
          thepage(i) := UTL_RAW.CAST_TO_RAW(htbuf(J));
       else
          -- otherwise, need to charset-convert the buffer
          tempraw := UTL_RAW.CONVERT(UTL_RAW.CAST_TO_RAW(htbuf(J)),
                                     'AMERICAN_AMERICA.'||ht_charset,
                                     'AMERICAN_AMERICA.'||db_charset);
          len := UTL_RAW.LENGTH(tempraw);
          if (len <= RAW_MAX) then
            -- if the post-converted buffer will fit, then just copy it out
            i := i + 1;
            thepage(i) := tempraw;
          else
            -- otherwise, cut it into chunks and copy them up to irows max
            loc := 1;
            k := i;
            while (loc < len) loop
              k := k + 1;
              thepage(k) := UTL_RAW.SUBSTR(tempraw, loc, RAW_MAX);
              loc := loc + RAW_MAX;
              if (k = irows) then
                exit;
              end if;
            end loop;
            if (loc < len) then
              while (i < irows) loop
                i := i + 1;
                thepage(i) := null;
              end loop;
              J := J - 1;
              exit;
            else
              i := k;
            end if;
          end if;
       end if;
     end loop;
     rows_out := j;
   end if;
end;

/* Start of OAS specific helper procedure */
procedure get_page_charset_convert (thepage     out NOCOPY htbuf_arr,
                    irows    in out integer ,
                    charset  in     varchar2 ) is
begin
   flush_charset_convert ( charset);

   irows := least(irows, rows_in - rows_out);
   if (irows = 0)
   then
      return;
   end if;

   for i in 1..irows
   loop
      thepage(i) := htbuf(rows_out + i);
   end loop;

   rows_out := rows_out + irows;
end;
/* End of OAS specific helper procedure */


procedure showpage is
   dbms_buf_size integer;
   buffer   varchar2(510);    /* size = 255 * 2 */
   i        integer;
   sp_loc   integer;
   nl_loc   integer;
begin
   /* First figure out how large to make the dbms_output buffer */
   dbms_buf_size := (rows_in - rows_out)*255*2;
   if (dbms_buf_size > 1000000)
   then
      dbms_output.enable(1000000);
   else
      dbms_output.enable(dbms_buf_size);
   end if;
 
   /* Now, loop through, adding lines from htbuf, but   */
   /* never getting larger than 510 characters.         */
   /* If a newline is found, print everything and clear */
   /* the buffer, otherwise, break on the last space    */
   /* possible.  If the last space is past 255 chars,   */
   /* or there is no space at all, then break on 255.   */
   flush;

   buffer := NULL;
   i := rows_out + 1;

   while ((i <= rows_in) or (buffer is not null))
   loop

      /* Pick up the next row if it exists, and there is enough space */
      if ((i <= rows_in) and (nvl(length(buffer),0) <= 255))
      then
         buffer := buffer || htbuf(i);
         i := i + 1;
      end if;

      /* Search for the last newline character in the first 255 bytes */
      nl_loc := instr(substr(buffer,1,255), NL_CHAR, -1);
      if (nl_loc = 0)
      then
         /* Newline not found. Try searching for last space */
         sp_loc := instr(substr(buffer,1,255), ' ', -1);
         if (sp_loc = 0)
         then
            /* Space not found. Write out the first 255 bytes as-is */
            dbms_output.put_line(substr(buffer, 1, 255));

            /* Update buffer to contain remaining bytes */
            buffer := substr(buffer,256);
         else
            /* Space found. Write out bytes without the space */
            dbms_output.put_line(substr(buffer, 1, sp_loc - 1));

            /* Update buffer to contain remaining bytes */
            buffer := substr(buffer, sp_loc + 1);
         end if;
      else
         /* Always strip out the newlines */
         /* PUT_LINE will put them in.    */

         /* Newline found. Write out bytes without the newline */
         dbms_output.put_line(substr(buffer, 1, nl_loc - 1));

         /* Update buffer to contain remaining bytes */
         buffer := substr(buffer, nl_loc + 1);
      end if;
   end loop;

   rows_out := rows_in;
end;

procedure reset_get_page is
begin
   /* Enhancement#5610575 : allow get_page to start over */
   rows_out := 0;
end;

procedure download_file(sFileName in varchar2,
   bCompress in boolean default false) is
begin
   if (sDownloadFilesList is NULL)
   then
      sDownLoadFilesList := sFileName;
      if (bCompress)
      then
         nCompressDownloadFiles := 1;
      else
         nCompressDownloadFiles := 0;
      end if;
   end if;
end;

procedure get_download_files_list(sFilesList out varchar2,
   nCompress out binary_integer) is
begin
   sFilesList := sDownloadFilesList;
   nCompress := nCompressDownloadFiles;
end;

function isHTMLHdr(cbuf in varchar2 character set any_cs) return boolean is
   len number := length(cbuf);
begin
   return
      ((len >= nContentTypeLen
           and sContentType = substr(cbuf, 1, nContentTypeLen))
    or (len >= nContentLengthLen
           and sContentLength = substr(cbuf, 1, nContentLengthLen))
    or (len >= nLocationLen
           and sLocation = substr(cbuf, 1, nLocationLen))
    or (len >= nStatusLen
           and sStatus = substr(cbuf, 1, nStatusLen))
    or (len >= nSetCookieLen
           and sSetCookie = substr(cbuf, 1, nSetCookieLen))
      );
end isHTMLHdr;

procedure addDefaultHTMLHdr(bAddHTMLHdr boolean) is
begin
   bAddDefaultHTMLHdr := bAddHTMLHdr;
end addDefaultHTMLHdr;

/* Enable raw mode transfers */
procedure set_transfer_mode(tmode in varchar2) is
begin
  if (lower(tmode) = 'raw')
  then
    bRawMode := true;
  end if;
end set_transfer_mode;

procedure setHTTPCharset(iana_charset in varchar2, 
                         ora_charset varchar2 default NULL) is
  lower_cs varchar2(40);
begin

  if (iana_charset is null)
  then
    last_iana_charset := null; -- Invalidate the cache.
    ht_charset_ID := NLS_CHARSET_ID(db_charset); -- Get ID for fast comparison
    ht_charset := db_charset;
    got_ht_charset := TRUE;
    return;
  end if;

  lower_cs := lower(iana_charset);
  if (last_iana_charset is not null) and (lower_cs = last_iana_charset)
  then
     got_ht_charset := TRUE;
     return;
  end if;

  if (ora_charset is not null) then ht_charset := ora_charset;
  elsif (lower_cs = 'iso-8859-1') then
    if (db_charset = 'WE8MSWIN1252') 
    then ht_charset := db_charset;
    else ht_charset := 'WE8ISO8859P1'; 
    end if;
  elsif (lower_cs = 'utf-8') then
    if (db_charset = 'UTF8') 
    then ht_charset := db_charset;
    else  ht_charset := 'AL32UTF8';
    end if;
  elsif (lower_cs = 'windows-1252') then 
    if (db_charset = 'WE8ISO8859P1') 
    then ht_charset := db_charset;
    else ht_charset := 'WE8MSWIN1252';
    end if;
  elsif (lower_cs = 'us-ascii') then      ht_charset := 'US7ASCII';
  elsif (lower_cs = 'iso-8859-2') then
    if (db_charset = 'EE8MSWIN1250') 
    then ht_charset := db_charset;
    ht_charset := 'EE8ISO8859P2';
    end if;
  elsif (lower_cs = 'iso-8859-3') then ht_charset := 'SE8ISO8859P3';
  elsif (lower_cs = 'iso-8859-4') then
    if (db_charset = 'BLT8MSWIN1257')
    then ht_charset := db_charset;
    else ht_charset := 'NEE8ISO8859P4';
    end if;
  elsif (lower_cs = 'iso-8859-5') then 
    if (db_charset = 'CL8MSWIN1251')
    then ht_charset := db_charset;
    else   ht_charset := 'CL8ISO8859P5';
    end if;
  elsif (lower_cs = 'iso-8859-6') then
    if (db_charset = 'AR8MSWIN1256')
    then ht_charset := db_charset;
    else ht_charset := 'AR8ISO8859P6';
    end if;
  elsif (lower_cs = 'iso-8859-7') then 
    if (db_charset = 'EL8MSWIN1253')
    then ht_charset := db_charset;
    else ht_charset := 'EL8ISO8859P7';
    end if;
  elsif (lower_cs = 'iso-8859-8-i') then
    if (db_charset = 'IW8MSWIN1255')
    then ht_charset := db_charset;
    else ht_charset := 'IW8ISO8859P8';
    end if;
  elsif (lower_cs = 'iso-8859-9') then    ht_charset := 'WE9ISO8859P9';
  elsif (lower_cs = 'iso-8859-10') then   ht_charset := 'NE8ISO8859P10';
  elsif (lower_cs = 'shift_jis') then     ht_charset := 'JA16SJIS';
  elsif (lower_cs = 'gb2312') or (lower_cs = 'gbk') then        
    if (db_charset = 'ZHS16CGB231280')
    then ht_charset := db_charset;
    else ht_charset := 'ZHS16GBK';
    end if;
  elsif (lower_cs = 'big5') then          ht_charset := 'ZHT16BIG5';
  elsif (lower_cs = 'ks_c_5601-1987') or (lower_cs = 'euc-kr') then
    if (db_charset = 'KO16MSWIN949')
    then ht_charset := db_charset;
    else ht_charset := 'KO16KSC5601';
    end if;
  elsif (lower_cs = 'tis-620') then       ht_charset := 'TH8TISASCII';
  elsif (lower_cs = 'euc-jp') then        ht_charset := 'JA16EUC';
  elsif (lower_cs = 'windows-1256') then  ht_charset := 'AR8MSWIN1256';
  elsif (lower_cs = 'windows-1257') then  ht_charset := 'BLT8MSWIN1257';
  elsif (lower_cs = 'windows-1251') then  ht_charset := 'CL8MSWIN1251';
  elsif (lower_cs = 'windows-1250') then  ht_charset := 'EE8MSWIN1250';
  elsif (lower_cs = 'windows-1253') then  ht_charset := 'EL8MSWIN1253';
  elsif (lower_cs = 'windows-1255') then  ht_charset := 'IW8MSWIN1255';
  elsif (lower_cs = 'windows-1254') then  ht_charset := 'TR8MSWIN1254';
  elsif (lower_cs = 'windows-1258') then  ht_charset := 'VN8MSWIN1258';
  elsif (lower_cs = 'windows-921') then   ht_charset := 'LT8MSWIN921';
  elsif (lower_cs = 'windows-936') then   ht_charset := 'ZHS16GBK';
  elsif (lower_cs = 'windows-950') then   ht_charset := 'ZHT16MSWIN950';
  elsif (lower_cs = 'windows-949') then   ht_charset := 'KO16MSWIN949';
  elsif (lower_cs = 'koi8-r') then   ht_charset := 'CL8KOI8R';
  elsif (lower_cs = 'koi8-u') then   ht_charset := 'CL8KOI8U';
  else
    ht_charset := db_charset; -- unknown
  end if;
  last_iana_charset := lower_cs; -- cache it.
  ht_charset_ID := NLS_CHARSET_ID(ht_charset); -- Get ID for fast comparison 
  got_ht_charset := TRUE;
end setHTTPCharset;

procedure putraw(bbuf in raw, buflen pls_integer DEFAULT null) is
  blen pls_integer;
  bloc pls_integer;
  bcpy pls_integer;
begin
  if (bbuf is not null) then
    if (buflen is not null) then
       blen := buflen;
    else
       blen := UTL_RAW.LENGTH(bbuf);
    end if;
    -- Transfer the contents to the raw array
    -- Not to pack the buffer since packing a RAW buffer is slow.  
    contentLen := contentLen + blen;
    if (blen <= RAW_MAX) then
      rows_in := rows_in + 1;
      htraws(rows_in) := bbuf;
      htbuf(rows_in) := '';
      return;
    end if;
     
    bloc := 1;
    while (bloc <= blen) loop
      rows_in := rows_in + 1;
      bcpy := least((blen - bloc) + 1, RAW_MAX);
      htraws(rows_in) := UTL_RAW.SUBSTR(bbuf,bloc,bcpy);
      htbuf(rows_in) := '';
      bloc := bloc + bcpy;
    end loop;
  end if;
end putraw;

procedure per_request_init is
   cversion  varchar2(40);
begin
   if (nGatewayVersion = 0) then
      /* Get the gateway version and cache it for this request */
      cversion := owa_util.get_cgi_env ('GATEWAY_IVERSION');
      if (cversion is not null)
      then
         begin
            nGatewayVersion := to_number (cversion);

            -- Reserve space for owa_cache headers
            if ((nGatewayVersion >= 2) AND (rows_in = 0))
            then
               owa_cache.init(htbuf, rows_in);
            end if;
         exception
            when VALUE_ERROR then
               null;
         end;
      end if;
   end if;
end per_request_init;

procedure check_request_charset is
  nIx      pls_integer;
  nFromIx  pls_integer;
  loc      pls_integer;
  ccharset VARCHAR2(256);
  bbuf     varchar2(2000);
begin
  -- Scan for Content-Type and get character set to compare with DB
  for nIx in 1..nEndOfHdrIx loop
    if (nIx <> nContentLengthIx) then
      bbuf := htbuf(nIx);
      if (length(bbuf) > nContentTypeLen) and
         (upper(substr(bbuf, 1, nContentTypeLen)) = sContentType) then
        loc := instr(bbuf, 'charset=');
        if (loc > 0) then
          ccharset := substr(bbuf, loc + 8);
          loc := instr(ccharset, NL_CHAR);
          if (loc > 0) then
            ccharset := substr(ccharset, 1, loc - 1);
          end if;
          setHTTPCharset(ccharset);
        end if;
        exit;
      end if;
    end if;
  end loop;
  if (NOT got_ht_charset) then
    setHTTPCharset(null); -- force it to have some value
  end if;
end check_request_charset;

procedure prn (cbuf in varchar2 character set any_cs DEFAULT NULL) is
   loc          pls_integer;
   len          pls_integer;
   tlen         pls_integer;
   ccharset     varchar2(40);
   bHasHTMLHdr  boolean;
begin
   if (cbuf is NULL)
   then
      return;
   end if;

   if (bRawMode) then
       prn_raw(cbuf);
       return;
   end if;

   --
   -- We used to have a separate prn_char procedure for CHAR mode processing,
   -- analogous to prn_raw. We now embed the code directly in prn in order
   -- to avoid the extra fn call overhead. 
   --
   if (bFirstCall)
   then
      bFirstCall := FALSE;
      per_request_init;

      if (bAddDefaultHTMLHdr)
      then
         bHTMLPageReady := FALSE;
         bHasContentLength := FALSE;
         nEndOfHdrIx := -1;
         nContentLengthIx := -1;
         -- Check for HTML headers
         bHasHTMLHdr := isHTMLHdr(upper(cbuf));
         if (not bHasHTMLHdr)
         then
            -- add Content-type: text/html[; charset=<IANA_CHARSET_NAME> ]
            rows_in := rows_in + 1;
            ccharset := owa_util.get_cgi_env('REQUEST_IANA_CHARSET');
            if (ccharset is null) then
               htbuf(rows_in) := 'Content-type: ' || stexthtml || NL_CHAR;
            else
               htbuf(rows_in) := 'Content-type: ' || sTextHtml || '; charset='
                      || ccharset || NL_CHAR;
            end if;

            -- reserve space for Content-length: header
            rows_in := rows_in + 1;
            nContentLengthIx := rows_in;
            rows_in := rows_in + 1;
            htbuf(rows_in) := NL_CHAR;
            nEndOfHdrIx := rows_in;
            if (nGatewayVersion > 2) then
               pack_after := nEndOfHdrIx;
            end if;
            bHasContentLength := TRUE;
         end if;
      else
         bHTMLPageReady := TRUE;
      end if;
   end if;

   len := length(cbuf);
   if (not bHTMLPageReady)
   then
      -- We assume that 'pack_after' is sufficiently large that we won't be
      -- packing HTML headers.
      -- We also assume that end of headers request will be by itself
      if (nEndOfHdrIx < 0) -- we have not seen end of headers yet
      then
         if ((len >= nContentLengthLen) and
             (sContentLength = substr(upper(cbuf), 1, nContentLengthLen)))
         then
            bHasContentLength := TRUE;
         end if;
         if ((cbuf = NL_CHAR
                 and (rows_in > 0
                         and substr(htbuf(rows_in), length(htbuf(rows_in)), 1)
                                = NL_CHAR)
             ) or (instr(cbuf, NLNL_CHAR, -1) != 0))
         then -- we now have seen!
            if (not bHasContentLength)
            then
               -- reserve space for Content-length: header
               rows_in := rows_in + 1;
               nContentLengthIx := rows_in;
            end if;
            nEndOfHdrIx := (rows_in + 1);
            if (nGatewayVersion > 2) then
               pack_after := nEndOfHdrIx;
            end if;
            bHasContentLength := TRUE;
            --
            --    cbuf should be inserted into the header buffer here.
            --
            rows_in := rows_in + 1;
            htbuf(rows_in) := cbuf;
            return;
         end if;
      end if;
   end if;

   loc := 0;
   if (rows_in < pack_after) then
      while ((len - loc) >= HTBUF_LEN)
      loop
         rows_in := rows_in + 1;
         htbuf(rows_in) := substr(cbuf, loc + 1, HTBUF_LEN);
         loc := loc + HTBUF_LEN;
      end loop;
      if (loc < len)
      then
         rows_in := rows_in + 1;
         htbuf(rows_in) := substr(cbuf, loc + 1);
      end if;
      return;
   end if;

   if (htcurline is null)
   then
      tlen := HTBUF_LEN;
   else
      tlen := HTBUF_LEN - length(htcurline);
   end if;

   while (loc < len)
   loop
      if ((len - loc) <= tlen)
      then
         if (loc = 0)
         then
            htcurline := htcurline || cbuf;
         else
            htcurline := htcurline || substr(cbuf, loc + 1);
         end if;
         exit;
      end if;
      rows_in := rows_in + 1;
      htbuf(rows_in) := htcurline || substr(cbuf, loc + 1, tlen);
      htcurline := '';
      loc := loc + tlen;
      tlen := HTBUF_LEN; -- remaining buffer size
   end loop;
end prn;

procedure prn_raw(cbuf in varchar2 character set any_cs) is
   loc          pls_integer;
   len          pls_integer;
   tlen         pls_integer;
   ccharset     varchar2(40);
   bHasHTMLHdr  boolean; 
begin
   if (bFirstCall)
   then
      bFirstCall := FALSE;

      /*
      **   Get the NCHAR character set for later use by CONVERT.
      **    Unfortunately it's only available from a view, so we
      **    have to run SQL to get it.  Put it here rather than in
      **    init so that hopefully it only gets run once per
      **    database session.  
      */
      select VALUE into nc_charset from V$NLS_PARAMETERS
          where PARAMETER = 'NLS_NCHAR_CHARACTERSET';
      nc_charset_ID := NLS_CHARSET_ID (nc_charset);

      -- Initialize ID here when we are in RAW mode
      db_charset_ID := NLS_CHARSET_ID(db_charset);
      ht_charset_ID := db_charset_ID;

      per_request_init;

      if (bAddDefaultHTMLHdr)
      then
         bHTMLPageReady := FALSE;
         bHasContentLength := FALSE;
         nEndOfHdrIx := -1;
         nContentLengthIx := -1;
         -- Check for HTML headers
         bHasHTMLHdr := isHTMLHdr(upper(cbuf));
         if (not bHasHTMLHdr)
         then
            -- add Content-type: text/html[; charset=<IANA_CHARSET_NAME> ]
            rows_in := rows_in + 1;
            ccharset := owa_util.get_cgi_env('REQUEST_IANA_CHARSET');
            if (ccharset is null) then
               htbuf(rows_in) := 'Content-type: ' || stexthtml || NL_CHAR;
            else
               htbuf(rows_in) := 'Content-type: ' || sTextHtml || '; charset='
                                  || ccharset || NL_CHAR;
            end if;
            setHTTPCharset(ccharset, owa_util.get_cgi_env('REQUEST_CHARSET'));

            -- reserve space for Content-length: header
            rows_in := rows_in + 1;
            nContentLengthIx := rows_in;
            rows_in := rows_in + 1;
            htbuf(rows_in) := NL_CHAR;
            nEndOfHdrIx := rows_in;
            if (nGatewayVersion > 2) then
               pack_after := nEndOfHdrIx;
            end if;
            bHasContentLength := TRUE;
         end if;
      else
         bHTMLPageReady := TRUE;
      end if;
   end if;

   len := lengthb(cbuf);
   if (not bHTMLPageReady)
   then
      -- We assume that 'pack_after' is sufficiently large that we won't be
      -- packing HTML headers.
      -- We also assume that end of headers request will be by itself
      if (nEndOfHdrIx < 0) -- we have not seen end of headers yet
      then
         if ((len >= nContentLengthLen) and
             (sContentLength = substr(upper(cbuf), 1, nContentLengthLen)))
         then
            bHasContentLength := TRUE;
         end if;
         if ((cbuf = NL_CHAR
                 and (rows_in > 0
                         and substr(htbuf(rows_in), lengthb(htbuf(rows_in)), 1)
                                = NL_CHAR)
             ) or (instr(cbuf, NLNL_CHAR, -1) != 0))
         then -- we now have seen!
            if (not bHasContentLength)
            then
               -- reserve space for Content-length: header
               rows_in := rows_in + 1;
               nContentLengthIx := rows_in;
            end if;
            nEndOfHdrIx := rows_in + 1;
            if (nGatewayVersion > 2) then
               pack_after := nEndOfHdrIx;
            end if;
            bHasContentLength := TRUE;
            -- 
            --    cbuf should be inserted into the header buffer here.
            --
            rows_in := rows_in + 1;
            htbuf(rows_in) := cbuf; 
            return; 
         end if;
      else
         if (not got_ht_charset) then
            check_request_charset;
         end if;
      end if;
   end if;

   if (nEndOfHdrIx >= 0) or (rows_in >= pack_after) then
      if (isnchar(cbuf))
      then
         if (nc_charset_ID <> ht_charset_ID) then
            putraw(UTL_RAW.CONVERT(UTL_RAW.CAST_TO_RAW(cbuf),
                           'AMERICAN_AMERICA.'||ht_charset,
                           'AMERICAN_AMERICA.'||nc_charset));
         else 
            if (len > RAW_MAX) then
              putraw(UTL_RAW.CAST_TO_RAW(cbuf), len);
            else
              rows_in := rows_in + 1;
              htraws(rows_in) := UTL_RAW.CAST_TO_RAW(cbuf);
              htbuf(rows_in) := '';
              contentlen := contentLen + len;
            end if;
         end if;
      else
         if (db_charset_ID <> ht_charset_ID) then
            putraw(UTL_RAW.CONVERT(UTL_RAW.CAST_TO_RAW(cbuf),
                       'AMERICAN_AMERICA.'||ht_charset,
                       'AMERICAN_AMERICA.'||db_charset));
         else
            if (len > RAW_MAX) then
              putraw(UTL_RAW.CAST_TO_RAW(cbuf),len);
            else
              rows_in := rows_in + 1;
              htraws(rows_in) := UTL_RAW.CAST_TO_RAW(cbuf);
              htbuf(rows_in) := '';
              contentlen := contentLen + len; 
            end if;
         end if;
     end if;
     return;
   end if;

   len := length(cbuf);
   loc := 0;
   while ((len - loc) >= HTBUF_LEN)
   loop
      rows_in := rows_in + 1;
      htbuf(rows_in) := substr(cbuf, loc + 1, HTBUF_LEN);
      loc := loc + HTBUF_LEN;
   end loop;
   if (loc < len)
   then
      rows_in := rows_in + 1;
      htbuf(rows_in) := substr(cbuf, loc + 1);
   end if;
end prn_raw;

--
-- Code for htp.p and htp.print is duplicated so that we avoid a 
-- procedure call overhead in the typical cases
--
procedure print (cbuf in varchar2 character set any_cs DEFAULT NULL) is
begin
    prn(cbuf || NL_CHAR);
end;

procedure p (cbuf in varchar2 character set any_cs DEFAULT NULL) is
begin
    prn(cbuf || NL_CHAR);
end;

procedure print (dbuf in date) is
begin print(to_char(dbuf)); end;

procedure print (nbuf in number) is
begin print(to_char(nbuf)); end;

procedure prn (dbuf in date) is
begin prn(to_char(dbuf)); end;

procedure prn (nbuf in number) is
begin prn(to_char(nbuf)); end;

procedure p (dbuf in date) is
begin print(to_char(dbuf)); end;

procedure p (nbuf in number) is
begin print(to_char(nbuf)); end;

procedure prints(ctext in varchar2 character set any_cs) is
begin p(htf.escape_sc(ctext)); end;

procedure ps(ctext in varchar2 character set any_cs) is
begin p(htf.escape_sc(ctext)); end;

procedure escape_sc(ctext in varchar2 character set any_cs) is
begin p(htf.escape_sc(ctext)); end;

procedure print_header (cbuf in varchar2, nline in number) is
begin 
   per_request_init;
   if (nGatewayVersion >= 2)
   then
      htbuf(nline) := cbuf || NL_CHAR; 
   end if;
end;
/* END SPECIAL PROCEDURES */

begin
   init;
end;
/
show errors package body htp

