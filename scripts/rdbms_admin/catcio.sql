Rem
Rem $Header: catcio.sql 03-jul-2003.15:28:31 arithikr Exp $
Rem
Rem catcio.sql
Rem
Rem Copyright (c) 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catcio.sql - Create sys.Index_Online$ table
Rem
Rem    DESCRIPTION
Rem      This SQL script is used to create the sys.ind_online$ table
Rem      in the event user run into ORA-08120. 
Rem
Rem    NOTES
Rem      Must be run when connected AS SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    arithikr    07/03/03 - arithikr_bug-1486580
Rem    arithikr    07/01/03 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

create table ind_online$
( obj#          number not null,
  type#         number not null,              /* what kind of index is this? */
                                                               /* normal : 1 */
                                                               /* bitmap : 2 */
                                                              /* cluster : 3 */
                                                            /* iot - top : 4 */
                                                         /* iot - nested : 5 */
                                                            /* secondary : 6 */
                                                                 /* ansi : 7 */
                                                                  /* lob : 8 */
                                             /* cooperative index method : 9 */
  flags         number not null
                                      /* index is being online built : 0x100 */
                                    /* index is being online rebuilt : 0x200 */
)
/

