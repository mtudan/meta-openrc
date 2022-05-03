LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2307fb28847883ac2b0b110b1c1f36e0"

SRCREV = "0053bc4198f584574dfa609ccdeceaef4e2f9be1"

SRC_URI = " \
    git://github.com/openrc/openrc.git;nobranch=1;protocol=https \
    file://volatiles.initd \
"

S = "${WORKDIR}/git"

inherit meson

PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'audit pam selinux usrmerge', d)}"

PACKAGECONFIG[audit] = "-Daudit=enabled,-Daudit=disabled,audit"
PACKAGECONFIG[bash-completions] = "-Dbash-completions=true,-Dbash-completions=false,bash-completion"
PACKAGECONFIG[pam] = "-Dpam=true,-Dpam=false,libpam"
PACKAGECONFIG[selinux] = "-Dselinux=enabled,-Dselinux=disabled,libselinux"
PACKAGECONFIG[usrmerge] = "-Dsplit-usr=false,-Dsplit-usr=true"
PACKAGECONFIG[zsh-completions] = "-Dzsh-completions=true,-Dzsh-completions=false"

EXTRA_OEMESON += " \
    -Dos=Linux \
    -Dpkg_prefix=${prefix} \
"

do_install:append() {
    # Default sysvinit doesn't do anything with keymaps on a minimal install so
    # we're not going to either.
    rm ${D}${sysconfdir}/runlevels/*/keymaps

    install -m 755 ${WORKDIR}/volatiles.initd ${D}${OPENRC_INITDIR}/volatiles
    ln -snf ${OPENRC_INITDIR}/volatiles ${D}${sysconfdir}/runlevels/boot

    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/openrc
        mv ${D}${OPENRC_INITDIR} ${D}${sysconfdir}/openrc/$(basename ${OPENRC_INITDIR})
    fi
}

RDEPENDS:${PN} = " \
    kbd \
    ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'openrc-inittab', '', d)} \
    procps-sysctl \
    sysvinit \
    util-linux-mount \
    util-linux-umount \
"

FILES:${PN}-dbg:append = " \
    ${base_libdir}/rc/bin/.debug \
    ${base_libdir}/rc/sbin/.debug \
"
FILES:${PN}-doc:append = " ${datadir}/${BPN}/support"
FILES:${PN}:append = " ${base_libdir}/rc/"

inherit update-alternatives

ALTERNATIVE_PRIORITY = "100"
ALTERNATIVE:${PN} = "start-stop-daemon"
ALTERNATIVE_LINK_NAME[start-stop-daemon] = "${base_sbindir}/start-stop-daemon"
