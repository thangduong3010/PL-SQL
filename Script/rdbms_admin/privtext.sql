rem
rem
Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      privtext.sql
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_text - Utitility procedures/functions for manipulating
Rem                       large amounts of text.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     mbookman   11/29/95 -  Creation

create or replace package body OWA_TEXT is

   NL_CHAR constant varchar2(1) := '
';

   function new_multi return multi_line
      is
     new multi_line;
   begin
      new.num_rows := 0;
      new.partial_row := FALSE;

      return new;
   end;

   procedure new_multi(mline out multi_line)
      is
   begin
      mline := new_multi;
   end;

   procedure stream2multi(stream in varchar2, mline out multi_line)
    is
      temp_multi multi_line;
   begin
      /* Initialize the structure */
      temp_multi := new_multi;

      if (stream is not null)
      then
         /* Add the new stream */
         add2multi(stream, temp_multi, FALSE);
      end if;

      mline := temp_multi;
   end;

   procedure add2multi(stream   in     varchar2,
                       mline    in out multi_line,
                       continue in     boolean DEFAULT TRUE)
    is
      row_start integer;
      row_end   integer;

      prev_partial boolean;
   begin
      /* Save the previous value of partial_row */
      prev_partial := mline.partial_row;

      /* Get the boundaries of the first row to add */
      row_start := 1;
      row_end := instr(stream, NL_CHAR, row_start);
      mline.partial_row := (row_end = 0);

      /* If the previous last row was incomplete, */
      /* handle first new as a special case       */
      if ( (prev_partial = TRUE) AND (continue = TRUE) )
      then
         /* Check the length to avoid "PL/SQL numeric or value error" */
         if ( (length(mline.rows(mline.num_rows)) + (row_end - row_start))
               > 32767 ) -- MAX_VC_LEN
         then
            raise_application_error(-20000, 'Cannot create row larger than 32767 bytes');
         end if;

         /* Length is okay, so append it. */
         if (mline.partial_row = TRUE)
         then
            mline.rows(mline.num_rows) := mline.rows(mline.num_rows) ||
                                                     substr(stream, row_start);
            /* We're done, just exit */
            return;
         else
            mline.rows(mline.num_rows) := mline.rows(mline.num_rows) ||
                                substr(stream, row_start, row_end - row_start);

            /* Get the next chunk */
            row_start := row_end + 1;
            row_end := instr(stream, NL_CHAR, row_start);
            if ( (row_end = 0) AND (row_start <= length(stream)) )
            then
               mline.partial_row := TRUE;
            end if;
         end if;
      end if;

      /* Loop through pulling out the lines */
      while ( (row_end >= row_start) AND (mline.partial_row = FALSE) )
      loop
         mline.num_rows := mline.num_rows + 1;
         mline.rows(mline.num_rows) := substr(stream, row_start,
                                              row_end - row_start);
         row_start := row_end + 1;
         row_end := instr(stream, NL_CHAR, row_start);
         if ( (row_end = 0) AND (row_start <= length(stream)) )
         then
            mline.partial_row := TRUE;
         end if;
      end loop;

      /* Get the last line if it is partial */
      if (mline.partial_row = TRUE)
      then
         mline.num_rows := mline.num_rows + 1;
         mline.rows(mline.num_rows) := substr(stream, row_start);
      end if;
   end;

   procedure print_multi(mline in multi_line)
      is
   begin
      for i in 1..mline.num_rows
      loop
         htp.print(mline.rows(i));
      end loop;
   end;

   function  new_row_list return row_list
       is
      new row_list;
   begin
      new.num_rows := 0;
      return new;
   end;

   procedure new_row_list(rlist out row_list)
      is
   begin
      rlist := new_row_list;
   end;

   procedure print_row_list(rlist in row_list)
      is
   begin
      for i in 1..rlist.num_rows
      loop
         htp.print(rlist.rows(i));
      end loop;
   end;

   /* Just a debugging routine */
   procedure print_debug(mline in multi_line)
      is
   begin
      htp.print(mline.num_rows);
      if mline.partial_row
         then htp.print('PARTIAL ROW');
         else htp.print('NO PARTIAL ROW');
      end if;

      for i in 1..mline.num_rows
      loop
         htp.print(mline.rows(i));
      end loop;
   end;
end;
/
show errors
