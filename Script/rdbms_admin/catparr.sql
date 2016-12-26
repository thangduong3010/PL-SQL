Rem
Rem $Header: catparr.sql 26-jun-2001.16:50:45 eyho Exp $
Rem
Rem catclustdb.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      catparr.sql
Rem
Rem    DESCRIPTION
Rem       Parallel-Server specific views for performance queries, etc
Rem
Rem    NOTES
Rem      This script has been replaced by catclust.sql. Please make
Rem      any modifcations to catclust.sql instead. It is temporary
Rem      to keep this file for a little while.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    eyho        06/26/01 - obsolete catparr
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    eyho        04/11/01 - rename catparr.sql catclust.sql
Rem    eyho        04/03/01 - Rename catparr.sql to catclustdb.sql
Rem    ppjanic     01/14/01 - 601567: Correct v$lock_element definition
Rem    mjungerm    06/15/99 - add java shared data object type
Rem    nmacnaug    02/02/99 - zero out unused field
Rem    kquinn      05/13/98 - 666009: Correct v$cache definition
Rem    nmacnaug    06/10/98 - return zero for deleted columns
Rem    mcoyle      08/22/97 - Move v$lock_activity to kernel view
Rem    tlahiri     03/23/97 - Move v$bh to kqfv.h, remove use of ext_to_obj
Rem    tlahiri     07/23/96 - Proj-2721: Modifications for enhanced OPS statis
Rem    atsukerm    07/22/96 - change type for partitioned objects.
Rem    atsukerm    06/13/96 - fix EXT_TO_OBJ view.
Rem    mmonajje    05/24/96 - Replace type col name with type#
Rem    asurpur     04/08/96 - Dictionary Protection Implementation
Rem    atsukerm    02/29/96 - space support for partitions.
Rem    jwlee       02/05/96 - fix x$bh column name.
Rem    atsukerm    02/05/96 - fix ext_to_obj definition.
Rem    atsukerm    01/03/96 - tablespace-relative DBAs.
Rem    tlahiri     11/30/95 - Fix error in v$lock_element in last checkin
Rem    tlahiri     11/20/95 - Bugs 313766 and 313767
Rem    aho         11/02/95 - iot change clu# references in ext_to_obj_view
Rem    aezzat      08/09/95 - modify v$bh, v$ping to include buffer class
Rem    pgreenwa    10/21/94 - create public syn. for v$locks_with_collisions
Rem    svenkate    11/30/94 - bug 250244 : view changes
Rem    thayes      07/08/94 - Extend vbh view
Rem    svenkate    06/17/94 - bug 172282 : amendments
Rem    svenkate    06/08/94 - 172288 : add file_lock, file_PING
Rem    wmaimone    05/06/94 - #184921 run as sys/internal
Rem    jloaiza     03/17/94 - add false ping view, v$lock_element, etc
Rem    hrizvi      02/09/93 - apply changes to x$bh 
Rem    jloaiza     11/09/92 - get rid of quted column 
Rem    jklein      11/04/92 - fix view definitions 
Rem    jklein      10/28/92 - merge forward changes from v6 
Rem    Porter      12/03/90 - Added to control system, renamed to psviews.sql
Rem    Laursen     10/01/90 - Creation
Rem

@@catclust