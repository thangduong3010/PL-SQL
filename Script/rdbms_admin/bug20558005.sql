--
-- bug20558005.sql
-- 
-- Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      bug20558005.sql -- drop unneeded procedure 
--
--    DESCRIPTION
--      patch 9968263 left a procedure behind.  This file drops it.
--
--    NOTES
--      None
--
--    MODIFIED  (MM/DD/YY)
--    jcarey     03/16/15 - Created

drop procedure sys.drop_aw_elist_all;

