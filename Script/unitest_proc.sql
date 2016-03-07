declare
	l_isbn varchar2(13) := '1-56592-335-9';
	l_title varchar2(200) := 'Oracle PL/SQL Programming';
	l_summary varchar2(2000) := 'Reference for PL/SQL developers';
	l_author varchar2(200) := 'Feuerstein, Steven, and Bill';
	l_date_published date := to_date('01-SEP-1997', 'DD-MON-YYYY');
	l_page_count number := 987;
	l_barcode_id varchar2(100) := '1000000001';

	cursor bookCountCur is select count(*) from books;
	cursor copiesCountCur is select count(*) from book_copies;
	cursor bookMatchCur is select count(*) from books
				where isbn = l_isbn and title = l_title and summary = l_summary
				and author = l_author and date_published = l_date_published
				and page_count = l_page_count;
	cursor copiesMatchCur is select count(*) from book_copies
				where isbn = l_isbn and barcode_id = l_barcode_id;
	how_many number;
	l_sqlcode number;
begin
	delete book_copies;
	delete books;

	add_book(isbn_in => l_isbn, barcode_id_in => l_barcode_id, title_in => l_title, summary_in => l_summary, author_in => l_author, date_published_in => l_date_published, page_count_in => l_page_count);

	open bookMatchCur;
	fetch bookMatchCur into how_many;
	reporteqbool('add procedure, book fetch matches insert', expected_value => TRUE, actual_value => bookMatchCur%found);
	close bookMatchCur;

	begin
		add_book(isbn_in => null, barcode_id_in => 'foo', title_in => 'foo', summary_in => 'foo', author_in => 'foo',
			date_published_in => sysdate, page_count_in => 0);
		l_sqlcode := SQLCODE;
	exception
		when others then
			l_sqlcode := sqlcode;
	end;

	reporteq('add procedure, detection of NULL input', expected_value => '-6502', actual_value => to_char(l_sqlcode));

	open bookCountCur;
	fetch bookCountCur into how_many;
	reporteq('add procedure, book_record count', expected_value => '1', actual_value => how_many);
	close bookCountCur;

	open copiesCountcur;
	fetch copiesCountCur into how_many;
	reporteq('add procedure, book_copy record count', expected_value => '1', actual_value => how_many);
	close copiesCountCur;

	open copiesMatchCur;
	fetch copiesMatchCur into how_many;
	reporteqbool('add procedure, book copy fetch matches insert', expected_value => TRUE, actual_value => copiesMatchCur%found);
	close copiesMatchCur;

	begin
		add_book(isbn_in => l_isbn, barcode_id_in => l_barcode_id, title_in => l_title, summary_in => l_summary,
			author_in => l_author, date_published_in => l_date_published, page_count_in => l_page_count);
		l_sqlcode := sqlcode;
	exception
		when others then
			l_sqlcode := sqlcode;
	end;

	reporteq('add procedure, detection of duplicate isbn', expected_value => '-1', actual_value => l_sqlcode);
end;
/
