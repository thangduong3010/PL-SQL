# $Id: pllp.c,v 1.1 2001/11/30 23:26:33 bill Exp $
# From "Learning Oracle PL/SQL" page 299

# Send input text to default line printer ("lp" device)
# (Thanks Fred Polizo for helping with this program)

#include <stdio.h>
#include <sys/wait.h>

int lp(char *text)
{
    char *cmd = "/usr/bin/lp > /tmp/$$.pllp.out 2>&1";
    int childstatus;
    FILE *lppipe;
    int retcode = 1;
    
    if ((lppipe = popen(cmd, "w")) != NULL) {
        if ( fputs(text, lppipe) != EOF) {
            retcode = 0;
        }
        childstatus = pclose(lppipe);
        if (!WIFEXITED(childstatus) || WEXITSTATUS(childstatus) != 0) {
            retcode = 1;
        }
    }
    return retcode;
}
