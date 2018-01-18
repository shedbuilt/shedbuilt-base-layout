#!/bin/bash
if [ "$SHED_BUILDMODE" == 'bootstrap' ]; then
    chgrp -v utmp /var/log/lastlog
fi
