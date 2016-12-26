Rem
Rem $Header: dbmsobtk.sql 22-apr-2005.14:01:49 dmwong Exp $
Rem
Rem dbmsobtk.sql
Rem
Rem Copyright (c) 1997, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsobtk.sql - rDBMS OBfuscation ToolKit
Rem
Rem    DESCRIPTION
Rem      Contains the PL/SQL interface to the obfuscation toolkit
Rem
Rem    NOTES
Rem      None.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsamuel     04/22/05 - Change DBMS_SQLHASH to invokers rights 
Rem    mxu         04/05/05 - Add dbms_sqlhash package 
Rem    pyoun       03/10/05 - add deterministic to hash 
Rem    nmanappa    02/23/04 - Bug 3452620 - POSITIVE to PLS_INTEGER arg type 
Rem                           for Random 
Rem    dmwong      12/25/03 - add CRYPTO_TOOLKIT_LIBRARY
Rem    mhho        12/24/03 - add dbms_crypto package 
Rem    mjaeger     08/19/03 - bug 2846316: add PRAGMA RESTRICT_REFERENCES
Rem    nireland    05/27/02 - Add IV support
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    htseng      04/12/01 - eliminate execute twice (remove ;).
Rem    rwessman    07/30/00 - Added routines to generate keys
Rem    rwessman    03/30/00 - Added Triple DES support
Rem    rwessman    01/13/00 - Changed to use a subtype for MD5 checksums to mak
Rem    rwessman    12/16/99 - Added function versions of the various routines
Rem    rwessman    12/15/99 - Added a VARCHAR2 version of the MD5 routines
Rem    rwessman    12/03/99 - Added MD5 procedure
Rem    sgkrishn    03/01/99 - added DES related routines
Rem    sgkrishn    02/25/99 - Creation
Rem
REM  ***************************************
REM  THIS PACKAGE MUST BE CREATED UNDER SYS
REM  ***************************************

-- Create the trusted PL/SQL callout library.
CREATE OR REPLACE LIBRARY DBMS_OBFUSCATION_LIB TRUSTED AS STATIC;
/
show errors;

CREATE OR REPLACE LIBRARY CRYPTO_TOOLKIT_LIBRARY TRUSTED AS STATIC;
/
show errors;

CREATE OR REPLACE PACKAGE DBMS_CRYPTO AS

    ---------------------------------------------------------------------------
    --
    -- PACKAGE NOTES
    --
    -- DBMS_CRYPTO contains basic cryptographic functions and
    -- procedures.  To use correctly and securely, a general level of
    -- security expertise is assumed.
    --
    -- VARCHAR2 datatype is not supported.  Cryptographic operations
    -- on this type should be prefaced with conversions to a uniform
    -- character set (AL32UTF8) and conversion to RAW type.
    --
    -- Prior to encryption, hashing or keyed hashing, CLOB datatype is
    -- converted to AL32UTF8.  This allows cryptographic data to be
    -- transferred and understood between databases with different
    -- character sets, across character set changes and between
    -- separate processes (for example, Java programs).
    --
    ---------------------------------------------------------------------------


    -------------------------- ALGORITHM CONSTANTS ----------------------------
    -- The following constants refer to various types of cryptographic
    -- functions available from this package.  Some of the constants
    -- represent modifiers to these algorithms.
    ---------------------------------------------------------------------------

    -- Hash Functions
    HASH_MD4           CONSTANT PLS_INTEGER            :=     1;
    HASH_MD5           CONSTANT PLS_INTEGER            :=     2;
    HASH_SH1           CONSTANT PLS_INTEGER            :=     3;

    -- MAC Functions
    HMAC_MD5           CONSTANT PLS_INTEGER            :=     1;
    HMAC_SH1           CONSTANT PLS_INTEGER            :=     2;

    -- Block Cipher Algorithms
    ENCRYPT_DES        CONSTANT PLS_INTEGER            :=     1;  -- 0x0001
    ENCRYPT_3DES_2KEY  CONSTANT PLS_INTEGER            :=     2;  -- 0x0002
    ENCRYPT_3DES       CONSTANT PLS_INTEGER            :=     3;  -- 0x0003
    ENCRYPT_AES        CONSTANT PLS_INTEGER            :=     4;  -- 0x0004
    ENCRYPT_PBE_MD5DES CONSTANT PLS_INTEGER            :=     5;  -- 0x0005
    ENCRYPT_AES128     CONSTANT PLS_INTEGER            :=     6;  -- 0x0006
    ENCRYPT_AES192     CONSTANT PLS_INTEGER            :=     7;  -- 0x0007
    ENCRYPT_AES256     CONSTANT PLS_INTEGER            :=     8;  -- 0x0008

    -- Block Cipher Chaining Modifiers
    CHAIN_CBC          CONSTANT PLS_INTEGER            :=   256;  -- 0x0100
    CHAIN_CFB          CONSTANT PLS_INTEGER            :=   512;  -- 0x0200
    CHAIN_ECB          CONSTANT PLS_INTEGER            :=   768;  -- 0x0300
    CHAIN_OFB          CONSTANT PLS_INTEGER            :=  1024;  -- 0x0400

    -- Block Cipher Padding Modifiers
    PAD_PKCS5          CONSTANT PLS_INTEGER            :=  4096;  -- 0x1000
    PAD_NONE           CONSTANT PLS_INTEGER            :=  8192;  -- 0x2000
    PAD_ZERO           CONSTANT PLS_INTEGER            := 12288;  -- 0x3000
    PAD_ORCL           CONSTANT PLS_INTEGER            := 16384;  -- 0x4000

    -- Stream Cipher Algorithms
    ENCRYPT_RC4        CONSTANT PLS_INTEGER            :=   129;  -- 0x0081


    -- Convenience Constants for Block Ciphers
    DES_CBC_PKCS5      CONSTANT PLS_INTEGER            := ENCRYPT_DES
                                                          + CHAIN_CBC
                                                          + PAD_PKCS5;

    DES3_CBC_PKCS5     CONSTANT PLS_INTEGER            := ENCRYPT_3DES
                                                          + CHAIN_CBC
                                                          + PAD_PKCS5;

    AES_CBC_PKCS5      CONSTANT PLS_INTEGER            := ENCRYPT_AES
                                                          + CHAIN_CBC
                                                          + PAD_PKCS5;
    

    ----------------------------- EXCEPTIONS ----------------------------------
    -- Invalid Cipher Suite
    CipherSuiteInvalid EXCEPTION;
    PRAGMA EXCEPTION_INIT(CipherSuiteInvalid, -28827);

    -- Null Cipher Suite
    CipherSuiteNull EXCEPTION;
    PRAGMA EXCEPTION_INIT(CipherSuiteNull,    -28829);

    -- Key Null
    KeyNull EXCEPTION;
    PRAGMA EXCEPTION_INIT(KeyNull,            -28239);

    -- Key Bad Size
    KeyBadSize EXCEPTION;
    PRAGMA EXCEPTION_INIT(KeyBadSize,         -28234);

    -- Double Encryption
    DoubleEncryption EXCEPTION;
    PRAGMA EXCEPTION_INIT(DoubleEncryption,   -28233);


    ---------------------- FUNCTIONS AND PROCEDURES ------------------------

    ------------------------------------------------------------------------
    --
    -- NAME:  Encrypt
    --
    -- DESCRIPTION:
    --
    --   Encrypt plain text data using stream or block cipher with user
    --   supplied key and optional iv.
    --
    -- PARAMETERS
    --
    --   plaintext   - Plaintext data to be encrypted
    --   crypto_type - Stream or block cipher type plus modifiers
    --   key         - Key to be used for encryption
    --   iv          - Optional IV for block ciphers.  Default all zeros.
    --
    -- USAGE NOTES:
    --
    --   Block ciphers may be modified with chaining type (CBC most
    --   common) and padding type (PKCS5 recommended).  Of the four
    --   common data formats, three have been provided: RAW, BLOB,
    --   CLOB. For VARCHAR2 encryption, callers should first convert
    --   to AL32UTF8 character set and then encrypt.
    --   
    --     Encrypt(UTL_RAW.CAST_TO_RAW(CONVERT(src,'AL32UTF8')),typ,key);
    --
    --   As return type for encrypt is RAW, callers should consider
    --   encoding it with RAWTOHEX or UTL_ENCODE.BASE64_ENCODE to make
    --   it suitable for VARCHAR2 storage.  These functions expand
    --   data size by 2 and 4/3, respectively.
    -- 
    --   To improve readability, callers should define their own
    --   package level constants to represent the ciphersuites used
    --   for encryption and decryption.
    --
    --   For example:
    --
    --   DES_CBC_PKCS5 CONSTANT PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_DES
    --                                       + DBMS_CRYPTO.CHAIN_CBC
    --                                       + DBMS_CRYPTO.PAD_PKCS5;
    --
    --
    -- STREAM CIPHERS (RC4) ARE NOT RECOMMENDED FOR STORED DATA ENCRYPTION.
    --
    --
    ------------------------------------------------------------------------

    FUNCTION  Encrypt (src IN            RAW,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL)
      RETURN RAW;

    PROCEDURE Encrypt (dst IN OUT NOCOPY BLOB,
                       src IN            BLOB,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL);

    PROCEDURE Encrypt (dst IN OUT NOCOPY BLOB,
                       src IN            CLOB         CHARACTER SET ANY_CS,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL);


    ------------------------------------------------------------------------
    --
    -- NAME:  Decrypt
    --
    -- DESCRIPTION:
    --
    --   Decrypt crypt text data using stream or block cipher with user
    --   supplied key and optional iv.
    --
    -- PARAMETERS
    --
    --   cryptext    - Crypt text data to be decrypted
    --   crypto_type - Stream or block cipher type plus modifiers
    --   key         - Key to be used for encryption
    --   iv          - Optional IV for block ciphers.  Default all zeros.
    --
    -- USAGE NOTES:
    --   To retrieve original plain text data, Decrypt must be called
    --   with the same cipher, modifiers, key and iv used for
    --   encryption.  If crypt text data was converted to hex or
    --   base64 prior to storage, it must be decoded using HEXTORAW or
    --   UTL_ENCODE.BASE64_DECODE prior to decryption.
    --
    ------------------------------------------------------------------------

    FUNCTION  Decrypt (src IN            RAW,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL)
       RETURN RAW;

    PROCEDURE Decrypt (dst IN OUT NOCOPY BLOB,
                       src IN            BLOB,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL);

    PROCEDURE Decrypt (dst IN OUT NOCOPY CLOB         CHARACTER SET ANY_CS,
                       src IN            BLOB,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL);


    ------------------------------------------------------------------------
    --
    -- NAME:  Hash
    --
    -- DESCRIPTION:
    --
    --   Hash source data by cryptographic hash type.
    --
    -- PARAMETERS
    --
    --   source    - Source data to be hashed
    --   hash_type - Hash algorithm to be used
    --
    -- USAGE NOTES:
    --   SHA-1 (HASH_SH1) is recommended.  Consider encoding returned
    --   raw value to hex or base64 prior to storage.
    --
    ------------------------------------------------------------------------

    FUNCTION Hash (src IN RAW,
                   typ IN PLS_INTEGER)
      RETURN RAW DETERMINISTIC;

    FUNCTION Hash (src IN BLOB,
                   typ IN PLS_INTEGER)
      RETURN RAW DETERMINISTIC;

    FUNCTION Hash (src IN CLOB        CHARACTER SET ANY_CS,
                   typ IN PLS_INTEGER)
      RETURN RAW DETERMINISTIC;


    ------------------------------------------------------------------------
    --
    -- NAME:  Mac
    --
    -- DESCRIPTION:
    --
    --   Message Authentication Code algorithms provide keyed message
    --   protection.
    --
    -- PARAMETERS
    --
    --   source   - Source data to be mac-ed
    --   mac_type - Mac algorithm to be used
    --   key      - Key to be used for mac
    --
    -- USAGE NOTES:
    --   Callers should consider encoding returned raw value to hex or
    --   base64 prior to storage.
    --
    ------------------------------------------------------------------------
    FUNCTION Mac (src IN RAW,
                  typ IN PLS_INTEGER,
                  key IN RAW)
      RETURN RAW;

    FUNCTION Mac (src IN BLOB,
                  typ IN PLS_INTEGER,
                  key IN RAW)
      RETURN RAW;

    FUNCTION Mac (src IN CLOB         CHARACTER SET ANY_CS,
                  typ IN PLS_INTEGER,
                  key IN RAW)
      RETURN RAW;


    ------------------------------------------------------------------------
    --
    -- NAME:  RandomBytes
    --
    -- DESCRIPTION:
    --
    --   Returns a raw value containing a pseudo-random sequence of
    --   bytes.
    --
    -- PARAMETERS
    --
    --   number_bytes - Number of pseudo-random bytes to be generated.
    --
    -- USAGE NOTES:
    --   number_bytes should not exceed maximum RAW length.
    --
    ------------------------------------------------------------------------
    FUNCTION RandomBytes (number_bytes IN PLS_INTEGER)
      RETURN RAW;


    ------------------------------------------------------------------------
    --
    -- NAME:  RandomNumber
    --
    -- DESCRIPTION:
    --
    --   Returns a random Oracle Number.
    --
    -- PARAMETERS
    --
    --  None.
    --
    ------------------------------------------------------------------------
    FUNCTION RandomNumber
      RETURN NUMBER;


    ------------------------------------------------------------------------
    --
    -- NAME:  RandomInteger
    --
    -- DESCRIPTION:
    --
    --   Returns a random BINARY_INTEGER.
    --
    -- PARAMETERS
    --
    --  None.
    --
    ------------------------------------------------------------------------
    FUNCTION RandomInteger
      RETURN BINARY_INTEGER;


    PRAGMA RESTRICT_REFERENCES(DEFAULT, WNDS, RNDS, WNPS, RNPS);

END DBMS_CRYPTO;
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_CRYPTO
   FOR sys.DBMS_CRYPTO;


CREATE OR REPLACE PACKAGE dbms_obfuscation_toolkit AS

    -- Note that the following pragma applies to both functions
    -- and procedures (see doc bug 3103959).
    pragma restrict_references (default, RNDS, WNDS, RNPS, WNPS);

    ------------------------------- TYPES ------------------------------------
    -- Types used to make it easier for the user to reserve the correct
    -- amount of memory for a checksum.

    SUBTYPE varchar2_checksum IS VARCHAR2(16);
    SUBTYPE raw_checksum IS RAW(16);

    ----------------------------- CONSTANTS -----------------------------------
    -- Triple DES modes
    TwoKeyMode   INTEGER := 0;
    ThreeKeyMode INTEGER := 1;

    ----------------------------- EXCEPTIONS ----------------------------------
    -- Invalid mode specified for Triple DES.
    InvalidTripleDESMode EXCEPTION;
    PRAGMA EXCEPTION_INIT(InvalidTripleDESMode, -28236);

    ---------------------- FUNCTIONS AND PROCEDURES ---------------------------

    ---------------------------- KEY GENERATION ------------------------------
    -- The following routines generate encryption keys. Each takes a random
    -- value which it uses in the generation of the key. This value must be
    -- at least 80 characters long.
    -- There are two versions of each procedure and function: one for raw data
    -- and the other for strings.
    ---------------------------------------------------------------------------
    PROCEDURE DESGetKey(seed  IN     RAW,
                        key      OUT RAW);
    pragma restrict_references (DESGetKey, RNDS, WNDS, WNPS);

    FUNCTION DESGetKey(seed IN RAW) RETURN RAW;
    pragma restrict_references (DESGetKey, RNDS, WNDS, WNPS);

    PROCEDURE DESGetKey(seed_string IN     VARCHAR2,
                        key            OUT VARCHAR2);
    pragma restrict_references (DESGetKey, RNDS, WNDS, WNPS);

    FUNCTION DESGetKey(seed_string IN VARCHAR2) RETURN VARCHAR2;
    pragma restrict_references (DESGetKey, RNDS, WNDS, WNPS);

    -- For Triple DES, the mode is specified so that the key has the proper
    -- length is returned.
    PROCEDURE DES3GetKey(which IN     PLS_INTEGER DEFAULT TwoKeyMode,
                         seed  IN     RAW,
                         key      OUT RAW);
    pragma restrict_references (DES3GetKey, RNDS, WNDS, WNPS);

    FUNCTION DES3GetKey(which IN PLS_INTEGER DEFAULT TwoKeyMode,
                        seed  IN RAW)
        RETURN RAW;
    pragma restrict_references (DES3GetKey, RNDS, WNDS, WNPS);

    PROCEDURE DES3GetKey(which       IN     PLS_INTEGER DEFAULT TwoKeyMode,
                         seed_string IN     VARCHAR2,
                         key            OUT VARCHAR2);
    pragma restrict_references (DES3GetKey, RNDS, WNDS, WNPS);

    FUNCTION DES3GetKey(which        IN PLS_INTEGER DEFAULT TwoKeyMode,
                        seed_string  IN VARCHAR2)
        RETURN VARCHAR2;
    pragma restrict_references (DES3GetKey, RNDS, WNDS, WNPS);

    ---------------------------- DATA ENCRYPTION ------------------------------
    -- The following routines encrypt and decrypt data.
    -- There are two versions of each procedure and function: one for raw data
    -- and the other for strings.
    ---------------------------------------------------------------------------

    -- DES
    PROCEDURE DESEncrypt(input            IN     RAW,
                         key              IN     RAW,
                         encrypted_data      OUT RAW);

    FUNCTION DESEncrypt(input            IN  RAW,
                        key              IN  RAW)
        RETURN RAW;

    PROCEDURE DESEncrypt(input_string    IN     VARCHAR2,
                        key_string       IN     VARCHAR2,
                        encrypted_string    OUT VARCHAR2);

    FUNCTION DESEncrypt(input_string     IN  VARCHAR2,
                        key_string       IN  VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE DESDecrypt(input            IN      RAW,
                         key              IN      RAW,
                         decrypted_data       OUT RAW);

    FUNCTION DESDecrypt(input            IN  RAW,
                        key              IN  RAW)
        RETURN RAW;

    PROCEDURE DESDecrypt(input_string     IN    VARCHAR2,
                         key_string       IN    VARCHAR2,
                         decrypted_string    OUT VARCHAR2);

    FUNCTION DESDecrypt(input_string     IN     VARCHAR2,
                        key_string       IN  VARCHAR2)
        RETURN VARCHAR2;

    -- Triple DES

    PROCEDURE DES3Encrypt(input          IN     RAW,
                          key            IN     RAW,
                          encrypted_data    OUT RAW,
                          which          IN     PLS_INTEGER
                                                  DEFAULT TwoKeyMode,
                          iv             IN     RAW DEFAULT NULL);
    pragma restrict_references (DES3Encrypt, RNDS, WNDS, WNPS);

    FUNCTION DES3Encrypt(input IN RAW,
                         key   IN RAW,
                         which IN PLS_INTEGER DEFAULT TwoKeyMode,
                         iv    IN RAW DEFAULT NULL)
        RETURN RAW;
    pragma restrict_references (DES3Encrypt, RNDS, WNDS, WNPS);

    PROCEDURE DES3Encrypt(input_string     IN     VARCHAR2,
                          key_string       IN     VARCHAR2,
                          encrypted_string    OUT VARCHAR2,
                          which            IN     PLS_INTEGER
                                                    DEFAULT TwoKeyMode,
                          iv_string        IN     VARCHAR2 DEFAULT NULL);
    pragma restrict_references (DES3Encrypt, RNDS, WNDS, WNPS);

    FUNCTION DES3Encrypt(input_string  IN VARCHAR2,
                         key_string    IN VARCHAR2,
                         which         IN PLS_INTEGER DEFAULT TwoKeyMode,
                         iv_string     IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;
    pragma restrict_references (DES3Encrypt, RNDS, WNDS, WNPS);

    PROCEDURE DES3Decrypt(input          IN     RAW,
                          key            IN     RAW,
                          decrypted_data    OUT RAW,
                          which          IN     PLS_INTEGER
                                                  DEFAULT TwoKeyMode,
                          iv             IN     RAW DEFAULT NULL);
    pragma restrict_references (DES3Decrypt, RNDS, WNDS, WNPS);

    FUNCTION DES3Decrypt(input IN RAW,
                         key   IN RAW,
                         which IN PLS_INTEGER DEFAULT TwoKeyMode,
                         iv    IN RAW DEFAULT NULL)
        RETURN RAW;
    pragma restrict_references (DES3Decrypt, RNDS, WNDS, WNPS);

    PROCEDURE DES3Decrypt(input_string     IN     VARCHAR2,
                          key_string       IN     VARCHAR2,
                          decrypted_string    OUT VARCHAR2,
                          which            IN     PLS_INTEGER
                                                    DEFAULT TwoKeyMode,
                          iv_string        IN VARCHAR2 DEFAULT NULL);
    pragma restrict_references (DES3Decrypt, RNDS, WNDS, WNPS);

    FUNCTION DES3Decrypt(input_string IN VARCHAR2,
                         key_string   IN VARCHAR2,
                         which        IN PLS_INTEGER DEFAULT TwoKeyMode,
                         iv_string    IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;
    pragma restrict_references (DES3Decrypt, RNDS, WNDS, WNPS);

    -------------------------------- MD5 --------------------------------------
    -- The following routines generate MD5 hashes of data.
    -- There are two versions: one for raw data and the other for strings.
    ---------------------------------------------------------------------------

    PROCEDURE MD5(input    IN  RAW,
                  checksum OUT raw_checksum);

    FUNCTION MD5(input    IN  RAW)
        RETURN raw_checksum;

    PROCEDURE MD5(input_string    IN     VARCHAR2,
                  checksum_string    OUT varchar2_checksum);

    FUNCTION MD5(input_string    IN     VARCHAR2)
        RETURN varchar2_checksum;

END dbms_obfuscation_toolkit;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_obfuscation_toolkit
   FOR sys.dbms_obfuscation_toolkit;
GRANT EXECUTE ON dbms_obfuscation_toolkit TO public
/
show errors;

CREATE OR REPLACE PACKAGE DBMS_SQLHASH AUTHID CURRENT_USER AS

    FUNCTION gethash(sqltext     IN varchar2,         -- input sql statement
                     digest_type IN BINARY_INTEGER,  -- digest algorithm type
                     chunk_size  IN number DEFAULT 134217728)  -- 128M
        RETURN raw;

END DBMS_SQLHASH;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_SQLHASH
   FOR sys.DBMS_SQLHASH;
