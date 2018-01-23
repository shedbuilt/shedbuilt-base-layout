#!/bin/bash
# HACK: Clean up duplicate symlink that results from installing over an existing system
if [ -L /run/run ]; then
    rm /run/run
fi
# Install default passwd and group files, if necessary
if [ ! -e /etc/passwd ]; then
    install -v -m644 /etc/passwd.default /etc/passwd
fi
if [ ! -e /etc/group ]; then
    install -v -m644 /etc/group.default /etc/group
fi
if [ "$SHED_BUILDMODE" == 'bootstrap' ]; then
    chgrp -v utmp /var/log/lastlog
fi

