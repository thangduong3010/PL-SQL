rem
rem
Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      privimg.sql
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_image - Utitility procedures/functions for handling image
Rem                     map (x,y) coordinates.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     mbookman   03/13/96 -  Add NULL_POINT
Rem     mbookman   12/14/95 -  Creation

create or replace package body OWA_IMAGE is

   function get_x(p in point) return integer is
   begin
      return(p(1));
   end;

   function get_y(p in point) return integer is
   begin
      return(p(2));
   end;

/* Package initialization */
begin
   NULL_POINT(1) := NULL;
   NULL_POINT(2) := NULL;
end;
/
show errors
