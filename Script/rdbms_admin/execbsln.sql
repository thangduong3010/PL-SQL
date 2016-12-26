Rem
Rem $Header: execbsln.sql 08-may-2007.10:43:47 jsoule Exp $
Rem
Rem catbslnj.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catbslnj.sql - BaSeLiNe Jobs for database
Rem
Rem    DESCRIPTION
Rem      Define and schedule the task(s) for BSLN management.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsoule      05/08/07 - do not execute when no diagnostics pack
Rem    jsoule      06/14/06 - created
Rem

------------------------------------------------------------------------------
--  PROGRAM:
--    BSLN_MAINTAIN_STATS_PROG
--
--  DESCRIPTION:
--    Create BSLN compute statistics program.  This program will keep the
--    default baseline's statistics up-to-date.
------------------------------------------------------------------------------
declare
  l_block constant varchar2(512) :=
   'begin '||
     'if prvt_advisor.is_pack_enabled('''||
         dbms_management_packs.DIAGNOSTIC_PACK||
                                      ''') then '||
       'dbsnmp.bsln_internal.maintain_statistics; '||
     'end if; '||
   'end;';
begin
  dbms_scheduler.create_program
    (program_name        => 'BSLN_MAINTAIN_STATS_PROG'
    ,program_type        => 'PLSQL_BLOCK'
    ,program_action      => l_block
    ,number_of_arguments => 0
    ,enabled             => TRUE
    ,comments            => 'Moving window baseline statistics maintenance program');
exception
when others then
  if sqlcode = -27477 then
    NULL;
  else
    raise;
  end if;
end;
/

------------------------------------------------------------------------------
--  SCHEDULE:
--    BSLN_MAINTAIN_STATS_SCHED
--
--  DESCRIPTION:
--    Create BSLN weekly schedule.  This is the schedule for the (re)compu-
--    tation of baseline statistics for the default baseline.
--    The window opens weekly on Saturday night (Sunday morning) at midnight.
------------------------------------------------------------------------------
begin
  dbms_scheduler.create_schedule
    (schedule_name   => 'BSLN_MAINTAIN_STATS_SCHED'
    ,start_date      => TRUNC(sysdate,'D')+7
    ,repeat_interval => 'FREQ=WEEKLY'
    ,comments        => 'Pre-defined schedule for computing moving window baseline statistics');
exception
when others then
  if sqlcode = -27477 then
    NULL;
  else
    raise;
  end if;
end;
/

------------------------------------------------------------------------------
--  JOB:
--    BSLN_MAINTAIN_STATS_JOB
--
--  DESCRIPTION:
--    Create compute statistics job.  This job runs the 
--    BSLN_MAINTAIN_STATS_PROG program on the BSLN_MAINTAIN_STATS_SCHED
--    schedule.
------------------------------------------------------------------------------
begin
  dbms_scheduler.create_job
    (job_name      => 'BSLN_MAINTAIN_STATS_JOB'
    ,program_name  => 'BSLN_MAINTAIN_STATS_PROG'
    ,schedule_name => 'BSLN_MAINTAIN_STATS_SCHED'
    ,enabled       => TRUE
    ,auto_drop     => FALSE
    ,comments      => 'Oracle defined automatic moving window baseline statistics computation job');
exception
when others then
  if sqlcode = -27477 then
    NULL;
  else
    raise;
  end if;
end;
/
