#!/bin/bash
# Create essential directories, files and symlinks (from LFS 8.1)
mkdir -pv ${SHED_FAKEROOT}/{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
mkdir -pv ${SHED_FAKEROOT}/{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 ${SHED_FAKEROOT}/root
install -dv -m 1777 ${SHED_FAKEROOT}/tmp ${SHED_FAKEROOT}/var/tmp
mkdir -pv ${SHED_FAKEROOT}/usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv ${SHED_FAKEROOT}/usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -v  ${SHED_FAKEROOT}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -v  ${SHED_FAKEROOT}/usr/libexec
mkdir -pv ${SHED_FAKEROOT}/usr/{,local/}share/man/man{1..8}
mkdir -v ${SHED_FAKEROOT}/var/{log,mail,spool}
ln -sv ../run ${SHED_FAKEROOT}/var/run
ln -sv ../run/lock ${SHED_FAKEROOT}/var/lock
mkdir -pv ${SHED_FAKEROOT}/var/{opt,cache,lib/{color,misc,locate},local}
ln -sv /proc/self/mounts ${SHED_FAKEROOT}/etc/mtab
install -v -m644 ${SHED_CONTRIBDIR}/passwd ${SHED_FAKEROOT}/etc/passwd
install -v -m644 ${SHED_CONTRIBDIR}/group ${SHED_FAKEROOT}/etc/group
touch ${SHED_FAKEROOT}/var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp ${SHED_FAKEROOT}/var/log/lastlog
chmod -v 664  ${SHED_FAKEROOT}/var/log/lastlog
chmod -v 600  ${SHED_FAKEROOT}/var/log/btmp
