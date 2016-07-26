Rem 
Rem plitblm.sql
Rem 
Rem Copyright (c) 1995, 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      plitblm.sql - package PLITBLM
Rem
Rem    DESCRIPTION
Rem      PL/sql Index-TaBLe Methods
Rem      Package for index-table operations. This package must
Rem      be loaded by catproc.sql script.
Rem      
Rem    NOTES
Rem      This file needs to be kept in sync with its .pls version
Rem      (icd/plitblm.pls) currently. We hope to soon eliminate 
Rem      this dependency once we automate the generation of .pls
Rem      version.  See that file for more important caveats.
Rem
Rem      Changes in this file require kkxwtp.c to be recompiled to
Rem      to update the ICD entry point vector and the database to be
Rem      recreated, 12/96, ~edarnell
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dbronnik    10/23/00 - associative arrays
Rem    gviswana    05/25/01 - CREATE OR REPLACE SYNONYM
Rem    gviswana    05/09/01 - Remove DROP PACKAGE
Rem    edarnell    11/25/96 - add <collection_1> explicitly
Rem    edarnell    11/06/96 - Add purity for read-only functions
Rem    edarnell    07/30/96 - add extend, limit, & trim
Rem    kmuthukk    03/21/95 - change method names
Rem    kmuthukk    03/07/95 - PLITBLM package .sql file
Rem    kmuthukk    03/06/95 - Created
Rem
 
create or replace package sys.plitblm is

 subtype key_type is binary_integer;
 subtype element_count IS binary_integer; /* natural is too inefficient */ 

 function count (collection IN "<COLLECTION_1>") return key_type;
  pragma interface(c, count);
  pragma restrict_references(count,rnds,wnds,rnps,wnps);
 
 function first (collection IN "<COLLECTION_1>") return key_type;
  pragma interface(c, first);
  pragma restrict_references(first,rnds,wnds,rnps,wnps);

 function last  (collection IN "<COLLECTION_1>") return key_type;
  pragma interface(c, last);
  pragma restrict_references(last,rnds,wnds,rnps,wnps);

 function exists (collection IN "<COLLECTION_1>", i key_type) return boolean;
  pragma interface(c, exists);
  pragma restrict_references(exists,rnds,wnds,rnps,wnps);

 function prior (collection IN "<COLLECTION_1>", i key_type) return key_type;
  pragma interface(c, prior);
  pragma restrict_references(prior,rnds,wnds,rnps,wnps);

 function next  (collection IN "<COLLECTION_1>", i key_type) return key_type;
  pragma interface(c, next);
  pragma restrict_references(next,rnds,wnds,rnps,wnps);

 procedure delete(collection IN OUT "<COLLECTION_1>");
  pragma interface(c, delete);
  pragma restrict_references(delete,rnds,wnds,rnps,wnps);

 procedure delete (collection IN OUT "<V2_TABLE_1>", i key_type);
  pragma interface(c, delete);
  pragma restrict_references(delete,rnds,wnds,rnps,wnps);

 procedure delete (collection IN OUT "<TABLE_1>", i key_type);
  pragma interface(c, delete);
  pragma restrict_references(delete,rnds,wnds,rnps,wnps);
  
 procedure delete (collection IN OUT "<V2_TABLE_1>", i key_type, j key_type);
  pragma interface(c, delete);
  pragma restrict_references(delete,rnds,wnds,rnps,wnps);
  
 procedure delete (collection IN OUT "<TABLE_1>", i key_type, j key_type);
  pragma interface(c, delete);
  pragma restrict_references(delete,rnds,wnds,rnps,wnps);

 function limit (collection IN "<COLLECTION_1>") return key_type; 
  pragma interface(c, limit);
  pragma restrict_references(limit,rnds,wnds,rnps,wnps);

 procedure trim (collection IN OUT "<VARRAY_1>", n element_count:=1);
  pragma interface(c, trim);
  pragma restrict_references(trim,rnds,wnds,rnps,wnps);

 procedure trim (collection IN OUT "<TABLE_1>", n element_count:=1);
  pragma interface(c, trim);
  pragma restrict_references(trim,rnds,wnds,rnps,wnps);

 procedure extend (collection IN OUT "<VARRAY_1>", n element_count:=1);
  pragma interface(c, extend);
  pragma restrict_references(extend,rnds,wnds,rnps,wnps);

 procedure extend (collection IN OUT "<TABLE_1>", n element_count:=1);
  pragma interface(c, extend);
  pragma restrict_references(extend,rnds,wnds,rnps,wnps);

 procedure extend (collection IN OUT "<VARRAY_1>", n element_count, i key_type);
  pragma interface(c, extend);
  pragma restrict_references(extend,rnds,wnds,rnps,wnps);

 procedure extend (collection IN OUT "<TABLE_1>", n element_count, i key_type);
  pragma interface(c, extend);
  pragma restrict_references(extend,rnds,wnds,rnps,wnps);

 function count (collection IN "<ASSOC_ARRAY_1>") return element_count;
  pragma interface(c, count);
  pragma restrict_references(count,rnds,wnds,rnps,wnps);
 
 function first (collection IN "<ASSOC_ARRAY_1>") return varchar2;
  pragma interface(c, first);
  pragma restrict_references(first,rnds,wnds,rnps,wnps);

 function last  (collection IN "<ASSOC_ARRAY_1>") return varchar2;
  pragma interface(c, last);
  pragma restrict_references(last,rnds,wnds,rnps,wnps);

 function exists (collection IN "<ASSOC_ARRAY_1>", i varchar2) return boolean;
  pragma interface(c, exists);
  pragma restrict_references(exists,rnds,wnds,rnps,wnps);

 function prior (collection IN "<ASSOC_ARRAY_1>", i varchar2) return varchar2;
  pragma interface(c, prior);
  pragma restrict_references(prior,rnds,wnds,rnps,wnps);

 function next  (collection IN "<ASSOC_ARRAY_1>", i varchar2) return varchar2;
  pragma interface(c, next);
  pragma restrict_references(next,rnds,wnds,rnps,wnps);

 procedure delete(collection IN OUT "<ASSOC_ARRAY_1>");
  pragma interface(c, delete);
  pragma restrict_references(delete,rnds,wnds,rnps,wnps);

 procedure delete (collection IN OUT "<ASSOC_ARRAY_1>", i varchar2);
  pragma interface(c, delete);
  pragma restrict_references(delete,rnds,wnds,rnps,wnps);

 procedure delete (collection IN OUT "<ASSOC_ARRAY_1>", 
                   i1 varchar2, i2 varchar2);
  pragma interface(c, delete);
  pragma restrict_references(delete,rnds,wnds,rnps,wnps);
  
end plitblm;
/

create or replace public synonym plitblm for sys.plitblm;

grant execute on sys.plitblm to public;

