rem
rem
Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      pubpat.sql
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_pattern - Utitility procedures/functions for matching 
Rem                       and changing values in text strings.
Rem
Rem    NOTES
Rem      This packages is dependent on the package OWA_TEXT.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     mbookman   11/29/95 -  Creation

create or replace package OWA_PATTERN is

   /*
   The package OWA_PATTERN is a "regular expression" pattern matching
   package.  There are 3 fundamental subprograms in OWA_PATTERN.
   The are: AMATCH, MATCH, and CHANGE.  

   MATCH provides the ability to determine *if* a pattern exists in a 
   string.

   AMATCH provides more flexibilty to specify *WHERE* in the string to
   search for the pattern and also gives more information in return by
   indicating *WHERE* in the string the end of the pattern was found.

   CHANGE provides the ability to change occurances of a matched pattern
   to a new string.

   The algorithms used here are derived from "Software Tools" by Brian
   Kernighan.  These algorithms have been extended to support most of
   Perl's pattern matching functionality.

   The regular expression elements that are supported are:

   Assertions:
   ----------
   ^ Matches the beginning of a line (or string)
   $ Matches the end of a line (or string)

   Quantifiers:
   -----------
   {n,m} Must match at least n times, but not more than m times
    {n,} Must match at least n times
     {n} Must match exactly n times.
       * 0 or more occurances
       + 1 or more occurances
       ? 0 or 1 occurance(s)

   Legal atoms:
   -----------
   . matches any character except \n

   A list of characters in square brackets [] is a class of characters,
   for example [0-9] indicates match any character from 0 to 9.

   \n matches newlines
   \t matches tabs
   \d matches digits [0-9]
   \D matches non-digits [^0-9]
   \w matches word characters (alphanumeric) [0-9a-z_A-Z]
   \W matches non-word characters [^0-9a-z_A-Z]
   \s matches whitespace characters [ \t\n]
   \S matches non-whitespace characters [^ \t\n]
   \b matches on "word" boundaries (between \w and \W)

   A backslashed x followed by two hexadecimal digits, such as \x7f,
   matches the character having that hexadecimal value.

   A backslashed 2 or 3 digit octal number such as \033 matches the 
   character with the specified value.

   Any other "backslashed" character matches itself.

   Valid flags passed to CHANGE, MATCH, AMATCH:
   -------------------------------------------
   i - perform pattern matching in a case-insensitive manner.
   g - perform all changes globally (all occurances)

   Replacements
   ------------
   ampersand can be used in the substitution string to "re-place" that which
   has been matched.

   For example: change('Oracle 7.1.3', '\d\.\d\.\d', 'Version &');

                yields: Oracle Version 7.1.3

   \<n> can be used to do backreferences, meaning to replace portions of
      the matched string:

      change('Matt Bookman','(Matt) (Bookman)','\2, \1')
          --> Bookman, Matt

   Match Extraction
   ----------------
   One can extract the matched values from the parenthesized patterns,
   for example:

   declare
      string     varchar2(32767);
      components owa_text.vc_arr;
   begin
      string := 'Today is 01/04/72';
      if (owa_pattern.match(string, '(\d\d)/(\d\d)/(\d\d)', components))
      then
         htp.print('The month is '||components(1));
         htp.print('The day is '||components(2));
         htp.print('The year is '||components(3));
      end if;
   end;      

   Possible future enhancements:
   -----------------------------
   * \B - match on non-"word" boundaries (between \w and \w, or \W and \W)

   * "or" character matches:
       change(text,'(Unix|unix)','UNIX') would change both occurances

   * Using control character references:

        A backslashed c followed by a single character, such as \cD, matches
        the corresponding control character.

   -- No support for:
   --   \b == Backspace (in a character class)
   --   \r == Carriage return
   --   \f == Form feed
   -- Modified support for:
   --   \s == A whitespace charcter -> [ \t\n\r\f]
   --   \S == A non-whitespace character

   */

   type pattern is table of varchar2(4) index by binary_integer;
   /* pattern must be able to hold a value for "Character Classes"
      indicating the number of items in that character class.  For
      single-byte character sets, which this currently supports, 
      there are no more than 256 characters. */

   procedure getpat(arg in varchar2, pat in out pattern);

   /* The easiest to use of the "match" functions is the first.  */
   /* The second one would be used in the case where you wanted   */
   /* to perform some optimizations and you were matching against */
   /* the same pattern repeatedly.  You could use getpat to build */
   /* the pattern, then call match (2nd version) and amatch       */
   /* repeatedly.                                                 */ 
   function match(line  in varchar2, 
                  pat   in varchar2,
                  flags in varchar2 DEFAULT NULL) return boolean;
   function match(line  in     varchar2,
                  pat   in out pattern,
                  flags in     varchar2 DEFAULT NULL) return boolean;

   function match(line  in        varchar2, 
                  pat   in        varchar2,
                  backrefs    out owa_text.vc_arr,
                  flags in        varchar2 DEFAULT NULL) return boolean;
   function match(line     in     varchar2,
                  pat      in out pattern,
                  backrefs    out owa_text.vc_arr,
                  flags    in     varchar2 DEFAULT NULL) return boolean;

   /* Parameters to MATCH */
   /* line  - Any text string.                                       */
   /* pat   - In the first call, pat is a regular expression.        */
   /*         In the second, pat has been generated by getpat.       */
   /* flags - only valid value currently is 'i' for case-insensitive */
   /*         searches.                                              */

   /* Function returns whether or not a match was made.              */

   /* The following MATCH functions perform matches on multi-line text */
   /* objects.                                                         */
   function match(mline  in     owa_text.multi_line, 
                  pat    in     varchar2,
                  rlist     out owa_text.row_list,
                  flags  in     varchar2 DEFAULT NULL) return boolean;
   function match(mline  in     owa_text.multi_line,
                  pat    in out pattern,
                  rlist     out owa_text.row_list,
                  flags  in     varchar2 DEFAULT NULL) return boolean;

   /* AMATCH */
   function amatch(line     in varchar2,
                   from_loc in integer,
                   pat      in varchar2,
                   flags    in varchar2 DEFAULT NULL) return integer;
   function amatch(line     in     varchar2,
                   from_loc in     integer,
                   pat      in out pattern,
                   flags    in     varchar2 DEFAULT NULL) return integer;

   function amatch(line     in     varchar2,
                   from_loc in     integer,
                   pat      in     varchar2,
                   backrefs    out owa_text.vc_arr,
                   flags    in     varchar2 DEFAULT NULL) return integer;
   function amatch(line     in     varchar2,
                   from_loc in     integer,
                   pat      in out pattern,
                   backrefs    out owa_text.vc_arr,
                   flags    in     varchar2 DEFAULT NULL) return integer;

   /* Parameters to AMATCH */
   /* line  - Any text string.                                        */
   /* from_loc - Indicates the index of the first character in "line" */
   /*            to try to match.                                     */
   /* pat   - See MATCH above.                                        */
   /* flags - See MATCH above.                                        */

   /* Function returns the index of the first character after the end */
   /* of the match.                                                   */

   function change(line     in out varchar2,
                   from_str in     varchar2,
                   to_str   in     varchar2,
                   flags    in     varchar2 DEFAULT NULL) return integer;

   procedure change(line     in out varchar2,
                    from_str in     varchar2,
                    to_str   in     varchar2,
                    flags    in     varchar2 DEFAULT NULL);

   /* Parameters to CHANGE */
   /* line     - Any text string.                                     */
   /* from_str - The regular expression to match in "line".           */
   /* to_str   - The substitution pattern to replace "from_str"       */
   /* flags    - i - case-insensitive search                          */
   /*            g - make changes "g"lobally - each occurance.        */
   /*            By default CHANGE quits after the first match.       */
   /* Function returns the number of matches made.                    */

   function change(mline    in out owa_text.multi_line,
                   from_str in     varchar2,
                   to_str   in     varchar2,
                   flags    in     varchar2 DEFAULT NULL) return integer;

   procedure change(mline    in out owa_text.multi_line,
                    from_str in     varchar2,
                    to_str   in     varchar2,
                    flags    in     varchar2 DEFAULT NULL);

   /* Parameters to CHANGE */
   /* mline    - A multi-line structure containing text strings.      */
   /* from_str - The regular expression to match in "mline".          */
   /* to_str   - The substitution pattern to replace "from_str"       */
   /* flags    - i - case-insensitive search                          */
   /*            g - make changes "g"lobally - each occurance.        */
   /*            By default CHANGE quits after the first match on     */
   /*            each line.                                           */
   /* Function returns the number of matches made.                    */

end;
/
show errors
