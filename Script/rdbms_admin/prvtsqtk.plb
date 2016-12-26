create or replace package hm_sqltk_internal wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
3fa 195
2/jRmjQWWAo406avkyWgzrcz+TEwg423f65qfC8CWE7VSPbFf8q0TQRfx95W2px3UqlZSTkU
L2PTULWWbi/KFHlDMEt6NLu57eu+jgltKhVO/aq8IP5k5MIFJBCKHMTK5RbhFjuXAnlUCx2m
wg6XvcC4SdhHRu1fZNGnuBAdbYdbh8RUQuIbDSYtxty4mkUcHpKU07eDURdZkLbZdGNKkFMq
hRTANumdXP/vV59612Bc/yRqps8WebV0isje3EvxtTdDFgJiubDz5nt04Ub69Exe4E3kcuSh
/nUcuCx6Y6BLTTzSA0Q4UHCGUx57tuw4rsflX4SZgmWySXg31E5O+doINHN5PrU+5CCrPUCh
UumXlc2VB9qgQMjThcDi39TeKM40FEf8ipkdCmiG

/
show errors;
create or replace package body hm_sqltk_internal wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
765 25c
mH5SPmbHt/Uv0Ubx3c/oVTl9yX0wgzvDACDWfI6KR2SlUKhaTYTqd683gEt8QAS3Rvr8aSZc
61p5TrU9gKyk56EBg3ylKZi/v7vu8WCITKZYH1KEhyTS/sGfteKan/icZFVOPAuNwfMJl2as
U6dnUayxvlDMnszfXvX/NZnsHTis2E1fCcUsHTZxrS87rQqOGUX7cF6XuTwt5uwpBOUR56Xz
qdznWGqsvbta6jfDMMxEJqdxClmMe0r/whIMnVE0QBhH/MI2MQMeW2/WgVTkynCMuFJwpDlb
KQtrYE8sBkkvCMpQuHUNVjyGDkzAfZWKYXERPYmPReSOCNJf0EF+27XnzllV969UNeQW3v3B
QkfIceMxQn3x5uG655A1hsvFbNkmfqPIIsOQ5+zKluu9hp4UWI8mmgbzff5gv1/oVQd+mJ+u
IJ+WBWt3zD81tVy4wBDey1mdcoumQsuZsHn2YieT1n75pYJ1GNz9SmKR8AQwEe7vJFl8Kvau
ksImmXsLjw6pFMKFgHv6ewLvA+4j/D80A6s/MPDZWTa++5xVSyBrCgV1G/xlEBGd7noN0N7i
97Y+LT3KREPuVSj1ncTs

/
show errors;
grant execute on hm_sqltk_internal to dba;
begin
  hm_sqltk_internal.tab_init('tab$');
  hm_sqltk_internal.row_check('tab$','obj#','PRIMARY KEY',
        'Primary Key obj#');
  hm_sqltk_internal.column_check('tab$','obj#','< 0',
        'Obj# invalid - < 0');
  hm_sqltk_internal.ref_check('tab$','file#','file$','file#',
        'file# != 0 and file# != 1024',
        'foreign key file# not found in file$');
  hm_sqltk_internal.ref_check('tab$','ts#','ts$','ts#','ts# != 2147483647',
        'foreign key ts# not found in ts$');
  hm_sqltk_internal.ref_check
        ('tab$','ts#, file#, block#','seg$','ts#, file#,block#',
         'file# != 0 and block# != 0',
         'foreign key (file#, block#) not found in seg$');
  hm_sqltk_internal.ref_check
        ('tab$','obj#','obj$','obj#', '', 
         'foreign key (obj#) not found in obj$');
  hm_sqltk_internal.column_check
        ('tab$','tab#','is not null and tab# not between 1 and 31',
        'tab# out of range for a clustered table');
  hm_sqltk_internal.column_check
        ('tab$','cols','>1000','invalid column number');
  hm_sqltk_internal.column_check
        ('tab$','clucols','is not null and clucols not between 1 and 33',
        'invalid cluster column number found');
  hm_sqltk_internal.column_check
        ('tab$','pctfree$','not between 0 and 99',
        'invalid pctfree found');
  hm_sqltk_internal.column_check
        ('tab$','pctused$',
        'not between 0 and 99 and dataobj# != 0 and dataobj#  is not null',
        'invalid pctused$ found');
  hm_sqltk_internal.column_check
        ('tab$','analyzetime','>SYSDATE',
        'analyzetime for object new than sysdate');
  hm_sqltk_internal.tab_desc
        ('tab$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, tab$ t where t.rowid = chartorowid(:1) and t.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
 hm_sqltk_internal.tab_init('clu$');
 hm_sqltk_internal.row_check('clu$','obj#','PRIMARY KEY','Primary Key obj#');
 hm_sqltk_internal.column_check('clu$','obj#','< 0', 'obj# invalid - < 0');
 hm_sqltk_internal.column_check('clu$','dataobj#','< obj#',
        'dataobj# invalid - must be >= obj#');
 hm_sqltk_internal.ref_check('clu$','file#','file$','file#', 'file# != 1024',
        'Foreign Key - clu$.file# not found in file$.file#');
 hm_sqltk_internal.ref_check('clu$','ts#','ts$','ts#', 'ts# != 2147483647',
        'Foreign Key - clu$.ts# not found in ts$.ts#');
 hm_sqltk_internal.ref_check
        ('clu$','ts#, file#, block#','seg$','ts#, file#,block#',
         'file# != 0 and block# != 0',
         'Foreign Key - clu$.(file#,block#) not found in seg$');
  hm_sqltk_internal.column_check
        ('clu$','pctfree$','not between 0 and 99','Invalid pctfree$');
  hm_sqltk_internal.column_check
        ('clu$','pctused$','not between 1 and 99','Invalid pctused$');
  hm_sqltk_internal.column_check
        ('clu$','cols','>33','Invalid cols in clu$ - cols > 33');
  hm_sqltk_internal.column_check
        ('clu$','func','not in (0,3)','Invalid function found - not in (0,3)');

  hm_sqltk_internal.tab_desc
        ('clu$',
        'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, clu$ c where c.rowid = chartorowid(:1) and c.obj# = o.obj# and o.owner# = u.user#');

 commit;
end;
/
begin
  hm_sqltk_internal.tab_init('fet$');
  hm_sqltk_internal.row_check
         ('fet$','ts#, file#, block#','PRIMARY KEY','fet$.ts_file_block pk');
  hm_sqltk_internal.ref_check('fet$','ts#','ts$','ts#','','fet$.ts# fk');
  hm_sqltk_internal.tab_desc
        ('fet$',
         'select ''Ts# ''||f.ts#||'' File# ''||f.file#||'' Block# ''||f.block#||'' is referenced'' from fet$ f where f.rowid = chartorowid(:1)');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('uet$');
  hm_sqltk_internal.row_check
         ('uet$','ts#,segfile#,segblock#,ext#','PRIMARY KEY','uet$ pk');
  hm_sqltk_internal.ref_check
         ('uet$','ts#','ts$','ts#','','uet.ts# fk');
  hm_sqltk_internal.row_check
         ('uet$','ts#,file#,block#','UNIQUE KEY','uet$.ts.file.block uk');
  hm_sqltk_internal.ref_check
        ('uet$','ts#,segfile#,segblock#','seg$','ts#,file#,block#','',
         'uet$ seg$ fk');
  hm_sqltk_internal.tab_desc
        ('uet$',
         'select ''Ts# ''||u.ts#||'' File# ''||u.segfile#||'' Block# ''||u.segblock#||'' is referenced'' from uet$ u where u.rowid = chartorowid(:1)');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('seg$');
  hm_sqltk_internal.row_check
         ('seg$','ts#,file#,block#','primary key','seg$ pk');
  hm_sqltk_internal.ref_check
         ('seg$','ts#','ts$','ts#','','seg.ts# fk');
  hm_sqltk_internal.column_check
         ('seg$', 'type#','not between 1 and 10','seg$.type#');
  hm_sqltk_internal.ref_check
         ('seg$','user#','user$','user#','','seg$.user# fk');
  hm_sqltk_internal.column_check
        ('seg$','extents','!=(select count(*) from sys.uet$ u where u.ts# = seg$.ts# and u.segfile# = seg$.file# and u.segblock# = seg$.block#) and seg$.ts# in (select ts$.ts# from ts$ where flags=0)', 'seg$.extents');
  hm_sqltk_internal.tab_desc
        ('seg$',
         'select ''Ts# ''||s.ts#||'' File# ''||s.file#||'' Block# ''||s.block#||'' is referenced'' from seg$ s where s.rowid = chartorowid(:1)');
 commit;
end;
/
begin
  hm_sqltk_internal.tab_init('undo$');
  hm_sqltk_internal.ref_check
        ('undo$','ts#,file#,block#','seg$','ts#,file#,block#', 'status$ != 1', 
         'undo$ seg fk');
  hm_sqltk_internal.row_check
        ('undo$','us#','primary key','undo$ pk');
  hm_sqltk_internal.column_check
        ('undo$','status$','not between 1 and 6','undo$.status$');
  hm_sqltk_internal.ref_check
        ('undo$','ts#','ts$','ts#','','undo$.ts# fk');
  hm_sqltk_internal.tab_desc
        ('undo$',
         'select ''Undo segment ''||u.name||'' is referenced'' from undo$ u where u.rowid = chartorowid(:1)');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('ts$');
  hm_sqltk_internal.row_check
        ('ts$','ts#','primary key','ts$.ts# pk');
  hm_sqltk_internal.ref_check
        ('ts$','owner#','user$','user#','','ts$.owner# fk');
  hm_sqltk_internal.row_check
        ('ts$','name','unique key','ts$.name uk');
  hm_sqltk_internal.column_check
        ('ts$','online$','not between 1 and 3', 'ts$.online$');
  hm_sqltk_internal.tab_desc
        ('ts$',
         'select ''Tablespace ''||t.name||'' is referenced'' from ts$ t where t.rowid = chartorowid(:1)');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('file$');
  hm_sqltk_internal.row_check
        ('file$','ts#, file#','primary key','file$ pk');
  hm_sqltk_internal.ref_check
        ('file$','ts#','ts$','ts#','','file$.ts# fk');
  hm_sqltk_internal.column_check
        ('file$','status$','not between 1 and 2','file$.status$');
  hm_sqltk_internal.tab_desc
        ('file$',
        'select ''Filename ''||vf.name||'' is referenced'' from file$ f, v$dbfile vf where f.rowid = chartorowid(:1) and f.file# = vf.file#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('obj$');
  hm_sqltk_internal.row_check
        ('obj$','obj#','primary key','obj$.obj# pk');
  hm_sqltk_internal.ref_check
        ('obj$','owner#','user$','user#','','obj$.owner# fk');
  hm_sqltk_internal.column_check
        ('obj$','namespace','not between 1 and 66','obj$.namespace');
  hm_sqltk_internal.column_check
        ('obj$','type#','not between 0 and 101', 'obj$.type#');
  hm_sqltk_internal.column_check
        ('obj$','status','not between 0 and 7','obj$.status');
  hm_sqltk_internal.ref_check
        ('obj$','obj#','tab$','obj#','obj$.type# = 2 and remoteowner is null and linkname is null','obj$ ref to tab$');
  hm_sqltk_internal.tab_desc
        ('obj$',
         'select ''Object Name ''||o.name||'' is referenced'' from obj$ o where o.rowid = chartorowid(:1)');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('ind$');
  hm_sqltk_internal.row_check
        ('ind$','obj#','primary key','ind$.obj# pk');
  hm_sqltk_internal.column_check
        ('ind$','obj#','<0','ind$.obj#');
  hm_sqltk_internal.row_check
        ('ind$','dataobj#','<obj#','ind$.dataobj# range');
  hm_sqltk_internal.ref_check
        ('ind$','ts#','ts$','ts#','ts# != 2147483647','ind$.ts# fk');
  hm_sqltk_internal.ref_check
        ('ind$','ts#,file#,block#','seg$','ts#,file#,block#',
         'file# != 0 and block# != 0','ind$.ts,file,block fk');
  hm_sqltk_internal.ref_check
        ('ind$','obj#','obj$','obj#','','ind$.obj# fk_obj$');
  hm_sqltk_internal.column_check
        ('ind$','type#','not between 1 and 9','ind$.type#');
  hm_sqltk_internal.column_check
        ('ind$','pctfree$','not between 0 and 99','ind$.pctfree$');
  hm_sqltk_internal.column_check
        ('ind$','analyzetime','> SYSDATE', 'ind$.analyzetime <= SYSDATE');
  hm_sqltk_internal.tab_desc
        ('ind$',
         'select ''Index Name ''||u.name||''.''||o.name||'' is referenced'' from ind$ i, obj$ o, user$ u where i.rowid = chartorowid(:1) and i.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('icol$');
  hm_sqltk_internal.row_check
        ('icol$','obj#,pos#','primary key','icol$ pk');
  hm_sqltk_internal.ref_check
        ('icol$','obj#','obj$','obj#','','icol$.obj# fk');
  hm_sqltk_internal.ref_check
        ('icol$','bo#','obj$','obj#','','icol$.bo# fk');
  hm_sqltk_internal.ref_check
        ('icol$','bo#, col#','col$','obj#, col#','','icol$.col# fk');
  hm_sqltk_internal.ref_check
        ('icol$','obj#','ind$','obj#','','icol$.bo# fk');
  hm_sqltk_internal.tab_desc
        ('icol$',
         'select ''Index Name ''||u.name||''.''||o.name||'' is referenced'' from icol$ i, obj$ o, user$ u where i.rowid = chartorowid(:1) and i.obj# = o.obj# and o.obj# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('col$');
  hm_sqltk_internal.ref_check
        ('col$','obj#','obj$','obj#','','col$.obj# fk(obj$)');
  hm_sqltk_internal.column_check
        ('col$','col#','not between 0 and 1000','col$.col#');
  hm_sqltk_internal.column_check
        ('col$','segcol#','not between 0 and 1000','col$,segcol#');
  hm_sqltk_internal.tab_desc
        ('col$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, col$ c where c.rowid = chartorowid(:1) and c.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('user$');
  hm_sqltk_internal.row_check
        ('user$','user#','primary key','user$.user# pk');
  hm_sqltk_internal.ref_check
        ('user$','datats#','ts$','ts#','','user$.datats# fk');
  hm_sqltk_internal.ref_check
        ('user$','tempts#','ts$','ts#','','user$.tempts# fk');
  hm_sqltk_internal.column_check
        ('user$','ctime','>=SYSDATE','user$.ctime');
  hm_sqltk_internal.column_check
        ('user$','astatus','not between 0 and 9','user$.astatus');
  hm_sqltk_internal.tab_desc
        ('user$',
         'select ''Username ''||u.name||'' is referenced'' from user$ u where u.rowid = chartorowid(:1)');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('con$');
  hm_sqltk_internal.row_check
        ('con$','con#','primary key','con$.con# pk');
  hm_sqltk_internal.ref_check
        ('con$','owner#','user$','owner#','','con$.owner# fk');
  hm_sqltk_internal.tab_desc
         ('con$',
          'select ''Constraint name  ''||c.name||'' is referenced'' from con$ c where c.rowid = chartorowid(:1)');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('cdef$');
  hm_sqltk_internal.row_check
        ('cdef$','con#','primary key','cdef$.con# pk');
  hm_sqltk_internal.ref_check
        ('cdef$','con#','con$','con#','','cdef$.con# fk');
  hm_sqltk_internal.ref_check
        ('cdef$','obj#','obj$','obj#','','cdef$.obj# fk');
  hm_sqltk_internal.column_check
        ('cdef$','type#','not between 1 and 17','cdef$.type#');
  hm_sqltk_internal.column_check
        ('cdef$','mtime','>SYSDATE','cdef$.mtime');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('ccol$');
  hm_sqltk_internal.ref_check
        ('ccol$','obj#','obj$','obj#','','ccol$.obj# fk');
  hm_sqltk_internal.ref_check
        ('ccol$','con#','con$','con#','','ccol$.con# fk');
  hm_sqltk_internal.ref_check
        ('ccol$','obj#,col#','col$','obj#,col#','','ccol$.obj#,col# fk');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('bootstrap$');
  hm_sqltk_internal.row_check
        ('bootstrap$','obj#,line#','primary key','bootstrap$ pk');
  hm_sqltk_internal.ref_check
        ('bootstrap$','obj#','obj$','obj#','obj# > 0','bootstrap$.obj# fk');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('objauth$');
  hm_sqltk_internal.row_check
        ('objauth$','obj#,grantor#,grantee#,privilege#,sequence#',
                'primary key','objauth$ pk');
  hm_sqltk_internal.ref_check
        ('objauth$','obj#','obj$','obj#','','objauth$.obj# fk');
  hm_sqltk_internal.ref_check
        ('objauth$','grantor#','user$','user#','','objauth$.grantor# fk');
  hm_sqltk_internal.ref_check
        ('objauth$','grantee#','user$','user#','','objauth$.grantee# fk');
  hm_sqltk_internal.tab_desc
        ('objauth$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from objauth$ oa, user$ u, obj$ o where oa.rowid = chartorowid(:1) and oa.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('ugroup$');
  hm_sqltk_internal.row_check   
        ('ugroup$','ugrp#','primary key','ugroup$.ugrp# pk');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('tsq$');
  hm_sqltk_internal.row_check
        ('tsq$','ts#,user#','primary key','tsq$.ts#,user# pk');
  hm_sqltk_internal.ref_check   
        ('tsq$','ts#','ts$','ts#','','tsq$.ts# fk');
  hm_sqltk_internal.ref_check
        ('tsq$','user#','user$','user#','','tsq$.user# fk');
  hm_sqltk_internal.ref_check
        ('tsq$','grantor#','user$','user#','','tsq$.grantor# fk');
  hm_sqltk_internal.tab_desc
        ('tsq$',
         'select ''Tablespace ''||t.name||'' is referenced'' from ts$ t, tsq$ tsq where tsq.rowid = chartorowid(:1) and tsq.ts# = t.ts#');        
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('syn$');
  hm_sqltk_internal.row_check
        ('syn$','obj#','primary key','syn$.obj# pk');



  hm_sqltk_internal.column_check
        ('syn$','owner','not in (select name from user$ union select name from obj$ where type#=9 union select ''REMOTE_USER'' from dual)', 'syn$.owner');
  hm_sqltk_internal.tab_desc
        ('syn$',
         'select ''Synonym ''||s.name||'' is referenced'' from syn$ s where s.rowid = chartorowid(:1)');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('view$');
  hm_sqltk_internal.row_check
        ('view$','obj#','primary key','view$.obj# pk');
  hm_sqltk_internal.ref_check
        ('view$','obj#','obj$','obj#','','view$.obj# fk');
  hm_sqltk_internal.tab_desc
        ('view$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, view$ v where v.rowid = chartorowid(:1) and v.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('typed_view$');
  hm_sqltk_internal.row_check
        ('typed_view$','obj#','primary key','view$.obj# pk');
  hm_sqltk_internal.ref_check
        ('typed_view$','obj#','obj$','obj#','','view$.obj# fk');
  hm_sqltk_internal.ref_check
        ('typed_view$','typeowner','user$','name','',
         'typed_view$.typeowner fk');
  hm_sqltk_internal.tab_desc
        ('typed_view$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, typed_view$ v where v.rowid = chartorowid(:1) and v.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('superobj$');
  hm_sqltk_internal.ref_check
        ('superobj$','subobj#','obj$','obj#','','superobj$.subobj# fk');
  hm_sqltk_internal.ref_check
        ('superobj$','superobj#','obj$','obj#','','superobj$.superobj# fk');
  hm_sqltk_internal.row_check
        ('superobj$','subobj#,superobj#','primary key','superobj# pk');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('seq$');
  hm_sqltk_internal.row_check
        ('seq$','obj#','primary key','seq$.obj# pk');
  hm_sqltk_internal.ref_check
        ('seq$','obj#','obj$','obj#','','seq$.obj# fk');
  hm_sqltk_internal.tab_desc
        ('seq$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, seq$ s where s.rowid = chartorowid(:1) and s.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('lob$');
  hm_sqltk_internal.row_check
        ('lob$','obj#,intcol#','primary key','lob$.obj# pk');
  hm_sqltk_internal.ref_check
        ('lob$','obj#','obj$','obj#','','lob$.obj# fk');
  hm_sqltk_internal.ref_check
        ('lob$','obj#,col#','col$','obj#,col#','','lob$.obj#,col# fk');
  hm_sqltk_internal.ref_check
        ('lob$','lobj#','obj$','obj#','','lob$.lobj# fk');
  hm_sqltk_internal.ref_check
        ('lob$','ind#','ind$','obj#','','lob$.ind# fk');
  hm_sqltk_internal.ref_check
        ('lob$','ts#,file#,block#','seg$','ts#,file#,block#',
         'block# != 0', 'lob$.ts#,file#,block# fk');
  hm_sqltk_internal.tab_desc
        ('lob$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, lob$ l where l.rowid = chartorowid(:1) and l.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('coltype$');
  hm_sqltk_internal.ref_check
        ('coltype$','obj#','obj$','obj#','','coltype$.obj# fk');
  hm_sqltk_internal.ref_check
        ('coltype$','obj#,col#','col$','obj#,col#','','coltype$.obj#,col# fk');
  hm_sqltk_internal.tab_desc
        ('coltype$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, coltype$ c where c.rowid = chartorowid(:1) and c.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('subcoltype$');
  hm_sqltk_internal.ref_check
        ('subcoltype$','obj#','obj$','obj#','','subcoltype$.obj# fk');
  hm_sqltk_internal.ref_check
        ('subcoltype$','obj#,intcol#','col$','obj#,intcol#','',
                'subcoltype$.obj#,intcol# fk');
  hm_sqltk_internal.tab_desc
        ('subcoltype$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, subcoltype$ sc where sc.rowid = chartorowid(:1) and sc.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('ntab$');
  hm_sqltk_internal.row_check
        ('ntab$','obj#,intcol#','primary key','ntab$ pk');
  hm_sqltk_internal.ref_check
        ('ntab$','obj#','obj$','obj#','','ntab$.obj# fk');
  hm_sqltk_internal.ref_check
        ('ntab$','obj#,intcol#','col$','obj#,intcol#','',
                'ntab$.obj#,intcol# fk');
  hm_sqltk_internal.ref_check
        ('ntab$','ntab#','obj$','obj#','ntab# != 0','ntab$.ntab$ fk');
  hm_sqltk_internal.tab_desc
        ('ntab$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, ntab$ n where n.rowid = chartorowid(:1) and n.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('refcon$');
  hm_sqltk_internal.ref_check
        ('refcon$','obj#','obj$','obj#','','refcon$.obj# fk');
  hm_sqltk_internal.ref_check
        ('refcon$','obj#,col#', 'col$','obj#,col#','','refcont$.obj#,col# fk');
  hm_sqltk_internal.tab_desc
        ('refcon$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, refcon$ r where r.rowid = chartorowid(:1) and r.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('opqtype$');
  hm_sqltk_internal.row_check
        ('opqtype$','obj#,intcol#','primary key','opqtype$ pk');
  hm_sqltk_internal.ref_check
        ('opqtype$','obj#','obj$','obj#','','opqtype$.obj# fk');
  hm_sqltk_internal.ref_check
        ('opqtype$','obj#,intcol#','col$','obj#,intcol#','',
                'opqtype$.obj#,intcol# fk');
  hm_sqltk_internal.tab_desc
        ('opqtype$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, opqtype$ op where op.rowid = chartorowid(:1) and op.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('dependency$');
  hm_sqltk_internal.row_check
        ('dependency$','d_obj#, order#', 'primary key', 'dependency$ pk');




  hm_sqltk_internal.column_check
        ('dependency$','d_timestamp','>SYSDATE and d_timestamp != to_date(''12/31/4712 23:59:59'', ''mm/dd/yyyy hh24:mi:ss'')','dependency$.d_timestamp');
  hm_sqltk_internal.column_check
        ('dependency$','p_timestamp','>SYSDATE and p_timestamp != to_date(''12/31/4712 23:59:59'', ''mm/dd/yyyy hh24:mi:ss'')','dependency$.p_timestamp');
  hm_sqltk_internal.tab_desc
        ('dependency$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, dependency$ d where d.rowid = chartorowid(:1) and d.d_obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('access$');
  hm_sqltk_internal.ref_check
        ('access$','d_obj#','dependency$','d_obj#','types != 12','access$.dobj# fk');
  hm_sqltk_internal.tab_desc
        ('access$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, dependency$ d, access$ a where a.rowid = chartorowid(:1) and a.d_obj# = d.d_obj# and d.d_obj# = o.obj# and o.owner# = u.user#');

  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('viewcon$');
  hm_sqltk_internal.row_check
        ('viewcon$','obj#,con#','primary key','viewcon$ pk');
  hm_sqltk_internal.ref_check
        ('viewcon$','obj#','view$','obj#','','viewcon$.obj# fk');
  hm_sqltk_internal.ref_check
        ('viewcon$','con#','cdef$','con#','','viewcon$.con# fk');
  hm_sqltk_internal.column_check
        ('viewcon$','type#','not in (2,3,4)','viewcon$.type#');
  hm_sqltk_internal.ref_check
        ('viewcon$','robj#','obj$','obj#','','viewcon$.robj# fk');
  hm_sqltk_internal.tab_desc
        ('viewcon$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, viewcon$ v where v.rowid = chartorowid(:1) and v.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('icoldep$');
  hm_sqltk_internal.ref_check
        ('icoldep$','obj#','ind$','obj#', '','icoldep$.obj# fk');
  hm_sqltk_internal.tab_desc
        ('icoldep$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, icoldep$ i where i.rowid = chartorowid(:1) and i.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('dual');
  hm_sqltk_internal.column_check
        ('dual','rownum', '>1','dual row count');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('sysauth$');
  hm_sqltk_internal.row_check
        ('sysauth$','grantee#,privilege#,sequence#','primary key',
                'sysauth$ pk');
  hm_sqltk_internal.ref_check
        ('sysauth$','grantee#','user$','user#','','sysauth$.grantee# fk');
  hm_sqltk_internal.column_check
        ('sysauth$','option$','not in (null, 1)', 'sysauth$.option$');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('objpriv$');
  hm_sqltk_internal.row_check
        ('objpriv$','obj#,privilege#','primary key','objpriv$ pk');
  hm_sqltk_internal.ref_check
        ('objpriv$','obj#','obj$','obj#','','objpriv$.obj# fk');
  hm_sqltk_internal.tab_desc
        ('objpriv$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, objpriv$ p where p.rowid = chartorowid(:1) and p.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('defrole$');
  hm_sqltk_internal.row_check   
        ('defrole$','user#,role#','primary key','defrole$ pk');
  hm_sqltk_internal.ref_check
        ('defrole$','user#','user$','user#','','defrole$.user# fk');
  hm_sqltk_internal.tab_desc
        ('defrole$',
         'select ''Username ''||u.name||'' is referenced'' from user$ u, defrole$ d where d.rowid = chartorowid(:1) and d.user# = u.user#');

  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('ecol$');
  hm_sqltk_internal.row_check
        ('ecol$','tabobj#,colnum','primary key','ecol$ pk');
  hm_sqltk_internal.ref_check
        ('ecol$','tabobj#','tab$','obj#','','ecol$.tabobj# fk');
  hm_sqltk_internal.ref_check
        ('ecol$','tabobj#,colnum','col$','obj#,col#', '',
                'ecol$.tabobj#,colnum fk');
  hm_sqltk_internal.tab_desc
        ('ecol$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, ecol$ e where e.rowid = chartorowid(:1) and e.tabobj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('deferred_stg$');
  hm_sqltk_internal.row_check
        ('deferred_stg$','obj#','primary key','deferred_stg$ pk');
  hm_sqltk_internal.ref_check
        ('deferred_stg$','obj#','obj$','obj#','','deferred_stg$.obj# fk');
  hm_sqltk_internal.tab_desc
        ('deferred_stg$',
         'select ''Object ''||u.name||''.''||o.name||'' is referenced'' from obj$ o, user$ u, deferred_stg$ d where d.rowid = chartorowid(:1) and d.obj# = o.obj# and o.owner# = u.user#');
  commit;
end;
/
begin
  hm_sqltk_internal.tab_init('transient_iot$');
  hm_sqltk_internal.row_check
        ('transient_iot$','obj#','primary key','transient_iot$ pk');
  hm_sqltk_internal.ref_check
        ('transient_iot$','obj#','tab$','obj#','','transient_iot$.obj# fk');
  commit;
end;
/
