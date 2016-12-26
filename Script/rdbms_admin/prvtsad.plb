CREATE OR REPLACE VIEW LBACSYS.sa$admin AS
SELECT POL#, pol_name, admin_dn usr_name
  FROM LBACSYS.lbac$pol P,
       LBACSYS.lbac$policy_admin PA
 WHERE P.pol_name = PA.policy_name;
CREATE OR REPLACE VIEW LBACSYS.all_sa_policies AS
   SELECT p.pol_name as policy_name, p.column_name, p.status, p.policy_options
     FROM LBACSYS.sa$pol p
    WHERE sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
          pol# in (select pol# from LBACSYS.sa$admin where
                   usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME')));
CREATE OR REPLACE VIEW LBACSYS.all_sa_schema_policies AS
  SELECT s.policy_name, schema_name, s.status, schema_options
    FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_schema_policies s
   WHERE p.pol_name = s.policy_name 
     AND (sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
         pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))));
CREATE OR REPLACE VIEW LBACSYS.all_sa_table_policies AS
  SELECT t.policy_name, schema_name, table_name, t.status,
         table_options, function, predicate
    FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_table_policies t
   WHERE p.pol_name=t.policy_name 
     AND (sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
         pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))));
CREATE OR REPLACE VIEW LBACSYS.all_sa_data_labels AS
  SELECT p.pol_name AS policy_name,
         l.slabel AS label,
         lbac_label.to_tag(l.lab#) AS label_tag
   FROM LBACSYS.lbac$lab l, LBACSYS.sa$pol p
  WHERE p.pol# = l.pol# 
    AND BITAND(l.flags, 1) = 1
    AND ((sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
          p.pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))))
         OR
         lbacsys.lbac$sa.enforce_read(p.pol_name, l.ilabel)>0);
CREATE OR REPLACE VIEW LBACSYS.all_sa_labels AS
  SELECT p.pol_name AS policy_name,
         l.slabel AS label,
         lbac_label.to_tag(l.lab#) AS label_tag,
         DECODE (l.flags,2,'USER LABEL',
                 3, 'USER/DATA LABEL', 'UNDEFINED') AS label_type
   FROM LBACSYS.lbac$lab l, LBACSYS.sa$pol p
  WHERE p.pol# = l.pol# 
    AND ((sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
          p.pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))))
         OR
         LBACSYS.lbac$sa.enforce_read(p.pol_name, l.ilabel)>0);
CREATE OR REPLACE VIEW LBACSYS.all_sa_levels AS
   SELECT p.pol_name as policy_name, l.level# AS level_num, 
          l.code AS short_name, l.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.sa$levels l
    WHERE p.pol# = l.pol#       
      AND (sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
           p.pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))))
    UNION
   SELECT p.pol_name as policy_name, l.level# AS level_num,
          l.code AS short_name, l.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.sa$levels l, LBACSYS.sa$user_levels ul
    WHERE p.pol# = l.pol#
      and l.pol# = ul.pol#
      and l.level# <= ul.max_level
      and ul.usr_name = sa_session.sa_user_name(lbac_cache.policy_name(ul.pol#));
CREATE OR REPLACE VIEW LBACSYS.all_sa_compartments AS
   SELECT p.pol_name as policy_name, c.comp# AS comp_num,
          c.code AS short_name, c.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.sa$compartments c
    WHERE p.pol# = c.pol#
      and ((sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
            p.pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))))
           OR
          (c.pol#,c.comp#) in (select pol#,comp#
                               from LBACSYS.sa$user_compartments
                               where usr_name = sa_session.sa_user_name(
                                                 lbac_cache.policy_name(pol#))));
CREATE OR REPLACE VIEW LBACSYS.all_sa_groups AS
   SELECT p.pol_name as policy_name, g.group# AS group_num,
          g.code AS short_name, g.name AS long_name,
          g.parent# AS parent_num, pg.code AS parent_name
     FROM LBACSYS.sa$pol p, LBACSYS.sa$groups g, LBACSYS.sa$groups pg
    WHERE p.pol# = g.pol# 
      AND g.pol# = pg.pol# (+) 
      AND g.parent# = pg.group#(+)
      and ((sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
            p.pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))))
           OR
          (g.pol#,g.group#) in (select pol#,group#
                                from LBACSYS.sa$user_groups
                                where usr_name = sa_session.sa_user_name(
                                                 lbac_cache.policy_name(pol#))));
CREATE OR REPLACE VIEW LBACSYS.all_sa_group_hierarchy AS
   SELECT p.pol_name as policy_name, g.hierarchy_level, g.group_name
     FROM (SELECT LEVEL AS hierarchy_level,
                  RPAD(' ',2*LEVEL,' ') || code || ' - ' ||  name AS group_name,
                  pol# 
             FROM LBACSYS.sa$groups
                  CONNECT BY PRIOR pol#=pol# AND PRIOR group#=parent#
            START WITH ((pol# in (select pol# from LBACSYS.lbac$pol  p,
                                                   LBACSYS.lbac$policy_admin pa
                         where (sys_context('USERENV','SESSION_USER') in
                               ('SYS','LBACSYS') OR
                                p.pol_name = pa.policy_name AND
                                pa.admin_dn=UPPER(sys_context('USERENV',
                                                  'EXTERNAL_NAME'))))
                         and parent# IS NULL)
                        or
                        (pol#,group#) in
                        (select pol#,group# from LBACSYS.sa$user_groups
                          where usr_name = sa_session.sa_user_name(
                                           lbac_cache.policy_name(pol#))))
          ) g,
          sa$pol p
    WHERE g.pol#=p.pol#;
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_levels AS
   SELECT DISTINCT p.pol_name AS policy_name, 
          ul.usr_name AS user_name,
          lmax.code AS max_level, 
          lmin.code AS min_level, 
          ldef.code AS def_level, 
          lrow.code AS row_level
     FROM LBACSYS.sa$pol p, LBACSYS.sa$user_levels ul, 
          LBACSYS.sa$levels lmax, LBACSYS.sa$levels lmin, 
          LBACSYS.sa$levels ldef, LBACSYS.sa$levels lrow
    WHERE p.pol#=ul.pol# 
      AND ul.pol#=lmax.pol#  
      AND ul.pol#=lmin.pol#  
      AND ul.pol#=ldef.pol#  
      AND ul.pol#=lrow.pol#  
      AND ul.max_level = lmax.level# 
      AND ul.min_level = lmin.level# 
      AND ul.def_level = ldef.level#
      AND ul.row_level = lrow.level# 
      AND ((sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
            p.pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))))
           or
           ul.usr_name = sa_session.sa_user_name(lbac_cache.policy_name(p.pol#)));
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_compartments AS
   SELECT p.pol_name AS policy_name, uc.usr_name AS user_name,
          c.code AS comp, DECODE(uc.rw_access,'1','WRITE','READ') AS rw_access,
          uc.def_comp, uc.row_comp
     FROM LBACSYS.sa$pol p, LBACSYS.sa$user_compartments uc, 
          LBACSYS.sa$compartments c
    WHERE p.pol#=uc.pol# 
      AND uc.pol#=c.pol# 
      AND uc.comp# = c.comp#
      AND ((sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
            p.pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))))
           or
           uc.usr_name = sa_session.sa_user_name(lbac_cache.policy_name(p.pol#)));
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_groups AS
   SELECT p.pol_name AS policy_name, ug.usr_name AS user_name,
          g.code AS grp, DECODE(ug.rw_access,'1','WRITE','READ') AS rw_access,
          ug.def_group, ug.row_group
     FROM LBACSYS.sa$pol p, LBACSYS.sa$user_groups ug, LBACSYS.sa$groups g
    WHERE p.pol#=ug.pol# 
      AND ug.pol#=g.pol# 
      AND ug.group# = g.group#
      AND ((sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
            p.pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))))
           or
           ug.usr_name = sa_session.sa_user_name(lbac_cache.policy_name(p.pol#)));
CREATE OR REPLACE VIEW LBACSYS.all_sa_users AS
   SELECT user_name,  u.policy_name, user_privileges,
          'MAX READ LABEL=''' || LABEL1 || ''',MAX WRITE LABEL=''' || LABEL2
          || ''',MIN WRITE LABEL=''' || LABEL3 || ''',DEFAULT READ LABEL='''
          || LABEL4 || ''',DEFAULT WRITE LABEL=''' || LABEL5
          || ''',DEFAULT ROW LABEL=''' || LABEL6 || ''''
          AS user_labels,
          LABEL1 AS MAX_READ_LABEL, LABEL2 AS MAX_WRITE_LABEL,
          LABEL3 AS MIN_WRITE_LABEL , LABEL4 AS DEFAULT_READ_LABEL,
          LABEL5 AS DEFAULT_WRITE_LABEL, LABEL6 AS DEFAULT_ROW_LABEL
     FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_users u
    WHERE p.pol_name=u.policy_name
      AND ((sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
            p.pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))))
           or
           u.user_name = sa_session.sa_user_name(lbac_cache.policy_name(p.pol#)));
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_labels AS
   SELECT user_name,
          policy_name,
          user_labels as labels,
          MAX_READ_LABEL,
          MAX_WRITE_LABEL, MIN_WRITE_LABEL ,DEFAULT_READ_LABEL,
          DEFAULT_WRITE_LABEL ,  DEFAULT_ROW_LABEL
     FROM LBACSYS.all_sa_users
    WHERE MAX_READ_LABEL IS NOT NULL;
CREATE OR REPLACE VIEW LBACSYS.all_sa_programs AS
   SELECT schema_name, program_name, p.policy_name, prog_privileges,
          prog_labels
     FROM LBACSYS.sa$pol, LBACSYS.dba_lbac_programs p
    WHERE pol_name=p.policy_name 
      AND (sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
           pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))));
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_privs AS
  SELECT user_name,
         policy_name,
         user_privileges
    FROM LBACSYS.all_sa_users 
   WHERE user_privileges IS NOT NULL;
CREATE OR REPLACE VIEW LBACSYS.all_sa_prog_privs AS
  SELECT schema_name, program_name, policy_name, 
         prog_privileges as program_privileges
    FROM LBACSYS.all_sa_programs
   WHERE prog_privileges IS NOT NULL;
CREATE OR REPLACE VIEW LBACSYS.all_sa_audit_options AS
  SELECT a.policy_name, a.user_name, APY, REM, SET_, PRV
    FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_audit_options a
   WHERE p.pol_name = a.policy_name 
     AND  (sys_context('USERENV','SESSION_USER') in ('SYS','LBACSYS') OR
           p.pol# in (select pol# from LBACSYS.sa$admin where
                  usr_name=UPPER(sys_context('USERENV','EXTERNAL_NAME'))));
