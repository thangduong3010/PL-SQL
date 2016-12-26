UPDATE LBACSYS.lbac$props SET value$='1' where name ='OID_STATUS_FLAG';
DROP PUBLIC SYNONYM to_data_label;
DROP PUBLIC SYNONYM to_numeric_data_label;
DROP FUNCTION LBACSYS.to_numeric_data_label;
