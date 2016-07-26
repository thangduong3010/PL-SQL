Rem
Rem $Header: owadummy.sql 16-feb-2001.19:27:01 kmuthukk Exp $
Rem
Rem owadummy.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      owadummy.sql - OWA dummy file
Rem
Rem    DESCRIPTION
Rem
Rem      This file does nothing in particular; it simply enables 
Rem      use to conditionally install OWA packages.
Rem
Rem      This dummy file is created because SQL*Plus doesn't allow
Rem      an elegant way to "conditionally" load a file.
Rem
Rem      owainst.sql decides if it needs to install OWA packages.
Rem       - if yes, it loads "@owacomm.sql"; 
Rem       - if no,  it loads "@owadummy.sql" as a no-op essentially.
Rem
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kmuthukk    04/27/01 - Created
Rem


Rem **
Rem ** OWA pkgs already in the system correspond to a higher verison.
Rem ** Therefore, not reinstalling OWA pkgs.........
Rem ** 
