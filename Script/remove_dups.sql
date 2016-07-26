# using subquery
delete from table_name t1
	where t1.rowid > any (select t2.rowid from table_name t2
							where t1.col1 = t2.col1
							and t1.col2 = t2.col2);