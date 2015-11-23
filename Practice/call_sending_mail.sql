BEGIN
  send_mail(
			p_to        => 'tamdv@ists.com.vn',
            p_from      => 'thangduong.hanu@gmail.com',
            p_subject   => 'Test Message',
            p_message   => 'This is a test message.',
            p_smtp_host => 'smtp.gmail.com');
END;

