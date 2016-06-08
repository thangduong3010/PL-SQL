CREATE OR REPLACE FUNCTION DEMOEBANKING.pgb_num_to_char(iNumber_v number) RETURN VARCHAR2
 IS
/*
         iNumber                    NUMBER;
         i                                BINARY_INTEGER        := 0;
         j                                BINARY_INTEGER        := 0;
         s                                BINARY_INTEGER        := 0;
         k                                BINARY_INTEGER        := 0;
         m                                BINARY_INTEGER        := 0;
         tam                            BINARY_INTEGER        := 0;
         header_ketso            VARCHAR2(4000);
         trailer_ketso        VARCHAR2(4000);
         ketso                        VARCHAR2(4000);
         ketso_kt                    VARCHAR2(4000);
         ostr                            VARCHAR2(4000);
         Solon                        VARCHAR2(4000)          :=
         'tram  muoi  nghin  tram  muoi  ty    tram  muoi  trieu tram  muoi  nghin  tram  muoi';
         Sodonvi                    VARCHAR2(4000)           :=
         'mot  hai  ba   bon  nam  sau  bay  tam  chin';
         baso                            VARCHAR2(3);
         baso_d                        VARCHAR2(3);
         dangso                        VARCHAR2(4000);
         sodau                        VARCHAR2(1);
         sogiua                        VARCHAR2(1);
         socuoi                        VARCHAR2(1);
         doi                          VARCHAR2(4000);
         chu                            VARCHAR2(4000);
         temp                            number:=0;
         
         FUNCTION loaidau (xauvao    in VARCHAR2)
         RETURN varchar2
     IS
         xaura          VARCHAR2(4000);
         xauvao_t  VARCHAR2(4000);
         i                  INTEGER    := 0;
         tam              INTEGER    := 0;
         kitu_t      VARCHAR2(2);
         kitu_s      VARCHAR2(2);
     BEGIN
       xauvao_t      := TRIM(xauvao)||' ';
       xaura                    := '';
       kitu_t                := '';
       kitu_s                := '';
       FOR i IN 1..(LENGTH(xauvao_t)-1)
           LOOP
                   kitu_t    :=    SUBSTR(xauvao_t,i,1);
                   kitu_s    :=    SUBSTR(xauvao_t,i+1,1);
                   IF not((kitu_t=' ')and(kitu_s=' '))THEN
                  xaura:=xaura||kitu_t;
                   END IF;
           END LOOP;
       RETURN xaura;
END;

BEGIN

         iNumber := iNumber_v;
IF ((iNumber<0) OR (iNumber>999999999999999))THEN
         ketso:= 'se tiOn ?m ho?c '||
                                'se lin h?n 999.999.999.999.999';
ELSIF ((iNumber<=9) AND (iNumber>=0)) THEN
                 ketso:='';
                 chu:='';
                 doi:='';
                 s   := TO_NUMBER(SUBSTR(to_char(iNumber),1,1));
                 IF s>0 THEN
                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' ';
                         chu:=chu||''||doi;
                 ELSE
                         
                         doi:='khong ';
                         chu:=chu||''||doi;
                 END IF;
                     
                     ketso:=ketso||chu||' ';
         ELSIF ((iNumber<=99) AND (iNumber>=10)) THEN
                 ketso:='';
                 chu:='';
                 doi:='';
                 s  := TO_NUMBER(SUBSTR(to_char(iNumber),1,1));
                 IF s > 1 THEN
                         
                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' muoi ';
                         chu:=chu||doi;
                 ELSE
                         
                         doi:='muoi ';
                         chu:=chu||doi;
                 END IF;
                 s  := TO_NUMBER(SUBSTR(to_char(iNumber),2,1));
                 IF s>0 THEN
                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' ';
                         if s=5 then
                         
                             doi :='lam';
                         end if;

                         chu:=chu||''||doi;
                 ELSE
                         doi:=' ';
                         chu:=chu||''||doi;
                 END IF;

               
               ketso:=ketso||chu||' ';

ELSE
               ketso         :='';
                Dangso      := TO_CHAR(ABS(iNumber),'99999999999999');
              Dangso   := SUBSTR(Dangso,1,15);
              baso_d := SUBSTR(Dangso,1,3);

                 FOR i IN 1..5 LOOP
                       baso      := SUBSTR(Dangso,i*3-2,3);
                         IF baso <> '   ' THEN
                                 IF baso ='000' THEN
                                     IF i=5 THEN chu:='';
                                     ELSE                                         
                                         IF i=2 THEN
                                             IF baso<>'000' THEN                                                  
                                                  chu:='ty ';
                                             ELSE
                                                 IF baso_d<>'000'THEN
                                                    
                                                    chu:='ty ';
                                                 ELSE
                                                     chu:='';
                                                 END IF;
                                             END IF;
                                         ELSE                                     
                                                 chu:='';
                                         END IF;
                                     END IF;
                                 ELSE                                             
                                     temp:=1;
                                     sodau :=SUBSTR(baso,1,1);
                                     sogiua:=SUBSTR(baso,2,1);
                                     socuoi:=SUBSTR(baso,3,1);
                                     chu:='';
                                     doi:='';

                                     if sodau = ' ' then
                                         temp:=2;
                                     end if;

                                     if sogiua= ' ' then
                                         temp:=3;
                                     end if;

                                     FOR j IN temp..3 LOOP
                                         s   := TO_NUMBER(nvl(SUBSTR(baso,j,1),'-1'));
                                         IF s>0 THEN

                                             IF (s=1)and(j=2)THEN
                                                 
                                                doi:='muoi ';
                                             ELSE                                
                                                 IF (s=1)and(j=3)THEN
                                                     IF sogiua>'1' THEN
                                                 
                                                        doi:='mot '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     ELSE
                                                 
                                                        doi:='mot '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     END IF;
                                                 ELSE                            
                                                     IF (s=5    )and(j=3) THEN
                                                         IF (sogiua<>' ')and(sogiua<>'0')THEN
                                                 
                                                            doi:='lam '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                         ELSE
                                                             doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' '||
                                                                    TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                         END IF;
                                                     ELSE                        
                                                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' '||
                                                                  TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     END IF;                    
                                                 END IF;                        
                                             END IF;                            
                                         ELSE                                    
                                             IF j=1 THEN
                                                 
                                                    doi:='khong tram ';
                                             ELSE                                
                                                 IF j=2 THEN
                                                     IF socuoi='0'THEN
                                                         doi:='';
                                                     ELSE                        
                                                         doi:='linh ';
                                                     END IF;
                                                 ELSE                            
                                                     IF baso<>'  0'THEN
                                                         doi:=TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     END IF;
                                                 END IF;                        
                                             END IF;                            
                                         END IF;                                
                                         chu:=chu||''||doi;
                                     END LOOP;                                
                                 END IF;                                        
                         END IF;                                                 

                         IF (iNumber>999999999999999)or(iNumber<0)or(iNumber=0)THEN
                             ketso:='Kh<ng ?-ic nhEp v?o se ?m, se 0 '||
                                'se lin h?n 999.999.999.999.999';
                         ELSE
                             IF i=5 THEN
                                 
                                ketso:=ketso||chu||' ';
                             ELSE
                                 ketso:=ketso||chu||' ';
                             END IF;
                         END IF;
                END LOOP;                                                   

       ketso   := loaidau(ketso);
       ketso_kt:=TRIM(ketso);
       
     k:=LENGTH('khong tram');
       
     IF (SUBSTR(ketso_kt,1,k)='khong tram')THEN
             ketso_kt:=SUBSTR(ketso_kt,k+1,(LENGTH(ketso_kt)-k));
       END IF;
       ketso_kt:=TRIM(ketso_kt);
       m:=LENGTH('linh');
       IF (SUBSTR(ketso_kt,1,m)='linh')THEN
             ketso_kt:=(SUBSTR(ketso_kt,m+1,LENGTH(ketso_kt)-m));
       END IF;
       ketso_kt:=TRIM(ketso_kt);
       ketso:=ketso_kt;

END IF;
*/
         iNumber                    NUMBER;
         i                                BINARY_INTEGER        := 0;
         j                                BINARY_INTEGER        := 0;
         s                                BINARY_INTEGER        := 0;
         k                                BINARY_INTEGER        := 0;
         m                                BINARY_INTEGER        := 0;
         tam                            BINARY_INTEGER        := 0;
         header_ketso            VARCHAR2(4000);
         trailer_ketso        VARCHAR2(4000);
         ketso                        VARCHAR2(4000);
         ketso_kt                    VARCHAR2(4000);
         ostr                            VARCHAR2(4000);
         Solon                        VARCHAR2(4000)          :=
         'tram  muoi  nghin  tram  muoi  ty    tram  muoi  trieu tram  muoi  nghin  tram  muoi';
         --'tr?m  m-?i  ngh?n  tr?m  m-?i  tu    tr?m  m-?i  triOu tr?m  m-?i  ngh?n  tr?m  m-?i  ??ng';
         Sodonvi                    VARCHAR2(4000)           :=
         'mot  hai  ba   bon  nam  sau  bay  tam  chin';
         --'met  hai  ba   ben  n?m  s?u  b?y  t?m  chYn';
         baso                            VARCHAR2(3);
         baso_d                        VARCHAR2(3);
         dangso                        VARCHAR2(4000);
         sodau                        VARCHAR2(1);
         sogiua                        VARCHAR2(1);
         socuoi                        VARCHAR2(1);
         doi                          VARCHAR2(4000);
         chu                            VARCHAR2(4000);
         temp                            number:=0;
         dau                           varchar2(10):=' ';
         so_thap_phan                  number:=0;

FUNCTION loaidau (xauvao    in VARCHAR2)
    RETURN varchar2
IS
    xaura          VARCHAR2(4000);
    xauvao_t  VARCHAR2(4000);
    i                  INTEGER    := 0;
    tam              INTEGER    := 0;
    kitu_t      VARCHAR2(2);
    kitu_s      VARCHAR2(2);
BEGIN
  xauvao_t      := TRIM(xauvao)||' ';
  xaura                    := '';
  kitu_t                := '';
  kitu_s                := '';
  FOR i IN 1..(LENGTH(xauvao_t)-1)
      LOOP
              kitu_t    :=    SUBSTR(xauvao_t,i,1);
              kitu_s    :=    SUBSTR(xauvao_t,i+1,1);
              IF not((kitu_t=' ')and(kitu_s=' '))THEN
             xaura:=xaura||kitu_t;
              END IF;
      END LOOP;
  RETURN xaura;
END;         

FUNCTION Num_to_Char_thap_phan(iNumber_v    in NUMBER) RETURN VARCHAR2
 IS
         iNumber                    NUMBER;
         i                                BINARY_INTEGER        := 0;
         j                                BINARY_INTEGER        := 0;
         s                                BINARY_INTEGER        := 0;
         k                                BINARY_INTEGER        := 0;
         m                                BINARY_INTEGER        := 0;
         tam                            BINARY_INTEGER        := 0;
         header_ketso            VARCHAR2(4000);
         trailer_ketso        VARCHAR2(4000);
         ketso                        VARCHAR2(4000);
         ketso_kt                    VARCHAR2(4000);
         ostr                            VARCHAR2(4000);
         Solon                        VARCHAR2(4000)          :=
         'tram  muoi  nghin  tram  muoi  ty    tram  muoi  trieu tram  muoi  nghin  tram  muoi ';
         --'tr?m  m-?i  ngh?n  tr?m  m-?i  tu    tr?m  m-?i  triOu tr?m  m-?i  ngh?n  tr?m  m-?i  ??ng';
         Sodonvi                    VARCHAR2(4000)           :=
         'mot  hai  ba   bon  nam  sau  bay  tam  chin';
         --'met  hai  ba   ben  n?m  s?u  b?y  t?m  chYn';
         baso                            VARCHAR2(3);
         baso_d                        VARCHAR2(3);
         dangso                        VARCHAR2(4000);
         sodau                        VARCHAR2(1);
         sogiua                        VARCHAR2(1);
         socuoi                        VARCHAR2(1);
         doi                          VARCHAR2(4000);
         chu                            VARCHAR2(4000);
         temp                            number:=0;
         dau                           varchar2(10):=' ';
         str_temp                       VARCHAR2(4000);
         mauso                          VARCHAR2(4000);
         l_length                       number:=length(mod(iNumber_v,1))-1;

BEGIN
         str_temp:=TO_CHAR(ABS(iNumber_v),'.99999999999999');
              str_temp   := SUBSTR(trim(str_temp),2,(l_length));
         iNumber := abs(to_number(str_temp));

if (l_length = 1) then
    mauso:= 'phan muoi';         
elsif (l_length = 2) then
    mauso:= 'phan tram';
elsif (l_length = 3) then
    mauso:= 'phan nghin';
elsif (l_length = 4) then
    mauso:= 'phan chuc nghin';
elsif (l_length = 5) then
    mauso:= 'phan tram nghin';
elsif (l_length = 6) then
    mauso:= 'phan trieu';
elsif (l_length = 7) then
    mauso:= 'phan chuc trieu';
elsif (l_length = 8) then
    mauso:= 'phan tram trieu';
elsif (l_length = 9) then
    mauso:= 'phan ty';
elsif (l_length = 10) then
    mauso:= 'phan chuc ty';
elsif (l_length = 11) then
    mauso:= 'phan tram ty';
elsif (l_length = 12) then
    mauso:= 'phan nghin ty';
elsif (l_length = 13) then
    mauso:= 'phan chuc nghin ty';
elsif (l_length = 14) then
    mauso:= 'phan tram nghin ty';
elsif (l_length = 15) then
    mauso:= 'phan trieu ty';
end if;
                         
IF ((iNumber<=9) AND (iNumber>=0) and (l_length <=2) ) THEN
                 ketso:='';
                 chu:='';
                 doi:='';
                 s   := TO_NUMBER(SUBSTR(to_char(iNumber),1,1));
                 IF s>0 THEN
                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' ';
                         chu:=chu||''||doi;
                 ELSE
                         --doi:='kh<ng ';
                         doi:='khong ';
                         chu:=chu||''||doi;
                 END IF;
                     --ketso:=ketso||chu||' '||nvl (loai_tien,'??ng')||' ';
                     if l_length = 1 then
                        ketso:=ketso||chu||' ';
                     else  
                        ketso:='khong'||' '||ketso||chu||' ';
                      end if;
                     
         ELSIF ((iNumber<=99) AND (iNumber>=10) and (l_length <=2)) THEN
                 ketso:='';
                 chu:='';
                 doi:='';
                 s  := TO_NUMBER(SUBSTR(to_char(iNumber),1,1));
                 IF s > 1 THEN
                         --doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' m-?i ';
                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' muoi ';
                         chu:=chu||doi;
                 ELSE
                         --doi:='m-ei ';
                         doi:='muoi ';
                         chu:=chu||doi;
                 END IF;
                 s  := TO_NUMBER(SUBSTR(to_char(iNumber),2,1));
                 IF s>0 THEN
                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' ';
                         if s=5 then
                             --doi :='l?m';
                             doi :='lam';
                         end if;

                         chu:=chu||''||doi;
                 ELSE
                         doi:=' ';
                         chu:=chu||''||doi;
                 END IF;

               --ketso:=ketso||chu||' '||nvl (loai_tien,'??ng')||' ';
               ketso:=ketso||chu||' ';

ELSE
               ketso         :='';
                Dangso      := TO_CHAR(ABS(iNumber),'99999999999999');
              Dangso   := SUBSTR(Dangso,1,15);
              baso_d := SUBSTR(Dangso,1,3);

                 FOR i IN 1..5 LOOP
                       baso      := SUBSTR(Dangso,i*3-2,3);
                         IF baso <> '   ' THEN
                                 IF baso ='000' THEN
                                     IF i=5 THEN chu:='';
                                     ELSE                                         /* i khac 5*/
                                         IF i=2 THEN
                                             IF baso<>'000' THEN
                                                  --chu:='tu ';
                                                  chu:='ty ';
                                             ELSE
                                                 IF baso_d<>'000'THEN
                                                    --chu:='tu ';
                                                    chu:='ty ';
                                                 ELSE
                                                     chu:='ty ';
                                                 END IF;
                                             END IF;
                                         ELSE                                     /* i khac 2 va i khac 5 */
                                                 chu:='';
                                         END IF;
                                     END IF;
                                 ELSE                                             /* baso khac '000' */
                                     temp:=1;
                                     sodau :=SUBSTR(baso,1,1);
                                     sogiua:=SUBSTR(baso,2,1);
                                     socuoi:=SUBSTR(baso,3,1);
                                     chu:='';
                                     doi:='';

                                     if sodau = ' ' then
                                         temp:=2;
                                     end if;

                                     if sogiua= ' ' then
                                         temp:=3;
                                     end if;

                                     FOR j IN temp..3 LOOP
                                         s   := TO_NUMBER(nvl(SUBSTR(baso,j,1),'-1'));
                                         IF s>0 THEN

                                             IF (s=1)and(j=2)THEN
                                                 --doi:='m-ei ';
                                                doi:='muoi ';
                                             ELSE                                /* s=1 and j=2 */
                                                 IF (s=1)and(j=3)THEN
                                                     IF sogiua>'1' THEN
                                                         --doi:='met '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                        doi:='mot '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     ELSE
                                                         --doi:='met '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                        doi:='mot '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     END IF;
                                                 ELSE                            /* s=1 and j=3*/
                                                     IF (s=5    )and(j=3) THEN
                                                         IF (sogiua<>' ')and(sogiua<>'0')THEN
                                                             --doi:='l?m '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                            doi:='lam '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                         ELSE
                                                             doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' '||
                                                                    TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                         END IF;
                                                     ELSE                        /* s=5 and j=3 */
                                                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' '||
                                                                  TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     END IF;                    /* s=5 and j=3 */
                                                 END IF;                        /* s=1 and j=3 */
                                             END IF;                            /* s=1 and j=2 */
                                         ELSE                                    /* s=0 */
                                             IF j=1 THEN
                                                 --doi:='kh<ng tr?m ';
                                                    doi:='khong tram ';
                                             ELSE                                /* j=1 */
                                                 IF j=2 THEN
                                                     IF socuoi='0'THEN
                                                         doi:='';
                                                     ELSE                        /* so cuoi khac 0 */
                                                         doi:='linh ';
                                                     END IF;
                                                 ELSE                            /* j=2 */
                                                     IF baso<>'  0'THEN
                                                         doi:=TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     END IF;
                                                 END IF;                        /* j=2 */
                                             END IF;                            /* j=1 */
                                         END IF;                                /* s>0 */
                                         chu:=chu||''||doi;
                                     END LOOP;                                /* j IN 1..3    */
                                 END IF;                                        /* baso = '000' */
                         END IF;                                                 /* baso <>'   ' */

                         IF (iNumber>999999999999999)or(iNumber<0)or(iNumber=0)THEN
                             ketso:='Kh<ng ?-ic nhEp v?o se ?m, se 0 '||
                                'se lin h?n 999.999.999.999.999';
                         ELSE
                             IF i=5 THEN
                                 --ketso:=ketso||chu||' '||nvl (loai_tien,'??ng')||' ';
                                ketso:=ketso||chu||' ';
                             ELSE
                                 ketso:=ketso||chu||' ';
                             END IF;
                         END IF;
                END LOOP;                                                    /* i IN 1..5    */

       ketso   := loaidau(ketso);
       ketso_kt:=TRIM(ketso);
       --k:=LENGTH('kh<ng tr?m');
     k:=LENGTH('khong tram');
       --IF (SUBSTR(ketso_kt,1,k)='kh<ng tr?m')THEN
     IF (SUBSTR(ketso_kt,1,k)='khong tram')THEN
             ketso_kt:=SUBSTR(ketso_kt,k+1,(LENGTH(ketso_kt)-k));
       END IF;
       ketso_kt:=TRIM(ketso_kt);
       m:=LENGTH('linh');
       IF (SUBSTR(ketso_kt,1,m)='linh')THEN
             ketso_kt:=(SUBSTR(ketso_kt,m+1,LENGTH(ketso_kt)-m));
       END IF;
       ketso_kt:=TRIM(ketso_kt);
       ketso:=ketso_kt;
END IF;
         header_ketso  := lower(SUBSTR(TRIM(ketso),1,1));
         trailer_ketso := SUBSTR(TRIM(ketso),2,LENGTH(ketso)-1);
       ketso                 := header_ketso||trailer_ketso;
         ketso         := loaidau(dau||' '||ketso);
       if l_length>2 then
            ostr:= ' phay'||' '||ketso||' '||mauso;
       else
            ostr:= ' phay'||' '||ketso;
        end if;
            
       
       IF iNumber_v = 0 THEN 
            --ostr:=' '||ostr;
            ostr:=' ';
       END IF;
        
RETURN ostr;

END;

-- bat dau ham chinh
BEGIN

         --iNumber := iNumber_v;
         so_thap_phan:=mod(iNumber_v,1);
         iNumber := (iNumber_v - so_thap_phan);
         if  iNumber < 0 then 
            dau:=' Am ';
            --iNumber := abs(iNumber_v);
            iNumber := abs(iNumber);
         end if;
            
IF ((iNumber<0) OR (iNumber>999999999999999))THEN
         ketso:= 'se tien am hoac '||
                                'so lon hon 999.999.999.999.999';
ELSIF ((iNumber<=9) AND (iNumber>=0)) THEN
                 ketso:='';
                 chu:='';
                 doi:='';
                 s   := TO_NUMBER(SUBSTR(to_char(iNumber),1,1));
                 IF s>0 THEN
                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' ';
                         chu:=chu||''||doi;
                 ELSE
                         --doi:='kh<ng ';
                         doi:='khong ';
                         chu:=chu||''||doi;
                 END IF;
                     --ketso:=ketso||chu||' '||nvl (loai_tien,'??ng')||' ';
                     ketso:=ketso||chu||' '||Num_to_Char_thap_phan(so_thap_phan)||' ';
         ELSIF ((iNumber<=99) AND (iNumber>=10)) THEN
                 ketso:='';
                 chu:='';
                 doi:='';
                 s  := TO_NUMBER(SUBSTR(to_char(iNumber),1,1));
                 IF s > 1 THEN
                         --doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' m-?i ';
                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' muoi ';
                         chu:=chu||doi;
                 ELSE
                         --doi:='m-ei ';
                         doi:='muoi ';
                         chu:=chu||doi;
                 END IF;
                 s  := TO_NUMBER(SUBSTR(to_char(iNumber),2,1));
                 IF s>0 THEN
                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' ';
                         if s=5 then
                             --doi :='l?m';
                             doi :='lam';
                         end if;

                         chu:=chu||''||doi;
                 ELSE
                         doi:=' ';
                         chu:=chu||''||doi;
                 END IF;

               --ketso:=ketso||chu||' '||nvl (loai_tien,'??ng')||' ';
               ketso:=ketso||chu||' '||Num_to_Char_thap_phan(so_thap_phan)||' ';

ELSE
               ketso         :='';
                Dangso      := TO_CHAR(ABS(iNumber),'99999999999999');
              Dangso   := SUBSTR(Dangso,1,15);
              baso_d := SUBSTR(Dangso,1,3);

                 FOR i IN 1..5 LOOP
                       baso      := SUBSTR(Dangso,i*3-2,3);
                         IF baso <> '   ' THEN
                                 IF baso ='000' THEN
                                     IF i=5 THEN chu:='';
                                     ELSE                                         /* i khac 5*/
                                         IF i=2 THEN
                                             IF baso<>'000' THEN
                                                  --chu:='tu ';
                                                  chu:='ty ';
                                             ELSE
                                                 IF baso_d<>'000'THEN
                                                    --chu:='tu ';
                                                    chu:='ty ';
                                                 ELSE
                                                     chu:='';
                                                 END IF;
                                             END IF;
                                         ELSE                                     /* i khac 2 va i khac 5 */
                                                 chu:='';
                                         END IF;
                                     END IF;
                                 ELSE                                             /* baso khac '000' */
                                     temp:=1;
                                     sodau :=SUBSTR(baso,1,1);
                                     sogiua:=SUBSTR(baso,2,1);
                                     socuoi:=SUBSTR(baso,3,1);
                                     chu:='';
                                     doi:='';

                                     if sodau = ' ' then
                                         temp:=2;
                                     end if;

                                     if sogiua= ' ' then
                                         temp:=3;
                                     end if;

                                     FOR j IN temp..3 LOOP
                                         s   := TO_NUMBER(nvl(SUBSTR(baso,j,1),'-1'));
                                         IF s>0 THEN

                                             IF (s=1)and(j=2)THEN
                                                 --doi:='m-ei ';
                                                doi:='muoi ';
                                             ELSE                                /* s=1 and j=2 */
                                                 IF (s=1)and(j=3)THEN
                                                     IF sogiua>'1' THEN
                                                         --doi:='met '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                        doi:='mot '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     ELSE
                                                         --doi:='met '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                        doi:='mot '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     END IF;
                                                 ELSE                            /* s=1 and j=3*/
                                                     IF (s=5    )and(j=3) THEN
                                                         IF (sogiua<>' ')and(sogiua<>'0')THEN
                                                             --doi:='l?m '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                            doi:='lam '||TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                         ELSE
                                                             doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' '||
                                                                    TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                         END IF;
                                                     ELSE                        /* s=5 and j=3 */
                                                         doi:=TRIM(SUBSTR(sodonvi,s*5-4,5))||' '||
                                                                  TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     END IF;                    /* s=5 and j=3 */
                                                 END IF;                        /* s=1 and j=3 */
                                             END IF;                            /* s=1 and j=2 */
                                         ELSE                                    /* s=0 */
                                             IF j=1 THEN
                                                 --doi:='kh<ng tr?m ';
                                                    doi:='khong tram ';
                                             ELSE                                /* j=1 */
                                                 IF j=2 THEN
                                                     IF socuoi='0'THEN
                                                         doi:='';
                                                     ELSE                        /* so cuoi khac 0 */
                                                         doi:='linh ';
                                                     END IF;
                                                 ELSE                            /* j=2 */
                                                     IF baso<>'  0'THEN
                                                         doi:=TRIM(SUBSTR(solon,(i-1)*18+j*6-5,6))||' ';
                                                     END IF;
                                                 END IF;                        /* j=2 */
                                             END IF;                            /* j=1 */
                                         END IF;                                /* s>0 */
                                         chu:=chu||''||doi;
                                     END LOOP;                                /* j IN 1..3    */
                                 END IF;                                        /* baso = '000' */
                         END IF;                                                 /* baso <>'   ' */

                         IF (iNumber>999999999999999)or(iNumber<0)or(iNumber=0)THEN
                             ketso:='Kh<ng ?-ic nhEp v?o se ?m, se 0 '||
                                'se lin h?n 999.999.999.999.999';
                         ELSE
                             IF i=5 THEN
                                 --ketso:=ketso||chu||' '||nvl (loai_tien,'??ng')||' ';
                                ketso:=ketso||chu||' '||Num_to_Char_thap_phan(so_thap_phan)||' ';
                             ELSE
                                 ketso:=ketso||chu||' ';
                             END IF;
                         END IF;
                END LOOP;                                                    /* i IN 1..5    */

       ketso   := loaidau(ketso);
       ketso_kt:=TRIM(ketso);
       --k:=LENGTH('kh<ng tr?m');
     k:=LENGTH('khong tram');
       
     IF (SUBSTR(ketso_kt,1,k)='khong tram')THEN
             ketso_kt:=SUBSTR(ketso_kt,k+1,(LENGTH(ketso_kt)-k));
       END IF;
       ketso_kt:=TRIM(ketso_kt);
       m:=LENGTH('linh');
       IF (SUBSTR(ketso_kt,1,m)='linh')THEN
             ketso_kt:=(SUBSTR(ketso_kt,m+1,LENGTH(ketso_kt)-m));
       END IF;
       ketso_kt:=TRIM(ketso_kt);
--       ketso:=ketso_kt||' '||Num_to_Char_thap_phan(so_thap_phan)||' ';

END IF;

         header_ketso  := UPPER(SUBSTR(TRIM(ketso),1,1));
         trailer_ketso := SUBSTR(TRIM(ketso),2,LENGTH(ketso)-1);
       ketso                 := header_ketso||trailer_ketso;
         ketso         := loaidau(ketso);
       ketso                 := ketso;
       ostr                     := ketso;
RETURN ostr;

END;
-----------------------------------------------------------
/