Rem
Rem $Header: rdbms/admin/depspspi.sql /main/2 2009/07/01 21:38:42 kkunchit Exp $
Rem
Rem depspspi.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      depspspi.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shase       01/28/09 - Add dependent views of Archive Provider
Rem    shase       01/28/09 - Created
Rem

CREATE OR REPLACE VIEW USER_DBFS_HS_FILES AS SELECT APT.path, SF.SequenceNumber, SF.StartOffset, SF.EndOffset, SF.TarballId, BF.BackupFileName, BF.TarStartOffset, BF.TarEndOffset FROM DBFS_HS$_SFLocatorTable SF, DBFS_HS$_ContentFnMapTbl MP, DBFS_HS$_StoreId2PolicyCtx PC, DBFS_HS$_BackupFileTable BF, TABLE(dbms_dbfs_hs.listcontentfilename) APT WHERE MP.ArchiveRefId = SF.ArchiveRefId AND PC.StoreId = BF.StoreId AND BF.TarballId = SF.TarballId AND APT.contentfilename = MP.ContentFilename
/

CREATE OR REPLACE PUBLIC SYNONYM USER_DBFS_HS_FILES FOR USER_DBFS_HS_FILES
/

GRANT SELECT ON USER_DBFS_HS_FILES TO PUBLIC
/

