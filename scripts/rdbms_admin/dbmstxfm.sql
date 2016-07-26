Rem
Rem $Header: dbmstxfm.sql 27-sep-2004.11:11:03 apadmana Exp $
Rem
Rem dbmstxfm.sql
Rem
Rem Copyright (c) 2000, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmstxfm.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apadmana    09/27/04 - lrg1545883
Rem    apadmana    09/21/04 - move dbms_transform_eximp to prvttxfm.sql 
Rem    apadmana    09/16/04 - make dbms_transform_eximp invokers rights 
Rem    wesmith     10/03/03 - pkg dbms_transform_eximp: add instance_info_exp()
Rem    weiwang     09/08/03 - default transformation schema to NULL during 
Rem                           import
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    nbhatt      03/27/01 - remove i_fetch_transformation
Rem    nbhatt      11/29/00 - add import_trans_Attr
Rem    nbhatt      11/28/00 - Created
Rem

-- Create the library where 3GL callouts will reside
CREATE OR REPLACE LIBRARY dbms_trans_lib trusted as static
/
CREATE OR REPLACE PACKAGE dbms_transform AS

  -- Create transformation
  PROCEDURE  CREATE_TRANSFORMATION(
		 schema           IN     VARCHAR2,
		 name             IN     VARCHAR2,
		 from_schema      IN     VARCHAR2,
		 from_type        IN     VARCHAR2,
		 to_schema        IN     VARCHAR2,
		 to_type          IN     VARCHAR2,
		 transformation   IN     VARCHAR2 default null);

  -- Drop transformation
  PROCEDURE  DROP_TRANSFORMATION(
		 schema           IN     VARCHAR2,
		 name             IN     VARCHAR2);

  PROCEDURE  MODIFY_TRANSFORMATION(
		 schema           IN     VARCHAR2,
		 name             IN     VARCHAR2,
		 attribute_number      IN      NUMBER,
		 transformation        IN       VARCHAR2);

  PROCEDURE  COMPUTE_TRANSFORMATION(
	        message                IN    "<ADT_1>",
		transformation_schema  IN     VARCHAR2,
		transformation_name    IN     VARCHAR2,
                transformed_message    OUT   "<ADT_1>");

END dbms_transform;
/




-- create public synonyms
--
CREATE OR REPLACE PUBLIC SYNONYM dbms_transform FOR sys.dbms_transform
/
   
