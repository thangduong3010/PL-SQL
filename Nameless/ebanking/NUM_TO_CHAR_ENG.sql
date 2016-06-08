CREATE OR REPLACE FUNCTION DEMOEBANKING.num_to_char_ENG (p_amount   IN NUMBER,
                                            p_ccy         VARCHAR2)
   RETURN VARCHAR2
IS
   /*****************************************************************************
   --Author          :  VUNA
   --Creation Date   :  27/02/2012
   --Purpose         :  This Function returns amount in words.
   --Parameters      :
   --1) p_amount     :  Only positive and negative values are allowed.
                        Precision can be entered upto 10 digits and only 2 scales
                        are allowed e.g 9999999999.99
   -------------------------    MODIFICATION HISTORY ----------------------------
   WHO              WHEN(Date)    WHY
   VUNA             27/02/2012    Created.
   -------"-------  28/02/2012    add CCY.
   ******************************************************************************/
   -------------------------------------
   -- Index by Tables to store word list
   -------------------------------------
   TYPE typ_word_list IS TABLE OF VARCHAR2 (200)
                            INDEX BY BINARY_INTEGER;

   t_typ_word_list   typ_word_list;

   TYPE typ_word_gap IS TABLE OF VARCHAR2 (200)
                           INDEX BY BINARY_INTEGER;

   t_typ_word_gap    typ_word_gap;
   ------------------
   -- Local Variables
   ------------------
   v_amount          NUMBER := p_amount;
   v_amount_length   NUMBER;
   v_words           VARCHAR2 (10000);
   v_point_found     VARCHAR2 (1) := 'N';
   v_point_value     NUMBER;
BEGIN
   /*Getting value after point if found */
   v_point_value := SUBSTR (v_amount, (INSTR (v_amount, '.', 1) + 1), 2);

   /*Checking whether amount has any scale value also */
   v_point_found :=
      CASE
         WHEN (INSTR (v_amount, '.', 1)) = 0 THEN 'N'
         WHEN (INSTR (v_amount, '.', 1)) > 0 THEN 'Y'
      END;
   /*Converting amount into pure numeric format */
   v_amount := FLOOR (ABS (v_amount));

   --
   v_amount_length := LENGTH (v_amount);
   --
   t_typ_word_gap (2) := 'and Paise';
   t_typ_word_gap (3) := 'Hundred';
   t_typ_word_gap (4) := 'Thousand';
   t_typ_word_gap (7) := 'Million';
   t_typ_word_gap (10):= 'Billion';

   --
   FOR i IN 1 .. 99
   LOOP
      t_typ_word_list (i) := TO_CHAR (TO_DATE (i, 'J'), 'Jsp');
   END LOOP;

   --
   IF v_amount_length <= 2
   THEN
      /* Conversion 1 to 99 digits */
      v_words := t_typ_word_list (v_amount);
   ELSIF v_amount_length = 3
   THEN
      /* Conversion for 3 digits till 999 */
      v_words :=
            t_typ_word_list (SUBSTR (v_amount, 1, 1))
         || ' '
         || t_typ_word_gap (3);
      v_words := v_words || ' ' || t_typ_word_list (SUBSTR (v_amount, 2, 2));
   ELSIF v_amount_length = 4
   THEN
      /* Conversion for 4 digits till 9999 */
      v_words :=
            t_typ_word_list (SUBSTR (v_amount, 1, 1))
         || ' '
         || t_typ_word_gap (4);

      IF SUBSTR (v_amount, 2, 1) != 0
      THEN
         v_words :=
               v_words
            || ' '
            || t_typ_word_list (SUBSTR (v_amount, 2, 1))
            || ' '
            || t_typ_word_gap (3);
      END IF;

      IF SUBSTR (v_amount, 3, 2) != 0
      THEN
         v_words :=
            v_words || ' ' || t_typ_word_list (SUBSTR (v_amount, 3, 2));
      END IF;
   ELSIF v_amount_length = 5
   THEN
      /* Conversion for 5 digits till 99999 */
      v_words :=
            t_typ_word_list (SUBSTR (v_amount, 1, 2))
         || ' '
         || t_typ_word_gap (4);

      IF SUBSTR (v_amount, 3, 1) != 0
      THEN
         v_words :=
               v_words
            || ' '
            || t_typ_word_list (SUBSTR (v_amount, 3, 1))
            || ' '
            || t_typ_word_gap (3);
      END IF;

      IF SUBSTR (v_amount, 4, 2) != 0
      THEN
         v_words :=
            v_words || ' ' || t_typ_word_list (SUBSTR (v_amount, 4, 2));
      END IF;

   ELSIF v_amount_length = 6
   THEN
      /* Conversion for 6 digits till 999999 */
      v_words :=
            t_typ_word_list (SUBSTR (v_amount, 1, 1))
         || ' '
         || t_typ_word_gap (3)
         ;

      IF SUBSTR (v_amount, 2, 2) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 2, 2))
            || t_typ_word_gap (4)
            ;
else
         v_words :=
               v_words
            || ' '
            || t_typ_word_gap (4)
            ;
            
      END IF;

      IF SUBSTR (v_amount, 4, 3) != 0
      then
        v_words :=
             v_words
            || ' And ';
      IF SUBSTR (v_amount, 4, 1) != 0
      THEN
         v_words :=
             v_words
            || t_typ_word_list (SUBSTR (v_amount, 4, 1))
            || ' '
            || t_typ_word_gap (3);
      END IF;

      IF SUBSTR (v_amount, 5, 2) != 0
      THEN
         v_words :=
            v_words || ' ' || t_typ_word_list (SUBSTR (v_amount, 5, 2));
      END IF;
end if;

   ELSIF v_amount_length = 7
   THEN
      /* Conversion for 7 digits till 9999999 */
      v_words :=
            t_typ_word_list (SUBSTR (v_amount, 1, 1))
         || ' '
         || t_typ_word_gap (7);

      IF SUBSTR (v_amount,2,1) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 2, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;

      IF SUBSTR (v_amount, 3, 2) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 3, 2))
            || ' '
            || t_typ_word_gap (4);
      else
         v_words :=
               v_words
            || ' '
            || t_typ_word_gap (4);
            
      END IF;

      IF SUBSTR (v_amount,5,1) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 5, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;

      IF SUBSTR (v_amount, 6, 2) != 0
      THEN
         v_words :=
            v_words || ' ' || t_typ_word_list (SUBSTR (v_amount, 6, 2));
      END IF;
   ELSIF v_amount_length = 8
   THEN
      v_words :=
            t_typ_word_list (SUBSTR (v_amount, 1, 2))
         || ' '
         || t_typ_word_gap (7);

      IF SUBSTR (v_amount,3,3) != 0
      THEN
      IF SUBSTR (v_amount,3,1) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 3, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;

      IF SUBSTR (v_amount, 4, 2) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 4, 2))
            || ' '
            || t_typ_word_gap (4);
else
         v_words :=
               v_words
            || ' '
            || t_typ_word_gap (4);

      END IF;
end if;
      IF SUBSTR (v_amount,6,3) != 0
      THEN
      v_words :=
               v_words
            || ' And ';
      IF SUBSTR (v_amount,6,1) != 0
      THEN
         v_words :=
               v_words
            || t_typ_word_list (SUBSTR (v_amount, 6, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;

      IF SUBSTR (v_amount, 7, 2) != 0
      THEN
         v_words :=
            v_words || ' ' || t_typ_word_list (SUBSTR (v_amount, 7, 2));
      END IF;
      end if;
      
   ELSIF v_amount_length = 9
   THEN
      /* Conversion for 9 digits till 999999999 */

      v_words :=
            t_typ_word_list (SUBSTR (v_amount, 1, 1))
         || ' '
         || t_typ_word_gap (3);

      IF SUBSTR (v_amount,2,2) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 2, 2))
            || ' '
            || t_typ_word_gap (7)
            ;
else
         v_words :=
               v_words
            || ' '
            || t_typ_word_gap (7)
            ;

      END IF;

IF SUBSTR (v_amount,4,3) != 0
THEN
      IF SUBSTR (v_amount,4,1) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 4, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;

      IF SUBSTR (v_amount, 5, 2) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 5, 2))
            || ' '
            || t_typ_word_gap (4);
      END IF;
END IF;
IF SUBSTR (v_amount,7,3) != 0
THEN
         v_words :=
               v_words
            || ' And '
;
      IF SUBSTR (v_amount,7,1) != 0
      THEN
         v_words :=
               v_words
            || t_typ_word_list (SUBSTR (v_amount, 7, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;

      IF SUBSTR (v_amount, 8, 2) != 0
      THEN
         v_words :=
            v_words || ' ' || t_typ_word_list (SUBSTR (v_amount, 8, 2));
      END IF;
end if;
      
   ELSIF v_amount_length = 10
   THEN
      /* Conversion for 10 digits till 9999999999 */

      v_words :=
            t_typ_word_list (SUBSTR (v_amount, 1, 1))
         || ' '
         || t_typ_word_gap (10);

     IF SUBSTR (v_amount,2,3) != 0
      THEN
      IF SUBSTR (v_amount,2,1) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 2, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;



      IF SUBSTR (v_amount,3,2) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 3, 2))
            || ' '
            || t_typ_word_gap (7)
            ;

else
         v_words :=
               v_words
            || ' '
            || t_typ_word_gap (7)
            ;

      END IF;
end if;

      IF SUBSTR (v_amount,5,3) != 0
      THEN
      IF SUBSTR (v_amount,5,1) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 5, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;

      IF SUBSTR (v_amount, 6, 2) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 6, 2))
            || ' '
            || t_typ_word_gap (4);

else
         v_words :=
               v_words
            || ' '
            || t_typ_word_gap (4);

      END IF;

end if;

      IF SUBSTR (v_amount,8,3) != 0
      THEN
      v_words :=
               v_words
            || ' And ';
      IF SUBSTR (v_amount,8,1) != 0
      THEN
         v_words :=
               v_words
            || t_typ_word_list (SUBSTR (v_amount, 8, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;

      IF SUBSTR (v_amount, 9, 2) != 0
      THEN
         v_words :=
            v_words || ' ' || t_typ_word_list (SUBSTR (v_amount, 9, 2));
      END IF;
      end if;
      
   ELSIF v_amount_length = 11
   THEN
      /* Conversion for 11 digits till 99999999999 */

      v_words :=
            t_typ_word_list (SUBSTR (v_amount, 1, 2))
         || ' '
         || t_typ_word_gap (10);

      IF SUBSTR (v_amount,3,3) != 0
      THEN

      IF SUBSTR (v_amount,3,1) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 3, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;




      IF SUBSTR (v_amount,4,2) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 4, 2))
            || ' '
            || t_typ_word_gap (7)
            ;
else

         v_words :=
               v_words
            || ' '
            || t_typ_word_gap (7)
            ;

      END IF;

end if;

      IF SUBSTR (v_amount,6,3) != 0
      THEN
      IF SUBSTR (v_amount,6,1) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 6, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;

      IF SUBSTR (v_amount, 7, 2) != 0
      THEN
         v_words :=
               v_words
            || ' And '
            || t_typ_word_list (SUBSTR (v_amount, 7, 2))
            || ' '
            || t_typ_word_gap (4);
else
         v_words :=
               v_words
            || ' '
            || t_typ_word_gap (4);

      END IF;
end if;

      IF SUBSTR (v_amount,9,3) != 0
      THEN
  v_words :=
               v_words
            || ' And ';
      IF SUBSTR (v_amount,9,1) != 0
      THEN
         v_words :=
               v_words
            || t_typ_word_list (SUBSTR (v_amount, 9, 1))
            || ' '
            || t_typ_word_gap (3)
            ;
      END IF;

      IF SUBSTR (v_amount, 10, 2) != 0
      THEN
         v_words :=
            v_words || ' ' || t_typ_word_list (SUBSTR (v_amount, 10, 2));
      END IF;      
   END IF;
end if;
   --
   IF v_point_found = 'Y'
   THEN
      IF v_point_value != 0
      THEN
         v_words :=
            v_words || ' ' || t_typ_word_gap (2) || ' '
            || t_typ_word_list (
                  CASE
                     WHEN LENGTH (
                             SUBSTR (p_amount,
                                     (INSTR (p_amount, '.', 1) + 1),
                                     2)) = 1
                     THEN
                        SUBSTR (p_amount, (INSTR (p_amount, '.', 1) + 1), 2)
                        || '0'
                     WHEN LENGTH (
                             SUBSTR (p_amount,
                                     (INSTR (p_amount, '.', 1) + 1),
                                     2)) = 2
                     THEN
                        SUBSTR (p_amount, (INSTR (p_amount, '.', 1) + 1), 2)
                  END);
      END IF;
   END IF;

   --
   IF p_amount < 0
   THEN
      v_words := 'Minus ' || v_words;
   ELSIF p_amount = 0
   THEN
      v_words := 'Zero';
   END IF;

   IF LENGTH (v_amount) > 11
   THEN
      v_words :=
         'Value larger than specified precision allowed to convert into words. Maximum 10 digits allowed for precision.';
   END IF;

   IF p_ccy IS NOT NULL
   THEN
      select v_words || ' ' || DECODE (p_ccy, 'VND', 'dong', UPPER (p_ccy)) into v_words  from dual;
   END IF;

   RETURN (v_words);
END num_to_char_ENG;
/