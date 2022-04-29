RDEPENDS:${PN}:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'sysvinit-inittab initrd-functions', '', d)}"

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        rm -f ${D}${sysconfdir}/init.d/*
    fi
}
