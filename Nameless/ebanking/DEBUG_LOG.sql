CREATE OR REPLACE PROCEDURE DEMOEBANKING.debug_log(line in varchar2) is
    l_path  varchar2(255) := null;
    flog    utl_file.file_type;
    l_conf  EB_CONFIG%ROWTYPE;
    l_file  varchar2(255) := null;
begin
    if FN_GET_ebconfig('ENABLE_DEBUG_DB', 'SYS', l_conf) <> 0 then
        RETURN;
    end if;
    if trim(l_conf.CONFIG_VALUE) <> 'Y' then
        RETURN;
    end if;
    if FN_GET_ebconfig('DB_DEBUG_PATH', 'SYS', l_conf) <> 0 then
        RETURN;
    end if;
    l_path := l_conf.CONFIG_VALUE;
    if FN_GET_ebconfig('DB_DEBUG_FILE', 'SYS', l_conf) <> 0 then
        RETURN;
    end if;
    l_file := l_conf.CONFIG_VALUE;
    if utl_file.is_open(flog) then
       utl_file.fclose(flog);
    end if; -- is_open
    flog := utl_file.fopen(l_path, l_file, 'a', 32767);
    utl_file.put_line(flog, '['||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS')||'] '||line);
    utl_file.fflush(flog);
    utl_file.fclose(flog);
exception
    when others then
        null;
end debug_log;
/