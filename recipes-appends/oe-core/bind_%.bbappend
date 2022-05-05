FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://named.initd file://named.confd"

inherit openrc

OPENRC_SERVICES:${PN} = "named"

do_install:append() {
    openrc_install_initd ${WORKDIR}/named.initd
    openrc_install_confd ${WORKDIR}/named.confd
}
