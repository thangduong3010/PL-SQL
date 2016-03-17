REM $Id: book_barcodes_t.typ,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 306

REM Create a collection that can hold barcode ids

CREATE TYPE book_barcodes_t AS TABLE OF VARCHAR2(100);
/

