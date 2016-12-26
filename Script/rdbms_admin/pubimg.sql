rem
rem
Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      pubimg.sql
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_image - Utitility procedures/functions for handling image
Rem                     map (x,y) coordinates.
Rem
Rem    NOTES
Rem      This package allows the developer to easily handle clickable
Rem      image input using the Oracle Web Agent.
Rem
Rem      When a user clicks on an image (suppose the NAME field of the image
Rem      is "IMG") and the action of that image is to call the Web Agent, 
Rem      the Web Agent will take the two values, IMG.X and IMG.Y and turn
Rem      them into a "POINT".  The web developer can then access the x,y
Rem      values as follows:
Rem
Rem      create or replace procedure process_img(img in OWA_IMAGE.POINT) is
Rem         x integer := OWA_IMAGE.GET_X(img);
Rem         y integer := OWA_IMAGE.GET_Y(img);
Rem      begin
Rem         /* You've got x and y.  Do whatever you like. */
Rem      end;
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     mbookman   03/13/96 -  Add NULL_POINT
Rem     mbookman   12/14/95 -  Creation

create or replace package OWA_IMAGE is

   /* The Web Agent can only pass PL/SQL tables of characters, */
   /* but technically, this should be integers.                */
   /* PL/SQL will take care of the casting of values.          */
   type point is table of varchar2(32767) index by binary_integer;

   NULL_POINT point;

   function get_x(p in point) return integer;
   function get_y(p in point) return integer;

   PRAGMA RESTRICT_REFERENCES(get_x, WNDS, WNPS, RNDS, RNPS);
   PRAGMA RESTRICT_REFERENCES(get_y, WNDS, WNPS, RNDS, RNPS);

   PRAGMA RESTRICT_REFERENCES(owa_image, WNDS, RNDS,       RNPS);

end;
/
show errors

