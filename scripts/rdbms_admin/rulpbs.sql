Rem
Rem $Header: rdbms/admin/rulpbs.sql /main/11 2009/01/08 11:05:04 ayalaman Exp $
Rem
Rem rulpbs.sql
Rem
Rem Copyright (c) 2004, 2008, Oracle. All rights reserved.
Rem
Rem    NAME
Rem      rulpbs.sql - Rule Manager public PL/SQL APIs
Rem
Rem    DESCRIPTION
Rem      This script creates the public packages/APIs used for the 
Rem      Rule Manager operations. 
Rem
Rem    NOTES
Rem      See documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    08/08/08 - windowlen for and and any
Rem    ayalaman    12/06/06 - utilities
Rem    ayalaman    05/18/06 - get aggregate value function 
Rem    ayalaman    03/28/05 - collection element to support aggregate 
Rem                           predicates 
Rem    ayalaman    09/13/05 - shared rule conditions and table aliases 
Rem    ayalaman    01/26/05 - shared primitive rule conditions 
Rem    ayalaman    07/18/05 - db change notification 
Rem    ayalaman    08/04/05 - text predicates in rule conditions 
Rem    ayalaman    06/11/05 - xml schema excep handling 
Rem    ayalaman    01/31/05 - rlm4j aliases 
Rem    ayalaman    10/19/04 - create scheduler jobs at the time of 
Rem                           installation 
Rem    ayalaman    05/10/04 - rename rule set to rule class 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    04/13/04 - add notany element in rule condition 
Rem    ayalaman    04/02/04 - Created
Rem


REM 
REM  Rule Manager public PL/SQL APIs
REM 
prompt .. creating Rule Manager PL/SQL Package Specifications

/***************************************************************************/
/***                 Rule Manager Package Definitions                    ***/
/***************************************************************************/

/***************************************************************************/
/*** DBMS_RLMGR : Rule Manager - APIs required to manage a rules engine  ***/
/*** based on Expression Filter feature. For most common rule            ***/
/*** applications, these APIs can be used to create and manage rules in  ***/
/*** the RDBMS. The APIs in this package can be used along with          ***/
/*** Expression Filer APIs to model complex rules applications.          ***/
/***************************************************************************/
create or replace package dbms_rlmgr authid current_user as

  procedure create_rule_class (
              rule_class     IN   VARCHAR2,   -- rule class name --
              event_struct   IN   VARCHAR2,   -- event structure (object) --
              action_cbk     IN   VARCHAR2,   -- action cbk procedure --
              actprf_spec    IN   VARCHAR2 default null,
              rslt_viewnm    IN   VARCHAR2 default null, 
              rlcls_prop     IN   VARCHAR2 default null);

  procedure process_rules (
              rule_class     IN   VARCHAR2,
              event_inst     IN   VARCHAR2, 
              event_type     IN   VARCHAR2 default null);

  procedure process_rules (
              rule_class     IN   VARCHAR2, 
              event_inst     IN   sys.AnyData);

  procedure add_rule (
              rule_class     IN   VARCHAR2,
              rule_id        IN   VARCHAR2, 
              rule_cond      IN   VARCHAR2,
              actprf_nml     IN   VARCHAR2 default null, 
              actprf_vall    IN   VARCHAR2 default null);
  
  procedure delete_rule (
              rule_class     IN   VARCHAR2,
              rule_id        IN   VARCHAR2);

  procedure drop_rule_class (
              rule_class    IN   VARCHAR2);

  procedure grant_privilege (
              rule_class     IN   VARCHAR2,
              priv_type      IN   VARCHAR2, 
              to_user        IN   VARCHAR2);

  procedure revoke_privilege (
              rule_class     IN   VARCHAR2, 
              priv_type      IN   VARCHAR2, 
              from_user      IN   VARCHAR2); 

  --- APIs for obtaining results as a set --
  procedure add_event (
              rule_class     IN   VARCHAR2, 
              event_inst     IN   VARCHAR2,
              event_type     IN   VARCHAR2 default null);

  procedure add_event (
              rule_class     IN   VARCHAR2, 
              event_inst     IN   sys.AnyData);

  function consume_event (
              rule_class     IN   VARCHAR2, 
              event_ident    IN   VARCHAR2) return number;

  function consume_prim_events (
              rule_class     IN   VARCHAR2, 
              event_idents   IN   RLM$EVENTIDS) return number;
 

  procedure reset_session (
              rule_class     IN   VARCHAR2);

  --- event structure designing APIs ---
  procedure create_event_struct (
              event_struct   IN   VARCHAR2);

  procedure add_elementary_attribute (
              event_struct   IN   VARCHAR2,    --- event structure name
              attr_name      IN   VARCHAR2,    --- attr name
              attr_type      IN   VARCHAR2,    --- attr type
              attr_defvl     IN   VARCHAR2     --- default value for attr
                         default NULL);

  procedure add_elementary_attribute (
              event_struct   IN   VARCHAR2,    --- attr set name
              attr_name      IN   VARCHAR2,    --- table alias (name)
              tab_alias      IN   rlm$table_alias);  -- table alias for

  procedure add_elementary_attribute (
              event_struct   IN   VARCHAR2,    --- attr set name
              attr_name      IN   VARCHAR2,    --- attr name
              attr_type      IN   VARCHAR2,    --- attr type
              text_pref      IN   exf$text);   --- text data type pref

  procedure add_functions (
              event_struct   IN   VARCHAR2,    --- attr set name 
              funcs_name     IN   VARCHAR2);   --- function/package/type name

  procedure drop_event_struct (
              event_struct   IN   VARCHAR2);

  procedure sync_text_indexes (
              rule_class     IN   VARCHAR2);

  procedure purge_events (
              rule_class     IN   VARCHAR2);
  
  procedure create_conditions_table (
              cond_table     IN   VARCHAR2,
              pevent_struct  IN   VARCHAR2, 
              stg_clause     IN   VARCHAR2 default null);

  procedure create_conditions_table (
              cond_table     IN   VARCHAR2,
              tab_alias      IN   rlm$table_alias, 
              stg_clause     IN   VARCHAR2 default null);

  procedure drop_conditions_table (
              cond_table     IN   VARCHAR2); 

  procedure create_expfil_indexes (
              rule_class     IN   VARCHAR2,
              coll_stats     IN   VARCHAR2 default 'NO');
  
  procedure drop_expfil_indexes (
              rule_class     IN   VARCHAR2);

  procedure create_interface (
              rule_class     IN   VARCHAR2, 
              interface_nm   IN   VARCHAR2);
  
  procedure drop_interface (
              interface_nm   IN   VARCHAR2);

  procedure extend_event_struct (
              event_struct   IN   VARCHAR2,
              attr_name      IN   VARCHAR2, 
              attr_type      IN   VARCHAR2,
              attr_defvl     IN   VARCHAR2 default null); 

  function condition_ref (
              rulecond       IN   VARCHAR2, 
              eventnm        IN   VARCHAR2) return VARCHAR2 deterministic;

  function get_aggregate_value (
              rule_class     IN   VARCHAR2,    
              event_ident    IN   VARCHAR2, 
              aggr_func      IN   VARCHAR2) return VARCHAR2; 

end dbms_rlmgr;
/

show errors;

create or replace public synonym dbms_rlmgr for exfsys.dbms_rlmgr;

grant execute on dbms_rlmgr to public;

/***************************************************************************/
/*** RLM$CREATE_SCHEDULER_JOBS : Create the jobs for timely event clean- ***/
/*** up and for execution of scheduled actions                           ***/
/***************************************************************************/
create or replace procedure rlm$create_scheduler_jobs is
begin
  begin 
    dbms_scheduler.create_job(
                 job_name   =>'EXFSYS.RLM$EVTCLEANUP',
                 job_action =>
                      'begin dbms_rlmgr_dr.cleanup_events; end;',
                 job_type   => 'plsql_block',
                 number_of_arguments => 0,
                 start_date => systimestamp+0.0001,
                 repeat_interval => 'FREQ = HOURLY; INTERVAL = 1',
                 auto_drop => FALSE,
                 enabled    => true);
  exception 
    when others then 
      if (SQLCODE = -27477) then
        dbms_scheduler.set_attribute ('EXFSYS.RLM$EVTCLEANUP',
                                      'start_date', systimestamp);
        dbms_scheduler.enable('EXFSYS.RLM$EVTCLEANUP');
      else
        raise;
      end if;
  end;

  begin
    dbms_scheduler.create_job(
                 job_name   =>'EXFSYS.RLM$SCHDNEGACTION',
                 job_action =>
          'begin dbms_rlmgr_dr.execschdactions(''RLM$SCHDNEGACTION''); end;',
                 job_type   => 'plsql_block',
                 number_of_arguments => 0,
                 start_date => systimestamp+0.0001,
                 repeat_interval => 'FREQ=MINUTELY;INTERVAL=60',
                 auto_drop => FALSE,
                 enabled    => true);
  exception 
    when others then 
      if (SQLCODE = -27477) then
        dbms_scheduler.set_attribute ('EXFSYS.RLM$SCHDNEGACTION',
                                      'start_date', systimestamp);
        dbms_scheduler.enable('EXFSYS.RLM$SCHDNEGACTION');
      else
        raise;
      end if;
  end;
end rlm$create_scheduler_jobs;
/

show errors;

/***************************************************************************/
/***  XML Schema defintions for rule class properties file and the rule  ***/
/***  conditions syntax                                                  ***/
/***************************************************************************/
begin
  -- rule class properties schema: the properties file could be one of the 
  -- following forms --
  /*
     <simple ordering= "rlm$rule.actpref1, rlm$rule.actpref2 ..."
             autocommit = "[FALSE|TRUE*]"
             dmlevents = "[IUD]"
             consumption="[EXCLUSIVE|SHARED*]"
             storage= "tablespace TBS_1"/>

     <composite ordering= "Flt.Xyz, rlm$rule.actpref1, rlm$rule.actpref2 "
                autocommit = "[YES|NO*]"
                consumption="[EXCLUSIVE|SHARED*]"
                storage="tablespace TBS_1"
                duration="[transaction*| session | x [min | hours | days]]
                equal="Flt.Xyz, Car.Xyz">
        <object type="AddRentalCar"
                consumption="[EXCLUSIVE|SHARED]"
                duration="[transaction | session | x [min | hours | days]]/>
        <object type="AddFlight"
                consumption="[EXCLUSIVE|SHARED]"
                duration="[transaction | session | x [min | hours | days]]/>
     </composite>
  */
  -- remove target namespace specification if we like to allow xmlschema 
  -- instances without schema specification --
  dbms_xmlschema.registerschema(
   schemaurl =>'http://xmlns.oracle.com/rlmgr/rclsprop.xsd',
   local =>  false,
   gentypes => false,
   genbean => false,
   gentables => false,
   schemadoc =>
   '<xsd:schema
            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            xmlns:xdb="http://xmlns.oracle.com/xdb"
            xmlns:rlmp="http://xmlns.oracle.com/rlmgr/rclsprop.xsd"
            elementFormDefault="qualified"
            targetNamespace="http://xmlns.oracle.com/rlmgr/rclsprop.xsd">

      <xsd:element name="simple" type="rlmp:SimpleRuleClsProp"/>
      <xsd:element name="composite" type="rlmp:CompositeRuleClsProp">
        <xsd:unique name="objtype">
          <xsd:selector xpath="./*"/>
          <xsd:field xpath="@type"/>
        </xsd:unique>
      </xsd:element>

      <xsd:complexType name="SimpleRuleClsProp">
        <xsd:complexContent>
          <xsd:restriction base="xsd:anyType">   <!-- empty element -->
            <xsd:attribute name="ordering" type="xsd:string"/>
            <xsd:attribute name="storage" type="xsd:string"/>
            <xsd:attribute name="autocommit">
              <xsd:simpleType>
                <xsd:restriction base="xsd:string">
                  <xsd:enumeration value="yes"/>
                  <xsd:enumeration value="no"/>
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="dmlevents">
              <xsd:simpleType>
                <xsd:restriction base="xsd:string">
                  <xsd:enumeration value="I"/>
                  <xsd:enumeration value="IU"/>
                  <xsd:enumeration value="IUD"/>
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="cnfevents">
              <xsd:simpleType>
                <xsd:restriction base="xsd:string">
                  <xsd:enumeration value="I"/>
                  <xsd:enumeration value="IU"/>
                  <xsd:enumeration value="IUD"/>
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="consumption">
              <xsd:simpleType>
                <xsd:restriction base="xsd:string">
                  <xsd:enumeration value="exclusive"/>
                  <xsd:enumeration value="shared"/>
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
          </xsd:restriction>
        </xsd:complexContent>
      </xsd:complexType>

      <xsd:group name="ObjectOrCollectionProp">
        <xsd:choice>
          <xsd:element name="object" type="rlmp:PrimEventProp" 
                       minOccurs="0" maxOccurs="1"/>
          <xsd:element name="collection" type="rlmp:CollectionProp" 
                       minOccurs="0" maxOccurs="1"/>
        </xsd:choice>
      </xsd:group>

      <xsd:complexType name="CompositeRuleClsProp">
        <xsd:sequence> 
          <xsd:group ref="rlmp:ObjectOrCollectionProp" minOccurs="0"
                       maxOccurs="unbounded"/>
        </xsd:sequence>

        <xsd:attribute name="ordering" type="xsd:string"/>
        <xsd:attribute name="storage" type="xsd:string"/>
        <xsd:attribute name="autocommit">
          <xsd:simpleType>
            <xsd:restriction base="xsd:string">
              <xsd:enumeration value="yes"/>
              <xsd:enumeration value="no"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:attribute>
        <xsd:attribute name="dmlevents">
          <xsd:simpleType>
            <xsd:restriction base="xsd:string">
              <xsd:enumeration value="I"/>
              <xsd:enumeration value="IU"/>
              <xsd:enumeration value="IUD"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:attribute>
        <xsd:attribute name="equal" type="xsd:string"/>
        <xsd:attribute name="consumption">
          <xsd:simpleType>
            <xsd:restriction base="xsd:string">
              <xsd:enumeration value="exclusive"/>
              <xsd:enumeration value="shared"/>
              <xsd:enumeration value="rule"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:attribute>
        <xsd:attribute name="duration">
          <xsd:simpleType>
            <xsd:restriction base="xsd:string">
              <xsd:pattern value="transaction"/>
              <xsd:pattern value="session"/>
              <xsd:pattern value="([1-9]|\d{2}|\d{3}|\d{4}) (minutes|hours|days)"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:attribute>
      </xsd:complexType>

      <xsd:complexType name="PrimEventProp">
        <xsd:complexContent>
          <xsd:restriction base="xsd:anyType">
            <xsd:attribute name="type" type="xsd:string" use="required"/>
            <xsd:attribute name="consumption">
              <xsd:simpleType>
                <xsd:restriction base="xsd:string">
                  <xsd:enumeration value="exclusive"/>
                  <xsd:enumeration value="shared"/>
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="duration">
              <xsd:simpleType>
                <xsd:restriction base="xsd:string">
               <!--  <xsd:pattern value="transaction"/> 
                  <xsd:pattern value="session"/> -->
                  <xsd:pattern value="call"/>
                  <xsd:pattern value="([1-9]|\d{2}|\d{3}|\d{4}) (minutes|hours|days)"/>
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
          </xsd:restriction>
        </xsd:complexContent>
      </xsd:complexType>

      <xsd:complexType name="CollectionProp">
        <xsd:complexContent>
          <xsd:restriction base="xsd:anyType">
            <xsd:attribute name="type" type="xsd:string" use="required"/>
            <xsd:attribute name="groupby" type="xsd:string"/>
            <xsd:attribute name="compute" type="xsd:string"/>
          </xsd:restriction>
        </xsd:complexContent>
      </xsd:complexType>

    </xsd:schema>');

  dbms_xmlschema.registerschema(
   schemaurl =>'http://xmlns.oracle.com/rlmgr/rulecond.xsd',
   local =>  false,
   gentypes => false,
   genbean => false,
   gentables => false,
   schemadoc =>
   '<xsd:schema
            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            xmlns:xdb="http://xmlns.oracle.com/xdb"
            xmlns:rlmc="http://xmlns.oracle.com/rlmgr/rulecond.xsd"
            elementFormDefault="qualified"
            targetNamespace="http://xmlns.oracle.com/rlmgr/rulecond.xsd">

      <xsd:element name="condition">
        <xsd:complexType mixed="true">
          <xsd:choice>
            <xsd:element name="and" type="rlmc:AndType"
                                    minOccurs="0" maxOccurs="1"/>
            <xsd:element name="any" type="rlmc:AnyType" 
                                    minOccurs="0" maxOccurs="1"/>
            <xsd:element name="object" type="rlmc:ObjectCondType"
                                    minOccurs="0" maxOccurs="1"/>
          </xsd:choice>
        </xsd:complexType>
        <xsd:unique name="objNamesAny">
          <xsd:selector xpath=".//object"/>
          <xsd:field xpath="@name"/>
        </xsd:unique>            
      </xsd:element>

      <xsd:group name="ObjectOrCollectionCondition">
        <xsd:choice>
          <xsd:element name="object" type="rlmc:ObjectCondType" 
                       minOccurs="1" maxOccurs="1"/>
          <xsd:element name="collection" type="rlmc:CollectionCondType"
                       minOccurs="1" maxOccurs="1"/>
        </xsd:choice>
      </xsd:group>

      <xsd:complexType name="AndType">
        <xsd:sequence>
          <xsd:group ref="rlmc:ObjectOrCollectionCondition"
                       minOccurs="1" maxOccurs="unbounded"/>
          <xsd:choice>
            <xsd:element name="not" type="rlmc:NotCondType" 
                         minOccurs="0" maxOccurs="1"/>
            <xsd:element name="notany" type="rlmc:NotAnyCondType"
                         minOccurs="0" maxOccurs="1"/>
          </xsd:choice>
        </xsd:sequence>   
        <xsd:attribute name="join"  type="xsd:string"/>
        <xsd:attribute name="equal" type="xsd:string"/> 
        <xsd:attribute name="having" type="xsd:string"/>
        <xsd:attribute name="windowlen" type="xsd:string"/>
        <xsd:attribute name="sequence">
          <xsd:simpleType>
            <xsd:restriction base="xsd:string">
              <xsd:enumeration value="yes"/>
              <xsd:enumeration value="no"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:attribute>
      </xsd:complexType>

      <xsd:complexType name="NotCondType">
        <xsd:sequence>
          <xsd:element name="object" type="rlmc:ObjectCondType" 
                                     minOccurs="1" maxOccurs="1"/>   
        </xsd:sequence>
        <xsd:attribute name="by" type="xsd:string"/>
        <xsd:attribute name="join" type="xsd:string"/>
      </xsd:complexType>

      <xsd:complexType name="NotAnyCondType">
        <xsd:sequence>
          <xsd:element name="object" type="rlmc:ObjectCondType" 
                                     minOccurs="2" maxOccurs="unbounded"/>
        </xsd:sequence>
        <xsd:attribute name="count" type="xsd:positiveInteger"/>
        <xsd:attribute name="by" type="xsd:string"/>
        <xsd:attribute name="join" type="xsd:string"/>
      </xsd:complexType>

      <xsd:complexType name="AnyType">
        <xsd:sequence>
          <xsd:element name="object" type="rlmc:ObjectCondType" minOccurs="1"       
                       maxOccurs="unbounded"/>
        </xsd:sequence>
        <xsd:attribute name="count" type="xsd:positiveInteger"/>
        <xsd:attribute name="join"  type="xsd:string"/>
        <xsd:attribute name="equal" type="xsd:string"/>
        <xsd:attribute name="windowlen" type="xsd:string"/>
        <xsd:attribute name="sequence">
          <xsd:simpleType>
            <xsd:restriction base="xsd:string">
              <xsd:enumeration value="yes"/>
              <xsd:enumeration value="no"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:attribute>
      </xsd:complexType> 

      <xsd:complexType name="ObjectCondType">
        <xsd:simpleContent>
          <xsd:extension base="xsd:string">
            <xsd:attribute name="name" type="xsd:string" use="required"/>
            <xsd:attribute name="ref" type="xsd:string"/>
          </xsd:extension>
        </xsd:simpleContent>
      </xsd:complexType>

      <xsd:complexType name="CollectionCondType">
        <xsd:simpleContent>
          <xsd:extension base="xsd:string">
            <xsd:attribute name="name" type="xsd:string" use="required"/>
            <xsd:attribute name="groupby" type="xsd:string" use="required"/> 
            <xsd:attribute name="having" type="xsd:string"/>
            <xsd:attribute name="compute" type="xsd:string"/>
            <xsd:attribute name="windowsize" type="xsd:string"/>
            <xsd:attribute name="windowlen" type="xsd:string"/>
          </xsd:extension>
        </xsd:simpleContent>
      </xsd:complexType>
    </xsd:schema>');
exception 
  when others then 
   if (SQLCODE = -31085) then null;
   else raise; 
   end if;
end;
/

show errors;

/***************************************************************************/
/***      Rule Manager for Java (RLM4J) Package Specification            ***/
/***************************************************************************/

/***************************************************************************/
/*** DBMS_RLM4J_DICTMAINT : Invoker rights package to maintain the RLM4J ***/
/*** Dictionary                                                          ***/
/***************************************************************************/
CREATE OR REPLACE PACKAGE dbms_rlm4j_dictmaint AUTHID current_user AS
  
  -- Return the case-preserved names ---
  FUNCTION dict_name(rawname IN VARCHAR2)
    RETURN VARCHAR2;

  -- Record the event-structure and java package/class mapping
  PROCEDURE add_event_struct (esowner     VARCHAR2,
                              esname      VARCHAR2,
                              javapkg     VARCHAR2, 
                              javacls     VARCHAR2,
                              iscomposite NUMBER);        

  -- Record the rule class, event-structure and java package/class
  -- mapping
  PROCEDURE add_rule_class( rleowner VARCHAR2,
                            rlename  VARCHAR2,
                            evsname  VARCHAR2,
                            javapkg  VARCHAR2,
                            javacls  VARCHAR2);

  PROCEDURE add_attribute_alias (esname   VARCHAR2, 
                                 alsname  VARCHAR2, 
                                 alsexpr  VARCHAR2,
                                 alstype  NUMBER default 0); 

  PROCEDURE validate_rulecls_properties(propdoc VARCHAR2);

  PROCEDURE validate_rule_condition(conddoc VARCHAR2);
  
END dbms_rlm4j_dictmaint;
/

show errors;

GRANT execute ON exfsys.dbms_rlm4j_dictmaint TO PUBLIC;

