#!/bin/bash
# Install default passwd and group files, if necessary
if [ ! -e /etc/passwd ]; then
    install -v -m644 /etc/passwd.default /etc/passwd
fi
if [ ! -e /etc/group ]; then
    install -v -m644 /etc/group.default /etc/group
fi
if [ "$SHED_BUILD_MODE" == 'bootstrap' ]; then
    chgrp -v utmp /var/log/lastlog
    chgrp -v shedmake /var/shedmake
    chgrp -v shedmake /var/shedmake/template
    chgrp -v shedmake /var/shedmake/repos
    chgrp -v shedmake /var/shedmake/repos/remote
    chgrp -v shedmake /var/shedmake/repos/remote/system
    chgrp -v shedmake /var/shedmake/repos/local
    chgrp -v shedmake /var/shedmake/repos/local/default
    chmod -v -R 775 /var/shedmake/repos/local
    chmod -v g+s /var/shedmake
    chmod -v g+s /var/shedmake/template
    chmod -v g+s /var/shedmake/repos
    chmod -v g+s /var/shedmake/repos/remote
    chmod -v g+s /var/shedmake/repos/remote/system
    chmod -v g+s /var/shedmake/repos/local
    chmod -v g+s /var/shedmake/repos/local/default
fi
# HACK: Clean up duplicate symlink that results from installing over an existing system
if [ -L /run/run ]; then
    rm /run/run
fi
