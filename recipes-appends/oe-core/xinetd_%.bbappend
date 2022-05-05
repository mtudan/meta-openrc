FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://xinetd.initd file://xinetd.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${WORKDIR}/xinetd.initd
    openrc_install_confd ${WORKDIR}/xinetd.confd
}
