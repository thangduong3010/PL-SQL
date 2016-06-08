/* Specification:
Consider the following sequence of letters where gaps have been placed to form "words". The first 26 letters in the sequence are "words" that have one letter each.
Then all 2-letter "words" are listed in alphabetical order, followed by all 3-letter "words" and so on.

A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
AA ... AZ BA ... BZ ...... ZA ... ZA 
AAA ... AZZ BAA ... BZZ ...... ZAA ... ZZZ
AAAA ... AZZZ BAAA ... BZZZ ....... ZAAA ... ZZZZ
Thus, for example, the 10th letter and 10th word in this sequence is J,
the 30th letter is B which occurs in the 28th word AB and the 60th letter is Q which occurs in the 43rd word AQ. 

Write a program to display:

a. The 2015th letter in this sequence and the "word" in which it appears

b. How many times the letter A appears in this sequence before the 2015th letter in the sequence?
*/

declare
    v_loopcount number := 0;
    v_charcount number := 0;
    v_wordcount number := 0;
    v_cond number := 0;
    v_2015th varchar2(10);
    v_word varchar2(10);
    v_keyword varchar2(10);
    v_Atimes number := 0;

    -- count letter A appearances
    procedure get_A(p_char in char, p_count in number)
    is
    begin
        if p_char = chr(65) and p_count <= 2015 then
            v_Atimes := v_Atimes + 1;
        else
            NULL;
        end if;
    end get_A;

    -- get the 2015th letter
    procedure get_2015th(p_count in number, p_char in char)
    is
    begin
        if p_count = 2015 then
            v_2015th := p_char;
        else
            NULL;
        end if;
    end get_2015th;

    -- get the word that contain the 2015th letter
    procedure get_keyword(p_count in number, p_word in varchar2)
    is
    begin
        if p_count in (2015,2016,2017) then
            v_word := p_word;
        else
            NULL;
        end if;
    end get_keyword;
begin   
    loop
        exit when v_loopcount > 2;
        for i in 65..90 loop
            if v_cond = 0 then
                v_keyword := chr(i);
                v_charcount := v_charcount + 1;
                
                get_A(chr(i), v_charcount);
                get_2015th(v_charcount, chr(i));
                get_keyword(v_charcount, v_keyword);
                
                dbms_output.put(v_keyword || ' ');                
                v_wordcount := v_wordcount + 1;
            end if;

            if v_cond = 1 then
                for j in 65..90 loop
                    v_keyword := chr(i);
                    v_charcount := v_charcount + 1;
                    
                    get_A(chr(i), v_charcount);
                    get_2015th(v_charcount, chr(i));

                    v_keyword := v_keyword || chr(j);
                    v_charcount := v_charcount + 1;
                    
                    get_A(chr(j), v_charcount);
                    get_2015th(v_charcount, chr(j));

                    get_keyword(v_charcount, v_keyword);

                    dbms_output.put(v_keyword || ' ');
                    v_wordcount := v_wordcount + 1;
                end loop;
                dbms_output.put_line(' ');
            end if;

            if v_cond = 2 then
                for j in 65..90 loop
                    v_keyword := chr(i);
                    v_charcount := v_charcount + 1;
                    
                    get_A(chr(i), v_charcount);
                    get_2015th(v_charcount, chr(i));

                    v_keyword := v_keyword || chr(j);
                    v_charcount := v_charcount + 1;
                    
                    get_A(chr(j), v_charcount);
                    get_2015th(v_charcount, chr(j));
                     
                    v_keyword := v_keyword || chr(j);
                    v_charcount := v_charcount + 1;
                    
                    get_A(chr(j), v_charcount);
                    get_2015th(v_charcount, chr(j));
                        
                    get_keyword(v_charcount, v_keyword);
                    
                    dbms_output.put(v_keyword || ' ');
                    v_wordcount := v_wordcount + 1;
                end loop;
                dbms_output.put_line(' ');
            end if;
                       
        end loop; -- end inner loop
        dbms_output.put_line(' ');
        dbms_output.put_line('Letter count: ' || v_charcount);
        dbms_output.put_line('Word count: ' || v_wordcount);

        v_cond := v_cond + 1;
        v_loopcount := v_loopcount + 1;
    end loop; -- end outer loop
    dbms_output.put_line('2015th character: ' || v_2015th);
    dbms_output.put_line('In word: ' || v_word);
    dbms_output.put_line('The letter A has appeared: ' || v_Atimes);
end;
/