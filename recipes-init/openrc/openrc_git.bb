LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2307fb28847883ac2b0b110b1c1f36e0"

PV = "0.20.4"
SRCREV = "${PV}"
#PR = "0"

SRC_URI = " \
    git://github.com/openrc/openrc.git;nobranch=1 \
    file://librc-sh-respect-alternative-INITDIR.patch \
"
# submitted upstream, https://github.com/OpenRC/openrc/pull/82

S = "${WORKDIR}/git"

EXTRA_OEMAKE = " \
    PKG_PREFIX=${prefix} \
    LIBEXECDIR=${base_libdir}/rc \
    LIBNAME=lib \
    MKTOOLS=no \
    OS=Linux \
    INITDIR=${OPENRC_INITDIR} \
    CONFDIR=${OPENRC_CONFDIR} \
"

openrc_do_patch() {
    # QA[useless-rpaths]: We don't need an rpath to /lib
    sed -i '/-rpath=/d' ${S}/mk/prog.mk

    # Support busybox swapon
    sed -i 's|swapon -a -e|swapon -a|' ${S}/init.d/swap.in

    # - Drop keymaps from default runlevel
    # - Drop netmount from default runlevel, requires umount -O
    #       https://bugs.busybox.net/show_bug.cgi?id=8566
    sed -i \
        -e 's| keymaps | |' \
        -e 's|^\(DEFAULT=.*\) netmount|\1|' \
        ${S}/runlevels/Makefile
}

do_patch_append() {
    bb.build.exec_func('openrc_do_patch', d)
}

do_install() {
    oe_runmake DESTDIR=${D} install
}

RDEPENDS_${PN} := " \
    sysvinit \
"

FILES_${PN}-dbg_append := " \
    ${base_libdir}/rc/bin/.debug \
    ${base_libdir}/rc/sbin/.debug \
"

FILES_${PN}_append := " \
    ${base_libdir}/rc/* \
"

