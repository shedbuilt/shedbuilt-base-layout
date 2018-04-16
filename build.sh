#!/bin/bash
if [ "$SHED_BUILD_MODE" == 'toolchain' ]; then
    echo "The base layout package should not be built in toolchain mode."
    return 1
fi

# Create essential directories, files and symlinks (from LFS 8.1)
mkdir -pv "${SHED_FAKE_ROOT}"/{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
# Create placeholder 64-bit library folder
if [[ $SHED_NATIVE_TARGET =~ ^aarch64-.* ]]; then
    mkdir -v "${SHED_FAKE_ROOT}/lib64"
fi
mkdir -pv "${SHED_FAKE_ROOT}"/{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 "${SHED_FAKE_ROOT}/root"
install -dv -m 1777 "${SHED_FAKE_ROOT}/tmp" "${SHED_FAKE_ROOT}/var/tmp"
mkdir -pv "${SHED_FAKE_ROOT}"/usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv "${SHED_FAKE_ROOT}"/usr/{,local/}share/{color,defaults,dict,doc,info,locale,man,misc,terminfo,zoneinfo}
mkdir -v  "${SHED_FAKE_ROOT}"/usr/libexec
mkdir -pv "${SHED_FAKE_ROOT}"/usr/{,local/}share/man/man{1..8}
mkdir -v  "${SHED_FAKE_ROOT}"/var/{log,mail,spool}
mkdir -pv "${SHED_FAKE_ROOT}"/var/{opt,cache,lib/{color,misc,locate},local}
touch "${SHED_FAKE_ROOT}"/var/log/{btmp,lastlog,faillog,wtmp}
chmod -v 664 "${SHED_FAKE_ROOT}/var/log/lastlog"
chmod -v 600 "${SHED_FAKE_ROOT}/var/log/btmp"
ln -sv ../run "${SHED_FAKE_ROOT}/var/run"
ln -sv ../run/lock "${SHED_FAKE_ROOT}/var/lock"
ln -sv /proc/self/mounts "${SHED_FAKE_ROOT}/etc/mtab"
# Distribution info and LSB compliance
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/os-release" "${SHED_FAKE_ROOT}/etc"
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/lsb-release" "${SHED_FAKE_ROOT}/etc"
# Default users and groups
install -dm755 "${SHED_FAKE_ROOT}/usr/share/defaults/etc"
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/passwd" "${SHED_FAKE_ROOT}/usr/share/defaults/etc"
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/group" "${SHED_FAKE_ROOT}/usr/share/defaults/etc"
# Default hostname and hosts
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/hostname" "${SHED_FAKE_ROOT}/usr/share/defaults/etc"
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/hosts" "${SHED_FAKE_ROOT}/usr/share/defaults/etc"
# Default automount config
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/fstab" "${SHED_FAKE_ROOT}/usr/share/defaults/etc"
# Default login prompt config
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/issue" "${SHED_FAKE_ROOT}/usr/share/defaults/etc"

case "$SHED_BUILD_MODE" in
    bootstrap)
        # Install default users and groups
        install -v -m644 "${SHED_PKG_CONTRIB_DIR}/passwd" "${SHED_FAKE_ROOT}/etc"
        install -v -m644 "${SHED_PKG_CONTRIB_DIR}/group" "${SHED_FAKE_ROOT}/etc"
        install -v -m644 "${SHED_PKG_CONTRIB_DIR}/hostname" "${SHED_FAKE_ROOT}/etc"
        install -v -m644 "${SHED_PKG_CONTRIB_DIR}/hosts" "${SHED_FAKE_ROOT}/etc"
        install -v -m644 "${SHED_PKG_CONTRIB_DIR}/fstab" "${SHED_FAKE_ROOT}/etc"
        install -v -m644 "${SHED_PKG_CONTRIB_DIR}/issue" "${SHED_FAKE_ROOT}/etc"

        # Create temporary symlinks for bootstrap
        ln -sv /tools/bin/{bash,cat,dd,echo,ln,pwd,rm,stty} "${SHED_FAKE_ROOT}/bin"
        ln -sv /tools/bin/{env,install,perl} "${SHED_FAKE_ROOT}/usr/bin"
        ln -sv /tools/lib/libgcc_s.so{,.1} "${SHED_FAKE_ROOT}/usr/lib"
        ln -sv /tools/lib/libstdc++.{a,so{,.6}} "${SHED_FAKE_ROOT}/usr/lib"
        for SHDPKG_LIB in blkid lzma mount uuid
        do
            ln -sv /tools/lib/lib${SHDPKG_LIB}.so* "${SHED_FAKE_ROOT}/usr/lib"
        done
        ln -svf /tools/include/blkid "${SHED_FAKE_ROOT}/usr/include"
        ln -svf /tools/include/libmount "${SHED_FAKE_ROOT}/usr/include"
        ln -svf /tools/include/uuid "${SHED_FAKE_ROOT}/usr/include"
        install -vdm755 "${SHED_FAKE_ROOT}/usr/lib/pkgconfig"
        for SHDPKG_LIB in blkid mount uuid
        do
            sed 's@tools@usr@g' /tools/lib/pkgconfig/${SHDPKG_LIB}.pc \
                > "${SHED_FAKE_ROOT}/usr/lib/pkgconfig/${SHDPKG_LIB}.pc"
        done
        ln -sv bash "${SHED_FAKE_ROOT}/bin/sh"
        ;;
    release)
        # NOTE: In 'bootstrap' this is done as a post-install step because we need
        # to install /etc/group for 'utmp' and to be found. In 'release' we do
        # this during the build instead because it will only be built from system
        # from same the same release series. This allows this package to be installed
        # without bash and its dependencies being available, which running the
        # post-install would require.
        chgrp -v utmp "${SHED_FAKE_ROOT}/var/log/lastlog"
        ;;
esac

