rem
rem
Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      privpat.sql
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_pattern - Utitility procedures/functions for matching 
Rem                       and changing values in text strings.
Rem
Rem    NOTES
Rem      This packages is dependent on the package OWA_TEXT.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     pkapasi    09/01/00 -  Fix bug# 1395850
Rem     rdasarat   03/04/98 -  Fix bug# 611104
Rem     mpal       03/19/97 -  Fix bug# 466482 - changed char(1) to varchar2(5)
Rem                                              5 is chosen because the max number of
Rem                                              bytes per Oracle's NLS charset is 5
Rem     mbookman   11/29/95 -  Creation

create or replace package body OWA_PATTERN is

   subtype substitution is pattern;

   -- MAX_VC_LEN constant number := 32767;
   -- PL/SQL doesn't allow one to use constant values in variable declarations,
   -- like 'vc varchar2(MAX_VC_LEN), so this is really just here as a reminder
   -- to always use value(MAX_VC_LEN) for declarations.

   BOL         constant varchar2(1) := '^';
   EOL         constant varchar2(1) := '$';
   CCL         constant varchar2(1) := '[';
   CCLEND      constant varchar2(1) := ']';
   QUANT       constant varchar2(1) := '{';
   QUANTEND    constant varchar2(1) := '}';
   BR          constant varchar2(1) := '(';
   BREND       constant varchar2(1) := ')';
   ANY_CHAR    constant varchar2(1) := '.';
   ESCAPE      constant varchar2(1) := '\';
   DASH        constant varchar2(1) := '-';
   NOT_CHAR    constant varchar2(1) := '^';
   CLOSURE     constant varchar2(1) := '*';
   ONE_OR_MORE constant varchar2(1) := '+';
   ZERO_OR_ONE constant varchar2(1) := '?';

   AMP       constant varchar2(1) := '&';

   /* The following line should be broken to represent a NEWLINE */
   NEWLINE constant varchar2(1) := '
';
   /* The following character is a true "tab" */
   TAB     constant varchar2(1) := '	';
   SPACE   constant varchar2(1) := ' ';

   NCCL      constant varchar2(4) := 'NCCL';
   CHARCHAR  constant varchar2(4) := 'CHAR';
   DITTO     constant varchar2(4) := 'DTTO';
   BREF      constant varchar2(4) := 'BREF';
   EOP       constant varchar2(4) := 'EOP';

   CLOSIZE constant integer := 6;
   BRSIZE  constant integer := 4;

   DIGITS constant VARCHAR2(10) := '0123456789';
   LOWLET constant VARCHAR2(26) := 'abcdefghijklmnopqrstuvwxyz';
   UPPLET constant VARCHAR2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   UNDERBAR constant VARCHAR2(1) := '_';

   WORD_CHARS  constant VARCHAR2(63) := DIGITS||LOWLET||UNDERBAR||UPPLET;
   SPACE_CHARS constant VARCHAR2(3)  := SPACE||TAB||NEWLINE;

   DIG_ESCAPE_CHAR       constant varchar2(1) := 'd'; -- [0-9]
   NON_DIG_ESCAPE_CHAR   constant varchar2(1) := 'D'; -- [^0-9]
   WORD_ESCAPE_CHAR      constant varchar2(1) := 'w'; -- [0-9a-z_A-Z]
   NON_WORD_ESCAPE_CHAR  constant varchar2(1) := 'W'; -- [^0-9a-z_A-Z]
   SPACE_ESCAPE_CHAR     constant varchar2(1) := 's'; -- [ \t\n]
   NON_SPACE_ESCAPE_CHAR constant varchar2(1) := 'S'; -- [^ \t\n]
   BOUND_ESCAPE_CHAR     constant varchar2(1) := 'b';
   NON_BOUND_ESCAPE_CHAR constant varchar2(1) := 'B';

   DIG_ESCAPE       constant varchar2(2) := ESCAPE||DIG_ESCAPE_CHAR;
   NON_DIG_ESCAPE   constant varchar2(2) := ESCAPE||NON_DIG_ESCAPE_CHAR;
   WORD_ESCAPE      constant varchar2(2) := ESCAPE||WORD_ESCAPE_CHAR;
   NON_WORD_ESCAPE  constant varchar2(2) := ESCAPE||NON_WORD_ESCAPE_CHAR;
   SPACE_ESCAPE     constant varchar2(2) := ESCAPE||SPACE_ESCAPE_CHAR;
   NON_SPACE_ESCAPE constant varchar2(2) := ESCAPE||NON_SPACE_ESCAPE_CHAR;
   BOUND_ESCAPE     constant varchar2(2) := ESCAPE||BOUND_ESCAPE_CHAR;
   NON_BOUND_ESCAPE constant varchar2(2) := ESCAPE||NON_BOUND_ESCAPE_CHAR;

   COUNT_IND  constant integer := 1;
   PREVCL_IND constant integer := 2;
   START_IND  constant integer := 3;
   MIN_IND    constant integer := 4;
   MAX_IND    constant integer := 5;

   PREVBR_IND  constant integer := 1;
   LOC_IND     constant integer := 2;
   BRNO_IND    constant integer := 3;
   OPENBR_IND  constant integer := 3;

   in_b boolean;

   function ind(str in varchar2, i in integer) return varchar2
      is
   begin
      return substr(str,i,1);
   end;

   function line_len(line in varchar2) return integer
      is
   begin
      if (line is null)
      then
         return 1;
      else
         return length(line);
      end if;
   end;

   function get_int(arg  in     varchar2,
                    loc  in out integer,
                    digs in     varchar2 DEFAULT DIGITS) return integer is
      start_loc integer;
   begin
      start_loc := loc;

      while (instr(digs, ind(arg,loc)) != 0)
      loop
         loc := loc + 1;
      end loop;

      return substr(arg, start_loc, loc-start_loc);
   end;

   function base_convert(str in varchar2, base in integer) return integer
     is
      acc integer;
      len integer;
   begin
      len := length(str);
      if (len is NULL)
      then
         return NULL;
      end if;

      acc := 0;
      for i in 1..len
      loop
         if (instr('abcdefABCDEF', ind(str,i)) != 0)
         then
            acc := acc*base + ascii(convert(lower(ind(str,i)), 'US7ASCII')) - 87;
         else
            acc := acc*base + ind(str,i);
	 end if;
      end loop;

      return acc;
   end;

   procedure addpat(ch in varchar2, pat in out pattern, j in out integer)
      is
   begin
      pat(j) := ch;
      j := j + 1;
   end;

   function patsize(pat in pattern, n in integer) return integer is
   begin
      if (pat(n) = CHARCHAR)
      then return 2;
      end if;
      if (pat(n) in (BOL, EOL, ANY_CHAR,
                     DIG_ESCAPE, NON_DIG_ESCAPE,
                     WORD_ESCAPE, NON_WORD_ESCAPE,
                     SPACE_ESCAPE, NON_SPACE_ESCAPE,
                     BOUND_ESCAPE, NON_BOUND_ESCAPE))
      then return 1;
      end if;
      if (pat(n) in (CCL, NCCL))
      then return pat(n+1) + 2;
      end if;
      if (pat(n) = CLOSURE)
      then return CLOSIZE;
      end if;
      if (pat(n) in (BR, BREND))
      then return BRSIZE;
      end if;

      raise_application_error(-20002,'in patsize: shouldn''t happen');
   end;

   procedure copypat(pat in out pattern,
                     j   in out integer,
                     loc in     integer) is
      pat_size integer;
      k    integer;
   begin
      pat_size := patsize(pat,loc);
      for k in loc..loc+pat_size-1
      loop
         addpat(pat(k), pat, j); 
      end loop;
   end;

   function esc(arg in varchar2, i in out integer) return varchar2
      is
      NL_ESCAPE  constant varchar2(1) := 'n';
      TAB_ESCAPE constant varchar2(1) := 't';

      arg_i varchar2(5); -- MAX NO OF BYTES FOR NLS CHARSET
   begin
      arg_i := ind(arg,i);
      if (arg_i != ESCAPE)
      then
         return arg_i;
      end if;

      if (i = length(arg))
      then
         return arg_i;
      end if;

      i := i+1;
      arg_i := ind(arg,i);
      if (arg_i = NL_ESCAPE)
      then
         return NEWLINE;
      end if;

      if (arg_i = TAB_ESCAPE)
      then
         return TAB;
      end if;

      return arg_i;
   end;

   procedure dodash(valid_chars in varchar2,
                    arg         in varchar2,
                    i           in out integer,
                    pat         in out pattern,
                    j           in out integer) is
      limit integer;
      k     integer;
   begin
      i := i + 1;
      j := j - 1;

      limit := instr(valid_chars, esc(arg,i));
      k := instr(valid_chars, pat(j));
      while (k <= limit)
      loop
         addpat(ind(valid_chars,k), pat, j);
         k := k+1;
      end loop;
   end;

   procedure filset(delim in     varchar2,
                    arg   in     varchar2,
                    i     in out integer,
                    pat   in out pattern,
                    j     in out integer) is
      arglen integer;
      ch     varchar2(5); -- MAX NO OF BYTES FOR NLS CHARSET
   begin
      arglen := length(arg);

      ch := ind(arg,i);
      while (ch != delim) AND (i <= arglen)
      loop
         if (ch = ESCAPE)
         then
            addpat(esc(arg,i), pat,j);
         else if (ch != DASH)
         then
            addpat(ch, pat, j);
         else if (j <= 1) OR (i+1 >= arglen)
         then
            addpat(DASH, pat, j);
         else if (instr(DIGITS,pat(j-1)) > 0)
         then
            dodash(DIGITS, arg, i, pat, j);
         else if (instr(LOWLET, pat(j-1)) > 0)
         then
            dodash(LOWLET, arg, i, pat, j);
         else if (instr(UPPLET, pat(j-1)) > 0)
         then
            dodash(UPPLET, arg, i, pat, j);
         else         
            addpat(DASH, pat, j);
         end if;
         end if;
         end if;
         end if;
         end if;
         end if;

         i := i + 1;
         ch := ind(arg,i);
      end loop;
   end;

   procedure getccl(arg in     varchar2,
                    i   in out integer,
                    pat in out pattern,
                    j   in out integer) is
      jstart integer;
   begin
      i := i + 1; -- Skip over the "["

      if (ind(arg,i) = NOT_CHAR)
      then
         addpat(NCCL, pat, j);
         i := i + 1;
      else
         addpat(CCL, pat, j);
      end if;

      jstart := j;
      addpat(0, pat, j);
      filset(CCLEND, arg, i, pat, j);
      pat(jstart) := j - jstart - 1;
      if (ind(arg,i) != CCLEND)
      then
         raise_application_error(-20000, 'Error in getccl');
      end if;
   end;

   -- stmin_max returns FALSE if a string beginning with a '{' is not
   -- a proper {n,m} quantifier
   function stmin_max(arg     in     varchar2,
                      i       in out integer,
                      min_val    out integer,
                      max_val    out integer) return boolean
     is
      COMMA constant varchar2(1) := ',';

      arg_i varchar2(5); -- MAX NO OF BYTES FOR NLS CHARSET
      i1    integer;
      i2    integer;

      min_v integer;
   begin
      arg_i := ind(arg,i);
      if (arg_i = CLOSURE)
      then
         min_val := 0;
         max_val := NULL;
      else if (arg_i = ONE_OR_MORE)
      then
         min_val := 1;
         max_val := NULL;
      else if (arg_i = ZERO_OR_ONE)
      then
         min_val := 0;
         max_val := 1;
      else if (arg_i = QUANT)
      then
         i1 := i + 1;
         i2 := i1;

         while (instr(DIGITS, ind(arg,i2)) != 0)
         loop
            i2 := i2 + 1;
         end loop;

         min_v := substr(arg, i1, i2-i1);
         if (min_v is null) then return FALSE; end if;

         if (ind(arg,i2) = QUANTEND)
         then
            max_val := min_v;
         else if (ind(arg,i2) = COMMA)
         then
            i1 := i2 + 1;
            i2 := i1;

            while (instr(DIGITS, ind(arg,i2)) != 0)
            loop
               i2 := i2 + 1;
            end loop;

            if (ind(arg,i2) = QUANTEND)
            then
               max_val := substr(arg, i1, i2-i1);
            else
               return FALSE;
            end if;
         else
            return FALSE;
         end if;
         end if;

         min_val := min_v;
         i := i2;
      else
         raise_application_error(-20001, 'In stmin_max: illegal pattern');
      end if;
      end if;
      end if;
      end if;

      return TRUE;
   end;

   function stclos(pat     in out pattern,
                   j       in out integer,
                   lastj   in out integer, 
                   lastcl  in     integer,
                   min_val in     integer,
                   max_val in     integer) return integer is
      jp         integer;
      jt         integer;
      return_val integer;
   begin
      for jp in REVERSE lastj..j-1 
      loop
         jt := jp + CLOSIZE;
         addpat(pat(jp), pat, jt);
      end loop;

      j := j + CLOSIZE;
      return_val := lastj;

      addpat(CLOSURE, pat, lastj);
      addpat(0,       pat, lastj);
      addpat(lastcl,  pat, lastj);
      addpat(0,       pat, lastj);
      addpat(min_val, pat, lastj);
      addpat(max_val, pat, lastj);

      return return_val;
   end;

   procedure stbr(brtype  in     varchar2,
                  pat     in out pattern,
                  j       in out integer,
                  lastbr  in out integer,
                  var     in out integer) is
      -- "var" will be either "brno" if we are on a "("
      --   or it will be "openbr" if we are on a ")"
   begin
      addpat(brtype, pat, j);
      addpat(lastbr, pat, j);
      addpat(0,      pat, j);

      -- var is "brno" increment it before inserting the value.
      if (brtype = BR)
      then
         var := var + 1;
      end if;

      addpat(var, pat, j);
      lastbr := j - BRSIZE;

      -- var is "openbr" - find the last unmatched openbr.
      if (brtype = BREND)
      then
         var := pat(var + PREVBR_IND);

         while (var > 0) AND (pat(var) != BR)
         loop
            var := pat(var + OPENBR_IND);
            var := pat(var + PREVBR_IND);
         end loop;
      end if;
   end;

   /* ESCPAT is an enhancement to Kernighan's algorithms.  It allows */
   /* more "short-cut" tags in the pattern, such as using '\d' for   */
   /* [0-9].  This is to extend the algorithms to support more of    */
   /* Perl's regular expression patterns.                            */
   procedure escpat(arg in     varchar2,
                    i   in out integer,
                    pat in out pattern,
                    j   in out integer) is
      HEXCHAR   constant varchar2(1) := 'x';
      HEXDIGITS constant varchar2(22) := DIGITS||'abcdefABCDEF';
      OCTDIGITS constant varchar2(8) := '01234567';
   begin
      if (ind(arg,i) != ESCAPE)
      then
         addpat(CHARCHAR, pat, j);
         addpat(ind(arg,i), pat, j);
      else if (ind(arg,i+1) in (DIG_ESCAPE_CHAR, NON_DIG_ESCAPE_CHAR,
                                WORD_ESCAPE_CHAR, NON_WORD_ESCAPE_CHAR,
                                SPACE_ESCAPE_CHAR, NON_SPACE_ESCAPE_CHAR,
                                BOUND_ESCAPE_CHAR, NON_BOUND_ESCAPE_CHAR))
      then
         addpat(ESCAPE||ind(arg,i+1), pat, j);
         i := i + 1;
      else if ((ind(arg,i+1) = HEXCHAR) AND
               (instr(HEXDIGITS, ind(arg,i+2)) != 0) AND
               (instr(HEXDIGITS, ind(arg,i+3)) != 0)
              )
      then
         addpat(CHARCHAR, pat, j);
         addpat(chr(base_convert(substr(arg,i+2,2), 16)), pat, j);
         i := i + 3;
      else if ((instr(OCTDIGITS, ind(arg,i+1)) != 0) AND
               (instr(OCTDIGITS, ind(arg,i+2)) != 0)
              )
      then
         if (instr(OCTDIGITS, ind(arg,i+3)) != 0)
         then
            addpat(CHARCHAR, pat, j);
            addpat(chr(base_convert(substr(arg,i+1,3), 8)), pat, j);
            i := i + 3;
         else
            addpat(CHARCHAR, pat, j);
            addpat(chr(base_convert(substr(arg,i+1,2), 8)), pat, j);
            i := i + 2;
         end if;
      else
         addpat(CHARCHAR, pat, j);
         addpat(esc(arg,i), pat, j);
      end if;
      end if;
      end if;
      end if;
   end;

   /* GETPAT is a merge of the "getpat" and "makpat" functions which */
   /* Kernighan details.  The additional level of abstraction which  */
   /* makpat provides is unnecessary in this implementation.         */
   procedure getpat(arg in varchar2, pat in out pattern) is
      arglen integer;

      i integer;
      j integer;

      lastcl integer;
      lastj  integer;
      lj     integer;

      lastbr integer;
      openbr integer;
      brno   integer;

      arg_i varchar2(5); -- MAX NO OF BYTES FOR NLS CHARSET

      min_val integer;
      max_val integer;
   begin
      arglen := length(arg);

      j := 1;
      lastj  := 1;
      lastcl := 0;
      lastbr := 0;
      openbr := 0;
      brno   := 0;

      i := 1;
      while (i <= arglen)
      loop
         lj := j;

         arg_i := ind(arg,i);
         if (arg_i = ANY_CHAR)
         then
            addpat(ANY_CHAR, pat, j);
         else if (arg_i = BOL) AND (i = 1)
         then
            addpat(BOL, pat, j);
         else if (arg_i = EOL) AND (i = arglen)
         then
            addpat(EOL, pat, j);
         else if (arg_i = CCL)
         then
            getccl(arg, i, pat, j);
         else if (arg_i in (CLOSURE, ZERO_OR_ONE,
                            ONE_OR_MORE, QUANT)) AND (i > 1)
         then
            lj := lastj;
            if (pat(lj) NOT in (BOL, EOL, CLOSURE, ZERO_OR_ONE,
                                          ONE_OR_MORE, QUANT))
            then
               if (stmin_max(arg, i, min_val, max_val))
               then
                  lastcl := stclos(pat, j, lastj, lastcl, min_val, max_val);
               else
                  escpat(arg, i, pat, j);
               end if;
            else
               raise_application_error(-20000,arg||': nested *?+ in regular expression');
            end if;
         else if (arg_i = BR)
         then
            openbr := j;
            stbr(BR, pat, j, lastbr, brno);
         else if (arg_i = BREND)
         then
            if (openbr = 0)
            then
               raise_application_error(-20000,arg||': unmatched () in regular expression');
            end if;

            stbr(BREND, pat, j, lastbr, openbr);
         else
            escpat(arg, i, pat, j);
         end if;
         end if;
         end if;
         end if;
         end if;
         end if;
         end if;

         lastj := lj;
         i := i+1;
      end loop;

      if (openbr != 0)
      then
         raise_application_error(-20000,arg||': unmatched () in regular expression');
      end if;

      addpat(EOP, pat, j);
   end;

   procedure printpat(pat in pattern) is
      i integer;
   begin
      i := 1;
      while pat(i) != EOP
      loop
         dbms_output.put_line('pat('||i||') = '||pat(i));
         i := i+1;
      end loop;
   end;

   /* LOCATE - Determine if character 'ch' is in the character class */
   /*          found at pat(offset).                                 */
   function locate(ch in varchar2, pat    in pattern,
                                   offset in integer) return boolean is
   begin
      -- Fix 611104
      --   pat(offset) has #of chars in character class
      for i in REVERSE (offset + 1)..offset+pat(offset) 
      loop
         if (ch = pat(i))
         then
            return TRUE;
         end if;
      end loop;

      return FALSE;
   end;

   function is_word_char(ch in varchar2) return boolean
     is
   begin
      return (instr (DIGITS||LOWLET||'_'||UPPLET, ch) != 0);
   end;

   function omatch(line  in     varchar2,
                   i     in out integer,
                   pat   in     pattern,
                   j     in     integer,
                   flags in     varchar2 DEFAULT NULL) return boolean is
      bump   integer;
      line_i varchar2(5); -- MAX NO OF BYTES FOR NLS CHARSET
      pat_j  varchar2(4);

      save_i integer;
   begin
      bump := -1;
      line_i := ind(line,i);
      pat_j  := pat(j);

      if (pat_j = CHARCHAR)
      then
         /* Here is a simple extension to add case-insensitive searches. */
         /* This is the easiest place to put this, although it may not   */
         /* be the most efficient location for it.                       */
         if /* (flags is not null) AND */ (instr(flags,'i') != 0)
         then
            if (lower(line_i) = lower(pat(j+1)))
            then
               bump := 1;
               in_b := FALSE;
            end if;
         else
            if (line_i = pat(j+1))
            then
               bump := 1;
               in_b := FALSE;
            end if;
         end if;
      else if (pat_j = BOL)
      then
         if ( (i = 1) OR (ind(line,i-1) = NEWLINE) )
         then
            bump := 0;
            in_b := FALSE;
         end if;
      else if (pat_j = ANY_CHAR)
      then
         if (line_i != NEWLINE)
         then
            bump := 1;
            in_b := FALSE;
         end if;
      else if (pat_j = EOL)
      then
         if (line_i = NEWLINE) OR (i > length(line))
         then
            bump := 0;
            in_b := FALSE;
         end if;
      else if (pat_j = BOUND_ESCAPE)
      then
         if ( i = 1 ) OR (i > length(line))
         then
            bump := 0;
            in_b := TRUE;
         else
         if ( ( is_word_char(line_i) AND
                NOT is_word_char(ind(line,i-1)) )
            OR
              ( is_word_char(ind(line,i-1)) AND
                NOT is_word_char(line_i) ) )
         then
            bump := 0;
            in_b := TRUE;
         end if;
         end if;
      else if (pat_j = DIG_ESCAPE)
      then
         if (instr(DIGITS, line_i) != 0)
         then
            bump := 1;
            in_b := FALSE;
         end if;
      else if (pat_j = NON_DIG_ESCAPE)
      then
         if (instr(DIGITS, line_i) = 0)
         then
            bump := 1;
            in_b := FALSE;
         end if;
      else if (pat_j = WORD_ESCAPE)
      then
         if (instr(WORD_CHARS, line_i) != 0)
         then
            bump := 1;
            in_b := FALSE;
         end if;
      else if (pat_j = NON_WORD_ESCAPE)
      then
         if (instr(WORD_CHARS, line_i) = 0)
         then
            bump := 1;
            in_b := FALSE;
         end if;
      else if (pat_j = SPACE_ESCAPE)
      then
         if (instr(SPACE_CHARS, line_i) != 0)
         then
            bump := 1;
            in_b := FALSE;
         end if;
      else if (pat_j = NON_SPACE_ESCAPE)
      then
         if (instr(SPACE_CHARS, line_i) = 0)
         then
            bump := 1;
            in_b := FALSE;
         end if;
      else if (pat_j = CCL)
      then
         if (locate(line_i, pat, j+1) = TRUE)
         then
            bump := 1;
            in_b := FALSE;
         end if;
      else if (pat_j = NCCL)
      then
         if (line_i != NEWLINE) AND (locate(line_i, pat, j+1) = FALSE)
         then
            bump :=1;
            in_b := FALSE;
         end if;
      else
         raise_application_error(-20001,'In omatch: illegal pattern found');
      end if;
      end if;
      end if;
      end if;
      end if;
      end if;
      end if;
      end if;
      end if;
      end if;
      end if;
      end if;
      end if;

      if (bump >= 0)
      then
         i := i + bump;
         return TRUE;
      else
         /* We just validated a word-boundary match the last time through. */
         /* Here we chew up as much whitespace as is necessary.            */
         if (in_b)
         then
            if (NOT is_word_char(ind(line,i)))
            then
               save_i := i;
               i := i + 1;
               if (omatch(line, i, pat, j, flags) = TRUE)
               then
                  in_b := FALSE;
                  return TRUE;
               else
                  i := save_i;
                  in_b := FALSE;
                  return FALSE;
               end if;
            end if;
            in_b := FALSE;
         end if;
      end if;

      return FALSE;
   end;

   procedure clo_backoff(pat    in out pattern,
                         j      in out integer,
                         stack  in out integer,
                         offset in out integer) is
   begin
      while (stack > 0) AND
            (pat(stack+COUNT_IND) <= pat(stack+MIN_IND))
      loop
         stack := pat(stack + PREVCL_IND);
      end loop;

      if (stack > 0)
      then
         pat(stack + COUNT_IND) := pat(stack + COUNT_IND) - 1;
         j := stack + CLOSIZE;
         offset := pat(stack + START_IND) + pat(stack + COUNT_IND);
      end if;
   end;

   procedure br_backoff(pat    in out pattern,
                        j      in     integer,
                        lastbr in out integer) is
   begin
      while (lastbr > j)
      loop
         pat(lastbr + LOC_IND) := 0;
         lastbr := pat(lastbr + PREVBR_IND);
      end loop;
   end;

   function amatch(line     in     varchar2,
                   from_loc in     integer,
                   pat      in out pattern,
                   backrefs    out owa_text.vc_arr,
                   flags    in     varchar2 DEFAULT NULL) return integer is
      i      integer;
      j      integer;
      offset integer;
      stack  integer;

      openbr integer;
      lastbr integer;
   begin
      lastbr := 0;
      stack := 0;
      offset := from_loc;

      j := 1;
      while (pat(j) != EOP)
      loop
         if (pat(j) = CLOSURE)
         then
            stack := j;
            j := j + CLOSIZE;

            i := offset;
            if (pat(stack + MAX_IND) is NULL)
            then
               while (i <= length(line)) AND
                     (omatch(line, i, pat, j, flags) = TRUE)
               loop null;
               end loop;
            else
               while (i <= length(line)) AND
                     (i - offset < pat(stack + MAX_IND)) AND
                     (omatch(line, i, pat, j, flags) = TRUE)
               loop null;
               end loop;
            end if;

            -- Check if we matched enough values.  If not, then back off.
            if ((i - offset) >= pat(stack + MIN_IND))
            then
               pat(stack + COUNT_IND) := i - offset;
               pat(stack + START_IND) := offset;
               offset := i;
            else
               j := stack;
               stack := pat(stack + PREVCL_IND);

               clo_backoff(pat, j, stack, offset); 
               br_backoff(pat, j, lastbr);
               if (stack <= 0) then return 0; end if;
           end if;
         else if (pat(j) in (BR, BREND))
         then
            pat(j + LOC_IND) := offset;
            lastbr := j;
         else if (omatch(line, offset, pat, j, flags) = FALSE)
         then
            clo_backoff(pat, j, stack, offset);
            br_backoff(pat, j, lastbr);
            if (stack <= 0) then return 0; end if;
         end if;
         end if;
         end if;

         j := j + patsize(pat,j);
      end loop;

      while (lastbr > 0)
      loop
         if (pat(lastbr) = BREND)
         then
            openbr := pat(lastbr + OPENBR_IND);

            backrefs(pat(openbr+BRNO_IND)) := 
               substr(line, to_number(pat(openbr+LOC_IND)),
                            to_number(pat(lastbr+LOC_IND)) 
	                    - to_number(pat(openbr+LOC_IND)));
         end if;

         lastbr := pat(lastbr+PREVBR_IND);
      end loop;

      return offset;
   end;

   function amatch(line     in     varchar2,
                   from_loc in     integer,
                   pat      in     varchar2,
                   backrefs    out owa_text.vc_arr,
                   flags    in     varchar2 DEFAULT NULL) return integer is
      p pattern;
   begin
      getpat(pat, p);     
      return amatch(line, from_loc, p, backrefs, flags);
   end;

   function amatch(line     in     varchar2,
                   from_loc in     integer,
                   pat      in out pattern,
                   flags    in     varchar2 DEFAULT NULL) return integer is
      backrefs owa_text.vc_arr;
   begin
      return amatch(line, from_loc, pat, backrefs, flags);
   end;

   function amatch(line     in varchar2,
                   from_loc in integer,
                   pat      in varchar2,
                   flags    in varchar2 DEFAULT NULL) return integer is
      p pattern;
   begin
      getpat(pat, p);     
      return amatch(line, from_loc, p, flags);
   end;

   function match(line     in     varchar2,
                  pat      in out pattern,
                  backrefs    out owa_text.vc_arr,
                  flags    in     varchar2 DEFAULT NULL) return boolean is
   begin
      for i in 1..line_len(line)
      loop
         if (amatch(line, i, pat, backrefs, flags) > 0)
         then return TRUE;
         end if;
      end loop;

      return FALSE;
   end;

   function match(line     in     varchar2,
                  pat      in     varchar2,
                  backrefs    out owa_text.vc_arr,
                  flags    in     varchar2 DEFAULT NULL) return boolean is
      p pattern;
   begin
      getpat(pat, p);     
      return match(line, p, backrefs, flags);
   end;

   function match(line  in     varchar2,
                  pat   in out pattern,
                  flags in     varchar2 DEFAULT NULL) return boolean is
      backrefs owa_text.vc_arr;
   begin
      return match(line, pat, backrefs, flags);
   end;

   function match(line  in varchar2,
                  pat   in varchar2,
                  flags in varchar2 DEFAULT NULL) return boolean is
      p pattern;
   begin
      getpat(pat, p);     
      return match(line, p, flags);
   end;

   function match(mline  in     owa_text.multi_line, 
                  pat    in out pattern,
                  rlist     out owa_text.row_list,
                  flags  in     varchar2 DEFAULT NULL) return boolean is
      temp_rlist owa_text.row_list;
   begin
      temp_rlist := owa_text.new_row_list;

      for i in 1..mline.num_rows
      loop
         if match(mline.rows(i), pat, flags)
         then
            temp_rlist.num_rows := temp_rlist.num_rows + 1;
            temp_rlist.rows(temp_rlist.num_rows) := i;
         end if;
      end loop;

      rlist := temp_rlist;

      return temp_rlist.num_rows > 0;
   end;

   function match(mline in     owa_text.multi_line,
                  pat   in     varchar2,
                  rlist    out owa_text.row_list,
                  flags in     varchar2 DEFAULT NULL) return boolean is
      p pattern;
   begin
      getpat(pat,p);
      return match(mline, p, rlist, flags);
   end;


   procedure catsub(line     in     varchar2,
                    from_loc in     integer,
                    to_loc   in     integer,
                    sub      in     substitution,
                    backrefs in     owa_text.vc_arr,
                    new      in out varchar2) is
      i integer;
      j integer;
   begin
      i := 1;
      while (sub(i) != EOP)
      loop
         if (sub(i) = DITTO)
         then
            new := new||substr(line,from_loc,to_loc - from_loc);
         else if (sub(i) = BREF)
         then
            i := i + 1;
            new := new||backrefs(sub(i));
         else
            new := new||sub(i);
         end if;
         end if;

         i := i + 1;
      end loop;
   end;

   procedure escsub(arg in     varchar2,
                    i   in out integer,
                    sub in out substitution,
                    j   in out integer) is
   begin
      if (ind(arg,i) != ESCAPE)
      then
         addpat(ind(arg,i), sub, j);
      else if (instr(DIGITS, ind(arg,i+1)) != 0)
      then
         addpat(BREF, sub, j);
         i := i + 1;
         addpat(get_int(arg, i), sub, j);
         i := i - 1; -- get_int puts i up past the last digit.
      else
         addpat(esc(arg,i), sub, j);
      end if;
      end if;
   end;

   procedure getsub(arg in varchar2, sub out substitution)  is
      i integer;
      j integer;
      s substitution;
   begin
      j := 1;
      i := 1;
      while (i <= length(arg))
      loop
         if ind(arg,i) = AMP
         then
            addpat(DITTO, s, j);
         else
            escsub(arg, i, s, j);
         end if;

         i := i + 1;
      end loop;

      addpat(EOP, s, j);
      sub := s;
   end;

   function change(line     in out varchar2,
                   from_str in     varchar2,
                   to_str   in     varchar2,
                   flags    in     varchar2 DEFAULT NULL) return integer is
      p     pattern;
      s     substitution;
      i     integer;
      m     integer;
      lastm integer;
      new   varchar2(32767); -- MAX_VC_LEN

      backrefs owa_text.vc_arr;

      num_matches integer;
   begin
      getpat(from_str,p);
      getsub(to_str,s);

      num_matches := 0;
      lastm := 0;
      i := 1;
      while (i <= line_len(line))
      loop
         m := amatch(line, i , p, backrefs, flags);
         if (m > 0) AND (lastm != m)
         then
            num_matches := num_matches + 1;
            catsub(line, i, m, s, backrefs, new);

            /* New code make the default behavior to be change 1st match. */
            /* Enhancement to Kernighan's code.                           */
            if (flags IS NULL) OR (instr(flags,'g') = 0)
            then
               new := new||substr(line,m);
               exit;
            end if;
            /* End enhancement code */

            lastm := m;
         end if;

         if (m in (0,i))
         then
            new := new||ind(line,i);
            i := i + 1;
         else
            i := m;
         end if;
      end loop;

      line := new;
      return num_matches;
   end;

   procedure change(line     in out varchar2,
                    from_str in     varchar2,
                    to_str   in     varchar2,
                    flags    in     varchar2 DEFAULT NULL) is
      ignore integer;
   begin
      ignore := change(line, from_str, to_str, flags);
   end;

   function change(mline    in out owa_text.multi_line,
                   from_str in     varchar2,
                   to_str   in     varchar2,
                   flags    in     varchar2 DEFAULT NULL) return integer is
      num_matches integer;
   begin
      num_matches := 0;

      for i in 1..mline.num_rows
      loop
         num_matches := num_matches + 
                          change(mline.rows(i), from_str, to_str, flags);
      end loop;

      return num_matches;
   end;

   procedure change(mline     in out owa_text.multi_line,
                    from_str in     varchar2,
                    to_str   in     varchar2,
                    flags    in     varchar2 DEFAULT NULL) is
      ignore integer;
   begin
      ignore := change(mline, from_str, to_str, flags);
   end;

end;
/
show errors
