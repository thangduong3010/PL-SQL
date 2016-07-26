Rem
Rem $Header: utlnla.sql 25-may-2006.11:01:46 lvbcheng Exp $
Rem
Rem utlnla.sql
Rem
Rem Copyright (c) 2003, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utlnla.sql - UTiLity Numerical Linear Algebra
Rem
Rem    DESCRIPTION
Rem      PL/SQL language bindings for the BLAS and LAPACK libraries.
Rem
Rem    NOTES
Rem      BLAS   Website: http://www.netlib.org/blas
Rem      LAPACK Website: http://www.netlib.org/lapack
Rem
Rem      Instructions for adding language binding for new BLAS/LAPACK
Rem      routines to this package are in prvtnla.sql.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lvbcheng    05/25/06 - Remove dependency on NOT NULL 
Rem    achaudhr    07/29/04 - add detailed comments describing the arguments
Rem    lvbcheng    06/09/04 - lvbcheng_matrix_prototype
Rem    lvbcheng    05/07/04 - Swap info params 
Rem    lvbcheng    05/04/04 - Change info to out param 
Rem    lvbcheng    12/24/03 - Created
Rem

CREATE OR REPLACE TYPE UTL_NLA_ARRAY_DBL is VARRAY(1000000) OF BINARY_DOUBLE;
/
CREATE OR REPLACE TYPE UTL_NLA_ARRAY_FLT is VARRAY(1000000) OF BINARY_FLOAT;
/
CREATE OR REPLACE TYPE UTL_NLA_ARRAY_INT is VARRAY(1000000) OF INTEGER;
/

CREATE OR REPLACE PACKAGE UTL_NLA as
  
  --
  -- Types
  --
  
  SUBTYPE scalar_double IS BINARY_DOUBLE                     NOT NULL;
  SUBTYPE scalar_float  IS BINARY_FLOAT                      NOT NULL;
  
  SUBTYPE flag          IS CHAR(1)                           NOT NULL;
  
  --  -------------------------------------------------------------
  --    flag   |  legal values
  --  -------------------------------------------------------------
  --    trans  |  'N' or 'n' => No traspose
  --           |  'T' or 't' => Transpose
  --           |
  --    uplo   |  'U' or 'u' => Upper-triangular
  --           |  'L' or 'l' => Lower-triangular
  --           |
  --    diag   |  'N' or 'n' => Non-unit triangular
  --           |  'U' or 'u' => Unit triangular
  --           |
  --    side   |  'L' or 'l' => Left
  --           |  'R' or 'r' => Right
  --           |
  --    pack   |  'R' or 'r' => Row-major array
  --           |  'C' or 'c' => Column-major array
  --           |
  --    jobz   |  'N' => only eigenvalues computed
  --           |  'V' => both eigenvalues and eigenvectors computed
  --           |
  --  -------------------------------------------------------------
  
  -- ------------- --
  -- Unit Testing 
  -- ------------- --

  PROCEDURE unit_test_blas;
  PROCEDURE unit_test_lapack;

  -- --------------------------------------- --
  -- BLAS Level 1 (Vector-Vector Operations)
  -- --------------------------------------- --
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_SWAPS swaps the contents of two vectors each of size n.
  --
  -- Arguments   
  -- =========   
  --
  -- N      - INTEGER.   
  --          On entry, N specifies the number of elements of the vectors X and Y.   
  --          N must be at least zero.   
  --          Unchanged on exit. 
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) )
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.     
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) )
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.     

  PROCEDURE blas_swap(n    IN     POSITIVEN,
                      x    IN OUT utl_nla_array_dbl,
                      incx IN     POSITIVEN,
                      y    IN OUT utl_nla_array_dbl,
                      incy IN     POSITIVEN);
  
  PROCEDURE blas_swap(n    IN     POSITIVEN,
                      x    IN OUT UTL_NLA_ARRAY_FLT,
                      incx IN     POSITIVEN,
                      y    IN OUT UTL_NLA_ARRAY_FLT,
                      incy IN     POSITIVEN);
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_SCAL scales a vector by a constant.
  --
  -- Arguments   
  -- =========   
  --
  -- N      - INTEGER.   
  --          On entry, N specifies the number of elements of the vectors X and Y.   
  --          N must be at least zero.   
  --          Unchanged on exit. 
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) )
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.
  
  PROCEDURE blas_scal(n     IN     POSITIVEN,
                      alpha IN     scalar_double,
                      x     IN OUT utl_nla_array_dbl,
                      incx  IN     POSITIVEN);
  
  PROCEDURE blas_scal(n     IN     POSITIVEN,
                      alpha IN     scalar_float,
                      x     IN OUT UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN);
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_COPY copies the contents of vector X  to vector Y.
  --
  -- Arguments   
  -- =========   
  --
  -- N      - INTEGER.   
  --          On entry, N specifies the number of elements of the vectors X and Y.   
  --          N must be at least zero.   
  --          Unchanged on exit. 
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) )
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.     
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) )
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.     
  
  PROCEDURE blas_copy(n    IN     POSITIVEN,
                      x    IN     utl_nla_array_dbl,
                      incx IN     POSITIVEN,
                      y    IN OUT utl_nla_array_dbl,
                      incy IN     POSITIVEN);
  
  PROCEDURE blas_copy(n    IN     POSITIVEN,
                      x    IN     UTL_NLA_ARRAY_FLT, 
                      incx IN     POSITIVEN,
                      y    IN OUT UTL_NLA_ARRAY_FLT, 
                      incy IN     POSITIVEN);
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_AXPY copies alpha*X + Y into vector Y.
  --
  -- Arguments   
  -- =========   
  --
  -- N      - INTEGER.   
  --          On entry, N specifies the number of elements of the vectors X and Y.   
  --          N must be at least zero.   
  --          Unchanged on exit. 
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) )
  --          Unchanged on exit.  
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.     
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) )
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.  

  PROCEDURE blas_axpy(n     IN     POSITIVEN,
                      alpha IN     scalar_double,
                      x     IN     utl_nla_array_dbl,
                      incx  IN     POSITIVEN,
                      y     IN OUT utl_nla_array_dbl,
                      incy  IN     POSITIVEN);
  
  PROCEDURE blas_axpy(n     IN     POSITIVEN,
                      alpha IN     scalar_float,
                      x     IN     UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      y     IN OUT UTL_NLA_ARRAY_FLT,
                      incy  IN     POSITIVEN);
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_DOT returns the dot (scalar) product of two vectors X and Y.
  --
  -- Arguments   
  -- =========   
  --
  -- N      - INTEGER.   
  --          On entry, N specifies the number of elements of the vectors X and Y.   
  --          N must be at least zero.   
  --          Unchanged on exit. 
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) )
  --          Unchanged on exit.    
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.     
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) )
  --          Unchanged on exit.    
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.    
  
  FUNCTION blas_dot(n    IN     POSITIVEN,
                    x    IN     utl_nla_array_dbl,
                    incx IN     POSITIVEN,
                    y    IN     utl_nla_array_dbl,
                    incy IN     POSITIVEN) RETURN BINARY_DOUBLE;
  
  FUNCTION blas_dot(n    IN     POSITIVEN,
                    x    IN     UTL_NLA_ARRAY_FLT,
                    incx IN     POSITIVEN,
                    y    IN     UTL_NLA_ARRAY_FLT,
                    incy IN     POSITIVEN) RETURN BINARY_FLOAT;
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_NRM2 computes the vector 2-norm (Euclidean norm)
  --
  -- Arguments   
  -- =========   
  --
  -- N      - INTEGER.   
  --          On entry, N specifies the number of elements of the vectors X and Y.   
  --          N must be at least zero.   
  --          Unchanged on exit. 
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) )
  --          Unchanged on exit.
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.
  
  FUNCTION blas_nrm2(n    IN     POSITIVEN,
                     x    IN     utl_nla_array_dbl,
                     incx IN     POSITIVEN) RETURN BINARY_DOUBLE;
  
  FUNCTION blas_nrm2(n    IN     POSITIVEN,
                     x    IN     UTL_NLA_ARRAY_FLT,
                     incx IN     POSITIVEN) RETURN BINARY_FLOAT;
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_ASUM computes the sum of the absolute values of the vector components
  --
  -- Arguments   
  -- =========   
  --
  -- N      - INTEGER.   
  --          On entry, N specifies the number of elements of the vectors X and Y.   
  --          N must be at least zero.   
  --          Unchanged on exit. 
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) )
  --          Unchanged on exit.
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.
  
  FUNCTION blas_asum(n    IN     POSITIVEN,
                     x    IN     utl_nla_array_dbl, 
                     incx IN     POSITIVEN) RETURN BINARY_DOUBLE;
  
  FUNCTION blas_asum(n    IN     POSITIVEN,
                     x    IN     UTL_NLA_ARRAY_FLT,
                     incx IN     POSITIVEN)  RETURN BINARY_FLOAT;
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_IAMAX computes the index of first element of a vector that has the
  -- largest absolute value.
  --
  -- Arguments   
  -- =========   
  --
  -- N      - INTEGER.   
  --          On entry, N specifies the number of elements of the vectors X and Y.   
  --          N must be at least zero.   
  --          Unchanged on exit. 
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) )
  --          Unchanged on exit.
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.

  FUNCTION blas_iamax(n    IN     POSITIVEN,
                      x    IN     utl_nla_array_dbl,
                      incx IN     POSITIVEN) RETURN POSITIVEN;

  FUNCTION blas_iamax(n    IN     POSITIVEN,
                      x    IN     UTL_NLA_ARRAY_FLT,
                      incx IN     POSITIVEN)  RETURN POSITIVEN;

  -- Purpose   
  -- =======   
  --
  -- BLAS_ROT returns the Plane rotation of points
  --
  -- Arguments   
  -- =========   
  --
  -- N      - INTEGER.   
  --          On entry, N specifies the number of elements of the vectors X and Y.   
  --          N must be at least zero.   
  --          Unchanged on exit. 
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) )
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.     
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) )
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.   
  -- C      - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, C specifies the scalar C.   
  --          Unchanged on exit.     
  -- S      - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, S specifies the scalar S.   
  --          Unchanged on exit.     

  PROCEDURE blas_rot(n    IN     POSITIVEN,
                     x    IN OUT utl_nla_array_dbl,
                     incx IN     POSITIVEN,
                     y    IN OUT utl_nla_array_dbl,
                     incy IN     POSITIVEN,
                     c    IN     scalar_double,
                     s    IN     scalar_double);
  
  PROCEDURE blas_rot(n    IN     POSITIVEN,
                     x    IN OUT UTL_NLA_ARRAY_FLT,
                     incx IN     POSITIVEN,
                     y    IN OUT UTL_NLA_ARRAY_FLT,
                     incy IN     POSITIVEN,
                     c    IN     scalar_float,
                     s    IN     scalar_float);
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_ROTG returns the Givens rotation of points
  --
  -- Arguments   
  -- =========   
  --
  -- A      - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, A specifies the scalar A.   
  -- B      - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, B specifies the scalar B.   
  -- C      - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, C specifies the scalar C.   
  -- S      - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, S specifies the scalar S.   
  
  PROCEDURE blas_rotg(a IN OUT scalar_double,
                      b IN OUT scalar_double,
                      c IN OUT scalar_double,
                      s IN OUT scalar_double);
  
  PROCEDURE blas_rotg(a IN OUT scalar_float,
                      b IN OUT scalar_float,
                      c IN OUT scalar_float,
                      s IN OUT scalar_float);
  
  -- --------------------------------------- --
  -- BLAS Level 2 (Vector-Matrix Operations)
  -- --------------------------------------- --
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_GEMV  performs one of the matrix-vector operations   
  --    y := alpha*A*x + beta*y,   or   y := alpha*A'*x + beta*y,   
  -- where alpha and beta are scalars, x and y are vectors and A is an   
  -- m by n matrix.   
  --
  -- Arguments   
  -- =========   
  --
  -- TRANS  - FLAG.   
  --          On entry, TRANS specifies the operation to be performed as   
  --          follows:   
  --             TRANS = 'N' or 'n'   y := alpha*A*x + beta*y.   
  --             TRANS = 'T' or 't'   y := alpha*A'*x + beta*y.   
  --             TRANS = 'C' or 'c'   y := alpha*A'*x + beta*y.   
  --          Unchanged on exit.   
  -- M      - INTEGER.   
  --          On entry, M specifies the number of rows of the matrix A.   
  --          M must be at least zero.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the number of columns of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry, the leading m by n part of the array A must   
  --          contain the matrix of coefficients.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          max( 1, m ).   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ) when TRANS = 'N' or 'n'   
  --          and at least   
  --          ( 1 + ( m - 1 )*abs( INCX ) ) otherwise.   
  --          Before entry, the incremented array X must contain the   
  --          vector x.   
  --          Unchanged on exit.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- BETA   - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, BETA specifies the scalar beta. When BETA is   
  --          supplied as zero then Y need not be set on input.   
  --          Unchanged on exit.   
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( m - 1 )*abs( INCY ) ) when TRANS = 'N' or 'n'   
  --          and at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) ) otherwise.   
  --          Before entry with BETA non-zero, the incremented array Y   
  --          must contain the vector y. On exit, Y is overwritten by the   
  --          updated vector y.   
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit. 
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE blas_gemv(trans IN     flag,
                      m     IN     POSITIVEN,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_double, 
                      a     IN     utl_nla_array_dbl,
                      lda   IN     POSITIVEN,
                      x     IN     utl_nla_array_dbl,
                      incx  IN     POSITIVEN,
                      beta  IN     scalar_double,
                      y     IN OUT utl_nla_array_dbl,
                      incy  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');  
  
  PROCEDURE blas_gemv(trans IN     flag,
                      m     IN     POSITIVEN,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_float, 
                      a     IN     UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      x     IN     UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      beta  IN     scalar_float,
                      y     IN OUT UTL_NLA_ARRAY_FLT,
                      incy  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');  
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_GBMV  performs one of the matrix-vector operations   
  --    y := alpha*A*x + beta*y,   or   y := alpha*A'*x + beta*y,   
  -- where alpha and beta are scalars, x and y are vectors and A is an   
  -- m by n band matrix, with kl sub-diagonals and ku super-diagonals.   
  --
  -- Arguments
  -- =========   
  --
  -- TRANS  - FLAG.   
  --          On entry, TRANS specifies the operation to be performed as   
  --          follows:   
  --             TRANS = 'N' or 'n'   y := alpha*A*x + beta*y.   
  --             TRANS = 'T' or 't'   y := alpha*A'*x + beta*y.   
  --             TRANS = 'C' or 'c'   y := alpha*A'*x + beta*y.   
  --          Unchanged on exit.   
  -- M      - INTEGER.   
  --          On entry, M specifies the number of rows of the matrix A.   
  --          M must be at least zero.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the number of columns of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- KL     - INTEGER.   
  --          On entry, KL specifies the number of sub-diagonals of the   
  --          matrix A. KL must satisfy  0 .le. KL.   
  --          Unchanged on exit.   
  -- KU     - INTEGER.   
  --          On entry, KU specifies the number of super-diagonals of the   
  --          matrix A. KU must satisfy  0 .le. KU.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry, the leading ( kl + ku + 1 ) by n part of the   
  --          array A must contain the matrix of coefficients, supplied   
  --          column by column, with the leading diagonal of the matrix in   
  --          row ( ku + 1 ) of the array, the first super-diagonal   
  --          starting at position 2 in row ku, the first sub-diagonal   
  --          starting at position 1 in row ( ku + 2 ), and so on.   
  --          Elements in the array A that do not correspond to elements   
  --          in the band matrix (such as the top left ku by ku triangle)   
  --          are not referenced.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          ( kl + ku + 1 ).   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ) when TRANS = 'N' or 'n'   
  --          and at least   
  --          ( 1 + ( m - 1 )*abs( INCX ) ) otherwise.   
  --          Before entry, the incremented array X must contain the   
  --          vector x.   
  --          Unchanged on exit.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- BETA   - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, BETA specifies the scalar beta. When BETA is   
  --          supplied as zero then Y need not be set on input.   
  --          Unchanged on exit.   
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( m - 1 )*abs( INCY ) ) when TRANS = 'N' or 'n'   
  --          and at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) ) otherwise.   
  --          Before entry, the incremented array Y must contain the   
  --          vector y. On exit, Y is overwritten by the updated vector y.   
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.   
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_gbmv(trans IN     flag,
                      m     IN     POSITIVEN,
                      n     IN     POSITIVEN,
                      kl    IN     NATURALN,
                      ku    IN     NATURALN,
                      alpha IN     scalar_double,
                      a     IN     utl_nla_array_dbl,
                      lda   IN     POSITIVEN,
                      x     IN     utl_nla_array_dbl,
                      incx  IN     POSITIVEN, 
                      beta  IN     scalar_double,
                      y     IN OUT utl_nla_array_dbl,
                      incy  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');  
  
  PROCEDURE blas_gbmv(trans IN     flag,
                      m     IN     POSITIVEN,
                      n     IN     POSITIVEN,
                      kl    IN     NATURALN,
                      ku    IN     NATURALN,
                      alpha IN     scalar_float,
                      a     IN     UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      x     IN     UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN, 
                      beta  IN     scalar_float,
                      y     IN OUT UTL_NLA_ARRAY_FLT,
                      incy  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');  
    
  -- Purpose   
  -- =======   
  --
  -- BLAS_SYMV  performs the matrix-vector  operation   
  --    y := alpha*A*x + beta*y,   
  -- where alpha and beta are scalars, x and y are n element vectors and   
  -- A is an n by n symmetric matrix.   
  --
  -- Arguments
  -- =========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the upper or lower   
  --          triangular part of the array A is to be referenced as   
  --          follows:   
  --             UPLO = 'U' or 'u'   Only the upper triangular part of A   
  --                                 is to be referenced.   
  --             UPLO = 'L' or 'l'   Only the lower triangular part of A   
  --                                 is to be referenced.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry with  UPLO = 'U' or 'u', the leading n by n   
  --          upper triangular part of the array A must contain the upper   
  --          triangular part of the symmetric matrix and the strictly   
  --          lower triangular part of A is not referenced.   
  --          Before entry with UPLO = 'L' or 'l', the leading n by n   
  --          lower triangular part of the array A must contain the lower   
  --          triangular part of the symmetric matrix and the strictly   
  --          upper triangular part of A is not referenced.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          max( 1, n ).   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element vector x.   
  --          Unchanged on exit.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- BETA   - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, BETA specifies the scalar beta. When BETA is   
  --          supplied as zero then Y need not be set on input.   
  --          Unchanged on exit.   
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) ).   
  --          Before entry, the incremented array Y must contain the n   
  --          element vector y. On exit, Y is overwritten by the updated   
  --          vector y.   
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.   
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE blas_symv(uplo  IN     flag,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_double,
                      a     IN     utl_nla_array_dbl,
                      lda   IN     POSITIVEN,
                      x     IN     utl_nla_array_dbl,
                      incx  IN     POSITIVEN,
                      beta  IN     scalar_double,
                      y     IN OUT utl_nla_array_dbl,
                      incy  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');      
  
  PROCEDURE blas_symv(uplo  IN     flag,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_float,
                      a     IN     UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      x     IN     UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      beta  IN     scalar_float,
                      y     IN OUT UTL_NLA_ARRAY_FLT,
                      incy  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');  
    
  -- Purpose   
  -- =======   
  --
  -- SSBMV  performs the matrix-vector  operation   
  --    y := alpha*A*x + beta*y,   
  -- where alpha and beta are scalars, x and y are n element vectors and   
  -- A is an n by n symmetric band matrix, with k super-diagonals.   
  --
  -- Parameters   
  -- ==========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the upper or lower   
  --          triangular part of the band matrix A is being supplied as   
  --          follows:   
  --             UPLO = 'U' or 'u'   The upper triangular part of A is   
  --                                 being supplied.   
  --             UPLO = 'L' or 'l'   The lower triangular part of A is   
  --                                 being supplied.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- K      - INTEGER.   
  --          On entry, K specifies the number of super-diagonals of the   
  --          matrix A. K must satisfy  0 .le. K.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry with UPLO = 'U' or 'u', the leading ( k + 1 )   
  --          by n part of the array A must contain the upper triangular   
  --          band part of the symmetric matrix, supplied column by   
  --          column, with the leading diagonal of the matrix in row   
  --          ( k + 1 ) of the array, the first super-diagonal starting at   
  --          position 2 in row k, and so on. The top left k by k triangle   
  --          of the array A is not referenced.   
  --          Before entry with UPLO = 'L' or 'l', the leading ( k + 1 )   
  --          by n part of the array A must contain the lower triangular   
  --          band part of the symmetric matrix, supplied column by   
  --          column, with the leading diagonal of the matrix in row 1 of   
  --          the array, the first sub-diagonal starting at position 1 in   
  --          row 2, and so on. The bottom right k by k triangle of the   
  --          array A is not referenced.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          ( k + 1 ).   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the   
  --          vector x.   
  --          Unchanged on exit.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- BETA   - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, BETA specifies the scalar beta.   
  --          Unchanged on exit.   
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) ).   
  --          Before entry, the incremented array Y must contain the   
  --          vector y. On exit, Y is overwritten by the updated vector y.   
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.   
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_sbmv(uplo  IN     flag,
                      n     IN     POSITIVEN,
                      k     IN     NATURALN, 
                      alpha IN     scalar_double, 
                      a     IN     utl_nla_array_dbl, 
                      lda   IN     POSITIVEN, 
                      x     IN     utl_nla_array_dbl,
                      incx  IN     POSITIVEN, 
                      beta  IN     scalar_double,
                      y     IN OUT utl_nla_array_dbl,
                      incy  IN     POSITIVEN, 
                      pack  IN     flag DEFAULT 'C');      
  
  PROCEDURE blas_sbmv(uplo  IN     flag,
                      n     IN     POSITIVEN,
                      k     IN     NATURALN,
                      alpha IN     scalar_float, 
                      a     IN     UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      x     IN     UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      beta  IN     scalar_float,
                      y     IN OUT UTL_NLA_ARRAY_FLT,
                      incy  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');  
    
  -- Purpose   
  -- =======
  --   
  -- BLAS_SPMV  performs the matrix-vector operation   
  --    y := alpha*A*x + beta*y,   
  -- where alpha and beta are scalars, x and y are n element vectors and   
  -- A is an n by n symmetric matrix, supplied in packed form.   
  --   
  -- Parameters   
  -- ==========   
  --   
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the upper or lower   
  --          triangular part of the matrix A is supplied in the packed   
  --          array AP as follows:   
  --             UPLO = 'U' or 'u'   The upper triangular part of A is   
  --                                 supplied in AP.   
  --             UPLO = 'L' or 'l'   The lower triangular part of A is   
  --                                 supplied in AP.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- AP     - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( ( n*( n + 1 ) )/2 ).   
  --          Before entry with UPLO = 'U' or 'u', the array AP must   
  --          contain the upper triangular part of the symmetric matrix   
  --          packed sequentially, column by column, so that AP( 1 )   
  --          contains a( 1, 1 ), AP( 2 ) and AP( 3 ) contain a( 1, 2 )   
  --          and a( 2, 2 ) respectively, and so on.   
  --          Before entry with UPLO = 'L' or 'l', the array AP must   
  --          contain the lower triangular part of the symmetric matrix   
  --          packed sequentially, column by column, so that AP( 1 )   
  --          contains a( 1, 1 ), AP( 2 ) and AP( 3 ) contain a( 2, 1 )   
  --          and a( 3, 1 ) respectively, and so on.   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element vector x.   
  --          Unchanged on exit.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- BETA   - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, BETA specifies the scalar beta. When BETA is   
  --          supplied as zero then Y need not be set on input.   
  --          Unchanged on exit.   
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) ).   
  --          Before entry, the incremented array Y must contain the n   
  --          element vector y. On exit, Y is overwritten by the updated   
  --          vector y.   
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit. 
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_spmv(uplo  IN     flag,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_double,
                      ap    IN     utl_nla_array_dbl,
                      x     IN     utl_nla_array_dbl,
                      incx  IN     POSITIVEN,
                      beta  IN     scalar_double,
                      y     IN OUT utl_nla_array_dbl,
                      incy  IN     POSITIVEN, 
                      pack  IN     flag DEFAULT 'C');      
  
  PROCEDURE blas_spmv(uplo  IN     flag, 
                      n     IN     POSITIVEN,
                      alpha IN     scalar_float,
                      ap    IN     UTL_NLA_ARRAY_FLT,
                      x     IN     UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN, 
                      beta  IN     scalar_float,
                      y     IN OUT UTL_NLA_ARRAY_FLT,
                      incy  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');  
    
  -- Purpose   
  -- =======   
  --
  -- BLAS_TRMV  performs one of the matrix-vector operations   
  --    x := A*x,   or   x := A'*x,   
  -- where x is an n element vector and  A is an n by n unit, or non-unit,   
  -- upper or lower triangular matrix.   
  -- 
  -- Parameters   
  -- ==========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the matrix is an upper or   
  --          lower triangular matrix as follows:   
  --             UPLO = 'U' or 'u'   A is an upper triangular matrix.   
  --             UPLO = 'L' or 'l'   A is a lower triangular matrix.   
  --          Unchanged on exit.   
  -- TRANS  - FLAG.   
  --          On entry, TRANS specifies the operation to be performed as   
  --          follows:   
  --             TRANS = 'N' or 'n'   x := A*x.   
  --             TRANS = 'T' or 't'   x := A'*x.   
  --             TRANS = 'C' or 'c'   x := A'*x.   
  --          Unchanged on exit.   
  -- DIAG   - FLAG.   
  --          On entry, DIAG specifies whether or not A is unit   
  --          triangular as follows:   
  --             DIAG = 'U' or 'u'   A is assumed to be unit triangular.   
  --             DIAG = 'N' or 'n'   A is not assumed to be unit   
  --                                 triangular.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry with  UPLO = 'U' or 'u', the leading n by n   
  --          upper triangular part of the array A must contain the upper   
  --          triangular matrix and the strictly lower triangular part of   
  --          A is not referenced.   
  --          Before entry with UPLO = 'L' or 'l', the leading n by n   
  --          lower triangular part of the array A must contain the lower   
  --          triangular matrix and the strictly upper triangular part of   
  --          A is not referenced.   
  --          Note that when  DIAG = 'U' or 'u', the diagonal elements of   
  --          A are not referenced either, but are assumed to be unity.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          max( 1, n ).   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element vector x. On exit, X is overwritten with the   
  --          tranformed vector x.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_trmv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      a     IN     utl_nla_array_dbl,
                      lda   IN     POSITIVEN,
                      x     IN OUT utl_nla_array_dbl, 
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');      
  
  PROCEDURE blas_trmv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      a     IN     UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      x     IN OUT UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');      
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_TBMV  performs one of the matrix-vector operations   
  --    x := A*x,   or   x := A'*x,   
  -- where x is an n element vector and  A is an n by n unit, or non-unit,   
  -- upper or lower triangular band matrix, with ( k + 1 ) diagonals.   
  --
  -- Arguments   
  -- =========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the matrix is an upper or   
  --          lower triangular matrix as follows:   
  --             UPLO = 'U' or 'u'   A is an upper triangular matrix.   
  --             UPLO = 'L' or 'l'   A is a lower triangular matrix.   
  --          Unchanged on exit.   
  -- TRANS  - FLAG.   
  --          On entry, TRANS specifies the operation to be performed as   
  --          follows:   
  --             TRANS = 'N' or 'n'   x := A*x.   
  --             TRANS = 'T' or 't'   x := A'*x.   
  --             TRANS = 'C' or 'c'   x := A'*x.   
  --          Unchanged on exit.   
  -- DIAG   - FLAG.   
  --          On entry, DIAG specifies whether or not A is unit   
  --          triangular as follows:   
  --             DIAG = 'U' or 'u'   A is assumed to be unit triangular.   
  --             DIAG = 'N' or 'n'   A is not assumed to be unit   
  --                                 triangular.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- K      - INTEGER.   
  --          On entry with UPLO = 'U' or 'u', K specifies the number of   
  --          super-diagonals of the matrix A.   
  --          On entry with UPLO = 'L' or 'l', K specifies the number of   
  --          sub-diagonals of the matrix A.   
  --          K must satisfy  0 .le. K.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry with UPLO = 'U' or 'u', the leading ( k + 1 )   
  --          by n part of the array A must contain the upper triangular   
  --          band part of the matrix of coefficients, supplied column by   
  --          column, with the leading diagonal of the matrix in row   
  --          ( k + 1 ) of the array, the first super-diagonal starting at   
  --          position 2 in row k, and so on. The top left k by k triangle   
  --          of the array A is not referenced.   
  --          Before entry with UPLO = 'L' or 'l', the leading ( k + 1 )   
  --          by n part of the array A must contain the lower triangular   
  --          band part of the matrix of coefficients, supplied column by   
  --          column, with the leading diagonal of the matrix in row 1 of   
  --          the array, the first sub-diagonal starting at position 1 in   
  --          row 2, and so on. The bottom right k by k triangle of the   
  --          array A is not referenced.   
  --          Note that when DIAG = 'U' or 'u' the elements of the array A   
  --          corresponding to the diagonal elements of the matrix are not   
  --          referenced, but are assumed to be unity.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          ( k + 1 ).   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element vector x. On exit, X is overwritten with the   
  --          tranformed vector x.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.  
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE blas_tbmv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      k     IN     NATURALN, 
                      a     IN     utl_nla_array_dbl,
                      lda   IN     POSITIVEN,
                      x     IN OUT utl_nla_array_dbl,
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');
  
  PROCEDURE blas_tbmv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      k     IN     NATURALN,
                      a     IN     UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      x     IN OUT UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_TPMV  performs one of the matrix-vector operations   
  --    x := A*x,   or   x := A'*x,   
  -- where x is an n element vector and  A is an n by n unit, or non-unit,   
  -- upper or lower triangular matrix, supplied in packed form.   
  --
  -- Parameters   
  -- ==========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the matrix is an upper or   
  --          lower triangular matrix as follows:   
  --             UPLO = 'U' or 'u'   A is an upper triangular matrix.   
  --             UPLO = 'L' or 'l'   A is a lower triangular matrix.   
  --          Unchanged on exit.   
  -- TRANS  - FLAG.   
  --          On entry, TRANS specifies the operation to be performed as   
  --          follows:   
  --             TRANS = 'N' or 'n'   x := A*x.   
  --             TRANS = 'T' or 't'   x := A'*x.   
  --             TRANS = 'C' or 'c'   x := A'*x.   
  --          Unchanged on exit.   
  -- DIAG   - FLAG.   
  --          On entry, DIAG specifies whether or not A is unit   
  --          triangular as follows:   
  --             DIAG = 'U' or 'u'   A is assumed to be unit triangular.   
  --             DIAG = 'N' or 'n'   A is not assumed to be unit   
  --                                 triangular.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- AP     - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( ( n*( n + 1 ) )/2 ).   
  --          Before entry with  UPLO = 'U' or 'u', the array AP must   
  --          contain the upper triangular matrix packed sequentially,   
  --          column by column, so that AP( 1 ) contains a( 1, 1 ),   
  --          AP( 2 ) and AP( 3 ) contain a( 1, 2 ) and a( 2, 2 )   
  --          respectively, and so on.   
  --          Before entry with UPLO = 'L' or 'l', the array AP must   
  --          contain the lower triangular matrix packed sequentially,   
  --          column by column, so that AP( 1 ) contains a( 1, 1 ),   
  --          AP( 2 ) and AP( 3 ) contain a( 2, 1 ) and a( 3, 1 )   
  --          respectively, and so on.   
  --          Note that when  DIAG = 'U' or 'u', the diagonal elements of   
  --          A are not referenced, but are assumed to be unity.   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element vector x. On exit, X is overwritten with the   
  --          tranformed vector x.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.  
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_tpmv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      ap    IN     utl_nla_array_dbl,
                      x     IN OUT utl_nla_array_dbl,
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');      
  
  PROCEDURE blas_tpmv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      ap    IN     UTL_NLA_ARRAY_FLT,
                      x     IN OUT UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');      
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_TRSV  solves one of the systems of equations   
  --    A*x = b,   or   A'*x = b,   
  -- where b and x are n element vectors and A is an n by n unit, or   
  -- non-unit, upper or lower triangular matrix.   
  -- No test for singularity or near-singularity is included in this   
  -- routine. Such tests must be performed before calling this routine.   
  --
  -- Arguments   
  -- =========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the matrix is an upper or   
  --          lower triangular matrix as follows:   
  --             UPLO = 'U' or 'u'   A is an upper triangular matrix.   
  --             UPLO = 'L' or 'l'   A is a lower triangular matrix.   
  --          Unchanged on exit.   
  -- TRANS  - FLAG.   
  --          On entry, TRANS specifies the equations to be solved as   
  --          follows:   
  --             TRANS = 'N' or 'n'   A*x = b.   
  --             TRANS = 'T' or 't'   A'*x = b.   
  --             TRANS = 'C' or 'c'   A'*x = b.   
  --          Unchanged on exit.   
  -- DIAG   - FLAG.   
  --          On entry, DIAG specifies whether or not A is unit   
  --          triangular as follows:   
  --             DIAG = 'U' or 'u'   A is assumed to be unit triangular.   
  --             DIAG = 'N' or 'n'   A is not assumed to be unit   
  --                                 triangular.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry with  UPLO = 'U' or 'u', the leading n by n   
  --          upper triangular part of the array A must contain the upper   
  --          triangular matrix and the strictly lower triangular part of   
  --          A is not referenced.   
  --          Before entry with UPLO = 'L' or 'l', the leading n by n   
  --          lower triangular part of the array A must contain the lower   
  --          triangular matrix and the strictly upper triangular part of   
  --          A is not referenced.   
  --          Note that when  DIAG = 'U' or 'u', the diagonal elements of   
  --          A are not referenced either, but are assumed to be unity.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          max( 1, n ).   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element right-hand side vector b. On exit, X is overwritten   
  --          with the solution vector x.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.  
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE blas_trsv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      a     IN     utl_nla_array_dbl,
                      lda   IN     POSITIVEN, 
                      x     IN OUT utl_nla_array_dbl,
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');      
  
  PROCEDURE blas_trsv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      a     IN     UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      x     IN OUT UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');      
  
  -- Purpose   
  -- =======   
  --
  -- STBSV  solves one of the systems of equations   
  --    A*x = b,   or   A'*x = b,   
  -- where b and x are n element vectors and A is an n by n unit, or   
  -- non-unit, upper or lower triangular band matrix, with ( k + 1 )   
  -- diagonals.   
  -- No test for singularity or near-singularity is included in this   
  -- routine. Such tests must be performed before calling this routine.   
  --
  -- Parameters   
  -- ==========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the matrix is an upper or   
  --          lower triangular matrix as follows:   
  --             UPLO = 'U' or 'u'   A is an upper triangular matrix.   
  --             UPLO = 'L' or 'l'   A is a lower triangular matrix.   
  --          Unchanged on exit.   
  -- TRANS  - FLAG.   
  --          On entry, TRANS specifies the equations to be solved as   
  --          follows:   
  --             TRANS = 'N' or 'n'   A*x = b.   
  --             TRANS = 'T' or 't'   A'*x = b.   
  --             TRANS = 'C' or 'c'   A'*x = b.   
  --          Unchanged on exit.   
  -- DIAG   - FLAG.   
  --          On entry, DIAG specifies whether or not A is unit   
  --          triangular as follows:   
  --             DIAG = 'U' or 'u'   A is assumed to be unit triangular.   
  --             DIAG = 'N' or 'n'   A is not assumed to be unit   
  --                                 triangular.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- K      - INTEGER.   
  --          On entry with UPLO = 'U' or 'u', K specifies the number of   
  --          super-diagonals of the matrix A.   
  --          On entry with UPLO = 'L' or 'l', K specifies the number of   
  --          sub-diagonals of the matrix A.   
  --          K must satisfy  0 .le. K.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry with UPLO = 'U' or 'u', the leading ( k + 1 )   
  --          by n part of the array A must contain the upper triangular   
  --          band part of the matrix of coefficients, supplied column by   
  --          column, with the leading diagonal of the matrix in row   
  --          ( k + 1 ) of the array, the first super-diagonal starting at   
  --          position 2 in row k, and so on. The top left k by k triangle   
  --          of the array A is not referenced.   
  --          Before entry with UPLO = 'L' or 'l', the leading ( k + 1 )   
  --          by n part of the array A must contain the lower triangular   
  --          band part of the matrix of coefficients, supplied column by   
  --          column, with the leading diagonal of the matrix in row 1 of   
  --          the array, the first sub-diagonal starting at position 1 in   
  --          row 2, and so on. The bottom right k by k triangle of the   
  --          array A is not referenced.   
  --          Note that when DIAG = 'U' or 'u' the elements of the array A   
  --          corresponding to the diagonal elements of the matrix are not   
  --          referenced, but are assumed to be unity.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          ( k + 1 ).   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element right-hand side vector b. On exit, X is overwritten   
  --          with the solution vector x.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE blas_tbsv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      k     IN     NATURALN,
                      a     IN     utl_nla_array_dbl,
                      lda   IN     POSITIVEN,
                      x     IN OUT utl_nla_array_dbl,
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');
  
  PROCEDURE blas_tbsv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      k     IN     NATURALN, 
                      a     IN     UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      x     IN OUT UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_TPSV  solves one of the systems of equations   
  --    A*x = b,   or   A'*x = b,   
  -- where b and x are n element vectors and A is an n by n unit, or   
  -- non-unit, upper or lower triangular matrix, supplied in packed form.   
  -- No test for singularity or near-singularity is included in this   
  -- routine. Such tests must be performed before calling this routine.   
  --
  -- Arguments   
  -- =========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the matrix is an upper or   
  --          lower triangular matrix as follows:   
  --             UPLO = 'U' or 'u'   A is an upper triangular matrix.   
  --             UPLO = 'L' or 'l'   A is a lower triangular matrix.   
  --          Unchanged on exit.   
  -- TRANS  - FLAG.   
  --          On entry, TRANS specifies the equations to be solved as   
  --          follows:   
  --             TRANS = 'N' or 'n'   A*x = b.   
  --             TRANS = 'T' or 't'   A'*x = b.   
  --             TRANS = 'C' or 'c'   A'*x = b.   
  --          Unchanged on exit.   
  -- DIAG   - FLAG.   
  --          On entry, DIAG specifies whether or not A is unit   
  --          triangular as follows:   
  --             DIAG = 'U' or 'u'   A is assumed to be unit triangular.   
  --             DIAG = 'N' or 'n'   A is not assumed to be unit   
  --                                 triangular.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- AP     - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( ( n*( n + 1 ) )/2 ).   
  --          Before entry with  UPLO = 'U' or 'u', the array AP must   
  --          contain the upper triangular matrix packed sequentially,   
  --          column by column, so that AP( 1 ) contains a( 1, 1 ),   
  --          AP( 2 ) and AP( 3 ) contain a( 1, 2 ) and a( 2, 2 )   
  --          respectively, and so on.   
  --          Before entry with UPLO = 'L' or 'l', the array AP must   
  --          contain the lower triangular matrix packed sequentially,   
  --          column by column, so that AP( 1 ) contains a( 1, 1 ),   
  --          AP( 2 ) and AP( 3 ) contain a( 2, 1 ) and a( 3, 1 )   
  --          respectively, and so on.   
  --          Note that when  DIAG = 'U' or 'u', the diagonal elements of   
  --          A are not referenced, but are assumed to be unity.   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element right-hand side vector b. On exit, X is overwritten   
  --          with the solution vector x.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_tpsv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag,
                      n     IN     POSITIVEN,
                      ap    IN     utl_nla_array_dbl,
                      x     IN OUT utl_nla_array_dbl, 
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');
  
  PROCEDURE blas_tpsv(uplo  IN     flag,
                      trans IN     flag,
                      diag  IN     flag, 
                      n     IN     POSITIVEN,
                      ap    IN     UTL_NLA_ARRAY_FLT,
                      x     IN OUT UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_GER   performs the rank 1 operation   
  --    A := alpha*x*y' + A,   
  -- where alpha is a scalar, x is an m element vector, y is an n element   
  -- vector and A is an m by n matrix.   
  --
  -- Arguments
  -- =========   
  --
  -- M      - INTEGER.   
  --          On entry, M specifies the number of rows of the matrix A.   
  --          M must be at least zero.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the number of columns of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( m - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the m   
  --          element vector x.   
  --          Unchanged on exit.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) ).   
  --          Before entry, the incremented array Y must contain the n   
  --          element vector y.   
  --          Unchanged on exit.   
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry, the leading m by n part of the array A must   
  --          contain the matrix of coefficients. On exit, A is   
  --          overwritten by the updated matrix.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          max( 1, m ).   
  --          Unchanged on exit.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_ger(m     IN     POSITIVEN,
                     n     IN     POSITIVEN,
                     alpha IN     scalar_double,
                     x     IN     utl_nla_array_dbl,
                     incx  IN     POSITIVEN,
                     y     IN     utl_nla_array_dbl,
                     a     IN OUT utl_nla_array_dbl,
                     lda   IN     POSITIVEN,
                     pack  IN     flag DEFAULT 'C');
  
  PROCEDURE blas_ger(m     IN     POSITIVEN,
                     n     IN     POSITIVEN,
                     alpha IN     scalar_float,
                     x     IN     UTL_NLA_ARRAY_FLT, 
                     incx  IN     POSITIVEN,
                     y     IN     UTL_NLA_ARRAY_FLT,
                     a     IN OUT UTL_NLA_ARRAY_FLT,
                     lda   IN     POSITIVEN,
                     pack  IN     flag DEFAULT 'C');
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_SYR   performs the symmetric rank 1 operation   
  --    A := alpha*x*x' + A,   
  -- where alpha is a real scalar, x is an n element vector and A is an   
  -- n by n symmetric matrix.   
  --
  -- Arguments   
  -- =========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the upper or lower   
  --          triangular part of the array A is to be referenced as   
  --          follows:   
  --             UPLO = 'U' or 'u'   Only the upper triangular part of A   
  --                                 is to be referenced.   
  --             UPLO = 'L' or 'l'   Only the lower triangular part of A   
  --                                 is to be referenced.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element vector x.   
  --          Unchanged on exit.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry with  UPLO = 'U' or 'u', the leading n by n   
  --          upper triangular part of the array A must contain the upper   
  --          triangular part of the symmetric matrix and the strictly   
  --          lower triangular part of A is not referenced. On exit, the   
  --          upper triangular part of the array A is overwritten by the   
  --          upper triangular part of the updated matrix.   
  --          Before entry with UPLO = 'L' or 'l', the leading n by n   
  --          lower triangular part of the array A must contain the lower   
  --          triangular part of the symmetric matrix and the strictly   
  --          upper triangular part of A is not referenced. On exit, the   
  --          lower triangular part of the array A is overwritten by the   
  --          lower triangular part of the updated matrix.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          max( 1, n ).   
  --          Unchanged on exit.  
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE blas_syr(uplo  IN     flag,
                     n     IN     POSITIVEN,
                     alpha IN     scalar_double,
                     x     IN     utl_nla_array_dbl,
                     incx  IN     POSITIVEN,
                     a     IN OUT utl_nla_array_dbl,
                     lda   IN     POSITIVEN,
                     pack  IN     flag DEFAULT 'C');
  
  PROCEDURE blas_syr(uplo  IN     flag,
                     n     IN     POSITIVEN,
                     alpha IN     scalar_float,
                     x     IN     UTL_NLA_ARRAY_FLT, 
                     incx  IN     POSITIVEN,
                     a     IN OUT UTL_NLA_ARRAY_FLT,
                     lda   IN     POSITIVEN,
                     pack  IN     flag DEFAULT 'C');

  -- Purpose   
  -- =======   
  --
  -- BLAS_SPR  performs the symmetric rank 1 operation   
  --    A := alpha*x*x' + A,   
  -- where alpha is a real scalar, x is an n element vector and A is an   
  -- n by n symmetric matrix, supplied in packed form.   
  --
  -- Parameters   
  -- ==========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the upper or lower   
  --          triangular part of the matrix A is supplied in the packed   
  --          array AP as follows:   
  --             UPLO = 'U' or 'u'   The upper triangular part of A is   
  --                                 supplied in AP.   
  --             UPLO = 'L' or 'l'   The lower triangular part of A is   
  --                                 supplied in AP.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element vector x.   
  --          Unchanged on exit.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- AP     - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( ( n*( n + 1 ) )/2 ).   
  --          Before entry with  UPLO = 'U' or 'u', the array AP must   
  --          contain the upper triangular part of the symmetric matrix   
  --          packed sequentially, column by column, so that AP( 1 )   
  --          contains a( 1, 1 ), AP( 2 ) and AP( 3 ) contain a( 1, 2 )   
  --          and a( 2, 2 ) respectively, and so on. On exit, the array   
  --          AP is overwritten by the upper triangular part of the   
  --          updated matrix.   
  --          Before entry with UPLO = 'L' or 'l', the array AP must   
  --          contain the lower triangular part of the symmetric matrix   
  --          packed sequentially, column by column, so that AP( 1 )   
  --          contains a( 1, 1 ), AP( 2 ) and AP( 3 ) contain a( 2, 1 )   
  --          and a( 3, 1 ) respectively, and so on. On exit, the array   
  --          AP is overwritten by the lower triangular part of the   
  --          updated matrix. 
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE blas_spr(uplo  IN     flag,
                     n     IN     POSITIVEN,
                     alpha IN     scalar_double,
                     x     IN     utl_nla_array_dbl,
                     incx  IN     POSITIVEN,
                     ap    IN OUT utl_nla_array_dbl,
                     pack  IN     flag DEFAULT 'C');
  
  PROCEDURE blas_spr(uplo  IN     flag,
                     n     IN     POSITIVEN,
                     alpha IN     scalar_float,
                     x     IN     UTL_NLA_ARRAY_FLT, 
                     incx  IN     POSITIVEN,
                     ap    IN OUT UTL_NLA_ARRAY_FLT,
                     pack  IN     flag DEFAULT 'C');

  -- Purpose   
  -- =======   
  --
  -- BLAS_SYR2  performs the symmetric rank 2 operation   
  --    A := alpha*x*y' + alpha*y*x' + A,   
  -- where alpha is a scalar, x and y are n element vectors and A is an n   
  -- by n symmetric matrix.   
  --
  -- Arguments   
  -- =========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the upper or lower   
  --          triangular part of the array A is to be referenced as   
  --          follows:   
  --             UPLO = 'U' or 'u'   Only the upper triangular part of A   
  --                                 is to be referenced.   
  --             UPLO = 'L' or 'l'   Only the lower triangular part of A   
  --                                 is to be referenced.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element vector x.   
  --          Unchanged on exit.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) ).   
  --          Before entry, the incremented array Y must contain the n   
  --          element vector y.   
  --          Unchanged on exit.   
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, n ).   
  --          Before entry with  UPLO = 'U' or 'u', the leading n by n   
  --          upper triangular part of the array A must contain the upper   
  --          triangular part of the symmetric matrix and the strictly   
  --          lower triangular part of A is not referenced. On exit, the   
  --          upper triangular part of the array A is overwritten by the   
  --          upper triangular part of the updated matrix.   
  --          Before entry with UPLO = 'L' or 'l', the leading n by n   
  --          lower triangular part of the array A must contain the lower   
  --          triangular part of the symmetric matrix and the strictly   
  --          upper triangular part of A is not referenced. On exit, the   
  --          lower triangular part of the array A is overwritten by the   
  --          lower triangular part of the updated matrix.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. LDA must be at least   
  --          max( 1, n ).   
  --          Unchanged on exit.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE blas_syr2(uplo  IN     flag,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_double,
                      x     IN     utl_nla_array_dbl,
                      incx  IN     POSITIVEN,
                      y     IN     utl_nla_array_dbl,
                      incy  IN     POSITIVEN,
                      a     IN OUT utl_nla_array_dbl,
                      lda   IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');
  
  PROCEDURE blas_syr2(uplo  IN     flag,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_float,
                      x     IN     UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      y     IN     UTL_NLA_ARRAY_FLT,
                      incy  IN     POSITIVEN,
                      a     IN OUT UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');

  -- Purpose   
  -- =======   
  --
  -- BLAS_SPR2  performs the symmetric rank 2 operation   
  --    A := alpha*x*y' + alpha*y*x' + A,   
  -- where alpha is a scalar, x and y are n element vectors and A is an   
  -- n by n symmetric matrix, supplied in packed form.   
  --
  -- Arguments   
  -- =========   
  --
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the upper or lower   
  --          triangular part of the matrix A is supplied in the packed   
  --          array AP as follows:   
  --             UPLO = 'U' or 'u'   The upper triangular part of A is   
  --                                 supplied in AP.   
  --             UPLO = 'L' or 'l'   The lower triangular part of A is   
  --                                 supplied in AP.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the order of the matrix A.   
  --          N must be at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- X      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCX ) ).   
  --          Before entry, the incremented array X must contain the n   
  --          element vector x.   
  --          Unchanged on exit.   
  -- INCX   - INTEGER.   
  --          On entry, INCX specifies the increment for the elements of   
  --          X. INCX must not be zero.   
  --          Unchanged on exit.   
  -- Y      - UTL_NLA_ARRAY_FLT/DBL of dimension at least   
  --          ( 1 + ( n - 1 )*abs( INCY ) ).   
  --          Before entry, the incremented array Y must contain the n   
  --          element vector y.   
  --          Unchanged on exit.   
  -- INCY   - INTEGER.   
  --          On entry, INCY specifies the increment for the elements of   
  --          Y. INCY must not be zero.   
  --          Unchanged on exit.   
  -- AP     - UTL_NLA_ARRAY_FLT/DBL of DIMENSION at least   
  --          ( ( n*( n + 1 ) )/2 ).   
  --          Before entry with  UPLO = 'U' or 'u', the array AP must   
  --          contain the upper triangular part of the symmetric matrix   
  --          packed sequentially, column by column, so that AP( 1 )   
  --          contains a( 1, 1 ), AP( 2 ) and AP( 3 ) contain a( 1, 2 )   
  --          and a( 2, 2 ) respectively, and so on. On exit, the array   
  --          AP is overwritten by the upper triangular part of the   
  --          updated matrix.   
  --          Before entry with UPLO = 'L' or 'l', the array AP must   
  --          contain the lower triangular part of the symmetric matrix   
  --          packed sequentially, column by column, so that AP( 1 )   
  --          contains a( 1, 1 ), AP( 2 ) and AP( 3 ) contain a( 2, 1 )   
  --          and a( 3, 1 ) respectively, and so on. On exit, the array   
  --          AP is overwritten by the lower triangular part of the   
  --          updated matrix.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE blas_spr2(uplo  IN     flag,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_double,
                      x     IN     utl_nla_array_dbl,
                      incx  IN     POSITIVEN,
                      y     IN     utl_nla_array_dbl,
                      incy  IN     POSITIVEN,
                      ap    IN OUT utl_nla_array_dbl,
                      pack  IN     flag DEFAULT 'C');
  
  PROCEDURE blas_spr2(uplo  IN     flag,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_float,
                      x     IN     UTL_NLA_ARRAY_FLT,
                      incx  IN     POSITIVEN,
                      y     IN     UTL_NLA_ARRAY_FLT,
                      incy  IN     POSITIVEN,
                      ap    IN OUT UTL_NLA_ARRAY_FLT,
                      pack  IN     flag DEFAULT 'C');


  -- ---------------------------------------- --
  -- BLAS Level 3 (Matrix-Matrix Operations)  --
  -- ---------------------------------------- --
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_GEMM  performs one of the matrix-matrix operations   
  --    C := alpha*op( A )*op( B ) + beta*C,   
  -- where  op( X ) is one of   
  --    op( X ) = X   or   op( X ) = X',   
  -- alpha and beta are scalars, and A, B and C are matrices, with op( A )   
  -- an m by k matrix,  op( B )  a  k by n matrix and  C an m by n matrix.   
  --
  -- Arguments   
  -- =========   
  --
  -- TRANSA - FLAG.   
  --          On entry, TRANSA specifies the form of op( A ) to be used in   
  --          the matrix multiplication as follows:   
  --             TRANSA = 'N' or 'n',  op( A ) = A.   
  --             TRANSA = 'T' or 't',  op( A ) = A'.   
  --             TRANSA = 'C' or 'c',  op( A ) = A'.   
  --          Unchanged on exit.   
  -- TRANSB - FLAG.   
  --          On entry, TRANSB specifies the form of op( B ) to be used in   
  --          the matrix multiplication as follows:   
  --             TRANSB = 'N' or 'n',  op( B ) = B.   
  --             TRANSB = 'T' or 't',  op( B ) = B'.   
  --             TRANSB = 'C' or 'c',  op( B ) = B'.   
  --          Unchanged on exit.   
  -- M      - INTEGER.   
  --          On entry,  M  specifies  the number  of rows  of the  matrix   
  --          op( A )  and of the  matrix  C.  M  must  be at least  zero.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry,  N  specifies the number  of columns of the matrix   
  --          op( B ) and the number of columns of the matrix C. N must be   
  --          at least zero.   
  --          Unchanged on exit.   
  -- K      - INTEGER.   
  --          On entry,  K  specifies  the number of columns of the matrix   
  --          op( A ) and the number of rows of the matrix op( B ). K must   
  --          be at least  zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, ka ), where ka is   
  --          k  when  TRANSA = 'N' or 'n',  and is  m  otherwise.   
  --          Before entry with  TRANSA = 'N' or 'n',  the leading  m by k   
  --          part of the array  A  must contain the matrix  A,  otherwise   
  --          the leading  k by m  part of the array  A  must contain  the   
  --          matrix A.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program. When  TRANSA = 'N' or 'n' then   
  --          LDA must be at least  max( 1, m ), otherwise  LDA must be at   
  --          least  max( 1, k ).   
  --          Unchanged on exit.   
  -- B      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDB, kb ), where kb is   
  --          n  when  TRANSB = 'N' or 'n',  and is  k  otherwise.   
  --          Before entry with  TRANSB = 'N' or 'n',  the leading  k by n   
  --          part of the array  B  must contain the matrix  B,  otherwise   
  --          the leading  n by k  part of the array  B  must contain  the   
  --          matrix B.   
  --          Unchanged on exit.   
  -- LDB    - INTEGER.   
  --          On entry, LDB specifies the first dimension of B as declared   
  --          in the calling (sub) program. When  TRANSB = 'N' or 'n' then   
  --          LDB must be at least  max( 1, k ), otherwise  LDB must be at   
  --          least  max( 1, n ).   
  --          Unchanged on exit.   
  -- BETA   - SCALAR_FLOAT/DOUBLE            .   
  --          On entry,  BETA  specifies the scalar  beta.  When  BETA  is   
  --          supplied as zero then C need not be set on input.   
  --          Unchanged on exit.   
  -- C      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDC, n ).   
  --          Before entry, the leading  m by n  part of the array  C must   
  --          contain the matrix  C,  except when  beta  is zero, in which   
  --          case C need not be set on entry.   
  --          On exit, the array  C  is overwritten by the  m by n  matrix   
  --          ( alpha*op( A )*op( B ) + beta*C ).   
  -- LDC    - INTEGER.   
  --          On entry, LDC specifies the first dimension of C as declared   
  --          in  the  calling  (sub)  program.   LDC  must  be  at  least   
  --          max( 1, m ).
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_gemm(transa IN     flag,
                      transb IN     flag,
                      m      IN     POSITIVEN,
                      n      IN     POSITIVEN,
                      k      IN     POSITIVEN,
                      alpha  IN     scalar_double,
                      a      IN     utl_nla_array_dbl,
                      lda    IN     POSITIVEN,
                      b      IN     utl_nla_array_dbl,
                      ldb    IN     POSITIVEN,
                      beta   IN     scalar_double,
                      c      IN OUT utl_nla_array_dbl,
                      ldc    IN     POSITIVEN,
                      pack   IN     flag DEFAULT 'C');  
  
  PROCEDURE blas_gemm(transa IN     flag,
                      transb IN     flag,
                      m      IN     POSITIVEN,
                      n      IN     POSITIVEN,
                      k      IN     POSITIVEN,
                      alpha  IN     scalar_float,
                      a      IN     UTL_NLA_ARRAY_FLT,
                      lda    IN     POSITIVEN,
                      b      IN     UTL_NLA_ARRAY_FLT,
                      ldb    IN     POSITIVEN,
                      beta   IN     scalar_float,
                      c      IN OUT UTL_NLA_ARRAY_FLT,
                      ldc    IN     POSITIVEN,
                      pack   IN     flag DEFAULT 'C');
  

  -- Purpose   
  -- =======   
  --
  -- BLAS_SYMM  performs one of the matrix-matrix operations   
  --    C := alpha*A*B + beta*C,   
  -- or   
  --    C := alpha*B*A + beta*C,   
  -- where alpha and beta are scalars,  A is a symmetric matrix and  B and   
  -- C are  m by n matrices.   
  --
  -- Arguments   
  -- =========   
  --
  -- SIDE   - FLAG.   
  --          On entry,  SIDE  specifies whether  the  symmetric matrix  A   
  --          appears on the  left or right  in the  operation as follows:   
  --             SIDE = 'L' or 'l'   C := alpha*A*B + beta*C,   
  --             SIDE = 'R' or 'r'   C := alpha*B*A + beta*C,   
  --          Unchanged on exit.   
  -- UPLO   - FLAG.   
  --          On  entry,   UPLO  specifies  whether  the  upper  or  lower   
  --          triangular  part  of  the  symmetric  matrix   A  is  to  be   
  --          referenced as follows:   
  --             UPLO = 'U' or 'u'   Only the upper triangular part of the   
  --                                 symmetric matrix is to be referenced.   
  --             UPLO = 'L' or 'l'   Only the lower triangular part of the   
  --                                 symmetric matrix is to be referenced.   
  --          Unchanged on exit.   
  -- M      - INTEGER.   
  --          On entry,  M  specifies the number of rows of the matrix  C.   
  --          M  must be at least zero.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the number of columns of the matrix C.   
  --          N  must be at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, ka ), where ka is   
  --          m  when  SIDE = 'L' or 'l'  and is  n otherwise.   
  --          Before entry  with  SIDE = 'L' or 'l',  the  m by m  part of   
  --          the array  A  must contain the  symmetric matrix,  such that   
  --          when  UPLO = 'U' or 'u', the leading m by m upper triangular   
  --          part of the array  A  must contain the upper triangular part   
  --          of the  symmetric matrix and the  strictly  lower triangular   
  --          part of  A  is not referenced,  and when  UPLO = 'L' or 'l',   
  --          the leading  m by m  lower triangular part  of the  array  A   
  --          must  contain  the  lower triangular part  of the  symmetric   
  --          matrix and the  strictly upper triangular part of  A  is not   
  --          referenced.   
  --          Before entry  with  SIDE = 'R' or 'r',  the  n by n  part of   
  --          the array  A  must contain the  symmetric matrix,  such that   
  --          when  UPLO = 'U' or 'u', the leading n by n upper triangular   
  --          part of the array  A  must contain the upper triangular part   
  --          of the  symmetric matrix and the  strictly  lower triangular   
  --          part of  A  is not referenced,  and when  UPLO = 'L' or 'l',   
  --          the leading  n by n  lower triangular part  of the  array  A   
  --          must  contain  the  lower triangular part  of the  symmetric   
  --          matrix and the  strictly upper triangular part of  A  is not   
  --          referenced.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program.  When  SIDE = 'L' or 'l'  then   
  --          LDA must be at least  max( 1, m ), otherwise  LDA must be at   
  --          least  max( 1, n ).   
  --          Unchanged on exit.   
  -- B      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDB, n ).   
  --          Before entry, the leading  m by n part of the array  B  must   
  --          contain the matrix B.   
  --          Unchanged on exit.   
  -- LDB    - INTEGER.   
  --          On entry, LDB specifies the first dimension of B as declared   
  --          in  the  calling  (sub)  program.   LDB  must  be  at  least   
  --          max( 1, m ).   
  --          Unchanged on exit.   
  -- BETA   - SCALAR_FLOAT/DOUBLE            .   
  --          On entry,  BETA  specifies the scalar  beta.  When  BETA  is   
  --          supplied as zero then C need not be set on input.   
  --          Unchanged on exit.   
  -- C      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDC, n ).   
  --          Before entry, the leading  m by n  part of the array  C must   
  --          contain the matrix  C,  except when  beta  is zero, in which   
  --          case C need not be set on entry.   
  --          On exit, the array  C  is overwritten by the  m by n updated   
  --          matrix.   
  -- LDC    - INTEGER.   
  --          On entry, LDC specifies the first dimension of C as declared   
  --          in  the  calling  (sub)  program.   LDC  must  be  at  least   
  --          max( 1, m ).   
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_symm(side  IN     flag,
                      uplo  IN     flag,
                      m     IN     POSITIVEN,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_double,
                      a     IN     utl_nla_array_dbl,
                      lda   IN     POSITIVEN,
                      b     IN     utl_nla_array_dbl,
                      ldb   IN     POSITIVEN,
                      beta  IN     scalar_double,
                      c     IN OUT utl_nla_array_dbl,
                      ldc   IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');  
  
  PROCEDURE blas_symm(side  IN     flag,
                      uplo  IN     flag,
                      m     IN     POSITIVEN,
                      n     IN     POSITIVEN,
                      alpha IN     scalar_float,
                      a     IN     UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      b     IN     UTL_NLA_ARRAY_FLT,
                      ldb   IN     POSITIVEN,
                      beta  IN     scalar_float,
                      c     IN OUT UTL_NLA_ARRAY_FLT,
                      ldc   IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_TRMM  performs one of the matrix-matrix operations   
  --    B := alpha*op( A )*B,   or   B := alpha*B*op( A ),   
  -- where  alpha  is a scalar,  B  is an m by n matrix,  A  is a unit, or   
  -- non-unit,  upper or lower triangular matrix  and  op( A )  is one  of   
  --    op( A ) = A   or   op( A ) = A'.   
  --
  -- Arguments   
  -- =========   
  --
  -- SIDE   - FLAG.   
  --          On entry,  SIDE specifies whether  op( A ) multiplies B from   
  --          the left or right as follows:   
  --             SIDE = 'L' or 'l'   B := alpha*op( A )*B.   
  --             SIDE = 'R' or 'r'   B := alpha*B*op( A ).   
  --          Unchanged on exit.   
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the matrix A is an upper or   
  --          lower triangular matrix as follows:   
  --             UPLO = 'U' or 'u'   A is an upper triangular matrix.   
  --             UPLO = 'L' or 'l'   A is a lower triangular matrix.   
  --          Unchanged on exit.   
  -- TRANSA - FLAG.   
  --          On entry, TRANSA specifies the form of op( A ) to be used in   
  --          the matrix multiplication as follows:   
  --             TRANSA = 'N' or 'n'   op( A ) = A.   
  --             TRANSA = 'T' or 't'   op( A ) = A'.   
  --             TRANSA = 'C' or 'c'   op( A ) = A'.   
  --          Unchanged on exit.   
  -- DIAG   - FLAG.   
  --          On entry, DIAG specifies whether or not A is unit triangular   
  --          as follows:   
  --             DIAG = 'U' or 'u'   A is assumed to be unit triangular.   
  --             DIAG = 'N' or 'n'   A is not assumed to be unit   
  --                                 triangular.   
  --          Unchanged on exit.   
  -- M      - INTEGER.   
  --          On entry, M specifies the number of rows of B. M must be at   
  --          least zero.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the number of columns of B.  N must be   
  --          at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry,  ALPHA specifies the scalar  alpha. When  alpha is   
  --          zero then  A is not referenced and  B need not be set before   
  --          entry.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, k ), where k is m   
  --          when  SIDE = 'L' or 'l'  and is  n  when  SIDE = 'R' or 'r'.   
  --          Before entry  with  UPLO = 'U' or 'u',  the  leading  k by k   
  --          upper triangular part of the array  A must contain the upper   
  --          triangular matrix  and the strictly lower triangular part of   
  --          A is not referenced.   
  --          Before entry  with  UPLO = 'L' or 'l',  the  leading  k by k   
  --          lower triangular part of the array  A must contain the lower   
  --          triangular matrix  and the strictly upper triangular part of   
  --          A is not referenced.   
  --          Note that when  DIAG = 'U' or 'u',  the diagonal elements of   
  --          A  are not referenced either,  but are assumed to be  unity.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program.  When  SIDE = 'L' or 'l'  then   
  --          LDA  must be at least  max( 1, m ),  when  SIDE = 'R' or 'r'   
  --          then LDA must be at least max( 1, n ).   
  --          Unchanged on exit.   
  -- B      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDB, n ).   
  --          Before entry,  the leading  m by n part of the array  B must   
  --          contain the matrix  B,  and  on exit  is overwritten  by the   
  --          transformed matrix.   
  -- LDB    - INTEGER.   
  --          On entry, LDB specifies the first dimension of B as declared   
  --          in  the  calling  (sub)  program.   LDB  must  be  at  least   
  --          max( 1, m ).
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_trmm(side   IN     flag,
                      uplo   IN     flag,
                      transa IN     flag,
                      diag   IN     flag,
                      m      IN     POSITIVEN,
                      n      IN     POSITIVEN,
                      alpha  IN     scalar_double,
                      a      IN     utl_nla_array_dbl,
                      lda    IN     POSITIVEN,
                      b      IN OUT utl_nla_array_dbl,
                      ldb    IN     POSITIVEN,
                      pack   IN     flag DEFAULT 'C');  
  
  PROCEDURE blas_trmm(side   IN     flag,
                      uplo   IN     flag,
                      transa IN     flag,
                      diag   IN     flag,
                      m      IN     POSITIVEN,
                      n      IN     POSITIVEN,
                      alpha  IN     scalar_float,
                      a      IN     UTL_NLA_ARRAY_FLT,
                      lda    IN     POSITIVEN,
                      b      IN OUT UTL_NLA_ARRAY_FLT,
                      ldb    IN     POSITIVEN,
                      pack   IN     flag DEFAULT 'C');
  
  -- Purpose   
  -- =======   
  --
  -- BLAS_TRSM solves one of the matrix equations   
  --    op( A )*X = alpha*B,   or   X*op( A ) = alpha*B,   
  -- where alpha is a scalar, X and B are m by n matrices, A is a unit, or   
  -- non-unit,  upper or lower triangular matrix  and  op( A )  is one  of   
  --    op( A ) = A   or   op( A ) = A'.   
  -- The matrix X is overwritten on B.   
  --
  -- Parameters   
  -- ==========   
  --
  -- SIDE   - FLAG.   
  --          On entry, SIDE specifies whether op( A ) appears on the left   
  --          or right of X as follows:   
  --             SIDE = 'L' or 'l'   op( A )*X = alpha*B.   
  --             SIDE = 'R' or 'r'   X*op( A ) = alpha*B.   
  --          Unchanged on exit.   
  -- UPLO   - FLAG.   
  --          On entry, UPLO specifies whether the matrix A is an upper or   
  --          lower triangular matrix as follows:   
  --             UPLO = 'U' or 'u'   A is an upper triangular matrix.   
  --             UPLO = 'L' or 'l'   A is a lower triangular matrix.   
  --          Unchanged on exit.   
  -- TRANSA - FLAG.   
  --          On entry, TRANSA specifies the form of op( A ) to be used in   
  --          the matrix multiplication as follows:   
  --             TRANSA = 'N' or 'n'   op( A ) = A.   
  --             TRANSA = 'T' or 't'   op( A ) = A'.   
  --             TRANSA = 'C' or 'c'   op( A ) = A'.   
  --          Unchanged on exit.   
  -- DIAG   - FLAG.   
  --          On entry, DIAG specifies whether or not A is unit triangular   
  --          as follows:   
  --             DIAG = 'U' or 'u'   A is assumed to be unit triangular.   
  --             DIAG = 'N' or 'n'   A is not assumed to be unit   
  --                                 triangular.   
  --          Unchanged on exit.   
  -- M      - INTEGER.   
  --          On entry, M specifies the number of rows of B. M must be at   
  --          least zero.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry, N specifies the number of columns of B.  N must be   
  --          at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry,  ALPHA specifies the scalar  alpha. When  alpha is   
  --          zero then  A is not referenced and  B need not be set before   
  --          entry.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, k ), where k is m   
  --          when  SIDE = 'L' or 'l'  and is  n  when  SIDE = 'R' or 'r'.   
  --          Before entry  with  UPLO = 'U' or 'u',  the  leading  k by k   
  --          upper triangular part of the array  A must contain the upper   
  --          triangular matrix  and the strictly lower triangular part of   
  --          A is not referenced.   
  --          Before entry  with  UPLO = 'L' or 'l',  the  leading  k by k   
  --          lower triangular part of the array  A must contain the lower   
  --          triangular matrix  and the strictly upper triangular part of   
  --          A is not referenced.   
  --          Note that when  DIAG = 'U' or 'u',  the diagonal elements of   
  --          A  are not referenced either,  but are assumed to be  unity.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in the calling (sub) program.  When  SIDE = 'L' or 'l'  then   
  --          LDA  must be at least  max( 1, m ),  when  SIDE = 'R' or 'r'   
  --          then LDA must be at least max( 1, n ).   
  --          Unchanged on exit.   
  -- B      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDB, n ).   
  --          Before entry,  the leading  m by n part of the array  B must   
  --          contain  the  right-hand  side  matrix  B,  and  on exit  is   
  --          overwritten by the solution matrix  X.   
  -- LDB    - INTEGER.   
  --          On entry, LDB specifies the first dimension of B as declared   
  --          in  the  calling  (sub)  program.   LDB  must  be  at  least   
  --          max( 1, m ).     
  --          Unchanged on exit.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_trsm(side   IN     flag,
                      uplo   IN     flag,
                      transa IN     flag,
                      diag   IN     flag,
                      m      IN     POSITIVEN,
                      n      IN     POSITIVEN,
                      alpha  IN     scalar_double,
                      a      IN     utl_nla_array_dbl,
                      lda    IN     POSITIVEN,
                      b      IN OUT utl_nla_array_dbl,
                      ldb    IN     POSITIVEN,
                      pack   IN     flag DEFAULT 'C');  
  
  PROCEDURE blas_trsm(side   IN     flag,
                      uplo   IN     flag,
                      transa IN     flag,
                      diag   IN     flag,
                      m      IN     POSITIVEN,
                      n      IN     POSITIVEN,
                      alpha  IN     scalar_float,
                      a      IN     UTL_NLA_ARRAY_FLT,
                      lda    IN     POSITIVEN,
                      b      IN OUT UTL_NLA_ARRAY_FLT,
                      ldb    IN     POSITIVEN,
                      pack   IN     flag DEFAULT 'C');
    
  -- Purpose   
  -- =======   
  --
  -- BLAS_SYRK  performs one of the symmetric rank k operations   
  --    C := alpha*A*A' + beta*C,   
  -- or   
  --    C := alpha*A'*A + beta*C,   
  -- where  alpha and beta  are scalars, C is an  n by n  symmetric matrix   
  -- and  A  is an  n by k  matrix in the first case and a  k by n  matrix   
  -- in the second case.   
  --
  -- Arguments   
  -- =========   
  -- UPLO   - FLAG.   
  --          On  entry,   UPLO  specifies  whether  the  upper  or  lower   
  --          triangular  part  of the  array  C  is to be  referenced  as   
  --          follows:   
  --             UPLO = 'U' or 'u'   Only the  upper triangular part of  C   
  --                                 is to be referenced.   
  --             UPLO = 'L' or 'l'   Only the  lower triangular part of  C   
  --                                 is to be referenced.   
  --          Unchanged on exit.   
  -- TRANS  - FLAG.   
  --          On entry,  TRANS  specifies the operation to be performed as   
  --          follows:   
  --             TRANS = 'N' or 'n'   C := alpha*A*A' + beta*C.   
  --             TRANS = 'T' or 't'   C := alpha*A'*A + beta*C.   
  --             TRANS = 'C' or 'c'   C := alpha*A'*A + beta*C.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry,  N specifies the order of the matrix C.  N must be   
  --          at least zero.   
  --          Unchanged on exit.   
  -- K      - INTEGER.   
  --          On entry with  TRANS = 'N' or 'n',  K  specifies  the number   
  --          of  columns   of  the   matrix   A,   and  on   entry   with   
  --          TRANS = 'T' or 't' or 'C' or 'c',  K  specifies  the  number   
  --          of rows of the matrix  A.  K must be at least zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, ka ), where ka is   
  --          k  when  TRANS = 'N' or 'n',  and is  n  otherwise.   
  --          Before entry with  TRANS = 'N' or 'n',  the  leading  n by k   
  --          part of the array  A  must contain the matrix  A,  otherwise   
  --          the leading  k by n  part of the array  A  must contain  the   
  --          matrix A.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in  the  calling  (sub)  program.   When  TRANS = 'N' or 'n'   
  --          then  LDA must be at least  max( 1, n ), otherwise  LDA must   
  --          be at least  max( 1, k ).   
  --          Unchanged on exit.   
  -- BETA   - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, BETA specifies the scalar beta.   
  --          Unchanged on exit.   
  -- C      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDC, n ).   
  --          Before entry  with  UPLO = 'U' or 'u',  the leading  n by n   
  --          upper triangular part of the array C must contain the upper   
  --          triangular part  of the  symmetric matrix  and the strictly   
  --          lower triangular part of C is not referenced.  On exit, the   
  --          upper triangular part of the array  C is overwritten by the   
  --          upper triangular part of the updated matrix.   
  --          Before entry  with  UPLO = 'L' or 'l',  the leading  n by n   
  --          lower triangular part of the array C must contain the lower   
  --          triangular part  of the  symmetric matrix  and the strictly   
  --          upper triangular part of C is not referenced.  On exit, the   
  --          lower triangular part of the array  C is overwritten by the   
  --          lower triangular part of the updated matrix.   
  -- LDC    - INTEGER.   
  --          On entry, LDC specifies the first dimension of C as declared   
  --          in  the  calling  (sub)  program.   LDC  must  be  at  least   
  --          max( 1, n ).   
  --          Unchanged on exit.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE blas_syrk(uplo  IN     flag,
                      trans IN     flag,
                      n     IN     POSITIVEN,
                      k     IN     POSITIVEN,
                      alpha IN     scalar_double,
                      a     IN     utl_nla_array_dbl,
                      lda   IN     POSITIVEN,
                      beta  IN     scalar_double,
                      c     IN OUT utl_nla_array_dbl,
                      ldc   IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');  
  
  PROCEDURE blas_syrk(uplo  IN     flag,
                      trans IN     flag,
                      n     IN     POSITIVEN,
                      k     IN     POSITIVEN,
                      alpha IN     scalar_float,
                      a     IN     UTL_NLA_ARRAY_FLT,
                      lda   IN     POSITIVEN,
                      beta  IN     scalar_float,
                      c     IN OUT UTL_NLA_ARRAY_FLT,
                      ldc   IN     POSITIVEN,
                      pack  IN     flag DEFAULT 'C');
    
  -- Purpose   
  -- =======   
  --
  -- BLAS_SYR2K  performs one of the symmetric rank 2k operations   
  --    C := alpha*A*B' + alpha*B*A' + beta*C,   
  -- or   
  --    C := alpha*A'*B + alpha*B'*A + beta*C,   
  -- where  alpha and beta  are scalars, C is an  n by n  symmetric matrix   
  -- and  A and B  are  n by k  matrices  in the  first  case  and  k by n   
  -- matrices in the second case.   
  --
  -- Arguments   
  -- =========   
  -- UPLO   - FLAG.   
  --          On  entry,   UPLO  specifies  whether  the  upper  or  lower   
  --          triangular  part  of the  array  C  is to be  referenced  as   
  --          follows:   
  --             UPLO = 'U' or 'u'   Only the  upper triangular part of  C   
  --                                 is to be referenced.   
  --             UPLO = 'L' or 'l'   Only the  lower triangular part of  C   
  --                                 is to be referenced.   
  --          Unchanged on exit.   
  -- TRANS  - FLAG.   
  --          On entry,  TRANS  specifies the operation to be performed as   
  --          follows:   
  --             TRANS = 'N' or 'n'   C := alpha*A*B' + alpha*B*A' +   
  --                                       beta*C.   
  --             TRANS = 'T' or 't'   C := alpha*A'*B + alpha*B'*A +   
  --                                       beta*C.   
  --             TRANS = 'C' or 'c'   C := alpha*A'*B + alpha*B'*A +   
  --                                       beta*C.   
  --          Unchanged on exit.   
  -- N      - INTEGER.   
  --          On entry,  N specifies the order of the matrix C.  N must be   
  --          at least zero.   
  --          Unchanged on exit.   
  -- K      - INTEGER.   
  --          On entry with  TRANS = 'N' or 'n',  K  specifies  the number   
  --          of  columns  of the  matrices  A and B,  and on  entry  with   
  --          TRANS = 'T' or 't' or 'C' or 'c',  K  specifies  the  number   
  --          of rows of the matrices  A and B.  K must be at least  zero.   
  --          Unchanged on exit.   
  -- ALPHA  - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, ALPHA specifies the scalar alpha.   
  --          Unchanged on exit.   
  -- A      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDA, ka ), where ka is   
  --          k  when  TRANS = 'N' or 'n',  and is  n  otherwise.   
  --          Before entry with  TRANS = 'N' or 'n',  the  leading  n by k   
  --          part of the array  A  must contain the matrix  A,  otherwise   
  --          the leading  k by n  part of the array  A  must contain  the   
  --          matrix A.   
  --          Unchanged on exit.   
  -- LDA    - INTEGER.   
  --          On entry, LDA specifies the first dimension of A as declared   
  --          in  the  calling  (sub)  program.   When  TRANS = 'N' or 'n'   
  --          then  LDA must be at least  max( 1, n ), otherwise  LDA must   
  --          be at least  max( 1, k ).   
  --          Unchanged on exit.   
  -- B      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDB, kb ), where kb is   
  --          k  when  TRANS = 'N' or 'n',  and is  n  otherwise.   
  --          Before entry with  TRANS = 'N' or 'n',  the  leading  n by k   
  --          part of the array  B  must contain the matrix  B,  otherwise   
  --          the leading  k by n  part of the array  B  must contain  the   
  --          matrix B.   
  --          Unchanged on exit.   
  -- LDB    - INTEGER.   
  --          On entry, LDB specifies the first dimension of B as declared   
  --          in  the  calling  (sub)  program.   When  TRANS = 'N' or 'n'   
  --          then  LDB must be at least  max( 1, n ), otherwise  LDB must   
  --          be at least  max( 1, k ).   
  --          Unchanged on exit.   
  -- BETA   - SCALAR_FLOAT/DOUBLE            .   
  --          On entry, BETA specifies the scalar beta.   
  --          Unchanged on exit.   
  -- C      - UTL_NLA_ARRAY_FLT/DBL of DIMENSION ( LDC, n ).   
  --          Before entry  with  UPLO = 'U' or 'u',  the leading  n by n   
  --          upper triangular part of the array C must contain the upper   
  --          triangular part  of the  symmetric matrix  and the strictly   
  --          lower triangular part of C is not referenced.  On exit, the   
  --          upper triangular part of the array  C is overwritten by the   
  --          upper triangular part of the updated matrix.   
  --          Before entry  with  UPLO = 'L' or 'l',  the leading  n by n   
  --          lower triangular part of the array C must contain the lower   
  --          triangular part  of the  symmetric matrix  and the strictly   
  --          upper triangular part of C is not referenced.  On exit, the   
  --          lower triangular part of the array  C is overwritten by the   
  --          lower triangular part of the updated matrix.   
  -- LDC    - INTEGER.   
  --          On entry, LDC specifies the first dimension of C as declared   
  --          in  the  calling  (sub)  program.   LDC  must  be  at  least   
  --          max( 1, n ).   
  --          Unchanged on exit.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE blas_syr2k(uplo  IN     flag,
                       trans IN     flag,
                       n     IN     POSITIVEN,
                       k     IN     POSITIVEN,
                       alpha IN     scalar_double,
                       a     IN     utl_nla_array_dbl,
                       lda   IN     POSITIVEN,
                       b     IN     utl_nla_array_dbl,
                       ldb   IN     POSITIVEN,
                       beta  IN     scalar_double,
                       c     IN OUT utl_nla_array_dbl,
                       ldc   IN     POSITIVEN,
                       pack  IN     flag DEFAULT 'C');  
  
  PROCEDURE blas_syr2k(uplo  IN     flag,
                       trans IN     flag,
                       n     IN     POSITIVEN,
                       k     IN     POSITIVEN,
                       alpha IN     scalar_float,
                       a     IN     UTL_NLA_ARRAY_FLT,
                       lda   IN     POSITIVEN,
                       b     IN     UTL_NLA_ARRAY_FLT,
                       ldb   IN     POSITIVEN,
                       beta  IN     scalar_float,
                       c     IN OUT UTL_NLA_ARRAY_FLT,
                       ldc   IN     POSITIVEN,
                       pack  IN     flag DEFAULT 'C');
  
  
  -- ------------------------------------------ --
  --  LAPACK Driver Routines: Linear Equations  --
  -- ------------------------------------------ --

  --
  -- Purpose
  -- =======
  --
  -- LAPACK_GESV computes the solution to a real system of linear equations
  --    A * X = B,
  -- where A is an N-by-N matrix and X and B are N-by-NRHS matrices.
  --
  -- The LU decomposition with partial pivoting and row interchanges is
  -- used to factor A as
  --    A = P * L * U,
  -- where P is a permutation matrix, L is unit lower triangular, and U is
  -- upper triangular.  The factored form of A is then used to solve the
  -- system of equations A * X = B.
  --
  -- Arguments
  -- =========
  --
  -- N       (input) INTEGER
  --         The number of linear equations, i.e., the order of the
  --         matrix A.  N >= 0.
  --
  -- NRHS    (input) INTEGER
  --         The number of right hand sides, i.e., the number of columns
  --         of the matrix B.  NRHS >= 0.
  --
  -- A       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDA,N)
  --         On entry, the N-by-N coefficient matrix A.
  --         On exit, the factors L and U from the factorization
  --         A = P*L*U; the unit diagonal elements of L are not stored.
  --
  -- LDA     (input) INTEGER
  --         The leading dimension of the array A.  LDA >= max(1,N).
  --
  -- IPIV    (output) INTEGER array, dimension (N)
  --         The pivot indices that define the permutation matrix P;
  --         row i of the matrix was interchanged with row IPIV(i).
  --
  -- B       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDB,NRHS)
  --         On entry, the N-by-NRHS matrix of right hand side matrix B.
  --         On exit, if INFO = 0, the N-by-NRHS solution matrix X.
  --
  -- LDB     (input) INTEGER
  --         The leading dimension of the array B.  LDB >= max(1,N).
  --
  -- INFO    (output) INTEGER
  --         = 0:  successful exit
  --         < 0:  if INFO = -i, the i-th argument had an illegal value
  --         > 0:  if INFO = i, U(i,i) is exactly zero.  The factorization
  --               has been completed, but the factor U is exactly
  --               singular, so the solution could not be computed.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE lapack_gesv(n     IN     POSITIVEN, 
                       nrhs  IN     POSITIVEN, 
                       a     IN OUT utl_nla_array_dbl, 
                       lda   IN     POSITIVEN,
                       ipiv  IN OUT UTL_NLA_ARRAY_INT,
                       b     IN OUT utl_nla_array_dbl, 
                       ldb   IN     POSITIVEN,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_gesv(n     IN     POSITIVEN, 
                       nrhs  IN     POSITIVEN, 
                       a     IN OUT UTL_NLA_ARRAY_FLT, 
                       lda   IN     POSITIVEN,
                       ipiv  IN OUT UTL_NLA_ARRAY_INT,
                       b     IN OUT UTL_NLA_ARRAY_FLT, 
                       ldb   IN     POSITIVEN,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');

  --  
  --  Purpose
  --  =======
  --
  --  LAPACK_GBSV computes the solution to a real system of linear equations
  --  A * X = B, where A is a band matrix of order N with KL subdiagonals
  --  and KU superdiagonals, and X and B are N-by-NRHS matrices.
  --
  --  The LU decomposition with partial pivoting and row interchanges is
  --  used to factor A as A = L * U, where L is a product of permutation
  --  and unit lower triangular matrices with KL subdiagonals, and U is
  --  upper triangular with KL+KU superdiagonals.  The factored form of A
  --  is then used to solve the system of equations A * X = B.
  --
  --  Arguments
  --  =========
  --
  --  N       (input) INTEGER
  --          The number of linear equations, i.e., the order of the
  --          matrix A.  N >= 0.
  --
  --  KL      (input) INTEGER
  --          The number of subdiagonals within the band of A.  KL >= 0.
  --
  --  KU      (input) INTEGER
  --          The number of superdiagonals within the band of A.  KU >= 0.
  --
  --  NRHS    (input) INTEGER
  --          The number of right hand sides, i.e., the number of columns
  --          of the matrix B.  NRHS >= 0.
  --
  --  AB      (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDAB,N)
  --          On entry, the matrix A in band storage, in rows KL+1 to
  --          2*KL+KU+1; rows 1 to KL of the array need not be set.
  --          The j-th column of A is stored in the j-th column of the
  --          array AB as follows:
  --          AB(KL+KU+1+i-j,j) = A(i,j) for max(1,j-KU)<=i<=min(N,j+KL)
  --          On exit, details of the factorization: U is stored as an
  --          upper triangular band matrix with KL+KU superdiagonals in
  --          rows 1 to KL+KU+1, and the multipliers used during the
  --          factorization are stored in rows KL+KU+2 to 2*KL+KU+1.
  --          See below for further details.
  --
  --  LDAB    (input) INTEGER
  --          The leading dimension of the array AB.  LDAB >= 2*KL+KU+1.
  --
  --  IPIV    (output) INTEGER array, dimension (N)
  --          The pivot indices that define the permutation matrix P;
  --          row i of the matrix was interchanged with row IPIV(i).
  --
  --  B       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDB,NRHS)
  --          On entry, the N-by-NRHS right hand side matrix B.
  --          On exit, if INFO = 0, the N-by-NRHS solution matrix X.
  --
  --  LDB     (input) INTEGER
  --          The leading dimension of the array B.  LDB >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, U(i,i) is exactly zero.  The factorization
  --                has been completed, but the factor U is exactly
  --                singular, and the solution has not been computed.
  --
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE lapack_gbsv (n     IN     POSITIVEN, 
                        kl    IN     NATURALN,
                        ku    IN     NATURALN,
                        nrhs  IN     POSITIVEN, 
                        ab    IN OUT utl_nla_array_dbl, 
                        ldab  IN     POSITIVEN,
                        ipiv  IN OUT UTL_NLA_ARRAY_INT,
                        b     IN OUT utl_nla_array_dbl, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_gbsv (n     IN     POSITIVEN, 
                        kl    IN     NATURALN,
                        ku    IN     NATURALN,
                        nrhs  IN     POSITIVEN, 
                        ab    IN OUT UTL_NLA_ARRAY_FLT, 
                        ldab  IN     POSITIVEN,
                        ipiv  IN OUT UTL_NLA_ARRAY_INT,
                        b     IN OUT UTL_NLA_ARRAY_FLT, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_GTSV  solves the equation
  --
  --     A*X = B,
  --
  --  where A is an n by n tridiagonal matrix, by Gaussian elimination with
  --  partial pivoting.
  --
  --  Note that the equation  A'*X = B  may be solved by interchanging the
  --  order of the arguments DU and DL.
  --
  --  Arguments
  --  =========
  --
  --  N       (input) INTEGER
  --          The order of the matrix A.  N >= 0.
  --
  --  NRHS    (input) INTEGER
  --          The number of right hand sides, i.e., the number of columns
  --          of the matrix B.  NRHS >= 0.
  --
  --  DL      (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N-1)
  --          On entry, DL must contain the (n-1) sub-diagonal elements of
  --          A.
  --
  --          On exit, DL is overwritten by the (n-2) elements of the
  --          second super-diagonal of the upper triangular matrix U from
  --          the LU factorization of A, in DL(1), ..., DL(n-2).
  --
  --  D       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          On entry, D must contain the diagonal elements of A.
  --
  --          On exit, D is overwritten by the n diagonal elements of U.
  --
  --  DU      (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N-1)
  --          On entry, DU must contain the (n-1) super-diagonal elements
  --          of A.
  --
  --          On exit, DU is overwritten by the (n-1) elements of the first
  --          super-diagonal of U.
  --
  --  B       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDB,NRHS)
  --          On entry, the N by NRHS matrix of right hand side matrix B.
  --          On exit, if INFO = 0, the N by NRHS solution matrix X.
  --
  --  LDB     (input) INTEGER
  --          The leading dimension of the array B.  LDB >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0: successful exit
  --          < 0: if INFO = -i, the i-th argument had an illegal value
  --          > 0: if INFO = i, U(i,i) is exactly zero, and the solution
  --               has not been computed.  The factorization has not been
  --               completed unless i = N.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE lapack_gtsv (n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        dl    IN OUT utl_nla_array_dbl, 
                        d     IN OUT utl_nla_array_dbl, 
                        du    IN OUT utl_nla_array_dbl,
                        b     IN OUT utl_nla_array_dbl, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_gtsv (n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        dl    IN OUT UTL_NLA_ARRAY_FLT, 
                        d     IN OUT UTL_NLA_ARRAY_FLT, 
                        du    IN OUT UTL_NLA_ARRAY_FLT, 
                        b     IN OUT UTL_NLA_ARRAY_FLT, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_POSV computes the solution to a real system of linear equations
  --     A * X = B,
  --  where A is an N-by-N symmetric positive definite matrix and X and B
  --  are N-by-NRHS matrices.
  --
  --  The Cholesky decomposition is used to factor A as
  --     A = U**T* U,  if UPLO = 'U', or
  --     A = L * L**T,  if UPLO = 'L',
  --  where U is an upper triangular matrix and L is a lower triangular
  --  matrix.  The factored form of A is then used to solve the system of
  --  equations A * X = B.
  --
  --  Arguments
  --  =========
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The number of linear equations, i.e., the order of the
  --          matrix A.  N >= 0.
  --
  --  NRHS    (input) INTEGER
  --          The number of right hand sides, i.e., the number of columns
  --          of the matrix B.  NRHS >= 0.
  --
  --  A       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDA,N)
  --          On entry, the symmetric matrix A.  If UPLO = 'U', the leading
  --          N-by-N upper triangular part of A contains the upper
  --          triangular part of the matrix A, and the strictly lower
  --          triangular part of A is not referenced.  If UPLO = 'L', the
  --          leading N-by-N lower triangular part of A contains the lower
  --          triangular part of the matrix A, and the strictly upper
  --          triangular part of A is not referenced.
  --
  --          On exit, if INFO = 0, the factor U or L from the Cholesky
  --          factorization A = U**T*U or A = L*L**T.
  --
  --  LDA     (input) INTEGER
  --          The leading dimension of the array A.  LDA >= max(1,N).
  --
  --  B       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDB,NRHS)
  --          On entry, the N-by-NRHS right hand side matrix B.
  --          On exit, if INFO = 0, the N-by-NRHS solution matrix X.
  --
  --  LDB     (input) INTEGER
  --          The leading dimension of the array B.  LDB >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, the leading minor of order i of A is not
  --                positive definite, so the factorization could not be
  --                completed, and the solution has not been computed.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_posv (uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        a     IN OUT utl_nla_array_dbl, 
                        lda   IN     POSITIVEN,
                        b     IN OUT utl_nla_array_dbl, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_posv (uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        a     IN OUT UTL_NLA_ARRAY_FLT, 
                        lda   IN     POSITIVEN,
                        b     IN OUT UTL_NLA_ARRAY_FLT, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_PPSV computes the solution to a real system of linear equations
  --     A * X = B,
  --  where A is an N-by-N symmetric positive definite matrix stored in
  --  packed format and X and B are N-by-NRHS matrices.
  --
  --  The Cholesky decomposition is used to factor A as
  --     A = U**T* U,  if UPLO = 'U', or
  --     A = L * L**T,  if UPLO = 'L',
  --  where U is an upper triangular matrix and L is a lower triangular
  --  matrix.  The factored form of A is then used to solve the system of
  --  equations A * X = B.
  --
  --  Arguments
  --  =========
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The number of linear equations, i.e., the order of the
  --          matrix A.  N >= 0.
  --
  --  NRHS    (input) INTEGER
  --          The number of right hand sides, i.e., the number of columns
  --          of the matrix B.  NRHS >= 0.
  --
  --  AP      (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N*(N+1)/2)
  --          On entry, the upper or lower triangle of the symmetric matrix
  --          A, packed columnwise in a linear array.  The j-th column of A
  --          is stored in the array AP as follows:
  --          if UPLO = 'U', AP(i + (j-1)*j/2) = A(i,j) for 1<=i<=j;
  --          if UPLO = 'L', AP(i + (j-1)*(2n-j)/2) = A(i,j) for j<=i<=n.
  --          See below for further details.  
  --
  --          On exit, if INFO = 0, the factor U or L from the Cholesky
  --          factorization A = U**T*U or A = L*L**T, in the same storage
  --          format as A.
  --
  --  B       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDB,NRHS)
  --          On entry, the N-by-NRHS right hand side matrix B.
  --          On exit, if INFO = 0, the N-by-NRHS solution matrix X.
  --
  --  LDB     (input) INTEGER
  --          The leading dimension of the array B.  LDB >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, the leading minor of order i of A is not
  --                positive definite, so the factorization could not be
  --                completed, and the solution has not been computed.
  -- 
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
 
  PROCEDURE lapack_ppsv (uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        ap    IN OUT utl_nla_array_dbl, 
                        b     IN OUT utl_nla_array_dbl, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_ppsv (uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        ap    IN OUT UTL_NLA_ARRAY_FLT, 
                        b     IN OUT UTL_NLA_ARRAY_FLT, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_PBSV computes the solution to a real system of linear equations
  --     A * X = B,
  --  where A is an N-by-N symmetric positive definite band matrix and X
  --  and B are N-by-NRHS matrices.
  --
  --  The Cholesky decomposition is used to factor A as
  --     A = U**T * U,  if UPLO = 'U', or
  --     A = L * L**T,  if UPLO = 'L',
  --  where U is an upper triangular band matrix, and L is a lower
  --  triangular band matrix, with the same number of superdiagonals or
  --  subdiagonals as A.  The factored form of A is then used to solve the
  --  system of equations A * X = B.
  --
  --  Arguments
  --  =========
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The number of linear equations, i.e., the order of the
  --          matrix A.  N >= 0.
  --
  --  KD      (input) INTEGER
  --          The number of superdiagonals of the matrix A if UPLO = 'U',
  --          or the number of subdiagonals if UPLO = 'L'.  KD >= 0.
  --
  --  NRHS    (input) INTEGER
  --          The number of right hand sides, i.e., the number of columns
  --          of the matrix B.  NRHS >= 0.
  --
  --  AB      (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDAB,N)
  --          On entry, the upper or lower triangle of the symmetric band
  --          matrix A, stored in the first KD+1 rows of the array.  The
  --          j-th column of A is stored in the j-th column of the array AB
  --          as follows:
  --          if UPLO = 'U', AB(KD+1+i-j,j) = A(i,j) for max(1,j-KD)<=i<=j;
  --          if UPLO = 'L', AB(1+i-j,j)    = A(i,j) for j<=i<=min(N,j+KD).
  --          See below for further details.
  --
  --          On exit, if INFO = 0, the triangular factor U or L from the
  --          Cholesky factorization A = U**T*U or A = L*L**T of the band
  --          matrix A, in the same storage format as A.
  --
  --  LDAB    (input) INTEGER
  --          The leading dimension of the array AB.  LDAB >= KD+1.
  --
  --  B       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDB,NRHS)
  --          On entry, the N-by-NRHS right hand side matrix B.
  --          On exit, if INFO = 0, the N-by-NRHS solution matrix X.
  --
  --  LDB     (input) INTEGER
  --          The leading dimension of the array B.  LDB >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, the leading minor of order i of A is not
  --                positive definite, so the factorization could not be
  --                completed, and the solution has not been computed.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_pbsv (uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        kd    IN     NATURALN,
                        nrhs  IN     POSITIVEN, 
                        ab    IN OUT utl_nla_array_dbl, 
                        ldab  IN     POSITIVEN,
                        b     IN OUT utl_nla_array_dbl, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_pbsv (uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        kd    IN     NATURALN,
                        nrhs  IN     POSITIVEN, 
                        ab    IN OUT UTL_NLA_ARRAY_FLT, 
                        ldab  IN     POSITIVEN,
                        b     IN OUT UTL_NLA_ARRAY_FLT, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  SPTSV computes the solution to a real system of linear equations
  --  A*X = B, where A is an N-by-N symmetric positive definite tridiagonal
  --  matrix, and X and B are N-by-NRHS matrices.
  --
  --  A is factored as A = L*D*L**T, and the factored form of A is then
  --  used to solve the system of equations.
  --
  --  Arguments
  --  =========
  --
  --  N       (input) INTEGER
  --          The order of the matrix A.  N >= 0.
  --
  --  NRHS    (input) INTEGER
  --          The number of right hand sides, i.e., the number of columns
  --          of the matrix B.  NRHS >= 0.
  --
  --  D       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          On entry, the n diagonal elements of the tridiagonal matrix
  --          A.  On exit, the n diagonal elements of the diagonal matrix
  --          D from the factorization A = L*D*L**T.
  --
  --  E       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N-1)
  --          On entry, the (n-1) subdiagonal elements of the tridiagonal
  --          matrix A.  On exit, the (n-1) subdiagonal elements of the
  --          unit bidiagonal factor L from the L*D*L**T factorization of
  --          A.  (E can also be regarded as the superdiagonal of the unit
  --          bidiagonal factor U from the U**T*D*U factorization of A.)
  --
  --  B       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDB,NRHS)
  --          On entry, the N-by-NRHS right hand side matrix B.
  --          On exit, if INFO = 0, the N-by-NRHS solution matrix X.
  --
  --  LDB     (input) INTEGER
  --          The leading dimension of the array B.  LDB >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, the leading minor of order i is not
  --                positive definite, and the solution has not been
  --                computed.  The factorization has not been completed
  --                unless i = N.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_ptsv (n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        d     IN OUT utl_nla_array_dbl, 
                        e     IN OUT utl_nla_array_dbl, 
                        b     IN OUT utl_nla_array_dbl, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_ptsv (n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        d     IN OUT UTL_NLA_ARRAY_FLT, 
                        e     IN OUT UTL_NLA_ARRAY_FLT, 
                        b     IN OUT UTL_NLA_ARRAY_FLT, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_SYSV computes the solution to a real system of linear equations
  --     A * X = B,
  --  where A is an N-by-N symmetric matrix and X and B are N-by-NRHS
  --  matrices.
  --
  --  The diagonal pivoting method is used to factor A as
  --     A = U * D * U**T,  if UPLO = 'U', or
  --     A = L * D * L**T,  if UPLO = 'L',
  --  where U (or L) is a product of permutation and unit upper (lower)
  --  triangular matrices, and D is symmetric and block diagonal with 
  --  1-by-1 and 2-by-2 diagonal blocks.  The factored form of A is then
  --  used to solve the system of equations A * X = B.
  --
  --  Arguments
  --  =========
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The number of linear equations, i.e., the order of the
  --          matrix A.  N >= 0.
  --
  --  NRHS    (input) INTEGER
  --          The number of right hand sides, i.e., the number of columns
  --          of the matrix B.  NRHS >= 0.
  --
  --  A       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDA,N)
  --          On entry, the symmetric matrix A.  If UPLO = 'U', the leading
  --          N-by-N upper triangular part of A contains the upper
  --          triangular part of the matrix A, and the strictly lower
  --          triangular part of A is not referenced.  If UPLO = 'L', the
  --          leading N-by-N lower triangular part of A contains the lower
  --          triangular part of the matrix A, and the strictly upper
  --          triangular part of A is not referenced.
  --
  --          On exit, if INFO = 0, the block diagonal matrix D and the
  --          multipliers used to obtain the factor U or L from the
  --          factorization A = U*D*U**T or A = L*D*L**T as computed by
  --          SSYTRF.
  --
  --  LDA     (input) INTEGER
  --          The leading dimension of the array A.  LDA >= max(1,N).
  --
  --  IPIV    (output) INTEGER array, dimension (N)
  --          Details of the interchanges and the block structure of D, as
  --          determined by SSYTRF.  If IPIV(k) > 0, then rows and columns
  --          k and IPIV(k) were interchanged, and D(k,k) is a 1-by-1
  --          diagonal block.  If UPLO = 'U' and IPIV(k) = IPIV(k-1) < 0,
  --          then rows and columns k-1 and -IPIV(k) were interchanged and
  --          D(k-1:k,k-1:k) is a 2-by-2 diagonal block.  If UPLO = 'L' and
  --          IPIV(k) = IPIV(k+1) < 0, then rows and columns k+1 and
  --          -IPIV(k) were interchanged and D(k:k+1,k:k+1) is a 2-by-2
  --          diagonal block.
  --
  --  B       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDB,NRHS)
  --          On entry, the N-by-NRHS right hand side matrix B.
  --          On exit, if INFO = 0, the N-by-NRHS solution matrix X.
  --
  --  LDB     (input) INTEGER
  --          The leading dimension of the array B.  LDB >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0: successful exit
  --          < 0: if INFO = -i, the i-th argument had an illegal value
  --          > 0: if INFO = i, D(i,i) is exactly zero.  The factorization
  --               has been completed, but the block diagonal matrix D is
  --               exactly singular, so the solution could not be computed.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_sysv (uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        a     IN OUT utl_nla_array_dbl, 
                        lda   IN     POSITIVEN,
                        ipiv  IN OUT UTL_NLA_ARRAY_INT,
                        b     IN OUT utl_nla_array_dbl, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_sysv (uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        a     IN OUT UTL_NLA_ARRAY_FLT, 
                        lda   IN     POSITIVEN,
                        ipiv  IN OUT UTL_NLA_ARRAY_INT,
                        b     IN OUT UTL_NLA_ARRAY_FLT, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');

  --
  --  Purpose
  --  =======
  --
  --  LAPACK_SPSV computes the solution to a real system of linear equations
  --     A * X = B,
  --  where A is an N-by-N symmetric matrix stored in packed format and X
  --  and B are N-by-NRHS matrices.
  --
  --  The diagonal pivoting method is used to factor A as
  --     A = U * D * U**T,  if UPLO = 'U', or
  --     A = L * D * L**T,  if UPLO = 'L',
  --  where U (or L) is a product of permutation and unit upper (lower)
  --  triangular matrices, D is symmetric and block diagonal with 1-by-1
  --  and 2-by-2 diagonal blocks.  The factored form of A is then used to
  --  solve the system of equations A * X = B.
  --
  --  Arguments
  --  =========
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The number of linear equations, i.e., the order of the
  --          matrix A.  N >= 0.
  --
  --  NRHS    (input) INTEGER
  --          The number of right hand sides, i.e., the number of columns
  --          of the matrix B.  NRHS >= 0.
  --
  --  AP      (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N*(N+1)/2)
  --          On entry, the upper or lower triangle of the symmetric matrix
  --          A, packed columnwise in a linear array.  The j-th column of A
  --          is stored in the array AP as follows:
  --          if UPLO = 'U', AP(i + (j-1)*j/2) = A(i,j) for 1<=i<=j;
  --          if UPLO = 'L', AP(i + (j-1)*(2n-j)/2) = A(i,j) for j<=i<=n.
  --          See below for further details.
  --
  --          On exit, the block diagonal matrix D and the multipliers used
  --          to obtain the factor U or L from the factorization
  --          A = U*D*U**T or A = L*D*L**T as computed by SSPTRF, stored as
  --          a packed triangular matrix in the same storage format as A.
  --
  --  IPIV    (output) INTEGER array, dimension (N)
  --          Details of the interchanges and the block structure of D, as
  --          determined by SSPTRF.  If IPIV(k) > 0, then rows and columns
  --          k and IPIV(k) were interchanged, and D(k,k) is a 1-by-1
  --          diagonal block.  If UPLO = 'U' and IPIV(k) = IPIV(k-1) < 0,
  --          then rows and columns k-1 and -IPIV(k) were interchanged and
  --          D(k-1:k,k-1:k) is a 2-by-2 diagonal block.  If UPLO = 'L' and
  --          IPIV(k) = IPIV(k+1) < 0, then rows and columns k+1 and
  --          -IPIV(k) were interchanged and D(k:k+1,k:k+1) is a 2-by-2
  --          diagonal block.
  --
  --  B       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDB,NRHS)
  --          On entry, the N-by-NRHS right hand side matrix B.
  --          On exit, if INFO = 0, the N-by-NRHS solution matrix X.
  --
  --  LDB     (input) INTEGER
  --          The leading dimension of the array B.  LDB >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, D(i,i) is exactly zero.  The factorization
  --                has been completed, but the block diagonal matrix D is
  --                exactly singular, so the solution could not be
  --                computed.
  -- PACK   - (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE lapack_spsv (uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        ap    IN OUT utl_nla_array_dbl, 
                        ipiv  IN OUT UTL_NLA_ARRAY_INT,
                        b     IN OUT utl_nla_array_dbl, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_spsv (uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        nrhs  IN     POSITIVEN, 
                        ap    IN OUT UTL_NLA_ARRAY_FLT, 
                        ipiv  IN OUT UTL_NLA_ARRAY_INT,
                        b     IN OUT UTL_NLA_ARRAY_FLT, 
                        ldb   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
 
  -- ----------------------------------------------------- --
  --  LAPACK Driver Routines: LLS and Eigenvalue Problems  --
  -- ----------------------------------------------------- --
  
  -- [> LLS Problems <]
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_GELS solves overdetermined or underdetermined real linear systems
  --  involving an M-by-N matrix A, or its transpose, using a QR or LQ
  --  factorization of A.  It is assumed that A has full rank.
  --
  --  The following options are provided: 
  --
  --  1. If TRANS = 'N' and m >= n:  find the least squares solution of
  --     an overdetermined system, i.e., solve the least squares problem
  --                  minimize || B - A*X ||.
  --
  --  2. If TRANS = 'N' and m < n:  find the minimum norm solution of
  --     an underdetermined system A * X = B.
  --
  --  3. If TRANS = 'T' and m >= n:  find the minimum norm solution of
  --     an undetermined system A**T * X = B.
  --
  --  4. If TRANS = 'T' and m < n:  find the least squares solution of
  --     an overdetermined system, i.e., solve the least squares problem
  --                  minimize || B - A**T * X ||.
  --
  --  Several right hand side vectors b and solution vectors x can be 
  --  handled in a single call; they are stored as the columns of the
  --  M-by-NRHS right hand side matrix B and the N-by-NRHS solution 
  --  matrix X.
  --
  --  Arguments
  --  =========
  --
  --  TRANS   (input) CHARACTER
  --          = 'N': the linear system involves A;
  --          = 'T': the linear system involves A**T. 
  --
  --  M       (input) INTEGER
  --          The number of rows of the matrix A.  M >= 0.
  --
  --  N       (input) INTEGER
  --          The number of columns of the matrix A.  N >= 0.
  --
  --  NRHS    (input) INTEGER
  --          The number of right hand sides, i.e., the number of
  --          columns of the matrices B and X. NRHS >=0.
  --
  --  A       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDA,N)
  --          On entry, the M-by-N matrix A.
  --          On exit,
  --            if M >= N, A is overwritten by details of its QR
  --                       factorization as returned by SGEQRF;
  --            if M <  N, A is overwritten by details of its LQ
  --                       factorization as returned by SGELQF.
  --
  --  LDA     (input) INTEGER
  --          The leading dimension of the array A.  LDA >= max(1,M).
  --
  --  B       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDB,NRHS)
  --          On entry, the matrix B of right hand side vectors, stored
  --          columnwise; B is M-by-NRHS if TRANS = 'N', or N-by-NRHS
  --          if TRANS = 'T'.  
  --          On exit, B is overwritten by the solution vectors, stored
  --          columnwise:
  --          if TRANS = 'N' and m >= n, rows 1 to n of B contain the least
  --          squares solution vectors; the residual sum of squares for the
  --          solution in each column is given by the sum of squares of
  --          elements N+1 to M in that column;
  --          if TRANS = 'N' and m < n, rows 1 to N of B contain the
  --          minimum norm solution vectors;
  --          if TRANS = 'T' and m >= n, rows 1 to M of B contain the
  --          minimum norm solution vectors;
  --          if TRANS = 'T' and m < n, rows 1 to M of B contain the
  --          least squares solution vectors; the residual sum of squares
  --          for the solution in each column is given by the sum of
  --          squares of elements M+1 to N in that column.
  --
  --  LDB     (input) INTEGER
  --          The leading dimension of the array B. LDB >= MAX(1,M,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_gels(trans IN     flag,
                       m     IN     POSITIVEN, 
                       n     IN     POSITIVEN, 
                       nrhs  IN     POSITIVEN, 
                       a     IN OUT utl_nla_array_dbl,
                       lda   IN     POSITIVEN,
                       b     IN OUT utl_nla_array_dbl, 
                       ldb   IN     POSITIVEN,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_gels(trans IN     flag,
                       m     IN     POSITIVEN, 
                       n     IN     POSITIVEN, 
                       nrhs  IN     POSITIVEN, 
                       a     IN OUT UTL_NLA_ARRAY_FLT,
                       lda   IN     POSITIVEN,
                       b     IN OUT UTL_NLA_ARRAY_FLT, 
                       ldb   IN     POSITIVEN,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');
   
  -- [> Symmetric Eigenproblems <]
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_SSYEV computes all eigenvalues and, optionally, eigenvectors of a
  --  real symmetric matrix A.
  --
  --  Arguments
  --  =========
  --
  --  JOBZ    (input) FLAG
  --          = 'N':  Compute eigenvalues only;
  --          = 'V':  Compute eigenvalues and eigenvectors.
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The order of the matrix A.  N >= 0.
  --
  --  A       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDA, N)
  --          On entry, the symmetric matrix A.  If UPLO = 'U', the
  --          leading N-by-N upper triangular part of A contains the
  --          upper triangular part of the matrix A.  If UPLO = 'L',
  --          the leading N-by-N lower triangular part of A contains
  --          the lower triangular part of the matrix A.
  --          On exit, if JOBZ = 'V', then if INFO = 0, A contains the
  --          orthonormal eigenvectors of the matrix A.
  --          If JOBZ = 'N', then on exit the lower triangle (if UPLO='L')
  --          or the upper triangle (if UPLO='U') of A, including the
  --          diagonal, is destroyed.
  --
  --  LDA     (input) INTEGER
  --          The leading dimension of the array A.  LDA >= max(1,N).
  --
  --  W       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          If INFO = 0, the eigenvalues in ascending order.
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, the algorithm failed to converge; i
  --                off-diagonal elements of an intermediate tridiagonal
  --                form did not converge to zero.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE lapack_syev(jobz  IN     flag,     
                       uplo  IN     flag,
                       n     IN     POSITIVEN, 
                       a     IN OUT utl_nla_array_dbl,
                       lda   IN     POSITIVEN,
                       w     IN OUT utl_nla_array_dbl,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_syev(jobz  IN     flag,     
                       uplo  IN     flag,
                       n     IN     POSITIVEN, 
                       a     IN OUT UTL_NLA_ARRAY_FLT,
                       lda   IN     POSITIVEN,
                       w     IN OUT UTL_NLA_ARRAY_FLT,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_SYEVD computes all eigenvalues and, optionally, eigenvectors of a
  --  real symmetric matrix A. If eigenvectors are desired, it uses a
  --  divide and conquer algorithm.
  --
  --  The divide and conquer algorithm makes very mild assumptions about
  --  floating point arithmetic.
  --
  --  Arguments
  --  =========
  --
  --  JOBZ    (input) FLAG
  --          = 'N':  Compute eigenvalues only;
  --          = 'V':  Compute eigenvalues and eigenvectors.
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The order of the matrix A.  N >= 0.
  --
  --  A       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDA, N)
  --          On entry, the symmetric matrix A.  If UPLO = 'U', the
  --          leading N-by-N upper triangular part of A contains the
  --          upper triangular part of the matrix A.  If UPLO = 'L',
  --          the leading N-by-N lower triangular part of A contains
  --          the lower triangular part of the matrix A.
  --          On exit, if JOBZ = 'V', then if INFO = 0, A contains the
  --          orthonormal eigenvectors of the matrix A.
  --          If JOBZ = 'N', then on exit the lower triangle (if UPLO='L')
  --          or the upper triangle (if UPLO='U') of A, including the
  --          diagonal, is destroyed.
  --
  --  LDA     (input) INTEGER
  --          The leading dimension of the array A.  LDA >= max(1,N).
  --
  --  W       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          If INFO = 0, the eigenvalues in ascending order.
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, the algorithm failed to converge; i
  --                off-diagonal elements of an intermediate tridiagonal
  --                form did not converge to zero.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_syevd(jobz  IN     flag,     
                        uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        a     IN OUT utl_nla_array_dbl,
                        lda   IN     POSITIVEN,
                        w     IN OUT utl_nla_array_dbl,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_syevd(jobz  IN     flag,     
                        uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        a     IN OUT UTL_NLA_ARRAY_FLT,
                        lda   IN     POSITIVEN,
                        w     IN OUT UTL_NLA_ARRAY_FLT,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');  
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_SPEV computes all the eigenvalues and, optionally, eigenvectors of a
  --  real symmetric matrix A in packed storage.
  --
  --  Arguments
  --  =========
  --
  --  JOBZ    (input) FLAG
  --          = 'N':  Compute eigenvalues only;
  --          = 'V':  Compute eigenvalues and eigenvectors.
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The order of the matrix A.  N >= 0.
  --
  --  AP      (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N*(N+1)/2)
  --          On entry, the upper or lower triangle of the symmetric matrix
  --          A, packed columnwise in a linear array.  The j-th column of A
  --          is stored in the array AP as follows:
  --          if UPLO = 'U', AP(i + (j-1)*j/2) = A(i,j) for 1<=i<=j;
  --          if UPLO = 'L', AP(i + (j-1)*(2*n-j)/2) = A(i,j) for j<=i<=n.
  --
  --          On exit, AP is overwritten by values generated during the
  --          reduction to tridiagonal form.  If UPLO = 'U', the diagonal
  --          and first superdiagonal of the tridiagonal matrix T overwrite
  --          the corresponding elements of A, and if UPLO = 'L', the
  --          diagonal and first subdiagonal of T overwrite the
  --          corresponding elements of A.
  --
  --  W       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          If INFO = 0, the eigenvalues in ascending order.
  --
  --  Z       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDZ, N)
  --          If JOBZ = 'V', then if INFO = 0, Z contains the orthonormal
  --          eigenvectors of the matrix A, with the i-th column of Z
  --          holding the eigenvector associated with W(i).
  --          If JOBZ = 'N', then Z is not referenced.
  --
  --  LDZ     (input) INTEGER
  --          The leading dimension of the array Z.  LDZ >= 1, and if
  --          JOBZ = 'V', LDZ >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit.
  --          < 0:  if INFO = -i, the i-th argument had an illegal value.
  --          > 0:  if INFO = i, the algorithm failed to converge; i
  --                off-diagonal elements of an intermediate tridiagonal
  --                form did not converge to zero.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_spev(jobz  IN     flag,     
                        uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        ap    IN OUT utl_nla_array_dbl,
                        w     IN OUT utl_nla_array_dbl,
                        z     IN OUT utl_nla_array_dbl,
                        ldz   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_spev(jobz  IN     flag,     
                       uplo  IN     flag,
                       n     IN     POSITIVEN, 
                       ap    IN OUT UTL_NLA_ARRAY_FLT, 
                       w     IN OUT UTL_NLA_ARRAY_FLT, 
                       z     IN OUT UTL_NLA_ARRAY_FLT, 
                       ldz   IN     POSITIVEN,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');

  --  
  --  Purpose
  --  =======
  --
  --  LAPACK_SPEVD computes all the eigenvalues and, optionally, eigenvectors
  --  of a real symmetric matrix A in packed storage. If eigenvectors are
  --  desired, it uses a divide and conquer algorithm.
  --
  --  The divide and conquer algorithm makes very mild assumptions about
  --  floating point arithmetic. 
  --
  --  Arguments
  --  =========
  --
  --  JOBZ    (input) FLAG
  --          = 'N':  Compute eigenvalues only;
  --          = 'V':  Compute eigenvalues and eigenvectors.
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The order of the matrix A.  N >= 0.
  --
  --  AP      (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N*(N+1)/2)
  --          On entry, the upper or lower triangle of the symmetric matrix
  --          A, packed columnwise in a linear array.  The j-th column of A
  --          is stored in the array AP as follows:
  --          if UPLO = 'U', AP(i + (j-1)*j/2) = A(i,j) for 1<=i<=j;
  --          if UPLO = 'L', AP(i + (j-1)*(2*n-j)/2) = A(i,j) for j<=i<=n.
  --
  --          On exit, AP is overwritten by values generated during the
  --          reduction to tridiagonal form.  If UPLO = 'U', the diagonal
  --          and first superdiagonal of the tridiagonal matrix T overwrite
  --          the corresponding elements of A, and if UPLO = 'L', the
  --          diagonal and first subdiagonal of T overwrite the
  --          corresponding elements of A.
  --
  --  W       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          If INFO = 0, the eigenvalues in ascending order.
  --
  --  Z       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDZ, N)
  --          If JOBZ = 'V', then if INFO = 0, Z contains the orthonormal
  --          eigenvectors of the matrix A, with the i-th column of Z
  --          holding the eigenvector associated with W(i).
  --          If JOBZ = 'N', then Z is not referenced.
  --
  --  LDZ     (input) INTEGER
  --          The leading dimension of the array Z.  LDZ >= 1, and if
  --          JOBZ = 'V', LDZ >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value.
  --          > 0:  if INFO = i, the algorithm failed to converge; i
  --                off-diagonal elements of an intermediate tridiagonal
  --                form did not converge to zero.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_spevd(jobz  IN     flag,     
                        uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        ap    IN OUT utl_nla_array_dbl,
                        w     IN OUT utl_nla_array_dbl,
                        z     IN OUT utl_nla_array_dbl,
                        ldz   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_spevd(jobz  IN     flag,     
                        uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        ap    IN OUT UTL_NLA_ARRAY_FLT,
                        w     IN OUT UTL_NLA_ARRAY_FLT,
                        z     IN OUT UTL_NLA_ARRAY_FLT,
                        ldz   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  SSBEV computes all the eigenvalues and, optionally, eigenvectors of
  --  a real symmetric band matrix A.
  --
  --  Arguments
  --  =========
  --
  --  JOBZ    (input) FLAG
  --          = 'N':  Compute eigenvalues only;
  --          = 'V':  Compute eigenvalues and eigenvectors.
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The order of the matrix A.  N >= 0.
  --
  --  KD      (input) INTEGER
  --          The number of superdiagonals of the matrix A if UPLO = 'U',
  --          or the number of subdiagonals if UPLO = 'L'.  KD >= 0.
  --
  --  AB      (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDAB, N)
  --          On entry, the upper or lower triangle of the symmetric band
  --          matrix A, stored in the first KD+1 rows of the array.  The
  --          j-th column of A is stored in the j-th column of the array AB
  --          as follows:
  --          if UPLO = 'U', AB(kd+1+i-j,j) = A(i,j) for max(1,j-kd)<=i<=j;
  --          if UPLO = 'L', AB(1+i-j,j)    = A(i,j) for j<=i<=min(n,j+kd).
  --
  --          On exit, AB is overwritten by values generated during the
  --          reduction to tridiagonal form.  If UPLO = 'U', the first
  --          superdiagonal and the diagonal of the tridiagonal matrix T
  --          are returned in rows KD and KD+1 of AB, and if UPLO = 'L',
  --          the diagonal and first subdiagonal of T are returned in the
  --          first two rows of AB.
  --
  --  LDAB    (input) INTEGER
  --          The leading dimension of the array AB.  LDAB >= KD + 1.
  --
  --  W       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          If INFO = 0, the eigenvalues in ascending order.
  --
  --  Z       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDZ, N)
  --          If JOBZ = 'V', then if INFO = 0, Z contains the orthonormal
  --          eigenvectors of the matrix A, with the i-th column of Z
  --          holding the eigenvector associated with W(i).
  --          If JOBZ = 'N', then Z is not referenced.
  --
  --  LDZ     (input) INTEGER
  --          The leading dimension of the array Z.  LDZ >= 1, and if
  --          JOBZ = 'V', LDZ >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, the algorithm failed to converge; i
  --                off-diagonal elements of an intermediate tridiagonal
  --                form did not converge to zero.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE lapack_sbev(jobz  IN     flag,     
                       uplo  IN     flag,
                       n     IN     POSITIVEN, 
                       kd    IN     NATURALN, 
                       ab    IN OUT utl_nla_array_dbl,
                       ldab  IN     POSITIVEN,
                       w     IN OUT utl_nla_array_dbl,
                       z     IN OUT utl_nla_array_dbl,
                       ldz   IN     POSITIVEN,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_sbev(jobz  IN     flag,     
                       uplo  IN     flag,
                       n     IN     POSITIVEN, 
                       kd    IN     NATURALN, 
                       ab    IN OUT UTL_NLA_ARRAY_FLT,
                       ldab  IN     POSITIVEN,
                       w     IN OUT UTL_NLA_ARRAY_FLT,
                       z     IN OUT UTL_NLA_ARRAY_FLT, 
                       ldz   IN     POSITIVEN,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_SBEVD computes all the eigenvalues and, optionally, eigenvectors of
  --  a real symmetric band matrix A. If eigenvectors are desired, it uses
  --  a divide and conquer algorithm.
  --
  --  The divide and conquer algorithm makes very mild assumptions about
  --  floating point arithmetic. 
  --
  --  Arguments
  --  =========
  --
  --  JOBZ    (input) FLAG
  --          = 'N':  Compute eigenvalues only;
  --          = 'V':  Compute eigenvalues and eigenvectors.
  --
  --  UPLO    (input) FLAG
  --          = 'U':  Upper triangle of A is stored;
  --          = 'L':  Lower triangle of A is stored.
  --
  --  N       (input) INTEGER
  --          The order of the matrix A.  N >= 0.
  --
  --  KD      (input) INTEGER
  --          The number of superdiagonals of the matrix A if UPLO = 'U',
  --          or the number of subdiagonals if UPLO = 'L'.  KD >= 0.
  --
  --  AB      (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDAB, N)
  --          On entry, the upper or lower triangle of the symmetric band
  --          matrix A, stored in the first KD+1 rows of the array.  The
  --          j-th column of A is stored in the j-th column of the array AB
  --          as follows:
  --          if UPLO = 'U', AB(kd+1+i-j,j) = A(i,j) for max(1,j-kd)<=i<=j;
  --          if UPLO = 'L', AB(1+i-j,j)    = A(i,j) for j<=i<=min(n,j+kd).
  --
  --          On exit, AB is overwritten by values generated during the
  --          reduction to tridiagonal form.  If UPLO = 'U', the first
  --          superdiagonal and the diagonal of the tridiagonal matrix T
  --          are returned in rows KD and KD+1 of AB, and if UPLO = 'L',
  --          the diagonal and first subdiagonal of T are returned in the
  --          first two rows of AB.
  --
  --  LDAB    (input) INTEGER
  --          The leading dimension of the array AB.  LDAB >= KD + 1.
  --
  --  W       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          If INFO = 0, the eigenvalues in ascending order.
  --
  --  Z       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDZ, N)
  --          If JOBZ = 'V', then if INFO = 0, Z contains the orthonormal
  --          eigenvectors of the matrix A, with the i-th column of Z
  --          holding the eigenvector associated with W(i).
  --          If JOBZ = 'N', then Z is not referenced.
  --
  --  LDZ     (input) INTEGER
  --          The leading dimension of the array Z.  LDZ >= 1, and if
  --          JOBZ = 'V', LDZ >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, the algorithm failed to converge; i
  --                off-diagonal elements of an intermediate tridiagonal
  --                form did not converge to zero.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE lapack_sbevd(jobz  IN     flag,     
                        uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        kd    IN     NATURALN,
                        ab    IN OUT utl_nla_array_dbl,
                        ldab  IN     POSITIVEN,
                        w     IN OUT utl_nla_array_dbl,
                        z     IN OUT utl_nla_array_dbl,
                        ldz   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_sbevd(jobz  IN     flag,     
                        uplo  IN     flag,
                        n     IN     POSITIVEN, 
                        kd    IN     NATURALN,  
                        ab    IN OUT UTL_NLA_ARRAY_FLT,
                        ldab  IN     POSITIVEN,
                        w     IN OUT UTL_NLA_ARRAY_FLT,
                        z     IN OUT UTL_NLA_ARRAY_FLT, 
                        ldz   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');

  --
  --  Purpose
  --  =======
  --
  --  LAPACK_STEV computes all eigenvalues and, optionally, eigenvectors of a
  --  real symmetric tridiagonal matrix A.
  --
  --  Arguments
  --  =========
  --
  --  JOBZ    (input) FLAG
  --          = 'N':  Compute eigenvalues only;
  --          = 'V':  Compute eigenvalues and eigenvectors.
  --
  --  N       (input) INTEGER
  --          The order of the matrix.  N >= 0.
  --
  --  D       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          On entry, the n diagonal elements of the tridiagonal matrix
  --          A.
  --          On exit, if INFO = 0, the eigenvalues in ascending order.
  --
  --  E       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          On entry, the (n-1) subdiagonal elements of the tridiagonal
  --          matrix A, stored in elements 1 to N-1 of E; E(N) need not
  --          be set, but is used by the routine.
  --          On exit, the contents of E are destroyed.
  --
  --  Z       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDZ, N)
  --          If JOBZ = 'V', then if INFO = 0, Z contains the orthonormal
  --          eigenvectors of the matrix A, with the i-th column of Z
  --          holding the eigenvector associated with D(i).
  --          If JOBZ = 'N', then Z is not referenced.
  --
  --  LDZ     (input) INTEGER
  --          The leading dimension of the array Z.  LDZ >= 1, and if
  --          JOBZ = 'V', LDZ >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, the algorithm failed to converge; i
  --                off-diagonal elements of E did not converge to zero.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_stev(jobz  IN     flag,     
                       n     IN     POSITIVEN, 
                       d     IN OUT utl_nla_array_dbl,
                       e     IN OUT utl_nla_array_dbl,
                       z     IN OUT utl_nla_array_dbl,
                       ldz   IN     POSITIVEN,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_stev(jobz  IN     flag,     
                       n     IN     POSITIVEN, 
                       d     IN OUT UTL_NLA_ARRAY_FLT,
                       e     IN OUT UTL_NLA_ARRAY_FLT,
                       z     IN OUT UTL_NLA_ARRAY_FLT,
                       ldz   IN     POSITIVEN,
                       info  OUT    integer,
                       pack  IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_STEVD computes all eigenvalues and, optionally, eigenvectors of a
  --  real symmetric tridiagonal matrix. If eigenvectors are desired, it
  --  uses a divide and conquer algorithm.
  --
  --  The divide and conquer algorithm makes very mild assumptions about
  --  floating point arithmetic. 
  --
  --  Arguments
  --  =========
  --
  --  JOBZ    (input) FLAG
  --          = 'N':  Compute eigenvalues only;
  --          = 'V':  Compute eigenvalues and eigenvectors.
  --
  --  N       (input) INTEGER
  --          The order of the matrix.  N >= 0.
  --
  --  D       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          On entry, the n diagonal elements of the tridiagonal matrix
  --          A.
  --          On exit, if INFO = 0, the eigenvalues in ascending order.
  --
  --  E       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          On entry, the (n-1) subdiagonal elements of the tridiagonal
  --          matrix A, stored in elements 1 to N-1 of E; E(N) need not
  --          be set, but is used by the routine.
  --          On exit, the contents of E are destroyed.
  --
  --  Z       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDZ, N)
  --          If JOBZ = 'V', then if INFO = 0, Z contains the orthonormal
  --          eigenvectors of the matrix A, with the i-th column of Z
  --          holding the eigenvector associated with D(i).
  --          If JOBZ = 'N', then Z is not referenced.
  --
  --  LDZ     (input) INTEGER
  --          The leading dimension of the array Z.  LDZ >= 1, and if
  --          JOBZ = 'V', LDZ >= max(1,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value
  --          > 0:  if INFO = i, the algorithm failed to converge; i
  --                off-diagonal elements of E did not converge to zero.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 

  PROCEDURE lapack_stevd(jobz  IN     flag,     
                        n     IN     POSITIVEN, 
                        d     IN OUT utl_nla_array_dbl,
                        e     IN OUT utl_nla_array_dbl,
                        z     IN OUT utl_nla_array_dbl,
                        ldz   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN    flag DEFAULT 'C');
  
  PROCEDURE lapack_stevd(jobz  IN     flag,     
                        n     IN     POSITIVEN, 
                        d     IN OUT UTL_NLA_ARRAY_FLT,
                        e     IN OUT UTL_NLA_ARRAY_FLT,
                        z     IN OUT UTL_NLA_ARRAY_FLT,
                        ldz   IN     POSITIVEN,
                        info  OUT    integer,
                        pack  IN     flag DEFAULT 'C');
  
  -- [> Nonsymmetric Eigenproblems <]
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_GEES computes for an N-by-N real nonsymmetric matrix A, the
  --  eigenvalues, the real Schur form T, and, optionally, the matrix of
  --  Schur vectors Z.  This gives the Schur factorization A = Z*T*(Z**T).
  --
  --  A matrix is in real Schur form if it is upper quasi-triangular with
  --  1-by-1 and 2-by-2 blocks. 2-by-2 blocks will be standardized in the
  --  form
  --          [  a  b  ]
  --          [  c  a  ]
  --
  --  where b*c < 0. The eigenvalues of such a block are a +- sqrt(bc).
  --
  --  Arguments
  --  =========
  --
  --  JOBVS   (input) FLAG
  --          = 'N': Schur vectors are not computed;
  --          = 'V': Schur vectors are computed.
  --
  --  N       (input) INTEGER
  --          The order of the matrix A. N >= 0.
  --
  --  A       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDA,N)
  --          On entry, the N-by-N matrix A.
  --          On exit, A has been overwritten by its real Schur form T.
  --
  --  LDA     (input) INTEGER
  --          The leading dimension of the array A.  LDA >= max(1,N).
  --
  --  WR      (output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --  WI      (output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          WR and WI contain the real and imaginary parts,
  --          respectively, of the computed eigenvalues in the same order
  --          that they appear on the diagonal of the output Schur form T.
  --          Complex conjugate pairs of eigenvalues will appear
  --          consecutively with the eigenvalue having the positive
  --          imaginary part first.
  --
  --  VS      (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDVS,N)
  --          If JOBVS = 'V', VS contains the orthogonal matrix Z of Schur
  --          vectors.
  --          If JOBVS = 'N', VS is not referenced.
  --
  --  LDVS    (input) INTEGER
  --          The leading dimension of the array VS.  LDVS >= 1; if
  --          JOBVS = 'V', LDVS >= N.
  --
  --  INFO    (output) INTEGER
  --          = 0: successful exit
  --          < 0: if INFO = -i, the i-th argument had an illegal value.
  --          > 0: if INFO = i, and i is
  --             <= N: the QR algorithm failed to compute all the
  --                   eigenvalues; elements 1:ILO-1 and i+1:N of WR and WI
  --                   contain those eigenvalues which have converged; if
  --                   JOBVS = 'V', VS contains the matrix which reduces A
  --                   to its partially converged Schur form.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_gees(jobvs  IN     flag,     
                       n      IN     POSITIVEN, 
                       a      IN OUT utl_nla_array_dbl,
                       lda    IN     POSITIVEN,
                       wr     IN OUT utl_nla_array_dbl,
                       wi     IN OUT utl_nla_array_dbl,
                       vs     IN OUT utl_nla_array_dbl,
                       ldvs   IN     POSITIVEN,
                       info   OUT    integer,
                       pack   IN     flag DEFAULT 'C');
   
  PROCEDURE lapack_gees(jobvs  IN     flag,     
                       n      IN     POSITIVEN, 
                       a      IN OUT UTL_NLA_ARRAY_FLT,
                       lda    IN     POSITIVEN,
                       wr     IN OUT UTL_NLA_ARRAY_FLT,
                       wi     IN OUT UTL_NLA_ARRAY_FLT,
                       vs     IN OUT UTL_NLA_ARRAY_FLT,
                       ldvs   IN     POSITIVEN,
                       info   OUT    integer,
                       pack   IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_GEEV computes for an N-by-N real nonsymmetric matrix A, the
  --  eigenvalues and, optionally, the left and/or right eigenvectors.
  --
  --  The right eigenvector v(j) of A satisfies
  --                   A * v(j) = lambda(j) * v(j)
  --  where lambda(j) is its eigenvalue.
  --  The left eigenvector u(j) of A satisfies
  --                u(j)**H * A = lambda(j) * u(j)**H
  --  where u(j)**H denotes the conjugate transpose of u(j).
  --
  --  The computed eigenvectors are normalized to have Euclidean norm
  --  equal to 1 and largest component real.
  --
  --  Arguments
  --  =========
  --
  --  JOBVL   (input) FLAG
  --          = 'N': left eigenvectors of A are not computed;
  --          = 'V': left eigenvectors of A are computed.
  --
  --  JOBVR   (input) FLAG
  --          = 'N': right eigenvectors of A are not computed;
  --          = 'V': right eigenvectors of A are computed.
  --
  --  N       (input) INTEGER
  --          The order of the matrix A. N >= 0.
  --
  --  A       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDA,N)
  --          On entry, the N-by-N matrix A.
  --          On exit, A has been overwritten.
  --
  --  LDA     (input) INTEGER
  --          The leading dimension of the array A.  LDA >= max(1,N).
  --
  --  WR      (output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --  WI      (output) UTL_NLA_ARRAY_FLT/DBL, dimension (N)
  --          WR and WI contain the real and imaginary parts,
  --          respectively, of the computed eigenvalues.  Complex
  --          conjugate pairs of eigenvalues appear consecutively
  --          with the eigenvalue having the positive imaginary part
  --          first.
  --
  --  VL      (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDVL,N)
  --          If JOBVL = 'V', the left eigenvectors u(j) are stored one
  --          after another in the columns of VL, in the same order
  --          as their eigenvalues.
  --          If JOBVL = 'N', VL is not referenced.
  --          If the j-th eigenvalue is real, then u(j) = VL(:,j),
  --          the j-th column of VL.
  --          If the j-th and (j+1)-st eigenvalues form a complex
  --          conjugate pair, then u(j) = VL(:,j) + i*VL(:,j+1) and
  --          u(j+1) = VL(:,j) - i*VL(:,j+1).
  --
  --  LDVL    (input) INTEGER
  --          The leading dimension of the array VL.  LDVL >= 1; if
  --          JOBVL = 'V', LDVL >= N.
  --
  --  VR      (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDVR,N)
  --          If JOBVR = 'V', the right eigenvectors v(j) are stored one
  --          after another in the columns of VR, in the same order
  --          as their eigenvalues.
  --          If JOBVR = 'N', VR is not referenced.
  --          If the j-th eigenvalue is real, then v(j) = VR(:,j),
  --          the j-th column of VR.
  --          If the j-th and (j+1)-st eigenvalues form a complex
  --          conjugate pair, then v(j) = VR(:,j) + i*VR(:,j+1) and
  --          v(j+1) = VR(:,j) - i*VR(:,j+1).
  --
  --  LDVR    (input) INTEGER
  --          The leading dimension of the array VR.  LDVR >= 1; if
  --          JOBVR = 'V', LDVR >= N.
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit
  --          < 0:  if INFO = -i, the i-th argument had an illegal value.
  --          > 0:  if INFO = i, the QR algorithm failed to compute all the
  --                eigenvalues, and no eigenvectors have been computed;
  --                elements i+1:N of WR and WI contain eigenvalues which
  --                have converged.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_geev(jobvl  IN     flag,     
                       jobvr  IN     flag,     
                       n      IN     POSITIVEN, 
                       a      IN OUT utl_nla_array_dbl,
                       lda    IN     POSITIVEN,
                       wr     IN OUT utl_nla_array_dbl,
                       wi     IN OUT utl_nla_array_dbl,
                       vl     IN OUT utl_nla_array_dbl,
                       ldvl   IN     POSITIVEN,
                       vr     IN OUT utl_nla_array_dbl,
                       ldvr   IN     POSITIVEN,
                       info   OUT    integer,
                       pack   IN     flag DEFAULT 'C');
   
  PROCEDURE lapack_geev(jobvl  IN     flag,     
                       jobvr  IN     flag,     
                       n      IN     POSITIVEN, 
                       a      IN OUT UTL_NLA_ARRAY_FLT,
                       lda    IN     POSITIVEN,
                       wr     IN OUT UTL_NLA_ARRAY_FLT,
                       wi     IN OUT UTL_NLA_ARRAY_FLT,
                       vl     IN OUT UTL_NLA_ARRAY_FLT,
                       ldvl   IN     POSITIVEN,
                       vr     IN OUT UTL_NLA_ARRAY_FLT,
                       ldvr   IN     POSITIVEN,
                       info   OUT    INTEGER,
                       pack   IN     flag DEFAULT 'C');
   
  -- [> Singular Value Decomposition <]
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_GESVD computes the singular value decomposition (SVD) of a real
  --  M-by-N matrix A, optionally computing the left and/or right singular
  --  vectors. The SVD is written
  --
  --       A = U * SIGMA * transpose(V)
  --
  --  where SIGMA is an M-by-N matrix which is zero except for its
  --  min(m,n) diagonal elements, U is an M-by-M orthogonal matrix, and
  --  V is an N-by-N orthogonal matrix.  The diagonal elements of SIGMA
  --  are the singular values of A; they are real and non-negative, and
  --  are returned in descending order.  The first min(m,n) columns of
  --  U and V are the left and right singular vectors of A.
  --
  --  Note that the routine returns V**T, not V.
  --
  --  Arguments
  --  =========
  --
  --  JOBU    (input) FLAG
  --          Specifies options for computing all or part of the matrix U:
  --          = 'A':  all M columns of U are returned in array U:
  --          = 'S':  the first min(m,n) columns of U (the left singular
  --                  vectors) are returned in the array U;
  --          = 'O':  the first min(m,n) columns of U (the left singular
  --                  vectors) are overwritten on the array A;
  --          = 'N':  no columns of U (no left singular vectors) are
  --                  computed.
  --
  --  JOBVT   (input) FLAG
  --          Specifies options for computing all or part of the matrix
  --          V**T:
  --          = 'A':  all N rows of V**T are returned in the array VT;
  --          = 'S':  the first min(m,n) rows of V**T (the right singular
  --                  vectors) are returned in the array VT;
  --          = 'O':  the first min(m,n) rows of V**T (the right singular
  --                  vectors) are overwritten on the array A;
  --          = 'N':  no rows of V**T (no right singular vectors) are
  --                  computed.
  --
  --          JOBVT and JOBU cannot both be 'O'.
  --
  --  M       (input) INTEGER
  --          The number of rows of the input matrix A.  M >= 0.
  --
  --  N       (input) INTEGER
  --          The number of columns of the input matrix A.  N >= 0.
  --
  --  A       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDA,N)
  --          On entry, the M-by-N matrix A.
  --          On exit,
  --          if JOBU = 'O',  A is overwritten with the first min(m,n)
  --                          columns of U (the left singular vectors,
  --                          stored columnwise);
  --          if JOBVT = 'O', A is overwritten with the first min(m,n)
  --                          rows of V**T (the right singular vectors,
  --                          stored rowwise);
  --          if JOBU .ne. 'O' and JOBVT .ne. 'O', the contents of A
  --                          are destroyed.
  --
  --  LDA     (input) INTEGER
  --          The leading dimension of the array A.  LDA >= max(1,M).
  --
  --  S       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (min(M,N))
  --          The singular values of A, sorted so that S(i) >= S(i+1).
  --
  --  U       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDU,UCOL)
  --          (LDU,M) if JOBU = 'A' or (LDU,min(M,N)) if JOBU = 'S'.
  --          If JOBU = 'A', U contains the M-by-M orthogonal matrix U;
  --          if JOBU = 'S', U contains the first min(m,n) columns of U
  --          (the left singular vectors, stored columnwise);
  --          if JOBU = 'N' or 'O', U is not referenced.
  --
  --  LDU     (input) INTEGER
  --          The leading dimension of the array U.  LDU >= 1; if
  --          JOBU = 'S' or 'A', LDU >= M.
  --
  --  VT      (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDVT,N)
  --          If JOBVT = 'A', VT contains the N-by-N orthogonal matrix
  --          V**T;
  --          if JOBVT = 'S', VT contains the first min(m,n) rows of
  --          V**T (the right singular vectors, stored rowwise);
  --          if JOBVT = 'N' or 'O', VT is not referenced.
  --
  --  LDVT    (input) INTEGER
  --          The leading dimension of the array VT.  LDVT >= 1; if
  --          JOBVT = 'A', LDVT >= N; if JOBVT = 'S', LDVT >= min(M,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit.
  --          < 0:  if INFO = -i, the i-th argument had an illegal value.
  --          > 0:  if SBDSQR did not converge, INFO specifies how many
  --                superdiagonals of an intermediate bidiagonal form B
  --                did not converge to zero. See the description of WORK
  --                above for details.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_gesvd(jobu   IN     flag,     
                        jobvt  IN     flag,     
                        m      IN     POSITIVEN, 
                        n      IN     POSITIVEN, 
                        a      IN OUT utl_nla_array_dbl,
                        lda    IN     POSITIVEN,
                        s      IN OUT utl_nla_array_dbl,
                        u      IN OUT utl_nla_array_dbl,
                        ldu    IN     POSITIVEN,
                        vt     IN OUT utl_nla_array_dbl,
                        ldvt   IN     POSITIVEN,
                        info   OUT    integer,
                        pack   IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_gesvd(jobu   IN     flag,     
                        jobvt  IN     flag,     
                        m      IN     POSITIVEN, 
                        n      IN     POSITIVEN, 
                        a      IN OUT UTL_NLA_ARRAY_FLT,
                        lda    IN     POSITIVEN,
                        s      IN OUT UTL_NLA_ARRAY_FLT,
                        u      IN OUT UTL_NLA_ARRAY_FLT,
                        ldu    IN     POSITIVEN,
                        vt     IN OUT UTL_NLA_ARRAY_FLT,
                        ldvt   IN     POSITIVEN,
                        info   OUT    integer,
                        pack   IN     flag DEFAULT 'C');
  
  --
  --  Purpose
  --  =======
  --
  --  LAPACK_GESDD computes the singular value decomposition (SVD) of a real
  --  M-by-N matrix A, optionally computing the left and right singular
  --  vectors.  If singular vectors are desired, it uses a
  --  divide-and-conquer algorithm.
  --
  --  The SVD is written
  --
  --       A = U * SIGMA * transpose(V)
  --
  --  where SIGMA is an M-by-N matrix which is zero except for its
  --  min(m,n) diagonal elements, U is an M-by-M orthogonal matrix, and
  --  V is an N-by-N orthogonal matrix.  The diagonal elements of SIGMA
  --  are the singular values of A; they are real and non-negative, and
  --  are returned in descending order.  The first min(m,n) columns of
  --  U and V are the left and right singular vectors of A.
  --
  --  Note that the routine returns VT = V**T, not V.
  --
  --  The divide and conquer algorithm makes very mild assumptions about
  --  floating point arithmetic.
  --
  --  Arguments
  --  =========
  --
  --  JOBZ    (input) FLAG
  --          Specifies options for computing all or part of the matrix U:
  --          = 'A':  all M columns of U and all N rows of V**T are
  --                  returned in the arrays U and VT;
  --          = 'S':  the first min(M,N) columns of U and the first
  --                  min(M,N) rows of V**T are returned in the arrays U
  --                  and VT;
  --          = 'O':  If M >= N, the first N columns of U are overwritten
  --                  on the array A and all rows of V**T are returned in
  --                  the array VT;
  --                  otherwise, all columns of U are returned in the
  --                  array U and the first M rows of V**T are overwritten
  --                  in the array VT;
  --          = 'N':  no columns of U or rows of V**T are computed.
  --
  --  M       (input) INTEGER
  --          The number of rows of the input matrix A.  M >= 0.
  --
  --  N       (input) INTEGER
  --          The number of columns of the input matrix A.  N >= 0.
  --
  --  A       (input/output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDA,N)
  --          On entry, the M-by-N matrix A.
  --          On exit,
  --          if JOBZ = 'O',  A is overwritten with the first N columns
  --                          of U (the left singular vectors, stored
  --                          columnwise) if M >= N;
  --                          A is overwritten with the first M rows
  --                          of V**T (the right singular vectors, stored
  --                          rowwise) otherwise.
  --          if JOBZ .ne. 'O', the contents of A are destroyed.
  --
  --  LDA     (input) INTEGER
  --          The leading dimension of the array A.  LDA >= max(1,M).
  --
  --  S       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (min(M,N))
  --          The singular values of A, sorted so that S(i) >= S(i+1).
  --
  --  U       (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDU,UCOL)
  --          UCOL = M if JOBZ = 'A' or JOBZ = 'O' and M < N;
  --          UCOL = min(M,N) if JOBZ = 'S'.
  --          If JOBZ = 'A' or JOBZ = 'O' and M < N, U contains the M-by-M
  --          orthogonal matrix U;
  --          if JOBZ = 'S', U contains the first min(M,N) columns of U
  --          (the left singular vectors, stored columnwise);
  --          if JOBZ = 'O' and M >= N, or JOBZ = 'N', U is not referenced.
  --
  --  LDU     (input) INTEGER
  --          The leading dimension of the array U.  LDU >= 1; if
  --          JOBZ = 'S' or 'A' or JOBZ = 'O' and M < N, LDU >= M.
  --
  --  VT      (output) UTL_NLA_ARRAY_FLT/DBL, dimension (LDVT,N)
  --          If JOBZ = 'A' or JOBZ = 'O' and M >= N, VT contains the
  --          N-by-N orthogonal matrix V**T;
  --          if JOBZ = 'S', VT contains the first min(M,N) rows of
  --          V**T (the right singular vectors, stored rowwise);
  --          if JOBZ = 'O' and M < N, or JOBZ = 'N', VT is not referenced.
  --
  --  LDVT    (input) INTEGER
  --          The leading dimension of the array VT.  LDVT >= 1; if
  --          JOBZ = 'A' or JOBZ = 'O' and M >= N, LDVT >= N;
  --          if JOBZ = 'S', LDVT >= min(M,N).
  --
  --  INFO    (output) INTEGER
  --          = 0:  successful exit.
  --          < 0:  if INFO = -i, the i-th argument had an illegal value.
  --          > 0:  SBDSDC did not converge, updating process failed.
  --
  --  PACK     (optional) FLAG
  --          The packing of the matricies:
  --            'C': column-major (default)
  --            'R': row-major 
  
  PROCEDURE lapack_gesdd(jobz   IN     flag,     
                        m      IN     POSITIVEN, 
                        n      IN     POSITIVEN, 
                        a      IN OUT utl_nla_array_dbl,
                        lda    IN     POSITIVEN,
                        s      IN OUT utl_nla_array_dbl,
                        u      IN OUT utl_nla_array_dbl,
                        ldu    IN     POSITIVEN,
                        vt     IN OUT utl_nla_array_dbl,
                        ldvt   IN     POSITIVEN,
                        info   OUT    INTEGER,
                        pack   IN     flag DEFAULT 'C');
  
  PROCEDURE lapack_gesdd(jobz   IN     flag,     
                        m      IN     POSITIVEN, 
                        n      IN     POSITIVEN, 
                        a      IN OUT UTL_NLA_ARRAY_FLT,
                        lda    IN     POSITIVEN,
                        s      IN OUT UTL_NLA_ARRAY_FLT,
                        u      IN OUT UTL_NLA_ARRAY_FLT,
                        ldu    IN     POSITIVEN,
                        vt     IN OUT UTL_NLA_ARRAY_FLT,
                        ldvt   IN     POSITIVEN,
                        info   OUT    INTEGER,
                        pack   IN     flag DEFAULT 'C');  
END UTL_NLA;
/
show errors;

create or replace public synonym UTL_NLA_ARRAY_DBL for SYS.UTL_NLA_ARRAY_DBL;
grant execute on UTL_NLA_ARRAY_DBL to public;

create or replace public synonym UTL_NLA_ARRAY_FLT for SYS.UTL_NLA_ARRAY_FLT;
grant execute on UTL_NLA_ARRAY_FLT to public;

create or replace public synonym UTL_NLA_ARRAY_INT for SYS.UTL_NLA_ARRAY_INT;
grant execute on UTL_NLA_ARRAY_INT to public;

create or replace public synonym UTL_NLA for SYS.UTL_NLA;
grant execute on UTL_NLA to public;
