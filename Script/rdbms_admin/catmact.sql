Rem
Rem
Rem Copyright (c) 2004, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem    NAME
Rem      catmact.sql
Rem
Rem    DESCRIPTION
Rem      Create the MACSEC triggers
Rem
Rem    NOTES
Rem      Run as DVSYS
Rem    MODIFIED (MM/DD/YY)
Rem    jsamuel   01/12/09  - move audit statements to catmaca.sql
Rem    youyang   10/21/08  - Remove DDL triggers
Rem    clei      09/03/08  - bug 6435192: trigger driven by enforcement status 
Rem    clei      05/09/08  - bug 7025501
Rem    pyoun     05/25/07  - fix bug 6001677
Rem    rvissapr  12/08/06  - figure correct current user for DV triggers
Rem    clei      12/07/06  - DV no longer needs VPD policies
Rem    jciminsk  05/02/06  - cleanup embedded file boilerplate 
Rem    jciminsk  05/02/06  - created admin/catmact.sql 
Rem    ayalaman  04/03/06  - post DDL trigger for dict maint 
Rem    sgaetjen  02/22/06  - XbranchMerge sgaetjen_dvopt2 from 
Rem                          st_rdbms_10.2audit 
Rem    sgaetjen  02/13/06  - add CREATE VIEW,TABLE,SYN synch logic 
Rem    sgaetjen  01/16/06  - remove commented init_session 
Rem    sgaetjen  01/03/06  - remove login trigger 
Rem    sgaetjen  08/18/05  - Disable triggers until last step in install 
Rem    sgaetjen  08/11/05  - sgaetjen_dvschema
Rem    sgaetjen  08/08/05  - Remove table DML 
Rem    sgaetjen  07/30/05  - separate DVSYS and SYS commands 
Rem    sgaetjen  07/28/05  - dos2unix
Rem    raustin   11/11/04  - Created
Rem
Rem
Rem 
Rem
Rem
Rem    DESCRIPTION
Rem      Creates functions data for DVF account based on factor$ table.
Rem


SET SERVEROUT ON SIZE 1000000
DECLARE
    l_exp dvsys.dv$factor.get_expr%TYPE;
    l_name dvsys.dv$factor.name%TYPE;
    l_sql VARCHAR2(1000);

BEGIN
    FOR c99 IN (
        SELECT id# , name, get_expr
        FROM dvsys.factor$
        --FROM dvsys.dv$factor
        ) LOOP
        -- WHERE get_expr IS NOT NULL
        l_exp := c99.get_expr;
        l_name := c99.name;

        BEGIN
            dvf.dbms_macsec_function.create_factor_function(DVSYS.dbms_macutl.to_oracle_identifier(l_name));
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line ('sddvffnc: factor=' || l_name || ',error=' || sqlerrm );
        END;

    END LOOP;
END;
/

SET SERVEROUT OFF;


