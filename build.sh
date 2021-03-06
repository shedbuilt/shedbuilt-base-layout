#!/bin/bash
if [ "$SHED_BUILDMODE" == 'toolchain' ]; then
    echo "The base layout package should not be built in toolchain mode."
    return 1
fi

# Create essential directories, files and symlinks (from LFS 8.1)
mkdir -pv "${SHED_FAKEROOT}"/{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
# Create placeholder 64-bit library folder
if [[ $SHED_NATIVE_TARGET =~ ^aarch64-.* ]]; then
    mkdir -v "${SHED_FAKEROOT}/lib64"
fi
mkdir -pv "${SHED_FAKEROOT}"/{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 "${SHED_FAKEROOT}/root"
install -dv -m 1777 "${SHED_FAKEROOT}/tmp" "${SHED_FAKEROOT}/var/tmp"
mkdir -pv "${SHED_FAKEROOT}"/usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv "${SHED_FAKEROOT}"/usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -v  "${SHED_FAKEROOT}"/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -v  "${SHED_FAKEROOT}"/usr/libexec
mkdir -pv "${SHED_FAKEROOT}"/usr/{,local/}share/man/man{1..8}
mkdir -v  "${SHED_FAKEROOT}"/var/{log,mail,spool}
mkdir -pv "${SHED_FAKEROOT}"/var/{opt,cache,lib/{color,misc,locate},local}
touch "${SHED_FAKEROOT}"/var/log/{btmp,lastlog,faillog,wtmp}
chmod -v 664 "${SHED_FAKEROOT}/var/log/lastlog"
chmod -v 600 "${SHED_FAKEROOT}/var/log/btmp"
ln -sv ../run "${SHED_FAKEROOT}/var/run"
ln -sv ../run/lock "${SHED_FAKEROOT}/var/lock"
ln -sv /proc/self/mounts "${SHED_FAKEROOT}/etc/mtab"
install -v -m644 "${SHED_CONTRIBDIR}/passwd" "${SHED_FAKEROOT}/etc/passwd.default"
install -v -m644 "${SHED_CONTRIBDIR}/group" "${SHED_FAKEROOT}/etc/group.default"

case "$SHED_BUILDMODE" in
    bootstrap)
        # Install default users and groups
        install -v -m644 "${SHED_CONTRIBDIR}/passwd" "${SHED_FAKEROOT}/etc/passwd"
        install -v -m644 "${SHED_CONTRIBDIR}/group" "${SHED_FAKEROOT}/etc/group"

        # Create temporary symlinks for bootstrap
        ln -sv /tools/bin/{bash,cat,dd,echo,ln,pwd,rm,stty} "${SHED_FAKEROOT}/bin"
        ln -sv /tools/bin/{env,install,perl} "${SHED_FAKEROOT}/usr/bin"
        ln -sv /tools/lib/libgcc_s.so{,.1} "${SHED_FAKEROOT}/usr/lib"
        ln -sv /tools/lib/libstdc++.{a,so{,.6}} "${SHED_FAKEROOT}/usr/lib"
        for SHDPKG_LIB in blkid lzma mount uuid
        do
            ln -sv /tools/lib/lib${SHDPKG_LIB}.so* "${SHED_FAKEROOT}/usr/lib"
        done
        ln -svf /tools/include/blkid "${SHED_FAKEROOT}/usr/include"
        ln -svf /tools/include/libmount "${SHED_FAKEROOT}/usr/include"
        ln -svf /tools/include/uuid "${SHED_FAKEROOT}/usr/include"
        install -vdm755 "${SHED_FAKEROOT}/usr/lib/pkgconfig"
        for SHDPKG_LIB in blkid mount uuid
        do
            sed 's@tools@usr@g' /tools/lib/pkgconfig/${SHDPKG_LIB}.pc \
                > "${SHED_FAKEROOT}/usr/lib/pkgconfig/${SHDPKG_LIB}.pc"
        done
        ln -sv bash "${SHED_FAKEROOT}/bin/sh"
        ;;
    release)
        # NOTE: In 'bootstrap' this is done as a post-install step because we need
        # to install /etc/group for 'utmp' and to be found. In 'release' we do
        # this during the build instead because it will only be built from system
        # from same the same release series. This allows this package to be installed
        # without bash and its dependencies being available, which running the
        # post-install would require.
        chgrp -v utmp "${SHED_FAKEROOT}/var/log/lastlog"
        ;;
esac

