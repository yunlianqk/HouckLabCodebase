% CLEAR BUFFER
fprintf(k2400,':TRAC:FEED:CONT NEVER'); %necessary before clearing buffer, avoid +800 error
fprintf(k2400,':TRAC:CLE'); %clear buffer