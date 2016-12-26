Rem
Rem $Header: dbmsstts.sql 20-jan-2003.14:57:43 aamor Exp $
Rem
Rem dbmsstts.sql
Rem
Rem Copyright (c) 2002, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsstts.sql - DBMS Statistical functions
Rem
Rem    DESCRIPTION
Rem      This file contains the interface for the DBMS Statistical 
Rem      Functions Package (DBMS_STAT_FUNCS). It provides procedures
Rem      to do distribution fitting and to summarize numerical data.
Rem
Rem    NOTES
Rem      The summaryType type uses cmode instead of mode because mode
Rem      is a reserved word in plsql.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aamor       01/13/03 - rename dbms_stts to dbms_stat_funcs
Rem    tbingol     10/22/02 - Improvements
Rem    tbingol     10/18/02 - tbingol_dbms_statistics
Rem    tbingol     09/23/02 - Created
Rem

create or replace package dbms_stat_funcs authid current_user is

  TYPE n_arr IS VARRAY(5) of NUMBER;
  TYPE num_table IS TABLE of NUMBER;

  TYPE summaryType IS RECORD (
        count           NUMBER,
        min             NUMBER,
        max             NUMBER,
        range           NUMBER,
        mean            NUMBER,
        cmode           num_table,
        variance        NUMBER, 
        stddev          NUMBER,
        quantile_5      NUMBER,
        quantile_25     NUMBER,
        median          NUMBER,
        quantile_75     NUMBER,
        quantile_95     NUMBER,    
        plus_x_sigma    NUMBER, 
        minus_x_sigma   NUMBER,
        extreme_values  num_table,
        top_5_values    n_arr,
        bottom_5_values n_arr);

 -----------------------------------------------------------------------
 -- SUMMARY
 -- Summarizes a numerical column of a table. 
 -- The input parameters are the table name, the column name and the 
 -- name of the owner of the table, as well as the sigma value, which
 -- defaults to 3. 
 -- The output is a record of type summaryType, which contains the 
 -- following information for the set of numbers in the column: the
 -- count, minimum value, maximum value, range, mean, mode, variance,
 -- standard deviation, five quantile values (5%, 25%, 50% or median,
 -- 75% and 95%), the value of the mean plus (and minus) sigma times
 -- the standard deviation, the set of extreme values (defined as the
 -- ones that fall outside of the plus/minus sigma values), the top 5
 -- and the bottom 5 values. 
 -----------------------------------------------------------------------
 procedure SUMMARY(p_ownername       IN  varchar2,
                   p_tablename       IN  varchar2,
                   p_columnname      IN  varchar2,
                   p_sigma_value     IN  number := 3, 
                   s                 OUT NOCOPY SummaryType);

 -----------------------------------------------------------------------
 -- NORMAL_DIST_FIT
 -- Calculates how well the data in the input column fits a normal
 -- distribution.  The p_test_type input parameter can be one of the
 -- following: 'SHAPIRO_WILKS' (the default), 'KOLMOGOROV_SMIRNOV',
 -- 'ANDERSON_DARLING' or 'CHI_SQUARED'.  The output of this procedure
 -- is the significance of the fit.
 -- mean is the location parameter
 -- stddev is the scale parameter
 -----------------------------------------------------------------------
 procedure NORMAL_DIST_FIT(
         ownername    IN  varchar2, 
         tablename    IN  varchar2, 
         columnname   IN  varchar2,
         test_type    IN  varchar2 DEFAULT 'SHAPIRO_WILKS',
         mean         IN OUT number,
         stdev        IN OUT number,
         sig          OUT number);

 -----------------------------------------------------------------------
 -- UNIFORM_DIST_FIT
 -- Calculates how well the data in the input column fits a uniform
 -- distribution.  The p_test_type input parameter can be one of the
 -- following: 'KOLMOGOROV_SMIRNOV' (the default), 'ANDERSON_DARLING'
 -- or 'CHI_SQUARED'.  The var_type input parameter can be 
 -- 'CONTINUOUS' (the default) or 'DISCRETE'.  The output of this
 -- procedure is the significance of the fit.
 -- paramA is location parameter
 -- paramB is scale parameter
 -- For the continuous case, the probability density function
 -- is f(x)= 1 / (B - A) and the cumulative distribution function
 -- is F(x) = (x - A) / (B - A)
 -----------------------------------------------------------------------
 procedure UNIFORM_DIST_FIT(
         ownername   IN  varchar2, 
         tablename   IN  varchar2, 
         columnname  IN  varchar2,
         var_type    IN  varchar2 DEFAULT 'CONTINUOUS',
         test_type   IN  varchar2 DEFAULT 'KOLMOGOROV_SMIRNOV',
         paramA      IN OUT number,
         paramB      IN OUT number,
         sig         OUT number);  

 -----------------------------------------------------------------------
 -- POISSON_DIST_FIT
 -- Calculates how well the data in the input column fits a Poisson
 -- distribution.  The p_test_type input parameter can be one of the
 -- following: 'KOLMOGOROV_SMIRNOV' (the default) or 'ANDERSON_DARLING'
 -- The output of this procedure is the significance of the fit.
 -- lambda is the shape parameter.
 -----------------------------------------------------------------------
 procedure POISSON_DIST_FIT(
         ownername   IN  varchar2, 
         tablename   IN  varchar2, 
         columnname  IN  varchar2,
         test_type   IN  varchar2 DEFAULT 'KOLMOGOROV_SMIRNOV',
         lambda      IN OUT number,
         sig         OUT number);

 -----------------------------------------------------------------------
 -- WEIBULL_DIST_FIT
 -- Calculates how well the data in the input column fits a Weibull
 -- distribution.  The p_test_type input parameter can be one of the
 -- following: 'KOLMOGOROV_SMIRNOV' (the default), 'ANDERSON_DARLING'
 -- or 'CHI_SQUARED'.  The output of this procedure is the significance
 -- of the fit.
 -- alpha is the scale parameter.
 -- mu is the location parameter.
 -- beta is the slope/shape parameter.
 -----------------------------------------------------------------------
 procedure WEIBULL_DIST_FIT(
         ownername   IN  varchar2, 
         tablename   IN  varchar2, 
         columnname  IN  varchar2,
         test_type   IN  varchar2 DEFAULT 'KOLMOGOROV_SMIRNOV',
         alpha       IN OUT number,
         mu          IN OUT number,
         beta        IN OUT number,
         sig         OUT number);

 -----------------------------------------------------------------------
 -- EXPONENTIAL_DIST_FIT
 -- Calculates how well the data in the input column fits an exponential
 -- distribution.  The p_test_type input parameter can be one of the
 -- following: 'KOLMOGOROV_SMIRNOV' (the default), 'ANDERSON_DARLING'
 -- or 'CHI_SQUARED'.  The output of this procedure is the significance
 -- of the fit.
 -- lambda is the scale parameter
 -- mu is the location parameter
 -----------------------------------------------------------------------
 procedure EXPONENTIAL_DIST_FIT(
         ownername   IN  varchar2, 
         tablename   IN  varchar2, 
         columnname  IN  varchar2,
         test_type   IN  varchar2 DEFAULT 'KOLMOGOROV_SMIRNOV',
         lambda      IN OUT number,
         mu          IN OUT number,
         sig         OUT number);  

end;
/

create or replace public synonym dbms_stat_funcs for sys.dbms_stat_funcs
/
grant execute on dbms_stat_funcs to public
/
-- create the trusted pl/sql callout library
create or replace library dbms_stat_funcs_lib trusted as static;
/
