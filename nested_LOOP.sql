DECLARE
   brokerage_id_limit   TRANSACTIONS.BROKERAGE_id%TYPE := 10;
   stock_id_limit       TRANSACTIONS.STOCK_ID%TYPE := 10;
   time_id              TRANSACTIONS.TIME_ID%TYPE := 45;
BEGIN
   -- outer loop. similar transactions for every broker
   FOR x IN 1 .. brokerage_id_limit
   LOOP
      -- inner loop. every brokerage will either buy or sell
      FOR i IN 1 .. stock_id_limit
      LOOP
         -- test for every even value of i
         IF MOD (i, 2) = 0
         THEN
            -- insert SELL record
            INSERT INTO transactions (stock_id,
                                      time_id,
                                      brokerage_id,
                                      buy_sell_indicator,
                                      number_shares,
                                      price)
                 VALUES (i,
                         time_id,
                         x,
                         'S',
                         100 + x + i,
                         10 + x + 1);
         ELSE
            -- insert BUY record
            INSERT INTO transactions (stock_id,
                                      time_id,
                                      brokerage_id,
                                      buy_sell_indicator,
                                      number_shares,
                                      price)
                 VALUES (i,
                         time_id,
                         x,
                         'B',
                         200 + x + i,
                         20 + x + 1);
         END IF;
      END LOOP;
   END LOOP;
END;