#!/bin/bash
if [ ! -e /etc/hostname ]; then
    install -v -m644 /usr/share/defaults/etc/hostname /etc/hostname
fi
if [ ! -e /etc/hosts ]; then
    install -v -m644 /usr/share/defaults/etc/hosts /etc/hosts
fi
if [ ! -e /etc/fstab ]; then
    install -v -m644 /usr/share/defaults/etc/fstab /etc/fstab
fi
if [ ! -e /etc/issue ]; then
    install -v -m644 /usr/share/defaults/etc/issue /etc/issue
fi
if [ "$SHED_BUILD_MODE" == 'bootstrap' ]; then
    chgrp -v utmp /var/log/lastlog
    chmod -v 775 /var/tmp/shedmake
    chgrp -v shedmake /var/tmp/shedmake
    chgrp -v shedmake /var/shedmake
    chgrp -v shedmake /var/shedmake/template
    chgrp -v shedmake /var/shedmake/repos
    chgrp -v shedmake /var/shedmake/repos/remote
    chgrp -v shedmake /var/shedmake/repos/local
    chgrp -v shedmake /var/shedmake/repos/local/default
    chmod -v -R 775 /var/shedmake/repos/local
    chmod -v g+s /var/shedmake
    chmod -v g+s /var/shedmake/template
    chmod -v g+s /var/shedmake/repos
    chmod -v g+s /var/shedmake/repos/remote
    chmod -v g+s /var/shedmake/repos/local
    chmod -v g+s /var/shedmake/repos/local/default
fi
# HACK: Clean up duplicate symlink that results from installing over an existing system
if [ -L /run/run ]; then
    rm /run/run
fi
