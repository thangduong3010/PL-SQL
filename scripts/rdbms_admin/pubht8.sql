Rem  Copyright (c) 1994, 1995, 1996, 1997 by Oracle Corp.  All rights reserved.
Rem
Rem   NAME
Rem     ht.sql - Hyper Text packages
Rem   PURPOSE
Rem     Provide utility functions for producing HTML documents
Rem     from pl/sql.
Rem   NOTES
Rem     Two sets of packages - one is all functions/constants (htf)
Rem                          - one is all procedures (htp)
Rem
Rem     A PL/SQL table of varchar2 is used to buffer output.
Rem       htp.print() buffers the output.
Rem       owa.get_page() fetches it out.
Rem
Rem     This script should be run by the intended owner of the OWA packages.
Rem   HISTORY
Rem     pkapasi    07/25/02 -  Performance fixes (2460224, 2470207, 2482024)
Rem     skwong     07/20/01 -  Add APIs and types related to RAW transfers
Rem     pkapasi    06/12/01 -  Merge OAS specific helper functions
Rem     ehlee      05/10/00 -  Remove header reserving procedures
Rem     ehlee      05/05/00 -  Add two functions to reserve header spaces
Rem     rdasarat   11/19/98 -  Add addDefaultHTMLHdr procedure
Rem     rdasarat   10/26/98 -  Fix 735061
Rem     rdasarat   04/02/98 -  Add file upload/download functionality
Rem     rdasarat   01/14/98 -  Add pack_after variable for procedure prn
Rem     rdasarat   11/13/97 -  Add init procedure
Rem     mpal       04/23/97 -  Fix bug# #482019 - added escape_url for '%'
Rem     mpal       01/29/97 -  Fix bug# #444697 - Restore pragma references 
Rem                            for anchor, anchor2, mail
Rem     rpang      01/27/97 -  Restored PRAGMA RESTRICT_REFERENCES (bug#439474)
Rem     mpal       11/15/96 -  Adding formFile procedure
Rem     mpal       11/12/96 -  Adding NLS char conversion
Rem     mpal       08/22/96 -  HTML 3.2 support
Rem     mpal       08/19/96 -  Fix Bug# 393305
Rem     mpal       06/24/96 -  Adding escape sequence support '%'    
Rem     mbookman   03/04/96 -  Fixed a number of new PRAGMAs
Rem     mbookman   03/04/96 -  Re-asserted purity level for htf.base (314403)
Rem     mbookman   03/04/95 -  Change RESTRICT_REFERENCES (314398)
Rem     kireland   02/03/96 -  HTML3.0 support, Netscape Frames, Msft extensions
Rem     mbookman   07/26/95 -  Added mailto support
Rem     mbookman   05/23/95 -  Full HTML 2.0 support. Standardize names
Rem     mloennro   09/05/94 -  Creation
Rem

REM Creating HTF package...
create or replace package htf as

/* STRUCTURE tags */
/*function*/ htmlOpen          constant varchar2(7) := '<HTML>';
         /* No attributes in HTML 3.0 spec as of 6/7/95 */
/*function*/ htmlClose         constant varchar2(7) := '</HTML>';
         /* No attributes in HTML 3.0 spec as of 6/7/95 */
/*function*/ headOpen          constant varchar2(7) := '<HEAD>';
         /* No attributes in HTML 3.0 spec as of 6/7/95 */
/*function*/ headClose         constant varchar2(7) := '</HEAD>';
         /* No attributes in HTML 3.0 spec as of 6/7/95 */
function     bodyOpen (cbackground in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) return varchar2;
/*function*/ bodyClose         constant varchar2(7) := '</BODY>';
         /* No attributes in HTML 3.0 spec as of 6/7/95 */
/* END STRUCTURE tags */

/* HEAD Related elements tags */
function title(ctitle in varchar2) return varchar2 character set ctitle%charset;
         /* No attributes in HTML 3.0 spec as of 6/7/95 */
function htitle(ctitle      in varchar2,
                nsize       in integer  DEFAULT 1,
                calign      in varchar2 DEFAULT NULL,
                cnowrap     in varchar2 DEFAULT NULL,
                cclear      in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) 
                return varchar2 character set ctitle%charset;
function base(    ctarget in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL) return varchar2;

function isindex(cprompt in varchar2 DEFAULT NULL,
                 curl    in varchar2 DEFAULT NULL)
                 return varchar2 character set cprompt%charset;
         /* No attributes in HTML 3.0 spec as of 6/7/95 */
function linkRel(crel   in varchar2, 
                 curl   in varchar2,
                 ctitle in varchar2 DEFAULT NULL)  
                 return varchar2 character set ctitle%charset;
         /* No attributes in HTML 3.0 spec as of 6/7/95 */
function linkRev(crev   in varchar2,
                 curl   in varchar2, 
                 ctitle in varchar2 DEFAULT NULL) 
                 return varchar2 character set ctitle%charset;
         /* No attributes in HTML 3.0 spec as of 6/7/95 */
function meta(chttp_equiv in varchar2,
              cname       in varchar2,
              ccontent    in varchar2) return varchar2;
         /* No attributes in HTML 3.0 spec as of 6/7/95 */
function nextid(cidentifier in varchar2) return varchar2;
         /* No attributes in HTML 3.0 spec as of 6/7/95 */

function style(cstyle in varchar2)
              return varchar2 character set cstyle%charset;
     /* No attributes in HTML 3.2 spec as of 8/22/96 */
function script(cscript in varchar2,
        clanguage in varchar2 DEFAULT NULL) return varchar2;

/* END HEAD Related elements tags */

/* BODY ELEMENT tags */
function hr  (cclear      in varchar2 DEFAULT NULL,
              csrc        in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) return varchar2;
function line(cclear      in varchar2 DEFAULT NULL,
              csrc        in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) return varchar2;
function br(cclear      in varchar2 DEFAULT NULL,
            cattributes in varchar2 DEFAULT NULL) return varchar2;
function nl(cclear      in varchar2 DEFAULT NULL,
            cattributes in varchar2 DEFAULT NULL) return varchar2;

function header(nsize   in integer,
                cheader in varchar2,
                calign  in varchar2 DEFAULT NULL,
                cnowrap in varchar2 DEFAULT NULL,
                cclear  in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL)
                return varchar2 character set cheader%charset;

function anchor(curl        in varchar2,
                ctext       in varchar2,
                cname       in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) 
                return varchar2 character set ctext%charset;

function anchor2(curl        in varchar2,
                ctext       in varchar2,
                cname       in varchar2 DEFAULT NULL,
        ctarget        in varchar2 DEFAULT NULL, 
                cattributes in varchar2 DEFAULT NULL) 
                return varchar2 character set ctext%charset;

function mailto(caddress    in varchar2,
                ctext       in varchar2,
                cname       in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL)                
                return varchar2 character set ctext%charset;

function img(curl        in varchar2,
             calign      in varchar2 DEFAULT NULL,
             calt        in varchar2 DEFAULT NULL,
             cismap      in varchar2 DEFAULT NULL,
             cattributes in varchar2 DEFAULT NULL) return varchar2;
function img2(curl        in varchar2,
             calign      in varchar2 DEFAULT NULL,
             calt        in varchar2 DEFAULT NULL,
             cismap      in varchar2 DEFAULT NULL,
          cusemap     in varchar2 DEFAULT NULL,
             cattributes in varchar2 DEFAULT NULL) return varchar2;

function area(    ccoords    in varchar2,
                 cshape    in varchar2 DEFAULT NULL,
                 chref    in varchar2 DEFAULT NULL,
                 cnohref    in varchar2 DEFAULT NULL,
        ctarget in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL) return varchar2;

function mapOpen(cname    in varchar2,
         cattributes in varchar2 DEFAULT NULL) return varchar2;
/*function*/ mapClose    constant varchar2(6) := '</MAP>';

function bgsound(csrc    in varchar2,
         cloop     in varchar2 DEFAULT NULL,
         cattributes in varchar2 DEFAULT NULL) return varchar2;


/*function*/ para              constant varchar2(3) := '<P>';
function paragraph(calign       in varchar2 DEFAULT NULL,
                   cnowrap      in varchar2 DEFAULT NULL,
                   cclear       in varchar2 DEFAULT NULL,
                   cattributes  in varchar2 DEFAULT NULL) return varchar2;
function div(    calign       in varchar2 DEFAULT NULL,
                cattributes  in varchar2 DEFAULT NULL) return varchar2;
function address(cvalue       in varchar2,
                 cnowrap      in varchar2 DEFAULT NULL,
                 cclear       in varchar2 DEFAULT NULL,
                 cattributes  in varchar2 DEFAULT NULL) 
                 return varchar2 character set cvalue%charset;
function comment(ctext in varchar2) 
                 return varchar2 character set ctext%charset;
function preOpen(cclear      in varchar2 DEFAULT NULL,
                 cwidth      in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) return varchar2;
/*function*/ preClose          constant varchar2(6) := '</PRE>';
/*function*/ listingOpen    constant varchar2(9) := '<LISTING>';
/*function*/ listingClose    constant varchar2(10) := '</LISTING>';

function nobr(ctext in varchar2) 
             return varchar2 character set ctext%charset;
/*function*/ wbr constant varchar(5) := '<WBR>';

function center(ctext in varchar2) 
                return varchar2 character set ctext%charset;
/*function*/ centerOpen    constant varchar2(8) := '<CENTER>';
/*function*/ centerClose constant varchar2(9) := '</CENTER>';

function blockquoteOpen(cnowrap      in varchar2 DEFAULT NULL,
                        cclear       in varchar2 DEFAULT NULL,
                        cattributes  in varchar2 DEFAULT NULL) return varchar2;
/*function*/ blockquoteClose   constant varchar2(13) := '</BLOCKQUOTE>';

/* LIST tags */
function listHeader(ctext in varchar2,
                    cattributes in varchar2 DEFAULT NULL)
                    return varchar2 character set ctext%charset;
function listItem(ctext       in varchar2 DEFAULT NULL,
                  cclear      in varchar2 DEFAULT NULL,
                  cdingbat    in varchar2 DEFAULT NULL,
                  csrc        in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) 
                  return varchar2 character set ctext%charset;
function ulistOpen(cclear      in varchar2 DEFAULT NULL,
                   cwrap       in varchar2 DEFAULT NULL,
                   cdingbat    in varchar2 DEFAULT NULL,
                   csrc        in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2;
/*function */ ulistClose        constant varchar2(5) := '</UL>';
function olistOpen(cclear      in varchar2 DEFAULT NULL,
                   cwrap       in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2;
/*function */ olistClose        constant varchar2(5) := '</OL>';
function dlistOpen(cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2;
function dlistTerm(ctext       in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) 
                   return varchar2 character set ctext%charset;
function dlistDef(ctext       in varchar2 DEFAULT NULL,
                  cclear      in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) 
                  return varchar2 character set ctext%charset;
/*function */ dlistClose        constant varchar2(5) := '</DL>';

/*function */ menulistOpen      constant varchar2(6) := '<MENU>';
/*function */ menulistClose     constant varchar2(7) := '</MENU>';

/*function */ dirlistOpen       constant varchar2(5) := '<DIR>';
/*function */ dirlistClose      constant varchar2(6) := '</DIR>';
/* END LIST tags */


/* SEMANTIC FORMAT ELEMENTS */
function dfn(ctext in varchar2,
              cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function cite(ctext in varchar2,
              cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function code(ctext in varchar2,
              cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function em(ctext in varchar2,
            cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function emphasis(ctext in varchar2,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function keyboard(ctext in varchar2,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function kbd(ctext in varchar2,
             cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function sample(ctext in varchar2,
                cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function strong(ctext in varchar2,
                cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function variable(ctext in varchar2,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function big(    ctext         in varchar2,
        cattributes     in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function small(    ctext         in varchar2,
        cattributes     in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function sub(    ctext         in varchar2,
        calign         in varchar2 DEFAULT NULL,
        cattributes     in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function sup(    ctext         in varchar2,
        calign        in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
/* END SEMANTIC FORMAT ELEMENTS */

/* PHYSICAL FORMAT ELEMENTS */
function basefont(    nsize in integer,
            cattributes in varchar2 DEFAULT NULL) return varchar2;
function fontOpen(    ccolor     in varchar2 DEFAULT NULL,
        cface    in varchar2 DEFAULT NULL,
        csize    in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL) return varchar2;
/*function*/ fontClose    constant varchar2(7) := '</FONT>';
function bold(ctext in varchar2,
              cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function italic(ctext in varchar2,
                cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function teletype(ctext in varchar2,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function plaintext(ctext in varchar2,
                     cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function s(ctext in varchar2,
           cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
function strike(ctext in varchar2,
                cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;

function underline(ctext in varchar2,
           cattributes in varchar2 DEFAULT NULL) return varchar2 character set ctext%charset;
/* END PHYSICAL FORMAT ELEMENTS */

/* HTML FORMS */
function formOpen(curl     in varchar2,
                  cmethod  in varchar2 DEFAULT 'POST',
          ctarget  in varchar2 DEFAULT NULL,
          cenctype in varchar2 DEFAULT NULL,
          cattributes in varchar2 DEFAULT NULL) return varchar2;

function formCheckbox(cname       in varchar2,
                      cvalue      in varchar2 DEFAULT 'on',
                      cchecked    in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 character set cvalue%charset;
function formFile(cname       in varchar2,
                  caccept     in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) return varchar2;
function formHidden(cname       in varchar2,
                    cvalue      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) return varchar2 character set cvalue%charset;
function formImage(cname       in varchar2,
                   csrc        in varchar2,
                   calign      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2;
function formPassword(cname       in varchar2,
                      csize       in varchar2 DEFAULT NULL,
                      cmaxlength  in varchar2 DEFAULT NULL,
                      cvalue      in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 character set cvalue%charset;
function formRadio(cname       in varchar2,
                   cvalue      in varchar2,
                   cchecked    in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 character set cvalue%charset;
function formReset(cvalue      in varchar2 DEFAULT 'Reset',
                   cattributes in varchar2 DEFAULT NULL) return varchar2 character set cvalue%charset;
function formSubmit(cname       in varchar2 DEFAULT NULL,
                    cvalue      in varchar2 DEFAULT 'Submit',
                    cattributes in varchar2 DEFAULT NULL) return varchar2 character set cvalue%charset;
function formText(cname       in varchar2,
                  csize       in varchar2 DEFAULT NULL,
                  cmaxlength  in varchar2 DEFAULT NULL,
                  cvalue      in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 character set cvalue%charset;
function formSelectOpen(cname       in varchar2,
                        cprompt     in varchar2 DEFAULT NULL,
                        nsize       in integer  DEFAULT NULL,
                        cattributes in varchar2 DEFAULT NULL) 
                        return varchar2 character set cprompt%charset;
function formSelectOption(cvalue      in varchar2,
                          cselected   in varchar2 DEFAULT NULL,
                          cattributes in varchar2 DEFAULT NULL) 
                          return varchar2 character set cvalue%charset;
/*function */ formSelectClose   constant varchar2(9) := '</SELECT>';

function formTextarea(cname       in varchar2,
                      nrows       in integer,
                      ncolumns    in integer,
                      calign      in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2; 

function formTextarea2(cname       in varchar2,
                      nrows       in integer,
                      ncolumns    in integer,
                      calign      in varchar2 DEFAULT NULL,
                      cwrap       in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2; 

function formTextareaOpen(cname       in varchar2,
                          nrows       in integer,
                          ncolumns    in integer,
                          calign      in varchar2 DEFAULT NULL,
                          cattributes in varchar2 DEFAULT NULL) return varchar2;

function formTextareaOpen2(cname       in varchar2,
                          nrows       in integer,
                          ncolumns    in integer,
                          calign      in varchar2 DEFAULT NULL,
                          cwrap       in varchar2 DEFAULT NULL,
                          cattributes in varchar2 DEFAULT NULL) return varchar2;

/*function */ formTextareaClose constant varchar2(11) := '</TEXTAREA>';

/*function */ formClose         constant varchar2(7) := '</FORM>';
/* END HTML FORMS */ 


/* HTML TABLES */
function tableOpen(cborder     in varchar2 DEFAULT NULL,
                   calign      in varchar2 DEFAULT NULL,
                   cnowrap     in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2;
function tableCaption(ccaption    in varchar2,
                      calign      in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) 
                      return varchar2 character set ccaption%charset;
function tableRowOpen(calign      in varchar2 DEFAULT NULL,
                      cvalign     in varchar2 DEFAULT NULL,
                      cdp         in varchar2 DEFAULT NULL,
                      cnowrap     in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2;
function tableHeader(cvalue      in varchar2 DEFAULT NULL,
                     calign      in varchar2 DEFAULT NULL,
                     cdp         in varchar2 DEFAULT NULL,
                     cnowrap     in varchar2 DEFAULT NULL,
                     crowspan    in varchar2 DEFAULT NULL,
                     ccolspan    in varchar2 DEFAULT NULL,
                     cattributes in varchar2 DEFAULT NULL)
                     return varchar2 character set cvalue%charset;
function tableData(cvalue      in varchar2 DEFAULT NULL,
                   calign      in varchar2 DEFAULT NULL,
                   cdp         in varchar2 DEFAULT NULL,
                   cnowrap     in varchar2 DEFAULT NULL,
                   crowspan    in varchar2 DEFAULT NULL,
                   ccolspan    in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) 
                   return varchar2 character set cvalue%charset;
function format_cell( columnValue in varchar2, 
                      format_numbers in varchar2 default null)
                      return varchar2 character set columnvalue%charset;
/*function */ tableRowClose constant varchar2(5) := '</TR>';

/*function */ tableClose    constant varchar2(8) := '</TABLE>';
/* END HTML TABLES */

/* HTML FRAMES */

function framesetOpen(    crows    in varchar2 DEFAULT NULL,    /* row heigh value list */
            ccols     in varchar2 DEFAULT NULL,
            cattributes in varchar2 DEFAULT NULL) return varchar2;    /* column width list */

/* function */ framesetClose     constant varchar2(11) := '</FRAMESET>';

function frame(        csrc    in varchar2,                /* URL */
            cname    in varchar2 DEFAULT NULL,        /* Window Name */
            cmarginwidth     in varchar2 DEFAULT NULL,    /* Value in pixels */
            cmarginheight    in varchar2 DEFAULT NULL,    /* Value in pixels */
            cscrolling    in varchar2 DEFAULT NULL,    /* yes | no | auto */
            cnoresize    in varchar2 DEFAULT NULL,
            cattributes    in varchar2 DEFAULT NULL) return varchar2;    /* Not resizable by user */

/* function */ noframesOpen    constant varchar2(10) := '<NOFRAMES>';
/* function */ noframesClose    constant varchar2(11) := '</NOFRAMES>';
/* END HTML FRAMES */

/* SPECIAL HTML TAGS */
function appletOpen(ccode     in varchar2,
            cwidth    in integer,
            cheight    in integer,
            cattributes in varchar2 DEFAULT NULL) return varchar2;
function param(cname     in varchar2,
           cvalue     in varchar2) 
               return varchar2 character set cvalue%charset;
/*function */ appletClose    constant varchar2(9) := '</APPLET>';
/* END SPECIAL HTML TAGS */

/* SPECIAL FUNCTIONS */
function escape_sc(ctext in varchar2) 
                  return varchar2 character set ctext%charset;
function escape_url(p_url in varchar2) 
                   return varchar2 character set p_url%charset;
/* END SPECIAL FUNCTIONS */

/* END BODY ELEMENT tags */

/* Assert function purities so that they can be used in select lists */
PRAGMA RESTRICT_REFERENCES(bodyOpen,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(title,            WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(htitle,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(base,             WNDS, WNPS, RNDS);
PRAGMA RESTRICT_REFERENCES(isindex,          WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(linkRel,          WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(linkRev,          WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(meta,             WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(nextid,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(style,            WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(script,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(hr,               WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(line,             WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(br,               WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(nl,               WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(header,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(anchor,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(anchor2,          WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(mailto,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(img,              WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(img2,              WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(mapOpen,          WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(area,             WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(bgsound,          WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(paragraph,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(div,                WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(address,          WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(comment,          WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(preOpen,          WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(nobr,             WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(center,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(blockquoteOpen,   WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(listHeader,       WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(listItem,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(ulistOpen,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(olistOpen,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(dlistOpen,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(dlistTerm,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(dlistDef,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(cite,             WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(dfn,              WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(code,             WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(em,               WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(emphasis,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(keyboard,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(kbd,              WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(sample,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(strong,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(variable,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(big,                 WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(small,            WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(sub,              WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(sup,              WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(basefont,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(fontOpen,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(bold,             WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(italic,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(teletype,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(plaintext,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(strike,           WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(s,                WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(underline,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formOpen,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formCheckbox,     WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formFile,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formHidden,       WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formImage,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formPassword,     WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formRadio,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formReset,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formSubmit,       WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formText,         WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formSelectOpen,   WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formSelectOption, WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formTextarea,     WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formTextarea2,     WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formTextareaOpen, WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(formTextareaOpen2, WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(tableOpen,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(tableCaption,     WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(tableRowOpen,     WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(tableHeader,      WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(tableData,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(framesetOpen,     WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(frame,            WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(appletOpen,       WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(param,            WNDS, WNPS, RNDS, RNPS);

PRAGMA RESTRICT_REFERENCES(escape_sc,        WNDS, WNPS, RNDS, RNPS);
PRAGMA RESTRICT_REFERENCES(escape_url,       WNDS, WNPS, RNDS, RNPS);

end;
/
show errors package htf

REM Creating HTP package...
create or replace package htp as

/* STRUCTURE tags */
procedure htmlOpen;
procedure htmlClose;
procedure headOpen;
procedure headClose;
procedure bodyOpen(cbackground in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL)   ;
procedure bodyClose;
/* END STRUCTURE tags */

/* HEAD Related elements tags */
procedure title  (ctitle in varchar2)                      ;
procedure htitle(ctitle      in varchar2,
                 nsize       in integer  DEFAULT 1,
                 calign      in varchar2 DEFAULT NULL,
                 cnowrap     in varchar2 DEFAULT NULL,
                 cclear      in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL)     ;
procedure base(    ctarget    in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL);
procedure isindex(cprompt in varchar2 DEFAULT NULL,
                  curl    in varchar2 DEFAULT NULL) ;
procedure linkRel(crel   in varchar2,
                  curl   in varchar2, 
                  ctitle in varchar2 DEFAULT NULL)          ;
procedure linkRev(crev  in varchar2, 
                  curl  in varchar2, 
                  ctitle in varchar2 DEFAULT NULL)          ;
procedure meta(chttp_equiv in varchar2,
               cname       in varchar2,
               ccontent    in varchar2)                     ;
procedure nextid(cidentifier in varchar2)                   ;
procedure style(cstyle in varchar2)                ;
procedure script(cscript     in varchar2,
         clanguage     in varchar2 DEFAULT NULL)   ;
/* END HEAD Related elements tags */

/* BODY ELEMENT tags */
procedure hr  (cclear      in varchar2 DEFAULT NULL,
               csrc        in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL)       ;
procedure line(cclear      in varchar2 DEFAULT NULL,
               csrc        in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL)       ;
procedure br(cclear      in varchar2 DEFAULT NULL,
             cattributes in varchar2 DEFAULT NULL)         ;
procedure nl(cclear      in varchar2 DEFAULT NULL,
             cattributes in varchar2 DEFAULT NULL)         ;

procedure header(nsize   in integer,
                 cheader in varchar2,
                 calign  in varchar2 DEFAULT NULL,
                 cnowrap in varchar2 DEFAULT NULL,
                 cclear  in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL)     ;
procedure anchor(curl        in varchar2,
                 ctext       in varchar2,
                 cname       in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL)     ;
procedure anchor2(curl        in varchar2,
                 ctext       in varchar2,
                 cname       in varchar2 DEFAULT NULL,
         ctarget     in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL)     ;
procedure mailto(caddress    in varchar2,
                 ctext       in varchar2,
                 cname       in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL)     ;
procedure img(curl        in varchar2,
              calign      in varchar2 DEFAULT NULL,
              calt        in varchar2 DEFAULT NULL,
              cismap      in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL)        ;
procedure img2(curl        in varchar2,
              calign      in varchar2 DEFAULT NULL,
              calt        in varchar2 DEFAULT NULL,
              cismap      in varchar2 DEFAULT NULL,
              cusemap     in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL)        ;
procedure area(    ccoords    in varchar2,
                   cshape    in varchar2 DEFAULT NULL,
                  chref    in varchar2 DEFAULT NULL,
                  cnohref in varchar2 DEFAULT NULL,
        ctarget in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL);

procedure mapOpen(cname    in varchar2,
          cattributes in varchar2 DEFAULT NULL);
procedure mapClose;

procedure bgsound(csrc    in varchar2,
          cloop    in varchar2 DEFAULT NULL,
          cattributes in varchar2 DEFAULT NULL);


procedure para;
procedure paragraph(calign       in varchar2 DEFAULT NULL,
                    cnowrap      in varchar2 DEFAULT NULL,
                    cclear       in varchar2 DEFAULT NULL,
                    cattributes  in varchar2 DEFAULT NULL) ;
procedure div(    calign       in varchar2 DEFAULT NULL,
                cattributes  in varchar2 DEFAULT NULL) ;
procedure address(cvalue       in varchar2,
                  cnowrap      in varchar2 DEFAULT NULL,
                  cclear       in varchar2 DEFAULT NULL,
                  cattributes  in varchar2 DEFAULT NULL)   ;
procedure comment(ctext in varchar2)                       ;
procedure preOpen(cclear      in varchar2 DEFAULT NULL,
                  cwidth      in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL)    ;
procedure preClose;
procedure listingOpen;
procedure listingClose;
procedure nobr(ctext in varchar2);
procedure wbr;
procedure center(ctext in varchar2);
procedure centerOpen;
procedure centerClose;

procedure blockquoteOpen(cnowrap      in varchar2 DEFAULT NULL,
                         cclear       in varchar2 DEFAULT NULL,
                         cattributes  in varchar2 DEFAULT NULL) ;
procedure blockquoteClose;

/* LIST tags */
procedure listHeader(ctext in varchar2,
                     cattributes in varchar2 DEFAULT NULL) ;
procedure listItem(ctext       in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cdingbat    in varchar2 DEFAULT NULL,
                   csrc        in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL)   ;
procedure ulistOpen(cclear      in varchar2 DEFAULT NULL,
                    cwrap       in varchar2 DEFAULT NULL,
                    cdingbat    in varchar2 DEFAULT NULL,
                    csrc        in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL)  ;
procedure ulistClose;
procedure olistOpen(cclear      in varchar2 DEFAULT NULL,
                    cwrap       in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL)  ;
procedure olistClose;
procedure dlistOpen(cclear      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL)  ;
procedure dlistTerm(ctext       in varchar2 DEFAULT NULL,
                    cclear      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL)  ;
procedure dlistDef(ctext       in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL)  ;
procedure dlistClose;

procedure menulistOpen;
procedure menulistClose;
procedure dirlistOpen;
procedure dirlistClose;
/* END LIST tags */

/* SEMANTIC FORMAT ELEMENTS */
procedure dfn(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) ;
procedure cite(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) ;
procedure code(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) ;
procedure em(ctext in varchar2,
             cattributes in varchar2 DEFAULT NULL) ;
procedure emphasis(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) ;
procedure keyboard(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) ;
procedure kbd(ctext in varchar2,
              cattributes in varchar2 DEFAULT NULL) ;
procedure sample(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) ;
procedure strong(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) ;
procedure variable(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) ;
procedure big(    ctext         in varchar2,
        cattributes     in varchar2 DEFAULT NULL);
procedure small(ctext         in varchar2,
        cattributes     in varchar2 DEFAULT NULL);
procedure sub(    ctext         in varchar2,
        calign        in varchar2 DEFAULT NULL,
        cattributes     in varchar2 DEFAULT NULL);
procedure sup(    ctext         in varchar2,
        calign        in varchar2 DEFAULT NULL,
        cattributes     in varchar2 DEFAULT NULL);

/* END SEMANTIC FORMAT ELEMENTS */

/* PHYSICAL FORMAT ELEMENTS */
procedure basefont(nsize in integer);
procedure fontOpen(    ccolor    in varchar2 DEFAULT NULL,
        cface    in varchar2 DEFAULT NULL,
        csize    in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL);
procedure fontClose;
procedure bold(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) ;
procedure italic(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) ;
procedure teletype(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) ;
procedure plaintext(ctext in varchar2,
                    cattributes in varchar2 DEFAULT NULL) ;
procedure s(ctext in varchar2,
            cattributes in varchar2 DEFAULT NULL) ;
procedure strike(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) ;
procedure underline(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) ;
/* END PHYSICAL FORMAT ELEMENTS */

/* HTML FORMS */
procedure formOpen(curl     in varchar2,
                   cmethod  in varchar2 DEFAULT 'POST',
           ctarget  in varchar2 DEFAULT NULL,
           cenctype in varchar2 DEFAULT NULL, 
           cattributes in varchar2 DEFAULT NULL);

procedure formCheckbox(cname       in varchar2,
                       cvalue      in varchar2 DEFAULT 'on',
                       cchecked    in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL);
procedure formFile(cname       in varchar2,
                   caccept     in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL);
procedure formHidden(cname       in varchar2,
                     cvalue      in varchar2 DEFAULT NULL,
                     cattributes in varchar2 DEFAULT NULL);
procedure formImage(cname       in varchar2,
                    csrc        in varchar2,
                    calign      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL);
procedure formPassword(cname       in varchar2,
                       csize       in varchar2 DEFAULT NULL,
                       cmaxlength  in varchar2 DEFAULT NULL,
                       cvalue      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL);
procedure formRadio(cname       in varchar2,
                    cvalue      in varchar2,
                    cchecked    in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL);
procedure formReset(cvalue      in varchar2 DEFAULT 'Reset',
                    cattributes in varchar2 DEFAULT NULL);
procedure formSubmit(cname       in varchar2 DEFAULT NULL,
                     cvalue      in varchar2 DEFAULT 'Submit',
                     cattributes in varchar2 DEFAULT NULL);
procedure formText(cname       in varchar2,
                   csize       in varchar2 DEFAULT NULL,
                   cmaxlength  in varchar2 DEFAULT NULL,
                   cvalue      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL);

procedure formSelectOpen(cname       in varchar2,
                         cprompt     in varchar2 DEFAULT NULL,
                         nsize       in integer  DEFAULT NULL,
                         cattributes in varchar2 DEFAULT NULL);
procedure formSelectOption(cvalue      in varchar2,
                           cselected   in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL);
procedure formSelectClose;

procedure formTextarea(cname       in varchar2,
                       nrows       in integer,
                       ncolumns    in integer,
                       calign      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL); 

procedure formTextarea2(cname       in varchar2,
                       nrows       in integer,
                       ncolumns    in integer,
                       calign      in varchar2 DEFAULT NULL,
               cwrap       in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL); 

procedure formTextareaOpen(cname       in varchar2,
                           nrows       in integer,
                           ncolumns    in integer,
                           calign      in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL); 

procedure formTextareaOpen2(cname       in varchar2,
                           nrows       in integer,
                           ncolumns    in integer,
                           calign      in varchar2 DEFAULT NULL,
               cwrap       in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL); 
procedure formTextareaClose;

procedure formClose;
/* END HTML FORMS */

/* HTML TABLES */
procedure tableOpen(cborder     in varchar2 DEFAULT NULL,
                    calign      in varchar2 DEFAULT NULL,
                    cnowrap     in varchar2 DEFAULT NULL,
                    cclear      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL);
procedure tableCaption(ccaption    in varchar2,
                       calign      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL);
procedure tableRowOpen(calign      in varchar2 DEFAULT NULL,
                       cvalign     in varchar2 DEFAULT NULL,
                       cdp         in varchar2 DEFAULT NULL,
                       cnowrap     in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL);
procedure tableHeader(cvalue      in varchar2 DEFAULT NULL,
                      calign      in varchar2 DEFAULT NULL,
                      cdp         in varchar2 DEFAULT NULL,
                      cnowrap     in varchar2 DEFAULT NULL,
                      crowspan    in varchar2 DEFAULT NULL,
                      ccolspan    in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL);
procedure tableData(cvalue      in varchar2 DEFAULT NULL,
                    calign      in varchar2 DEFAULT NULL,
                    cdp         in varchar2 DEFAULT NULL,
                    cnowrap     in varchar2 DEFAULT NULL,
                    crowspan    in varchar2 DEFAULT NULL,
                    ccolspan    in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL);
procedure tableRowClose;

procedure tableClose;
/* END HTML TABLES */

/* BEGIN HTML FRAMES - Netscape Extensions FRAMESET, FRAME tags */
procedure framesetOpen(    crows in varchar2 DEFAULT NULL,    /* row height value list */
            ccols in varchar2 DEFAULT NULL,
            cattributes in varchar2 DEFAULT NULL);    /* column width list */
procedure framesetClose;
procedure frame(    csrc    in varchar2,                /* URL */
            cname    in varchar2 DEFAULT NULL,        /* Window Name */
            cmarginwidth     in varchar2 DEFAULT NULL,    /* Value in pixels */
            cmarginheight    in varchar2 DEFAULT NULL,    /* Value in pixels */
            cscrolling    in varchar2 DEFAULT NULL,    /* yes | no | auto */
            cnoresize    in varchar2 DEFAULT NULL,
            cattributes     in varchar2 DEFAULT NULL);    /* Not resizable by user */
procedure noframesOpen;
procedure noframesClose;

/* END FRAMES */

/* BEGIN SPECIAL HTML TAGS */
procedure appletOpen(    ccode        in varchar2,
            cwidth        in integer,
            cheight        in integer,
            cattributes    in varchar2 DEFAULT NULL);
procedure param(    cname        in varchar2,
            cvalue        in varchar2);
procedure appletClose;

/* END BODY ELEMENT tags */

/* TYPES FOR htp.print */
-- PL/SQL table used for output buffering
HTBUF_LEN number := 255;
type htbuf_arr is table of varchar2(256) index by binary_integer;
type htraw_arr is table of raw(256)      index by binary_integer;

/* SPECIAL PROCEDURES */
procedure init;
-- call addDefaultHTMLHdr(FALSE) before your first call
-- to prn or print to suppress HTML header generation
-- if not present
procedure addDefaultHTMLHdr(bAddHTMLHdr in boolean);
procedure flush;

/* Start of OAS specific helper procedures */
procedure flush_charset_convert (charset in varchar2);
procedure get_page_charset_convert (thepage out NOCOPY htbuf_arr,
   irows in out integer, charset in varchar2);
/* End of OAS specific helper procedures */

function get_line (irows out integer) return varchar2;
procedure get_page (thepage out NOCOPY htbuf_arr, irows in out integer);

/* Add RAW transfer API */
procedure get_page_raw (thepage out NOCOPY htraw_arr, irows in out integer);
procedure showpage;
procedure reset_get_page;

/* Following procedures are for file download feature */
procedure download_file(sFileName in varchar2,
   bCompress in boolean default false);
procedure get_download_files_list(sFilesList out varchar2,
   nCompress out binary_integer);

  -- Output Procedures
procedure print (cbuf in varchar2 DEFAULT NULL);
procedure print (dbuf in date);
procedure print (nbuf in number);

  -- Output without the newline
procedure prn (cbuf in varchar2 DEFAULT NULL);
procedure prn (dbuf in date);
procedure prn (nbuf in number);

  -- Abbrev call to print()
procedure p (cbuf in varchar2 DEFAULT NULL);
procedure p (dbuf in date);
procedure p (nbuf in number);

  -- Raw output functions
/* Allow direct writes of raw content, e.g. to produce images or
** literally anything. */
procedure putraw  (bbuf in raw, buflen pls_integer DEFAULT NULL);

procedure prints(ctext in varchar2);
procedure ps(ctext in varchar2);
procedure escape_sc(ctext in varchar2);
procedure setHTTPCharset(iana_charset in varchar2, 
                         ora_charset varchar2 default NULL);
procedure print_header(cbuf in varchar2, nline in number);
/* Set raw transfer mode */
procedure set_transfer_mode(tmode in varchar2);
/* END SPECIAL PROCEDURES */
end;
/
show errors package htp

