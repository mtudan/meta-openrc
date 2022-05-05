FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://cronie.initd file://cronie.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${WORKDIR}/cronie.initd
    openrc_install_confd ${WORKDIR}/cronie.confd
}
