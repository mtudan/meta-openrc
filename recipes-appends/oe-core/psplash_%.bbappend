FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://psplash.initd file://psplash.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${WORKDIR}/psplash.initd
    openrc_install_confd ${WORKDIR}/psplash.confd
}
