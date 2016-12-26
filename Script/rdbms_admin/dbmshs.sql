Rem
Rem $Header: dbmshs.sql 05-may-2008.15:53:18 kchen Exp $
Rem
Rem dbmshs.sql
Rem
Rem Copyright (c) 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmshs.sql - Hetrogeneous option packages 
Rem
Rem    DESCRIPTION
Rem      The following packages are located in this file:
rem      dbms_hs - Public procedures for createing and modifying objects in 
rem                the hs dictionary.
Rem    NOTES
Rem 
Rem      The procedural option is needed to use this facility.
Rem
Rem      This packages are installed by sys (connect internal).
Rem
Rem      The hs tables are created by caths.sql and are owned by the system.
Rem
Rem    DEPENDENCIES
Rem      
Rem    USAGE
Rem
Rem    SECURITY
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     kchen      05/05/08  - fixed bug 6943575
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     delson     08/28/00  - delete references to unused tables.
Rem     delson     08/17/00  - remove dcl for pkg dbms_hs_extproc.
Rem     jdraaije   04/18/97 -  Add 24279: insufficient privs to create lib
Rem     jdraaije   03/26/97 -  Name consistency: ho => hs
Rem     ktarkhan   02/24/97 -  add privilege exception
Rem     jdraaije   01/01/97 -  external_procedure ==> external_object
Rem     celsbern   10/21/96 -  Changing package names.
Rem     celsbern   09/18/96 -  fix up error messages and rename callout procedu
Rem     celsbern   09/09/96 -  created
rem
REM  ***********************************************************************
REM  THESE PACKAGES AND PACKAGE BODIES MUST NOT BE MODIFIED BY THE CUSTOMER.
REM  DOING SO COULD CAUSE INTERNAL ERRORS AND CORRUPTIONS IN THE RDBMS.
REM  ***********************************************************************
 
REM  ************************************************************
REM  THESE PACKAGES AND PACKAGE BODIES MUST BE CREATED UNDER SYS.
REM  ************************************************************
create or replace package "DBMS_HS" as

  ----------------------------------------
  -- Exceptions
  -- 
  miss_base_caps exception;           
  pragma exception_init(miss_base_caps, -24274);
  miss_base_caps_num number := -24274;
  miss_base_caps_msg varchar2(76) := 'HS$_BASE_CAPS';

  dupl_base_caps exception;           
  pragma exception_init(dupl_base_caps, -24270);
  dupl_base_caps_num number := -24270;
  dupl_base_caps_msg varchar2(76) := 'HS$_BASE_CAPS';

  miss_base_dd exception;             
  pragma exception_init(miss_base_dd, -24274);  
  miss_base_dd_num number := -24274;  
  miss_base_dd_msg varchar2(76) := 'HS$_BASE_DD';    

  dupl_base_dd exception;             
  pragma exception_init(dupl_base_dd, -24270);  
  dupl_base_dd_num number := -24270;  
  dupl_base_dd_msg varchar2(76) := 'HS$_BASE_DD';    

  miss_class_caps exception;          
  pragma exception_init(miss_class_caps, -24274);        
  miss_class_caps_num number := -24274;         
  miss_class_caps_msg varchar2(76) := 'HS$_CLASS_CAPS';         

  dupl_class_caps exception;          
  pragma exception_init(dupl_class_caps, -24270);        
  dupl_class_caps_num number := -24270;         
  dupl_class_caps_msg varchar2(76) := 'HS$_CLASS_CAPS';          

  miss_class_dd exception;            
  pragma exception_init(miss_class_dd, -24274); 
  miss_class_dd_num number := -24274; 
  miss_class_dd_msg varchar2(76) := 'HS$_CLASS_DD';  

  dupl_class_dd exception;            
  pragma exception_init(dupl_class_dd, -24270); 
  dupl_class_dd_num number := -24270; 
  dupl_class_dd_msg varchar2(76) := 'HS$_CLASS_DD';  

  bad_TRANSLATION_TYPE exception;     
  pragma exception_init(bad_TRANSLATION_TYPE, -24271);   
  bad_TRANSLATION_TYPE_num number := -24271;    
  bad_TRANSLATION_TYPE_msg varchar2(76) := 'NULL';  
  
  bad_TRANSLATION_TEXT exception;
  pragma exception_init(bad_TRANSLATION_TEXT, -24273);   
  bad_TRANSLATION_TEXT_num number := -24273;    
  bad_TRANSLATION_TEXT_msg varchar2(76) := 'NULL';  

  miss_class_init exception;          
  pragma exception_init(miss_class_init, -24274);        
  miss_class_init_num number := -24274;         
  miss_class_init_msg varchar2(76) := 'HS$_CLASS_INIT';         

  dupl_class_init exception;          
  pragma exception_init(dupl_class_init, -24270);        
  dupl_class_init_num number := -24270;         
  dupl_class_init_msg varchar2(76) := 'HS$_CLASS_INIT';          

  bad_INIT_VALUE_TYPE exception;      
  pragma exception_init(bad_INIT_VALUE_TYPE, -24272);    
  bad_INIT_VALUE_TYPE_num number := -24272;     
  bad_INIT_VALUE_TYPE_msg varchar2(76) := 'NULL';   

  miss_fds_class exception;           
  pragma exception_init(miss_fds_class, -24274);
  miss_fds_class_num number := -24274;
  miss_fds_class_msg varchar2(76) := 'HS$_FDS_CLASS';

  dupl_fds_class exception;           
  pragma exception_init(dupl_fds_class, -24270);
  dupl_fds_class_num number := -24270;
  dupl_fds_class_msg varchar2(76) := 'HS$_FDS_CLASS';

  miss_fds_inst exception;            
  pragma exception_init(miss_fds_inst, -24274); 
  miss_fds_inst_num number := -24274; 
  miss_fds_inst_msg varchar2(76) := 'HS$_FDS_INST';  

  dupl_fds_inst exception;            
  pragma exception_init(dupl_fds_inst, -24270); 
  dupl_fds_inst_num number := -24270; 
  dupl_fds_inst_msg varchar2(76) := 'HS$_FDS_INST';  

  miss_inst_caps exception;           
  pragma exception_init(miss_inst_caps, -24274);
  miss_inst_caps_num number := -24274;
  miss_inst_caps_msg varchar2(76) := 'HS$_INST_CAPS';

  dupl_inst_caps exception;           
  pragma exception_init(dupl_inst_caps, -24270);
  dupl_inst_caps_num number := -24270;
  dupl_inst_caps_msg varchar2(76) := 'HS$_INST_CAPS';

  miss_inst_dd exception;             
  pragma exception_init(miss_inst_dd, -24274);  
  miss_inst_dd_num number := -24274;  
  miss_inst_dd_msg varchar2(76) := 'HS$_INST_DD';    

  dupl_inst_dd exception;             
  pragma exception_init(dupl_inst_dd, -24270);  
  dupl_inst_dd_num number := -24270;  
  dupl_inst_dd_msg varchar2(76) := 'HS$_INST_DD';    

  miss_inst_init exception;
  pragma exception_init(miss_inst_init, -24274);
  miss_inst_init_num number := -24274;
  miss_inst_init_msg varchar2(76) := 'HS$_INST_INIT';

  dupl_inst_init exception;           
  pragma exception_init(dupl_inst_init, -24270);
  dupl_inst_init_num number := -24270;
  dupl_inst_init_msg varchar2(76) := 'HS$_INST_INIT';
 --------------------------------
  -- Public procedures
  -- 

  --------------------------------
  -- create_base_caps procedure
  --
  -- This procedure creates a row in the HS$_BASE_CAPS table.
  -- 
  
  procedure create_base_caps(         
    CAP_NUMBER in NUMBER,             
    CAP_DESCRIPTION in VARCHAR2 := null);       

  --------------------------------
  -- create_base_dd procedure
  -- 
  -- This procedure creates a row in the HS$_BASE_DD table.
  --

  procedure create_base_dd(           
    DD_TABLE_NAME in VARCHAR2,        
    DD_TABLE_DESC in VARCHAR2 := null);         

  --------------------------------
  -- create_class_caps procedure
  -- 
  -- This procedure creates a row in the HS$_CLASS_CAPS table.  
  -- The FDS_CLASS_NAME must be exist in the HS$_FDS_CLASS table.
  -- The CAP_NUMBER must be defined in the HS$_BASE_CAPS table.

  procedure create_class_caps(        
    FDS_CLASS_NAME in VARCHAR2,       
    CAP_NUMBER in NUMBER,             
    CONTEXT in NUMBER := null,        
    TRANSLATION in VARCHAR2 := null,  
    ADDITIONAL_INFO in NUMBER := null);         

  --------------------------------
  -- create_class_dd procedure
  -- 
  -- This procedure creates a row in the HS$_CLASS_DD table.
  -- The FDS_CLASS_NAME must exist in the HS$_FDS_CLASS table.
  -- The DD_TABLE_NAME must exist in the HS$_BASE_DD table.
  -- TRANSLATION_TYPE must be either 'T' (translated) or 'M'
  -- (mimicked).  If TRANSLATION_TYPE = 'T' then the TRANSLATION_TEXT
  -- string must be supplied.

  procedure create_class_dd(          
    FDS_CLASS_NAME in VARCHAR2,       
    DD_TABLE_NAME in VARCHAR2,        
    TRANSLATION_TYPE in CHAR,         
    TRANSLATION_TEXT in VARCHAR2 := null);      

  --------------------------------
  -- create_class_init procedure
  -- 
  -- This procedure creates a row in the HS$_CLASS_INIT table.
  -- The FDS_CLASS_NAME must exist in the HS$_FDS_CLASS table.
  -- The INIT_VALUE_TYPE must either 'F' (environment variable) or 
  -- 'M' (not an environment variable).

  procedure create_class_init(        
    FDS_CLASS_NAME in VARCHAR2,       
    INIT_VALUE_NAME in VARCHAR2,      
    INIT_VALUE in VARCHAR2,           
    INIT_VALUE_TYPE in VARCHAR2);     

  --------------------------------
  -- create_fds_class procedure
  -- 
  -- This procedure creates a row in the HS$_FDS_CLASS table.

  procedure create_fds_class(         
    FDS_CLASS_NAME in VARCHAR2,       
    FDS_CLASS_COMMENTS in VARCHAR2 := null);    

  --------------------------------
  -- create_fds_inst procedure
  -- 
  -- This procedure creates a row in the HS$_FDS_INST table.
  -- The FDS_CLASS_NAME must exist in the HS$_FDS_CLASS table.
  
  procedure create_fds_inst(          
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    FDS_INST_COMMENTS in VARCHAR2 := null);     

  --------------------------------
  -- create_inst_caps procedure
  -- 
  -- This procedure creates a row in the HS$_INST_CAPS table.
  -- The FDS_INST_NAME must exist in the HS$_FDS_INST table and 
  -- be defined for the row in HS$_FDS_CLASS specified by the FDS_CLASS_NAME
  -- row.  The CAP_NUMBER must be defined in the HS$_BASE_CAPS table.

  procedure create_inst_caps(         
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    CAP_NUMBER in NUMBER,             
    CONTEXT in NUMBER := null,        
    TRANSLATION in VARCHAR2 := null,  
    ADDITIONAL_INFO in NUMBER := null);         

  --------------------------------
  -- create_inst_dd procedure
  -- 
  -- This procedure creates a row in the HS$_INST_DD table.
  -- The FDS_INST_NAME must be defined in the HS$_FDS_INST table and 
  -- must belong to the FDS_CLASS specified by the HS$_FDS_CLASS 
  -- parameter.  The DD_TABLE_NAME must be defined in the HS$_BASE_DD 
  -- table.  TRANSLATION_TYPE must be either 'T' (translated) or 'M'
  -- (mimicked).  If TRANSLATION_TYPE is 'T', then TRANSLATION_TEXT
  -- must be supplied.
  
  procedure create_inst_dd(           
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    DD_TABLE_NAME in VARCHAR2,        
    TRANSLATION_TYPE in CHAR,         
    TRANSLATION_TEXT in VARCHAR2 := null);      

  --------------------------------
  -- create_inst_init procedure
  -- 
  -- This procedure creates a row in the HS$_INST_INIT table.
  -- The FDS_INST_NAME must exist in the HS$_FDS_INST table and
  -- must be exist in the HS$_FDS_CLASS table as specified by 
  -- the FDS_CLASS_NAME parameter. The INIT_VALUE_TYPE must 
  -- be defined either 'F' or 'T'.

  procedure create_inst_init(         
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    INIT_VALUE_NAME in VARCHAR2,      
    INIT_VALUE in VARCHAR2,           
    INIT_VALUE_TYPE in VARCHAR2);     

  --------------------------------
  -- drop_base_caps procedure
  -- 
  -- This procedure drops a row from the HS$_BASE_CAPS table as specified 
  -- by the CAP_NUMBER parameter.

  procedure drop_base_caps(           
    CAP_NUMBER in NUMBER);            

  --------------------------------
  -- drop_base_dd procedure
  -- 
  -- drops a row from the HS$_BASE_DD table as specified by table_name.
  
  procedure drop_base_dd(             
    DD_TABLE_NAME in VARCHAR2);       

  --------------------------------
  -- drop_class_caps procedure
  -- 
  -- This procedure deletes a row from the HS$_CLASS_CAPS table
  -- as specified by the FDS_CLASS_NAME and CAP_NUMBER.

  procedure drop_class_caps(          
    FDS_CLASS_NAME in VARCHAR2,       
    CAP_NUMBER in NUMBER);            

  --------------------------------
  -- drop_class_dd procedure
  -- 
  -- Deletes row in HS$_CLASS_DD specified by FDS_CLASS_NAME and DD_TABLE_NAME

  procedure drop_class_dd(            
    FDS_CLASS_NAME in VARCHAR2,       
    DD_TABLE_NAME in VARCHAR2);       

  --------------------------------
  -- drop_class_init procedure
  -- 
  -- Drops row in HS$_CLASS_INIT as specified by FDS_CLASS_NAME and 
  -- INIT_VALUE_NAME.

  procedure drop_class_init(          
    FDS_CLASS_NAME in VARCHAR2,       
    INIT_VALUE_NAME in VARCHAR2);     

  --------------------------------
  -- drop_fds_class procedure
  --
  -- Drops row in HS$_FDS_CLASS as specified by FDS_CLASS_NAME;
 
  procedure drop_fds_class(           
    FDS_CLASS_NAME in VARCHAR2);      

  --------------------------------
  -- drop_fds_inst procedure
  -- 
  -- Drops row in HS$_FDS_INST table as specified by FDS_INST_NAME
  -- and FDS_CLASS_NAME.

  procedure drop_fds_inst(            
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2);      

  --------------------------------
  -- drop_inst_caps
  --
  -- delete rows in HS$_INST_CAPS specified by FDS_INST_NAME, FDS_CLASS_NAME
  -- and CAP_NUMBER

  procedure drop_inst_caps(           
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    CAP_NUMBER in NUMBER);            

  --------------------------------
  -- drop_inst_dd
  --
  -- Drops rows from HS$_INST_DD specified by FDS_INST_NAME, FDS_CLASS_NAME
  -- and DD_TABLE_NAME.

  procedure drop_inst_dd(             
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    DD_TABLE_NAME in VARCHAR2);       

  --------------------------------
  -- drop_inst_init
  --
  -- Drops rows from HS$_INST_INIT table as specified by 
  -- FDS_INST_NAME, FDS_CLASS_NAME, and INIT_VALUE_NAME.

  procedure drop_inst_init(           
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    INIT_VALUE_NAME in VARCHAR2);     

  --------------------------------
  -- alter_base_caps
  --
  -- This procedure alters a row in the HS$_BASE_CAPS table.

  procedure alter_base_caps(          
    CAP_NUMBER in NUMBER,             
    new_CAP_NUMBER in NUMBER := -1e-130,        
    new_CAP_DESCRIPTION in VARCHAR2 := '-');    

  --------------------------------
  -- alter_base_dd
  -- 
  -- This procedure alters a row in the HS$_BASE_DD table.
  
  procedure alter_base_dd(            
    DD_TABLE_NAME in VARCHAR2,        
    new_DD_TABLE_NAME in VARCHAR2 := '-',       
    new_DD_TABLE_DESC in VARCHAR2 := '-');      

  --------------------------------
  -- alter_class_caps
  -- 
  -- This procedure alters the contents of the HS$_CLASS_CAPS table.

  procedure alter_class_caps(         
    FDS_CLASS_NAME in VARCHAR2,       
    CAP_NUMBER in NUMBER,             
    new_FDS_CLASS_NAME in VARCHAR2 := '-',      
    new_CAP_NUMBER in NUMBER := -1e-130,        
    new_CONTEXT in NUMBER := -1e-130, 
    new_TRANSLATION in VARCHAR2 := '-',         
    new_ADDITIONAL_INFO in NUMBER := -1e-130);  

  --------------------------------
  -- alter_class_dd
  --
  -- This procedure modifies the contents of the HS$_CLASS_DD table.

  procedure alter_class_dd(           
    FDS_CLASS_NAME in VARCHAR2,       
    DD_TABLE_NAME in VARCHAR2,        
    new_FDS_CLASS_NAME in VARCHAR2 := '-',      
    new_DD_TABLE_NAME in VARCHAR2 := '-',       
    new_TRANSLATION_TYPE in CHAR := '-',        
    new_TRANSLATION_TEXT in VARCHAR2 := '-');   

  --------------------------------
  -- alter_class_init
  -- 
  -- This procedure alters the contents of the HS$_CLASS_INIT table.

  procedure alter_class_init(         
    FDS_CLASS_NAME in VARCHAR2,       
    INIT_VALUE_NAME in VARCHAR2,      
    new_FDS_CLASS_NAME in VARCHAR2 := '-',      
    new_INIT_VALUE_NAME in VARCHAR2 := '-',     
    new_INIT_VALUE in VARCHAR2 := '-',
    new_INIT_VALUE_TYPE in VARCHAR2 := '-');    

  --------------------------------
  -- alter_fds_class
  -- 
  -- Alters the contents of the HS$_FDS_CLASS table.

  procedure alter_fds_class(          
    FDS_CLASS_NAME in VARCHAR2,       
    new_FDS_CLASS_NAME in VARCHAR2 := '-',      
    new_FDS_CLASS_COMMENTS in VARCHAR2 := '-'); 

  --------------------------------
  -- alter_fds_inst
  -- 
  -- Modifies the contents of the HS$_FDS_INST table.

  procedure alter_fds_inst(           
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    new_FDS_INST_NAME in VARCHAR2 := '-',       
    new_FDS_CLASS_NAME in VARCHAR2 := '-',      
    new_FDS_INST_COMMENTS in VARCHAR2 := '-');  

  --------------------------------
  -- alter_inst_caps procedures
  --
  -- Modifies the contents of the $HS_INST_CAPS table.

  procedure alter_inst_caps(          
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    CAP_NUMBER in NUMBER,             
    new_FDS_INST_NAME in VARCHAR2 := '-',       
    new_FDS_CLASS_NAME in VARCHAR2 := '-',      
    new_CAP_NUMBER in NUMBER := -1e-130,        
    new_CONTEXT in NUMBER := -1e-130, 
    new_TRANSLATION in VARCHAR2 := '-',         
    new_ADDITIONAL_INFO in NUMBER := -1e-130);  

  --------------------------------
  -- alter_inst_dd
  --
  -- Alters the contents of the HS$_INST_DD table.

  procedure alter_inst_dd(            
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    DD_TABLE_NAME in VARCHAR2,        
    new_FDS_INST_NAME in VARCHAR2 := '-',       
    new_FDS_CLASS_NAME in VARCHAR2 := '-',      
    new_DD_TABLE_NAME in VARCHAR2 := '-',       
    new_TRANSLATION_TYPE in CHAR := '-',        
    new_TRANSLATION_TEXT in VARCHAR2 := '-');   

  --------------------------------
  -- alter_inst_init
  --
  -- Alters the contents of the HS$_INST_INIT table.

  procedure alter_inst_init(          
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    INIT_VALUE_NAME in VARCHAR2,      
    new_FDS_INST_NAME in VARCHAR2 := '-',       
    new_FDS_CLASS_NAME in VARCHAR2 := '-',      
    new_INIT_VALUE_NAME in VARCHAR2 := '-',     
    new_INIT_VALUE in VARCHAR2 := '-',
    new_INIT_VALUE_TYPE in VARCHAR2 := '-');    
 
  -------------------------------
  -- copy_inst 
  -- 
  -- copies everything for an HS$_FDS_INST to 
  -- a new inst in the same FDS_CLASS

  procedure copy_inst(FDS_INST_NAME in VARCHAR2,
                      FDS_CLASS_NAME in VARCHAR2,
                      new_FDS_INST_NAME in VARCHAR2,
                      new_FDS_COMMENTS in VARCHAR2 default '-');

  -------------------------------
  -- copy_class 
  --
  -- Copies everything for a class to another class
  procedure copy_class(old_fds_class_name varchar2,
                       new_fds_class_name varchar2,
                       new_fds_class_comments varchar2 default '-');


  --------------------------------
  -- replace_base_caps
  --
  -- This procedure creates  or replaces a row in the HS$_BASE_CAPS table.
  -- It will first attempt to update the row in hs$_base_caps.  If the row
  -- does not exist, it will attempt to insert the row.
  -- The new_CAP_NUMBER parameter is ignored if the row specified by 
  -- CAP_NUMBER does not exist.

  procedure replace_base_caps(          
    CAP_NUMBER in NUMBER,             
    new_CAP_NUMBER in NUMBER := null,        
    new_CAP_DESCRIPTION in VARCHAR2 := null);    

  --------------------------------
  -- replace_base_dd
  --
  -- This procedure does a create or replace on a row in the HS$_BASE_DD 
  -- table.  First, this procedure will attempt to update the row.  If 
  -- the row does not exist, it is inserted.  
  -- The new_DD_TABLE_NAME parameter is ignored if the row does not 
  -- exist.

  procedure replace_base_dd(            
    DD_TABLE_NAME in VARCHAR2,        
    new_DD_TABLE_NAME in VARCHAR2 := null,       
    new_DD_TABLE_DESC in VARCHAR2 := null);

  --------------------------------
  -- replace_class_caps
  --
  -- This procedure does a 'create or replace' on the HS$_CLASS_CAPS table.
  -- If a row exists for the FDS_CLASS_NAME and CAP_NUMBER, it is updated.
  -- If a row does not exist, it is inserted.
  -- If a row does not exist, the new_FDS_CLASS_NAME and new_CAP_NUMBER 
  -- parameters are ignored.

  procedure replace_class_caps(         
    FDS_CLASS_NAME in VARCHAR2,       
    CAP_NUMBER in NUMBER,             
    new_FDS_CLASS_NAME in VARCHAR2 := NULL,      
    new_CAP_NUMBER in NUMBER := null,        
    new_CONTEXT in NUMBER := NULL, 
    new_TRANSLATION in VARCHAR2 := NULL,         
    new_ADDITIONAL_INFO in NUMBER := NULL);

  --------------------------------
  -- replace_class_dd
  -- 
  -- This procedure performs a 'create or replace' on the HS$_CLASS_DD table.
  -- If a row exists for the FDS_CLASS_NAME and DD_TABLE_NAME then the row
  -- is updated.  If a row does not exist, it is inserted.
  -- If a row does not exist, the new_FDS_CLASS_NAME and new_DD_TABLE_NAME
  -- parameters are ignored.

  procedure replace_class_dd(           
    FDS_CLASS_NAME in VARCHAR2,       
    DD_TABLE_NAME in VARCHAR2,        
    new_FDS_CLASS_NAME in VARCHAR2 := NULL,      
    new_DD_TABLE_NAME in VARCHAR2 := NULL,       
    new_TRANSLATION_TYPE in CHAR := NULL,        
    new_TRANSLATION_TEXT in VARCHAR2 := NULL);

  --------------------------------
  -- replace_class_init
  --
  -- This procedure will create or update a row in the HS$_CLASS_INIT table.
  -- If a row exists with the specified FDS_CLASS_NAME and INIT_VALUE_NAME,
  -- it will be updated.  If the row does not exist, it is inserted.  If 
  -- the row does not exist, new_FDS_CLASS_NAME and new_INIT_VALUE_NAME 
  -- parameters are ignored.

  procedure replace_class_init(         
    FDS_CLASS_NAME in VARCHAR2,       
    INIT_VALUE_NAME in VARCHAR2,      
    new_FDS_CLASS_NAME in VARCHAR2 := NULL,      
    new_INIT_VALUE_NAME in VARCHAR2 := NULL,     
    new_INIT_VALUE in VARCHAR2 := NULL,
    new_INIT_VALUE_TYPE in VARCHAR2 := NULL);

  --------------------------------
  -- replace_fds_class
  --
  -- This procedure does create or replace operations on the 
  -- HS$_FDS_CLASS table.  If a row exists for the FDS_CLASS_NAME,
  -- it is updated.  If no row exists, it is created.  If no row exists,
  -- the new_FDS_CLASS_NAME parameter is ignored.
 
  procedure replace_fds_class(          
    FDS_CLASS_NAME in VARCHAR2,       
    new_FDS_CLASS_NAME in VARCHAR2 := NULL,      
    new_FDS_CLASS_COMMENTS in VARCHAR2 := NULL);

  --------------------------------
  -- replace_fds_inst
  -- 
  -- This procedure creates or replaces rows in the HS$_FDS_INST table.
  -- If a row exists for the FDS_INST_NAME and FDS_CLASS_NAME, it is 
  -- updated.  If no row exists, it is created.
  -- If no row exists, the new_FDS_INST_NAME and new_FDS_CLASS_NAME 
  -- parameters are ignored when performing the insert.

  procedure replace_fds_inst(           
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    new_FDS_INST_NAME in VARCHAR2 := NULL,       
    new_FDS_CLASS_NAME in VARCHAR2 := NULL,      
    new_FDS_INST_COMMENTS in VARCHAR2 := NULL);

  --------------------------------
  -- replace_inst_caps
  -- 
  -- This procedure does a create or replace on the HS$_INST_CAPS table.
  -- If no row exists for the FDS_INST_NAME, FDS_CLASS_NAME and CAP_NUMBER,
  -- the row is created.
  -- If a row exists, it is updated.
  -- In the case where an insert is performed, the new_FDS_INST_NAME,
  -- new_FDS_CLASS_NAME and new_CLASS_NUMBER parameters are ignored.

  procedure replace_inst_caps(          
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    CAP_NUMBER in NUMBER,             
    new_FDS_INST_NAME in VARCHAR2 := NULL,       
    new_FDS_CLASS_NAME in VARCHAR2 := NULL,      
    new_CAP_NUMBER in NUMBER := NULL,        
    new_CONTEXT in NUMBER := NULL, 
    new_TRANSLATION in VARCHAR2 := NULL,         
    new_ADDITIONAL_INFO in NUMBER := NULL);

  --------------------------------
  -- replace_inst_dd
  -- 
  -- This procedure performs a create or replace operation on the 
  -- HS$_INST_DD table.  If a row exists for the FDS_INST_NAME, 
  -- FDS_CLASS_NAME and DD_TABLE_NAME, it is updated.  If no row 
  -- exists, it is created and the new_FDS_INST_NAME, new_FDS_CLASS_NAME,
  -- and new_DD_TABLE_NAME values are ignored.

  procedure replace_inst_dd(            
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    DD_TABLE_NAME in VARCHAR2,        
    new_FDS_INST_NAME in VARCHAR2 := NULL,       
    new_FDS_CLASS_NAME in VARCHAR2 := NULL,      
    new_DD_TABLE_NAME in VARCHAR2 := NULL,       
    new_TRANSLATION_TYPE in CHAR := NULL,        
    new_TRANSLATION_TEXT in VARCHAR2 := NULL);

  --------------------------------
  -- replace_inst_init
  -- 
  -- This procedure performs a create or replace on the HS$_INST_INIT table.
  -- If a row exists with the FDS_INST_NAME, FDS_CLASS_NAME and 
  -- and INIT_VALUE_NAME, it is updated.  If a row does not exist, it is 
  -- created.  In the creation case, the new_FDS_INST_NAME, new_FDS_CLASS_NAME
  -- and new_INIT_VALUE_NAME are ignored.

  procedure replace_inst_init(          
    FDS_INST_NAME in VARCHAR2,        
    FDS_CLASS_NAME in VARCHAR2,       
    INIT_VALUE_NAME in VARCHAR2,      
    new_FDS_INST_NAME in VARCHAR2 := NULL,       
    new_FDS_CLASS_NAME in VARCHAR2 := NULL,      
    new_INIT_VALUE_NAME in VARCHAR2 := NULL,     
    new_INIT_VALUE in VARCHAR2 := NULL,
    new_INIT_VALUE_TYPE in VARCHAR2 := NULL);

end "DBMS_HS";                        
/
grant execute on dbms_hs to hs_admin_execute_role;

create or replace public synonym dbms_hs for dbms_hs;

