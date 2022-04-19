LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2307fb28847883ac2b0b110b1c1f36e0"

SRCREV = "d8e4da5e5d4d77cdd705823aa71990276a872ee1"

SRC_URI = " \
    git://github.com/openrc/openrc.git;nobranch=1 \
    file://0001-mk-break-up-long-SED_REPLACE-line.patch \
    file://0002-fix-alternative-conf-and-init-dir-support.patch \
    file://volatiles.initd \
"

S = "${WORKDIR}/git"

EXTRA_OEMAKE = " \
    PKG_PREFIX=${prefix} \
    LIBEXECDIR=${base_libdir}/rc \
    LIBNAME=lib \
    MKTOOLS=no \
    OS=Linux \
    INITDIRNAME=$(basename ${OPENRC_INITDIR}) \
    CONFDIRNAME=$(basename ${OPENRC_CONFDIR}) \
"

inherit openrc openrc-image

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

    # Example code that requires perl.
    rm -r ${D}${prefix}/share/${PN}/support/deptree2dot

    openrc_install_script ${WORKDIR}/volatiles.initd
    openrc_add_to_boot_runlevel ${D} volatiles
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

inherit update-alternatives

ALTERNATIVE_PRIORITY = "100"
ALTERNATIVE_${PN} = "start-stop-daemon"
ALTERNATIVE_LINK_NAME[start-stop-daemon] = "${base_sbindir}/start-stop-daemon"
