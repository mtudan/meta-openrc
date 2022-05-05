FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://neard.initd file://neard.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${WORKDIR}/neard.initd
    openrc_install_confd ${WORKDIR}/neard.confd
}
