Rem
Rem $Header: catsumno.sql 10-may-00.13:11:11 btao Exp $
Rem
Rem catsumno.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      catsumno.sql
Rem
Rem    DESCRIPTION
Rem      Undefines the objects and/or views defined in catsum.sql
Rem
Rem    NOTES
Rem      Called in downgrade script files (eg c813d805.sql)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    btao        05/10/00 - drop additional advisor views
Rem    btao        01/12/00 - drop advisor views and packages
Rem    rshaikh     11/05/98 - dont drop dba_dimensions
Rem    awitkows    06/03/98 - add mview views
Rem    qiwang      05/28/98 - drop dbms_sumadv and dbms_sumvdm packages
Rem    qiwang      04/03/98 - Fix comments
Rem    qiwang      03/25/98 - Update according to changes made to catsum.sql
Rem    jfeenan     03/24/98 - Add downgrade of advisor packages
Rem    qiwang      03/24/98 - Drop more views created by catsum.sql
Rem    jfeenan     03/20/98 - Initial Creation
Rem    jfeenan     03/20/98 - Created
Rem

Rem Remove the catalog summary management info created in 8.1

Rem drop summary refresh packages

drop SYNONYM dbms_summary
/
drop PACKAGE dbms_summary
/
drop PACKAGE dbms_sumref_parent
/
drop PACKAGE dbms_sumref_child
/
drop PACKAGE dbms_sumref_util
/
drop PACKAGE dbms_sumref_util2
/
Rem Drop Advisor packages
Rem JJF have to add
drop PACKAGE dbms_sumadvisor
/  
drop PACKAGE dbms_sumvdm
/
drop PACKAGE dbms_sumadv
/
drop LIBRARY dbms_sumadv_lib
/

Rem Drop base summary/dimension information

Rem Drop DIMENSION FAMILY
Rem

drop public synonym ALL_DIMENSIONS
/
drop public synonym USER_DIMENSIONS
/
REM don't drop this view because it is needed to find the 
REM incompatible objects for a downgrade
REM drop view DBA_DIMENSIONS

drop view ALL_DIMENSIONS
/  	
drop view USER_DIMENSIONS
/  

Rem Drop DIM_LEVELS FAMILY
Rem

drop public synonym ALL_DIM_LEVELS
/
drop public synonym USER_DIM_LEVELS
/
drop view DBA_DIM_LEVELS
/  	
drop view ALL_DIM_LEVELS
/  	
drop view USER_DIM_LEVELS
/  


Rem Drop DIM_LEVEL_KEY FAMILY
Rem

drop public synonym ALL_DIM_LEVEL_KEY
/
drop public synonym USER_DIM_LEVEL_KEY
/
drop view DBA_DIM_LEVEL_KEY
/  	
drop view ALL_DIM_LEVEL_KEY
/  	
drop view USER_DIM_LEVEL_KEY
/  


Rem Drop DIM_ATTRIBUTES FAMILY
Rem

drop public synonym ALL_DIM_ATTRIBUTES
/
drop public synonym USER_DIM_ATTRIBUTES
/
drop view DBA_DIM_ATTRIBUTES
/  	
drop view ALL_DIM_ATTRIBUTES
/  	
drop view USER_DIM_ATTRIBUTES
/  


Rem Drop DIM_HIERARCHIES FAMILY
Rem

drop public synonym ALL_DIM_HIERARCHIES
/
drop public synonym USER_DIM_HIERARCHIES
/
drop view DBA_DIM_HIERARCHIES
/  	
drop view ALL_DIM_HIERARCHIES
/  	
drop view USER_DIM_HIERARCHIES
/  

Rem Drop DIM_CHILD_OF FAMILY
Rem

drop public synonym ALL_DIM_CHILD_OF
/
drop public synonym USER_DIM_CHILD_OF
/
drop view DBA_DIM_CHILD_OF
/  	
drop view ALL_DIM_CHILD_OF
/  	
drop view USER_DIM_CHILD_OF
/  


Rem Drop DIM_JOIN_KEY FAMILY
Rem

drop public synonym ALL_DIM_JOIN_KEY
/
drop public synonym USER_DIM_JOIN_KEY
/
drop view DBA_DIM_JOIN_KEY
/  	
drop view ALL_DIM_JOIN_KEY
/  	
drop view USER_DIM_JOIN_KEY
/  

Rem   

Rem Drop SUMMARIES FAMILY
Rem

drop public synonym ALL_SUMMARIES
/
drop public synonym USER_SUMMARIES
/
drop view DBA_SUMMARIES
/  	
drop view ALL_SUMMARIES
/  	
drop view USER_SUMMARIES
/  

Rem Drop SUMMARY_AGGREGATES FAMILY
Rem

drop public synonym ALL_SUMMARY_AGGREGATES
/
drop public synonym USER_SUMMARY_AGGREGATES
/
drop view DBA_SUMMARY_AGGREGATES
/  	
drop view ALL_SUMMARY_AGGREGATES
/  	
drop view USER_SUMMARY_AGGREGATES
/ 

Rem Drop SUMMARY_DETAIL_TABLES FAMILY
Rem

drop public synonym ALL_SUMMARY_DETAIL_TABLES
/
drop public synonym USER_SUMMARY_DETAIL_TABLES
/
drop view DBA_SUMMARY_DETAIL_TABLES
/  	
drop view ALL_SUMMARY_DETAIL_TABLES
/  	
drop view USER_SUMMARY_DETAIL_TABLES
/ 

Rem Drop SUMMARY_KEYS FAMILY
Rem

drop public synonym ALL_SUMMARY_KEYS
/
drop public synonym USER_SUMMARY_KEYS
/
drop view DBA_SUMMARY_KEYS
/  	
drop view ALL_SUMMARY_KEYS
/  	
drop view USER_SUMMARY_KEYS
/ 

Rem Drop SUMMARY_JOINS FAMILY
Rem

drop public synonym ALL_SUMMARY_JOINS
/
drop public synonym USER_SUMMARY_JOINS
/
drop view DBA_SUMMARY_JOINS
/  	
drop view ALL_SUMMARY_JOINS
/  	
drop view USER_SUMMARY_JOINS
/ 

Rem

Rem Drop MVIEW_ANALYSIS FAMILY
Rem

drop public synonym ALL_MVIEW_ANALYSIS
/
drop public synonym USER_MVIEW_ANALYSIS
/
drop view DBA_MVIEW_ANALYSIS
/  	
drop view ALL_MVIEW_ANALYSIS
/  	
drop view USER_MVIEW_ANALYSIS
/  

Rem Drop MVIEW_AGGREGATES FAMILY
Rem

drop public synonym ALL_MVIEW_AGGREGATES
/
drop public synonym USER_MVIEW_AGGREGATES
/
drop view DBA_MVIEW_AGGREGATES
/  	
drop view ALL_MVIEW_AGGREGATES
/  	
drop view USER_MVIEW_AGGREGATES
/ 

Rem Drop SUMMARY_DETAIL_RELATIONS FAMILY
Rem

drop public synonym ALL_MVIEW_DETAIL_RELATIONS
/
drop public synonym USER_MVIEW_DETAIL_RELATIONS
/
drop view DBA_MVIEW_DETAIL_RELATIONS
/  	
drop view ALL_MVIEW_DETAIL_RELATIONS
/  	
drop view USER_MVIEW_DETAIL_RELATIONS
/ 

Rem Drop MVIEW_KEYS FAMILY
Rem

drop public synonym ALL_MVIEW_KEYS
/
drop public synonym USER_MVIEW_KEYS
/
drop view DBA_MVIEW_KEYS
/  	
drop view ALL_MVIEW_KEYS
/  	
drop view USER_MVIEW_KEYS
/ 

Rem Drop MVIEW_JOINS FAMILY
Rem

drop public synonym ALL_MVIEW_JOINS
/
drop public synonym USER_MVIEW_JOINS
/
drop view DBA_MVIEW_JOINS
/  	
drop view ALL_MVIEW_JOINS
/  	
drop view USER_MVIEW_JOINS
/ 


drop public synonym ALL_REFRESH_DEPENDENCIES
/
drop view ALL_REFRESH_DEPENDENCIES
/


Rem Drop All advisor views 
Rem

drop view SYSTEM.MVIEW_WORKLOAD
/
drop view SYSTEM.MVIEW_RECOMMENDATIONS
/
drop view SYSTEM.MVIEW_EVALUATIONS
/
drop view  SYSTEM.MVIEW_EXCEPTIONS
/
drop view  SYSTEM.MVIEW_LOG
/
drop view  SYSTEM.MVIEW_FILTER
/

