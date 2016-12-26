Rem
Rem $Header: exechae.sql 06-jun-2006.09:14:49 kneel Exp $
Rem
Rem exechae.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exechae.sql - EXECute HA Event setup
Rem
Rem    DESCRIPTION
Rem      pl/sql blocks for HA events (FAN alerts)
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kneel       06/06/06 - removing auto-inserted SET commands 
Rem    kneel       06/01/06 - subscriber creation for HA Events (FAN alerts) 
Rem    kneel       06/01/06 - subscriber creation for HA Events (FAN alerts) 
Rem    kneel       06/01/06 - Created
Rem



Rem Define a transformation to be used for the notification subscriber
begin
  sys.dbms_transform.create_transformation(
        schema => 'SYS', name => 'haen_txfm_obj',
        from_schema => 'SYS', from_type => 'ALERT_TYPE',
        to_SCHEMA => 'SYS', to_type => 'VARCHAR2',
        transformation => 'SYS.haen_txfm_text(source.user_data)');
EXCEPTION
  when others then
    if sqlcode = -24184 then NULL;
    else raise;
    end if;
end;
/


Rem Define the HAE_SUB subscriber for the alert_que
  
declare  
subscriber sys.aq$_agent; 
begin 
subscriber := sys.aq$_agent('HAE_SUB',null,null); 
dbms_aqadm_sys.add_subscriber(queue_name => 'SYS.ALERT_QUE',
                              subscriber => subscriber,
                              rule => 'tab.user_data.MESSAGE_LEVEL <> '
                                      || sys.dbms_server_alert.level_clear ||
                                      ' AND tab.user_data.MESSAGE_GROUP = ' ||
                                      '''High Availability''',
                              transformation => 'SYS.haen_txfm_obj',
                              properties =>
                                dbms_aqadm_sys.NOTIFICATION_SUBSCRIBER
                                + dbms_aqadm_sys.PUBLIC_SUBSCRIBER); 
EXCEPTION
  when others then
    if sqlcode = -24034 then NULL;
    else raise;
    end if;
end;
/
