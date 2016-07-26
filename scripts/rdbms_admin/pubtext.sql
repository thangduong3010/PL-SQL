rem
rem
Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      pubtext.sql
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_text - Utitility procedures/functions for manipulating
Rem                       large amounts of text.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     mbookman   11/29/95 -  Creation

create or replace package OWA_TEXT is

   /*
   The package OWA_TEXT provides an utility functions for handling
   large amounts of text.  These utilities mainly provide the ability
   to turn a single stream of text into an array of individual lines.
   These utilities are primarily used by the OWA_PATTERN package,
   but may also be used independently.
   */

   type vc_arr is table of varchar2(32767) index by binary_integer;
   type int_arr is table of integer index by binary_integer;

   /* A multi_line is just an abstract datatype which can hold */
   /* large amounts of text data as one piece.                 */
   type multi_line is record
   (
      rows        vc_arr,
      num_rows    integer,
      partial_row boolean
   );

   /* row_list is used to contain a list of "interesting" rows */
   type row_list is record
   (
      rows        int_arr,
      num_rows    integer
   );

   /* Standard "make element" routines. */
   function  new_multi return multi_line;
   procedure new_multi(mline out multi_line);

   /* STREAM2MULTI takes in a single stream of text and will turn */
   /* it into a multi_line structure.                             */
   procedure stream2multi(stream in varchar2, mline out multi_line);
   /* ADD2MULTI allows you to easily add new text to a multi-line */
   /* structure.                                                  */
   procedure add2multi(stream   in     varchar2,
                       mline    in out multi_line,
                       continue in     boolean DEFAULT TRUE);

   /* PRINT_MULTI uses HTP.PRINT to print out a multi-line structure */
   procedure print_multi(mline in multi_line);

   /* For manipulating row_list structures - standard creation routines */
   function  new_row_list return row_list;
   procedure new_row_list(rlist out row_list);

   /* Print a row list using HTP.PRINT */
   procedure print_row_list(rlist in row_list);

end;
/
show errors
